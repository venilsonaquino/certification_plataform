begin;

create table public.user_flashcard_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  flashcard_id uuid not null references public.flashcards(id) on delete cascade,
  last_rating text,
  review_count integer not null default 0,
  successful_review_count integer not null default 0,
  interval_days integer not null default 0,
  next_review_at timestamptz,
  last_reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_flashcard_progress_user_card_unique unique (user_id, flashcard_id),
  constraint user_flashcard_progress_last_rating_check
    check (last_rating is null or last_rating in ('again', 'hard', 'good', 'easy')),
  constraint user_flashcard_progress_review_count_check check (review_count >= 0),
  constraint user_flashcard_progress_successful_count_check
    check (successful_review_count >= 0 and successful_review_count <= review_count),
  constraint user_flashcard_progress_interval_check check (interval_days between 0 and 90),
  constraint user_flashcard_progress_state_check check (
    (
      review_count = 0
      and last_rating is null
      and successful_review_count = 0
      and interval_days = 0
      and next_review_at is null
      and last_reviewed_at is null
    )
    or (
      review_count > 0
      and last_rating is not null
      and interval_days between 1 and 90
      and next_review_at is not null
      and last_reviewed_at is not null
    )
  )
);

create index user_flashcard_progress_user_due_idx
  on public.user_flashcard_progress (user_id, next_review_at)
  where next_review_at is not null;

create index user_flashcard_progress_flashcard_idx
  on public.user_flashcard_progress (flashcard_id);

create trigger user_flashcard_progress_set_updated_at
before update on public.user_flashcard_progress
for each row execute function public.set_updated_at();

alter table public.user_flashcard_progress enable row level security;

create policy "Users can read their own flashcard progress"
on public.user_flashcard_progress for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can insert their own flashcard progress"
on public.user_flashcard_progress for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can update their own flashcard progress"
on public.user_flashcard_progress for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

revoke all on table public.user_flashcard_progress from anon, authenticated;
grant select on table public.user_flashcard_progress to authenticated;

create function public.calculate_flashcard_interval(
  p_current_interval integer,
  p_rating text
)
returns integer
language plpgsql
immutable
set search_path = ''
as $$
declare
  max_review_interval_days constant integer := 90;
  current_interval integer := greatest(coalesce(p_current_interval, 0), 0);
begin
  if p_rating is null or p_rating not in ('again', 'hard', 'good', 'easy') then
    raise exception 'Invalid flashcard review rating.' using errcode = '23514';
  end if;

  return least(
    max_review_interval_days,
    case p_rating
      when 'again' then 1
      when 'hard' then greatest(2, round(current_interval * 1.5)::integer)
      when 'good' then greatest(4, round(current_interval * 2.0)::integer)
      when 'easy' then greatest(7, round(current_interval * 2.5)::integer)
    end
  );
end;
$$;

with review_totals as (
  select
    user_id,
    flashcard_id,
    count(*)::integer as review_count,
    count(*) filter (where rating in ('good', 'easy'))::integer as successful_review_count
  from public.flashcard_reviews
  group by user_id, flashcard_id
),
latest_reviews as (
  select distinct on (user_id, flashcard_id)
    user_id,
    flashcard_id,
    rating,
    reviewed_at
  from public.flashcard_reviews
  order by user_id, flashcard_id, reviewed_at desc, created_at desc, id desc
)
insert into public.user_flashcard_progress (
  user_id,
  flashcard_id,
  last_rating,
  review_count,
  successful_review_count,
  interval_days,
  next_review_at,
  last_reviewed_at
)
select
  totals.user_id,
  totals.flashcard_id,
  latest.rating,
  totals.review_count,
  totals.successful_review_count,
  public.calculate_flashcard_interval(0, latest.rating),
  latest.reviewed_at + make_interval(days => public.calculate_flashcard_interval(0, latest.rating)),
  latest.reviewed_at
from review_totals totals
join latest_reviews latest
  on latest.user_id = totals.user_id
  and latest.flashcard_id = totals.flashcard_id
on conflict (user_id, flashcard_id) do nothing;

drop function public.submit_flashcard_review(uuid, text);

create function public.submit_flashcard_review(
  p_flashcard_id uuid,
  p_rating text
)
returns table (
  review_id uuid,
  review_user_id uuid,
  review_flashcard_id uuid,
  rating text,
  reviewed_at timestamptz,
  review_created_at timestamptz,
  progress_id uuid,
  last_rating text,
  review_count integer,
  successful_review_count integer,
  interval_days integer,
  next_review_at timestamptz,
  last_reviewed_at timestamptz,
  progress_created_at timestamptz,
  progress_updated_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
  reviewed_timestamp timestamptz := clock_timestamp();
  current_progress public.user_flashcard_progress;
  inserted_review public.flashcard_reviews;
  updated_progress public.user_flashcard_progress;
  new_interval integer;
begin
  if current_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  if p_rating is null or p_rating not in ('again', 'hard', 'good', 'easy') then
    raise exception 'Invalid flashcard review rating.' using errcode = '23514';
  end if;

  if not exists (
    select 1
    from public.flashcards
    where id = p_flashcard_id
      and is_published = true
  ) then
    raise exception 'Published flashcard not found.' using errcode = 'P0002';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(current_user_id::text || ':' || p_flashcard_id::text, 0)
  );

  select *
  into current_progress
  from public.user_flashcard_progress progress
  where progress.user_id = current_user_id
    and progress.flashcard_id = p_flashcard_id
  for update;

  new_interval := public.calculate_flashcard_interval(
    coalesce(current_progress.interval_days, 0),
    p_rating
  );

  insert into public.flashcard_reviews (
    user_id,
    flashcard_id,
    rating,
    reviewed_at
  )
  values (
    current_user_id,
    p_flashcard_id,
    p_rating,
    reviewed_timestamp
  )
  returning * into inserted_review;

  insert into public.user_flashcard_progress (
    user_id,
    flashcard_id,
    last_rating,
    review_count,
    successful_review_count,
    interval_days,
    next_review_at,
    last_reviewed_at
  )
  values (
    current_user_id,
    p_flashcard_id,
    p_rating,
    1,
    case when p_rating in ('good', 'easy') then 1 else 0 end,
    new_interval,
    reviewed_timestamp + make_interval(days => new_interval),
    reviewed_timestamp
  )
  on conflict (user_id, flashcard_id) do update set
    last_rating = excluded.last_rating,
    review_count = public.user_flashcard_progress.review_count + 1,
    successful_review_count = public.user_flashcard_progress.successful_review_count
      + case when excluded.last_rating in ('good', 'easy') then 1 else 0 end,
    interval_days = excluded.interval_days,
    next_review_at = excluded.next_review_at,
    last_reviewed_at = excluded.last_reviewed_at
  returning * into updated_progress;

  return query select
    inserted_review.id,
    inserted_review.user_id,
    inserted_review.flashcard_id,
    inserted_review.rating,
    inserted_review.reviewed_at,
    inserted_review.created_at,
    updated_progress.id,
    updated_progress.last_rating,
    updated_progress.review_count,
    updated_progress.successful_review_count,
    updated_progress.interval_days,
    updated_progress.next_review_at,
    updated_progress.last_reviewed_at,
    updated_progress.created_at,
    updated_progress.updated_at;
end;
$$;

create function public.get_flashcard_study_queue(
  p_certification_id uuid,
  p_limit integer default 20,
  p_new_limit integer default 5
)
returns table (
  id uuid,
  lesson_id uuid,
  lesson_title text,
  lesson_slug text,
  front_text text,
  back_text text,
  hint text,
  display_order integer,
  is_published boolean,
  created_at timestamptz,
  updated_at timestamptz,
  review_status text,
  next_review_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
  queue_limit integer := least(greatest(coalesce(p_limit, 20), 1), 100);
  new_card_limit integer := least(greatest(coalesce(p_new_limit, 5), 0), queue_limit);
begin
  if current_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  if not exists (select 1 from public.certifications where certifications.id = p_certification_id) then
    raise exception 'Certification not found.' using errcode = 'P0002';
  end if;

  return query
  with eligible_cards as (
    select
      flashcards.*,
      lessons.title as lesson_title,
      lessons.slug as lesson_slug,
      domains.display_order as domain_order,
      topics.display_order as topic_order,
      lessons.display_order as lesson_order,
      progress.next_review_at,
      progress.id as progress_id
    from public.flashcards
    join public.lessons on lessons.id = flashcards.lesson_id
    join public.topics on topics.id = lessons.topic_id
    join public.domains on domains.id = topics.domain_id
    left join public.user_flashcard_progress progress
      on progress.flashcard_id = flashcards.id
      and progress.user_id = current_user_id
    where domains.certification_id = p_certification_id
      and lessons.is_published = true
      and flashcards.is_published = true
  ),
  due_cards as (
    select eligible.*,
      row_number() over (
        order by eligible.next_review_at asc, eligible.domain_order, eligible.topic_order,
          eligible.lesson_order, eligible.display_order, eligible.id
      )::integer as queue_order
    from eligible_cards eligible
    where eligible.progress_id is not null
      and eligible.next_review_at <= clock_timestamp()
    order by eligible.next_review_at asc, eligible.domain_order, eligible.topic_order,
      eligible.lesson_order, eligible.display_order, eligible.id
    limit queue_limit
  ),
  due_total as (
    select count(*)::integer as count from due_cards
  ),
  new_cards as (
    select eligible.*,
      (select count from due_total) + row_number() over (
        order by eligible.domain_order, eligible.topic_order, eligible.lesson_order,
          eligible.display_order, eligible.id
      )::integer as queue_order
    from eligible_cards eligible
    where eligible.progress_id is null
    order by eligible.domain_order, eligible.topic_order, eligible.lesson_order,
      eligible.display_order, eligible.id
    limit least(new_card_limit, greatest(queue_limit - (select count from due_total), 0))
  ),
  queue as (
    select due.*, 'due'::text as review_status from due_cards due
    union all
    select fresh.*, 'new'::text as review_status from new_cards fresh
  )
  select
    queue.id,
    queue.lesson_id,
    queue.lesson_title,
    queue.lesson_slug,
    queue.front_text,
    queue.back_text,
    queue.hint,
    queue.display_order,
    queue.is_published,
    queue.created_at,
    queue.updated_at,
    queue.review_status,
    queue.next_review_at
  from queue
  order by queue.queue_order;
end;
$$;

create function public.get_flashcard_review_overview(
  p_certification_id uuid
)
returns table (
  queue_count integer,
  next_review_at timestamptz,
  available_flashcard_count integer
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  return query
  select
    (select count(*)::integer from public.get_flashcard_study_queue(p_certification_id)) as queue_count,
    min(progress.next_review_at) filter (where progress.next_review_at > clock_timestamp()) as next_review_at,
    count(distinct flashcards.id)::integer as available_flashcard_count
  from public.flashcards
  join public.lessons on lessons.id = flashcards.lesson_id
  join public.topics on topics.id = lessons.topic_id
  join public.domains on domains.id = topics.domain_id
  left join public.user_flashcard_progress progress
    on progress.flashcard_id = flashcards.id
    and progress.user_id = current_user_id
  where domains.certification_id = p_certification_id
    and lessons.is_published = true
    and flashcards.is_published = true;
end;
$$;

revoke execute on function public.calculate_flashcard_interval(integer, text) from public, anon, authenticated;
revoke execute on function public.submit_flashcard_review(uuid, text) from public, anon;
revoke execute on function public.get_flashcard_study_queue(uuid, integer, integer) from public, anon;
revoke execute on function public.get_flashcard_review_overview(uuid) from public, anon;

grant execute on function public.submit_flashcard_review(uuid, text) to authenticated;
grant execute on function public.get_flashcard_study_queue(uuid, integer, integer) to authenticated;
grant execute on function public.get_flashcard_review_overview(uuid) to authenticated;

commit;

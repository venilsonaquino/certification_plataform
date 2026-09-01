begin;

create function public.is_flashcard_available(p_flashcard_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select auth.uid() is not null and exists (
    select 1
    from public.flashcards flashcard
    join public.lessons lesson on lesson.id = flashcard.lesson_id
    where flashcard.id = p_flashcard_id
      and flashcard.is_published = true
      and lesson.is_published = true
      and (
        exists (
          select 1 from public.user_lesson_progress lesson_progress
          where lesson_progress.user_id = auth.uid()
            and lesson_progress.lesson_id = lesson.id
            and lesson_progress.status = 'completed'
        )
        or exists (
          select 1 from public.user_flashcard_progress card_progress
          where card_progress.user_id = auth.uid()
            and card_progress.flashcard_id = flashcard.id
        )
      )
  );
$$;

create or replace function public.get_flashcard_study_queue(
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
  if not exists (select 1 from public.certifications where id = p_certification_id) then
    raise exception 'Certification not found.' using errcode = 'P0002';
  end if;

  return query
  with eligible_cards as (
    select
      flashcard.*,
      lesson.title as lesson_title,
      lesson.slug as lesson_slug,
      domain.display_order as domain_order,
      topic.display_order as topic_order,
      lesson.display_order as lesson_order,
      card_progress.next_review_at,
      card_progress.id as progress_id
    from public.flashcards flashcard
    join public.lessons lesson on lesson.id = flashcard.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    left join public.user_flashcard_progress card_progress
      on card_progress.flashcard_id = flashcard.id
     and card_progress.user_id = current_user_id
    where domain.certification_id = p_certification_id
      and lesson.is_published = true
      and flashcard.is_published = true
      and (
        exists (
          select 1 from public.user_lesson_progress lesson_progress
          where lesson_progress.user_id = current_user_id
            and lesson_progress.lesson_id = lesson.id
            and lesson_progress.status = 'completed'
        )
        or card_progress.id is not null
      )
  ),
  due_cards as (
    select eligible.*,
      row_number() over (
        order by eligible.next_review_at, eligible.domain_order, eligible.topic_order,
          eligible.lesson_order, eligible.display_order, eligible.id
      )::integer as queue_order
    from eligible_cards eligible
    where eligible.progress_id is not null
      and eligible.next_review_at <= clock_timestamp()
    order by eligible.next_review_at, eligible.domain_order, eligible.topic_order,
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
    queue.id, queue.lesson_id, queue.lesson_title, queue.lesson_slug,
    queue.front_text, queue.back_text, queue.hint, queue.display_order,
    queue.is_published, queue.created_at, queue.updated_at,
    queue.review_status, queue.next_review_at
  from queue
  order by queue.queue_order;
end;
$$;

drop function public.get_flashcard_review_overview(uuid);

create function public.get_flashcard_review_overview(p_certification_id uuid)
returns table (
  queue_count integer,
  due_count integer,
  new_count integer,
  next_review_at timestamptz,
  available_flashcard_count integer,
  total_flashcard_count integer
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
  with queue as (
    select * from public.get_flashcard_study_queue(p_certification_id)
  ),
  catalog as (
    select flashcard.id, card_progress.next_review_at,
      (lesson_progress.status = 'completed' or card_progress.id is not null) as available
    from public.flashcards flashcard
    join public.lessons lesson on lesson.id = flashcard.lesson_id and lesson.is_published = true
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    left join public.user_lesson_progress lesson_progress
      on lesson_progress.lesson_id = lesson.id
     and lesson_progress.user_id = current_user_id
    left join public.user_flashcard_progress card_progress
      on card_progress.flashcard_id = flashcard.id
     and card_progress.user_id = current_user_id
    where domain.certification_id = p_certification_id
      and flashcard.is_published = true
  )
  select
    (select count(*)::integer from queue),
    (select count(*)::integer from queue where review_status = 'due'),
    (select count(*)::integer from queue where review_status = 'new'),
    min(catalog.next_review_at) filter (
      where catalog.available and catalog.next_review_at > clock_timestamp()
    ),
    count(*) filter (where catalog.available)::integer,
    count(*)::integer
  from catalog;
end;
$$;

create function public.get_flashcard_catalog_overview(p_certification_id uuid)
returns table (
  domain_id uuid,
  domain_title text,
  domain_display_order integer,
  topic_id uuid,
  topic_title text,
  topic_display_order integer,
  available_flashcard_count integer,
  total_flashcard_count integer,
  studied_flashcard_count integer
)
language plpgsql
security definer
set search_path = ''
stable
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  return query
  select
    domain.id,
    domain.title,
    domain.display_order,
    topic.id,
    topic.title,
    topic.display_order,
    count(flashcard.id) filter (
      where lesson_progress.status = 'completed' or card_progress.id is not null
    )::integer,
    count(flashcard.id)::integer,
    count(flashcard.id) filter (where card_progress.id is not null)::integer
  from public.domains domain
  join public.topics topic on topic.domain_id = domain.id
  left join public.lessons lesson
    on lesson.topic_id = topic.id and lesson.is_published = true
  left join public.flashcards flashcard
    on flashcard.lesson_id = lesson.id and flashcard.is_published = true
  left join public.user_lesson_progress lesson_progress
    on lesson_progress.lesson_id = lesson.id
   and lesson_progress.user_id = current_user_id
  left join public.user_flashcard_progress card_progress
    on card_progress.flashcard_id = flashcard.id
   and card_progress.user_id = current_user_id
  where domain.certification_id = p_certification_id
  group by domain.id, domain.title, domain.display_order,
    topic.id, topic.title, topic.display_order
  order by domain.display_order, domain.id, topic.display_order, topic.id;
end;
$$;

create function public.get_available_flashcards(
  p_certification_id uuid,
  p_topic_id uuid default null,
  p_lesson_id uuid default null
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
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = ''
stable
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;
  if (p_topic_id is null) = (p_lesson_id is null) then
    raise exception 'Exactly one Flashcard scope is required.' using errcode = '22023';
  end if;

  return query
  select
    flashcard.id, flashcard.lesson_id, lesson.title, lesson.slug,
    flashcard.front_text, flashcard.back_text, flashcard.hint,
    flashcard.display_order, flashcard.is_published,
    flashcard.created_at, flashcard.updated_at
  from public.flashcards flashcard
  join public.lessons lesson on lesson.id = flashcard.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  left join public.user_flashcard_progress card_progress
    on card_progress.flashcard_id = flashcard.id
   and card_progress.user_id = current_user_id
  where domain.certification_id = p_certification_id
    and (p_topic_id is null or topic.id = p_topic_id)
    and (p_lesson_id is null or lesson.id = p_lesson_id)
    and lesson.is_published = true
    and flashcard.is_published = true
    and (
      exists (
        select 1 from public.user_lesson_progress lesson_progress
        where lesson_progress.user_id = current_user_id
          and lesson_progress.lesson_id = lesson.id
          and lesson_progress.status = 'completed'
      )
      or card_progress.id is not null
    )
  order by lesson.display_order, lesson.id, flashcard.display_order, flashcard.id;
end;
$$;

alter function public.submit_flashcard_review(uuid, text)
  rename to submit_flashcard_review_unchecked;
revoke execute on function public.submit_flashcard_review_unchecked(uuid, text)
  from public, anon, authenticated;

create function public.submit_flashcard_review(p_flashcard_id uuid, p_rating text)
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
begin
  if auth.uid() is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;
  if not public.is_flashcard_available(p_flashcard_id) then
    raise exception 'Flashcard is locked. Complete its Lesson first.' using errcode = 'P0001';
  end if;
  return query select * from public.submit_flashcard_review_unchecked(p_flashcard_id, p_rating);
end;
$$;

revoke execute on function public.is_flashcard_available(uuid) from public, anon;
revoke execute on function public.get_flashcard_catalog_overview(uuid) from public, anon;
revoke execute on function public.get_available_flashcards(uuid, uuid, uuid) from public, anon;
revoke execute on function public.get_flashcard_review_overview(uuid) from public, anon;
revoke execute on function public.submit_flashcard_review(uuid, text) from public, anon;
grant execute on function public.is_flashcard_available(uuid) to authenticated;
grant execute on function public.get_flashcard_catalog_overview(uuid) to authenticated;
grant execute on function public.get_available_flashcards(uuid, uuid, uuid) to authenticated;
grant execute on function public.get_flashcard_review_overview(uuid) to authenticated;
grant execute on function public.submit_flashcard_review(uuid, text) to authenticated;

commit;

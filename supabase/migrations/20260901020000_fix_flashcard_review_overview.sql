begin;

create or replace function public.get_flashcard_review_overview(p_certification_id uuid)
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
stable
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  return query
  with catalog as (
    select
      card.id,
      progress.id as progress_id,
      progress.next_review_at as scheduled_at,
      (lesson_progress.status = 'completed' or progress.id is not null) as available
    from public.flashcards card
    join public.lessons lesson
      on lesson.id = card.lesson_id
     and lesson.is_published = true
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    left join public.user_lesson_progress lesson_progress
      on lesson_progress.lesson_id = lesson.id
     and lesson_progress.user_id = current_user_id
    left join public.user_flashcard_progress progress
      on progress.flashcard_id = card.id
     and progress.user_id = current_user_id
    where domain.certification_id = p_certification_id
      and card.is_published = true
  ),
  totals as (
    select
      count(*) filter (
        where available and progress_id is not null
          and scheduled_at <= clock_timestamp()
      )::integer as due_total,
      count(*) filter (
        where available and progress_id is null
      )::integer as new_total,
      min(scheduled_at) filter (
        where available and scheduled_at > clock_timestamp()
      ) as next_scheduled_at,
      count(*) filter (where available)::integer as available_total,
      count(*)::integer as catalog_total
    from catalog
  ),
  limited as (
    select
      least(due_total, 20) as due_limited,
      least(new_total, 5, greatest(20 - least(due_total, 20), 0)) as new_limited,
      next_scheduled_at,
      available_total,
      catalog_total
    from totals
  )
  select
    due_limited + new_limited,
    due_limited,
    new_limited,
    next_scheduled_at,
    available_total,
    catalog_total
  from limited;
end;
$$;

revoke execute on function public.get_flashcard_review_overview(uuid)
  from public, anon;
grant execute on function public.get_flashcard_review_overview(uuid)
  to authenticated;

-- Execute the production RPC with an authenticated fixture. The forced custom
-- exception rolls back only this nested block, leaving no fixture data behind.
do $$
declare
  certification_uuid uuid;
  lesson_uuid uuid;
  overview record;
begin
  begin
    select certification.id into strict certification_uuid
    from public.certifications certification
    where certification.code = 'az-900';

    select lesson.id into strict lesson_uuid
    from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    where domain.certification_id = certification_uuid
      and lesson.is_published = true
    order by domain.display_order, topic.display_order, lesson.display_order
    limit 1;

    insert into auth.users(
      instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
      raw_app_meta_data,raw_user_meta_data,created_at,updated_at
    ) values (
      '00000000-0000-0000-0000-000000000000',
      '58000000-0000-4000-8000-000000000071',
      'authenticated','authenticated','flashcard-overview-fix@example.invalid','',now(),
      '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()
    );

    insert into public.user_lesson_progress(
      user_id,lesson_id,status,started_at,completed_at,last_accessed_at
    ) values (
      '58000000-0000-4000-8000-000000000071', lesson_uuid,
      'completed',now(),now(),now()
    );

    perform set_config(
      'request.jwt.claim.sub',
      '58000000-0000-4000-8000-000000000071',
      true
    );

    select * into strict overview
    from public.get_flashcard_review_overview(certification_uuid);

    if overview.queue_count < 1 or overview.queue_count > 5
      or overview.due_count <> 0
      or overview.new_count <> overview.queue_count
      or overview.available_flashcard_count < overview.queue_count
      or overview.total_flashcard_count <> 397 then
      raise exception '13.5.2.1 flashcard review overview regression failed';
    end if;

    raise exception 'fixture rollback' using errcode = 'ZX001';
  exception when sqlstate 'ZX001' then
    null;
  end;
end;
$$;

commit;

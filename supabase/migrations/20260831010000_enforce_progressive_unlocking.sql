begin;

-- Availability remains derived. These predicates are the server-side counterpart
-- of the client domain resolver; no persisted unlock flag is introduced.
create function public.is_lesson_available(p_lesson_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  with target_certification as (
    select domain.certification_id
    from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    where lesson.id = p_lesson_id
      and lesson.is_published = true
  ),
  ordered_topics as (
    select
      topic.id,
      row_number() over (
        order by domain.display_order, domain.id, topic.display_order, topic.id
      ) as topic_position
    from public.topics topic
    join public.domains domain on domain.id = topic.domain_id
    join target_certification target on target.certification_id = domain.certification_id
  ),
  curriculum as (
    select
      lesson.id,
      lesson.topic_id,
      ordered_topics.topic_position,
      row_number() over (
        order by domain.display_order, domain.id, topic.display_order, topic.id,
          lesson.display_order, lesson.id
      ) as lesson_position,
      row_number() over (
        partition by topic.id order by lesson.display_order, lesson.id
      ) as lesson_in_topic
    from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join ordered_topics on ordered_topics.id = topic.id
    where lesson.is_published = true
  ),
  target as (
    select * from curriculum where id = p_lesson_id
  )
  select auth.uid() is not null and exists (select 1 from target) and (
    exists (select 1 from target where lesson_position = 1)
    or exists (
      select 1
      from target
      join curriculum previous
        on previous.topic_id = target.topic_id
       and previous.lesson_in_topic = target.lesson_in_topic - 1
      join public.user_lesson_progress progress
        on progress.lesson_id = previous.id
       and progress.user_id = auth.uid()
       and progress.status = 'completed'
    )
    or exists (
      select 1
      from target
      join ordered_topics previous_topic
        on previous_topic.topic_position = target.topic_position - 1
      join public.quiz_attempts attempt
        on attempt.topic_id = previous_topic.id
       and attempt.user_id = auth.uid()
       and attempt.quiz_type = 'topic'
       and attempt.status = 'completed'
      where target.lesson_in_topic = 1
    )
    -- Grandfathering is monotonic: later valid activity keeps its curriculum prefix open.
    or exists (
      select 1
      from target
      join curriculum evidence_lesson
        on evidence_lesson.lesson_position >= target.lesson_position
      join public.user_lesson_progress progress
        on progress.lesson_id = evidence_lesson.id
       and progress.user_id = auth.uid()
       and progress.status in ('in_progress', 'completed')
    )
    or exists (
      select 1
      from target
      join ordered_topics evidence_topic
        on evidence_topic.topic_position >= target.topic_position
      join public.quiz_attempts attempt
        on attempt.topic_id = evidence_topic.id
       and attempt.user_id = auth.uid()
       and attempt.quiz_type = 'topic'
       and attempt.status in ('in_progress', 'completed')
    )
  );
$$;

create function public.is_topic_checkpoint_available(p_topic_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  with target_certification as (
    select domain.certification_id
    from public.topics topic
    join public.domains domain on domain.id = topic.domain_id
    where topic.id = p_topic_id
  ),
  ordered_topics as (
    select
      topic.id,
      row_number() over (
        order by domain.display_order, domain.id, topic.display_order, topic.id
      ) as topic_position
    from public.topics topic
    join public.domains domain on domain.id = topic.domain_id
    join target_certification target on target.certification_id = domain.certification_id
  ),
  target as (
    select * from ordered_topics where id = p_topic_id
  )
  select auth.uid() is not null and exists (select 1 from target) and (
    exists (
      select 1 from public.quiz_attempts attempt
      where attempt.user_id = auth.uid()
        and attempt.quiz_type = 'topic'
        and attempt.topic_id = p_topic_id
        and attempt.status in ('in_progress', 'completed')
    )
    or (
      exists (
        select 1 from public.lessons lesson
        where lesson.topic_id = p_topic_id and lesson.is_published = true
      )
      and not exists (
        select 1
        from public.lessons lesson
        where lesson.topic_id = p_topic_id
          and lesson.is_published = true
          and not exists (
            select 1 from public.user_lesson_progress progress
            where progress.user_id = auth.uid()
              and progress.lesson_id = lesson.id
              and progress.status = 'completed'
          )
      )
    )
    or exists (
      select 1
      from target
      join ordered_topics evidence_topic
        on evidence_topic.topic_position > target.topic_position
      left join public.lessons evidence_lesson
        on evidence_lesson.topic_id = evidence_topic.id
       and evidence_lesson.is_published = true
      where exists (
        select 1 from public.user_lesson_progress progress
        where progress.user_id = auth.uid()
          and progress.lesson_id = evidence_lesson.id
          and progress.status in ('in_progress', 'completed')
      ) or exists (
        select 1 from public.quiz_attempts attempt
        where attempt.user_id = auth.uid()
          and attempt.quiz_type = 'topic'
          and attempt.topic_id = evidence_topic.id
          and attempt.status in ('in_progress', 'completed')
      )
    )
  );
$$;

alter function public.start_lesson_progress(uuid) rename to start_lesson_progress_unchecked;
alter function public.complete_lesson_progress(uuid) rename to complete_lesson_progress_unchecked;
alter function public.start_topic_quiz(uuid) rename to start_topic_quiz_unchecked;

revoke execute on function public.start_lesson_progress_unchecked(uuid) from public, anon, authenticated;
revoke execute on function public.complete_lesson_progress_unchecked(uuid) from public, anon, authenticated;
revoke execute on function public.start_topic_quiz_unchecked(uuid) from public, anon, authenticated;

create function public.start_lesson_progress(p_lesson_id uuid)
returns setof public.user_lesson_progress
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;
  if not public.is_lesson_available(p_lesson_id) then
    raise exception 'Lesson is locked. Complete the prerequisite first.' using errcode = 'P0001';
  end if;
  return query select * from public.start_lesson_progress_unchecked(p_lesson_id);
end;
$$;

create function public.complete_lesson_progress(p_lesson_id uuid)
returns setof public.user_lesson_progress
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;
  if not public.is_lesson_available(p_lesson_id) then
    raise exception 'Lesson is locked. Complete the prerequisite first.' using errcode = 'P0001';
  end if;
  return query select * from public.complete_lesson_progress_unchecked(p_lesson_id);
end;
$$;

create function public.start_topic_quiz(p_topic_id uuid)
returns setof public.quiz_attempts
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;
  if not public.is_topic_checkpoint_available(p_topic_id) then
    raise exception 'Topic Checkpoint is locked. Complete the published Lessons first.' using errcode = 'P0001';
  end if;
  return query select * from public.start_topic_quiz_unchecked(p_topic_id);
end;
$$;

revoke execute on function public.is_lesson_available(uuid) from public, anon;
revoke execute on function public.is_topic_checkpoint_available(uuid) from public, anon;
revoke execute on function public.start_lesson_progress(uuid) from public, anon;
revoke execute on function public.complete_lesson_progress(uuid) from public, anon;
revoke execute on function public.start_topic_quiz(uuid) from public, anon;
grant execute on function public.is_lesson_available(uuid) to authenticated;
grant execute on function public.is_topic_checkpoint_available(uuid) to authenticated;
grant execute on function public.start_lesson_progress(uuid) to authenticated;
grant execute on function public.complete_lesson_progress(uuid) to authenticated;
grant execute on function public.start_topic_quiz(uuid) to authenticated;

commit;

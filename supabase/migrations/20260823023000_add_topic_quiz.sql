begin;

alter table public.quiz_attempts
  add column quiz_type text not null default 'lesson',
  add column topic_id uuid references public.topics(id) on delete cascade;

alter table public.quiz_attempts alter column lesson_id drop not null;

alter table public.quiz_attempts
  drop constraint quiz_attempts_total_questions_check,
  add constraint quiz_attempts_total_questions_check check (total_questions between 1 and 10),
  add constraint quiz_attempts_type_check check (quiz_type in ('lesson', 'topic')),
  add constraint quiz_attempts_scope_check check (
    (quiz_type = 'lesson' and lesson_id is not null and topic_id is null)
    or (quiz_type = 'topic' and topic_id is not null and lesson_id is null)
  );

drop index public.quiz_attempts_one_active_lesson_idx;

create unique index quiz_attempts_one_active_lesson_idx
  on public.quiz_attempts (user_id, lesson_id)
  where status = 'in_progress' and quiz_type = 'lesson';

create unique index quiz_attempts_one_active_topic_idx
  on public.quiz_attempts (user_id, topic_id)
  where status = 'in_progress' and quiz_type = 'topic';

create index quiz_attempts_user_topic_history_idx
  on public.quiz_attempts (user_id, topic_id, created_at desc)
  where quiz_type = 'topic';

create or replace function public.start_lesson_quiz(p_lesson_id uuid)
returns setof public.quiz_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_certification_id uuid;
  v_total integer;
  v_attempt public.quiz_attempts;
begin
  if v_user_id is null then raise exception 'Authentication is required.' using errcode = '42501'; end if;

  select attempt.* into v_attempt from public.quiz_attempts attempt
  where attempt.user_id = v_user_id and attempt.quiz_type = 'lesson'
    and attempt.lesson_id = p_lesson_id and attempt.status = 'in_progress'
  order by attempt.started_at desc limit 1;
  if found then return next v_attempt; return; end if;

  select domain.certification_id into v_certification_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  where lesson.id = p_lesson_id and lesson.is_published = true;
  if v_certification_id is null then raise exception 'Published lesson not found.' using errcode = 'P0002'; end if;

  select count(*) into v_total from (
    select question.id from public.questions question
    where question.lesson_id = p_lesson_id and question.is_published = true
      and question.question_type = 'single_choice'
    order by question.display_order, question.id limit 5
  ) selected;
  if v_total = 0 then raise exception 'No published questions are available for this lesson.' using errcode = 'P0002'; end if;

  begin
    insert into public.quiz_attempts (user_id, certification_id, quiz_type, lesson_id, total_questions)
    values (v_user_id, v_certification_id, 'lesson', p_lesson_id, v_total)
    returning * into v_attempt;
  exception when unique_violation then
    select attempt.* into strict v_attempt from public.quiz_attempts attempt
    where attempt.user_id = v_user_id and attempt.quiz_type = 'lesson'
      and attempt.lesson_id = p_lesson_id and attempt.status = 'in_progress';
    return next v_attempt; return;
  end;

  insert into public.quiz_attempt_questions (attempt_id, question_id, display_order)
  select v_attempt.id, selected.id,
    row_number() over (order by selected.display_order, selected.id)::integer
  from (
    select question.id, question.display_order from public.questions question
    where question.lesson_id = p_lesson_id and question.is_published = true
      and question.question_type = 'single_choice'
    order by question.display_order, question.id limit 5
  ) selected;
  return next v_attempt;
end;
$$;

create function public.start_topic_quiz(p_topic_id uuid)
returns setof public.quiz_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_certification_id uuid;
  v_total integer;
  v_attempt public.quiz_attempts;
begin
  if v_user_id is null then raise exception 'Authentication is required.' using errcode = '42501'; end if;

  select attempt.* into v_attempt from public.quiz_attempts attempt
  where attempt.user_id = v_user_id and attempt.quiz_type = 'topic'
    and attempt.topic_id = p_topic_id and attempt.status = 'in_progress'
  order by attempt.started_at desc limit 1;
  if found then return next v_attempt; return; end if;

  select domain.certification_id into v_certification_id
  from public.topics topic
  join public.domains domain on domain.id = topic.domain_id
  where topic.id = p_topic_id;
  if v_certification_id is null then raise exception 'Topic not found.' using errcode = 'P0002'; end if;

  select count(*) into v_total from (
    select question.id from public.questions question
    left join public.lessons lesson on lesson.id = question.lesson_id
    where question.topic_id = p_topic_id and question.is_published = true
      and question.question_type = 'single_choice'
    order by
      row_number() over (
        partition by coalesce(question.lesson_id, '00000000-0000-0000-0000-000000000000'::uuid)
        order by question.display_order, question.id
      ),
      coalesce(lesson.display_order, 2147483647),
      question.id
    limit 10
  ) selected;
  if v_total = 0 then raise exception 'No published questions are available for this topic.' using errcode = 'P0002'; end if;

  begin
    insert into public.quiz_attempts (user_id, certification_id, quiz_type, topic_id, total_questions)
    values (v_user_id, v_certification_id, 'topic', p_topic_id, v_total)
    returning * into v_attempt;
  exception when unique_violation then
    select attempt.* into strict v_attempt from public.quiz_attempts attempt
    where attempt.user_id = v_user_id and attempt.quiz_type = 'topic'
      and attempt.topic_id = p_topic_id and attempt.status = 'in_progress';
    return next v_attempt; return;
  end;

  insert into public.quiz_attempt_questions (attempt_id, question_id, display_order)
  select v_attempt.id, selected.id,
    row_number() over (order by selected.round_number, selected.lesson_order, selected.id)::integer
  from (
    select
      question.id,
      coalesce(lesson.display_order, 2147483647) as lesson_order,
      row_number() over (
        partition by coalesce(question.lesson_id, '00000000-0000-0000-0000-000000000000'::uuid)
        order by question.display_order, question.id
      ) as round_number
    from public.questions question
    left join public.lessons lesson on lesson.id = question.lesson_id
    where question.topic_id = p_topic_id and question.is_published = true
      and question.question_type = 'single_choice'
    order by round_number, lesson_order, question.id
    limit 10
  ) selected;
  return next v_attempt;
end;
$$;

create function public.get_topic_quiz_performance(p_attempt_id uuid)
returns table (
  lesson_id uuid,
  lesson_title text,
  lesson_slug text,
  total_questions integer,
  correct_answers integer,
  percentage numeric
)
language sql
security definer
set search_path = ''
stable
as $$
  select
    question.lesson_id,
    coalesce(lesson.title, 'Questões gerais do tópico'),
    lesson.slug,
    count(*)::integer,
    count(*) filter (where answer.is_correct)::integer,
    round(
      count(*) filter (where answer.is_correct)::numeric / nullif(count(*), 0)::numeric * 100,
      2
    )
  from public.quiz_attempt_questions attempt_question
  join public.quiz_attempts attempt on attempt.id = attempt_question.attempt_id
  join public.questions question on question.id = attempt_question.question_id
  left join public.lessons lesson on lesson.id = question.lesson_id
  left join public.quiz_answers answer
    on answer.attempt_id = attempt_question.attempt_id
    and answer.question_id = attempt_question.question_id
  where attempt.id = p_attempt_id
    and attempt.user_id = auth.uid()
    and attempt.quiz_type = 'topic'
  group by question.lesson_id, lesson.title, lesson.slug, lesson.display_order
  order by lesson.display_order nulls last, lesson.title;
$$;

create function public.get_topic_quiz_summaries(p_certification_id uuid)
returns table (
  topic_id uuid,
  question_count bigint,
  active_attempt_id uuid,
  active_total_questions integer,
  active_answered_count bigint,
  last_score_percentage numeric
)
language sql
security definer
set search_path = ''
stable
as $$
  select
    topic.id,
    (select count(*) from public.questions question
      where question.topic_id = topic.id and question.is_published = true),
    active.id,
    active.total_questions,
    (select count(*) from public.quiz_answers answer where answer.attempt_id = active.id),
    completed.score_percentage
  from public.topics topic
  join public.domains domain on domain.id = topic.domain_id
  left join lateral (
    select attempt.id, attempt.total_questions
    from public.quiz_attempts attempt
    where attempt.user_id = auth.uid() and attempt.quiz_type = 'topic'
      and attempt.topic_id = topic.id and attempt.status = 'in_progress'
    order by attempt.started_at desc limit 1
  ) active on true
  left join lateral (
    select attempt.score_percentage
    from public.quiz_attempts attempt
    where attempt.user_id = auth.uid() and attempt.quiz_type = 'topic'
      and attempt.topic_id = topic.id and attempt.status = 'completed'
    order by attempt.completed_at desc limit 1
  ) completed on true
  where domain.certification_id = p_certification_id;
$$;

revoke execute on function public.start_topic_quiz(uuid) from public, anon;
revoke execute on function public.get_topic_quiz_performance(uuid) from public, anon;
revoke execute on function public.get_topic_quiz_summaries(uuid) from public, anon;
grant execute on function public.start_topic_quiz(uuid) to authenticated;
grant execute on function public.get_topic_quiz_performance(uuid) to authenticated;
grant execute on function public.get_topic_quiz_summaries(uuid) to authenticated;

commit;

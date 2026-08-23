begin;

alter table public.quiz_attempts
  drop constraint quiz_attempts_type_check,
  drop constraint quiz_attempts_scope_check,
  add constraint quiz_attempts_type_check check (quiz_type in ('lesson', 'topic', 'review')),
  add constraint quiz_attempts_scope_check check (
    (quiz_type = 'lesson' and lesson_id is not null and topic_id is null)
    or (quiz_type = 'topic' and topic_id is not null and lesson_id is null)
    or (quiz_type = 'review' and lesson_id is null and topic_id is null)
  );

create unique index quiz_attempts_one_active_review_idx
  on public.quiz_attempts (user_id, certification_id)
  where status = 'in_progress' and quiz_type = 'review';

create index quiz_attempts_user_review_history_idx
  on public.quiz_attempts (user_id, certification_id, created_at desc)
  where quiz_type = 'review';

create index quiz_answers_question_history_idx
  on public.quiz_answers (question_id, answered_at desc);

create function public.get_user_question_stats(p_certification_id uuid)
returns table (
  question_id uuid,
  question_text text,
  domain_id uuid,
  domain_title text,
  topic_id uuid,
  topic_title text,
  lesson_id uuid,
  lesson_title text,
  lesson_slug text,
  total_attempts bigint,
  correct_count bigint,
  incorrect_count bigint,
  accuracy_percentage numeric,
  error_percentage numeric,
  last_answered_at timestamptz,
  last_result boolean
)
language sql
security definer
set search_path = ''
stable
as $$
  with answer_history as (
    select
      question.id as question_id,
      question.question_text,
      domain.id as domain_id,
      domain.title as domain_title,
      topic.id as topic_id,
      topic.title as topic_title,
      lesson.id as lesson_id,
      lesson.title as lesson_title,
      lesson.slug as lesson_slug,
      answer.id as answer_id,
      answer.is_correct,
      answer.answered_at
    from public.quiz_answers answer
    join public.quiz_attempts attempt on attempt.id = answer.attempt_id
    join public.questions question on question.id = answer.question_id
    left join public.domains domain on domain.id = question.domain_id
    left join public.topics topic on topic.id = question.topic_id
    left join public.lessons lesson on lesson.id = question.lesson_id
    where attempt.user_id = auth.uid()
      and attempt.certification_id = p_certification_id
      and question.certification_id = p_certification_id
      and question.is_published = true
  )
  select
    history.question_id,
    history.question_text,
    history.domain_id,
    coalesce(history.domain_title, 'Domínio geral'),
    history.topic_id,
    coalesce(history.topic_title, 'Tópico geral'),
    history.lesson_id,
    history.lesson_title,
    history.lesson_slug,
    count(*),
    count(*) filter (where history.is_correct),
    count(*) filter (where not history.is_correct),
    round(count(*) filter (where history.is_correct)::numeric / count(*)::numeric * 100, 2),
    round(count(*) filter (where not history.is_correct)::numeric / count(*)::numeric * 100, 2),
    max(history.answered_at),
    (array_agg(history.is_correct order by history.answered_at desc, history.answer_id desc))[1]
  from answer_history history
  group by
    history.question_id, history.question_text,
    history.domain_id, history.domain_title,
    history.topic_id, history.topic_title,
    history.lesson_id, history.lesson_title, history.lesson_slug
  having count(*) filter (where not history.is_correct) > 0
  order by
    ((array_agg(history.is_correct order by history.answered_at desc, history.answer_id desc))[1] = false) desc,
    round(count(*) filter (where not history.is_correct)::numeric / count(*)::numeric * 100, 2) desc,
    count(*) filter (where not history.is_correct) desc,
    max(history.answered_at) desc;
$$;

create function public.start_review_quiz(
  p_certification_id uuid,
  p_question_id uuid default null
)
returns setof public.quiz_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt public.quiz_attempts;
  v_total integer;
  v_completed_review_count integer;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  if not exists (
    select 1 from public.certifications certification
    where certification.id = p_certification_id and certification.is_enabled = true
  ) then
    raise exception 'Certification not found.' using errcode = 'P0002';
  end if;

  select attempt.* into v_attempt
  from public.quiz_attempts attempt
  where attempt.user_id = v_user_id
    and attempt.certification_id = p_certification_id
    and attempt.quiz_type = 'review'
    and attempt.status = 'in_progress'
  order by attempt.started_at desc
  limit 1;

  if found then
    if p_question_id is not null and not exists (
      select 1 from public.quiz_attempt_questions attempt_question
      where attempt_question.attempt_id = v_attempt.id
        and attempt_question.question_id = p_question_id
    ) then
      raise exception 'Finish the active review before starting an individual review.' using errcode = '55000';
    end if;
    return next v_attempt;
    return;
  end if;

  if p_question_id is not null and not exists (
    select 1
    from public.questions question
    join public.quiz_answers answer on answer.question_id = question.id and not answer.is_correct
    join public.quiz_attempts attempt on attempt.id = answer.attempt_id
    where question.id = p_question_id
      and question.certification_id = p_certification_id
      and question.is_published = true
      and question.question_type = 'single_choice'
      and attempt.user_id = v_user_id
      and attempt.certification_id = p_certification_id
  ) then
    raise exception 'Question is not eligible for this review.' using errcode = 'P0002';
  end if;

  select count(*) into v_completed_review_count
  from public.quiz_attempts attempt
  where attempt.user_id = v_user_id
    and attempt.certification_id = p_certification_id
    and attempt.quiz_type = 'review'
    and attempt.status = 'completed';

  create temporary table if not exists review_selected_questions (
    question_id uuid primary key,
    selection_order integer not null
  ) on commit drop;
  truncate review_selected_questions;

  if p_question_id is not null then
    insert into review_selected_questions values (p_question_id, 1);
  else
    insert into review_selected_questions (question_id, selection_order)
    with stats as (
      select
        question.id,
        count(*) filter (where not answer.is_correct) as errors,
        count(*) filter (where not answer.is_correct)::numeric / count(*)::numeric as error_rate,
        (array_agg(answer.is_correct order by answer.answered_at desc, answer.id desc))[1] as last_result,
        max(answer.answered_at) as last_answered_at
      from public.quiz_answers answer
      join public.quiz_attempts attempt on attempt.id = answer.attempt_id
      join public.questions question on question.id = answer.question_id
      where attempt.user_id = v_user_id
        and attempt.certification_id = p_certification_id
        and question.certification_id = p_certification_id
        and question.is_published = true
        and question.question_type = 'single_choice'
      group by question.id
      having count(*) filter (where not answer.is_correct) > 0
    ), ranked as (
      select stats.*,
        row_number() over (
          order by (stats.last_result = false) desc, stats.error_rate desc,
            stats.errors desc, stats.last_answered_at desc, stats.id
        )::integer as priority_rank
      from stats
    ), candidates as (
      select * from ranked where priority_rank <= 20
    ), numbered as (
      select candidates.*,
        count(*) filter (where priority_rank > 7) over ()::integer as tail_count
      from candidates
    ), selected as (
      select numbered.id, numbered.priority_rank,
        case
          when numbered.priority_rank <= 7 then numbered.priority_rank
          when numbered.tail_count = 0 then numbered.priority_rank
          else 8 + mod(
            numbered.priority_rank - 8 - mod(v_completed_review_count, numbered.tail_count) + numbered.tail_count,
            numbered.tail_count
          )
        end as rotated_order
      from numbered
      order by (numbered.priority_rank <= 7) desc, rotated_order
      limit 10
    )
    select selected.id,
      row_number() over (order by (selected.priority_rank <= 7) desc, selected.rotated_order)::integer
    from selected;
  end if;

  select count(*) into v_total from review_selected_questions;
  if v_total = 0 then
    raise exception 'No questions with incorrect history are available for review.' using errcode = 'P0002';
  end if;

  begin
    insert into public.quiz_attempts (
      user_id, certification_id, quiz_type, lesson_id, topic_id, total_questions
    ) values (
      v_user_id, p_certification_id, 'review', null, null, v_total
    ) returning * into v_attempt;
  exception when unique_violation then
    select attempt.* into strict v_attempt
    from public.quiz_attempts attempt
    where attempt.user_id = v_user_id
      and attempt.certification_id = p_certification_id
      and attempt.quiz_type = 'review'
      and attempt.status = 'in_progress';
    return next v_attempt;
    return;
  end;

  insert into public.quiz_attempt_questions (attempt_id, question_id, display_order)
  select v_attempt.id, selected.question_id, selected.selection_order
  from review_selected_questions selected
  order by selected.selection_order;

  return next v_attempt;
end;
$$;

create function public.get_quiz_lesson_performance(p_attempt_id uuid)
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
    coalesce(lesson.title, 'Questões gerais'),
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
    and attempt.quiz_type in ('topic', 'review')
  group by question.lesson_id, lesson.title, lesson.slug, lesson.display_order
  order by lesson.display_order nulls last, lesson.title;
$$;

revoke execute on function public.get_user_question_stats(uuid) from public, anon;
revoke execute on function public.start_review_quiz(uuid, uuid) from public, anon;
revoke execute on function public.get_quiz_lesson_performance(uuid) from public, anon;
grant execute on function public.get_user_question_stats(uuid) to authenticated;
grant execute on function public.start_review_quiz(uuid, uuid) to authenticated;
grant execute on function public.get_quiz_lesson_performance(uuid) to authenticated;

commit;

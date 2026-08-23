begin;

create or replace function public.submit_quiz_answer(
  p_attempt_id uuid,
  p_question_id uuid,
  p_selected_option_id uuid
)
returns table (
  is_correct boolean,
  correct_option_id uuid,
  question_explanation text,
  selected_option_explanation text,
  correct_option_explanation text,
  attempt_completed boolean,
  correct_answers integer,
  total_questions integer,
  score_percentage numeric
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt public.quiz_attempts;
  v_existing public.quiz_answers;
  v_is_correct boolean;
  v_correct_option_id uuid;
  v_question_explanation text;
  v_selected_explanation text;
  v_correct_explanation text;
  v_answered_count integer;
  v_correct_count integer;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  select attempt.* into v_attempt
  from public.quiz_attempts attempt
  where attempt.id = p_attempt_id
    and attempt.user_id = v_user_id
  for update;

  if not found then
    raise exception 'Quiz attempt not found.' using errcode = '42501';
  end if;

  select answer.* into v_existing
  from public.quiz_answers answer
  where answer.attempt_id = p_attempt_id
    and answer.question_id = p_question_id;

  if found and v_existing.selected_option_id <> p_selected_option_id then
    raise exception 'This question has already been answered.' using errcode = '23505';
  end if;

  if not found and v_attempt.status <> 'in_progress' then
    raise exception 'The quiz attempt is already completed.' using errcode = '55000';
  end if;

  if not exists (
    select 1 from public.quiz_attempt_questions attempt_question
    where attempt_question.attempt_id = p_attempt_id
      and attempt_question.question_id = p_question_id
  ) then
    raise exception 'Question does not belong to this attempt.' using errcode = '23503';
  end if;

  select option.is_correct, option.explanation
  into v_is_correct, v_selected_explanation
  from public.question_options option
  where option.id = p_selected_option_id
    and option.question_id = p_question_id;

  if not found then
    raise exception 'Selected option does not belong to the question.' using errcode = '23503';
  end if;

  select option.id, option.explanation
  into v_correct_option_id, v_correct_explanation
  from public.question_options option
  where option.question_id = p_question_id
    and option.is_correct = true;

  select question.explanation into v_question_explanation
  from public.questions question
  where question.id = p_question_id;

  if v_existing.id is null then
    insert into public.quiz_answers (
      attempt_id, question_id, selected_option_id, is_correct
    ) values (
      p_attempt_id, p_question_id, p_selected_option_id, v_is_correct
    );
  else
    v_is_correct := v_existing.is_correct;
  end if;

  select count(*), count(*) filter (where answer.is_correct)
  into v_answered_count, v_correct_count
  from public.quiz_answers answer
  where answer.attempt_id = p_attempt_id;

  if v_answered_count = v_attempt.total_questions and v_attempt.status = 'in_progress' then
    update public.quiz_attempts
    set
      status = 'completed',
      correct_answers = v_correct_count,
      score_percentage = round(
        (v_correct_count::numeric / v_attempt.total_questions::numeric) * 100,
        2
      ),
      completed_at = clock_timestamp()
    where id = p_attempt_id
    returning * into v_attempt;
  else
    select attempt.* into v_attempt
    from public.quiz_attempts attempt
    where attempt.id = p_attempt_id;
  end if;

  return query select
    v_is_correct,
    v_correct_option_id,
    v_question_explanation,
    v_selected_explanation,
    v_correct_explanation,
    v_attempt.status = 'completed',
    v_attempt.correct_answers,
    v_attempt.total_questions,
    v_attempt.score_percentage;
end;
$$;

commit;

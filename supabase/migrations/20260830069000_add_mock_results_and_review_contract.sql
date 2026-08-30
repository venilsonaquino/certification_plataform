begin;

create function public.get_mock_exam_result(p_attempt_id uuid)
returns table (
  attempt_id uuid,
  total_questions integer,
  answered_questions integer,
  correct_answers integer,
  incorrect_answers integer,
  unanswered_questions integer,
  practice_score_percentage numeric,
  started_at timestamptz,
  submitted_at timestamptz,
  elapsed_seconds integer,
  domain_breakdown jsonb,
  topic_breakdown jsonb,
  difficulty_breakdown jsonb
)
language plpgsql
security definer
set search_path = ''
stable
as $$
declare
  v_attempt public.mock_exam_attempts;
  v_domains jsonb;
  v_topics jsonb;
  v_difficulties jsonb;
begin
  select * into v_attempt
  from public.mock_exam_attempts attempt
  where attempt.id = p_attempt_id
    and attempt.user_id = auth.uid()
    and attempt.status = 'completed';

  if not found then
    return;
  end if;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'domainId', aggregate.domain_id,
      'domainTitle', aggregate.domain_title,
      'totalQuestions', aggregate.total_questions,
      'correctAnswers', aggregate.correct_answers,
      'incorrectAnswers', aggregate.incorrect_answers,
      'unansweredQuestions', aggregate.unanswered_questions,
      'percentage', aggregate.percentage
    ) order by aggregate.first_order
  ), '[]'::jsonb)
  into v_domains
  from (
    select
      item.domain_id,
      item.domain_title_snapshot as domain_title,
      min(item.display_order) as first_order,
      count(*)::integer as total_questions,
      count(*) filter (where answer.is_correct is true)::integer as correct_answers,
      count(*) filter (where answer.is_correct is false)::integer as incorrect_answers,
      count(*) filter (where answer.id is null)::integer as unanswered_questions,
      round(
        count(*) filter (where answer.is_correct is true)::numeric / count(*)::numeric * 100,
        2
      ) as percentage
    from public.mock_exam_attempt_questions item
    left join public.mock_exam_answers answer on answer.attempt_question_id = item.id
    where item.attempt_id = p_attempt_id
    group by item.domain_id, item.domain_title_snapshot
  ) aggregate;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'domainId', aggregate.domain_id,
      'domainTitle', aggregate.domain_title,
      'topicId', aggregate.topic_id,
      'topicTitle', aggregate.topic_title,
      'totalQuestions', aggregate.total_questions,
      'correctAnswers', aggregate.correct_answers,
      'incorrectAnswers', aggregate.incorrect_answers,
      'unansweredQuestions', aggregate.unanswered_questions,
      'percentage', aggregate.percentage
    ) order by aggregate.percentage, aggregate.topic_order
  ), '[]'::jsonb)
  into v_topics
  from (
    select
      item.domain_id,
      item.domain_title_snapshot as domain_title,
      item.topic_id,
      item.topic_title_snapshot as topic_title,
      min(item.display_order) as topic_order,
      count(*)::integer as total_questions,
      count(*) filter (where answer.is_correct is true)::integer as correct_answers,
      count(*) filter (where answer.is_correct is false)::integer as incorrect_answers,
      count(*) filter (where answer.id is null)::integer as unanswered_questions,
      round(
        count(*) filter (where answer.is_correct is true)::numeric / count(*)::numeric * 100,
        2
      ) as percentage
    from public.mock_exam_attempt_questions item
    left join public.mock_exam_answers answer on answer.attempt_question_id = item.id
    where item.attempt_id = p_attempt_id
    group by item.domain_id, item.domain_title_snapshot, item.topic_id, item.topic_title_snapshot
  ) aggregate;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'difficulty', aggregate.difficulty,
      'totalQuestions', aggregate.total_questions,
      'correctAnswers', aggregate.correct_answers,
      'incorrectAnswers', aggregate.incorrect_answers,
      'unansweredQuestions', aggregate.unanswered_questions,
      'percentage', aggregate.percentage
    ) order by aggregate.difficulty_order
  ), '[]'::jsonb)
  into v_difficulties
  from (
    select
      item.difficulty_snapshot as difficulty,
      case item.difficulty_snapshot when 'easy' then 1 when 'medium' then 2 else 3 end
        as difficulty_order,
      count(*)::integer as total_questions,
      count(*) filter (where answer.is_correct is true)::integer as correct_answers,
      count(*) filter (where answer.is_correct is false)::integer as incorrect_answers,
      count(*) filter (where answer.id is null)::integer as unanswered_questions,
      round(
        count(*) filter (where answer.is_correct is true)::numeric / count(*)::numeric * 100,
        2
      ) as percentage
    from public.mock_exam_attempt_questions item
    left join public.mock_exam_answers answer on answer.attempt_question_id = item.id
    where item.attempt_id = p_attempt_id
    group by item.difficulty_snapshot
  ) aggregate;

  return query select
    v_attempt.id,
    v_attempt.total_questions,
    v_attempt.answered_questions,
    v_attempt.correct_answers,
    v_attempt.incorrect_answers,
    v_attempt.unanswered_questions,
    v_attempt.practice_score_percentage,
    v_attempt.started_at,
    v_attempt.submitted_at,
    v_attempt.elapsed_seconds,
    v_domains,
    v_topics,
    v_difficulties;
end;
$$;

create function public.get_mock_exam_review(p_attempt_id uuid)
returns table (
  id uuid,
  attempt_id uuid,
  question_id uuid,
  display_order integer,
  domain_id uuid,
  domain_title text,
  topic_id uuid,
  topic_title text,
  lesson_id uuid,
  lesson_title text,
  lesson_slug text,
  difficulty text,
  question_text text,
  options jsonb,
  selected_option_key text,
  correct_option_key text,
  answer_status text,
  explanation text
)
language sql
security definer
set search_path = ''
stable
as $$
  select
    item.id,
    item.attempt_id,
    item.question_id,
    item.display_order,
    item.domain_id,
    item.domain_title_snapshot,
    item.topic_id,
    item.topic_title_snapshot,
    item.lesson_id,
    item.lesson_title_snapshot,
    item.lesson_slug_snapshot,
    item.difficulty_snapshot,
    item.question_text_snapshot,
    coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'key', option_item ->> 'key',
            'text', option_item ->> 'text',
            'displayOrder', (option_item ->> 'displayOrder')::integer
          ) order by (option_item ->> 'displayOrder')::integer, option_item ->> 'key'
        )
        from jsonb_array_elements(item.options_snapshot) option_item
      ),
      '[]'::jsonb
    ),
    answer.selected_option_key,
    item.correct_option_key,
    case
      when answer.id is null then 'unanswered'
      when answer.is_correct then 'correct'
      else 'incorrect'
    end,
    coalesce(
      item.question_explanation_snapshot,
      (
        select nullif(option_item ->> 'explanation', '')
        from jsonb_array_elements(item.options_snapshot) option_item
        where option_item ->> 'key' = item.correct_option_key
        limit 1
      )
    )
  from public.mock_exam_attempt_questions item
  join public.mock_exam_attempts attempt on attempt.id = item.attempt_id
  left join public.mock_exam_answers answer on answer.attempt_question_id = item.id
  where item.attempt_id = p_attempt_id
    and attempt.user_id = auth.uid()
    and attempt.status = 'completed'
  order by item.display_order;
$$;

revoke execute on function public.get_mock_exam_result(uuid) from public, anon;
revoke execute on function public.get_mock_exam_review(uuid) from public, anon;
grant execute on function public.get_mock_exam_result(uuid) to authenticated;
grant execute on function public.get_mock_exam_review(uuid) to authenticated;

comment on function public.get_mock_exam_result(uuid) is
  'Returns persisted Practice Score and deterministic snapshot-based breakdowns for an owned completed Mock Exam.';
comment on function public.get_mock_exam_review(uuid) is
  'Returns answer keys and explanations only for an owned completed Mock Exam.';

commit;

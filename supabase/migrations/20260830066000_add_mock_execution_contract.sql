begin;

drop function public.get_mock_exam_attempt_questions(uuid);

create function public.get_mock_exam_attempt_questions(p_attempt_id uuid)
returns table (
  id uuid,
  attempt_id uuid,
  question_id uuid,
  display_order integer,
  question_text text,
  options jsonb,
  selected_option_key text,
  answered_at timestamptz
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
    answer.answered_at
  from public.mock_exam_attempt_questions item
  join public.mock_exam_attempts attempt on attempt.id = item.attempt_id
  left join public.mock_exam_answers answer on answer.attempt_question_id = item.id
  where item.attempt_id = p_attempt_id
    and attempt.user_id = auth.uid()
    and attempt.status = 'in_progress'
  order by item.display_order;
$$;

create function public.submit_mock_exam(p_attempt_id uuid)
returns setof public.mock_exam_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt public.mock_exam_attempts;
  v_answer_count integer;
  v_correct_count integer;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  select * into v_attempt
  from public.mock_exam_attempts attempt
  where attempt.id=p_attempt_id and attempt.user_id=v_user_id
  for update;

  if not found then
    raise exception 'Mock Exam attempt not found.' using errcode = '42501';
  end if;

  if v_attempt.status='completed' then
    return next v_attempt;
    return;
  end if;

  if v_attempt.status<>'in_progress' then
    raise exception 'Only an in-progress Mock Exam can be submitted.' using errcode = '55000';
  end if;

  if (select count(*) from public.mock_exam_attempt_questions item
      where item.attempt_id=p_attempt_id)<>v_attempt.total_questions then
    raise exception 'Mock Exam Question snapshots are incomplete.' using errcode = 'P0002';
  end if;

  update public.mock_exam_answers answer
  set is_correct=(answer.selected_option_key=item.correct_option_key)
  from public.mock_exam_attempt_questions item
  where answer.attempt_id=p_attempt_id
    and item.id=answer.attempt_question_id
    and item.attempt_id=answer.attempt_id;

  select count(*)::integer,count(*) filter(where answer.is_correct)::integer
  into v_answer_count,v_correct_count
  from public.mock_exam_answers answer
  where answer.attempt_id=p_attempt_id;

  update public.mock_exam_attempts attempt
  set
    status='completed',
    answered_questions=v_answer_count,
    correct_answers=v_correct_count,
    incorrect_answers=v_answer_count-v_correct_count,
    unanswered_questions=v_attempt.total_questions-v_answer_count,
    practice_score_percentage=round(
      (v_correct_count::numeric/v_attempt.total_questions::numeric)*100,2
    ),
    submitted_at=clock_timestamp(),
    elapsed_seconds=greatest(0,extract(epoch from (clock_timestamp()-v_attempt.started_at))::integer),
    last_activity_at=clock_timestamp()
  where attempt.id=p_attempt_id
  returning * into v_attempt;

  return next v_attempt;
end;
$$;

revoke execute on function public.get_mock_exam_attempt_questions(uuid) from public,anon;
revoke execute on function public.submit_mock_exam(uuid) from public,anon;
grant execute on function public.get_mock_exam_attempt_questions(uuid) to authenticated;
grant execute on function public.submit_mock_exam(uuid) to authenticated;

commit;

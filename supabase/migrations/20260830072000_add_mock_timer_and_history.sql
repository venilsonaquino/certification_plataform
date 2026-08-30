begin;

-- Practice configuration owned by Certification Academy, not an official exam duration.
create function public.mock_exam_time_limit_seconds()
returns integer
language sql
immutable
set search_path = ''
as $$ select 3600 $$;

revoke execute on function public.mock_exam_time_limit_seconds() from public, anon, authenticated;

alter table public.mock_exam_attempts
  drop constraint mock_exam_attempts_lifecycle_check,
  drop constraint mock_exam_attempts_elapsed_check;

alter table public.mock_exam_attempts
  add constraint mock_exam_attempts_elapsed_check check (
    elapsed_seconds is null
    or (elapsed_seconds >= 0 and (time_limit_seconds is null or elapsed_seconds <= time_limit_seconds))
  ),
  add constraint mock_exam_attempts_lifecycle_check check (
    (
      status = 'in_progress'
      and submitted_at is null and abandoned_at is null
      and correct_answers is null and incorrect_answers is null
      and unanswered_questions is null and practice_score_percentage is null
    ) or (
      status in ('completed', 'expired')
      and submitted_at is not null and abandoned_at is null
      and correct_answers is not null and incorrect_answers is not null
      and unanswered_questions is not null and practice_score_percentage is not null
      and (status <> 'expired' or expires_at is not null)
    ) or (
      status = 'abandoned'
      and submitted_at is null and abandoned_at is not null
      and correct_answers is null and incorrect_answers is null
      and unanswered_questions is null and practice_score_percentage is null
    )
  );

create function public.finalize_mock_exam_if_expired(p_attempt_id uuid, p_user_id uuid)
returns public.mock_exam_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_attempt public.mock_exam_attempts;
  v_answer_count integer;
  v_correct_count integer;
begin
  select * into v_attempt
  from public.mock_exam_attempts attempt
  where attempt.id = p_attempt_id and attempt.user_id = p_user_id
  for update;

  if not found then return null; end if;

  if v_attempt.status = 'in_progress' and v_attempt.time_limit_seconds is null then
    update public.mock_exam_attempts attempt
    set
      time_limit_seconds = public.mock_exam_time_limit_seconds(),
      expires_at = attempt.started_at + make_interval(secs => public.mock_exam_time_limit_seconds())
    where attempt.id = p_attempt_id
    returning * into v_attempt;
  end if;

  if v_attempt.status <> 'in_progress'
    or v_attempt.expires_at is null
    or v_attempt.expires_at > clock_timestamp() then
    return v_attempt;
  end if;

  if (select count(*) from public.mock_exam_attempt_questions item
      where item.attempt_id = p_attempt_id) <> v_attempt.total_questions then
    raise exception 'Mock Exam Question snapshots are incomplete.' using errcode = 'P0002';
  end if;

  update public.mock_exam_answers answer
  set is_correct = (answer.selected_option_key = item.correct_option_key)
  from public.mock_exam_attempt_questions item
  where answer.attempt_id = p_attempt_id
    and item.id = answer.attempt_question_id
    and item.attempt_id = answer.attempt_id;

  select count(*)::integer, count(*) filter (where answer.is_correct)::integer
  into v_answer_count, v_correct_count
  from public.mock_exam_answers answer
  where answer.attempt_id = p_attempt_id;

  update public.mock_exam_attempts attempt
  set
    status = 'expired',
    answered_questions = v_answer_count,
    correct_answers = v_correct_count,
    incorrect_answers = v_answer_count - v_correct_count,
    unanswered_questions = v_attempt.total_questions - v_answer_count,
    practice_score_percentage = round(
      (v_correct_count::numeric / v_attempt.total_questions::numeric) * 100, 2
    ),
    submitted_at = v_attempt.expires_at,
    elapsed_seconds = v_attempt.time_limit_seconds,
    last_activity_at = clock_timestamp()
  where attempt.id = p_attempt_id
  returning * into v_attempt;

  return v_attempt;
end;
$$;

revoke execute on function public.finalize_mock_exam_if_expired(uuid, uuid)
  from public, anon, authenticated;

create or replace function public.start_mock_exam(p_certification_id uuid)
returns setof public.mock_exam_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt public.mock_exam_attempts;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  select * into strict v_attempt
  from public.start_mock_exam_internal(p_certification_id, null);

  if v_attempt.time_limit_seconds is null then
    update public.mock_exam_attempts attempt
    set
      time_limit_seconds = public.mock_exam_time_limit_seconds(),
      expires_at = attempt.started_at + make_interval(secs => public.mock_exam_time_limit_seconds())
    where attempt.id = v_attempt.id
    returning * into v_attempt;
  end if;

  v_attempt := public.finalize_mock_exam_if_expired(v_attempt.id, v_user_id);

  if v_attempt.status = 'expired' then
    select * into strict v_attempt
    from public.start_mock_exam_internal(p_certification_id, null);

    update public.mock_exam_attempts attempt
    set
      time_limit_seconds = public.mock_exam_time_limit_seconds(),
      expires_at = attempt.started_at + make_interval(secs => public.mock_exam_time_limit_seconds())
    where attempt.id = v_attempt.id
    returning * into v_attempt;
  end if;

  return next v_attempt;
end;
$$;

create function public.sync_mock_exam_attempt(p_attempt_id uuid)
returns table (attempt jsonb, server_now timestamptz)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt public.mock_exam_attempts;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  select * into v_attempt
  from public.mock_exam_attempts candidate
  where candidate.id = p_attempt_id and candidate.user_id = v_user_id
  for update;

  if not found then return; end if;

  if v_attempt.status = 'in_progress' and v_attempt.time_limit_seconds is null then
    update public.mock_exam_attempts candidate
    set
      time_limit_seconds = public.mock_exam_time_limit_seconds(),
      expires_at = candidate.started_at + make_interval(secs => public.mock_exam_time_limit_seconds())
    where candidate.id = p_attempt_id
    returning * into v_attempt;
  end if;

  v_attempt := public.finalize_mock_exam_if_expired(p_attempt_id, v_user_id);
  return query select to_jsonb(v_attempt), clock_timestamp();
end;
$$;

create or replace function public.get_mock_exam_attempt_questions(p_attempt_id uuid)
returns table (
  id uuid, attempt_id uuid, question_id uuid, display_order integer,
  question_text text, options jsonb, selected_option_key text, answered_at timestamptz
)
language sql
security definer
set search_path = ''
stable
as $$
  select
    item.id, item.attempt_id, item.question_id, item.display_order,
    item.question_text_snapshot,
    coalesce((
      select jsonb_agg(jsonb_build_object(
        'key', option_item ->> 'key', 'text', option_item ->> 'text',
        'displayOrder', (option_item ->> 'displayOrder')::integer
      ) order by (option_item ->> 'displayOrder')::integer, option_item ->> 'key')
      from jsonb_array_elements(item.options_snapshot) option_item
    ), '[]'::jsonb),
    answer.selected_option_key, answer.answered_at
  from public.mock_exam_attempt_questions item
  join public.mock_exam_attempts attempt on attempt.id = item.attempt_id
  left join public.mock_exam_answers answer on answer.attempt_question_id = item.id
  where item.attempt_id = p_attempt_id
    and attempt.user_id = auth.uid()
    and attempt.status = 'in_progress'
    and attempt.expires_at > clock_timestamp()
  order by item.display_order;
$$;

create or replace function public.save_mock_exam_answer(
  p_attempt_id uuid, p_attempt_question_id uuid, p_selected_option_key text
)
returns table (
  id uuid, attempt_id uuid, attempt_question_id uuid,
  selected_option_key text, answered_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt public.mock_exam_attempts;
  v_question public.mock_exam_attempt_questions;
  v_answer public.mock_exam_answers;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  v_attempt := public.finalize_mock_exam_if_expired(p_attempt_id, v_user_id);
  if v_attempt.id is null then
    raise exception 'Mock Exam attempt not found.' using errcode = '42501';
  end if;
  if v_attempt.status <> 'in_progress' then
    raise exception 'Only an active Mock Exam can be answered.' using errcode = '55000';
  end if;

  select * into v_question
  from public.mock_exam_attempt_questions item
  where item.id = p_attempt_question_id and item.attempt_id = p_attempt_id;
  if not found then
    raise exception 'Question does not belong to this Mock Exam attempt.' using errcode = '23503';
  end if;
  if not exists (
    select 1 from jsonb_array_elements(v_question.options_snapshot) option_item
    where option_item ->> 'key' = p_selected_option_key
  ) then
    raise exception 'Selected option does not belong to the Question snapshot.' using errcode = '23503';
  end if;

  insert into public.mock_exam_answers (
    attempt_id, attempt_question_id, selected_option_key, is_correct, answered_at
  ) values (p_attempt_id, p_attempt_question_id, p_selected_option_key, null, clock_timestamp())
  on conflict (attempt_question_id) do update set
    selected_option_key = excluded.selected_option_key,
    is_correct = null,
    answered_at = excluded.answered_at
  returning * into v_answer;

  update public.mock_exam_attempts candidate
  set
    answered_questions = (select count(*)::integer from public.mock_exam_answers answer
      where answer.attempt_id = p_attempt_id),
    last_activity_at = clock_timestamp()
  where candidate.id = p_attempt_id;

  return query select v_answer.id, v_answer.attempt_id, v_answer.attempt_question_id,
    v_answer.selected_option_key, v_answer.answered_at;
end;
$$;

create or replace function public.submit_mock_exam(p_attempt_id uuid)
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
  v_now timestamptz;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  v_attempt := public.finalize_mock_exam_if_expired(p_attempt_id, v_user_id);
  if v_attempt.id is null then
    raise exception 'Mock Exam attempt not found.' using errcode = '42501';
  end if;
  if v_attempt.status in ('completed', 'expired') then
    return next v_attempt;
    return;
  end if;
  if v_attempt.status <> 'in_progress' then
    raise exception 'Only an in-progress Mock Exam can be submitted.' using errcode = '55000';
  end if;

  if (select count(*) from public.mock_exam_attempt_questions item
      where item.attempt_id = p_attempt_id) <> v_attempt.total_questions then
    raise exception 'Mock Exam Question snapshots are incomplete.' using errcode = 'P0002';
  end if;

  update public.mock_exam_answers answer
  set is_correct = (answer.selected_option_key = item.correct_option_key)
  from public.mock_exam_attempt_questions item
  where answer.attempt_id = p_attempt_id
    and item.id = answer.attempt_question_id and item.attempt_id = answer.attempt_id;

  select count(*)::integer, count(*) filter (where answer.is_correct)::integer
  into v_answer_count, v_correct_count
  from public.mock_exam_answers answer where answer.attempt_id = p_attempt_id;
  v_now := clock_timestamp();

  update public.mock_exam_attempts candidate
  set
    status = 'completed', answered_questions = v_answer_count,
    correct_answers = v_correct_count, incorrect_answers = v_answer_count - v_correct_count,
    unanswered_questions = v_attempt.total_questions - v_answer_count,
    practice_score_percentage = round((v_correct_count::numeric / v_attempt.total_questions::numeric) * 100, 2),
    submitted_at = v_now,
    elapsed_seconds = least(v_attempt.time_limit_seconds,
      greatest(0, extract(epoch from (v_now - v_attempt.started_at))::integer)),
    last_activity_at = v_now
  where candidate.id = p_attempt_id returning * into v_attempt;

  return next v_attempt;
end;
$$;

create function public.get_mock_exam_history(
  p_certification_id uuid, p_limit integer default 10, p_offset integer default 0
)
returns table (
  attempt_id uuid, attempt_number bigint, status text, total_questions integer,
  answered_questions integer, correct_answers integer, incorrect_answers integer,
  unanswered_questions integer, practice_score_percentage numeric,
  started_at timestamptz, submitted_at timestamptz, expires_at timestamptz,
  time_limit_seconds integer, elapsed_seconds integer, total_count bigint
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_id uuid;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;
  if p_limit < 1 or p_limit > 50 or p_offset < 0 then
    raise exception 'Invalid history pagination.' using errcode = '22023';
  end if;

  update public.mock_exam_attempts attempt
  set
    time_limit_seconds = public.mock_exam_time_limit_seconds(),
    expires_at = attempt.started_at + make_interval(secs => public.mock_exam_time_limit_seconds())
  where attempt.user_id = v_user_id and attempt.certification_id = p_certification_id
    and attempt.status = 'in_progress' and attempt.time_limit_seconds is null;

  for v_id in
    select attempt.id from public.mock_exam_attempts attempt
    where attempt.user_id = v_user_id and attempt.certification_id = p_certification_id
      and attempt.status = 'in_progress' and attempt.expires_at <= clock_timestamp()
  loop
    perform public.finalize_mock_exam_if_expired(v_id, v_user_id);
  end loop;

  return query
  with numbered as (
    select attempt.*,
      row_number() over (order by attempt.started_at, attempt.id) as friendly_number,
      count(*) over () as history_count
    from public.mock_exam_attempts attempt
    where attempt.user_id = v_user_id and attempt.certification_id = p_certification_id
  )
  select n.id, n.friendly_number, n.status, n.total_questions, n.answered_questions,
    n.correct_answers, n.incorrect_answers, n.unanswered_questions,
    n.practice_score_percentage, n.started_at, n.submitted_at, n.expires_at,
    n.time_limit_seconds, n.elapsed_seconds, n.history_count
  from numbered n
  order by n.started_at desc, n.id desc
  limit p_limit offset p_offset;
end;
$$;

revoke execute on function public.sync_mock_exam_attempt(uuid) from public, anon;
revoke execute on function public.get_mock_exam_history(uuid, integer, integer) from public, anon;
grant execute on function public.sync_mock_exam_attempt(uuid) to authenticated;
grant execute on function public.get_mock_exam_history(uuid, integer, integer) to authenticated;

comment on function public.mock_exam_time_limit_seconds() is
  'Central Certification Academy Practice Mock duration: 60 minutes; not an official Microsoft exam duration.';
comment on function public.sync_mock_exam_attempt(uuid) is
  'Owner-only server clock synchronization that deterministically finalizes an expired Practice Mock.';
comment on function public.get_mock_exam_history(uuid, integer, integer) is
  'Owner-only paginated metadata history; does not load Question snapshots.';

commit;

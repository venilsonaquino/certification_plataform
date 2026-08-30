begin;

do $$
declare
  v_user_a constant uuid := '74100000-0000-4000-8000-000000000001';
  v_user_b constant uuid := '74100000-0000-4000-8000-000000000002';
  v_certification_id uuid;
  v_attempt_1 public.mock_exam_attempts;
  v_attempt_2 public.mock_exam_attempts;
  v_attempt_question_id uuid;
  v_option_key text;
  v_history_count integer;
  v_overlap integer;
  v_definition text;
begin
  if public.mock_exam_time_limit_seconds() <> 3600 then
    raise exception 'Practice Mock time limit must be centralized at 3600 seconds.';
  end if;

  if to_regprocedure('public.sync_mock_exam_attempt(uuid)') is null
    or to_regprocedure('public.get_mock_exam_history(uuid,integer,integer)') is null
    or has_function_privilege('anon', 'public.get_mock_exam_history(uuid,integer,integer)', 'EXECUTE')
    or not has_function_privilege('authenticated', 'public.get_mock_exam_history(uuid,integer,integer)', 'EXECUTE') then
    raise exception 'Timer/history RPC privilege contract is invalid.';
  end if;

  select pg_get_functiondef('public.save_mock_exam_answer(uuid,uuid,text)'::regprocedure)
  into v_definition;
  if v_definition not like '%finalize_mock_exam_if_expired%' then
    raise exception 'Answer writes are not guarded by server-side expiration.';
  end if;

  select certification.id into strict v_certification_id
  from public.certifications certification where lower(certification.code) = 'az-900';

  insert into auth.users (id, aud, role, email, encrypted_password, email_confirmed_at)
  values
    (v_user_a, 'authenticated', 'authenticated', 'mock-timer-a@example.test', '', now()),
    (v_user_b, 'authenticated', 'authenticated', 'mock-timer-b@example.test', '', now());

  perform set_config('request.jwt.claim.role', 'authenticated', true);
  perform set_config('request.jwt.claim.sub', v_user_a::text, true);

  select * into strict v_attempt_1 from public.start_mock_exam(v_certification_id);
  if v_attempt_1.time_limit_seconds <> 3600
    or extract(epoch from (v_attempt_1.expires_at - v_attempt_1.started_at))::integer <> 3600
    or (select count(*) from public.mock_exam_attempt_questions item where item.attempt_id = v_attempt_1.id) <> 40 then
    raise exception 'Start did not persist the authoritative 60-minute timer and 40 snapshots.';
  end if;

  select item.id, item.options_snapshot -> 0 ->> 'key'
  into strict v_attempt_question_id, v_option_key
  from public.mock_exam_attempt_questions item
  where item.attempt_id = v_attempt_1.id order by item.display_order limit 1;
  perform * from public.save_mock_exam_answer(v_attempt_1.id, v_attempt_question_id, v_option_key);

  update public.mock_exam_attempts attempt
  set started_at = clock_timestamp() - interval '2 hours',
      expires_at = clock_timestamp() - interval '1 hour'
  where attempt.id = v_attempt_1.id;

  select (session.attempt ->> 'status')::text
  into strict v_definition
  from public.sync_mock_exam_attempt(v_attempt_1.id) session;
  if v_definition <> 'expired' then
    raise exception 'Offline reload did not finalize the expired Attempt.';
  end if;

  select * into strict v_attempt_1 from public.mock_exam_attempts attempt where attempt.id = v_attempt_1.id;
  if v_attempt_1.status <> 'expired' or v_attempt_1.elapsed_seconds <> 3600
    or v_attempt_1.answered_questions <> 1 or v_attempt_1.unanswered_questions <> 39
    or v_attempt_1.submitted_at <> v_attempt_1.expires_at then
    raise exception 'Expired result counts or duration are inconsistent.';
  end if;

  begin
    perform * from public.save_mock_exam_answer(v_attempt_1.id, v_attempt_question_id, v_option_key);
    raise exception 'Answer write unexpectedly succeeded after expiration.';
  exception when sqlstate '55000' then null;
  end;

  if (select count(*) from public.get_mock_exam_result(v_attempt_1.id)) <> 1
    or (select count(*) from public.get_mock_exam_review(v_attempt_1.id)) <> 40 then
    raise exception 'Timeout-finalized Result/Review is unavailable.';
  end if;

  select * into strict v_attempt_2 from public.start_mock_exam(v_certification_id);
  if v_attempt_2.id = v_attempt_1.id or v_attempt_2.status <> 'in_progress'
    or v_attempt_2.time_limit_seconds <> 3600 then
    raise exception 'Retake did not create a new timed Attempt.';
  end if;
  if (select count(distinct item.question_id) from public.mock_exam_attempt_questions item
      where item.attempt_id = v_attempt_2.id) <> 40
    or exists (
      select domain.display_order, count(*)
      from public.mock_exam_attempt_questions item
      join public.domains domain on domain.id = item.domain_id
      where item.attempt_id = v_attempt_2.id
      group by domain.display_order
      having count(*) <> case domain.display_order when 1 then 11 when 2 then 15 when 3 then 14 end
    )
    or (select count(*) from public.mock_exam_attempt_questions item
      where item.attempt_id = v_attempt_2.id and item.difficulty_snapshot = 'easy') <> 12
    or (select count(*) from public.mock_exam_attempt_questions item
      where item.attempt_id = v_attempt_2.id and item.difficulty_snapshot = 'medium') <> 20
    or (select count(*) from public.mock_exam_attempt_questions item
      where item.attempt_id = v_attempt_2.id and item.difficulty_snapshot = 'hard') <> 8 then
    raise exception 'Retake selection invariants changed.';
  end if;

  select count(*)::integer into v_overlap
  from public.mock_exam_attempt_questions first_item
  join public.mock_exam_attempt_questions second_item on second_item.question_id = first_item.question_id
  where first_item.attempt_id = v_attempt_1.id and second_item.attempt_id = v_attempt_2.id;
  if v_overlap > 10 then
    raise exception 'Retake overlap is unexpectedly high: %.', v_overlap;
  end if;

  select count(*)::integer into v_history_count
  from public.get_mock_exam_history(v_certification_id, 10, 0);
  if v_history_count <> 2
    or not exists (select 1 from public.get_mock_exam_history(v_certification_id, 10, 0) history
      where history.attempt_id = v_attempt_1.id and history.status = 'expired'
        and history.attempt_number = 1 and history.total_count = 2)
    or not exists (select 1 from public.get_mock_exam_history(v_certification_id, 10, 0) history
      where history.attempt_id = v_attempt_2.id and history.status = 'in_progress'
        and history.attempt_number = 2 and history.total_count = 2) then
    raise exception 'History ordering, numbering or preservation is invalid.';
  end if;

  select * into strict v_attempt_2 from public.submit_mock_exam(v_attempt_2.id);
  if v_attempt_2.status <> 'completed' or v_attempt_2.elapsed_seconds > 3600 then
    raise exception 'Manual submit did not finalize with bounded server duration.';
  end if;

  perform set_config('request.jwt.claim.sub', v_user_b::text, true);
  if exists (select 1 from public.get_mock_exam_history(v_certification_id, 10, 0))
    or exists (select 1 from public.sync_mock_exam_attempt(v_attempt_1.id)) then
    raise exception 'User isolation failed for timer/history.';
  end if;
  if not (select relrowsecurity from pg_class where oid = 'public.mock_exam_attempts'::regclass)
    or not exists (select 1 from pg_policies where schemaname = 'public'
      and tablename = 'mock_exam_attempts' and cmd = 'SELECT') then
    raise exception 'Mock Attempt RLS/select policy is not enabled.';
  end if;
end;
$$;

rollback;

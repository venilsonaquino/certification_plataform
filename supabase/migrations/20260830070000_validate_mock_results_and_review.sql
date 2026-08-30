begin;

do $$
declare
  v_submit_source text := pg_get_functiondef('public.submit_mock_exam(uuid)'::regprocedure);
begin
  if to_regprocedure('public.get_mock_exam_result(uuid)') is null
    or to_regprocedure('public.get_mock_exam_review(uuid)') is null then
    raise exception '11.5 result/review contracts are missing';
  end if;
  if has_function_privilege('anon','public.get_mock_exam_result(uuid)','EXECUTE')
    or has_function_privilege('anon','public.get_mock_exam_review(uuid)','EXECUTE')
    or not has_function_privilege('authenticated','public.get_mock_exam_result(uuid)','EXECUTE')
    or not has_function_privilege('authenticated','public.get_mock_exam_review(uuid)','EXECUTE') then
    raise exception '11.5 result/review grants are invalid';
  end if;
  if pg_get_function_arguments('public.submit_mock_exam(uuid)'::regprocedure) <> 'p_attempt_id uuid'
    or v_submit_source like '%p_score%'
    or has_table_privilege('authenticated','public.mock_exam_attempts','UPDATE') then
    raise exception '11.5 frontend could control authoritative result data';
  end if;
end;
$$;

commit;

begin;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values
  ('00000000-0000-0000-0000-000000000000','70000000-0000-4000-8000-000000000001',
   'authenticated','authenticated','mock-result-a@example.invalid','',now(),
   '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()),
  ('00000000-0000-0000-0000-000000000000','70000000-0000-4000-8000-000000000002',
   'authenticated','authenticated','mock-result-b@example.invalid','',now(),
   '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now());

do $$
declare
  v_certification_id uuid := (select id from public.certifications where code='az-900');
  v_attempt_all_correct public.mock_exam_attempts;
  v_attempt_all_incorrect public.mock_exam_attempts;
  v_attempt_unanswered public.mock_exam_attempts;
  v_attempt_mixed public.mock_exam_attempts;
  v_attempt_b public.mock_exam_attempts;
  v_completed public.mock_exam_attempts;
  v_second_submit public.mock_exam_attempts;
  v_item record;
  v_result record;
  v_wrong_key text;
  v_domain_total integer;
  v_topic_total integer;
  v_difficulty_total integer;
begin
  perform set_config('request.jwt.claim.sub','70000000-0000-4000-8000-000000000001',true);

  select * into strict v_attempt_all_correct
  from public.start_mock_exam_internal(v_certification_id,'result-all-correct');
  if (select count(*) from public.get_mock_exam_review(v_attempt_all_correct.id)) <> 0
    or (select count(*) from public.get_mock_exam_result(v_attempt_all_correct.id)) <> 0 then
    raise exception '11.5 exposed result/review before completion';
  end if;
  for v_item in select * from public.mock_exam_attempt_questions where attempt_id=v_attempt_all_correct.id loop
    perform * from public.save_mock_exam_answer(v_attempt_all_correct.id,v_item.id,v_item.correct_option_key);
  end loop;
  select * into strict v_completed from public.submit_mock_exam(v_attempt_all_correct.id);
  if v_completed.correct_answers<>40 or v_completed.incorrect_answers<>0
    or v_completed.unanswered_questions<>0 or v_completed.practice_score_percentage<>100 then
    raise exception '11.5 all-correct scoring failed';
  end if;

  select * into strict v_second_submit from public.submit_mock_exam(v_attempt_all_correct.id);
  if v_second_submit.submitted_at<>v_completed.submitted_at
    or v_second_submit.practice_score_percentage<>v_completed.practice_score_percentage then
    raise exception '11.5 double submit changed the persisted result';
  end if;
  if (select count(*) from public.get_mock_exam_review(v_attempt_all_correct.id))<>40 then
    raise exception '11.5 completed Review does not contain 40 Questions';
  end if;

  begin
    perform * from public.save_mock_exam_answer(
      v_attempt_all_correct.id,
      (select id from public.mock_exam_attempt_questions where attempt_id=v_attempt_all_correct.id order by display_order limit 1),
      (select correct_option_key from public.mock_exam_attempt_questions where attempt_id=v_attempt_all_correct.id order by display_order limit 1)
    );
    raise exception '11.5 completed Attempt accepted answer mutation';
  exception when object_not_in_prerequisite_state then null;
  end;

  select * into strict v_attempt_all_incorrect
  from public.start_mock_exam_internal(v_certification_id,'result-all-incorrect');
  for v_item in select * from public.mock_exam_attempt_questions where attempt_id=v_attempt_all_incorrect.id loop
    select option_item->>'key' into strict v_wrong_key
    from jsonb_array_elements(v_item.options_snapshot) option_item
    where option_item->>'key'<>v_item.correct_option_key limit 1;
    perform * from public.save_mock_exam_answer(v_attempt_all_incorrect.id,v_item.id,v_wrong_key);
  end loop;
  select * into strict v_completed from public.submit_mock_exam(v_attempt_all_incorrect.id);
  if v_completed.correct_answers<>0 or v_completed.incorrect_answers<>40
    or v_completed.unanswered_questions<>0 or v_completed.practice_score_percentage<>0 then
    raise exception '11.5 all-incorrect scoring failed';
  end if;

  select * into strict v_attempt_unanswered
  from public.start_mock_exam_internal(v_certification_id,'result-unanswered');
  for v_item in select * from public.mock_exam_attempt_questions where attempt_id=v_attempt_unanswered.id and display_order<=35 loop
    if v_item.display_order<=30 then
      perform * from public.save_mock_exam_answer(v_attempt_unanswered.id,v_item.id,v_item.correct_option_key);
    else
      select option_item->>'key' into strict v_wrong_key
      from jsonb_array_elements(v_item.options_snapshot) option_item
      where option_item->>'key'<>v_item.correct_option_key limit 1;
      perform * from public.save_mock_exam_answer(v_attempt_unanswered.id,v_item.id,v_wrong_key);
    end if;
  end loop;
  select * into strict v_completed from public.submit_mock_exam(v_attempt_unanswered.id);
  if v_completed.correct_answers<>30 or v_completed.incorrect_answers<>5
    or v_completed.unanswered_questions<>5 or v_completed.practice_score_percentage<>75 then
    raise exception '11.5 unanswered scoring failed';
  end if;

  select * into strict v_result from public.get_mock_exam_result(v_attempt_unanswered.id);
  select coalesce(sum((entry->>'totalQuestions')::integer),0) into v_domain_total
  from jsonb_array_elements(v_result.domain_breakdown) entry;
  select coalesce(sum((entry->>'totalQuestions')::integer),0) into v_topic_total
  from jsonb_array_elements(v_result.topic_breakdown) entry;
  select coalesce(sum((entry->>'totalQuestions')::integer),0) into v_difficulty_total
  from jsonb_array_elements(v_result.difficulty_breakdown) entry;
  if v_domain_total<>40 or v_topic_total<>40 or v_difficulty_total<>40
    or exists(select 1 from jsonb_array_elements(v_result.topic_breakdown) entry
      where (entry->>'totalQuestions')::integer=0)
    or v_result.correct_answers+v_result.incorrect_answers+v_result.unanswered_questions<>40 then
    raise exception '11.5 breakdown invariants failed';
  end if;

  select * into strict v_attempt_mixed
  from public.start_mock_exam_internal(v_certification_id,'result-mixed');
  for v_item in select * from public.mock_exam_attempt_questions where attempt_id=v_attempt_mixed.id and display_order<=30 loop
    if v_item.display_order<=17 then
      perform * from public.save_mock_exam_answer(v_attempt_mixed.id,v_item.id,v_item.correct_option_key);
    else
      select option_item->>'key' into strict v_wrong_key
      from jsonb_array_elements(v_item.options_snapshot) option_item
      where option_item->>'key'<>v_item.correct_option_key limit 1;
      perform * from public.save_mock_exam_answer(v_attempt_mixed.id,v_item.id,v_wrong_key);
    end if;
  end loop;
  select * into strict v_completed from public.submit_mock_exam(v_attempt_mixed.id);
  if v_completed.correct_answers<>17 or v_completed.incorrect_answers<>13
    or v_completed.unanswered_questions<>10 or v_completed.practice_score_percentage<>42.50 then
    raise exception '11.5 mixed scoring failed';
  end if;

  perform set_config('request.jwt.claim.sub','70000000-0000-4000-8000-000000000002',true);
  select * into strict v_attempt_b from public.start_mock_exam_internal(v_certification_id,'result-user-b');
  if (select count(*) from public.get_mock_exam_result(v_attempt_unanswered.id))<>0
    or (select count(*) from public.get_mock_exam_review(v_attempt_unanswered.id))<>0 then
    raise exception '11.5 user B accessed user A result or Review';
  end if;
  begin
    perform * from public.submit_mock_exam(v_attempt_unanswered.id);
    raise exception '11.5 user B submitted user A Attempt';
  exception when insufficient_privilege then null;
  end;
end;
$$;

rollback;

begin;

do $$
declare
  v_source text;
begin
  select pg_get_functiondef('public.get_mock_exam_attempt_questions(uuid)'::regprocedure)
  into v_source;
  if v_source like '%correct_option%'
    or v_source like '%explanation_snapshot%'
    or v_source like '%difficulty_snapshot%'
    or v_source like '%domain_title_snapshot%'
    or v_source like '%topic_title_snapshot%' then
    raise exception '11.4 active execution DTO leaks private/pedagogical metadata';
  end if;

  if has_function_privilege('anon','public.submit_mock_exam(uuid)','EXECUTE')
    or not has_function_privilege('authenticated','public.submit_mock_exam(uuid)','EXECUTE') then
    raise exception '11.4 submit grants are invalid';
  end if;
end;
$$;

commit;

begin;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values
  ('00000000-0000-0000-0000-000000000000','67000000-0000-4000-8000-000000000001',
   'authenticated','authenticated','mock-ui-a@example.invalid','',now(),
   '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()),
  ('00000000-0000-0000-0000-000000000000','67000000-0000-4000-8000-000000000002',
   'authenticated','authenticated','mock-ui-b@example.invalid','',now(),
   '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now());

do $$
declare
  v_certification_id uuid := (select id from public.certifications where code='az-900');
  v_attempt_a public.mock_exam_attempts;
  v_attempt_b public.mock_exam_attempts;
  v_question record;
  v_option_key text;
  v_completed public.mock_exam_attempts;
begin
  perform set_config('request.jwt.claim.sub','67000000-0000-4000-8000-000000000001',true);
  select * into strict v_attempt_a from public.start_mock_exam_internal(v_certification_id,'ui-a');
  select * into strict v_question from public.get_mock_exam_attempt_questions(v_attempt_a.id)
    order by display_order limit 1;
  select option_item->>'key' into v_option_key
    from jsonb_array_elements(v_question.options) option_item limit 1;
  perform * from public.save_mock_exam_answer(v_attempt_a.id,v_question.id,v_option_key);

  select * into strict v_completed from public.submit_mock_exam(v_attempt_a.id);
  if v_completed.status<>'completed' or v_completed.answered_questions<>1
    or v_completed.correct_answers+v_completed.incorrect_answers<>1
    or v_completed.unanswered_questions<>39
    or v_completed.practice_score_percentage not in (0,2.50)
    or (select count(*) from public.get_mock_exam_attempt_questions(v_attempt_a.id))<>0 then
    raise exception '11.4 server-authoritative Submit result is inconsistent';
  end if;

  select * into strict v_completed from public.submit_mock_exam(v_attempt_a.id);
  if v_completed.status<>'completed' then raise exception '11.4 Submit is not idempotent'; end if;

  begin
    perform * from public.save_mock_exam_answer(v_attempt_a.id,v_question.id,v_option_key);
    raise exception '11.4 completed attempt accepted answer mutation';
  exception when object_not_in_prerequisite_state then null;
  end;

  perform set_config('request.jwt.claim.sub','67000000-0000-4000-8000-000000000002',true);
  select * into strict v_attempt_b from public.start_mock_exam_internal(v_certification_id,'ui-b');
  begin
    perform * from public.submit_mock_exam(v_attempt_a.id);
    raise exception '11.4 user B submitted user A attempt';
  exception when insufficient_privilege then null;
  end;
  if (select count(*) from public.get_mock_exam_attempt_questions(v_attempt_a.id))<>0 then
    raise exception '11.4 user B loaded user A execution payload';
  end if;
end;
$$;

rollback;

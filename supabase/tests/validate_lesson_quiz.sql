begin;

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
)
values
  ('00000000-0000-0000-0000-000000000000', '52000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'quiz-test-a@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()),
  ('00000000-0000-0000-0000-000000000000', '52000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'quiz-test-b@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now());

set local role authenticated;
select set_config('request.jwt.claim.sub', '52000000-0000-4000-8000-000000000001', true);

do $$
declare
  v_lesson_id uuid := (select id from public.lessons where slug = 'availability-zones');
  v_attempt public.quiz_attempts;
  v_same_attempt public.quiz_attempts;
  v_feedback record;
  v_new_attempt public.quiz_attempts;
begin
  select * into strict v_attempt from public.start_lesson_quiz(v_lesson_id);

  if v_attempt.user_id <> auth.uid() or v_attempt.total_questions <> 5 or v_attempt.status <> 'in_progress' then
    raise exception 'The initial attempt is invalid.';
  end if;

  if (select count(*) from public.quiz_attempt_questions where attempt_id = v_attempt.id) <> 5 then
    raise exception 'The attempt did not persist exactly 5 questions.';
  end if;

  select * into strict v_same_attempt from public.start_lesson_quiz(v_lesson_id);
  if v_same_attempt.id <> v_attempt.id then
    raise exception 'Starting an active lesson quiz created a duplicate attempt.';
  end if;

  begin
    perform is_correct from public.question_options limit 1;
    raise exception 'The answer key is directly readable by authenticated users.';
  exception
    when insufficient_privilege then null;
  end;

  if (select count(*) from public.question_options_public where question_id in (
    select question_id from public.quiz_attempt_questions where attempt_id = v_attempt.id
  )) <> 20 then
    raise exception 'The public options view did not return the expected safe options.';
  end if;

  begin
    perform * from public.submit_quiz_answer(
      v_attempt.id,
      '60000000-0000-4000-8000-000000000001',
      '70000000-0000-4000-8000-000000000001'
    );
    raise exception 'A question outside the attempt was accepted.';
  exception
    when foreign_key_violation then null;
  end;

  begin
    perform * from public.submit_quiz_answer(
      v_attempt.id,
      '60000000-0000-4000-8000-000000000005',
      '70000000-0000-4000-8000-000000000001'
    );
    raise exception 'An option from another question was accepted.';
  exception
    when foreign_key_violation then null;
  end;

  select * into strict v_feedback from public.submit_quiz_answer(
    v_attempt.id,
    '60000000-0000-4000-8000-000000000005',
    '70000000-0000-4000-8000-000000000018'
  );
  if v_feedback.is_correct or v_feedback.correct_option_id <> '70000000-0000-4000-8000-000000000017' then
    raise exception 'Incorrect-answer feedback is invalid.';
  end if;

  perform * from public.submit_quiz_answer(
    v_attempt.id,
    '60000000-0000-4000-8000-000000000005',
    '70000000-0000-4000-8000-000000000018'
  );
  if (select count(*) from public.quiz_answers where attempt_id = v_attempt.id) <> 1 then
    raise exception 'Idempotent retry created a duplicate answer.';
  end if;

  begin
    perform * from public.submit_quiz_answer(
      v_attempt.id,
      '60000000-0000-4000-8000-000000000005',
      '70000000-0000-4000-8000-000000000017'
    );
    raise exception 'Changing an existing answer unexpectedly succeeded.';
  exception
    when unique_violation then null;
  end;

  if (select count(*) from public.quiz_answers where attempt_id = v_attempt.id) <> 1 then
    raise exception 'Refresh state did not preserve the first answer.';
  end if;

  perform * from public.submit_quiz_answer(v_attempt.id, '61000000-0000-4000-8000-000000000001', '71000000-0000-4000-8000-000000000001');
  perform * from public.submit_quiz_answer(v_attempt.id, '61000000-0000-4000-8000-000000000002', '71000000-0000-4000-8000-000000000005');
  perform * from public.submit_quiz_answer(v_attempt.id, '61000000-0000-4000-8000-000000000003', '71000000-0000-4000-8000-000000000009');
  select * into strict v_feedback from public.submit_quiz_answer(v_attempt.id, '61000000-0000-4000-8000-000000000004', '71000000-0000-4000-8000-000000000013');

  if not v_feedback.attempt_completed or v_feedback.correct_answers <> 4 or v_feedback.score_percentage <> 80 then
    raise exception 'The final score was not calculated server-side as 4/5 and 80%%.';
  end if;

  if (select status from public.quiz_attempts where id = v_attempt.id) <> 'completed'
    or (select completed_at from public.quiz_attempts where id = v_attempt.id) is null then
    raise exception 'The attempt was not finalized.';
  end if;

  if (select count(*) from public.get_quiz_answer_review(v_attempt.id)) <> 5 then
    raise exception 'Completed-attempt review did not return all answers.';
  end if;

  perform set_config('quiz.test_user_a_attempt', v_attempt.id::text, true);

  begin
    perform * from public.submit_quiz_answer(
      v_attempt.id,
      '60000000-0000-4000-8000-000000000001',
      '70000000-0000-4000-8000-000000000001'
    );
    raise exception 'A completed attempt accepted another answer.';
  exception
    when object_not_in_prerequisite_state then null;
  end;

  select * into strict v_new_attempt from public.start_lesson_quiz(v_lesson_id);
  if v_new_attempt.id = v_attempt.id or v_new_attempt.status <> 'in_progress' then
    raise exception 'Retaking the Quiz did not create a new attempt.';
  end if;

  begin
    insert into public.quiz_answers (attempt_id, question_id, selected_option_id, is_correct)
    values (v_new_attempt.id, '60000000-0000-4000-8000-000000000005', '70000000-0000-4000-8000-000000000017', true);
    raise exception 'Direct authenticated answer INSERT unexpectedly succeeded.';
  exception
    when insufficient_privilege then null;
  end;
end;
$$;

select set_config('request.jwt.claim.sub', '52000000-0000-4000-8000-000000000002', true);

do $$
declare
  v_user_a_attempt uuid := current_setting('quiz.test_user_a_attempt')::uuid;
  v_lesson_id uuid := (select id from public.lessons where slug = 'availability-zones');
  v_user_b_attempt public.quiz_attempts;
begin
  if exists (select 1 from public.quiz_attempts where user_id = '52000000-0000-4000-8000-000000000001') then
    raise exception 'User B can read user A attempts.';
  end if;

  if exists (select 1 from public.get_quiz_answer_review(v_user_a_attempt)) then
    raise exception 'User B can review user A answers.';
  end if;

  begin
    perform * from public.submit_quiz_answer(
      v_user_a_attempt,
      '60000000-0000-4000-8000-000000000005',
      '70000000-0000-4000-8000-000000000018'
    );
    raise exception 'User B submitted an answer to user A attempt.';
  exception
    when insufficient_privilege then null;
  end;

  select * into strict v_user_b_attempt from public.start_lesson_quiz(v_lesson_id);
  if v_user_b_attempt.user_id <> auth.uid() then
    raise exception 'User B attempt has the wrong owner.';
  end if;
end;
$$;

reset role;

select json_build_object(
  'five_question_attempt', true,
  'safe_public_options', true,
  'server_answer_validation', true,
  'idempotent_double_click', true,
  'refresh_persistence', true,
  'final_score', '4/5 (80%)',
  'retake_created_new_attempt', true,
  'cross_user_isolation', true
) as lesson_quiz_validation;

rollback;

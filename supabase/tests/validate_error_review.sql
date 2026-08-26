begin;

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values
  ('00000000-0000-0000-0000-000000000000', '54000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'review-a@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()),
  ('00000000-0000-0000-0000-000000000000', '54000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'review-b@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now());

insert into public.questions (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select
  format('6e000000-0000-4000-8000-%s', lpad(series::text, 12, '0'))::uuid,
  domain.certification_id, domain.id, topic.id, lesson.id,
  format('Temporary review question %s', series), 'single_choice', 'medium',
  'Temporary transactional review explanation.', true, 100 + series
from generate_series(1, 13) series
join public.lessons lesson on lesson.slug = 'availability-zones'
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id;

insert into public.question_options (
  id, question_id, option_text, is_correct, explanation, display_order
)
select format('%s000000-0000-4000-8000-%s', prefix, lpad(series::text, 12, '0'))::uuid,
  format('6e000000-0000-4000-8000-%s', lpad(series::text, 12, '0'))::uuid,
  case when prefix = '7e' then 'Correct option' else 'Wrong option' end,
  prefix = '7e', 'Temporary option.', case when prefix = '7e' then 1 else 2 end
from generate_series(1, 13) series cross join (values ('7e'), ('7f')) prefixes(prefix);

create temporary table review_test_correct (question_id uuid primary key, option_id uuid not null) on commit drop;
insert into review_test_correct
select id, format('7e000000-0000-4000-8000-%s', lpad(right(id::text, 12), 12, '0'))::uuid
from public.questions where question_text like 'Temporary review question %';
grant select on review_test_correct to authenticated;

insert into public.quiz_attempts (id, user_id, certification_id, quiz_type, lesson_id, total_questions, status, completed_at)
values
  ('64000000-0000-4000-8000-000000000001', '54000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000900', 'lesson', (select id from public.lessons where slug='availability-zones'), 10, 'completed', now() - interval '3 days'),
  ('64000000-0000-4000-8000-000000000002', '54000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000900', 'lesson', (select id from public.lessons where slug='availability-zones'), 3, 'completed', now() - interval '2 days'),
  ('64000000-0000-4000-8000-000000000003', '54000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000900', 'lesson', (select id from public.lessons where slug='availability-zones'), 2, 'completed', now() - interval '1 day');

insert into public.quiz_attempt_questions (attempt_id, question_id, display_order)
select '64000000-0000-4000-8000-000000000001'::uuid, format('6e000000-0000-4000-8000-%s', lpad(series::text,12,'0'))::uuid, series from generate_series(1,10) series
union all select '64000000-0000-4000-8000-000000000002'::uuid, question_id, display_order from (values
  ('6e000000-0000-4000-8000-000000000001'::uuid,1),
  ('6e000000-0000-4000-8000-000000000011'::uuid,2),
  ('6e000000-0000-4000-8000-000000000012'::uuid,3)
) second_attempt(question_id,display_order)
union all select '64000000-0000-4000-8000-000000000003'::uuid, question_id, display_order from (values
  ('6e000000-0000-4000-8000-000000000001'::uuid,1), ('6e000000-0000-4000-8000-000000000013'::uuid,2)
) selected(question_id,display_order);

insert into public.quiz_answers (attempt_id, question_id, selected_option_id, is_correct, answered_at)
select '64000000-0000-4000-8000-000000000001'::uuid, format('6e000000-0000-4000-8000-%s', lpad(series::text,12,'0'))::uuid,
  format('7f000000-0000-4000-8000-%s', lpad(series::text,12,'0'))::uuid, false, now() - interval '3 days' + series * interval '1 minute'
from generate_series(1,10) series
union all
select '64000000-0000-4000-8000-000000000002'::uuid, question_id, option_id, false, now() - interval '2 days' + display_order * interval '1 minute'
from (values
  ('6e000000-0000-4000-8000-000000000001'::uuid,'7f000000-0000-4000-8000-000000000001'::uuid,1),
  ('6e000000-0000-4000-8000-000000000011'::uuid,'7f000000-0000-4000-8000-000000000011'::uuid,2),
  ('6e000000-0000-4000-8000-000000000012'::uuid,'7f000000-0000-4000-8000-000000000012'::uuid,3)
) second_answers(question_id,option_id,display_order)
union all
select '64000000-0000-4000-8000-000000000003'::uuid, question_id, option_id, true, now() - interval '1 day' + display_order * interval '1 minute'
from (values
  ('6e000000-0000-4000-8000-000000000001'::uuid,'7e000000-0000-4000-8000-000000000001'::uuid,1),
  ('6e000000-0000-4000-8000-000000000013'::uuid,'7e000000-0000-4000-8000-000000000013'::uuid,2)
) selected(question_id,option_id,display_order);

do $$ begin
  begin
    insert into public.quiz_attempts (user_id, certification_id, quiz_type, lesson_id, total_questions)
    values ('54000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000900','review',(select id from public.lessons limit 1),1);
    raise exception 'Review scope accepted a lesson.';
  exception when check_violation then null; end;
end $$;

set local role authenticated;
select set_config('request.jwt.claim.sub', '54000000-0000-4000-8000-000000000001', true);

create temporary table first_review_questions (question_id uuid primary key) on commit drop;
grant select, insert on first_review_questions to authenticated;

do $$
declare v_attempt public.quiz_attempts; v_same public.quiz_attempts; v_stats record; v_question record;
begin
  if (select count(*) from public.get_user_question_stats('10000000-0000-4000-8000-000000000900')) <> 12 then
    raise exception 'Stats must contain exactly the 12 questions with errors.'; end if;
  if exists (select 1 from public.get_user_question_stats('10000000-0000-4000-8000-000000000900') where question_id='6e000000-0000-4000-8000-000000000013') then
    raise exception 'A question answered only correctly appeared in Meus Erros.'; end if;
  select * into strict v_stats from public.get_user_question_stats('10000000-0000-4000-8000-000000000900') where question_id='6e000000-0000-4000-8000-000000000001';
  if v_stats.total_attempts<>3 or v_stats.correct_count<>1 or v_stats.incorrect_count<>2
    or round(v_stats.accuracy_percentage)<>33 or round(v_stats.error_percentage)<>67 or not v_stats.last_result then
    raise exception 'Error/error/correct aggregation is invalid.'; end if;
  if exists (select 1 from public.get_user_question_stats('10000000-0000-4000-8000-000000000104')) then
    raise exception 'Certification isolation failed.'; end if;

  select * into strict v_attempt from public.start_review_quiz('10000000-0000-4000-8000-000000000900');
  if v_attempt.quiz_type<>'review' or v_attempt.lesson_id is not null or v_attempt.topic_id is not null or v_attempt.total_questions<>10 then
    raise exception 'Review attempt scope or total is invalid.'; end if;
  if (select count(*) from public.quiz_attempt_questions where attempt_id=v_attempt.id)<>10 then raise exception 'Review selection was not persisted.'; end if;
  if exists (select 1 from public.quiz_attempt_questions aq join public.questions q on q.id=aq.question_id where aq.attempt_id=v_attempt.id and (not q.is_published or q.certification_id<>v_attempt.certification_id)) then raise exception 'Review selected an invalid question.'; end if;
  insert into first_review_questions select question_id from public.quiz_attempt_questions where attempt_id=v_attempt.id;
  select * into strict v_same from public.start_review_quiz('10000000-0000-4000-8000-000000000900');
  if v_same.id<>v_attempt.id then raise exception 'Active review was duplicated.'; end if;

  for v_question in select aq.question_id, correct.option_id from public.quiz_attempt_questions aq join review_test_correct correct using(question_id) where aq.attempt_id=v_attempt.id order by aq.display_order limit 4 loop
    perform * from public.submit_quiz_answer(v_attempt.id,v_question.question_id,v_question.option_id); end loop;
  if (select count(*) from public.quiz_answers where attempt_id=v_attempt.id)<>4 then raise exception 'Refresh did not preserve 4 review answers.'; end if;
  select * into strict v_same from public.start_review_quiz('10000000-0000-4000-8000-000000000900');
  if v_same.id<>v_attempt.id then raise exception 'Refresh did not return active review.'; end if;
  for v_question in select aq.question_id, correct.option_id from public.quiz_attempt_questions aq join review_test_correct correct using(question_id) where aq.attempt_id=v_attempt.id and not exists(select 1 from public.quiz_answers a where a.attempt_id=v_attempt.id and a.question_id=aq.question_id) order by aq.display_order loop
    perform * from public.submit_quiz_answer(v_attempt.id,v_question.question_id,v_question.option_id); end loop;
  if (select status from public.quiz_attempts where id=v_attempt.id)<>'completed' then raise exception 'Review was not completed by shared submit engine.'; end if;

  select * into strict v_attempt from public.start_review_quiz('10000000-0000-4000-8000-000000000900');
  if (select count(*) from public.quiz_attempt_questions aq join first_review_questions first using(question_id) where aq.attempt_id=v_attempt.id)=10 then raise exception 'Rotation selected exactly the same 10 questions.'; end if;
  for v_question in select aq.question_id, correct.option_id from public.quiz_attempt_questions aq join review_test_correct correct using(question_id) where aq.attempt_id=v_attempt.id order by aq.display_order loop
    perform * from public.submit_quiz_answer(v_attempt.id,v_question.question_id,v_question.option_id); end loop;

  select * into strict v_attempt from public.start_review_quiz('10000000-0000-4000-8000-000000000900','6e000000-0000-4000-8000-000000000001');
  if v_attempt.total_questions<>1 or (select count(*) from public.quiz_attempt_questions where attempt_id=v_attempt.id and question_id='6e000000-0000-4000-8000-000000000001')<>1 then raise exception 'Individual review is invalid.'; end if;
  perform * from public.submit_quiz_answer(v_attempt.id,'6e000000-0000-4000-8000-000000000001','7e000000-0000-4000-8000-000000000001');
  select * into strict v_stats from public.get_user_question_stats('10000000-0000-4000-8000-000000000900') where question_id='6e000000-0000-4000-8000-000000000001';
  if v_stats.incorrect_count<>2 or v_stats.correct_count<2 then raise exception 'Stats did not update after review while preserving error history.'; end if;

  begin perform * from public.start_review_quiz('10000000-0000-4000-8000-000000000900','6e000000-0000-4000-8000-000000000013'); raise exception 'Correct-only question started an individual review.'; exception when no_data_found then null; end;
  begin perform * from public.start_review_quiz('10000000-0000-4000-8000-000000000104','6e000000-0000-4000-8000-000000000001'); raise exception 'Question from another certification started.'; exception when no_data_found then null; end;
  perform set_config('review.user_a_attempt',v_attempt.id::text,true);
end $$;

select set_config('request.jwt.claim.sub', '54000000-0000-4000-8000-000000000002', true);
do $$ begin
  if exists(select 1 from public.get_user_question_stats('10000000-0000-4000-8000-000000000900')) then raise exception 'User B can read user A error history.'; end if;
  if exists(select 1 from public.quiz_attempts where id=current_setting('review.user_a_attempt')::uuid) then raise exception 'User B can read user A review attempt.'; end if;
  begin perform * from public.start_review_quiz('10000000-0000-4000-8000-000000000900'); raise exception 'User without errors started review.'; exception when no_data_found then null; end;
end $$;

reset role;
select json_build_object(
  'error_only_history', true, 'error_error_correct_aggregation', true,
  'ten_priority_questions', true, 'selection_rotation', true,
  'refresh_four_of_ten', true, 'individual_review', true,
  'stats_update', true, 'shared_submit_engine', true,
  'user_isolation', true, 'certification_isolation', true,
  'answer_key_protected', not has_table_privilege('authenticated','public.question_options','select')
) as error_review_validation;
rollback;

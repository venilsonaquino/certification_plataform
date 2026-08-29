begin;

do $$ begin
  if exists(select 1 from auth.users where id in(
    '58000000-0000-4000-8000-000000000030','58000000-0000-4000-8000-000000000031','58000000-0000-4000-8000-000000000032')) then
    raise exception '9.4 temporary validation user UUID already exists'; end if;
end; $$;

create temporary table target_lessons on commit drop as
select lesson.id,lesson.slug,lesson.display_order,certification.id certification_id
from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and domain.title='Describe Azure management and governance'
  and topic.id='33000000-0000-4000-8000-000000000001' and topic.title='Cost Management'
  and lesson.slug in ('azure-cost-factors','pricing-calculator','azure-cost-management','resource-tags');

create temporary table wrong_options(question_id uuid primary key,option_id uuid not null) on commit drop;
insert into wrong_options select question.id,(array_agg(option.id order by option.display_order) filter(where not option.is_correct))[1]
from public.questions question join target_lessons target on target.id=question.lesson_id
join public.question_options option on option.question_id=question.id group by question.id;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select '00000000-0000-0000-0000-000000000000',seed.id,'authenticated','authenticated',seed.email,'',now(),
  '{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now()
from(values
  ('58000000-0000-4000-8000-000000000030'::uuid,'cost-closure-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000031'::uuid,'cost-closure-b@example.invalid'),
  ('58000000-0000-4000-8000-000000000032'::uuid,'cost-closure-c@example.invalid')) seed(id,email);
grant select on target_lessons,wrong_options to authenticated;
set local role authenticated;

do $$
declare seeded_user uuid; attempt public.quiz_attempts; first_attempt_id uuid;
begin
  foreach seeded_user in array array['58000000-0000-4000-8000-000000000030'::uuid,
    '58000000-0000-4000-8000-000000000031'::uuid,'58000000-0000-4000-8000-000000000032'::uuid]
  loop
    perform set_config('request.jwt.claim.sub',seeded_user::text,true);
    select * into strict attempt from public.start_topic_quiz('33000000-0000-4000-8000-000000000001');
    if attempt.total_questions<>10 or (select count(*) from public.quiz_attempt_questions where attempt_id=attempt.id)<>10
      or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id
        where item.attempt_id=attempt.id)<>4
      or exists(select 1 from target_lessons target where not exists(select 1 from public.quiz_attempt_questions item
        join public.questions question on question.id=item.question_id where item.attempt_id=attempt.id and question.lesson_id=target.id))
      or exists(select 1 from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id
        where item.attempt_id=attempt.id group by question.lesson_id having count(*)>3) then
      raise exception '9.4 Topic Quiz is not balanced across all four Lessons'; end if;
    if first_attempt_id is null then first_attempt_id:=attempt.id; end if;
  end loop;
  perform set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000031',true);
  if exists(select 1 from public.quiz_attempts where id=first_attempt_id) then raise exception '9.4 Quiz history leaked across users'; end if;
end; $$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000030',true);
do $$
declare lesson_target record; attempt public.quiz_attempts; question_record record; started public.user_lesson_progress;
  completed public.user_lesson_progress; target_card_id uuid; review_attempt public.quiz_attempts; target_certification_id uuid;
begin
  for lesson_target in select id from target_lessons order by display_order loop
    select * into strict attempt from public.start_lesson_quiz(lesson_target.id);
    if attempt.total_questions<>5 or (select count(*) from public.quiz_attempt_questions where attempt_id=attempt.id)<>5 then
      raise exception '9.4 Lesson Quiz failed for %',lesson_target.id; end if;
    if lesson_target.id=(select id from target_lessons order by display_order limit 1) then
      for question_record in select item.question_id,wrong.option_id from public.quiz_attempt_questions item
        join wrong_options wrong on wrong.question_id=item.question_id where item.attempt_id=attempt.id order by item.display_order
      loop perform * from public.submit_quiz_answer(attempt.id,question_record.question_id,question_record.option_id); end loop;
    end if;
  end loop;
  select * into strict started from public.start_lesson_progress((select id from target_lessons order by display_order limit 1));
  select * into strict completed from public.complete_lesson_progress((select id from target_lessons order by display_order limit 1));
  if started.status<>'in_progress' or completed.status<>'completed' or completed.completed_at is null then
    raise exception '9.4 Lesson progress flow failed'; end if;
  select card.id into strict target_card_id from public.flashcards card join target_lessons target on target.id=card.lesson_id
    where card.is_published order by target.display_order,card.display_order limit 1;
  perform public.submit_flashcard_review(target_card_id,'good');
  if not exists(select 1 from public.flashcard_reviews where flashcard_id=target_card_id)
    or not exists(select 1 from public.user_flashcard_progress where flashcard_id=target_card_id) then
    raise exception '9.4 spaced repetition failed'; end if;
  select certification_id into strict target_certification_id from target_lessons limit 1;
  select * into strict review_attempt from public.start_review_quiz(target_certification_id);
  if review_attempt.quiz_type<>'review' or review_attempt.total_questions<>5
    or (select count(*) from public.quiz_attempt_questions where attempt_id=review_attempt.id)<>5 then
    raise exception '9.4 Review flow failed'; end if;
end; $$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000031',true);
do $$ begin
  if exists(select 1 from public.user_lesson_progress where user_id='58000000-0000-4000-8000-000000000030')
    or exists(select 1 from public.flashcard_reviews where user_id='58000000-0000-4000-8000-000000000030')
    or exists(select 1 from public.user_flashcard_progress where user_id='58000000-0000-4000-8000-000000000030') then
    raise exception '9.4 progress or review state leaked across users'; end if;
end; $$;
reset role;
set local role postgres;

delete from public.quiz_answers where attempt_id in(select id from public.quiz_attempts where user_id in(
  '58000000-0000-4000-8000-000000000030','58000000-0000-4000-8000-000000000031','58000000-0000-4000-8000-000000000032'));
delete from public.quiz_attempt_questions where attempt_id in(select id from public.quiz_attempts where user_id in(
  '58000000-0000-4000-8000-000000000030','58000000-0000-4000-8000-000000000031','58000000-0000-4000-8000-000000000032'));
delete from public.quiz_attempts where user_id in(
  '58000000-0000-4000-8000-000000000030','58000000-0000-4000-8000-000000000031','58000000-0000-4000-8000-000000000032');
delete from public.flashcard_reviews where user_id in(
  '58000000-0000-4000-8000-000000000030','58000000-0000-4000-8000-000000000031','58000000-0000-4000-8000-000000000032');
delete from public.user_flashcard_progress where user_id in(
  '58000000-0000-4000-8000-000000000030','58000000-0000-4000-8000-000000000031','58000000-0000-4000-8000-000000000032');
delete from public.user_lesson_progress where user_id in(
  '58000000-0000-4000-8000-000000000030','58000000-0000-4000-8000-000000000031','58000000-0000-4000-8000-000000000032');
delete from auth.users where id in(
  '58000000-0000-4000-8000-000000000030','58000000-0000-4000-8000-000000000031','58000000-0000-4000-8000-000000000032');

do $$ begin
  if exists(select 1 from auth.users where id in(
    '58000000-0000-4000-8000-000000000030','58000000-0000-4000-8000-000000000031','58000000-0000-4000-8000-000000000032'))
    or exists(select 1 from public.quiz_attempts where user_id in(
      '58000000-0000-4000-8000-000000000030','58000000-0000-4000-8000-000000000031','58000000-0000-4000-8000-000000000032'))
    or exists(select 1 from public.user_lesson_progress where user_id in(
      '58000000-0000-4000-8000-000000000030','58000000-0000-4000-8000-000000000031','58000000-0000-4000-8000-000000000032')) then
    raise exception '9.4 temporary validation data cleanup failed'; end if;
end; $$;

set role postgres;
commit;

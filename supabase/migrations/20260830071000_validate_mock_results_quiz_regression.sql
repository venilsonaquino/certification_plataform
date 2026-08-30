begin;

do $$
begin
  if to_regprocedure('public.start_lesson_quiz(uuid)') is null
    or to_regprocedure('public.start_topic_quiz(uuid)') is null
    or to_regprocedure('public.submit_quiz_answer(uuid,uuid,uuid)') is null
    or to_regprocedure('public.start_review_quiz(uuid,uuid)') is null
    or to_regprocedure('public.submit_flashcard_review(uuid,text)') is null then
    raise exception '11.5 existing practice RPCs are missing';
  end if;
end;
$$;

commit;

begin;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values('00000000-0000-0000-0000-000000000000','71000000-0000-4000-8000-000000000001',
  'authenticated','authenticated','mock-results-regression@example.invalid','',now(),
  '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now());

create temporary table audit_115_answer_key on commit drop as
select question.id question_id,
  (array_agg(option.id order by option.display_order) filter(where not option.is_correct))[1] incorrect_id
from public.questions question join public.question_options option on option.question_id=question.id
group by question.id
having count(*) filter(where option.is_correct)=1 and count(*) filter(where not option.is_correct)>0;

grant select on audit_115_answer_key to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub','71000000-0000-4000-8000-000000000001',true);

do $$
declare
  v_certification_id uuid := (select id from public.certifications where code='az-900');
  v_lesson public.quiz_attempts;
  v_topic_one public.quiz_attempts;
  v_topic_two public.quiz_attempts;
  v_review public.quiz_attempts;
  v_item record;
  v_card uuid;
begin
  select * into strict v_lesson
  from public.start_lesson_quiz((select id from public.lessons where slug='what-is-cloud-computing'));
  if v_lesson.total_questions<>5 then raise exception '11.5 Lesson Quiz regressed'; end if;

  select * into strict v_topic_one from public.start_topic_quiz((
    select topic.id from public.topics topic
    join public.domains domain on domain.id=topic.domain_id
    join public.questions question on question.topic_id=topic.id and question.is_published
    where domain.certification_id=v_certification_id
    group by topic.id order by count(*) desc,topic.id limit 1
  ));
  if v_topic_one.total_questions<>10 then raise exception '11.5 Topic Quiz regressed'; end if;

  for v_item in
    select item.question_id,key.incorrect_id
    from public.quiz_attempt_questions item
    join audit_115_answer_key key on key.question_id=item.question_id
    where item.attempt_id=v_topic_one.id order by item.display_order
  loop
    perform * from public.submit_quiz_answer(v_topic_one.id,v_item.question_id,v_item.incorrect_id);
  end loop;

  select * into strict v_topic_two from public.start_topic_quiz(v_topic_one.topic_id);
  if v_topic_two.id=v_topic_one.id or v_topic_two.total_questions<>10
    or (select count(*) from public.quiz_attempt_questions first_item
      join public.quiz_attempt_questions second_item on second_item.question_id=first_item.question_id
      where first_item.attempt_id=v_topic_one.id and second_item.attempt_id=v_topic_two.id)>=10 then
    raise exception '11.5 Topic Quiz retake rotation regressed';
  end if;

  select * into strict v_review from public.start_review_quiz(v_certification_id,null);
  if v_review.total_questions not between 5 and 10 then raise exception '11.5 Review regressed'; end if;

  select card.id into strict v_card from public.flashcards card
  join public.lessons lesson on lesson.id=card.lesson_id
  join public.topics topic on topic.id=lesson.topic_id
  join public.domains domain on domain.id=topic.domain_id
  where domain.certification_id=v_certification_id and card.is_published order by card.id limit 1;
  perform public.submit_flashcard_review(v_card,'good');
  if not exists(select 1 from public.user_flashcard_progress
      where user_id='71000000-0000-4000-8000-000000000001' and flashcard_id=v_card) then
    raise exception '11.5 Spaced Repetition regressed';
  end if;
end;
$$;

rollback;

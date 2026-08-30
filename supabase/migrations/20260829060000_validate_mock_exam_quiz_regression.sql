begin;

do $$
begin
  if to_regprocedure('public.start_lesson_quiz(uuid)') is null
    or to_regprocedure('public.start_topic_quiz(uuid)') is null
    or to_regprocedure('public.submit_quiz_answer(uuid,uuid,uuid)') is null
    or to_regprocedure('public.start_review_quiz(uuid,uuid)') is null
    or to_regprocedure('public.submit_flashcard_review(uuid,text)') is null then
    raise exception '11.2 existing practice RPCs are missing';
  end if;

  if exists (
    select 1 from public.quiz_attempt_questions item
    left join public.quiz_attempts attempt on attempt.id = item.attempt_id
    left join public.questions question on question.id = item.question_id
    where attempt.id is null or question.id is null
  ) or exists (
    select 1 from public.quiz_answers answer
    left join public.quiz_attempts attempt on attempt.id = answer.attempt_id
    left join public.quiz_attempt_questions item
      on item.attempt_id = answer.attempt_id and item.question_id = answer.question_id
    where attempt.id is null or item.id is null
  ) then
    raise exception '11.2 existing Quiz history contains orphan relationships';
  end if;
end;
$$;

commit;

begin;

insert into auth.users(
  instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at
) values (
  '00000000-0000-0000-0000-000000000000','5a000000-0000-4000-8000-000000000001',
  'authenticated','authenticated','mock-quiz-regression@example.invalid','',now(),
  '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()
);

create temporary table audit_112_quiz_context on commit drop as
select
  (select id from public.certifications where code = 'az-900') as certification_id,
  (select id from public.lessons where slug = 'what-is-cloud-computing') as lesson_id,
  (
    select topic.id
    from public.topics topic
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    join public.questions question on question.topic_id = topic.id
      and question.is_published and question.question_type = 'single_choice'
    where certification.code = 'az-900'
    group by topic.id
    order by count(*) desc, topic.id
    limit 1
  ) as topic_id;

create temporary table audit_112_answer_key on commit drop as
select
  question.id as question_id,
  (array_agg(option.id order by option.display_order) filter (where option.is_correct))[1]
    as correct_option_id,
  (array_agg(option.id order by option.display_order) filter (where not option.is_correct))[1]
    as incorrect_option_id
from public.questions question
join public.question_options option on option.question_id = question.id
group by question.id
having count(*) filter (where option.is_correct) = 1
  and count(*) filter (where not option.is_correct) > 0;

create temporary table audit_112_topic_attempts (
  attempt_no integer not null,
  question_id uuid not null,
  primary key (attempt_no, question_id)
) on commit drop;

grant select on audit_112_quiz_context, audit_112_answer_key to authenticated;
grant select, insert on audit_112_topic_attempts to authenticated;

set local role authenticated;
select set_config('request.jwt.claim.sub','5a000000-0000-4000-8000-000000000001',true);

do $$
declare
  v_lesson_attempt public.quiz_attempts;
  v_topic_one public.quiz_attempts;
  v_topic_two public.quiz_attempts;
  v_review_attempt public.quiz_attempts;
  v_item record;
  v_card_id uuid;
begin
  select * into strict v_lesson_attempt
  from public.start_lesson_quiz((select lesson_id from audit_112_quiz_context));
  if v_lesson_attempt.total_questions <> 5
    or (select count(*) from public.quiz_attempt_questions
        where attempt_id = v_lesson_attempt.id) <> 5 then
    raise exception '11.2 Lesson Quiz regression failed';
  end if;

  select * into strict v_topic_one
  from public.start_topic_quiz((select topic_id from audit_112_quiz_context));
  if v_topic_one.total_questions <> 10 then
    raise exception '11.2 Topic Quiz regression failed';
  end if;

  insert into audit_112_topic_attempts
  select 1,item.question_id
  from public.quiz_attempt_questions item
  where item.attempt_id = v_topic_one.id;

  for v_item in
    select item.question_id,key.incorrect_option_id
    from public.quiz_attempt_questions item
    join audit_112_answer_key key on key.question_id = item.question_id
    where item.attempt_id = v_topic_one.id
    order by item.display_order
  loop
    perform * from public.submit_quiz_answer(
      v_topic_one.id,v_item.question_id,v_item.incorrect_option_id
    );
  end loop;

  if (select status from public.quiz_attempts where id = v_topic_one.id) <> 'completed' then
    raise exception '11.2 Topic Quiz completion regression failed';
  end if;

  select * into strict v_topic_two
  from public.start_topic_quiz((select topic_id from audit_112_quiz_context));
  insert into audit_112_topic_attempts
  select 2,item.question_id
  from public.quiz_attempt_questions item
  where item.attempt_id = v_topic_two.id;

  if v_topic_two.id = v_topic_one.id
    or v_topic_two.total_questions <> 10
    or (select count(*) from audit_112_topic_attempts where attempt_no = 2) <> 10
    or (select count(*) from audit_112_topic_attempts first_item
        join audit_112_topic_attempts second_item using (question_id)
        where first_item.attempt_no = 1 and second_item.attempt_no = 2) >= 10 then
    raise exception '11.2 Topic Quiz retake rotation regression failed';
  end if;

  select * into strict v_review_attempt
  from public.start_review_quiz((select certification_id from audit_112_quiz_context),null);
  if v_review_attempt.total_questions not between 5 and 10 then
    raise exception '11.2 Review regression failed';
  end if;

  select card.id into strict v_card_id
  from public.flashcards card
  join public.lessons lesson on lesson.id = card.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  where domain.certification_id = (select certification_id from audit_112_quiz_context)
    and card.is_published
  order by card.id limit 1;

  perform public.submit_flashcard_review(v_card_id,'good');
  if not exists (
    select 1 from public.user_flashcard_progress
    where user_id = '5a000000-0000-4000-8000-000000000001'
      and flashcard_id = v_card_id
  ) then
    raise exception '11.2 Spaced Repetition regression failed';
  end if;
end;
$$;

rollback;

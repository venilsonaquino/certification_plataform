begin;

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
)
values
  ('00000000-0000-0000-0000-000000000000', '53000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'topic-quiz-a@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()),
  ('00000000-0000-0000-0000-000000000000', '53000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'topic-quiz-b@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now());

with temporary_seed (lesson_slug, sequence) as (
  values
    ('comparing-compute-options', 1), ('comparing-compute-options', 2),
    ('azure-virtual-machines', 1),
    ('azure-app-service', 1),
    ('azure-functions', 1), ('azure-functions', 2),
    ('containers-on-azure', 1), ('containers-on-azure', 2)
)
insert into public.questions (
  certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select domain.certification_id, domain.id, topic.id, lesson.id,
  format('Temporary balanced distribution question %s-%s', seed.lesson_slug, seed.sequence),
  'single_choice', 'medium', 'Temporary transactional test question.', true, 50 + seed.sequence
from temporary_seed seed
join public.lessons lesson on lesson.slug = seed.lesson_slug
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id;

insert into public.topics (id, domain_id, title, description, display_order)
select
  '3f000000-0000-4000-8000-999999999999',
  domain.id,
  'Temporary empty Topic Quiz fixture',
  'Transactional topic without questions.',
  999
from public.domains domain
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
order by domain.display_order
limit 1;

insert into public.topics (id, domain_id, title, description, display_order)
select
  '3f000000-0000-4000-8000-999999999998',
  domain.id,
  'Temporary two-question Topic Quiz fixture',
  'Transactional topic with exactly two questions.',
  998
from public.domains domain
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
order by domain.display_order
limit 1;

insert into public.lessons (
  id, topic_id, slug, title, short_description, content,
  estimated_minutes, display_order, is_published
)
values (
  '4f000000-0000-4000-8000-999999999998',
  '3f000000-0000-4000-8000-999999999998',
  'temporary-two-question-topic-quiz-fixture',
  'Temporary two-question Topic Quiz fixture',
  'Transactional test Lesson.',
  'Transactional test content.',
  1,
  1,
  true
);

insert into public.questions (
  certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select
  domain.certification_id,
  domain.id,
  '3f000000-0000-4000-8000-999999999998',
  '4f000000-0000-4000-8000-999999999998',
  format('Temporary two-question fixture %s', series),
  'single_choice',
  'easy',
  'Temporary transactional explanation.',
  true,
  series
from generate_series(1, 2) series
join public.domains domain on domain.id = (
  select topic.domain_id
  from public.topics topic
  where topic.id = '3f000000-0000-4000-8000-999999999998'
);

do $$
begin
  if exists (
    select 1 from public.quiz_attempts
    where quiz_type = 'lesson' and (lesson_id is null or topic_id is not null)
  ) then raise exception 'A migrated Lesson Quiz has an invalid scope.'; end if;

  begin
    insert into public.quiz_attempts (
      user_id, certification_id, quiz_type, lesson_id, topic_id, total_questions
    ) values (
      '53000000-0000-4000-8000-000000000001',
      '10000000-0000-4000-8000-000000000900',
      'topic',
      (select id from public.lessons where slug = 'azure-regions'),
      '30000000-0000-4000-8000-000000000002',
      1
    );
    raise exception 'An inconsistent topic scope unexpectedly succeeded.';
  exception when check_violation then null;
  end;
end;
$$;

create temporary table topic_quiz_answer_key (
  question_id uuid primary key,
  correct_option_id uuid not null,
  incorrect_option_id uuid not null
) on commit drop;

insert into topic_quiz_answer_key
select
  question.id,
  (array_agg(option.id order by option.display_order) filter (where option.is_correct))[1],
  (array_agg(option.id order by option.display_order) filter (where not option.is_correct))[1]
from public.questions question
join public.question_options option on option.question_id = question.id
where question.topic_id = '30000000-0000-4000-8000-000000000002'
  and question.is_published
group by question.id
having count(*) filter (where option.is_correct) = 1
  and count(*) filter (where not option.is_correct) >= 1;

grant select on topic_quiz_answer_key to authenticated;

set local role authenticated;
select set_config('request.jwt.claim.sub', '53000000-0000-4000-8000-000000000001', true);

do $$
declare
  v_compute_topic uuid := '32000000-0000-4000-8000-000000000002';
  v_core_topic uuid := '30000000-0000-4000-8000-000000000002';
  v_empty_topic uuid := '3f000000-0000-4000-8000-999999999999';
  v_few_topic uuid := '3f000000-0000-4000-8000-999999999998';
  v_balanced public.quiz_attempts;
  v_core public.quiz_attempts;
  v_same public.quiz_attempts;
  v_new public.quiz_attempts;
  v_few public.quiz_attempts;
  v_expected_lessons integer;
  v_expected_groups integer;
  v_item record;
  v_position integer := 0;
begin
  select * into strict v_balanced from public.start_topic_quiz(v_compute_topic);
  if v_balanced.quiz_type <> 'topic' or v_balanced.topic_id <> v_compute_topic
    or v_balanced.lesson_id is not null or v_balanced.total_questions <> 10 then
    raise exception 'The 10-question Topic Quiz has an invalid scope.';
  end if;

  select least(count(distinct question.lesson_id), 10)
  into v_expected_lessons
  from public.questions question
  where question.topic_id = v_compute_topic
    and question.is_published;

  if (select count(distinct question.lesson_id)
      from public.quiz_attempt_questions aq
      join public.questions question on question.id = aq.question_id
      where aq.attempt_id = v_balanced.id) <> v_expected_lessons then
    raise exception 'The balanced selection did not cover all available lessons.';
  end if;

  if (
    select max(amount) - min(amount)
    from (
      select question.lesson_id, count(*) as amount
      from public.quiz_attempt_questions aq
      join public.questions question on question.id = aq.question_id
      where aq.attempt_id = v_balanced.id
      group by question.lesson_id
    ) distribution
  ) > 1 then raise exception 'The round-robin selection differs by more than one question per lesson.'; end if;

  select * into strict v_same from public.start_topic_quiz(v_compute_topic);
  if v_same.id <> v_balanced.id then raise exception 'An active Topic Quiz was duplicated.'; end if;

  begin
    perform * from public.start_topic_quiz(v_empty_topic);
    raise exception 'A topic without questions unexpectedly started.';
  exception when no_data_found then null;
  end;

  select * into strict v_few from public.start_topic_quiz(v_few_topic);
  if v_few.total_questions <> 2 then raise exception 'A topic with 2 questions did not use both.'; end if;

  select * into strict v_core from public.start_topic_quiz(v_core_topic);
  if v_core.total_questions not between 5 and 10 then
    raise exception 'Core Architectural Components returned an invalid Topic Quiz size.';
  end if;

  for v_item in
    select aq.question_id, key.correct_option_id, key.incorrect_option_id
    from public.quiz_attempt_questions aq
    join topic_quiz_answer_key key using (question_id)
    where aq.attempt_id = v_core.id
    order by aq.display_order
    limit 4
  loop
    v_position := v_position + 1;
    perform * from public.submit_quiz_answer(
      v_core.id,
      v_item.question_id,
      case when v_position = 1 then v_item.incorrect_option_id else v_item.correct_option_id end
    );
  end loop;

  if (select count(*) from public.quiz_answers where attempt_id = v_core.id) <> 4 then
    raise exception 'Refresh did not preserve 4 answers.';
  end if;

  for v_item in
    select aq.question_id, key.correct_option_id
    from public.quiz_attempt_questions aq
    join topic_quiz_answer_key key using (question_id)
    where aq.attempt_id = v_core.id
      and not exists (
        select 1 from public.quiz_answers answer
        where answer.attempt_id = v_core.id
          and answer.question_id = aq.question_id
      )
    order by aq.display_order
  loop
    perform * from public.submit_quiz_answer(v_core.id, v_item.question_id, v_item.correct_option_id);
  end loop;

  if (select status from public.quiz_attempts where id = v_core.id) <> 'completed'
    or (select correct_answers from public.quiz_attempts where id = v_core.id) <> v_core.total_questions - 1 then
    raise exception 'Topic Quiz final result should contain exactly one error.';
  end if;

  select count(distinct question.lesson_id)
  into v_expected_groups
  from public.quiz_attempt_questions aq
  join public.questions question on question.id = aq.question_id
  where aq.attempt_id = v_core.id;

  if (select count(*) from public.get_topic_quiz_performance(v_core.id)) <> v_expected_groups then
    raise exception 'Performance does not contain every Lesson group in the attempt.';
  end if;

  if not exists (
    select 1 from public.get_topic_quiz_performance(v_core.id)
    where correct_answers < total_questions and percentage < 100
  ) then raise exception 'The Topic Quiz weak area was not calculated.'; end if;

  perform set_config('quiz.topic_user_a_attempt', v_core.id::text, true);
  select * into strict v_new from public.start_topic_quiz(v_core_topic);
  if v_new.id = v_core.id then raise exception 'Retaking did not create a new Topic Quiz.'; end if;
end;
$$;

select set_config('request.jwt.claim.sub', '53000000-0000-4000-8000-000000000002', true);

do $$
declare
  v_user_a_attempt uuid := current_setting('quiz.topic_user_a_attempt')::uuid;
begin
  if exists (select 1 from public.quiz_attempts where id = v_user_a_attempt) then
    raise exception 'User B can read user A Topic Quiz.';
  end if;
  if exists (select 1 from public.get_topic_quiz_performance(v_user_a_attempt)) then
    raise exception 'User B can read user A Topic performance.';
  end if;
end;
$$;

reset role;

select json_build_object(
  'legacy_lesson_attempts_preserved', true,
  'ten_questions_balanced', true,
  'available_lessons_covered', true,
  'few_questions_supported', true,
  'empty_topic_rejected', true,
  'refresh_persisted_four_answers', true,
  'result_by_lesson', true,
  'weak_area_detected', true,
  'retake_created_new_attempt', true,
  'cross_user_isolation', true
) as topic_quiz_validation;

rollback;

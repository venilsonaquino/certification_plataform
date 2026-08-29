begin;

do $$
declare lesson_row record; duplicate_count integer; combined_text text;
begin
  if (select count(*) from public.lessons
      where topic_id = '33000000-0000-4000-8000-000000000004') <> 6 then
    raise exception '9.7.4 expected six Monitoring Lessons'; end if;

  for lesson_row in select id, slug from public.lessons
    where topic_id = '33000000-0000-4000-8000-000000000004'
  loop
    if not exists (select 1 from public.lessons where id = lesson_row.id and is_published
        and content is not null and btrim(content) <> '')
      or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_row.id and is_published)
        <> (case lesson_row.slug when 'azure-advisor' then 11 when 'azure-service-health' then 12
          when 'azure-monitor' then 11 when 'log-analytics' then 8
          when 'azure-monitor-alerts' then 8 when 'application-insights' then 10 end)
      or (select count(*) from public.flashcards where lesson_id = lesson_row.id and is_published)
        <> (case when lesson_row.slug = 'azure-advisor' then 7
          when lesson_row.slug = 'azure-service-health' then 8 else 6 end)
      or (select count(*) from public.questions where lesson_id = lesson_row.id and is_published)
        <> (case when lesson_row.slug in ('azure-advisor','application-insights') then 10 else 5 end)
      or (select min(display_order) from public.lesson_content_blocks where lesson_id = lesson_row.id) <> 1
      or (select max(display_order) from public.lesson_content_blocks where lesson_id = lesson_row.id)
        <> (select count(*) from public.lesson_content_blocks where lesson_id = lesson_row.id)
      or (select count(distinct display_order) from public.lesson_content_blocks where lesson_id = lesson_row.id)
        <> (select count(*) from public.lesson_content_blocks where lesson_id = lesson_row.id)
      or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_row.id and type = 'summary') <> 1
      or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_row.id and type = 'exam_tip') <> 1
      or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_row.id and type = 'exam_trap') < 1 then
      raise exception '9.7.4 invalid Lesson artifacts for %', lesson_row.slug; end if;
  end loop;

  if (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id = block.lesson_id
      where lesson.topic_id = '33000000-0000-4000-8000-000000000004' and block.is_published) <> 60
    or (select count(*) from public.visual_experiences visual join public.lessons lesson on lesson.id = visual.lesson_id
      where lesson.topic_id = '33000000-0000-4000-8000-000000000004' and visual.is_published) <> 1
    or (select count(*) from public.flashcards card join public.lessons lesson on lesson.id = card.lesson_id
      where lesson.topic_id = '33000000-0000-4000-8000-000000000004' and card.is_published) <> 39
    or (select count(*) from public.questions where topic_id = '33000000-0000-4000-8000-000000000004' and is_published) <> 40
    or (select sum(estimated_minutes) from public.lessons where topic_id = '33000000-0000-4000-8000-000000000004') <> 68 then
    raise exception '9.7.4 Monitoring totals invalid'; end if;

  if not exists (select 1 from public.lesson_content_blocks
      where id = '7b290000-0000-4000-8000-000000000007' and type = 'important'
        and content ~* 'Azure Status' and content ~* 'Application Insights')
    or not exists (select 1 from public.visual_experiences
      where id = '76000000-0000-4000-8000-000000000017' and is_published
        and jsonb_array_length(config->'nodes') = 8 and jsonb_array_length(config->'edges') = 9)
    or not exists (select 1 from public.lesson_content_blocks
      where visual_experience_id = '76000000-0000-4000-8000-000000000017'
        and type = 'visual_experience' and is_published) then
    raise exception '9.7.4 comparison or visual invalid'; end if;

  if exists (select 1 from public.questions question left join public.question_options option on option.question_id = question.id
      where question.topic_id = '33000000-0000-4000-8000-000000000004' group by question.id
      having count(option.id) <> 4 or count(option.id) filter (where option.is_correct) <> 1
        or count(distinct lower(btrim(option.option_text))) <> 4 or min(length(btrim(question.explanation))) < 40) then
    raise exception '9.7.4 Questions invalid'; end if;

  select count(*) into duplicate_count from (
    select lower(regexp_replace(btrim(card.front_text), '[^[:alnum:]]+', ' ', 'g')) value
    from public.flashcards card join public.lessons lesson on lesson.id = card.lesson_id
    where lesson.topic_id = '33000000-0000-4000-8000-000000000004'
    group by value having count(*) > 1) duplicates;
  if duplicate_count <> 0 then raise exception '9.7.4 duplicate Flashcards'; end if;

  select count(*) into duplicate_count from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g')) value
    from public.questions question where question.topic_id = '33000000-0000-4000-8000-000000000004'
    group by value having count(*) > 1) duplicates;
  if duplicate_count <> 0 then raise exception '9.7.4 duplicate Questions'; end if;

  select string_agg(value, ' ') into combined_text from (
    select concat_ws(' ', block.title, block.content, block.config::text) value
    from public.lesson_content_blocks block join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.topic_id = '33000000-0000-4000-8000-000000000004'
    union all select concat_ws(' ', card.front_text, card.back_text, card.hint)
    from public.flashcards card join public.lessons lesson on lesson.id = card.lesson_id
    where lesson.topic_id = '33000000-0000-4000-8000-000000000004'
    union all select concat_ws(' ', question.question_text, question.explanation, option.option_text)
    from public.questions question join public.question_options option on option.question_id = question.id
    where question.topic_id = '33000000-0000-4000-8000-000000000004') artifacts;
  if combined_text !~* 'Azure Advisor' or combined_text !~* 'Azure Status'
    or combined_text !~* 'Azure Service Health' or combined_text !~* 'Resource Health'
    or combined_text !~* 'Azure Monitor' or combined_text !~* 'Log Analytics'
    or combined_text !~* 'Azure Monitor Alerts' or combined_text !~* 'Application Insights'
    or combined_text !~* 'CPU' or combined_text !~* 'latency' or combined_text !~* 'request count' then
    raise exception '9.7.4 concepts incomplete'; end if;

  if exists (select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id = progress.lesson_id where lesson.id is null)
    or exists (select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id = item.attempt_id
      left join public.questions question on question.id = item.question_id where attempt.id is null or question.id is null)
    or exists (select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id = answer.attempt_id
      left join public.questions question on question.id = answer.question_id
      left join public.question_options option on option.id = answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null)
    or exists (select 1 from public.flashcard_reviews review left join public.flashcards card on card.id = review.flashcard_id where card.id is null)
    or exists (select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id = progress.flashcard_id where card.id is null) then
    raise exception '9.7.4 orphan history'; end if;

  if (select count(*) from public.lessons lesson join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      where domain.title = 'Describe Azure management and governance' and lesson.is_published) <> 20
    or (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id = block.lesson_id
      join public.topics topic on topic.id = lesson.topic_id join public.domains domain on domain.id = topic.domain_id
      where domain.title = 'Describe Azure management and governance' and block.is_published) <> 226
    or (select count(*) from public.visual_experiences visual join public.lessons lesson on lesson.id = visual.lesson_id
      join public.topics topic on topic.id = lesson.topic_id join public.domains domain on domain.id = topic.domain_id
      where domain.title = 'Describe Azure management and governance' and visual.is_published) <> 2
    or (select count(*) from public.flashcards card join public.lessons lesson on lesson.id = card.lesson_id
      join public.topics topic on topic.id = lesson.topic_id join public.domains domain on domain.id = topic.domain_id
      where domain.title = 'Describe Azure management and governance' and card.is_published) <> 130
    or (select count(*) from public.questions question join public.domains domain on domain.id = question.domain_id
      where domain.title = 'Describe Azure management and governance' and question.is_published) <> 140 then
    raise exception '9.7.4 Domain 3 totals invalid'; end if;
end; $$;

create temporary table target_lessons on commit drop as
select lesson.id, lesson.slug, lesson.display_order, certification.id certification_id
from public.lessons lesson join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900' and topic.id = '33000000-0000-4000-8000-000000000004';
create temporary table wrong_options(question_id uuid primary key, option_id uuid not null) on commit drop;
insert into wrong_options select question.id,
  (array_agg(option.id order by option.display_order) filter (where not option.is_correct))[1]
from public.questions question join target_lessons target on target.id = question.lesson_id
join public.question_options option on option.question_id = question.id group by question.id;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select '00000000-0000-0000-0000-000000000000',seed.id,'authenticated','authenticated',seed.email,'',now(),
  '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()
from(values
  ('58000000-0000-4000-8000-000000000044'::uuid,'monitoring-close-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000045'::uuid,'monitoring-close-b@example.invalid')) seed(id,email);
grant select on target_lessons, wrong_options to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000044',true);

do $$
declare lesson_row record; lesson_attempt public.quiz_attempts; topic_attempt public.quiz_attempts;
  review_attempt public.quiz_attempts; question_row record; started public.user_lesson_progress;
  completed public.user_lesson_progress; card_id uuid; certification_uuid uuid;
begin
  for lesson_row in select * from target_lessons order by display_order loop
    select * into strict lesson_attempt from public.start_lesson_quiz(lesson_row.id);
    if lesson_attempt.total_questions <> 5
      or (select count(*) from public.quiz_attempt_questions where attempt_id = lesson_attempt.id) <> 5 then
      raise exception '9.7.4 Lesson Quiz failed for %', lesson_row.slug; end if;
    if lesson_row.slug = 'azure-monitor' then
      for question_row in select item.question_id, wrong.option_id
        from public.quiz_attempt_questions item join wrong_options wrong on wrong.question_id = item.question_id
        where item.attempt_id = lesson_attempt.id order by item.display_order loop
        perform * from public.submit_quiz_answer(lesson_attempt.id, question_row.question_id, question_row.option_id);
      end loop;
    end if;
  end loop;
  select * into strict topic_attempt from public.start_topic_quiz('33000000-0000-4000-8000-000000000004');
  if topic_attempt.total_questions <> 10
    or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item
      join public.questions question on question.id = item.question_id where item.attempt_id = topic_attempt.id) <> 6
    or exists (select 1 from target_lessons target where not exists (select 1 from public.quiz_attempt_questions item
      join public.questions question on question.id = item.question_id
      where item.attempt_id = topic_attempt.id and question.lesson_id = target.id))
    or exists (select 1 from public.quiz_attempt_questions item join public.questions question on question.id = item.question_id
      where item.attempt_id = topic_attempt.id group by question.lesson_id having count(*) > 2) then
    raise exception '9.7.4 Topic Quiz failed'; end if;
  select certification_id into strict certification_uuid from target_lessons limit 1;
  select * into strict review_attempt from public.start_review_quiz(certification_uuid);
  if review_attempt.quiz_type <> 'review' or review_attempt.total_questions <> 5 then
    raise exception '9.7.4 Review failed'; end if;
  select * into strict started from public.start_lesson_progress((select id from target_lessons where slug = 'azure-monitor'));
  select * into strict completed from public.complete_lesson_progress((select id from target_lessons where slug = 'azure-monitor'));
  if started.status <> 'in_progress' or completed.status <> 'completed' or completed.completed_at is null then
    raise exception '9.7.4 progress failed'; end if;
  select card.id into strict card_id from public.flashcards card join target_lessons target on target.id = card.lesson_id
    order by target.display_order, card.display_order limit 1;
  perform public.submit_flashcard_review(card_id,'good');
  if not exists (select 1 from public.flashcard_reviews where flashcard_id = card_id)
    or not exists (select 1 from public.user_flashcard_progress where flashcard_id = card_id) then
    raise exception '9.7.4 spaced repetition failed'; end if;
end; $$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000045',true);
do $$ declare topic_attempt public.quiz_attempts; begin
  if exists (select 1 from public.quiz_attempts where user_id = '58000000-0000-4000-8000-000000000044')
    or exists (select 1 from public.user_lesson_progress where user_id = '58000000-0000-4000-8000-000000000044')
    or exists (select 1 from public.flashcard_reviews where user_id = '58000000-0000-4000-8000-000000000044')
    or exists (select 1 from public.user_flashcard_progress where user_id = '58000000-0000-4000-8000-000000000044') then
    raise exception '9.7.4 user isolation failed'; end if;
  select * into strict topic_attempt from public.start_topic_quiz('33000000-0000-4000-8000-000000000004');
  if (select count(distinct question.lesson_id) from public.quiz_attempt_questions item
      join public.questions question on question.id = item.question_id where item.attempt_id = topic_attempt.id) <> 6 then
    raise exception '9.7.4 second Topic Quiz failed'; end if;
end; $$;

select jsonb_build_object(
  'monitoring_lessons', 6, 'content_blocks', 60, 'visual_experiences', 1,
  'flashcards', 39, 'questions', 40, 'difficulty', '14/18/8',
  'monitoring_status', 'CLOSED', 'domain_3_status', 'CLOSED'
) as monitoring_domain3_closure_validation;

rollback;

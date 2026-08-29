begin;

do $$
begin
  if exists (
    select 1 from auth.users where id = '58000000-0000-4000-8000-000000000033'
  ) then
    raise exception '9.5.2 temporary validation user UUID already exists';
  end if;
end; $$;

create temporary table target_lesson on commit drop as
select lesson.id, lesson.slug, lesson.estimated_minutes, lesson.display_order,
  certification.id certification_id
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and domain.title = 'Describe Azure management and governance'
  and topic.id = '33000000-0000-4000-8000-000000000002'
  and topic.title = 'Governance and Compliance'
  and lesson.slug = 'microsoft-purview';

do $$
declare
  lesson_uuid uuid;
begin
  if (select count(*) from target_lesson) <> 1 then
    raise exception '9.5.2 validation expected one Microsoft Purview Lesson';
  end if;
  select id into strict lesson_uuid from target_lesson;

  if exists (
    select 1 from target_lesson target
    join public.lessons lesson on lesson.id = target.id
    where not lesson.is_published
      or lesson.content is null
      or btrim(lesson.content) = ''
      or lesson.estimated_minutes <> 12
      or lesson.display_order <> 1
  ) then
    raise exception '9.5.2 Lesson publication, fallback, estimate or order is invalid';
  end if;

  if (select count(*) from public.lesson_content_blocks where lesson_id = lesson_uuid) <> 13
    or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_uuid and is_published) <> 13
    or (select min(display_order) from public.lesson_content_blocks where lesson_id = lesson_uuid) <> 1
    or (select max(display_order) from public.lesson_content_blocks where lesson_id = lesson_uuid) <> 13
    or (select count(distinct display_order) from public.lesson_content_blocks where lesson_id = lesson_uuid) <> 13
    or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_uuid and type = 'summary') <> 1
    or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_uuid and type = 'exam_tip') <> 1
    or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_uuid and type = 'exam_trap') <> 2 then
    raise exception '9.5.2 Content Blocks are invalid';
  end if;

  if exists (
    select 1 from public.lesson_content_blocks summary
    where summary.lesson_id = lesson_uuid and summary.type = 'summary'
      and (summary.display_order <> 13
        or jsonb_typeof(summary.config -> 'items') <> 'array'
        or jsonb_array_length(summary.config -> 'items') <> 6)
  ) then
    raise exception '9.5.2 summary is invalid';
  end if;

  if exists (select 1 from public.visual_experiences where lesson_id = lesson_uuid)
    or (select count(*) from public.flashcards where lesson_id = lesson_uuid and is_published) <> 7
    or (select count(*) from public.questions where lesson_id = lesson_uuid and is_published) <> 5
    or (select count(*) from public.questions where lesson_id = lesson_uuid and difficulty = 'easy') <> 2
    or (select count(*) from public.questions where lesson_id = lesson_uuid and difficulty = 'medium') <> 2
    or (select count(*) from public.questions where lesson_id = lesson_uuid and difficulty = 'hard') <> 1 then
    raise exception '9.5.2 visual or practice inventory is invalid';
  end if;

  if exists (
    select 1 from public.questions question
    left join public.question_options option on option.question_id = question.id
    where question.lesson_id = lesson_uuid
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
  ) then
    raise exception '9.5.2 Question Options are invalid';
  end if;

  if not exists (
    with artifacts as (
      select concat_ws(' ', title, content, config::text) text
      from public.lesson_content_blocks where lesson_id = lesson_uuid
      union all
      select concat_ws(' ', front_text, back_text, hint)
      from public.flashcards where lesson_id = lesson_uuid
      union all
      select concat_ws(' ', question_text, explanation)
      from public.questions where lesson_id = lesson_uuid
    ), combined as (select string_agg(text, ' ') text from artifacts)
    select 1 from combined
    where text ~* 'Data Governance'
      and text ~* 'discovery'
      and text ~* 'Data Map'
      and text ~* 'Unified Catalog'
      and text ~* 'classification'
      and text ~* 'compliance'
      and text ~* 'Azure Policy'
      and text ~* 'Defender for Cloud'
      and text ~* 'Azure Storage'
      and text ~* 'multicloud'
  ) then
    raise exception '9.5.2 required Purview concepts are missing';
  end if;

  if exists (
    select 1 from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.topic_id = '33000000-0000-4000-8000-000000000002'
      and lesson.slug in ('azure-policy', 'resource-locks')
  ) or exists (
    select 1 from public.flashcards card
    join public.lessons lesson on lesson.id = card.lesson_id
    where lesson.topic_id = '33000000-0000-4000-8000-000000000002'
      and lesson.slug in ('azure-policy', 'resource-locks')
  ) or exists (
    select 1 from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    where lesson.topic_id = '33000000-0000-4000-8000-000000000002'
      and lesson.slug in ('azure-policy', 'resource-locks')
  ) then
    raise exception '9.5.2 changed Azure Policy or Resource Locks';
  end if;

  if exists (
    select 1 from public.user_lesson_progress progress
    left join public.lessons lesson on lesson.id = progress.lesson_id
    where lesson.id is null
  ) or exists (
    select 1 from public.flashcard_reviews review
    left join public.flashcards card on card.id = review.flashcard_id
    where card.id is null
  ) or exists (
    select 1 from public.user_flashcard_progress progress
    left join public.flashcards card on card.id = progress.flashcard_id
    where card.id is null
  ) or exists (
    select 1 from public.quiz_attempt_questions item
    left join public.quiz_attempts attempt on attempt.id = item.attempt_id
    left join public.questions question on question.id = item.question_id
    where attempt.id is null or question.id is null
  ) or exists (
    select 1 from public.quiz_answers answer
    left join public.quiz_attempts attempt on attempt.id = answer.attempt_id
    left join public.questions question on question.id = answer.question_id
    left join public.question_options option on option.id = answer.selected_option_id
    where attempt.id is null or question.id is null or option.id is null
  ) then
    raise exception 'Study history contains an orphaned reference';
  end if;

  if exists (
    select 1 from pg_class relation
    join pg_namespace namespace on namespace.oid = relation.relnamespace
    where namespace.nspname = 'public'
      and relation.relname in (
        'lessons', 'lesson_content_blocks', 'visual_experiences', 'flashcards',
        'questions', 'question_options', 'user_lesson_progress', 'quiz_attempts',
        'quiz_attempt_questions', 'quiz_answers', 'flashcard_reviews',
        'user_flashcard_progress'
      )
      and not relation.relrowsecurity
  ) then
    raise exception '9.5.2 requires RLS on study tables';
  end if;

  if not has_table_privilege('authenticated', 'public.lessons', 'SELECT')
    or not has_table_privilege('authenticated', 'public.lesson_content_blocks', 'SELECT')
    or not has_table_privilege('authenticated', 'public.flashcards', 'SELECT')
    or has_table_privilege('authenticated', 'public.questions', 'SELECT')
    or has_table_privilege('authenticated', 'public.question_options', 'SELECT')
    or has_table_privilege('authenticated', 'public.lesson_content_blocks', 'UPDATE')
    or has_table_privilege('authenticated', 'public.flashcards', 'UPDATE')
    or has_table_privilege('authenticated', 'public.questions', 'UPDATE') then
    raise exception '9.5.2 curriculum grants are invalid';
  end if;
end; $$;

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
)
values (
  '00000000-0000-0000-0000-000000000000',
  '58000000-0000-4000-8000-000000000033',
  'authenticated', 'authenticated', 'purview-validation@example.invalid', '', now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
);

grant select on target_lesson to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000033', true);

do $$
declare
  lesson_uuid uuid;
  lesson_attempt public.quiz_attempts;
  topic_attempt public.quiz_attempts;
  started public.user_lesson_progress;
  completed public.user_lesson_progress;
  target_card_id uuid;
begin
  select id into strict lesson_uuid from target_lesson;

  if (select count(*) from public.lesson_content_blocks where lesson_id = lesson_uuid and is_published) <> 13
    or (select count(*) from public.flashcards where lesson_id = lesson_uuid and is_published) <> 7
    or (select count(*) from public.questions where lesson_id = lesson_uuid and is_published) <> 5 then
    raise exception '9.5.2 authenticated published-content read failed';
  end if;

  select * into strict lesson_attempt from public.start_lesson_quiz(lesson_uuid);
  if lesson_attempt.total_questions <> 5
    or (select count(*) from public.quiz_attempt_questions where attempt_id = lesson_attempt.id) <> 5 then
    raise exception '9.5.2 Lesson Quiz failed';
  end if;

  select * into strict topic_attempt
  from public.start_topic_quiz('33000000-0000-4000-8000-000000000002');
  if topic_attempt.total_questions <> 5
    or (select count(*) from public.quiz_attempt_questions where attempt_id = topic_attempt.id) <> 5
    or exists (
      select 1 from public.quiz_attempt_questions item
      join public.questions question on question.id = item.question_id
      where item.attempt_id = topic_attempt.id and question.lesson_id <> lesson_uuid
    ) then
    raise exception '9.5.2 Topic Quiz failed';
  end if;

  select * into strict started from public.start_lesson_progress(lesson_uuid);
  select * into strict completed from public.complete_lesson_progress(lesson_uuid);
  if started.status <> 'in_progress' or completed.status <> 'completed' or completed.completed_at is null then
    raise exception '9.5.2 Lesson progress flow failed';
  end if;

  select id into strict target_card_id
  from public.flashcards
  where lesson_id = lesson_uuid and is_published
  order by display_order limit 1;
  perform public.submit_flashcard_review(target_card_id, 'good');
  if not exists (select 1 from public.flashcard_reviews where flashcard_id = target_card_id)
    or not exists (select 1 from public.user_flashcard_progress where flashcard_id = target_card_id) then
    raise exception '9.5.2 spaced repetition failed';
  end if;
end; $$;

reset role;
set local role postgres;

delete from public.quiz_answers
where attempt_id in (
  select id from public.quiz_attempts where user_id = '58000000-0000-4000-8000-000000000033'
);
delete from public.quiz_attempt_questions
where attempt_id in (
  select id from public.quiz_attempts where user_id = '58000000-0000-4000-8000-000000000033'
);
delete from public.quiz_attempts where user_id = '58000000-0000-4000-8000-000000000033';
delete from public.flashcard_reviews where user_id = '58000000-0000-4000-8000-000000000033';
delete from public.user_flashcard_progress where user_id = '58000000-0000-4000-8000-000000000033';
delete from public.user_lesson_progress where user_id = '58000000-0000-4000-8000-000000000033';
delete from auth.users where id = '58000000-0000-4000-8000-000000000033';

do $$
begin
  if exists (select 1 from auth.users where id = '58000000-0000-4000-8000-000000000033')
    or exists (select 1 from public.quiz_attempts where user_id = '58000000-0000-4000-8000-000000000033')
    or exists (select 1 from public.user_lesson_progress where user_id = '58000000-0000-4000-8000-000000000033')
    or exists (select 1 from public.flashcard_reviews where user_id = '58000000-0000-4000-8000-000000000033')
    or exists (select 1 from public.user_flashcard_progress where user_id = '58000000-0000-4000-8000-000000000033') then
    raise exception '9.5.2 temporary validation data cleanup failed';
  end if;
end; $$;

set role postgres;
commit;

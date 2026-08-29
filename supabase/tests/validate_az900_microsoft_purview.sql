begin;
set local statement_timeout = '30s';

create temporary table target_lesson on commit drop as
select lesson.id, lesson.slug, lesson.estimated_minutes, lesson.display_order
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
  duplicate_count integer;
begin
  if not exists (
    select 1 from supabase_migrations.schema_migrations where version = '20260829010000'
  ) then
    raise exception '9.5.2 migration is not registered';
  end if;

  if (select count(*) from target_lesson) <> 1 then
    raise exception '9.5.2 Lesson inventory is invalid';
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
    raise exception '9.5.2 publication, fallback, estimate or ordering is invalid';
  end if;

  if (select count(*) from public.lesson_content_blocks where lesson_id = lesson_uuid) <> 13
    or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_uuid and is_published) <> 13
    or (select min(display_order) from public.lesson_content_blocks where lesson_id = lesson_uuid) <> 1
    or (select max(display_order) from public.lesson_content_blocks where lesson_id = lesson_uuid) <> 13
    or (select count(distinct display_order) from public.lesson_content_blocks where lesson_id = lesson_uuid) <> 13
    or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_uuid and type = 'summary') <> 1
    or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_uuid and type = 'exam_tip') <> 1
    or (select count(*) from public.lesson_content_blocks where lesson_id = lesson_uuid and type = 'exam_trap') < 2 then
    raise exception '9.5.2 Content Blocks or ordering are invalid';
  end if;

  if exists (
    select 1 from public.lesson_content_blocks summary
    where summary.lesson_id = lesson_uuid
      and summary.type = 'summary'
      and (
        summary.display_order <> 13
        or jsonb_typeof(summary.config -> 'items') <> 'array'
        or jsonb_array_length(summary.config -> 'items') not between 3 and 6
      )
  ) then
    raise exception '9.5.2 summary is invalid';
  end if;

  if exists (select 1 from public.visual_experiences where lesson_id = lesson_uuid) then
    raise exception '9.5.2 must not contain a Visual Experience';
  end if;

  if (select count(*) from public.flashcards where lesson_id = lesson_uuid and is_published) <> 7 then
    raise exception '9.5.2 Flashcard inventory is invalid';
  end if;

  select count(*) into duplicate_count
  from (
    select lower(regexp_replace(btrim(front_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.flashcards
    where lesson_id = lesson_uuid
    group by 1 having count(*) > 1
  ) duplicates;
  if duplicate_count <> 0 then
    raise exception '9.5.2 contains duplicate Flashcards';
  end if;

  if (select count(*) from public.questions where lesson_id = lesson_uuid and is_published) <> 5
    or (select count(*) from public.questions where lesson_id = lesson_uuid and difficulty = 'easy') <> 2
    or (select count(*) from public.questions where lesson_id = lesson_uuid and difficulty = 'medium') <> 2
    or (select count(*) from public.questions where lesson_id = lesson_uuid and difficulty = 'hard') <> 1 then
    raise exception '9.5.2 Question inventory or difficulty is invalid';
  end if;

  if (select count(*) from public.questions where id between
      '68000000-0000-4000-8000-000000000129' and '68000000-0000-4000-8000-000000000133') <> 5
    or (select count(*) from public.question_options where id between
      '7f230000-0000-4000-8000-000000000001' and '7f230000-0000-4000-8000-000000000020') <> 20 then
    raise exception '9.5.2 new Question or Option UUIDs are invalid';
  end if;

  if exists (
    select 1 from public.questions question
    left join public.question_options option on option.question_id = question.id
    where question.lesson_id = lesson_uuid and question.is_published
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
      or min(length(btrim(question.explanation))) < 40
  ) then
    raise exception '9.5.2 Question or Question Options are invalid';
  end if;

  select count(*) into duplicate_count
  from (
    select lower(regexp_replace(btrim(question_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.questions
    where lesson_id = lesson_uuid
    group by 1 having count(*) > 1
  ) duplicates;
  if duplicate_count <> 0 then
    raise exception '9.5.2 contains duplicate Questions';
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
    raise exception '9.5.2 required Microsoft Purview concepts are missing';
  end if;
end; $$;

do $$
begin
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

  if not has_table_privilege('authenticated', 'public.lesson_content_blocks', 'SELECT')
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
  '58000000-0000-4000-8000-000000000027',
  'authenticated', 'authenticated', 'purview-952@example.invalid', '', now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
);

grant select on target_lesson to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000027', true);

do $$
declare
  lesson_uuid uuid;
  lesson_attempt public.quiz_attempts;
  topic_attempt public.quiz_attempts;
begin
  select id into strict lesson_uuid from target_lesson;

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
end; $$;

reset role;

select json_build_object(
  'stage', '9.5.2',
  'lesson', 'microsoft-purview',
  'published_blocks', 13,
  'visuals_created', 0,
  'flashcards_preserved', 0,
  'flashcards_added', 7,
  'questions_preserved', 0,
  'questions_added', 5,
  'difficulty', json_build_object('easy', 2, 'medium', 2, 'hard', 1),
  'history_preserved', true
) as microsoft_purview_validation;

rollback;

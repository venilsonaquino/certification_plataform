begin;

set local statement_timeout = '30s';

do $$
declare
  target_lesson_id uuid;
  block_types text[];
  duplicate_count integer;
begin
  if not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260826080000'
  ) then
    raise exception '8.5.4 migration is not registered';
  end if;

  select lesson.id
  into strict target_lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Core Architectural Components'
    and lesson.slug = 'region-pairs-and-sovereign-regions';

  if target_lesson_id <> '79f8ca50-0ec9-4dda-bade-9b6d918a913c' then
    raise exception 'The Lesson UUID changed';
  end if;

  select array_agg(type order by display_order)
  into block_types
  from public.lesson_content_blocks
  where lesson_id = target_lesson_id
    and is_published;

  if block_types is distinct from array[
    'explanation', 'important', 'example', 'exam_trap', 'explanation',
    'important', 'exam_trap', 'exam_tip', 'summary'
  ]::text[] then
    raise exception 'Unexpected Region Pairs and Sovereign Regions block order: %', block_types;
  end if;

  if not exists (
    select 1
    from public.lessons
    where id = target_lesson_id
      and is_published
      and estimated_minutes = 10
      and content is not null
      and btrim(content) <> ''
  ) then
    raise exception 'Lesson publication, estimate or fallback is invalid';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = target_lesson_id
    group by lesson_id
    having min(display_order) <> 1
      or max(display_order) <> 9
      or count(distinct display_order) <> 9
      or count(*) <> 9
  ) then
    raise exception 'Content Block display_order is not contiguous';
  end if;

  if (select count(*) from public.lesson_content_blocks where lesson_id = target_lesson_id and type = 'exam_trap') <> 2
    or not exists (
      select 1
      from public.lesson_content_blocks
      where lesson_id = target_lesson_id
        and type = 'exam_tip'
    )
    or not exists (
      select 1
      from public.lesson_content_blocks
      where lesson_id = target_lesson_id
        and type = 'summary'
        and jsonb_typeof(config -> 'items') = 'array'
        and jsonb_array_length(config -> 'items') = 6
    ) then
    raise exception 'Exam blocks or summary are invalid';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = target_lesson_id
      and (type = 'visual_experience' or visual_experience_id is not null)
  ) or exists (
    select 1
    from public.visual_experiences
    where lesson_id = target_lesson_id
  ) then
    raise exception '8.5.4 created an unexpected Visual Experience';
  end if;

  if (select count(*) from public.flashcards where lesson_id = target_lesson_id and is_published) <> 4
    or (select array_agg(id order by display_order) from public.flashcards where lesson_id = target_lesson_id and is_published) is distinct from array[
      '71000000-0000-4000-8000-000000000085'::uuid,
      '71000000-0000-4000-8000-000000000086'::uuid,
      '71000000-0000-4000-8000-000000000087'::uuid,
      '71000000-0000-4000-8000-000000000088'::uuid
    ] then
    raise exception 'Flashcard count or UUIDs changed';
  end if;

  if not exists (
    select 1 from public.flashcards
    where id = '71000000-0000-4000-8000-000000000086'
      and back_text ilike '%Availability Zones%'
      and back_text ilike '%multi-region%'
  ) or not exists (
    select 1 from public.flashcards
    where id = '71000000-0000-4000-8000-000000000088'
      and back_text ilike '%Data residency%'
      and back_text ilike '%não exige%'
  ) then
    raise exception 'Required paired/nonpaired or sovereignty memory cues are missing';
  end if;

  if (select count(*) from public.questions where lesson_id = target_lesson_id and is_published) <> 5
    or (select array_agg(id order by display_order) from public.questions where lesson_id = target_lesson_id and is_published) is distinct from array[
      '64000000-0000-4000-8000-000000000016'::uuid,
      '64000000-0000-4000-8000-000000000017'::uuid,
      '64000000-0000-4000-8000-000000000018'::uuid,
      '64000000-0000-4000-8000-000000000019'::uuid,
      '64000000-0000-4000-8000-000000000020'::uuid
    ]
    or exists (
      select 1
      from public.questions question
      left join public.question_options option on option.question_id = question.id
      where question.lesson_id = target_lesson_id
        and question.is_published
      group by question.id
      having count(option.id) <> 4
        or count(option.id) filter (where option.is_correct) <> 1
        or count(distinct lower(btrim(option.option_text))) <> 4
        or min(length(btrim(question.explanation))) < 40
    ) then
    raise exception 'Questions, answer options or explanations are invalid';
  end if;

  select count(*)
  into duplicate_count
  from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    where lesson.topic_id = '30000000-0000-4000-8000-000000000002'
    group by 1
    having count(*) > 1
  ) duplicates;

  if duplicate_count <> 0 then
    raise exception 'Core Architectural Components contains exact Question duplicates';
  end if;
end;
$$;

do $$
begin
  if exists (
    select 1
    from public.user_lesson_progress progress
    left join public.lessons lesson on lesson.id = progress.lesson_id
    where lesson.id is null
  ) or exists (
    select 1
    from public.flashcard_reviews review
    left join public.flashcards flashcard on flashcard.id = review.flashcard_id
    where flashcard.id is null
  ) or exists (
    select 1
    from public.user_flashcard_progress progress
    left join public.flashcards flashcard on flashcard.id = progress.flashcard_id
    where flashcard.id is null
  ) or exists (
    select 1
    from public.quiz_attempts attempt
    left join public.certifications certification on certification.id = attempt.certification_id
    left join public.lessons lesson on lesson.id = attempt.lesson_id
    left join public.topics topic on topic.id = attempt.topic_id
    where certification.id is null
      or (attempt.lesson_id is not null and lesson.id is null)
      or (attempt.topic_id is not null and topic.id is null)
  ) or exists (
    select 1
    from public.quiz_attempt_questions item
    left join public.quiz_attempts attempt on attempt.id = item.attempt_id
    left join public.questions question on question.id = item.question_id
    where attempt.id is null or question.id is null
  ) or exists (
    select 1
    from public.quiz_answers answer
    left join public.quiz_attempts attempt on attempt.id = answer.attempt_id
    left join public.questions question on question.id = answer.question_id
    left join public.question_options option on option.id = answer.selected_option_id
    where attempt.id is null or question.id is null or option.id is null
  ) then
    raise exception 'Study history contains an orphaned reference';
  end if;
end;
$$;

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
)
values (
  '00000000-0000-0000-0000-000000000000',
  '58000000-0000-4000-8000-000000000004',
  'authenticated',
  'authenticated',
  'region-pairs-quiz@example.invalid',
  '',
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  now(),
  now()
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000004', true);

do $$
declare
  lesson_attempt public.quiz_attempts;
begin
  if (
    select count(*)
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'region-pairs-and-sovereign-regions'
  ) <> 9 then
    raise exception 'Authenticated users cannot read all published 8.5.4 blocks';
  end if;

  select *
  into strict lesson_attempt
  from public.start_lesson_quiz('79f8ca50-0ec9-4dda-bade-9b6d918a913c');

  if lesson_attempt.user_id <> auth.uid()
    or lesson_attempt.lesson_id <> '79f8ca50-0ec9-4dda-bade-9b6d918a913c'
    or lesson_attempt.total_questions <> 5
    or lesson_attempt.status <> 'in_progress'
    or (
      select count(*)
      from public.quiz_attempt_questions
      where attempt_id = lesson_attempt.id
    ) <> 5
    or exists (
      select 1
      from public.quiz_attempt_questions item
      join public.questions question on question.id = item.question_id
      where item.attempt_id = lesson_attempt.id
        and question.lesson_id <> '79f8ca50-0ec9-4dda-bade-9b6d918a913c'
    ) then
    raise exception 'The 8.5.4 Lesson Quiz flow is invalid';
  end if;
end;
$$;

reset role;

select json_build_object(
  'stage', '8.5.4',
  'lesson', 'region-pairs-and-sovereign-regions',
  'lesson_id', '79f8ca50-0ec9-4dda-bade-9b6d918a913c',
  'published_blocks', 9,
  'visual_experiences', 0,
  'flashcards_corrected', 4,
  'questions_corrected', 5,
  'exact_question_duplicates', 0,
  'estimated_minutes', 10,
  'history_preserved', true
) as region_pairs_sovereign_regions_validation;

rollback;

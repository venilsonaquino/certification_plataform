begin;

set local statement_timeout = '30s';

create temporary table target_lessons on commit drop as
select lesson.id, lesson.slug, lesson.estimated_minutes
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and domain.title = 'Describe Azure architecture and services'
  and topic.title = 'Compute Services'
  and lesson.slug in ('azure-app-service', 'choosing-application-hosting');

do $$
declare
  duplicate_count integer;
begin
  if not exists (
    select 1 from supabase_migrations.schema_migrations
    where version = '20260827040000'
  ) then
    raise exception '8.6.5 migration is not registered';
  end if;

  if (select count(*) from target_lessons) <> 2
    or exists (
      select 1
      from target_lessons target
      join public.lessons lesson on lesson.id = target.id
      where not lesson.is_published
        or lesson.content is null
        or btrim(lesson.content) = ''
        or lesson.estimated_minutes <> case lesson.slug
          when 'azure-app-service' then 10
          when 'choosing-application-hosting' then 12
        end
    ) then
    raise exception 'A scoped Lesson is missing or has invalid publication, fallback or estimate';
  end if;

  if (select array_agg(block.type order by block.display_order)
      from public.lesson_content_blocks block
      join target_lessons target on target.id = block.lesson_id
      where target.slug = 'azure-app-service' and block.is_published)
      is distinct from array['explanation','important','example','dotnet_example','important','exam_trap','exam_tip','summary']::text[]
    or (select array_agg(block.type order by block.display_order)
      from public.lesson_content_blocks block
      join target_lessons target on target.id = block.lesson_id
      where target.slug = 'choosing-application-hosting' and block.is_published)
      is distinct from array['explanation','important','dotnet_example','example','example','important','exam_trap','exam_tip','summary']::text[] then
    raise exception 'A scoped Lesson has an unexpected Content Block sequence';
  end if;

  if exists (
    select 1
    from target_lessons target
    join public.lesson_content_blocks block on block.lesson_id = target.id
    group by target.id
    having min(block.display_order) <> 1
      or max(block.display_order) <> count(*)
      or count(distinct block.display_order) <> count(*)
      or count(*) filter (
        where block.type = 'summary'
          and jsonb_typeof(block.config -> 'items') = 'array'
          and jsonb_array_length(block.config -> 'items') between 3 and 6
      ) <> 1
      or count(*) filter (where block.type = 'exam_tip') <> 1
      or count(*) filter (where block.type = 'exam_trap') <> 1
      or count(*) filter (where block.is_published) <> count(*)
  ) then
    raise exception 'Display order, publication, summary, exam tip or exam trap is invalid';
  end if;

  if (select count(*) from public.lesson_content_blocks block join target_lessons target on target.id = block.lesson_id) <> 17
    or exists (
      select 1
      from public.lesson_content_blocks block
      join target_lessons target on target.id = block.lesson_id
      where block.type = 'visual_experience'
         or block.visual_experience_id is not null
    )
    or exists (
      select 1
      from public.visual_experiences visual
      join target_lessons target on target.id = visual.lesson_id
    ) then
    raise exception '8.6.5 block count or no-visual constraint is invalid';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join target_lessons target on target.id = block.lesson_id
    where target.slug = 'choosing-application-hosting'
      and block.title = 'Matriz: Web Apps | Containers | VMs'
      and block.content ilike '%Controle do SO%'
      and block.content ilike '%Portabilidade%'
      and block.content ilike '%Responsabilidade operacional%'
  ) then
    raise exception 'The structured application-hosting comparison is missing';
  end if;

  if (select count(*) from public.flashcards card join target_lessons target on target.id = card.lesson_id where card.is_published) <> 9
    or not exists (select 1 from public.flashcards where id = '72000000-0000-4000-8000-000000000007' and back_text ilike '%PaaS%web%API%')
    or not exists (select 1 from public.flashcards where id = '72000000-0000-4000-8000-000000000009' and back_text ilike '%controle%SO%VM%')
    or (select count(*) from public.flashcards where id between '7e100000-0000-4000-8000-000000000001' and '7e100000-0000-4000-8000-000000000005') <> 5 then
    raise exception 'The scoped Flashcards are incomplete or conceptually invalid';
  end if;

  if exists (
    select 1
    from public.flashcards card
    join target_lessons target on target.id = card.lesson_id
    where concat_ws(' ', card.front_text, card.back_text, card.hint)
      ~* '(deployment slots?|SKUs?|custom domains?|certificates?|Node\.js|Python|Ruby|PHP|Java)'
  ) then
    raise exception 'App Service Flashcards still require out-of-scope feature memorization';
  end if;

  if exists (
    select 1
    from public.questions question
    join target_lessons target on target.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where question.is_published
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
      or min(length(btrim(question.explanation))) < 40
  ) then
    raise exception 'A scoped Question or its options are invalid';
  end if;

  if exists (
    select 1
    from target_lessons target
    left join public.questions question on question.lesson_id = target.id and question.is_published
    group by target.id
    having count(question.id) <> 5
      or count(question.id) filter (where question.difficulty = 'easy') <> 2
      or count(question.id) filter (where question.difficulty = 'medium') <> 2
      or count(question.id) filter (where question.difficulty = 'hard') <> 1
  ) then
    raise exception 'Question count or 2/2/1 difficulty distribution is invalid';
  end if;

  if not exists (
    select 1
    from public.question_options option
    where option.id = '70000000-0000-4000-8000-000000000029'
      and option.question_id = '60000000-0000-4000-8000-000000000008'
      and option.is_correct
      and option.option_text ilike '%plataforma%SO%VM%guest OS%'
  )
    or (select count(*) from public.questions where id between '68000000-0000-4000-8000-000000000016' and '68000000-0000-4000-8000-000000000024') <> 9 then
    raise exception 'Historical App Service practice or required new Questions are missing';
  end if;

  if exists (
    select 1
    from public.questions question
    join target_lessons target on target.id = question.lesson_id
    join public.question_options option on option.question_id = question.id
    where concat_ws(' ', question.question_text, question.explanation, option.option_text, option.explanation)
      ~* '(deployment slots?|SKUs?|custom domains?|certificates?|cor do .cone|cadeiras|marketing)'
  ) then
    raise exception 'Out-of-scope or absurd application-hosting practice remains';
  end if;

  select count(*) into duplicate_count
  from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.questions question
    where question.topic_id = '32000000-0000-4000-8000-000000000002'
    group by 1
    having count(*) > 1
  ) duplicates;

  if duplicate_count <> 0 then
    raise exception 'Compute Services contains exact Question duplicates';
  end if;
end;
$$;

do $$
begin
  if exists (
    select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id = progress.lesson_id where lesson.id is null
  ) or exists (
    select 1 from public.flashcard_reviews review left join public.flashcards flashcard on flashcard.id = review.flashcard_id where flashcard.id is null
  ) or exists (
    select 1 from public.user_flashcard_progress progress left join public.flashcards flashcard on flashcard.id = progress.flashcard_id where flashcard.id is null
  ) or exists (
    select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id = item.attempt_id left join public.questions question on question.id = item.question_id where attempt.id is null or question.id is null
  ) or exists (
    select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id = answer.attempt_id left join public.questions question on question.id = answer.question_id left join public.question_options option on option.id = answer.selected_option_id where attempt.id is null or question.id is null or option.id is null
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
  '58000000-0000-4000-8000-000000000009',
  'authenticated', 'authenticated', 'application-hosting-quiz@example.invalid', '', now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000009', true);

do $$
declare
  target record;
  lesson_attempt public.quiz_attempts;
  topic_attempt public.quiz_attempts;
begin
  if (
    select count(*)
    from public.lesson_content_blocks block
    join target_lessons target on target.id = block.lesson_id
    where block.is_published
  ) <> 17
    or (
      select count(*)
      from public.flashcards card
      join target_lessons target on target.id = card.lesson_id
      where card.is_published
    ) <> 9 then
    raise exception 'Authenticated users cannot read all published 8.6.5 content';
  end if;

  for target in select id from target_lessons order by slug
  loop
    select * into strict lesson_attempt from public.start_lesson_quiz(target.id);
    if lesson_attempt.user_id <> auth.uid()
      or lesson_attempt.lesson_id <> target.id
      or lesson_attempt.total_questions <> 5
      or lesson_attempt.status <> 'in_progress'
      or (select count(*) from public.quiz_attempt_questions where attempt_id = lesson_attempt.id) <> 5 then
      raise exception 'Lesson Quiz failed for %', target.id;
    end if;
  end loop;

  select * into strict topic_attempt
  from public.start_topic_quiz('32000000-0000-4000-8000-000000000002');

  if topic_attempt.user_id <> auth.uid()
    or topic_attempt.topic_id <> '32000000-0000-4000-8000-000000000002'
    or topic_attempt.lesson_id is not null
    or topic_attempt.quiz_type <> 'topic'
    or topic_attempt.total_questions <> 10
    or topic_attempt.status <> 'in_progress'
    or (select count(*) from public.quiz_attempt_questions where attempt_id = topic_attempt.id) <> 10 then
    raise exception 'Compute Topic Quiz failed after the 8.6.5 enrichment';
  end if;
end;
$$;

reset role;

select json_build_object(
  'stage', '8.6.5',
  'lessons', 2,
  'published_blocks', 17,
  'blocks_by_lesson', json_build_object(
    'azure-app-service', 8,
    'choosing-application-hosting', 9
  ),
  'visuals_created', 0,
  'flashcards', 9,
  'flashcards_corrected', 4,
  'flashcards_added', 5,
  'questions', 10,
  'questions_corrected', 1,
  'questions_added', 9,
  'history_preserved', true
) as application_hosting_validation;

rollback;

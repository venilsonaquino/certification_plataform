begin;

set local statement_timeout = '30s';

do $$
declare
  target record;
  actual_types text[];
  target_lesson_ids uuid[];
begin
  if not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260826060000'
  ) then
    raise exception '8.5.2 migration is not registered';
  end if;

  select array_agg(lesson.id order by lesson.display_order)
  into target_lesson_ids
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Core Architectural Components'
    and lesson.slug in ('azure-datacenters', 'azure-regions');

  if coalesce(cardinality(target_lesson_ids), 0) <> 2 then
    raise exception 'Expected two target Lessons';
  end if;

  for target in
    select *
    from (values
      ('azure-datacenters', array[
        'explanation', 'important', 'example', 'important',
        'exam_trap', 'exam_tip', 'summary'
      ]::text[]),
      ('azure-regions', array[
        'explanation', 'important', 'explanation', 'dotnet_example',
        'exam_trap', 'exam_tip', 'summary'
      ]::text[])
    ) expected(slug, block_types)
  loop
    select array_agg(block.type order by block.display_order)
    into actual_types
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = target.slug
      and block.is_published;

    if actual_types is distinct from target.block_types then
      raise exception 'Unexpected block order for %: %', target.slug, actual_types;
    end if;

    if not exists (
      select 1
      from public.lessons lesson
      where lesson.slug = target.slug
        and lesson.id = any(target_lesson_ids)
        and lesson.is_published
        and lesson.estimated_minutes = 10
        and lesson.content is not null
        and btrim(lesson.content) <> ''
    ) then
      raise exception 'Publication, estimate or fallback invalid for %', target.slug;
    end if;
  end loop;

  if (
    select count(*)
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and is_published
  ) <> 14 then
    raise exception 'Expected exactly 14 published blocks';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and display_order not between 1 and 7
  ) or exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
    group by lesson_id
    having min(display_order) <> 1
      or max(display_order) <> 7
      or count(distinct display_order) <> 7
  ) then
    raise exception 'Content Block display_order is not contiguous';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and type = 'summary'
      and (
        coalesce(jsonb_typeof(config -> 'items'), '') <> 'array'
        or jsonb_array_length(config -> 'items') not between 5 and 6
      )
  ) then
    raise exception 'A summary is invalid';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and (type = 'visual_experience' or visual_experience_id is not null)
  ) then
    raise exception 'A Visual Experience was added to a target Lesson';
  end if;
end;
$$;

do $$
declare
  target_lesson_ids uuid[];
  exact_duplicates integer;
begin
  select array_agg(lesson.id)
  into target_lesson_ids
  from public.lessons lesson
  where lesson.slug in ('azure-datacenters', 'azure-regions');

  if (select count(*) from public.flashcards where lesson_id = any(target_lesson_ids) and is_published) <> 11 then
    raise exception 'Expected 11 published Flashcards';
  end if;

  if (select count(*) from public.questions where lesson_id = any(target_lesson_ids) and is_published) <> 16 then
    raise exception 'Expected 16 published Questions';
  end if;

  if exists (
    select 1
    from public.questions question
    left join public.question_options option on option.question_id = question.id
    where question.lesson_id = any(target_lesson_ids)
      and question.is_published
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
  ) then
    raise exception 'A target Question lacks four distinct options and one correct answer';
  end if;

  if exists (
    select 1
    from public.questions
    where lesson_id = (select id from public.lessons where slug = 'azure-datacenters')
      and (
        question_text ilike '%par de regi%'
        or question_text ilike '%region pair%'
        or question_text ilike '%recupera%desastre%'
        or question_text ilike '%múltiplas zonas%'
      )
  ) then
    raise exception 'Datacenters practice still tests a later objective';
  end if;

  if not exists (
    select 1
    from public.questions
    where id = '63000000-0000-4000-8000-000000000081'
      and question_text = 'O que é um Azure Datacenter?'
  ) or not exists (
    select 1
    from public.questions
    where id = '60000000-0000-4000-8000-000000000004'
      and explanation ilike '%opções de resiliência%'
  ) then
    raise exception 'Required practice corrections are missing';
  end if;

  select count(*)
  into exact_duplicates
  from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    where topic.title = 'Core Architectural Components'
    group by 1
    having count(*) > 1
  ) duplicates;

  if exact_duplicates <> 0 then
    raise exception 'Core Architectural Components still contains exact Question duplicates';
  end if;

  if exists (
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
    from public.quiz_attempt_questions attempt_question
    left join public.questions question on question.id = attempt_question.question_id
    where question.id is null
  ) then
    raise exception 'Practice history contains an orphaned reference';
  end if;
end;
$$;

set local role authenticated;

do $$
begin
  if (
    select count(*)
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug in ('azure-datacenters', 'azure-regions')
  ) <> 14 then
    raise exception 'Authenticated users cannot read all published target blocks';
  end if;
end;
$$;

reset role;

select json_build_object(
  'stage', '8.5.2',
  'lessons', 2,
  'published_blocks', 14,
  'flashcards', 11,
  'questions', 16,
  'questions_corrected', 11,
  'visual_experiences_created', 0,
  'estimated_minutes', 20,
  'history_preserved', true
) as datacenters_regions_validation;

rollback;

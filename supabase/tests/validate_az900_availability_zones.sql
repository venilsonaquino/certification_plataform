begin;

set local statement_timeout = '30s';

do $$
declare
  target_lesson_id uuid;
  block_types text[];
  visual_config jsonb;
  duplicate_count integer;
begin
  if not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260826070000'
  ) then
    raise exception '8.5.3 migration is not registered';
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
    and lesson.slug = 'availability-zones';

  select array_agg(type order by display_order)
  into block_types
  from public.lesson_content_blocks
  where lesson_content_blocks.lesson_id = target_lesson_id
    and is_published;

  if block_types is distinct from array[
    'explanation', 'important', 'visual_experience', 'explanation', 'important',
    'dotnet_example', 'exam_tip', 'exam_trap', 'summary'
  ]::text[] then
    raise exception 'Unexpected Availability Zones block order: %', block_types;
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
    where lesson_content_blocks.lesson_id = target_lesson_id
    group by lesson_content_blocks.lesson_id
    having min(display_order) <> 1
      or max(display_order) <> 9
      or count(distinct display_order) <> 9
      or count(*) <> 9
  ) then
    raise exception 'Content Block display_order is not contiguous';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks
    where lesson_content_blocks.lesson_id = target_lesson_id
      and type = 'summary'
      and jsonb_typeof(config -> 'items') = 'array'
      and jsonb_array_length(config -> 'items') = 6
  ) then
    raise exception 'Availability Zones summary is invalid';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks
    where lesson_content_blocks.lesson_id = target_lesson_id
      and type = 'visual_experience'
      and visual_experience_id = '76000000-0000-4000-8000-000000000002'
      and content is null
      and config is null
  ) then
    raise exception 'The existing visual is not linked by its Content Block';
  end if;

  select config
  into strict visual_config
  from public.visual_experiences
  where id = '76000000-0000-4000-8000-000000000002'
    and visual_experiences.lesson_id = target_lesson_id
    and type = 'architecture'
    and is_published;

  if jsonb_array_length(visual_config -> 'nodes') <> 7
    or jsonb_array_length(visual_config -> 'edges') <> 6
    or (select count(*) from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'kind' = 'zone') <> 3
    or (select count(*) from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'label' = '1+ Datacenters') <> 3
    or exists (
      select 1
      from jsonb_array_elements(visual_config -> 'nodes') node
      where node ->> 'kind' = 'zone'
        and not (
          node ->> 'description' ilike '%energia%'
          and node ->> 'description' ilike '%refrigeração%'
          and node ->> 'description' ilike '%networking%'
        )
    ) then
    raise exception 'Availability Zones Visual Experience config is invalid';
  end if;

  if (select count(*) from public.flashcards where flashcards.lesson_id = target_lesson_id and is_published) <> 7
    or exists (
      select 1 from public.flashcards
      where flashcards.lesson_id = target_lesson_id
        and (front_text ilike '%Availability Set%' or back_text ilike '%Availability Set%')
    ) then
    raise exception 'Availability Zones Flashcards are invalid';
  end if;

  if not exists (
    select 1 from public.flashcards
    where id = '70000000-0000-4000-8000-000000000016'
      and back_text ilike '%um ou mais datacenters%'
  ) or not exists (
    select 1 from public.flashcards
    where id = '71000000-0000-4000-8000-000000000083'
      and back_text ilike '%múltiplas Zones%'
  ) then
    raise exception 'Required Availability Zones memory cues are missing';
  end if;

  if (select count(*) from public.questions where questions.lesson_id = target_lesson_id and is_published) <> 5
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
    ) then
    raise exception 'Availability Zones Questions are invalid';
  end if;

  select count(*)
  into duplicate_count
  from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    where topic.id = '30000000-0000-4000-8000-000000000002'
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
    where lesson.slug = 'availability-zones'
  ) <> 9 then
    raise exception 'Authenticated users cannot read all published Availability Zones blocks';
  end if;

  if not exists (
    select 1
    from public.visual_experiences
    where id = '76000000-0000-4000-8000-000000000002'
  ) then
    raise exception 'Authenticated users cannot read the published visual';
  end if;
end;
$$;

reset role;

select json_build_object(
  'stage', '8.5.3',
  'lesson', 'availability-zones',
  'published_blocks', 9,
  'visual_id', '76000000-0000-4000-8000-000000000002',
  'visual_nodes', 7,
  'flashcards_corrected', 7,
  'questions_corrected', 5,
  'estimated_minutes', 10,
  'history_preserved', true
) as availability_zones_validation;

rollback;

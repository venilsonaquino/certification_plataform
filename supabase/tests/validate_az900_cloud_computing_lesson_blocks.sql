begin;

set local statement_timeout = '30s';

do $$
declare
  actual_types text[];
  expected_types text[];
  target record;
  target_lesson_ids uuid[];
begin
  if not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260826010000'
  ) then
    raise exception 'Cloud Computing enrichment migration is not registered';
  end if;

  select array_agg(lesson.id order by lesson.display_order)
  into target_lesson_ids
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Cloud Computing'
    and lesson.slug in (
      'what-is-cloud-computing',
      'public-private-hybrid-cloud',
      'choosing-a-cloud-model',
      'consumption-based-model',
      'capex-vs-opex',
      'serverless-computing'
    );

  if coalesce(cardinality(target_lesson_ids), 0) <> 6 then
    raise exception 'Expected exactly six target lessons, found %', cardinality(target_lesson_ids);
  end if;

  for target in
    select *
    from (values
      ('what-is-cloud-computing', array[
        'explanation', 'important', 'example', 'dotnet_example', 'exam_tip', 'summary'
      ]::text[], 10),
      ('public-private-hybrid-cloud', array[
        'explanation', 'visual_experience', 'example', 'important', 'exam_tip', 'summary'
      ]::text[], 10),
      ('choosing-a-cloud-model', array[
        'explanation', 'example', 'example', 'example', 'exam_trap', 'exam_tip', 'summary'
      ]::text[], 10),
      ('consumption-based-model', array[
        'explanation', 'important', 'example', 'dotnet_example', 'exam_tip', 'summary'
      ]::text[], 8),
      ('capex-vs-opex', array[
        'explanation', 'visual_experience', 'example', 'important', 'exam_tip', 'exam_trap', 'summary'
      ]::text[], 10),
      ('serverless-computing', array[
        'explanation', 'important', 'example', 'dotnet_example', 'exam_tip', 'exam_trap', 'summary'
      ]::text[], 10)
    ) expected(slug, block_types, estimated_minutes)
  loop
    select array_agg(block.type order by block.display_order)
    into actual_types
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = target.slug
      and block.is_published;

    expected_types := target.block_types;
    if actual_types is distinct from expected_types then
      raise exception 'Unexpected block order for %: expected %, found %',
        target.slug, expected_types, actual_types;
    end if;

    if not exists (
      select 1
      from public.lessons lesson
      where lesson.slug = target.slug
        and lesson.id = any(target_lesson_ids)
        and lesson.estimated_minutes = target.estimated_minutes
        and lesson.estimated_minutes between 8 and 12
        and lesson.content is not null
        and btrim(lesson.content) <> ''
    ) then
      raise exception 'Estimate or legacy fallback is invalid for %', target.slug;
    end if;
  end loop;

  if (
    select count(*)
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and is_published
  ) <> 39 then
    raise exception 'The six enriched lessons must have exactly 39 published blocks';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and not is_published
  ) then
    raise exception 'A target lesson contains an unpublished block';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and type in (
        'explanation', 'important', 'example', 'dotnet_example', 'exam_tip', 'exam_trap'
      )
      and (content is null or btrim(content) = '')
  ) then
    raise exception 'A textual Cloud Computing block is empty';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and type = 'summary'
      and (
        coalesce(jsonb_typeof(config -> 'items'), '') <> 'array'
        or jsonb_array_length(config -> 'items') < 4
        or exists (
          select 1
          from jsonb_array_elements(config -> 'items') item
          where jsonb_typeof(item) <> 'string'
            or btrim(item #>> '{}') = ''
        )
      )
  ) then
    raise exception 'A Cloud Computing summary is invalid';
  end if;

  if (
    select count(*)
    from public.visual_experiences visual
    where visual.id in (
      '76000000-0000-4000-8000-000000000005',
      '76000000-0000-4000-8000-000000000006'
    )
      and visual.type = 'comparison'
      and visual.is_published
      and jsonb_typeof(visual.config -> 'columns') = 'array'
      and jsonb_array_length(visual.config -> 'columns') between 2 and 3
      and jsonb_typeof(visual.config -> 'rows') = 'array'
      and jsonb_array_length(visual.config -> 'rows') = 4
  ) <> 2 then
    raise exception 'The lightweight comparison visuals are invalid';
  end if;

  if (
    select count(*)
    from public.lesson_content_blocks block
    where block.lesson_id = any(target_lesson_ids)
      and block.type = 'visual_experience'
      and block.visual_experience_id in (
        '76000000-0000-4000-8000-000000000005',
        '76000000-0000-4000-8000-000000000006'
      )
      and block.content is null
      and block.config is null
  ) <> 2 then
    raise exception 'The comparison visuals are not linked by their content blocks';
  end if;
end;
$$;

do $$
declare
  shared_lesson_id uuid;
  shared_types text[];
  fallback_lesson_id uuid;
begin
  select lesson.id
  into strict shared_lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and lesson.slug = 'shared-responsibility-model';

  select array_agg(type order by display_order)
  into shared_types
  from public.lesson_content_blocks
  where lesson_id = shared_lesson_id
    and is_published;

  if shared_types is distinct from array[
    'explanation', 'important', 'visual_experience', 'example',
    'dotnet_example', 'exam_tip', 'exam_trap', 'summary'
  ]::text[] then
    raise exception 'Shared Responsibility was modified unexpectedly: %', shared_types;
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = shared_lesson_id
      and type = 'visual_experience'
      and visual_experience_id = '76000000-0000-4000-8000-000000000004'
  ) then
    raise exception 'Shared Responsibility visual experience was not preserved';
  end if;

  select lesson.id
  into strict fallback_lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and lesson.slug = 'infrastructure-as-a-service'
    and lesson.content is not null
    and btrim(lesson.content) <> '';

  if (
    select count(*)
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and block.is_published
  ) <> 128 then
    raise exception 'Domain 1 must expose 128 published blocks after 8.4.4';
  end if;

  if (
    select count(distinct lesson.id)
    from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    join public.lesson_content_blocks block on block.lesson_id = lesson.id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and block.is_published
  ) <> 18 then
    raise exception 'All 18 Domain 1 lessons should use content blocks';
  end if;

  if (
    select count(*)
    from public.flashcards flashcard
    join public.lessons lesson on lesson.id = flashcard.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and flashcard.is_published
  ) <> 84 then
    raise exception 'Domain 1 flashcards were not preserved';
  end if;

  if (
    select count(*)
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and question.is_published
  ) <> 153 then
    raise exception 'Domain 1 question count is inconsistent after 8.4.5';
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
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
  ) <> 128 then
    raise exception 'Authenticated users cannot read every published Domain 1 block';
  end if;
end;
$$;

reset role;

select json_build_object(
  'domain', 'Describe cloud concepts',
  'enriched_lessons', 6,
  'new_blocks', 39,
  'total_block_lessons', 18,
  'total_published_blocks', 128,
  'comparison_visuals', 2,
  'shared_responsibility_preserved', true,
  'legacy_content_preserved', true,
  'flashcards_preserved', 84,
  'questions_available', 153
) as cloud_computing_lesson_validation;

rollback;

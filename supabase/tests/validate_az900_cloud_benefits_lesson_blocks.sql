begin;

set local statement_timeout = '30s';

do $$
declare
  actual_types text[];
  actual_order text[];
  target record;
  target_lesson_ids uuid[];
begin
  if not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260826020000'
  ) then
    raise exception 'Cloud benefits enrichment migration is not registered';
  end if;

  select
    array_agg(lesson.id order by lesson.display_order),
    array_agg(lesson.slug order by lesson.display_order)
  into target_lesson_ids, actual_order
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Benefits of Cloud Services';

  if actual_order is distinct from array[
    'high-availability',
    'scalability',
    'elasticity',
    'reliability',
    'predictability',
    'security-and-governance-benefits',
    'manageability'
  ]::text[] then
    raise exception 'Unexpected cloud benefits lesson order: %', actual_order;
  end if;

  for target in
    select *
    from (values
      ('high-availability', array[
        'explanation', 'important', 'example', 'dotnet_example',
        'exam_tip', 'exam_trap', 'summary'
      ]::text[], 10),
      ('scalability', array[
        'explanation', 'important', 'example', 'dotnet_example',
        'exam_tip', 'exam_trap', 'summary'
      ]::text[], 10),
      ('elasticity', array[
        'explanation', 'important', 'example', 'dotnet_example',
        'exam_tip', 'exam_trap', 'summary'
      ]::text[], 10),
      ('reliability', array[
        'explanation', 'important', 'example', 'dotnet_example',
        'exam_tip', 'exam_trap', 'summary'
      ]::text[], 10),
      ('predictability', array[
        'explanation', 'important', 'example', 'dotnet_example',
        'exam_tip', 'exam_trap', 'summary'
      ]::text[], 10),
      ('security-and-governance-benefits', array[
        'explanation', 'important', 'example', 'explanation', 'example',
        'dotnet_example', 'exam_tip', 'exam_trap', 'summary'
      ]::text[], 12),
      ('manageability', array[
        'explanation', 'important', 'example', 'dotnet_example',
        'exam_tip', 'exam_trap', 'summary'
      ]::text[], 10)
    ) expected(slug, block_types, estimated_minutes)
  loop
    select array_agg(block.type order by block.display_order)
    into actual_types
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.id = any(target_lesson_ids)
      and lesson.slug = target.slug
      and block.is_published;

    if actual_types is distinct from target.block_types then
      raise exception 'Unexpected block order for %: expected %, found %',
        target.slug, target.block_types, actual_types;
    end if;

    if not exists (
      select 1
      from public.lessons lesson
      where lesson.id = any(target_lesson_ids)
        and lesson.slug = target.slug
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
  ) <> 51 then
    raise exception 'The seven cloud benefits lessons must have 51 published blocks';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and not is_published
  ) then
    raise exception 'A cloud benefits lesson contains an unpublished block';
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
    raise exception 'A textual cloud benefits block is empty';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and type = 'summary'
      and (
        coalesce(jsonb_typeof(config -> 'items'), '') <> 'array'
        or jsonb_array_length(config -> 'items') < 5
        or exists (
          select 1
          from jsonb_array_elements(config -> 'items') item
          where jsonb_typeof(item) <> 'string'
            or btrim(item #>> '{}') = ''
        )
      )
  ) then
    raise exception 'A cloud benefits summary is invalid';
  end if;
end;
$$;

do $$
begin
  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'scalability'
      and block.type = 'explanation'
      and block.content ilike '%Scale Up%'
      and block.content ilike '%Scale Down%'
      and block.content ilike '%Scale Out%'
      and block.content ilike '%Scale In%'
  ) then
    raise exception 'Vertical and horizontal scaling directions are incomplete';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'elasticity'
      and block.type = 'exam_trap'
      and block.title = 'Scalability versus Elasticity'
  ) then
    raise exception 'Scalability versus Elasticity comparison is missing';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'reliability'
      and block.type = 'exam_trap'
      and block.title = 'Availability versus Reliability'
  ) then
    raise exception 'Availability versus Reliability comparison is missing';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'security-and-governance-benefits'
      and block.type = 'important'
      and block.title = 'Cloud não significa automaticamente seguro'
  ) then
    raise exception 'Cloud security warning is missing';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'security-and-governance-benefits'
      and block.type = 'exam_trap'
      and block.title = 'Security versus Governance'
  ) then
    raise exception 'Security versus Governance comparison is missing';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'high-availability'
      and block.content ilike '%Availability Zone%'
  ) then
    raise exception 'High Availability goes too deep into Availability Zones';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'manageability'
      and block.type = 'explanation'
      and block.content ilike '%Portal%'
      and block.content ilike '%CLI%'
      and block.content ilike '%PowerShell%'
      and block.content ilike '%APIs%'
      and block.content ilike '%Infrastructure as Code%'
  ) then
    raise exception 'Manageability interfaces are incomplete';
  end if;
end;
$$;

do $$
declare
  service_types_legacy_content_count integer;
begin
  select count(*)
  into service_types_legacy_content_count
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Cloud Service Types'
    and lesson.content is not null
    and btrim(lesson.content) <> '';

  if service_types_legacy_content_count <> 4 then
    raise exception 'All four Cloud Service Types lessons must preserve legacy content';
  end if;

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
  ) <> 129 then
    raise exception 'Domain 1 must expose 129 published blocks after 8.4.7';
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
  ) <> 129 then
    raise exception 'Authenticated users cannot read every published Domain 1 block';
  end if;
end;
$$;

reset role;

select json_build_object(
  'topic', 'Benefits of Cloud Services',
  'enriched_lessons', 7,
  'new_blocks', 51,
  'domain_block_lessons', 18,
  'domain_published_blocks', 129,
  'service_types_legacy_content_preserved', true,
  'flashcards_preserved', 84,
  'questions_available', 153
) as cloud_benefits_lesson_validation;

rollback;

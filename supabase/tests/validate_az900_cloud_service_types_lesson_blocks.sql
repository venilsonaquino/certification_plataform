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
    where version = '20260826030000'
  ) then
    raise exception 'Cloud Service Types enrichment migration is not registered';
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
    and topic.title = 'Cloud Service Types';

  if actual_order is distinct from array[
    'infrastructure-as-a-service',
    'platform-as-a-service',
    'software-as-a-service',
    'choosing-iaas-paas-saas'
  ]::text[] then
    raise exception 'Unexpected Cloud Service Types lesson order: %', actual_order;
  end if;

  for target in
    select *
    from (values
      ('infrastructure-as-a-service', array[
        'explanation', 'important', 'example', 'dotnet_example',
        'exam_tip', 'exam_trap', 'summary'
      ]::text[], 10),
      ('platform-as-a-service', array[
        'explanation', 'important', 'example', 'dotnet_example',
        'exam_tip', 'exam_trap', 'summary'
      ]::text[], 10),
      ('software-as-a-service', array[
        'explanation', 'important', 'example', 'dotnet_example',
        'exam_tip', 'exam_trap', 'summary'
      ]::text[], 10),
      ('choosing-iaas-paas-saas', array[
        'explanation', 'visual_experience', 'example', 'example', 'example',
        'important', 'exam_tip', 'exam_trap', 'summary'
      ]::text[], 12)
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
      raise exception 'Estimate or legacy content is invalid for %', target.slug;
    end if;
  end loop;

  if (
    select count(*)
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and is_published
  ) <> 30 then
    raise exception 'The four Service Types lessons must have 30 published blocks';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and not is_published
  ) then
    raise exception 'A Service Types lesson contains an unpublished block';
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
    raise exception 'A textual Service Types block is empty';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and type = 'summary'
      and (
        coalesce(jsonb_typeof(config -> 'items'), '') <> 'array'
        or jsonb_array_length(config -> 'items') not between 3 and 6
        or exists (
          select 1
          from jsonb_array_elements(config -> 'items') item
          where jsonb_typeof(item) <> 'string'
            or btrim(item #>> '{}') = ''
        )
      )
  ) then
    raise exception 'A Service Types summary is invalid';
  end if;
end;
$$;

do $$
declare
  comparison_config jsonb;
begin
  select visual.config
  into strict comparison_config
  from public.visual_experiences visual
  join public.lessons lesson on lesson.id = visual.lesson_id
  where visual.id = '76000000-0000-4000-8000-000000000001'
    and lesson.slug = 'choosing-iaas-paas-saas'
    and visual.type = 'comparison'
    and visual.is_published;

  if jsonb_array_length(comparison_config -> 'columns') <> 3
    or jsonb_array_length(comparison_config -> 'rows') <> 4
    or not (comparison_config -> 'rows') @> $json$[
      {"id": "control"},
      {"id": "operations"},
      {"id": "use-case"},
      {"id": "azure-example"}
    ]$json$::jsonb then
    raise exception 'The reused IaaS/PaaS/SaaS comparison config is invalid';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'choosing-iaas-paas-saas'
      and block.type = 'visual_experience'
      and block.visual_experience_id = '76000000-0000-4000-8000-000000000001'
      and block.content is null
      and block.config is null
  ) then
    raise exception 'The comparison visual is not linked to Choosing Service Type';
  end if;

  if (
    select count(*)
    from public.visual_experiences visual
    where visual.type = 'responsibility'
      and visual.id = '76000000-0000-4000-8000-000000000004'
      and visual.is_published
  ) <> 1 then
    raise exception 'The existing Shared Responsibility visual was changed or duplicated';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'shared-responsibility-model'
      and block.type = 'visual_experience'
      and block.visual_experience_id = '76000000-0000-4000-8000-000000000004'
  ) then
    raise exception 'Shared Responsibility no longer references its visual';
  end if;
end;
$$;

do $$
begin
  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'infrastructure-as-a-service'
      and block.type = 'exam_trap'
      and block.title = 'IaaS não é servidor físico próprio'
  ) then
    raise exception 'IaaS exam trap is missing';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'platform-as-a-service'
      and block.type = 'dotnet_example'
      and block.content ilike '%ASP.NET Core%'
      and block.content ilike '%Azure App Service%'
      and block.content ilike '%sistema operacional%'
  ) then
    raise exception 'PaaS .NET example is incomplete';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'platform-as-a-service'
      and block.type = 'exam_trap'
      and block.title = 'PaaS não é SaaS'
  ) then
    raise exception 'PaaS versus SaaS exam trap is missing';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'software-as-a-service'
      and block.type = 'exam_trap'
      and block.title = 'SaaS não significa zero responsabilidade'
  ) then
    raise exception 'SaaS responsibility exam trap is missing';
  end if;

  if (
    select count(*)
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'choosing-iaas-paas-saas'
      and block.type = 'example'
      and block.title like 'Cenário:%'
  ) <> 3 then
    raise exception 'Choosing Service Type must have exactly three scenario examples';
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
  'topic', 'Cloud Service Types',
  'enriched_lessons', 4,
  'new_blocks', 30,
  'domain_block_lessons', 18,
  'domain_published_blocks', 129,
  'comparison_visual_reused', true,
  'responsibility_visual_preserved', true,
  'legacy_content_preserved', true,
  'flashcards_preserved', 84,
  'questions_available', 153
) as cloud_service_types_lesson_validation;

rollback;

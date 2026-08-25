begin;

do $$
declare
  target_lesson_id uuid;
  target_visual_experience_id uuid;
  ordered_types text[];
  ordered_ids uuid[];
  summary_config jsonb;
begin
  select lesson.id, visual.id
  into strict target_lesson_id, target_visual_experience_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  join public.visual_experiences visual
    on visual.lesson_id = lesson.id
   and visual.type = 'responsibility'
   and visual.is_published = true
  where certification.code = 'az-900'
    and lesson.slug = 'shared-responsibility-model';

  if (
    select count(*)
    from public.lesson_content_blocks
    where lesson_id = target_lesson_id
  ) <> 8 then
    raise exception 'Shared Responsibility must have exactly 8 content blocks';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id <> target_lesson_id
  ) then
    raise exception 'A Lesson other than Shared Responsibility was converted in 8.3.4';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = target_lesson_id
      and not is_published
  ) then
    raise exception 'Shared Responsibility has an unpublished pilot block';
  end if;

  select
    array_agg(type order by display_order),
    array_agg(id order by display_order)
  into ordered_types, ordered_ids
  from public.lesson_content_blocks
  where lesson_id = target_lesson_id;

  if ordered_types <> array[
    'explanation',
    'important',
    'visual_experience',
    'example',
    'dotnet_example',
    'exam_tip',
    'exam_trap',
    'summary'
  ]::text[] then
    raise exception 'Unexpected Shared Responsibility block order: %', ordered_types;
  end if;

  if ordered_ids <> array[
    '79000000-0000-4000-8000-000000000001',
    '79000000-0000-4000-8000-000000000002',
    '79000000-0000-4000-8000-000000000003',
    '79000000-0000-4000-8000-000000000004',
    '79000000-0000-4000-8000-000000000005',
    '79000000-0000-4000-8000-000000000006',
    '79000000-0000-4000-8000-000000000007',
    '79000000-0000-4000-8000-000000000008'
  ]::uuid[] then
    raise exception 'Unexpected deterministic block IDs: %', ordered_ids;
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = target_lesson_id
      and type in (
        'explanation', 'important', 'example', 'dotnet_example', 'exam_tip', 'exam_trap'
      )
      and (content is null or btrim(content) = '')
  ) then
    raise exception 'A textual pilot block has empty content';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = target_lesson_id
      and type = 'visual_experience'
      and visual_experience_id = target_visual_experience_id
      and content is null
      and config is null
  ) then
    raise exception 'The responsibility visual is not referenced correctly';
  end if;

  select config
  into strict summary_config
  from public.lesson_content_blocks
  where lesson_id = target_lesson_id
    and type = 'summary';

  if coalesce(jsonb_typeof(summary_config -> 'items'), '') <> 'array'
    or jsonb_array_length(summary_config -> 'items') <> 5
    or exists (
      select 1
      from jsonb_array_elements(summary_config -> 'items') item
      where jsonb_typeof(item) <> 'string'
        or btrim(item #>> '{}') = ''
    ) then
    raise exception 'Shared Responsibility summary config is invalid';
  end if;

  if not exists (
    select 1
    from public.lessons
    where id = target_lesson_id
      and content is not null
      and btrim(content) <> ''
  ) then
    raise exception 'Legacy lessons.content was not preserved';
  end if;

  if not exists (
    select 1
    from public.flashcards
    where lesson_id = target_lesson_id
      and is_published = true
  ) then
    raise exception 'Shared Responsibility flashcards are no longer available';
  end if;

  if not exists (
    select 1
    from public.questions
    where lesson_id = target_lesson_id
      and is_published = true
  ) then
    raise exception 'Shared Responsibility quiz questions are no longer available';
  end if;

  if not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260825060000'
  ) then
    raise exception 'Shared Responsibility lesson block migration is not registered';
  end if;
end;
$$;

set local role authenticated;

do $$
declare
  visible_types text[];
begin
  select array_agg(block.type order by block.display_order)
  into visible_types
  from public.lesson_content_blocks block
  join public.lessons lesson on lesson.id = block.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and lesson.slug = 'shared-responsibility-model';

  if visible_types <> array[
    'explanation',
    'important',
    'visual_experience',
    'example',
    'dotnet_example',
    'exam_tip',
    'exam_trap',
    'summary'
  ]::text[] then
    raise exception 'Authenticated user cannot read the ordered pilot blocks: %', visible_types;
  end if;
end;
$$;

reset role;

select json_build_object(
  'lesson', 'shared-responsibility-model',
  'published_blocks', 8,
  'ordered_types', array[
    'explanation',
    'important',
    'visual_experience',
    'example',
    'dotnet_example',
    'exam_tip',
    'exam_trap',
    'summary'
  ],
  'responsibility_visual_reused', true,
  'legacy_content_preserved', true,
  'flashcards_preserved', true,
  'quiz_preserved', true
) as shared_responsibility_lesson_validation;

rollback;

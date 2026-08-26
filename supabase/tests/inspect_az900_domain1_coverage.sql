with target_domain as (
  select domain.id, domain.title, domain.exam_weight_min, domain.exam_weight_max
  from public.domains domain
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
),
target_lessons as (
  select
    lesson.id,
    topic.id as topic_id,
    topic.title as topic_title,
    topic.display_order as topic_order,
    lesson.slug,
    lesson.title,
    lesson.short_description,
    lesson.content,
    lesson.estimated_minutes,
    lesson.display_order,
    lesson.is_published
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join target_domain domain on domain.id = topic.domain_id
)
select json_build_object(
  'domain', (select row_to_json(domain) from target_domain domain),
  'topics', (select count(distinct topic_id) from target_lessons),
  'lessons', (select count(*) from target_lessons),
  'published_lessons', (select count(*) from target_lessons where is_published),
  'content_blocks', (
    select count(*)
    from public.lesson_content_blocks block
    join target_lessons lesson on lesson.id = block.lesson_id
  ),
  'published_content_blocks', (
    select count(*)
    from public.lesson_content_blocks block
    join target_lessons lesson on lesson.id = block.lesson_id
    where block.is_published
  ),
  'flashcards', (
    select count(*)
    from public.flashcards flashcard
    join target_lessons lesson on lesson.id = flashcard.lesson_id
  ),
  'published_flashcards', (
    select count(*)
    from public.flashcards flashcard
    join target_lessons lesson on lesson.id = flashcard.lesson_id
    where flashcard.is_published
  ),
  'questions', (
    select count(*)
    from public.questions question
    join target_lessons lesson on lesson.id = question.lesson_id
  ),
  'published_questions', (
    select count(*)
    from public.questions question
    join target_lessons lesson on lesson.id = question.lesson_id
    where question.is_published
  )
) as domain_1_summary;

with target_lessons as (
  select
    lesson.id,
    topic.title as topic_title,
    topic.display_order as topic_order,
    lesson.slug,
    lesson.title,
    lesson.short_description,
    lesson.content,
    lesson.estimated_minutes,
    lesson.display_order,
    lesson.is_published
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
)
select
  lesson.id,
  lesson.topic_title,
  lesson.topic_order,
  lesson.slug,
  lesson.title,
  lesson.short_description,
  lesson.content,
  lesson.estimated_minutes,
  lesson.display_order,
  lesson.is_published,
  coalesce(blocks.total, 0) as content_block_count,
  coalesce(blocks.published, 0) as published_content_block_count,
  coalesce(blocks.types, array[]::text[]) as published_content_block_types,
  coalesce(flashcards.total, 0) as flashcard_count,
  coalesce(flashcards.published, 0) as published_flashcard_count,
  coalesce(questions.total, 0) as question_count,
  coalesce(questions.published, 0) as published_question_count
from target_lessons lesson
left join lateral (
  select
    count(*) as total,
    count(*) filter (where block.is_published) as published,
    array_agg(block.type order by block.display_order)
      filter (where block.is_published) as types
  from public.lesson_content_blocks block
  where block.lesson_id = lesson.id
) blocks on true
left join lateral (
  select
    count(*) as total,
    count(*) filter (where flashcard.is_published) as published
  from public.flashcards flashcard
  where flashcard.lesson_id = lesson.id
) flashcards on true
left join lateral (
  select
    count(*) as total,
    count(*) filter (where question.is_published) as published
  from public.questions question
  where question.lesson_id = lesson.id
) questions on true
order by lesson.topic_order, lesson.display_order;

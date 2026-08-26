with target_lessons as (
  select lesson.id, lesson.slug
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
),
question_distribution as (
  select
    lesson.slug,
    count(question.id) filter (where question.is_published) as published_questions,
    count(question.id) filter (
      where question.is_published and question.difficulty = 'easy'
    ) as easy,
    count(question.id) filter (
      where question.is_published and question.difficulty = 'medium'
    ) as medium,
    count(question.id) filter (
      where question.is_published and question.difficulty = 'hard'
    ) as hard
  from target_lessons lesson
  left join public.questions question on question.lesson_id = lesson.id
  group by lesson.slug
),
normalized_questions as (
  select
    question.id,
    lesson.slug,
    lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g'))
      as normalized
  from public.questions question
  join target_lessons lesson on lesson.id = question.lesson_id
),
question_duplicates as (
  select
    normalized,
    count(*) as duplicate_count,
    array_agg(id order by id) as question_ids,
    array_agg(distinct slug order by slug) as lesson_slugs
  from normalized_questions
  group by normalized
  having count(*) > 1
),
normalized_flashcards as (
  select
    flashcard.id,
    lesson.slug,
    lower(regexp_replace(btrim(flashcard.front_text), '[^[:alnum:]]+', ' ', 'g'))
      as normalized
  from public.flashcards flashcard
  join target_lessons lesson on lesson.id = flashcard.lesson_id
),
flashcard_duplicates as (
  select
    normalized,
    count(*) as duplicate_count,
    array_agg(id order by id) as flashcard_ids,
    array_agg(distinct slug order by slug) as lesson_slugs
  from normalized_flashcards
  group by normalized
  having count(*) > 1
)
select json_build_object(
  'question_distribution', (
    select json_agg(distribution order by distribution.slug)
    from question_distribution distribution
  ),
  'exact_question_duplicates', coalesce(
    (
      select json_agg(duplicate order by duplicate.duplicate_count desc, duplicate.normalized)
      from question_duplicates duplicate
    ),
    '[]'::json
  ),
  'exact_flashcard_duplicates', coalesce(
    (
      select json_agg(duplicate order by duplicate.duplicate_count desc, duplicate.normalized)
      from flashcard_duplicates duplicate
    ),
    '[]'::json
  )
) as domain_1_artifact_quality;

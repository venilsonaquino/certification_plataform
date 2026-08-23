select json_build_object(
  'questions', count(*),
  'lessons', json_agg(
    json_build_object(
      'lesson', inventory.lesson_title,
      'topic', inventory.topic_title,
      'domain', inventory.domain_title,
      'difficulty', inventory.difficulty
    )
    order by inventory.domain_order, inventory.topic_order, inventory.lesson_order
  )
) as question_inventory
from (
  select
    question.id,
    question.difficulty,
    lesson.title as lesson_title,
    lesson.display_order as lesson_order,
    topic.title as topic_title,
    topic.display_order as topic_order,
    domain.title as domain_title,
    domain.display_order as domain_order
  from public.questions question
  join public.lessons lesson on lesson.id = question.lesson_id
  join public.topics topic on topic.id = question.topic_id
  join public.domains domain on domain.id = question.domain_id
  join public.certifications certification on certification.id = question.certification_id
  where certification.code = 'az-900'
) inventory;

select json_build_object(
  'question_constraints', (
    select count(*)
    from pg_constraint
    where conrelid = 'public.questions'::regclass
  ),
  'option_constraints', (
    select count(*)
    from pg_constraint
    where conrelid = 'public.question_options'::regclass
  ),
  'question_indexes', (
    select count(*)
    from pg_indexes
    where schemaname = 'public' and tablename = 'questions'
  ),
  'option_indexes', (
    select count(*)
    from pg_indexes
    where schemaname = 'public' and tablename = 'question_options'
  ),
  'rls_policies', (
    select count(*)
    from pg_policies
    where schemaname = 'public'
      and tablename in ('questions', 'question_options')
  )
) as question_schema_inventory;

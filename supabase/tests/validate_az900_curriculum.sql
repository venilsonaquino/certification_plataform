with az900_domains as (
  select d.id, d.title, d.display_order
  from public.domains d
  join public.certifications c on c.id = d.certification_id
  where c.code = 'az-900'
),
az900_topics as (
  select t.id, t.domain_id, t.title, t.display_order
  from public.topics t
  join az900_domains d on d.id = t.domain_id
),
az900_lessons as (
  select l.*
  from public.lessons l
  join az900_topics t on t.id = l.topic_id
),
domain_summary as (
  select
    d.display_order,
    d.title,
    count(distinct t.id) as topics,
    count(l.id) as lessons
  from az900_domains d
  left join az900_topics t on t.domain_id = d.id
  left join az900_lessons l on l.topic_id = t.id
  group by d.id, d.display_order, d.title
),
duplicate_titles as (
  select lower(title) as normalized_title
  from az900_lessons
  group by lower(title)
  having count(*) > 1
),
duplicate_topic_orders as (
  select domain_id, display_order
  from az900_topics
  group by domain_id, display_order
  having count(*) > 1
),
duplicate_lesson_orders as (
  select topic_id, display_order
  from az900_lessons
  group by topic_id, display_order
  having count(*) > 1
)
select json_build_object(
  'domains', (select count(*) from az900_domains),
  'topics', (select count(*) from az900_topics),
  'lessons', (select count(*) from az900_lessons),
  'total_estimated_minutes', (select sum(estimated_minutes) from az900_lessons),
  'average_estimated_minutes', (select round(avg(estimated_minutes), 1) from az900_lessons),
  'domain_summary', (
    select json_agg(
      json_build_object('order', display_order, 'title', title, 'topics', topics, 'lessons', lessons)
      order by display_order
    )
    from domain_summary
  ),
  'duplicate_lesson_titles', (select count(*) from duplicate_titles),
  'duplicate_topic_orders', (select count(*) from duplicate_topic_orders),
  'duplicate_lesson_orders', (select count(*) from duplicate_lesson_orders),
  'lessons_outside_5_to_15_minutes', (select count(*) from az900_lessons where estimated_minutes not between 5 and 15),
  'unpublished_lessons', (select count(*) from az900_lessons where not is_published),
  'empty_topics', (select count(*) from az900_topics t where not exists (select 1 from az900_lessons l where l.topic_id = t.id)),
  'lessons_missing_structure', (
    select count(*)
    from az900_lessons
    where content not like '%## O que você precisa entender%'
      or content not like '%## Explicação simples%'
      or content not like '%## Exemplo%'
      or content not like '%## O que lembrar para a prova%'
  )
) as curriculum_validation;

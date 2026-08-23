with ordered_lessons as (
  select
    d.display_order as domain_order,
    d.title as domain_title,
    t.display_order as topic_order,
    t.title as topic_title,
    l.display_order as lesson_order,
    l.slug,
    l.title,
    lag(l.slug) over (
      order by d.display_order, t.display_order, l.display_order
    ) as previous_slug,
    lead(l.slug) over (
      order by d.display_order, t.display_order, l.display_order
    ) as next_slug,
    lag(t.id) over (
      order by d.display_order, t.display_order, l.display_order
    ) as previous_topic_id,
    lead(t.id) over (
      order by d.display_order, t.display_order, l.display_order
    ) as next_topic_id,
    lag(d.id) over (
      order by d.display_order, t.display_order, l.display_order
    ) as previous_domain_id,
    lead(d.id) over (
      order by d.display_order, t.display_order, l.display_order
    ) as next_domain_id,
    t.id as topic_id,
    d.id as domain_id,
    row_number() over (
      order by d.display_order, t.display_order, l.display_order
    ) as global_order
  from public.certifications c
  join public.domains d on d.certification_id = c.id
  join public.topics t on t.domain_id = d.id
  join public.lessons l on l.topic_id = t.id and l.is_published
  where c.code = 'az-900'
),
topic_transitions as (
  select *
  from ordered_lessons
  where next_topic_id is distinct from topic_id
    and next_slug is not null
),
domain_transitions as (
  select *
  from ordered_lessons
  where next_domain_id is distinct from domain_id
    and next_slug is not null
)
select json_build_object(
  'lesson_count', (select count(*) from ordered_lessons),
  'first_lesson', (
    select json_build_object('slug', slug, 'previous', previous_slug, 'next', next_slug)
    from ordered_lessons
    order by global_order
    limit 1
  ),
  'last_lesson', (
    select json_build_object('slug', slug, 'previous', previous_slug, 'next', next_slug)
    from ordered_lessons
    order by global_order desc
    limit 1
  ),
  'topic_transition_count', (select count(*) from topic_transitions),
  'domain_transition_count', (select count(*) from domain_transitions),
  'topic_transitions', (
    select json_agg(
      json_build_object(
        'from_slug', slug,
        'to_slug', next_slug,
        'from_topic', topic_title
      )
      order by global_order
    )
    from topic_transitions
  ),
  'domain_transitions', (
    select json_agg(
      json_build_object(
        'from_slug', slug,
        'to_slug', next_slug,
        'from_domain', domain_title
      )
      order by global_order
    )
    from domain_transitions
  )
) as study_navigation_validation;

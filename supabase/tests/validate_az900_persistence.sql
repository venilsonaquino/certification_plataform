with az900 as (
  select id
  from public.certifications
  where code = 'az-900'
),
az900_domains as (
  select d.*
  from public.domains d
  join az900 c on c.id = d.certification_id
),
az900_topics as (
  select t.*
  from public.topics t
  join az900_domains d on d.id = t.domain_id
),
az900_lessons as (
  select l.*
  from public.lessons l
  join az900_topics t on t.id = l.topic_id
),
future_certifications as (
  select id
  from public.certifications
  where code in ('az-104', 'az-204', 'ai-900', 'dp-900', 'sc-900')
),
ordered_domains as (
  select display_order, row_number() over (order by display_order, id) as expected_order
  from az900_domains
),
ordered_topics as (
  select
    domain_id,
    display_order,
    row_number() over (partition by domain_id order by display_order, id) as expected_order
  from az900_topics
),
ordered_lessons as (
  select
    topic_id,
    display_order,
    row_number() over (partition by topic_id order by display_order, id) as expected_order
  from az900_lessons
),
hierarchy as (
  select json_agg(
    json_build_object(
      'domain_order', d.display_order,
      'domain', d.title,
      'topics', (
        select json_agg(
          json_build_object(
            'topic_order', t.display_order,
            'topic', t.title,
            'lessons', (
              select json_agg(
                json_build_object(
                  'lesson_order', l.display_order,
                  'slug', l.slug,
                  'title', l.title
                )
                order by l.display_order
              )
              from az900_lessons l
              where l.topic_id = t.id
            )
          )
          order by t.display_order
        )
        from az900_topics t
        where t.domain_id = d.id
      )
    )
    order by d.display_order
  ) as value
  from az900_domains d
)
select json_build_object(
  'counts', json_build_object(
    'az900_certifications', (select count(*) from az900),
    'domains', (select count(*) from az900_domains),
    'topics', (select count(*) from az900_topics),
    'lessons', (select count(*) from az900_lessons)
  ),
  'integrity', json_build_object(
    'orphan_domains', (select count(*) from public.domains d left join public.certifications c on c.id = d.certification_id where c.id is null),
    'orphan_topics', (select count(*) from public.topics t left join public.domains d on d.id = t.domain_id where d.id is null),
    'orphan_lessons', (select count(*) from public.lessons l left join public.topics t on t.id = l.topic_id where t.id is null),
    'duplicate_topic_slugs', (
      select count(*)
      from (
        select topic_id, slug from az900_lessons group by topic_id, slug having count(*) > 1
      ) duplicates
    ),
    'duplicate_global_slugs', (
      select count(*)
      from (
        select slug from az900_lessons group by slug having count(*) > 1
      ) duplicates
    ),
    'invalid_slugs', (select count(*) from az900_lessons where slug <> lower(slug) or slug !~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
    'incomplete_lessons', (
      select count(*)
      from az900_lessons
      where short_description is null
        or content is null
        or estimated_minutes is null
        or not is_published
    ),
    'domain_order_gaps', (select count(*) from ordered_domains where display_order <> expected_order),
    'topic_order_gaps', (select count(*) from ordered_topics where display_order <> expected_order),
    'lesson_order_gaps', (select count(*) from ordered_lessons where display_order <> expected_order),
    'future_certification_domains', (select count(*) from public.domains d join future_certifications c on c.id = d.certification_id)
  ),
  'security', json_build_object(
    'rls_enabled_tables', (
      select count(*)
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public'
        and c.relname in ('certifications', 'domains', 'topics', 'lessons')
        and c.relrowsecurity
    ),
    'authenticated_select_policies', (
      select count(*)
      from pg_policies
      where schemaname = 'public'
        and tablename in ('certifications', 'domains', 'topics', 'lessons')
        and cmd = 'SELECT'
        and roles = array['authenticated']::name[]
    ),
    'authenticated_write_policies', (
      select count(*)
      from pg_policies
      where schemaname = 'public'
        and tablename in ('certifications', 'domains', 'topics', 'lessons')
        and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')
    ),
    'authenticated_write_grants', (
      select count(*)
      from information_schema.role_table_grants
      where table_schema = 'public'
        and grantee = 'authenticated'
        and table_name in ('certifications', 'domains', 'topics', 'lessons')
        and privilege_type in ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')
    )
  ),
  'migration_applied', exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260822183000'
  ),
  'hierarchy', (select value from hierarchy)
) as persistence_validation;

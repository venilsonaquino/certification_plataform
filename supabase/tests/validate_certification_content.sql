select json_build_object(
  'seed_counts', json_build_object(
    'certifications', (select count(*) from public.certifications),
    'enabled_certifications', (select count(*) from public.certifications where is_enabled),
    'domains', (select count(*) from public.domains),
    'topics', (select count(*) from public.topics),
    'published_lessons', (select count(*) from public.lessons where is_published)
  ),
  'constraints', json_build_object(
    'primary_keys', (select count(*) from pg_constraint where contype = 'p' and conrelid in ('public.certifications'::regclass, 'public.domains'::regclass, 'public.topics'::regclass, 'public.lessons'::regclass)),
    'foreign_keys', (select count(*) from pg_constraint where contype = 'f' and conrelid in ('public.domains'::regclass, 'public.topics'::regclass, 'public.lessons'::regclass)),
    'cascade_foreign_keys', (select count(*) from pg_constraint where contype = 'f' and confdeltype = 'c' and conrelid in ('public.domains'::regclass, 'public.topics'::regclass, 'public.lessons'::regclass)),
    'unique_constraints', (select count(*) from pg_constraint where contype = 'u' and conrelid in ('public.certifications'::regclass, 'public.domains'::regclass, 'public.topics'::regclass, 'public.lessons'::regclass)),
    'check_constraints', (select count(*) from pg_constraint where contype = 'c' and conrelid in ('public.certifications'::regclass, 'public.domains'::regclass, 'public.topics'::regclass, 'public.lessons'::regclass))
  ),
  'security', json_build_object(
    'rls_enabled_tables', (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public' and c.relname in ('certifications', 'domains', 'topics', 'lessons') and c.relrowsecurity),
    'authenticated_select_policies', (select count(*) from pg_policies where schemaname = 'public' and tablename in ('certifications', 'domains', 'topics', 'lessons') and cmd = 'SELECT' and roles = array['authenticated']::name[]),
    'write_policies', (select count(*) from pg_policies where schemaname = 'public' and tablename in ('certifications', 'domains', 'topics', 'lessons') and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')),
    'authenticated_select_grants', (select count(*) from information_schema.role_table_grants where table_schema = 'public' and grantee = 'authenticated' and table_name in ('certifications', 'domains', 'topics', 'lessons') and privilege_type = 'SELECT'),
    'authenticated_write_grants', (select count(*) from information_schema.role_table_grants where table_schema = 'public' and grantee = 'authenticated' and table_name in ('certifications', 'domains', 'topics', 'lessons') and privilege_type in ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE'))
  ),
  'migration_applied', exists (select 1 from supabase_migrations.schema_migrations where version = '20260822163000')
) as validation;

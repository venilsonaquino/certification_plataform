select json_build_object(
  'table_exists', to_regclass('public.user_lesson_progress') is not null,
  'columns', (
    select json_agg(column_name order by ordinal_position)
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'user_lesson_progress'
  ),
  'constraints', json_build_object(
    'primary_keys', (
      select count(*) from pg_constraint
      where conrelid = 'public.user_lesson_progress'::regclass and contype = 'p'
    ),
    'foreign_keys', (
      select count(*) from pg_constraint
      where conrelid = 'public.user_lesson_progress'::regclass and contype = 'f'
    ),
    'unique_constraints', (
      select count(*) from pg_constraint
      where conrelid = 'public.user_lesson_progress'::regclass and contype = 'u'
    ),
    'check_constraints', (
      select count(*) from pg_constraint
      where conrelid = 'public.user_lesson_progress'::regclass and contype = 'c'
    )
  ),
  'indexes', (
    select json_agg(indexname order by indexname)
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'user_lesson_progress'
  ),
  'security', json_build_object(
    'rls_enabled', (
      select relrowsecurity
      from pg_class
      where oid = 'public.user_lesson_progress'::regclass
    ),
    'policies', (
      select json_agg(json_build_object('name', policyname, 'command', cmd) order by cmd)
      from pg_policies
      where schemaname = 'public'
        and tablename = 'user_lesson_progress'
    ),
    'authenticated_grants', (
      select json_agg(privilege_type order by privilege_type)
      from information_schema.role_table_grants
      where table_schema = 'public'
        and table_name = 'user_lesson_progress'
        and grantee = 'authenticated'
    )
  ),
  'functions', json_build_object(
    'start_exists', to_regprocedure('public.start_lesson_progress(uuid)') is not null,
    'complete_exists', to_regprocedure('public.complete_lesson_progress(uuid)') is not null,
    'security_definer_functions', (
      select count(*)
      from pg_proc
      where oid in (
        to_regprocedure('public.start_lesson_progress(uuid)'),
        to_regprocedure('public.complete_lesson_progress(uuid)')
      )
        and prosecdef
    )
  ),
  'migration_applied', exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260822213000'
  )
) as user_lesson_progress_schema_validation;

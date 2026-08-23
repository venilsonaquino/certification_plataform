select json_build_object(
  'columns', (
    select json_agg(json_build_object(
      'name', column_name,
      'type', data_type,
      'nullable', is_nullable,
      'default', column_default
    ) order by ordinal_position)
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'flashcard_reviews'
  ),
  'constraints', (
    select json_agg(constraint_name order by constraint_name)
    from information_schema.table_constraints
    where table_schema = 'public'
      and table_name = 'flashcard_reviews'
  ),
  'indexes', (
    select json_agg(indexname order by indexname)
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'flashcard_reviews'
  ),
  'policies', (
    select json_agg(json_build_object(
      'policy', policyname,
      'command', cmd,
      'roles', roles,
      'using', qual,
      'check', with_check
    ) order by policyname)
    from pg_policies
    where schemaname = 'public'
      and tablename = 'flashcard_reviews'
  ),
  'rpc_security_definer', (
    select prosecdef
    from pg_proc
    where oid = 'public.submit_flashcard_review(uuid, text)'::regprocedure
  )
) as flashcard_reviews_schema;

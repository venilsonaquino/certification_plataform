select json_build_object(
  'review_rows', (select count(*) from public.flashcard_reviews),
  'review_pairs', (
    select count(*) from (
      select user_id, flashcard_id from public.flashcard_reviews group by user_id, flashcard_id
    ) pairs
  ),
  'progress_rows', (select count(*) from public.user_flashcard_progress),
  'indexes', (
    select json_agg(indexname order by indexname)
    from pg_indexes
    where schemaname = 'public' and tablename = 'user_flashcard_progress'
  ),
  'policies', (
    select json_agg(json_build_object('name', policyname, 'command', cmd, 'roles', roles) order by policyname)
    from pg_policies
    where schemaname = 'public' and tablename = 'user_flashcard_progress'
  ),
  'rpc_security', (
    select json_agg(json_build_object('name', proname, 'security_definer', prosecdef) order by proname)
    from pg_proc
    where oid in (
      'public.submit_flashcard_review(uuid, text)'::regprocedure,
      'public.get_flashcard_study_queue(uuid, integer, integer)'::regprocedure,
      'public.get_flashcard_review_overview(uuid)'::regprocedure
    )
  )
) as spaced_flashcard_review;

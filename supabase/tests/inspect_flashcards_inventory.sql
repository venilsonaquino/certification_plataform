select json_build_object(
  'total', (select count(*) from public.flashcards),
  'published', (select count(*) from public.flashcards where is_published),
  'lessons', (
    select json_agg(title order by title)
    from (
      select distinct lessons.title
      from public.flashcards flashcards
      join public.lessons lessons on lessons.id = flashcards.lesson_id
    ) seeded_lessons
  ),
  'policies', (
    select json_agg(json_build_object(
      'policy', policyname,
      'command', cmd,
      'roles', roles,
      'using', qual
    ))
    from pg_policies
    where schemaname = 'public'
      and tablename = 'flashcards'
  ),
  'indexes', (
    select json_agg(indexname order by indexname)
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'flashcards'
  )
) as flashcards_inventory;

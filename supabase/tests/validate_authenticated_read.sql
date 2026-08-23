begin;
set local role authenticated;

select json_build_object(
  'certifications_visible', (select count(*) from public.certifications),
  'domains_visible', (select count(*) from public.domains),
  'topics_visible', (select count(*) from public.topics),
  'published_lessons_visible', (select count(*) from public.lessons where is_published)
) as authenticated_read;

rollback;

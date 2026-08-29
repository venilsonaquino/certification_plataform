begin;

do $$
declare lesson_row record;
begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000003')<>7 then
    raise exception '9.6.5 expected seven Lessons'; end if;
  for lesson_row in select id,slug from public.lessons where topic_id='33000000-0000-4000-8000-000000000003' loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and is_published)
        <>(case lesson_row.slug when 'azure-arc' then 13 when 'infrastructure-as-code' then 12
          when 'azure-resource-manager-and-arm-templates' then 14 else 10 end)
      or (select count(*) from public.flashcards where lesson_id=lesson_row.id and is_published)
        <>(case lesson_row.slug when 'azure-arc' then 7 when 'azure-resource-manager-and-arm-templates' then 8 else 6 end)
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug in('azure-cloud-shell','azure-cli','azure-arc','azure-resource-manager-and-arm-templates') then 10 else 5 end) then
      raise exception '9.6.5 inventory invalid for %',lesson_row.slug; end if;
  end loop;
  if (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and block.is_published)<>79
    or (select count(*) from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and card.is_published)<>45
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and question.is_published)<>55 then
    raise exception '9.6.5 totals invalid'; end if;
end; $$;

rollback;

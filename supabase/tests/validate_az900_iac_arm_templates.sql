begin;

do $$
declare lesson_row record; arm_lesson_id uuid;
begin
  for lesson_row in select id,slug from public.lessons where topic_id='33000000-0000-4000-8000-000000000003'
    and slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates') loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='infrastructure-as-code' then 12 else 14 end)
      or (select count(*) from public.flashcards where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='infrastructure-as-code' then 6 else 8 end)
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='infrastructure-as-code' then 5 else 10 end) then
      raise exception '9.6.4 inventory invalid for %',lesson_row.slug; end if;
  end loop;
  select id into strict arm_lesson_id from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000003' and slug='azure-resource-manager-and-arm-templates';
  if not exists(select 1 from public.visual_experiences where lesson_id=arm_lesson_id and type='architecture'
      and jsonb_array_length(config->'nodes')=8 and jsonb_array_length(config->'edges')=7 and is_published)
    or not exists(select 1 from public.lesson_content_blocks where lesson_id=arm_lesson_id and type='visual_experience'
      and visual_experience_id='76000000-0000-4000-8000-000000000016') then
    raise exception '9.6.4 ARM visual invalid'; end if;
  if exists(select 1 from public.questions question left join public.question_options option on option.question_id=question.id
    where question.lesson_id in(select id from public.lessons where topic_id='33000000-0000-4000-8000-000000000003'
      and slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates'))
    group by question.id having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1) then
    raise exception '9.6.4 Question options invalid'; end if;
end; $$;

rollback;

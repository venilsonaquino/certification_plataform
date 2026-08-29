begin;

do $$
declare lesson_row record;
begin
  for lesson_row in select id,slug,estimated_minutes from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000003'
      and slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell') loop
    if lesson_row.estimated_minutes<>10
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and is_published)<>10
      or (select min(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)<>1
      or (select max(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)<>10
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='summary')<>1
      or (select count(*) from public.flashcards where lesson_id=lesson_row.id and is_published)<>6
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug in('azure-cloud-shell','azure-cli') then 10 else 5 end) then
      raise exception '9.6.2 inventory invalid for %',lesson_row.slug; end if;
  end loop;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003'
      and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell')) then
    raise exception '9.6.2 expected no Visual Experiences'; end if;
  if exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003'
      and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell')
    group by question.id having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1) then
    raise exception '9.6.2 Question options invalid'; end if;
end; $$;

rollback;

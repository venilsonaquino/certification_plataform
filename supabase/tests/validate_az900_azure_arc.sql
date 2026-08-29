begin;

do $$
declare lesson_uuid uuid;
begin
  select id into strict lesson_uuid from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000003' and slug='azure-arc'
      and is_published and content is not null and btrim(content)<>'' and estimated_minutes=12;
  if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_uuid and is_published)<>13
    or (select min(display_order) from public.lesson_content_blocks where lesson_id=lesson_uuid)<>1
    or (select max(display_order) from public.lesson_content_blocks where lesson_id=lesson_uuid)<>13
    or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_uuid and type='summary')<>1
    or (select count(*) from public.flashcards where lesson_id=lesson_uuid and is_published)<>7
    or (select count(*) from public.questions where lesson_id=lesson_uuid and is_published)<>10 then
    raise exception '9.6.3 inventory invalid'; end if;
  if exists(select 1 from public.visual_experiences where lesson_id=lesson_uuid) then
    raise exception '9.6.3 expected no Visual Experience'; end if;
  if exists(select 1 from public.questions question left join public.question_options option on option.question_id=question.id
    where question.lesson_id=lesson_uuid group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1) then
    raise exception '9.6.3 Question options invalid'; end if;
end; $$;

rollback;

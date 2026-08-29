do $$
declare advisor_id uuid; health_id uuid;
begin
  select id into strict advisor_id from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000004' and slug='azure-advisor';
  select id into strict health_id from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000004' and slug='azure-service-health';
  if (select count(*) from public.lesson_content_blocks where lesson_id=advisor_id and is_published)<>11
    or (select count(*) from public.lesson_content_blocks where lesson_id=health_id and is_published)<>12
    or (select count(*) from public.flashcards where lesson_id=advisor_id and is_published)<>7
    or (select count(*) from public.flashcards where lesson_id=health_id and is_published)<>8
    or (select count(*) from public.questions where lesson_id=advisor_id and is_published)<>10
    or (select count(*) from public.questions where lesson_id=health_id and is_published)<>5 then
    raise exception 'Advisor and Service Health inventory is invalid';
  end if;
  if exists(select 1 from public.questions question left join public.question_options option on option.question_id=question.id
      where question.lesson_id in(advisor_id,health_id) group by question.id
      having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1) then
    raise exception 'Advisor or Service Health practice is invalid';
  end if;
  if exists(select 1 from public.visual_experiences visual
      where visual.lesson_id in(advisor_id,health_id)) then
    raise exception '9.7.2 must not contain a Visual Experience';
  end if;
end; $$;

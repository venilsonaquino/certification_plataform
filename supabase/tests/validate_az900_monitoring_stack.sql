do $$ begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000004' and is_published)<>6
    or (select count(*) from public.lesson_content_blocks b join public.lessons l on l.id=b.lesson_id where l.topic_id='33000000-0000-4000-8000-000000000004' and b.is_published)<>60
    or (select count(*) from public.flashcards f join public.lessons l on l.id=f.lesson_id where l.topic_id='33000000-0000-4000-8000-000000000004' and f.is_published)<>39
    or (select count(*) from public.questions where topic_id='33000000-0000-4000-8000-000000000004' and is_published)<>40
    or (select count(*) from public.visual_experiences v join public.lessons l on l.id=v.lesson_id where l.topic_id='33000000-0000-4000-8000-000000000004' and v.is_published)<>1 then
    raise exception 'Monitoring stack inventory invalid'; end if;
end; $$;

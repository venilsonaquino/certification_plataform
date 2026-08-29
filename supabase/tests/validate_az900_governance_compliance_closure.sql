begin;
set local statement_timeout='30s';
do $$ begin
  if not exists(select 1 from supabase_migrations.schema_migrations where version='20260829030000')
    or not exists(select 1 from supabase_migrations.schema_migrations where version='20260829031000') then
    raise exception '9.5.4 migrations are not registered'; end if;
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000002')<>3
    or (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000002' and block.is_published)<>37
    or (select count(*) from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000002' and card.is_published)<>20
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000002' and question.is_published)<>15 then
    raise exception '9.5.4 closure inventory is invalid'; end if;
end; $$;
select json_build_object('stage','9.5.4','status','CLOSED','lessons',3,'blocks',37,'visuals',0,
  'flashcards',20,'questions',15,'difficulty',json_build_object('easy',6,'medium',6,'hard',3)) as validation;
rollback;

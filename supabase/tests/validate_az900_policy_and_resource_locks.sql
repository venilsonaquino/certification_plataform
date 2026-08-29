begin;
set local statement_timeout='30s';
do $$
declare target record;
begin
  if not exists(select 1 from supabase_migrations.schema_migrations where version='20260829020000')
    or not exists(select 1 from supabase_migrations.schema_migrations where version='20260829021000') then
    raise exception '9.5.3 migrations are not registered'; end if;
  for target in select lesson.id,lesson.slug from public.lessons lesson
    where lesson.topic_id='33000000-0000-4000-8000-000000000002' and lesson.slug in('azure-policy','resource-locks') loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=target.id and is_published)<>12
      or (select count(*) from public.flashcards where lesson_id=target.id and is_published)<>6
      or (select count(*) from public.questions where lesson_id=target.id and is_published)<>5
      or exists(select 1 from public.questions question left join public.question_options option on option.question_id=question.id
        where question.lesson_id=target.id group by question.id having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1) then
      raise exception '9.5.3 invalid artifacts for %',target.slug; end if;
  end loop;
end; $$;
select json_build_object('stage','9.5.3','lessons',2,'blocks',24,'flashcards',12,'questions',10,'options',40,'visuals',0) as validation;
rollback;

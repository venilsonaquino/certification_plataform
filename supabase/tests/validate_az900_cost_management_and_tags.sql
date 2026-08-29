begin;
set local statement_timeout='30s';

create temporary table target_lessons on commit drop as
select lesson.id,lesson.slug,lesson.estimated_minutes,lesson.display_order
from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and domain.title='Describe Azure management and governance'
  and topic.id='33000000-0000-4000-8000-000000000001' and topic.title='Cost Management'
  and lesson.slug in ('azure-cost-management','resource-tags');

do $$
declare duplicate_count integer;
begin
  if not exists(select 1 from supabase_migrations.schema_migrations where version='20260828110000') then
    raise exception '9.3 migration is not registered'; end if;
  if (select count(*) from target_lessons)<>2
    or exists(select 1 from target_lessons target join public.lessons lesson on lesson.id=target.id
      where not lesson.is_published or lesson.content is null or btrim(lesson.content)=''
        or lesson.estimated_minutes<>(case target.slug when 'azure-cost-management' then 12 else 10 end)) then
    raise exception '9.3 Lesson inventory, publication, fallback or estimates are invalid'; end if;
  if exists(select 1 from target_lessons target left join public.lesson_content_blocks block on block.lesson_id=target.id
    group by target.id,target.slug having count(block.id)<>13 or min(block.display_order)<>1 or max(block.display_order)<>13
      or count(distinct block.display_order)<>13 or count(*) filter(where block.is_published)<>13
      or count(*) filter(where block.type='explanation')<3 or count(*) filter(where block.type='important')<3
      or count(*) filter(where block.type='example')<2 or count(*) filter(where block.type='exam_tip')<>1
      or count(*) filter(where block.type='exam_trap')<1 or count(*) filter(where block.type='summary')<>1
      or count(*) filter(where block.type='visual_experience')<>0) then
    raise exception '9.3 Content Blocks or ordering are invalid'; end if;
  if exists(select 1 from public.lesson_content_blocks summary join target_lessons target on target.id=summary.lesson_id
    where summary.type='summary' and (summary.display_order<>13 or jsonb_typeof(summary.config->'items')<>'array'
      or jsonb_array_length(summary.config->'items') not between 3 and 6)) then
    raise exception '9.3 summary is invalid'; end if;
  if exists(select 1 from public.visual_experiences visual join target_lessons target on target.id=visual.lesson_id) then
    raise exception '9.3 must not contain a Visual Experience'; end if;
  if exists(select 1 from target_lessons target left join public.flashcards card on card.lesson_id=target.id and card.is_published
    group by target.id,target.slug having count(card.id)<>(case target.slug when 'azure-cost-management' then 7 else 6 end)) then
    raise exception '9.3 Flashcard inventory is invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g'))
    from public.flashcards card join target_lessons target on target.id=card.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.3 contains exact Flashcard duplicates'; end if;
  if exists(select 1 from target_lessons target left join public.questions question on question.lesson_id=target.id and question.is_published
    group by target.id,target.slug having count(question.id)<>(case target.slug when 'azure-cost-management' then 10 else 5 end)
      or count(question.id) filter(where question.difficulty='easy')<>(case target.slug when 'azure-cost-management' then 3 else 2 end)
      or count(question.id) filter(where question.difficulty='medium')<>(case target.slug when 'azure-cost-management' then 5 else 2 end)
      or count(question.id) filter(where question.difficulty='hard')<>(case target.slug when 'azure-cost-management' then 2 else 1 end)) then
    raise exception '9.3 Question inventory or difficulty is invalid'; end if;
  if (select count(*) from public.questions where id between '63000000-0000-4000-8000-000000000071'
      and '63000000-0000-4000-8000-000000000080')<>10
    or (select count(*) from public.questions where id between '68000000-0000-4000-8000-000000000124'
      and '68000000-0000-4000-8000-000000000128')<>5 then
    raise exception '9.3 historical or new Question UUIDs are invalid'; end if;
  if exists(select 1 from public.questions question join target_lessons target on target.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id where question.is_published group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception '9.3 Question or Question Options are invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g'))
    from public.questions question join target_lessons target on target.id=question.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.3 contains exact Question duplicates'; end if;
  if not exists(with artifacts as(
    select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card join target_lessons target on target.id=card.lesson_id
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question join target_lessons target on target.id=question.lesson_id),
    combined as(select string_agg(text,' ') text from artifacts)
    select 1 from combined where text ~* 'Cost Analysis' and text ~* 'Budget' and text ~* 'alert'
      and text ~* 'Actual Cost' and text ~* 'Forecast' and text ~* 'Pricing Calculator') then
    raise exception '9.3 Cost Management concepts are missing'; end if;
  if not exists(with artifacts as(
    select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card join target_lessons target on target.id=card.lesson_id
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question join target_lessons target on target.id=question.lesson_id),
    combined as(select string_agg(text,' ') text from artifacts)
    select 1 from combined where text ~* 'key/value' and text ~* 'Resource Groups' and text ~* 'Subscriptions'
      and text ~* 'não são automaticamente herdadas' and text ~* 'RBAC' and text ~* 'Resource Locks'
      and text ~* 'Azure Policy') then
    raise exception '9.3 Tag concepts are missing'; end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null) then
    raise exception 'Study history contains an orphaned reference'; end if;
  if not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.questions','UPDATE') then
    raise exception '9.3 curriculum grants are invalid'; end if;
end; $$;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values('00000000-0000-0000-0000-000000000000','58000000-0000-4000-8000-000000000026','authenticated','authenticated',
  'cost-93@example.invalid','',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now());
grant select on target_lessons to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000026',true);
do $$
declare lesson_target record; lesson_attempt public.quiz_attempts; topic_attempt public.quiz_attempts;
begin
  for lesson_target in select id from target_lessons order by display_order loop
    select * into strict lesson_attempt from public.start_lesson_quiz(lesson_target.id);
    if lesson_attempt.total_questions<>5
      or (select count(*) from public.quiz_attempt_questions where attempt_id=lesson_attempt.id)<>5 then
      raise exception '9.3 Lesson Quiz failed for %',lesson_target.id; end if;
  end loop;
  select * into strict topic_attempt from public.start_topic_quiz('33000000-0000-4000-8000-000000000001');
  if topic_attempt.total_questions<>10
    or (select count(*) from public.quiz_attempt_questions where attempt_id=topic_attempt.id)<>10
    or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id
      where item.attempt_id=topic_attempt.id)<>4
    or exists(select 1 from target_lessons scoped where not exists(select 1 from public.quiz_attempt_questions item
      join public.questions question on question.id=item.question_id
      where item.attempt_id=topic_attempt.id and question.lesson_id=scoped.id)) then
    raise exception '9.3 Topic Quiz failed'; end if;
end; $$;
reset role;

select json_build_object('stage','9.3','lessons',2,'published_blocks',26,'visuals_created',0,
  'flashcards_preserved',0,'flashcards_added',13,'questions_preserved_and_corrected',10,'questions_added',5,
  'tags_difficulty',json_build_object('easy',2,'medium',2,'hard',1),'history_preserved',true)
  as cost_management_tags_validation;
rollback;

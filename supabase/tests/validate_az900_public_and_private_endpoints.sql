begin;
set local statement_timeout='30s';

create temporary table target_lesson on commit drop as
select lesson.id,lesson.slug,lesson.estimated_minutes from public.lessons lesson
join public.topics topic on topic.id=lesson.topic_id join public.domains domain on domain.id=topic.domain_id
join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and domain.title='Describe Azure architecture and services'
  and topic.title='Networking Services' and lesson.slug='public-vs-private-endpoints';

do $$ declare visual_config jsonb; duplicate_count integer;
begin
  if not exists(select 1 from supabase_migrations.schema_migrations where version='20260827080000') then raise exception '8.7.5 migration is not registered'; end if;
  if (select count(*) from target_lesson)<>1 or exists(select 1 from target_lesson target join public.lessons lesson on lesson.id=target.id
    where not lesson.is_published or lesson.content is null or btrim(lesson.content)='' or lesson.estimated_minutes<>12) then
    raise exception 'Target Lesson publication, fallback or estimate is invalid'; end if;
  if (select array_agg(block.type order by block.display_order) from public.lesson_content_blocks block join target_lesson target on target.id=block.lesson_id where block.is_published)
    is distinct from array['explanation','important','explanation','important','important','important','dotnet_example','visual_experience','exam_trap','exam_tip','summary']::text[] then
    raise exception 'Unexpected block sequence'; end if;
  if exists(select 1 from target_lesson target join public.lesson_content_blocks block on block.lesson_id=target.id group by target.id
    having count(*)<>11 or min(block.display_order)<>1 or max(block.display_order)<>11 or count(distinct block.display_order)<>11
      or count(*) filter(where block.is_published)<>11
      or count(*) filter(where block.type='summary' and jsonb_typeof(block.config->'items')='array' and jsonb_array_length(block.config->'items') between 3 and 6)<>1
      or count(*) filter(where block.type='exam_tip')<>1 or count(*) filter(where block.type='exam_trap')<>1
      or count(*) filter(where block.type='visual_experience' and block.visual_experience_id='76000000-0000-4000-8000-000000000012')<>1) then
    raise exception 'Block order or required blocks are invalid'; end if;

  select visual.config into strict visual_config from public.visual_experiences visual join target_lesson target on target.id=visual.lesson_id
  where visual.id='76000000-0000-4000-8000-000000000012' and visual.type='comparison' and visual.is_published;
  if jsonb_typeof(visual_config->'columns')<>'array' or jsonb_typeof(visual_config->'rows')<>'array'
    or jsonb_array_length(visual_config->'columns')<>2 or jsonb_array_length(visual_config->'rows')<>6 then
    raise exception 'Endpoint comparison visual shape is invalid'; end if;
  if exists(select 1 from jsonb_array_elements(visual_config->'rows') row_config
    where not(row_config->'values'?'public-endpoint') or not(row_config->'values'?'private-endpoint') or jsonb_object_length(row_config->'values')<>2) then
    raise exception 'A visual row does not cover both endpoint columns'; end if;

  if (select count(*) from public.flashcards card join target_lesson target on target.id=card.lesson_id where card.is_published)<>5
    or not exists(select 1 from public.flashcards where id='72000000-0000-4000-8000-000000000035' and back_text ilike '%Não necessariamente%coexistir%')
    or not exists(select 1 from public.flashcards where id='7e200000-0000-4000-8000-000000000001' and back_text ilike '%Private Link%tecnologia%Private Endpoint%interface%')
    or not exists(select 1 from public.flashcards where id='7e200000-0000-4000-8000-000000000002' and back_text ilike '%Service Endpoint%público%Private Endpoint%IP privado%') then
    raise exception 'Endpoint Flashcards are incomplete'; end if;
  if exists(select 1 from public.questions question join target_lesson target on target.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id where question.is_published group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception 'A Question or options are invalid'; end if;
  if (select count(*) from public.questions question join target_lesson target on target.id=question.lesson_id where question.is_published)<>5
    or (select count(*) from public.questions question join target_lesson target on target.id=question.lesson_id where difficulty='easy')<>2
    or (select count(*) from public.questions question join target_lesson target on target.id=question.lesson_id where difficulty='medium')<>2
    or (select count(*) from public.questions question join target_lesson target on target.id=question.lesson_id where difficulty='hard')<>1 then
    raise exception 'Question count or 2/2/1 distribution is invalid'; end if;
  if exists(select 1 from public.questions question join target_lesson target on target.id=question.lesson_id
    join public.question_options option on option.question_id=question.id
    where concat_ws(' ',question.question_text,question.explanation,option.option_text,option.explanation)
      ~* '(Private DNS Resolver|DNS forwarding|registros? (A|CNAME)|Service Endpoints? detalhado|BGP|ExpressRoute Direct|FastPath)') then
    raise exception 'Out-of-scope endpoint practice remains'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g'))
    from public.questions question where question.topic_id='32000000-0000-4000-8000-000000000003' group by 1 having count(*)>1)duplicates;
  if duplicate_count<>0 then raise exception 'Networking Services contains exact Question duplicates'; end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id where attempt.id is null or question.id is null or option.id is null) then
    raise exception 'Study history contains an orphaned reference'; end if;
end; $$;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values('00000000-0000-0000-0000-000000000000','58000000-0000-4000-8000-000000000016','authenticated','authenticated','endpoints-quiz@example.invalid','',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now());
set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000016',true);
do $$ declare target_id uuid; lesson_attempt public.quiz_attempts; topic_attempt public.quiz_attempts;
begin
  select id into strict target_id from target_lesson;
  if (select count(*) from public.lesson_content_blocks where lesson_id=target_id and is_published)<>11
    or (select count(*) from public.visual_experiences where lesson_id=target_id and is_published)<>1
    or (select count(*) from public.flashcards where lesson_id=target_id and is_published)<>5 then raise exception 'Authenticated endpoint content read failed'; end if;
  select * into strict lesson_attempt from public.start_lesson_quiz(target_id);
  if lesson_attempt.user_id<>auth.uid() or lesson_attempt.lesson_id<>target_id or lesson_attempt.total_questions<>5
    or lesson_attempt.status<>'in_progress' or (select count(*) from public.quiz_attempt_questions where attempt_id=lesson_attempt.id)<>5 then raise exception 'Endpoint Lesson Quiz failed'; end if;
  select * into strict topic_attempt from public.start_topic_quiz('32000000-0000-4000-8000-000000000003');
  if topic_attempt.user_id<>auth.uid() or topic_attempt.topic_id<>'32000000-0000-4000-8000-000000000003' or topic_attempt.total_questions<>10
    or (select count(*) from public.quiz_attempt_questions where attempt_id=topic_attempt.id)<>10
    or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id where item.attempt_id=topic_attempt.id)<>5 then
    raise exception 'Networking Topic Quiz failed after 8.7.5'; end if;
end; $$;
reset role;
select json_build_object('stage','8.7.5','lesson','public-vs-private-endpoints','published_blocks',11,'visuals_created',1,
  'flashcards_corrected',3,'flashcards_added',2,'questions_added',5,'history_preserved',true) as endpoint_validation;
rollback;

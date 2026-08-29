begin;
set local statement_timeout='30s';

create temporary table target_lessons on commit drop as
select lesson.id,lesson.slug,lesson.estimated_minutes,lesson.display_order
from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and domain.title='Describe Azure architecture and services'
  and topic.id='32000000-0000-4000-8000-000000000004' and topic.title='Storage Services'
  and lesson.slug in ('storage-accounts-and-services','blob-storage','azure-files','managed-disks');

do $$
declare duplicate_count integer;
begin
  if not exists(select 1 from supabase_migrations.schema_migrations where version='20260828010000') then raise exception '8.8.2 migration is not registered'; end if;
  if (select count(*) from target_lessons)<>4 or exists(select 1 from target_lessons target join public.lessons lesson on lesson.id=target.id
    where not lesson.is_published or lesson.content is null or btrim(lesson.content)=''
      or lesson.estimated_minutes<>case when lesson.slug='storage-accounts-and-services' then 12 else 10 end) then
    raise exception '8.8.2 Lesson inventory, publication, fallback or estimates are invalid'; end if;
  if (select sum(expected) from (select case slug when 'storage-accounts-and-services' then 10 else 7 end expected from target_lessons) counts)<>31
    or exists(select 1 from target_lessons target left join public.lesson_content_blocks block on block.lesson_id=target.id
      group by target.id,target.slug having count(block.id)<>case when target.slug='storage-accounts-and-services' then 10 else 7 end
        or min(block.display_order)<>1 or max(block.display_order)<>count(block.id) or count(distinct block.display_order)<>count(block.id)
        or count(*) filter(where block.is_published)<>count(block.id) or count(*) filter(where block.type='explanation')<1
        or count(*) filter(where block.type in('example','dotnet_example'))<1 or count(*) filter(where block.type='exam_tip')<>1
        or count(*) filter(where block.type='exam_trap')<>1 or count(*) filter(where block.type='summary')<>1) then
    raise exception '8.8.2 Content Blocks are invalid'; end if;
  if exists(select 1 from public.lesson_content_blocks summary join target_lessons target on target.id=summary.lesson_id
    where summary.type='summary' and (summary.display_order<>(select max(display_order) from public.lesson_content_blocks where lesson_id=summary.lesson_id)
      or jsonb_typeof(summary.config->'items')<>'array' or jsonb_array_length(summary.config->'items') not between 3 and 6)) then
    raise exception 'A Storage summary is invalid'; end if;
  if exists(select 1 from public.visual_experiences visual join target_lessons target on target.id=visual.lesson_id)
    or exists(select 1 from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id where block.type='visual_experience') then
    raise exception '8.8.2 must not contain a Visual Experience'; end if;
  if (select count(*) from public.flashcards card join target_lessons target on target.id=card.lesson_id where card.is_published)<>15
    or exists(select 1 from target_lessons target left join public.flashcards card on card.lesson_id=target.id and card.is_published
      group by target.id,target.slug having count(card.id)<>case target.slug when 'storage-accounts-and-services' then 5 when 'blob-storage' then 4 else 3 end)
    or exists(select 1 from public.flashcards card join target_lessons target on target.id=card.lesson_id
      where length(btrim(card.front_text))>220 or length(btrim(card.back_text))>500) then raise exception '8.8.2 Flashcards are invalid'; end if;
  if (select count(*) from public.flashcards where id between '72000000-0000-4000-8000-000000000036' and '72000000-0000-4000-8000-000000000050')<>15 then
    raise exception 'Historical Storage Flashcard UUIDs were not preserved'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g'))
    from public.flashcards card join target_lessons target on target.id=card.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '8.8.2 contains exact Flashcard duplicates'; end if;
  if (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.is_published)<>25
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.difficulty='easy')<>9
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.difficulty='medium')<>11
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.difficulty='hard')<>5 then
    raise exception '8.8.2 Question inventory or difficulty is invalid'; end if;
  if exists(select 1 from target_lessons target left join public.questions question on question.lesson_id=target.id and question.is_published
    group by target.id,target.slug having count(question.id)<>case when target.slug='azure-files' then 10 else 5 end
      or count(question.id) filter(where question.difficulty='easy')<>case when target.slug='azure-files' then 3 else 2 end
      or count(question.id) filter(where question.difficulty='medium')<>case when target.slug='azure-files' then 5 else 2 end
      or count(question.id) filter(where question.difficulty='hard')<>case when target.slug='azure-files' then 2 else 1 end) then
    raise exception 'A scoped Storage Lesson has an invalid Question distribution'; end if;
  if (select count(*) from public.questions where id between '63000000-0000-4000-8000-000000000101' and '63000000-0000-4000-8000-000000000110')<>10 then
    raise exception 'Historical Azure Files Question UUIDs were not preserved'; end if;
  if exists(select 1 from public.questions question join target_lessons target on target.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id where question.is_published group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1 or count(distinct lower(btrim(option.option_text)))<>4
      or min(length(btrim(question.explanation)))<40) then raise exception 'A Storage Question or its options are invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g'))
    from public.questions question join target_lessons target on target.id=question.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '8.8.2 contains exact Question duplicates'; end if;
  if exists(with artifacts as(
    select concat_ws(' ',block.title,block.content) text from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card join target_lessons target on target.id=card.lesson_id
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question join target_lessons target on target.id=question.lesson_id)
    select 1 from artifacts where text ~* '(storage account (é|=) (um )?(blob container|managed disk|único arquivo)|azure files (é|=) (um )?(blob storage|managed disk)|table storage (é|=) (um )?(sql|azure sql)|queue storage (é|=) (um )?service bus|managed disk (é|=) (um )?blob comum)') then
    raise exception 'A prohibited Storage misconception remains'; end if;
  if exists(select 1 from public.questions question join target_lessons target on target.id=question.lesson_id
    join public.question_options option on option.question_id=question.id
    where concat_ws(' ',question.question_text,question.explanation,option.option_text,option.explanation)
      ~* '(IOPS|throughput|lifecycle management|SAS token|access key|partition key design|premium block blob|premium file share|Azure File Sync|AzCopy|Storage Explorer|Data Box|Azure Migrate)') then
    raise exception '8.8.2 practice exceeds its intended scope'; end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id where attempt.id is null or question.id is null or option.id is null) then
    raise exception 'Study history contains an orphaned reference'; end if;
  if has_table_privilege('authenticated','public.questions','SELECT') or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE') or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') then
    raise exception 'Storage curriculum grants are invalid'; end if;
end; $$;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values('00000000-0000-0000-0000-000000000000','58000000-0000-4000-8000-000000000020','authenticated','authenticated','storage-882@example.invalid','',now(),' {"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now());
set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000020',true);
do $$ declare target record; lesson_attempt public.quiz_attempts; topic_attempt public.quiz_attempts;
begin
  for target in select id from target_lessons order by display_order loop
    select * into strict lesson_attempt from public.start_lesson_quiz(target.id);
    if lesson_attempt.total_questions<>5 or (select count(*) from public.quiz_attempt_questions where attempt_id=lesson_attempt.id)<>5 then
      raise exception 'Lesson Quiz failed for %',target.id; end if;
  end loop;
  select * into strict topic_attempt from public.start_topic_quiz('32000000-0000-4000-8000-000000000004');
  if topic_attempt.total_questions<>10 or (select count(*) from public.quiz_attempt_questions where attempt_id=topic_attempt.id)<>10
    or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id where item.attempt_id=topic_attempt.id)<>5 then
    raise exception 'Storage Topic Quiz failed after 8.8.2'; end if;
end; $$;
reset role;

select json_build_object('stage','8.8.2','lessons',4,'published_blocks',31,'visuals_created',0,'flashcards_corrected',15,
  'flashcards_added',0,'questions_corrected',10,'questions_added',15,'difficulty',json_build_object('easy',9,'medium',11,'hard',5),
  'history_preserved',true) as storage_accounts_services_validation;
rollback;

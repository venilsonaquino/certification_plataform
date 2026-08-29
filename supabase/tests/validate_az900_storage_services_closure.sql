begin;
set local statement_timeout='60s';

create temporary table target_lessons on commit drop as
select lesson.id,lesson.slug,lesson.display_order,lesson.estimated_minutes,domain.certification_id
from public.lessons lesson
join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id
join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and domain.title='Describe Azure architecture and services'
  and topic.id='32000000-0000-4000-8000-000000000004' and topic.title='Storage Services';

do $$
declare duplicate_count integer; architecture_config jsonb;
begin
  if not exists(select 1 from supabase_migrations.schema_migrations where version='20260828040000') then
    raise exception 'The final Storage content migration is not registered'; end if;
  if (select count(*) from target_lessons)<>8 or (select sum(estimated_minutes) from target_lessons)<>88
    or exists(select 1 from target_lessons target join public.lessons lesson on lesson.id=target.id
      where not lesson.is_published or nullif(btrim(lesson.content),'') is null
        or lesson.display_order<>case lesson.slug
          when 'storage-accounts-and-services' then 1 when 'blob-storage' then 2 when 'azure-files' then 3
          when 'managed-disks' then 4 when 'storage-tiers' then 5 when 'storage-redundancy-options' then 6
          when 'moving-files-to-azure' then 7 when 'azure-migrate-and-data-box' then 8 else -1 end
        or lesson.estimated_minutes<>case lesson.slug
          when 'storage-accounts-and-services' then 12 when 'blob-storage' then 10 when 'azure-files' then 10
          when 'managed-disks' then 10 when 'storage-tiers' then 12 when 'storage-redundancy-options' then 12
          when 'moving-files-to-azure' then 12 when 'azure-migrate-and-data-box' then 10 else -1 end) then
    raise exception 'Storage Lesson inventory, order, publication, fallback or estimates are invalid'; end if;

  if (select count(*) from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id)<>76
    or exists(select 1 from target_lessons target left join public.lesson_content_blocks block on block.lesson_id=target.id
      group by target.id,target.slug having count(block.id)<>case target.slug
        when 'storage-accounts-and-services' then 10 when 'blob-storage' then 7 when 'azure-files' then 7
        when 'managed-disks' then 7 when 'storage-tiers' then 11 when 'storage-redundancy-options' then 14
        when 'moving-files-to-azure' then 10 when 'azure-migrate-and-data-box' then 10 end
        or min(block.display_order)<>1 or max(block.display_order)<>count(block.id)
        or count(distinct block.display_order)<>count(block.id) or count(*) filter(where block.is_published)<>count(block.id)
        or count(*) filter(where block.type='explanation')<1
        or count(*) filter(where block.type in ('example','dotnet_example'))<1
        or count(*) filter(where block.type='exam_tip')<>1
        or count(*) filter(where block.type='exam_trap')<>1
        or count(*) filter(where block.type='summary')<>1) then
    raise exception 'A Storage Lesson has invalid Content Blocks'; end if;
  if exists(select 1 from public.lesson_content_blocks summary join target_lessons target on target.id=summary.lesson_id
    where summary.type='summary' and (summary.display_order<>(select max(block.display_order) from public.lesson_content_blocks block where block.lesson_id=summary.lesson_id)
      or jsonb_typeof(summary.config->'items') is distinct from 'array'
      or jsonb_array_length(summary.config->'items') not between 3 and 6)) then
    raise exception 'A Storage summary is not final or lacks 3-6 recall items'; end if;

  if (select count(*) from public.visual_experiences visual join target_lessons target on target.id=visual.lesson_id)<>1
    or not exists(select 1 from public.visual_experiences visual join target_lessons target on target.id=visual.lesson_id
      where visual.id='76000000-0000-4000-8000-000000000013' and target.slug='storage-redundancy-options'
        and visual.type='architecture' and visual.is_published) then
    raise exception 'Storage must preserve exactly the justified Redundancy visual'; end if;
  select visual.config into strict architecture_config from public.visual_experiences visual
    where visual.id='76000000-0000-4000-8000-000000000013';
  if jsonb_typeof(architecture_config->'nodes')<>'array' or jsonb_array_length(architecture_config->'nodes')<>15
    or jsonb_typeof(architecture_config->'edges')<>'array' or jsonb_array_length(architecture_config->'edges')<>11
    or exists(select 1 from jsonb_array_elements(architecture_config->'edges') edge
      where not exists(select 1 from jsonb_array_elements(architecture_config->'nodes') node where node->>'id'=edge->>'source')
         or not exists(select 1 from jsonb_array_elements(architecture_config->'nodes') node where node->>'id'=edge->>'target')) then
    raise exception 'Storage Redundancy visual config or edges are invalid'; end if;
  if (select count(*) from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id where block.type='visual_experience')<>1
    or exists(select 1 from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
      where block.type='visual_experience' and (block.visual_experience_id<>'76000000-0000-4000-8000-000000000013' or block.content is not null or block.config is not null)) then
    raise exception 'Storage visual Content Block is invalid'; end if;

  if (select count(*) from public.flashcards card join target_lessons target on target.id=card.lesson_id where card.is_published)<>40
    or exists(select 1 from target_lessons target left join public.flashcards card on card.lesson_id=target.id and card.is_published
      group by target.id,target.slug having count(card.id)<>case target.slug
        when 'storage-accounts-and-services' then 5 when 'blob-storage' then 4 when 'azure-files' then 3
        when 'managed-disks' then 3 when 'storage-tiers' then 6 when 'storage-redundancy-options' then 8
        when 'moving-files-to-azure' then 6 when 'azure-migrate-and-data-box' then 5 end)
    or exists(select 1 from public.flashcards card join target_lessons target on target.id=card.lesson_id
      where nullif(btrim(card.front_text),'') is null or nullif(btrim(card.back_text),'') is null
        or length(btrim(card.front_text))>220 or length(btrim(card.back_text))>500) then
    raise exception 'Storage Flashcard inventory or concision is invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g'))
    from public.flashcards card join target_lessons target on target.id=card.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception 'Storage contains exact normalized Flashcard duplicates'; end if;

  if (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.is_published)<>46
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.is_published and difficulty='easy')<>17
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.is_published and difficulty='medium')<>19
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.is_published and difficulty='hard')<>10 then
    raise exception 'Storage Question inventory or difficulty distribution is invalid'; end if;
  if exists(select 1 from target_lessons target left join public.questions question on question.lesson_id=target.id and question.is_published
    group by target.id,target.slug having count(question.id)<>case
      when target.slug='azure-files' then 10 when target.slug='storage-redundancy-options' then 6 else 5 end
      or count(question.id) filter(where question.difficulty='easy')<>case when target.slug='azure-files' then 3 else 2 end
      or count(question.id) filter(where question.difficulty='medium')<>case when target.slug='azure-files' then 5 else 2 end
      or count(question.id) filter(where question.difficulty='hard')<>case
        when target.slug in ('azure-files','storage-redundancy-options') then 2 else 1 end) then
    raise exception 'A Storage Lesson has an unexpected Question distribution'; end if;
  if exists(select 1 from public.questions question join target_lessons target on target.id=question.lesson_id
    join public.lessons lesson on lesson.id=question.lesson_id left join public.question_options option on option.question_id=question.id
    where question.is_published group by question.id,lesson.topic_id
    having question.topic_id<>lesson.topic_id or nullif(btrim(question.explanation),'') is null
      or length(btrim(question.explanation))<40 or count(option.id)<>4
      or count(option.id) filter(where option.is_correct)<>1 or count(distinct lower(btrim(option.option_text)))<>4) then
    raise exception 'A Storage Question, hierarchy or its options are invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g'))
    from public.questions question join target_lessons target on target.id=question.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception 'Storage contains exact normalized Question duplicates'; end if;

  if exists(with artifacts as(
    select concat_ws(' ',block.title,block.content) text from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
    union all select concat_ws(' ',card.back_text,card.hint) from public.flashcards card join target_lessons target on target.id=card.lesson_id
    union all select question.explanation from public.questions question join target_lessons target on target.id=question.lesson_id)
    select 1 from artifacts where text ~* '(Blob Storage (é|=) Azure Files|Azure Files (é|=) (um )?Managed Disk|Queue Storage (é|=) Azure Service Bus|Table Storage (é|=) (um )?SQL Database|Storage Account (é|=) (um )?Blob Container|Managed Disk (é|=).{0,20}Blob comum|Cold (é|=) Archive|Archive (é|=) (um )?backup|LRS (protege|oferece proteção).{0,20}(perda|falha) regional|ZRS (protege|oferece proteção).{0,20}(perda|falha) regional completa|GRS (é|=) RA-GRS|GZRS (é|=) RA-GZRS|geo-redundancy (significa|=).{0,20}failover automático|AzCopy (é|=) Azure File Sync|Storage Explorer (é|=).{0,20}sincronização|Azure Migrate (é|=) (Azure )?Data Box|Data Box (é|=).{0,20}assessment)') then
    raise exception 'A prohibited Storage misconception remains'; end if;
  if exists(with practice as(
    select concat_ws(' ',card.front_text,card.back_text,card.hint) text from public.flashcards card join target_lessons target on target.id=card.lesson_id
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question join target_lessons target on target.id=question.lesson_id)
    select 1 from practice where text ~* '(shared access signature|\bSAS\b|storage key|lifecycle rule|immutability|object replication|private endpoint|RBAC detalhad|encryption implementation|Data Lake analytics|\bIOPS\b|throughput|performance tuning|azcopy (copy|sync|login)|server endpoint|cloud endpoint|migration wave|replication appliance|capacidade.{0,20}Data Box)') then
    raise exception 'Storage practice requires content beyond AZ-900 scope'; end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.quiz_attempts attempt left join public.certifications certification on certification.id=attempt.certification_id
      left join public.lessons lesson on lesson.id=attempt.lesson_id left join public.topics topic on topic.id=attempt.topic_id
      where certification.id is null or (attempt.lesson_id is not null and lesson.id is null) or (attempt.topic_id is not null and topic.id is null))
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id where attempt.id is null or question.id is null or option.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null) then
    raise exception 'Study history contains an orphaned reference'; end if;
  if exists(select 1 from pg_class relation join pg_namespace namespace on namespace.oid=relation.relnamespace
    where namespace.nspname='public' and relation.relname in ('lessons','lesson_content_blocks','visual_experiences','flashcards','questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions','quiz_answers','flashcard_reviews','user_flashcard_progress')
      and not relation.relrowsecurity) then raise exception 'A required curriculum or study table has RLS disabled'; end if;
  if has_table_privilege('authenticated','public.questions','SELECT') or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lessons','UPDATE') or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE') or has_table_privilege('authenticated','public.visual_experiences','UPDATE')
    or not has_table_privilege('authenticated','public.lessons','SELECT') or not has_table_privilege('authenticated','public.flashcards','SELECT')
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') or not has_table_privilege('authenticated','public.visual_experiences','SELECT') then
    raise exception 'Storage curriculum grants are invalid'; end if;
  if not exists(select 1 from pg_proc where oid='public.start_lesson_progress(uuid)'::regprocedure)
    or not exists(select 1 from pg_proc where oid='public.complete_lesson_progress(uuid)'::regprocedure)
    or not exists(select 1 from pg_proc where oid='public.start_lesson_quiz(uuid)'::regprocedure)
    or not exists(select 1 from pg_proc where oid='public.start_topic_quiz(uuid)'::regprocedure)
    or not exists(select 1 from pg_proc where oid='public.start_review_quiz(uuid,uuid)'::regprocedure)
    or not exists(select 1 from pg_proc where oid='public.submit_quiz_answer(uuid,uuid,uuid)'::regprocedure)
    or not exists(select 1 from pg_proc where oid='public.submit_flashcard_review(uuid,text)'::regprocedure) then
    raise exception 'A required study, quiz, review or spaced-repetition function is missing'; end if;
end; $$;

create temporary table wrong_options(question_id uuid primary key,option_id uuid not null) on commit drop;
insert into wrong_options
select question.id,(array_agg(option.id order by option.display_order) filter(where not option.is_correct))[1]
from public.questions question join target_lessons target on target.id=question.lesson_id
join public.question_options option on option.question_id=question.id group by question.id;
grant select on wrong_options to authenticated;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select '00000000-0000-0000-0000-000000000000',seed.id,'authenticated','authenticated',seed.email,'',now(),
  '{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now()
from(values
  ('58000000-0000-4000-8000-000000000024'::uuid,'storage-closure-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000025'::uuid,'storage-closure-b@example.invalid'),
  ('58000000-0000-4000-8000-000000000026'::uuid,'storage-closure-c@example.invalid')) seed(id,email);

grant select on target_lessons to authenticated;
set local role authenticated;
do $$
declare seeded_user uuid; attempt public.quiz_attempts; first_attempt_id uuid;
begin
  foreach seeded_user in array array['58000000-0000-4000-8000-000000000024'::uuid,'58000000-0000-4000-8000-000000000025'::uuid,'58000000-0000-4000-8000-000000000026'::uuid]
  loop
    perform set_config('request.jwt.claim.sub',seeded_user::text,true);
    select * into strict attempt from public.start_topic_quiz('32000000-0000-4000-8000-000000000004');
    if attempt.total_questions<>10 or (select count(*) from public.quiz_attempt_questions where attempt_id=attempt.id)<>10
      or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id where item.attempt_id=attempt.id)<>8
      or exists(select 1 from target_lessons target where not exists(select 1 from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id where item.attempt_id=attempt.id and question.lesson_id=target.id))
      or exists(select 1 from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id where item.attempt_id=attempt.id group by question.lesson_id having count(*)>2) then
      raise exception 'Storage Topic Quiz is not balanced across all eight Lessons'; end if;
    if first_attempt_id is null then first_attempt_id:=attempt.id; end if;
  end loop;
  perform set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000025',true);
  if exists(select 1 from public.quiz_attempts where id=first_attempt_id) then raise exception 'Quiz history leaked across users'; end if;
end; $$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000024',true);
do $$
declare lesson_target record; attempt public.quiz_attempts; question_record record; started public.user_lesson_progress; completed public.user_lesson_progress; target_card_id uuid; review_attempt public.quiz_attempts; certification_id uuid;
begin
  for lesson_target in select id from target_lessons order by display_order loop
    select * into strict attempt from public.start_lesson_quiz(lesson_target.id);
    if attempt.total_questions<>5 or (select count(*) from public.quiz_attempt_questions where attempt_id=attempt.id)<>5 then
      raise exception 'Storage Lesson Quiz failed for %',lesson_target.id; end if;
    if lesson_target.id=(select id from target_lessons order by display_order limit 1) then
      for question_record in select item.question_id,wrong.option_id from public.quiz_attempt_questions item join wrong_options wrong on wrong.question_id=item.question_id where item.attempt_id=attempt.id order by item.display_order
      loop perform * from public.submit_quiz_answer(attempt.id,question_record.question_id,question_record.option_id); end loop;
    end if;
  end loop;
  select * into strict started from public.start_lesson_progress((select id from target_lessons order by display_order limit 1));
  select * into strict completed from public.complete_lesson_progress((select id from target_lessons order by display_order limit 1));
  if started.status<>'in_progress' or completed.status<>'completed' or completed.completed_at is null then raise exception 'Storage Lesson progress flow failed'; end if;
  select card.id into strict target_card_id from public.flashcards card join target_lessons target on target.id=card.lesson_id
    where card.is_published order by target.display_order,card.display_order limit 1;
  perform public.submit_flashcard_review(target_card_id,'good');
  if not exists(select 1 from public.flashcard_reviews where flashcard_id=target_card_id)
    or not exists(select 1 from public.user_flashcard_progress where flashcard_id=target_card_id) then raise exception 'Storage spaced repetition failed'; end if;
  select target.certification_id into strict certification_id from target_lessons target limit 1;
  select * into strict review_attempt from public.start_review_quiz(certification_id);
  if review_attempt.quiz_type<>'review' or review_attempt.total_questions<>5
    or (select count(*) from public.quiz_attempt_questions where attempt_id=review_attempt.id)<>5 then raise exception 'Storage error Review flow failed'; end if;
end; $$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000025',true);
do $$ begin
  if exists(select 1 from public.user_lesson_progress where user_id='58000000-0000-4000-8000-000000000024')
    or exists(select 1 from public.flashcard_reviews where user_id='58000000-0000-4000-8000-000000000024')
    or exists(select 1 from public.user_flashcard_progress where user_id='58000000-0000-4000-8000-000000000024') then
    raise exception 'Storage progress or review state leaked across users'; end if;
end; $$;
reset role;

select json_build_object('stage','8.8.6','topic','Azure Storage Services','status','CLOSED',
  'lessons',8,'estimated_minutes',88,'content_blocks',76,'visual_experiences',1,'flashcards',40,'questions',46,
  'difficulty',json_build_object('easy',17,'medium',19,'hard',10),'topic_quiz_lessons_per_attempt',8,
  'covered_atomic',14,'covered_aggregates',2,'partial',0,'missing',0,'history_preserved',true) as storage_services_closure_validation;
rollback;

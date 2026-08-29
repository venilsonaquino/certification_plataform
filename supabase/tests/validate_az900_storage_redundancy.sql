begin;
set local statement_timeout='30s';

create temporary table target_lesson on commit drop as
select lesson.id,lesson.slug,lesson.estimated_minutes
from public.lessons lesson
join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id
join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900'
  and domain.title='Describe Azure architecture and services'
  and topic.id='32000000-0000-4000-8000-000000000004'
  and lesson.slug='storage-redundancy-options';

do $$
declare architecture_config jsonb; duplicate_count integer;
begin
  if not exists(select 1 from supabase_migrations.schema_migrations where version='20260828030000') then
    raise exception '8.8.4 migration is not registered'; end if;
  if (select count(*) from target_lesson)<>1
    or exists(select 1 from target_lesson target join public.lessons lesson on lesson.id=target.id
      where not lesson.is_published or nullif(btrim(lesson.content),'') is null or lesson.estimated_minutes<>12) then
    raise exception 'Storage Redundancy Lesson publication, fallback or estimate is invalid'; end if;

  if (select array_agg(block.type order by block.display_order)
      from public.lesson_content_blocks block join target_lesson target on target.id=block.lesson_id where block.is_published)
    is distinct from array['explanation','explanation','explanation','explanation','explanation','explanation','explanation','visual_experience','important','important','example','exam_trap','exam_tip','summary']::text[] then
    raise exception 'Unexpected Storage Redundancy block sequence'; end if;
  if exists(select 1 from target_lesson target join public.lesson_content_blocks block on block.lesson_id=target.id group by target.id
    having count(*)<>14 or min(block.display_order)<>1 or max(block.display_order)<>14
      or count(distinct block.display_order)<>14 or count(*) filter(where block.is_published)<>14
      or count(*) filter(where block.type='exam_tip')<>1 or count(*) filter(where block.type='exam_trap')<>1
      or count(*) filter(where block.type='visual_experience' and block.visual_experience_id='76000000-0000-4000-8000-000000000013')<>1
      or count(*) filter(where block.type='summary' and jsonb_typeof(block.config->'items')='array'
        and jsonb_array_length(block.config->'items') between 3 and 6)<>1) then
    raise exception 'Storage Redundancy blocks, order, visual reference or summary are invalid'; end if;

  select visual.config into strict architecture_config
  from public.visual_experiences visual join target_lesson target on target.id=visual.lesson_id
  where visual.id='76000000-0000-4000-8000-000000000013'
    and visual.type='architecture' and visual.is_published and visual.display_order=1;
  if jsonb_typeof(architecture_config->'nodes')<>'array'
    or jsonb_array_length(architecture_config->'nodes')<>15
    or jsonb_typeof(architecture_config->'edges')<>'array'
    or jsonb_array_length(architecture_config->'edges')<>11 then
    raise exception 'Storage Redundancy architecture shape is invalid'; end if;
  if exists(select 1 from jsonb_array_elements(architecture_config->'edges') edge
    where not exists(select 1 from jsonb_array_elements(architecture_config->'nodes') node where node->>'id'=edge->>'source')
       or not exists(select 1 from jsonb_array_elements(architecture_config->'nodes') node where node->>'id'=edge->>'target')) then
    raise exception 'Storage Redundancy architecture has a dangling edge'; end if;
  if (select count(distinct node->>'id') from jsonb_array_elements(architecture_config->'nodes') node)<>15
    or not (architecture_config->'nodes') @> '[{"id":"ra-grs-read"},{"id":"ra-gzrs-read"},{"id":"gzrs-primary-zones"}]'::jsonb then
    raise exception 'Storage Redundancy architecture nodes are incomplete'; end if;

  if (select count(*) from public.flashcards card join target_lesson target on target.id=card.lesson_id where card.is_published)<>8
    or (select count(*) from public.flashcards where id in (
      '70000000-0000-4000-8000-000000000025','70000000-0000-4000-8000-000000000026','70000000-0000-4000-8000-000000000027'))<>3
    or (select count(*) from public.flashcards where id between '7e300000-0000-4000-8000-000000000007' and '7e300000-0000-4000-8000-000000000011')<>5 then
    raise exception 'Storage Redundancy Flashcards are incomplete or historical IDs were lost'; end if;
  select count(*) into duplicate_count from(
    select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g'))
    from public.flashcards card join target_lesson target on target.id=card.lesson_id group by 1 having count(*)>1
  ) duplicates;
  if duplicate_count<>0 then raise exception 'Storage Redundancy contains duplicate Flashcards'; end if;

  if (select count(*) from public.questions question join target_lesson target on target.id=question.lesson_id where question.is_published)<>6
    or (select count(*) from public.questions question join target_lesson target on target.id=question.lesson_id where difficulty='easy')<>2
    or (select count(*) from public.questions question join target_lesson target on target.id=question.lesson_id where difficulty='medium')<>2
    or (select count(*) from public.questions question join target_lesson target on target.id=question.lesson_id where difficulty='hard')<>2 then
    raise exception 'Storage Redundancy Question distribution is invalid'; end if;
  if not exists(select 1 from public.questions question join target_lesson target on target.id=question.lesson_id
      where question.id='60000000-0000-4000-8000-000000000009')
    or (select count(*) from public.question_options where id in (
      '70000000-0000-4000-8000-000000000033','70000000-0000-4000-8000-000000000034',
      '70000000-0000-4000-8000-000000000035','70000000-0000-4000-8000-000000000036'))<>4 then
    raise exception 'Historical Storage Redundancy Question or options were lost'; end if;
  if exists(select 1 from public.questions question join target_lesson target on target.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id where question.is_published group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception 'A Storage Redundancy Question or its options are invalid'; end if;

  if exists(with artifacts as(
    select concat_ws(' ',block.title,block.content) text from public.lesson_content_blocks block join target_lesson target on target.id=block.lesson_id
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card join target_lesson target on target.id=card.lesson_id
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question join target_lesson target on target.id=question.lesson_id)
    select 1 from artifacts where text ~* '(ZRS.{0,30}(outra|segunda) região|GRS.{0,30}(replica|replicação) síncr|GZRS.{0,30}(replica|replicação) síncr|RA-GRS.{0,30}escrita|RA-GZRS.{0,30}escrita|failover.{0,30}automátic)') then
    raise exception 'A prohibited redundancy misconception remains'; end if;
  if exists(select 1 from public.questions question join target_lesson target on target.id=question.lesson_id
    join public.question_options option on option.question_id=question.id
    where concat_ws(' ',question.question_text,question.explanation,option.option_text,option.explanation)
      ~* '(durabilidade de [0-9]|comando|passo a passo|AzCopy|Storage Explorer|File Sync|Data Box|Azure Migrate|lifecycle management)') then
    raise exception 'Storage Redundancy practice exceeds the 8.8.4 scope'; end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id where attempt.id is null or question.id is null or option.id is null) then
    raise exception 'Study history contains an orphaned reference'; end if;
  if has_table_privilege('authenticated','public.questions','SELECT')
    or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or has_table_privilege('authenticated','public.visual_experiences','UPDATE')
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT')
    or not has_table_privilege('authenticated','public.visual_experiences','SELECT') then
    raise exception 'Storage Redundancy curriculum grants are invalid'; end if;
end; $$;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values('00000000-0000-0000-0000-000000000000','58000000-0000-4000-8000-000000000022','authenticated','authenticated','storage-redundancy-884@example.invalid','',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now());
set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000022',true);
do $$ declare target_id uuid; lesson_attempt public.quiz_attempts; topic_attempt public.quiz_attempts;
begin
  select id into strict target_id from target_lesson;
  if (select count(*) from public.lesson_content_blocks where lesson_id=target_id)<>14
    or (select count(*) from public.visual_experiences where lesson_id=target_id)<>1 then
    raise exception 'Published Storage Redundancy content is not visible through RLS'; end if;
  select * into strict lesson_attempt from public.start_lesson_quiz(target_id);
  if lesson_attempt.total_questions<>5
    or (select count(*) from public.quiz_attempt_questions where attempt_id=lesson_attempt.id)<>5 then
    raise exception 'Storage Redundancy Lesson Quiz failed'; end if;
  select * into strict topic_attempt from public.start_topic_quiz('32000000-0000-4000-8000-000000000004');
  if topic_attempt.total_questions<>10
    or (select count(*) from public.quiz_attempt_questions where attempt_id=topic_attempt.id)<>10
    or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item
      join public.questions question on question.id=item.question_id where item.attempt_id=topic_attempt.id)<>6 then
    raise exception 'Storage Topic Quiz failed after 8.8.4'; end if;
end; $$;
reset role;

select json_build_object('stage','8.8.4','lesson','storage-redundancy-options','published_blocks',14,
  'visuals_created',1,'flashcards_total',8,'flashcards_added',5,'questions_total',6,'questions_added',5,
  'difficulty',json_build_object('easy',2,'medium',2,'hard',2),'history_preserved',true) as storage_redundancy_validation;
rollback;

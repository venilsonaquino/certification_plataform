begin;
set local statement_timeout='30s';

create temporary table target_lessons on commit drop as
select lesson.id,lesson.slug,lesson.estimated_minutes
from public.lessons lesson
join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id
join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and domain.title='Describe Azure architecture and services'
  and topic.id='32000000-0000-4000-8000-000000000004'
  and lesson.slug in ('moving-files-to-azure','azure-migrate-and-data-box');

do $$
declare duplicate_count integer;
begin
  if not exists(select 1 from supabase_migrations.schema_migrations where version='20260828040000') then
    raise exception '8.8.5 migration is not registered'; end if;
  if (select count(*) from target_lessons)<>2
    or exists(select 1 from target_lessons target join public.lessons lesson on lesson.id=target.id
      where not lesson.is_published or nullif(btrim(lesson.content),'') is null
        or (lesson.slug='moving-files-to-azure' and lesson.estimated_minutes<>12)
        or (lesson.slug='azure-migrate-and-data-box' and lesson.estimated_minutes<>10)) then
    raise exception '8.8.5 Lesson identity, fallback, publication or estimate is invalid'; end if;

  if (select array_agg(block.type order by block.display_order) from public.lesson_content_blocks block
      join target_lessons target on target.id=block.lesson_id where target.slug='moving-files-to-azure' and block.is_published)
    is distinct from array['explanation','explanation','explanation','explanation','important','important','example','exam_trap','exam_tip','summary']::text[] then
    raise exception 'Unexpected File Movement block sequence'; end if;
  if (select array_agg(block.type order by block.display_order) from public.lesson_content_blocks block
      join target_lessons target on target.id=block.lesson_id where target.slug='azure-migrate-and-data-box' and block.is_published)
    is distinct from array['explanation','explanation','explanation','important','explanation','important','example','exam_trap','exam_tip','summary']::text[] then
    raise exception 'Unexpected Migration block sequence'; end if;
  if exists(select 1 from target_lessons target join public.lesson_content_blocks block on block.lesson_id=target.id group by target.id
    having count(*)<>10 or min(block.display_order)<>1 or max(block.display_order)<>10
      or count(distinct block.display_order)<>10 or count(*) filter(where block.is_published)<>10
      or count(*) filter(where block.type='exam_tip')<>1 or count(*) filter(where block.type='exam_trap')<>1
      or count(*) filter(where block.type='summary' and jsonb_typeof(block.config->'items')='array'
        and jsonb_array_length(block.config->'items') between 3 and 6)<>1) then
    raise exception '8.8.5 blocks, order, publication or summary are invalid'; end if;
  if exists(select 1 from public.visual_experiences visual join target_lessons target on target.id=visual.lesson_id)
    or exists(select 1 from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id where block.type='visual_experience') then
    raise exception '8.8.5 must not create a Visual Experience'; end if;

  if (select count(*) from public.flashcards card join target_lessons target on target.id=card.lesson_id
      where target.slug='moving-files-to-azure' and card.is_published)<>6
    or (select count(*) from public.flashcards card join target_lessons target on target.id=card.lesson_id
      where target.slug='azure-migrate-and-data-box' and card.is_published)<>5 then
    raise exception '8.8.5 Flashcard distribution is invalid'; end if;
  select count(*) into duplicate_count from(
    select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g'))
    from public.flashcards card join target_lessons target on target.id=card.lesson_id group by 1 having count(*)>1
  ) duplicates;
  if duplicate_count<>0 then raise exception '8.8.5 contains duplicate Flashcards'; end if;

  if exists(select 1 from target_lessons target left join public.questions question on question.lesson_id=target.id and question.is_published
    group by target.id having count(question.id)<>5 or count(question.id) filter(where question.difficulty='easy')<>2
      or count(question.id) filter(where question.difficulty='medium')<>2
      or count(question.id) filter(where question.difficulty='hard')<>1) then
    raise exception '8.8.5 Question distribution is invalid'; end if;
  if exists(select 1 from public.questions question join target_lessons target on target.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id where question.is_published group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception 'An 8.8.5 Question or its options are invalid'; end if;
  select count(*) into duplicate_count from(
    select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g'))
    from public.questions question join target_lessons target on target.id=question.lesson_id group by 1 having count(*)>1
  ) duplicates;
  if duplicate_count<>0 then raise exception '8.8.5 contains duplicate Questions'; end if;

  if exists(with artifacts as(
    select concat_ws(' ',block.title,block.content) text from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card join target_lessons target on target.id=card.lesson_id
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question join target_lessons target on target.id=question.lesson_id)
    select 1 from artifacts where text ~* '(Storage Explorer (é|=).{0,20}(linha de comando|CLI)|File Sync (é|=).{0,20}(cópia pontual|dispositivo físico)|Data Box (é|=).{0,20}(assessment|análise de arquitetura)|Azure Migrate (é|=).{0,20}dispositivo físico)') then
    raise exception 'A prohibited File Movement or Migration misconception remains'; end if;
  if exists(select 1 from public.questions question join target_lessons target on target.id=question.lesson_id
    join public.question_options option on option.question_id=question.id
    where concat_ws(' ',question.question_text,question.explanation,option.option_text,option.explanation)
      ~* '(azcopy (copy|sync|login)|server endpoint|cloud endpoint|Storage Sync Service|migration wave|dependency visualization|replication appliance|[0-9]+ TB de capacidade)') then
    raise exception '8.8.5 practice exceeds the Fundamentals scope'; end if;
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
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') then
    raise exception '8.8.5 curriculum grants are invalid'; end if;
end; $$;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values('00000000-0000-0000-0000-000000000000','58000000-0000-4000-8000-000000000023','authenticated','authenticated','storage-movement-885@example.invalid','',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now());
set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000023',true);
do $$ declare target record; lesson_attempt public.quiz_attempts; topic_attempt public.quiz_attempts;
begin
  for target in select * from target_lessons loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=target.id)<>10 then
      raise exception 'Published blocks are not visible through RLS for %',target.slug; end if;
    select * into strict lesson_attempt from public.start_lesson_quiz(target.id);
    if lesson_attempt.total_questions<>5
      or (select count(*) from public.quiz_attempt_questions where attempt_id=lesson_attempt.id)<>5 then
      raise exception 'Lesson Quiz failed for %',target.slug; end if;
  end loop;
  select * into strict topic_attempt from public.start_topic_quiz('32000000-0000-4000-8000-000000000004');
  if topic_attempt.total_questions<>10
    or (select count(*) from public.quiz_attempt_questions where attempt_id=topic_attempt.id)<>10
    or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item
      join public.questions question on question.id=item.question_id where item.attempt_id=topic_attempt.id)<>8 then
    raise exception 'Storage Topic Quiz failed after 8.8.5'; end if;
end; $$;
reset role;

select json_build_object('stage','8.8.5','lessons',2,'published_blocks',20,'visuals_created',0,
  'flashcards_added',11,'questions_added',10,'options_added',40,
  'difficulty',json_build_object('easy',4,'medium',4,'hard',2),'history_preserved',true) as file_movement_migration_validation;
rollback;

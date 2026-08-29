begin;

do $$ begin
  if exists(select 1 from auth.users where id='58000000-0000-4000-8000-000000000034') then
    raise exception '9.5.3 temporary validation user already exists'; end if;
end; $$;

create temporary table target_lessons on commit drop as
select lesson.id,lesson.slug,lesson.display_order,lesson.estimated_minutes
from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and domain.title='Describe Azure management and governance'
  and topic.id='33000000-0000-4000-8000-000000000002' and topic.title='Governance and Compliance';

do $$
declare lesson_row record; combined_text text;
begin
  if (select count(*) from target_lessons)<>3 then raise exception '9.5.3 Topic Lesson inventory is invalid'; end if;
  if exists(select 1 from target_lessons target join public.lessons lesson on lesson.id=target.id
    where not lesson.is_published or lesson.content is null or btrim(lesson.content)=''
      or lesson.estimated_minutes<>(case lesson.slug when 'microsoft-purview' then 12 when 'azure-policy' then 12 else 10 end)) then
    raise exception '9.5.3 publication, fallback or estimates are invalid'; end if;
  if exists(select 1 from public.visual_experiences visual join target_lessons target on target.id=visual.lesson_id) then
    raise exception '9.5.3 must not contain Visual Experiences'; end if;
  for lesson_row in select * from target_lessons loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and is_published)
        <>(case lesson_row.slug when 'microsoft-purview' then 13 else 12 end)
      or (select min(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)<>1
      or (select max(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)
        <>(case lesson_row.slug when 'microsoft-purview' then 13 else 12 end)
      or (select count(distinct display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)
        <>(case lesson_row.slug when 'microsoft-purview' then 13 else 12 end)
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='summary')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='exam_tip')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='exam_trap')<2
      or (select count(*) from public.flashcards where lesson_id=lesson_row.id and is_published)
        <>(case lesson_row.slug when 'microsoft-purview' then 7 else 6 end)
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)<>5
      or (select count(*) from public.questions where lesson_id=lesson_row.id and difficulty='easy')<>2
      or (select count(*) from public.questions where lesson_id=lesson_row.id and difficulty='medium')<>2
      or (select count(*) from public.questions where lesson_id=lesson_row.id and difficulty='hard')<>1 then
      raise exception '9.5.3 artifact inventory is invalid for %',lesson_row.slug; end if;
  end loop;
  if exists(select 1 from public.questions question join target_lessons target on target.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4) then
    raise exception '9.5.3 Question Options are invalid'; end if;
  select string_agg(text,' ') into combined_text from(
    select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card join target_lessons target on target.id=card.lesson_id
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question join target_lessons target on target.id=question.lesson_id) artifacts;
  if combined_text !~* 'Policy definition' or combined_text !~* 'assignment' or combined_text !~* 'scope'
    or combined_text !~* 'compliance' or combined_text !~* 'Audit' or combined_text !~* 'Deny'
    or combined_text !~* 'CanNotDelete' or combined_text !~* 'ReadOnly' or combined_text !~* 'Owner'
    or combined_text !~* 'backup' or combined_text !~* 'Conditional Access' or combined_text !~* 'Microsoft Purview' then
    raise exception '9.5.3 required concepts are missing'; end if;
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null) then raise exception 'Study history contains an orphan'; end if;
  if exists(select 1 from pg_class relation join pg_namespace namespace on namespace.oid=relation.relnamespace
    where namespace.nspname='public' and relation.relname in('lessons','lesson_content_blocks','visual_experiences','flashcards','questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions','quiz_answers','flashcard_reviews','user_flashcard_progress')
      and not relation.relrowsecurity) then raise exception '9.5.3 requires RLS'; end if;
  if has_table_privilege('authenticated','public.questions','SELECT') or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lessons','UPDATE') or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or not has_table_privilege('authenticated','public.lessons','SELECT') or not has_table_privilege('authenticated','public.flashcards','SELECT')
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') then raise exception '9.5.3 grants are invalid'; end if;
end; $$;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values('00000000-0000-0000-0000-000000000000','58000000-0000-4000-8000-000000000034','authenticated','authenticated',
  'governance-953@example.invalid','',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now());
grant select on target_lessons to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000034',true);
do $$
declare lesson_row record; attempt public.quiz_attempts; topic_attempt public.quiz_attempts; started public.user_lesson_progress;
  completed public.user_lesson_progress; card_id uuid;
begin
  for lesson_row in select * from target_lessons where slug in('azure-policy','resource-locks') order by display_order loop
    select * into strict attempt from public.start_lesson_quiz(lesson_row.id);
    if attempt.total_questions<>5 or (select count(*) from public.quiz_attempt_questions where attempt_id=attempt.id)<>5 then
      raise exception '9.5.3 Lesson Quiz failed for %',lesson_row.slug; end if;
  end loop;
  select * into strict topic_attempt from public.start_topic_quiz('33000000-0000-4000-8000-000000000002');
  if topic_attempt.total_questions<>10 or (select count(*) from public.quiz_attempt_questions where attempt_id=topic_attempt.id)<>10
    or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id
      where item.attempt_id=topic_attempt.id)<>3
    or exists(select 1 from target_lessons target where not exists(select 1 from public.quiz_attempt_questions item
      join public.questions question on question.id=item.question_id where item.attempt_id=topic_attempt.id and question.lesson_id=target.id)) then
    raise exception '9.5.3 Topic Quiz failed'; end if;
  select * into strict started from public.start_lesson_progress((select id from target_lessons where slug='azure-policy'));
  select * into strict completed from public.complete_lesson_progress((select id from target_lessons where slug='azure-policy'));
  if started.status<>'in_progress' or completed.status<>'completed' then raise exception '9.5.3 progress failed'; end if;
  select card.id into strict card_id from public.flashcards card join target_lessons target on target.id=card.lesson_id order by target.display_order,card.display_order limit 1;
  perform public.submit_flashcard_review(card_id,'good');
  if not exists(select 1 from public.flashcard_reviews where flashcard_id=card_id)
    or not exists(select 1 from public.user_flashcard_progress where flashcard_id=card_id) then raise exception '9.5.3 repetition failed'; end if;
end; $$;
reset role; set local role postgres;
delete from public.quiz_answers where attempt_id in(select id from public.quiz_attempts where user_id='58000000-0000-4000-8000-000000000034');
delete from public.quiz_attempt_questions where attempt_id in(select id from public.quiz_attempts where user_id='58000000-0000-4000-8000-000000000034');
delete from public.quiz_attempts where user_id='58000000-0000-4000-8000-000000000034';
delete from public.flashcard_reviews where user_id='58000000-0000-4000-8000-000000000034';
delete from public.user_flashcard_progress where user_id='58000000-0000-4000-8000-000000000034';
delete from public.user_lesson_progress where user_id='58000000-0000-4000-8000-000000000034';
delete from auth.users where id='58000000-0000-4000-8000-000000000034';
do $$ begin
  if exists(select 1 from auth.users where id='58000000-0000-4000-8000-000000000034')
    or exists(select 1 from public.quiz_attempts where user_id='58000000-0000-4000-8000-000000000034')
    or exists(select 1 from public.user_lesson_progress where user_id='58000000-0000-4000-8000-000000000034') then
    raise exception '9.5.3 cleanup failed'; end if;
end; $$;
set role postgres;
commit;

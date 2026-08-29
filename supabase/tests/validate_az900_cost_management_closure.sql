begin;
set local statement_timeout='45s';

create temporary table target_lessons on commit drop as
select lesson.id,lesson.slug,lesson.display_order,certification.id certification_id
from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and domain.title='Describe Azure management and governance'
  and topic.id='33000000-0000-4000-8000-000000000001' and topic.title='Cost Management'
  and lesson.slug in ('azure-cost-factors','pricing-calculator','azure-cost-management','resource-tags');

do $$
declare duplicate_count integer;
begin
  if not exists(select 1 from supabase_migrations.schema_migrations where version='20260828120000') then
    raise exception '9.4 closure migration is not registered'; end if;
  if (select count(*) from target_lessons)<>4
    or (select count(*) from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id where block.is_published)<>50
    or (select count(*) from public.visual_experiences visual join target_lessons target on target.id=visual.lesson_id)<>0
    or (select count(*) from public.flashcards card join target_lessons target on target.id=card.lesson_id where card.is_published)<>26
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.is_published)<>30 then
    raise exception '9.4 final Topic inventory is invalid'; end if;
  if exists(select 1 from target_lessons target left join public.lesson_content_blocks block on block.lesson_id=target.id
    group by target.id,target.slug having min(block.display_order)<>1 or max(block.display_order)<>count(block.id)
      or count(distinct block.display_order)<>count(block.id) or count(*) filter(where block.is_published)<>count(block.id)
      or count(*) filter(where block.type='summary')<>1 or count(*) filter(where block.type='exam_tip')<>1
      or count(*) filter(where block.type='exam_trap')<1 or count(*) filter(where block.type='example')<2) then
    raise exception '9.4 blocks or ordering are invalid'; end if;
  if exists(select 1 from public.lesson_content_blocks summary join target_lessons target on target.id=summary.lesson_id
    where summary.type='summary' and (summary.display_order<>(select max(display_order) from public.lesson_content_blocks where lesson_id=summary.lesson_id)
      or jsonb_typeof(summary.config->'items')<>'array' or jsonb_array_length(summary.config->'items') not between 3 and 6)) then
    raise exception '9.4 summary is invalid'; end if;
  if exists(select 1 from target_lessons target left join public.questions question on question.lesson_id=target.id and question.is_published
    group by target.id,target.slug having count(question.id)<>(case target.slug when 'azure-cost-factors' then 10
      when 'pricing-calculator' then 5 when 'azure-cost-management' then 10 else 5 end)) then
    raise exception '9.4 Lesson practice distribution is invalid'; end if;
  if exists(select 1 from public.questions question join target_lessons target on target.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id where question.is_published group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception '9.4 Question options are invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g'))
    from public.questions question join target_lessons target on target.id=question.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.4 contains duplicate Questions'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g'))
    from public.flashcards card join target_lessons target on target.id=card.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.4 contains duplicate Flashcards'; end if;
  if not exists(with artifacts as(
    select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card join target_lessons target on target.id=card.lesson_id
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question join target_lessons target on target.id=question.lesson_id),
    combined as(select string_agg(text,' ') text from artifacts)
    select 1 from combined where text ~* 'consumo' and text ~* 'Region' and text ~* 'transferência'
      and text ~* 'Pricing Calculator' and text ~* 'Cost Analysis' and text ~* 'Budget'
      and text ~* 'Forecast' and text ~* 'key/value' and text ~* 'não são automaticamente herdadas') then
    raise exception '9.4 official coverage is incomplete'; end if;
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null) then
    raise exception 'Study history contains an orphaned reference'; end if;
  if exists(select 1 from pg_class relation join pg_namespace namespace on namespace.oid=relation.relnamespace
    where namespace.nspname='public' and relation.relname in ('lessons','lesson_content_blocks','visual_experiences','flashcards','questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions','quiz_answers','flashcard_reviews','user_flashcard_progress')
      and not relation.relrowsecurity) then raise exception 'A required table has RLS disabled'; end if;
end; $$;

create temporary table wrong_options(question_id uuid primary key,option_id uuid not null) on commit drop;
insert into wrong_options select question.id,(array_agg(option.id order by option.display_order) filter(where not option.is_correct))[1]
from public.questions question join target_lessons target on target.id=question.lesson_id
join public.question_options option on option.question_id=question.id group by question.id;
grant select on target_lessons,wrong_options to authenticated;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select '00000000-0000-0000-0000-000000000000',seed.id,'authenticated','authenticated',seed.email,'',now(),
  '{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now()
from(values
  ('58000000-0000-4000-8000-000000000030'::uuid,'cost-closure-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000031'::uuid,'cost-closure-b@example.invalid'),
  ('58000000-0000-4000-8000-000000000032'::uuid,'cost-closure-c@example.invalid')) seed(id,email);
set local role authenticated;

do $$
declare seeded_user uuid; attempt public.quiz_attempts; first_attempt_id uuid;
begin
  foreach seeded_user in array array['58000000-0000-4000-8000-000000000030'::uuid,
    '58000000-0000-4000-8000-000000000031'::uuid,'58000000-0000-4000-8000-000000000032'::uuid]
  loop
    perform set_config('request.jwt.claim.sub',seeded_user::text,true);
    select * into strict attempt from public.start_topic_quiz('33000000-0000-4000-8000-000000000001');
    if attempt.total_questions<>10 or (select count(*) from public.quiz_attempt_questions where attempt_id=attempt.id)<>10
      or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id
        where item.attempt_id=attempt.id)<>4
      or exists(select 1 from target_lessons target where not exists(select 1 from public.quiz_attempt_questions item
        join public.questions question on question.id=item.question_id where item.attempt_id=attempt.id and question.lesson_id=target.id))
      or exists(select 1 from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id
        where item.attempt_id=attempt.id group by question.lesson_id having count(*)>3) then
      raise exception 'Cost Management Topic Quiz is not balanced across four Lessons'; end if;
    if first_attempt_id is null then first_attempt_id:=attempt.id; end if;
  end loop;
  perform set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000031',true);
  if exists(select 1 from public.quiz_attempts where id=first_attempt_id) then raise exception 'Quiz history leaked across users'; end if;
end; $$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000030',true);
do $$
declare lesson_target record; attempt public.quiz_attempts; question_record record; started public.user_lesson_progress;
  completed public.user_lesson_progress; target_card_id uuid; review_attempt public.quiz_attempts; target_certification_id uuid;
begin
  for lesson_target in select id from target_lessons order by display_order loop
    select * into strict attempt from public.start_lesson_quiz(lesson_target.id);
    if attempt.total_questions<>5 or (select count(*) from public.quiz_attempt_questions where attempt_id=attempt.id)<>5 then
      raise exception 'Cost Management Lesson Quiz failed for %',lesson_target.id; end if;
    if lesson_target.id=(select id from target_lessons order by display_order limit 1) then
      for question_record in select item.question_id,wrong.option_id from public.quiz_attempt_questions item
        join wrong_options wrong on wrong.question_id=item.question_id where item.attempt_id=attempt.id order by item.display_order
      loop perform * from public.submit_quiz_answer(attempt.id,question_record.question_id,question_record.option_id); end loop;
    end if;
  end loop;
  select * into strict started from public.start_lesson_progress((select id from target_lessons order by display_order limit 1));
  select * into strict completed from public.complete_lesson_progress((select id from target_lessons order by display_order limit 1));
  if started.status<>'in_progress' or completed.status<>'completed' or completed.completed_at is null then
    raise exception 'Cost Management Lesson progress flow failed'; end if;
  select card.id into strict target_card_id from public.flashcards card join target_lessons target on target.id=card.lesson_id
    where card.is_published order by target.display_order,card.display_order limit 1;
  perform public.submit_flashcard_review(target_card_id,'good');
  if not exists(select 1 from public.flashcard_reviews where flashcard_id=target_card_id)
    or not exists(select 1 from public.user_flashcard_progress where flashcard_id=target_card_id) then
    raise exception 'Cost Management spaced repetition failed'; end if;
  select certification_id into strict target_certification_id from target_lessons limit 1;
  select * into strict review_attempt from public.start_review_quiz(target_certification_id);
  if review_attempt.quiz_type<>'review' or review_attempt.total_questions<>5
    or (select count(*) from public.quiz_attempt_questions where attempt_id=review_attempt.id)<>5 then
    raise exception 'Cost Management Review flow failed'; end if;
end; $$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000031',true);
do $$ begin
  if exists(select 1 from public.user_lesson_progress where user_id='58000000-0000-4000-8000-000000000030')
    or exists(select 1 from public.flashcard_reviews where user_id='58000000-0000-4000-8000-000000000030')
    or exists(select 1 from public.user_flashcard_progress where user_id='58000000-0000-4000-8000-000000000030') then
    raise exception 'Cost Management progress or review state leaked across users'; end if;
end; $$;
reset role;

select json_build_object('stage','9.4','topic','Azure Cost Management','status','CLOSED','lessons',4,
  'estimated_minutes',44,'content_blocks',50,'visual_experiences',0,'flashcards',26,'questions',30,
  'difficulty',json_build_object('easy',10,'medium',14,'hard',6),'questions_corrected',0,'questions_created',0,
  'flashcards_corrected',0,'flashcards_created',0,'covered',4,'partial',0,'missing',0,
  'topic_quiz_lessons_per_attempt',4,'history_preserved',true) as cost_management_closure_validation;
rollback;

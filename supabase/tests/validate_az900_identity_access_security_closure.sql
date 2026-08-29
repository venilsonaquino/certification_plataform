begin;
set local statement_timeout='45s';

create temporary table target_lessons on commit drop as
select lesson.id,lesson.slug,lesson.estimated_minutes,lesson.display_order,domain.certification_id
from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and domain.title='Describe Azure architecture and services'
  and topic.id='32000000-0000-4000-8000-000000000005' and topic.title='Identity, Access and Security';

do $$
declare duplicate_count integer;
begin
  if not exists(select 1 from supabase_migrations.schema_migrations where version='20260828090000') then
    raise exception '8.9.6 closure migration is not registered'; end if;
  if (select count(*) from target_lessons)<>9
    or exists(select 1 from target_lessons target join public.lessons lesson on lesson.id=target.id
      where not lesson.is_published or lesson.content is null or btrim(lesson.content)='')
    or (select sum(estimated_minutes) from target_lessons)<>100 then
    raise exception 'Identity Lesson publication, fallback or estimate inventory is invalid'; end if;
  if (select count(*) from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id)<>105
    or exists(select 1 from target_lessons target left join public.lesson_content_blocks block on block.lesson_id=target.id
      group by target.id,target.slug having count(block.id)<>case target.slug
        when 'entra-id-and-domain-services' then 15 when 'authentication-vs-authorization' then 8
        when 'single-sign-on' then 8 when 'mfa-and-passwordless' then 13 when 'external-identities' then 10
        when 'conditional-access' then 11 when 'azure-rbac' then 14
        when 'zero-trust-and-defense-in-depth' then 15 when 'defender-for-cloud' then 11 end
        or min(block.display_order)<>1 or max(block.display_order)<>count(block.id)
        or count(distinct block.display_order)<>count(block.id) or count(*) filter(where block.is_published)<>count(block.id)
        or count(*) filter(where block.type='explanation')<1 or count(*) filter(where block.type='important')<1
        or count(*) filter(where block.type='example')<1 or count(*) filter(where block.type='exam_tip')<>1
        or count(*) filter(where block.type='exam_trap')<1 or count(*) filter(where block.type='summary')<>1) then
    raise exception 'An Identity Lesson has invalid Content Blocks'; end if;
  if exists(select 1 from public.lesson_content_blocks summary join target_lessons target on target.id=summary.lesson_id
    where summary.type='summary' and (summary.display_order<>(select max(display_order) from public.lesson_content_blocks where lesson_id=summary.lesson_id)
      or jsonb_typeof(summary.config->'items') is distinct from 'array'
      or jsonb_array_length(summary.config->'items') not between 3 and 6)) then
    raise exception 'An Identity summary is invalid'; end if;
  if (select count(*) from public.visual_experiences visual join target_lessons target on target.id=visual.lesson_id)<>3
    or (select count(*) from public.visual_experiences visual join target_lessons target on target.id=visual.lesson_id
      where visual.is_published and ((visual.id='76000000-0000-4000-8000-000000000003' and target.slug='entra-id-and-domain-services' and visual.type='flow')
        or (visual.id='76000000-0000-4000-8000-000000000014' and target.slug='azure-rbac' and visual.type='architecture')
        or (visual.id='76000000-0000-4000-8000-000000000015' and target.slug='zero-trust-and-defense-in-depth' and visual.type='architecture')))<>3
    or exists(select 1 from public.visual_experiences visual join target_lessons target on target.id=visual.lesson_id
      where jsonb_typeof(visual.config)<>'object') then
    raise exception 'Identity Visual Experience inventory is invalid'; end if;
  if (select count(*) from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
    where block.type='visual_experience')<>3 then raise exception 'Identity visual block links are invalid'; end if;
  if (select count(*) from public.flashcards card join target_lessons target on target.id=card.lesson_id where card.is_published)<>49
    or exists(select 1 from target_lessons target left join public.flashcards card on card.lesson_id=target.id and card.is_published
      group by target.id,target.slug having count(card.id)<>case target.slug
        when 'entra-id-and-domain-services' then 7 when 'authentication-vs-authorization' then 3
        when 'single-sign-on' then 4 when 'mfa-and-passwordless' then 7 when 'external-identities' then 5
        when 'conditional-access' then 5 when 'azure-rbac' then 6
        when 'zero-trust-and-defense-in-depth' then 7 when 'defender-for-cloud' then 5 end)
    or exists(select 1 from public.flashcards card join target_lessons target on target.id=card.lesson_id
      where nullif(btrim(card.front_text),'') is null or nullif(btrim(card.back_text),'') is null
        or length(btrim(card.front_text))>220 or length(btrim(card.back_text))>500) then
    raise exception 'Identity Flashcard inventory or concision is invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g'))
    from public.flashcards card join target_lessons target on target.id=card.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception 'Identity contains exact normalized Flashcard duplicates'; end if;
  if (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.is_published)<>50
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.is_published and difficulty='easy')<>19
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.is_published and difficulty='medium')<>21
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.is_published and difficulty='hard')<>10 then
    raise exception 'Identity Question inventory or difficulty distribution is invalid'; end if;
  if exists(select 1 from target_lessons target left join public.questions question on question.lesson_id=target.id and question.is_published
    group by target.id,target.slug having count(question.id)<>case when target.slug='authentication-vs-authorization' then 10 else 5 end
      or count(question.id) filter(where question.difficulty='easy')<>case when target.slug='authentication-vs-authorization' then 3 else 2 end
      or count(question.id) filter(where question.difficulty='medium')<>case when target.slug='authentication-vs-authorization' then 5 else 2 end
      or count(question.id) filter(where question.difficulty='hard')<>case when target.slug='authentication-vs-authorization' then 2 else 1 end) then
    raise exception 'An Identity Lesson has unexpected Question distribution'; end if;
  if exists(select 1 from public.questions question join target_lessons target on target.id=question.lesson_id
    join public.lessons lesson on lesson.id=question.lesson_id left join public.question_options option on option.question_id=question.id
    where question.is_published group by question.id,lesson.topic_id
    having question.topic_id<>lesson.topic_id or nullif(btrim(question.explanation),'') is null
      or length(btrim(question.explanation))<40 or count(option.id)<>4
      or count(option.id) filter(where option.is_correct)<>1 or count(distinct lower(btrim(option.option_text)))<>4) then
    raise exception 'An Identity Question, hierarchy or its options are invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g'))
    from public.questions question join target_lessons target on target.id=question.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception 'Identity contains exact normalized Question duplicates'; end if;
  if (select count(*) from public.questions where id between '63000000-0000-4000-8000-000000000011' and '63000000-0000-4000-8000-000000000020')<>10
    or (select count(*) from public.question_options where question_id between '63000000-0000-4000-8000-000000000011' and '63000000-0000-4000-8000-000000000020')<>40 then
    raise exception 'Historical Authentication Question UUIDs are not preserved'; end if;
  if not exists(with artifacts as(
    select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card join target_lessons target on target.id=card.lesson_id
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question join target_lessons target on target.id=question.lesson_id),
    combined as(select string_agg(text,' ') text from artifacts)
    select 1 from combined where text ~* 'Entra ID' and text ~* 'Domain Services' and text ~* 'LDAP' and text ~* 'Kerberos'
      and text ~* 'authentication' and text ~* 'authorization' and text ~* 'Single Sign-On' and text ~* 'MFA'
      and text ~* 'passwordless' and text ~* 'External Identities' and text ~* 'Conditional Access'
      and text ~* 'role assignment' and text ~* 'Zero Trust' and text ~* 'Defense in Depth'
      and text ~* 'security posture' and text ~* 'workload protection') then
    raise exception 'Identity objective evidence is incomplete'; end if;
  if exists(select 1 from public.questions question join target_lessons target on target.id=question.lesson_id
    where concat_ws(' ',question.question_text,question.explanation) ~* '(PIM|Identity Protection|Access Reviews|Entitlement Management|custom RBAC|OAuth internals|OIDC internals|SAML internals|LDAP configuration|Kerberos configuration|Defender plans|Defender XDR|advanced threat hunting)') then
    raise exception 'Identity Questions require content beyond AZ-900 scope'; end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.quiz_attempts attempt left join public.certifications certification on certification.id=attempt.certification_id
      left join public.lessons lesson on lesson.id=attempt.lesson_id left join public.topics topic on topic.id=attempt.topic_id
      where certification.id is null or (attempt.lesson_id is not null and lesson.id is null) or (attempt.topic_id is not null and topic.id is null))
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null) then
    raise exception 'Study history contains an orphaned reference'; end if;
  if exists(select 1 from pg_class relation join pg_namespace namespace on namespace.oid=relation.relnamespace
    where namespace.nspname='public' and relation.relname in ('lessons','lesson_content_blocks','visual_experiences','flashcards','questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions','quiz_answers','flashcard_reviews','user_flashcard_progress')
      and not relation.relrowsecurity) then raise exception 'A required table has RLS disabled'; end if;
  if has_table_privilege('authenticated','public.questions','SELECT') or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lessons','UPDATE') or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE') or has_table_privilege('authenticated','public.visual_experiences','UPDATE')
    or not has_table_privilege('authenticated','public.lessons','SELECT') or not has_table_privilege('authenticated','public.flashcards','SELECT')
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') or not has_table_privilege('authenticated','public.visual_experiences','SELECT') then
    raise exception 'Identity curriculum grants are invalid'; end if;
end; $$;

create temporary table wrong_options(question_id uuid primary key,option_id uuid not null) on commit drop;
insert into wrong_options select question.id,(array_agg(option.id order by option.display_order) filter(where not option.is_correct))[1]
from public.questions question join target_lessons target on target.id=question.lesson_id
join public.question_options option on option.question_id=question.id group by question.id;
grant select on wrong_options to authenticated;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select '00000000-0000-0000-0000-000000000000',seed.id,'authenticated','authenticated',seed.email,'',now(),
  '{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now()
from(values
  ('58000000-0000-4000-8000-000000000027'::uuid,'identity-closure-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000028'::uuid,'identity-closure-b@example.invalid'),
  ('58000000-0000-4000-8000-000000000029'::uuid,'identity-closure-c@example.invalid')) seed(id,email);
grant select on target_lessons,wrong_options to authenticated;
set local role authenticated;
do $$
declare seeded_user uuid; attempt public.quiz_attempts; first_attempt_id uuid;
begin
  foreach seeded_user in array array['58000000-0000-4000-8000-000000000027'::uuid,
    '58000000-0000-4000-8000-000000000028'::uuid,'58000000-0000-4000-8000-000000000029'::uuid]
  loop
    perform set_config('request.jwt.claim.sub',seeded_user::text,true);
    select * into strict attempt from public.start_topic_quiz('32000000-0000-4000-8000-000000000005');
    if attempt.total_questions<>10 or (select count(*) from public.quiz_attempt_questions where attempt_id=attempt.id)<>10
      or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id where item.attempt_id=attempt.id)<>9
      or exists(select 1 from target_lessons target where not exists(select 1 from public.quiz_attempt_questions item
        join public.questions question on question.id=item.question_id where item.attempt_id=attempt.id and question.lesson_id=target.id))
      or exists(select 1 from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id
        where item.attempt_id=attempt.id group by question.lesson_id having count(*)>2) then
      raise exception 'Identity Topic Quiz is not balanced across all nine Lessons'; end if;
    if first_attempt_id is null then first_attempt_id:=attempt.id; end if;
  end loop;
  perform set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000028',true);
  if exists(select 1 from public.quiz_attempts where id=first_attempt_id) then raise exception 'Quiz history leaked across users'; end if;
end; $$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000027',true);
do $$
declare lesson_target record; attempt public.quiz_attempts; question_record record; started public.user_lesson_progress;
  completed public.user_lesson_progress; target_card_id uuid; review_attempt public.quiz_attempts; target_certification_id uuid;
begin
  for lesson_target in select id from target_lessons order by display_order loop
    select * into strict attempt from public.start_lesson_quiz(lesson_target.id);
    if attempt.total_questions<>5 or (select count(*) from public.quiz_attempt_questions where attempt_id=attempt.id)<>5 then
      raise exception 'Identity Lesson Quiz failed for %',lesson_target.id; end if;
    if lesson_target.id=(select id from target_lessons order by display_order limit 1) then
      for question_record in select item.question_id,wrong.option_id from public.quiz_attempt_questions item
        join wrong_options wrong on wrong.question_id=item.question_id where item.attempt_id=attempt.id order by item.display_order
      loop perform * from public.submit_quiz_answer(attempt.id,question_record.question_id,question_record.option_id); end loop;
    end if;
  end loop;
  select * into strict started from public.start_lesson_progress((select id from target_lessons order by display_order limit 1));
  select * into strict completed from public.complete_lesson_progress((select id from target_lessons order by display_order limit 1));
  if started.status<>'in_progress' or completed.status<>'completed' or completed.completed_at is null then
    raise exception 'Identity Lesson progress flow failed'; end if;
  select card.id into strict target_card_id from public.flashcards card join target_lessons target on target.id=card.lesson_id
    where card.is_published order by target.display_order,card.display_order limit 1;
  perform public.submit_flashcard_review(target_card_id,'good');
  if not exists(select 1 from public.flashcard_reviews where flashcard_id=target_card_id)
    or not exists(select 1 from public.user_flashcard_progress where flashcard_id=target_card_id) then
    raise exception 'Identity spaced repetition failed'; end if;
  select certification_id into strict target_certification_id from target_lessons limit 1;
  select * into strict review_attempt from public.start_review_quiz(target_certification_id);
  if review_attempt.quiz_type<>'review' or review_attempt.total_questions<>5
    or (select count(*) from public.quiz_attempt_questions where attempt_id=review_attempt.id)<>5 then
    raise exception 'Identity Review flow failed'; end if;
end; $$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000028',true);
do $$ begin
  if exists(select 1 from public.user_lesson_progress where user_id='58000000-0000-4000-8000-000000000027')
    or exists(select 1 from public.flashcard_reviews where user_id='58000000-0000-4000-8000-000000000027')
    or exists(select 1 from public.user_flashcard_progress where user_id='58000000-0000-4000-8000-000000000027') then
    raise exception 'Identity progress or review state leaked across users'; end if;
end; $$;
reset role;

do $$
declare topic_record record;
begin
  for topic_record in select * from(values
    ('30000000-0000-4000-8000-000000000002'::uuid,7,55,2,37,42),
    ('32000000-0000-4000-8000-000000000002'::uuid,9,73,2,34,51),
    ('32000000-0000-4000-8000-000000000003'::uuid,5,48,3,23,30),
    ('32000000-0000-4000-8000-000000000004'::uuid,8,76,1,40,46),
    ('32000000-0000-4000-8000-000000000005'::uuid,9,105,3,49,50)
  ) expected(topic_id,lessons,blocks,visuals,cards,questions)
  loop
    if (select count(*) from public.lessons where topic_id=topic_record.topic_id and is_published)<>topic_record.lessons
      or (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id where lesson.topic_id=topic_record.topic_id and block.is_published)<>topic_record.blocks
      or (select count(*) from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id where lesson.topic_id=topic_record.topic_id and visual.is_published)<>topic_record.visuals
      or (select count(*) from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id where lesson.topic_id=topic_record.topic_id and card.is_published)<>topic_record.cards
      or (select count(*) from public.questions question where question.topic_id=topic_record.topic_id and question.is_published)<>topic_record.questions then
      raise exception 'Domain 2 Topic inventory is invalid for %',topic_record.topic_id; end if;
  end loop;
end; $$;

select json_build_object('stage','8.9.6','topic','Azure Identity, Access and Security','status','CLOSED',
  'domain_2_status','CLOSED','lessons',9,'estimated_minutes',100,'content_blocks',105,'visual_experiences',3,
  'flashcards',49,'questions',50,'difficulty',json_build_object('easy',19,'medium',21,'hard',10),
  'questions_corrected',10,'questions_created',0,'flashcards_corrected',0,'flashcards_created',3,
  'covered',11,'partial',0,'missing',0,'topic_quiz_lessons_per_attempt',9,'history_preserved',true)
  as identity_access_security_closure_validation;
rollback;

begin;
set local statement_timeout='30s';

create temporary table target_lessons on commit drop as
select lesson.id,lesson.slug,lesson.estimated_minutes,lesson.display_order
from public.lessons lesson
join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id
join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and domain.title='Describe Azure architecture and services'
  and topic.id='32000000-0000-4000-8000-000000000005' and topic.title='Identity, Access and Security'
  and lesson.slug in ('single-sign-on','mfa-and-passwordless','external-identities');

do $$
declare duplicate_count integer;
begin
  if not exists(select 1 from supabase_migrations.schema_migrations where version='20260828060000') then
    raise exception '8.9.3 migration is not registered';
  end if;
  if (select count(*) from target_lessons)<>3
    or exists(select 1 from target_lessons target join public.lessons lesson on lesson.id=target.id
      where not lesson.is_published or lesson.content is null or btrim(lesson.content)=''
        or lesson.estimated_minutes<>case lesson.slug when 'single-sign-on' then 8 when 'mfa-and-passwordless' then 12 else 10 end) then
    raise exception '8.9.3 Lesson inventory, publication, fallback or estimates are invalid';
  end if;
  if exists(select 1 from target_lessons target left join public.lesson_content_blocks block on block.lesson_id=target.id
    group by target.id,target.slug having count(block.id)<>case target.slug when 'single-sign-on' then 8 when 'mfa-and-passwordless' then 13 else 10 end
      or min(block.display_order)<>1 or max(block.display_order)<>count(block.id)
      or count(distinct block.display_order)<>count(block.id) or count(*) filter(where block.is_published)<>count(block.id)
      or count(*) filter(where block.type='explanation')<1 or count(*) filter(where block.type='important')<1
      or count(*) filter(where block.type='example')<1 or count(*) filter(where block.type='exam_tip')<>1
      or count(*) filter(where block.type='exam_trap')<1 or count(*) filter(where block.type='summary')<>1) then
    raise exception '8.9.3 Content Blocks or ordering are invalid';
  end if;
  if exists(select 1 from public.lesson_content_blocks summary join target_lessons target on target.id=summary.lesson_id
    where summary.type='summary' and (summary.display_order<>(select max(display_order) from public.lesson_content_blocks where lesson_id=summary.lesson_id)
      or jsonb_typeof(summary.config->'items')<>'array' or jsonb_array_length(summary.config->'items') not between 3 and 6)) then
    raise exception '8.9.3 summary is invalid';
  end if;
  if exists(select 1 from public.visual_experiences visual join target_lessons target on target.id=visual.lesson_id)
    or exists(select 1 from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
      where block.type='visual_experience' or block.visual_experience_id is not null) then
    raise exception '8.9.3 must not contain a Visual Experience';
  end if;
  if (select count(*) from public.flashcards card join target_lessons target on target.id=card.lesson_id where card.is_published)<>16
    or exists(select 1 from target_lessons target left join public.flashcards card on card.lesson_id=target.id and card.is_published
      group by target.id,target.slug having count(card.id)<>case target.slug when 'single-sign-on' then 4 when 'mfa-and-passwordless' then 7 else 5 end)
    or exists(select 1 from public.flashcards card join target_lessons target on target.id=card.lesson_id
      where length(btrim(card.front_text))>220 or length(btrim(card.back_text))>500) then
    raise exception '8.9.3 Flashcards are invalid';
  end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g'))
    from public.flashcards card join target_lessons target on target.id=card.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '8.9.3 contains exact Flashcard duplicates'; end if;
  if (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.is_published)<>15
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.difficulty='easy')<>6
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.difficulty='medium')<>6
    or (select count(*) from public.questions question join target_lessons target on target.id=question.lesson_id where question.difficulty='hard')<>3
    or exists(select 1 from target_lessons target left join public.questions question on question.lesson_id=target.id and question.is_published
      group by target.id having count(question.id)<>5 or count(question.id) filter(where question.difficulty='easy')<>2
        or count(question.id) filter(where question.difficulty='medium')<>2 or count(question.id) filter(where question.difficulty='hard')<>1) then
    raise exception '8.9.3 Question inventory or difficulty is invalid';
  end if;
  if exists(select 1 from public.questions question join target_lessons target on target.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id where question.is_published group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception '8.9.3 Question or Question Options are invalid';
  end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g'))
    from public.questions question join target_lessons target on target.id=question.lesson_id group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '8.9.3 contains exact Question duplicates'; end if;
  if exists(with artifacts as(
    select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card join target_lessons target on target.id=card.lesson_id
    union all select concat_ws(' ',question.question_text,question.explanation,option.option_text,option.explanation)
      from public.questions question join target_lessons target on target.id=question.lesson_id join public.question_options option on option.question_id=question.id)
    select 1 from artifacts where text ~* '(Azure RBAC|Zero Trust|Defense in Depth|Defender for Cloud|Governance|Cost Management|SAML configuration|OIDC configuration|cross-tenant access settings)') then
    raise exception '8.9.3 artifacts exceed the intended scope';
  end if;
  if not exists(with artifacts as(
    select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card join target_lessons target on target.id=card.lesson_id
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question join target_lessons target on target.id=question.lesson_id)
    select 1 from artifacts where text ~* 'SSO' and text ~* 'MFA' and text ~* 'Passwordless')
    or not exists(with artifacts as(
      select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block join target_lessons target on target.id=block.lesson_id
      union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card join target_lessons target on target.id=card.lesson_id
      union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question join target_lessons target on target.id=question.lesson_id)
      select 1 from artifacts where text ~* 'home tenant' and text ~* 'resource tenant' and text ~* '(guest|external user)') then
    raise exception '8.9.3 required concepts are missing';
  end if;
end; $$;

do $$
begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null) then
    raise exception 'Study history contains an orphaned reference';
  end if;
  if not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or has_table_privilege('authenticated','public.visual_experiences','UPDATE')
    or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.questions','UPDATE') then
    raise exception '8.9.3 curriculum grants are invalid';
  end if;
end; $$;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values('00000000-0000-0000-0000-000000000000','58000000-0000-4000-8000-000000000022','authenticated','authenticated',
  'identity-893@example.invalid','',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now());
grant select on target_lessons to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000022',true);
do $$
declare lesson_target record; lesson_attempt public.quiz_attempts; topic_attempt public.quiz_attempts;
begin
  for lesson_target in select id from target_lessons order by display_order loop
    select * into strict lesson_attempt from public.start_lesson_quiz(lesson_target.id);
    if lesson_attempt.total_questions<>5 or (select count(*) from public.quiz_attempt_questions where attempt_id=lesson_attempt.id)<>5 then
      raise exception '8.9.3 Lesson Quiz failed for %',lesson_target.id; end if;
  end loop;
  select * into strict topic_attempt from public.start_topic_quiz('32000000-0000-4000-8000-000000000005');
  if topic_attempt.total_questions<>10 or (select count(*) from public.quiz_attempt_questions where attempt_id=topic_attempt.id)<>10
    or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id
      where item.attempt_id=topic_attempt.id)<6
    or exists(select 1 from target_lessons scoped where not exists(select 1 from public.quiz_attempt_questions item
      join public.questions question on question.id=item.question_id where item.attempt_id=topic_attempt.id and question.lesson_id=scoped.id)) then
    raise exception '8.9.3 Topic Quiz failed';
  end if;
end; $$;
reset role;

select json_build_object('stage','8.9.3','lessons',3,'published_blocks',31,'visuals_created',0,
  'flashcards_added',16,'questions_added',15,'difficulty',json_build_object('easy',6,'medium',6,'hard',3),
  'history_preserved',true) as identity_authentication_collaboration_validation;
rollback;

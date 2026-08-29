begin;

do $$
declare lesson_row record; duplicate_count integer; combined_text text; advanced_text text;
begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000003')<>7 then
    raise exception '9.6.5 expected exactly seven Lessons'; end if;
  for lesson_row in select id,slug,estimated_minutes from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000003' loop
    if not exists(select 1 from public.lessons where id=lesson_row.id and is_published and content is not null and btrim(content)<>'')
      or lesson_row.estimated_minutes<>(case lesson_row.slug
        when 'azure-portal' then 10 when 'azure-cloud-shell' then 10 when 'azure-cli' then 10
        when 'azure-powershell' then 10 when 'azure-arc' then 12 when 'infrastructure-as-code' then 12
        when 'azure-resource-manager-and-arm-templates' then 14 end)
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and is_published)
        <>(case lesson_row.slug when 'azure-arc' then 13 when 'infrastructure-as-code' then 12
          when 'azure-resource-manager-and-arm-templates' then 14 else 10 end)
      or (select min(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)<>1
      or (select max(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)
        <>(case lesson_row.slug when 'azure-arc' then 13 when 'infrastructure-as-code' then 12
          when 'azure-resource-manager-and-arm-templates' then 14 else 10 end)
      or (select count(distinct display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)
        <>(case lesson_row.slug when 'azure-arc' then 13 when 'infrastructure-as-code' then 12
          when 'azure-resource-manager-and-arm-templates' then 14 else 10 end)
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='summary')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='exam_tip')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='exam_trap')<1
      or (select count(*) from public.flashcards where lesson_id=lesson_row.id and is_published)
        <>(case lesson_row.slug when 'azure-arc' then 7 when 'azure-resource-manager-and-arm-templates' then 8 else 6 end)
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug in('azure-cloud-shell','azure-cli','azure-arc','azure-resource-manager-and-arm-templates') then 10 else 5 end) then
      raise exception '9.6.5 artifact inventory invalid for %',lesson_row.slug; end if;
  end loop;
  if (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and block.is_published)<>79
    or (select count(*) from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and visual.is_published)<>1
    or (select count(*) from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and card.is_published)<>45
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and question.is_published)<>55 then
    raise exception '9.6.5 Topic totals are invalid'; end if;
  if (select sum(estimated_minutes) from public.lessons where topic_id='33000000-0000-4000-8000-000000000003')<>78 then
    raise exception '9.6.5 estimated minutes are invalid'; end if;
  if (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and question.difficulty='easy')<>19
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and question.difficulty='medium')<>25
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and question.difficulty='hard')<>11 then
    raise exception '9.6.5 difficulty totals are invalid'; end if;
  if not exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
      where visual.id='76000000-0000-4000-8000-000000000016' and visual.type='architecture'
        and visual.is_published and lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug='azure-resource-manager-and-arm-templates'
        and jsonb_array_length(visual.config->'nodes')=8 and jsonb_array_length(visual.config->'edges')=7)
    or not exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and block.type='visual_experience'
        and block.visual_experience_id='76000000-0000-4000-8000-000000000016' and block.is_published) then
    raise exception '9.6.5 Visual Experience is invalid'; end if;
  if exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003' group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception '9.6.5 Questions or Options are invalid'; end if;
  select count(*) into duplicate_count from(select lesson.id,lower(regexp_replace(btrim(block.title),'[^[:alnum:]]+',' ','g')) value
    from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003' group by lesson.id,value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.6.5 duplicate Content Blocks'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g')) value
    from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003' group by value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.6.5 duplicate Flashcards'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g')) value
    from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003' group by value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.6.5 duplicate Questions'; end if;
  select string_agg(text,' ') into combined_text from(
    select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block
      join public.lessons lesson on lesson.id=block.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000003'
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card
      join public.lessons lesson on lesson.id=card.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000003'
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question
      join public.lessons lesson on lesson.id=question.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000003') artifacts;
  if combined_text !~* 'interface gráfica' or combined_text !~* 'terminal.*navegador'
    or combined_text !~* 'comandos? `?az' or combined_text !~* 'cmdlets?.*Az'
    or combined_text !~* 'Azure Arc' or combined_text !~* 'on-premises' or combined_text !~* 'hybrid'
    or combined_text !~* 'multicloud' or combined_text !~* 'Azure Migrate'
    or combined_text !~* 'Infrastructure as Code' or combined_text !~* 'Declarative'
    or combined_text !~* 'repeatab' or combined_text !~* 'version control'
    or combined_text !~* 'Azure Resource Manager' or combined_text !~* 'Resource Provider'
    or combined_text !~* 'ARM Template' or combined_text !~* 'JSON' then
    raise exception '9.6.5 objective coverage is incomplete'; end if;
  select string_agg(concat_ws(' ',block.title,block.content,block.config::text),' ') into advanced_text
    from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003';
  if advanced_text ~* 'Cloud Shell é Azure CLI' or advanced_text ~* 'Cloud Shell e PowerShell são a mesma coisa'
    or advanced_text ~* 'Azure Arc migra automaticamente' or advanced_text ~* 'Azure Arc transforma.*Azure VM'
    or advanced_text ~* 'Azure Arc só funciona com Kubernetes'
    or advanced_text ~* 'ARM e ARM Template são exatamente a mesma'
    or advanced_text ~* 'ARM Template é uma CLI' or advanced_text ~* 'Azure Resource Manager é um Resource Group'
    or advanced_text ~* 'Terraform state' or advanced_text ~* 'Bicep syntax' or advanced_text ~* 'deployment modes'
    or advanced_text ~* 'linked templates' or advanced_text ~* 'template specs' or advanced_text ~* 'deployment stacks'
    or advanced_text ~* 'GitOps' then raise exception '9.6.5 contains prohibited or advanced content'; end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.quiz_attempts attempt left join auth.users user_record on user_record.id=attempt.user_id where user_record.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null) then
    raise exception '9.6.5 study history contains an orphan'; end if;
  if exists(select 1 from pg_class relation join pg_namespace namespace on namespace.oid=relation.relnamespace
    where namespace.nspname='public' and relation.relname in('lessons','lesson_content_blocks','visual_experiences','flashcards','questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions','quiz_answers','flashcard_reviews','user_flashcard_progress')
      and not relation.relrowsecurity) then raise exception '9.6.5 requires RLS'; end if;
  if has_table_privilege('authenticated','public.questions','SELECT') or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lessons','UPDATE') or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE') or has_table_privilege('authenticated','public.visual_experiences','UPDATE')
    or not has_table_privilege('authenticated','public.lessons','SELECT') or not has_table_privilege('authenticated','public.flashcards','SELECT')
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') or not has_table_privilege('authenticated','public.visual_experiences','SELECT') then
    raise exception '9.6.5 grants are invalid'; end if;
end; $$;

create temporary table target_lessons on commit drop as
select lesson.id,lesson.slug,lesson.display_order,certification.id certification_id
from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and domain.title='Describe Azure management and governance'
  and topic.id='33000000-0000-4000-8000-000000000003' and topic.title='Resource Management and Deployment';
create temporary table wrong_options(question_id uuid primary key,option_id uuid not null) on commit drop;
insert into wrong_options select question.id,(array_agg(option.id order by option.display_order) filter(where not option.is_correct))[1]
from public.questions question join target_lessons target on target.id=question.lesson_id
join public.question_options option on option.question_id=question.id group by question.id;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select '00000000-0000-0000-0000-000000000000',seed.id,'authenticated','authenticated',seed.email,'',now(),
  '{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now()
from(values
  ('58000000-0000-4000-8000-000000000040'::uuid,'tools-close-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000041'::uuid,'tools-close-b@example.invalid')) seed(id,email);
grant select on target_lessons,wrong_options to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000040',true);

do $$
declare lesson_row record; attempt public.quiz_attempts; topic_attempt public.quiz_attempts;
  review_attempt public.quiz_attempts; question_row record; started public.user_lesson_progress;
  completed public.user_lesson_progress; card_id uuid; certification_uuid uuid;
begin
  for lesson_row in select * from target_lessons order by display_order loop
    select * into strict attempt from public.start_lesson_quiz(lesson_row.id);
    if attempt.total_questions<>5 or (select count(*) from public.quiz_attempt_questions where attempt_id=attempt.id)<>5 then
      raise exception '9.6.5 Lesson Quiz failed for %',lesson_row.slug; end if;
    if lesson_row.slug='azure-portal' then
      for question_row in select item.question_id,wrong.option_id from public.quiz_attempt_questions item
        join wrong_options wrong on wrong.question_id=item.question_id where item.attempt_id=attempt.id order by item.display_order loop
        perform * from public.submit_quiz_answer(attempt.id,question_row.question_id,question_row.option_id);
      end loop;
    end if;
  end loop;
  select * into strict topic_attempt from public.start_topic_quiz('33000000-0000-4000-8000-000000000003');
  if topic_attempt.total_questions<>10
    or (select count(*) from public.quiz_attempt_questions where attempt_id=topic_attempt.id)<>10
    or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id
      where item.attempt_id=topic_attempt.id)<>7
    or exists(select 1 from target_lessons target where not exists(select 1 from public.quiz_attempt_questions item
      join public.questions question on question.id=item.question_id where item.attempt_id=topic_attempt.id and question.lesson_id=target.id))
    or exists(select 1 from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id
      where item.attempt_id=topic_attempt.id group by question.lesson_id having count(*)>2) then
    raise exception '9.6.5 Topic Quiz is not balanced across seven Lessons'; end if;
  select certification_id into strict certification_uuid from target_lessons limit 1;
  select * into strict review_attempt from public.start_review_quiz(certification_uuid);
  if review_attempt.quiz_type<>'review' or review_attempt.total_questions<>5
    or (select count(*) from public.quiz_attempt_questions where attempt_id=review_attempt.id)<>5 then
    raise exception '9.6.5 Review Quiz failed'; end if;
  select * into strict started from public.start_lesson_progress((select id from target_lessons where slug='azure-resource-manager-and-arm-templates'));
  select * into strict completed from public.complete_lesson_progress((select id from target_lessons where slug='azure-resource-manager-and-arm-templates'));
  if started.status<>'in_progress' or completed.status<>'completed' or completed.completed_at is null then
    raise exception '9.6.5 progress failed'; end if;
  select card.id into strict card_id from public.flashcards card join target_lessons target on target.id=card.lesson_id
    order by target.display_order,card.display_order limit 1;
  perform public.submit_flashcard_review(card_id,'good');
  if not exists(select 1 from public.flashcard_reviews where flashcard_id=card_id)
    or not exists(select 1 from public.user_flashcard_progress where flashcard_id=card_id) then
    raise exception '9.6.5 spaced repetition failed'; end if;
end; $$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000041',true);
do $$
declare topic_attempt public.quiz_attempts;
begin
  if exists(select 1 from public.quiz_attempts where user_id='58000000-0000-4000-8000-000000000040')
    or exists(select 1 from public.user_lesson_progress where user_id='58000000-0000-4000-8000-000000000040')
    or exists(select 1 from public.flashcard_reviews where user_id='58000000-0000-4000-8000-000000000040')
    or exists(select 1 from public.user_flashcard_progress where user_id='58000000-0000-4000-8000-000000000040') then
    raise exception '9.6.5 user isolation failed'; end if;
  select * into strict topic_attempt from public.start_topic_quiz('33000000-0000-4000-8000-000000000003');
  if (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id=item.question_id
      where item.attempt_id=topic_attempt.id)<>7 then raise exception '9.6.5 second Topic Quiz is not distributed'; end if;
end; $$;

rollback;

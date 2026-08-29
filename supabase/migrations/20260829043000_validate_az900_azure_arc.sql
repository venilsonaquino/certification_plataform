begin;

do $$
declare lesson_uuid uuid; combined_text text; duplicate_count integer;
begin
  select id into strict lesson_uuid from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000003' and slug='azure-arc'
      and is_published and content is not null and btrim(content)<>'' and estimated_minutes=12;
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000003')<>7 then
    raise exception '9.6.3 changed the Topic Lesson inventory'; end if;
  if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_uuid and is_published)<>13
    or (select min(display_order) from public.lesson_content_blocks where lesson_id=lesson_uuid)<>1
    or (select max(display_order) from public.lesson_content_blocks where lesson_id=lesson_uuid)<>13
    or (select count(distinct display_order) from public.lesson_content_blocks where lesson_id=lesson_uuid)<>13
    or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_uuid and type='summary')<>1
    or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_uuid and type='exam_tip')<>1
    or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_uuid and type='exam_trap')<>2
    or (select count(*) from public.flashcards where lesson_id=lesson_uuid and is_published)<>7
    or (select count(*) from public.questions where lesson_id=lesson_uuid and is_published)<>10
    or (select count(*) from public.questions where lesson_id=lesson_uuid and difficulty='easy')<>3
    or (select count(*) from public.questions where lesson_id=lesson_uuid and difficulty='medium')<>5
    or (select count(*) from public.questions where lesson_id=lesson_uuid and difficulty='hard')<>2 then
    raise exception '9.6.3 Azure Arc artifact inventory is invalid'; end if;
  if exists(select 1 from public.visual_experiences where lesson_id=lesson_uuid) then
    raise exception '9.6.3 expected no Visual Experience'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates'))
    or exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates')) then
    raise exception '9.6.3 modified an out-of-scope Lesson'; end if;
  if (select count(*) from public.questions where id between '63000000-0000-4000-8000-000000000031'
      and '63000000-0000-4000-8000-000000000040' and lesson_id=lesson_uuid)<>10 then
    raise exception '9.6.3 historical Question UUIDs were not preserved'; end if;
  if (select count(*) from public.question_options where id between '74000000-0000-4000-8000-000000000121'
      and '74000000-0000-4000-8000-000000000160'
      and question_id between '63000000-0000-4000-8000-000000000031' and '63000000-0000-4000-8000-000000000040')<>40 then
    raise exception '9.6.3 historical Option UUIDs were not preserved'; end if;
  if exists(select 1 from public.questions question left join public.question_options option on option.question_id=question.id
    where question.lesson_id=lesson_uuid group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception '9.6.3 Questions or Options are invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(block.title),'[^[:alnum:]]+',' ','g')) value
    from public.lesson_content_blocks block where block.lesson_id=lesson_uuid group by value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.6.3 duplicate Content Blocks'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g')) value
    from public.flashcards card where card.lesson_id=lesson_uuid group by value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.6.3 duplicate Flashcards'; end if;
  select string_agg(text,' ') into combined_text from(
    select concat_ws(' ',title,content,config::text) text from public.lesson_content_blocks where lesson_id=lesson_uuid
    union all select concat_ws(' ',front_text,back_text,hint) from public.flashcards where lesson_id=lesson_uuid
    union all select concat_ws(' ',question_text,explanation) from public.questions where lesson_id=lesson_uuid) artifacts;
  if combined_text !~* 'fora do Azure' or combined_text !~* 'on-premises' or combined_text !~* 'hybrid'
    or combined_text !~* 'multicloud' or combined_text !~* 'Arc-enabled Server' or combined_text !~* 'Windows'
    or combined_text !~* 'Linux' or combined_text !~* 'continua.*(onde|local|VMware)'
    or combined_text !~* 'Azure Migrate' or combined_text !~* 'Azure Policy'
    or combined_text !~* 'VPN' or combined_text !~* 'ExpressRoute' or combined_text !~* 'Virtual Desktop'
    or combined_text !~* 'suportad' or combined_text !~* 'configura' then
    raise exception '9.6.3 required concepts are incomplete'; end if;
  if combined_text ~* 'migra automaticamente' and combined_text !~* '(não|nao) migra automaticamente'
    or combined_text ~* 'Azure Arc exige que o workload seja migrado'
    or combined_text ~* 'Arc (é|e) exclusivamente para Kubernetes'
    or combined_text ~* 'toda funcionalidade Azure funciona igualmente' then
    raise exception '9.6.3 contains a prohibited misconception'; end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null) then raise exception '9.6.3 study history contains an orphan'; end if;
  if exists(select 1 from pg_class relation join pg_namespace namespace on namespace.oid=relation.relnamespace
    where namespace.nspname='public' and relation.relname in('lessons','lesson_content_blocks','visual_experiences','flashcards','questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions','quiz_answers','flashcard_reviews','user_flashcard_progress')
      and not relation.relrowsecurity) then raise exception '9.6.3 requires RLS'; end if;
  if has_table_privilege('authenticated','public.questions','SELECT') or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lessons','UPDATE') or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or not has_table_privilege('authenticated','public.lessons','SELECT') or not has_table_privilege('authenticated','public.flashcards','SELECT')
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') then raise exception '9.6.3 grants are invalid'; end if;
end; $$;

commit;

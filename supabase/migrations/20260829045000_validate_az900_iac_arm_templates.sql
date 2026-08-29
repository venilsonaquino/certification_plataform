begin;

do $$
declare lesson_row record; combined_text text; lesson_text text; duplicate_count integer; arm_lesson_id uuid;
begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000003')<>7 then
    raise exception '9.6.4 changed the Topic Lesson inventory'; end if;
  for lesson_row in select id,slug,estimated_minutes from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000003'
      and slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates') loop
    if not exists(select 1 from public.lessons where id=lesson_row.id and is_published and content is not null and btrim(content)<>'')
      or lesson_row.estimated_minutes<>(case when lesson_row.slug='infrastructure-as-code' then 12 else 14 end)
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='infrastructure-as-code' then 12 else 14 end)
      or (select min(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)<>1
      or (select max(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)
        <>(case when lesson_row.slug='infrastructure-as-code' then 12 else 14 end)
      or (select count(distinct display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)
        <>(case when lesson_row.slug='infrastructure-as-code' then 12 else 14 end)
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='summary')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='exam_tip')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='exam_trap')
        <>(case when lesson_row.slug='infrastructure-as-code' then 2 else 2 end)
      or (select count(*) from public.flashcards where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='infrastructure-as-code' then 6 else 8 end)
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='infrastructure-as-code' then 5 else 10 end) then
      raise exception '9.6.4 artifact inventory invalid for %',lesson_row.slug; end if;
  end loop;
  select id into strict arm_lesson_id from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000003' and slug='azure-resource-manager-and-arm-templates';
  if (select count(*) from public.visual_experiences where lesson_id=arm_lesson_id and is_published)<>1
    or not exists(select 1 from public.visual_experiences where id='76000000-0000-4000-8000-000000000016'
      and lesson_id=arm_lesson_id and type='architecture'
      and jsonb_array_length(config->'nodes')=8 and jsonb_array_length(config->'edges')=7)
    or not exists(select 1 from public.lesson_content_blocks where lesson_id=arm_lesson_id and type='visual_experience'
      and visual_experience_id='76000000-0000-4000-8000-000000000016' and is_published) then
    raise exception '9.6.4 ARM Visual Experience is invalid'; end if;
  if exists(select 1 from public.visual_experiences where lesson_id in(
    select id from public.lessons where topic_id='33000000-0000-4000-8000-000000000003' and slug='infrastructure-as-code')) then
    raise exception '9.6.4 expected no separate IaC visual'; end if;
  if exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003'
      and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates')
    group by question.id having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception '9.6.4 Questions or Options are invalid'; end if;
  if (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.slug='infrastructure-as-code' and lesson.topic_id='33000000-0000-4000-8000-000000000003' and question.difficulty='easy')<>2
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.slug='infrastructure-as-code' and lesson.topic_id='33000000-0000-4000-8000-000000000003' and question.difficulty='medium')<>2
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.slug='infrastructure-as-code' and lesson.topic_id='33000000-0000-4000-8000-000000000003' and question.difficulty='hard')<>1
    or (select count(*) from public.questions where lesson_id=arm_lesson_id and difficulty='easy')<>4
    or (select count(*) from public.questions where lesson_id=arm_lesson_id and difficulty='medium')<>4
    or (select count(*) from public.questions where lesson_id=arm_lesson_id and difficulty='hard')<>2 then
    raise exception '9.6.4 Question difficulty distribution is invalid'; end if;
  select count(*) into duplicate_count from(select lesson.id,lower(regexp_replace(btrim(block.title),'[^[:alnum:]]+',' ','g')) value
    from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003'
      and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates')
    group by lesson.id,value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.6.4 duplicate Content Blocks'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g')) value
    from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003'
      and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates')
    group by value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.6.4 duplicate Flashcards'; end if;
  select string_agg(text,' ') into combined_text from(
    select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block
      join public.lessons lesson on lesson.id=block.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates')
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card
      join public.lessons lesson on lesson.id=card.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates')
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question
      join public.lessons lesson on lesson.id=question.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates')) artifacts;
  select string_agg(concat_ws(' ',block.title,block.content,block.config::text),' ') into lesson_text
    from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003'
      and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates');
  if combined_text !~* 'Infrastructure as Code' or combined_text !~* 'repeatab' or combined_text !~* 'consisten'
    or combined_text !~* 'automat' or combined_text !~* 'version control' or combined_text !~* 'reprodu'
    or combined_text !~* 'Declarative' or combined_text !~* 'Imperative' or combined_text !~* 'estado desejado'
    or combined_text !~* 'Azure Resource Manager' or combined_text !~* 'camada.*gerenciamento'
    or combined_text !~* 'Resource Provider' or combined_text !~* 'Microsoft.Compute' or combined_text !~* 'Microsoft.Storage'
    or combined_text !~* 'ARM Template' or combined_text !~* 'JSON' or combined_text !~* 'Parameters'
    or combined_text !~* 'Variables' or combined_text !~* 'Resources' or combined_text !~* 'Outputs'
    or combined_text !~* 'Bicep' then raise exception '9.6.4 required concepts are incomplete'; end if;
  if lesson_text ~* 'ARM (é|e) uma (VM|CLI|Resource Group|template|servidor físico)'
    or lesson_text ~* 'Portal substitui Azure Resource Manager'
    or lesson_text ~* 'ARM e ARM Template são exatamente a mesma'
    or lesson_text ~* 'Bicep (é|e) imperative' then raise exception '9.6.4 contains a prohibited misconception'; end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null) then raise exception '9.6.4 study history contains an orphan'; end if;
  if exists(select 1 from pg_class relation join pg_namespace namespace on namespace.oid=relation.relnamespace
    where namespace.nspname='public' and relation.relname in('lessons','lesson_content_blocks','visual_experiences','flashcards','questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions','quiz_answers','flashcard_reviews','user_flashcard_progress')
      and not relation.relrowsecurity) then raise exception '9.6.4 requires RLS'; end if;
  if has_table_privilege('authenticated','public.questions','SELECT') or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lessons','UPDATE') or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE') or has_table_privilege('authenticated','public.visual_experiences','UPDATE')
    or not has_table_privilege('authenticated','public.lessons','SELECT') or not has_table_privilege('authenticated','public.flashcards','SELECT')
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') or not has_table_privilege('authenticated','public.visual_experiences','SELECT') then
    raise exception '9.6.4 grants are invalid'; end if;
end; $$;

commit;

begin;

do $$
declare lesson_row record; combined_text text; duplicate_count integer;
begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000003')<>7 then
    raise exception '9.6.2 changed the Topic Lesson inventory'; end if;
  for lesson_row in select id,slug,estimated_minutes from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000003'
      and slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell') loop
    if lesson_row.estimated_minutes<>10
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and is_published)<>10
      or (select min(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)<>1
      or (select max(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)<>10
      or (select count(distinct display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)<>10
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='summary')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='exam_tip')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='exam_trap')<>1
      or (select count(*) from public.flashcards where lesson_id=lesson_row.id and is_published)<>6
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug in('azure-cloud-shell','azure-cli') then 10 else 5 end) then
      raise exception '9.6.2 artifact inventory invalid for %',lesson_row.slug; end if;
  end loop;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003'
      and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell')) then
    raise exception '9.6.2 expected no Visual Experiences'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('azure-arc','infrastructure-as-code','azure-resource-manager-and-arm-templates'))
    or exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('azure-arc','infrastructure-as-code','azure-resource-manager-and-arm-templates')) then
    raise exception '9.6.2 modified an out-of-scope Lesson'; end if;
  if (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug='azure-arc')<>10
    or exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates')) then
    raise exception '9.6.2 modified out-of-scope Questions'; end if;
  if exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003'
      and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell')
    group by question.id having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception '9.6.2 Questions or Options invalid'; end if;
  select count(*) into duplicate_count from(select lesson.id,lower(regexp_replace(btrim(block.title),'[^[:alnum:]]+',' ','g')) value
    from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003'
      and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell')
    group by lesson.id,value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.6.2 duplicate Content Blocks'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g')) value
    from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000003'
      and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell')
    group by value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.6.2 duplicate Flashcards'; end if;
  select string_agg(text,' ') into combined_text from(
    select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block
      join public.lessons lesson on lesson.id=block.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell')
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card
      join public.lessons lesson on lesson.id=card.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell')
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question
      join public.lessons lesson on lesson.id=question.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell')) artifacts;
  if combined_text !~* 'interface gráfica' or combined_text !~* 'terminal.*navegador'
    or combined_text !~* 'Bash' or combined_text !~* 'PowerShell' or combined_text !~* 'comandos? `?az'
    or combined_text !~* 'Verb-AzNoun' or combined_text !~* 'Get-AzVM'
    or combined_text !~* 'multiplataforma' or combined_text !~* 'automat' or combined_text !~* 'repet' then
    raise exception '9.6.2 required concepts are incomplete'; end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null) then raise exception '9.6.2 study history contains an orphan'; end if;
  if exists(select 1 from pg_class relation join pg_namespace namespace on namespace.oid=relation.relnamespace
    where namespace.nspname='public' and relation.relname in('lessons','lesson_content_blocks','visual_experiences','flashcards','questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions','quiz_answers','flashcard_reviews','user_flashcard_progress')
      and not relation.relrowsecurity) then raise exception '9.6.2 requires RLS'; end if;
  if has_table_privilege('authenticated','public.questions','SELECT') or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lessons','UPDATE') or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or not has_table_privilege('authenticated','public.lessons','SELECT') or not has_table_privilege('authenticated','public.flashcards','SELECT')
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') then raise exception '9.6.2 grants invalid'; end if;
end; $$;

commit;

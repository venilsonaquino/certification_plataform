begin;

do $$
declare duplicate_count integer;
begin
  if (select count(*) from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
      join public.domains domain on domain.id=topic.domain_id join public.certifications certification on certification.id=domain.certification_id
      where certification.code='az-900' and domain.title='Describe Azure management and governance'
        and topic.id='33000000-0000-4000-8000-000000000001' and topic.title='Cost Management'
        and lesson.slug in ('azure-cost-factors','pricing-calculator','azure-cost-management','resource-tags'))<>4 then
    raise exception '9.4 expected four Cost Management Lessons'; end if;
  if exists(select 1 from public.lessons where topic_id='33000000-0000-4000-8000-000000000001'
    and slug in ('azure-cost-factors','pricing-calculator','azure-cost-management','resource-tags')
    and (not is_published or content is null or btrim(content)=''
      or estimated_minutes<>(case slug when 'azure-cost-factors' then 12 when 'pricing-calculator' then 10
        when 'azure-cost-management' then 12 else 10 end))) then
    raise exception '9.4 publication, fallback or estimated minutes are invalid'; end if;
  if (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000001'
        and lesson.slug in ('azure-cost-factors','pricing-calculator','azure-cost-management','resource-tags') and block.is_published)<>50
    or exists(select 1 from public.lessons lesson left join public.lesson_content_blocks block on block.lesson_id=lesson.id
      where lesson.topic_id='33000000-0000-4000-8000-000000000001'
        and lesson.slug in ('azure-cost-factors','pricing-calculator','azure-cost-management','resource-tags')
      group by lesson.id,lesson.slug having count(block.id)<>(case lesson.slug when 'azure-cost-factors' then 14
          when 'pricing-calculator' then 10 else 13 end)
        or min(block.display_order)<>1 or max(block.display_order)<>count(block.id)
        or count(distinct block.display_order)<>count(block.id) or count(*) filter(where block.is_published)<>count(block.id)
        or count(*) filter(where block.type='explanation')<2 or count(*) filter(where block.type='important')<2
        or count(*) filter(where block.type='example')<2 or count(*) filter(where block.type='exam_tip')<>1
        or count(*) filter(where block.type='exam_trap')<1 or count(*) filter(where block.type='summary')<>1) then
    raise exception '9.4 Content Blocks, types or ordering are invalid'; end if;
  if exists(select 1 from public.lesson_content_blocks summary join public.lessons lesson on lesson.id=summary.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000001'
      and lesson.slug in ('azure-cost-factors','pricing-calculator','azure-cost-management','resource-tags') and summary.type='summary'
      and (summary.display_order<>(select max(display_order) from public.lesson_content_blocks where lesson_id=summary.lesson_id)
        or jsonb_typeof(summary.config->'items')<>'array' or jsonb_array_length(summary.config->'items') not between 3 and 6)) then
    raise exception '9.4 summary is invalid'; end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000001'
      and lesson.slug in ('azure-cost-factors','pricing-calculator','azure-cost-management','resource-tags')) then
    raise exception '9.4 expected no Cost Management Visual Experience'; end if;
  if (select count(*) from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000001'
        and lesson.slug in ('azure-cost-factors','pricing-calculator','azure-cost-management','resource-tags') and card.is_published)<>26
    or exists(select 1 from public.lessons lesson left join public.flashcards card on card.lesson_id=lesson.id and card.is_published
      where lesson.topic_id='33000000-0000-4000-8000-000000000001'
        and lesson.slug in ('azure-cost-factors','pricing-calculator','azure-cost-management','resource-tags')
      group by lesson.id,lesson.slug having count(card.id)<>(case lesson.slug when 'azure-cost-factors' then 8
        when 'pricing-calculator' then 5 when 'azure-cost-management' then 7 else 6 end)) then
    raise exception '9.4 Flashcard inventory is invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g'))
    from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000001' group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.4 contains exact Flashcard duplicates'; end if;
  if exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000001'
      and (length(btrim(card.front_text))>180 or length(btrim(card.back_text))>300
        or concat_ws(' ',card.front_text,card.back_text,card.hint) ~* '(R\$|USD|EUR|por mês|por hora.*[0-9])')) then
    raise exception '9.4 Flashcard is too long or contains fragile pricing'; end if;
  if (select count(*) from public.questions where topic_id='33000000-0000-4000-8000-000000000001' and is_published)<>30
    or exists(select 1 from public.lessons lesson left join public.questions question on question.lesson_id=lesson.id and question.is_published
      where lesson.topic_id='33000000-0000-4000-8000-000000000001'
        and lesson.slug in ('azure-cost-factors','pricing-calculator','azure-cost-management','resource-tags')
      group by lesson.id,lesson.slug having count(question.id)<>(case lesson.slug when 'azure-cost-factors' then 10
          when 'pricing-calculator' then 5 when 'azure-cost-management' then 10 else 5 end)
        or count(question.id) filter(where question.difficulty='easy')<>(case lesson.slug when 'azure-cost-factors' then 3
          when 'pricing-calculator' then 2 when 'azure-cost-management' then 3 else 2 end)
        or count(question.id) filter(where question.difficulty='medium')<>(case lesson.slug when 'azure-cost-factors' then 5
          when 'pricing-calculator' then 2 when 'azure-cost-management' then 5 else 2 end)
        or count(question.id) filter(where question.difficulty='hard')<>(case lesson.slug when 'azure-cost-factors' then 2
          when 'pricing-calculator' then 1 when 'azure-cost-management' then 2 else 1 end)) then
    raise exception '9.4 Question inventory or difficulty is invalid'; end if;
  if exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id
    where lesson.topic_id='33000000-0000-4000-8000-000000000001' and question.is_published group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception '9.4 Question or Question Options are invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g'))
    from public.questions question where question.topic_id='33000000-0000-4000-8000-000000000001'
      and question.is_published group by 1 having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.4 contains exact Question duplicates'; end if;
  if exists(select 1 from public.questions question where question.topic_id='33000000-0000-4000-8000-000000000001'
    and concat_ws(' ',question.question_text,question.explanation) ~* '(R\$|USD|EUR|enterprise agreement|invoice management|Cost Management API|advanced export|showback)') then
    raise exception '9.4 Question exceeds the AZ-900 scope or uses fragile pricing'; end if;
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
    raise exception 'Study history contains an orphaned reference'; end if;
  if exists(select 1 from pg_class relation join pg_namespace namespace on namespace.oid=relation.relnamespace
    where namespace.nspname='public' and relation.relname in ('lessons','lesson_content_blocks','visual_experiences','flashcards','questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions','quiz_answers','flashcard_reviews','user_flashcard_progress')
      and not relation.relrowsecurity) then raise exception 'A required table has RLS disabled'; end if;
  if has_table_privilege('authenticated','public.questions','SELECT') or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lessons','UPDATE') or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE') or has_table_privilege('authenticated','public.visual_experiences','UPDATE')
    or not has_table_privilege('authenticated','public.lessons','SELECT') or not has_table_privilege('authenticated','public.flashcards','SELECT')
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') or not has_table_privilege('authenticated','public.visual_experiences','SELECT') then
    raise exception 'Cost Management curriculum grants are invalid'; end if;
end; $$;

commit;

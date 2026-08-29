begin;

do $$
declare duplicate_count integer;
begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000002')<>3 then
    raise exception '9.5.4 expected exactly three Lessons'; end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000002') then raise exception '9.5.4 expected no Visual Experiences'; end if;
  if exists(select 1 from public.flashcards where id='7e430000-0000-4000-8000-000000000013') then
    raise exception '9.5.4 compliance Flashcard UUID already exists'; end if;
  if not exists(select 1 from public.lessons lesson where lesson.topic_id='33000000-0000-4000-8000-000000000002'
    and lesson.slug='azure-policy' and lesson.is_published and lesson.content is not null and btrim(lesson.content)<>'') then
    raise exception '9.5.4 Azure Policy Lesson is invalid'; end if;
end; $$;

insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select '7e430000-0000-4000-8000-000000000013',lesson.id,
  'O que significam compliant e non-compliant no Azure Policy?',
  'Compliant atende à regra avaliada; non-compliant não atende à regra.',
  'Resultado da avaliação.',7,true
from public.lessons lesson
where lesson.topic_id='33000000-0000-4000-8000-000000000002' and lesson.slug='azure-policy';

do $$
declare lesson_row record; duplicate_count integer; combined_text text;
begin
  for lesson_row in select id,slug from public.lessons where topic_id='33000000-0000-4000-8000-000000000002' loop
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
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)<>5
      or (select count(*) from public.questions where lesson_id=lesson_row.id and difficulty='easy')<>2
      or (select count(*) from public.questions where lesson_id=lesson_row.id and difficulty='medium')<>2
      or (select count(*) from public.questions where lesson_id=lesson_row.id and difficulty='hard')<>1 then
      raise exception '9.5.4 artifact inventory invalid for %',lesson_row.slug; end if;
  end loop;
  if (select count(*) from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000002' and card.is_published)<>20 then
    raise exception '9.5.4 Flashcard inventory is invalid'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(block.title),'[^[:alnum:]]+',' ','g')) value
    from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000002' group by lesson.id,value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.5.4 duplicate Content Blocks'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g')) value
    from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000002' group by value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.5.4 duplicate Flashcards'; end if;
  select count(*) into duplicate_count from(select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g')) value
    from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000002' group by value having count(*)>1) duplicates;
  if duplicate_count<>0 then raise exception '9.5.4 duplicate Questions'; end if;
  if exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id
    where lesson.topic_id='33000000-0000-4000-8000-000000000002' group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4 or min(length(btrim(question.explanation)))<40) then
    raise exception '9.5.4 Questions or Options are invalid'; end if;
  select string_agg(text,' ') into combined_text from(
    select concat_ws(' ',block.title,block.content,block.config::text) text from public.lesson_content_blocks block
      join public.lessons lesson on lesson.id=block.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000002'
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint) from public.flashcards card
      join public.lessons lesson on lesson.id=card.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000002'
    union all select concat_ws(' ',question.question_text,question.explanation) from public.questions question
      join public.lessons lesson on lesson.id=question.lesson_id where lesson.topic_id='33000000-0000-4000-8000-000000000002') artifacts;
  if combined_text !~* 'Data Governance' or combined_text !~* 'discovery' or combined_text !~* 'classification'
    or combined_text !~* 'Policy definition' or combined_text !~* 'assignment' or combined_text !~* 'compliant'
    or combined_text !~* 'non-compliant' or combined_text !~* 'Audit' or combined_text !~* 'Deny'
    or combined_text !~* 'CanNotDelete' or combined_text !~* 'ReadOnly' or combined_text !~* 'herdad'
    or combined_text !~* 'RBAC' or combined_text !~* 'backup' then raise exception '9.5.4 concepts are incomplete'; end if;
  if combined_text ~* 'Purview (é|como) (um )?banco de dados' or combined_text ~* 'Purview (é|como) (um )?antivírus'
    or combined_text ~* 'Purview serve apenas para Azure Storage' or combined_text ~* 'Purview é equivalente ao Defender for Cloud'
    or combined_text ~* 'Policy define quem pode acessar'
    or combined_text ~* 'Resource Lock é backup' or combined_text ~* 'Resource Lock controla autorização' then
    raise exception '9.5.4 contains a prohibited misconception'; end if;
end; $$;

do $$ begin
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
      and not relation.relrowsecurity) then raise exception '9.5.4 requires RLS'; end if;
  if has_table_privilege('authenticated','public.questions','SELECT') or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lessons','UPDATE') or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or not has_table_privilege('authenticated','public.lessons','SELECT') or not has_table_privilege('authenticated','public.flashcards','SELECT')
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') then raise exception '9.5.4 grants are invalid'; end if;
end; $$;

commit;

begin;

do $$
declare lesson_row record; combined_text text; duplicate_count integer;
begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000004')<>6 then
    raise exception '9.7.2 changed the Monitoring Lesson inventory';
  end if;
  for lesson_row in select id,slug,estimated_minutes from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000004'
      and slug in('azure-advisor','azure-service-health') loop
    if not exists(select 1 from public.lessons where id=lesson_row.id and is_published
        and content is not null and btrim(content)<>'')
      or lesson_row.estimated_minutes<>12
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='azure-advisor' then 11 else 12 end)
      or (select min(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)<>1
      or (select max(display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)
        <>(case when lesson_row.slug='azure-advisor' then 11 else 12 end)
      or (select count(distinct display_order) from public.lesson_content_blocks where lesson_id=lesson_row.id)
        <>(case when lesson_row.slug='azure-advisor' then 11 else 12 end)
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='summary')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='exam_tip')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and type='exam_trap')
        <>(case when lesson_row.slug='azure-advisor' then 1 else 2 end)
      or (select count(*) from public.flashcards where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='azure-advisor' then 7 else 8 end)
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='azure-advisor' then 10 else 5 end) then
      raise exception '9.7.2 artifact inventory invalid for %',lesson_row.slug;
    end if;
  end loop;
  if (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug='azure-advisor' and question.difficulty='easy')<>3
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug='azure-advisor' and question.difficulty='medium')<>5
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug='azure-advisor' and question.difficulty='hard')<>2
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug='azure-service-health' and question.difficulty='easy')<>2
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug='azure-service-health' and question.difficulty='medium')<>2
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug='azure-service-health' and question.difficulty='hard')<>1 then
    raise exception '9.7.2 difficulty distribution is invalid';
  end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004') then
    raise exception '9.7.2 expected no Visual Experiences in Monitoring';
  end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug in('azure-monitor','log-analytics','azure-monitor-alerts','application-insights'))
    or exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug in('azure-monitor','log-analytics','azure-monitor-alerts','application-insights')) then
    raise exception '9.7.2 modified out-of-scope Lessons';
  end if;
  if exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug in('azure-monitor','log-analytics','azure-monitor-alerts'))
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug='application-insights')<>10 then
    raise exception '9.7.2 modified out-of-scope Questions';
  end if;
  if (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where question.id between '63000000-0000-4000-8000-000000000021'
        and '63000000-0000-4000-8000-000000000030'
        and lesson.topic_id='33000000-0000-4000-8000-000000000004' and lesson.slug='azure-advisor')<>10
    or (select count(*) from public.question_options
      where id between '74000000-0000-4000-8000-000000000081'
        and '74000000-0000-4000-8000-000000000120'
        and question_id between '63000000-0000-4000-8000-000000000021'
        and '63000000-0000-4000-8000-000000000030')<>40 then
    raise exception '9.7.2 historical Advisor UUIDs were not preserved';
  end if;
  if exists(select 1 from public.questions question left join public.question_options option on option.question_id=question.id
      join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug in('azure-advisor','azure-service-health')
      group by question.id having count(option.id)<>4
        or count(option.id) filter(where option.is_correct)<>1
        or count(distinct lower(btrim(option.option_text)))<>4
        or min(length(btrim(question.explanation)))<40) then
    raise exception '9.7.2 Questions or Options are invalid';
  end if;
  select count(*) into duplicate_count from(
    select lesson.id,lower(regexp_replace(btrim(block.title),'[^[:alnum:]]+',' ','g')) value
    from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000004'
      and lesson.slug in('azure-advisor','azure-service-health')
    group by lesson.id,value having count(*)>1
  ) duplicates;
  if duplicate_count<>0 then raise exception '9.7.2 duplicate Content Blocks'; end if;
  select count(*) into duplicate_count from(
    select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g')) value
    from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000004'
      and lesson.slug in('azure-advisor','azure-service-health')
    group by value having count(*)>1
  ) duplicates;
  if duplicate_count<>0 then raise exception '9.7.2 duplicate Flashcards'; end if;
  select string_agg(text,' ') into combined_text from(
    select concat_ws(' ',block.title,block.content,block.config::text) text
      from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug in('azure-advisor','azure-service-health')
    union all select concat_ws(' ',card.front_text,card.back_text,card.hint)
      from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug in('azure-advisor','azure-service-health')
    union all select concat_ws(' ',question.question_text,question.explanation)
      from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug in('azure-advisor','azure-service-health')
  ) artifacts;
  if combined_text !~* 'recomendações personalizadas' or combined_text !~* 'Reliability'
    or combined_text !~* 'Security' or combined_text !~* 'Performance' or combined_text !~* 'Cost'
    or combined_text !~* 'Operational Excellence' or combined_text !~* 'Service issues'
    or combined_text !~* 'Planned maintenance' or combined_text !~* 'Health advisories'
    or combined_text !~* 'Azure Status' or combined_text !~* 'Resource Health'
    or combined_text !~* 'global' or combined_text !~* 'personaliz'
    or combined_text !~* 'recurso específico' or combined_text !~* 'Azure Monitor'
    or combined_text !~* 'Cost Management' then
    raise exception '9.7.2 required concepts are incomplete';
  end if;
  if combined_text ~* 'Advisor aplica automaticamente todas as recomendações sem (revisão|validar|avalia)'
    or combined_text ~* 'Service Health monitora CPU detalhada'
    or combined_text ~* 'Resource Health (é|e) monitoramento detalhado'
    or combined_text ~* 'Azure Status (é|e) personalizado' then
    raise exception '9.7.2 contains a prohibited misconception';
  end if;
end; $$;

do $$
declare selected_count integer; represented_targets integer;
begin
  if exists(select 1 from public.lessons lesson
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug in('azure-advisor','azure-service-health')
        and (select count(*) from public.questions question
          where question.lesson_id=lesson.id and question.is_published and question.question_type='single_choice')<5) then
    raise exception '9.7.2 Lesson Quiz lacks five Questions';
  end if;
  select count(*),count(distinct lesson_id) filter(where lesson_slug in('azure-advisor','azure-service-health'))
    into selected_count,represented_targets from(
    select question.lesson_id,lesson.slug lesson_slug
    from public.questions question left join public.lessons lesson on lesson.id=question.lesson_id
    where question.topic_id='33000000-0000-4000-8000-000000000004'
      and question.is_published and question.question_type='single_choice'
    order by row_number() over(partition by question.lesson_id order by question.display_order,question.id),
      lesson.display_order,question.id limit 10
  ) selected;
  if selected_count<>10 or represented_targets<>2 then
    raise exception '9.7.2 Topic Quiz selection does not represent both enriched Lessons';
  end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists(select 1 from public.flashcard_reviews review left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists(select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id=progress.flashcard_id where card.id is null)
    or exists(select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id where attempt.id is null or question.id is null)
    or exists(select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id
      left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null) then
    raise exception '9.7.2 study history contains an orphan';
  end if;
  if exists(select 1 from pg_class relation join pg_namespace namespace on namespace.oid=relation.relnamespace
      where namespace.nspname='public'
        and relation.relname in('lessons','lesson_content_blocks','visual_experiences','flashcards','questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions','quiz_answers','flashcard_reviews','user_flashcard_progress')
        and not relation.relrowsecurity) then
    raise exception '9.7.2 requires RLS';
  end if;
  if has_table_privilege('authenticated','public.questions','SELECT')
    or has_table_privilege('authenticated','public.question_options','SELECT')
    or has_table_privilege('authenticated','public.lessons','UPDATE')
    or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or not has_table_privilege('authenticated','public.lessons','SELECT')
    or not has_table_privilege('authenticated','public.flashcards','SELECT')
    or not has_table_privilege('authenticated','public.lesson_content_blocks','SELECT') then
    raise exception '9.7.2 grants are invalid';
  end if;
end; $$;

commit;

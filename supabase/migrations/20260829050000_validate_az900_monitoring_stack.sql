begin;

do $$ declare r record; combined_text text; begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000004')<>6 then
    raise exception '9.7.3 changed Monitoring Lessons'; end if;
  for r in select id,slug,estimated_minutes from public.lessons where topic_id='33000000-0000-4000-8000-000000000004' loop
    if not exists(select 1 from public.lessons where id=r.id and is_published and content is not null and btrim(content)<>'')
      or r.estimated_minutes<>(case when r.slug in('azure-advisor','azure-service-health','azure-monitor','application-insights') then 12 else 10 end)
      or (select count(*) from public.lesson_content_blocks where lesson_id=r.id and is_published)<>(case r.slug
        when 'azure-advisor' then 11 when 'azure-service-health' then 12 when 'azure-monitor' then 11
        when 'log-analytics' then 8 when 'azure-monitor-alerts' then 8 else 10 end)
      or (select count(*) from public.flashcards where lesson_id=r.id and is_published)<>(case when r.slug='azure-advisor' then 7 when r.slug='azure-service-health' then 8 else 6 end)
      or (select count(*) from public.questions where lesson_id=r.id and is_published)<>(case when r.slug in('azure-advisor','application-insights') then 10 else 5 end)
      or (select count(*) from public.lesson_content_blocks where lesson_id=r.id and type='summary')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=r.id and type='exam_tip')<>1
      or (select count(*) from public.lesson_content_blocks where lesson_id=r.id and type='exam_trap')<1 then
      raise exception '9.7.3 invalid artifacts for %',r.slug; end if;
  end loop;
  if (select count(*) from public.lesson_content_blocks b join public.lessons l on l.id=b.lesson_id
      where l.topic_id='33000000-0000-4000-8000-000000000004' and b.is_published)<>60
    or (select count(*) from public.flashcards f join public.lessons l on l.id=f.lesson_id
      where l.topic_id='33000000-0000-4000-8000-000000000004' and f.is_published)<>39
    or (select count(*) from public.questions q where q.topic_id='33000000-0000-4000-8000-000000000004' and q.is_published)<>40 then
    raise exception '9.7.3 Topic totals invalid'; end if;
  if (select count(*) from public.visual_experiences v join public.lessons l on l.id=v.lesson_id
      where l.topic_id='33000000-0000-4000-8000-000000000004' and v.is_published)<>1
    or not exists(select 1 from public.visual_experiences where id='76000000-0000-4000-8000-000000000017'
      and type='architecture' and jsonb_array_length(config->'nodes')=8 and jsonb_array_length(config->'edges')=9)
    or not exists(select 1 from public.lesson_content_blocks where visual_experience_id='76000000-0000-4000-8000-000000000017'
      and type='visual_experience' and is_published) then
    raise exception '9.7.3 Visual Experience invalid'; end if;
  if exists(select 1 from public.questions q left join public.question_options o on o.question_id=q.id
      where q.topic_id='33000000-0000-4000-8000-000000000004' group by q.id
      having count(o.id)<>4 or count(o.id) filter(where o.is_correct)<>1
        or count(distinct lower(btrim(o.option_text)))<>4 or min(length(btrim(q.explanation)))<40) then
    raise exception '9.7.3 Questions or Options invalid'; end if;
  if (select count(*) from public.questions where id between '63000000-0000-4000-8000-000000000001' and '63000000-0000-4000-8000-000000000010')<>10
    or (select count(*) from public.question_options where id between '74000000-0000-4000-8000-000000000001' and '74000000-0000-4000-8000-000000000040')<>40 then
    raise exception '9.7.3 Application Insights UUIDs not preserved'; end if;
  select string_agg(x,' ') into combined_text from(
    select concat_ws(' ',b.title,b.content,b.config::text) x from public.lesson_content_blocks b join public.lessons l on l.id=b.lesson_id
      where l.topic_id='33000000-0000-4000-8000-000000000004' and l.slug in('azure-monitor','log-analytics','azure-monitor-alerts','application-insights')
    union all select concat_ws(' ',f.front_text,f.back_text) from public.flashcards f join public.lessons l on l.id=f.lesson_id
      where l.topic_id='33000000-0000-4000-8000-000000000004' and l.slug in('azure-monitor','log-analytics','azure-monitor-alerts','application-insights')
  ) a;
  if combined_text !~* 'coletar.*analisar.*responder' or combined_text !~* 'telemetria'
    or combined_text !~* 'valores numéricos' or combined_text !~* 'série temporal'
    or combined_text !~* 'Log Analytics' or combined_text !~* 'KQL'
    or combined_text !~* 'Signal.*Condition.*Alert' or combined_text !~* 'Notification.*Action'
    or combined_text !~* 'Application Performance Monitoring' or combined_text !~* 'requests'
    or combined_text !~* 'failures' or combined_text !~* 'response time' or combined_text !~* 'dependencies'
    or combined_text !~* 'Resource Health' or combined_text !~* 'Service Health' or combined_text !~* 'Advisor' then
    raise exception '9.7.3 required concepts incomplete'; end if;
  if combined_text ~* '(connection strings|OpenTelemetry configuration|diagnostic settings|alert processing rules|dynamic thresholds|sampling)' then
    raise exception '9.7.3 contains advanced out-of-scope content'; end if;
end; $$;

do $$ declare selected_count integer; represented integer; begin
  if exists(select 1 from public.lessons l where l.topic_id='33000000-0000-4000-8000-000000000004'
      and (select count(*) from public.questions q where q.lesson_id=l.id and q.is_published)<5) then
    raise exception '9.7.3 Lesson Quiz coverage invalid'; end if;
  select count(*),count(distinct lesson_id) into selected_count,represented from(
    select q.lesson_id from public.questions q join public.lessons l on l.id=q.lesson_id
    where q.topic_id='33000000-0000-4000-8000-000000000004' and q.is_published
    order by row_number() over(partition by q.lesson_id order by q.display_order,q.id),l.display_order,q.id limit 10
  ) s;
  if selected_count<>10 or represented<>6 then raise exception '9.7.3 Topic Quiz distribution invalid'; end if;
end; $$;

do $$ begin
  if exists(select 1 from public.user_lesson_progress p left join public.lessons l on l.id=p.lesson_id where l.id is null)
    or exists(select 1 from public.flashcard_reviews r left join public.flashcards f on f.id=r.flashcard_id where f.id is null)
    or exists(select 1 from public.user_flashcard_progress p left join public.flashcards f on f.id=p.flashcard_id where f.id is null)
    or exists(select 1 from public.quiz_attempt_questions i left join public.quiz_attempts a on a.id=i.attempt_id left join public.questions q on q.id=i.question_id where a.id is null or q.id is null)
    or exists(select 1 from public.quiz_answers x left join public.quiz_attempts a on a.id=x.attempt_id left join public.questions q on q.id=x.question_id left join public.question_options o on o.id=x.selected_option_id where a.id is null or q.id is null or o.id is null) then
    raise exception '9.7.3 orphan history'; end if;
  if exists(select 1 from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public'
      and c.relname in('lessons','lesson_content_blocks','visual_experiences','flashcards','questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions','quiz_answers','flashcard_reviews','user_flashcard_progress') and not c.relrowsecurity) then
    raise exception '9.7.3 requires RLS'; end if;
  if has_table_privilege('authenticated','public.lessons','UPDATE') or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or has_table_privilege('authenticated','public.visual_experiences','UPDATE') or has_table_privilege('authenticated','public.flashcards','UPDATE') then
    raise exception '9.7.3 grants invalid'; end if;
end; $$;

commit;

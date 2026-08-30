begin;

alter table public.questions
  add column mock_eligible boolean not null default false;

create index questions_mock_eligible_pool_idx
  on public.questions (certification_id, domain_id, topic_id, difficulty, id)
  where is_published = true and mock_eligible = true;

-- Minimal editorial baseline. A/B are approved; C/D remain available to study quizzes.
-- This deliberately does not change is_published or any existing Question/option UUID.
update public.questions question
set mock_eligible = (
  question.is_published
  and question.question_type = 'single_choice'
  and question.domain_id is not null
  and question.topic_id is not null
  and question.lesson_id is not null
  and question.difficulty in ('easy','medium','hard')
  and length(btrim(question.question_text)) >= 55
  and length(btrim(coalesce(question.explanation,''))) >= 80
  and (select count(*) from public.question_options option
       where option.question_id = question.id) = 4
  and (select count(*) from public.question_options option
       where option.question_id = question.id and option.is_correct) = 1
  and (select count(distinct lower(btrim(option.option_text)))
       from public.question_options option where option.question_id = question.id) = 4
  and not exists (
    select 1 from public.question_options option
    where option.question_id = question.id and length(btrim(option.option_text)) < 3
  )
)
where question.certification_id = (
  select certification.id from public.certifications certification where certification.code = 'az-900'
);

create function public.start_mock_exam_internal(
  p_certification_id uuid,
  p_seed text
)
returns setof public.mock_exam_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt public.mock_exam_attempts;
  v_attempt_id uuid := gen_random_uuid();
  v_seed text;
  v_position integer;
  v_question_id uuid;
  v_previous_attempt_id uuid;
  v_domain_allocation jsonb;
  v_difficulty_allocation jsonb;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  if not exists (
    select 1 from public.certifications certification
    where certification.id = p_certification_id
      and certification.code = 'az-900'
      and certification.is_enabled
  ) then
    raise exception 'AZ-900 certification not found or disabled.' using errcode = 'P0002';
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(v_user_id::text || ':' || p_certification_id::text, 11203)
  );

  select * into v_attempt
  from public.mock_exam_attempts attempt
  where attempt.user_id = v_user_id
    and attempt.certification_id = p_certification_id
    and attempt.status = 'in_progress'
  order by attempt.started_at desc, attempt.id
  limit 1;

  if found then
    return next v_attempt;
    return;
  end if;

  v_seed := coalesce(nullif(p_seed,''), v_attempt_id::text);

  drop table if exists pg_temp.mock_domain_targets;
  drop table if exists pg_temp.mock_topic_targets;
  drop table if exists pg_temp.mock_selected_questions;

  create temporary table mock_domain_targets (
    domain_id uuid primary key,
    domain_order integer not null,
    question_target integer not null,
    easy_target integer not null,
    medium_target integer not null,
    hard_target integer not null
  ) on commit drop;

  insert into mock_domain_targets
  select
    domain.id,
    domain.display_order,
    config.question_target,
    config.easy_target,
    config.medium_target,
    config.hard_target
  from public.domains domain
  join (values
    (1,11,3,6,2),
    (2,15,5,7,3),
    (3,14,4,7,3)
  ) config(domain_order,question_target,easy_target,medium_target,hard_target)
    on config.domain_order = domain.display_order
  where domain.certification_id = p_certification_id;

  if (select count(*) from mock_domain_targets) <> 3 then
    raise exception 'AZ-900 Mock configuration requires exactly three Domains.'
      using errcode = 'P0002';
  end if;

  if exists (
    select 1
    from mock_domain_targets target
    where (select count(*) from public.questions question
      where question.certification_id = p_certification_id
        and question.domain_id = target.domain_id
        and question.is_published
        and question.mock_eligible) < target.question_target
  ) then
    raise exception 'Mock Question Bank is insufficient for the configured Domain allocation.'
      using errcode = 'P0002';
  end if;

  select attempt.id into v_previous_attempt_id
  from public.mock_exam_attempts attempt
  where attempt.user_id = v_user_id
    and attempt.certification_id = p_certification_id
    and attempt.status in ('completed','abandoned','expired')
  order by coalesce(attempt.submitted_at,attempt.abandoned_at,attempt.expires_at,attempt.started_at) desc,
    attempt.id desc
  limit 1;

  create temporary table mock_topic_targets (
    topic_id uuid primary key,
    domain_id uuid not null,
    question_target integer not null
  ) on commit drop;

  insert into mock_topic_targets(topic_id,domain_id,question_target)
  with topic_history as (
    select
      topic.id as topic_id,
      topic.domain_id,
      target.question_target as domain_target,
      count(*) over (partition by topic.domain_id) as topic_count,
      count(distinct history_item.id) as historical_count,
      max(coalesce(history_attempt.submitted_at,history_attempt.abandoned_at,
        history_attempt.expires_at,history_attempt.started_at)) as last_used_at
    from public.topics topic
    join mock_domain_targets target on target.domain_id = topic.domain_id
    join public.questions eligible on eligible.topic_id = topic.id
      and eligible.certification_id = p_certification_id
      and eligible.is_published and eligible.mock_eligible
    left join public.mock_exam_attempt_questions history_item on history_item.topic_id = topic.id
    left join public.mock_exam_attempts history_attempt
      on history_attempt.id = history_item.attempt_id
      and history_attempt.user_id = v_user_id
      and history_attempt.certification_id = p_certification_id
      and history_attempt.status in ('completed','abandoned','expired')
    group by topic.id,topic.domain_id,target.question_target
  ), ranked as (
    select
      history.*,
      row_number() over (
        partition by history.domain_id
        order by history.historical_count,history.last_used_at nulls first,
          md5(v_seed || ':' || history.topic_id::text)
      ) as extra_rank
    from topic_history history
  )
  select
    ranked.topic_id,
    ranked.domain_id,
    floor(ranked.domain_target::numeric / ranked.topic_count)::integer
      + case when ranked.extra_rank <= ranked.domain_target % ranked.topic_count then 1 else 0 end
  from ranked;

  if exists (
    select 1 from mock_domain_targets domain_target
    where (select coalesce(sum(topic_target.question_target),0)
      from mock_topic_targets topic_target
      where topic_target.domain_id = domain_target.domain_id) <> domain_target.question_target
  ) then
    raise exception 'Mock Topic allocation does not match Domain allocation.' using errcode = 'P0002';
  end if;

  create temporary table mock_selected_questions (
    question_id uuid primary key,
    display_order integer not null unique
  ) on commit drop;

  for v_position in 1..40 loop
    select question.id into v_question_id
    from public.questions question
    join mock_domain_targets domain_target on domain_target.domain_id = question.domain_id
    join mock_topic_targets topic_target on topic_target.topic_id = question.topic_id
    left join lateral (
      select count(*)::integer as selected_count
      from mock_selected_questions selected
      join public.questions selected_question on selected_question.id = selected.question_id
      where selected_question.domain_id = question.domain_id
    ) domain_selection on true
    left join lateral (
      select count(*)::integer as selected_count
      from mock_selected_questions selected
      join public.questions selected_question on selected_question.id = selected.question_id
      where selected_question.topic_id = question.topic_id
    ) topic_selection on true
    left join lateral (
      select count(*)::integer as selected_count
      from mock_selected_questions selected
      join public.questions selected_question on selected_question.id = selected.question_id
      where selected_question.domain_id = question.domain_id
        and selected_question.difficulty = question.difficulty
    ) difficulty_selection on true
    left join lateral (
      select count(*)::integer as selected_count
      from mock_selected_questions selected
      join public.questions selected_question on selected_question.id = selected.question_id
      where selected_question.lesson_id = question.lesson_id
    ) lesson_selection on true
    left join lateral (
      select
        count(history_item.id)::integer as seen_count,
        max(coalesce(history_attempt.submitted_at,history_attempt.abandoned_at,
          history_attempt.expires_at,history_attempt.started_at)) as last_seen_at,
        coalesce(bool_or(history_attempt.id = v_previous_attempt_id),false) as in_previous_attempt
      from public.mock_exam_attempt_questions history_item
      join public.mock_exam_attempts history_attempt on history_attempt.id = history_item.attempt_id
      where history_item.question_id = question.id
        and history_attempt.user_id = v_user_id
        and history_attempt.certification_id = p_certification_id
        and history_attempt.status in ('completed','abandoned','expired')
    ) history on true
    where question.certification_id = p_certification_id
      and question.is_published
      and question.mock_eligible
      and not exists (
        select 1 from mock_selected_questions selected where selected.question_id = question.id
      )
      and domain_selection.selected_count < domain_target.question_target
    order by
      case when topic_selection.selected_count < topic_target.question_target then 0 else 1 end,
      topic_target.question_target - topic_selection.selected_count desc,
      case question.difficulty
        when 'easy' then case when difficulty_selection.selected_count < domain_target.easy_target then 0 else 1 end
        when 'medium' then case when difficulty_selection.selected_count < domain_target.medium_target then 0 else 1 end
        when 'hard' then case when difficulty_selection.selected_count < domain_target.hard_target then 0 else 1 end
        else 1
      end,
      case question.difficulty
        when 'easy' then domain_target.easy_target - difficulty_selection.selected_count
        when 'medium' then domain_target.medium_target - difficulty_selection.selected_count
        when 'hard' then domain_target.hard_target - difficulty_selection.selected_count
        else -1
      end desc,
      case when history.seen_count = 0 then 0 else 1 end,
      case when history.in_previous_attempt then 1 else 0 end,
      history.last_seen_at nulls first,
      lesson_selection.selected_count,
      md5(v_seed || ':' || question.id::text),
      question.id
    limit 1;

    if v_question_id is null then
      raise exception 'Mock selection stopped at Question % of 40.', v_position using errcode = 'P0002';
    end if;

    insert into mock_selected_questions(question_id,display_order)
    values (v_question_id,v_position);
  end loop;

  if (select count(*) from mock_selected_questions) <> 40 then
    raise exception 'Mock selection did not produce exactly 40 unique Questions.' using errcode = 'P0002';
  end if;

  select jsonb_object_agg(allocation.domain_id::text,allocation.question_count)
  into v_domain_allocation
  from (
    select question.domain_id,count(*)::integer as question_count
    from mock_selected_questions selected
    join public.questions question on question.id = selected.question_id
    group by question.domain_id
  ) allocation;

  select jsonb_object_agg(allocation.difficulty,allocation.question_count)
  into v_difficulty_allocation
  from (
    select question.difficulty,count(*)::integer as question_count
    from mock_selected_questions selected
    join public.questions question on question.id = selected.question_id
    group by question.difficulty
  ) allocation;

  insert into public.mock_exam_attempts(
    id,user_id,certification_id,total_questions,selection_policy_version,
    domain_allocation,difficulty_allocation
  ) values (
    v_attempt_id,v_user_id,p_certification_id,40,'az900-mock-v1',
    v_domain_allocation,v_difficulty_allocation
  ) returning * into v_attempt;

  insert into public.mock_exam_attempt_questions(
    attempt_id,question_id,display_order,domain_id,domain_title_snapshot,
    topic_id,topic_title_snapshot,lesson_id,lesson_title_snapshot,lesson_slug_snapshot,
    difficulty_snapshot,question_type_snapshot,question_text_snapshot,options_snapshot,
    correct_option_key,question_explanation_snapshot,question_source_updated_at,
    snapshot_schema_version
  )
  select
    v_attempt.id,question.id,selected.display_order,question.domain_id,domain.title,
    question.topic_id,topic.title,question.lesson_id,lesson.title,lesson.slug,
    question.difficulty,question.question_type,question.question_text,options.options_snapshot,
    options.correct_option_key,question.explanation,question.updated_at,1
  from mock_selected_questions selected
  join public.questions question on question.id = selected.question_id
  join public.domains domain on domain.id = question.domain_id
  join public.topics topic on topic.id = question.topic_id
  join public.lessons lesson on lesson.id = question.lesson_id
  join lateral (
    select
      jsonb_agg(
        jsonb_build_object(
          'key',option.id::text,
          'sourceOptionId',option.id::text,
          'text',option.option_text,
          'explanation',option.explanation,
          'displayOrder',option.display_order
        ) order by option.display_order,option.id
      ) as options_snapshot,
      min(option.id::text) filter (where option.is_correct) as correct_option_key
    from public.question_options option
    where option.question_id = question.id
  ) options on true
  order by selected.display_order;

  if (select count(*) from public.mock_exam_attempt_questions item
      where item.attempt_id = v_attempt.id) <> 40 then
    raise exception 'Mock snapshot persistence was incomplete.' using errcode = 'P0002';
  end if;

  return next v_attempt;
end;
$$;

create function public.start_mock_exam(p_certification_id uuid)
returns setof public.mock_exam_attempts
language sql
security definer
set search_path = ''
as $$
  select * from public.start_mock_exam_internal(p_certification_id,null);
$$;

revoke execute on function public.start_mock_exam_internal(uuid,text) from public,anon,authenticated;
revoke execute on function public.start_mock_exam(uuid) from public,anon;
grant execute on function public.start_mock_exam(uuid) to authenticated;

commit;

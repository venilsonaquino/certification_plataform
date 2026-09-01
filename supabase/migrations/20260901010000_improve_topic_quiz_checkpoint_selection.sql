begin;

do $$
begin
  if to_regprocedure('public.start_topic_quiz(uuid)') is null
    or to_regprocedure('public.start_topic_quiz_unchecked(uuid)') is null
    or to_regprocedure('public.get_topic_quiz_summaries(uuid)') is null then
    raise exception '13.5.2.1 requires the existing Topic Checkpoint contracts';
  end if;
end;
$$;

alter table public.quiz_attempts
  drop constraint quiz_attempts_total_questions_check,
  add constraint quiz_attempts_total_questions_check
    check (total_questions between 1 and 20);

create or replace function public.calculate_topic_checkpoint_size(
  p_lesson_count integer,
  p_pool_count integer
)
returns integer
language sql
immutable
set search_path = ''
as $$
  select case
    when coalesce(p_lesson_count, 0) <= 0 or coalesce(p_pool_count, 0) <= 0 then 0
    else least(
      p_pool_count,
      case
        when p_lesson_count <= 3 then 12
        when p_lesson_count <= 5 then 15
        else 20
      end
    )
  end;
$$;

revoke execute on function public.calculate_topic_checkpoint_size(integer, integer)
  from public, anon, authenticated;

create or replace function public.start_topic_quiz_unchecked(p_topic_id uuid)
returns setof public.quiz_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_certification_id uuid;
  v_lesson_count integer;
  v_pool_count integer;
  v_total integer;
  v_attempt public.quiz_attempts;
  v_last_attempt_id uuid;
  v_selected_ids uuid[] := array[]::uuid[];
  v_question_id uuid;
  v_position integer;
  v_target_easy integer;
  v_target_medium integer;
  v_target_hard integer;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  -- Active attempts are immutable snapshots of their original size. A legacy
  -- ten-question Checkpoint is resumed instead of being recreated.
  select attempt.* into v_attempt
  from public.quiz_attempts attempt
  where attempt.user_id = v_user_id
    and attempt.quiz_type = 'topic'
    and attempt.topic_id = p_topic_id
    and attempt.status = 'in_progress'
  order by attempt.started_at desc, attempt.id desc
  limit 1;

  if found then
    return next v_attempt;
    return;
  end if;

  select domain.certification_id into v_certification_id
  from public.topics topic
  join public.domains domain on domain.id = topic.domain_id
  where topic.id = p_topic_id;

  if v_certification_id is null then
    raise exception 'Topic not found.' using errcode = 'P0002';
  end if;

  select count(*)::integer into v_lesson_count
  from public.lessons lesson
  where lesson.topic_id = p_topic_id
    and lesson.is_published = true;

  select count(*)::integer into v_pool_count
  from public.questions question
  left join public.lessons lesson
    on lesson.id = question.lesson_id
   and lesson.topic_id = p_topic_id
   and lesson.is_published = true
  where question.topic_id = p_topic_id
    and question.is_published = true
    and question.question_type = 'single_choice'
    and (question.lesson_id is null or lesson.id is not null);

  v_total := public.calculate_topic_checkpoint_size(v_lesson_count, v_pool_count);

  if v_total = 0 then
    raise exception 'No published questions are available for this topic.' using errcode = 'P0002';
  end if;

  -- Preserve the current 30% easy / 50% medium / 20% hard intent. Rotation
  -- has priority when unseen Questions are available, so constrained retakes
  -- may relax the exact mix instead of repeating a recently seen Question.
  v_target_hard := floor(v_total * 0.20)::integer;
  v_target_medium := floor(v_total * 0.50)::integer;
  v_target_easy := v_total - v_target_medium - v_target_hard;

  select attempt.id into v_last_attempt_id
  from public.quiz_attempts attempt
  where attempt.user_id = v_user_id
    and attempt.quiz_type = 'topic'
    and attempt.topic_id = p_topic_id
    and attempt.status = 'completed'
  order by attempt.completed_at desc nulls last, attempt.started_at desc, attempt.id desc
  limit 1;

  for v_position in 1..v_total loop
    select question.id into v_question_id
    from public.questions question
    left join public.lessons lesson
      on lesson.id = question.lesson_id
     and lesson.topic_id = p_topic_id
     and lesson.is_published = true
    left join lateral (
      select
        count(history_item.id)::integer as seen_count,
        max(coalesce(history_attempt.completed_at, history_attempt.started_at)) as last_seen_at,
        coalesce(bool_or(history_attempt.id = v_last_attempt_id), false) as in_last_attempt
      from public.quiz_attempt_questions history_item
      join public.quiz_attempts history_attempt on history_attempt.id = history_item.attempt_id
      where history_item.question_id = question.id
        and history_attempt.user_id = v_user_id
        and history_attempt.quiz_type = 'topic'
        and history_attempt.topic_id = p_topic_id
        and history_attempt.status = 'completed'
    ) history on true
    left join lateral (
      select
        count(*) filter (where selected_question.lesson_id = question.lesson_id)::integer
          as lesson_selected,
        count(*) filter (where selected_question.difficulty = 'easy')::integer
          as easy_selected,
        count(*) filter (where selected_question.difficulty = 'medium')::integer
          as medium_selected,
        count(*) filter (where selected_question.difficulty = 'hard')::integer
          as hard_selected
      from public.questions selected_question
      where selected_question.id = any(v_selected_ids)
    ) selection on true
    where question.topic_id = p_topic_id
      and question.is_published = true
      and question.question_type = 'single_choice'
      and (question.lesson_id is null or lesson.id is not null)
      and not (question.id = any(v_selected_ids))
    order by
      -- Reserve one slot for every published Lesson that has an eligible pool.
      case
        when question.lesson_id is not null and selection.lesson_selected = 0 then 0
        when question.lesson_id is not null then 1
        else 2
      end,
      -- Within coverage, use the complete user history: unseen, then least recent.
      case when history.seen_count = 0 then 0 else 1 end,
      case when history.in_last_attempt then 1 else 0 end,
      history.last_seen_at asc nulls first,
      -- For equal rotation history, keep represented Lesson pools balanced.
      selection.lesson_selected,
      -- Difficulty remains a best-effort tie-breaker inside the rotation tier.
      case question.difficulty
        when 'easy' then case when selection.easy_selected < v_target_easy then 0 else 1 end
        when 'medium' then case when selection.medium_selected < v_target_medium then 0 else 1 end
        when 'hard' then case when selection.hard_selected < v_target_hard then 0 else 1 end
        else 1
      end,
      case question.difficulty
        when 'easy' then v_target_easy - selection.easy_selected
        when 'medium' then v_target_medium - selection.medium_selected
        when 'hard' then v_target_hard - selection.hard_selected
        else -1
      end desc,
      coalesce(lesson.display_order, 2147483647),
      question.display_order,
      question.id
    limit 1;

    if v_question_id is null then
      raise exception 'Topic Checkpoint selection stopped before reaching % Questions.', v_total;
    end if;

    v_selected_ids := array_append(v_selected_ids, v_question_id);
  end loop;

  begin
    insert into public.quiz_attempts
      (user_id, certification_id, quiz_type, topic_id, total_questions)
    values
      (v_user_id, v_certification_id, 'topic', p_topic_id, v_total)
    returning * into v_attempt;
  exception when unique_violation then
    select attempt.* into strict v_attempt
    from public.quiz_attempts attempt
    where attempt.user_id = v_user_id
      and attempt.quiz_type = 'topic'
      and attempt.topic_id = p_topic_id
      and attempt.status = 'in_progress';
    return next v_attempt;
    return;
  end;

  insert into public.quiz_attempt_questions (attempt_id, question_id, display_order)
  select v_attempt.id, selected.question_id, selected.ordinality::integer
  from unnest(v_selected_ids) with ordinality as selected(question_id, ordinality);

  return next v_attempt;
end;
$$;

revoke execute on function public.start_topic_quiz_unchecked(uuid)
  from public, anon, authenticated;

drop function public.get_topic_quiz_summaries(uuid);

create function public.get_topic_quiz_summaries(p_certification_id uuid)
returns table (
  topic_id uuid,
  question_count bigint,
  target_question_count integer,
  active_attempt_id uuid,
  active_total_questions integer,
  active_answered_count bigint,
  last_score_percentage numeric
)
language sql
security definer
set search_path = ''
stable
as $$
  select
    topic.id,
    catalog.pool_count,
    public.calculate_topic_checkpoint_size(catalog.lesson_count, catalog.pool_count::integer),
    active.id,
    active.total_questions,
    (select count(*) from public.quiz_answers answer where answer.attempt_id = active.id),
    completed.score_percentage
  from public.topics topic
  join public.domains domain on domain.id = topic.domain_id
  cross join lateral (
    select
      (select count(*)::integer
       from public.lessons lesson
       where lesson.topic_id = topic.id and lesson.is_published = true) as lesson_count,
      (select count(*)
       from public.questions question
       left join public.lessons lesson
         on lesson.id = question.lesson_id
        and lesson.topic_id = topic.id
        and lesson.is_published = true
       where question.topic_id = topic.id
         and question.is_published = true
         and question.question_type = 'single_choice'
         and (question.lesson_id is null or lesson.id is not null)) as pool_count
  ) catalog
  left join lateral (
    select attempt.id, attempt.total_questions
    from public.quiz_attempts attempt
    where attempt.user_id = auth.uid() and attempt.quiz_type = 'topic'
      and attempt.topic_id = topic.id and attempt.status = 'in_progress'
    order by attempt.started_at desc limit 1
  ) active on true
  left join lateral (
    select attempt.score_percentage
    from public.quiz_attempts attempt
    where attempt.user_id = auth.uid() and attempt.quiz_type = 'topic'
      and attempt.topic_id = topic.id and attempt.status = 'completed'
    order by attempt.completed_at desc limit 1
  ) completed on true
  where domain.certification_id = p_certification_id;
$$;

revoke execute on function public.get_topic_quiz_summaries(uuid) from public, anon;
grant execute on function public.get_topic_quiz_summaries(uuid) to authenticated;

do $$
declare
  function_source text;
begin
  if public.calculate_topic_checkpoint_size(1, 100) <> 12
    or public.calculate_topic_checkpoint_size(2, 100) <> 12
    or public.calculate_topic_checkpoint_size(3, 100) <> 12
    or public.calculate_topic_checkpoint_size(4, 100) <> 15
    or public.calculate_topic_checkpoint_size(5, 100) <> 15
    or public.calculate_topic_checkpoint_size(6, 100) <> 20
    or public.calculate_topic_checkpoint_size(8, 100) <> 20
    or public.calculate_topic_checkpoint_size(5, 11) <> 11
    or public.calculate_topic_checkpoint_size(3, 0) <> 0 then
    raise exception '13.5.2.1 dynamic sizing rule is invalid';
  end if;

  select pg_get_functiondef('public.start_topic_quiz_unchecked(uuid)'::regprocedure)
    into function_source;
  if function_source not like '%calculate_topic_checkpoint_size%'
    or function_source not like '%history.seen_count%'
    or function_source not like '%history.in_last_attempt%'
    or function_source not like '%selection.lesson_selected%'
    or function_source not like '%question.lesson_id is null%' then
    raise exception '13.5.2.1 selection source is missing sizing, coverage or rotation rules';
  end if;

  if has_function_privilege('anon','public.start_topic_quiz(uuid)','EXECUTE')
    or has_function_privilege('anon','public.get_topic_quiz_summaries(uuid)','EXECUTE')
    or has_function_privilege('authenticated','public.start_topic_quiz_unchecked(uuid)','EXECUTE')
    or not has_function_privilege('authenticated','public.start_topic_quiz(uuid)','EXECUTE')
    or not has_function_privilege('authenticated','public.get_topic_quiz_summaries(uuid)','EXECUTE') then
    raise exception '13.5.2.1 Topic Checkpoint grants are invalid';
  end if;
end;
$$;

commit;

-- Runtime validator. All fixture history is rolled back.
begin;
set local statement_timeout = '10min';

create temporary table audit_13521_topics on commit drop as
select
  topic.id,
  topic.title,
  count(distinct lesson.id)::integer as lesson_count,
  count(distinct lesson.id) filter (where question.id is not null)::integer
    as lessons_with_pool,
  count(distinct question.id)::integer as pool_count,
  public.calculate_topic_checkpoint_size(
    count(distinct lesson.id)::integer,
    count(distinct question.id)::integer
  ) as target_count
from public.topics topic
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
left join public.lessons lesson
  on lesson.topic_id = topic.id and lesson.is_published = true
left join public.questions question
  on question.topic_id = topic.id
 and question.lesson_id = lesson.id
 and question.is_published = true
 and question.question_type = 'single_choice'
where certification.code = 'az-900'
group by topic.id, topic.title;

create temporary table audit_13521_items (
  topic_id uuid not null,
  attempt_no integer not null,
  attempt_id uuid not null,
  question_id uuid not null,
  lesson_id uuid,
  difficulty text,
  primary key (topic_id, attempt_no, question_id)
) on commit drop;

do $$
begin
  if (select count(*) from audit_13521_topics) <> 12 then
    raise exception '13.5.2.1 expected all twelve AZ-900 Topics';
  end if;
  if exists (select 1 from audit_13521_topics where pool_count = 0 or target_count = 0) then
    raise exception '13.5.2.1 found a Topic without an eligible Checkpoint pool';
  end if;
end;
$$;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values
  ('00000000-0000-0000-0000-000000000000','58000000-0000-4000-8000-000000000061',
   'authenticated','authenticated','checkpoint-sizing-a@example.invalid','',now(),
   '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()),
  ('00000000-0000-0000-0000-000000000000','58000000-0000-4000-8000-000000000062',
   'authenticated','authenticated','checkpoint-sizing-b@example.invalid','',now(),
   '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now());

-- Uneven fixture: ten Questions in one Lesson, one in another and zero in the
-- third. The small pool must be represented and the empty Lesson cannot block.
insert into public.topics(id,domain_id,title,display_order)
select '5a000000-0000-4000-8000-000000000061', domain.id,
  '13.5.2.1 uneven fixture', 2147483000
from public.domains domain
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
order by domain.display_order
limit 1;

insert into public.lessons(id,topic_id,slug,title,display_order,is_published)
values
  ('5b000000-0000-4000-8000-000000000061','5a000000-0000-4000-8000-000000000061','audit-uneven-large','Audit uneven large',1,true),
  ('5b000000-0000-4000-8000-000000000062','5a000000-0000-4000-8000-000000000061','audit-uneven-small','Audit uneven small',2,true),
  ('5b000000-0000-4000-8000-000000000063','5a000000-0000-4000-8000-000000000061','audit-empty-pool','Audit empty pool',3,true);

insert into public.questions(
  certification_id,domain_id,topic_id,lesson_id,question_text,
  question_type,difficulty,is_published,display_order
)
select domain.certification_id, domain.id,
  '5a000000-0000-4000-8000-000000000061',
  '5b000000-0000-4000-8000-000000000061',
  '13.5.2.1 uneven large Question ' || series.number,
  'single_choice',
  case series.number % 3 when 0 then 'hard' when 1 then 'easy' else 'medium' end,
  true, series.number
from public.domains domain
join public.certifications certification on certification.id = domain.certification_id
cross join generate_series(1,10) as series(number)
where certification.code = 'az-900'
order by domain.display_order
limit 10;

insert into public.questions(
  certification_id,domain_id,topic_id,lesson_id,question_text,
  question_type,difficulty,is_published,display_order
)
select domain.certification_id, domain.id,
  '5a000000-0000-4000-8000-000000000061',
  '5b000000-0000-4000-8000-000000000062',
  '13.5.2.1 uneven small Question', 'single_choice', 'medium', true, 1
from public.domains domain
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
order by domain.display_order
limit 1;

insert into public.user_lesson_progress
  (user_id, lesson_id, status, started_at, completed_at, last_accessed_at)
select '58000000-0000-4000-8000-000000000061', lesson.id, 'completed', now(), now(), now()
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900' and lesson.is_published = true;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000061',true);

do $$
declare
  topic_row record;
  attempt_one public.quiz_attempts;
  attempt_again public.quiz_attempts;
  attempt_two public.quiz_attempts;
  attempt_three public.quiz_attempts;
  uneven_attempt public.quiz_attempts;
  network_topic_id uuid;
  benefits_topic_id uuid;
begin
  for topic_row in select * from audit_13521_topics order by title loop
    select * into strict attempt_one from public.start_topic_quiz(topic_row.id);
    select * into strict attempt_again from public.start_topic_quiz(topic_row.id);

    if attempt_one.id <> attempt_again.id
      or attempt_one.total_questions <> topic_row.target_count then
      raise exception '13.5.2.1 size/active behavior failed for %', topic_row.title;
    end if;

    insert into audit_13521_items
    select topic_row.id, 1, attempt_one.id, question.id, question.lesson_id,
      question.difficulty
    from public.quiz_attempt_questions item
    join public.questions question on question.id = item.question_id
    where item.attempt_id = attempt_one.id;

    if (select count(*) from audit_13521_items item
        where item.topic_id = topic_row.id and item.attempt_no = 1)
        <> topic_row.target_count
      or (select count(distinct item.question_id) from audit_13521_items item
        where item.topic_id = topic_row.id and item.attempt_no = 1)
        <> topic_row.target_count then
      raise exception '13.5.2.1 duplicate or missing Question for %', topic_row.title;
    end if;

    if (select count(distinct item.lesson_id) from audit_13521_items item
        where item.topic_id = topic_row.id and item.attempt_no = 1
          and item.lesson_id is not null)
        <> least(topic_row.lessons_with_pool, topic_row.target_count) then
      raise exception '13.5.2.1 Lesson coverage failed for %', topic_row.title;
    end if;

    if exists (
      select 1
      from audit_13521_items item
      join public.questions question on question.id = item.question_id
      left join public.lessons lesson on lesson.id = question.lesson_id
      where item.topic_id = topic_row.id and item.attempt_no = 1
        and (question.topic_id <> topic_row.id or not question.is_published
          or question.question_type <> 'single_choice'
          or (question.lesson_id is not null
            and (lesson.id is null or lesson.topic_id <> topic_row.id or not lesson.is_published)))
    ) then
      raise exception '13.5.2.1 eligibility/scope failed for %', topic_row.title;
    end if;

    if exists (
      select 1 from (
        select count(*) as amount
        from audit_13521_items item
        where item.topic_id = topic_row.id and item.attempt_no = 1
          and item.lesson_id is not null
        group by item.lesson_id
      ) distribution
      having max(amount) - min(amount) > 1
    ) then
      raise exception '13.5.2.1 Lesson distribution is not balanced for %', topic_row.title;
    end if;

    update public.quiz_attempts
    set status = 'completed', completed_at = clock_timestamp(), updated_at = clock_timestamp()
    where id = attempt_one.id;
  end loop;

  select * into strict uneven_attempt
  from public.start_topic_quiz('5a000000-0000-4000-8000-000000000061');

  if uneven_attempt.total_questions <> 11
    or (select count(distinct question.lesson_id)
        from public.quiz_attempt_questions item
        join public.questions question on question.id = item.question_id
        where item.attempt_id = uneven_attempt.id) <> 2
    or not exists (
      select 1
      from public.quiz_attempt_questions item
      join public.questions question on question.id = item.question_id
      where item.attempt_id = uneven_attempt.id
        and question.lesson_id = '5b000000-0000-4000-8000-000000000062'
    ) then
    raise exception '13.5.2.1 uneven or zero-Question Lesson behavior failed';
  end if;

  select id into strict network_topic_id
  from audit_13521_topics where lesson_count = 5 and pool_count = 30;
  select * into strict attempt_two from public.start_topic_quiz(network_topic_id);
  insert into audit_13521_items
  select network_topic_id, 2, attempt_two.id, question.id, question.lesson_id,
    question.difficulty
  from public.quiz_attempt_questions item
  join public.questions question on question.id = item.question_id
  where item.attempt_id = attempt_two.id;

  if attempt_two.total_questions <> 15
    or exists (
      select 1 from audit_13521_items first_item
      join audit_13521_items second_item
        on second_item.topic_id = first_item.topic_id
       and second_item.attempt_no = 2
       and second_item.question_id = first_item.question_id
      where first_item.topic_id = network_topic_id and first_item.attempt_no = 1
    ) then
    raise exception '13.5.2.1 5-Lesson retake did not achieve zero overlap';
  end if;
  update public.quiz_attempts
  set status = 'completed', completed_at = clock_timestamp(), updated_at = clock_timestamp()
  where id = attempt_two.id;

  select id into strict benefits_topic_id
  from audit_13521_topics where lesson_count = 7 and pool_count = 61;
  select * into strict attempt_two from public.start_topic_quiz(benefits_topic_id);
  insert into audit_13521_items
  select benefits_topic_id, 2, attempt_two.id, question.id, question.lesson_id,
    question.difficulty
  from public.quiz_attempt_questions item
  join public.questions question on question.id = item.question_id
  where item.attempt_id = attempt_two.id;
  update public.quiz_attempts
  set status = 'completed', completed_at = clock_timestamp(), updated_at = clock_timestamp()
  where id = attempt_two.id;

  select * into strict attempt_three from public.start_topic_quiz(benefits_topic_id);
  insert into audit_13521_items
  select benefits_topic_id, 3, attempt_three.id, question.id, question.lesson_id,
    question.difficulty
  from public.quiz_attempt_questions item
  join public.questions question on question.id = item.question_id
  where item.attempt_id = attempt_three.id;

  if attempt_two.total_questions <> 20 or attempt_three.total_questions <> 20
    or (select count(distinct item.question_id)
        from audit_13521_items item
        where item.topic_id = benefits_topic_id and item.attempt_no = 3) <> 20
    or (select count(distinct item.lesson_id)
        from audit_13521_items item
        where item.topic_id = benefits_topic_id and item.attempt_no = 3
          and item.lesson_id is not null) <> 7
    or (select count(*)
        from audit_13521_items current_item
        where current_item.topic_id = benefits_topic_id
          and current_item.attempt_no = 3
          and not exists (
            select 1 from audit_13521_items prior
            where prior.topic_id = benefits_topic_id
              and prior.attempt_no in (1, 2)
              and prior.question_id = current_item.question_id
          )) < 13
    or exists (
      select 1 from audit_13521_items current_item
      where current_item.topic_id = benefits_topic_id
        and current_item.attempt_no = 3
        and exists (
          select 1 from audit_13521_items prior
          where prior.topic_id = benefits_topic_id
            and prior.attempt_no in (1, 2)
            and prior.question_id = current_item.question_id
        )
        and exists (
          select 1
          from public.questions alternative
          where alternative.topic_id = benefits_topic_id
            and alternative.lesson_id = current_item.lesson_id
            and alternative.is_published = true
            and alternative.question_type = 'single_choice'
            and not exists (
              select 1 from audit_13521_items prior
              where prior.topic_id = benefits_topic_id
                and prior.attempt_no in (1, 2)
                and prior.question_id = alternative.id
            )
        )
    ) then
    raise exception '13.5.2.1 full-history third-attempt coverage/rotation failed';
  end if;
end;
$$;

-- A pre-existing in-progress attempt keeps its original ten-question snapshot.
insert into public.quiz_attempts
  (id,user_id,certification_id,quiz_type,topic_id,status,total_questions,started_at)
select
  '59000000-0000-4000-8000-000000000061',
  '58000000-0000-4000-8000-000000000062',
  domain.certification_id,
  'topic', topic.id, 'in_progress', 10, now()
from public.topics topic
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
order by domain.display_order, topic.display_order
limit 1;

insert into public.quiz_attempt_questions(attempt_id,question_id,display_order)
select
  '59000000-0000-4000-8000-000000000061',
  question.id,
  row_number() over(order by question.display_order,question.id)::integer
from public.questions question
where question.topic_id = (
  select topic_id from public.quiz_attempts
  where id = '59000000-0000-4000-8000-000000000061'
)
  and question.is_published = true
  and question.question_type = 'single_choice'
order by question.display_order, question.id
limit 10;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000062',true);

do $$
declare
  resumed public.quiz_attempts;
begin
  select * into strict resumed from public.start_topic_quiz((
    select topic_id from public.quiz_attempts
    where id = '59000000-0000-4000-8000-000000000061'
  ));
  if resumed.id <> '59000000-0000-4000-8000-000000000061'
    or resumed.total_questions <> 10 then
    raise exception '13.5.2.1 legacy active attempt was not resumed intact';
  end if;
end;
$$;

rollback;

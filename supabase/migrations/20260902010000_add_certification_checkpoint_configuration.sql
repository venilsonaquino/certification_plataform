begin;

create table public.certification_checkpoint_policies (
  id uuid primary key default gen_random_uuid(),
  certification_id uuid not null references public.certifications(id) on delete cascade,
  policy_version text not null,
  is_active boolean not null default false,
  is_enabled boolean not null default false,
  eligible_question_types text[] not null,
  clamp_to_eligible_pool boolean not null default true,
  require_lesson_coverage boolean not null default true,
  rotation_strategy text not null,
  penalize_previous_attempt boolean not null default true,
  easy_weight numeric(6,5) not null,
  medium_weight numeric(6,5) not null,
  hard_weight numeric(6,5) not null,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint certification_checkpoint_policies_version_unique
    unique (certification_id, policy_version),
  constraint certification_checkpoint_policies_version_not_blank
    check (btrim(policy_version) <> ''),
  constraint certification_checkpoint_policies_question_types_check
    check (
      cardinality(eligible_question_types) > 0
      and eligible_question_types <@ array['single_choice']::text[]
    ),
  constraint certification_checkpoint_policies_rotation_check
    check (rotation_strategy = 'unseen_then_least_recent'),
  constraint certification_checkpoint_policies_weights_check
    check (
      easy_weight between 0 and 1
      and medium_weight between 0 and 1
      and hard_weight between 0 and 1
      and easy_weight + medium_weight + hard_weight = 1
    )
);

create unique index certification_checkpoint_policies_one_active_idx
  on public.certification_checkpoint_policies (certification_id)
  where is_active;

create table public.certification_checkpoint_sizing_brackets (
  id uuid primary key default gen_random_uuid(),
  policy_id uuid not null references public.certification_checkpoint_policies(id) on delete cascade,
  minimum_lessons integer not null,
  maximum_lessons integer,
  question_count integer not null,
  created_at timestamptz not null default now(),
  constraint certification_checkpoint_sizing_brackets_minimum_unique
    unique (policy_id, minimum_lessons),
  constraint certification_checkpoint_sizing_brackets_minimum_check
    check (minimum_lessons > 0),
  constraint certification_checkpoint_sizing_brackets_range_check
    check (maximum_lessons is null or maximum_lessons >= minimum_lessons),
  constraint certification_checkpoint_sizing_brackets_question_count_check
    check (question_count between 1 and 20)
);

create unique index certification_checkpoint_sizing_brackets_one_open_idx
  on public.certification_checkpoint_sizing_brackets (policy_id)
  where maximum_lessons is null;

create function public.validate_checkpoint_sizing_brackets()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_policy_id uuid;
  v_requires_complete_policy boolean;
begin
  if tg_table_name = 'certification_checkpoint_policies' then
    v_policy_id := case when tg_op = 'DELETE' then old.id else new.id end;
  else
    v_policy_id := case when tg_op = 'DELETE' then old.policy_id else new.policy_id end;
  end if;

  select policy.is_active and policy.is_enabled
  into v_requires_complete_policy
  from public.certification_checkpoint_policies policy
  where policy.id = v_policy_id;

  if not coalesce(v_requires_complete_policy, false) then
    if tg_op = 'DELETE' then return old; end if;
    return new;
  end if;

  if not exists (
    select 1
    from public.certification_checkpoint_sizing_brackets bracket
    where bracket.policy_id = v_policy_id
      and bracket.minimum_lessons = 1
  ) or (
    select count(*)
    from public.certification_checkpoint_sizing_brackets bracket
    where bracket.policy_id = v_policy_id
      and bracket.maximum_lessons is null
  ) <> 1 then
    raise exception 'Active Checkpoint sizing must start at one and have one open-ended bracket.'
      using errcode = '23514';
  end if;

  if exists (
    with ordered as (
      select
        bracket.minimum_lessons,
        bracket.maximum_lessons,
        lag(bracket.maximum_lessons) over (order by bracket.minimum_lessons) as previous_maximum
      from public.certification_checkpoint_sizing_brackets bracket
      where bracket.policy_id = v_policy_id
    )
    select 1
    from ordered
    where previous_maximum is not null
      and minimum_lessons <> previous_maximum + 1
  ) or exists (
    select 1
    from public.certification_checkpoint_sizing_brackets open_bracket
    join public.certification_checkpoint_sizing_brackets later_bracket
      on later_bracket.policy_id = open_bracket.policy_id
     and later_bracket.minimum_lessons > open_bracket.minimum_lessons
    where open_bracket.policy_id = v_policy_id
      and open_bracket.maximum_lessons is null
  ) then
    raise exception 'Active Checkpoint sizing brackets must be ordered, contiguous and non-overlapping.'
      using errcode = '23514';
  end if;

  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;

create function public.protect_checkpoint_policy_version()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_published_at timestamptz;
begin
  if tg_table_name = 'certification_checkpoint_policies' then
    if tg_op = 'INSERT' then
      if new.is_active or new.published_at is not null then
        raise exception 'Create Checkpoint policies inactive, add their brackets, then activate them.'
          using errcode = '23514';
      end if;
      return new;
    end if;

    if old.published_at is not null and (
      new.certification_id,
      new.policy_version,
      new.eligible_question_types,
      new.clamp_to_eligible_pool,
      new.require_lesson_coverage,
      new.rotation_strategy,
      new.penalize_previous_attempt,
      new.easy_weight,
      new.medium_weight,
      new.hard_weight,
      new.published_at
    ) is distinct from (
      old.certification_id,
      old.policy_version,
      old.eligible_question_types,
      old.clamp_to_eligible_pool,
      old.require_lesson_coverage,
      old.rotation_strategy,
      old.penalize_previous_attempt,
      old.easy_weight,
      old.medium_weight,
      old.hard_weight,
      old.published_at
    ) then
      raise exception 'Published Checkpoint policy definitions are immutable; create a new version.'
        using errcode = '23514';
    end if;

    if new.is_active and new.published_at is null then
      new.published_at := now();
    end if;

    return new;
  end if;

  select policy.published_at into v_published_at
  from public.certification_checkpoint_policies policy
  where policy.id = case when tg_op = 'DELETE' then old.policy_id else new.policy_id end;

  if v_published_at is not null then
    raise exception 'Published Checkpoint sizing brackets are immutable; create a new policy version.'
      using errcode = '23514';
  end if;

  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;

create trigger certification_checkpoint_policy_protect_version
before insert or update on public.certification_checkpoint_policies
for each row execute function public.protect_checkpoint_policy_version();

create trigger certification_checkpoint_bracket_protect_version
before insert or update or delete on public.certification_checkpoint_sizing_brackets
for each row execute function public.protect_checkpoint_policy_version();

create constraint trigger certification_checkpoint_policy_validate_sizing
after insert or update on public.certification_checkpoint_policies
deferrable initially deferred
for each row execute function public.validate_checkpoint_sizing_brackets();

create constraint trigger certification_checkpoint_bracket_validate_sizing
after insert or update or delete on public.certification_checkpoint_sizing_brackets
deferrable initially deferred
for each row execute function public.validate_checkpoint_sizing_brackets();

create trigger certification_checkpoint_policies_set_updated_at
before update on public.certification_checkpoint_policies
for each row execute function public.set_updated_at();

alter table public.certification_checkpoint_policies enable row level security;
alter table public.certification_checkpoint_sizing_brackets enable row level security;

revoke all on table public.certification_checkpoint_policies from public, anon, authenticated;
revoke all on table public.certification_checkpoint_sizing_brackets from public, anon, authenticated;
revoke execute on function public.validate_checkpoint_sizing_brackets()
  from public, anon, authenticated;
revoke execute on function public.protect_checkpoint_policy_version()
  from public, anon, authenticated;

insert into public.certification_checkpoint_policies (
  id,
  certification_id,
  policy_version,
  is_active,
  is_enabled,
  eligible_question_types,
  clamp_to_eligible_pool,
  require_lesson_coverage,
  rotation_strategy,
  penalize_previous_attempt,
  easy_weight,
  medium_weight,
  hard_weight
)
values (
  '91000000-0000-4000-8000-000000000001',
  (select id from public.certifications where code = 'az-900'),
  'az900-checkpoint-v1',
  false,
  true,
  array['single_choice']::text[],
  true,
  true,
  'unseen_then_least_recent',
  true,
  0.30,
  0.50,
  0.20
);

insert into public.certification_checkpoint_sizing_brackets (
  id, policy_id, minimum_lessons, maximum_lessons, question_count
)
values
  ('92000000-0000-4000-8000-000000000001', '91000000-0000-4000-8000-000000000001', 1, 3, 12),
  ('92000000-0000-4000-8000-000000000002', '91000000-0000-4000-8000-000000000001', 4, 5, 15),
  ('92000000-0000-4000-8000-000000000003', '91000000-0000-4000-8000-000000000001', 6, null, 20);

update public.certification_checkpoint_policies
set is_active = true
where id = '91000000-0000-4000-8000-000000000001';

alter table public.quiz_attempts
  add column checkpoint_policy_version text,
  add constraint quiz_attempts_checkpoint_policy_version_check
    check (
      checkpoint_policy_version is null
      or (quiz_type = 'topic' and btrim(checkpoint_policy_version) <> '')
    );

create function public.calculate_topic_checkpoint_size(
  p_certification_id uuid,
  p_lesson_count integer,
  p_pool_count integer
)
returns integer
language plpgsql
security definer
set search_path = ''
stable
as $$
declare
  v_policy_id uuid;
  v_clamp_to_pool boolean;
  v_question_count integer;
begin
  if coalesce(p_lesson_count, 0) <= 0 or coalesce(p_pool_count, 0) <= 0 then
    return 0;
  end if;

  select policy.id, policy.clamp_to_eligible_pool
  into v_policy_id, v_clamp_to_pool
  from public.certification_checkpoint_policies policy
  where policy.certification_id = p_certification_id
    and policy.is_active
    and policy.is_enabled;

  if v_policy_id is null then
    return 0;
  end if;

  select bracket.question_count into v_question_count
  from public.certification_checkpoint_sizing_brackets bracket
  where bracket.policy_id = v_policy_id
    and p_lesson_count >= bracket.minimum_lessons
    and (bracket.maximum_lessons is null or p_lesson_count <= bracket.maximum_lessons)
  order by bracket.minimum_lessons desc
  limit 1;

  if v_question_count is null then
    return 0;
  end if;

  return case
    when v_clamp_to_pool then least(p_pool_count, v_question_count)
    else v_question_count
  end;
end;
$$;

revoke execute on function public.calculate_topic_checkpoint_size(uuid, integer, integer)
  from public, anon, authenticated;

create or replace function public.is_topic_checkpoint_available(p_topic_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  with target_certification as (
    select domain.certification_id
    from public.topics topic
    join public.domains domain on domain.id = topic.domain_id
    where topic.id = p_topic_id
  ),
  ordered_topics as (
    select
      topic.id,
      row_number() over (
        order by domain.display_order, domain.id, topic.display_order, topic.id
      ) as topic_position
    from public.topics topic
    join public.domains domain on domain.id = topic.domain_id
    join target_certification target on target.certification_id = domain.certification_id
  ),
  target as (
    select * from ordered_topics where id = p_topic_id
  )
  select auth.uid() is not null
    and exists (
      select 1
      from target_certification target_cert
      join public.certification_checkpoint_policies policy
        on policy.certification_id = target_cert.certification_id
       and policy.is_active
       and policy.is_enabled
    )
    and exists (select 1 from target)
    and (
      exists (
        select 1 from public.quiz_attempts attempt
        where attempt.user_id = auth.uid()
          and attempt.quiz_type = 'topic'
          and attempt.topic_id = p_topic_id
          and attempt.status in ('in_progress', 'completed')
      )
      or (
        exists (
          select 1 from public.lessons lesson
          where lesson.topic_id = p_topic_id and lesson.is_published = true
        )
        and not exists (
          select 1
          from public.lessons lesson
          where lesson.topic_id = p_topic_id
            and lesson.is_published = true
            and not exists (
              select 1 from public.user_lesson_progress progress
              where progress.user_id = auth.uid()
                and progress.lesson_id = lesson.id
                and progress.status = 'completed'
            )
        )
      )
      or exists (
        select 1
        from target
        join ordered_topics evidence_topic
          on evidence_topic.topic_position > target.topic_position
        left join public.lessons evidence_lesson
          on evidence_lesson.topic_id = evidence_topic.id
         and evidence_lesson.is_published = true
        where exists (
          select 1 from public.user_lesson_progress progress
          where progress.user_id = auth.uid()
            and progress.lesson_id = evidence_lesson.id
            and progress.status in ('in_progress', 'completed')
        ) or exists (
          select 1 from public.quiz_attempts attempt
          where attempt.user_id = auth.uid()
            and attempt.quiz_type = 'topic'
            and attempt.topic_id = evidence_topic.id
            and attempt.status in ('in_progress', 'completed')
        )
      )
    );
$$;

create or replace function public.start_topic_quiz_unchecked(p_topic_id uuid)
returns setof public.quiz_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_certification_id uuid;
  v_policy_id uuid;
  v_policy_version text;
  v_eligible_question_types text[];
  v_require_lesson_coverage boolean;
  v_penalize_previous_attempt boolean;
  v_easy_weight numeric;
  v_medium_weight numeric;
  v_hard_weight numeric;
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

  select
    policy.id,
    policy.policy_version,
    policy.eligible_question_types,
    policy.require_lesson_coverage,
    policy.penalize_previous_attempt,
    policy.easy_weight,
    policy.medium_weight,
    policy.hard_weight
  into
    v_policy_id,
    v_policy_version,
    v_eligible_question_types,
    v_require_lesson_coverage,
    v_penalize_previous_attempt,
    v_easy_weight,
    v_medium_weight,
    v_hard_weight
  from public.certification_checkpoint_policies policy
  where policy.certification_id = v_certification_id
    and policy.is_active
    and policy.is_enabled;

  if v_policy_id is null then
    raise exception 'Topic Checkpoint configuration not found or disabled.' using errcode = 'P0002';
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
    and question.question_type = any(v_eligible_question_types)
    and (question.lesson_id is null or lesson.id is not null);

  v_total := public.calculate_topic_checkpoint_size(
    v_certification_id,
    v_lesson_count,
    v_pool_count
  );

  if v_total = 0 then
    raise exception 'No published questions are available for this topic.' using errcode = 'P0002';
  end if;

  v_target_hard := floor(v_total * v_hard_weight)::integer;
  v_target_medium := floor(v_total * v_medium_weight)::integer;
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
      and question.question_type = any(v_eligible_question_types)
      and (question.lesson_id is null or lesson.id is not null)
      and not (question.id = any(v_selected_ids))
    order by
      case
        when not v_require_lesson_coverage then 0
        when question.lesson_id is not null and selection.lesson_selected = 0 then 0
        when question.lesson_id is not null then 1
        else 2
      end,
      case when history.seen_count = 0 then 0 else 1 end,
      case when v_penalize_previous_attempt and history.in_last_attempt then 1 else 0 end,
      history.last_seen_at asc nulls first,
      selection.lesson_selected,
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
    insert into public.quiz_attempts (
      user_id,
      certification_id,
      quiz_type,
      topic_id,
      total_questions,
      checkpoint_policy_version
    ) values (
      v_user_id,
      v_certification_id,
      'topic',
      p_topic_id,
      v_total,
      v_policy_version
    )
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
    public.calculate_topic_checkpoint_size(
      p_certification_id,
      catalog.lesson_count,
      catalog.pool_count::integer
    ),
    active.id,
    active.total_questions,
    (select count(*) from public.quiz_answers answer where answer.attempt_id = active.id),
    completed.score_percentage
  from public.topics topic
  join public.domains domain on domain.id = topic.domain_id
  left join lateral (
    select policy.eligible_question_types
    from public.certification_checkpoint_policies policy
    where policy.certification_id = p_certification_id
      and policy.is_active
      and policy.is_enabled
  ) policy on true
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
       where policy.eligible_question_types is not null
         and question.topic_id = topic.id
         and question.is_published = true
         and question.question_type = any(policy.eligible_question_types)
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

drop function public.calculate_topic_checkpoint_size(integer, integer);

do $$
declare
  v_az900_id uuid;
  v_policy record;
  v_start_source text;
  v_summary_source text;
begin
  select id into strict v_az900_id
  from public.certifications
  where code = 'az-900';

  select * into strict v_policy
  from public.certification_checkpoint_policies
  where certification_id = v_az900_id and is_active and is_enabled;

  if v_policy.policy_version <> 'az900-checkpoint-v1'
    or v_policy.published_at is null
    or v_policy.eligible_question_types <> array['single_choice']::text[]
    or not v_policy.clamp_to_eligible_pool
    or not v_policy.require_lesson_coverage
    or v_policy.rotation_strategy <> 'unseen_then_least_recent'
    or not v_policy.penalize_previous_attempt
    or v_policy.easy_weight <> 0.30
    or v_policy.medium_weight <> 0.50
    or v_policy.hard_weight <> 0.20 then
    raise exception 'AZ-900 Checkpoint policy does not preserve the V2 baseline.';
  end if;

  if public.calculate_topic_checkpoint_size(v_az900_id, 1, 100) <> 12
    or public.calculate_topic_checkpoint_size(v_az900_id, 3, 100) <> 12
    or public.calculate_topic_checkpoint_size(v_az900_id, 4, 100) <> 15
    or public.calculate_topic_checkpoint_size(v_az900_id, 5, 100) <> 15
    or public.calculate_topic_checkpoint_size(v_az900_id, 6, 100) <> 20
    or public.calculate_topic_checkpoint_size(v_az900_id, 8, 100) <> 20
    or public.calculate_topic_checkpoint_size(v_az900_id, 5, 11) <> 11
    or public.calculate_topic_checkpoint_size(v_az900_id, 3, 0) <> 0 then
    raise exception 'AZ-900 Checkpoint sizing parity failed.';
  end if;

  select pg_get_functiondef('public.start_topic_quiz_unchecked(uuid)'::regprocedure)
  into v_start_source;
  select pg_get_functiondef('public.get_topic_quiz_summaries(uuid)'::regprocedure)
  into v_summary_source;

  if v_start_source not like '%certification_checkpoint_policies%'
    or v_start_source not like '%eligible_question_types%'
    or v_start_source not like '%checkpoint_policy_version%'
    or v_summary_source not like '%calculate_topic_checkpoint_size(%'
    or to_regprocedure('public.calculate_topic_checkpoint_size(integer,integer)') is not null then
    raise exception 'Generic Checkpoint functions still depend on the legacy sizing contract.';
  end if;

  if has_table_privilege('authenticated', 'public.certification_checkpoint_policies', 'SELECT')
    or has_table_privilege('authenticated', 'public.certification_checkpoint_sizing_brackets', 'SELECT')
    or has_function_privilege(
      'authenticated',
      'public.calculate_topic_checkpoint_size(uuid,integer,integer)',
      'EXECUTE'
    )
    or not has_function_privilege('authenticated', 'public.start_topic_quiz(uuid)', 'EXECUTE')
    or not has_function_privilege('authenticated', 'public.get_topic_quiz_summaries(uuid)', 'EXECUTE') then
    raise exception 'Generic Checkpoint privileges are invalid.';
  end if;
end;
$$;

commit;

-- Rollback-only genericity fixture. No fake Certification or policy persists.
begin;

insert into public.certifications (
  id, code, name, provider, is_enabled, display_order
) values (
  '90000000-0000-4000-8000-000000000001',
  'test-001',
  'Checkpoint Configuration Test',
  'Test',
  false,
  999
);

insert into public.certification_checkpoint_policies (
  id,
  certification_id,
  policy_version,
  is_active,
  is_enabled,
  eligible_question_types,
  clamp_to_eligible_pool,
  require_lesson_coverage,
  rotation_strategy,
  penalize_previous_attempt,
  easy_weight,
  medium_weight,
  hard_weight
) values (
  '91000000-0000-4000-8000-000000000099',
  '90000000-0000-4000-8000-000000000001',
  'test001-checkpoint-v1',
  false,
  true,
  array['single_choice']::text[],
  true,
  false,
  'unseen_then_least_recent',
  false,
  0.20,
  0.60,
  0.20
);

insert into public.certification_checkpoint_sizing_brackets (
  policy_id, minimum_lessons, maximum_lessons, question_count
) values
  ('91000000-0000-4000-8000-000000000099', 1, 2, 7),
  ('91000000-0000-4000-8000-000000000099', 3, null, 9);

update public.certification_checkpoint_policies
set is_active = true
where id = '91000000-0000-4000-8000-000000000099';

do $$
begin
  begin
    update public.certification_checkpoint_policies
    set medium_weight = 0.55
    where id = '91000000-0000-4000-8000-000000000099';
    raise exception 'Published Checkpoint policy mutation was accepted.';
  exception when check_violation then
    null;
  end;

  begin
    update public.certification_checkpoint_sizing_brackets
    set question_count = 8
    where policy_id = '91000000-0000-4000-8000-000000000099'
      and minimum_lessons = 1;
    raise exception 'Published Checkpoint bracket mutation was accepted.';
  exception when check_violation then
    null;
  end;

  if public.calculate_topic_checkpoint_size(
      '90000000-0000-4000-8000-000000000001', 1, 100
    ) <> 7
    or public.calculate_topic_checkpoint_size(
      '90000000-0000-4000-8000-000000000001', 4, 100
    ) <> 9
    or public.calculate_topic_checkpoint_size(
      '90000000-0000-4000-8000-000000000001', 4, 6
    ) <> 6 then
    raise exception 'Second-Certification Checkpoint policy was not resolved independently.';
  end if;
end;
$$;

rollback;

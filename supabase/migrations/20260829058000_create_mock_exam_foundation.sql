begin;

create table public.mock_exam_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  certification_id uuid not null references public.certifications(id) on delete restrict,
  status text not null default 'in_progress',
  total_questions integer not null,
  answered_questions integer not null default 0,
  correct_answers integer,
  incorrect_answers integer,
  unanswered_questions integer,
  practice_score_percentage numeric(5,2),
  started_at timestamptz not null default now(),
  submitted_at timestamptz,
  abandoned_at timestamptz,
  expires_at timestamptz,
  time_limit_seconds integer,
  elapsed_seconds integer,
  last_activity_at timestamptz not null default now(),
  selection_policy_version text not null,
  domain_allocation jsonb not null default '{}'::jsonb,
  difficulty_allocation jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint mock_exam_attempts_status_check
    check (status in ('in_progress', 'completed', 'abandoned', 'expired')),
  constraint mock_exam_attempts_total_questions_check
    check (total_questions between 1 and 100),
  constraint mock_exam_attempts_answered_questions_check
    check (answered_questions between 0 and total_questions),
  constraint mock_exam_attempts_result_counts_check check (
    (correct_answers is null and incorrect_answers is null and unanswered_questions is null)
    or (
      correct_answers between 0 and total_questions
      and incorrect_answers between 0 and total_questions
      and unanswered_questions between 0 and total_questions
      and correct_answers + incorrect_answers + unanswered_questions = total_questions
      and answered_questions = correct_answers + incorrect_answers
    )
  ),
  constraint mock_exam_attempts_score_check
    check (practice_score_percentage is null or practice_score_percentage between 0 and 100),
  constraint mock_exam_attempts_timer_check check (
    (time_limit_seconds is null and expires_at is null)
    or (time_limit_seconds > 0 and expires_at is not null and expires_at > started_at)
  ),
  constraint mock_exam_attempts_elapsed_check
    check (elapsed_seconds is null or elapsed_seconds >= 0),
  constraint mock_exam_attempts_selection_policy_check
    check (length(btrim(selection_policy_version)) between 1 and 100),
  constraint mock_exam_attempts_allocations_check check (
    jsonb_typeof(domain_allocation) = 'object'
    and jsonb_typeof(difficulty_allocation) = 'object'
  ),
  constraint mock_exam_attempts_lifecycle_check check (
    (
      status = 'in_progress'
      and submitted_at is null and abandoned_at is null
      and correct_answers is null and incorrect_answers is null
      and unanswered_questions is null and practice_score_percentage is null
    ) or (
      status = 'completed'
      and submitted_at is not null and abandoned_at is null
      and correct_answers is not null and incorrect_answers is not null
      and unanswered_questions is not null and practice_score_percentage is not null
    ) or (
      status = 'abandoned'
      and submitted_at is null and abandoned_at is not null
      and correct_answers is null and incorrect_answers is null
      and unanswered_questions is null and practice_score_percentage is null
    ) or (
      status = 'expired'
      and submitted_at is null and abandoned_at is null and expires_at is not null
      and correct_answers is null and incorrect_answers is null
      and unanswered_questions is null and practice_score_percentage is null
    )
  )
);

create table public.mock_exam_attempt_questions (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.mock_exam_attempts(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete restrict,
  display_order integer not null,
  domain_id uuid not null references public.domains(id) on delete restrict,
  domain_title_snapshot text not null,
  topic_id uuid not null references public.topics(id) on delete restrict,
  topic_title_snapshot text not null,
  lesson_id uuid not null references public.lessons(id) on delete restrict,
  lesson_title_snapshot text not null,
  lesson_slug_snapshot text not null,
  difficulty_snapshot text not null,
  question_type_snapshot text not null,
  question_text_snapshot text not null,
  options_snapshot jsonb not null,
  correct_option_key text not null,
  question_explanation_snapshot text,
  question_source_updated_at timestamptz not null,
  snapshot_schema_version integer not null default 1,
  created_at timestamptz not null default now(),
  constraint mock_exam_attempt_questions_attempt_question_unique
    unique (attempt_id, question_id),
  constraint mock_exam_attempt_questions_attempt_order_unique
    unique (attempt_id, display_order),
  constraint mock_exam_attempt_questions_id_attempt_unique
    unique (id, attempt_id),
  constraint mock_exam_attempt_questions_display_order_check check (display_order > 0),
  constraint mock_exam_attempt_questions_difficulty_check
    check (difficulty_snapshot in ('easy', 'medium', 'hard')),
  constraint mock_exam_attempt_questions_type_check
    check (question_type_snapshot = 'single_choice'),
  constraint mock_exam_attempt_questions_text_check check (
    length(btrim(domain_title_snapshot)) > 0
    and length(btrim(topic_title_snapshot)) > 0
    and length(btrim(lesson_title_snapshot)) > 0
    and length(btrim(lesson_slug_snapshot)) > 0
    and length(btrim(question_text_snapshot)) > 0
  ),
  constraint mock_exam_attempt_questions_snapshot_version_check
    check (snapshot_schema_version > 0)
);

create table public.mock_exam_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null,
  attempt_question_id uuid not null,
  selected_option_key text not null,
  is_correct boolean,
  answered_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint mock_exam_answers_attempt_question_unique unique (attempt_question_id),
  constraint mock_exam_answers_attempt_question_fkey
    foreign key (attempt_question_id, attempt_id)
    references public.mock_exam_attempt_questions (id, attempt_id)
    on delete cascade,
  constraint mock_exam_answers_option_key_check
    check (length(btrim(selected_option_key)) > 0)
);

create unique index mock_exam_attempts_one_active_idx
  on public.mock_exam_attempts (user_id, certification_id)
  where status = 'in_progress';

create index mock_exam_attempts_user_history_idx
  on public.mock_exam_attempts (user_id, certification_id, started_at desc);

create index mock_exam_attempt_questions_question_idx
  on public.mock_exam_attempt_questions (question_id);

create index mock_exam_answers_attempt_idx
  on public.mock_exam_answers (attempt_id);

create function public.validate_mock_exam_question_snapshot()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_attempt public.mock_exam_attempts;
  v_question record;
  v_options jsonb;
  v_correct_option_key text;
begin
  select * into v_attempt
  from public.mock_exam_attempts attempt
  where attempt.id = new.attempt_id
  for update;

  if not found or v_attempt.status <> 'in_progress' then
    raise exception 'Mock Exam attempt must be in progress.' using errcode = '55000';
  end if;

  if new.display_order > v_attempt.total_questions then
    raise exception 'Question order exceeds the attempt size.' using errcode = '23514';
  end if;

  select
    question.certification_id,
    question.domain_id,
    domain.title as domain_title,
    question.topic_id,
    topic.title as topic_title,
    question.lesson_id,
    lesson.title as lesson_title,
    lesson.slug as lesson_slug,
    question.difficulty,
    question.question_type,
    question.question_text,
    question.explanation,
    question.updated_at
  into v_question
  from public.questions question
  join public.domains domain on domain.id = question.domain_id
  join public.topics topic on topic.id = question.topic_id
  join public.lessons lesson on lesson.id = question.lesson_id
  where question.id = new.question_id
    and question.is_published = true;

  if not found or v_question.certification_id <> v_attempt.certification_id then
    raise exception 'Published Question does not belong to the attempt certification.'
      using errcode = '23503';
  end if;

  select
    jsonb_agg(
      jsonb_build_object(
        'key', option.id::text,
        'sourceOptionId', option.id::text,
        'text', option.option_text,
        'explanation', option.explanation,
        'displayOrder', option.display_order
      ) order by option.display_order, option.id
    ),
    min(option.id::text) filter (where option.is_correct)
  into v_options, v_correct_option_key
  from public.question_options option
  where option.question_id = new.question_id;

  if jsonb_array_length(coalesce(v_options, '[]'::jsonb)) < 2
    or (select count(*) from public.question_options option
        where option.question_id = new.question_id and option.is_correct) <> 1 then
    raise exception 'Question must have options and exactly one correct answer.'
      using errcode = '23514';
  end if;

  if new.domain_id <> v_question.domain_id
    or new.domain_title_snapshot <> v_question.domain_title
    or new.topic_id <> v_question.topic_id
    or new.topic_title_snapshot <> v_question.topic_title
    or new.lesson_id <> v_question.lesson_id
    or new.lesson_title_snapshot <> v_question.lesson_title
    or new.lesson_slug_snapshot <> v_question.lesson_slug
    or new.difficulty_snapshot <> v_question.difficulty
    or new.question_type_snapshot <> v_question.question_type
    or new.question_text_snapshot <> v_question.question_text
    or new.question_explanation_snapshot is distinct from v_question.explanation
    or new.question_source_updated_at <> v_question.updated_at
    or new.options_snapshot <> v_options
    or new.correct_option_key <> v_correct_option_key then
    raise exception 'Question snapshot does not match its canonical source.'
      using errcode = '23514';
  end if;

  return new;
end;
$$;

create trigger mock_exam_attempt_questions_validate_snapshot
before insert on public.mock_exam_attempt_questions
for each row execute function public.validate_mock_exam_question_snapshot();

create function public.prevent_mock_exam_question_snapshot_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Mock Exam Question snapshots are immutable.' using errcode = '55000';
end;
$$;

create trigger mock_exam_attempt_questions_immutable
before update on public.mock_exam_attempt_questions
for each row execute function public.prevent_mock_exam_question_snapshot_update();

create trigger mock_exam_attempts_set_updated_at
before update on public.mock_exam_attempts
for each row execute function public.set_updated_at();

create trigger mock_exam_answers_set_updated_at
before update on public.mock_exam_answers
for each row execute function public.set_updated_at();

alter table public.mock_exam_attempts enable row level security;
alter table public.mock_exam_attempt_questions enable row level security;
alter table public.mock_exam_answers enable row level security;

create policy "Users can read their own Mock Exam attempts"
on public.mock_exam_attempts for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can read their own Mock Exam question rows"
on public.mock_exam_attempt_questions for select
to authenticated
using (
  exists (
    select 1 from public.mock_exam_attempts attempt
    where attempt.id = mock_exam_attempt_questions.attempt_id
      and attempt.user_id = (select auth.uid())
  )
);

create policy "Users can read their own Mock Exam answer rows"
on public.mock_exam_answers for select
to authenticated
using (
  exists (
    select 1 from public.mock_exam_attempts attempt
    where attempt.id = mock_exam_answers.attempt_id
      and attempt.user_id = (select auth.uid())
  )
);

revoke all on table public.mock_exam_attempts from public, anon, authenticated;
revoke all on table public.mock_exam_attempt_questions from public, anon, authenticated;
revoke all on table public.mock_exam_answers from public, anon, authenticated;
grant select on table public.mock_exam_attempts to authenticated;

create function public.get_mock_exam_attempt_questions(p_attempt_id uuid)
returns table (
  id uuid,
  attempt_id uuid,
  question_id uuid,
  display_order integer,
  domain_id uuid,
  domain_title text,
  topic_id uuid,
  topic_title text,
  lesson_id uuid,
  lesson_title text,
  lesson_slug text,
  difficulty text,
  question_type text,
  question_text text,
  options jsonb,
  selected_option_key text,
  answered_at timestamptz
)
language sql
security definer
set search_path = ''
stable
as $$
  select
    item.id,
    item.attempt_id,
    item.question_id,
    item.display_order,
    item.domain_id,
    item.domain_title_snapshot,
    item.topic_id,
    item.topic_title_snapshot,
    item.lesson_id,
    item.lesson_title_snapshot,
    item.lesson_slug_snapshot,
    item.difficulty_snapshot,
    item.question_type_snapshot,
    item.question_text_snapshot,
    coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'key', option_item ->> 'key',
            'text', option_item ->> 'text',
            'displayOrder', (option_item ->> 'displayOrder')::integer
          ) order by (option_item ->> 'displayOrder')::integer, option_item ->> 'key'
        )
        from jsonb_array_elements(item.options_snapshot) option_item
      ),
      '[]'::jsonb
    ),
    answer.selected_option_key,
    answer.answered_at
  from public.mock_exam_attempt_questions item
  join public.mock_exam_attempts attempt on attempt.id = item.attempt_id
  left join public.mock_exam_answers answer on answer.attempt_question_id = item.id
  where item.attempt_id = p_attempt_id
    and attempt.user_id = auth.uid()
    and attempt.status = 'in_progress'
  order by item.display_order;
$$;

create function public.save_mock_exam_answer(
  p_attempt_id uuid,
  p_attempt_question_id uuid,
  p_selected_option_key text
)
returns table (
  id uuid,
  attempt_id uuid,
  attempt_question_id uuid,
  selected_option_key text,
  answered_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt public.mock_exam_attempts;
  v_question public.mock_exam_attempt_questions;
  v_answer public.mock_exam_answers;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  select * into v_attempt
  from public.mock_exam_attempts attempt
  where attempt.id = p_attempt_id and attempt.user_id = v_user_id
  for update;

  if not found then
    raise exception 'Mock Exam attempt not found.' using errcode = '42501';
  end if;

  if v_attempt.status <> 'in_progress' then
    raise exception 'Only an in-progress Mock Exam can be answered.' using errcode = '55000';
  end if;

  select * into v_question
  from public.mock_exam_attempt_questions item
  where item.id = p_attempt_question_id and item.attempt_id = p_attempt_id;

  if not found then
    raise exception 'Question does not belong to this Mock Exam attempt.' using errcode = '23503';
  end if;

  if not exists (
    select 1 from jsonb_array_elements(v_question.options_snapshot) option_item
    where option_item ->> 'key' = p_selected_option_key
  ) then
    raise exception 'Selected option does not belong to the Question snapshot.'
      using errcode = '23503';
  end if;

  insert into public.mock_exam_answers (
    attempt_id, attempt_question_id, selected_option_key, is_correct, answered_at
  ) values (
    p_attempt_id, p_attempt_question_id, p_selected_option_key, null, clock_timestamp()
  )
  on conflict (attempt_question_id) do update set
    selected_option_key = excluded.selected_option_key,
    is_correct = null,
    answered_at = excluded.answered_at
  returning * into v_answer;

  update public.mock_exam_attempts attempt
  set
    answered_questions = (
      select count(*)::integer from public.mock_exam_answers answer
      where answer.attempt_id = p_attempt_id
    ),
    last_activity_at = clock_timestamp()
  where attempt.id = p_attempt_id;

  return query select
    v_answer.id,
    v_answer.attempt_id,
    v_answer.attempt_question_id,
    v_answer.selected_option_key,
    v_answer.answered_at;
end;
$$;

create function public.abandon_mock_exam_attempt(p_attempt_id uuid)
returns setof public.mock_exam_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt public.mock_exam_attempts;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  select * into v_attempt
  from public.mock_exam_attempts attempt
  where attempt.id = p_attempt_id and attempt.user_id = v_user_id
  for update;

  if not found then
    raise exception 'Mock Exam attempt not found.' using errcode = '42501';
  end if;

  if v_attempt.status = 'abandoned' then
    return next v_attempt;
    return;
  end if;

  if v_attempt.status <> 'in_progress' then
    raise exception 'Only an in-progress Mock Exam can be abandoned.' using errcode = '55000';
  end if;

  update public.mock_exam_attempts attempt
  set status = 'abandoned', abandoned_at = clock_timestamp(), last_activity_at = clock_timestamp()
  where attempt.id = p_attempt_id
  returning * into v_attempt;

  return next v_attempt;
end;
$$;

revoke execute on function public.validate_mock_exam_question_snapshot() from public, anon, authenticated;
revoke execute on function public.prevent_mock_exam_question_snapshot_update() from public, anon, authenticated;
revoke execute on function public.get_mock_exam_attempt_questions(uuid) from public, anon;
revoke execute on function public.save_mock_exam_answer(uuid, uuid, text) from public, anon;
revoke execute on function public.abandon_mock_exam_attempt(uuid) from public, anon;
grant execute on function public.get_mock_exam_attempt_questions(uuid) to authenticated;
grant execute on function public.save_mock_exam_answer(uuid, uuid, text) to authenticated;
grant execute on function public.abandon_mock_exam_attempt(uuid) to authenticated;

commit;

begin;

-- The foundation is already additive history. Qualify the answer upsert through its
-- named constraint so PostgreSQL does not confuse the column with an OUT parameter.
create or replace function public.save_mock_exam_answer(
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
  on conflict on constraint mock_exam_answers_attempt_question_unique do update set
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

revoke execute on function public.save_mock_exam_answer(uuid, uuid, text) from public, anon;
grant execute on function public.save_mock_exam_answer(uuid, uuid, text) to authenticated;

do $$
declare
  table_name text;
  constraint_definition text;
begin
  foreach table_name in array array[
    'mock_exam_attempts',
    'mock_exam_attempt_questions',
    'mock_exam_answers'
  ] loop
    if to_regclass('public.' || table_name) is null then
      raise exception '11.2 missing table public.%', table_name;
    end if;

    if not (select relrowsecurity from pg_class where oid = ('public.' || table_name)::regclass) then
      raise exception '11.2 RLS is disabled on public.%', table_name;
    end if;
  end loop;

  if exists (
    select required.column_name
    from (values
      ('mock_exam_attempts', 'user_id'),
      ('mock_exam_attempts', 'certification_id'),
      ('mock_exam_attempts', 'status'),
      ('mock_exam_attempts', 'answered_questions'),
      ('mock_exam_attempts', 'unanswered_questions'),
      ('mock_exam_attempts', 'expires_at'),
      ('mock_exam_attempts', 'time_limit_seconds'),
      ('mock_exam_attempts', 'elapsed_seconds'),
      ('mock_exam_attempt_questions', 'options_snapshot'),
      ('mock_exam_attempt_questions', 'correct_option_key'),
      ('mock_exam_attempt_questions', 'question_source_updated_at'),
      ('mock_exam_attempt_questions', 'snapshot_schema_version'),
      ('mock_exam_answers', 'attempt_question_id'),
      ('mock_exam_answers', 'selected_option_key'),
      ('mock_exam_answers', 'is_correct')
    ) required(table_name, column_name)
    left join information_schema.columns column_info
      on column_info.table_schema = 'public'
      and column_info.table_name = required.table_name
      and column_info.column_name = required.column_name
    where column_info.column_name is null
  ) then
    raise exception '11.2 is missing one or more required Mock Exam columns';
  end if;

  select pg_get_constraintdef(oid) into constraint_definition
  from pg_constraint
  where conrelid = 'public.mock_exam_attempts'::regclass
    and conname = 'mock_exam_attempts_status_check';

  if constraint_definition is null
    or constraint_definition not like '%in_progress%'
    or constraint_definition not like '%completed%'
    or constraint_definition not like '%abandoned%'
    or constraint_definition not like '%expired%' then
    raise exception '11.2 lifecycle constraint is incomplete';
  end if;

  if not exists (
      select 1 from pg_constraint
      where conrelid = 'public.mock_exam_attempt_questions'::regclass
        and conname = 'mock_exam_attempt_questions_attempt_question_unique'
    ) or not exists (
      select 1 from pg_constraint
      where conrelid = 'public.mock_exam_attempt_questions'::regclass
        and conname = 'mock_exam_attempt_questions_attempt_order_unique'
    ) or not exists (
      select 1 from pg_constraint
      where conrelid = 'public.mock_exam_answers'::regclass
        and conname = 'mock_exam_answers_attempt_question_fkey'
    ) then
    raise exception '11.2 duplicate or relationship constraints are missing';
  end if;

  if not exists (
      select 1 from pg_indexes where schemaname = 'public'
        and indexname = 'mock_exam_attempts_one_active_idx'
        and indexdef like '%WHERE (status = ''in_progress''%'
    ) or not exists (
      select 1 from pg_indexes where schemaname = 'public'
        and indexname = 'mock_exam_attempts_user_history_idx'
    ) or not exists (
      select 1 from pg_indexes where schemaname = 'public'
        and indexname = 'mock_exam_attempt_questions_question_idx'
    ) or not exists (
      select 1 from pg_indexes where schemaname = 'public'
        and indexname = 'mock_exam_answers_attempt_idx'
    ) then
    raise exception '11.2 required indexes are missing';
  end if;

  if (select count(*) from pg_policies where schemaname = 'public'
      and tablename in ('mock_exam_attempts','mock_exam_attempt_questions','mock_exam_answers')) <> 3 then
    raise exception '11.2 expected one owner-read RLS policy per private table';
  end if;

  if has_table_privilege('anon', 'public.mock_exam_attempts', 'SELECT')
    or has_table_privilege('authenticated', 'public.mock_exam_attempts', 'INSERT')
    or has_table_privilege('authenticated', 'public.mock_exam_attempts', 'UPDATE')
    or has_table_privilege('authenticated', 'public.mock_exam_attempts', 'DELETE')
    or has_table_privilege('authenticated', 'public.mock_exam_attempt_questions', 'SELECT')
    or has_table_privilege('authenticated', 'public.mock_exam_answers', 'SELECT') then
    raise exception '11.2 private table grants are unsafe';
  end if;

  if not has_table_privilege('authenticated', 'public.mock_exam_attempts', 'SELECT')
    or has_function_privilege('anon', 'public.get_mock_exam_attempt_questions(uuid)', 'EXECUTE')
    or has_function_privilege('anon', 'public.save_mock_exam_answer(uuid,uuid,text)', 'EXECUTE')
    or not has_function_privilege('authenticated', 'public.get_mock_exam_attempt_questions(uuid)', 'EXECUTE')
    or not has_function_privilege('authenticated', 'public.save_mock_exam_answer(uuid,uuid,text)', 'EXECUTE')
    or not has_function_privilege('authenticated', 'public.abandon_mock_exam_attempt(uuid)', 'EXECUTE') then
    raise exception '11.2 safe read/write RPC grants are invalid';
  end if;

  if exists (
      select 1 from public.mock_exam_attempt_questions item
      left join public.mock_exam_attempts attempt on attempt.id = item.attempt_id
      left join public.questions question on question.id = item.question_id
      where attempt.id is null or question.id is null
    ) or exists (
      select 1 from public.mock_exam_answers answer
      left join public.mock_exam_attempt_questions item
        on item.id = answer.attempt_question_id and item.attempt_id = answer.attempt_id
      where item.id is null
    ) then
    raise exception '11.2 found orphan Mock Exam records';
  end if;
end;
$$;

commit;

-- Runtime/RLS fixtures are deliberately rolled back.
begin;

insert into auth.users(
  instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at
) values
  ('00000000-0000-0000-0000-000000000000','59000000-0000-4000-8000-000000000001',
   'authenticated','authenticated','mock-foundation-a@example.invalid','',now(),
   '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()),
  ('00000000-0000-0000-0000-000000000000','59000000-0000-4000-8000-000000000002',
   'authenticated','authenticated','mock-foundation-b@example.invalid','',now(),
   '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now());

create temporary table audit_112_context on commit drop as
select
  certification.id as certification_id,
  question.id as question_id,
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
  question.updated_at,
  jsonb_agg(
    jsonb_build_object(
      'key', option.id::text,
      'sourceOptionId', option.id::text,
      'text', option.option_text,
      'explanation', option.explanation,
      'displayOrder', option.display_order
    ) order by option.display_order, option.id
  ) as options_snapshot,
  min(option.id::text) filter (where option.is_correct) as correct_option_key
from public.questions question
join public.question_options option on option.question_id = question.id
join public.domains domain on domain.id = question.domain_id
join public.topics topic on topic.id = question.topic_id
join public.lessons lesson on lesson.id = question.lesson_id
join public.certifications certification on certification.id = question.certification_id
where certification.code = 'az-900'
  and question.is_published
  and question.question_type = 'single_choice'
  and question.difficulty is not null
group by certification.id, question.id, domain.title, topic.title, lesson.title, lesson.slug
having count(*) >= 2 and count(*) filter (where option.is_correct) = 1
order by question.display_order, question.id
limit 3;

do $$
begin
  if (select count(*) from audit_112_context) <> 3 then
    raise exception '11.2 runtime validator requires three eligible AZ-900 Questions';
  end if;
end;
$$;

insert into public.mock_exam_attempts (
  id,user_id,certification_id,total_questions,selection_policy_version,
  domain_allocation,difficulty_allocation
) values
  ('59100000-0000-4000-8000-000000000001','59000000-0000-4000-8000-000000000001',
   (select certification_id from audit_112_context limit 1),2,'11.2-validator',
   '{"fixture":2}'::jsonb,'{"fixture":2}'::jsonb),
  ('59100000-0000-4000-8000-000000000002','59000000-0000-4000-8000-000000000002',
   (select certification_id from audit_112_context limit 1),1,'11.2-validator',
   '{"fixture":1}'::jsonb,'{"fixture":1}'::jsonb);

insert into public.mock_exam_attempt_questions (
  id,attempt_id,question_id,display_order,domain_id,domain_title_snapshot,
  topic_id,topic_title_snapshot,lesson_id,lesson_title_snapshot,lesson_slug_snapshot,
  difficulty_snapshot,question_type_snapshot,question_text_snapshot,options_snapshot,
  correct_option_key,question_explanation_snapshot,question_source_updated_at
)
select
  ('59200000-0000-4000-8000-' || lpad(row_number() over ()::text,12,'0'))::uuid,
  case when row_number() over () <= 2
    then '59100000-0000-4000-8000-000000000001'::uuid
    else '59100000-0000-4000-8000-000000000002'::uuid end,
  context.question_id,
  case when row_number() over () <= 2 then row_number() over ()::integer else 1 end,
  context.domain_id,context.domain_title,context.topic_id,context.topic_title,
  context.lesson_id,context.lesson_title,context.lesson_slug,context.difficulty,
  context.question_type,context.question_text,context.options_snapshot,
  context.correct_option_key,context.explanation,context.updated_at
from audit_112_context context;

grant select on audit_112_context to authenticated;

set local role authenticated;
select set_config('request.jwt.claim.sub','59000000-0000-4000-8000-000000000001',true);

do $$
declare
  v_question record;
  v_first_key text;
  v_second_key text;
  v_answer record;
  v_attempt public.mock_exam_attempts;
begin
  if (select count(*) from public.mock_exam_attempts) <> 1
    or exists (select 1 from public.mock_exam_attempts
      where user_id = '59000000-0000-4000-8000-000000000002') then
    raise exception '11.2 attempt RLS did not isolate user A from user B';
  end if;

  if (select count(*) from public.get_mock_exam_attempt_questions(
      '59100000-0000-4000-8000-000000000002')) <> 0 then
    raise exception '11.2 sanitized RPC exposed user B Questions to user A';
  end if;

  select * into strict v_question
  from public.get_mock_exam_attempt_questions('59100000-0000-4000-8000-000000000001')
  order by display_order limit 1;

  if exists (
    select 1 from jsonb_array_elements(v_question.options) option_item
    where option_item ? 'sourceOptionId'
      or option_item ? 'explanation'
      or option_item ? 'isCorrect'
      or option_item ? 'correct'
  ) then
    raise exception '11.2 active Question payload leaked answer-key metadata';
  end if;

  select option_item ->> 'key' into v_first_key
  from jsonb_array_elements(v_question.options) option_item
  order by (option_item ->> 'displayOrder')::integer limit 1;

  select option_item ->> 'key' into v_second_key
  from jsonb_array_elements(v_question.options) option_item
  order by (option_item ->> 'displayOrder')::integer offset 1 limit 1;

  select * into strict v_answer from public.save_mock_exam_answer(
    '59100000-0000-4000-8000-000000000001',v_question.id,v_first_key
  );
  select * into strict v_answer from public.save_mock_exam_answer(
    '59100000-0000-4000-8000-000000000001',v_question.id,v_second_key
  );

  if v_answer.selected_option_key <> v_second_key
    or (select answered_questions from public.mock_exam_attempts
        where id = '59100000-0000-4000-8000-000000000001') <> 1 then
    raise exception '11.2 answer upsert/change or progress count failed';
  end if;

  select * into strict v_question
  from public.get_mock_exam_attempt_questions('59100000-0000-4000-8000-000000000001')
  where id = v_question.id;
  if v_question.selected_option_key <> v_second_key then
    raise exception '11.2 resume did not return the persisted answer';
  end if;

  begin
    perform * from public.save_mock_exam_answer(
      '59100000-0000-4000-8000-000000000002',
      '59200000-0000-4000-8000-000000000003','known-key'
    );
    raise exception '11.2 user A changed user B data through a known relationship ID';
  exception when insufficient_privilege then null;
  end;

  begin
    perform * from public.abandon_mock_exam_attempt('59100000-0000-4000-8000-000000000002');
    raise exception '11.2 user A abandoned user B attempt';
  exception when insufficient_privilege then null;
  end;

  select * into strict v_attempt
  from public.abandon_mock_exam_attempt('59100000-0000-4000-8000-000000000001');
  if v_attempt.status <> 'abandoned' or v_attempt.abandoned_at is null then
    raise exception '11.2 abandon lifecycle failed';
  end if;

  begin
    perform * from public.save_mock_exam_answer(
      '59100000-0000-4000-8000-000000000001',v_question.id,v_second_key
    );
    raise exception '11.2 accepted an answer after finalization';
  exception when object_not_in_prerequisite_state then null;
  end;

  begin
    insert into public.mock_exam_attempts(
      user_id,certification_id,total_questions,selection_policy_version
    ) values (
      '59000000-0000-4000-8000-000000000001',
      (select certification_id from audit_112_context limit 1),1,'unsafe-client'
    );
    raise exception '11.2 authenticated client inserted a private attempt directly';
  exception when insufficient_privilege then null;
  end;
end;
$$;

reset role;
set local role postgres;

do $$
declare
  v_failed boolean;
begin
  begin
    insert into public.mock_exam_attempts(
      user_id,certification_id,status,total_questions,selection_policy_version
    ) values (
      '59000000-0000-4000-8000-000000000001',
      (select certification_id from audit_112_context limit 1),'invalid',1,'validator'
    );
  exception when check_violation then v_failed := true;
  end;
  if not coalesce(v_failed,false) then raise exception '11.2 accepted an invalid status'; end if;

  v_failed := false;
  begin
    insert into public.mock_exam_answers(
      attempt_id,attempt_question_id,selected_option_key
    ) values (
      '59100000-0000-4000-8000-000000000001',
      '59200000-0000-4000-8000-000000000003','mismatch'
    );
  exception when foreign_key_violation then v_failed := true;
  end;
  if not v_failed then raise exception '11.2 accepted a cross-attempt answer relationship'; end if;

  v_failed := false;
  begin
    update public.mock_exam_attempt_questions set question_text_snapshot = 'mutated'
    where id = '59200000-0000-4000-8000-000000000001';
  exception when object_not_in_prerequisite_state then v_failed := true;
  end;
  if not v_failed then raise exception '11.2 allowed snapshot mutation'; end if;

  v_failed := false;
  begin
    insert into public.mock_exam_attempt_questions(
      attempt_id,question_id,display_order,domain_id,domain_title_snapshot,
      topic_id,topic_title_snapshot,lesson_id,lesson_title_snapshot,lesson_slug_snapshot,
      difficulty_snapshot,question_type_snapshot,question_text_snapshot,options_snapshot,
      correct_option_key,question_explanation_snapshot,question_source_updated_at
    ) select
      '59100000-0000-4000-8000-000000000002',context.question_id,1,
      context.domain_id,context.domain_title,context.topic_id,context.topic_title,
      context.lesson_id,context.lesson_title,context.lesson_slug,context.difficulty,
      context.question_type,context.question_text,context.options_snapshot,
      context.correct_option_key,context.explanation,context.updated_at
    from public.mock_exam_attempt_questions item
    join audit_112_context context on context.question_id = item.question_id
    where item.id = '59200000-0000-4000-8000-000000000003';
  exception when unique_violation then v_failed := true;
  end;
  if not v_failed then raise exception '11.2 accepted duplicate Question/order'; end if;

  if exists (select 1 from public.mock_exam_answers where is_correct is not null) then
    raise exception '11.2 persisted correctness before final submission';
  end if;
end;
$$;

rollback;

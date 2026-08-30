begin;

insert into auth.users(
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values
  ('00000000-0000-0000-0000-000000000000', '75000000-0000-4000-8000-000000000001',
   'authenticated', 'authenticated', 'mock-closure-a@example.invalid', '', now(),
   '{"provider":"email","providers":["email"]}'::jsonb, '{}', now(), now()),
  ('00000000-0000-0000-0000-000000000000', '75000000-0000-4000-8000-000000000002',
   'authenticated', 'authenticated', 'mock-closure-b@example.invalid', '', now(),
   '{"provider":"email","providers":["email"]}'::jsonb, '{}', now(), now());

create temporary table audit_117_mocks (
  mock_no integer not null,
  attempt_id uuid not null,
  question_id uuid not null,
  domain_order integer not null,
  topic_id uuid not null,
  difficulty text not null,
  primary key (mock_no, question_id)
) on commit drop;

do $$
declare
  v_user_a constant uuid := '75000000-0000-4000-8000-000000000001';
  v_user_b constant uuid := '75000000-0000-4000-8000-000000000002';
  v_certification_id uuid;
  v_parity_a public.mock_exam_attempts;
  v_parity_b public.mock_exam_attempts;
  v_attempt public.mock_exam_attempts;
  v_first_attempt_id uuid;
  v_first_question_id uuid;
  v_first_item_id uuid;
  v_original_snapshot_text text;
  v_first_key text;
  v_changed_key text;
  v_mock integer;
  v_record record;
  v_submitted_at timestamptz;
  v_bank record;
begin
  select certification.id into strict v_certification_id
  from public.certifications certification where lower(certification.code) = 'az-900';

  with classified as (
    select question.*,
      (question.is_published and question.question_type = 'single_choice'
        and question.domain_id is not null and question.topic_id is not null
        and question.lesson_id is not null and question.difficulty is not null
        and coalesce(length(btrim(question.explanation)), 0) > 0
        and (select count(*) from public.question_options option where option.question_id = question.id) = 4
        and (select count(*) from public.question_options option
          where option.question_id = question.id and option.is_correct) = 1) as study_valid,
      question.question_text ~* '(empresa|organiza[cç][aã]o|equipe|cliente|aplica[cç][aã]o|carga de trabalho|requisito|precisa|deseja|usu[aá]rio|administrador|cen[aá]rio)' as scenario_style
    from public.questions question where question.certification_id = v_certification_id
  )
  select count(*)::integer as total,
    count(*) filter (where mock_eligible and scenario_style and difficulty in ('medium', 'hard'))::integer as grade_a,
    count(*) filter (where mock_eligible and not (scenario_style and difficulty in ('medium', 'hard')))::integer as grade_b,
    count(*) filter (where not mock_eligible and study_valid)::integer as grade_c,
    count(*) filter (where not mock_eligible and not study_valid)::integer as grade_d,
    count(*) filter (where mock_eligible)::integer as eligible
  into strict v_bank from classified;

  if v_bank.total <> 512 or v_bank.grade_a <> 228 or v_bank.grade_b <> 211
    or v_bank.grade_c <> 73 or v_bank.grade_d <> 0 or v_bank.eligible <> 439 then
    raise exception '11.7 Question Bank audit changed: %', to_jsonb(v_bank);
  end if;

  if pg_get_function_result('public.get_mock_exam_attempt_questions(uuid)'::regprocedure)
      ~* '(correct|explanation|difficulty|domain|topic|lesson)'
    or pg_get_function_result('public.get_mock_exam_history(uuid,integer,integer)'::regprocedure)
      ~* '(question_text|options|snapshot)' then
    raise exception '11.7 execution or History contract over-exposes protected/heavy fields.';
  end if;

  -- Same seed and empty history must be identical across owners.
  perform set_config('request.jwt.claim.sub', v_user_a::text, true);
  select * into strict v_parity_a
  from public.start_mock_exam_internal(v_certification_id, 'closure-owner-parity');
  perform set_config('request.jwt.claim.sub', v_user_b::text, true);
  select * into strict v_parity_b
  from public.start_mock_exam_internal(v_certification_id, 'closure-owner-parity');
  if exists (
    (select question_id, display_order from public.mock_exam_attempt_questions where attempt_id = v_parity_a.id
     except
     select question_id, display_order from public.mock_exam_attempt_questions where attempt_id = v_parity_b.id)
    union all
    (select question_id, display_order from public.mock_exam_attempt_questions where attempt_id = v_parity_b.id
     except
     select question_id, display_order from public.mock_exam_attempt_questions where attempt_id = v_parity_a.id)
  ) then
    raise exception '11.7 owner history leaked into a fresh deterministic selection.';
  end if;
  delete from public.mock_exam_attempts where id in (v_parity_a.id, v_parity_b.id);

  perform set_config('request.jwt.claim.sub', v_user_a::text, true);
  for v_mock in 1..5 loop
    select * into strict v_attempt from public.start_mock_exam(v_certification_id);
    if v_attempt.status <> 'in_progress' or v_attempt.time_limit_seconds <> 3600
      or extract(epoch from (v_attempt.expires_at - v_attempt.started_at))::integer <> 3600 then
      raise exception '11.7 Mock % did not start with the server timer.', v_mock;
    end if;

    if (select count(*) from public.mock_exam_attempt_questions item where item.attempt_id = v_attempt.id) <> 40
      or (select count(distinct item.question_id) from public.mock_exam_attempt_questions item where item.attempt_id = v_attempt.id) <> 40
      or (select min(item.display_order) from public.mock_exam_attempt_questions item where item.attempt_id = v_attempt.id) <> 1
      or (select max(item.display_order) from public.mock_exam_attempt_questions item where item.attempt_id = v_attempt.id) <> 40
      or exists (
        select 1 from public.mock_exam_attempt_questions item
        join public.questions question on question.id = item.question_id
        where item.attempt_id = v_attempt.id
          and (not question.mock_eligible or not question.is_published
            or question.certification_id <> v_certification_id
            or item.domain_id <> question.domain_id or item.topic_id <> question.topic_id
            or item.lesson_id <> question.lesson_id
            or item.difficulty_snapshot not in ('easy', 'medium', 'hard'))
      ) then
      raise exception '11.7 Mock % violated size, uniqueness, eligibility, order or snapshot relationships.', v_mock;
    end if;

    insert into audit_117_mocks
    select v_mock, v_attempt.id, item.question_id, domain.display_order,
      item.topic_id, item.difficulty_snapshot
    from public.mock_exam_attempt_questions item
    join public.domains domain on domain.id = item.domain_id
    where item.attempt_id = v_attempt.id;

    if v_mock = 1 then
      v_first_attempt_id := v_attempt.id;
      select item.id, item.question_id, item.question_text_snapshot,
        item.options_snapshot -> 0 ->> 'key', item.options_snapshot -> 2 ->> 'key'
      into strict v_first_item_id, v_first_question_id, v_original_snapshot_text,
        v_first_key, v_changed_key
      from public.mock_exam_attempt_questions item
      where item.attempt_id = v_attempt.id order by item.display_order limit 1;

      perform * from public.save_mock_exam_answer(v_attempt.id, v_first_item_id, v_first_key);
      perform * from public.save_mock_exam_answer(v_attempt.id, v_first_item_id, v_changed_key);
      if not exists (
        select 1 from public.get_mock_exam_attempt_questions(v_attempt.id) execution
        where execution.id = v_first_item_id and execution.selected_option_key = v_changed_key
      ) or exists (
        select 1 from public.get_mock_exam_attempt_questions(v_attempt.id) execution,
          lateral jsonb_object_keys(to_jsonb(execution)) key
        where key in ('correct_option_key', 'correct_option_id', 'explanation', 'difficulty',
          'domain_id', 'topic_id', 'lesson_id')
      ) then
        raise exception '11.7 answer replacement failed or active DTO leaked protected metadata.';
      end if;
    end if;

    select * into strict v_attempt from public.submit_mock_exam(v_attempt.id);
    v_submitted_at := v_attempt.submitted_at;
    select * into strict v_attempt from public.submit_mock_exam(v_attempt.id);
    if v_attempt.status <> 'completed' or v_attempt.submitted_at <> v_submitted_at
      or v_attempt.correct_answers + v_attempt.incorrect_answers + v_attempt.unanswered_questions <> 40
      or v_attempt.practice_score_percentage <> round(v_attempt.correct_answers::numeric / 40 * 100, 2)
      or (select count(*) from public.get_mock_exam_result(v_attempt.id)) <> 1
      or (select count(*) from public.get_mock_exam_review(v_attempt.id)) <> 40 then
      raise exception '11.7 Mock % submit, idempotency, score, Result or Review failed.', v_mock;
    end if;
  end loop;

  if exists (
    select mock_no, domain_order, count(*) from audit_117_mocks
    group by mock_no, domain_order
    having count(*) <> case domain_order when 1 then 11 when 2 then 15 when 3 then 14 end
  ) or exists (
    select mock_no from audit_117_mocks group by mock_no
    having count(*) filter (where difficulty = 'easy') <> 12
      or count(*) filter (where difficulty = 'medium') <> 20
      or count(*) filter (where difficulty = 'hard') <> 8
      or count(distinct topic_id) <> 12
  ) or exists (
    select mock_no, domain_order from (
      select mock_no, domain_order, topic_id, count(*) amount
      from audit_117_mocks group by mock_no, domain_order, topic_id
    ) distribution group by mock_no, domain_order
    having max(amount) - min(amount) > 1
  ) then
    raise exception '11.7 five-Mock Domain, Topic or difficulty distribution failed.';
  end if;

  if (select count(distinct question_id) from audit_117_mocks) < 190 then
    raise exception '11.7 cumulative five-Mock exposure regressed below 190 Questions.';
  end if;

  update public.questions question set question_text = question.question_text || ' [isolated closure test]'
  where question.id = v_first_question_id;
  if not exists (
    select 1 from public.get_mock_exam_review(v_first_attempt_id) review
    where review.id = v_first_item_id and review.question_text = v_original_snapshot_text
  ) then
    raise exception '11.7 historical Review changed with the source Question.';
  end if;

  if (select count(*) from public.get_mock_exam_history(v_certification_id, 10, 0)) <> 5
    or exists (
      select 1 from public.get_mock_exam_history(v_certification_id, 10, 0) history
      where history.status <> 'completed' or history.practice_score_percentage is null
        or history.elapsed_seconds is null or history.total_count <> 5
    ) then
    raise exception '11.7 History metadata, result status or duration failed.';
  end if;

  begin
    perform * from public.save_mock_exam_answer(v_first_attempt_id, v_first_item_id, v_changed_key);
    raise exception '11.7 completed Attempt accepted an answer update.';
  exception when sqlstate '55000' then null;
  end;

  for v_record in
    with metrics as (
      select current_item.mock_no,
        count(distinct current_item.question_id)::integer unique_questions,
        count(*) filter (where previous_item.question_id is not null)::integer overlap_previous,
        count(distinct current_item.topic_id)::integer topics,
        count(*) filter (where current_item.domain_order = 1)::integer d1,
        count(*) filter (where current_item.domain_order = 2)::integer d2,
        count(*) filter (where current_item.domain_order = 3)::integer d3
      from audit_117_mocks current_item
      left join audit_117_mocks previous_item
        on previous_item.mock_no = current_item.mock_no - 1
        and previous_item.question_id = current_item.question_id
      group by current_item.mock_no
    ) select * from metrics order by mock_no
  loop
    raise notice '11.7 MOCK=% UNIQUE=% OVERLAP_PREVIOUS=% TOPICS=% D1/D2/D3=%/%/%',
      v_record.mock_no, v_record.unique_questions, v_record.overlap_previous,
      v_record.topics, v_record.d1, v_record.d2, v_record.d3;
  end loop;
  raise notice '11.7 BANK A=% B=% C=% D=% ELIGIBLE=%; FIVE_MOCK_UNIQUE=%',
    v_bank.grade_a, v_bank.grade_b, v_bank.grade_c, v_bank.grade_d, v_bank.eligible,
    (select count(distinct question_id) from audit_117_mocks);
end;
$$;

grant select on audit_117_mocks to authenticated;

set local role authenticated;
select set_config('request.jwt.claim.sub', '75000000-0000-4000-8000-000000000002', true);

do $$
declare
  v_certification_id uuid := (select id from public.certifications where lower(code) = 'az-900');
  v_foreign_attempt_id uuid := (select attempt_id from audit_117_mocks order by mock_no limit 1);
begin
  if exists (select 1 from public.mock_exam_attempts attempt where attempt.id = v_foreign_attempt_id)
    or exists (select 1 from public.get_mock_exam_result(v_foreign_attempt_id))
    or exists (select 1 from public.get_mock_exam_review(v_foreign_attempt_id))
    or exists (select 1 from public.sync_mock_exam_attempt(v_foreign_attempt_id))
    or exists (select 1 from public.get_mock_exam_history(v_certification_id, 10, 0)) then
    raise exception '11.7 User B accessed User A Attempt, Result, Review, sync or History.';
  end if;

  begin
    perform 1 from public.mock_exam_attempt_questions item where item.attempt_id = v_foreign_attempt_id;
    raise exception '11.7 authenticated role unexpectedly has direct snapshot-table access.';
  exception when insufficient_privilege then null;
  end;
  begin
    perform 1 from public.mock_exam_answers answer where answer.attempt_id = v_foreign_attempt_id;
    raise exception '11.7 authenticated role unexpectedly has direct answer-table access.';
  exception when insufficient_privilege then null;
  end;
end;
$$;

rollback;

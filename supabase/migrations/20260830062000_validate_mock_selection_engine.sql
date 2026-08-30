begin;

-- 061 is already migration history. Harden its Topic-history aggregate additively:
-- rows from another owner must not count when the owned attempt join is filtered out.
do $$
declare
  v_source text;
begin
  select pg_get_functiondef('public.start_mock_exam_internal(uuid,text)'::regprocedure)
  into v_source;
  v_source := regexp_replace(
    v_source,
    'count\s*\(\s*distinct\s+history_item\.id\s*\)',
    'count(DISTINCT history_item.id) FILTER (WHERE history_attempt.id IS NOT NULL)',
    'i'
  );
  if upper(v_source) not like '%FILTER (WHERE HISTORY_ATTEMPT.ID IS NOT NULL)%' then
    raise exception '11.3 could not apply the owner-isolated Topic history correction';
  end if;
  execute v_source;
end;
$$;

do $$
declare
  v_total integer;
  v_a integer;
  v_b integer;
  v_c integer;
  v_d integer;
  v_eligible integer;
  v_record record;
  v_source text;
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='questions'
      and column_name='mock_eligible' and data_type='boolean' and is_nullable='NO'
  ) then
    raise exception '11.3 mock_eligible metadata is missing or nullable';
  end if;

  if not exists (
    select 1 from pg_indexes where schemaname='public'
      and indexname='questions_mock_eligible_pool_idx'
      and indexdef like '%mock_eligible = true%'
  ) then
    raise exception '11.3 Mock-eligible pool index is missing';
  end if;

  select pg_get_functiondef('public.start_mock_exam_internal(uuid,text)'::regprocedure)
  into v_source;
  if v_source not like '%question.mock_eligible%'
    or v_source not like '%domain_selection.selected_count < domain_target.question_target%'
    or v_source not like '%history_attempt.user_id = v_user_id%'
    or v_source not like '%history.in_previous_attempt%'
    or v_source not like '%md5(v_seed%'
    or v_source not like '%mock_selected_questions%' then
    raise exception '11.3 selector is missing an eligibility, allocation, history or deterministic rule';
  end if;

  if has_function_privilege('anon','public.start_mock_exam(uuid)','EXECUTE')
    or not has_function_privilege('authenticated','public.start_mock_exam(uuid)','EXECUTE')
    or has_function_privilege('authenticated','public.start_mock_exam_internal(uuid,text)','EXECUTE') then
    raise exception '11.3 start/internal RPC grants are invalid';
  end if;

  if pg_get_functiondef('public.start_lesson_quiz(uuid)'::regprocedure) like '%mock_eligible%'
    or pg_get_functiondef('public.start_topic_quiz(uuid)'::regprocedure) like '%mock_eligible%'
    or pg_get_functiondef('public.start_review_quiz(uuid,uuid)'::regprocedure) like '%mock_eligible%' then
    raise exception '11.3 eligibility leaked into an existing Quiz selector';
  end if;

  with classified as (
    select
      question.*,
      (
        question.is_published and question.question_type='single_choice'
        and question.domain_id is not null and question.topic_id is not null
        and question.lesson_id is not null and question.difficulty is not null
        and coalesce(length(btrim(question.explanation)),0) > 0
        and (select count(*) from public.question_options option
             where option.question_id=question.id)=4
        and (select count(*) from public.question_options option
             where option.question_id=question.id and option.is_correct)=1
      ) as study_valid,
      (
        question.question_text ~* '(empresa|organiza[cç][aã]o|equipe|cliente|aplica[cç][aã]o|carga de trabalho|requisito|precisa|deseja|usu[aá]rio|administrador|cen[aá]rio)'
      ) as scenario_style
    from public.questions question
    join public.certifications certification on certification.id=question.certification_id
    where certification.code='az-900'
  )
  select
    count(*)::integer,
    count(*) filter(where mock_eligible and scenario_style and difficulty in ('medium','hard'))::integer,
    count(*) filter(where mock_eligible and not (scenario_style and difficulty in ('medium','hard')))::integer,
    count(*) filter(where not mock_eligible and study_valid)::integer,
    count(*) filter(where not mock_eligible and not study_valid)::integer,
    count(*) filter(where mock_eligible)::integer
  into v_total,v_a,v_b,v_c,v_d,v_eligible
  from classified;

  if v_total <> 512 or v_a+v_b+v_c+v_d <> v_total or v_eligible <> v_a+v_b then
    raise exception '11.3 quality classification is internally inconsistent: total %, A %, B %, C %, D %',
      v_total,v_a,v_b,v_c,v_d;
  end if;

  if v_eligible < 40 or v_c = 0 then
    raise exception '11.3 audit did not produce a usable distinction between Mock and Study Questions';
  end if;

  if exists (
    select 1 from public.questions question
    join public.certifications certification on certification.id=question.certification_id
    where certification.code='az-900' and question.mock_eligible
      and (not question.is_published or question.question_type<>'single_choice'
        or question.domain_id is null or question.topic_id is null or question.lesson_id is null
        or question.difficulty is null)
  ) then
    raise exception '11.3 approved an unpublished or structurally invalid Question';
  end if;

  raise notice '11.3 BANK TOTAL=% A=% B=% C=% D=% ELIGIBLE=%',v_total,v_a,v_b,v_c,v_d,v_eligible;

  for v_record in
    select domain.display_order,domain.title,count(question.id)::integer as total,
      count(question.id) filter(where question.mock_eligible)::integer as eligible,
      count(question.id) filter(where question.mock_eligible and question.difficulty='easy')::integer as easy,
      count(question.id) filter(where question.mock_eligible and question.difficulty='medium')::integer as medium,
      count(question.id) filter(where question.mock_eligible and question.difficulty='hard')::integer as hard
    from public.domains domain
    join public.questions question on question.domain_id=domain.id
    join public.certifications certification on certification.id=domain.certification_id
    where certification.code='az-900'
    group by domain.display_order,domain.title
    order by domain.display_order
  loop
    raise notice '11.3 DOMAIN % | % | total=% eligible=% E/M/H=%/%/%',
      v_record.display_order,v_record.title,v_record.total,v_record.eligible,
      v_record.easy,v_record.medium,v_record.hard;
  end loop;

  for v_record in
    select domain.display_order as domain_display_order,topic.display_order,topic.title,
      count(question.id)::integer as total,
      count(question.id) filter(where question.mock_eligible)::integer as eligible,
      count(question.id) filter(where question.mock_eligible and question.difficulty='easy')::integer as easy,
      count(question.id) filter(where question.mock_eligible and question.difficulty='medium')::integer as medium,
      count(question.id) filter(where question.mock_eligible and question.difficulty='hard')::integer as hard
    from public.topics topic
    join public.domains domain on domain.id=topic.domain_id
    join public.questions question on question.topic_id=topic.id
    join public.certifications certification on certification.id=domain.certification_id
    where certification.code='az-900'
    group by domain.display_order,topic.display_order,topic.title
    order by domain.display_order,topic.display_order
  loop
    raise notice '11.3 TOPIC %.% | % | total=% eligible=% E/M/H=%/%/%',
      v_record.domain_display_order,v_record.display_order,v_record.title,v_record.total,
      v_record.eligible,v_record.easy,v_record.medium,v_record.hard;
  end loop;
end;
$$;

commit;

begin;

insert into auth.users(
  instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at
) values
  ('00000000-0000-0000-0000-000000000000','62000000-0000-4000-8000-000000000001',
   'authenticated','authenticated','mock-selector-a@example.invalid','',now(),
   '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()),
  ('00000000-0000-0000-0000-000000000000','62000000-0000-4000-8000-000000000002',
   'authenticated','authenticated','mock-selector-b@example.invalid','',now(),
   '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()),
  ('00000000-0000-0000-0000-000000000000','62000000-0000-4000-8000-000000000003',
   'authenticated','authenticated','mock-selector-simulation@example.invalid','',now(),
   '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now());

create temporary table audit_113_attempts (
  user_label text not null,
  mock_no integer not null,
  attempt_id uuid not null,
  question_id uuid not null,
  domain_order integer not null,
  topic_id uuid not null,
  difficulty text not null,
  primary key(user_label,mock_no,question_id)
) on commit drop;

do $$
declare
  v_certification_id uuid := (select id from public.certifications where code='az-900');
  v_attempt_a public.mock_exam_attempts;
  v_attempt_b public.mock_exam_attempts;
  v_attempt public.mock_exam_attempts;
  v_mock integer;
  v_record record;
begin
  perform set_config('request.jwt.claim.sub','62000000-0000-4000-8000-000000000001',true);
  select * into strict v_attempt_a
  from public.start_mock_exam_internal(v_certification_id,'deterministic-parity');

  perform set_config('request.jwt.claim.sub','62000000-0000-4000-8000-000000000002',true);
  select * into strict v_attempt_b
  from public.start_mock_exam_internal(v_certification_id,'deterministic-parity');

  if exists (
    (select question_id,display_order from public.mock_exam_attempt_questions
      where attempt_id=v_attempt_a.id
     except
     select question_id,display_order from public.mock_exam_attempt_questions
      where attempt_id=v_attempt_b.id)
    union all
    (select question_id,display_order from public.mock_exam_attempt_questions
      where attempt_id=v_attempt_b.id
     except
     select question_id,display_order from public.mock_exam_attempt_questions
      where attempt_id=v_attempt_a.id)
  ) then
    raise exception '11.3 same seed + same history was not deterministic';
  end if;

  if (select count(*) from public.mock_exam_attempt_questions where attempt_id=v_attempt_a.id)<>40
    or (select count(distinct question_id) from public.mock_exam_attempt_questions
        where attempt_id=v_attempt_a.id)<>40
    or exists (
      select 1 from public.mock_exam_attempt_questions item
      join public.questions question on question.id=item.question_id
      where item.attempt_id=v_attempt_a.id
        and (not question.mock_eligible or not question.is_published
          or question.certification_id<>v_certification_id)
    ) then
    raise exception '11.3 basic size, uniqueness, eligibility or certification selection failed';
  end if;

  if exists (
    select domain.display_order,count(*)
    from public.mock_exam_attempt_questions item
    join public.domains domain on domain.id=item.domain_id
    where item.attempt_id=v_attempt_a.id
    group by domain.display_order
    having count(*)<>case domain.display_order when 1 then 11 when 2 then 15 when 3 then 14 end
  ) then
    raise exception '11.3 Domain allocation is not 11/15/14';
  end if;

  if (select count(*) from public.mock_exam_attempt_questions
      where attempt_id=v_attempt_a.id and difficulty_snapshot='easy')<>12
    or (select count(*) from public.mock_exam_attempt_questions
      where attempt_id=v_attempt_a.id and difficulty_snapshot='medium')<>20
    or (select count(*) from public.mock_exam_attempt_questions
      where attempt_id=v_attempt_a.id and difficulty_snapshot='hard')<>8 then
    raise exception '11.3 healthy-pool difficulty allocation is not 12/20/8';
  end if;

  if exists (
    select domain_id,max(amount)-min(amount) as spread
    from (
      select item.domain_id,item.topic_id,count(*) as amount
      from public.mock_exam_attempt_questions item
      where item.attempt_id=v_attempt_a.id
      group by item.domain_id,item.topic_id
    ) distribution
    group by domain_id having max(amount)-min(amount)>1
  ) then
    raise exception '11.3 Topic allocation is not near-even';
  end if;

  update public.mock_exam_attempts set status='abandoned',abandoned_at=clock_timestamp()
  where id in (v_attempt_a.id,v_attempt_b.id);

  perform set_config('request.jwt.claim.sub','62000000-0000-4000-8000-000000000003',true);
  for v_mock in 1..10 loop
    select * into strict v_attempt
    from public.start_mock_exam_internal(v_certification_id,'simulation-'||v_mock::text);

    insert into audit_113_attempts
    select 'simulation',v_mock,v_attempt.id,item.question_id,domain.display_order,
      item.topic_id,item.difficulty_snapshot
    from public.mock_exam_attempt_questions item
    join public.domains domain on domain.id=item.domain_id
    where item.attempt_id=v_attempt.id;

    update public.mock_exam_attempts
    set status='abandoned',abandoned_at=clock_timestamp()
    where id=v_attempt.id;
  end loop;

  if exists (
    select mock_no,domain_order,count(*)
    from audit_113_attempts where user_label='simulation'
    group by mock_no,domain_order
    having count(*)<>case domain_order when 1 then 11 when 2 then 15 when 3 then 14 end
  ) or exists (
    select mock_no from audit_113_attempts where user_label='simulation'
    group by mock_no
    having count(*)<>40 or count(distinct question_id)<>40
      or count(*) filter(where difficulty='easy')<>12
      or count(*) filter(where difficulty='medium')<>20
      or count(*) filter(where difficulty='hard')<>8
  ) then
    raise exception '11.3 one of ten simulations violated size, Domain or difficulty';
  end if;

  if exists (
    select mock_no,domain_order,max(amount)-min(amount)
    from (
      select mock_no,domain_order,topic_id,count(*) amount
      from audit_113_attempts where user_label='simulation'
      group by mock_no,domain_order,topic_id
    ) topic_counts
    group by mock_no,domain_order
    having max(amount)-min(amount)>1
  ) then
    raise exception '11.3 one of ten simulations violated Topic balance';
  end if;

  if (select count(distinct topic_id) from audit_113_attempts where user_label='simulation')
      <> (select count(*) from public.topics topic join public.domains domain on domain.id=topic.domain_id
          where domain.certification_id=v_certification_id)
    or exists (
      select 1 from public.questions question
      join audit_113_attempts item on item.question_id=question.id
      where not question.mock_eligible
    ) then
    raise exception '11.3 simulations missed a Topic or used Study-only content';
  end if;

  for v_record in
    with per_mock as (
      select current_item.mock_no,
        count(*) filter(where previous_item.question_id is not null)::integer as overlap,
        count(distinct current_item.topic_id)::integer as topics,
        count(*) filter(where current_item.difficulty='easy')::integer as easy,
        count(*) filter(where current_item.difficulty='medium')::integer as medium,
        count(*) filter(where current_item.difficulty='hard')::integer as hard
      from audit_113_attempts current_item
      left join audit_113_attempts previous_item
        on previous_item.user_label=current_item.user_label
        and previous_item.mock_no=current_item.mock_no-1
        and previous_item.question_id=current_item.question_id
      where current_item.user_label='simulation'
      group by current_item.mock_no
    )
    select * from per_mock order by mock_no
  loop
    raise notice '11.3 SIM MOCK=% D1=11 D2=15 D3=14 E/M/H=%/%/% TOPICS=% OVERLAP_PREVIOUS=%',
      v_record.mock_no,v_record.easy,v_record.medium,v_record.hard,
      v_record.topics,v_record.overlap;
  end loop;

  for v_record in
    select checkpoint,count(distinct item.question_id)::integer as unique_questions
    from (values(1),(2),(3),(5),(10)) point(checkpoint)
    join audit_113_attempts item on item.mock_no<=point.checkpoint
      and item.user_label='simulation'
    group by checkpoint order by checkpoint
  loop
    raise notice '11.3 CUMULATIVE MOCKS=% UNIQUE=%',v_record.checkpoint,v_record.unique_questions;
  end loop;

  select avg(overlap)::numeric(6,2) as average_overlap,max(overlap) as maximum_overlap
  into v_record
  from (
    select current_item.mock_no,count(*) filter(where previous_item.question_id is not null) overlap
    from audit_113_attempts current_item
    left join audit_113_attempts previous_item
      on previous_item.mock_no=current_item.mock_no-1
      and previous_item.question_id=current_item.question_id
      and previous_item.user_label=current_item.user_label
    where current_item.user_label='simulation' and current_item.mock_no>1
    group by current_item.mock_no
  ) overlap_stats;
  raise notice '11.3 OVERLAP AVG=% MAX=%',v_record.average_overlap,v_record.maximum_overlap;

  if exists (
    select expected.domain_order
    from (values(1),(3)) expected(domain_order)
    where (select count(distinct extra.topic_id)
      from (
        select mock_no,domain_order,topic_id,count(*) amount
        from audit_113_attempts
        where user_label='simulation' and domain_order=expected.domain_order
        group by mock_no,domain_order,topic_id
      ) extra where extra.amount=4) < 3
  ) then
    raise exception '11.3 Topic extra slots did not rotate across all eligible Topics';
  end if;
end;
$$;

grant select on audit_113_attempts to authenticated;

set local role authenticated;
select set_config('request.jwt.claim.sub','62000000-0000-4000-8000-000000000001',true);

do $$
declare
  v_certification_id uuid := (select id from public.certifications where code='az-900');
  v_attempt public.mock_exam_attempts;
begin
  select * into strict v_attempt from public.start_mock_exam(v_certification_id);
  if v_attempt.user_id<>'62000000-0000-4000-8000-000000000001'
    or (select count(*) from public.get_mock_exam_attempt_questions(v_attempt.id))<>40 then
    raise exception '11.3 authenticated public start/resume failed';
  end if;

  if exists (
    select 1 from public.mock_exam_attempts
    where user_id='62000000-0000-4000-8000-000000000002'
  ) or (select count(*) from public.get_mock_exam_attempt_questions(
      (select id from public.mock_exam_attempts
       where user_id='62000000-0000-4000-8000-000000000002' limit 1)))<>0 then
    raise exception '11.3 user A can observe user B history';
  end if;
end;
$$;

rollback;

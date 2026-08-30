begin;

do $$ begin
  if to_regprocedure('public.start_mock_exam_internal(uuid,text)') is null then
    raise exception '11.3 selector is missing';
  end if;
end $$;

commit;

begin;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values('00000000-0000-0000-0000-000000000000','64000000-0000-4000-8000-000000000001',
  'authenticated','authenticated','mock-final-audit@example.invalid','',now(),
  '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now());

create temporary table audit_113_final(
  mock_no integer not null,question_id uuid not null,domain_order integer not null,
  topic_id uuid not null,difficulty text not null,primary key(mock_no,question_id)
) on commit drop;

do $$
declare
  v_certification_id uuid := (select id from public.certifications where code='az-900');
  v_attempt public.mock_exam_attempts;
  v_mock integer;
  v_payload jsonb;
begin
  perform set_config('request.jwt.claim.sub','64000000-0000-4000-8000-000000000001',true);
  for v_mock in 1..10 loop
    select * into strict v_attempt
    from public.start_mock_exam_internal(v_certification_id,'final-audit-'||v_mock::text);
    insert into audit_113_final
    select v_mock,item.question_id,domain.display_order,item.topic_id,item.difficulty_snapshot
    from public.mock_exam_attempt_questions item
    join public.domains domain on domain.id=item.domain_id where item.attempt_id=v_attempt.id;
    update public.mock_exam_attempts set status='abandoned',abandoned_at=clock_timestamp()
    where id=v_attempt.id;
  end loop;

  with classified as (
    select question.*,
      (question.is_published and question.question_type='single_choice'
        and question.domain_id is not null and question.topic_id is not null
        and question.lesson_id is not null and question.difficulty is not null
        and coalesce(length(btrim(question.explanation)),0)>0
        and (select count(*) from public.question_options option where option.question_id=question.id)=4
        and (select count(*) from public.question_options option
             where option.question_id=question.id and option.is_correct)=1) study_valid,
      (question.question_text ~* '(empresa|organiza[cç][aã]o|equipe|cliente|aplica[cç][aã]o|carga de trabalho|requisito|precisa|deseja|usu[aá]rio|administrador|cen[aá]rio)') scenario_style
    from public.questions question
    where question.certification_id=v_certification_id
  ), bank as (
    select count(*) total,
      count(*) filter(where mock_eligible and scenario_style and difficulty in ('medium','hard')) grade_a,
      count(*) filter(where mock_eligible and not (scenario_style and difficulty in ('medium','hard'))) grade_b,
      count(*) filter(where not mock_eligible and study_valid) grade_c,
      count(*) filter(where not mock_eligible and not study_valid) grade_d,
      count(*) filter(where mock_eligible) eligible
    from classified
  ), domains as (
    select domain.display_order,domain.title,count(question.id) total,
      count(question.id) filter(where question.mock_eligible) eligible,
      count(question.id) filter(where question.mock_eligible and question.difficulty='easy') easy,
      count(question.id) filter(where question.mock_eligible and question.difficulty='medium') medium,
      count(question.id) filter(where question.mock_eligible and question.difficulty='hard') hard
    from public.domains domain join public.questions question on question.domain_id=domain.id
    where domain.certification_id=v_certification_id group by domain.display_order,domain.title
  ), topics as (
    select domain.display_order domain_order,topic.display_order topic_order,topic.title,
      count(question.id) total,count(question.id) filter(where question.mock_eligible) eligible,
      count(question.id) filter(where question.mock_eligible and question.difficulty='easy') easy,
      count(question.id) filter(where question.mock_eligible and question.difficulty='medium') medium,
      count(question.id) filter(where question.mock_eligible and question.difficulty='hard') hard
    from public.topics topic join public.domains domain on domain.id=topic.domain_id
    join public.questions question on question.topic_id=topic.id
    where domain.certification_id=v_certification_id
    group by domain.display_order,topic.display_order,topic.title
  ), mocks as (
    select current_item.mock_no,
      count(*) filter(where current_item.domain_order=1) d1,
      count(*) filter(where current_item.domain_order=2) d2,
      count(*) filter(where current_item.domain_order=3) d3,
      count(*) filter(where current_item.difficulty='easy') easy,
      count(*) filter(where current_item.difficulty='medium') medium,
      count(*) filter(where current_item.difficulty='hard') hard,
      count(distinct current_item.topic_id) topics,
      count(*) filter(where previous_item.question_id is not null) overlap
    from audit_113_final current_item
    left join audit_113_final previous_item on previous_item.mock_no=current_item.mock_no-1
      and previous_item.question_id=current_item.question_id
    group by current_item.mock_no
  ), cumulative as (
    select checkpoint,count(distinct item.question_id) unique_questions
    from (values(1),(2),(3),(5),(10)) point(checkpoint)
    join audit_113_final item on item.mock_no<=point.checkpoint group by checkpoint
  ), overlap_stats as (
    select round(avg(overlap),2) average,max(overlap) maximum from mocks where mock_no>1
  )
  select jsonb_build_object(
    'bank',(select to_jsonb(bank) from bank),
    'domains',(select jsonb_agg(to_jsonb(domains) order by display_order) from domains),
    'topics',(select jsonb_agg(to_jsonb(topics) order by domain_order,topic_order) from topics),
    'mocks',(select jsonb_agg(to_jsonb(mocks) order by mock_no) from mocks),
    'cumulative',(select jsonb_agg(to_jsonb(cumulative) order by checkpoint) from cumulative),
    'overlap',(select to_jsonb(overlap_stats) from overlap_stats)
  ) into v_payload;

  execute format(
    'comment on function public.start_mock_exam(uuid) is %L',
    'AZ-900 Mock selection engine. 11.3 audit snapshot: ' || v_payload::text
  );

  delete from auth.users where id='64000000-0000-4000-8000-000000000001';
  if exists (select 1 from public.mock_exam_attempts
      where user_id='64000000-0000-4000-8000-000000000001') then
    raise exception '11.3 audit fixture cleanup failed';
  end if;
end;
$$;

commit;

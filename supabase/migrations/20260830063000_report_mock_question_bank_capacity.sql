begin;

do $$
declare
  v_record record;
begin
  for v_record in
    with classified as (
      select question.*,
        (question.is_published and question.question_type='single_choice'
          and question.domain_id is not null and question.topic_id is not null
          and question.lesson_id is not null and question.difficulty is not null
          and coalesce(length(btrim(question.explanation)),0)>0
          and (select count(*) from public.question_options option
               where option.question_id=question.id)=4
          and (select count(*) from public.question_options option
               where option.question_id=question.id and option.is_correct)=1) study_valid,
        (question.question_text ~* '(empresa|organiza[cç][aã]o|equipe|cliente|aplica[cç][aã]o|carga de trabalho|requisito|precisa|deseja|usu[aá]rio|administrador|cen[aá]rio)') scenario_style
      from public.questions question
      join public.certifications certification on certification.id=question.certification_id
      where certification.code='az-900'
    )
    select count(*)::integer total,
      count(*) filter(where mock_eligible and scenario_style and difficulty in ('medium','hard'))::integer grade_a,
      count(*) filter(where mock_eligible and not (scenario_style and difficulty in ('medium','hard')))::integer grade_b,
      count(*) filter(where not mock_eligible and study_valid)::integer grade_c,
      count(*) filter(where not mock_eligible and not study_valid)::integer grade_d,
      count(*) filter(where mock_eligible)::integer eligible
    from classified
  loop
    raise warning 'BANK|TOTAL=%|A=%|B=%|C=%|D=%|ELIGIBLE=%',v_record.total,
      v_record.grade_a,v_record.grade_b,v_record.grade_c,v_record.grade_d,v_record.eligible;
  end loop;

  for v_record in
    select domain.display_order domain_order,domain.title,count(question.id)::integer total,
      count(question.id) filter(where question.mock_eligible)::integer eligible,
      count(question.id) filter(where question.mock_eligible and question.difficulty='easy')::integer easy,
      count(question.id) filter(where question.mock_eligible and question.difficulty='medium')::integer medium,
      count(question.id) filter(where question.mock_eligible and question.difficulty='hard')::integer hard
    from public.domains domain join public.questions question on question.domain_id=domain.id
    join public.certifications certification on certification.id=domain.certification_id
    where certification.code='az-900'
    group by domain.display_order,domain.title order by domain.display_order
  loop
    raise warning 'DOMAIN|%= %|TOTAL=%|ELIGIBLE=%|E=%|M=%|H=%',v_record.domain_order,
      v_record.title,v_record.total,v_record.eligible,v_record.easy,v_record.medium,v_record.hard;
  end loop;

  for v_record in
    select domain.display_order domain_order,topic.display_order topic_order,topic.title,
      count(question.id)::integer total,
      count(question.id) filter(where question.mock_eligible)::integer eligible,
      count(question.id) filter(where question.mock_eligible and question.difficulty='easy')::integer easy,
      count(question.id) filter(where question.mock_eligible and question.difficulty='medium')::integer medium,
      count(question.id) filter(where question.mock_eligible and question.difficulty='hard')::integer hard
    from public.topics topic join public.domains domain on domain.id=topic.domain_id
    join public.questions question on question.topic_id=topic.id
    join public.certifications certification on certification.id=domain.certification_id
    where certification.code='az-900'
    group by domain.display_order,topic.display_order,topic.title
    order by domain.display_order,topic.display_order
  loop
    raise warning 'TOPIC|%.%=%|TOTAL=%|ELIGIBLE=%|E=%|M=%|H=%',v_record.domain_order,
      v_record.topic_order,v_record.title,v_record.total,v_record.eligible,
      v_record.easy,v_record.medium,v_record.hard;
  end loop;
end;
$$;

commit;

begin;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values('00000000-0000-0000-0000-000000000000','63000000-0000-4000-8000-000000000001',
  'authenticated','authenticated','mock-capacity-report@example.invalid','',now(),
  '{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now());

create temporary table audit_113_report(
  mock_no integer not null,question_id uuid not null,domain_order integer not null,
  topic_id uuid not null,difficulty text not null,primary key(mock_no,question_id)
) on commit drop;

do $$
declare
  v_certification_id uuid := (select id from public.certifications where code='az-900');
  v_attempt public.mock_exam_attempts;
  v_mock integer;
  v_record record;
begin
  perform set_config('request.jwt.claim.sub','63000000-0000-4000-8000-000000000001',true);
  for v_mock in 1..10 loop
    select * into strict v_attempt
    from public.start_mock_exam_internal(v_certification_id,'capacity-'||v_mock::text);
    insert into audit_113_report
    select v_mock,item.question_id,domain.display_order,item.topic_id,item.difficulty_snapshot
    from public.mock_exam_attempt_questions item
    join public.domains domain on domain.id=item.domain_id where item.attempt_id=v_attempt.id;
    update public.mock_exam_attempts set status='abandoned',abandoned_at=clock_timestamp()
    where id=v_attempt.id;
  end loop;

  for v_record in
    select current_item.mock_no,
      count(*) filter(where current_item.domain_order=1)::integer d1,
      count(*) filter(where current_item.domain_order=2)::integer d2,
      count(*) filter(where current_item.domain_order=3)::integer d3,
      count(*) filter(where current_item.difficulty='easy')::integer easy,
      count(*) filter(where current_item.difficulty='medium')::integer medium,
      count(*) filter(where current_item.difficulty='hard')::integer hard,
      count(distinct current_item.topic_id)::integer topics,
      count(*) filter(where previous_item.question_id is not null)::integer overlap
    from audit_113_report current_item
    left join audit_113_report previous_item on previous_item.mock_no=current_item.mock_no-1
      and previous_item.question_id=current_item.question_id
    group by current_item.mock_no order by current_item.mock_no
  loop
    raise warning 'MOCK|%=|D1=%|D2=%|D3=%|E=%|M=%|H=%|TOPICS=%|OVERLAP=%',
      v_record.mock_no,v_record.d1,v_record.d2,v_record.d3,v_record.easy,v_record.medium,
      v_record.hard,v_record.topics,v_record.overlap;
  end loop;

  for v_record in
    select checkpoint,count(distinct report.question_id)::integer unique_questions
    from (values(1),(2),(3),(5),(10)) point(checkpoint)
    join audit_113_report report on report.mock_no<=point.checkpoint
    group by checkpoint order by checkpoint
  loop
    raise warning 'CUMULATIVE|MOCKS=%|UNIQUE=%',v_record.checkpoint,v_record.unique_questions;
  end loop;

  select avg(overlap)::numeric(6,2) average_overlap,max(overlap)::integer maximum_overlap
  into v_record from (
    select current_item.mock_no,count(*) filter(where previous_item.question_id is not null) overlap
    from audit_113_report current_item
    left join audit_113_report previous_item on previous_item.mock_no=current_item.mock_no-1
      and previous_item.question_id=current_item.question_id
    where current_item.mock_no>1 group by current_item.mock_no
  ) overlap_data;
  raise warning 'OVERLAP|AVG=%|MAX=%',v_record.average_overlap,v_record.maximum_overlap;
end;
$$;

rollback;

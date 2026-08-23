begin;

do $$
declare
  question_count integer;
  invalid_option_count integer;
  invalid_relationship_count integer;
begin
  select count(*)
  into question_count
  from public.questions question
  join public.certifications certification on certification.id = question.certification_id
  where certification.code = 'az-900';

  if question_count <> 10 then
    raise exception 'Expected 10 AZ-900 questions, found %.', question_count;
  end if;

  select count(*)
  into invalid_option_count
  from (
    select
      question.id,
      count(option.id) as option_count,
      count(option.id) filter (where option.is_correct) as correct_count
    from public.questions question
    left join public.question_options option on option.question_id = question.id
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
  ) invalid;

  if invalid_option_count <> 0 then
    raise exception '% seed questions do not have exactly 4 options and 1 correct answer.', invalid_option_count;
  end if;

  select count(*)
  into invalid_relationship_count
  from public.questions question
  join public.lessons lesson on lesson.id = question.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  where question.topic_id <> topic.id
     or question.domain_id <> domain.id
     or question.certification_id <> domain.certification_id;

  if invalid_relationship_count <> 0 then
    raise exception '% questions have an inconsistent certification/domain/topic/lesson hierarchy.', invalid_relationship_count;
  end if;

  if exists (
    select 1
    from public.questions
    where explanation is null
      or difficulty is null
      or question_type <> 'single_choice'
  ) then
    raise exception 'Every seed question must have explanation, difficulty and single_choice type.';
  end if;

  if exists (
    select 1
    from public.question_options
    where question_id in (
      select id from public.questions where id::text like '60000000-0000-4000-8000-%'
    )
      and explanation is null
  ) then
    raise exception 'Every seed option must have an explanation.';
  end if;
end;
$$;

do $$
declare
  az900_id uuid := (select id from public.certifications where code = 'az-900');
  cloud_domain_id uuid := '20000000-0000-4000-8000-000000000001';
  cloud_topic_id uuid := '30000000-0000-4000-8000-000000000001';
  region_lesson_id uuid := (
    select id from public.lessons where slug = 'azure-regions'
  );
begin
  begin
    insert into public.questions (
      certification_id, domain_id, topic_id, lesson_id, question_text
    ) values (
      az900_id,
      cloud_domain_id,
      cloud_topic_id,
      region_lesson_id,
      'Invalid hierarchy test'
    );
    raise exception 'A mismatched lesson/topic relationship unexpectedly succeeded.';
  exception
    when foreign_key_violation then null;
  end;

  begin
    insert into public.questions (certification_id, question_text, question_type)
    values (az900_id, 'Invalid type test', 'multiple_choice');
    raise exception 'An unsupported question_type unexpectedly succeeded.';
  exception
    when check_violation then null;
  end;

  begin
    insert into public.questions (certification_id, question_text, difficulty)
    values (az900_id, 'Invalid difficulty test', 'expert');
    raise exception 'An unsupported difficulty unexpectedly succeeded.';
  exception
    when check_violation then null;
  end;

  begin
    insert into public.question_options (
      question_id, option_text, is_correct, display_order
    ) values (
      '60000000-0000-4000-8000-000000000001',
      'Second correct answer test',
      true,
      99
    );
    raise exception 'A second correct option unexpectedly succeeded.';
  exception
    when unique_violation then null;
  end;
end;
$$;

insert into public.questions (
  id,
  certification_id,
  question_text,
  explanation,
  is_published,
  display_order
)
values (
  '60000000-0000-4000-8000-999999999999',
  (select id from public.certifications where code = 'az-900'),
  'Unpublished RLS test',
  'This row must stay invisible to authenticated users.',
  false,
  999
);

insert into public.question_options (
  id, question_id, option_text, is_correct, display_order
)
values (
  '70000000-0000-4000-8000-999999999999',
  '60000000-0000-4000-8000-999999999999',
  'Hidden option',
  true,
  1
);

set local role authenticated;

do $$
begin
  if (select count(*) from public.questions) <> 10 then
    raise exception 'Authenticated users should see exactly the 10 published questions.';
  end if;

  if exists (
    select 1
    from public.questions
    where id = '60000000-0000-4000-8000-999999999999'
  ) then
    raise exception 'An unpublished question is visible to authenticated users.';
  end if;

  if exists (
    select 1
    from public.question_options
    where question_id = '60000000-0000-4000-8000-999999999999'
  ) then
    raise exception 'Options of an unpublished question are visible to authenticated users.';
  end if;

  if (select count(*) from public.question_options) <> 40 then
    raise exception 'Authenticated users should see exactly 40 published question options.';
  end if;

  begin
    insert into public.questions (certification_id, question_text)
    values ('10000000-0000-4000-8000-000000000900', 'RLS insert test');
    raise exception 'Authenticated INSERT unexpectedly succeeded.';
  exception
    when insufficient_privilege then null;
  end;

  begin
    update public.questions
    set question_text = question_text
    where id = '60000000-0000-4000-8000-000000000001';
    raise exception 'Authenticated UPDATE unexpectedly succeeded.';
  exception
    when insufficient_privilege then null;
  end;

  begin
    delete from public.questions
    where id = '60000000-0000-4000-8000-000000000001';
    raise exception 'Authenticated DELETE unexpectedly succeeded.';
  exception
    when insufficient_privilege then null;
  end;
end;
$$;

select json_build_object(
  'questions', (select count(*) from public.questions),
  'options', (select count(*) from public.question_options),
  'correct_options', (select count(*) from public.question_options where is_correct),
  'unpublished_visible', (
    select count(*)
    from public.questions
    where id = '60000000-0000-4000-8000-999999999999'
  ),
  'authenticated_writes_denied', true
) as questions_foundation_validation;

rollback;

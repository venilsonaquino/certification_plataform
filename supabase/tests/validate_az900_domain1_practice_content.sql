begin;

set local statement_timeout = '30s';

do $$
declare
  domain_flashcards integer;
  corrected_flashcards integer;
  exact_duplicates integer;
begin
  if not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260826040000'
  ) then
    raise exception 'Domain 1 practice content migration is not registered';
  end if;

  select count(*)
  into domain_flashcards
  from public.flashcards flashcard
  join public.lessons lesson on lesson.id = flashcard.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and flashcard.is_published;

  if domain_flashcards <> 84 then
    raise exception 'Domain 1 must preserve exactly 84 published flashcards';
  end if;

  select count(*)
  into corrected_flashcards
  from public.flashcards
  where id in (
    '71000000-0000-4000-8000-000000000001','71000000-0000-4000-8000-000000000004',
    '71000000-0000-4000-8000-000000000005','71000000-0000-4000-8000-000000000007',
    '71000000-0000-4000-8000-000000000011','71000000-0000-4000-8000-000000000014',
    '71000000-0000-4000-8000-000000000015','71000000-0000-4000-8000-000000000019',
    '71000000-0000-4000-8000-000000000021','71000000-0000-4000-8000-000000000024',
    '71000000-0000-4000-8000-000000000025','71000000-0000-4000-8000-000000000031',
    '71000000-0000-4000-8000-000000000034','71000000-0000-4000-8000-000000000036',
    '71000000-0000-4000-8000-000000000038','71000000-0000-4000-8000-000000000043',
    '71000000-0000-4000-8000-000000000045','71000000-0000-4000-8000-000000000046',
    '71000000-0000-4000-8000-000000000047','71000000-0000-4000-8000-000000000048',
    '71000000-0000-4000-8000-000000000050','71000000-0000-4000-8000-000000000053',
    '71000000-0000-4000-8000-000000000054','71000000-0000-4000-8000-000000000056',
    '71000000-0000-4000-8000-000000000059','71000000-0000-4000-8000-000000000069',
    '71000000-0000-4000-8000-000000000070','71000000-0000-4000-8000-000000000071',
    '71000000-0000-4000-8000-000000000072'
  )
    and is_published
    and length(front_text) between 1 and 120
    and length(back_text) between 1 and 240;

  if corrected_flashcards <> 29 then
    raise exception 'The 29 corrected flashcards are not all available and concise';
  end if;

  if exists (
    select 1
    from public.flashcards flashcard
    join public.lessons lesson on lesson.id = flashcard.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and (length(flashcard.front_text) > 120 or length(flashcard.back_text) > 240)
  ) then
    raise exception 'A Domain 1 flashcard remains excessively long';
  end if;

  select count(*)
  into exact_duplicates
  from (
    select lower(regexp_replace(btrim(flashcard.front_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.flashcards flashcard
    join public.lessons lesson on lesson.id = flashcard.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
    group by 1
    having count(*) > 1
  ) duplicate;

  if exact_duplicates <> 0 then
    raise exception 'Domain 1 contains exact normalized flashcard duplicates';
  end if;

  if not exists (
    select 1 from public.flashcards
    where id = '71000000-0000-4000-8000-000000000019'
      and back_text ilike 'Não.%depende do serviço%'
  ) or not exists (
    select 1 from public.flashcards
    where id = '71000000-0000-4000-8000-000000000024'
      and back_text ilike '%depende do contrato%'
  ) or not exists (
    select 1 from public.flashcards
    where id = '71000000-0000-4000-8000-000000000007'
      and front_text = 'Quem administra o sistema operacional em PaaS?'
  ) then
    raise exception 'A required factual flashcard correction is missing';
  end if;
end;
$$;

do $$
declare
  domain_questions integer;
  new_questions integer;
  new_options integer;
  exact_duplicates integer;
  distribution jsonb;
begin
  select count(*)
  into domain_questions
  from public.questions question
  join public.lessons lesson on lesson.id = question.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and question.is_published;

  if domain_questions <> 153 then
    raise exception 'Domain 1 must have exactly 153 published questions';
  end if;

  select count(*) into new_questions
  from public.questions
  where id between '66000000-0000-4000-8000-000000000001'
               and '66000000-0000-4000-8000-000000000020'
    and is_published
    and explanation is not null
    and btrim(explanation) <> '';

  select count(*) into new_options
  from public.question_options
  where id between '7d000000-0000-4000-8000-000000000001'
               and '7d000000-0000-4000-8000-000000000080';

  if new_questions <> 20 or new_options <> 80 then
    raise exception 'Expected 20 new questions and 80 new options';
  end if;

  if exists (
    select 1
    from public.questions question
    left join public.question_options option on option.question_id = question.id
    where question.id between '66000000-0000-4000-8000-000000000001'
                          and '66000000-0000-4000-8000-000000000020'
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
  ) then
    raise exception 'A new question does not have four distinct options and one correct answer';
  end if;

  select jsonb_object_agg(slug, published_questions)
  into distribution
  from (
    select lesson.slug, count(question.id) filter (where question.is_published) as published_questions
    from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    left join public.questions question on question.lesson_id = lesson.id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
    group by lesson.slug
  ) lesson_distribution;

  if (distribution ->> 'infrastructure-as-a-service')::integer <> 5
    or (distribution ->> 'platform-as-a-service')::integer <> 5
    or (distribution ->> 'security-and-governance-benefits')::integer <> 6
    or (distribution ->> 'manageability')::integer <> 5 then
    raise exception 'Previously weak Lessons have unexpected distribution: %', distribution;
  end if;

  if exists (
    select 1
    from jsonb_each_text(distribution)
    where value::integer < 5
  ) then
    raise exception 'A Domain 1 Lesson still has fewer than five published questions';
  end if;

  select count(*)
  into exact_duplicates
  from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
    group by 1
    having count(*) > 1
  ) duplicate;

  if exact_duplicates <> 0 then
    raise exception 'Domain 1 contains exact normalized question duplicates';
  end if;

  if exists (
    select 1
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and (question.explanation is null or btrim(question.explanation) = '')
  ) then
    raise exception 'A published Domain 1 question has no teaching explanation';
  end if;

  if exists (
    select 1
    from public.questions
    where id in (
      '62000000-0000-4000-8000-000000000079',
      '62000000-0000-4000-8000-000000000080'
    )
      and (question_text ilike '%zone%' or question_text ilike '%regi%')
  ) then
    raise exception 'High Availability practice still anticipates Zones or Regions';
  end if;
end;
$$;

do $$
begin
  if exists (
    select 1
    from public.question_options
    where id in (
      '73000000-0000-4000-8000-000000000037','73000000-0000-4000-8000-000000000038',
      '73000000-0000-4000-8000-000000000040','73000000-0000-4000-8000-000000000121',
      '73000000-0000-4000-8000-000000000123','73000000-0000-4000-8000-000000000124',
      '73000000-0000-4000-8000-000000000129','73000000-0000-4000-8000-000000000130',
      '73000000-0000-4000-8000-000000000131','73000000-0000-4000-8000-000000000169',
      '73000000-0000-4000-8000-000000000170','73000000-0000-4000-8000-000000000172',
      '73000000-0000-4000-8000-000000000249','73000000-0000-4000-8000-000000000252',
      '73000000-0000-4000-8000-000000000341','73000000-0000-4000-8000-000000000342',
      '73000000-0000-4000-8000-000000000344','73000000-0000-4000-8000-000000000425',
      '73000000-0000-4000-8000-000000000427','73000000-0000-4000-8000-000000000428',
      '73000000-0000-4000-8000-000000000446','73000000-0000-4000-8000-000000000447',
      '73000000-0000-4000-8000-000000000448','75000000-0000-4000-8000-000000000022',
      '75000000-0000-4000-8000-000000000023','75000000-0000-4000-8000-000000000024'
    )
      and (
        option_text ilike '%cadeir%'
        or option_text ilike '%feriad%'
        or option_text ilike '%cor da interface%'
        or option_text ilike '%funcionários%'
        or option_text ilike '%funcionarios%'
        or option_text ilike '%estacionamento%'
      )
  ) then
    raise exception 'A known implausible distractor was not corrected';
  end if;

  if exists (
    select 1
    from public.flashcard_reviews review
    left join public.flashcards flashcard on flashcard.id = review.flashcard_id
    where flashcard.id is null
  ) or exists (
    select 1
    from public.user_flashcard_progress progress
    left join public.flashcards flashcard on flashcard.id = progress.flashcard_id
    where flashcard.id is null
  ) then
    raise exception 'Flashcard history contains an orphaned flashcard reference';
  end if;
end;
$$;

select json_build_object(
  'domain', 'Describe cloud concepts',
  'flashcards_reviewed', 84,
  'flashcards_corrected', 29,
  'flashcards_added', 0,
  'questions_reviewed', 133,
  'questions_corrected', 3,
  'distractors_corrected', 34,
  'questions_added', 20,
  'published_flashcards', 84,
  'published_questions', 153,
  'minimum_questions_per_lesson', 5,
  'history_preserved', true
) as domain_1_practice_validation;

rollback;

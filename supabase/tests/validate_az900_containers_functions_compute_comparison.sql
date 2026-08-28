begin;

set local statement_timeout = '30s';

create temporary table target_lessons on commit drop as
select lesson.id, lesson.slug, lesson.estimated_minutes
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and domain.title = 'Describe Azure architecture and services'
  and topic.title = 'Compute Services'
  and lesson.slug in ('containers-on-azure', 'azure-functions', 'comparing-compute-options');

do $$
declare
  duplicate_count integer;
begin
  if not exists (
    select 1 from supabase_migrations.schema_migrations
    where version = '20260827030000'
  ) or not exists (
    select 1 from supabase_migrations.schema_migrations
    where version = '20260827031000'
  ) then
    raise exception 'An 8.6.4 migration is not registered';
  end if;

  if (select count(*) from target_lessons) <> 3
    or exists (
      select 1
      from target_lessons target
      join public.lessons lesson on lesson.id = target.id
      where not lesson.is_published
        or lesson.content is null
        or btrim(lesson.content) = ''
        or lesson.estimated_minutes <> 10
    ) then
    raise exception 'A scoped Lesson is missing or has invalid publication, fallback or estimate';
  end if;

  if (select array_agg(block.type order by block.display_order)
      from public.lesson_content_blocks block
      join target_lessons target on target.id = block.lesson_id
      where target.slug = 'containers-on-azure' and block.is_published)
      is distinct from array['explanation','important','example','dotnet_example','explanation','exam_tip','exam_trap','summary']::text[]
    or (select array_agg(block.type order by block.display_order)
      from public.lesson_content_blocks block
      join target_lessons target on target.id = block.lesson_id
      where target.slug = 'azure-functions' and block.is_published)
      is distinct from array['explanation','important','example','dotnet_example','important','exam_trap','exam_tip','summary']::text[]
    or (select array_agg(block.type order by block.display_order)
      from public.lesson_content_blocks block
      join target_lessons target on target.id = block.lesson_id
      where target.slug = 'comparing-compute-options' and block.is_published)
      is distinct from array['explanation','important','example','dotnet_example','dotnet_example','dotnet_example','exam_trap','exam_tip','summary']::text[] then
    raise exception 'A scoped Lesson has an unexpected Content Block sequence';
  end if;

  if exists (
    select 1
    from target_lessons target
    join public.lesson_content_blocks block on block.lesson_id = target.id
    group by target.id
    having min(block.display_order) <> 1
      or max(block.display_order) <> count(*)
      or count(distinct block.display_order) <> count(*)
      or count(*) filter (
        where block.type = 'summary'
          and jsonb_typeof(block.config -> 'items') = 'array'
          and jsonb_array_length(block.config -> 'items') between 3 and 6
      ) <> 1
      or count(*) filter (where block.type = 'exam_tip') <> 1
      or count(*) filter (where block.type = 'exam_trap') <> 1
      or count(*) filter (where block.is_published) <> count(*)
  ) then
    raise exception 'Display order, publication, summary, exam tip or exam trap is invalid';
  end if;

  if (select count(*) from public.lesson_content_blocks block join target_lessons target on target.id = block.lesson_id) <> 25
    or exists (
      select 1
      from public.lesson_content_blocks block
      join target_lessons target on target.id = block.lesson_id
      where block.type = 'visual_experience'
         or block.visual_experience_id is not null
    )
    or exists (
      select 1
      from public.visual_experiences visual
      join target_lessons target on target.id = visual.lesson_id
    ) then
    raise exception '8.6.4 block count or no-visual constraint is invalid';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join target_lessons target on target.id = block.lesson_id
    where target.slug = 'comparing-compute-options'
      and block.title = 'Matriz de comparação: VM | Container | Function'
      and block.content ilike '%Controle do SO%'
      and block.content ilike '%Guest OS próprio%'
      and block.content ilike '%Event-driven%'
  ) then
    raise exception 'The structured VM/container/Function comparison is missing';
  end if;

  if (select count(*) from public.flashcards card join target_lessons target on target.id = card.lesson_id where card.is_published) <> 11
    or not exists (select 1 from public.flashcards where id = '72000000-0000-4000-8000-000000000014' and back_text ilike '%kernel%host%guest OS%')
    or not exists (select 1 from public.flashcards where id = '72000000-0000-4000-8000-000000000015' and back_text ilike '%ACI%')
    or not exists (select 1 from public.flashcards where id = '72000000-0000-4000-8000-000000000016' and back_text ilike '%AKS%')
    or not exists (select 1 from public.flashcards where id = '72000000-0000-4000-8000-000000000013' and back_text ilike '%plano%configuração%') then
    raise exception 'The scoped Flashcards are incomplete or conceptually invalid';
  end if;

  if exists (
    select 1
    from public.questions question
    join target_lessons target on target.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where question.is_published
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
      or min(length(btrim(question.explanation))) < 40
  ) then
    raise exception 'A scoped Question or its options are invalid';
  end if;

  if exists (
    select 1
    from target_lessons target
    left join public.questions question on question.lesson_id = target.id and question.is_published
    group by target.id, target.slug
    having count(question.id) <> case target.slug
      when 'azure-functions' then 10 else 5 end
      or count(question.id) filter (where question.difficulty = 'easy') <> case target.slug
        when 'azure-functions' then 3 else 2 end
      or count(question.id) filter (where question.difficulty = 'medium') <> case target.slug
        when 'azure-functions' then 5 else 2 end
      or count(question.id) filter (where question.difficulty = 'hard') <> case target.slug
        when 'azure-functions' then 2 else 1 end
  ) then
    raise exception 'Question count or difficulty distribution is invalid';
  end if;

  if (select count(*) from public.questions where id between '68000000-0000-4000-8000-000000000011' and '68000000-0000-4000-8000-000000000015') <> 5
    or (select count(*) from public.questions where id between '63000000-0000-4000-8000-000000000111' and '63000000-0000-4000-8000-000000000120') <> 10
    or (select count(*) from public.questions where id between '65000000-0000-4000-8000-000000000011' and '65000000-0000-4000-8000-000000000015') <> 5 then
    raise exception 'Required existing/new practice records are missing';
  end if;

  if not exists (
    select 1
    from public.question_options option
    where option.id = '74000000-0000-4000-8000-000000000443'
      and option.is_correct
      and option.option_text ilike '%serverless%eventos%'
  ) then
    raise exception 'Azure Functions Question 111 has a semantically invalid correct option';
  end if;

  if exists (
    select 1
    from public.questions question
    join target_lessons target on target.id = question.lesson_id
    join public.question_options option on option.question_id = question.id
    where concat_ws(' ', question.question_text, question.explanation, option.option_text, option.explanation)
      ~* '(Premium plan|cold start|application settings|Function App configuration|Durable Functions|Helm|node pools|pods|ingress|cadeiras|marketing|cor do .cone)'
  ) then
    raise exception 'Advanced or absurd 8.6.4 practice content remains';
  end if;

  select count(*) into duplicate_count
  from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.questions question
    where question.topic_id = '32000000-0000-4000-8000-000000000002'
    group by 1
    having count(*) > 1
  ) duplicates;

  if duplicate_count <> 0 then
    raise exception 'Compute Services contains exact Question duplicates';
  end if;
end;
$$;

do $$
begin
  if exists (
    select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id = progress.lesson_id where lesson.id is null
  ) or exists (
    select 1 from public.flashcard_reviews review left join public.flashcards flashcard on flashcard.id = review.flashcard_id where flashcard.id is null
  ) or exists (
    select 1 from public.user_flashcard_progress progress left join public.flashcards flashcard on flashcard.id = progress.flashcard_id where flashcard.id is null
  ) or exists (
    select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id = item.attempt_id left join public.questions question on question.id = item.question_id where attempt.id is null or question.id is null
  ) or exists (
    select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id = answer.attempt_id left join public.questions question on question.id = answer.question_id left join public.question_options option on option.id = answer.selected_option_id where attempt.id is null or question.id is null or option.id is null
  ) then
    raise exception 'Study history contains an orphaned reference';
  end if;
end;
$$;

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
)
values (
  '00000000-0000-0000-0000-000000000000',
  '58000000-0000-4000-8000-000000000008',
  'authenticated', 'authenticated', 'compute-options-quiz@example.invalid', '', now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000008', true);

do $$
declare
  target record;
  lesson_attempt public.quiz_attempts;
  topic_attempt public.quiz_attempts;
begin
  if (
    select count(*)
    from public.lesson_content_blocks block
    join target_lessons target on target.id = block.lesson_id
    where block.is_published
  ) <> 25
    or (
      select count(*)
      from public.flashcards card
      join target_lessons target on target.id = card.lesson_id
      where card.is_published
    ) <> 11 then
    raise exception 'Authenticated users cannot read all published 8.6.4 content';
  end if;

  for target in select id from target_lessons order by slug
  loop
    select * into strict lesson_attempt from public.start_lesson_quiz(target.id);
    if lesson_attempt.user_id <> auth.uid()
      or lesson_attempt.lesson_id <> target.id
      or lesson_attempt.total_questions <> 5
      or lesson_attempt.status <> 'in_progress'
      or (select count(*) from public.quiz_attempt_questions where attempt_id = lesson_attempt.id) <> 5 then
      raise exception 'Lesson Quiz failed for %', target.id;
    end if;
  end loop;

  select * into strict topic_attempt
  from public.start_topic_quiz('32000000-0000-4000-8000-000000000002');

  if topic_attempt.user_id <> auth.uid()
    or topic_attempt.topic_id <> '32000000-0000-4000-8000-000000000002'
    or topic_attempt.lesson_id is not null
    or topic_attempt.quiz_type <> 'topic'
    or topic_attempt.total_questions <> 10
    or topic_attempt.status <> 'in_progress'
    or (select count(*) from public.quiz_attempt_questions where attempt_id = topic_attempt.id) <> 10 then
    raise exception 'Compute Topic Quiz failed after the 8.6.4 enrichment';
  end if;
end;
$$;

reset role;

select json_build_object(
  'stage', '8.6.4',
  'lessons', 3,
  'published_blocks', 25,
  'blocks_by_lesson', json_build_object(
    'containers-on-azure', 8,
    'azure-functions', 8,
    'comparing-compute-options', 9
  ),
  'visuals_created', 0,
  'flashcards', 11,
  'flashcards_corrected', 11,
  'questions', 20,
  'questions_added', 5,
  'questions_corrected', 15,
  'history_preserved', true
) as containers_functions_compute_comparison_validation;

rollback;

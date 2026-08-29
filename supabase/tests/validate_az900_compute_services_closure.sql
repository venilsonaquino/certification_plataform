begin;

set local statement_timeout = '45s';

create temporary table target_lessons on commit drop as
select lesson.id, lesson.slug, lesson.display_order, lesson.estimated_minutes
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and domain.title = 'Describe Azure architecture and services'
  and topic.title = 'Compute Services';

do $$
declare
  duplicate_count integer;
begin
  if (select count(*) from target_lessons) <> 9
    or (select sum(estimated_minutes) from target_lessons) <> 96
    or exists (
      select 1
      from target_lessons target
      join public.lessons lesson on lesson.id = target.id
      where not lesson.is_published
        or lesson.content is null
        or btrim(lesson.content) = ''
        or lesson.estimated_minutes not between 8 and 12
    ) then
    raise exception 'Compute Lesson inventory, publication, fallback or estimates are invalid';
  end if;

  if (select count(*) from public.lesson_content_blocks block join target_lessons target on target.id = block.lesson_id) <> 73
    or exists (
      select 1
      from target_lessons target
      left join public.lesson_content_blocks block on block.lesson_id = target.id
      group by target.id
      having min(block.display_order) <> 1
        or max(block.display_order) <> count(block.id)
        or count(distinct block.display_order) <> count(block.id)
        or count(*) filter (where block.is_published) <> count(block.id)
        or count(*) filter (where block.type = 'explanation') < 1
        or count(*) filter (where block.type in ('example', 'dotnet_example')) < 1
        or count(*) filter (where block.type = 'exam_tip') <> 1
        or count(*) filter (where block.type = 'exam_trap') <> 1
        or count(*) filter (where block.type = 'summary') <> 1
    ) then
    raise exception 'A Compute Lesson has invalid Content Blocks';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks summary
    join target_lessons target on target.id = summary.lesson_id
    where summary.type = 'summary'
      and (
        summary.display_order <> (select max(block.display_order) from public.lesson_content_blocks block where block.lesson_id = summary.lesson_id)
        or jsonb_typeof(summary.config -> 'items') is distinct from 'array'
        or jsonb_array_length(summary.config -> 'items') not between 3 and 6
      )
  ) then
    raise exception 'A Compute summary is not final or lacks 3-6 recall items';
  end if;

  if (select count(*) from public.visual_experiences visual join target_lessons target on target.id = visual.lesson_id) <> 2
    or not exists (
      select 1 from public.visual_experiences visual
      join target_lessons target on target.id = visual.lesson_id
      where visual.id = '76000000-0000-4000-8000-000000000008'
        and target.slug = 'virtual-machine-resources'
        and visual.type = 'architecture' and visual.is_published
        and jsonb_array_length(visual.config -> 'nodes') = 8
        and jsonb_array_length(visual.config -> 'edges') = 7
    )
    or not exists (
      select 1 from public.visual_experiences visual
      join target_lessons target on target.id = visual.lesson_id
      where visual.id = '76000000-0000-4000-8000-000000000009'
        and target.slug = 'vm-scale-sets-and-availability-sets'
        and visual.type = 'architecture' and visual.is_published
        and jsonb_array_length(visual.config -> 'nodes') = 12
        and jsonb_array_length(visual.config -> 'edges') = 10
    ) then
    raise exception 'Compute must preserve exactly the two justified Visual Experiences';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks block
    join target_lessons target on target.id = block.lesson_id
    where block.type = 'visual_experience'
      and (block.visual_experience_id is null or block.content is not null or block.config is not null)
  ) or (
    select count(*)
    from public.lesson_content_blocks block
    join target_lessons target on target.id = block.lesson_id
    where block.type = 'visual_experience'
  ) <> 2 then
    raise exception 'Compute visual blocks are invalid';
  end if;

  if (select count(*) from public.flashcards card join target_lessons target on target.id = card.lesson_id where card.is_published) <> 34
    or exists (
      select 1
      from target_lessons target
      left join public.flashcards card on card.lesson_id = target.id and card.is_published
      group by target.id, target.slug
      having count(card.id) <> case target.slug
        when 'comparing-compute-options' then 4
        when 'azure-virtual-machines' then 4
        when 'vm-scale-sets-and-availability-sets' then 4
        when 'azure-virtual-desktop' then 3
        when 'virtual-machine-resources' then 3
        when 'azure-app-service' then 4
        when 'azure-functions' then 3
        when 'containers-on-azure' then 4
        when 'choosing-application-hosting' then 5
      end
    )
    or exists (
      select 1
      from public.flashcards card
      join target_lessons target on target.id = card.lesson_id
      where length(btrim(card.front_text)) > 220 or length(btrim(card.back_text)) > 500
    ) then
    raise exception 'Compute Flashcard inventory or concision is invalid';
  end if;

  select count(*) into duplicate_count
  from (
    select lower(regexp_replace(btrim(card.front_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.flashcards card
    join target_lessons target on target.id = card.lesson_id
    group by 1 having count(*) > 1
  ) duplicates;
  if duplicate_count <> 0 then
    raise exception 'Compute contains exact normalized Flashcard duplicates';
  end if;

  if (select count(*) from public.questions question join target_lessons target on target.id = question.lesson_id where question.is_published) <> 51
    or (select count(*) from public.questions question join target_lessons target on target.id = question.lesson_id where question.is_published and question.difficulty = 'easy') <> 19
    or (select count(*) from public.questions question join target_lessons target on target.id = question.lesson_id where question.is_published and question.difficulty = 'medium') <> 22
    or (select count(*) from public.questions question join target_lessons target on target.id = question.lesson_id where question.is_published and question.difficulty = 'hard') <> 10 then
    raise exception 'Compute Question inventory or difficulty distribution is invalid';
  end if;

  if exists (
    select 1
    from target_lessons target
    left join public.questions question on question.lesson_id = target.id and question.is_published
    group by target.id, target.slug
    having count(question.id) <> case target.slug
      when 'azure-virtual-machines' then 6
      when 'azure-functions' then 10
      else 5
    end
  ) then
    raise exception 'A Compute Lesson has an unexpected Question count';
  end if;

  if exists (
    select 1
    from public.questions question
    join target_lessons target on target.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where question.is_published
    group by question.id
    having question.explanation is null
      or length(btrim(question.explanation)) < 40
      or count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
  ) then
    raise exception 'A Compute Question or its options are invalid';
  end if;

  select count(*) into duplicate_count
  from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.questions question
    join target_lessons target on target.id = question.lesson_id
    group by 1 having count(*) > 1
  ) duplicates;
  if duplicate_count <> 0 then
    raise exception 'Compute contains exact normalized Question duplicates';
  end if;

  if exists (
    with artifacts as (
      select concat_ws(' ', block.title, block.content) as text
      from public.lesson_content_blocks block join target_lessons target on target.id = block.lesson_id
      union all
      select concat_ws(' ', card.front_text, card.back_text, card.hint)
      from public.flashcards card join target_lessons target on target.id = card.lesson_id
      union all
      select concat_ws(' ', question.question_text, question.explanation)
      from public.questions question join target_lessons target on target.id = question.lesson_id
      union all
      select concat_ws(' ', option.option_text, option.explanation)
      from public.question_options option
      join public.questions question on question.id = option.question_id
      join target_lessons target on target.id = question.lesson_id
    )
    select 1 from artifacts
    where text ~* '(container (é|=) (uma )?vm pequena|function (é|=) (um )?container|vm scale set (é|=) (um )?availability set|availability set (é|=) (uma )?availability zone|vmss sempre|load balancer sempre (é )?criado|public ip (é )?obrigatório para toda vm|desalocar.{0,40}custo zero|excluir vm.{0,80}sempre.{0,40}(apag|exclu))'
  ) then
    raise exception 'A prohibited Compute misconception remains';
  end if;
end;
$$;

do $$
begin
  if exists (
    select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id = progress.lesson_id where lesson.id is null
  ) or exists (
    select 1 from public.quiz_attempts attempt left join public.certifications certification on certification.id = attempt.certification_id left join public.lessons lesson on lesson.id = attempt.lesson_id left join public.topics topic on topic.id = attempt.topic_id
    where certification.id is null or (attempt.lesson_id is not null and lesson.id is null) or (attempt.topic_id is not null and topic.id is null)
  ) or exists (
    select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id = item.attempt_id left join public.questions question on question.id = item.question_id where attempt.id is null or question.id is null
  ) or exists (
    select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id = answer.attempt_id left join public.questions question on question.id = answer.question_id left join public.question_options option on option.id = answer.selected_option_id where attempt.id is null or question.id is null or option.id is null
  ) or exists (
    select 1 from public.flashcard_reviews review left join public.flashcards card on card.id = review.flashcard_id where card.id is null
  ) or exists (
    select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id = progress.flashcard_id where card.id is null
  ) then
    raise exception 'Study history contains an orphaned reference';
  end if;

  if has_table_privilege('authenticated', 'public.questions', 'SELECT')
    or has_table_privilege('authenticated', 'public.question_options', 'SELECT')
    or has_table_privilege('authenticated', 'public.lessons', 'UPDATE')
    or has_table_privilege('authenticated', 'public.flashcards', 'UPDATE')
    or has_table_privilege('authenticated', 'public.lesson_content_blocks', 'UPDATE')
    or has_table_privilege('authenticated', 'public.visual_experiences', 'UPDATE')
    or not has_table_privilege('authenticated', 'public.lessons', 'SELECT')
    or not has_table_privilege('authenticated', 'public.flashcards', 'SELECT')
    or not has_table_privilege('authenticated', 'public.lesson_content_blocks', 'SELECT')
    or not has_table_privilege('authenticated', 'public.visual_experiences', 'SELECT') then
    raise exception 'Compute curriculum grants are invalid';
  end if;

  if not exists (select 1 from pg_proc where oid = 'public.start_lesson_progress(uuid)'::regprocedure)
    or not exists (select 1 from pg_proc where oid = 'public.complete_lesson_progress(uuid)'::regprocedure)
    or not exists (select 1 from pg_proc where oid = 'public.start_lesson_quiz(uuid)'::regprocedure)
    or not exists (select 1 from pg_proc where oid = 'public.start_topic_quiz(uuid)'::regprocedure)
    or not exists (select 1 from pg_proc where oid = 'public.submit_flashcard_review(uuid,text)'::regprocedure)
    or not exists (select 1 from pg_proc where pronamespace = 'public'::regnamespace and proname = 'start_review_quiz') then
    raise exception 'A required study, quiz, review or spaced-repetition function is missing';
  end if;
end;
$$;

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
)
select
  '00000000-0000-0000-0000-000000000000', seeded.id,
  'authenticated', 'authenticated', seeded.email, '', now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
from (values
  ('58000000-0000-4000-8000-000000000010'::uuid, 'compute-closure-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000011'::uuid, 'compute-closure-b@example.invalid'),
  ('58000000-0000-4000-8000-000000000012'::uuid, 'compute-closure-c@example.invalid')
) seeded(id, email);

grant select on target_lessons to authenticated;
set local role authenticated;

do $$
declare
  seeded_user record;
  attempt public.quiz_attempts;
  first_attempt_id uuid;
  max_per_lesson integer;
begin
  for seeded_user in
    select id from (values
      ('58000000-0000-4000-8000-000000000010'::uuid),
      ('58000000-0000-4000-8000-000000000011'::uuid),
      ('58000000-0000-4000-8000-000000000012'::uuid)
    ) users(id)
  loop
    perform set_config('request.jwt.claim.sub', seeded_user.id::text, true);
    select * into strict attempt from public.start_topic_quiz('32000000-0000-4000-8000-000000000002');

    select max(amount) into max_per_lesson
    from (
      select question.lesson_id, count(*) as amount
      from public.quiz_attempt_questions item
      join public.questions question on question.id = item.question_id
      where item.attempt_id = attempt.id
      group by question.lesson_id
    ) distribution;

    if attempt.total_questions <> 10
      or (select count(*) from public.quiz_attempt_questions where attempt_id = attempt.id) <> 10
      or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id = item.question_id where item.attempt_id = attempt.id) <> 9
      or max_per_lesson > 2
      or (select count(*) from public.quiz_attempt_questions item join public.questions question on question.id = item.question_id join public.lessons lesson on lesson.id = question.lesson_id where item.attempt_id = attempt.id and lesson.slug in ('azure-functions', 'azure-virtual-machines')) > 3 then
      raise exception 'Topic Quiz is not balanced across all nine Compute Lessons';
    end if;

    if first_attempt_id is null then first_attempt_id := attempt.id; end if;
  end loop;

  perform set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000011', true);
  if exists (select 1 from public.quiz_attempts where id = first_attempt_id) then
    raise exception 'Quiz history leaked across users';
  end if;
end;
$$;

select set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000010', true);

do $$
declare
  lesson_target record;
  attempt public.quiz_attempts;
  started public.user_lesson_progress;
  completed public.user_lesson_progress;
  target_card_id uuid;
begin
  for lesson_target in select id from target_lessons order by display_order
  loop
    select * into strict attempt from public.start_lesson_quiz(lesson_target.id);
    if attempt.total_questions <> 5
      or (select count(*) from public.quiz_attempt_questions where attempt_id = attempt.id) <> 5 then
      raise exception 'Lesson Quiz failed for %', lesson_target.id;
    end if;
  end loop;

  select * into strict started from public.start_lesson_progress((select id from target_lessons order by display_order limit 1));
  select * into strict completed from public.complete_lesson_progress((select id from target_lessons order by display_order limit 1));
  if started.status <> 'in_progress' or completed.status <> 'completed' or completed.completed_at is null then
    raise exception 'Compute Lesson progress flow failed';
  end if;

  select card.id into strict target_card_id
  from public.flashcards card join target_lessons target on target.id = card.lesson_id
  where card.is_published order by target.display_order, card.display_order limit 1;
  perform public.submit_flashcard_review(target_card_id, 'good');
  if not exists (select 1 from public.flashcard_reviews where flashcard_id = target_card_id)
    or not exists (select 1 from public.user_flashcard_progress where flashcard_id = target_card_id) then
    raise exception 'Compute spaced repetition failed';
  end if;
end;
$$;

reset role;

select json_build_object(
  'stage', '8.6.6',
  'topic', 'Azure Compute Services',
  'status', 'CLOSED',
  'lessons', 9,
  'estimated_minutes', 96,
  'content_blocks', 73,
  'visual_experiences', 2,
  'flashcards', 34,
  'questions', 51,
  'difficulty', json_build_object('easy', 19, 'medium', 22, 'hard', 10),
  'topic_quiz_lessons_per_attempt', 9,
  'covered', 10,
  'partial', 0,
  'missing', 0,
  'history_preserved', true
) as compute_services_closure_validation;

rollback;

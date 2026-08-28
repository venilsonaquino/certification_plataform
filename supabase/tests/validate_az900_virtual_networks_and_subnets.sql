begin;

set local statement_timeout = '30s';

create temporary table target_lesson on commit drop as
select lesson.id, lesson.slug, lesson.estimated_minutes
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and domain.title = 'Describe Azure architecture and services'
  and topic.title = 'Networking Services'
  and lesson.slug = 'virtual-networks-and-subnets';

do $$
declare
  visual_config jsonb;
  duplicate_count integer;
begin
  if not exists (
    select 1 from supabase_migrations.schema_migrations
    where version = '20260827050000'
  ) then
    raise exception '8.7.2 migration is not registered';
  end if;

  if (select count(*) from target_lesson) <> 1
    or exists (
      select 1 from target_lesson target
      join public.lessons lesson on lesson.id = target.id
      where not lesson.is_published
        or lesson.content is null
        or btrim(lesson.content) = ''
        or lesson.estimated_minutes <> 12
    ) then
    raise exception 'The target Lesson is missing or has invalid publication, fallback or estimate';
  end if;

  if (select array_agg(block.type order by block.display_order)
      from public.lesson_content_blocks block
      join target_lesson target on target.id = block.lesson_id
      where block.is_published)
      is distinct from array[
        'explanation','important','explanation','example','dotnet_example',
        'important','visual_experience','exam_trap','exam_tip','summary'
      ]::text[] then
    raise exception 'The target Lesson has an unexpected Content Block sequence';
  end if;

  if exists (
    select 1
    from target_lesson target
    join public.lesson_content_blocks block on block.lesson_id = target.id
    group by target.id
    having count(*) <> 10
      or min(block.display_order) <> 1
      or max(block.display_order) <> 10
      or count(distinct block.display_order) <> 10
      or count(*) filter (where block.is_published) <> 10
      or count(*) filter (where block.type = 'summary'
        and jsonb_typeof(block.config -> 'items') = 'array'
        and jsonb_array_length(block.config -> 'items') between 3 and 6) <> 1
      or count(*) filter (where block.type = 'exam_tip') <> 1
      or count(*) filter (where block.type = 'exam_trap') <> 1
      or count(*) filter (where block.type = 'visual_experience'
        and block.visual_experience_id = '76000000-0000-4000-8000-000000000010') <> 1
  ) then
    raise exception 'Content Block order, publication or required block types are invalid';
  end if;

  select visual.config into strict visual_config
  from public.visual_experiences visual
  join target_lesson target on target.id = visual.lesson_id
  where visual.id = '76000000-0000-4000-8000-000000000010'
    and visual.type = 'architecture'
    and visual.display_order = 1
    and visual.is_published;

  if jsonb_typeof(visual_config -> 'nodes') <> 'array'
    or jsonb_typeof(visual_config -> 'edges') <> 'array'
    or jsonb_array_length(visual_config -> 'nodes') <> 7
    or jsonb_array_length(visual_config -> 'edges') <> 6 then
    raise exception 'The architecture visual must contain seven nodes and six edges';
  end if;

  if exists (
    select node ->> 'id'
    from jsonb_array_elements(visual_config -> 'nodes') node
    group by 1
    having node ->> 'id' is null or count(*) <> 1
  ) or exists (
    select edge ->> 'id'
    from jsonb_array_elements(visual_config -> 'edges') edge
    group by 1
    having edge ->> 'id' is null or count(*) <> 1
  ) or exists (
    select 1
    from jsonb_array_elements(visual_config -> 'edges') edge
    where not exists (select 1 from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'id' = edge ->> 'source')
       or not exists (select 1 from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'id' = edge ->> 'target')
  ) then
    raise exception 'The architecture visual contains duplicate ids or dangling edges';
  end if;

  if not exists (select 1 from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'id' = 'vnet' and node ->> 'label' ilike '%10.0.0.0/16%')
    or not exists (select 1 from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'id' = 'web-subnet' and node ->> 'label' ilike '%10.0.1.0/24%')
    or not exists (select 1 from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'id' = 'api-subnet' and node ->> 'label' ilike '%10.0.2.0/24%')
    or not exists (select 1 from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'id' = 'data-subnet' and node ->> 'label' ilike '%10.0.3.0/24%') then
    raise exception 'The VNet or subnet address-space nodes are missing';
  end if;

  if (select count(*) from public.flashcards card join target_lesson target on target.id = card.lesson_id where card.is_published) <> 8
    or not exists (select 1 from public.flashcards where id = '72000000-0000-4000-8000-000000000019' and back_text ilike '%depende%regras%rotas%configurações%')
    or not exists (select 1 from public.flashcards where id = '72000000-0000-4000-8000-000000000022' and back_text ilike '%Availability Zone%Resource Group%') then
    raise exception 'The eight preserved Flashcards are incomplete or conceptually invalid';
  end if;

  if exists (
    select 1 from public.questions question
    join target_lesson target on target.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where question.is_published
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
      or min(length(btrim(question.explanation))) < 40
  ) then
    raise exception 'A target Question or its options are invalid';
  end if;

  if (select count(*) from public.questions question join target_lesson target on target.id = question.lesson_id where question.is_published) <> 5
    or (select count(*) from public.questions question join target_lesson target on target.id = question.lesson_id where question.difficulty = 'easy') <> 2
    or (select count(*) from public.questions question join target_lesson target on target.id = question.lesson_id where question.difficulty = 'medium') <> 2
    or (select count(*) from public.questions question join target_lesson target on target.id = question.lesson_id where question.difficulty = 'hard') <> 1 then
    raise exception 'Question count or 2/2/1 distribution is invalid';
  end if;

  if exists (
    select 1 from public.questions question
    join target_lesson target on target.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where concat_ws(' ', question.question_text, question.explanation, option.option_text, option.explanation)
      ~* '(quantos hosts|hosts utilizáveis|máscara decimal|2\^|peering|expressroute|vpn gateway|private endpoint|service endpoint)'
  ) then
    raise exception 'The practice contains CIDR math or a later networking objective';
  end if;

  select count(*) into duplicate_count
  from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.questions question
    where question.topic_id = '32000000-0000-4000-8000-000000000003'
    group by 1 having count(*) > 1
  ) duplicates;

  if duplicate_count <> 0 then
    raise exception 'Networking Services contains exact Question duplicates';
  end if;
end;
$$;

do $$
begin
  if exists (select 1 from public.user_lesson_progress progress left join public.lessons lesson on lesson.id = progress.lesson_id where lesson.id is null)
    or exists (select 1 from public.flashcard_reviews review left join public.flashcards card on card.id = review.flashcard_id where card.id is null)
    or exists (select 1 from public.user_flashcard_progress progress left join public.flashcards card on card.id = progress.flashcard_id where card.id is null)
    or exists (select 1 from public.quiz_attempt_questions item left join public.quiz_attempts attempt on attempt.id = item.attempt_id left join public.questions question on question.id = item.question_id where attempt.id is null or question.id is null)
    or exists (select 1 from public.quiz_answers answer left join public.quiz_attempts attempt on attempt.id = answer.attempt_id left join public.questions question on question.id = answer.question_id left join public.question_options option on option.id = answer.selected_option_id where attempt.id is null or question.id is null or option.id is null) then
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
  '58000000-0000-4000-8000-000000000013',
  'authenticated', 'authenticated', 'vnet-subnets-quiz@example.invalid', '', now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000013', true);

do $$
declare
  target_id uuid;
  lesson_attempt public.quiz_attempts;
  topic_attempt public.quiz_attempts;
begin
  select id into strict target_id from target_lesson;

  if (select count(*) from public.lesson_content_blocks where lesson_id = target_id and is_published) <> 10
    or (select count(*) from public.visual_experiences where lesson_id = target_id and is_published) <> 1
    or (select count(*) from public.flashcards where lesson_id = target_id and is_published) <> 8 then
    raise exception 'Authenticated users cannot read all published 8.7.2 content';
  end if;

  select * into strict lesson_attempt from public.start_lesson_quiz(target_id);
  if lesson_attempt.user_id <> auth.uid()
    or lesson_attempt.lesson_id <> target_id
    or lesson_attempt.total_questions <> 5
    or lesson_attempt.status <> 'in_progress'
    or (select count(*) from public.quiz_attempt_questions where attempt_id = lesson_attempt.id) <> 5 then
    raise exception 'VNet and Subnets Lesson Quiz failed';
  end if;

  select * into strict topic_attempt
  from public.start_topic_quiz('32000000-0000-4000-8000-000000000003');

  if topic_attempt.user_id <> auth.uid()
    or topic_attempt.topic_id <> '32000000-0000-4000-8000-000000000003'
    or topic_attempt.total_questions <> 10
    or (select count(*) from public.quiz_attempt_questions where attempt_id = topic_attempt.id) <> 10
    or (select count(*) from public.quiz_attempt_questions item join public.questions question on question.id = item.question_id where item.attempt_id = topic_attempt.id and question.lesson_id = target_id) = 0
    or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id = item.question_id where item.attempt_id = topic_attempt.id) <> 2 then
    raise exception 'Networking Topic Quiz failed after the 8.7.2 enrichment';
  end if;
end;
$$;

reset role;

select json_build_object(
  'stage', '8.7.2',
  'lesson', 'virtual-networks-and-subnets',
  'published_blocks', 10,
  'visuals', 1,
  'visual_nodes', 7,
  'visual_edges', 6,
  'flashcards_preserved_and_corrected', 8,
  'questions_added', 5,
  'difficulty', json_build_object('easy', 2, 'medium', 2, 'hard', 1),
  'history_preserved', true
) as vnet_subnets_validation;

rollback;

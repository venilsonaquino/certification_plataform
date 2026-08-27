begin;

set local statement_timeout = '30s';

create temporary table target_lessons on commit drop as
select lesson.id, lesson.slug, lesson.display_order, lesson.estimated_minutes
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and domain.title = 'Describe Azure architecture and services'
  and topic.title = 'Core Architectural Components'
  and lesson.slug in (
    'resources-and-resource-groups',
    'subscriptions-and-management-groups',
    'azure-resource-hierarchy'
  );

do $$
declare
  hierarchy_config jsonb;
  duplicate_count integer;
begin
  if not exists (
    select 1 from supabase_migrations.schema_migrations
    where version = '20260826090000'
  ) then
    raise exception '8.5.5 migration is not registered';
  end if;

  if (select count(*) from target_lessons) <> 3
    or not exists (select 1 from target_lessons where id = '40000000-0000-4000-8000-000000000006' and slug = 'resources-and-resource-groups')
    or not exists (select 1 from target_lessons where id = '40000000-0000-4000-8000-000000000007' and slug = 'subscriptions-and-management-groups')
    or not exists (select 1 from target_lessons where id = '98880411-d0cb-47d7-a278-ae295552ad5f' and slug = 'azure-resource-hierarchy') then
    raise exception 'A scoped Lesson UUID or slug changed';
  end if;

  if exists (
    select 1
    from target_lessons target
    join public.lessons lesson on lesson.id = target.id
    where not lesson.is_published
      or lesson.estimated_minutes <> 10
      or lesson.content is null
      or btrim(lesson.content) = ''
  ) then
    raise exception 'A Lesson publication, estimate or fallback is invalid';
  end if;

  if (select array_agg(block.type order by block.display_order) from public.lesson_content_blocks block where block.lesson_id = '40000000-0000-4000-8000-000000000006' and block.is_published)
      is distinct from array['explanation','explanation','example','important','exam_trap','exam_tip','summary']::text[]
    or (select array_agg(block.type order by block.display_order) from public.lesson_content_blocks block where block.lesson_id = '40000000-0000-4000-8000-000000000007' and block.is_published)
      is distinct from array['explanation','important','example','explanation','important','exam_trap','exam_tip','summary']::text[]
    or (select array_agg(block.type order by block.display_order) from public.lesson_content_blocks block where block.lesson_id = '98880411-d0cb-47d7-a278-ae295552ad5f' and block.is_published)
      is distinct from array['explanation','visual_experience','explanation','example','important','exam_trap','exam_tip','summary']::text[] then
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
      or count(*) filter (where block.type = 'summary' and jsonb_typeof(block.config -> 'items') = 'array' and jsonb_array_length(block.config -> 'items') = 6) <> 1
      or count(*) filter (where block.type = 'exam_tip') <> 1
      or count(*) filter (where block.type = 'exam_trap') <> 1
  ) then
    raise exception 'Display order, summary, exam tip or exam trap is invalid';
  end if;

  if (select count(*) from public.visual_experiences visual join target_lessons target on target.id = visual.lesson_id) <> 1
    or not exists (
      select 1
      from public.lesson_content_blocks
      where lesson_id = '98880411-d0cb-47d7-a278-ae295552ad5f'
        and type = 'visual_experience'
        and visual_experience_id = '76000000-0000-4000-8000-000000000007'
        and content is null
        and config is null
    ) then
    raise exception 'The single hierarchy Visual Experience is not linked correctly';
  end if;

  select config
  into strict hierarchy_config
  from public.visual_experiences
  where id = '76000000-0000-4000-8000-000000000007'
    and lesson_id = '98880411-d0cb-47d7-a278-ae295552ad5f'
    and type = 'architecture'
    and is_published;

  if jsonb_array_length(hierarchy_config -> 'nodes') <> 5
    or jsonb_array_length(hierarchy_config -> 'edges') <> 4
    or (select array_agg(node ->> 'label' order by (node ->> 'y')::numeric) from jsonb_array_elements(hierarchy_config -> 'nodes') node)
       is distinct from array['Tenant / Root','Management Groups','Subscriptions','Resource Groups','Resources']::text[]
    or exists (
      select 1
      from jsonb_array_elements(hierarchy_config -> 'nodes') node
      where (node ->> 'x')::numeric <> 50
        or (node ->> 'y')::numeric < 0
        or (node ->> 'y')::numeric > 100
    )
    or exists (
      select 1
      from jsonb_array_elements(hierarchy_config -> 'edges') edge
      where not exists (select 1 from jsonb_array_elements(hierarchy_config -> 'nodes') node where node ->> 'id' = edge ->> 'source')
         or not exists (select 1 from jsonb_array_elements(hierarchy_config -> 'nodes') node where node ->> 'id' = edge ->> 'target')
    ) then
    raise exception 'The Resource Hierarchy visual config is invalid';
  end if;

  if (select count(*) from public.flashcards card join target_lessons target on target.id = card.lesson_id where card.is_published) <> 15
    or not exists (
      select 1 from public.flashcards
      where id = '71000000-0000-4000-8000-000000000092'
        and back_text ilike '%não são herdadas automaticamente%'
    )
    or not exists (
      select 1 from public.flashcards
      where id = '71000000-0000-4000-8000-000000000096'
        and back_text ilike '%compartilhar uma estrutura de billing%'
    )
    or not exists (
      select 1 from public.flashcards
      where id = '71000000-0000-4000-8000-000000000100'
        and back_text ilike '%não existe uma regra universal%'
    ) then
    raise exception 'The scoped Flashcards are incomplete or conceptually invalid';
  end if;

  if (select count(*) from public.questions question join target_lessons target on target.id = question.lesson_id where question.is_published) <> 16
    or exists (
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
    raise exception 'The scoped Questions or answer options are invalid';
  end if;

  if not exists (
    select 1 from public.questions
    where id = '64000000-0000-4000-8000-000000000023'
      and explanation ilike '%não são copiadas automaticamente%'
  ) or not exists (
    select 1 from public.questions
    where id = '65000000-0000-4000-8000-000000000004'
      and explanation ilike '%sem exigir invoices independentes%'
  ) or exists (
    select 1 from public.questions question
    where question.lesson_id = '98880411-d0cb-47d7-a278-ae295552ad5f'
      and question.id in (
        '65000000-0000-4000-8000-000000000007',
        '65000000-0000-4000-8000-000000000008',
        '65000000-0000-4000-8000-000000000009',
        '65000000-0000-4000-8000-000000000010'
      )
      and (question.question_text ilike '%Policy%' or question.question_text ilike '%RBAC%' or question.question_text ilike '%política%')
  ) then
    raise exception 'A required practice correction is missing';
  end if;

  select count(*)
  into duplicate_count
  from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    where lesson.topic_id = '30000000-0000-4000-8000-000000000002'
    group by 1
    having count(*) > 1
  ) duplicates;

  if duplicate_count <> 0 then
    raise exception 'Core Architectural Components contains exact Question duplicates';
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
  '58000000-0000-4000-8000-000000000005',
  'authenticated', 'authenticated', 'resource-hierarchy-quiz@example.invalid', '', now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000005', true);

do $$
declare
  target record;
  lesson_attempt public.quiz_attempts;
begin
  if (
    select count(*)
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.topic_id = '30000000-0000-4000-8000-000000000002'
      and lesson.slug in (
        'resources-and-resource-groups',
        'subscriptions-and-management-groups',
        'azure-resource-hierarchy'
      )
  ) <> 23
    or not exists (select 1 from public.visual_experiences where id = '76000000-0000-4000-8000-000000000007') then
    raise exception 'Authenticated users cannot read all published 8.5.5 content';
  end if;

  for target in
    select id
    from public.lessons
    where topic_id = '30000000-0000-4000-8000-000000000002'
      and slug in (
        'resources-and-resource-groups',
        'subscriptions-and-management-groups',
        'azure-resource-hierarchy'
      )
    order by display_order
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
end;
$$;

reset role;

select json_build_object(
  'stage', '8.5.5',
  'lessons', 3,
  'published_blocks', 23,
  'blocks_by_lesson', json_build_object(
    'resources-and-resource-groups', 7,
    'subscriptions-and-management-groups', 8,
    'azure-resource-hierarchy', 8
  ),
  'visual_id', '76000000-0000-4000-8000-000000000007',
  'visual_nodes', 5,
  'flashcards', 15,
  'flashcards_corrected', 5,
  'questions', 16,
  'questions_corrected', 10,
  'history_preserved', true
) as resource_hierarchy_validation;

rollback;

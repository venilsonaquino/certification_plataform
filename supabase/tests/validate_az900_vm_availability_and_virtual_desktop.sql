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
  and lesson.slug in ('vm-scale-sets-and-availability-sets', 'azure-virtual-desktop');

do $$
declare
  visual_config jsonb;
  duplicate_count integer;
begin
  if not exists (
    select 1 from supabase_migrations.schema_migrations
    where version = '20260827020000'
  ) then
    raise exception '8.6.3 migration is not registered';
  end if;

  if (select count(*) from target_lessons) <> 2
    or exists (
      select 1
      from target_lessons target
      join public.lessons lesson on lesson.id = target.id
      where not lesson.is_published
        or lesson.content is null
        or btrim(lesson.content) = ''
        or lesson.estimated_minutes <> case lesson.slug
          when 'vm-scale-sets-and-availability-sets' then 12
          when 'azure-virtual-desktop' then 10
        end
    ) then
    raise exception 'A scoped Lesson is missing or has invalid publication, fallback or estimate';
  end if;

  if (select array_agg(block.type order by block.display_order)
      from public.lesson_content_blocks block
      join target_lessons target on target.id = block.lesson_id
      where target.slug = 'vm-scale-sets-and-availability-sets' and block.is_published)
      is distinct from array['explanation','example','important','explanation','visual_experience','important','exam_trap','exam_tip','summary']::text[]
    or (select array_agg(block.type order by block.display_order)
      from public.lesson_content_blocks block
      join target_lessons target on target.id = block.lesson_id
      where target.slug = 'azure-virtual-desktop' and block.is_published)
      is distinct from array['explanation','important','example','example','exam_trap','exam_tip','summary']::text[] then
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
  ) then
    raise exception 'Display order, summary, exam tip or exam trap is invalid';
  end if;

  if (select count(*) from public.visual_experiences visual join target_lessons target on target.id = visual.lesson_id) <> 1
    or not exists (
      select 1
      from public.lesson_content_blocks block
      join target_lessons target on target.id = block.lesson_id
      where target.slug = 'vm-scale-sets-and-availability-sets'
        and block.type = 'visual_experience'
        and block.visual_experience_id = '76000000-0000-4000-8000-000000000009'
        and block.content is null
        and block.config is null
        and block.is_published
    ) then
    raise exception 'The single 8.6.3 Visual Experience is not linked correctly';
  end if;

  select visual.config
  into strict visual_config
  from public.visual_experiences visual
  join target_lessons target on target.id = visual.lesson_id
  where visual.id = '76000000-0000-4000-8000-000000000009'
    and target.slug = 'vm-scale-sets-and-availability-sets'
    and visual.type = 'architecture'
    and visual.is_published;

  if jsonb_array_length(visual_config -> 'nodes') <> 12
    or jsonb_array_length(visual_config -> 'edges') <> 10
    or not exists (select 1 from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'id' = 'scale-set')
    or not exists (select 1 from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'id' = 'availability-set')
    or not exists (select 1 from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'id' = 'fault-domain-1')
    or exists (
      select 1
      from jsonb_array_elements(visual_config -> 'edges') edge
      where not exists (select 1 from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'id' = edge ->> 'source')
         or not exists (select 1 from jsonb_array_elements(visual_config -> 'nodes') node where node ->> 'id' = edge ->> 'target')
    ) then
    raise exception 'The VM availability visual config is invalid';
  end if;

  if (select count(*) from public.flashcards card join target_lessons target on target.id = card.lesson_id where card.is_published) <> 7
    or not exists (
      select 1 from public.flashcards
      where id = '71000000-0000-4000-8000-000000000109'
        and back_text ilike '%autoscale configurado%'
    )
    or not exists (
      select 1 from public.flashcards
      where id = '71000000-0000-4000-8000-000000000110'
        and back_text ilike '%fault/update domains%'
    )
    or not exists (
      select 1 from public.flashcards
      where id = '72000000-0000-4000-8000-000000000001'
        and back_text ilike '%desktops%'
        and back_text ilike '%aplicações%'
    ) then
    raise exception 'The scoped Flashcards are incomplete or conceptually invalid';
  end if;

  if (select count(*) from public.questions question join target_lessons target on target.id = question.lesson_id where question.is_published) <> 10
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
    )
    or exists (
      select 1
      from target_lessons target
      left join public.questions question on question.lesson_id = target.id and question.is_published
      group by target.id
      having count(question.id) filter (where question.difficulty = 'easy') <> 2
        or count(question.id) filter (where question.difficulty = 'medium') <> 2
        or count(question.id) filter (where question.difficulty = 'hard') <> 1
    ) then
    raise exception 'The scoped Questions, difficulty distribution or options are invalid';
  end if;

  if exists (
    select 1
    from public.questions question
    join public.question_options option on option.question_id = question.id
    where question.id between '65000000-0000-4000-8000-000000000021' and '65000000-0000-4000-8000-000000000025'
      and (
        question.question_text ilike '%sempre idêntic%'
        or question.explanation ilike '%sempre idêntic%'
        or question.explanation ilike '%distribui automaticamente%'
        or option.option_text ilike '%já distribui automaticamente%'
      )
  ) or (select count(*) from public.questions where id between '68000000-0000-4000-8000-000000000006' and '68000000-0000-4000-8000-000000000010') <> 5 then
    raise exception 'A required 8.6.3 practice correction is missing';
  end if;

  select count(*)
  into duplicate_count
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
  '58000000-0000-4000-8000-000000000007',
  'authenticated', 'authenticated', 'vm-availability-quiz@example.invalid', '', now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000007', true);

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
  ) <> 16
    or not exists (select 1 from public.visual_experiences where id = '76000000-0000-4000-8000-000000000009') then
    raise exception 'Authenticated users cannot read all published 8.6.3 content';
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
    raise exception 'Compute Topic Quiz failed after the 8.6.3 enrichment';
  end if;
end;
$$;

reset role;

select json_build_object(
  'stage', '8.6.3',
  'lessons', 2,
  'published_blocks', 16,
  'blocks_by_lesson', json_build_object(
    'vm-scale-sets-and-availability-sets', 9,
    'azure-virtual-desktop', 7
  ),
  'visual_id', '76000000-0000-4000-8000-000000000009',
  'visual_nodes', 12,
  'flashcards', 7,
  'flashcards_corrected', 7,
  'questions', 10,
  'questions_added', 5,
  'questions_corrected', 5,
  'history_preserved', true
) as vm_availability_and_virtual_desktop_validation;

rollback;

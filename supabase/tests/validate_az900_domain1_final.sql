begin;

set local statement_timeout = '30s';

do $$
declare
  lesson_count integer;
  block_count integer;
  visual_count integer;
  flashcard_count integer;
  question_count integer;
begin
  with target_lessons as (
    select lesson.id
    from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
  )
  select
    (select count(*) from target_lessons),
    (select count(*) from public.lesson_content_blocks block join target_lessons lesson on lesson.id = block.lesson_id),
    (select count(*) from public.visual_experiences visual join target_lessons lesson on lesson.id = visual.lesson_id),
    (select count(*) from public.flashcards flashcard join target_lessons lesson on lesson.id = flashcard.lesson_id),
    (select count(*) from public.questions question join target_lessons lesson on lesson.id = question.lesson_id)
  into lesson_count, block_count, visual_count, flashcard_count, question_count;

  if lesson_count <> 18 or block_count <> 128 or visual_count <> 4
    or flashcard_count <> 84 or question_count <> 153 then
    raise exception 'Unexpected Domain 1 inventory: lessons %, blocks %, visuals %, flashcards %, questions %',
      lesson_count, block_count, visual_count, flashcard_count, question_count;
  end if;
end;
$$;

do $$
begin
  if exists (
    with target_lessons as (
      select lesson.*
      from public.lessons lesson
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900'
        and domain.title = 'Describe cloud concepts'
    )
    select 1
    from target_lessons lesson
    where not lesson.is_published
      or lesson.content is null
      or btrim(lesson.content) = ''
      or lesson.estimated_minutes not between 8 and 12
  ) then
    raise exception 'A Domain 1 Lesson is unpublished, lacks fallback content, or has an invalid estimate';
  end if;

  if exists (
    with target_lessons as (
      select lesson.id
      from public.lessons lesson
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900'
        and domain.title = 'Describe cloud concepts'
    ), block_order as (
      select
        block.lesson_id,
        min(block.display_order) as first_order,
        max(block.display_order) as last_order,
        count(*) as block_count,
        count(*) filter (where block.is_published) as published_count,
        count(*) filter (where block.type = 'summary') as summary_count,
        count(*) filter (where block.type = 'exam_tip') as exam_tip_count
      from public.lesson_content_blocks block
      join target_lessons lesson on lesson.id = block.lesson_id
      group by block.lesson_id
    )
    select 1
    from block_order
    where first_order <> 1
      or last_order <> block_count
      or published_count <> block_count
      or summary_count <> 1
      or exam_tip_count < 1
  ) then
    raise exception 'A Domain 1 Lesson has invalid block order, publication state, summary, or exam tip';
  end if;

  if exists (
    with target_lessons as (
      select lesson.id
      from public.lessons lesson
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900'
        and domain.title = 'Describe cloud concepts'
    )
    select 1
    from public.lesson_content_blocks summary
    join target_lessons lesson on lesson.id = summary.lesson_id
    where summary.type = 'summary'
      and (
        summary.display_order <> (
          select max(block.display_order)
          from public.lesson_content_blocks block
          where block.lesson_id = summary.lesson_id
        )
        or jsonb_typeof(summary.config -> 'items') is distinct from 'array'
        or case
          when jsonb_typeof(summary.config -> 'items') = 'array'
            then jsonb_array_length(summary.config -> 'items') not between 3 and 6
          else true
        end
      )
  ) then
    raise exception 'A Domain 1 summary is not last or does not contain 3-6 active-recall items';
  end if;
end;
$$;

do $$
begin
  if exists (
    with target_lessons as (
      select lesson.id
      from public.lessons lesson
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900'
        and domain.title = 'Describe cloud concepts'
    )
    select 1
    from public.lesson_content_blocks block
    join target_lessons lesson on lesson.id = block.lesson_id
    left join public.visual_experiences visual
      on visual.id = block.visual_experience_id
     and visual.lesson_id = block.lesson_id
    where (block.config is not null and jsonb_typeof(block.config) <> 'object')
       or (
         block.type = 'visual_experience'
         and (
           block.visual_experience_id is null
           or visual.id is null
           or not visual.is_published
           or jsonb_typeof(visual.config) <> 'object'
         )
       )
  ) then
    raise exception 'A Domain 1 block or visual experience has invalid configuration or reference';
  end if;

  if exists (
    with required_traps(slug) as (
      values
        ('shared-responsibility-model'),
        ('choosing-a-cloud-model'),
        ('capex-vs-opex'),
        ('serverless-computing'),
        ('high-availability'),
        ('scalability'),
        ('elasticity'),
        ('reliability'),
        ('predictability'),
        ('security-and-governance-benefits'),
        ('manageability'),
        ('infrastructure-as-a-service'),
        ('platform-as-a-service'),
        ('software-as-a-service'),
        ('choosing-iaas-paas-saas')
    )
    select 1
    from required_traps required
    left join public.lessons lesson on lesson.slug = required.slug
    left join public.lesson_content_blocks block
      on block.lesson_id = lesson.id
     and block.type = 'exam_trap'
     and block.is_published
    where block.id is null
  ) then
    raise exception 'A required Domain 1 comparison or trap block is missing';
  end if;
end;
$$;

do $$
begin
  if exists (
    with target_lessons as (
      select lesson.id
      from public.lessons lesson
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900'
        and domain.title = 'Describe cloud concepts'
    )
    select 1
    from target_lessons lesson
    left join public.flashcards flashcard on flashcard.lesson_id = lesson.id and flashcard.is_published
    left join public.questions question on question.lesson_id = lesson.id and question.is_published
    group by lesson.id
    having count(distinct flashcard.id) < 4 or count(distinct question.id) < 5
  ) then
    raise exception 'A Domain 1 Lesson lacks enough published flashcards or questions';
  end if;

  if exists (
    with target_lessons as (
      select lesson.id
      from public.lessons lesson
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900'
        and domain.title = 'Describe cloud concepts'
    )
    select 1
    from public.questions question
    join target_lessons lesson on lesson.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where question.is_published
    group by question.id
    having question.explanation is null
      or btrim(question.explanation) = ''
      or count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
  ) then
    raise exception 'A published Domain 1 question has invalid options or explanation';
  end if;
end;
$$;

do $$
begin
  if exists (
    select 1
    from public.user_lesson_progress progress
    left join public.lessons lesson on lesson.id = progress.lesson_id
    where lesson.id is null
  ) or exists (
    select 1
    from public.flashcard_reviews review
    left join public.flashcards flashcard on flashcard.id = review.flashcard_id
    where flashcard.id is null
  ) or exists (
    select 1
    from public.user_flashcard_progress progress
    left join public.flashcards flashcard on flashcard.id = progress.flashcard_id
    where flashcard.id is null
  ) or exists (
    select 1
    from public.quiz_attempt_questions item
    left join public.quiz_attempts attempt on attempt.id = item.attempt_id
    left join public.questions question on question.id = item.question_id
    where attempt.id is null or question.id is null
  ) or exists (
    select 1
    from public.quiz_answers answer
    left join public.quiz_attempts attempt on attempt.id = answer.attempt_id
    left join public.questions question on question.id = answer.question_id
    left join public.question_options option on option.id = answer.selected_option_id
    where attempt.id is null or question.id is null or option.id is null
  ) then
    raise exception 'A study-history table contains an orphaned reference';
  end if;

  if exists (
    select 1
    from pg_class relation
    join pg_namespace namespace on namespace.oid = relation.relnamespace
    where namespace.nspname = 'public'
      and relation.relname in (
        'lesson_content_blocks', 'visual_experiences', 'user_lesson_progress',
        'flashcard_reviews', 'user_flashcard_progress', 'quiz_attempts',
        'quiz_attempt_questions', 'quiz_answers'
      )
      and not relation.relrowsecurity
  ) then
    raise exception 'RLS is not enabled on a study-flow table';
  end if;

  if has_table_privilege('anon', 'public.lesson_content_blocks', 'SELECT')
    or has_table_privilege('anon', 'public.visual_experiences', 'SELECT')
    or not has_table_privilege('authenticated', 'public.lesson_content_blocks', 'SELECT')
    or not has_table_privilege('authenticated', 'public.visual_experiences', 'SELECT') then
    raise exception 'Content-block or visual-experience grants are inconsistent with authenticated-only study';
  end if;

  if not exists (select 1 from pg_proc where pronamespace = 'public'::regnamespace and proname = 'start_lesson_progress')
    or not exists (select 1 from pg_proc where pronamespace = 'public'::regnamespace and proname = 'complete_lesson_progress')
    or not exists (select 1 from pg_proc where pronamespace = 'public'::regnamespace and proname = 'start_lesson_quiz')
    or not exists (select 1 from pg_proc where pronamespace = 'public'::regnamespace and proname = 'start_topic_quiz')
    or not exists (select 1 from pg_proc where pronamespace = 'public'::regnamespace and proname = 'submit_flashcard_review') then
    raise exception 'A required study-flow database function is missing';
  end if;
end;
$$;

with target_lessons as (
  select lesson.id, lesson.slug, lesson.estimated_minutes
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
), visuals as (
  select visual.title, visual.type, lesson.slug
  from public.visual_experiences visual
  join target_lessons lesson on lesson.id = visual.lesson_id
  where visual.is_published
  order by lesson.slug, visual.display_order
), block_types as (
  select block.type, count(*) as amount
  from public.lesson_content_blocks block
  join target_lessons lesson on lesson.id = block.lesson_id
  where block.is_published
  group by block.type
  order by block.type
)
select json_build_object(
  'domain', 'Describe cloud concepts',
  'lessons', (select count(*) from target_lessons),
  'estimated_minutes_total', (select sum(estimated_minutes) from target_lessons),
  'estimated_minutes_range', (select json_build_array(min(estimated_minutes), max(estimated_minutes)) from target_lessons),
  'content_blocks', (select sum(amount) from block_types),
  'block_types', (select json_object_agg(type, amount) from block_types),
  'visual_experiences', (select coalesce(json_agg(row_to_json(visuals)), '[]'::json) from visuals),
  'flashcards', (select count(*) from public.flashcards flashcard join target_lessons lesson on lesson.id = flashcard.lesson_id where flashcard.is_published),
  'questions', (select count(*) from public.questions question join target_lessons lesson on lesson.id = question.lesson_id where question.is_published),
  'lesson_progress_rows', (select count(*) from public.user_lesson_progress progress join target_lessons lesson on lesson.id = progress.lesson_id),
  'quiz_attempt_rows', (select count(*) from public.quiz_attempts attempt join target_lessons lesson on lesson.id = attempt.lesson_id),
  'flashcard_review_rows', (select count(*) from public.flashcard_reviews review join public.flashcards flashcard on flashcard.id = review.flashcard_id join target_lessons lesson on lesson.id = flashcard.lesson_id),
  'all_invariants_passed', true
) as domain_1_final_validation;

rollback;

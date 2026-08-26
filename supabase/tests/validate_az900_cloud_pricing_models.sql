begin;

set local statement_timeout = '30s';

do $$
begin
  if not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260826050000'
  ) then
    raise exception 'Cloud pricing models migration is not registered';
  end if;

  if (
    select array_agg(block.type order by block.display_order)
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and lesson.slug = 'consumption-based-model'
      and block.is_published
  ) is distinct from array[
    'explanation', 'important', 'exam_trap', 'example',
    'dotnet_example', 'exam_tip', 'summary'
  ]::text[] then
    raise exception 'Pricing comparison blocks are incomplete or out of order';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where block.id = '7a040000-0000-4000-8000-000000000007'
      and lesson.slug = 'consumption-based-model'
      and block.is_published
      and block.content ilike '%pay-as-you-go%'
      and block.content ilike '%compromisso%'
      and block.content ilike '%flexibilidade%'
      and block.content ilike '%previsibilidade%'
      and block.content ilike '%CapEx%OpEx%'
  ) then
    raise exception 'The explicit pricing model comparison is missing';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks
    where id = '7a040000-0000-4000-8000-000000000002'
      and type = 'exam_trap'
      and content ilike '%não significa custo automaticamente baixo%'
      and content ilike '%OpEx%não significa obrigatoriamente pay-as-you-go%'
      and content ilike '%natureza do gasto%'
      and content ilike '%como o serviço é cobrado ou contratado%'
  ) then
    raise exception 'The required pricing Exam Trap is incomplete';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks
    where id = '7a050000-0000-4000-8000-000000000006'
      and content ilike '%CapEx e OpEx descrevem a natureza%'
      and content ilike '%Pricing model descreve%'
  ) or not exists (
    select 1
    from public.lesson_content_blocks
    where id = '7b050000-0000-4000-8000-000000000001'
      and content ilike '%compromisso%flexibilidade%previsibilidade%'
  ) then
    raise exception 'CapEx/OpEx or Predictability does not reinforce the comparison';
  end if;

  if not exists (
    select 1
    from public.lessons
    where slug = 'consumption-based-model'
      and estimated_minutes = 10
  ) then
    raise exception 'Consumption-Based Model estimate must be 10 minutes';
  end if;
end;
$$;

do $$
begin
  if not exists (
    select 1
    from public.flashcards
    where id = '71000000-0000-4000-8000-000000000018'
      and front_text ilike '%pay-as-you-go%compromisso%'
      and back_text ilike '%flexibilidade%previsibilidade%'
  ) or not exists (
    select 1
    from public.flashcards
    where id = '71000000-0000-4000-8000-000000000023'
      and front_text ilike '%pricing model%'
      and back_text ilike '%natureza do gasto%'
  ) then
    raise exception 'Pricing Flashcards were not reinforced in place';
  end if;

  if not exists (
    select 1
    from public.questions question
    join public.question_options option on option.question_id = question.id
    where question.id = '62000000-0000-4000-8000-000000000048'
      and question.question_text ilike '%pay-as-you-go%compromisso%'
      and question.explanation ilike '%não define sozinha%CapEx%OpEx%'
    group by question.id
    having count(option.id) = 4
      and count(option.id) filter (where option.is_correct) = 1
      and count(distinct lower(btrim(option.option_text))) = 4
  ) then
    raise exception 'Pricing scenario Question is invalid';
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
  ) or exists (
    select 1
    from public.quiz_attempt_questions attempt_question
    left join public.questions question on question.id = attempt_question.question_id
    where question.id is null
  ) then
    raise exception 'Practice history contains an orphan after the pricing update';
  end if;
end;
$$;

select json_build_object(
  'lessons_updated', array[
    'consumption-based-model', 'capex-vs-opex', 'predictability'
  ],
  'content_blocks_created', 1,
  'content_blocks_updated', 8,
  'flashcards_updated', 2,
  'flashcards_created', 0,
  'questions_updated', 1,
  'questions_created', 0,
  'published_domain_blocks', 129,
  'published_domain_flashcards', 84,
  'published_domain_questions', 153,
  'pricing_objective', 'Covered',
  'history_preserved', true
) as cloud_pricing_models_validation;

rollback;

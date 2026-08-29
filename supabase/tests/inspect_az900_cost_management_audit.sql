with target_lessons as (
  select lesson.id,lesson.title,lesson.slug,lesson.estimated_minutes,lesson.is_published,lesson.display_order,
    lesson.content
  from public.lessons lesson
  join public.topics topic on topic.id=lesson.topic_id
  join public.domains domain on domain.id=topic.domain_id
  join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900'
    and domain.title='Describe Azure management and governance'
    and topic.id='33000000-0000-4000-8000-000000000001'
    and topic.title='Cost Management'
), inventory as (
  select target.id,target.title,target.slug,target.estimated_minutes,target.is_published,target.display_order,
    (select count(*) from public.lesson_content_blocks block where block.lesson_id=target.id) blocks,
    (select count(*) from public.visual_experiences visual where visual.lesson_id=target.id) visuals,
    (select count(*) from public.flashcards card where card.lesson_id=target.id and card.is_published) flashcards,
    (select count(*) from public.questions question where question.lesson_id=target.id and question.is_published) questions,
    (select count(*) from public.questions question where question.lesson_id=target.id and question.is_published and question.difficulty='easy') easy,
    (select count(*) from public.questions question where question.lesson_id=target.id and question.is_published and question.difficulty='medium') medium,
    (select count(*) from public.questions question where question.lesson_id=target.id and question.is_published and question.difficulty='hard') hard
  from target_lessons target
), artifacts as (
  select target.slug,target.content text from target_lessons target
  union all
  select target.slug,concat_ws(' ',card.front_text,card.back_text,card.hint)
  from public.flashcards card join target_lessons target on target.id=card.lesson_id
  union all
  select target.slug,concat_ws(' ',question.question_text,question.explanation,option.option_text,option.explanation)
  from public.questions question join target_lessons target on target.id=question.lesson_id
  left join public.question_options option on option.question_id=question.id
)
select json_build_object(
  'topic_id','33000000-0000-4000-8000-000000000001',
  'lessons',(select json_agg(inventory order by display_order) from inventory),
  'totals',json_build_object(
    'lessons',(select count(*) from inventory),'minutes',(select sum(estimated_minutes) from inventory),
    'blocks',(select sum(blocks) from inventory),'visuals',(select sum(visuals) from inventory),
    'flashcards',(select sum(flashcards) from inventory),'questions',(select sum(questions) from inventory),
    'easy',(select sum(easy) from inventory),'medium',(select sum(medium) from inventory),'hard',(select sum(hard) from inventory)
  ),
  'supplementary_mentions',json_build_object(
    'reservations',(select count(*) from artifacts where text ~* '(reservation|reserved instance|instância reservada)'),
    'savings_plans',(select count(*) from artifacts where text ~* 'savings plan'),
    'spot',(select count(*) from artifacts where text ~* '(spot pricing|spot vm|azure spot)'),
    'tco',(select count(*) from artifacts where text ~* '(TCO|total cost of ownership|custo total de propriedade)')
  ),
  'exact_question_duplicates',(select count(*) from(
    select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g'))
    from public.questions question join target_lessons target on target.id=question.lesson_id
    group by 1 having count(*)>1
  ) duplicates),
  'invalid_question_options',(select count(*) from(
    select question.id from public.questions question join target_lessons target on target.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
  ) invalid)
) as cost_management_audit;

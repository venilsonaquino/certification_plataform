begin;

do $$
declare
  lesson_row record;
  duplicate_count integer;
begin
  if (select count(*) from public.domains domain
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900') <> 3 then
    raise exception '10.1 expected exactly three AZ-900 Domains';
  end if;

  if (select count(*) from public.topics topic
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900') <> 12 then
    raise exception '10.1 expected exactly twelve AZ-900 Topics';
  end if;

  if (select count(*) from public.lessons lesson
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900' and lesson.is_published) <> 76
    or (select count(*) from public.lesson_content_blocks block
      join public.lessons lesson on lesson.id = block.lesson_id
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900' and block.is_published) <> 677
    or (select count(*) from public.visual_experiences visual
      join public.lessons lesson on lesson.id = visual.lesson_id
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900' and visual.is_published) <> 17
    or (select count(*) from public.flashcards card
      join public.lessons lesson on lesson.id = card.lesson_id
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900' and card.is_published) <> 397
    or (select count(*) from public.questions question
      join public.certifications certification on certification.id = question.certification_id
      where certification.code = 'az-900' and question.is_published) <> 512
    or (select sum(lesson.estimated_minutes) from public.lessons lesson
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900' and lesson.is_published) <> 818 then
    raise exception '10.1 inventory: lessons %, blocks %, blocks_by_domain %, visuals %, cards %, questions %, minutes %',
      (select count(*) from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
        join public.domains domain on domain.id=topic.domain_id join public.certifications certification on certification.id=domain.certification_id
        where certification.code='az-900' and lesson.is_published),
      (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
        join public.topics topic on topic.id=lesson.topic_id join public.domains domain on domain.id=topic.domain_id
        join public.certifications certification on certification.id=domain.certification_id
        where certification.code='az-900' and block.is_published),
      (select jsonb_object_agg(title,amount) from (
        select domain.title,count(block.id) amount from public.domains domain
        join public.certifications certification on certification.id=domain.certification_id
        join public.topics topic on topic.domain_id=domain.id join public.lessons lesson on lesson.topic_id=topic.id
        join public.lesson_content_blocks block on block.lesson_id=lesson.id and block.is_published
        where certification.code='az-900' group by domain.title) totals),
      (select count(*) from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
        join public.topics topic on topic.id=lesson.topic_id join public.domains domain on domain.id=topic.domain_id
        join public.certifications certification on certification.id=domain.certification_id
        where certification.code='az-900' and visual.is_published),
      (select count(*) from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
        join public.topics topic on topic.id=lesson.topic_id join public.domains domain on domain.id=topic.domain_id
        join public.certifications certification on certification.id=domain.certification_id
        where certification.code='az-900' and card.is_published),
      (select count(*) from public.questions question join public.certifications certification on certification.id=question.certification_id
        where certification.code='az-900' and question.is_published),
      (select sum(lesson.estimated_minutes) from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
        join public.domains domain on domain.id=topic.domain_id join public.certifications certification on certification.id=domain.certification_id
        where certification.code='az-900' and lesson.is_published);
  end if;

  if (select count(*) from public.questions question
      join public.certifications certification on certification.id = question.certification_id
      where certification.code = 'az-900' and question.is_published and question.difficulty = 'easy') <> 178
    or (select count(*) from public.questions question
      join public.certifications certification on certification.id = question.certification_id
      where certification.code = 'az-900' and question.is_published and question.difficulty = 'medium') <> 234
    or (select count(*) from public.questions question
      join public.certifications certification on certification.id = question.certification_id
      where certification.code = 'az-900' and question.is_published and question.difficulty = 'hard') <> 100 then
    raise exception '10.1 difficulty: easy %, medium %, hard %, by_domain %',
      (select count(*) from public.questions question join public.certifications certification on certification.id=question.certification_id
        where certification.code='az-900' and question.is_published and question.difficulty='easy'),
      (select count(*) from public.questions question join public.certifications certification on certification.id=question.certification_id
        where certification.code='az-900' and question.is_published and question.difficulty='medium'),
      (select count(*) from public.questions question join public.certifications certification on certification.id=question.certification_id
        where certification.code='az-900' and question.is_published and question.difficulty='hard'),
      (select jsonb_object_agg(title,distribution) from (
        select domain.title,jsonb_build_object(
          'easy',count(*) filter(where question.difficulty='easy'),
          'medium',count(*) filter(where question.difficulty='medium'),
          'hard',count(*) filter(where question.difficulty='hard')) distribution
        from public.questions question join public.domains domain on domain.id=question.domain_id
        join public.certifications certification on certification.id=question.certification_id
        where certification.code='az-900' and question.is_published group by domain.title) totals);
  end if;

  if (select count(*) from public.lessons lesson
      join public.topics topic on topic.id=lesson.topic_id
      join public.domains domain on domain.id=topic.domain_id
      where domain.title='Describe cloud concepts'
        and not exists(select 1 from public.lesson_content_blocks block
          where block.lesson_id=lesson.id and block.is_published))<>5
    or exists(select 1 from public.lessons lesson
      join public.topics topic on topic.id=lesson.topic_id
      join public.domains domain on domain.id=topic.domain_id
      where domain.title='Describe cloud concepts'
        and not exists(select 1 from public.lesson_content_blocks block
          where block.lesson_id=lesson.id and block.is_published)
        and lesson.slug not in('high-availability','scalability','elasticity','reliability','predictability')) then
    raise exception '10.1 unexpected structured-content gap set';
  end if;

  for lesson_row in
    select lesson.id, lesson.slug
    from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900' and lesson.is_published
      and lesson.slug not in ('high-availability','scalability','elasticity','reliability','predictability')
  loop
    if not exists (select 1 from public.lessons where id = lesson_row.id
        and content is not null and btrim(content) <> '')
      or (select count(*) from public.lesson_content_blocks
          where lesson_id = lesson_row.id and is_published) = 0
      or (select min(display_order) from public.lesson_content_blocks
          where lesson_id = lesson_row.id and is_published) <> 1
      or (select max(display_order) from public.lesson_content_blocks
          where lesson_id = lesson_row.id and is_published)
        <> (select count(*) from public.lesson_content_blocks
          where lesson_id = lesson_row.id and is_published)
      or (select count(distinct display_order) from public.lesson_content_blocks
          where lesson_id = lesson_row.id and is_published)
        <> (select count(*) from public.lesson_content_blocks
          where lesson_id = lesson_row.id and is_published)
      or (select count(*) from public.lesson_content_blocks
          where lesson_id = lesson_row.id and is_published and type = 'summary') <> 1
      or (select count(*) from public.flashcards
          where lesson_id = lesson_row.id and is_published) = 0
      or (select count(*) from public.questions
          where lesson_id = lesson_row.id and is_published) < 5 then
      raise exception '10.1 incomplete Lessons: %', (
        select jsonb_agg(jsonb_build_object(
          'slug',lesson.slug,
          'blocks',(select count(*) from public.lesson_content_blocks where lesson_id=lesson.id and is_published),
          'summaries',(select count(*) from public.lesson_content_blocks where lesson_id=lesson.id and is_published and type='summary'),
          'cards',(select count(*) from public.flashcards where lesson_id=lesson.id and is_published),
          'questions',(select count(*) from public.questions where lesson_id=lesson.id and is_published)
        ) order by domain.display_order,topic.display_order,lesson.display_order)
        from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
        join public.domains domain on domain.id=topic.domain_id
        join public.certifications certification on certification.id=domain.certification_id
        where certification.code='az-900' and lesson.is_published and (
          lesson.content is null or btrim(lesson.content)=''
          or (select count(*) from public.lesson_content_blocks where lesson_id=lesson.id and is_published)=0
          or (select min(display_order) from public.lesson_content_blocks where lesson_id=lesson.id and is_published)<>1
          or (select max(display_order) from public.lesson_content_blocks where lesson_id=lesson.id and is_published)
            <>(select count(*) from public.lesson_content_blocks where lesson_id=lesson.id and is_published)
          or (select count(distinct display_order) from public.lesson_content_blocks where lesson_id=lesson.id and is_published)
            <>(select count(*) from public.lesson_content_blocks where lesson_id=lesson.id and is_published)
          or (select count(*) from public.lesson_content_blocks where lesson_id=lesson.id and is_published and type='summary')<>1
          or (select count(*) from public.flashcards where lesson_id=lesson.id and is_published)=0
          or (select count(*) from public.questions where lesson_id=lesson.id and is_published)<5
        )
      );
    end if;
  end loop;

  if exists (
      select 1 from public.questions question
      join public.certifications certification on certification.id = question.certification_id
      left join public.question_options option on option.question_id = question.id
      where certification.code = 'az-900' and question.is_published
      group by question.id
      having count(option.id) <> 4
        or count(option.id) filter (where option.is_correct) <> 1
        or count(distinct lower(btrim(option.option_text))) <> 4
        or min(length(btrim(question.explanation))) < 20
    ) then raise exception '10.1 invalid AZ-900 Questions or options'; end if;

  select count(*) into duplicate_count from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g')) normalized
    from public.questions question
    join public.certifications certification on certification.id = question.certification_id
    where certification.code = 'az-900' and question.is_published
    group by normalized having count(*) > 1
  ) duplicates;
  if duplicate_count <> 0 then
    raise exception '10.1 found % groups of exact normalized Question duplicates', duplicate_count;
  end if;

  select count(*) into duplicate_count from (
    select lower(regexp_replace(btrim(card.front_text), '[^[:alnum:]]+', ' ', 'g')) normalized
    from public.flashcards card
    join public.lessons lesson on lesson.id = card.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900' and card.is_published
    group by normalized having count(*) > 1
  ) duplicates;
  if duplicate_count <> 0 then
    raise exception '10.1 found % groups of exact normalized Flashcard duplicates', duplicate_count;
  end if;

  if exists (
      select 1 from public.visual_experiences visual
      join public.lessons lesson on lesson.id = visual.lesson_id
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900' and visual.is_published
        and (jsonb_typeof(visual.config) <> 'object'
          or not exists (select 1 from public.lesson_content_blocks block
            where block.lesson_id = visual.lesson_id
              and block.visual_experience_id = visual.id
              and block.type = 'visual_experience' and block.is_published))
    ) then raise exception '10.1 invalid or unlinked Visual Experience'; end if;

  if exists (
      select 1 from public.questions question
      join public.lessons lesson on lesson.id = question.lesson_id
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      where question.topic_id <> topic.id or question.domain_id <> domain.id
        or lesson.topic_id <> topic.id or topic.domain_id <> domain.id
    ) then raise exception '10.1 inconsistent Question hierarchy'; end if;

  if exists (select 1 from public.user_lesson_progress progress
      left join public.lessons lesson on lesson.id = progress.lesson_id where lesson.id is null)
    or exists (select 1 from public.quiz_attempts attempt
      left join auth.users user_record on user_record.id = attempt.user_id where user_record.id is null)
    or exists (select 1 from public.quiz_attempt_questions item
      left join public.quiz_attempts attempt on attempt.id = item.attempt_id
      left join public.questions question on question.id = item.question_id
      where attempt.id is null or question.id is null)
    or exists (select 1 from public.quiz_answers answer
      left join public.quiz_attempts attempt on attempt.id = answer.attempt_id
      left join public.questions question on question.id = answer.question_id
      left join public.question_options option on option.id = answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null)
    or exists (select 1 from public.flashcard_reviews review
      left join public.flashcards card on card.id = review.flashcard_id where card.id is null)
    or exists (select 1 from public.user_flashcard_progress progress
      left join public.flashcards card on card.id = progress.flashcard_id where card.id is null) then
    raise exception '10.1 found orphan study history';
  end if;

  if exists (select 1 from pg_class relation join pg_namespace namespace on namespace.oid = relation.relnamespace
      where namespace.nspname = 'public'
        and relation.relname in (
          'domains','topics','lessons','lesson_content_blocks','visual_experiences','flashcards',
          'questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions',
          'quiz_answers','flashcard_reviews','user_flashcard_progress'
        ) and not relation.relrowsecurity) then
    raise exception '10.1 requires RLS on all audited tables';
  end if;

  if has_table_privilege('authenticated','public.lessons','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or has_table_privilege('authenticated','public.visual_experiences','UPDATE')
    or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.questions','SELECT')
    or has_table_privilege('authenticated','public.question_options','SELECT') then
    raise exception '10.1 authenticated curriculum grants are unsafe';
  end if;
end; $$;

commit;

-- Exercita todos os Topics e desfaz integralmente os fixtures.
begin;

create temporary table audit_topics on commit drop as
select topic.id, topic.title, domain.display_order domain_order, topic.display_order,
  count(distinct lesson.id)::integer lesson_count,
  count(distinct question.id)::integer question_count,
  certification.id certification_id
from public.topics topic
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
join public.lessons lesson on lesson.topic_id = topic.id and lesson.is_published
join public.questions question on question.topic_id = topic.id and question.is_published
where certification.code = 'az-900'
group by topic.id, topic.title, domain.display_order, topic.display_order, certification.id;

create temporary table audit_lessons on commit drop as
select lesson.id, lesson.slug, topic.id topic_id, topic.display_order topic_order,
  domain.display_order domain_order
from public.lessons lesson join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900' and lesson.is_published;

create temporary table audit_wrong_options(question_id uuid primary key, option_id uuid not null) on commit drop;
insert into audit_wrong_options
select question.id, (array_agg(option.id order by option.display_order)
  filter (where not option.is_correct))[1]
from public.questions question join public.question_options option on option.question_id = question.id
join public.certifications certification on certification.id = question.certification_id
where certification.code = 'az-900' and question.is_published
group by question.id;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select '00000000-0000-0000-0000-000000000000',seed.id,'authenticated','authenticated',
  seed.email,'',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()
from(values
  ('58000000-0000-4000-8000-000000000046'::uuid,'global-audit-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000047'::uuid,'global-audit-b@example.invalid')) seed(id,email);

grant select on audit_topics, audit_lessons, audit_wrong_options to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000046',true);

do $$
declare
  lesson_row record;
  topic_row record;
  lesson_attempt public.quiz_attempts;
  topic_attempt public.quiz_attempts;
  review_attempt public.quiz_attempts;
  question_row record;
  first_lesson uuid;
  first_card uuid;
  certification_uuid uuid;
  started public.user_lesson_progress;
  completed public.user_lesson_progress;
begin
  select id into strict first_lesson from audit_lessons order by domain_order,topic_order,slug limit 1;
  select certification_id into strict certification_uuid from audit_topics limit 1;

  for lesson_row in select * from audit_lessons order by domain_order,topic_order,slug loop
    select * into strict lesson_attempt from public.start_lesson_quiz(lesson_row.id);
    if lesson_attempt.total_questions <> 5
      or (select count(*) from public.quiz_attempt_questions where attempt_id = lesson_attempt.id) <> 5 then
      raise exception '10.1 Lesson Quiz failed for %', lesson_row.slug;
    end if;
    if lesson_row.id = first_lesson then
      for question_row in select item.question_id, wrong.option_id
        from public.quiz_attempt_questions item
        join audit_wrong_options wrong on wrong.question_id = item.question_id
        where item.attempt_id = lesson_attempt.id order by item.display_order loop
        perform * from public.submit_quiz_answer(lesson_attempt.id,question_row.question_id,question_row.option_id);
      end loop;
    end if;
  end loop;

  for topic_row in select * from audit_topics order by domain_order,display_order loop
    select * into strict topic_attempt from public.start_topic_quiz(topic_row.id);
    if topic_attempt.total_questions <> least(topic_row.question_count,10)
      or (select count(*) from public.quiz_attempt_questions where attempt_id = topic_attempt.id)
        <> least(topic_row.question_count,10)
      or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item
        join public.questions question on question.id = item.question_id
        where item.attempt_id = topic_attempt.id) <> least(topic_row.lesson_count,10) then
      raise exception '10.1 Topic Quiz failed for %', topic_row.title;
    end if;
  end loop;

  select * into strict review_attempt from public.start_review_quiz(certification_uuid);
  if review_attempt.quiz_type <> 'review' or review_attempt.total_questions <> 5
    or (select count(*) from public.quiz_attempt_questions where attempt_id = review_attempt.id) <> 5 then
    raise exception '10.1 Review failed';
  end if;

  select * into strict started from public.start_lesson_progress(first_lesson);
  select * into strict completed from public.complete_lesson_progress(first_lesson);
  if started.status <> 'in_progress' or completed.status <> 'completed' or completed.completed_at is null then
    raise exception '10.1 progress failed';
  end if;

  select card.id into strict first_card from public.flashcards card
  join audit_lessons lesson on lesson.id = card.lesson_id
  order by lesson.domain_order,lesson.topic_order,card.display_order limit 1;
  perform public.submit_flashcard_review(first_card,'good');
  if not exists (select 1 from public.flashcard_reviews where flashcard_id = first_card)
    or not exists (select 1 from public.user_flashcard_progress where flashcard_id = first_card) then
    raise exception '10.1 spaced repetition failed';
  end if;
end; $$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000047',true);
do $$ begin
  if exists (select 1 from public.quiz_attempts where user_id = '58000000-0000-4000-8000-000000000046')
    or exists (select 1 from public.user_lesson_progress where user_id = '58000000-0000-4000-8000-000000000046')
    or exists (select 1 from public.flashcard_reviews where user_id = '58000000-0000-4000-8000-000000000046')
    or exists (select 1 from public.user_flashcard_progress where user_id = '58000000-0000-4000-8000-000000000046') then
    raise exception '10.1 user isolation failed';
  end if;
end; $$;

rollback;

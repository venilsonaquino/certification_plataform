begin;

create temporary table audit_102_expected_lessons (
  lesson_id uuid primary key,
  slug text not null unique,
  title text not null,
  fallback_md5 text not null
) on commit drop;

insert into audit_102_expected_lessons values
  ('40000000-0000-4000-8000-000000000002','high-availability','High Availability','330001c4977b075dd3b22c4212b848d7'),
  ('8e04bfc9-03a6-4ae4-be9c-e7238e5c2783','scalability','Scalability','6f97c7995a3e62a4f8a38bd1b6d359fd'),
  ('a7bb4f85-9cc1-46ad-9f65-44f978abf851','elasticity','Elasticity','4ce2f536de95c78ac94a4a8a6dc04f9d'),
  ('b74f3c89-867f-409e-b5b2-8ad1713c1428','reliability','Reliability','5204f82535bd4cfdc226a6a13fb11141'),
  ('e709cd4e-c17a-469e-b7a8-70271c79e52e','predictability','Predictability','fb2d31f34d685052b58480c3e4dace12');

do $$
declare
  expected_lesson record;
begin
  if (select count(*) from audit_102_expected_lessons) <> 5 then
    raise exception '10.2 expected five immutable Lesson identities';
  end if;

  for expected_lesson in select * from audit_102_expected_lessons loop
    if not exists (
      select 1
      from public.lessons lesson
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where lesson.id = expected_lesson.lesson_id
        and lesson.slug = expected_lesson.slug
        and lesson.title = expected_lesson.title
        and lesson.topic_id = '31000000-0000-4000-8000-000000000002'
        and topic.title = 'Benefits of Cloud Services'
        and domain.id = '20000000-0000-4000-8000-000000000001'
        and domain.title = 'Describe cloud concepts'
        and certification.code = 'az-900'
        and lesson.is_published
        and lesson.estimated_minutes = 10
        and lesson.content is not null
        and btrim(lesson.content) <> ''
        and md5(lesson.content) = expected_lesson.fallback_md5
    ) then
      raise exception '10.2 identity, hierarchy, timing or fallback changed for %', expected_lesson.slug;
    end if;

    if (select count(*) from public.lesson_content_blocks block
        where block.lesson_id = expected_lesson.lesson_id and block.is_published) <> 7
      or (select min(block.display_order) from public.lesson_content_blocks block
        where block.lesson_id = expected_lesson.lesson_id and block.is_published) <> 1
      or (select max(block.display_order) from public.lesson_content_blocks block
        where block.lesson_id = expected_lesson.lesson_id and block.is_published) <> 7
      or (select count(distinct block.display_order) from public.lesson_content_blocks block
        where block.lesson_id = expected_lesson.lesson_id and block.is_published) <> 7
      or (select count(*) from public.lesson_content_blocks block
        where block.lesson_id = expected_lesson.lesson_id and block.is_published and block.type = 'summary') <> 1
      or (select count(*) from public.lesson_content_blocks block
        where block.lesson_id = expected_lesson.lesson_id and block.is_published
          and block.type in ('explanation','important','example','exam_tip','exam_trap','summary')) <> 7
      or exists (select 1 from public.lesson_content_blocks block
        where block.lesson_id = expected_lesson.lesson_id and block.is_published
          and block.type not in ('explanation','important','example','exam_tip','exam_trap','summary')) then
      raise exception '10.2 invalid Content Block shape/order for %', expected_lesson.slug;
    end if;

    if not exists (
      select 1 from public.lesson_content_blocks block
      where block.lesson_id = expected_lesson.lesson_id
        and block.type = 'summary'
        and block.display_order = 7
        and block.content is null
        and jsonb_typeof(block.config) = 'object'
        and jsonb_typeof(block.config -> 'items') = 'array'
        and jsonb_array_length(block.config -> 'items') between 3 and 6
    ) then
      raise exception '10.2 missing valid final summary for %', expected_lesson.slug;
    end if;

    if (select count(*) from public.flashcards card
        where card.lesson_id = expected_lesson.lesson_id and card.is_published) <> 4
      or (select count(*) from public.questions question
        where question.lesson_id = expected_lesson.lesson_id and question.is_published) <> 10 then
      raise exception '10.2 practice count changed for %', expected_lesson.slug;
    end if;
  end loop;

  if (select count(*) from public.lesson_content_blocks block
      join public.lessons lesson on lesson.id = block.lesson_id
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900' and block.is_published) <> 712
    or (select count(*) from public.lesson_content_blocks block
      join public.lessons lesson on lesson.id = block.lesson_id
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      where domain.title = 'Describe cloud concepts' and block.is_published) <> 129 then
    raise exception '10.2 expected 712 global and 129 Domain 1 Content Blocks';
  end if;

  if exists (
    select 1 from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900' and lesson.is_published
      and (not exists (select 1 from public.lesson_content_blocks block
        where block.lesson_id = lesson.id and block.is_published)
      or (select count(*) from public.lesson_content_blocks block
        where block.lesson_id = lesson.id and block.is_published and block.type = 'summary') <> 1)
  ) then
    raise exception '10.2 found an AZ-900 Lesson without blocks or exactly one summary';
  end if;

  if exists (
    select 1 from public.questions question
    join audit_102_expected_lessons expected on expected.lesson_id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where question.is_published
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
      or min(length(btrim(question.explanation))) < 20
  ) then
    raise exception '10.2 invalid preserved Question or option';
  end if;

  if exists (select 1 from public.user_lesson_progress progress
      left join public.lessons lesson on lesson.id = progress.lesson_id where lesson.id is null)
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
    raise exception '10.2 found orphan study history';
  end if;

  if not (select relation.relrowsecurity from pg_class relation
      join pg_namespace namespace on namespace.oid = relation.relnamespace
      where namespace.nspname = 'public' and relation.relname = 'lesson_content_blocks')
    or has_table_privilege('authenticated','public.lesson_content_blocks','INSERT')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','DELETE') then
    raise exception '10.2 Content Block RLS or grants are unsafe';
  end if;
end;
$$;

commit;

-- Exercita o fluxo das cinco Lessons e desfaz integralmente os fixtures.
begin;

create temporary table audit_102_lessons on commit drop as
select * from (values
  ('40000000-0000-4000-8000-000000000002'::uuid,'high-availability'::text),
  ('8e04bfc9-03a6-4ae4-be9c-e7238e5c2783'::uuid,'scalability'::text),
  ('a7bb4f85-9cc1-46ad-9f65-44f978abf851'::uuid,'elasticity'::text),
  ('b74f3c89-867f-409e-b5b2-8ad1713c1428'::uuid,'reliability'::text),
  ('e709cd4e-c17a-469e-b7a8-70271c79e52e'::uuid,'predictability'::text)
) expected(id,slug);

create temporary table audit_102_wrong_options(question_id uuid primary key, option_id uuid not null) on commit drop;
insert into audit_102_wrong_options
select question.id, (array_agg(option.id order by option.display_order)
  filter (where not option.is_correct))[1]
from public.questions question
join public.question_options option on option.question_id = question.id
join audit_102_lessons lesson on lesson.id = question.lesson_id
where question.is_published
group by question.id;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select '00000000-0000-0000-0000-000000000000',seed.id,'authenticated','authenticated',
  seed.email,'',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()
from(values
  ('58000000-0000-4000-8000-000000000048'::uuid,'benefits-cleanup-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000049'::uuid,'benefits-cleanup-b@example.invalid')) seed(id,email);

grant select on audit_102_lessons, audit_102_wrong_options to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000048',true);

do $$
declare
  lesson_row record;
  lesson_attempt public.quiz_attempts;
  topic_attempt public.quiz_attempts;
  review_attempt public.quiz_attempts;
  question_row record;
  completed public.user_lesson_progress;
  first_card uuid;
begin
  if (select count(*) from public.lesson_content_blocks block
      join audit_102_lessons lesson on lesson.id = block.lesson_id
      where block.is_published) <> 35 then
    raise exception '10.2 authenticated renderer read failed';
  end if;

  for lesson_row in select * from audit_102_lessons order by slug loop
    select * into strict lesson_attempt from public.start_lesson_quiz(lesson_row.id);
    if lesson_attempt.total_questions <> 5
      or (select count(*) from public.quiz_attempt_questions where attempt_id = lesson_attempt.id) <> 5 then
      raise exception '10.2 Lesson Quiz failed for %', lesson_row.slug;
    end if;

    if lesson_row.slug = 'high-availability' then
      for question_row in
        select item.question_id, wrong.option_id
        from public.quiz_attempt_questions item
        join audit_102_wrong_options wrong on wrong.question_id = item.question_id
        where item.attempt_id = lesson_attempt.id
        order by item.display_order
      loop
        perform * from public.submit_quiz_answer(
          lesson_attempt.id, question_row.question_id, question_row.option_id
        );
      end loop;
    end if;

    select * into strict completed from public.complete_lesson_progress(lesson_row.id);
    if completed.status <> 'completed' or completed.completed_at is null then
      raise exception '10.2 completion failed for %', lesson_row.slug;
    end if;
  end loop;

  select * into strict topic_attempt
  from public.start_topic_quiz('31000000-0000-4000-8000-000000000002');
  if topic_attempt.total_questions <> 10
    or (select count(*) from public.quiz_attempt_questions where attempt_id = topic_attempt.id) <> 10
    or (select count(distinct question.lesson_id)
      from public.quiz_attempt_questions item
      join public.questions question on question.id = item.question_id
      where item.attempt_id = topic_attempt.id) <> 7 then
    raise exception '10.2 Benefits Topic Quiz failed';
  end if;

  select * into strict review_attempt
  from public.start_review_quiz((select id from public.certifications where code = 'az-900'));
  if review_attempt.quiz_type <> 'review' or review_attempt.total_questions <> 5
    or (select count(*) from public.quiz_attempt_questions where attempt_id = review_attempt.id) <> 5 then
    raise exception '10.2 Review failed';
  end if;

  select card.id into strict first_card
  from public.flashcards card
  join audit_102_lessons lesson on lesson.id = card.lesson_id
  order by lesson.slug, card.display_order limit 1;
  perform public.submit_flashcard_review(first_card,'good');
  if not exists (select 1 from public.flashcard_reviews where flashcard_id = first_card)
    or not exists (select 1 from public.user_flashcard_progress where flashcard_id = first_card) then
    raise exception '10.2 spaced repetition failed';
  end if;
end;
$$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000049',true);
do $$
begin
  if exists (select 1 from public.quiz_attempts where user_id = '58000000-0000-4000-8000-000000000048')
    or exists (select 1 from public.user_lesson_progress where user_id = '58000000-0000-4000-8000-000000000048')
    or exists (select 1 from public.flashcard_reviews where user_id = '58000000-0000-4000-8000-000000000048')
    or exists (select 1 from public.user_flashcard_progress where user_id = '58000000-0000-4000-8000-000000000048') then
    raise exception '10.2 user isolation failed';
  end if;
end;
$$;

rollback;

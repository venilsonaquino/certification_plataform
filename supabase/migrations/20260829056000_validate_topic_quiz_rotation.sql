begin;

do $$
declare
  function_source text;
begin
  select pg_get_functiondef('public.start_topic_quiz(uuid)'::regprocedure) into function_source;

  if function_source not like '%history_attempt.user_id = v_user_id%'
    or function_source not like '%history.in_last_attempt%'
    or function_source not like '%history.last_seen_at asc nulls first%'
    or function_source not like '%selection.lesson_selected%'
    or function_source not like '%v_target_medium%' then
    raise exception '10.3 start_topic_quiz does not contain the required user history, rotation and balance rules';
  end if;

  if has_function_privilege('anon','public.start_topic_quiz(uuid)','EXECUTE')
    or not has_function_privilege('authenticated','public.start_topic_quiz(uuid)','EXECUTE') then
    raise exception '10.3 start_topic_quiz grants are invalid';
  end if;

  if exists (select 1 from public.quiz_attempt_questions item
      left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id
      where attempt.id is null or question.id is null)
    or exists (select 1 from public.quiz_answers answer
      left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id
      left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null)
    or exists (select 1 from public.flashcard_reviews review
      left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists (select 1 from public.user_flashcard_progress progress
      left join public.flashcards card on card.id=progress.flashcard_id where card.id is null) then
    raise exception '10.3 found orphan history';
  end if;
end;
$$;

commit;

-- Testes determinísticos sobre os 12 Topics; todos os fixtures são revertidos.
begin;

create temporary table audit_103_topics on commit drop as
select
  topic.id,
  topic.title,
  count(distinct lesson.id)::integer as lesson_count,
  count(distinct question.id)::integer as pool_size,
  count(distinct question.id) filter(where question.difficulty='easy')::integer as easy_pool,
  count(distinct question.id) filter(where question.difficulty='medium')::integer as medium_pool,
  count(distinct question.id) filter(where question.difficulty='hard')::integer as hard_pool
from public.topics topic
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
join public.lessons lesson on lesson.topic_id = topic.id and lesson.is_published
join public.questions question on question.topic_id = topic.id
  and question.lesson_id = lesson.id
  and question.is_published
  and question.question_type = 'single_choice'
where certification.code = 'az-900'
group by topic.id, topic.title;

create temporary table audit_103_items (
  user_id uuid not null,
  topic_id uuid not null,
  attempt_no integer not null,
  attempt_id uuid not null,
  question_id uuid not null,
  lesson_id uuid,
  difficulty text not null,
  primary key(user_id,topic_id,attempt_no,question_id)
) on commit drop;

create temporary table audit_103_answer_key (
  question_id uuid primary key,
  correct_option_id uuid not null,
  incorrect_option_id uuid not null
) on commit drop;

insert into audit_103_answer_key
select
  question.id,
  (array_agg(option.id order by option.display_order) filter (where option.is_correct))[1],
  (array_agg(option.id order by option.display_order) filter (where not option.is_correct))[1]
from public.questions question
join public.question_options option on option.question_id = question.id
where question.topic_id in (select id from audit_103_topics)
group by question.id
having count(*) filter (where option.is_correct) = 1
  and count(*) filter (where not option.is_correct) >= 1;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select '00000000-0000-0000-0000-000000000000',seed.id,'authenticated','authenticated',
  seed.email,'',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()
from(values
  ('58000000-0000-4000-8000-000000000052'::uuid,'topic-rotation-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000053'::uuid,'topic-rotation-b@example.invalid')) seed(id,email);

grant select on audit_103_topics, audit_103_answer_key to authenticated;
grant select, insert on audit_103_items to authenticated;

set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000052',true);

do $$
declare
  topic_row record;
  item_row record;
  attempt_one public.quiz_attempts;
  attempt_one_again public.quiz_attempts;
  attempt_two public.quiz_attempts;
  attempt_three public.quiz_attempts;
  lesson_attempt public.quiz_attempts;
  review_attempt public.quiz_attempts;
  first_card uuid;
begin
  if (select count(*) from audit_103_topics) <> 12 then
    raise exception '10.3 expected all twelve AZ-900 Topics';
  end if;

  for topic_row in select * from audit_103_topics order by title loop
    select * into strict attempt_one from public.start_topic_quiz(topic_row.id);
    select * into strict attempt_one_again from public.start_topic_quiz(topic_row.id);

    if attempt_one.id <> attempt_one_again.id or attempt_one.total_questions <> 10 then
      raise exception '10.3 first/active attempt behavior failed for %', topic_row.title;
    end if;

    insert into audit_103_items
    select
      '58000000-0000-4000-8000-000000000052',
      topic_row.id,
      1,
      attempt_one.id,
      question.id,
      question.lesson_id,
      question.difficulty
    from public.quiz_attempt_questions item
    join public.questions question on question.id = item.question_id
    where item.attempt_id = attempt_one.id;

    for item_row in
      select item.question_id, item.display_order, answer_key.correct_option_id,
        answer_key.incorrect_option_id
      from public.quiz_attempt_questions item
      join audit_103_answer_key answer_key on answer_key.question_id = item.question_id
      where item.attempt_id = attempt_one.id
      order by item.display_order
    loop
      perform * from public.submit_quiz_answer(
        attempt_one.id,
        item_row.question_id,
        case
          when topic_row.id = '30000000-0000-4000-8000-000000000001'
            then item_row.incorrect_option_id
          else item_row.correct_option_id
        end
      );
    end loop;

    if (select status from public.quiz_attempts where id = attempt_one.id) <> 'completed' then
      raise exception '10.3 attempt one did not complete for %', topic_row.title;
    end if;

    select * into strict attempt_two from public.start_topic_quiz(topic_row.id);
    if attempt_two.id = attempt_one.id or attempt_two.total_questions <> 10 then
      raise exception '10.3 retake was not created for %', topic_row.title;
    end if;

    insert into audit_103_items
    select
      '58000000-0000-4000-8000-000000000052',
      topic_row.id,
      2,
      attempt_two.id,
      question.id,
      question.lesson_id,
      question.difficulty
    from public.quiz_attempt_questions item
    join public.questions question on question.id = item.question_id
    where item.attempt_id = attempt_two.id;

    for item_row in
      select item.question_id, answer_key.correct_option_id
      from public.quiz_attempt_questions item
      join audit_103_answer_key answer_key on answer_key.question_id = item.question_id
      where item.attempt_id = attempt_two.id
      order by item.display_order
    loop
      perform * from public.submit_quiz_answer(
        attempt_two.id, item_row.question_id, item_row.correct_option_id
      );
    end loop;
  end loop;

  if exists (
    select 1
    from audit_103_topics topic
    where (select count(*)
      from audit_103_items first_item
      join audit_103_items second_item
        on second_item.user_id = first_item.user_id
        and second_item.topic_id = first_item.topic_id
        and second_item.attempt_no = 2
        and second_item.question_id = first_item.question_id
      where first_item.user_id = '58000000-0000-4000-8000-000000000052'
        and first_item.topic_id = topic.id
        and first_item.attempt_no = 1)
      <> greatest(0, 6 - topic.easy_pool)
        + greatest(0, 10 - topic.medium_pool)
        + greatest(0, 4 - topic.hard_pool)
  ) then
    raise exception '10.3 attempt 1→2 overlap is not mathematically minimal';
  end if;

  if exists (
    select 1
    from audit_103_topics topic
    cross join (values(1),(2)) attempt_number(value)
    where (select count(distinct item.lesson_id)
      from audit_103_items item
      where item.user_id = '58000000-0000-4000-8000-000000000052'
        and item.topic_id = topic.id
        and item.attempt_no = attempt_number.value) <> least(topic.lesson_count,10)
  ) then
    raise exception '10.3 rotation removed an eligible Lesson';
  end if;

  if exists (
    select 1 from (
      select topic_id, attempt_no, max(amount) - min(amount) spread
      from (
        select topic_id, attempt_no, lesson_id, count(*) amount
        from audit_103_items
        where user_id = '58000000-0000-4000-8000-000000000052'
          and attempt_no in (1,2)
        group by topic_id,attempt_no,lesson_id
      ) lesson_distribution
      group by topic_id,attempt_no
    ) balance where spread > 1
  ) then
    raise exception '10.3 Lesson distribution differs by more than one item';
  end if;

  if exists (
    select topic_id,attempt_no
    from audit_103_items
    where user_id = '58000000-0000-4000-8000-000000000052'
      and attempt_no in (1,2)
    group by topic_id,attempt_no
    having count(*) filter(where difficulty='easy') <> 3
      or count(*) filter(where difficulty='medium') <> 5
      or count(*) filter(where difficulty='hard') <> 2
  ) then
    raise exception '10.3 difficulty distribution is not 3 easy / 5 medium / 2 hard';
  end if;

  -- Caso D: um pool totalmente visto continua funcionando e evita o último attempt
  -- até o limite matemático imposto pelo tamanho do pool e pela distribuição 3/5/2.
  for topic_row in
    select * from audit_103_topics
    where id = '33000000-0000-4000-8000-000000000002'
  loop
    select * into strict attempt_three from public.start_topic_quiz(topic_row.id);
    insert into audit_103_items
    select
      '58000000-0000-4000-8000-000000000052',topic_row.id,3,attempt_three.id,
      question.id,question.lesson_id,question.difficulty
    from public.quiz_attempt_questions item
    join public.questions question on question.id = item.question_id
    where item.attempt_id = attempt_three.id;

    if (select count(*)
        from audit_103_items prior
        join audit_103_items current_item
          on current_item.topic_id = prior.topic_id
          and current_item.attempt_no = 3
          and current_item.question_id = prior.question_id
        where prior.topic_id = topic_row.id and prior.attempt_no = 2)
      <> greatest(0, 6 - topic_row.easy_pool)
        + greatest(0, 10 - topic_row.medium_pool)
        + greatest(0, 4 - topic_row.hard_pool) then
      raise exception '10.3 exhausted-pool rotation failed for %', topic_row.title;
    end if;

    if exists (
      select 1 from audit_103_items current_item
      where current_item.topic_id = topic_row.id and current_item.attempt_no = 3
        and not exists (select 1 from audit_103_items prior
          where prior.topic_id = topic_row.id
            and prior.attempt_no in (1,2)
            and prior.question_id = current_item.question_id)
    ) then
      raise exception '10.3 exhausted-pool case unexpectedly found unseen Questions';
    end if;
  end loop;

  -- Lesson Quiz, Review e Spaced Repetition continuam independentes da rotação.
  select * into strict lesson_attempt
  from public.start_lesson_quiz((select id from public.lessons where slug='what-is-cloud-computing'));
  if lesson_attempt.total_questions <> 5 then raise exception '10.3 Lesson Quiz regressed'; end if;

  select * into strict review_attempt
  from public.start_review_quiz((select id from public.certifications where code='az-900'));
  if review_attempt.total_questions not between 5 and 10
    or (select count(*) from public.quiz_attempt_questions
      where attempt_id=review_attempt.id) <> review_attempt.total_questions then
    raise exception '10.3 Review regressed';
  end if;

  select card.id into strict first_card
  from public.flashcards card
  join public.lessons lesson on lesson.id = card.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code='az-900' and card.is_published
  order by domain.display_order,topic.display_order,lesson.display_order,card.display_order limit 1;
  perform public.submit_flashcard_review(first_card,'good');
  if not exists(select 1 from public.user_flashcard_progress where flashcard_id=first_card) then
    raise exception '10.3 Spaced Repetition regressed';
  end if;
end;
$$;

-- Caso E: o histórico de A não altera o primeiro attempt de B.
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000053',true);

do $$
declare
  user_b_attempt public.quiz_attempts;
begin
  select * into strict user_b_attempt
  from public.start_topic_quiz('31000000-0000-4000-8000-000000000003');

  insert into audit_103_items
  select
    '58000000-0000-4000-8000-000000000053',
    '31000000-0000-4000-8000-000000000003',
    1,
    user_b_attempt.id,
    question.id,
    question.lesson_id,
    question.difficulty
  from public.quiz_attempt_questions item
  join public.questions question on question.id = item.question_id
  where item.attempt_id = user_b_attempt.id;

  if exists (
      (select question_id from audit_103_items
        where user_id='58000000-0000-4000-8000-000000000052'
          and topic_id='31000000-0000-4000-8000-000000000003' and attempt_no=1
       except
       select question_id from audit_103_items
        where user_id='58000000-0000-4000-8000-000000000053'
          and topic_id='31000000-0000-4000-8000-000000000003' and attempt_no=1)
      union all
      (select question_id from audit_103_items
        where user_id='58000000-0000-4000-8000-000000000053'
          and topic_id='31000000-0000-4000-8000-000000000003' and attempt_no=1
       except
       select question_id from audit_103_items
        where user_id='58000000-0000-4000-8000-000000000052'
          and topic_id='31000000-0000-4000-8000-000000000003' and attempt_no=1)
  ) then
    raise exception '10.3 user isolation changed the first-attempt baseline';
  end if;

  if exists(select 1 from public.quiz_attempts
      where user_id='58000000-0000-4000-8000-000000000052') then
    raise exception '10.3 user B can read user A history';
  end if;
end;
$$;

rollback;

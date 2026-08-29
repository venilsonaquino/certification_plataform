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
  and topic.id = '32000000-0000-4000-8000-000000000003'
  and topic.title = 'Networking Services';

do $$
declare
  duplicate_count integer;
begin
  if not exists (
    select 1 from supabase_migrations.schema_migrations where version = '20260827080000'
  ) then
    raise exception 'The final Networking content migration is not registered';
  end if;

  if (select count(*) from target_lessons) <> 5
    or (select sum(estimated_minutes) from target_lessons) <> 56
    or exists (
      select 1
      from target_lessons target
      join public.lessons lesson on lesson.id = target.id
      where not lesson.is_published
        or lesson.content is null
        or btrim(lesson.content) = ''
        or lesson.display_order <> case lesson.slug
          when 'virtual-networks-and-subnets' then 1
          when 'vnet-peering' then 2
          when 'azure-dns' then 3
          when 'vpn-gateway-vs-expressroute' then 4
          when 'public-vs-private-endpoints' then 5
          else -1
        end
        or lesson.estimated_minutes <> case lesson.slug
          when 'virtual-networks-and-subnets' then 12
          when 'vnet-peering' then 10
          when 'azure-dns' then 10
          when 'vpn-gateway-vs-expressroute' then 12
          when 'public-vs-private-endpoints' then 12
          else -1
        end
    ) then
    raise exception 'Networking Lesson inventory, order, publication, fallback or estimates are invalid';
  end if;

  if (select count(*) from public.lesson_content_blocks block join target_lessons target on target.id = block.lesson_id) <> 48
    or exists (
      select 1
      from target_lessons target
      left join public.lesson_content_blocks block on block.lesson_id = target.id
      group by target.id, target.slug
      having count(block.id) <> case target.slug
          when 'virtual-networks-and-subnets' then 10
          when 'vnet-peering' then 8
          when 'azure-dns' then 9
          when 'vpn-gateway-vs-expressroute' then 10
          when 'public-vs-private-endpoints' then 11
        end
        or min(block.display_order) <> 1
        or max(block.display_order) <> count(block.id)
        or count(distinct block.display_order) <> count(block.id)
        or count(*) filter (where block.is_published) <> count(block.id)
        or count(*) filter (where block.type = 'explanation') < 1
        or count(*) filter (where block.type in ('example', 'dotnet_example')) < 1
        or count(*) filter (where block.type = 'exam_tip') <> 1
        or count(*) filter (where block.type = 'exam_trap') <> 1
        or count(*) filter (where block.type = 'summary') <> 1
    ) then
    raise exception 'A Networking Lesson has invalid Content Blocks';
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
    raise exception 'A Networking summary is not final or lacks 3-6 recall items';
  end if;

  if (select count(*) from public.visual_experiences visual join target_lessons target on target.id = visual.lesson_id) <> 3
    or not exists (
      select 1 from public.visual_experiences visual join target_lessons target on target.id = visual.lesson_id
      where visual.id = '76000000-0000-4000-8000-000000000010'
        and target.slug = 'virtual-networks-and-subnets' and visual.type = 'architecture'
        and visual.is_published and jsonb_array_length(visual.config -> 'nodes') = 7
        and jsonb_array_length(visual.config -> 'edges') = 6
    )
    or not exists (
      select 1 from public.visual_experiences visual join target_lessons target on target.id = visual.lesson_id
      where visual.id = '76000000-0000-4000-8000-000000000011'
        and target.slug = 'vpn-gateway-vs-expressroute' and visual.type = 'comparison'
        and visual.is_published and jsonb_array_length(visual.config -> 'columns') = 2
        and jsonb_array_length(visual.config -> 'rows') = 7
    )
    or not exists (
      select 1 from public.visual_experiences visual join target_lessons target on target.id = visual.lesson_id
      where visual.id = '76000000-0000-4000-8000-000000000012'
        and target.slug = 'public-vs-private-endpoints' and visual.type = 'comparison'
        and visual.is_published and jsonb_array_length(visual.config -> 'columns') = 2
        and jsonb_array_length(visual.config -> 'rows') = 6
    ) then
    raise exception 'Networking must preserve exactly the three justified Visual Experiences';
  end if;

  if exists (
    select 1
    from public.visual_experiences visual
    join target_lessons target on target.id = visual.lesson_id
    cross join lateral jsonb_array_elements(visual.config -> 'edges') edge
    where visual.type = 'architecture'
      and (
        not exists (select 1 from jsonb_array_elements(visual.config -> 'nodes') node where node ->> 'id' = edge ->> 'source')
        or not exists (select 1 from jsonb_array_elements(visual.config -> 'nodes') node where node ->> 'id' = edge ->> 'target')
      )
  ) then
    raise exception 'The Networking architecture visual has a dangling edge';
  end if;

  if (
    select count(*) from public.lesson_content_blocks block
    join target_lessons target on target.id = block.lesson_id
    where block.type = 'visual_experience'
  ) <> 3 or exists (
    select 1 from public.lesson_content_blocks block
    join target_lessons target on target.id = block.lesson_id
    where block.type = 'visual_experience'
      and (block.visual_experience_id is null or block.content is not null or block.config is not null)
  ) then
    raise exception 'Networking visual blocks are invalid';
  end if;

  if (select count(*) from public.flashcards card join target_lessons target on target.id = card.lesson_id where card.is_published) <> 23
    or exists (
      select 1
      from target_lessons target
      left join public.flashcards card on card.lesson_id = target.id and card.is_published
      group by target.id, target.slug
      having count(card.id) <> case target.slug
        when 'virtual-networks-and-subnets' then 8
        when 'vnet-peering' then 3
        when 'azure-dns' then 3
        when 'vpn-gateway-vs-expressroute' then 4
        when 'public-vs-private-endpoints' then 5
      end
    )
    or exists (
      select 1 from public.flashcards card join target_lessons target on target.id = card.lesson_id
      where btrim(card.front_text) = '' or btrim(card.back_text) = ''
        or length(btrim(card.front_text)) > 220 or length(btrim(card.back_text)) > 500
    ) then
    raise exception 'Networking Flashcard inventory or concision is invalid';
  end if;

  select count(*) into duplicate_count
  from (
    select lower(regexp_replace(btrim(card.front_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.flashcards card join target_lessons target on target.id = card.lesson_id
    group by 1 having count(*) > 1
  ) duplicates;
  if duplicate_count <> 0 then
    raise exception 'Networking contains exact normalized Flashcard duplicates';
  end if;

  if (select count(*) from public.questions question join target_lessons target on target.id = question.lesson_id where question.is_published) <> 30
    or (select count(*) from public.questions question join target_lessons target on target.id = question.lesson_id where question.is_published and question.difficulty = 'easy') <> 11
    or (select count(*) from public.questions question join target_lessons target on target.id = question.lesson_id where question.is_published and question.difficulty = 'medium') <> 13
    or (select count(*) from public.questions question join target_lessons target on target.id = question.lesson_id where question.is_published and question.difficulty = 'hard') <> 6 then
    raise exception 'Networking Question inventory or difficulty distribution is invalid';
  end if;

  if exists (
    select 1
    from target_lessons target
    left join public.questions question on question.lesson_id = target.id and question.is_published
    group by target.id, target.slug
    having count(question.id) <> case when target.slug = 'azure-dns' then 10 else 5 end
      or count(question.id) filter (where question.difficulty = 'easy') <> case when target.slug = 'azure-dns' then 3 else 2 end
      or count(question.id) filter (where question.difficulty = 'medium') <> case when target.slug = 'azure-dns' then 5 else 2 end
      or count(question.id) filter (where question.difficulty = 'hard') <> case when target.slug = 'azure-dns' then 2 else 1 end
  ) then
    raise exception 'A Networking Lesson has an unexpected Question distribution';
  end if;

  if exists (
    select 1
    from public.questions question
    join target_lessons target on target.id = question.lesson_id
    join public.lessons lesson on lesson.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where question.is_published
    group by question.id, lesson.topic_id
    having question.topic_id <> lesson.topic_id
      or question.explanation is null
      or length(btrim(question.explanation)) < 40
      or count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
  ) then
    raise exception 'A Networking Question, hierarchy or its options are invalid';
  end if;

  select count(*) into duplicate_count
  from (
    select lower(regexp_replace(btrim(question.question_text), '[^[:alnum:]]+', ' ', 'g'))
    from public.questions question join target_lessons target on target.id = question.lesson_id
    group by 1 having count(*) > 1
  ) duplicates;
  if duplicate_count <> 0 then
    raise exception 'Networking contains exact normalized Question duplicates';
  end if;

  if exists (
    with artifacts as (
      select concat_ws(' ', block.title, block.content) as text
      from public.lesson_content_blocks block join target_lessons target on target.id = block.lesson_id
      union all
      select concat_ws(' ', card.back_text, card.hint)
      from public.flashcards card join target_lessons target on target.id = card.lesson_id
      union all
      select question.explanation
      from public.questions question join target_lessons target on target.id = question.lesson_id
      union all
      select concat_ws(' ', option.option_text, option.explanation)
      from public.question_options option join public.questions question on question.id = option.question_id
      join target_lessons target on target.id = question.lesson_id
      where option.is_correct
    )
    select 1 from artifacts
    where text ~* '(vnet (é|=) (uma )?subnet|subnet (é|=) (uma )?(availability zone|zona de disponibilidade)|peering (é|=) (uma )?vpn|peering usa (a )?internet pública|vpn gateway (é|=) expressroute|expressroute (é|=) (uma )?vpn mais rápida|azure dns exige (uma )?vm|private endpoint (é|=) (um )?public endpoint protegido|private endpoint (é|=) (uma )?vpn|private endpoint automaticamente desliga|private endpoint (é|=) (um )?service endpoint)'
  ) then
    raise exception 'A prohibited Networking misconception remains';
  end if;

  if exists (
    with practice as (
      select concat_ws(' ', card.back_text, card.hint) as text
      from public.flashcards card join target_lessons target on target.id = card.lesson_id
      union all
      select concat_ws(' ', question.question_text, question.explanation)
      from public.questions question join target_lessons target on target.id = question.lesson_id
      union all
      select concat_ws(' ', option.option_text, option.explanation)
      from public.question_options option join public.questions question on question.id = option.question_id
      join target_lessons target on target.id = question.lesson_id
      where option.is_correct
    )
    select 1 from practice
    where text ~* '(expressroute direct|fastpath|private dns resolver|quantos hosts|calcule.{0,10}hosts|configur(e|ação detalhada).{0,30}(bgp|vpn)|route table|\budr\b|azure firewall|application gateway|nat gateway|azure bastion)'
  ) then
    raise exception 'Networking practice requires content beyond AZ-900 scope';
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

  if exists (
    select 1
    from pg_class relation join pg_namespace namespace on namespace.oid = relation.relnamespace
    where namespace.nspname = 'public'
      and relation.relname in ('lessons', 'lesson_content_blocks', 'visual_experiences', 'flashcards', 'questions', 'question_options', 'user_lesson_progress', 'quiz_attempts', 'quiz_attempt_questions', 'quiz_answers', 'flashcard_reviews', 'user_flashcard_progress')
      and not relation.relrowsecurity
  ) then
    raise exception 'A required curriculum or study table has RLS disabled';
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
    raise exception 'Networking curriculum grants are invalid';
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
  ('58000000-0000-4000-8000-000000000017'::uuid, 'networking-closure-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000018'::uuid, 'networking-closure-b@example.invalid'),
  ('58000000-0000-4000-8000-000000000019'::uuid, 'networking-closure-c@example.invalid')
) seeded(id, email);

grant select on target_lessons to authenticated;
set local role authenticated;

do $$
declare
  seeded_user record;
  attempt public.quiz_attempts;
  first_attempt_id uuid;
begin
  for seeded_user in
    select id from (values
      ('58000000-0000-4000-8000-000000000017'::uuid),
      ('58000000-0000-4000-8000-000000000018'::uuid),
      ('58000000-0000-4000-8000-000000000019'::uuid)
    ) users(id)
  loop
    perform set_config('request.jwt.claim.sub', seeded_user.id::text, true);
    select * into strict attempt from public.start_topic_quiz('32000000-0000-4000-8000-000000000003');

    if attempt.total_questions <> 10
      or (select count(*) from public.quiz_attempt_questions where attempt_id = attempt.id) <> 10
      or (select count(distinct question.lesson_id) from public.quiz_attempt_questions item join public.questions question on question.id = item.question_id where item.attempt_id = attempt.id) <> 5
      or exists (
        select 1
        from public.quiz_attempt_questions item join public.questions question on question.id = item.question_id
        where item.attempt_id = attempt.id
        group by question.lesson_id
        having count(*) <> 2
      ) then
      raise exception 'Topic Quiz is not balanced across all five Networking Lessons';
    end if;

    if first_attempt_id is null then first_attempt_id := attempt.id; end if;
  end loop;

  perform set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000018', true);
  if exists (select 1 from public.quiz_attempts where id = first_attempt_id) then
    raise exception 'Quiz history leaked across users';
  end if;
end;
$$;

select set_config('request.jwt.claim.sub', '58000000-0000-4000-8000-000000000017', true);

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
    raise exception 'Networking Lesson progress flow failed';
  end if;

  select card.id into strict target_card_id
  from public.flashcards card join target_lessons target on target.id = card.lesson_id
  where card.is_published order by target.display_order, card.display_order limit 1;
  perform public.submit_flashcard_review(target_card_id, 'good');
  if not exists (select 1 from public.flashcard_reviews where flashcard_id = target_card_id)
    or not exists (select 1 from public.user_flashcard_progress where flashcard_id = target_card_id) then
    raise exception 'Networking spaced repetition failed';
  end if;
end;
$$;

reset role;

select json_build_object(
  'stage', '8.7.6',
  'topic', 'Azure Networking Services',
  'status', 'CLOSED',
  'lessons', 5,
  'estimated_minutes', 56,
  'content_blocks', 48,
  'visual_experiences', 3,
  'flashcards', 23,
  'questions', 30,
  'difficulty', json_build_object('easy', 11, 'medium', 13, 'hard', 6),
  'topic_quiz_lessons_per_attempt', 5,
  'covered', 8,
  'partial', 0,
  'missing', 0,
  'history_preserved', true
) as networking_services_closure_validation;

rollback;

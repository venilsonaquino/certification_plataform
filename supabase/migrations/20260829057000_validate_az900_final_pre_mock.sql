begin;

-- Snapshot e integridade curricular final. Esta migration somente valida dados
-- existentes; as tabelas temporarias sao descartadas ao final da transacao.
do $$
declare
  exact_question_duplicates integer;
  exact_flashcard_duplicates integer;
  semantic_candidate_count integer;
  answer_length_candidate_count integer;
  long_flashcard_count integer;
begin
  if (select count(*) from public.domains domain
      join public.certifications certification on certification.id=domain.certification_id
      where certification.code='az-900') <> 3
    or (select count(*) from public.topics topic
      join public.domains domain on domain.id=topic.domain_id
      join public.certifications certification on certification.id=domain.certification_id
      where certification.code='az-900') <> 12
    or (select count(*) from public.lessons lesson
      join public.topics topic on topic.id=lesson.topic_id
      join public.domains domain on domain.id=topic.domain_id
      join public.certifications certification on certification.id=domain.certification_id
      where certification.code='az-900' and lesson.is_published) <> 76
    or (select count(*) from public.lesson_content_blocks block
      join public.lessons lesson on lesson.id=block.lesson_id
      join public.topics topic on topic.id=lesson.topic_id
      join public.domains domain on domain.id=topic.domain_id
      join public.certifications certification on certification.id=domain.certification_id
      where certification.code='az-900' and block.is_published) <> 712
    or (select count(*) from public.visual_experiences visual
      join public.lessons lesson on lesson.id=visual.lesson_id
      join public.topics topic on topic.id=lesson.topic_id
      join public.domains domain on domain.id=topic.domain_id
      join public.certifications certification on certification.id=domain.certification_id
      where certification.code='az-900' and visual.is_published) <> 17
    or (select count(*) from public.flashcards card
      join public.lessons lesson on lesson.id=card.lesson_id
      join public.topics topic on topic.id=lesson.topic_id
      join public.domains domain on domain.id=topic.domain_id
      join public.certifications certification on certification.id=domain.certification_id
      where certification.code='az-900' and card.is_published) <> 397
    or (select count(*) from public.questions question
      join public.certifications certification on certification.id=question.certification_id
      where certification.code='az-900' and question.is_published) <> 512
    or (select sum(lesson.estimated_minutes) from public.lessons lesson
      join public.topics topic on topic.id=lesson.topic_id
      join public.domains domain on domain.id=topic.domain_id
      join public.certifications certification on certification.id=domain.certification_id
      where certification.code='az-900' and lesson.is_published) <> 818 then
    raise exception '10.4 global inventory differs from the approved snapshot';
  end if;

  if exists (
    select 1 from public.lessons lesson
    join public.topics topic on topic.id=lesson.topic_id
    join public.domains domain on domain.id=topic.domain_id
    join public.certifications certification on certification.id=domain.certification_id
    where certification.code='az-900' and lesson.is_published and (
      lesson.content is null or btrim(lesson.content)=''
      or lesson.estimated_minutes not between 1 and 60
      or (select count(*) from public.lesson_content_blocks block
          where block.lesson_id=lesson.id and block.is_published)=0
      or (select count(*) from public.lesson_content_blocks block
          where block.lesson_id=lesson.id and block.is_published and block.type='summary')<>1
      or (select min(block.display_order) from public.lesson_content_blocks block
          where block.lesson_id=lesson.id and block.is_published)<>1
      or (select max(block.display_order) from public.lesson_content_blocks block
          where block.lesson_id=lesson.id and block.is_published)
        <>(select count(*) from public.lesson_content_blocks block
          where block.lesson_id=lesson.id and block.is_published)
      or (select count(distinct block.display_order) from public.lesson_content_blocks block
          where block.lesson_id=lesson.id and block.is_published)
        <>(select count(*) from public.lesson_content_blocks block
          where block.lesson_id=lesson.id and block.is_published)
      or (select count(*) from public.flashcards card
          where card.lesson_id=lesson.id and card.is_published)=0
      or (select count(*) from public.questions question
          where question.lesson_id=lesson.id and question.is_published)<5
    )
  ) then raise exception '10.4 found an incomplete published Lesson'; end if;

  if exists (
    select 1 from (values
      ('40000000-0000-4000-8000-000000000002'::uuid,'high-availability','330001c4977b075dd3b22c4212b848d7'),
      ('8e04bfc9-03a6-4ae4-be9c-e7238e5c2783'::uuid,'scalability','6f97c7995a3e62a4f8a38bd1b6d359fd'),
      ('a7bb4f85-9cc1-46ad-9f65-44f978abf851'::uuid,'elasticity','4ce2f536de95c78ac94a4a8a6dc04f9d'),
      ('b74f3c89-867f-409e-b5b2-8ad1713c1428'::uuid,'reliability','5204f82535bd4cfdc226a6a13fb11141'),
      ('e709cd4e-c17a-469e-b7a8-70271c79e52e'::uuid,'predictability','fb2d31f34d685052b58480c3e4dace12')
    ) expected(id,slug,fallback_md5)
    left join public.lessons lesson on lesson.id=expected.id
    where lesson.id is null or lesson.slug<>expected.slug or md5(lesson.content)<>expected.fallback_md5
      or not lesson.is_published
      or (select count(*) from public.lesson_content_blocks block
          where block.lesson_id=lesson.id and block.is_published)<>7
      or (select count(*) from public.lesson_content_blocks block
          where block.lesson_id=lesson.id and block.is_published and block.type='summary')<>1
      or (select count(*) from public.flashcards card
          where card.lesson_id=lesson.id and card.is_published)<>4
      or (select count(*) from public.questions question
          where question.lesson_id=lesson.id and question.is_published)<>10
  ) then raise exception '10.4 one of the five restored Benefits Lessons regressed'; end if;

  if not exists (select 1 from public.lesson_content_blocks block
      where block.lesson_id='40000000-0000-4000-8000-000000000002'
        and lower(coalesce(block.content,'') || ' ' || coalesce(block.config::text,''))
          like '%high availability%reliability%')
    or not exists (select 1 from public.lesson_content_blocks block
      where block.lesson_id in (
        '8e04bfc9-03a6-4ae4-be9c-e7238e5c2783','a7bb4f85-9cc1-46ad-9f65-44f978abf851')
        and lower(coalesce(block.content,'') || ' ' || coalesce(block.config::text,''))
          like '%scalability%elasticity%')
    or not exists (select 1 from public.lesson_content_blocks block
      where block.lesson_id='e709cd4e-c17a-469e-b7a8-70271c79e52e'
        and lower(coalesce(block.content,'') || ' ' || coalesce(block.config::text,''))
          like '%preço fixo%') then
    raise exception '10.4 restored Benefits conceptual distinctions regressed';
  end if;

  if exists (
    select 1 from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id=block.lesson_id
    join public.topics topic on topic.id=lesson.topic_id
    join public.domains domain on domain.id=topic.domain_id
    join public.certifications certification on certification.id=domain.certification_id
    where certification.code='az-900' and block.is_published and (
      block.type not in ('explanation','important','example','dotnet_example','exam_tip','exam_trap',
        'summary','image','video','visual_experience','azure_lab')
      or block.display_order<1
      or block.config is not null and jsonb_typeof(block.config)<>'object'
      or block.type in ('explanation','important','example','dotnet_example','exam_tip','exam_trap')
        and (block.content is null or btrim(block.content)='')
      or block.type='summary' and block.content is null
        and (jsonb_typeof(block.config->'items')<>'array' or jsonb_array_length(block.config->'items')=0)
      or block.type='image' and (
        jsonb_typeof(block.config)<>'object' or coalesce(block.config->>'url','') !~ '^https?://'
        or btrim(coalesce(block.config->>'alt',''))='')
      or block.type='video' and (
        jsonb_typeof(block.config)<>'object' or coalesce(block.config->>'url','') !~ '^https?://'
        or block.config->>'provider'<>'youtube' or btrim(coalesce(block.config->>'title',''))='')
      or block.type='azure_lab' and (
        jsonb_typeof(block.config)<>'object' or btrim(coalesce(block.config->>'objective',''))=''
        or jsonb_typeof(block.config->'steps')<>'array' or jsonb_array_length(block.config->'steps')=0)
      or block.type='visual_experience' and (
        block.visual_experience_id is null or block.content is not null or block.config is not null)
    )
  ) then raise exception '10.4 found an invalid or unsupported Content Block'; end if;

  if exists (
    select 1 from public.visual_experiences visual
    join public.lessons lesson on lesson.id=visual.lesson_id
    join public.topics topic on topic.id=lesson.topic_id
    join public.domains domain on domain.id=topic.domain_id
    join public.certifications certification on certification.id=domain.certification_id
    where certification.code='az-900' and visual.is_published and (
      visual.type not in ('comparison','architecture','flow','responsibility')
      or jsonb_typeof(visual.config)<>'object'
      or btrim(visual.title)='' or btrim(visual.description)=''
      or visual.type='comparison' and (
        jsonb_typeof(visual.config->'columns')<>'array' or jsonb_array_length(visual.config->'columns')<2
        or jsonb_typeof(visual.config->'rows')<>'array' or jsonb_array_length(visual.config->'rows')<1)
      or visual.type='architecture' and (
        jsonb_typeof(visual.config->'nodes')<>'array' or jsonb_array_length(visual.config->'nodes')<1
        or jsonb_typeof(visual.config->'edges')<>'array')
      or visual.type='flow' and (
        jsonb_typeof(visual.config->'steps')<>'array' or jsonb_array_length(visual.config->'steps')<2)
      or visual.type='responsibility' and (
        jsonb_typeof(visual.config->'owners')<>'object'
        or jsonb_typeof(visual.config->'layers')<>'array' or jsonb_array_length(visual.config->'layers')<1
        or jsonb_typeof(visual.config->'models')<>'array' or jsonb_array_length(visual.config->'models')<1)
      or (select count(*) from public.lesson_content_blocks block
          where block.visual_experience_id=visual.id and block.lesson_id=visual.lesson_id
            and block.type='visual_experience' and block.is_published)<>1
    )
  ) then raise exception '10.4 found an invalid, unrenderable or unlinked Visual Experience'; end if;

  if exists (
    select 1 from public.questions question
    join public.certifications certification on certification.id=question.certification_id
    left join public.question_options option on option.question_id=question.id
    where certification.code='az-900' and question.is_published
    group by question.id
    having question.question_type<>'single_choice'
      or btrim(question.question_text)='' or length(btrim(question.question_text))<15
      or btrim(question.explanation)='' or length(btrim(question.explanation))<20
      or question.difficulty not in ('easy','medium','hard')
      or count(option.id)<>4
      or count(option.id) filter(where option.is_correct)<>1
      or count(distinct lower(btrim(option.option_text)))<>4
      or count(option.id) filter(where btrim(option.option_text)='')>0
  ) then raise exception '10.4 found an invalid Question, explanation or option set'; end if;

  select count(*) into exact_question_duplicates from (
    select lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g')) normalized
    from public.questions question
    join public.certifications certification on certification.id=question.certification_id
    where certification.code='az-900' and question.is_published
    group by normalized having count(*)>1
  ) duplicate_group;
  if exact_question_duplicates<>0 then raise exception '10.4 found exact normalized Question duplicates'; end if;

  select count(*) into exact_flashcard_duplicates from (
    select lower(regexp_replace(btrim(card.front_text),'[^[:alnum:]]+',' ','g')) normalized
    from public.flashcards card
    join public.lessons lesson on lesson.id=card.lesson_id
    join public.topics topic on topic.id=lesson.topic_id
    join public.domains domain on domain.id=topic.domain_id
    join public.certifications certification on certification.id=domain.certification_id
    where certification.code='az-900' and card.is_published
    group by normalized having count(*)>1
  ) duplicate_group;
  if exact_flashcard_duplicates<>0 then raise exception '10.4 found exact normalized Flashcard duplicates'; end if;

  if exists (
    select 1 from public.flashcards card
    join public.lessons lesson on lesson.id=card.lesson_id
    join public.topics topic on topic.id=lesson.topic_id
    join public.domains domain on domain.id=topic.domain_id
    join public.certifications certification on certification.id=domain.certification_id
    where certification.code='az-900' and card.is_published
      and (btrim(card.front_text)='' or btrim(card.back_text)='')
  ) then raise exception '10.4 found an empty or orphan-prone Flashcard'; end if;

  if exists (select 1 from public.questions question
      join public.lessons lesson on lesson.id=question.lesson_id
      join public.topics topic on topic.id=lesson.topic_id
      join public.domains domain on domain.id=topic.domain_id
      where question.topic_id<>topic.id or question.domain_id<>domain.id)
    or exists (select 1 from public.lesson_content_blocks block
      left join public.lessons lesson on lesson.id=block.lesson_id where lesson.id is null)
    or exists (select 1 from public.visual_experiences visual
      left join public.lessons lesson on lesson.id=visual.lesson_id where lesson.id is null)
    or exists (select 1 from public.flashcards card
      left join public.lessons lesson on lesson.id=card.lesson_id where lesson.id is null)
    or exists (select 1 from public.user_lesson_progress progress
      left join public.lessons lesson on lesson.id=progress.lesson_id where lesson.id is null)
    or exists (select 1 from public.quiz_attempts attempt
      left join auth.users user_record on user_record.id=attempt.user_id where user_record.id is null)
    or exists (select 1 from public.quiz_attempt_questions item
      left join public.quiz_attempts attempt on attempt.id=item.attempt_id
      left join public.questions question on question.id=item.question_id
      where attempt.id is null or question.id is null)
    or exists (select 1 from public.quiz_answers answer
      left join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      left join public.questions question on question.id=answer.question_id
      left join public.question_options option on option.id=answer.selected_option_id
      where attempt.id is null or question.id is null or option.id is null
        or option.question_id<>answer.question_id)
    or exists (select 1 from public.flashcard_reviews review
      left join public.flashcards card on card.id=review.flashcard_id where card.id is null)
    or exists (select 1 from public.user_flashcard_progress progress
      left join public.flashcards card on card.id=progress.flashcard_id where card.id is null) then
    raise exception '10.4 found an inconsistent hierarchy or orphan reference';
  end if;

  if exists (
    select 1 from public.questions question
    join public.topics topic on topic.id=question.topic_id
    join public.domains domain on domain.id=topic.domain_id
    join public.certifications certification on certification.id=domain.certification_id
    where certification.code='az-900' and question.is_published
    group by topic.id
    having count(*) filter(where question.difficulty='easy')=0
      or count(*) filter(where question.difficulty='medium')=0
      or count(*) filter(where question.difficulty='hard')=0
      or count(*) filter(where question.difficulty='easy')::numeric/count(*)>0.60
      or count(*) filter(where question.difficulty='hard')::numeric/count(*)>0.40
  ) then raise exception '10.4 found a blocking Topic difficulty imbalance'; end if;

  if exists (select 1 from pg_class relation
      join pg_namespace namespace on namespace.oid=relation.relnamespace
      where namespace.nspname='public' and relation.relname in (
        'domains','topics','lessons','lesson_content_blocks','visual_experiences','flashcards',
        'questions','question_options','user_lesson_progress','quiz_attempts','quiz_attempt_questions',
        'quiz_answers','flashcard_reviews','user_flashcard_progress') and not relation.relrowsecurity) then
    raise exception '10.4 requires RLS on every audited table';
  end if;

  if has_table_privilege('authenticated','public.lessons','UPDATE')
    or has_table_privilege('authenticated','public.lesson_content_blocks','UPDATE')
    or has_table_privilege('authenticated','public.visual_experiences','UPDATE')
    or has_table_privilege('authenticated','public.flashcards','UPDATE')
    or has_table_privilege('authenticated','public.questions','SELECT')
    or has_table_privilege('authenticated','public.question_options','SELECT') then
    raise exception '10.4 authenticated curriculum grants are unsafe';
  end if;

  -- Heuristicas de polish: geram inventario para revisao, mas nao confundem
  -- proximidade textual ou tamanho com erro tecnico automaticamente.
  with normalized as (
    select question.id,question.lesson_id,
      lower(regexp_replace(btrim(question.question_text),'[^[:alnum:]]+',' ','g')) text
    from public.questions question
    join public.certifications certification on certification.id=question.certification_id
    where certification.code='az-900' and question.is_published
  )
  select count(*) into semantic_candidate_count
  from normalized first_question join normalized second_question
    on first_question.id<second_question.id and first_question.lesson_id=second_question.lesson_id
   and least(length(first_question.text),length(second_question.text))>=40
   and greatest(length(first_question.text),length(second_question.text))::numeric
      /least(length(first_question.text),length(second_question.text))<=1.55
   and (first_question.text like '%'||second_question.text||'%'
     or second_question.text like '%'||first_question.text||'%');

  with option_lengths as (
    select question.id,
      max(length(option.option_text)) filter(where option.is_correct) correct_length,
      max(length(option.option_text)) filter(where not option.is_correct) longest_distractor
    from public.questions question
    join public.question_options option on option.question_id=question.id
    join public.certifications certification on certification.id=question.certification_id
    where certification.code='az-900' and question.is_published group by question.id
  )
  select count(*) into answer_length_candidate_count from option_lengths
  where correct_length>=greatest(50,longest_distractor*2.5);

  select count(*) into long_flashcard_count
  from public.flashcards card
  join public.lessons lesson on lesson.id=card.lesson_id
  join public.topics topic on topic.id=lesson.topic_id
  join public.domains domain on domain.id=topic.domain_id
  join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900' and card.is_published and length(card.back_text)>500;

  raise notice '10.4 quality heuristics: semantic containment candidates=%, answer-length candidates=%, flashcard backs over 500 chars=%',
    semantic_candidate_count,answer_length_candidate_count,long_flashcard_count;
end;
$$;

-- Dois mocks conceituais de 40 itens, estratificados e sem persistencia.
create temporary table audit_104_mock_quota(
  domain_order integer,
  difficulty text,
  quota integer,
  primary key(domain_order,difficulty)
) on commit drop;

insert into audit_104_mock_quota values
  (1,'easy',4),(1,'medium',5),(1,'hard',2),
  (2,'easy',5),(2,'medium',7),(2,'hard',3),
  (3,'easy',5),(3,'medium',6),(3,'hard',3);

create temporary table audit_104_mock_candidates on commit drop as
with candidates as (
  select question.id question_id,domain.display_order domain_order,
    topic.id topic_id,topic.display_order topic_order,lesson.display_order lesson_order,
    question.difficulty,
    row_number() over(partition by domain.id,question.difficulty,topic.id
      order by lesson.display_order,question.display_order,question.id) within_topic_rank
  from public.questions question
  join public.lessons lesson on lesson.id=question.lesson_id and lesson.is_published
  join public.topics topic on topic.id=lesson.topic_id
  join public.domains domain on domain.id=topic.domain_id
  join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900' and question.is_published
    and question.question_type='single_choice'
)
select candidates.*,
  row_number() over(partition by domain_order,difficulty
    order by within_topic_rank,topic_order,lesson_order,question_id) domain_difficulty_rank
from candidates;

create temporary table audit_104_mock_items on commit drop as
select 1 mock_no,candidate.* from audit_104_mock_candidates candidate
join audit_104_mock_quota quota using(domain_order,difficulty)
where candidate.domain_difficulty_rank<=quota.quota
union all
select 2 mock_no,candidate.* from audit_104_mock_candidates candidate
join audit_104_mock_quota quota using(domain_order,difficulty)
where candidate.domain_difficulty_rank between quota.quota+1 and quota.quota*2;

do $$
begin
  if exists (select mock_no from audit_104_mock_items group by mock_no having count(*)<>40)
    or (select count(distinct mock_no) from audit_104_mock_items)<>2
    or exists (select 1 from audit_104_mock_items first_mock
      join audit_104_mock_items second_mock on second_mock.mock_no=2
        and second_mock.question_id=first_mock.question_id where first_mock.mock_no=1)
    or exists (select mock_no from audit_104_mock_items group by mock_no
      having count(distinct topic_id)<>12)
    or exists (
      select mock_no,domain_order from audit_104_mock_items
      group by mock_no,domain_order
      having count(*)<>case domain_order when 1 then 11 when 2 then 15 when 3 then 14 end
    )
    or exists (
      select item.mock_no,item.domain_order,item.difficulty
      from audit_104_mock_items item
      join audit_104_mock_quota quota using(domain_order,difficulty)
      group by item.mock_no,item.domain_order,item.difficulty,quota.quota
      having count(*)<>quota.quota
    ) then
    raise exception '10.4 the current pool cannot sustain two balanced 40-question mock selections';
  end if;
end;
$$;

commit;

-- Fluxos reais com fixtures transacionais. Nada abaixo persiste.
begin;

create temporary table audit_104_lessons on commit drop as
select lesson.id,lesson.slug,topic.id topic_id,topic.display_order topic_order,
  domain.display_order domain_order
from public.lessons lesson
join public.topics topic on topic.id=lesson.topic_id
join public.domains domain on domain.id=topic.domain_id
join public.certifications certification on certification.id=domain.certification_id
where certification.code='az-900' and lesson.is_published;

create temporary table audit_104_topics on commit drop as
select topic.id,topic.title,domain.display_order domain_order,topic.display_order,
  count(distinct lesson.id)::integer lesson_count,
  count(distinct question.id)::integer pool_size,
  count(distinct question.id) filter(where question.difficulty='easy')::integer easy_pool,
  count(distinct question.id) filter(where question.difficulty='medium')::integer medium_pool,
  count(distinct question.id) filter(where question.difficulty='hard')::integer hard_pool,
  certification.id certification_id
from public.topics topic
join public.domains domain on domain.id=topic.domain_id
join public.certifications certification on certification.id=domain.certification_id
join public.lessons lesson on lesson.topic_id=topic.id and lesson.is_published
join public.questions question on question.lesson_id=lesson.id and question.topic_id=topic.id
  and question.is_published and question.question_type='single_choice'
where certification.code='az-900'
group by topic.id,topic.title,domain.display_order,topic.display_order,certification.id;

create temporary table audit_104_answer_key(
  question_id uuid primary key,
  correct_option_id uuid not null,
  incorrect_option_id uuid not null
) on commit drop;

insert into audit_104_answer_key
select question.id,
  (array_agg(option.id order by option.display_order) filter(where option.is_correct))[1],
  (array_agg(option.id order by option.display_order) filter(where not option.is_correct))[1]
from public.questions question
join public.question_options option on option.question_id=question.id
join public.certifications certification on certification.id=question.certification_id
where certification.code='az-900' and question.is_published group by question.id;

create temporary table audit_104_topic_items(
  topic_id uuid not null,
  attempt_no integer not null,
  question_id uuid not null,
  lesson_id uuid not null,
  difficulty text not null,
  primary key(topic_id,attempt_no,question_id)
) on commit drop;

insert into auth.users(instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select '00000000-0000-0000-0000-000000000000',seed.id,'authenticated','authenticated',
  seed.email,'',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}',now(),now()
from(values
  ('58000000-0000-4000-8000-000000000060'::uuid,'pre-mock-a@example.invalid'),
  ('58000000-0000-4000-8000-000000000061'::uuid,'pre-mock-b@example.invalid')) seed(id,email);

grant select on audit_104_lessons,audit_104_topics,audit_104_answer_key to authenticated;
grant select,insert on audit_104_topic_items to authenticated;
grant update on public.user_flashcard_progress to authenticated;

set local role authenticated;
select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000060',true);

do $$
declare
  lesson_row record;
  topic_row record;
  item_row record;
  lesson_attempt public.quiz_attempts;
  topic_attempt public.quiz_attempts;
  review_attempt public.quiz_attempts;
  completed_progress public.user_lesson_progress;
  first_lesson uuid;
  first_card uuid;
  certification_uuid uuid;
  attempt_number integer;
begin
  select id into strict first_lesson from audit_104_lessons
    order by domain_order,topic_order,slug limit 1;
  select certification_id into strict certification_uuid from audit_104_topics limit 1;

  for lesson_row in select * from audit_104_lessons order by domain_order,topic_order,slug loop
    select * into strict lesson_attempt from public.start_lesson_quiz(lesson_row.id);
    if lesson_attempt.total_questions<>5
      or (select count(*) from public.quiz_attempt_questions item
          where item.attempt_id=lesson_attempt.id)<>5
      or exists (select 1 from public.quiz_attempt_questions item
          join public.questions question on question.id=item.question_id
          where item.attempt_id=lesson_attempt.id and question.lesson_id<>lesson_row.id) then
      raise exception '10.4 Lesson Quiz selection failed for %',lesson_row.slug;
    end if;

    for item_row in
      select item.question_id,key.correct_option_id,key.incorrect_option_id
      from public.quiz_attempt_questions item
      join audit_104_answer_key key on key.question_id=item.question_id
      where item.attempt_id=lesson_attempt.id order by item.display_order
    loop
      perform * from public.submit_quiz_answer(
        lesson_attempt.id,item_row.question_id,
        case when lesson_row.id=first_lesson then item_row.incorrect_option_id
          else item_row.correct_option_id end);
    end loop;

    if (select status from public.quiz_attempts where id=lesson_attempt.id)<>'completed'
      or (select count(*) from public.quiz_answers where attempt_id=lesson_attempt.id)<>5
      or (select score_percentage from public.quiz_attempts where id=lesson_attempt.id)
        <>(case when lesson_row.id=first_lesson then 0 else 100 end) then
      raise exception '10.4 Lesson Quiz persistence/score failed for %',lesson_row.slug;
    end if;

    select * into strict completed_progress from public.complete_lesson_progress(lesson_row.id);
    if completed_progress.status<>'completed' or completed_progress.completed_at is null then
      raise exception '10.4 Lesson progress failed for %',lesson_row.slug;
    end if;
  end loop;

  for topic_row in select * from audit_104_topics order by domain_order,display_order loop
    for attempt_number in 1..2 loop
      select * into strict topic_attempt from public.start_topic_quiz(topic_row.id);
      if topic_attempt.total_questions<>10
        or (select count(*) from public.quiz_attempt_questions item
            where item.attempt_id=topic_attempt.id)<>10 then
        raise exception '10.4 Topic Quiz selection failed for % attempt %',topic_row.title,attempt_number;
      end if;

      insert into audit_104_topic_items
      select topic_row.id,attempt_number,question.id,question.lesson_id,question.difficulty
      from public.quiz_attempt_questions item
      join public.questions question on question.id=item.question_id
      where item.attempt_id=topic_attempt.id;

      for item_row in
        select item.question_id,key.correct_option_id
        from public.quiz_attempt_questions item
        join audit_104_answer_key key on key.question_id=item.question_id
        where item.attempt_id=topic_attempt.id order by item.display_order
      loop
        perform * from public.submit_quiz_answer(
          topic_attempt.id,item_row.question_id,item_row.correct_option_id);
      end loop;

      if (select status from public.quiz_attempts where id=topic_attempt.id)<>'completed'
        or (select count(*) from public.quiz_answers where attempt_id=topic_attempt.id)<>10
        or (select score_percentage from public.quiz_attempts where id=topic_attempt.id)<>100 then
        raise exception '10.4 Topic Quiz persistence/score failed for % attempt %',topic_row.title,attempt_number;
      end if;
    end loop;
  end loop;

  if exists (
    select 1 from audit_104_topics topic
    where (select count(*) from audit_104_topic_items first_item
      join audit_104_topic_items second_item on second_item.topic_id=first_item.topic_id
        and second_item.attempt_no=2 and second_item.question_id=first_item.question_id
      where first_item.topic_id=topic.id and first_item.attempt_no=1)
      <>greatest(0,6-topic.easy_pool)+greatest(0,10-topic.medium_pool)+greatest(0,4-topic.hard_pool)
  ) then raise exception '10.4 Topic Quiz retake overlap is not minimal'; end if;

  if exists (
    select topic.id,attempt_number.value from audit_104_topics topic
    cross join(values(1),(2)) attempt_number(value)
    where (select count(distinct item.lesson_id) from audit_104_topic_items item
      where item.topic_id=topic.id and item.attempt_no=attempt_number.value)<>least(topic.lesson_count,10)
  ) or exists (
    select topic_id,attempt_no from audit_104_topic_items group by topic_id,attempt_no
    having count(*) filter(where difficulty='easy')<>3
      or count(*) filter(where difficulty='medium')<>5
      or count(*) filter(where difficulty='hard')<>2
  ) or exists (
    select 1 from (
      select topic_id,attempt_no,max(amount)-min(amount) spread from (
        select topic_id,attempt_no,lesson_id,count(*) amount from audit_104_topic_items
        group by topic_id,attempt_no,lesson_id
      ) distribution group by topic_id,attempt_no
    ) balance where spread>1
  ) then raise exception '10.4 Topic Quiz Lesson/difficulty balance regressed'; end if;

  select * into strict review_attempt from public.start_review_quiz(certification_uuid);
  if review_attempt.quiz_type<>'review' or review_attempt.total_questions not between 5 and 10
    or (select count(*) from public.quiz_attempt_questions item
        where item.attempt_id=review_attempt.id)<>review_attempt.total_questions then
    raise exception '10.4 Review selection failed';
  end if;
  for item_row in
    select item.question_id,key.correct_option_id from public.quiz_attempt_questions item
    join audit_104_answer_key key on key.question_id=item.question_id
    where item.attempt_id=review_attempt.id order by item.display_order
  loop
    perform * from public.submit_quiz_answer(
      review_attempt.id,item_row.question_id,item_row.correct_option_id);
  end loop;
  if (select status from public.quiz_attempts where id=review_attempt.id)<>'completed'
    or (select score_percentage from public.quiz_attempts where id=review_attempt.id)<>100 then
    raise exception '10.4 Review persistence/score failed';
  end if;

  select card.id into strict first_card from public.flashcards card
  join audit_104_lessons lesson on lesson.id=card.lesson_id
  where card.is_published
  order by lesson.domain_order,lesson.topic_order,card.display_order limit 1;
  perform public.submit_flashcard_review(first_card,'again');
  if not exists(select 1 from public.flashcard_reviews review where review.flashcard_id=first_card)
    or not exists(select 1 from public.user_flashcard_progress progress
      where progress.flashcard_id=first_card and progress.review_count=1
        and progress.interval_days=1 and progress.last_rating='again')
    or (select available_flashcard_count from public.get_flashcard_review_overview(certification_uuid))<>397 then
    raise exception '10.4 Spaced Repetition persistence failed';
  end if;
end;
$$;

update public.user_flashcard_progress
set next_review_at=clock_timestamp()-interval '1 minute'
where user_id='58000000-0000-4000-8000-000000000060';

do $$
declare
  certification_uuid uuid;
begin
  select certification_id into strict certification_uuid from audit_104_topics limit 1;
  if not exists(select 1 from public.get_flashcard_study_queue(certification_uuid,20,5)
      where review_status='due') then
    raise exception '10.4 due Flashcard queue failed';
  end if;
end;
$$;

select set_config('request.jwt.claim.sub','58000000-0000-4000-8000-000000000061',true);

do $$
begin
  if exists(select 1 from public.quiz_attempts
      where user_id='58000000-0000-4000-8000-000000000060')
    or exists(select 1 from public.quiz_attempt_questions item
      join public.quiz_attempts attempt on attempt.id=item.attempt_id
      where attempt.user_id='58000000-0000-4000-8000-000000000060')
    or exists(select 1 from public.quiz_answers answer
      join public.quiz_attempts attempt on attempt.id=answer.attempt_id
      where attempt.user_id='58000000-0000-4000-8000-000000000060')
    or exists(select 1 from public.user_lesson_progress
      where user_id='58000000-0000-4000-8000-000000000060')
    or exists(select 1 from public.flashcard_reviews
      where user_id='58000000-0000-4000-8000-000000000060')
    or exists(select 1 from public.user_flashcard_progress
      where user_id='58000000-0000-4000-8000-000000000060') then
    raise exception '10.4 RLS leaked user A study data to user B';
  end if;
end;
$$;

rollback;

begin;

revoke all on table public.questions from authenticated;
grant select (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, is_published, display_order, created_at, updated_at
) on table public.questions to authenticated;

revoke all on table public.question_options from authenticated;
grant select (id, question_id, option_text, display_order)
  on table public.question_options to authenticated;

create view public.question_options_public
with (security_invoker = true)
as
select id, question_id, option_text, display_order
from public.question_options;

revoke all on table public.question_options_public from public, anon, authenticated;
grant select on table public.question_options_public to authenticated;

alter table public.question_options
  add constraint question_options_id_question_unique unique (id, question_id);

create table public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  certification_id uuid not null references public.certifications(id) on delete cascade,
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  status text not null default 'in_progress',
  total_questions integer not null,
  correct_answers integer not null default 0,
  score_percentage numeric(5,2) not null default 0,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint quiz_attempts_status_check check (status in ('in_progress', 'completed')),
  constraint quiz_attempts_total_questions_check check (total_questions between 1 and 5),
  constraint quiz_attempts_correct_answers_check
    check (correct_answers between 0 and total_questions),
  constraint quiz_attempts_score_check check (score_percentage between 0 and 100),
  constraint quiz_attempts_completion_check check (
    (status = 'in_progress' and completed_at is null)
    or (status = 'completed' and completed_at is not null)
  )
);

create table public.quiz_attempt_questions (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.quiz_attempts(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete restrict,
  display_order integer not null,
  created_at timestamptz not null default now(),
  constraint quiz_attempt_questions_attempt_question_unique unique (attempt_id, question_id),
  constraint quiz_attempt_questions_attempt_order_unique unique (attempt_id, display_order),
  constraint quiz_attempt_questions_display_order_check check (display_order > 0)
);

create table public.quiz_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null,
  question_id uuid not null,
  selected_option_id uuid not null,
  is_correct boolean not null,
  answered_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  constraint quiz_answers_attempt_question_unique unique (attempt_id, question_id),
  constraint quiz_answers_attempt_question_fkey
    foreign key (attempt_id, question_id)
    references public.quiz_attempt_questions (attempt_id, question_id)
    on delete cascade,
  constraint quiz_answers_option_question_fkey
    foreign key (selected_option_id, question_id)
    references public.question_options (id, question_id)
    on delete restrict
);

create unique index quiz_attempts_one_active_lesson_idx
  on public.quiz_attempts (user_id, lesson_id)
  where status = 'in_progress';

create index quiz_attempts_user_lesson_history_idx
  on public.quiz_attempts (user_id, lesson_id, created_at desc);

create index quiz_attempt_questions_question_idx
  on public.quiz_attempt_questions (question_id);

create index quiz_answers_question_idx
  on public.quiz_answers (question_id);

create trigger quiz_attempts_set_updated_at
before update on public.quiz_attempts
for each row execute function public.set_updated_at();

alter table public.quiz_attempts enable row level security;
alter table public.quiz_attempt_questions enable row level security;
alter table public.quiz_answers enable row level security;

create policy "Users can read their own quiz attempts"
on public.quiz_attempts for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can read questions from their own quiz attempts"
on public.quiz_attempt_questions for select
to authenticated
using (
  exists (
    select 1 from public.quiz_attempts attempt
    where attempt.id = quiz_attempt_questions.attempt_id
      and attempt.user_id = (select auth.uid())
  )
);

create policy "Users can read answers from their own quiz attempts"
on public.quiz_answers for select
to authenticated
using (
  exists (
    select 1 from public.quiz_attempts attempt
    where attempt.id = quiz_answers.attempt_id
      and attempt.user_id = (select auth.uid())
  )
);

revoke all on table public.quiz_attempts from anon, authenticated;
revoke all on table public.quiz_attempt_questions from anon, authenticated;
revoke all on table public.quiz_answers from anon, authenticated;
grant select on table public.quiz_attempts to authenticated;
grant select on table public.quiz_attempt_questions to authenticated;
grant select on table public.quiz_answers to authenticated;

create function public.start_lesson_quiz(p_lesson_id uuid)
returns setof public.quiz_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_certification_id uuid;
  v_total integer;
  v_attempt public.quiz_attempts;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  select attempt.* into v_attempt
  from public.quiz_attempts attempt
  where attempt.user_id = v_user_id
    and attempt.lesson_id = p_lesson_id
    and attempt.status = 'in_progress'
  order by attempt.started_at desc
  limit 1;

  if found then
    return next v_attempt;
    return;
  end if;

  select domain.certification_id into v_certification_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  where lesson.id = p_lesson_id
    and lesson.is_published = true;

  if v_certification_id is null then
    raise exception 'Published lesson not found.' using errcode = 'P0002';
  end if;

  select count(*) into v_total
  from (
    select question.id
    from public.questions question
    where question.lesson_id = p_lesson_id
      and question.is_published = true
      and question.question_type = 'single_choice'
    order by question.display_order, question.id
    limit 5
  ) selected;

  if v_total = 0 then
    raise exception 'No published questions are available for this lesson.' using errcode = 'P0002';
  end if;

  begin
    insert into public.quiz_attempts (
      user_id, certification_id, lesson_id, total_questions
    ) values (
      v_user_id, v_certification_id, p_lesson_id, v_total
    ) returning * into v_attempt;
  exception
    when unique_violation then
      select attempt.* into strict v_attempt
      from public.quiz_attempts attempt
      where attempt.user_id = v_user_id
        and attempt.lesson_id = p_lesson_id
        and attempt.status = 'in_progress';
      return next v_attempt;
      return;
  end;

  insert into public.quiz_attempt_questions (attempt_id, question_id, display_order)
  select
    v_attempt.id,
    selected.id,
    row_number() over (order by selected.display_order, selected.id)::integer
  from (
    select question.id, question.display_order
    from public.questions question
    where question.lesson_id = p_lesson_id
      and question.is_published = true
      and question.question_type = 'single_choice'
    order by question.display_order, question.id
    limit 5
  ) selected;

  return next v_attempt;
end;
$$;

create function public.submit_quiz_answer(
  p_attempt_id uuid,
  p_question_id uuid,
  p_selected_option_id uuid
)
returns table (
  is_correct boolean,
  correct_option_id uuid,
  question_explanation text,
  selected_option_explanation text,
  correct_option_explanation text,
  attempt_completed boolean,
  correct_answers integer,
  total_questions integer,
  score_percentage numeric
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt public.quiz_attempts;
  v_existing public.quiz_answers;
  v_is_correct boolean;
  v_correct_option_id uuid;
  v_question_explanation text;
  v_selected_explanation text;
  v_correct_explanation text;
  v_answered_count integer;
  v_correct_count integer;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  select attempt.* into v_attempt
  from public.quiz_attempts attempt
  where attempt.id = p_attempt_id
    and attempt.user_id = v_user_id
  for update;

  if not found then
    raise exception 'Quiz attempt not found.' using errcode = '42501';
  end if;

  select answer.* into v_existing
  from public.quiz_answers answer
  where answer.attempt_id = p_attempt_id
    and answer.question_id = p_question_id;

  if found and v_existing.selected_option_id <> p_selected_option_id then
    raise exception 'This question has already been answered.' using errcode = '23505';
  end if;

  if not found and v_attempt.status <> 'in_progress' then
    raise exception 'The quiz attempt is already completed.' using errcode = '55000';
  end if;

  if not exists (
    select 1 from public.quiz_attempt_questions attempt_question
    where attempt_question.attempt_id = p_attempt_id
      and attempt_question.question_id = p_question_id
  ) then
    raise exception 'Question does not belong to this attempt.' using errcode = '23503';
  end if;

  select option.is_correct, option.explanation
  into v_is_correct, v_selected_explanation
  from public.question_options option
  where option.id = p_selected_option_id
    and option.question_id = p_question_id;

  if not found then
    raise exception 'Selected option does not belong to the question.' using errcode = '23503';
  end if;

  select option.id, option.explanation
  into v_correct_option_id, v_correct_explanation
  from public.question_options option
  where option.question_id = p_question_id
    and option.is_correct = true;

  select question.explanation into v_question_explanation
  from public.questions question
  where question.id = p_question_id;

  if v_existing.id is null then
    insert into public.quiz_answers (
      attempt_id, question_id, selected_option_id, is_correct
    ) values (
      p_attempt_id, p_question_id, p_selected_option_id, v_is_correct
    );
  else
    v_is_correct := v_existing.is_correct;
  end if;

  select count(*), count(*) filter (where answer.is_correct)
  into v_answered_count, v_correct_count
  from public.quiz_answers answer
  where answer.attempt_id = p_attempt_id;

  if v_answered_count = v_attempt.total_questions and v_attempt.status = 'in_progress' then
    update public.quiz_attempts
    set
      status = 'completed',
      correct_answers = v_correct_count,
      score_percentage = round((v_correct_count::numeric / v_attempt.total_questions::numeric) * 100, 2),
      completed_at = clock_timestamp()
    where id = p_attempt_id
    returning * into v_attempt;
  else
    select attempt.* into v_attempt
    from public.quiz_attempts attempt
    where attempt.id = p_attempt_id;
  end if;

  return query select
    v_is_correct,
    v_correct_option_id,
    v_question_explanation,
    v_selected_explanation,
    v_correct_explanation,
    v_attempt.status = 'completed',
    v_attempt.correct_answers,
    v_attempt.total_questions,
    v_attempt.score_percentage;
end;
$$;

create function public.get_quiz_answer_review(p_attempt_id uuid)
returns table (
  question_id uuid,
  selected_option_id uuid,
  selected_option_text text,
  is_correct boolean,
  correct_option_id uuid,
  correct_option_text text,
  question_explanation text,
  selected_option_explanation text,
  correct_option_explanation text
)
language sql
security definer
set search_path = ''
stable
as $$
  select
    answer.question_id,
    answer.selected_option_id,
    selected_option.option_text,
    answer.is_correct,
    correct_option.id,
    correct_option.option_text,
    question.explanation,
    selected_option.explanation,
    correct_option.explanation
  from public.quiz_answers answer
  join public.quiz_attempts attempt on attempt.id = answer.attempt_id
  join public.questions question on question.id = answer.question_id
  join public.question_options selected_option on selected_option.id = answer.selected_option_id
  join public.question_options correct_option
    on correct_option.question_id = answer.question_id
    and correct_option.is_correct = true
  where answer.attempt_id = p_attempt_id
    and attempt.user_id = auth.uid()
  order by answer.answered_at;
$$;

revoke execute on function public.start_lesson_quiz(uuid) from public, anon;
revoke execute on function public.submit_quiz_answer(uuid, uuid, uuid) from public, anon;
revoke execute on function public.get_quiz_answer_review(uuid) from public, anon;
grant execute on function public.start_lesson_quiz(uuid) to authenticated;
grant execute on function public.submit_quiz_answer(uuid, uuid, uuid) to authenticated;
grant execute on function public.get_quiz_answer_review(uuid) to authenticated;

with lesson_context as (
  select
    certification.id as certification_id,
    domain.id as domain_id,
    topic.id as topic_id,
    lesson.id as lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900' and lesson.slug = 'availability-zones'
), seed (id, question_text, difficulty, explanation, display_order) as (
  values
    ('61000000-0000-4000-8000-000000000001'::uuid, 'Qual afirmação descreve corretamente uma zona de disponibilidade do Azure?', 'easy', 'Uma zona de disponibilidade é um local físico separado dentro de uma região compatível, com energia, rede e refrigeração independentes.', 2),
    ('61000000-0000-4000-8000-000000000002'::uuid, 'Uma carga de trabalho usa duas máquinas virtuais em zonas diferentes da mesma região. Qual risco essa arquitetura reduz principalmente?', 'medium', 'A separação zonal reduz o risco de uma falha localizada de datacenter ou infraestrutura afetar todas as instâncias simultaneamente.', 3),
    ('61000000-0000-4000-8000-000000000003'::uuid, 'Qual condição deve ser verificada antes de planejar uma arquitetura baseada em zonas de disponibilidade?', 'medium', 'A disponibilidade de zonas varia por região e por serviço. É necessário confirmar que a região e o serviço escolhidos oferecem suporte zonal.', 4),
    ('61000000-0000-4000-8000-000000000004'::uuid, 'Uma empresa distribui recursos entre zonas de disponibilidade. Qual afirmação sobre responsabilidade continua correta?', 'hard', 'A infraestrutura zonal aumenta a resiliência, mas o cliente ainda precisa configurar a distribuição, o balanceamento e a recuperação da aplicação adequadamente.', 5)
)
insert into public.questions (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select seed.id, context.certification_id, context.domain_id, context.topic_id,
  context.lesson_id, seed.question_text, 'single_choice', seed.difficulty,
  seed.explanation, true, seed.display_order
from seed cross join lesson_context context
on conflict (id) do update set
  question_text = excluded.question_text,
  difficulty = excluded.difficulty,
  explanation = excluded.explanation,
  is_published = excluded.is_published,
  display_order = excluded.display_order;

insert into public.question_options (id, question_id, option_text, is_correct, explanation, display_order)
values
  ('71000000-0000-4000-8000-000000000001', '61000000-0000-4000-8000-000000000001', 'Um local físico separado dentro de uma região compatível', true, 'Correta: zonas fornecem isolamento físico dentro da região.', 1),
  ('71000000-0000-4000-8000-000000000002', '61000000-0000-4000-8000-000000000001', 'Uma região geográfica independente', false, 'Uma zona pertence a uma região; não é outra região.', 2),
  ('71000000-0000-4000-8000-000000000003', '61000000-0000-4000-8000-000000000001', 'Um resource group dedicado', false, 'Resource group é organização lógica, não separação física.', 3),
  ('71000000-0000-4000-8000-000000000004', '61000000-0000-4000-8000-000000000001', 'Uma rede virtual global', false, 'Rede virtual e zona são conceitos diferentes.', 4),
  ('71000000-0000-4000-8000-000000000005', '61000000-0000-4000-8000-000000000002', 'Falha localizada de infraestrutura', true, 'Correta: as instâncias não compartilham toda a infraestrutura física zonal.', 1),
  ('71000000-0000-4000-8000-000000000006', '61000000-0000-4000-8000-000000000002', 'Comprometimento de credenciais', false, 'Separação física não corrige problemas de identidade.', 2),
  ('71000000-0000-4000-8000-000000000007', '61000000-0000-4000-8000-000000000002', 'Erro lógico da aplicação', false, 'O mesmo erro de software pode afetar instâncias em todas as zonas.', 3),
  ('71000000-0000-4000-8000-000000000008', '61000000-0000-4000-8000-000000000002', 'Exclusão acidental dos dados', false, 'Zonas não substituem controles de acesso e backup.', 4),
  ('71000000-0000-4000-8000-000000000009', '61000000-0000-4000-8000-000000000003', 'Se a região e o serviço suportam zonas', true, 'Correta: suporte zonal não é uniforme em todas as combinações.', 1),
  ('71000000-0000-4000-8000-000000000010', '61000000-0000-4000-8000-000000000003', 'Se todos os recursos estão no mesmo resource group', false, 'Resource groups não determinam suporte zonal.', 2),
  ('71000000-0000-4000-8000-000000000011', '61000000-0000-4000-8000-000000000003', 'Se a subscription possui apenas um usuário', false, 'Quantidade de usuários não define disponibilidade zonal.', 3),
  ('71000000-0000-4000-8000-000000000012', '61000000-0000-4000-8000-000000000003', 'Se a aplicação usa somente armazenamento local', false, 'Esse fator não confirma suporte do serviço e da região.', 4),
  ('71000000-0000-4000-8000-000000000013', '61000000-0000-4000-8000-000000000004', 'O cliente ainda deve configurar a aplicação para usar a resiliência zonal', true, 'Correta: disponibilidade depende também da arquitetura e configuração do cliente.', 1),
  ('71000000-0000-4000-8000-000000000014', '61000000-0000-4000-8000-000000000004', 'A Microsoft elimina todos os pontos de falha da aplicação', false, 'O provedor não corrige automaticamente pontos de falha no design da aplicação.', 2),
  ('71000000-0000-4000-8000-000000000015', '61000000-0000-4000-8000-000000000004', 'Backups deixam de ser necessários', false, 'Resiliência zonal não substitui backup e recuperação de dados.', 3),
  ('71000000-0000-4000-8000-000000000016', '61000000-0000-4000-8000-000000000004', 'O cliente deixa de administrar identidades e dados', false, 'Identidades e dados continuam sob responsabilidade do cliente.', 4)
on conflict (id) do update set
  option_text = excluded.option_text,
  is_correct = excluded.is_correct,
  explanation = excluded.explanation,
  display_order = excluded.display_order;

commit;

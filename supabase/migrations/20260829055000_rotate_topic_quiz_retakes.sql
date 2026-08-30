begin;

do $$
begin
  if to_regprocedure('public.start_topic_quiz(uuid)') is null then
    raise exception '10.3 requires the existing start_topic_quiz(uuid) RPC';
  end if;

  if to_regclass('public.quiz_attempts') is null
    or to_regclass('public.quiz_attempt_questions') is null
    or to_regclass('public.questions') is null then
    raise exception '10.3 requires the existing quiz history tables';
  end if;
end;
$$;

create or replace function public.start_topic_quiz(p_topic_id uuid)
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
  v_last_attempt_id uuid;
  v_selected_ids uuid[] := array[]::uuid[];
  v_question_id uuid;
  v_position integer;
  v_target_easy integer;
  v_target_medium integer;
  v_target_hard integer;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  select attempt.* into v_attempt
  from public.quiz_attempts attempt
  where attempt.user_id = v_user_id
    and attempt.quiz_type = 'topic'
    and attempt.topic_id = p_topic_id
    and attempt.status = 'in_progress'
  order by attempt.started_at desc, attempt.id desc
  limit 1;

  if found then
    return next v_attempt;
    return;
  end if;

  select domain.certification_id into v_certification_id
  from public.topics topic
  join public.domains domain on domain.id = topic.domain_id
  where topic.id = p_topic_id;

  if v_certification_id is null then
    raise exception 'Topic not found.' using errcode = 'P0002';
  end if;

  select least(count(*)::integer, 10) into v_total
  from public.questions question
  where question.topic_id = p_topic_id
    and question.is_published = true
    and question.question_type = 'single_choice';

  if v_total = 0 then
    raise exception 'No published questions are available for this topic.' using errcode = 'P0002';
  end if;

  -- O baseline pedagógico para 10 itens é 3 easy / 5 medium / 2 hard.
  -- Para pools menores, a proporção é reduzida sem impedir o quiz.
  v_target_hard := floor(v_total * 0.20)::integer;
  v_target_medium := floor(v_total * 0.50)::integer;
  v_target_easy := v_total - v_target_medium - v_target_hard;

  select attempt.id into v_last_attempt_id
  from public.quiz_attempts attempt
  where attempt.user_id = v_user_id
    and attempt.quiz_type = 'topic'
    and attempt.topic_id = p_topic_id
    and attempt.status = 'completed'
  order by attempt.completed_at desc nulls last, attempt.started_at desc, attempt.id desc
  limit 1;

  for v_position in 1..v_total loop
    select question.id into v_question_id
    from public.questions question
    left join public.lessons lesson on lesson.id = question.lesson_id
    left join lateral (
      select
        count(history_item.id)::integer as seen_count,
        max(coalesce(history_attempt.completed_at, history_attempt.started_at)) as last_seen_at,
        coalesce(bool_or(history_attempt.id = v_last_attempt_id), false) as in_last_attempt
      from public.quiz_attempt_questions history_item
      join public.quiz_attempts history_attempt on history_attempt.id = history_item.attempt_id
      where history_item.question_id = question.id
        and history_attempt.user_id = v_user_id
        and history_attempt.quiz_type = 'topic'
        and history_attempt.topic_id = p_topic_id
        and history_attempt.status = 'completed'
    ) history on true
    left join lateral (
      select
        count(*) filter (
          where coalesce(selected_question.lesson_id, '00000000-0000-0000-0000-000000000000'::uuid)
            = coalesce(question.lesson_id, '00000000-0000-0000-0000-000000000000'::uuid)
        )::integer as lesson_selected,
        count(*) filter (where selected_question.difficulty = 'easy')::integer as easy_selected,
        count(*) filter (where selected_question.difficulty = 'medium')::integer as medium_selected,
        count(*) filter (where selected_question.difficulty = 'hard')::integer as hard_selected
      from public.questions selected_question
      where selected_question.id = any(v_selected_ids)
    ) selection on true
    where question.topic_id = p_topic_id
      and question.is_published = true
      and question.question_type = 'single_choice'
      and not (question.id = any(v_selected_ids))
    order by
      -- Primeiro distribui a tentativa entre as Lessons disponíveis.
      selection.lesson_selected,
      -- Em cada rodada de Lesson, evita destruir a distribuição 3/5/2.
      case question.difficulty
        when 'easy' then case when selection.easy_selected < v_target_easy then 0 else 1 end
        when 'medium' then case when selection.medium_selected < v_target_medium then 0 else 1 end
        when 'hard' then case when selection.hard_selected < v_target_hard then 0 else 1 end
        else 1
      end,
      -- Dentro das restrições pedagógicas, unseen sempre vence seen.
      case when history.seen_count = 0 then 0 else 1 end,
      -- A tentativa imediatamente anterior recebe a menor prioridade.
      case when history.in_last_attempt then 1 else 0 end,
      -- Quando todo o pool foi visto, entram primeiro as Questions menos recentes.
      history.last_seen_at asc nulls first,
      -- Desempata pelas maiores lacunas da distribuição de dificuldade.
      case question.difficulty
        when 'easy' then v_target_easy - selection.easy_selected
        when 'medium' then v_target_medium - selection.medium_selected
        when 'hard' then v_target_hard - selection.hard_selected
        else -1
      end desc,
      coalesce(lesson.display_order, 2147483647),
      question.display_order,
      question.id
    limit 1;

    if v_question_id is null then
      raise exception 'Topic Quiz selection stopped before reaching % Questions.', v_total;
    end if;

    v_selected_ids := array_append(v_selected_ids, v_question_id);
  end loop;

  begin
    insert into public.quiz_attempts
      (user_id, certification_id, quiz_type, topic_id, total_questions)
    values
      (v_user_id, v_certification_id, 'topic', p_topic_id, v_total)
    returning * into v_attempt;
  exception when unique_violation then
    select attempt.* into strict v_attempt
    from public.quiz_attempts attempt
    where attempt.user_id = v_user_id
      and attempt.quiz_type = 'topic'
      and attempt.topic_id = p_topic_id
      and attempt.status = 'in_progress';
    return next v_attempt;
    return;
  end;

  insert into public.quiz_attempt_questions (attempt_id, question_id, display_order)
  select v_attempt.id, selected.question_id, selected.ordinality::integer
  from unnest(v_selected_ids) with ordinality as selected(question_id, ordinality);

  return next v_attempt;
end;
$$;

revoke execute on function public.start_topic_quiz(uuid) from public, anon;
grant execute on function public.start_topic_quiz(uuid) to authenticated;

commit;

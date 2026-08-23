begin;

create or replace function public.start_review_quiz(
  p_certification_id uuid,
  p_question_id uuid default null
)
returns setof public.quiz_attempts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt public.quiz_attempts;
  v_question_ids uuid[];
  v_total integer;
  v_completed_review_count integer;
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  if not exists (
    select 1 from public.certifications certification
    where certification.id = p_certification_id and certification.is_enabled = true
  ) then
    raise exception 'Certification not found.' using errcode = 'P0002';
  end if;

  select attempt.* into v_attempt
  from public.quiz_attempts attempt
  where attempt.user_id = v_user_id
    and attempt.certification_id = p_certification_id
    and attempt.quiz_type = 'review'
    and attempt.status = 'in_progress'
  order by attempt.started_at desc
  limit 1;

  if found then
    if p_question_id is not null and not exists (
      select 1 from public.quiz_attempt_questions attempt_question
      where attempt_question.attempt_id = v_attempt.id
        and attempt_question.question_id = p_question_id
    ) then
      raise exception 'Finish the active review before starting an individual review.' using errcode = '55000';
    end if;
    return next v_attempt;
    return;
  end if;

  if p_question_id is not null and not exists (
    select 1
    from public.questions question
    join public.quiz_answers answer on answer.question_id = question.id and not answer.is_correct
    join public.quiz_attempts attempt on attempt.id = answer.attempt_id
    where question.id = p_question_id
      and question.certification_id = p_certification_id
      and question.is_published = true
      and question.question_type = 'single_choice'
      and attempt.user_id = v_user_id
      and attempt.certification_id = p_certification_id
  ) then
    raise exception 'Question is not eligible for this review.' using errcode = 'P0002';
  end if;

  select count(*) into v_completed_review_count
  from public.quiz_attempts attempt
  where attempt.user_id = v_user_id
    and attempt.certification_id = p_certification_id
    and attempt.quiz_type = 'review'
    and attempt.status = 'completed';

  if p_question_id is not null then
    v_question_ids := array[p_question_id];
  else
    with stats as (
      select
        question.id,
        count(*) filter (where not answer.is_correct) as errors,
        count(*) filter (where not answer.is_correct)::numeric / count(*)::numeric as error_rate,
        (array_agg(answer.is_correct order by answer.answered_at desc, answer.id desc))[1] as last_result,
        max(answer.answered_at) as last_answered_at
      from public.quiz_answers answer
      join public.quiz_attempts attempt on attempt.id = answer.attempt_id
      join public.questions question on question.id = answer.question_id
      where attempt.user_id = v_user_id
        and attempt.certification_id = p_certification_id
        and question.certification_id = p_certification_id
        and question.is_published = true
        and question.question_type = 'single_choice'
      group by question.id
      having count(*) filter (where not answer.is_correct) > 0
    ), ranked as (
      select stats.*,
        row_number() over (
          order by (stats.last_result = false) desc, stats.error_rate desc,
            stats.errors desc, stats.last_answered_at desc, stats.id
        )::integer as priority_rank
      from stats
    ), candidates as (
      select * from ranked where priority_rank <= 20
    ), numbered as (
      select candidates.*,
        count(*) filter (where priority_rank > 7) over ()::integer as tail_count
      from candidates
    ), selected as (
      select numbered.id, numbered.priority_rank,
        case
          when numbered.priority_rank <= 7 then numbered.priority_rank
          when numbered.tail_count = 0 then numbered.priority_rank
          else 8 + mod(
            numbered.priority_rank - 8 - mod(v_completed_review_count, numbered.tail_count) + numbered.tail_count,
            numbered.tail_count
          )
        end as rotated_order
      from numbered
      order by (numbered.priority_rank <= 7) desc, rotated_order
      limit 10
    ), ordered as (
      select selected.id,
        row_number() over (order by (selected.priority_rank <= 7) desc, selected.rotated_order) as selection_order
      from selected
    )
    select array_agg(ordered.id order by ordered.selection_order)
    into v_question_ids
    from ordered;
  end if;

  v_total := coalesce(cardinality(v_question_ids), 0);
  if v_total = 0 then
    raise exception 'No questions with incorrect history are available for review.' using errcode = 'P0002';
  end if;

  begin
    insert into public.quiz_attempts (
      user_id, certification_id, quiz_type, lesson_id, topic_id, total_questions
    ) values (
      v_user_id, p_certification_id, 'review', null, null, v_total
    ) returning * into v_attempt;
  exception when unique_violation then
    select attempt.* into strict v_attempt
    from public.quiz_attempts attempt
    where attempt.user_id = v_user_id
      and attempt.certification_id = p_certification_id
      and attempt.quiz_type = 'review'
      and attempt.status = 'in_progress';
    return next v_attempt;
    return;
  end;

  insert into public.quiz_attempt_questions (attempt_id, question_id, display_order)
  select v_attempt.id, selected.question_id, selected.display_order::integer
  from unnest(v_question_ids) with ordinality selected(question_id, display_order);

  return next v_attempt;
end;
$$;

revoke execute on function public.start_review_quiz(uuid, uuid) from public, anon;
grant execute on function public.start_review_quiz(uuid, uuid) to authenticated;

commit;

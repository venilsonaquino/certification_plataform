begin;

create function public.get_readiness_evidence(p_certification_id uuid)
returns table (
  evidence_id uuid,
  evidence_kind text,
  source text,
  attempt_id uuid,
  question_id uuid,
  domain_id uuid,
  topic_id uuid,
  lesson_id uuid,
  outcome text,
  occurred_at timestamptz,
  difficulty text,
  attempt_status text,
  duration_seconds integer,
  lesson_status text,
  flashcard_rating text,
  review_count integer,
  successful_review_count integer,
  due_at timestamptz
)
language plpgsql
security definer
set search_path = ''
stable
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  if not exists (
    select 1
    from public.certifications certification
    where certification.id = p_certification_id
      and certification.is_enabled = true
  ) then
    raise exception 'Certification not found.' using errcode = 'P0002';
  end if;

  return query
  with evidence as (
    select
      answer.id as evidence_id,
      'assessment'::text as evidence_kind,
      (attempt.quiz_type || '_quiz')::text as source,
      attempt.id as attempt_id,
      question.id as question_id,
      question.domain_id,
      question.topic_id,
      question.lesson_id,
      case when answer.is_correct then 'correct' else 'incorrect' end::text as outcome,
      answer.answered_at as occurred_at,
      question.difficulty::text,
      attempt.status::text as attempt_status,
      greatest(0, extract(epoch from (attempt.completed_at - attempt.started_at))::integer)
        as duration_seconds,
      null::text as lesson_status,
      null::text as flashcard_rating,
      null::integer as review_count,
      null::integer as successful_review_count,
      null::timestamptz as due_at
    from public.quiz_attempts attempt
    join public.quiz_answers answer on answer.attempt_id = attempt.id
    join public.questions question on question.id = answer.question_id
    where attempt.user_id = v_user_id
      and attempt.certification_id = p_certification_id
      and attempt.status = 'completed'
      and question.domain_id is not null
      and question.topic_id is not null

    union all

    select
      item.id,
      'assessment'::text,
      'mock_exam'::text,
      attempt.id,
      item.question_id,
      item.domain_id,
      item.topic_id,
      item.lesson_id,
      case
        when answer.id is null then 'unanswered'
        when answer.is_correct then 'correct'
        else 'incorrect'
      end::text,
      attempt.submitted_at,
      item.difficulty_snapshot::text,
      attempt.status::text,
      attempt.elapsed_seconds,
      null::text,
      null::text,
      null::integer,
      null::integer,
      null::timestamptz
    from public.mock_exam_attempts attempt
    join public.mock_exam_attempt_questions item on item.attempt_id = attempt.id
    left join public.mock_exam_answers answer on answer.attempt_question_id = item.id
    where attempt.user_id = v_user_id
      and attempt.certification_id = p_certification_id
      and attempt.status in ('completed', 'expired')
      and attempt.submitted_at is not null

    union all

    select
      progress.id,
      'learning'::text,
      'lesson_progress'::text,
      null::uuid,
      null::uuid,
      domain.id,
      topic.id,
      lesson.id,
      null::text,
      coalesce(progress.last_accessed_at, progress.completed_at, progress.started_at),
      null::text,
      null::text,
      null::integer,
      progress.status::text,
      null::text,
      null::integer,
      null::integer,
      null::timestamptz
    from public.user_lesson_progress progress
    join public.lessons lesson on lesson.id = progress.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    where progress.user_id = v_user_id
      and domain.certification_id = p_certification_id

    union all

    select
      review.id,
      'learning'::text,
      'flashcard_review'::text,
      null::uuid,
      null::uuid,
      domain.id,
      topic.id,
      lesson.id,
      null::text,
      review.reviewed_at,
      null::text,
      null::text,
      null::integer,
      null::text,
      review.rating::text,
      null::integer,
      null::integer,
      null::timestamptz
    from public.flashcard_reviews review
    join public.flashcards flashcard on flashcard.id = review.flashcard_id
    join public.lessons lesson on lesson.id = flashcard.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    where review.user_id = v_user_id
      and domain.certification_id = p_certification_id

    union all

    select
      progress.id,
      'learning'::text,
      'flashcard_progress'::text,
      null::uuid,
      null::uuid,
      domain.id,
      topic.id,
      lesson.id,
      null::text,
      progress.last_reviewed_at,
      null::text,
      null::text,
      null::integer,
      null::text,
      progress.last_rating::text,
      progress.review_count,
      progress.successful_review_count,
      progress.next_review_at
    from public.user_flashcard_progress progress
    join public.flashcards flashcard on flashcard.id = progress.flashcard_id
    join public.lessons lesson on lesson.id = flashcard.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    where progress.user_id = v_user_id
      and domain.certification_id = p_certification_id
  )
  select *
  from evidence
  order by occurred_at nulls last, evidence_id;
end;
$$;

revoke execute on function public.get_readiness_evidence(uuid) from public, anon;
grant execute on function public.get_readiness_evidence(uuid) to authenticated;

commit;

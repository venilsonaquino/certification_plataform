begin;

do $$
declare
  v_definition text;
begin
  v_definition := pg_get_functiondef('public.get_mock_exam_result(uuid)'::regprocedure);
  v_definition := replace(
    v_definition,
    'and attempt.status = ''completed''',
    'and attempt.status in (''completed'', ''expired'')'
  );
  if v_definition not like '%attempt.status in (''completed'', ''expired'')%' then
    raise exception 'Could not upgrade get_mock_exam_result lifecycle predicate.';
  end if;
  execute v_definition;

  v_definition := pg_get_functiondef('public.get_mock_exam_review(uuid)'::regprocedure);
  v_definition := replace(
    v_definition,
    'and attempt.status = ''completed''',
    'and attempt.status in (''completed'', ''expired'')'
  );
  if v_definition not like '%attempt.status in (''completed'', ''expired'')%' then
    raise exception 'Could not upgrade get_mock_exam_review lifecycle predicate.';
  end if;
  execute v_definition;
end;
$$;

comment on function public.get_mock_exam_result(uuid) is
  'Returns persisted Practice Score and snapshot breakdowns for an owned completed or timeout-finalized Mock Exam.';
comment on function public.get_mock_exam_review(uuid) is
  'Returns answer keys and explanations only for an owned completed or timeout-finalized Mock Exam.';

commit;

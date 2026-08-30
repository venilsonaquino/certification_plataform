begin;

do $$
declare
  v_definition text;
begin
  v_definition := pg_get_functiondef('public.save_mock_exam_answer(uuid,uuid,text)'::regprocedure);
  v_definition := replace(
    v_definition,
    'on conflict (attempt_question_id) do update set',
    'on conflict on constraint mock_exam_answers_attempt_question_unique do update set'
  );
  if v_definition not like '%on conflict on constraint mock_exam_answers_attempt_question_unique do update set%' then
    raise exception 'Could not disambiguate the Mock answer upsert constraint.';
  end if;
  execute v_definition;
end;
$$;

comment on function public.save_mock_exam_answer(uuid, uuid, text) is
  'Owner-only answer upsert guarded by server-authoritative Practice Mock expiration.';

commit;

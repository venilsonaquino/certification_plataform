begin;

-- Readiness uses this editorial flag to distinguish mock-eligible questions.
-- Keep the existing column-level protection for answer and explanation fields.
grant select (mock_eligible)
  on table public.questions
  to authenticated;

do $$
begin
  if not has_column_privilege(
    'authenticated',
    'public.questions',
    'mock_eligible',
    'SELECT'
  ) then
    raise exception 'Authenticated users must be able to read questions.mock_eligible';
  end if;
end;
$$;

commit;

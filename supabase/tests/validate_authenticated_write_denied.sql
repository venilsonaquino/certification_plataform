begin;

set local role authenticated;

do $$
begin
  insert into public.certifications (code, name, provider)
  values ('rls-write-test', 'RLS write test', 'Test');

  raise exception 'authenticated INSERT unexpectedly succeeded';
exception
  when insufficient_privilege then null;
end;
$$;

do $$
begin
  update public.certifications
  set name = name
  where code = 'az-900';

  raise exception 'authenticated UPDATE unexpectedly succeeded';
exception
  when insufficient_privilege then null;
end;
$$;

do $$
begin
  delete from public.certifications
  where code = 'az-900';

  raise exception 'authenticated DELETE unexpectedly succeeded';
exception
  when insufficient_privilege then null;
end;
$$;

select json_build_object(
  'role', current_user,
  'insert_denied', true,
  'update_denied', true,
  'delete_denied', true
) as authenticated_write_validation;

rollback;

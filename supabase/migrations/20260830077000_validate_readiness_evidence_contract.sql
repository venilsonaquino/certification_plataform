begin;

do $$
declare
  v_definition text;
begin
  if to_regprocedure('public.get_readiness_evidence(uuid)') is null then
    raise exception '12.2 requires get_readiness_evidence(uuid)';
  end if;
  if has_function_privilege('anon', 'public.get_readiness_evidence(uuid)', 'EXECUTE') then
    raise exception 'Anonymous users can execute the Readiness evidence RPC';
  end if;
  if not has_function_privilege(
    'authenticated', 'public.get_readiness_evidence(uuid)', 'EXECUTE'
  ) then
    raise exception 'Authenticated users cannot execute the Readiness evidence RPC';
  end if;
  if pg_get_function_identity_arguments('public.get_readiness_evidence(uuid)'::regprocedure)
      <> 'p_certification_id uuid' then
    raise exception 'Readiness RPC must not accept a client-provided user_id';
  end if;

  select pg_get_functiondef('public.get_readiness_evidence(uuid)'::regprocedure)
  into strict v_definition;

  if v_definition not like '%v_user_id uuid := auth.uid()%' then
    raise exception 'Readiness RPC does not derive ownership from auth.uid()';
  end if;
  if v_definition not like '%attempt.user_id = v_user_id%'
    or v_definition not like '%progress.user_id = v_user_id%'
    or v_definition not like '%review.user_id = v_user_id%' then
    raise exception 'A Readiness evidence source is missing its ownership predicate';
  end if;
  if v_definition like '%p_user_id%' then
    raise exception 'Readiness RPC unexpectedly trusts a client user id';
  end if;
end;
$$;

comment on function public.get_readiness_evidence(uuid) is
  'Owner-only, on-demand evidence contract for AZ-900 Readiness v1. Returns no answer keys.';

commit;

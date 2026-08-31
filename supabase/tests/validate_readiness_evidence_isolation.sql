begin;

do $$
begin
  if to_regprocedure('public.get_readiness_evidence(uuid)') is null then
    raise exception 'Readiness evidence RPC is missing';
  end if;
  if has_function_privilege('anon', 'public.get_readiness_evidence(uuid)', 'EXECUTE') then
    raise exception 'Anonymous users can execute the Readiness evidence RPC';
  end if;
  if pg_get_function_identity_arguments('public.get_readiness_evidence(uuid)'::regprocedure)
      <> 'p_certification_id uuid' then
    raise exception 'Readiness RPC must not accept a client-provided user_id';
  end if;
end;
$$;

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
)
values
  ('00000000-0000-0000-0000-000000000000', '5a000000-0000-4000-8000-000000000001',
   'authenticated', 'authenticated', 'readiness-a@example.invalid', '', now(),
   '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()),
  ('00000000-0000-0000-0000-000000000000', '5a000000-0000-4000-8000-000000000002',
   'authenticated', 'authenticated', 'readiness-b@example.invalid', '', now(),
   '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now());

do $$
declare
  v_lesson_id uuid;
begin
  select lesson.id into strict v_lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.is_enabled = true and lesson.is_published = true
  order by certification.display_order, domain.display_order, topic.display_order,
    lesson.display_order
  limit 1;

  insert into public.user_lesson_progress (
    user_id, lesson_id, status, started_at, completed_at, last_accessed_at
  ) values
    ('5a000000-0000-4000-8000-000000000001', v_lesson_id, 'completed',
     clock_timestamp(), clock_timestamp(), clock_timestamp()),
    ('5a000000-0000-4000-8000-000000000002', v_lesson_id, 'in_progress',
     clock_timestamp(), null, clock_timestamp());
end;
$$;

set local role authenticated;
select set_config('request.jwt.claim.sub', '5a000000-0000-4000-8000-000000000001', true);

do $$
declare
  v_certification_id uuid;
begin
  select certification.id into strict v_certification_id
  from public.certifications certification
  where certification.is_enabled = true
  order by certification.display_order
  limit 1;

  if (select count(*) from public.get_readiness_evidence(v_certification_id)
      where source = 'lesson_progress') <> 1 then
    raise exception 'User A did not receive exactly its own Lesson evidence';
  end if;
  if exists (
    select 1 from public.get_readiness_evidence(v_certification_id)
    where source = 'lesson_progress' and lesson_status <> 'completed'
  ) then
    raise exception 'User A received User B evidence';
  end if;
end;
$$;

select set_config('request.jwt.claim.sub', '5a000000-0000-4000-8000-000000000002', true);

do $$
declare
  v_certification_id uuid;
begin
  select certification.id into strict v_certification_id
  from public.certifications certification
  where certification.is_enabled = true
  order by certification.display_order
  limit 1;

  if (select count(*) from public.get_readiness_evidence(v_certification_id)
      where source = 'lesson_progress') <> 1 then
    raise exception 'User B did not receive exactly its own Lesson evidence';
  end if;
  if exists (
    select 1 from public.get_readiness_evidence(v_certification_id)
    where source = 'lesson_progress' and lesson_status <> 'in_progress'
  ) then
    raise exception 'User B received User A evidence';
  end if;
end;
$$;

reset role;
set local role postgres;

select json_build_object(
  'rpc_owner_isolation', true,
  'client_user_id_argument', false,
  'anonymous_execute', false,
  'temporary_users', 2
) as readiness_evidence_isolation_validation;

reset role;

rollback;

begin;

insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
values
  (
    '00000000-0000-0000-0000-000000000000',
    '51000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'progress-test-a@example.invalid',
    '',
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '51000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'progress-test-b@example.invalid',
    '',
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  );

set local role authenticated;
select set_config('request.jwt.claim.sub', '51000000-0000-4000-8000-000000000001', true);

do $$
declare
  started_progress public.user_lesson_progress;
  completed_progress public.user_lesson_progress;
  reopened_progress public.user_lesson_progress;
begin
  if exists (
    select 1
    from public.user_lesson_progress
    where lesson_id = '40000000-0000-4000-8000-000000000001'
  ) then
    raise exception 'New user unexpectedly has lesson progress';
  end if;

  select * into strict started_progress
  from public.start_lesson_progress('40000000-0000-4000-8000-000000000001');

  if started_progress.status <> 'in_progress'
    or started_progress.started_at is null
    or started_progress.last_accessed_at is null then
    raise exception 'startLesson did not create valid in-progress state';
  end if;

  select * into strict completed_progress
  from public.complete_lesson_progress('40000000-0000-4000-8000-000000000001');

  if completed_progress.status <> 'completed'
    or completed_progress.completed_at is null
    or completed_progress.started_at <> started_progress.started_at then
    raise exception 'completeLesson did not preserve the start state';
  end if;

  select * into strict reopened_progress
  from public.start_lesson_progress('40000000-0000-4000-8000-000000000001');

  if reopened_progress.status <> 'completed'
    or reopened_progress.started_at <> started_progress.started_at
    or reopened_progress.completed_at <> completed_progress.completed_at then
    raise exception 'startLesson regressed a completed lesson';
  end if;
end;
$$;

select set_config('request.jwt.claim.sub', '51000000-0000-4000-8000-000000000002', true);

do $$
begin
  if exists (
    select 1
    from public.user_lesson_progress
    where user_id = '51000000-0000-4000-8000-000000000001'
  ) then
    raise exception 'User B can read user A progress';
  end if;

  perform *
  from public.start_lesson_progress('40000000-0000-4000-8000-000000000001');
end;
$$;

select set_config('request.jwt.claim.sub', '51000000-0000-4000-8000-000000000001', true);

do $$
declare
  affected_rows integer;
begin
  update public.user_lesson_progress
  set status = 'not_started'
  where user_id = '51000000-0000-4000-8000-000000000002';

  get diagnostics affected_rows = row_count;

  if affected_rows <> 0 then
    raise exception 'User A can update user B progress';
  end if;

  if (select count(*) from public.user_lesson_progress) <> 1 then
    raise exception 'User A can read rows owned by another user';
  end if;
end;
$$;

reset role;

select json_build_object(
  'temporary_users', 2,
  'rows_created', (select count(*) from public.user_lesson_progress where user_id in (
    '51000000-0000-4000-8000-000000000001',
    '51000000-0000-4000-8000-000000000002'
  )),
  'unique_user_lesson_pairs', (
    select count(*)
    from (
      select user_id, lesson_id
      from public.user_lesson_progress
      where user_id in (
        '51000000-0000-4000-8000-000000000001',
        '51000000-0000-4000-8000-000000000002'
      )
      group by user_id, lesson_id
    ) pairs
  ),
  'user_a_status', (
    select status
    from public.user_lesson_progress
    where user_id = '51000000-0000-4000-8000-000000000001'
  ),
  'user_b_status', (
    select status
    from public.user_lesson_progress
    where user_id = '51000000-0000-4000-8000-000000000002'
  ),
  'user_b_cannot_read_a', true,
  'user_a_cannot_update_b', true,
  'completed_does_not_regress', true
) as user_lesson_progress_isolation_validation;

rollback;

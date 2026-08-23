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
    '55000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'flashcard-review-a@example.invalid',
    '',
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '55000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'flashcard-review-b@example.invalid',
    '',
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  );

set local role authenticated;
select set_config('request.jwt.claim.sub', '55000000-0000-4000-8000-000000000001', true);

select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000001', 'again');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000002', 'hard');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000003', 'good');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000004', 'easy');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000001', 'good');

do $$
begin
  if (select count(*) from public.flashcard_reviews) <> 5 then
    raise exception 'User A expected 5 visible reviews';
  end if;

  if (
    select count(*)
    from public.flashcard_reviews
    where flashcard_id = '70000000-0000-4000-8000-000000000001'
  ) <> 2 then
    raise exception 'A second rating overwrote the previous review';
  end if;

  if (
    select count(distinct rating)
    from public.flashcard_reviews
  ) <> 4 then
    raise exception 'Not all four ratings were persisted';
  end if;
end;
$$;

do $$
begin
  perform *
  from public.submit_flashcard_review('70000000-0000-4000-8000-000000000001', 'invalid');
  raise exception 'Invalid rating unexpectedly succeeded';
exception
  when check_violation then null;
end;
$$;

select set_config('request.jwt.claim.sub', '55000000-0000-4000-8000-000000000002', true);

do $$
begin
  if exists (select 1 from public.flashcard_reviews) then
    raise exception 'User B can read user A reviews';
  end if;

  perform *
  from public.submit_flashcard_review('70000000-0000-4000-8000-000000000001', 'hard');

  if (select count(*) from public.flashcard_reviews) <> 1 then
    raise exception 'User B review was not isolated correctly';
  end if;
end;
$$;

do $$
begin
  insert into public.flashcard_reviews (user_id, flashcard_id, rating)
  values (
    '55000000-0000-4000-8000-000000000001',
    '70000000-0000-4000-8000-000000000001',
    'easy'
  );
  raise exception 'User B inserted a review pretending to be user A';
exception
  when insufficient_privilege then null;
end;
$$;

reset role;

update public.flashcards
set is_published = false
where id = '70000000-0000-4000-8000-000000000033';

set local role authenticated;
select set_config('request.jwt.claim.sub', '55000000-0000-4000-8000-000000000001', true);

do $$
begin
  perform *
  from public.submit_flashcard_review('70000000-0000-4000-8000-000000000033', 'good');
  raise exception 'Review for unpublished flashcard unexpectedly succeeded';
exception
  when no_data_found then null;
end;
$$;

reset role;

do $$
begin
  if (
    select count(*)
    from public.flashcard_reviews
    where user_id = '55000000-0000-4000-8000-000000000001'
  ) <> 5 then
    raise exception 'User A history changed unexpectedly';
  end if;

  if (
    select count(*)
    from public.flashcard_reviews
    where user_id = '55000000-0000-4000-8000-000000000002'
  ) <> 1 then
    raise exception 'User B expected one independent review';
  end if;
end;
$$;

rollback;

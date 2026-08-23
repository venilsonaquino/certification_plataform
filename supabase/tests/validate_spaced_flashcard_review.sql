begin;

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
)
values
  ('00000000-0000-0000-0000-000000000000', '56000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'spaced-a@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()),
  ('00000000-0000-0000-0000-000000000000', '56000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'spaced-b@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()),
  ('00000000-0000-0000-0000-000000000000', '56000000-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'spaced-backfill@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now());

set local role authenticated;
select set_config('request.jwt.claim.sub', '56000000-0000-4000-8000-000000000001', true);

select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000001', 'again');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000002', 'hard');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000003', 'good');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000004', 'easy');

do $$
begin
  if (select interval_days from public.user_flashcard_progress where flashcard_id = '70000000-0000-4000-8000-000000000001') <> 1 then raise exception 'New again did not produce 1 day'; end if;
  if (select interval_days from public.user_flashcard_progress where flashcard_id = '70000000-0000-4000-8000-000000000002') <> 2 then raise exception 'New hard did not produce 2 days'; end if;
  if (select interval_days from public.user_flashcard_progress where flashcard_id = '70000000-0000-4000-8000-000000000003') <> 4 then raise exception 'New good did not produce 4 days'; end if;
  if (select interval_days from public.user_flashcard_progress where flashcard_id = '70000000-0000-4000-8000-000000000004') <> 7 then raise exception 'New easy did not produce 7 days'; end if;
end;
$$;

select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000003', 'good');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000003', 'hard');

do $$
begin
  if (select interval_days from public.user_flashcard_progress where flashcard_id = '70000000-0000-4000-8000-000000000003') <> 12 then raise exception '4 -> good -> 8 -> hard did not produce 12 days'; end if;
  if (select review_count from public.user_flashcard_progress where flashcard_id = '70000000-0000-4000-8000-000000000003') <> 3 then raise exception 'Review count is incorrect'; end if;
  if (select successful_review_count from public.user_flashcard_progress where flashcard_id = '70000000-0000-4000-8000-000000000003') <> 2 then raise exception 'Successful review count is incorrect'; end if;
end;
$$;

select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000005', 'good');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000005', 'good');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000005', 'good');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000005', 'again');

do $$
begin
  if (select interval_days from public.user_flashcard_progress where flashcard_id = '70000000-0000-4000-8000-000000000005') <> 1 then raise exception '16 days + again did not reset to 1'; end if;
end;
$$;

select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000006', 'easy');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000006', 'easy');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000006', 'easy');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000006', 'easy');
select * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000006', 'easy');

do $$
declare
  progress public.user_flashcard_progress;
begin
  select * into strict progress from public.user_flashcard_progress where flashcard_id = '70000000-0000-4000-8000-000000000006';
  if progress.interval_days <> 90 then raise exception 'Maximum interval was not capped at 90'; end if;
  if progress.next_review_at < progress.last_reviewed_at + interval '89 days 23 hours' then raise exception 'next_review_at was not calculated server-side from interval'; end if;
  if progress.next_review_at > progress.last_reviewed_at + interval '90 days 1 hour' then raise exception 'next_review_at exceeded interval'; end if;
end;
$$;

do $$
declare
  reviews_before integer := (select count(*) from public.flashcard_reviews);
  progress_before integer := (select count(*) from public.user_flashcard_progress);
begin
  begin
    perform * from public.submit_flashcard_review('70000000-0000-4000-8000-000000000007', 'invalid');
    raise exception 'Invalid rating unexpectedly succeeded';
  exception when check_violation then null;
  end;
  if (select count(*) from public.flashcard_reviews) <> reviews_before
    or (select count(*) from public.user_flashcard_progress) <> progress_before then
    raise exception 'Failed review changed history or progress';
  end if;
end;
$$;

reset role;

update public.user_flashcard_progress
set next_review_at = case flashcard_id
  when '70000000-0000-4000-8000-000000000001' then clock_timestamp() - interval '2 days'
  when '70000000-0000-4000-8000-000000000002' then clock_timestamp() - interval '1 day'
  else clock_timestamp() + interval '1 day'
end
where user_id = '56000000-0000-4000-8000-000000000001';

update public.flashcards set is_published = false where id = '70000000-0000-4000-8000-000000000033';

set local role authenticated;
select set_config('request.jwt.claim.sub', '56000000-0000-4000-8000-000000000001', true);

do $$
declare
  statuses text[];
  ids uuid[];
begin
  select array_agg(review_status order by row_number), array_agg(id order by row_number)
  into statuses, ids
  from (
    select *, row_number() over () as row_number
    from public.get_flashcard_study_queue('10000000-0000-4000-8000-000000000900')
  ) queue;

  if cardinality(statuses) <> 7 then raise exception 'Expected 2 due + 5 new cards, found %', cardinality(statuses); end if;
  if statuses[1] <> 'due' or statuses[2] <> 'due' then raise exception 'Due cards were not prioritized'; end if;
  if ids[1] <> '70000000-0000-4000-8000-000000000001' then raise exception 'Most overdue card was not first'; end if;
  if (select count(*) from unnest(statuses) status where status = 'new') <> 5 then raise exception 'New card limit is not 5'; end if;
  if '70000000-0000-4000-8000-000000000033' = any(ids) then raise exception 'Unpublished card entered the queue'; end if;
  if '70000000-0000-4000-8000-000000000003' = any(ids) then raise exception 'Future scheduled card entered the queue'; end if;
end;
$$;

select set_config('request.jwt.claim.sub', '56000000-0000-4000-8000-000000000002', true);

do $$
begin
  if exists (select 1 from public.user_flashcard_progress) then raise exception 'User B can read user A progress'; end if;
  if (select count(*) from public.get_flashcard_study_queue('10000000-0000-4000-8000-000000000900')) <> 5 then raise exception 'New user did not receive exactly 5 new cards'; end if;
  if exists (select 1 from public.get_flashcard_study_queue('10000000-0000-4000-8000-000000000900') where review_status <> 'new') then raise exception 'User B queue leaked user A state'; end if;
end;
$$;

do $$
begin
  update public.user_flashcard_progress set interval_days = 1 where user_id = '56000000-0000-4000-8000-000000000001';
  raise exception 'User B updated user A progress';
exception when insufficient_privilege then null;
end;
$$;

reset role;

insert into public.flashcard_reviews (user_id, flashcard_id, rating, reviewed_at, created_at)
values
  ('56000000-0000-4000-8000-000000000003', '70000000-0000-4000-8000-000000000010', 'again', clock_timestamp() - interval '3 days', clock_timestamp() - interval '3 days'),
  ('56000000-0000-4000-8000-000000000003', '70000000-0000-4000-8000-000000000010', 'good', clock_timestamp() - interval '1 day', clock_timestamp() - interval '1 day');

with review_totals as (
  select user_id, flashcard_id, count(*)::integer as review_count,
    count(*) filter (where rating in ('good', 'easy'))::integer as successful_review_count
  from public.flashcard_reviews where user_id = '56000000-0000-4000-8000-000000000003'
  group by user_id, flashcard_id
), latest_reviews as (
  select distinct on (user_id, flashcard_id) user_id, flashcard_id, rating, reviewed_at
  from public.flashcard_reviews where user_id = '56000000-0000-4000-8000-000000000003'
  order by user_id, flashcard_id, reviewed_at desc, created_at desc, id desc
)
insert into public.user_flashcard_progress (
  user_id, flashcard_id, last_rating, review_count, successful_review_count,
  interval_days, next_review_at, last_reviewed_at
)
select totals.user_id, totals.flashcard_id, latest.rating, totals.review_count,
  totals.successful_review_count, public.calculate_flashcard_interval(0, latest.rating),
  latest.reviewed_at + make_interval(days => public.calculate_flashcard_interval(0, latest.rating)),
  latest.reviewed_at
from review_totals totals join latest_reviews latest using (user_id, flashcard_id);

do $$
declare
  progress public.user_flashcard_progress;
begin
  select * into strict progress from public.user_flashcard_progress where user_id = '56000000-0000-4000-8000-000000000003';
  if progress.last_rating <> 'good' or progress.review_count <> 2
    or progress.successful_review_count <> 1 or progress.interval_days <> 4 then
    raise exception 'Backfill did not use latest rating plus historical counts';
  end if;
end;
$$;

insert into public.user_flashcard_progress (
  user_id, flashcard_id, last_rating, review_count, successful_review_count,
  interval_days, next_review_at, last_reviewed_at
)
select
  '56000000-0000-4000-8000-000000000001', flashcards.id, 'hard', 1, 0, 2,
  clock_timestamp() - interval '1 day', clock_timestamp() - interval '3 days'
from public.flashcards
where flashcards.is_published
order by flashcards.id
limit 20
on conflict (user_id, flashcard_id) do update set next_review_at = excluded.next_review_at;

set local role authenticated;
select set_config('request.jwt.claim.sub', '56000000-0000-4000-8000-000000000001', true);

do $$
begin
  if (select count(*) from public.get_flashcard_study_queue('10000000-0000-4000-8000-000000000900')) <> 20 then raise exception 'Daily queue limit is not 20'; end if;
  if exists (select 1 from public.get_flashcard_study_queue('10000000-0000-4000-8000-000000000900') where review_status <> 'due') then raise exception 'New cards displaced 20 due cards'; end if;
end;
$$;

reset role;

insert into public.domains (id, certification_id, title, display_order)
values ('26000000-0000-4000-8000-000000000104', '10000000-0000-4000-8000-000000000104', 'Temporary AZ-104 domain', 99);
insert into public.topics (id, domain_id, title, display_order)
values ('36000000-0000-4000-8000-000000000104', '26000000-0000-4000-8000-000000000104', 'Temporary topic', 1);
insert into public.lessons (id, topic_id, slug, title, display_order, is_published)
values ('46000000-0000-4000-8000-000000000104', '36000000-0000-4000-8000-000000000104', 'temporary-az104-lesson', 'Temporary lesson', 1, true);
insert into public.flashcards (id, lesson_id, front_text, back_text, display_order, is_published)
values ('76000000-0000-4000-8000-000000000104', '46000000-0000-4000-8000-000000000104', 'AZ-104 only?', 'Yes.', 1, true);

set local role authenticated;
select set_config('request.jwt.claim.sub', '56000000-0000-4000-8000-000000000002', true);

do $$
begin
  if exists (
    select 1 from public.get_flashcard_study_queue('10000000-0000-4000-8000-000000000900')
    where id = '76000000-0000-4000-8000-000000000104'
  ) then raise exception 'AZ-104 card leaked into AZ-900 queue'; end if;
  if (select count(*) from public.get_flashcard_study_queue('10000000-0000-4000-8000-000000000104')) <> 1 then raise exception 'AZ-104 queue did not return its own card'; end if;
end;
$$;

rollback;

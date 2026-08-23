begin;

create table public.user_lesson_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  status text not null default 'not_started',
  started_at timestamptz,
  completed_at timestamptz,
  last_accessed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_lesson_progress_user_lesson_unique unique (user_id, lesson_id),
  constraint user_lesson_progress_status_check
    check (status in ('not_started', 'in_progress', 'completed'))
);

create index user_lesson_progress_lesson_idx
  on public.user_lesson_progress (lesson_id);

create index user_lesson_progress_user_status_idx
  on public.user_lesson_progress (user_id, status);

create trigger user_lesson_progress_set_updated_at
before update on public.user_lesson_progress
for each row execute function public.set_updated_at();

alter table public.user_lesson_progress enable row level security;

create policy "Users can read their own lesson progress"
on public.user_lesson_progress for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can insert their own lesson progress"
on public.user_lesson_progress for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can update their own lesson progress"
on public.user_lesson_progress for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

revoke all on table public.user_lesson_progress from anon, authenticated;
grant select, insert, update on table public.user_lesson_progress to authenticated;

create function public.start_lesson_progress(p_lesson_id uuid)
returns setof public.user_lesson_progress
language plpgsql
security invoker
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
  accessed_at timestamptz := clock_timestamp();
begin
  if current_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  return query
  insert into public.user_lesson_progress (
    user_id,
    lesson_id,
    status,
    started_at,
    last_accessed_at
  )
  values (
    current_user_id,
    p_lesson_id,
    'in_progress',
    accessed_at,
    accessed_at
  )
  on conflict (user_id, lesson_id) do update set
    status = case
      when public.user_lesson_progress.status = 'completed' then 'completed'
      else 'in_progress'
    end,
    started_at = coalesce(public.user_lesson_progress.started_at, excluded.started_at),
    last_accessed_at = excluded.last_accessed_at
  returning *;
end;
$$;

create function public.complete_lesson_progress(p_lesson_id uuid)
returns setof public.user_lesson_progress
language plpgsql
security invoker
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
  accessed_at timestamptz := clock_timestamp();
begin
  if current_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  return query
  insert into public.user_lesson_progress (
    user_id,
    lesson_id,
    status,
    started_at,
    completed_at,
    last_accessed_at
  )
  values (
    current_user_id,
    p_lesson_id,
    'completed',
    accessed_at,
    accessed_at,
    accessed_at
  )
  on conflict (user_id, lesson_id) do update set
    status = 'completed',
    started_at = coalesce(public.user_lesson_progress.started_at, excluded.started_at),
    completed_at = coalesce(public.user_lesson_progress.completed_at, excluded.completed_at),
    last_accessed_at = excluded.last_accessed_at
  returning *;
end;
$$;

revoke execute on function public.start_lesson_progress(uuid) from public, anon;
revoke execute on function public.complete_lesson_progress(uuid) from public, anon;
grant execute on function public.start_lesson_progress(uuid) to authenticated;
grant execute on function public.complete_lesson_progress(uuid) to authenticated;

commit;

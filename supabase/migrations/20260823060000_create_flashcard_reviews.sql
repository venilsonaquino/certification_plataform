begin;

create table public.flashcard_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  flashcard_id uuid not null references public.flashcards(id) on delete cascade,
  rating text not null,
  reviewed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  constraint flashcard_reviews_rating_check
    check (rating in ('again', 'hard', 'good', 'easy'))
);

create index flashcard_reviews_user_card_reviewed_idx
  on public.flashcard_reviews (user_id, flashcard_id, reviewed_at desc);

create index flashcard_reviews_flashcard_idx
  on public.flashcard_reviews (flashcard_id);

alter table public.flashcard_reviews enable row level security;

create policy "Users can read their own flashcard reviews"
on public.flashcard_reviews for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can insert their own flashcard reviews"
on public.flashcard_reviews for insert
to authenticated
with check ((select auth.uid()) = user_id);

revoke all on table public.flashcard_reviews from anon, authenticated;
grant select on table public.flashcard_reviews to authenticated;

create function public.submit_flashcard_review(
  p_flashcard_id uuid,
  p_rating text
)
returns setof public.flashcard_reviews
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  if p_rating is null or p_rating not in ('again', 'hard', 'good', 'easy') then
    raise exception 'Invalid flashcard review rating.' using errcode = '23514';
  end if;

  if not exists (
    select 1
    from public.flashcards
    where id = p_flashcard_id
      and is_published = true
  ) then
    raise exception 'Published flashcard not found.' using errcode = 'P0002';
  end if;

  return query
  insert into public.flashcard_reviews (
    user_id,
    flashcard_id,
    rating,
    reviewed_at
  )
  values (
    current_user_id,
    p_flashcard_id,
    p_rating,
    clock_timestamp()
  )
  returning *;
end;
$$;

revoke execute on function public.submit_flashcard_review(uuid, text) from public, anon;
grant execute on function public.submit_flashcard_review(uuid, text) to authenticated;

commit;

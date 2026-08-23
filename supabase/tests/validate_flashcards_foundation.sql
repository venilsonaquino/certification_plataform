begin;

do $$
declare
  total_count integer;
  lesson_count integer;
  invalid_relation_count integer;
  invalid_order_count integer;
begin
  select count(*), count(distinct lesson_id)
  into total_count, lesson_count
  from public.flashcards;

  if total_count <> 33 then
    raise exception 'Expected 33 flashcards, found %', total_count;
  end if;

  if lesson_count <> 11 then
    raise exception 'Expected flashcards in 11 lessons, found %', lesson_count;
  end if;

  select count(*)
  into invalid_relation_count
  from public.flashcards flashcards
  left join public.lessons lessons on lessons.id = flashcards.lesson_id
  where lessons.id is null;

  if invalid_relation_count <> 0 then
    raise exception 'Found % flashcards without a valid lesson', invalid_relation_count;
  end if;

  select count(*)
  into invalid_order_count
  from (
    select lesson_id
    from public.flashcards
    group by lesson_id
    having min(display_order) <> 1
      or max(display_order) <> count(*)
      or count(*) <> count(distinct display_order)
  ) invalid_lessons;

  if invalid_order_count <> 0 then
    raise exception 'Found % lessons with invalid flashcard ordering', invalid_order_count;
  end if;
end;
$$;

set local role authenticated;

do $$
declare
  visible_count integer;
begin
  select count(*) into visible_count from public.flashcards;
  if visible_count <> 33 then
    raise exception 'Authenticated role expected 33 published flashcards, found %', visible_count;
  end if;
end;
$$;

reset role;

insert into public.flashcards (
  id, lesson_id, front_text, back_text, display_order, is_published
)
select
  '70000000-0000-4000-8000-000000000099',
  id,
  'Card não publicado',
  'Não deve ficar visível para authenticated.',
  99,
  false
from public.lessons
where slug = 'availability-zones'
limit 1;

set local role authenticated;

do $$
begin
  if exists (
    select 1 from public.flashcards
    where id = '70000000-0000-4000-8000-000000000099'
  ) then
    raise exception 'Unpublished flashcard is visible to authenticated role';
  end if;
end;
$$;

do $$
begin
  insert into public.flashcards (lesson_id, front_text, back_text, display_order)
  select id, 'Tentativa', 'De escrita', 100
  from public.lessons
  limit 1;
  raise exception 'authenticated INSERT unexpectedly succeeded';
exception
  when insufficient_privilege then null;
end;
$$;

do $$
begin
  update public.flashcards set front_text = front_text;
  raise exception 'authenticated UPDATE unexpectedly succeeded';
exception
  when insufficient_privilege then null;
end;
$$;

do $$
begin
  delete from public.flashcards;
  raise exception 'authenticated DELETE unexpectedly succeeded';
exception
  when insufficient_privilege then null;
end;
$$;

rollback;

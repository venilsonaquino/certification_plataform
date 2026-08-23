begin;

do $$
declare
  imported_count integer;
  imported_lesson_count integer;
  published_count integer;
begin
  select
    count(*),
    count(distinct lesson_id),
    count(*) filter (where is_published)
  into imported_count, imported_lesson_count, published_count
  from public.flashcards
  where id::text like '72000000-0000-4000-8000-%';

  if imported_count <> 50 then
    raise exception 'Validação do lote 2 falhou: esperados 50 flashcards, encontrados %.', imported_count;
  end if;
  if imported_lesson_count <> 14 then
    raise exception 'Validação do lote 2 falhou: esperadas 14 lições, encontradas %.', imported_lesson_count;
  end if;
  if published_count <> 50 then
    raise exception 'Validação do lote 2 falhou: esperados 50 flashcards publicados, encontrados %.', published_count;
  end if;
end
$$;

commit;

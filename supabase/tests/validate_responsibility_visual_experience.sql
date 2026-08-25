begin;

do $$
declare
  responsibility_config jsonb;
  target_count integer;
begin
  if not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260825030000'
  ) then
    raise exception 'Migration 20260825030000 is not registered as applied';
  end if;

  select count(*)
  into target_count
  from public.visual_experiences visual
  join public.lessons lesson on lesson.id = visual.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where visual.id = '76000000-0000-4000-8000-000000000004'
    and certification.code = 'az-900'
    and lesson.slug = 'shared-responsibility-model'
    and visual.type = 'responsibility'
    and visual.is_published;

  if target_count <> 1 then
    raise exception 'Responsibility visual targets the wrong certification or lesson';
  end if;

  if (select count(*) from public.visual_experiences where is_published) <> 4 then
    raise exception 'Expected exactly 4 published visual experiences';
  end if;

  if (select count(distinct type) from public.visual_experiences where is_published) <> 4 then
    raise exception 'Expected comparison, architecture, flow and responsibility to remain available';
  end if;

  select config
  into strict responsibility_config
  from public.visual_experiences
  where id = '76000000-0000-4000-8000-000000000004';

  if coalesce(jsonb_typeof(responsibility_config -> 'owners'), '') <> 'object'
    or coalesce(jsonb_typeof(responsibility_config -> 'layers'), '') <> 'array'
    or coalesce(jsonb_typeof(responsibility_config -> 'models'), '') <> 'array'
    or jsonb_array_length(responsibility_config -> 'layers') <> 9
    or jsonb_array_length(responsibility_config -> 'models') <> 4 then
    raise exception 'Responsibility seed has an invalid top-level structure';
  end if;

  if (select array_agg(key order by key) from jsonb_each(responsibility_config -> 'owners'))
    <> array['customer', 'provider', 'shared']::text[] then
    raise exception 'Responsibility seed must define the three owner categories';
  end if;

  if exists (
    select layer_id
    from (
      select layer ->> 'id' as layer_id
      from jsonb_array_elements(responsibility_config -> 'layers') layer
    ) configured_layers
    group by layer_id
    having layer_id is null or count(*) <> 1
  ) then
    raise exception 'Responsibility seed has duplicate or missing layer ids';
  end if;

  if exists (
    select model_id
    from (
      select model ->> 'id' as model_id
      from jsonb_array_elements(responsibility_config -> 'models') model
    ) configured_models
    group by model_id
    having model_id is null or count(*) <> 1
  ) then
    raise exception 'Responsibility seed has duplicate or missing model ids';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(responsibility_config -> 'models') model
    where coalesce(jsonb_typeof(model -> 'responsibilities'), '') <> 'object'
      or exists (
        select layer ->> 'id'
        from jsonb_array_elements(responsibility_config -> 'layers') layer
        except
        select responsibility.key
        from jsonb_each(model -> 'responsibilities') responsibility
      )
      or exists (
        select responsibility.key
        from jsonb_each(model -> 'responsibilities') responsibility
        except
        select layer ->> 'id'
        from jsonb_array_elements(responsibility_config -> 'layers') layer
      )
      or exists (
        select 1
        from jsonb_each_text(model -> 'responsibilities') responsibility
        where responsibility.value not in ('customer', 'provider', 'shared')
      )
  ) then
    raise exception 'A responsibility model has missing, extra or unsupported assignments';
  end if;
end;
$$;

do $$
declare
  target_lesson_id uuid;
begin
  select lesson.id
  into strict target_lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and lesson.slug = 'shared-responsibility-model';

  begin
    insert into public.visual_experiences (
      lesson_id, type, title, description, config, display_order
    ) values (
      target_lesson_id, 'unsupported', 'Invalid type', 'Must be rejected.', '{}'::jsonb, 99
    );
    raise exception 'Unsupported visual type unexpectedly succeeded';
  exception
    when check_violation then null;
  end;
end;
$$;

set local role authenticated;

do $$
begin
  if not exists (
    select 1
    from public.visual_experiences
    where id = '76000000-0000-4000-8000-000000000004'
      and type = 'responsibility'
  ) then
    raise exception 'Authenticated users cannot read the published responsibility visual';
  end if;

  begin
    update public.visual_experiences
    set title = title
    where id = '76000000-0000-4000-8000-000000000004';
    raise exception 'Authenticated UPDATE unexpectedly succeeded';
  exception
    when insufficient_privilege then null;
  end;
end;
$$;

select json_build_object(
  'responsibility_visuals', (
    select count(*) from public.visual_experiences where type = 'responsibility'
  ),
  'layers', (
    select jsonb_array_length(config -> 'layers')
    from public.visual_experiences
    where id = '76000000-0000-4000-8000-000000000004'
  ),
  'models', (
    select jsonb_array_length(config -> 'models')
    from public.visual_experiences
    where id = '76000000-0000-4000-8000-000000000004'
  ),
  'authenticated_writes_denied', true
) as responsibility_visual_validation;

reset role;

rollback;

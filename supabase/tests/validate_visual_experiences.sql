begin;

do $$
declare
  total_count integer;
  target_count integer;
  invalid_config_count integer;
begin
  if to_regclass('public.visual_experiences') is null then
    raise exception 'public.visual_experiences does not exist';
  end if;

  select count(*)
  into total_count
  from public.visual_experiences;

  if total_count <> 6 then
    raise exception 'Expected exactly 6 visual experiences after the Domain 1 enrichment, found %', total_count;
  end if;

  select count(*)
  into target_count
  from public.visual_experiences visual
  join public.lessons lesson on lesson.id = visual.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and (
      (visual.id = '76000000-0000-4000-8000-000000000001'
        and lesson.slug = 'choosing-iaas-paas-saas'
        and visual.type = 'comparison')
      or (visual.id = '76000000-0000-4000-8000-000000000002'
        and lesson.slug = 'availability-zones'
        and visual.type = 'architecture')
      or (visual.id = '76000000-0000-4000-8000-000000000003'
        and lesson.slug = 'entra-id-and-domain-services'
        and visual.type = 'flow')
    );

  if target_count <> 3 then
    raise exception 'One or more visual experience seeds target the wrong certification, lesson or type';
  end if;

  select count(*)
  into invalid_config_count
  from public.visual_experiences
  where coalesce(jsonb_typeof(config), '') <> 'object';

  if invalid_config_count <> 0 then
    raise exception 'Found % visual experiences whose config is not an object', invalid_config_count;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.visual_experiences'::regclass
      and contype = 'f'
      and confrelid = 'public.lessons'::regclass
      and confdeltype = 'c'
  ) then
    raise exception 'visual_experiences.lesson_id must reference lessons with ON DELETE CASCADE';
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.visual_experiences'::regclass
      and conname = 'visual_experiences_type_check'
      and contype = 'c'
  ) then
    raise exception 'visual_experiences type CHECK constraint is missing';
  end if;

  if to_regclass('public.visual_experiences_published_lesson_order_idx') is null then
    raise exception 'Published visual experiences index is missing';
  end if;

  if not exists (
    select 1
    from pg_trigger
    where tgrelid = 'public.visual_experiences'::regclass
      and tgname = 'visual_experiences_set_updated_at'
      and not tgisinternal
  ) then
    raise exception 'visual_experiences updated_at trigger is missing';
  end if;

  if not (
    select relrowsecurity
    from pg_class
    where oid = 'public.visual_experiences'::regclass
  ) then
    raise exception 'RLS is not enabled on visual_experiences';
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'visual_experiences'
      and policyname = 'Authenticated users can read published visual experiences'
      and cmd = 'SELECT'
      and roles = array['authenticated']::name[]
  ) then
    raise exception 'Authenticated published SELECT policy is missing';
  end if;

  if exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'visual_experiences'
      and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')
  ) then
    raise exception 'visual_experiences unexpectedly has a write policy';
  end if;

  if not exists (
    select 1
    from information_schema.role_table_grants
    where table_schema = 'public'
      and table_name = 'visual_experiences'
      and grantee = 'authenticated'
      and privilege_type = 'SELECT'
  ) then
    raise exception 'authenticated SELECT grant is missing';
  end if;

  if exists (
    select 1
    from information_schema.role_table_grants
    where table_schema = 'public'
      and table_name = 'visual_experiences'
      and grantee in ('anon', 'authenticated')
      and privilege_type in ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')
  ) then
    raise exception 'anon or authenticated unexpectedly has a write grant';
  end if;

  if not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260825020000'
  ) then
    raise exception 'Migration 20260825020000 is not registered as applied';
  end if;
end;
$$;

do $$
declare
  comparison_config jsonb;
  architecture_config jsonb;
  flow_config jsonb;
begin
  select config
  into strict comparison_config
  from public.visual_experiences
  where id = '76000000-0000-4000-8000-000000000001';

  if coalesce(jsonb_typeof(comparison_config -> 'columns'), '') <> 'array'
    or coalesce(jsonb_typeof(comparison_config -> 'rows'), '') <> 'array'
    or jsonb_array_length(comparison_config -> 'columns') <> 3
    or jsonb_array_length(comparison_config -> 'rows') <> 4 then
    raise exception 'Comparison seed does not have the expected columns and rows';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(comparison_config -> 'columns') column_config
    where coalesce(jsonb_typeof(column_config -> 'id'), '') <> 'string'
      or coalesce(jsonb_typeof(column_config -> 'title'), '') <> 'string'
      or (
        column_config ? 'description'
        and coalesce(jsonb_typeof(column_config -> 'description'), '') <> 'string'
      )
  ) then
    raise exception 'Comparison seed has an invalid column';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(comparison_config -> 'rows') row_config
    where coalesce(jsonb_typeof(row_config -> 'id'), '') <> 'string'
      or coalesce(jsonb_typeof(row_config -> 'label'), '') <> 'string'
      or coalesce(jsonb_typeof(row_config -> 'values'), '') <> 'object'
      or (
        row_config ? 'description'
        and coalesce(jsonb_typeof(row_config -> 'description'), '') <> 'string'
      )
      or exists (
        select 1
        from jsonb_each(row_config -> 'values') value_entry
        where coalesce(jsonb_typeof(value_entry.value), '') <> 'string'
      )
  ) then
    raise exception 'Comparison seed has an invalid row';
  end if;

  if exists (
    select column_id
    from (
      select column_config ->> 'id' as column_id
      from jsonb_array_elements(comparison_config -> 'columns') column_config
    ) columns
    group by column_id
    having column_id is null or count(*) <> 1
  ) then
    raise exception 'Comparison seed has duplicate or missing column ids';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(comparison_config -> 'rows') row_config
    where exists (
      select column_config ->> 'id'
      from jsonb_array_elements(comparison_config -> 'columns') column_config
      except
      select value_entry.key
      from jsonb_each(row_config -> 'values') value_entry
    )
      or exists (
        select value_entry.key
        from jsonb_each(row_config -> 'values') value_entry
        except
        select column_config ->> 'id'
        from jsonb_array_elements(comparison_config -> 'columns') column_config
      )
  ) then
    raise exception 'Comparison row values do not match the configured columns';
  end if;

  select config
  into strict architecture_config
  from public.visual_experiences
  where id = '76000000-0000-4000-8000-000000000002';

  if coalesce(jsonb_typeof(architecture_config -> 'nodes'), '') <> 'array'
    or coalesce(jsonb_typeof(architecture_config -> 'edges'), '') <> 'array'
    or jsonb_array_length(architecture_config -> 'nodes') <> 7
    or jsonb_array_length(architecture_config -> 'edges') <> 6 then
    raise exception 'Architecture seed does not have the expected nodes and edges';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(architecture_config -> 'nodes') node_config
    where coalesce(jsonb_typeof(node_config -> 'id'), '') <> 'string'
      or coalesce(jsonb_typeof(node_config -> 'label'), '') <> 'string'
      or coalesce(jsonb_typeof(node_config -> 'kind'), '') <> 'string'
      or node_config ->> 'kind' not in ('external', 'service', 'group', 'zone', 'resource')
      or (
        node_config ? 'description'
        and coalesce(jsonb_typeof(node_config -> 'description'), '') <> 'string'
      )
      or (
        node_config ? 'x'
        and coalesce(jsonb_typeof(node_config -> 'x'), '') <> 'number'
      )
      or (
        node_config ? 'y'
        and coalesce(jsonb_typeof(node_config -> 'y'), '') <> 'number'
      )
  ) then
    raise exception 'Architecture seed has an invalid node';
  end if;

  if exists (
    select node_id
    from (
      select node_config ->> 'id' as node_id
      from jsonb_array_elements(architecture_config -> 'nodes') node_config
    ) nodes
    group by node_id
    having node_id is null or count(*) <> 1
  ) then
    raise exception 'Architecture seed has duplicate or missing node ids';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(architecture_config -> 'edges') edge_config
    where coalesce(jsonb_typeof(edge_config -> 'id'), '') <> 'string'
      or coalesce(jsonb_typeof(edge_config -> 'source'), '') <> 'string'
      or coalesce(jsonb_typeof(edge_config -> 'target'), '') <> 'string'
      or (
        edge_config ? 'label'
        and coalesce(jsonb_typeof(edge_config -> 'label'), '') <> 'string'
      )
      or not exists (
        select 1
        from jsonb_array_elements(architecture_config -> 'nodes') source_node
        where source_node ->> 'id' = edge_config ->> 'source'
      )
      or not exists (
        select 1
        from jsonb_array_elements(architecture_config -> 'nodes') target_node
        where target_node ->> 'id' = edge_config ->> 'target'
      )
  ) then
    raise exception 'Architecture seed has an invalid edge or dangling endpoint';
  end if;

  select config
  into strict flow_config
  from public.visual_experiences
  where id = '76000000-0000-4000-8000-000000000003';

  if coalesce(jsonb_typeof(flow_config -> 'steps'), '') <> 'array'
    or jsonb_array_length(flow_config -> 'steps') <> 5 then
    raise exception 'Flow seed does not have the expected steps';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(flow_config -> 'steps') step_config
    where coalesce(jsonb_typeof(step_config -> 'id'), '') <> 'string'
      or coalesce(jsonb_typeof(step_config -> 'label'), '') <> 'string'
      or (
        step_config ? 'description'
        and coalesce(jsonb_typeof(step_config -> 'description'), '') <> 'string'
      )
  ) then
    raise exception 'Flow seed has an invalid step';
  end if;

  if exists (
    select step_id
    from (
      select step_config ->> 'id' as step_id
      from jsonb_array_elements(flow_config -> 'steps') step_config
    ) steps
    group by step_id
    having step_id is null or count(*) <> 1
  ) then
    raise exception 'Flow seed has duplicate or missing step ids';
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
    and lesson.slug = 'choosing-iaas-paas-saas';

  begin
    insert into public.visual_experiences (
      lesson_id, type, title, description, config, display_order
    ) values (
      'ffffffff-ffff-4fff-8fff-ffffffffffff',
      'comparison',
      'Invalid foreign key',
      'Must be rejected.',
      '{"columns": [], "rows": []}'::jsonb,
      90
    );
    raise exception 'Invalid lesson foreign key unexpectedly succeeded';
  exception
    when foreign_key_violation then null;
  end;

  begin
    insert into public.visual_experiences (
      lesson_id, type, title, description, config, display_order
    ) values (
      target_lesson_id,
      'network',
      'Invalid type',
      'Must be rejected.',
      '{}'::jsonb,
      90
    );
    raise exception 'Unsupported visual type unexpectedly succeeded';
  exception
    when check_violation then null;
  end;

  begin
    insert into public.visual_experiences (
      lesson_id, type, title, description, config, display_order
    ) values (
      target_lesson_id,
      'comparison',
      'Invalid config',
      'Must be rejected.',
      '[]'::jsonb,
      90
    );
    raise exception 'Non-object config unexpectedly succeeded';
  exception
    when check_violation then null;
  end;

  begin
    insert into public.visual_experiences (
      lesson_id, type, title, description, config, display_order
    ) values (
      target_lesson_id,
      'comparison',
      'JSON null config',
      'Must be rejected.',
      'null'::jsonb,
      90
    );
    raise exception 'JSON null config unexpectedly succeeded';
  exception
    when check_violation then null;
  end;

  begin
    insert into public.visual_experiences (
      lesson_id, type, title, description, config, display_order
    ) values (
      target_lesson_id,
      'flow',
      'Invalid order',
      'Must be rejected.',
      '{"steps": []}'::jsonb,
      -1
    );
    raise exception 'Negative display_order unexpectedly succeeded';
  exception
    when check_violation then null;
  end;

  begin
    insert into public.visual_experiences (
      lesson_id, type, title, description, config, display_order
    ) values (
      target_lesson_id,
      'flow',
      'Duplicate order',
      'Must be rejected.',
      '{"steps": []}'::jsonb,
      1
    );
    raise exception 'Duplicate lesson display_order unexpectedly succeeded';
  exception
    when unique_violation then null;
  end;
end;
$$;

insert into public.visual_experiences (
  id,
  lesson_id,
  type,
  title,
  description,
  config,
  display_order,
  is_published
)
select
  '76000000-0000-4000-8000-999999999999',
  lesson.id,
  'flow',
  'Unpublished RLS test',
  'This row must stay invisible to authenticated users.',
  '{"steps": [{"id": "hidden", "label": "Hidden"}]}'::jsonb,
  99,
  false
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and lesson.slug = 'choosing-iaas-paas-saas';

set local role authenticated;

do $$
begin
  if (select count(*) from public.visual_experiences) <> 6 then
    raise exception 'Authenticated users should see exactly the 6 published visual experiences';
  end if;

  if exists (
    select 1
    from public.visual_experiences
    where id = '76000000-0000-4000-8000-999999999999'
  ) then
    raise exception 'An unpublished visual experience is visible to authenticated users';
  end if;

  begin
    insert into public.visual_experiences (
      lesson_id, type, title, description, config, display_order
    )
    select
      id,
      'flow',
      'Authenticated insert',
      'Must be rejected.',
      '{"steps": []}'::jsonb,
      100
    from public.lessons
    limit 1;
    raise exception 'Authenticated INSERT unexpectedly succeeded';
  exception
    when insufficient_privilege then null;
  end;

  begin
    update public.visual_experiences
    set title = title;
    raise exception 'Authenticated UPDATE unexpectedly succeeded';
  exception
    when insufficient_privilege then null;
  end;

  begin
    delete from public.visual_experiences;
    raise exception 'Authenticated DELETE unexpectedly succeeded';
  exception
    when insufficient_privilege then null;
  end;
end;
$$;

select json_build_object(
  'visual_experiences', (select count(*) from public.visual_experiences),
  'published_visual_experiences', (
    select count(*) from public.visual_experiences where is_published
  ),
  'types', (
    select json_agg(type order by type)
    from public.visual_experiences
    where id in (
      '76000000-0000-4000-8000-000000000001',
      '76000000-0000-4000-8000-000000000002',
      '76000000-0000-4000-8000-000000000003'
    )
  ),
  'unpublished_hidden_from_authenticated', true,
  'authenticated_writes_denied', true
) as visual_experiences_validation;

reset role;

rollback;

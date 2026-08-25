begin;

do $$
begin
  if to_regclass('public.lesson_content_blocks') is null then
    raise exception 'public.lesson_content_blocks does not exist';
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'lesson_content_blocks'
      and column_name = 'visual_experience_id'
      and data_type = 'uuid'
      and is_nullable = 'YES'
  ) then
    raise exception 'lesson_content_blocks.visual_experience_id is missing or invalid';
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.lesson_content_blocks'::regclass
      and conname = 'lesson_content_blocks_lesson_id_fkey'
      and confrelid = 'public.lessons'::regclass
      and confdeltype = 'c'
  ) then
    raise exception 'lesson_content_blocks.lesson_id cascade FK is missing';
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.lesson_content_blocks'::regclass
      and conname = 'lesson_content_blocks_visual_experience_lesson_fkey'
      and confrelid = 'public.visual_experiences'::regclass
      and confdeltype = 'c'
  ) then
    raise exception 'Composite visual experience cascade FK is missing';
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.lesson_content_blocks'::regclass
      and conname = 'lesson_content_blocks_type_check'
      and contype = 'c'
  ) or not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.lesson_content_blocks'::regclass
      and conname = 'lesson_content_blocks_visual_experience_shape_check'
      and contype = 'c'
  ) or not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.lesson_content_blocks'::regclass
      and conname = 'lesson_content_blocks_lesson_order_unique'
      and contype = 'u'
  ) then
    raise exception 'One or more lesson content block constraints are missing';
  end if;

  if to_regclass('public.lesson_content_blocks_published_lesson_order_idx') is null then
    raise exception 'Published lesson/order index is missing';
  end if;

  if to_regclass('public.lesson_content_blocks_visual_experience_idx') is null then
    raise exception 'Visual experience reference index is missing';
  end if;

  if not exists (
    select 1
    from pg_trigger
    where tgrelid = 'public.lesson_content_blocks'::regclass
      and tgname = 'lesson_content_blocks_set_updated_at'
      and not tgisinternal
  ) then
    raise exception 'lesson_content_blocks updated_at trigger is missing';
  end if;

  if not (
    select relrowsecurity
    from pg_class
    where oid = 'public.lesson_content_blocks'::regclass
  ) then
    raise exception 'RLS is not enabled on lesson_content_blocks';
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'lesson_content_blocks'
      and policyname = 'Authenticated users can read published lesson content blocks'
      and cmd = 'SELECT'
      and roles = array['authenticated']::name[]
      and qual like '%is_published%'
      and qual like '%true%'
  ) then
    raise exception 'Authenticated published SELECT policy is missing or invalid';
  end if;

  if exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'lesson_content_blocks'
      and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')
  ) then
    raise exception 'lesson_content_blocks unexpectedly has a write policy';
  end if;

  if not exists (
    select 1
    from information_schema.role_table_grants
    where table_schema = 'public'
      and table_name = 'lesson_content_blocks'
      and grantee = 'authenticated'
      and privilege_type = 'SELECT'
  ) then
    raise exception 'authenticated SELECT grant is missing';
  end if;

  if exists (
    select 1
    from information_schema.role_table_grants
    where table_schema = 'public'
      and table_name = 'lesson_content_blocks'
      and grantee in ('anon', 'authenticated')
      and privilege_type in ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')
  ) then
    raise exception 'anon or authenticated unexpectedly has a write grant';
  end if;

  if not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260825040000'
  ) or not exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260825050000'
  ) then
    raise exception 'Lesson content block migrations are not registered as applied';
  end if;
end;
$$;

do $$
declare
  target_lesson_id uuid;
  other_lesson_id uuid;
  target_visual_experience_id uuid;
  next_order integer;
  other_next_order integer;
  ordered_types text[];
  previous_updated_at timestamptz;
  current_updated_at timestamptz;
begin
  select lesson.id, visual.id
  into strict target_lesson_id, target_visual_experience_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  join public.visual_experiences visual on visual.lesson_id = lesson.id
  where certification.code = 'az-900'
    and lesson.slug = 'shared-responsibility-model'
    and visual.type = 'responsibility';

  select id
  into strict other_lesson_id
  from public.lessons
  where id <> target_lesson_id
  order by id
  limit 1;

  select coalesce(max(display_order), -1) + 100
  into next_order
  from public.lesson_content_blocks
  where lesson_id = target_lesson_id;

  select coalesce(max(display_order), -1) + 100
  into other_next_order
  from public.lesson_content_blocks
  where lesson_id = other_lesson_id;

  insert into public.lesson_content_blocks (
    id, lesson_id, type, title, content, display_order, is_published
  ) values
    (
      '78000000-0000-4000-8000-000000000001', target_lesson_id,
      'explanation', 'Primeiro', 'Conteúdo publicado.', next_order, true
    ),
    (
      '78000000-0000-4000-8000-000000000002', target_lesson_id,
      'important', 'Oculto', 'Conteúdo não publicado.', next_order + 1, false
    );

  insert into public.lesson_content_blocks (
    id, lesson_id, type, visual_experience_id, display_order, is_published
  ) values (
    '78000000-0000-4000-8000-000000000003', target_lesson_id,
    'visual_experience', target_visual_experience_id, next_order + 2, true
  );

  select array_agg(type order by display_order)
  into ordered_types
  from public.lesson_content_blocks
  where id in (
    '78000000-0000-4000-8000-000000000001',
    '78000000-0000-4000-8000-000000000002',
    '78000000-0000-4000-8000-000000000003'
  );

  if ordered_types <> array['explanation', 'important', 'visual_experience']::text[] then
    raise exception 'Content blocks are not ordered by display_order: %', ordered_types;
  end if;

  select updated_at into strict previous_updated_at
  from public.lesson_content_blocks
  where id = '78000000-0000-4000-8000-000000000001';

  update public.lesson_content_blocks
  set title = 'Primeiro atualizado', updated_at = '2000-01-01'::timestamptz
  where id = '78000000-0000-4000-8000-000000000001';

  select updated_at into strict current_updated_at
  from public.lesson_content_blocks
  where id = '78000000-0000-4000-8000-000000000001';

  if current_updated_at < previous_updated_at
    or current_updated_at = '2000-01-01'::timestamptz then
    raise exception 'updated_at trigger did not override the supplied timestamp';
  end if;

  begin
    insert into public.lesson_content_blocks (
      lesson_id, type, content, display_order
    ) values (
      target_lesson_id, 'quiz', 'Unsupported type.', next_order + 10
    );
    raise exception 'Unsupported block type unexpectedly succeeded';
  exception when check_violation then null;
  end;

  begin
    insert into public.lesson_content_blocks (
      lesson_id, type, content, display_order
    ) values (
      target_lesson_id, 'explanation', 'Invalid order.', -1
    );
    raise exception 'Negative display_order unexpectedly succeeded';
  exception when check_violation then null;
  end;

  begin
    insert into public.lesson_content_blocks (
      lesson_id, type, config, visual_experience_id, display_order
    ) values (
      target_lesson_id, 'visual_experience', '{}',
      target_visual_experience_id, next_order + 11
    );
    raise exception 'Duplicated visual config unexpectedly succeeded';
  exception when check_violation then null;
  end;

  begin
    insert into public.lesson_content_blocks (
      lesson_id, type, visual_experience_id, display_order
    ) values (
      other_lesson_id, 'visual_experience',
      target_visual_experience_id, other_next_order
    );
    raise exception 'Cross-lesson visual reference unexpectedly succeeded';
  exception when foreign_key_violation then null;
  end;
end;
$$;

set local role authenticated;

do $$
begin
  if (
    select count(*)
    from public.lesson_content_blocks
    where id in (
      '78000000-0000-4000-8000-000000000001',
      '78000000-0000-4000-8000-000000000002',
      '78000000-0000-4000-8000-000000000003'
    )
  ) <> 2 then
    raise exception 'Authenticated users should see exactly the two published test blocks';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where id = '78000000-0000-4000-8000-000000000002'
  ) then
    raise exception 'Unpublished lesson content block is visible to authenticated users';
  end if;

  begin
    insert into public.lesson_content_blocks (lesson_id, type, content, display_order)
    select id, 'explanation', 'Authenticated insert.', 99999
    from public.lessons
    limit 1;
    raise exception 'Authenticated INSERT unexpectedly succeeded';
  exception when insufficient_privilege then null;
  end;

  begin
    update public.lesson_content_blocks set title = title;
    raise exception 'Authenticated UPDATE unexpectedly succeeded';
  exception when insufficient_privilege then null;
  end;

  begin
    delete from public.lesson_content_blocks;
    raise exception 'Authenticated DELETE unexpectedly succeeded';
  exception when insufficient_privilege then null;
  end;
end;
$$;

reset role;

select json_build_object(
  'rls_published_only', true,
  'authenticated_writes_denied', true,
  'display_order_validated', true,
  'visual_fk_same_lesson_validated', true,
  'shared_responsibility_ready_for_blocks', true
) as lesson_content_blocks_validation;

rollback;

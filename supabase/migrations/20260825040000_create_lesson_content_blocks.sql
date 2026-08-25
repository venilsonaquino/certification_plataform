begin;

create table public.lesson_content_blocks (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  type text not null,
  title text,
  content text,
  config jsonb,
  display_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint lesson_content_blocks_type_check
    check (
      type in (
        'explanation',
        'important',
        'example',
        'dotnet_example',
        'exam_tip',
        'exam_trap',
        'summary',
        'image',
        'video',
        'visual_experience',
        'azure_lab'
      )
    ),
  constraint lesson_content_blocks_title_check
    check (title is null or btrim(title) <> ''),
  constraint lesson_content_blocks_content_check
    check (content is null or btrim(content) <> ''),
  constraint lesson_content_blocks_config_object_check
    check (config is null or coalesce(jsonb_typeof(config) = 'object', false)),
  constraint lesson_content_blocks_payload_check
    check (content is not null or config is not null),
  constraint lesson_content_blocks_text_content_check
    check (
      type not in (
        'explanation',
        'important',
        'example',
        'dotnet_example',
        'exam_tip',
        'exam_trap'
      )
      or content is not null
    ),
  constraint lesson_content_blocks_summary_payload_check
    check (
      type <> 'summary'
      or content is not null
      or case
        when jsonb_typeof(config -> 'items') = 'array'
          then jsonb_array_length(config -> 'items') > 0
        else false
      end
    ),
  constraint lesson_content_blocks_display_order_check
    check (display_order >= 0),
  constraint lesson_content_blocks_lesson_order_unique
    unique (lesson_id, display_order) deferrable initially immediate
);

create index lesson_content_blocks_published_lesson_order_idx
  on public.lesson_content_blocks (lesson_id, display_order)
  where is_published = true;

create trigger lesson_content_blocks_set_updated_at
before update on public.lesson_content_blocks
for each row execute function public.set_updated_at();

alter table public.lesson_content_blocks enable row level security;

create policy "Authenticated users can read published lesson content blocks"
on public.lesson_content_blocks for select
to authenticated
using (is_published = true);

revoke all on table public.lesson_content_blocks from anon, authenticated;
grant select on table public.lesson_content_blocks to authenticated;

commit;

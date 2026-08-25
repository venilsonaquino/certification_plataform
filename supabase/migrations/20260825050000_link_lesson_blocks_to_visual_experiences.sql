begin;

alter table public.visual_experiences
  add constraint visual_experiences_id_lesson_unique
  unique (id, lesson_id);

alter table public.lesson_content_blocks
  add column visual_experience_id uuid;

alter table public.lesson_content_blocks
  drop constraint lesson_content_blocks_payload_check;

alter table public.lesson_content_blocks
  add constraint lesson_content_blocks_payload_check
  check (
    content is not null
    or config is not null
    or visual_experience_id is not null
  );

alter table public.lesson_content_blocks
  add constraint lesson_content_blocks_visual_experience_shape_check
  check (
    (
      type = 'visual_experience'
      and visual_experience_id is not null
      and content is null
      and config is null
    )
    or (
      type <> 'visual_experience'
      and visual_experience_id is null
    )
  );

alter table public.lesson_content_blocks
  add constraint lesson_content_blocks_visual_experience_lesson_fkey
  foreign key (visual_experience_id, lesson_id)
  references public.visual_experiences (id, lesson_id)
  on delete cascade;

create index lesson_content_blocks_visual_experience_idx
  on public.lesson_content_blocks (visual_experience_id)
  where visual_experience_id is not null;

commit;

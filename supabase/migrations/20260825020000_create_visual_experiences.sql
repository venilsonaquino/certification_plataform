begin;

create table public.visual_experiences (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  type text not null,
  title text not null,
  description text not null,
  config jsonb not null,
  display_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint visual_experiences_type_check
    check (type in ('comparison', 'architecture', 'flow')),
  constraint visual_experiences_title_check
    check (btrim(title) <> ''),
  constraint visual_experiences_description_check
    check (btrim(description) <> ''),
  constraint visual_experiences_config_object_check
    check (coalesce(jsonb_typeof(config) = 'object', false)),
  constraint visual_experiences_display_order_check
    check (display_order >= 0),
  constraint visual_experiences_lesson_order_unique
    unique (lesson_id, display_order)
);

create index visual_experiences_published_lesson_order_idx
  on public.visual_experiences (lesson_id, display_order)
  where is_published = true;

create trigger visual_experiences_set_updated_at
before update on public.visual_experiences
for each row execute function public.set_updated_at();

alter table public.visual_experiences enable row level security;

create policy "Authenticated users can read published visual experiences"
on public.visual_experiences for select
to authenticated
using (is_published = true);

revoke all on table public.visual_experiences from anon, authenticated;
grant select on table public.visual_experiences to authenticated;

create temporary table visual_experience_seed (
  id uuid primary key,
  certification_code text not null,
  lesson_slug text not null,
  type text not null,
  title text not null,
  description text not null,
  config jsonb not null,
  display_order integer not null,
  is_published boolean not null
) on commit drop;

insert into visual_experience_seed (
  id,
  certification_code,
  lesson_slug,
  type,
  title,
  description,
  config,
  display_order,
  is_published
)
values
  (
    '76000000-0000-4000-8000-000000000001',
    'az-900',
    'choosing-iaas-paas-saas',
    'comparison',
    'IaaS, PaaS e SaaS',
    'Compare quem gerencia cada camada nos três principais modelos de serviço em nuvem.',
    $json$
    {
      "columns": [
        {
          "id": "iaas",
          "title": "IaaS",
          "description": "Maior controle do cliente sobre o ambiente."
        },
        {
          "id": "paas",
          "title": "PaaS",
          "description": "Plataforma gerenciada para criar e publicar aplicações."
        },
        {
          "id": "saas",
          "title": "SaaS",
          "description": "Aplicação pronta administrada pelo provedor."
        }
      ],
      "rows": [
        {
          "id": "infrastructure",
          "label": "Infraestrutura",
          "description": "Hardware, rede e virtualização subjacentes.",
          "values": {
            "iaas": "Microsoft gerencia",
            "paas": "Microsoft gerencia",
            "saas": "Microsoft gerencia"
          }
        },
        {
          "id": "operating-system",
          "label": "Sistema operacional",
          "values": {
            "iaas": "Cliente gerencia",
            "paas": "Microsoft gerencia",
            "saas": "Microsoft gerencia"
          }
        },
        {
          "id": "runtime",
          "label": "Runtime",
          "values": {
            "iaas": "Cliente gerencia",
            "paas": "Microsoft gerencia",
            "saas": "Microsoft gerencia"
          }
        },
        {
          "id": "application",
          "label": "Aplicação",
          "values": {
            "iaas": "Cliente gerencia",
            "paas": "Cliente gerencia",
            "saas": "Microsoft gerencia"
          }
        },
        {
          "id": "data",
          "label": "Dados e acesso",
          "description": "O cliente mantém responsabilidade sobre seus dados e identidades.",
          "values": {
            "iaas": "Cliente gerencia",
            "paas": "Cliente gerencia",
            "saas": "Cliente gerencia"
          }
        }
      ]
    }
    $json$::jsonb,
    1,
    true
  ),
  (
    '76000000-0000-4000-8000-000000000002',
    'az-900',
    'availability-zones',
    'architecture',
    'Região do Azure e zonas de disponibilidade',
    'Uma região compatível pode conter zonas fisicamente separadas com energia, rede e refrigeração independentes.',
    $json$
    {
      "nodes": [
        {
          "id": "azure-region",
          "label": "Azure Region",
          "kind": "group",
          "description": "Área geográfica que reúne um ou mais datacenters do Azure.",
          "x": 50,
          "y": 12
        },
        {
          "id": "zone-1",
          "label": "Availability Zone 1",
          "kind": "zone",
          "description": "Local físico independente dentro da região.",
          "x": 18,
          "y": 68
        },
        {
          "id": "zone-2",
          "label": "Availability Zone 2",
          "kind": "zone",
          "description": "Local físico independente dentro da região.",
          "x": 50,
          "y": 68
        },
        {
          "id": "zone-3",
          "label": "Availability Zone 3",
          "kind": "zone",
          "description": "Local físico independente dentro da região.",
          "x": 82,
          "y": 68
        }
      ],
      "edges": [
        {
          "id": "region-zone-1",
          "source": "azure-region",
          "target": "zone-1",
          "label": "contém"
        },
        {
          "id": "region-zone-2",
          "source": "azure-region",
          "target": "zone-2",
          "label": "contém"
        },
        {
          "id": "region-zone-3",
          "source": "azure-region",
          "target": "zone-3",
          "label": "contém"
        }
      ]
    }
    $json$::jsonb,
    1,
    true
  ),
  (
    '76000000-0000-4000-8000-000000000003',
    'az-900',
    'entra-id-and-domain-services',
    'flow',
    'Fluxo de autenticação com Microsoft Entra ID',
    'Acompanhe como uma identidade é autenticada e recebe um token para acessar uma aplicação.',
    $json$
    {
      "steps": [
        {
          "id": "user",
          "label": "Usuário",
          "description": "Pessoa que deseja acessar a aplicação."
        },
        {
          "id": "sign-in",
          "label": "Entrar",
          "description": "O usuário informa ou comprova suas credenciais."
        },
        {
          "id": "entra-id",
          "label": "Microsoft Entra ID",
          "description": "O serviço de identidade valida a autenticação."
        },
        {
          "id": "token",
          "label": "Token",
          "description": "Uma credencial de acesso é emitida após a autenticação."
        },
        {
          "id": "application",
          "label": "Aplicação",
          "description": "A aplicação usa o token para reconhecer a identidade e avaliar o acesso."
        }
      ]
    }
    $json$::jsonb,
    1,
    true
  );

do $$
declare
  invalid_targets text;
begin
  select string_agg(
    format(
      '%s/%s (%s lessons found)',
      target.certification_code,
      target.lesson_slug,
      target.lesson_count
    ),
    ', '
    order by target.certification_code, target.lesson_slug
  )
  into invalid_targets
  from (
    select
      seed.id,
      seed.certification_code,
      seed.lesson_slug,
      count(distinct lesson.id) as lesson_count
    from visual_experience_seed seed
    left join public.certifications certification
      on certification.code = seed.certification_code
    left join public.domains domain
      on domain.certification_id = certification.id
    left join public.topics topic
      on topic.domain_id = domain.id
    left join public.lessons lesson
      on lesson.topic_id = topic.id
     and lesson.slug = seed.lesson_slug
    group by seed.id, seed.certification_code, seed.lesson_slug
    having count(distinct lesson.id) <> 1
  ) target;

  if invalid_targets is not null then
    raise exception 'Visual experience seed has missing or ambiguous lesson targets: %', invalid_targets;
  end if;
end;
$$;

with resolved_seed as (
  select
    seed.id,
    lesson.id as lesson_id,
    seed.type,
    seed.title,
    seed.description,
    seed.config,
    seed.display_order,
    seed.is_published
  from visual_experience_seed seed
  join public.certifications certification
    on certification.code = seed.certification_code
  join public.domains domain
    on domain.certification_id = certification.id
  join public.topics topic
    on topic.domain_id = domain.id
  join public.lessons lesson
    on lesson.topic_id = topic.id
   and lesson.slug = seed.lesson_slug
)
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
  id,
  lesson_id,
  type,
  title,
  description,
  config,
  display_order,
  is_published
from resolved_seed
order by id
on conflict (id) do update set
  lesson_id = excluded.lesson_id,
  type = excluded.type,
  title = excluded.title,
  description = excluded.description,
  config = excluded.config,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

do $$
declare
  inserted_seed_count integer;
begin
  select count(*)
  into inserted_seed_count
  from public.visual_experiences
  where id in (
    '76000000-0000-4000-8000-000000000001',
    '76000000-0000-4000-8000-000000000002',
    '76000000-0000-4000-8000-000000000003'
  );

  if inserted_seed_count <> 3 then
    raise exception 'Expected 3 visual experience seeds, found %', inserted_seed_count;
  end if;
end;
$$;

commit;

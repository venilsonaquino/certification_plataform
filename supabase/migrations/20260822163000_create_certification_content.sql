begin;

create table public.certifications (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  provider text not null,
  description text,
  level text,
  is_enabled boolean not null default false,
  display_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint certifications_code_format_check
    check (code = lower(code) and code ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  constraint certifications_display_order_check check (display_order >= 0)
);

create table public.domains (
  id uuid primary key default gen_random_uuid(),
  certification_id uuid not null references public.certifications(id) on delete cascade,
  title text not null,
  description text,
  exam_weight_min smallint,
  exam_weight_max smallint,
  display_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint domains_certification_title_unique unique (certification_id, title),
  constraint domains_exam_weight_pair_check check (
    (exam_weight_min is null and exam_weight_max is null)
    or (exam_weight_min is not null and exam_weight_max is not null)
  ),
  constraint domains_exam_weight_range_check check (
    exam_weight_min is null
    or (
      exam_weight_min between 0 and 100
      and exam_weight_max between 0 and 100
      and exam_weight_min <= exam_weight_max
    )
  ),
  constraint domains_display_order_check check (display_order >= 0)
);

create table public.topics (
  id uuid primary key default gen_random_uuid(),
  domain_id uuid not null references public.domains(id) on delete cascade,
  title text not null,
  description text,
  display_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint topics_domain_title_unique unique (domain_id, title),
  constraint topics_display_order_check check (display_order >= 0)
);

create table public.lessons (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references public.topics(id) on delete cascade,
  slug text not null,
  title text not null,
  short_description text,
  content text,
  estimated_minutes integer,
  display_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint lessons_topic_slug_unique unique (topic_id, slug),
  constraint lessons_slug_format_check
    check (slug = lower(slug) and slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  constraint lessons_estimated_minutes_check
    check (estimated_minutes is null or estimated_minutes > 0),
  constraint lessons_display_order_check check (display_order >= 0)
);

create index domains_certification_order_idx
  on public.domains (certification_id, display_order);

create index topics_domain_order_idx
  on public.topics (domain_id, display_order);

create index lessons_topic_order_idx
  on public.lessons (topic_id, display_order);

create index lessons_published_idx
  on public.lessons (topic_id, is_published)
  where is_published = true;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger certifications_set_updated_at
before update on public.certifications
for each row execute function public.set_updated_at();

create trigger domains_set_updated_at
before update on public.domains
for each row execute function public.set_updated_at();

create trigger topics_set_updated_at
before update on public.topics
for each row execute function public.set_updated_at();

create trigger lessons_set_updated_at
before update on public.lessons
for each row execute function public.set_updated_at();

alter table public.certifications enable row level security;
alter table public.domains enable row level security;
alter table public.topics enable row level security;
alter table public.lessons enable row level security;

create policy "Authenticated users can read certifications"
on public.certifications for select
to authenticated
using (true);

create policy "Authenticated users can read domains"
on public.domains for select
to authenticated
using (true);

create policy "Authenticated users can read topics"
on public.topics for select
to authenticated
using (true);

create policy "Authenticated users can read lessons"
on public.lessons for select
to authenticated
using (true);

revoke all on table public.certifications from anon, authenticated;
revoke all on table public.domains from anon, authenticated;
revoke all on table public.topics from anon, authenticated;
revoke all on table public.lessons from anon, authenticated;

grant select on table public.certifications to authenticated;
grant select on table public.domains to authenticated;
grant select on table public.topics to authenticated;
grant select on table public.lessons to authenticated;

insert into public.certifications (
  id, code, name, provider, description, level, is_enabled, display_order
)
values
  (
    '10000000-0000-4000-8000-000000000900',
    'az-900',
    'Microsoft Azure Fundamentals',
    'Microsoft',
    'Fundamentos de nuvem e dos principais serviços do Microsoft Azure.',
    'Fundamentos',
    true,
    1
  ),
  (
    '10000000-0000-4000-8000-000000000104',
    'az-104',
    'Microsoft Azure Administrator',
    'Microsoft',
    'Administração de identidades, governança, armazenamento e recursos Azure.',
    'Associado',
    false,
    2
  ),
  (
    '10000000-0000-4000-8000-000000000204',
    'az-204',
    'Developing Solutions for Microsoft Azure',
    'Microsoft',
    'Desenvolvimento de soluções e serviços no Microsoft Azure.',
    'Associado',
    false,
    3
  ),
  (
    '10000000-0000-4000-8000-000000000901',
    'ai-900',
    'Microsoft Azure AI Fundamentals',
    'Microsoft',
    'Fundamentos de inteligência artificial e serviços de IA no Azure.',
    'Fundamentos',
    false,
    4
  ),
  (
    '10000000-0000-4000-8000-000000000902',
    'dp-900',
    'Microsoft Azure Data Fundamentals',
    'Microsoft',
    'Fundamentos de dados e serviços de dados do Azure.',
    'Fundamentos',
    false,
    5
  ),
  (
    '10000000-0000-4000-8000-000000000903',
    'sc-900',
    'Microsoft Security, Compliance, and Identity Fundamentals',
    'Microsoft',
    'Fundamentos de segurança, conformidade e identidade em soluções Microsoft.',
    'Fundamentos',
    false,
    6
  )
on conflict (code) do update set
  name = excluded.name,
  provider = excluded.provider,
  description = excluded.description,
  level = excluded.level,
  is_enabled = excluded.is_enabled,
  display_order = excluded.display_order;

insert into public.domains (
  id, certification_id, title, description,
  exam_weight_min, exam_weight_max, display_order
)
values
  (
    '20000000-0000-4000-8000-000000000001',
    (select id from public.certifications where code = 'az-900'),
    'Describe cloud concepts',
    'Conceitos fundamentais de computação e serviços em nuvem.',
    25,
    30,
    1
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    (select id from public.certifications where code = 'az-900'),
    'Describe Azure architecture and services',
    'Componentes arquitetônicos e principais categorias de serviços do Azure.',
    35,
    40,
    2
  ),
  (
    '20000000-0000-4000-8000-000000000003',
    (select id from public.certifications where code = 'az-900'),
    'Describe Azure management and governance',
    'Ferramentas para administrar, governar e monitorar recursos do Azure.',
    30,
    35,
    3
  )
on conflict (id) do update set
  certification_id = excluded.certification_id,
  title = excluded.title,
  description = excluded.description,
  exam_weight_min = excluded.exam_weight_min,
  exam_weight_max = excluded.exam_weight_max,
  display_order = excluded.display_order;

insert into public.topics (
  id, domain_id, title, description, display_order
)
values
  (
    '30000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    'Cloud computing',
    'Introdução ao modelo de computação em nuvem.',
    1
  ),
  (
    '30000000-0000-4000-8000-000000000002',
    '20000000-0000-4000-8000-000000000002',
    'Core architectural components',
    'Organização física e lógica dos recursos no Azure.',
    1
  )
on conflict (id) do update set
  domain_id = excluded.domain_id,
  title = excluded.title,
  description = excluded.description,
  display_order = excluded.display_order;

insert into public.lessons (
  id, topic_id, slug, title, short_description, content,
  estimated_minutes, display_order, is_published
)
values
  (
    '40000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    'what-is-cloud-computing',
    'What is cloud computing?',
    'Definição inicial de computação em nuvem.',
    'Conteúdo demonstrativo sobre o conceito de computação em nuvem.',
    6,
    1,
    true
  ),
  (
    '40000000-0000-4000-8000-000000000002',
    '30000000-0000-4000-8000-000000000001',
    'benefits-of-cloud-services',
    'Benefits of cloud services',
    'Benefícios comuns de soluções baseadas em nuvem.',
    'Conteúdo demonstrativo sobre disponibilidade, escalabilidade e confiabilidade.',
    7,
    2,
    true
  ),
  (
    '40000000-0000-4000-8000-000000000003',
    '30000000-0000-4000-8000-000000000001',
    'cloud-service-types',
    'Cloud service types',
    'Visão inicial de IaaS, PaaS e SaaS.',
    'Conteúdo demonstrativo sobre os principais tipos de serviço em nuvem.',
    8,
    3,
    true
  ),
  (
    '40000000-0000-4000-8000-000000000004',
    '30000000-0000-4000-8000-000000000002',
    'azure-regions',
    'Azure regions',
    'Organização geográfica da infraestrutura do Azure.',
    'Conteúdo demonstrativo sobre regiões do Azure.',
    6,
    1,
    true
  ),
  (
    '40000000-0000-4000-8000-000000000005',
    '30000000-0000-4000-8000-000000000002',
    'availability-zones',
    'Availability Zones',
    'Separação física de infraestrutura dentro de uma região.',
    'Conteúdo demonstrativo sobre zonas de disponibilidade.',
    6,
    2,
    true
  ),
  (
    '40000000-0000-4000-8000-000000000006',
    '30000000-0000-4000-8000-000000000002',
    'resource-groups',
    'Resource Groups',
    'Contêineres lógicos para recursos relacionados.',
    'Conteúdo demonstrativo sobre grupos de recursos.',
    5,
    3,
    true
  ),
  (
    '40000000-0000-4000-8000-000000000007',
    '30000000-0000-4000-8000-000000000002',
    'subscriptions',
    'Subscriptions',
    'Limites de cobrança e gerenciamento no Azure.',
    'Conteúdo demonstrativo sobre assinaturas do Azure.',
    5,
    4,
    true
  )
on conflict (id) do update set
  topic_id = excluded.topic_id,
  slug = excluded.slug,
  title = excluded.title,
  short_description = excluded.short_description,
  content = excluded.content,
  estimated_minutes = excluded.estimated_minutes,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

commit;

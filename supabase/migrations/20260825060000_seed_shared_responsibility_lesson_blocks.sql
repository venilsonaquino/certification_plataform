begin;

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

  if (
    select count(*)
    from public.visual_experiences
    where lesson_id = target_lesson_id
      and type = 'responsibility'
      and is_published = true
  ) <> 1 then
    raise exception 'Shared Responsibility requires exactly one published responsibility visual';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = target_lesson_id
      and id not in (
        '79000000-0000-4000-8000-000000000001',
        '79000000-0000-4000-8000-000000000002',
        '79000000-0000-4000-8000-000000000003',
        '79000000-0000-4000-8000-000000000004',
        '79000000-0000-4000-8000-000000000005',
        '79000000-0000-4000-8000-000000000006',
        '79000000-0000-4000-8000-000000000007',
        '79000000-0000-4000-8000-000000000008'
      )
  ) then
    raise exception 'Shared Responsibility already has content blocks outside the pilot seed';
  end if;
end;
$$;

create temporary table shared_responsibility_block_seed (
  id uuid primary key,
  type text not null,
  title text,
  content text,
  config jsonb,
  display_order integer not null,
  is_published boolean not null
) on commit drop;

insert into shared_responsibility_block_seed (
  id, type, title, content, config, display_order, is_published
)
values
  (
    '79000000-0000-4000-8000-000000000001',
    'explanation',
    'O que é o modelo de responsabilidade compartilhada?',
    'O modelo de responsabilidade compartilhada define como as tarefas de segurança, proteção e operação são divididas entre o provedor de nuvem e o cliente.

A Microsoft protege a infraestrutura física do Azure. As responsabilidades do cliente variam conforme o modelo de serviço utilizado e incluem decisões sobre dados, identidades, acessos e configurações.',
    null,
    1,
    true
  ),
  (
    '79000000-0000-4000-8000-000000000002',
    'important',
    'A nuvem não elimina suas responsabilidades',
    'Mover uma aplicação para o Azure não transfere todas as responsabilidades para a Microsoft. O provedor assume determinadas camadas, enquanto o cliente continua responsável pelas partes que controla, como dados, identidades, permissões e configurações de uso.',
    null,
    2,
    true
  ),
  (
    '79000000-0000-4000-8000-000000000003',
    'visual_experience',
    'Compare On-Premises, IaaS, PaaS e SaaS',
    null,
    null,
    3,
    true
  ),
  (
    '79000000-0000-4000-8000-000000000004',
    'example',
    'Azure Virtual Machine vs. Azure App Service',
    'Em uma Azure Virtual Machine, modelo IaaS, a Microsoft opera o datacenter, o hardware e a virtualização. Sua equipe administra o sistema operacional da VM, as atualizações, o runtime, a aplicação e os dados.

No Azure App Service, modelo PaaS, o Azure também gerencia a plataforma de hospedagem e o sistema operacional. Sua equipe pode se concentrar no código, nas configurações da aplicação, nos dados, nas identidades e nos acessos.',
    null,
    4,
    true
  ),
  (
    '79000000-0000-4000-8000-000000000005',
    'dotnet_example',
    'ASP.NET Core: VM vs. App Service',
    'Ao hospedar uma API ASP.NET Core em uma Azure VM, sua equipe mantém o sistema operacional, instala e atualiza o runtime .NET, publica a aplicação e protege seus dados e acessos.

No Azure App Service com runtime gerenciado, o Azure mantém uma parte maior da plataforma. Sua equipe continua responsável pelo código, pelas dependências da aplicação, pelas configurações, pelas identidades e pelos dados.',
    null,
    5,
    true
  ),
  (
    '79000000-0000-4000-8000-000000000006',
    'exam_tip',
    'O que lembrar para a prova',
    'Ao avançar de IaaS para PaaS e SaaS, o provedor assume progressivamente mais camadas operacionais. Isso reduz a administração realizada pelo cliente, mas não elimina suas responsabilidades sobre dados, identidades, acessos e uso seguro do serviço.',
    null,
    6,
    true
  ),
  (
    '79000000-0000-4000-8000-000000000007',
    'exam_trap',
    'Não confunda: SaaS não significa responsabilidade zero',
    'Em SaaS, o provedor administra a aplicação e a infraestrutura subjacente, mas isso não significa que ele seja responsável por absolutamente tudo. O cliente ainda gerencia aspectos como usuários, identidades, permissões, classificação dos dados e uso adequado da solução, conforme o contexto.',
    null,
    7,
    true
  ),
  (
    '79000000-0000-4000-8000-000000000008',
    'summary',
    'Resumo',
    null,
    $json$
    {
      "items": [
        "On-Premises concentra a maior responsabilidade operacional no cliente.",
        "Em IaaS, o provedor gerencia hardware e virtualização; o cliente gerencia o sistema operacional e as camadas acima.",
        "Em PaaS, o provedor também administra uma parte maior da plataforma.",
        "Em SaaS, o provedor entrega a aplicação pronta e gerencia a maior parte das camadas técnicas.",
        "A responsabilidade do cliente sobre dados, identidades, acessos e uso seguro nunca desaparece completamente."
      ]
    }
    $json$::jsonb,
    8,
    true
  );

with target as (
  select
    lesson.id as lesson_id,
    visual.id as visual_experience_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  join public.visual_experiences visual
    on visual.lesson_id = lesson.id
   and visual.type = 'responsibility'
   and visual.is_published = true
  where certification.code = 'az-900'
    and lesson.slug = 'shared-responsibility-model'
)
insert into public.lesson_content_blocks (
  id,
  lesson_id,
  type,
  title,
  content,
  config,
  visual_experience_id,
  display_order,
  is_published
)
select
  seed.id,
  target.lesson_id,
  seed.type,
  seed.title,
  seed.content,
  seed.config,
  case
    when seed.type = 'visual_experience' then target.visual_experience_id
    else null
  end,
  seed.display_order,
  seed.is_published
from shared_responsibility_block_seed seed
cross join target
order by seed.display_order
on conflict (id) do update set
  lesson_id = excluded.lesson_id,
  type = excluded.type,
  title = excluded.title,
  content = excluded.content,
  config = excluded.config,
  visual_experience_id = excluded.visual_experience_id,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

do $$
declare
  target_lesson_id uuid;
  ordered_types text[];
begin
  select lesson.id
  into strict target_lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and lesson.slug = 'shared-responsibility-model';

  select array_agg(type order by display_order)
  into ordered_types
  from public.lesson_content_blocks
  where lesson_id = target_lesson_id
    and is_published = true;

  if ordered_types <> array[
    'explanation',
    'important',
    'visual_experience',
    'example',
    'dotnet_example',
    'exam_tip',
    'exam_trap',
    'summary'
  ]::text[] then
    raise exception 'Unexpected Shared Responsibility block order: %', ordered_types;
  end if;
end;
$$;

commit;

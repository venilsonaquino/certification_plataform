begin;

alter table public.visual_experiences
  drop constraint visual_experiences_type_check;

alter table public.visual_experiences
  add constraint visual_experiences_type_check
  check (type in ('comparison', 'architecture', 'flow', 'responsibility'));

do $$
declare
  target_lesson_count integer;
begin
  select count(distinct lesson.id)
  into target_lesson_count
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and lesson.slug = 'shared-responsibility-model';

  if target_lesson_count <> 1 then
    raise exception 'Responsibility visual seed expected exactly one AZ-900/shared-responsibility-model lesson, found %', target_lesson_count;
  end if;
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
  '76000000-0000-4000-8000-000000000004',
  lesson.id,
  'responsibility',
  'Modelo de responsabilidade compartilhada',
  'Explore como as responsabilidades mudam entre ambientes locais e os modelos IaaS, PaaS e SaaS.',
  $json$
  {
    "owners": {
      "customer": {
        "label": "Você",
        "description": "O cliente configura, protege ou opera esta camada."
      },
      "provider": {
        "label": "Microsoft Azure",
        "description": "O provedor de nuvem opera e protege esta camada."
      },
      "shared": {
        "label": "Compartilhada",
        "description": "Cliente e provedor têm deveres diferentes na mesma camada."
      }
    },
    "layers": [
      {
        "id": "data",
        "label": "Dados",
        "description": "Informações criadas, armazenadas e processadas pela organização."
      },
      {
        "id": "applications",
        "label": "Aplicações",
        "description": "Software de negócio, suas configurações e seu uso seguro."
      },
      {
        "id": "runtime",
        "label": "Runtime",
        "description": "Ambiente e componentes necessários para executar a aplicação."
      },
      {
        "id": "operating-system",
        "label": "Sistema operacional",
        "description": "Sistema, correções e configurações da máquina que executa a carga."
      },
      {
        "id": "virtualization",
        "label": "Virtualização",
        "description": "Camada que abstrai o hardware e hospeda recursos virtuais."
      },
      {
        "id": "servers",
        "label": "Servidores",
        "description": "Hardware de computação usado para executar as cargas."
      },
      {
        "id": "storage",
        "label": "Armazenamento",
        "description": "Hardware e infraestrutura física usados para persistir dados."
      },
      {
        "id": "networking",
        "label": "Rede",
        "description": "Infraestrutura física de conectividade entre os recursos."
      },
      {
        "id": "physical-datacenter",
        "label": "Datacenter físico",
        "description": "Instalações, energia, refrigeração e segurança física."
      }
    ],
    "models": [
      {
        "id": "on-premises",
        "label": "On-Premises",
        "description": "No ambiente local, você é responsável por todas as camadas, do datacenter aos dados.",
        "responsibilities": {
          "data": "customer",
          "applications": "customer",
          "runtime": "customer",
          "operating-system": "customer",
          "virtualization": "customer",
          "servers": "customer",
          "storage": "customer",
          "networking": "customer",
          "physical-datacenter": "customer"
        }
      },
      {
        "id": "iaas",
        "label": "IaaS",
        "description": "O Azure gerencia a infraestrutura física e a virtualização; você gerencia o sistema operacional, o runtime, as aplicações e os dados.",
        "responsibilities": {
          "data": "customer",
          "applications": "customer",
          "runtime": "customer",
          "operating-system": "customer",
          "virtualization": "provider",
          "servers": "provider",
          "storage": "provider",
          "networking": "provider",
          "physical-datacenter": "provider"
        },
        "example": "Em uma VM do Azure que hospeda uma API ASP.NET Core, a Microsoft opera datacenter, hardware e virtualização; sua equipe atualiza o sistema operacional, o runtime .NET, a API, os acessos e os dados."
      },
      {
        "id": "paas",
        "label": "PaaS",
        "description": "O Azure também gerencia o sistema operacional e o runtime; você se concentra nas aplicações, nos dados, nas identidades e nas configurações.",
        "responsibilities": {
          "data": "customer",
          "applications": "customer",
          "runtime": "provider",
          "operating-system": "provider",
          "virtualization": "provider",
          "servers": "provider",
          "storage": "provider",
          "networking": "provider",
          "physical-datacenter": "provider"
        },
        "example": "No Azure App Service, a Microsoft mantém infraestrutura, sistema operacional e runtime; sua equipe publica a aplicação ASP.NET Core e continua responsável pelo código, pelas configurações, pelos acessos e pelos dados."
      },
      {
        "id": "saas",
        "label": "SaaS",
        "description": "O provedor opera a solução completa, mas SaaS não elimina seus deveres: você ainda protege dados, identidades, acessos e configura o uso da aplicação.",
        "responsibilities": {
          "data": "customer",
          "applications": "shared",
          "runtime": "provider",
          "operating-system": "provider",
          "virtualization": "provider",
          "servers": "provider",
          "storage": "provider",
          "networking": "provider",
          "physical-datacenter": "provider"
        },
        "example": "Ao usar um produto SaaS, sua equipe não mantém o runtime .NET nem os servidores do produto, mas ainda controla usuários, permissões, configurações e a proteção dos dados inseridos na solução."
      }
    ],
    "progression": {
      "startLabel": "Mais responsabilidade do cliente",
      "endLabel": "Mais responsabilidade do provedor"
    },
    "exampleTitle": "Exemplo para desenvolvedor .NET"
  }
  $json$::jsonb,
  1,
  true
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and lesson.slug = 'shared-responsibility-model'
on conflict (id) do update set
  lesson_id = excluded.lesson_id,
  type = excluded.type,
  title = excluded.title,
  description = excluded.description,
  config = excluded.config,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

do $$
begin
  if (select count(*) from public.visual_experiences where id = '76000000-0000-4000-8000-000000000004') <> 1 then
    raise exception 'Responsibility visual seed was not persisted exactly once';
  end if;
end;
$$;

commit;

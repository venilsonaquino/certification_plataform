begin;

do $$
declare
  target_count integer;
begin
  select count(*)
  into target_count
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Cloud Service Types'
    and lesson.slug in (
      'infrastructure-as-a-service',
      'platform-as-a-service',
      'software-as-a-service',
      'choosing-iaas-paas-saas'
    );

  if target_count <> 4 then
    raise exception 'Cloud Service Types enrichment expected exactly 4 target lessons, found %', target_count;
  end if;

  if (
    select count(*)
    from public.visual_experiences
    where type = 'responsibility'
      and id = '76000000-0000-4000-8000-000000000004'
      and is_published
  ) <> 1 then
    raise exception 'The existing Shared Responsibility visual must remain available';
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
  '76000000-0000-4000-8000-000000000001',
  lesson.id,
  'comparison',
  'IaaS, PaaS e SaaS por cenário',
  'Compare o nível de controle, o trabalho operacional e o tipo de solução entregue em cada modelo.',
  $json$
  {
    "columns": [
      {
        "id": "iaas",
        "title": "IaaS",
        "description": "Infraestrutura virtualizada com maior controle e gerenciamento pelo cliente."
      },
      {
        "id": "paas",
        "title": "PaaS",
        "description": "Plataforma gerenciada para desenvolver, publicar e executar aplicações."
      },
      {
        "id": "saas",
        "title": "SaaS",
        "description": "Software pronto consumido como serviço."
      }
    ],
    "rows": [
      {
        "id": "control",
        "label": "Controle",
        "values": {
          "iaas": "Maior controle sobre sistema operacional, runtime e configuração da aplicação.",
          "paas": "Controle concentrado na aplicação, nos dados e nas configurações oferecidas pela plataforma.",
          "saas": "Controle principalmente sobre usuários, dados, acessos e configurações disponíveis no software."
        }
      },
      {
        "id": "operations",
        "label": "Responsabilidade operacional",
        "values": {
          "iaas": "O cliente administra mais camadas, incluindo sistema operacional e runtime.",
          "paas": "O provider administra mais da stack; o cliente foca na aplicação e nos dados.",
          "saas": "O provider administra quase toda a plataforma e o software; responsabilidades do cliente permanecem."
        }
      },
      {
        "id": "use-case",
        "label": "Caso de uso",
        "values": {
          "iaas": "Executar uma carga que exige controle do sistema operacional ou configuração específica.",
          "paas": "Publicar uma aplicação sem administrar o sistema operacional da VM.",
          "saas": "Usar uma aplicação pronta sem desenvolver ou operar sua plataforma."
        }
      },
      {
        "id": "azure-example",
        "label": "Exemplo Azure",
        "values": {
          "iaas": "Azure Virtual Machines",
          "paas": "Azure App Service",
          "saas": "Microsoft 365"
        }
      }
    ]
  }
  $json$::jsonb,
  1,
  true
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and domain.title = 'Describe cloud concepts'
  and topic.title = 'Cloud Service Types'
  and lesson.slug = 'choosing-iaas-paas-saas'
on conflict (id) do update set
  lesson_id = excluded.lesson_id,
  type = excluded.type,
  title = excluded.title,
  description = excluded.description,
  config = excluded.config,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

create temporary table cloud_service_types_block_seed (
  id uuid primary key,
  lesson_slug text not null,
  type text not null,
  title text,
  content text,
  config jsonb,
  visual_experience_id uuid,
  display_order integer not null,
  is_published boolean not null
) on commit drop;

insert into cloud_service_types_block_seed values
  (
    '7c010000-0000-4000-8000-000000000001',
    'infrastructure-as-a-service',
    'explanation',
    'Infrastructure as a Service',
    $content$IaaS fornece infraestrutura de computação virtualizada. O cloud provider administra o datacenter físico, o hardware e a camada de virtualização. O cliente recebe recursos como máquinas virtuais, armazenamento e rede para configurar conforme a necessidade.

Em uma máquina virtual, o cliente normalmente administra mais elementos da stack: sistema operacional, atualizações, runtime, aplicações e dados. Esse modelo oferece maior controle, acompanhado de maior responsabilidade operacional.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7c010000-0000-4000-8000-000000000002',
    'infrastructure-as-a-service',
    'important',
    'Shared Responsibility em IaaS',
    $content$No visual de Shared Responsibility, a passagem de On-Premises para IaaS transfere datacenter, hardware e virtualização ao provider. O cliente deixa de manter a infraestrutura física, mas continua responsável por várias camadas acima dela, incluindo sistema operacional, aplicações, dados, identidades e configurações.$content$,
    null,
    null,
    2,
    true
  ),
  (
    '7c010000-0000-4000-8000-000000000003',
    'infrastructure-as-a-service',
    'example',
    'Azure Virtual Machines',
    $content$Azure Virtual Machines é um exemplo de IaaS. A Microsoft opera o datacenter, os servidores físicos e a virtualização. A organização escolhe a imagem e o tamanho da VM e administra o sistema operacional, o software instalado, a aplicação e os dados.$content$,
    null,
    null,
    3,
    true
  ),
  (
    '7c010000-0000-4000-8000-000000000004',
    'infrastructure-as-a-service',
    'dotnet_example',
    'ASP.NET Core em uma VM',
    $content$Ao hospedar uma ASP.NET Core API em uma Azure Virtual Machine, a equipe configura o sistema operacional, instala ou mantém o runtime, configura o servidor web, aplica patches e publica a aplicação. O Azure mantém a infraestrutura física e a virtualização que sustentam a VM.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7c010000-0000-4000-8000-000000000005',
    'infrastructure-as-a-service',
    'exam_tip',
    'Controle do sistema operacional',
    $content$Se um cenário exige controlar o sistema operacional, instalar componentes específicos ou manter compatibilidade com uma configuração de servidor existente, IaaS tende a ser mais apropriado que PaaS. Ainda assim, considere todo o requisito: controle adicional também aumenta o trabalho operacional.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7c010000-0000-4000-8000-000000000006',
    'infrastructure-as-a-service',
    'exam_trap',
    'IaaS não é servidor físico próprio',
    $content$Uma VM em IaaS não exige que o cliente compre ou mantenha o servidor físico. O provider administra a infraestrutura e a virtualização; o cliente administra o sistema operacional e as camadas superiores da VM.$content$,
    null,
    null,
    6,
    true
  ),
  (
    '7c010000-0000-4000-8000-000000000007',
    'infrastructure-as-a-service',
    'summary',
    'Resumo',
    null,
    $json${"items": ["O provider administra datacenter, hardware e virtualização.", "O cliente administra sistema operacional, runtime, aplicações e dados.", "Azure Virtual Machines é o exemplo principal.", "IaaS oferece mais controle e mais responsabilidade operacional.", "IaaS não significa possuir o servidor físico."]}$json$::jsonb,
    null,
    7,
    true
  ),

  (
    '7c020000-0000-4000-8000-000000000001',
    'platform-as-a-service',
    'explanation',
    'Platform as a Service',
    $content$PaaS oferece uma plataforma gerenciada para desenvolver, publicar e executar aplicações. Em comparação com IaaS, o provider administra mais da stack, incluindo infraestrutura, sistema operacional e componentes da plataforma ou runtime oferecidos pelo serviço.

O cliente concentra seu trabalho na aplicação, nos dados e nas configurações disponíveis. Isso reduz tarefas de manutenção da plataforma, sem eliminar responsabilidades sobre o que a aplicação faz e armazena.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7c020000-0000-4000-8000-000000000002',
    'platform-as-a-service',
    'important',
    'Shared Responsibility em PaaS',
    $content$Na progressão On-Premises → IaaS → PaaS → SaaS, PaaS transfere mais gerenciamento de infraestrutura ao provider do que IaaS. O cliente continua responsável pela aplicação, pelos dados, por identidades, acessos e configurações que estiverem sob seu controle.$content$,
    null,
    null,
    2,
    true
  ),
  (
    '7c020000-0000-4000-8000-000000000003',
    'platform-as-a-service',
    'example',
    'Azure App Service',
    $content$Azure App Service é um exemplo de PaaS para aplicações web e APIs. A equipe publica o código e configura a aplicação, enquanto o Azure administra a infraestrutura e o sistema operacional usado pela plataforma.$content$,
    null,
    null,
    3,
    true
  ),
  (
    '7c020000-0000-4000-8000-000000000004',
    'platform-as-a-service',
    'dotnet_example',
    'Publicar ASP.NET Core sem administrar o SO',
    $content$Uma equipe publica uma ASP.NET Core API no Azure App Service. Ela escolhe configurações suportadas, implanta o código, monitora a aplicação e administra seus dados e acessos. Não precisa acessar a VM para instalar patches ou manter o sistema operacional.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7c020000-0000-4000-8000-000000000005',
    'platform-as-a-service',
    'exam_tip',
    'Foco na aplicação',
    $content$Quando o requisito é desenvolver e publicar uma aplicação sem administrar o sistema operacional da VM, PaaS tende a ser a opção adequada. Verifique se a plataforma oferece as configurações e runtimes exigidos pelo cenário.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7c020000-0000-4000-8000-000000000006',
    'platform-as-a-service',
    'exam_trap',
    'PaaS não é SaaS',
    $content$Em PaaS, o cliente ainda desenvolve ou publica sua própria aplicação sobre uma plataforma gerenciada. Em SaaS, o cliente consome um software pronto. Não confunda menos administração de infraestrutura com ausência de desenvolvimento da aplicação.$content$,
    null,
    null,
    6,
    true
  ),
  (
    '7c020000-0000-4000-8000-000000000007',
    'platform-as-a-service',
    'summary',
    'Resumo',
    null,
    $json${"items": ["O provider administra mais da stack do que em IaaS.", "O cliente foca na aplicação e nos dados.", "Azure App Service é o exemplo principal.", "PaaS permite publicar ASP.NET Core sem administrar o SO da VM.", "PaaS entrega uma plataforma; SaaS entrega software pronto."]}$json$::jsonb,
    null,
    7,
    true
  ),

  (
    '7c030000-0000-4000-8000-000000000001',
    'software-as-a-service',
    'explanation',
    'Software as a Service',
    $content$SaaS entrega um software pronto para ser consumido como serviço, normalmente por navegador, aplicativo ou integração. O provider desenvolve e administra quase toda a plataforma necessária para executar o produto, incluindo infraestrutura e manutenção do software.

O cliente usa e configura o serviço dentro das opções disponíveis, sem desenvolver nem operar a plataforma que sustenta o produto.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7c030000-0000-4000-8000-000000000002',
    'software-as-a-service',
    'important',
    'Shared Responsibility em SaaS',
    $content$SaaS reduz ao máximo o gerenciamento técnico da plataforma pelo cliente, mas não elimina suas responsabilidades. A organização ainda administra usuários, acessos, dados inseridos, configurações disponíveis e uso adequado do serviço.$content$,
    null,
    null,
    2,
    true
  ),
  (
    '7c030000-0000-4000-8000-000000000003',
    'software-as-a-service',
    'example',
    'Microsoft 365',
    $content$Microsoft 365 fornece aplicações prontas como serviço. A Microsoft mantém a infraestrutura, a plataforma e o software. A organização gerencia seus usuários, permissões, informações e configurações de uso.$content$,
    null,
    null,
    3,
    true
  ),
  (
    '7c030000-0000-4000-8000-000000000004',
    'software-as-a-service',
    'dotnet_example',
    'Uma aplicação .NET consumindo SaaS',
    $content$Uma aplicação .NET pode integrar-se a um produto SaaS por uma API oferecida pelo fornecedor. A equipe não mantém os servidores nem o código interno do produto, mas continua responsável por proteger credenciais, conceder acessos adequados e tratar corretamente os dados enviados e recebidos.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7c030000-0000-4000-8000-000000000005',
    'software-as-a-service',
    'exam_tip',
    'Software pronto para uso',
    $content$Se o cenário pede uma solução pronta para o usuário, sem desenvolver a aplicação nem administrar sua plataforma, SaaS tende a ser o modelo adequado. Configuração do produto não transforma SaaS em PaaS.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7c030000-0000-4000-8000-000000000006',
    'software-as-a-service',
    'exam_trap',
    'SaaS não significa zero responsabilidade',
    $content$O provider administra quase toda a stack técnica, mas o cliente continua responsável por identidades, acessos, dados, configurações e uso. Na prova, rejeite afirmações de que toda responsabilidade passa para o provider.$content$,
    null,
    null,
    6,
    true
  ),
  (
    '7c030000-0000-4000-8000-000000000007',
    'software-as-a-service',
    'summary',
    'Resumo',
    null,
    $json${"items": ["SaaS é software pronto consumido como serviço.", "O provider administra quase toda a plataforma e o software.", "Microsoft 365 é o exemplo principal.", "O cliente ainda administra usuários, acessos, dados e configurações.", "SaaS não significa zero responsabilidade do cliente."]}$json$::jsonb,
    null,
    7,
    true
  ),

  (
    '7c040000-0000-4000-8000-000000000001',
    'choosing-iaas-paas-saas',
    'explanation',
    'Escolha pelo requisito do cenário',
    $content$A escolha entre IaaS, PaaS e SaaS equilibra controle, responsabilidade operacional e velocidade de entrega. Não existe um modelo universalmente melhor.

Pergunte primeiro o que precisa ser controlado ou construído. Controle do sistema operacional aponta para IaaS; foco em publicar uma aplicação aponta para PaaS; consumo de um software pronto aponta para SaaS.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7c040000-0000-4000-8000-000000000002',
    'choosing-iaas-paas-saas',
    'visual_experience',
    null,
    null,
    null,
    '76000000-0000-4000-8000-000000000001',
    2,
    true
  ),
  (
    '7c040000-0000-4000-8000-000000000003',
    'choosing-iaas-paas-saas',
    'example',
    'Cenário: controlar o sistema operacional',
    $content$Uma aplicação legada exige uma versão específica do sistema operacional, componentes instalados manualmente e acesso administrativo ao servidor. IaaS tende a ser mais apropriado porque oferece esse controle, embora aumente a responsabilidade de manutenção.$content$,
    null,
    null,
    3,
    true
  ),
  (
    '7c040000-0000-4000-8000-000000000004',
    'choosing-iaas-paas-saas',
    'example',
    'Cenário: publicar sem administrar o SO',
    $content$Uma equipe quer implantar sua ASP.NET Core API, configurar a aplicação e administrar os dados, mas não quer aplicar patches no sistema operacional. PaaS, como Azure App Service, tende a atender melhor esse requisito.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7c040000-0000-4000-8000-000000000005',
    'choosing-iaas-paas-saas',
    'example',
    'Cenário: consumir software pronto',
    $content$Uma organização precisa de ferramentas prontas de produtividade e colaboração, sem desenvolver ou hospedar o produto. SaaS, como Microsoft 365, tende a ser a escolha adequada.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7c040000-0000-4000-8000-000000000006',
    'choosing-iaas-paas-saas',
    'important',
    'O gradiente de Shared Responsibility',
    $content$No caminho On-Premises → IaaS → PaaS → SaaS, o provider administra progressivamente mais da infraestrutura e da plataforma. O cliente gerencia menos camadas técnicas, mas suas responsabilidades não desaparecem: dados, identidades, acessos e uso continuam relevantes em todos os modelos.$content$,
    null,
    null,
    6,
    true
  ),
  (
    '7c040000-0000-4000-8000-000000000007',
    'choosing-iaas-paas-saas',
    'exam_tip',
    'Use a pista principal sem criar regra cega',
    $content$Controle do sistema operacional favorece IaaS; publicar código sem administrar o SO favorece PaaS; consumir uma aplicação pronta favorece SaaS. Essas pistas orientam a resposta, mas requisitos de compatibilidade, controle e operação devem ser considerados em conjunto.$content$,
    null,
    null,
    7,
    true
  ),
  (
    '7c040000-0000-4000-8000-000000000008',
    'choosing-iaas-paas-saas',
    'exam_trap',
    'Três confusões frequentes',
    $content$IaaS fornece infraestrutura virtualizada, não exige servidor físico próprio. PaaS fornece uma plataforma para sua aplicação, não um software pronto. SaaS fornece o software pronto, mas não remove todas as responsabilidades do cliente.$content$,
    null,
    null,
    8,
    true
  ),
  (
    '7c040000-0000-4000-8000-000000000009',
    'choosing-iaas-paas-saas',
    'summary',
    'Resumo',
    null,
    $json${"items": ["IaaS favorece cenários que exigem controle do sistema operacional.", "PaaS favorece publicar aplicações sem administrar o SO.", "SaaS favorece consumir software pronto.", "Do IaaS ao SaaS, o provider administra progressivamente mais da stack.", "A escolha equilibra controle, responsabilidade operacional e velocidade.", "Responsabilidades do cliente permanecem nos três modelos."]}$json$::jsonb,
    null,
    9,
    true
  );

do $$
begin
  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug in (
      'infrastructure-as-a-service',
      'platform-as-a-service',
      'software-as-a-service',
      'choosing-iaas-paas-saas'
    )
      and not exists (
        select 1
        from cloud_service_types_block_seed seed
        where seed.id = block.id
          and seed.lesson_slug = lesson.slug
      )
  ) then
    raise exception 'A target lesson already has content blocks outside the 8.4.4 seed';
  end if;

  if (select count(*) from cloud_service_types_block_seed) <> 30 then
    raise exception 'Cloud Service Types block seed expected 30 rows';
  end if;
end;
$$;

with target_lessons as (
  select lesson.id, lesson.slug
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Cloud Service Types'
),
resolved_seed as (
  select seed.*, target.id as lesson_id
  from cloud_service_types_block_seed seed
  join target_lessons target on target.slug = seed.lesson_slug
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
  seed.lesson_id,
  seed.type,
  seed.title,
  seed.content,
  seed.config,
  seed.visual_experience_id,
  seed.display_order,
  seed.is_published
from resolved_seed seed
order by seed.lesson_slug, seed.display_order
on conflict (id) do update set
  lesson_id = excluded.lesson_id,
  type = excluded.type,
  title = excluded.title,
  content = excluded.content,
  config = excluded.config,
  visual_experience_id = excluded.visual_experience_id,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

update public.lessons lesson
set estimated_minutes = case lesson.slug
  when 'infrastructure-as-a-service' then 10
  when 'platform-as-a-service' then 10
  when 'software-as-a-service' then 10
  when 'choosing-iaas-paas-saas' then 12
  else lesson.estimated_minutes
end
from public.topics topic
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where lesson.topic_id = topic.id
  and certification.code = 'az-900'
  and domain.title = 'Describe cloud concepts'
  and topic.title = 'Cloud Service Types';

do $$
declare
  published_block_count integer;
  enriched_lesson_count integer;
begin
  select count(*), count(distinct lesson.id)
  into published_block_count, enriched_lesson_count
  from public.lesson_content_blocks block
  join public.lessons lesson on lesson.id = block.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Cloud Service Types'
    and block.is_published;

  if published_block_count <> 30 or enriched_lesson_count <> 4 then
    raise exception 'Unexpected Service Types lesson/block count: lessons %, blocks %', enriched_lesson_count, published_block_count;
  end if;

  if (
    select count(*)
    from public.visual_experiences
    where id = '76000000-0000-4000-8000-000000000001'
      and type = 'comparison'
      and is_published
  ) <> 1 then
    raise exception 'The IaaS/PaaS/SaaS comparison visual was not persisted';
  end if;

  if (
    select count(*)
    from public.visual_experiences
    where type = 'responsibility'
      and id = '76000000-0000-4000-8000-000000000004'
      and is_published
  ) <> 1 then
    raise exception 'The existing ResponsibilityVisual was changed or duplicated';
  end if;

  if exists (
    select 1
    from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and topic.title = 'Cloud Service Types'
      and (lesson.content is null or btrim(lesson.content) = '')
  ) then
    raise exception 'Legacy lessons.content must remain available after Service Types enrichment';
  end if;
end;
$$;

commit;

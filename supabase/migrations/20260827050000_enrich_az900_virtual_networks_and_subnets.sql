begin;

do $$
declare
  target_lesson_id uuid;
begin
  select lesson.id into strict target_lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Networking Services'
    and lesson.slug = 'virtual-networks-and-subnets';

  if exists (select 1 from public.lesson_content_blocks where lesson_id = target_lesson_id) then
    raise exception 'The VNet and Subnets Lesson already contains Content Blocks';
  end if;

  if exists (select 1 from public.visual_experiences where lesson_id = target_lesson_id)
    or exists (select 1 from public.visual_experiences where id = '76000000-0000-4000-8000-000000000010') then
    raise exception 'The VNet visual target or planned UUID is already in use';
  end if;

  if (select count(*) from public.flashcards where lesson_id = target_lesson_id and is_published) <> 8
    or exists (select 1 from public.questions where lesson_id = target_lesson_id) then
    raise exception 'Expected eight published Flashcards and no Questions before 8.7.2';
  end if;
end;
$$;

update public.lessons
set estimated_minutes = 12
where topic_id = '32000000-0000-4000-8000-000000000003'
  and slug = 'virtual-networks-and-subnets';

insert into public.visual_experiences (
  id, lesson_id, type, title, description, config, display_order, is_published
)
select
  '76000000-0000-4000-8000-000000000010',
  lesson.id,
  'architecture',
  'VNet, subnets e recursos de uma aplicação',
  'Uma VNet com espaço 10.0.0.0/16 organizada em subnets para as camadas web, API e dados. A divisão organiza a rede; comunicação e isolamento efetivos dependem das regras e configurações aplicadas.',
  $json$
  {
    "nodes": [
      {
        "id": "vnet",
        "label": "Azure VNet — 10.0.0.0/16",
        "kind": "group",
        "description": "Rede privada lógica no Azure. Seu espaço de endereços pode ser dividido em uma ou mais subnets.",
        "x": 50,
        "y": 8
      },
      {
        "id": "web-subnet",
        "label": "web-subnet — 10.0.1.0/24",
        "kind": "group",
        "description": "Faixa de endereços dentro da VNet usada para organizar a camada web.",
        "x": 18,
        "y": 38
      },
      {
        "id": "api-subnet",
        "label": "api-subnet — 10.0.2.0/24",
        "kind": "group",
        "description": "Faixa de endereços dentro da VNet usada para organizar a camada de API.",
        "x": 50,
        "y": 38
      },
      {
        "id": "data-subnet",
        "label": "data-subnet — 10.0.3.0/24",
        "kind": "group",
        "description": "Faixa de endereços dentro da VNet usada para organizar a camada de dados.",
        "x": 82,
        "y": 38
      },
      {
        "id": "frontend",
        "label": "Frontend",
        "kind": "resource",
        "description": "Recurso da camada web associado à web-subnet neste exemplo conceitual.",
        "x": 18,
        "y": 78
      },
      {
        "id": "aspnet-api",
        "label": "API ASP.NET Core",
        "kind": "service",
        "description": "Recurso da camada de aplicação associado à api-subnet neste exemplo conceitual.",
        "x": 50,
        "y": 78
      },
      {
        "id": "data-service",
        "label": "Serviço de dados",
        "kind": "resource",
        "description": "Recurso da camada de dados associado à data-subnet neste exemplo conceitual.",
        "x": 82,
        "y": 78
      }
    ],
    "edges": [
      {"id": "vnet-web", "source": "vnet", "target": "web-subnet", "label": "contém"},
      {"id": "vnet-api", "source": "vnet", "target": "api-subnet", "label": "contém"},
      {"id": "vnet-data", "source": "vnet", "target": "data-subnet", "label": "contém"},
      {"id": "web-frontend", "source": "web-subnet", "target": "frontend", "label": "organiza"},
      {"id": "api-service", "source": "api-subnet", "target": "aspnet-api", "label": "organiza"},
      {"id": "data-service", "source": "data-subnet", "target": "data-service", "label": "organiza"}
    ]
  }
  $json$::jsonb,
  1,
  true
from public.lessons lesson
where lesson.topic_id = '32000000-0000-4000-8000-000000000003'
  and lesson.slug = 'virtual-networks-and-subnets';

create temporary table stage_872_block_seed (
  id uuid primary key, type text not null, title text, content text,
  config jsonb, visual_experience_id uuid, display_order integer not null
) on commit drop;

insert into stage_872_block_seed values
  ('7b0e0000-0000-4000-8000-000000000001','explanation','O que é uma Azure Virtual Network?',
   $content$Azure Virtual Network (VNet) é uma rede privada lógica no Azure. Ela fornece isolamento lógico e um espaço de endereços no qual recursos habilitados para rede podem ser organizados e se comunicar conforme a arquitetura e as configurações aplicadas.

Uma VNet pode conter uma ou mais subnets. Ela também pode participar, futuramente, de arquiteturas que conectam outras VNets ou ambientes locais, mas esses mecanismos serão estudados em Lessons próprias.$content$,null,null,1),
  ('7b0e0000-0000-4000-8000-000000000002','important','Espaço de endereços em nível Fundamentals',
   $content$Ao criar uma VNet, você define seu espaço de endereços. Por exemplo, a VNet pode usar 10.0.0.0/16 e reservar partes desse espaço para subnets como 10.0.1.0/24, 10.0.2.0/24 e 10.0.3.0/24.

Para o AZ-900, reconheça a relação: o espaço pertence à VNet e as faixas das subnets ficam dentro dele. Não é necessário calcular quantidade de hosts.$content$,null,null,2),
  ('7b0e0000-0000-4000-8000-000000000003','explanation','O que é uma subnet?',
   $content$Uma subnet é uma faixa de endereços IP dentro do espaço de uma VNet. Ela ajuda a organizar e segmentar recursos por camada, função ou workload.

A subnet cria estrutura para aplicar futuramente controles de segurança e roteamento. A simples divisão em subnets, sozinha, não garante isolamento completo entre os recursos.$content$,null,null,3),
  ('7b0e0000-0000-4000-8000-000000000004','example','Organizando uma aplicação em três camadas',
   $content$Uma equipe pode organizar o frontend na web-subnet, os serviços de aplicação na api-subnet e os recursos de dados na data-subnet. Essa separação torna a arquitetura mais clara e prepara pontos distintos para configurações de rede.

Os nomes e intervalos são escolhas do projeto. Criar três subnets não exige que cada camada esteja em uma Availability Zone diferente.$content$,null,null,4),
  ('7b0e0000-0000-4000-8000-000000000005','dotnet_example','Frontend, API ASP.NET Core e dados',
   $content$Em uma solução .NET, um frontend pode ficar associado à web-subnet, uma API ASP.NET Core à api-subnet e um serviço de dados à data-subnet. A divisão pode facilitar organização e aplicação de regras diferentes para cada camada.

Esse é apenas um exemplo arquitetural. Usar .NET não obriga essa divisão, e o serviço Azure escolhido pode ter requisitos próprios de integração com VNet.$content$,null,null,5),
  ('7b0e0000-0000-4000-8000-000000000006','important','Comunicação depende de regras e configuração',
   $content$Recursos em subnets da mesma VNet podem se comunicar pela rede privada, sujeitos às rotas, regras de segurança, configurações dos recursos e demais controles aplicáveis.

Portanto, “estão na mesma VNet” não significa que todo tráfego será sempre permitido. Também não significa que os recursos compartilham a mesma subnet.$content$,null,null,6),
  ('7b0e0000-0000-4000-8000-000000000007','visual_experience','VNet organizada em subnets',
   null,null,'76000000-0000-4000-8000-000000000010',7),
  ('7b0e0000-0000-4000-8000-000000000008','exam_trap','Não confunda rede, organização e localização física',
   $content$VNet não é subnet: a VNet contém o espaço de endereços e uma ou mais subnets. Subnet não é Availability Zone nem Resource Group: ela é uma faixa de rede dentro da VNet, enquanto Zone trata de isolamento físico e Resource Group é um contêiner lógico de gerenciamento.

Uma VNet também não é automaticamente uma rede física dedicada ao cliente. Ela oferece isolamento lógico na infraestrutura do Azure.$content$,null,null,8),
  ('7b0e0000-0000-4000-8000-000000000009','exam_tip','Identifique o nível descrito pelo cenário',
   $content$Se a pergunta descreve a rede privada lógica e seu espaço de endereços, procure VNet. Se descreve uma faixa interna usada para organizar workloads, procure subnet. Se descreve datacenters fisicamente separados, o conceito é Availability Zone.$content$,null,null,9),
  ('7b0e0000-0000-4000-8000-000000000010','summary','Resumo para memória ativa',
   null,'{"items":["VNet é uma rede privada lógica no Azure.","O espaço de endereços pertence à VNet.","Subnet é uma faixa dentro do espaço da VNet.","Subnets ajudam a organizar e segmentar workloads.","Comunicação depende das regras e configurações aplicadas.","VNet, subnet, Availability Zone e Resource Group são conceitos diferentes."]}'::jsonb,null,10);

insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, visual_experience_id,
  display_order, is_published
)
select seed.id, lesson.id, seed.type, seed.title, seed.content, seed.config,
  seed.visual_experience_id, seed.display_order, true
from stage_872_block_seed seed
join public.lessons lesson
  on lesson.topic_id = '32000000-0000-4000-8000-000000000003'
 and lesson.slug = 'virtual-networks-and-subnets';

create temporary table stage_872_flashcard_update (
  id uuid primary key, front_text text not null, back_text text not null, hint text
) on commit drop;

insert into stage_872_flashcard_update values
  ('70000000-0000-4000-8000-000000000022','O que é uma Azure Virtual Network (VNet)?','É uma rede privada lógica no Azure que fornece isolamento lógico e um espaço de endereços para recursos habilitados para rede.','Rede lógica no Azure.'),
  ('70000000-0000-4000-8000-000000000023','O que é uma subnet?','É uma faixa de endereços IP dentro do espaço de uma VNet, usada para organizar e segmentar recursos.','Existe dentro de uma VNet.'),
  ('70000000-0000-4000-8000-000000000024','Qual é a relação entre VNet e subnet?','A VNet define o espaço de endereços; uma ou mais subnets usam faixas contidas nesse espaço.','Rede e divisão interna.'),
  ('72000000-0000-4000-8000-000000000018','Por que dividir uma VNet em subnets?','Para organizar e segmentar workloads por função ou camada e preparar a aplicação de configurações de rede distintas.','Organização e segmentação.'),
  ('72000000-0000-4000-8000-000000000019','Recursos em subnets diferentes da mesma VNet sempre podem se comunicar?','Não necessariamente. Eles podem se comunicar pela rede privada, mas o tráfego depende de regras, rotas e configurações aplicáveis.','Mesma VNet não libera todo tráfego.'),
  ('72000000-0000-4000-8000-000000000020','Uma VNet pertence a uma Region?', 'Sim. Uma VNet é criada em uma Azure Region e pode participar de arquiteturas conectadas a outras redes por mecanismos estudados separadamente.','Escopo regional.'),
  ('72000000-0000-4000-8000-000000000021','O que representa 10.0.0.0/16 em uma VNet?','Um exemplo de espaço de endereços da VNet, do qual podem ser destinadas faixas menores às subnets.','Não exige cálculo de hosts.'),
  ('72000000-0000-4000-8000-000000000022','Subnet é o mesmo que Availability Zone ou Resource Group?','Não. Subnet é uma faixa de rede; Availability Zone é isolamento físico e Resource Group é um contêiner lógico de gerenciamento.','Rede, localização e gerenciamento.');

update public.flashcards card
set front_text = seed.front_text, back_text = seed.back_text, hint = seed.hint
from stage_872_flashcard_update seed
where card.id = seed.id;

create temporary table stage_872_question_seed (
  id uuid primary key, question_text text not null, difficulty text not null,
  explanation text not null, display_order integer not null
) on commit drop;

insert into stage_872_question_seed values
  ('68000000-0000-4000-8000-000000000025','Qual descrição corresponde a uma Azure Virtual Network (VNet)?','easy','Uma VNet é uma rede privada lógica no Azure que define um espaço de endereços e organiza a conectividade de recursos.',1),
  ('68000000-0000-4000-8000-000000000026','O que é uma subnet em uma Azure VNet?','easy','Subnet é uma faixa de endereços IP contida no espaço da VNet, usada para organizar e segmentar recursos.',2),
  ('68000000-0000-4000-8000-000000000027','Uma VNet usa 10.0.0.0/16 e possui subnets 10.0.1.0/24, 10.0.2.0/24 e 10.0.3.0/24. Qual interpretação está correta?','medium','O /16 representa o espaço da VNet e os /24 representam faixas internas destinadas às subnets. Não é necessário calcular hosts para reconhecer essa relação.',3),
  ('68000000-0000-4000-8000-000000000028','Uma equipe quer organizar frontend, API ASP.NET Core e serviço de dados em segmentos distintos da mesma rede privada lógica. Qual desenho é mais alinhado?','medium','Uma VNet com web-subnet, api-subnet e data-subnet organiza as camadas em faixas distintas. Regras e requisitos reais ainda determinam a comunicação.',4),
  ('68000000-0000-4000-8000-000000000029','Dois recursos estão em subnets diferentes da mesma VNet. Qual afirmação é tecnicamente mais adequada?','hard','Eles podem usar conectividade privada da VNet, mas a comunicação efetiva depende de regras, rotas e configurações. Subnet não é Zone nem Resource Group.',5);

insert into public.questions (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select seed.id, certification.id, domain.id, topic.id, lesson.id,
  seed.question_text, 'single_choice', seed.difficulty, seed.explanation, true,
  seed.display_order
from stage_872_question_seed seed
join public.certifications certification on certification.code = 'az-900'
join public.domains domain on domain.certification_id = certification.id
  and domain.title = 'Describe Azure architecture and services'
join public.topics topic on topic.domain_id = domain.id and topic.title = 'Networking Services'
join public.lessons lesson on lesson.topic_id = topic.id and lesson.slug = 'virtual-networks-and-subnets';

create temporary table stage_872_option_seed (
  id uuid primary key, question_id uuid not null, option_text text not null,
  is_correct boolean not null, explanation text not null, display_order integer not null
) on commit drop;

insert into stage_872_option_seed values
  ('7f100000-0000-4000-8000-000000000097','68000000-0000-4000-8000-000000000025','Uma rede privada lógica no Azure com um espaço de endereços.',true,'Correta. Essa é a função conceitual de uma VNet.',1),
  ('7f100000-0000-4000-8000-000000000098','68000000-0000-4000-8000-000000000025','Um contêiner lógico usado apenas para cobrança e permissões.',false,'Incorreta. Isso descreve aspectos de escopos de gerenciamento, não uma VNet.',2),
  ('7f100000-0000-4000-8000-000000000099','68000000-0000-4000-8000-000000000025','Um datacenter fisicamente separado dentro de uma Region.',false,'Incorreta. Isso se relaciona a Availability Zones e datacenters.',3),
  ('7f100000-0000-4000-8000-000000000100','68000000-0000-4000-8000-000000000025','Uma rede física dedicada automaticamente a cada cliente.',false,'Incorreta. VNet oferece isolamento lógico, não hardware de rede automaticamente dedicado.',4),
  ('7f100000-0000-4000-8000-000000000101','68000000-0000-4000-8000-000000000026','Uma faixa de endereços IP dentro do espaço da VNet.',true,'Correta. Uma subnet divide logicamente o espaço da VNet.',1),
  ('7f100000-0000-4000-8000-000000000102','68000000-0000-4000-8000-000000000026','Uma segunda VNet criada automaticamente para cada workload.',false,'Incorreta. Subnet permanece dentro de uma VNet.',2),
  ('7f100000-0000-4000-8000-000000000103','68000000-0000-4000-8000-000000000026','Uma Availability Zone reservada para recursos de rede.',false,'Incorreta. Zone é um conceito de isolamento físico.',3),
  ('7f100000-0000-4000-8000-000000000104','68000000-0000-4000-8000-000000000026','Um Resource Group exclusivo para interfaces de rede.',false,'Incorreta. Resource Group é um contêiner de gerenciamento.',4),
  ('7f100000-0000-4000-8000-000000000105','68000000-0000-4000-8000-000000000027','O /16 é o espaço da VNet e cada /24 é uma faixa interna de subnet.',true,'Correta. A relação conceitual é VNet para subnets contidas.',1),
  ('7f100000-0000-4000-8000-000000000106','68000000-0000-4000-8000-000000000027','Cada /24 representa uma Region diferente do Azure.',false,'Incorreta. Intervalos de rede não representam Regions.',2),
  ('7f100000-0000-4000-8000-000000000107','68000000-0000-4000-8000-000000000027','O /16 representa um Resource Group e os /24 representam recursos.',false,'Incorreta. CIDR descreve intervalos de endereços, não escopos de gerenciamento.',3),
  ('7f100000-0000-4000-8000-000000000108','68000000-0000-4000-8000-000000000027','Os três /24 são redes físicas dedicadas fora da VNet.',false,'Incorreta. Eles representam subnets lógicas dentro da VNet.',4),
  ('7f100000-0000-4000-8000-000000000109','68000000-0000-4000-8000-000000000028','Uma VNet com web-subnet, api-subnet e data-subnet.',true,'Correta. As subnets organizam as camadas dentro da mesma VNet.',1),
  ('7f100000-0000-4000-8000-000000000110','68000000-0000-4000-8000-000000000028','Um Resource Group diferente para substituir cada subnet.',false,'Incorreta. Resource Groups não substituem a segmentação de rede.',2),
  ('7f100000-0000-4000-8000-000000000111','68000000-0000-4000-8000-000000000028','Uma Availability Zone obrigatória para cada camada.',false,'Incorreta. Subnet e Availability Zone resolvem dimensões diferentes.',3),
  ('7f100000-0000-4000-8000-000000000112','68000000-0000-4000-8000-000000000028','Uma única subnet, pois uma VNet não aceita subdivisões.',false,'Incorreta. Uma VNet pode conter uma ou mais subnets.',4),
  ('7f100000-0000-4000-8000-000000000113','68000000-0000-4000-8000-000000000029','Eles podem se comunicar de forma privada, sujeitos às regras, rotas e configurações aplicáveis.',true,'Correta. Mesma VNet oferece o caminho lógico, mas não garante que todo tráfego seja permitido.',1),
  ('7f100000-0000-4000-8000-000000000114','68000000-0000-4000-8000-000000000029','Eles sempre se comunicam sem qualquer possibilidade de restrição.',false,'Incorreta. Controles e configurações podem restringir o tráfego.',2),
  ('7f100000-0000-4000-8000-000000000115','68000000-0000-4000-8000-000000000029','Eles não podem se comunicar porque cada subnet é uma VNet independente.',false,'Incorreta. As duas subnets pertencem à mesma VNet.',3),
  ('7f100000-0000-4000-8000-000000000116','68000000-0000-4000-8000-000000000029','Eles só se comunicam quando as subnets são Resource Groups na mesma Zone.',false,'Incorreta. Subnet, Resource Group e Availability Zone são conceitos diferentes.',4);

insert into public.question_options (
  id, question_id, option_text, is_correct, explanation, display_order
)
select id, question_id, option_text, is_correct, explanation, display_order
from stage_872_option_seed;

do $$
declare
  target_lesson_id uuid;
begin
  select id into strict target_lesson_id
  from public.lessons
  where topic_id = '32000000-0000-4000-8000-000000000003'
    and slug = 'virtual-networks-and-subnets';

  if (select count(*) from public.lesson_content_blocks where lesson_id = target_lesson_id and is_published) <> 10
    or (select count(*) from public.visual_experiences where lesson_id = target_lesson_id and is_published) <> 1
    or (select count(*) from public.flashcards where lesson_id = target_lesson_id and is_published) <> 8
    or (select count(*) from public.questions where lesson_id = target_lesson_id and is_published) <> 5 then
    raise exception '8.7.2 final content counts are invalid';
  end if;

  if exists (
    select 1 from public.questions question
    left join public.question_options option on option.question_id = question.id
    where question.lesson_id = target_lesson_id and question.is_published
    group by question.id
    having count(option.id) <> 4 or count(option.id) filter (where option.is_correct) <> 1
  ) then
    raise exception '8.7.2 Question options are invalid';
  end if;

  if (select count(*) from public.questions where lesson_id = target_lesson_id and difficulty = 'easy') <> 2
    or (select count(*) from public.questions where lesson_id = target_lesson_id and difficulty = 'medium') <> 2
    or (select count(*) from public.questions where lesson_id = target_lesson_id and difficulty = 'hard') <> 1 then
    raise exception '8.7.2 Question difficulty distribution is invalid';
  end if;
end;
$$;

commit;

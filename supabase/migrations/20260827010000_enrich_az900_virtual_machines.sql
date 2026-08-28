begin;

do $$
declare
  scoped_lesson_count integer;
begin
  select count(*)
  into scoped_lesson_count
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Compute Services'
    and lesson.slug in ('azure-virtual-machines', 'virtual-machine-resources');

  if scoped_lesson_count <> 2 then
    raise exception '8.6.2 expected exactly two scoped Lessons';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug in ('azure-virtual-machines', 'virtual-machine-resources')
  ) then
    raise exception 'A scoped 8.6.2 Lesson already contains Content Blocks';
  end if;

  if exists (
    select 1
    from public.visual_experiences visual
    join public.lessons lesson on lesson.id = visual.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug in ('azure-virtual-machines', 'virtual-machine-resources')
  ) then
    raise exception 'A scoped 8.6.2 Lesson already contains a Visual Experience';
  end if;

  if exists (
    select 1 from public.visual_experiences
    where id = '76000000-0000-4000-8000-000000000008'
  ) then
    raise exception 'The planned VM Resources Visual Experience UUID is already in use';
  end if;
end;
$$;

update public.lessons
set estimated_minutes = case slug
  when 'azure-virtual-machines' then 12
  when 'virtual-machine-resources' then 10
  else estimated_minutes
end
where topic_id = '32000000-0000-4000-8000-000000000002'
  and slug in ('azure-virtual-machines', 'virtual-machine-resources');

insert into public.visual_experiences (
  id, lesson_id, type, title, description, config, display_order, is_published
)
select
  '76000000-0000-4000-8000-000000000008',
  lesson.id,
  'architecture',
  'Recursos relacionados a uma Azure VM',
  'A VM combina compute, storage e networking. Selecione os componentes para entender suas relações e quais são opcionais.',
  $json$
  {
    "nodes": [
      {
        "id": "virtual-network",
        "label": "Virtual Network",
        "kind": "group",
        "description": "Rede virtual que fornece o espaço de comunicação privada onde a NIC da VM se conecta.",
        "x": 50,
        "y": 10
      },
      {
        "id": "subnet",
        "label": "Subnet",
        "kind": "group",
        "description": "Segmento da Virtual Network usado pela configuração de IP da NIC. Networking detalhado será estudado depois.",
        "x": 50,
        "y": 25
      },
      {
        "id": "network-interface",
        "label": "Network Interface (NIC)",
        "kind": "resource",
        "description": "Conecta a VM à Virtual Network por meio de uma subnet e possui configurações de IP.",
        "x": 50,
        "y": 40
      },
      {
        "id": "public-ip",
        "label": "Public IP opcional",
        "kind": "external",
        "description": "Só é necessário quando o cenário exige comunicação pública direta. A VM pode operar somente com conectividade privada.",
        "x": 82,
        "y": 40
      },
      {
        "id": "virtual-machine",
        "label": "Virtual Machine",
        "kind": "service",
        "description": "Recurso de compute IaaS que executa um guest OS e o software administrado pelo cliente.",
        "x": 50,
        "y": 58
      },
      {
        "id": "vm-size",
        "label": "Compute / VM Size",
        "kind": "resource",
        "description": "Define uma combinação de capacidade, como vCPUs, memória e limites associados à VM.",
        "x": 18,
        "y": 80
      },
      {
        "id": "os-disk",
        "label": "OS Disk",
        "kind": "resource",
        "description": "Disco que contém o sistema operacional usado para inicializar a VM.",
        "x": 50,
        "y": 80
      },
      {
        "id": "data-disks",
        "label": "Data Disk(s) opcionais",
        "kind": "resource",
        "description": "Discos adicionais usados quando a carga precisa separar ou ampliar o armazenamento de dados.",
        "x": 82,
        "y": 80
      }
    ],
    "edges": [
      {"id": "vnet-subnet", "source": "virtual-network", "target": "subnet", "label": "contém"},
      {"id": "subnet-nic", "source": "subnet", "target": "network-interface", "label": "conecta"},
      {"id": "public-ip-nic", "source": "public-ip", "target": "network-interface", "label": "opcional"},
      {"id": "nic-vm", "source": "network-interface", "target": "virtual-machine", "label": "anexa"},
      {"id": "vm-compute", "source": "virtual-machine", "target": "vm-size", "label": "capacidade"},
      {"id": "vm-os-disk", "source": "virtual-machine", "target": "os-disk", "label": "inicializa"},
      {"id": "vm-data-disks", "source": "virtual-machine", "target": "data-disks", "label": "opcional"}
    ]
  }
  $json$::jsonb,
  1,
  true
from public.lessons lesson
where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
  and lesson.slug = 'virtual-machine-resources';

create temporary table vm_block_seed (
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

insert into vm_block_seed (
  id, lesson_slug, type, title, content, config, visual_experience_id,
  display_order, is_published
)
values
  (
    '7b0a0000-0000-4000-8000-000000000001',
    'azure-virtual-machines',
    'explanation',
    'O que é uma Azure Virtual Machine?',
    $content$Azure Virtual Machine é um recurso de compute virtualizado executado na infraestrutura do Azure. Ela fornece um guest operating system no qual a equipe pode instalar e configurar software.

VM é uma opção de Infrastructure as a Service (IaaS): a Microsoft opera datacenters, hardware e virtualização, enquanto o cliente mantém maior controle sobre o ambiente virtual.$content$,
    null, null, 1, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000002',
    'azure-virtual-machines',
    'important',
    'Shared Responsibility em uma VM',
    $content$O cliente normalmente administra o guest OS, patches e configuração do sistema, aplicações instaladas, dados e configuração da aplicação. A Microsoft continua responsável pela infraestrutura física e pela virtualização subjacente.

Automação e serviços adicionais podem ajudar nessas tarefas, mas não transformam automaticamente a VM em um serviço PaaS totalmente gerenciado.$content$,
    null, null, 2, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000003',
    'azure-virtual-machines',
    'example',
    'Quando uma VM pode ser adequada',
    $content$Uma VM pode ser apropriada para uma aplicação legada que exige uma versão específica do sistema operacional, um software instalado diretamente no ambiente ou configurações que uma plataforma gerenciada não oferece.

Também pode apoiar migração de workloads existentes ou ambientes de desenvolvimento e teste que precisam de maior controle. Isso não significa que VM seja sempre a melhor opção: mais controle normalmente traz mais responsabilidade operacional.$content$,
    null, null, 3, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000004',
    'azure-virtual-machines',
    'dotnet_example',
    'ASP.NET Core com dependências específicas',
    $content$Uma aplicação ASP.NET Core depende de um componente instalado no sistema operacional e exige configuração específica do servidor. Uma Azure VM pode atender ao requisito porque a equipe controla o guest OS, o runtime e o software instalado.

Se a aplicação não precisasse desse controle, uma opção PaaS poderia reduzir o trabalho operacional. A linguagem .NET, sozinha, não determina a escolha.$content$,
    null, null, 4, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000005',
    'azure-virtual-machines',
    'exam_trap',
    'O que uma VM não significa',
    $content$Azure VM não é automaticamente um servidor físico dedicado: ela é uma máquina virtual executada sobre infraestrutura administrada pela Microsoft.

Também não é equivalente a Azure Web Apps. Em uma VM, o cliente normalmente administra o guest OS; em uma plataforma web gerenciada, o provider administra mais camadas.$content$,
    null, null, 5, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000006',
    'azure-virtual-machines',
    'exam_tip',
    'Procure o requisito de controle',
    $content$Quando o cenário exige controlar o sistema operacional, instalar software específico ou manter compatibilidade com uma carga legada, Azure Virtual Machines tende a ser uma candidata. Quando o objetivo é apenas publicar código com menos administração, compare com opções gerenciadas.$content$,
    null, null, 6, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000007',
    'azure-virtual-machines',
    'summary',
    'Resumo para memória ativa',
    null,
    $json${"items": ["Azure VM oferece compute virtualizado no modelo IaaS.", "O cliente controla o guest OS e o software instalado.", "A Microsoft administra hardware, datacenter e virtualização subjacentes.", "VM pode atender workloads legados ou dependências específicas.", "Maior controle implica maior responsabilidade operacional.", "VM não é servidor físico dedicado nem serviço PaaS totalmente gerenciado."]}$json$::jsonb,
    null, 7, true
  ),

  (
    '7b0a0000-0000-4000-8000-000000000008',
    'virtual-machine-resources',
    'explanation',
    'Uma VM combina compute, storage e networking',
    $content$A VM não é somente CPU e memória. VM size representa a capacidade de compute; o OS disk contém o sistema operacional; data disks podem ser adicionados quando a carga precisa de armazenamento separado.

Para comunicação, a VM usa uma Network Interface (NIC) conectada a uma subnet de uma Virtual Network. A NIC possui configurações de IP que permitem conectividade privada e, quando necessário, podem se relacionar a um Public IP.$content$,
    null, null, 1, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000009',
    'virtual-machine-resources',
    'visual_experience',
    null, null, null,
    '76000000-0000-4000-8000-000000000008',
    2, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000010',
    'virtual-machine-resources',
    'explanation',
    'Como os recursos se relacionam',
    $content$VM size define uma combinação de recursos e limites, como vCPUs e memória. Toda VM usa um OS disk; data disks adicionais dependem da carga.

A NIC conecta a VM à rede. Sua configuração de IP se associa a uma subnet da Virtual Network. Um endereço privado é usado na comunicação interna; Public IP é opcional e só deve existir quando o cenário exigir exposição ou acesso público direto.$content$,
    null, null, 3, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000011',
    'virtual-machine-resources',
    'example',
    'Backend privado em uma VM',
    $content$Um backend interno pode usar uma VM com tamanho adequado, OS disk e NIC conectada à subnet da aplicação. Ele pode funcionar somente com IP privado.

Se a aplicação precisar armazenar dados separados do sistema operacional, a equipe pode anexar data disks. Public IP não é um requisito universal para criar ou operar uma VM.$content$,
    null, null, 4, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000012',
    'virtual-machine-resources',
    'important',
    'Ciclos de cobrança e lifecycle são diferentes',
    $content$Desalocar uma VM interrompe a cobrança da instância de compute, mas não significa custo zero para toda a solução. Discos, endereços IP ou outros recursos relacionados podem continuar sujeitos a cobrança conforme tipo e configuração.

Excluir a VM também não produz um único resultado universal: discos, NICs e Public IPs podem ser excluídos ou apenas desanexados, conforme as opções configuradas.$content$,
    null, null, 5, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000013',
    'virtual-machine-resources',
    'exam_trap',
    'Public IP e exclusão não são automáticos',
    $content$Public IP é opcional. Uma VM que atende somente tráfego privado não precisa obrigatoriamente dele.

Também evite a regra “deletar a VM sempre deleta todos os recursos”. O comportamento de OS disk, data disks, NIC e Public IP depende das opções de exclusão e da configuração.$content$,
    null, null, 6, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000014',
    'virtual-machine-resources',
    'exam_tip',
    'Mapeie cada requisito à categoria correta',
    $content$VM size representa compute; OS disk e data disks representam storage; NIC, Virtual Network, subnet e configurações de IP representam networking. Em uma questão, identifique primeiro qual categoria atende ao requisito apresentado.$content$,
    null, null, 7, true
  ),
  (
    '7b0a0000-0000-4000-8000-000000000015',
    'virtual-machine-resources',
    'summary',
    'Resumo para memória ativa',
    null,
    $json${"items": ["VM size define capacidade de compute e limites associados.", "OS disk contém o sistema operacional.", "Data disks são adicionais e dependem da carga.", "A NIC conecta a VM a uma subnet da Virtual Network.", "Public IP é opcional; conectividade privada pode ser suficiente.", "Compute, discos e rede podem ter ciclos de cobrança e exclusão diferentes."]}$json$::jsonb,
    null, 8, true
  );

insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, visual_experience_id,
  display_order, is_published
)
select
  seed.id, lesson.id, seed.type, seed.title, seed.content, seed.config,
  seed.visual_experience_id, seed.display_order, seed.is_published
from vm_block_seed seed
join public.lessons lesson
  on lesson.topic_id = '32000000-0000-4000-8000-000000000002'
 and lesson.slug = seed.lesson_slug;

update public.flashcards
set
  front_text = case id
    when '71000000-0000-4000-8000-000000000105' then 'O que é uma Azure Virtual Machine?'
    when '71000000-0000-4000-8000-000000000107' then 'Desalocar uma Azure VM elimina todos os custos relacionados?'
    when '71000000-0000-4000-8000-000000000108' then 'Como Azure VM difere de um serviço gerenciado como Azure Web Apps?'
    when '72000000-0000-4000-8000-000000000004' then 'Quais categorias de recursos normalmente apoiam uma Azure VM?'
    when '72000000-0000-4000-8000-000000000005' then 'Qual é a diferença entre OS disk e data disk em uma VM?'
    when '72000000-0000-4000-8000-000000000006' then 'Excluir uma VM sempre exclui discos, NIC e Public IP associados?'
    else front_text
  end,
  back_text = case id
    when '71000000-0000-4000-8000-000000000105' then 'É um recurso de compute virtualizado no modelo IaaS. O cliente controla o guest OS e o software; a Microsoft administra hardware e virtualização subjacentes.'
    when '71000000-0000-4000-8000-000000000107' then 'Não. A instância de compute desalocada não é cobrada, mas discos e alguns recursos de networking podem continuar sujeitos a cobrança.'
    when '71000000-0000-4000-8000-000000000108' then 'Na VM, o cliente normalmente administra o guest OS, patches e software. Em Azure Web Apps, a plataforma administra mais dessas camadas.'
    when '72000000-0000-4000-8000-000000000004' then 'Compute pelo VM size, storage pelo OS disk e data disks opcionais, e networking pela NIC conectada à subnet/VNet e suas configurações de IP.'
    when '72000000-0000-4000-8000-000000000005' then 'OS disk contém o sistema operacional. Data disk é armazenamento adicional usado quando a carga precisa separar ou ampliar seus dados.'
    when '72000000-0000-4000-8000-000000000006' then 'Não. Esses recursos podem ser excluídos ou desanexados conforme as opções de exclusão e a configuração; recursos mantidos podem continuar gerando custo.'
    else back_text
  end,
  hint = case id
    when '71000000-0000-4000-8000-000000000105' then 'IaaS e Shared Responsibility.'
    when '71000000-0000-4000-8000-000000000107' then 'Compute e recursos associados têm ciclos diferentes.'
    when '71000000-0000-4000-8000-000000000108' then 'Controle do guest OS.'
    when '72000000-0000-4000-8000-000000000004' then 'Compute + storage + networking.'
    when '72000000-0000-4000-8000-000000000005' then 'Inicialização versus dados adicionais.'
    when '72000000-0000-4000-8000-000000000006' then 'Delete ou Detach.'
    else hint
  end
where id in (
  '71000000-0000-4000-8000-000000000105',
  '71000000-0000-4000-8000-000000000107',
  '71000000-0000-4000-8000-000000000108',
  '72000000-0000-4000-8000-000000000004',
  '72000000-0000-4000-8000-000000000005',
  '72000000-0000-4000-8000-000000000006'
);

update public.questions
set
  question_text = 'Uma equipe desalocou uma Azure VM e concluiu que toda a solução deixou de gerar custos. Qual análise está correta?',
  explanation = 'A VM desalocada deixa de gerar cobrança da instância de compute, mas discos e alguns recursos de networking podem continuar sujeitos a cobrança conforme tipo e configuração.',
  difficulty = 'hard'
where id = '65000000-0000-4000-8000-000000000020'
  and lesson_id = (
    select id from public.lessons
    where topic_id = '32000000-0000-4000-8000-000000000002'
      and slug = 'azure-virtual-machines'
  );

update public.question_options
set
  option_text = case id
    when '77000000-0000-4000-8000-000000000077' then 'A desalocação interrompe a cobrança da instância de compute, mas discos e alguns recursos de networking podem continuar sujeitos a cobrança.'
    when '77000000-0000-4000-8000-000000000078' then 'Desligar o sistema operacional sempre desaloca a VM e elimina automaticamente toda cobrança associada.'
    when '77000000-0000-4000-8000-000000000079' then 'A única forma de interromper a cobrança de compute é excluir permanentemente a VM e todos os seus discos.'
    when '77000000-0000-4000-8000-000000000080' then 'Os estados Stopped (allocated) e Deallocated possuem exatamente o mesmo comportamento de cobrança de compute.'
    else option_text
  end,
  explanation = case id
    when '77000000-0000-4000-8000-000000000077' then 'Correta. Desalocar libera a capacidade de compute, mas não encerra necessariamente a cobrança dos recursos associados.'
    when '77000000-0000-4000-8000-000000000078' then 'Incorreta. Desligar dentro do guest OS pode manter a VM alocada, e recursos associados possuem cobrança própria.'
    when '77000000-0000-4000-8000-000000000079' then 'Incorreta. A desalocação interrompe a cobrança de compute sem exigir exclusão da VM; discos podem permanecer.'
    when '77000000-0000-4000-8000-000000000080' then 'Incorreta. Stopped (allocated) continua alocada e pode gerar cobrança de compute; Deallocated libera essa capacidade.'
    else explanation
  end
where id in (
  '77000000-0000-4000-8000-000000000077',
  '77000000-0000-4000-8000-000000000078',
  '77000000-0000-4000-8000-000000000079',
  '77000000-0000-4000-8000-000000000080'
);

update public.question_options
set is_correct = false
where question_id = '65000000-0000-4000-8000-000000000020'
  and is_correct;

update public.question_options
set is_correct = true
where id = '77000000-0000-4000-8000-000000000077'
  and question_id = '65000000-0000-4000-8000-000000000020';

create temporary table vm_resource_question_seed (
  id uuid primary key,
  question_text text not null,
  difficulty text not null,
  explanation text not null,
  display_order integer not null
) on commit drop;

insert into vm_resource_question_seed values
  ('68000000-0000-4000-8000-000000000001', 'O que o VM size representa conceitualmente em uma Azure Virtual Machine?', 'easy', 'VM size define uma combinação de capacidade e limites de compute, como vCPUs e memória disponíveis para a VM.', 1),
  ('68000000-0000-4000-8000-000000000002', 'Qual componente contém o sistema operacional usado para inicializar uma Azure VM?', 'easy', 'O OS disk contém o sistema operacional usado pela VM. Data disks são armazenamento adicional quando necessário.', 2),
  ('68000000-0000-4000-8000-000000000003', 'Uma aplicação precisa manter dados em armazenamento adicional separado do sistema operacional. Qual recurso é apropriado?', 'medium', 'Um data disk pode ser anexado à VM para armazenar dados adicionais separados do OS disk.', 3),
  ('68000000-0000-4000-8000-000000000004', 'Qual é a função principal da Network Interface (NIC) associada a uma Azure VM?', 'medium', 'A NIC conecta a VM a uma Virtual Network por meio de uma subnet e contém configurações de IP usadas na comunicação.', 4),
  ('68000000-0000-4000-8000-000000000005', 'Um backend em Azure VM deve atender somente sistemas internos pela rede privada. Qual conjunto descreve melhor os recursos necessários?', 'hard', 'A VM precisa de compute, OS disk e NIC conectada à subnet/VNet. Ela pode usar IP privado sem Public IP; data disks dependem da necessidade da carga.', 5);

with resolved_lesson as (
  select certification.id as certification_id, domain.id as domain_id,
    topic.id as topic_id, lesson.id as lesson_id
  from public.certifications certification
  join public.domains domain on domain.certification_id = certification.id
  join public.topics topic on topic.domain_id = domain.id
  join public.lessons lesson on lesson.topic_id = topic.id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Compute Services'
    and lesson.slug = 'virtual-machine-resources'
)
insert into public.questions (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select seed.id, target.certification_id, target.domain_id, target.topic_id,
  target.lesson_id, seed.question_text, 'single_choice', seed.difficulty,
  seed.explanation, true, seed.display_order
from vm_resource_question_seed seed
cross join resolved_lesson target;

create temporary table vm_resource_option_seed (
  id uuid primary key,
  question_id uuid not null,
  option_text text not null,
  is_correct boolean not null,
  explanation text not null,
  display_order integer not null
) on commit drop;

insert into vm_resource_option_seed values
  ('7f100000-0000-4000-8000-000000000001','68000000-0000-4000-8000-000000000001','Uma combinação de capacidade e limites, como vCPUs e memória.',true,'Correta. VM size determina a capacidade de compute e limites relacionados.',1),
  ('7f100000-0000-4000-8000-000000000002','68000000-0000-4000-8000-000000000001','A quantidade obrigatória de Public IPs conectados à VM.',false,'Incorreta. Public IP é opcional e não define o VM size.',2),
  ('7f100000-0000-4000-8000-000000000003','68000000-0000-4000-8000-000000000001','O conteúdo armazenado no OS disk da VM.',false,'Incorreta. O OS disk contém o sistema operacional; VM size representa compute.',3),
  ('7f100000-0000-4000-8000-000000000004','68000000-0000-4000-8000-000000000001','A subnet que contém fisicamente a máquina virtual.',false,'Incorreta. Subnet é um segmento lógico de rede, não a capacidade de compute.',4),

  ('7f100000-0000-4000-8000-000000000005','68000000-0000-4000-8000-000000000002','OS disk.',true,'Correta. O OS disk armazena o sistema operacional usado para inicializar a VM.',1),
  ('7f100000-0000-4000-8000-000000000006','68000000-0000-4000-8000-000000000002','Network Interface.',false,'Incorreta. A NIC fornece conectividade, não armazena o sistema operacional.',2),
  ('7f100000-0000-4000-8000-000000000007','68000000-0000-4000-8000-000000000002','Public IP.',false,'Incorreta. Public IP fornece endereçamento público opcional.',3),
  ('7f100000-0000-4000-8000-000000000008','68000000-0000-4000-8000-000000000002','Virtual Network.',false,'Incorreta. A VNet fornece o contexto de rede privada.',4),

  ('7f100000-0000-4000-8000-000000000009','68000000-0000-4000-8000-000000000003','Anexar um data disk à VM.',true,'Correta. Data disks oferecem armazenamento adicional separado do OS disk.',1),
  ('7f100000-0000-4000-8000-000000000010','68000000-0000-4000-8000-000000000003','Adicionar um segundo Public IP à NIC.',false,'Incorreta. Endereçamento de rede não fornece o armazenamento solicitado.',2),
  ('7f100000-0000-4000-8000-000000000011','68000000-0000-4000-8000-000000000003','Trocar a subnet usada pela NIC.',false,'Incorreta. Subnet altera o contexto de rede, não adiciona armazenamento.',3),
  ('7f100000-0000-4000-8000-000000000012','68000000-0000-4000-8000-000000000003','Criar outra Virtual Network para armazenar os dados.',false,'Incorreta. Virtual Network é networking, não storage.',4),

  ('7f100000-0000-4000-8000-000000000013','68000000-0000-4000-8000-000000000004','Conectar a VM à subnet de uma Virtual Network e manter suas configurações de IP.',true,'Correta. A NIC fornece a conexão de rede usada pela VM.',1),
  ('7f100000-0000-4000-8000-000000000014','68000000-0000-4000-8000-000000000004','Armazenar o guest OS usado pela VM.',false,'Incorreta. Essa é a função do OS disk.',2),
  ('7f100000-0000-4000-8000-000000000015','68000000-0000-4000-8000-000000000004','Definir a quantidade de vCPUs e memória.',false,'Incorreta. Essa capacidade é determinada pelo VM size.',3),
  ('7f100000-0000-4000-8000-000000000016','68000000-0000-4000-8000-000000000004','Substituir todos os data disks da VM.',false,'Incorreta. A NIC é um recurso de networking, não de armazenamento.',4),

  ('7f100000-0000-4000-8000-000000000017','68000000-0000-4000-8000-000000000005','VM size, OS disk e NIC conectada à subnet/VNet, usando IP privado; Public IP não é obrigatório.',true,'Correta. Esses recursos cobrem compute, inicialização e conectividade privada.',1),
  ('7f100000-0000-4000-8000-000000000018','68000000-0000-4000-8000-000000000005','Somente VM size e Public IP; discos e NIC são opcionais em toda VM.',false,'Incorreta. A VM precisa de OS disk e NIC; Public IP é que pode ser opcional.',2),
  ('7f100000-0000-4000-8000-000000000019','68000000-0000-4000-8000-000000000005','VM size, OS disk e Public IP, sem NIC nem Virtual Network.',false,'Incorreta. A conectividade da VM usa uma NIC ligada à rede; Public IP não substitui a NIC.',3),
  ('7f100000-0000-4000-8000-000000000020','68000000-0000-4000-8000-000000000005','Somente data disks e Public IP, pois compute e OS disk são fornecidos pela subnet.',false,'Incorreta. Subnet não fornece compute nem OS disk; data disks são opcionais.',4);

insert into public.question_options (
  id, question_id, option_text, is_correct, explanation, display_order
)
select id, question_id, option_text, is_correct, explanation, display_order
from vm_resource_option_seed;

do $$
begin
  if (select count(*) from vm_block_seed) <> 15
    or (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id = block.lesson_id where lesson.topic_id = '32000000-0000-4000-8000-000000000002' and lesson.slug = 'azure-virtual-machines' and block.is_published) <> 7
    or (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id = block.lesson_id where lesson.topic_id = '32000000-0000-4000-8000-000000000002' and lesson.slug = 'virtual-machine-resources' and block.is_published) <> 8 then
    raise exception '8.6.2 Content Block counts are invalid';
  end if;

  if (select count(*) from public.visual_experiences visual join public.lessons lesson on lesson.id = visual.lesson_id where lesson.topic_id = '32000000-0000-4000-8000-000000000002' and lesson.slug in ('azure-virtual-machines', 'virtual-machine-resources')) <> 1
    or not exists (
      select 1 from public.visual_experiences
      where id = '76000000-0000-4000-8000-000000000008'
        and type = 'architecture'
        and is_published
        and jsonb_array_length(config -> 'nodes') = 8
        and jsonb_array_length(config -> 'edges') = 7
    ) then
    raise exception '8.6.2 Visual Experience is invalid';
  end if;

  if (select count(*) from vm_resource_question_seed) <> 5
    or (select count(*) from vm_resource_option_seed) <> 20
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id = question.lesson_id where lesson.topic_id = '32000000-0000-4000-8000-000000000002' and lesson.slug = 'virtual-machine-resources' and question.is_published) <> 5 then
    raise exception '8.6.2 VM Resource practice counts are invalid';
  end if;

  if exists (
    select 1
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug = 'virtual-machine-resources'
      and question.is_published
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
  ) then
    raise exception '8.6.2 Question Options are invalid';
  end if;
end;
$$;

commit;

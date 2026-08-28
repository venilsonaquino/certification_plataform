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
    and lesson.slug in ('vm-scale-sets-and-availability-sets', 'azure-virtual-desktop');

  if scoped_lesson_count <> 2 then
    raise exception '8.6.3 expected exactly two scoped Lessons';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug in ('vm-scale-sets-and-availability-sets', 'azure-virtual-desktop')
  ) then
    raise exception 'A scoped 8.6.3 Lesson already contains Content Blocks';
  end if;

  if exists (
    select 1
    from public.visual_experiences visual
    join public.lessons lesson on lesson.id = visual.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug in ('vm-scale-sets-and-availability-sets', 'azure-virtual-desktop')
  ) or exists (
    select 1 from public.visual_experiences
    where id = '76000000-0000-4000-8000-000000000009'
  ) then
    raise exception 'The scoped visual state is not ready for 8.6.3';
  end if;
end;
$$;

update public.lessons
set estimated_minutes = case slug
  when 'vm-scale-sets-and-availability-sets' then 12
  when 'azure-virtual-desktop' then 10
  else estimated_minutes
end
where topic_id = '32000000-0000-4000-8000-000000000002'
  and slug in ('vm-scale-sets-and-availability-sets', 'azure-virtual-desktop');

insert into public.visual_experiences (
  id, lesson_id, type, title, description, config, display_order, is_published
)
select
  '76000000-0000-4000-8000-000000000009',
  lesson.id,
  'architecture',
  'VM Scale Set versus Availability Set',
  'Compare escala de quantidade com distribuição contra falhas e manutenção. Availability Zones oferecem isolamento físico maior dentro de uma Region e foram estudadas anteriormente.',
  $json$
  {
    "nodes": [
      {"id":"demand","label":"Demand","kind":"external","description":"A demanda pode orientar regras de autoscale quando elas são configuradas.","x":25,"y":10},
      {"id":"scale-set","label":"VM Scale Set","kind":"service","description":"Gerencia múltiplas instâncias de VM como um conjunto e permite alterar sua quantidade.","x":25,"y":28},
      {"id":"scale-vm-1","label":"VM instance 1","kind":"resource","description":"Uma das instâncias administradas pelo Scale Set.","x":25,"y":52},
      {"id":"scale-vm-2","label":"VM instance 2","kind":"resource","description":"A quantidade pode crescer ou diminuir manualmente ou por autoscale configurado.","x":25,"y":70},
      {"id":"scale-vm-3","label":"VM instance 3","kind":"resource","description":"Load balancing e distribuição física dependem da arquitetura e configuração.","x":25,"y":88},
      {"id":"availability-set","label":"Availability Set","kind":"service","description":"Agrupamento lógico que ajuda a reduzir falhas correlacionadas e impacto de manutenção planejada.","x":75,"y":10},
      {"id":"fault-domain-1","label":"Fault Domain 1","kind":"group","description":"Grupo de infraestrutura que compartilha recursos físicos, como energia e rede.","x":62,"y":35},
      {"id":"fault-domain-2","label":"Fault Domain 2","kind":"group","description":"Outro grupo de infraestrutura para limitar o impacto de uma falha localizada.","x":87,"y":35},
      {"id":"fd1-vm-1","label":"VM A","kind":"resource","description":"VM associada ao primeiro fault domain.","x":62,"y":62},
      {"id":"fd1-vm-2","label":"VM B","kind":"resource","description":"Update domains também organizam reinicializações de manutenção planejada.","x":62,"y":84},
      {"id":"fd2-vm-1","label":"VM C","kind":"resource","description":"VM associada ao segundo fault domain.","x":87,"y":62},
      {"id":"fd2-vm-2","label":"VM D","kind":"resource","description":"Separação reduz impacto compartilhado, mas não elimina todas as falhas.","x":87,"y":84}
    ],
    "edges": [
      {"id":"demand-scale-set","source":"demand","target":"scale-set","label":"pode orientar autoscale"},
      {"id":"scale-set-vm-1","source":"scale-set","target":"scale-vm-1","label":"gerencia"},
      {"id":"scale-vm-1-vm-2","source":"scale-vm-1","target":"scale-vm-2","label":"scale out / in"},
      {"id":"scale-vm-2-vm-3","source":"scale-vm-2","target":"scale-vm-3","label":"scale out / in"},
      {"id":"availability-fd1","source":"availability-set","target":"fault-domain-1","label":"distribui"},
      {"id":"availability-fd2","source":"availability-set","target":"fault-domain-2","label":"distribui"},
      {"id":"fd1-vm-1","source":"fault-domain-1","target":"fd1-vm-1","label":"contém"},
      {"id":"fd1-vm-2","source":"fault-domain-1","target":"fd1-vm-2","label":"contém"},
      {"id":"fd2-vm-1","source":"fault-domain-2","target":"fd2-vm-1","label":"contém"},
      {"id":"fd2-vm-2","source":"fault-domain-2","target":"fd2-vm-2","label":"contém"}
    ]
  }
  $json$::jsonb,
  1,
  true
from public.lessons lesson
where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
  and lesson.slug = 'vm-scale-sets-and-availability-sets';

create temporary table stage_863_block_seed (
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

insert into stage_863_block_seed values
  (
    '7b0b0000-0000-4000-8000-000000000001', 'vm-scale-sets-and-availability-sets',
    'explanation', 'Virtual Machine Scale Sets',
    $content$Azure Virtual Machine Scale Sets permitem criar, gerenciar e atualizar múltiplas instâncias de VM como um conjunto. A quantidade de instâncias pode aumentar ou diminuir para acompanhar a necessidade da carga.

Essa escala pode ser manual. Quando autoscale é configurado, regras baseadas em métricas, demanda ou programação podem alterar a quantidade automaticamente. Um Scale Set representa escala horizontal: mais ou menos instâncias, não apenas uma VM maior.$content$,
    null, null, 1, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000002', 'vm-scale-sets-and-availability-sets',
    'example', 'E-commerce com demanda variável',
    $content$Uma aplicação de e-commerce usa várias VMs para atender requisições. Durante uma promoção, um VM Scale Set configurado com autoscale pode adicionar instâncias; quando a demanda cai, pode removê-las dentro dos limites definidos.

O benefício central é gerenciar e escalar múltiplas VMs como um conjunto. As regras, métricas e limites precisam ser configurados.$content$,
    null, null, 2, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000003', 'vm-scale-sets-and-availability-sets',
    'important', 'Escala e disponibilidade dependem da configuração',
    $content$VM Scale Set não significa que toda arquitetura use VMs obrigatoriamente idênticas, que um Load Balancer sempre será criado ou que as instâncias estarão automaticamente distribuídas entre Zones.

O Scale Set pode integrar-se a balanceamento e pode distribuir instâncias para melhorar resiliência, mas o comportamento depende do modo, da Region e das opções configuradas. Esses detalhes não precisam ser configurados para a prova AZ-900.$content$,
    null, null, 3, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000004', 'vm-scale-sets-and-availability-sets',
    'explanation', 'Availability Sets: fault domains e update domains',
    $content$Availability Set é um agrupamento lógico para VMs que reduz a chance de falhas correlacionadas e de manutenção planejada indisponibilizarem todas ao mesmo tempo.

Fault domains separam VMs entre grupos de infraestrutura que compartilham recursos físicos, como energia e rede. Update domains organizam grupos que podem ser reiniciados durante manutenção planejada, evitando que todos precisem ser afetados simultaneamente.$content$,
    null, null, 4, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000005', 'vm-scale-sets-and-availability-sets',
    'visual_experience', null, null, null,
    '76000000-0000-4000-8000-000000000009', 5, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000006', 'vm-scale-sets-and-availability-sets',
    'important', 'Availability Set versus Availability Zone',
    $content$Availability Set separa VMs por fault e update domains dentro da infraestrutura da Region e ajuda contra falhas localizadas e manutenção.

Availability Zone é um local fisicamente separado dentro de uma Region compatível, com energia, rede e refrigeração independentes, oferecendo isolamento maior. Uma arquitetura pode combinar escala e disponibilidade; nenhum desses conceitos torna uma aplicação automaticamente altamente disponível.$content$,
    null, null, 6, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000007', 'vm-scale-sets-and-availability-sets',
    'exam_trap', 'Três conceitos, três finalidades principais',
    $content$VM Scale Set gerencia e escala múltiplas instâncias; não é uma única VM maior nem sinônimo de alta disponibilidade automática.

Availability Set organiza VMs em fault/update domains; não é VM Scale Set nem Availability Zone. Availability Zone oferece isolamento físico maior entre locais da Region. A arquitetura e a configuração determinam como esses recursos trabalham juntos.$content$,
    null, null, 7, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000008', 'vm-scale-sets-and-availability-sets',
    'exam_tip', 'Identifique o requisito dominante',
    $content$Se a questão pede aumentar ou reduzir quantidade de VMs, pense em VM Scale Set. Se pede fault/update domains contra falha localizada e manutenção, pense em Availability Set. Se pede datacenters fisicamente separados dentro da Region, pense em Availability Zones.$content$,
    null, null, 8, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000009', 'vm-scale-sets-and-availability-sets',
    'summary', 'Resumo para memória ativa', null,
    $json${"items":["VM Scale Set gerencia e escala múltiplas instâncias de VM.","Autoscale depende de regras, métricas ou programação configuradas.","Availability Set usa fault domains e update domains.","Availability Set reduz impacto de falhas localizadas e manutenção planejada.","Availability Zones oferecem isolamento físico maior dentro da Region.","Scale Set, Availability Set e Availability Zone não são sinônimos."]}$json$::jsonb,
    null, 9, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000010', 'azure-virtual-desktop',
    'explanation', 'O que é Azure Virtual Desktop?',
    $content$Azure Virtual Desktop (AVD) é um serviço de virtualização de desktops e aplicações executado no Azure. Ele permite entregar uma experiência Windows completa ou aplicações específicas remotamente para usuários.

Os usuários podem acessar recursos publicados por clientes compatíveis em diferentes dispositivos e, conforme a opção disponível, por navegador. O objetivo é centralizar a experiência de trabalho, não hospedar APIs ou sites.$content$,
    null, null, 1, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000011', 'azure-virtual-desktop',
    'important', 'Desktop completo, RemoteApp e tipos de sessão',
    $content$AVD pode publicar um desktop Windows completo ou uma aplicação individual por RemoteApp. Conforme o cenário, a organização pode usar sessões individuais ou recursos compartilhados/multi-session.

Essas opções permitem equilibrar experiência, isolamento e uso de recursos. No nível AZ-900, basta reconhecer a finalidade; não é necessário conhecer host pools, imagens ou etapas de deployment.$content$,
    null, null, 2, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000012', 'azure-virtual-desktop',
    'example', 'Ambiente corporativo centralizado',
    $content$Uma empresa precisa oferecer desktops Windows e aplicações corporativas para colaboradores remotos que usam notebooks e tablets. Com AVD, a equipe publica esses recursos em um ambiente centralizado e os usuários os acessam remotamente sem depender de executar todo o software no dispositivo local.$content$,
    null, null, 3, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000013', 'azure-virtual-desktop',
    'example', 'Aplicação remota sem desktop completo',
    $content$Se o usuário precisa somente de uma aplicação corporativa, a organização pode publicá-la como RemoteApp. O programa aparece para o usuário sem exigir que toda a experiência de desktop seja apresentada. Isso continua sendo virtualização de aplicação, não Azure App Service.$content$,
    null, null, 4, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000014', 'azure-virtual-desktop',
    'exam_trap', 'AVD não é uma VM comum com RDP',
    $content$Fazer RDP diretamente em uma VM oferece acesso remoto àquela máquina. Azure Virtual Desktop é uma plataforma de virtualização de desktops e aplicações com recursos próprios de publicação, acesso e gerenciamento.

VMs podem fazer parte da infraestrutura de sessão, mas isso não torna AVD equivalente a uma VM comum. AVD também não é App Service, VPN, container nem um desktop limitado ao navegador.$content$,
    null, null, 5, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000015', 'azure-virtual-desktop',
    'exam_tip', 'Procure usuários, desktops e aplicações remotas',
    $content$Quando o requisito fala em entregar desktops Windows ou aplicações corporativas remotamente a usuários, AVD é uma candidata. Se o requisito é hospedar uma aplicação web para receber requisições, compare outras opções de application hosting.$content$,
    null, null, 6, true
  ),
  (
    '7b0b0000-0000-4000-8000-000000000016', 'azure-virtual-desktop',
    'summary', 'Resumo para memória ativa', null,
    $json${"items":["AVD virtualiza desktops e aplicações no Azure.","Pode entregar desktop Windows completo ou RemoteApp.","Usuários podem acessar por diferentes dispositivos compatíveis.","Sessões podem ser individuais ou compartilhadas conforme o cenário.","AVD centraliza experiências para usuários; não hospeda APIs.","AVD não é simplesmente uma VM comum acessada por RDP."]}$json$::jsonb,
    null, 7, true
  );

insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, visual_experience_id,
  display_order, is_published
)
select seed.id, lesson.id, seed.type, seed.title, seed.content, seed.config,
  seed.visual_experience_id, seed.display_order, seed.is_published
from stage_863_block_seed seed
join public.lessons lesson
  on lesson.topic_id = '32000000-0000-4000-8000-000000000002'
 and lesson.slug = seed.lesson_slug;

create temporary table stage_863_flashcard_update (
  id uuid primary key,
  front_text text not null,
  back_text text not null,
  hint text
) on commit drop;

insert into stage_863_flashcard_update values
  ('71000000-0000-4000-8000-000000000109','Qual é a principal finalidade de um Virtual Machine Scale Set?','Criar e gerenciar múltiplas instâncias de VM como um conjunto, permitindo aumentar ou reduzir sua quantidade manualmente ou por autoscale configurado.','Escala horizontal de múltiplas VMs.'),
  ('71000000-0000-4000-8000-000000000110','Qual é a diferença principal entre VM Scale Set e Availability Set?','VM Scale Set gerencia e escala múltiplas instâncias. Availability Set distribui VMs por fault/update domains para reduzir impacto de falhas e manutenção.','Escala versus distribuição contra falhas/manutenção.'),
  ('71000000-0000-4000-8000-000000000111','O que é um fault domain em um Availability Set?','É um grupo de infraestrutura que compartilha recursos físicos, como energia e rede. Separar VMs entre fault domains reduz o impacto de uma falha localizada.','Falha física localizada.'),
  ('71000000-0000-4000-8000-000000000112','O que é um update domain em um Availability Set?','É um grupo de VMs e infraestrutura que pode ser reiniciado durante manutenção planejada sem exigir que todos os grupos sejam afetados ao mesmo tempo.','Manutenção planejada em grupos.'),
  ('72000000-0000-4000-8000-000000000001','O que é Azure Virtual Desktop?','É um serviço de virtualização de desktops e aplicações no Azure que entrega desktops Windows completos ou aplicações remotas a usuários.','Desktop e app virtualization.'),
  ('72000000-0000-4000-8000-000000000002','Que cenário empresarial pode usar Azure Virtual Desktop?','Entrega centralizada de desktops Windows ou aplicações corporativas para usuários remotos em diferentes dispositivos compatíveis.','Experiência centralizada para usuários.'),
  ('72000000-0000-4000-8000-000000000003','AVD permite apenas uma sessão por VM?','Não. Conforme o cenário, AVD pode usar sessões individuais ou ambientes compartilhados/multi-session.','Single-session ou multi-session.');

update public.flashcards card
set front_text = seed.front_text,
  back_text = seed.back_text,
  hint = seed.hint
from stage_863_flashcard_update seed
where card.id = seed.id;

create temporary table stage_863_question_update (
  id uuid primary key,
  question_text text not null,
  difficulty text not null,
  explanation text not null
) on commit drop;

insert into stage_863_question_update values
  ('65000000-0000-4000-8000-000000000021','Qual é a finalidade principal de Azure Virtual Machine Scale Sets?','easy','VM Scale Sets permitem criar e gerenciar múltiplas instâncias de VM como um conjunto e alterar sua quantidade. Autoscale, load balancing e distribuição física dependem de configuração.'),
  ('65000000-0000-4000-8000-000000000022','Qual descrição representa corretamente um Availability Set?','easy','Availability Set é um agrupamento lógico que distribui VMs entre fault domains e update domains para reduzir impactos correlacionados de falhas e manutenção planejada.'),
  ('65000000-0000-4000-8000-000000000023','Uma aplicação executa em várias VMs e precisa aumentar ou reduzir automaticamente a quantidade de instâncias conforme métricas de demanda. Qual opção atende ao requisito quando configurada?','medium','Um VM Scale Set com regras de autoscale configuradas pode aumentar ou diminuir a quantidade de instâncias de acordo com métricas, demanda ou programação.'),
  ('65000000-0000-4000-8000-000000000024','Duas VMs na mesma Region precisam reduzir o risco de uma falha localizada ou manutenção planejada afetar ambas ao mesmo tempo. O requisito não pede isolamento entre datacenters. Qual recurso é mais diretamente relacionado?','medium','Availability Set distribui VMs por fault domains e update domains, reduzindo o risco de impacto simultâneo por falhas localizadas e manutenção planejada.'),
  ('65000000-0000-4000-8000-000000000025','Uma equipe precisa escalar horizontalmente várias VMs e também melhorar sua resiliência. Qual análise evita uma suposição incorreta?','hard','VM Scale Set atende ao gerenciamento e escala de múltiplas instâncias, mas load balancing, autoscale e distribuição por Zones ou fault domains dependem da arquitetura e configuração; alta disponibilidade não é automática.');

update public.questions question
set question_text = seed.question_text,
  difficulty = seed.difficulty,
  explanation = seed.explanation
from stage_863_question_update seed
where question.id = seed.id;

create temporary table stage_863_option_update (
  id uuid primary key,
  option_text text not null,
  explanation text not null
) on commit drop;

insert into stage_863_option_update values
  ('77000000-0000-4000-8000-000000000081','Gerenciar múltiplas instâncias de VM como um conjunto e permitir alterar sua quantidade.','Correta. Essa é a finalidade central de VM Scale Sets; automações e distribuição dependem da configuração.'),
  ('77000000-0000-4000-8000-000000000082','Aumentar apenas CPU e memória de uma única VM, sem criar outras instâncias.','Incorreta. Isso descreve escala vertical; Scale Sets são voltados ao gerenciamento de múltiplas instâncias.'),
  ('77000000-0000-4000-8000-000000000083','Substituir Availability Zones criando datacenters fisicamente separados.','Incorreta. Scale Set não cria Zones nem substitui seu isolamento físico.'),
  ('77000000-0000-4000-8000-000000000084','Garantir que qualquer aplicação seja altamente disponível sem configuração adicional.','Incorreta. Alta disponibilidade depende da arquitetura e das opções configuradas.'),
  ('77000000-0000-4000-8000-000000000085','Um agrupamento lógico que distribui VMs entre fault domains e update domains.','Correta. Availability Set reduz impacto compartilhado de falhas localizadas e manutenção planejada.'),
  ('77000000-0000-4000-8000-000000000086','Um conjunto que aumenta automaticamente a quantidade de VMs conforme CPU.','Incorreta. Isso se relaciona a autoscale em VM Scale Sets quando configurado.'),
  ('77000000-0000-4000-8000-000000000087','Um local fisicamente separado com energia, rede e refrigeração independentes.','Incorreta. Isso descreve uma Availability Zone, que oferece isolamento físico maior.'),
  ('77000000-0000-4000-8000-000000000088','Um serviço de desktop remoto para múltiplos usuários.','Incorreta. Isso descreve a finalidade de Azure Virtual Desktop.'),
  ('77000000-0000-4000-8000-000000000089','Availability Set, porque ele ajusta a quantidade de VMs usando métricas.','Incorreta. Availability Set organiza VMs por domains; não é um mecanismo de autoscale.'),
  ('77000000-0000-4000-8000-000000000090','VM Scale Set com regras de autoscale configuradas.','Correta. As regras configuradas podem ajustar a quantidade de instâncias conforme métricas ou programação.'),
  ('77000000-0000-4000-8000-000000000091','Uma única VM maior, porque escala vertical sempre acompanha a demanda automaticamente.','Incorreta. Uma VM maior é escala vertical e não implica ajuste automático da quantidade.'),
  ('77000000-0000-4000-8000-000000000092','Availability Zone, porque ela adiciona e remove VMs conforme métricas.','Incorreta. Zone fornece isolamento físico; não é mecanismo de autoscale.'),
  ('77000000-0000-4000-8000-000000000093','VM Scale Set, pois sua finalidade principal é organizar update domains sem escala.','Incorreta. O requisito é distribuição contra falhas/manutenção sem escala; Availability Set é mais direto.'),
  ('77000000-0000-4000-8000-000000000094','Availability Set, usando fault domains e update domains.','Correta. Ele reduz a chance de falha localizada ou manutenção afetar todas as VMs simultaneamente.'),
  ('77000000-0000-4000-8000-000000000095','Availability Zone, porque o cenário exige obrigatoriamente datacenters separados.','Incorreta. O cenário exclui isolamento entre datacenters e aponta para fault/update domains.'),
  ('77000000-0000-4000-8000-000000000096','Uma única VM com RDP habilitado.','Incorreta. Uma única VM não fornece a distribuição solicitada.'),
  ('77000000-0000-4000-8000-000000000097','Availability Set, porque ele também aumenta automaticamente a quantidade de VMs.','Incorreta. Availability Set não é mecanismo de escala de quantidade.'),
  ('77000000-0000-4000-8000-000000000098','Usar VM Scale Set para escala e configurar explicitamente autoscale, balanceamento e distribuição adequados ao requisito de disponibilidade.','Correta. Scale Set gerencia múltiplas instâncias, mas os demais comportamentos dependem de decisões e configuração.'),
  ('77000000-0000-4000-8000-000000000099','Usar uma única VM grande, pois tamanho elimina qualquer ponto único de falha.','Incorreta. Escala vertical não elimina o ponto único de falha.'),
  ('77000000-0000-4000-8000-000000000100','Considerar Scale Set sinônimo de Availability Set e Availability Zone.','Incorreta. Os três conceitos têm finalidades distintas e podem ser combinados conforme a arquitetura.');

update public.question_options option
set option_text = seed.option_text,
  explanation = seed.explanation
from stage_863_option_update seed
where option.id = seed.id;

create temporary table avd_question_seed (
  id uuid primary key,
  question_text text not null,
  difficulty text not null,
  explanation text not null,
  display_order integer not null
) on commit drop;

insert into avd_question_seed values
  ('68000000-0000-4000-8000-000000000006','O que é Azure Virtual Desktop?','easy','Azure Virtual Desktop é um serviço de virtualização de desktops e aplicações no Azure, voltado a entregar experiências Windows e aplicações remotas para usuários.',1),
  ('68000000-0000-4000-8000-000000000007','Uma organização quer entregar somente uma aplicação corporativa remota, sem mostrar um desktop Windows completo. Qual recurso do AVD atende ao cenário?','easy','RemoteApp permite publicar uma aplicação individual por Azure Virtual Desktop sem apresentar necessariamente toda a experiência de desktop.',2),
  ('68000000-0000-4000-8000-000000000008','Colaboradores usam dispositivos diferentes e precisam acessar um ambiente Windows corporativo centralizado. Qual serviço é mais apropriado?','medium','Azure Virtual Desktop entrega desktops e aplicações remotas centralizados para usuários em dispositivos compatíveis.',3),
  ('68000000-0000-4000-8000-000000000009','Qual afirmação sobre sessões no Azure Virtual Desktop está correta?','medium','AVD pode atender cenários com sessões individuais ou compartilhadas/multi-session, conforme a necessidade e a configuração do ambiente.',4),
  ('68000000-0000-4000-8000-000000000010','Por que Azure Virtual Desktop não é equivalente a simplesmente habilitar RDP em uma Azure VM?','hard','RDP em uma VM fornece acesso remoto àquela máquina. AVD é uma plataforma de virtualização que publica e gerencia desktops e aplicações para usuários; VMs podem compor sua infraestrutura sem definir todo o serviço.',5);

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
    and lesson.slug = 'azure-virtual-desktop'
)
insert into public.questions (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select seed.id, target.certification_id, target.domain_id, target.topic_id,
  target.lesson_id, seed.question_text, 'single_choice', seed.difficulty,
  seed.explanation, true, seed.display_order
from avd_question_seed seed
cross join resolved_lesson target;

create temporary table avd_option_seed (
  id uuid primary key,
  question_id uuid not null,
  option_text text not null,
  is_correct boolean not null,
  explanation text not null,
  display_order integer not null
) on commit drop;

insert into avd_option_seed values
  ('7f100000-0000-4000-8000-000000000021','68000000-0000-4000-8000-000000000006','Um serviço de virtualização de desktops e aplicações executado no Azure.',true,'Correta. AVD entrega experiências de desktop e aplicações remotas para usuários.',1),
  ('7f100000-0000-4000-8000-000000000022','68000000-0000-4000-8000-000000000006','Uma plataforma PaaS exclusiva para hospedar APIs web.',false,'Incorreta. Isso se aproxima de App Service; AVD é voltado a usuários, desktops e aplicações remotas.',2),
  ('7f100000-0000-4000-8000-000000000023','68000000-0000-4000-8000-000000000006','Um serviço VPN que conecta redes locais ao Azure.',false,'Incorreta. VPN oferece conectividade de rede, não virtualização de desktops.',3),
  ('7f100000-0000-4000-8000-000000000024','68000000-0000-4000-8000-000000000006','Um runtime de containers para aplicações sem interface gráfica.',false,'Incorreta. AVD não é uma plataforma de containers.',4),
  ('7f100000-0000-4000-8000-000000000025','68000000-0000-4000-8000-000000000007','RemoteApp.',true,'Correta. RemoteApp publica uma aplicação individual para acesso remoto.',1),
  ('7f100000-0000-4000-8000-000000000026','68000000-0000-4000-8000-000000000007','Availability Set.',false,'Incorreta. Availability Set organiza VMs contra falhas/manutenção.',2),
  ('7f100000-0000-4000-8000-000000000027','68000000-0000-4000-8000-000000000007','Azure Load Balancer.',false,'Incorreta. Load Balancer distribui tráfego e não publica aplicações de desktop.',3),
  ('7f100000-0000-4000-8000-000000000028','68000000-0000-4000-8000-000000000007','Data disk.',false,'Incorreta. Data disk é armazenamento adicional de VM.',4),
  ('7f100000-0000-4000-8000-000000000029','68000000-0000-4000-8000-000000000008','Azure Virtual Desktop.',true,'Correta. AVD centraliza e entrega desktops/aplicações remotas para usuários.',1),
  ('7f100000-0000-4000-8000-000000000030','68000000-0000-4000-8000-000000000008','Azure App Service, porque ele entrega desktops Windows completos.',false,'Incorreta. App Service hospeda aplicações web; não entrega desktops Windows.',2),
  ('7f100000-0000-4000-8000-000000000031','68000000-0000-4000-8000-000000000008','Availability Zone, porque ela fornece uma interface de desktop aos usuários.',false,'Incorreta. Zone oferece isolamento físico, não uma experiência de desktop.',3),
  ('7f100000-0000-4000-8000-000000000032','68000000-0000-4000-8000-000000000008','VM Scale Set, porque escala de VMs equivale à publicação de desktops.',false,'Incorreta. Scale Set gerencia múltiplas VMs, mas não é por si só uma plataforma de desktop virtualization.',4),
  ('7f100000-0000-4000-8000-000000000033','68000000-0000-4000-8000-000000000009','Pode usar sessões individuais ou compartilhadas/multi-session conforme o cenário.',true,'Correta. AVD oferece opções de sessão adequadas a diferentes necessidades.',1),
  ('7f100000-0000-4000-8000-000000000034','68000000-0000-4000-8000-000000000009','Sempre limita uma VM a exatamente um usuário e uma sessão.',false,'Incorreta. AVD também suporta cenários multi-session.',2),
  ('7f100000-0000-4000-8000-000000000035','68000000-0000-4000-8000-000000000009','Exige que todo acesso seja feito exclusivamente por navegador.',false,'Incorreta. Há clientes compatíveis e opção de cliente web; não é browser-only.',3),
  ('7f100000-0000-4000-8000-000000000036','68000000-0000-4000-8000-000000000009','Não permite publicar aplicações individuais.',false,'Incorreta. RemoteApp permite publicar aplicações individuais.',4),
  ('7f100000-0000-4000-8000-000000000037','68000000-0000-4000-8000-000000000010','AVD publica e gerencia desktops e aplicações para usuários; RDP em uma VM acessa diretamente aquela máquina.',true,'Correta. Uma VM pode participar da infraestrutura, mas não representa toda a plataforma AVD.',1),
  ('7f100000-0000-4000-8000-000000000038','68000000-0000-4000-8000-000000000010','Não há diferença: qualquer VM com RDP habilitado é automaticamente um ambiente AVD.',false,'Incorreta. AVD possui componentes de publicação e gerenciamento próprios do serviço.',2),
  ('7f100000-0000-4000-8000-000000000039','68000000-0000-4000-8000-000000000010','AVD é somente o nome comercial do protocolo RDP.',false,'Incorreta. AVD é um serviço de virtualização, não apenas um protocolo.',3),
  ('7f100000-0000-4000-8000-000000000040','68000000-0000-4000-8000-000000000010','AVD é uma VPN usada para abrir a porta RDP na internet.',false,'Incorreta. AVD não é VPN e não se resume a expor RDP.',4);

insert into public.question_options (
  id, question_id, option_text, is_correct, explanation, display_order
)
select id, question_id, option_text, is_correct, explanation, display_order
from avd_option_seed;

do $$
begin
  if (select count(*) from stage_863_block_seed) <> 16
    or (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id = block.lesson_id where lesson.topic_id = '32000000-0000-4000-8000-000000000002' and lesson.slug = 'vm-scale-sets-and-availability-sets' and block.is_published) <> 9
    or (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id = block.lesson_id where lesson.topic_id = '32000000-0000-4000-8000-000000000002' and lesson.slug = 'azure-virtual-desktop' and block.is_published) <> 7 then
    raise exception '8.6.3 Content Block counts are invalid';
  end if;

  if (select count(*) from public.visual_experiences visual join public.lessons lesson on lesson.id = visual.lesson_id where lesson.topic_id = '32000000-0000-4000-8000-000000000002' and lesson.slug in ('vm-scale-sets-and-availability-sets', 'azure-virtual-desktop')) <> 1
    or not exists (
      select 1 from public.visual_experiences
      where id = '76000000-0000-4000-8000-000000000009'
        and type = 'architecture'
        and is_published
        and jsonb_array_length(config -> 'nodes') = 12
        and jsonb_array_length(config -> 'edges') = 10
    ) then
    raise exception '8.6.3 Visual Experience is invalid';
  end if;

  if (select count(*) from stage_863_flashcard_update) <> 7
    or (select count(*) from avd_question_seed) <> 5
    or (select count(*) from avd_option_seed) <> 20
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id = question.lesson_id where lesson.topic_id = '32000000-0000-4000-8000-000000000002' and lesson.slug = 'azure-virtual-desktop' and question.is_published) <> 5 then
    raise exception '8.6.3 Practice counts are invalid';
  end if;

  if exists (
    select 1
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug in ('vm-scale-sets-and-availability-sets', 'azure-virtual-desktop')
      and question.is_published
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
  ) then
    raise exception '8.6.3 Question Options are invalid';
  end if;
end;
$$;

commit;

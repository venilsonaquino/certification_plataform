begin;

do $$
begin
  if (
    select count(*)
    from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe Azure architecture and services'
      and topic.title = 'Compute Services'
      and lesson.slug in ('containers-on-azure', 'azure-functions', 'comparing-compute-options')
  ) <> 3 then
    raise exception '8.6.4 expected exactly three scoped Lessons';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug in ('containers-on-azure', 'azure-functions', 'comparing-compute-options')
  ) then
    raise exception 'A scoped 8.6.4 Lesson already contains Content Blocks';
  end if;
end;
$$;

create temporary table stage_864_block_seed (
  id uuid primary key,
  lesson_slug text not null,
  type text not null,
  title text,
  content text,
  config jsonb,
  display_order integer not null
) on commit drop;

insert into stage_864_block_seed values
  ('7b0c0000-0000-4000-8000-000000000001','containers-on-azure','explanation','O que é um container?',
   $content$Container é uma unidade de software que empacota a aplicação e suas dependências para executá-las de forma consistente entre ambientes. Ele isola processos e arquivos necessários à aplicação, mas não inclui um sistema operacional convidado completo por container.

Containers no mesmo host compartilham o kernel do sistema operacional do host. Por isso, normalmente são mais leves e iniciam mais rapidamente que máquinas virtuais, embora o resultado dependa da imagem, da aplicação e do ambiente.$content$,null,1),
  ('7b0c0000-0000-4000-8000-000000000002','containers-on-azure','important','Container não é uma VM pequena',
   $content$Uma VM virtualiza hardware e executa seu próprio guest OS. Um container compartilha o kernel do host e empacota a aplicação com suas dependências. Essa diferença reduz o overhead típico do container, mas não torna VM e container equivalentes nem elimina requisitos de segurança, rede, armazenamento e operação.$content$,null,2),
  ('7b0c0000-0000-4000-8000-000000000003','containers-on-azure','example','Portabilidade e consistência',
   $content$Uma equipe cria uma imagem de container para a aplicação e usa a mesma imagem validada em teste e produção. Isso reduz diferenças de runtime e bibliotecas entre ambientes. Portabilidade não significa que qualquer container executará em qualquer host: arquitetura, sistema operacional, configuração e serviços externos continuam relevantes.$content$,null,3),
  ('7b0c0000-0000-4000-8000-000000000004','containers-on-azure','dotnet_example','API ASP.NET Core empacotada',
   $content$Uma API ASP.NET Core pode ser empacotada em uma imagem Docker com o runtime e as bibliotecas necessários. A equipe promove a mesma imagem entre ambientes, em vez de reinstalar manualmente todas as dependências em cada servidor. O objetivo aqui é consistência de execução, não aprender Dockerfile.$content$,null,4),
  ('7b0c0000-0000-4000-8000-000000000005','containers-on-azure','explanation','ACI e AKS em nível Fundamentals',
   $content$Azure Container Instances (ACI) executa containers no Azure sem exigir que o usuário gerencie diretamente VMs. É uma opção simples para workloads containerizados isolados ou sob demanda.

Azure Kubernetes Service (AKS) é um serviço gerenciado de Kubernetes para orquestrar aplicações containerizadas. Ele é apropriado quando a solução precisa coordenar, gerenciar e escalar múltiplos containers. Em AZ-900, reconheça a finalidade; detalhes internos de Kubernetes ficam fora deste objetivo.$content$,null,5),
  ('7b0c0000-0000-4000-8000-000000000006','containers-on-azure','exam_tip','Escolha pelo requisito dominante',
   $content$Se o cenário pede executar um container simples ou isolado sem gerenciar VMs, ACI tende a ser a opção mais direta. Se pede orquestração e escala de uma aplicação com múltiplos containers, considere AKS. Se exige controle do sistema operacional, avalie VM.$content$,null,6),
  ('7b0c0000-0000-4000-8000-000000000007','containers-on-azure','exam_trap','Leve não significa sem infraestrutura',
   $content$Container não é uma VM pequena e não possui guest OS completo por container. Ele ainda precisa de um host e compartilha seu kernel. ACI também não é sinônimo de AKS: ambos executam workloads containerizados, mas AKS adiciona orquestração para cenários mais complexos.$content$,null,7),
  ('7b0c0000-0000-4000-8000-000000000008','containers-on-azure','summary','Resumo para memória ativa',null,
   '{"items":["Container empacota aplicação e dependências.","Containers compartilham o kernel do host em vez de usar um guest OS completo por container.","Normalmente iniciam mais rapidamente que VMs.","Imagens favorecem portabilidade e consistência entre ambientes.","ACI atende containers simples ou isolados sem gerenciamento direto de VMs.","AKS orquestra e escala aplicações com múltiplos containers."]}'::jsonb,8),

  ('7b0c0000-0000-4000-8000-000000000009','azure-functions','explanation','Azure Functions: código orientado a eventos',
   $content$Azure Functions é uma solução serverless para executar código em resposta a eventos. A equipe se concentra na função e no evento que inicia sua execução, enquanto o serviço abstrai o provisionamento e o gerenciamento da infraestrutura de servidor.

É comum usar Functions para unidades de trabalho acionadas sob demanda. O comportamento de escala, disponibilidade e cobrança depende do plano e da configuração; serverless descreve a abstração operacional, não uma garantia única de preço ou desempenho.$content$,null,1),
  ('7b0c0000-0000-4000-8000-000000000010','azure-functions','important','Triggers iniciam a execução',
   $content$Trigger é o evento que inicia uma Function. Exemplos conceituais incluem uma requisição HTTP, uma mensagem em fila, um horário definido por timer ou um evento de storage. Cada Function possui um trigger, e o código executa quando o evento correspondente ocorre.$content$,null,2),
  ('7b0c0000-0000-4000-8000-000000000011','azure-functions','example','Quatro cenários simples',
   $content$HTTP: responder a uma chamada de API ocasional.

Fila: processar uma mensagem quando ela chega.

Timer: executar uma rotina em horário programado.

Storage: reagir quando um arquivo é adicionado. Esses exemplos demonstram orientação a eventos; não exigem conhecer configuração detalhada de bindings.$content$,null,3),
  ('7b0c0000-0000-4000-8000-000000000012','azure-functions','dotnet_example','C# acionado por evento',
   $content$Uma função C# pode validar uma mensagem recebida em uma fila e registrar o resultado, ou responder a uma requisição HTTP. A escolha por Functions vem do modelo orientado a eventos e da infraestrutura abstraída, não da linguagem .NET isoladamente.$content$,null,4),
  ('7b0c0000-0000-4000-8000-000000000013','azure-functions','important','Escala e custo dependem do plano',
   $content$O serviço pode gerenciar a escala conforme a demanda, o plano de hospedagem e a configuração. Alguns modelos relacionam cobrança à execução; outros reservam capacidade. Por isso, evite afirmar que toda Function escala da mesma forma ou que sempre se paga apenas quando o código executa.$content$,null,5),
  ('7b0c0000-0000-4000-8000-000000000014','azure-functions','exam_trap','Serverless não significa ausência de servidores',
   $content$Servidores continuam existindo. Em serverless, a infraestrutura de servidor é abstraída do usuário e administrada pelo provider. A equipe ainda é responsável pelo código, pelos dados, pelas identidades, pelas permissões e pela configuração que estão sob seu controle.$content$,null,6),
  ('7b0c0000-0000-4000-8000-000000000015','azure-functions','exam_tip','Procure evento e unidade de código',
   $content$Quando a questão descreve executar uma unidade de código após HTTP, fila, timer ou evento de storage, Azure Functions é uma candidata forte. Uma carga contínua ou que exige controle do sistema operacional pede comparação com outras opções de compute.$content$,null,7),
  ('7b0c0000-0000-4000-8000-000000000016','azure-functions','summary','Resumo para memória ativa',null,
   '{"items":["Azure Functions executa código em resposta a eventos.","Serverless abstrai a infraestrutura; não elimina servidores.","Triggers incluem HTTP, fila, timer e eventos de storage.","A equipe foca no código e na configuração sob sua responsabilidade.","Escala e cobrança dependem do plano e da configuração."]}'::jsonb,8),

  ('7b0c0000-0000-4000-8000-000000000017','comparing-compute-options','explanation','Três modelos de compute',
   $content$Virtual Machines, containers e Azure Functions atendem necessidades diferentes. VM oferece mais controle do sistema operacional e maior responsabilidade operacional. Container empacota aplicação e dependências sem guest OS completo por container. Function executa unidades de código orientadas a eventos com infraestrutura abstraída.$content$,null,1),
  ('7b0c0000-0000-4000-8000-000000000018','comparing-compute-options','important','Matriz de comparação: VM | Container | Function',
   $content$Controle do SO — VM: alto | Container: menor, concentrado no host/imagem | Function: muito baixo, infraestrutura abstraída.

Guest OS próprio — VM: sim | Container: não por container | Function: abstraído pelo serviço.

Portabilidade — VM: média | Container: alta por imagem e dependências | Function: focada no código e runtime suportado.

Event-driven — VM: não necessariamente | Container: não necessariamente | Function: característica forte.

Gestão de infraestrutura — VM: maior | Container: intermediária e dependente da plataforma | Function: menor.

Startup típico — VM: geralmente mais lento | Container: geralmente mais rápido | Function: gerenciado pelo serviço e variável conforme plano/configuração. São tendências, não garantias absolutas.$content$,null,2),
  ('7b0c0000-0000-4000-8000-000000000019','comparing-compute-options','example','Três requisitos, três escolhas prováveis',
   $content$“Preciso controlar o sistema operacional e instalar software específico” → VM.

“Preciso empacotar a aplicação para execução consistente e portátil” → Container.

“Preciso executar código quando uma mensagem chega ou uma chamada HTTP ocorre” → Function.

Essas escolhas são tendências baseadas no requisito dominante; uma arquitetura real pode combinar opções.$content$,null,3),
  ('7b0c0000-0000-4000-8000-000000000020','comparing-compute-options','dotnet_example','VM: controle do ambiente .NET',
   $content$Uma API ASP.NET Core depende de um componente instalado diretamente no Windows e de configuração específica do sistema operacional. Uma VM oferece o controle necessário, junto com a responsabilidade por patches, runtime e operação do guest OS.$content$,null,4),
  ('7b0c0000-0000-4000-8000-000000000021','comparing-compute-options','dotnet_example','Container: aplicação .NET portátil',
   $content$Uma API ASP.NET Core é empacotada em uma imagem Docker com suas dependências para executar de maneira consistente em teste e produção. Container é a escolha arquitetural principal; a plataforma que executará a imagem é uma decisão adicional.$content$,null,5),
  ('7b0c0000-0000-4000-8000-000000000022','comparing-compute-options','dotnet_example','Function: C# acionado por evento',
   $content$Uma rotina C# precisa executar quando uma mensagem chega em uma fila. Azure Functions combina o trigger com a unidade de código e abstrai a infraestrutura de servidor, sem exigir que a equipe mantenha uma VM dedicada apenas para aguardar o evento.$content$,null,6),
  ('7b0c0000-0000-4000-8000-000000000023','comparing-compute-options','exam_trap','Não escolha somente por uma palavra',
   $content$Container não é uma VM pequena, Function não significa ausência de servidores e VM não é sempre a opção “mais poderosa”. Controle, portabilidade, modelo de execução e responsabilidade operacional devem ser avaliados juntos. “Mais rápido” e “mais barato” dependem da carga e da configuração.$content$,null,7),
  ('7b0c0000-0000-4000-8000-000000000024','comparing-compute-options','exam_tip','Comece pelo requisito dominante',
   $content$Controle do guest OS aponta para VM. Empacotamento portátil aponta para container. Execução de código orientada a eventos aponta para Function. Depois verifique restrições de operação, escala e custo antes de concluir.$content$,null,8),
  ('7b0c0000-0000-4000-8000-000000000025','comparing-compute-options','summary','Resumo para memória ativa',null,
   '{"items":["VM oferece maior controle do sistema operacional e maior responsabilidade operacional.","Container empacota aplicação e dependências e compartilha o kernel do host.","Function executa código orientado a eventos com infraestrutura abstraída.","VM, container e Function podem coexistir na mesma arquitetura.","A escolha depende do requisito dominante, não de uma regra absoluta."]}'::jsonb,9);

insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, display_order, is_published
)
select seed.id, lesson.id, seed.type, seed.title, seed.content, seed.config,
  seed.display_order, true
from stage_864_block_seed seed
join public.lessons lesson
  on lesson.topic_id = '32000000-0000-4000-8000-000000000002'
 and lesson.slug = seed.lesson_slug;

create temporary table stage_864_flashcard_update (
  id uuid primary key, front_text text not null, back_text text not null, hint text
) on commit drop;

insert into stage_864_flashcard_update values
  ('71000000-0000-4000-8000-000000000101','Quando uma VM tende a ser mais adequada que um container ou uma Function?','Quando o requisito exige maior controle do sistema operacional, do runtime ou do software instalado. Esse controle traz maior responsabilidade operacional.','Controle do guest OS.'),
  ('71000000-0000-4000-8000-000000000102','Quando Azure Functions tende a ser uma boa opção de compute?','Quando uma unidade de código deve executar em resposta a um evento, com infraestrutura de servidor abstraída. Escala e cobrança dependem do plano e da configuração.','Código orientado a eventos.'),
  ('71000000-0000-4000-8000-000000000103','Por que containers normalmente iniciam mais rapidamente que VMs?','Porque compartilham o kernel do host e não inicializam um guest OS completo por container.','Kernel compartilhado.'),
  ('71000000-0000-4000-8000-000000000104','Qual opção favorece empacotar aplicação e dependências para execução consistente?','Container. A imagem reúne a aplicação e suas dependências, favorecendo portabilidade e consistência entre ambientes compatíveis.','Aplicação + dependências.'),
  ('72000000-0000-4000-8000-000000000011','O que é Azure Functions?','É uma solução serverless que executa código em resposta a eventos, com a infraestrutura de servidor abstraída do usuário.','Serverless e event-driven.'),
  ('72000000-0000-4000-8000-000000000012','O que é um trigger em Azure Functions?','É o evento que inicia a execução, como HTTP, mensagem em fila, timer ou evento de storage.','Evento de início.'),
  ('72000000-0000-4000-8000-000000000013','Toda Azure Function cobra e escala da mesma forma?','Não. Cobrança e escala dependem do plano de hospedagem, da configuração e do padrão de uso.','Evite absolutos sobre planos.'),
  ('72000000-0000-4000-8000-000000000014','O que diferencia um container de uma VM?','Container compartilha o kernel do host e não executa um guest OS completo por container; VM executa seu próprio guest OS.','Container não é VM pequena.'),
  ('72000000-0000-4000-8000-000000000015','Quando Azure Container Instances (ACI) é uma opção conceitual adequada?','Para executar containers simples ou isolados no Azure sem gerenciar diretamente VMs ou um orquestrador.','Execução simples de container.'),
  ('72000000-0000-4000-8000-000000000016','Qual é a finalidade do Azure Kubernetes Service (AKS)?','Orquestrar, gerenciar e escalar aplicações com múltiplos containers usando Kubernetes gerenciado.','Orquestração.'),
  ('72000000-0000-4000-8000-000000000017','Qual é a diferença principal entre ACI e AKS?','ACI é mais direto para containers simples ou isolados; AKS atende orquestração e escala de aplicações com múltiplos containers.','Execução simples versus orquestração.');

update public.flashcards card
set front_text = seed.front_text, back_text = seed.back_text, hint = seed.hint
from stage_864_flashcard_update seed
where card.id = seed.id;

create temporary table stage_864_question_update (
  id uuid primary key, question_text text not null, difficulty text not null, explanation text not null
) on commit drop;

insert into stage_864_question_update values
  ('65000000-0000-4000-8000-000000000011','Qual descrição diferencia corretamente um container de uma máquina virtual?','easy','Container empacota aplicação e dependências e compartilha o kernel do host. A VM executa um guest OS completo e oferece maior controle desse sistema operacional.'),
  ('65000000-0000-4000-8000-000000000012','Ao comparar VM, container e Azure Functions, qual critério é mais útil para iniciar a escolha?','easy','O requisito dominante — como controle do SO, portabilidade do pacote ou execução orientada a eventos — ajuda a comparar controle e responsabilidade operacional.'),
  ('65000000-0000-4000-8000-000000000013','Uma rotina C# deve executar somente quando uma mensagem chega em uma fila, sem que a equipe gerencie a infraestrutura de servidor. Qual opção é a mais alinhada?','medium','Azure Functions é orientado a eventos e pode usar uma mensagem em fila como trigger, mantendo a infraestrutura de servidor abstraída.'),
  ('65000000-0000-4000-8000-000000000014','Uma aplicação legada exige software instalado diretamente no sistema operacional e configurações específicas do Windows. Qual opção tende a ser mais adequada?','medium','Azure Virtual Machines oferece controle do guest OS e do software instalado, com a correspondente responsabilidade operacional.'),
  ('65000000-0000-4000-8000-000000000015','Uma solução tem três componentes: um sistema legado que exige controle do SO, uma API empacotada para execução consistente entre ambientes e uma rotina acionada por fila. Qual combinação é mais coerente?','hard','VM atende ao controle do SO; container empacota a API e suas dependências; Azure Functions executa a rotina quando o evento de fila ocorre.'),
  ('63000000-0000-4000-8000-000000000111','O que caracteriza Azure Functions?','easy','Azure Functions é uma solução serverless orientada a eventos: executa unidades de código com a infraestrutura de servidor abstraída do usuário.'),
  ('63000000-0000-4000-8000-000000000112','O que significa serverless no contexto de Azure Functions?','easy','Serverless significa que a infraestrutura de servidor é abstraída e administrada pelo provider; servidores continuam existindo.'),
  ('63000000-0000-4000-8000-000000000113','Qual opção contém somente exemplos conceituais de triggers do Azure Functions?','easy','Requisições HTTP, mensagens em fila, timers e eventos de storage podem iniciar a execução de uma Function.'),
  ('63000000-0000-4000-8000-000000000114','Uma imagem deve ser processada quando um novo arquivo chega ao storage. Qual abordagem está mais alinhada ao Azure Functions?','medium','Uma Function acionada por evento de storage executa o processamento quando o arquivo chega, seguindo o modelo event-driven.'),
  ('63000000-0000-4000-8000-000000000115','Uma equipe quer responder a requisições HTTP ocasionais executando uma unidade de código sem administrar uma VM. Qual opção é adequada?','medium','Uma Azure Function com trigger HTTP pode executar o código em resposta à requisição, com a infraestrutura de servidor abstraída.'),
  ('63000000-0000-4000-8000-000000000116','Um processo deve começar quando uma mensagem chega a uma fila. Qual trigger representa diretamente esse evento?','medium','Um trigger de fila inicia a Function quando uma mensagem chega, permitindo processamento orientado ao evento.'),
  ('63000000-0000-4000-8000-000000000117','Uma rotina deve executar diariamente em horário definido. Qual trigger é mais diretamente relacionado?','medium','Um timer trigger inicia a Function conforme uma programação; não exige que outro sistema envie uma requisição manual.'),
  ('63000000-0000-4000-8000-000000000118','Qual afirmação descreve corretamente escalabilidade e cobrança no Azure Functions?','medium','Escala e cobrança variam conforme plano, configuração e uso. Alguns modelos acompanham execuções, enquanto outros reservam capacidade.'),
  ('63000000-0000-4000-8000-000000000119','Uma carga usa compute continuamente, 24 horas por dia, com demanda estável e exige controle do ambiente. Qual análise é mais correta?','hard','Functions não deve ser escolhido automaticamente só por ser serverless. Para uso contínuo e controle do ambiente, compare custo, operação e requisitos com containers ou VMs.'),
  ('63000000-0000-4000-8000-000000000120','Uma API ASP.NET Core exige componente instalado no Windows, enquanto uma rotina C# deve reagir a mensagens de fila. Qual decisão usa corretamente as opções de compute?','hard','A API pode exigir VM pelo controle do SO; a rotina orientada a eventos pode usar Azure Functions. Uma arquitetura pode combinar modelos conforme cada requisito.');

update public.questions question
set question_text = seed.question_text, difficulty = seed.difficulty, explanation = seed.explanation
from stage_864_question_update seed
where question.id = seed.id;

create temporary table stage_864_option_update (
  id uuid primary key, option_text text not null, explanation text not null
) on commit drop;

insert into stage_864_option_update values
  ('77000000-0000-4000-8000-000000000041','Container compartilha o kernel do host; VM executa um guest OS completo.','Correta. Essa é a diferença estrutural central entre os dois modelos.'),
  ('77000000-0000-4000-8000-000000000042','Container e VM sempre executam um guest OS completo por workload.','Incorreta. O container compartilha o kernel do host.'),
  ('77000000-0000-4000-8000-000000000043','VM compartilha o kernel do host, mas container virtualiza hardware.','Incorreta. A descrição inverte os modelos.'),
  ('77000000-0000-4000-8000-000000000044','Container elimina a necessidade de host e de sistema operacional.','Incorreta. Containers ainda dependem de host e kernel.'),
  ('77000000-0000-4000-8000-000000000045','O requisito dominante de controle, portabilidade ou evento e a responsabilidade operacional aceitável.','Correta. Esses fatores diferenciam diretamente as opções.'),
  ('77000000-0000-4000-8000-000000000046','Somente a linguagem de programação usada pela equipe.','Incorreta. A linguagem isolada não determina o modelo de compute.'),
  ('77000000-0000-4000-8000-000000000047','Somente o número atual de usuários da aplicação.','Incorreta. Demanda importa, mas não substitui requisitos de controle e execução.'),
  ('77000000-0000-4000-8000-000000000048','Somente se a carga será executada na mesma Region do banco.','Incorreta. Localização é relevante, mas não diferencia sozinha os três modelos.'),
  ('77000000-0000-4000-8000-000000000049','Uma VM dedicada aguardando continuamente a fila.','Incorreta. Pode funcionar, mas adiciona gerenciamento não pedido.'),
  ('77000000-0000-4000-8000-000000000050','Azure Functions com trigger de fila.','Correta. O evento de fila inicia a unidade de código.'),
  ('77000000-0000-4000-8000-000000000051','Um container sem mecanismo que consuma mensagens.','Incorreta. O container isolado não reage à fila sem aplicação e integração.'),
  ('77000000-0000-4000-8000-000000000052','Uma Availability Zone sem recurso de compute.','Incorreta. Zone é isolamento físico, não execução de código.'),
  ('77000000-0000-4000-8000-000000000053','Azure Functions, porque permite instalar qualquer componente no Windows subjacente.','Incorreta. Functions abstrai o sistema operacional.'),
  ('77000000-0000-4000-8000-000000000054','Um container, porque sempre oferece controle total do kernel do host.','Incorreta. Container não oferece automaticamente esse controle.'),
  ('77000000-0000-4000-8000-000000000055','Azure Virtual Machines, pelo controle do guest OS e do software instalado.','Correta. VM atende ao requisito explícito de controle.'),
  ('77000000-0000-4000-8000-000000000056','Azure Functions com timer, porque instalação no SO não afeta a escolha.','Incorreta. O requisito de software instalado no SO é determinante.'),
  ('77000000-0000-4000-8000-000000000057','Functions para o legado, VM para a API portátil e container para o evento.','Incorreta. A combinação não segue os requisitos dominantes.'),
  ('77000000-0000-4000-8000-000000000058','VM para o legado, container para a API e Functions para a rotina de fila.','Correta. Cada componente usa a opção alinhada ao requisito.'),
  ('77000000-0000-4000-8000-000000000059','Container para o legado, Functions para a API e VM aguardando a fila.','Incorreta. Inverte controle do SO e orientação a eventos.'),
  ('77000000-0000-4000-8000-000000000060','Uma única VM para os três componentes é sempre obrigatória.','Incorreta. Opções podem ser combinadas conforme cada requisito.'),

  ('74000000-0000-4000-8000-000000000441','Serviço serverless que executa código em resposta a eventos.','Correta. Functions combina código, triggers e infraestrutura abstraída.'),
  ('74000000-0000-4000-8000-000000000442','Serviço para controlar diretamente o guest OS de uma VM.','Incorreta. Isso descreve uma necessidade atendida por VM.'),
  ('74000000-0000-4000-8000-000000000443','Plataforma de virtualização de desktops para usuários finais.','Incorreta. Isso se aproxima de Azure Virtual Desktop.'),
  ('74000000-0000-4000-8000-000000000444','Orquestrador gerenciado de múltiplos containers Kubernetes.','Incorreta. Isso descreve AKS.'),
  ('74000000-0000-4000-8000-000000000445','Não existem servidores físicos ou virtuais envolvidos.','Incorreta. Servidores existem, mas são abstraídos.'),
  ('74000000-0000-4000-8000-000000000446','O cliente deve instalar e corrigir o sistema operacional de cada execução.','Incorreta. A infraestrutura é administrada pelo provider.'),
  ('74000000-0000-4000-8000-000000000447','Todo código serverless é executado gratuitamente.','Incorreta. Serverless não significa custo zero.'),
  ('74000000-0000-4000-8000-000000000448','A infraestrutura de servidor é abstraída do usuário e administrada pelo provider.','Correta. Essa é a ideia central de serverless.'),
  ('74000000-0000-4000-8000-000000000449','HTTP, fila, timer e evento de storage.','Correta. Todos são exemplos de triggers.'),
  ('74000000-0000-4000-8000-000000000450','VM size, OS disk, NIC e Public IP.','Incorreta. São recursos relacionados a VMs.'),
  ('74000000-0000-4000-8000-000000000451','Subscription, Management Group, Region e Zone.','Incorreta. São conceitos de organização e arquitetura.'),
  ('74000000-0000-4000-8000-000000000452','ACI, AKS, VNet e subnet.','Incorreta. Não são um conjunto de triggers.'),
  ('74000000-0000-4000-8000-000000000453','Uma VM que verifica o storage apenas uma vez por semana.','Incorreta. Não reage diretamente ao evento descrito.'),
  ('74000000-0000-4000-8000-000000000454','Uma Function com trigger de storage.','Correta. O evento de arquivo inicia o processamento.'),
  ('74000000-0000-4000-8000-000000000455','Um Availability Set para o arquivo.','Incorreta. Availability Set organiza VMs.'),
  ('74000000-0000-4000-8000-000000000456','Uma Function apenas com timer anual.','Incorreta. Timer anual não corresponde à chegada do arquivo.'),
  ('74000000-0000-4000-8000-000000000457','Um AKS sem aplicação HTTP implantada.','Incorreta. Orquestração isolada não implementa o endpoint.'),
  ('74000000-0000-4000-8000-000000000458','Uma VM obrigatoriamente dedicada para cada requisição.','Incorreta. Isso adiciona infraestrutura desnecessária ao requisito.'),
  ('74000000-0000-4000-8000-000000000459','Uma Azure Function com trigger HTTP.','Correta. O trigger inicia o código quando a requisição chega.'),
  ('74000000-0000-4000-8000-000000000460','Um Resource Group usado como endpoint.','Incorreta. Resource Group organiza recursos; não responde HTTP.'),
  ('74000000-0000-4000-8000-000000000461','Trigger HTTP.','Incorreta. O evento descrito é uma mensagem em fila.'),
  ('74000000-0000-4000-8000-000000000462','Trigger de timer.','Incorreta. Timer é orientado a programação.'),
  ('74000000-0000-4000-8000-000000000463','Trigger de storage.','Incorreta. O enunciado especifica uma fila.'),
  ('74000000-0000-4000-8000-000000000464','Trigger de fila.','Correta. A chegada da mensagem inicia a execução.'),
  ('74000000-0000-4000-8000-000000000465','Timer trigger.','Correta. O timer representa uma programação.'),
  ('74000000-0000-4000-8000-000000000466','Trigger de fila sem qualquer mensagem.','Incorreta. Não representa diretamente horário definido.'),
  ('74000000-0000-4000-8000-000000000467','Trigger HTTP que depende de chamada manual diária.','Incorreta. Pode ser chamado, mas não modela diretamente a programação.'),
  ('74000000-0000-4000-8000-000000000468','Trigger de storage sem evento de arquivo.','Incorreta. Não corresponde à execução agendada.'),
  ('74000000-0000-4000-8000-000000000469','Toda Function cobra apenas por execução e sempre escala até qualquer volume.','Incorreta. Planos, limites e configuração variam.'),
  ('74000000-0000-4000-8000-000000000470','Escala e cobrança dependem do plano, da configuração e do padrão de uso.','Correta. Evita absolutos e reconhece modelos diferentes.'),
  ('74000000-0000-4000-8000-000000000471','Azure Functions nunca pode ajustar capacidade conforme demanda.','Incorreta. O serviço oferece escala gerenciada conforme modelo e configuração.'),
  ('74000000-0000-4000-8000-000000000472','O usuário sempre gerencia servidores físicos para obter escala.','Incorreta. A infraestrutura permanece abstraída.'),
  ('74000000-0000-4000-8000-000000000473','Functions é sempre a opção mais barata por ser serverless.','Incorreta. Custo depende do uso, plano e requisitos.'),
  ('74000000-0000-4000-8000-000000000474','A carga deve obrigatoriamente ser dividida em várias Functions.','Incorreta. Decomposição não é consequência automática.'),
  ('74000000-0000-4000-8000-000000000475','Comparar Functions, containers e VMs segundo uso contínuo, controle, custo e operação.','Correta. A decisão depende do perfil e dos requisitos.'),
  ('74000000-0000-4000-8000-000000000476','Escolher Functions sem analisar demanda porque serverless elimina qualquer limite.','Incorreta. Serverless não elimina limites nem análise.'),
  ('74000000-0000-4000-8000-000000000477','Executar toda a solução em Functions porque C# exige serverless.','Incorreta. A linguagem não obriga um modelo de compute.'),
  ('74000000-0000-4000-8000-000000000478','Executar ambos em container porque eventos só funcionam em containers.','Incorreta. Functions é orientado a eventos.'),
  ('74000000-0000-4000-8000-000000000479','Executar ambos em VM porque Functions não recebe mensagens de fila.','Incorreta. Fila é um trigger conceitual de Functions.'),
  ('74000000-0000-4000-8000-000000000480','Usar VM para a API que exige controle do Windows e Function para a rotina de fila.','Correta. Cada componente recebe a opção coerente com seu requisito.');

update public.question_options option
set option_text = seed.option_text, explanation = seed.explanation
from stage_864_option_update seed
where option.id = seed.id;

create temporary table stage_864_container_question_seed (
  id uuid primary key, question_text text not null, difficulty text not null,
  explanation text not null, display_order integer not null
) on commit drop;

insert into stage_864_container_question_seed values
  ('68000000-0000-4000-8000-000000000011','O que um container empacota para favorecer execução consistente?','easy','Um container empacota a aplicação e suas dependências. Ele não inclui um guest OS completo por container.',1),
  ('68000000-0000-4000-8000-000000000012','Qual afirmação compara corretamente container e VM?','easy','Containers compartilham o kernel do host; VMs executam seu próprio guest OS. Por isso containers normalmente têm menor overhead e startup mais rápido.',2),
  ('68000000-0000-4000-8000-000000000013','Uma equipe precisa executar um container isolado no Azure sem gerenciar diretamente VMs ou Kubernetes. Qual opção é mais direta?','medium','ACI executa containers no Azure sem gerenciamento direto de VMs e é adequado a workloads simples ou isolados.',3),
  ('68000000-0000-4000-8000-000000000014','Uma aplicação exige orquestração e escala de múltiplos containers. Qual serviço é mais alinhado?','medium','AKS é o serviço gerenciado de Kubernetes indicado para orquestrar, gerenciar e escalar aplicações com múltiplos containers.',4),
  ('68000000-0000-4000-8000-000000000015','Uma API ASP.NET Core deve usar o mesmo pacote validado em teste e produção, incluindo runtime e bibliotecas. O controle do guest OS não é requisito. Qual escolha atende melhor?','hard','Uma imagem de container empacota a API e suas dependências, favorecendo portabilidade e consistência entre ambientes compatíveis.',5);

insert into public.questions (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select seed.id, certification.id, domain.id, topic.id, lesson.id,
  seed.question_text, 'single_choice', seed.difficulty, seed.explanation, true,
  seed.display_order
from stage_864_container_question_seed seed
join public.certifications certification on certification.code = 'az-900'
join public.domains domain on domain.certification_id = certification.id
  and domain.title = 'Describe Azure architecture and services'
join public.topics topic on topic.domain_id = domain.id and topic.title = 'Compute Services'
join public.lessons lesson on lesson.topic_id = topic.id and lesson.slug = 'containers-on-azure';

create temporary table stage_864_container_option_seed (
  id uuid primary key, question_id uuid not null, option_text text not null,
  is_correct boolean not null, explanation text not null, display_order integer not null
) on commit drop;

insert into stage_864_container_option_seed values
  ('7f100000-0000-4000-8000-000000000041','68000000-0000-4000-8000-000000000011','A aplicação e suas dependências.',true,'Correta. Esse pacote favorece consistência entre ambientes.',1),
  ('7f100000-0000-4000-8000-000000000042','68000000-0000-4000-8000-000000000011','Um datacenter físico e sua energia.',false,'Incorreta. Container é uma unidade de software.',2),
  ('7f100000-0000-4000-8000-000000000043','68000000-0000-4000-8000-000000000011','Uma Subscription e todos os seus recursos.',false,'Incorreta. Subscription é um limite de organização e cobrança.',3),
  ('7f100000-0000-4000-8000-000000000044','68000000-0000-4000-8000-000000000011','Um guest OS completo obrigatório por aplicação.',false,'Incorreta. Container compartilha o kernel do host.',4),
  ('7f100000-0000-4000-8000-000000000045','68000000-0000-4000-8000-000000000012','Container compartilha o kernel do host; VM executa um guest OS completo.',true,'Correta. Essa diferença explica o menor overhead típico do container.',1),
  ('7f100000-0000-4000-8000-000000000046','68000000-0000-4000-8000-000000000012','Container e VM são idênticos, mudando somente o nome.',false,'Incorreta. Eles possuem modelos de isolamento distintos.',2),
  ('7f100000-0000-4000-8000-000000000047','68000000-0000-4000-8000-000000000012','VM compartilha o kernel, mas container sempre virtualiza hardware.',false,'Incorreta. A afirmação inverte os modelos.',3),
  ('7f100000-0000-4000-8000-000000000048','68000000-0000-4000-8000-000000000012','Container nunca depende de um sistema operacional host.',false,'Incorreta. Container depende do host e de seu kernel.',4),
  ('7f100000-0000-4000-8000-000000000049','68000000-0000-4000-8000-000000000013','Azure Container Instances (ACI).',true,'Correta. ACI é direto para containers simples ou isolados.',1),
  ('7f100000-0000-4000-8000-000000000050','68000000-0000-4000-8000-000000000013','Azure Kubernetes Service (AKS), obrigatoriamente.',false,'Incorreta. AKS adiciona orquestração não exigida pelo cenário.',2),
  ('7f100000-0000-4000-8000-000000000051','68000000-0000-4000-8000-000000000013','Azure Virtual Desktop.',false,'Incorreta. AVD entrega desktops e aplicações remotas.',3),
  ('7f100000-0000-4000-8000-000000000052','68000000-0000-4000-8000-000000000013','Availability Set.',false,'Incorreta. Availability Set organiza VMs contra falhas/manutenção.',4),
  ('7f100000-0000-4000-8000-000000000053','68000000-0000-4000-8000-000000000014','Azure Virtual Machines sem orquestrador.',false,'Incorreta. Não atende diretamente à orquestração pedida.',1),
  ('7f100000-0000-4000-8000-000000000054','68000000-0000-4000-8000-000000000014','Azure Container Instances para cada container, sem coordenação.',false,'Incorreta. O cenário pede orquestração integrada.',2),
  ('7f100000-0000-4000-8000-000000000055','68000000-0000-4000-8000-000000000014','Azure Kubernetes Service (AKS).',true,'Correta. AKS oferece Kubernetes gerenciado para orquestração.',3),
  ('7f100000-0000-4000-8000-000000000056','68000000-0000-4000-8000-000000000014','Azure Functions com timer.',false,'Incorreta. Function executa código orientado a eventos, não orquestra containers.',4),
  ('7f100000-0000-4000-8000-000000000057','68000000-0000-4000-8000-000000000015','Uma VM recriada manualmente com instalações diferentes em cada ambiente.',false,'Incorreta. Isso aumenta variação entre ambientes.',1),
  ('7f100000-0000-4000-8000-000000000058','68000000-0000-4000-8000-000000000015','Uma imagem de container com a API e suas dependências.',true,'Correta. A mesma imagem favorece portabilidade e consistência.',2),
  ('7f100000-0000-4000-8000-000000000059','68000000-0000-4000-8000-000000000015','Uma Azure Function apenas porque o código usa C#.',false,'Incorreta. A linguagem não determina o modelo de compute.',3),
  ('7f100000-0000-4000-8000-000000000060','68000000-0000-4000-8000-000000000015','Um Availability Set para empacotar bibliotecas.',false,'Incorreta. Availability Set não empacota aplicações.',4);

insert into public.question_options (
  id, question_id, option_text, is_correct, explanation, display_order
)
select id, question_id, option_text, is_correct, explanation, display_order
from stage_864_container_option_seed;

do $$
begin
  if (select count(*) from stage_864_block_seed) <> 25
    or (select count(*) from stage_864_flashcard_update) <> 11
    or (select count(*) from stage_864_question_update) <> 15
    or (select count(*) from stage_864_option_update) <> 60
    or (select count(*) from stage_864_container_question_seed) <> 5
    or (select count(*) from stage_864_container_option_seed) <> 20 then
    raise exception '8.6.4 staged row counts are invalid';
  end if;

  if exists (
    select 1
    from public.visual_experiences visual
    join public.lessons lesson on lesson.id = visual.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug in ('containers-on-azure', 'azure-functions', 'comparing-compute-options')
  ) then
    raise exception '8.6.4 must not create a Visual Experience';
  end if;

  if exists (
    select 1
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug in ('containers-on-azure', 'azure-functions', 'comparing-compute-options')
      and question.is_published
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
  ) then
    raise exception '8.6.4 Question Options are invalid';
  end if;
end;
$$;

commit;

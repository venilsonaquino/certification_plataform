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
      and lesson.slug in ('azure-app-service', 'choosing-application-hosting')
  ) <> 2 then
    raise exception '8.6.5 expected exactly two scoped Lessons';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug in ('azure-app-service', 'choosing-application-hosting')
  ) then
    raise exception 'A scoped 8.6.5 Lesson already contains Content Blocks';
  end if;

  if (select count(*) from public.questions where id = '60000000-0000-4000-8000-000000000008') <> 1
    or (select count(*) from public.question_options where question_id = '60000000-0000-4000-8000-000000000008') <> 4 then
    raise exception 'The historical Azure App Service Question is missing';
  end if;

  if exists (
    select 1
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug = 'choosing-application-hosting'
  ) then
    raise exception 'Choosing Application Hosting already has Questions';
  end if;
end;
$$;

create temporary table stage_865_block_seed (
  id uuid primary key,
  lesson_slug text not null,
  type text not null,
  title text,
  content text,
  config jsonb,
  display_order integer not null
) on commit drop;

insert into stage_865_block_seed values
  ('7b0d0000-0000-4000-8000-000000000001','azure-app-service','explanation','Azure App Service e Web Apps',
   $content$Azure App Service é uma plataforma gerenciada para hospedar aplicações web e APIs. Azure Web Apps é a capacidade do App Service usada para publicar essas aplicações sem que a equipe administre diretamente a infraestrutura subjacente.

Como opção PaaS, a plataforma administra infraestrutura e grande parte do sistema operacional. A equipe concentra mais esforço no código, nos dados e na configuração da aplicação.$content$,null,1),
  ('7b0d0000-0000-4000-8000-000000000002','azure-app-service','important','PaaS reduz tarefas, não responsabilidades do cliente',
   $content$A Microsoft opera a infraestrutura e a plataforma gerenciada. O cliente continua responsável pela aplicação, pelos dados, pelas identidades, pelos acessos e pelas configurações sob seu controle.

App Service disponibiliza escala e recursos da plataforma conforme plano e configuração. Isso não significa escala ilimitada, automática em qualquer cenário ou custo sempre menor.$content$,null,2),
  ('7b0d0000-0000-4000-8000-000000000003','azure-app-service','example','Aplicação web em plataforma gerenciada',
   $content$Uma equipe mantém uma aplicação web e uma API REST que usam recursos suportados pela plataforma. Ela publica a aplicação no App Service e deixa a Microsoft administrar a infraestrutura e grande parte do sistema operacional, reduzindo tarefas de servidor.$content$,null,3),
  ('7b0d0000-0000-4000-8000-000000000004','azure-app-service','dotnet_example','Web API ASP.NET Core padrão',
   $content$Uma Web API ASP.NET Core padrão não exige drivers específicos nem instalação direta de componentes no sistema operacional. Azure App Service pode ser adequado porque a equipe publica a aplicação e foca no código.

Se a API depender de software instalado diretamente no Windows Server ou de controle profundo do ambiente, uma VM pode ser mais apropriada. App Service não é automaticamente a melhor escolha apenas porque a aplicação usa .NET.$content$,null,4),
  ('7b0d0000-0000-4000-8000-000000000005','azure-app-service','important','App Service versus Virtual Machine',
   $content$VM oferece maior controle do guest OS, runtime e software instalado, mas exige que o cliente assuma mais tarefas operacionais. App Service oferece menos controle direto do sistema operacional e reduz a responsabilidade de infraestrutura.

A escolha depende do requisito. Recursos complementares, runtimes, SKUs e opções de deployment não precisam ser memorizados para reconhecer o modelo de application hosting em AZ-900.$content$,null,5),
  ('7b0d0000-0000-4000-8000-000000000006','azure-app-service','exam_trap','App Service não é uma VM gerenciada pelo usuário',
   $content$No Azure App Service, o desenvolvedor não administra diretamente o guest OS como faria em uma VM. A plataforma ser gerenciada também não elimina a responsabilidade do cliente por código, dados, identidade, acesso e configuração da aplicação.$content$,null,6),
  ('7b0d0000-0000-4000-8000-000000000007','azure-app-service','exam_tip','Procure web/API sem controle do SO',
   $content$Se o cenário pede publicar uma aplicação web ou API em uma plataforma gerenciada e não exige controlar o sistema operacional, Azure Web Apps/App Service é uma candidata forte. Se o controle do SO ou a instalação direta de software for requisito, compare com VM.$content$,null,7),
  ('7b0d0000-0000-4000-8000-000000000008','azure-app-service','summary','Resumo para memória ativa',null,
   '{"items":["Azure App Service é PaaS para hospedar aplicações web e APIs.","Web Apps permite publicar a aplicação em uma plataforma gerenciada.","A Microsoft administra infraestrutura e grande parte do sistema operacional.","O cliente mantém responsabilidades sobre aplicação, dados, identidades e configurações.","App Service oferece menos controle do SO e menor responsabilidade de infraestrutura que uma VM.","Escala e recursos dependem do plano e da configuração."]}'::jsonb,8),

  ('7b0d0000-0000-4000-8000-000000000009','choosing-application-hosting','explanation','Escolhendo application hosting',
   $content$Azure Web Apps, containers e Virtual Machines podem hospedar aplicações, mas equilibram controle, portabilidade e responsabilidade operacional de formas diferentes. Comece pelo requisito dominante, não pela tecnologia favorita da equipe.

Uma arquitetura real pode combinar opções. Esta comparação apresenta tendências para o nível Fundamentals, não regras universais para todos os produtos e configurações do Azure.$content$,null,1),
  ('7b0d0000-0000-4000-8000-000000000010','choosing-application-hosting','important','Matriz: Web Apps | Containers | VMs',
   $content$Controle do SO — Web Apps: baixo | Containers: intermediário, concentrado na imagem e plataforma | VMs: alto.

Gestão da infraestrutura — Web Apps: baixa | Containers: intermediária e dependente da plataforma | VMs: alta.

Portabilidade — Web Apps: média | Containers: alta por imagem | VMs: geralmente menor.

Aplicação web gerenciada — Web Apps: característica forte | Containers: possível | VMs: possível.

Dependências customizadas — Web Apps: limitadas pela plataforma | Containers: empacotadas na imagem | VMs: alto controle.

Responsabilidade operacional — Web Apps: menor | Containers: intermediária | VMs: maior. Essas posições são comparativas e podem variar conforme serviço, plano e arquitetura.$content$,null,2),
  ('7b0d0000-0000-4000-8000-000000000011','choosing-application-hosting','dotnet_example','Cenário A: Web Apps',
   $content$Uma API ASP.NET Core comum não exige dependências específicas do sistema operacional. A equipe quer publicar o código e reduzir tarefas de infraestrutura. Azure Web Apps é a resposta provável porque oferece hosting PaaS gerenciado.$content$,null,3),
  ('7b0d0000-0000-4000-8000-000000000012','choosing-application-hosting','example','Cenário B: Container',
   $content$Uma aplicação já está empacotada em Docker com runtime e bibliotecas e precisa executar de forma consistente em diferentes ambientes compatíveis. Container é a resposta provável porque a imagem preserva o pacote da aplicação e favorece portabilidade.$content$,null,4),
  ('7b0d0000-0000-4000-8000-000000000013','choosing-application-hosting','example','Cenário C: Virtual Machine',
   $content$Uma aplicação legada precisa instalar componentes diretamente no Windows Server e alterar configurações do sistema operacional. Virtual Machine é a resposta provável porque oferece controle do guest OS, acompanhado de maior responsabilidade operacional.$content$,null,5),
  ('7b0d0000-0000-4000-8000-000000000014','choosing-application-hosting','important','As opções podem se sobrepor',
   $content$Uma aplicação web pode executar em Web Apps, container ou VM. “É uma aplicação web” não encerra a decisão: verifique necessidade de plataforma gerenciada, portabilidade da imagem, dependências customizadas e controle do sistema operacional.

Web Apps não é sempre melhor, containers não eliminam operação e VMs não são obrigatórias para toda aplicação legada.$content$,null,6),
  ('7b0d0000-0000-4000-8000-000000000015','choosing-application-hosting','exam_trap','Não confunda possibilidade com melhor alinhamento',
   $content$VM pode hospedar uma API e container pode hospedar uma aplicação web, mas isso não os torna a resposta mais alinhada a todo cenário. Para a prova, relacione o requisito dominante ao nível de controle, portabilidade e responsabilidade operacional, evitando palavras absolutas como “sempre” e “nunca”.$content$,null,7),
  ('7b0d0000-0000-4000-8000-000000000016','choosing-application-hosting','exam_tip','Três perguntas rápidas',
   $content$Precisa de plataforma web gerenciada sem controlar o SO? Pense em Web Apps. Precisa empacotar dependências e favorecer portabilidade? Pense em container. Precisa controlar o guest OS e instalar software específico? Pense em VM.$content$,null,8),
  ('7b0d0000-0000-4000-8000-000000000017','choosing-application-hosting','summary','Resumo para memória ativa',null,
   '{"items":["Web Apps favorece aplicações web/APIs em plataforma PaaS gerenciada.","Containers favorecem dependências empacotadas e portabilidade.","VMs favorecem controle do sistema operacional e software instalado.","Menor controle de infraestrutura normalmente reduz tarefas operacionais do cliente.","Uma aplicação web pode executar nas três opções; o requisito dominante orienta a escolha.","Controle, portabilidade e responsabilidade operacional são pistas centrais de prova."]}'::jsonb,9);

insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, display_order, is_published
)
select seed.id, lesson.id, seed.type, seed.title, seed.content, seed.config,
  seed.display_order, true
from stage_865_block_seed seed
join public.lessons lesson
  on lesson.topic_id = '32000000-0000-4000-8000-000000000002'
 and lesson.slug = seed.lesson_slug;

create temporary table stage_865_flashcard_update (
  id uuid primary key, front_text text not null, back_text text not null, hint text
) on commit drop;

insert into stage_865_flashcard_update values
  ('72000000-0000-4000-8000-000000000007','O que é Azure App Service?','É uma plataforma PaaS gerenciada para hospedar aplicações web e APIs, reduzindo a administração direta de infraestrutura e sistema operacional.','Application hosting gerenciado.'),
  ('72000000-0000-4000-8000-000000000008','Qual é o foco da equipe ao usar Azure Web Apps?','Publicar e configurar a aplicação, além de administrar código, dados, identidades e acessos, enquanto a Microsoft gerencia a plataforma subjacente.','PaaS não elimina responsabilidade.'),
  ('72000000-0000-4000-8000-000000000009','Qual é a diferença principal entre App Service e uma VM para application hosting?','App Service oferece menos controle do SO e menos tarefas de infraestrutura; VM oferece maior controle do guest OS e maior responsabilidade operacional.','Controle versus operação.'),
  ('72000000-0000-4000-8000-000000000010','Quando Azure Web Apps tende a ser adequado?','Quando uma aplicação web ou API pode usar a plataforma gerenciada sem exigir instalação direta de software ou controle profundo do sistema operacional.','Web/API sem controle do SO.');

update public.flashcards card
set front_text = seed.front_text, back_text = seed.back_text, hint = seed.hint
from stage_865_flashcard_update seed
where card.id = seed.id;

create temporary table stage_865_flashcard_seed (
  id uuid primary key, front_text text not null, back_text text not null,
  hint text, display_order integer not null
) on commit drop;

insert into stage_865_flashcard_seed values
  ('7e100000-0000-4000-8000-000000000001','Qual opção tende a atender uma API web padrão sem necessidade de controlar o SO?','Azure Web Apps/App Service, por oferecer uma plataforma PaaS gerenciada para aplicações web e APIs.','Plataforma web gerenciada.',1),
  ('7e100000-0000-4000-8000-000000000002','Qual opção favorece aplicação e dependências empacotadas com portabilidade?','Container, porque a imagem reúne a aplicação, o runtime e as dependências.','Imagem portátil.',2),
  ('7e100000-0000-4000-8000-000000000003','Qual opção tende a atender software que exige controle do guest OS?','Virtual Machine, porque permite instalar componentes e configurar o sistema operacional, assumindo maior responsabilidade operacional.','Controle do SO.',3),
  ('7e100000-0000-4000-8000-000000000004','Quais três critérios ajudam a escolher application hosting?','Controle do sistema operacional, portabilidade das dependências e responsabilidade operacional desejada.','Controle, portabilidade e operação.',4),
  ('7e100000-0000-4000-8000-000000000005','Toda aplicação web deve usar Azure Web Apps?','Não. Web Apps, containers e VMs podem hospedar aplicações web; requisitos de plataforma, dependências e controle orientam a escolha.','Evite regras absolutas.',5);

insert into public.flashcards (
  id, lesson_id, front_text, back_text, hint, display_order, is_published
)
select seed.id, lesson.id, seed.front_text, seed.back_text, seed.hint,
  seed.display_order, true
from stage_865_flashcard_seed seed
join public.lessons lesson
  on lesson.topic_id = '32000000-0000-4000-8000-000000000002'
 and lesson.slug = 'choosing-application-hosting';

update public.questions
set question_text = 'Qual característica diferencia Azure App Service de hospedar a mesma aplicação em uma Virtual Machine?',
  difficulty = 'medium',
  explanation = 'App Service é PaaS: a Microsoft administra a plataforma e grande parte do sistema operacional. Em uma VM, o cliente possui mais controle do guest OS e assume mais tarefas operacionais.'
where id = '60000000-0000-4000-8000-000000000008';

create temporary table stage_865_existing_option_update (
  id uuid primary key, option_text text not null, explanation text not null
) on commit drop;

insert into stage_865_existing_option_update values
  ('70000000-0000-4000-8000-000000000029','App Service administra a plataforma e grande parte do SO; na VM, o cliente administra o guest OS.','Correta. Essa diferença representa PaaS versus maior controle e responsabilidade em IaaS.'),
  ('70000000-0000-4000-8000-000000000030','App Service e VM oferecem sempre o mesmo acesso administrativo ao sistema operacional.','Incorreta. App Service não oferece o mesmo controle direto do guest OS.'),
  ('70000000-0000-4000-8000-000000000031','VM administra automaticamente código, dados e identidades da aplicação.','Incorreta. Essas responsabilidades continuam com o cliente.'),
  ('70000000-0000-4000-8000-000000000032','App Service exige que o cliente aplique patches no guest OS como em uma VM.','Incorreta. A plataforma gerenciada assume grande parte dessas tarefas.');

update public.question_options option
set option_text = seed.option_text, explanation = seed.explanation
from stage_865_existing_option_update seed
where option.id = seed.id;

create temporary table stage_865_question_seed (
  id uuid primary key, lesson_slug text not null, question_text text not null,
  difficulty text not null, explanation text not null, display_order integer not null
) on commit drop;

insert into stage_865_question_seed values
  ('68000000-0000-4000-8000-000000000016','azure-app-service','Qual modelo de serviço representa melhor Azure App Service para hospedar uma aplicação web?','easy','Azure App Service é uma oferta PaaS: a plataforma gerencia a infraestrutura subjacente e permite que a equipe foque mais na aplicação.',2),
  ('68000000-0000-4000-8000-000000000017','azure-app-service','Ao usar Azure Web Apps, qual responsabilidade normalmente permanece com o cliente?','easy','O cliente continua responsável pelo código, dados, identidades, acessos e configurações da aplicação, mesmo com a plataforma gerenciada.',3),
  ('68000000-0000-4000-8000-000000000018','azure-app-service','Uma equipe possui uma Web API ASP.NET Core padrão, sem drivers específicos nem controle do SO. Ela quer reduzir tarefas de infraestrutura. Qual opção é mais alinhada?','medium','Azure Web Apps/App Service oferece hosting PaaS gerenciado para a API, sem exigir administração direta do guest OS.',4),
  ('68000000-0000-4000-8000-000000000019','azure-app-service','Uma API web exige componente instalado diretamente no Windows Server e alterações profundas no sistema operacional. Qual análise é mais adequada?','hard','Uma VM tende a ser mais adequada quando controle do guest OS e instalação direta de software são requisitos. App Service não é sempre a melhor opção para toda aplicação web.',5),
  ('68000000-0000-4000-8000-000000000020','choosing-application-hosting','Qual requisito aponta mais diretamente para Azure Web Apps?','easy','Aplicação web ou API que deseja plataforma PaaS gerenciada e não precisa controlar o sistema operacional.',1),
  ('68000000-0000-4000-8000-000000000021','choosing-application-hosting','Qual requisito aponta mais diretamente para containers?','easy','Empacotar aplicação e dependências em uma imagem para favorecer portabilidade e consistência entre ambientes.',2),
  ('68000000-0000-4000-8000-000000000022','choosing-application-hosting','Uma aplicação legada precisa instalar componentes diretamente no Windows Server. Qual opção tende a ser mais adequada?','medium','Virtual Machine oferece controle do guest OS e do software instalado, com maior responsabilidade operacional.',3),
  ('68000000-0000-4000-8000-000000000023','choosing-application-hosting','Qual comparação entre Web Apps, containers e VMs é conceitualmente correta?','medium','Web Apps reduz tarefas de plataforma; container controla o pacote da aplicação; VM oferece maior controle do guest OS. São tendências, não garantias absolutas.',4),
  ('68000000-0000-4000-8000-000000000024','choosing-application-hosting','Uma solução possui uma API padrão sem dependência de SO, um worker empacotado em Docker para vários ambientes e um sistema legado que exige componentes no Windows Server. Qual combinação é mais coerente?','hard','Web Apps atende à API gerenciada, container preserva o pacote portátil e VM oferece o controle exigido pelo sistema legado.',5);

insert into public.questions (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select seed.id, certification.id, domain.id, topic.id, lesson.id,
  seed.question_text, 'single_choice', seed.difficulty, seed.explanation, true,
  seed.display_order
from stage_865_question_seed seed
join public.certifications certification on certification.code = 'az-900'
join public.domains domain on domain.certification_id = certification.id
  and domain.title = 'Describe Azure architecture and services'
join public.topics topic on topic.domain_id = domain.id and topic.title = 'Compute Services'
join public.lessons lesson on lesson.topic_id = topic.id and lesson.slug = seed.lesson_slug;

create temporary table stage_865_option_seed (
  id uuid primary key, question_id uuid not null, option_text text not null,
  is_correct boolean not null, explanation text not null, display_order integer not null
) on commit drop;

insert into stage_865_option_seed values
  ('7f100000-0000-4000-8000-000000000061','68000000-0000-4000-8000-000000000016','Platform as a Service (PaaS).',true,'Correta. App Service fornece uma plataforma gerenciada para publicar aplicações.',1),
  ('7f100000-0000-4000-8000-000000000062','68000000-0000-4000-8000-000000000016','Infrastructure as a Service (IaaS).',false,'Incorreta. IaaS deixa o guest OS sob responsabilidade do cliente.',2),
  ('7f100000-0000-4000-8000-000000000063','68000000-0000-4000-8000-000000000016','Software as a Service (SaaS).',false,'Incorreta. SaaS entrega software pronto, não plataforma para publicar o código.',3),
  ('7f100000-0000-4000-8000-000000000064','68000000-0000-4000-8000-000000000016','Datacenter privado.',false,'Incorreta. Não representa o modelo do App Service.',4),
  ('7f100000-0000-4000-8000-000000000065','68000000-0000-4000-8000-000000000017','Código, dados, identidades, acessos e configurações da aplicação.',true,'Correta. Shared Responsibility continua valendo em PaaS.',1),
  ('7f100000-0000-4000-8000-000000000066','68000000-0000-4000-8000-000000000017','Substituição do hardware físico do datacenter.',false,'Incorreta. Hardware é responsabilidade da Microsoft.',2),
  ('7f100000-0000-4000-8000-000000000067','68000000-0000-4000-8000-000000000017','Manutenção da refrigeração e da energia do datacenter.',false,'Incorreta. Instalações pertencem ao provider.',3),
  ('7f100000-0000-4000-8000-000000000068','68000000-0000-4000-8000-000000000017','Atualização do hipervisor da plataforma Azure.',false,'Incorreta. A Microsoft administra a infraestrutura subjacente.',4),
  ('7f100000-0000-4000-8000-000000000069','68000000-0000-4000-8000-000000000018','Azure Virtual Machines, para administrar manualmente o guest OS.',false,'Incorreta. Pode hospedar a API, mas adiciona as tarefas que a equipe quer reduzir.',1),
  ('7f100000-0000-4000-8000-000000000070','68000000-0000-4000-8000-000000000018','Azure Web Apps no Azure App Service.',true,'Correta. O cenário está alinhado a hosting web PaaS gerenciado.',2),
  ('7f100000-0000-4000-8000-000000000071','68000000-0000-4000-8000-000000000018','Azure Virtual Desktop para publicar a API aos usuários.',false,'Incorreta. AVD entrega desktops e aplicações remotas, não hosting de API.',3),
  ('7f100000-0000-4000-8000-000000000072','68000000-0000-4000-8000-000000000018','Availability Set sem nenhuma VM.',false,'Incorreta. Availability Set não executa aplicação.',4),
  ('7f100000-0000-4000-8000-000000000073','68000000-0000-4000-8000-000000000019','App Service é obrigatório porque toda API deve usar PaaS.',false,'Incorreta. O requisito de controle do SO muda a análise.',1),
  ('7f100000-0000-4000-8000-000000000074','68000000-0000-4000-8000-000000000019','Container sempre resolve qualquer dependência do Windows sem considerar o host.',false,'Incorreta. Compatibilidade e plataforma do container ainda importam.',2),
  ('7f100000-0000-4000-8000-000000000075','68000000-0000-4000-8000-000000000019','Azure Functions oferece controle administrativo completo do Windows Server.',false,'Incorreta. Functions abstrai a infraestrutura do servidor.',3),
  ('7f100000-0000-4000-8000-000000000076','68000000-0000-4000-8000-000000000019','Uma VM tende a ser mais adequada pelo controle do guest OS e do software instalado.',true,'Correta. O requisito explícito favorece VM.',4),
  ('7f100000-0000-4000-8000-000000000077','68000000-0000-4000-8000-000000000020','Hospedar uma aplicação web/API em plataforma gerenciada sem controlar o SO.',true,'Correta. Esse é o cenário principal de Web Apps.',1),
  ('7f100000-0000-4000-8000-000000000078','68000000-0000-4000-8000-000000000020','Instalar componentes diretamente no guest OS e alterar o kernel.',false,'Incorreta. Esse requisito aponta para maior controle, como VM.',2),
  ('7f100000-0000-4000-8000-000000000079','68000000-0000-4000-8000-000000000020','Orquestrar múltiplos containers com Kubernetes.',false,'Incorreta. Esse cenário aponta para AKS, não Web Apps como conceito principal.',3),
  ('7f100000-0000-4000-8000-000000000080','68000000-0000-4000-8000-000000000020','Entregar um desktop Windows remoto a usuários.',false,'Incorreta. Esse cenário aponta para Azure Virtual Desktop.',4),
  ('7f100000-0000-4000-8000-000000000081','68000000-0000-4000-8000-000000000021','Controle físico do datacenter onde a aplicação executa.',false,'Incorreta. Container não oferece controle físico do datacenter.',1),
  ('7f100000-0000-4000-8000-000000000082','68000000-0000-4000-8000-000000000021','Aplicação e dependências empacotadas em uma imagem portátil.',true,'Correta. Esse é o benefício central do container neste cenário.',2),
  ('7f100000-0000-4000-8000-000000000083','68000000-0000-4000-8000-000000000021','Guest OS próprio obrigatório para cada processo da aplicação.',false,'Incorreta. Container compartilha o kernel do host.',3),
  ('7f100000-0000-4000-8000-000000000084','68000000-0000-4000-8000-000000000021','Execução exclusiva por timer, sem pacote da aplicação.',false,'Incorreta. Isso não descreve o requisito de portabilidade.',4),
  ('7f100000-0000-4000-8000-000000000085','68000000-0000-4000-8000-000000000022','Azure Web Apps, porque permite acesso administrativo irrestrito ao Windows Server.',false,'Incorreta. Web Apps abstrai o guest OS.',1),
  ('7f100000-0000-4000-8000-000000000086','68000000-0000-4000-8000-000000000022','Container, porque sempre permite alterar o sistema operacional do host.',false,'Incorreta. Container não oferece automaticamente esse controle.',2),
  ('7f100000-0000-4000-8000-000000000087','68000000-0000-4000-8000-000000000022','Azure Virtual Machines.',true,'Correta. VM oferece controle do guest OS e software instalado.',3),
  ('7f100000-0000-4000-8000-000000000088','68000000-0000-4000-8000-000000000022','Azure Functions com trigger HTTP.',false,'Incorreta. Functions não atende ao controle profundo do Windows Server.',4),
  ('7f100000-0000-4000-8000-000000000089','68000000-0000-4000-8000-000000000023','As três opções sempre oferecem o mesmo controle e a mesma responsabilidade operacional.',false,'Incorreta. Esses fatores diferenciam as opções.',1),
  ('7f100000-0000-4000-8000-000000000090','68000000-0000-4000-8000-000000000023','Web Apps oferece controle irrestrito do SO; container reduz portabilidade; VM elimina tarefas operacionais.',false,'Incorreta. A afirmação inverte as tendências das três opções.',2),
  ('7f100000-0000-4000-8000-000000000091','68000000-0000-4000-8000-000000000023','Container elimina toda responsabilidade operacional e VM elimina necessidade de patches.',false,'Incorreta. Ambas as opções mantêm responsabilidades do cliente.',3),
  ('7f100000-0000-4000-8000-000000000092','68000000-0000-4000-8000-000000000023','Web Apps reduz tarefas de plataforma; container controla o pacote; VM oferece maior controle do SO.','true','Correta. Resume as tendências sem transformá-las em absolutos.',4),
  ('7f100000-0000-4000-8000-000000000093','68000000-0000-4000-8000-000000000024','VM para a API, Web Apps para o worker portátil e container para o legado Windows.','false','Incorreta. A combinação não segue os requisitos dominantes.',1),
  ('7f100000-0000-4000-8000-000000000094','68000000-0000-4000-8000-000000000024','Web Apps para a API, container para o worker e VM para o legado.','true','Correta. Cada opção atende ao requisito principal correspondente.',2),
  ('7f100000-0000-4000-8000-000000000095','68000000-0000-4000-8000-000000000024','Container para a API, VM para o worker portátil e Web Apps para o legado.','false','Incorreta. Inverte portabilidade e controle do SO.',3),
  ('7f100000-0000-4000-8000-000000000096','68000000-0000-4000-8000-000000000024','Functions para os três componentes porque todos usam código.','false','Incorreta. Usar código não torna toda carga orientada a eventos.',4);

insert into public.question_options (
  id, question_id, option_text, is_correct, explanation, display_order
)
select id, question_id, option_text, is_correct, explanation, display_order
from stage_865_option_seed;

do $$
begin
  if (select count(*) from stage_865_block_seed) <> 17
    or (select count(*) from stage_865_flashcard_update) <> 4
    or (select count(*) from stage_865_flashcard_seed) <> 5
    or (select count(*) from stage_865_question_seed) <> 9
    or (select count(*) from stage_865_option_seed) <> 36 then
    raise exception '8.6.5 staged row counts are invalid';
  end if;

  if exists (
    select 1
    from public.visual_experiences visual
    join public.lessons lesson on lesson.id = visual.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug in ('azure-app-service', 'choosing-application-hosting')
  ) then
    raise exception '8.6.5 must not create a Visual Experience';
  end if;

  if exists (
    select 1
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000002'
      and lesson.slug in ('azure-app-service', 'choosing-application-hosting')
      and question.is_published
    group by question.id
    having count(option.id) <> 4
      or count(option.id) filter (where option.is_correct) <> 1
      or count(distinct lower(btrim(option.option_text))) <> 4
  ) then
    raise exception '8.6.5 Question Options are invalid';
  end if;
end;
$$;

commit;

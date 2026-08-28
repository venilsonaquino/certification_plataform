begin;

do $$
declare target_lesson_id uuid;
begin
  select lesson.id into strict target_lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Networking Services'
    and lesson.slug = 'vpn-gateway-vs-expressroute';

  if exists (select 1 from public.lesson_content_blocks where lesson_id = target_lesson_id) then
    raise exception 'The VPN Gateway vs ExpressRoute Lesson already contains Content Blocks';
  end if;
  if exists (select 1 from public.visual_experiences where lesson_id = target_lesson_id)
    or exists (select 1 from public.visual_experiences where id = '76000000-0000-4000-8000-000000000011') then
    raise exception 'The scoped visual target or planned UUID is already in use';
  end if;
  if (select count(*) from public.flashcards where lesson_id = target_lesson_id and is_published) <> 4
    or exists (select 1 from public.questions where lesson_id = target_lesson_id) then
    raise exception 'Expected four published Flashcards and no Questions before 8.7.4';
  end if;
end;
$$;

update public.lessons set estimated_minutes = 12
where topic_id = '32000000-0000-4000-8000-000000000003'
  and slug = 'vpn-gateway-vs-expressroute';

insert into public.visual_experiences (
  id, lesson_id, type, title, description, config, display_order, is_published
)
select '76000000-0000-4000-8000-000000000011', lesson.id, 'comparison',
  'VPN Gateway versus ExpressRoute',
  'Compare o caminho principal, o mecanismo e os cenários típicos das duas opções de conectividade híbrida. As diferenças são tendências conceituais, não garantias absolutas.',
  $json$
  {
    "columns": [
      {"id":"vpn-gateway","title":"VPN Gateway","description":"Túnel VPN criptografado; para on-premises e Azure, normalmente usa a Internet pública como transporte."},
      {"id":"expressroute","title":"ExpressRoute","description":"Conectividade privada com a Microsoft Cloud por meio de um connectivity provider."}
    ],
    "rows": [
      {"id":"path","label":"Caminho conceitual","description":"Como a rede on-premises alcança o Azure.","values":{"vpn-gateway":"On-premises → túnel criptografado → Internet pública → VPN Gateway → VNet","expressroute":"On-premises → connectivity provider → conexão privada → rede Microsoft → Azure"}},
      {"id":"transport","label":"Transporte principal","values":{"vpn-gateway":"Internet pública para conexões híbridas","expressroute":"Conexão privada, fora da Internet pública"}},
      {"id":"vpn-encryption","label":"Túnel VPN","values":{"vpn-gateway":"Sim, tráfego criptografado","expressroute":"Não é uma VPN pela Internet"}},
      {"id":"provisioning","label":"Implantação inicial","values":{"vpn-gateway":"Geralmente mais simples","expressroute":"Requer provider e conectividade"}},
      {"id":"cost","label":"Custo relativo","values":{"vpn-gateway":"Normalmente menor","expressroute":"Normalmente maior"}},
      {"id":"predictability","label":"Previsibilidade","values":{"vpn-gateway":"Mais sujeita às condições do caminho público","expressroute":"Pode oferecer latência e performance mais previsíveis"}},
      {"id":"scenario","label":"Uso comum","values":{"vpn-gateway":"Conectividade híbrida com túnel criptografado","expressroute":"Conectividade híbrida privada e mais previsível"}}
    ]
  }
  $json$::jsonb, 1, true
from public.lessons lesson
where lesson.topic_id = '32000000-0000-4000-8000-000000000003'
  and lesson.slug = 'vpn-gateway-vs-expressroute';

create temporary table stage_874_block_seed (
  id uuid primary key, type text not null, title text, content text,
  config jsonb, visual_experience_id uuid, display_order integer not null
) on commit drop;

insert into stage_874_block_seed values
  ('7b100000-0000-4000-8000-000000000001','explanation','O que é Azure VPN Gateway?',
   $content$Azure VPN Gateway permite enviar tráfego criptografado por túneis VPN entre uma Azure VNet e uma rede on-premises, entre um dispositivo remoto e uma VNet e, em cenários suportados, entre VNets.

Em uma conexão híbrida on-premises ↔ Azure, a Internet pública normalmente funciona como transporte. O túnel VPN protege o tráfego durante esse caminho.$content$,null,null,1),
  ('7b100000-0000-4000-8000-000000000002','important','Site-to-Site e Point-to-Site',
   $content$Site-to-Site (S2S): rede da empresa ↔ túnel VPN ↔ Azure VNet. Conecta uma rede ou local on-premises ao Azure.

Point-to-Site (P2S): dispositivo individual ↔ túnel VPN ↔ Azure VNet. Conecta um usuário ou dispositivo remoto à VNet.

Para Fundamentals, reconheça o cenário. Protocolos, certificados, autenticação, SKUs e configuração ficam fora desta Lesson.$content$,null,null,2),
  ('7b100000-0000-4000-8000-000000000003','example','Escritório conectado por VPN',
   $content$Uma pequena empresa precisa conectar a rede de seu escritório a uma Azure VNet usando um túnel criptografado pela Internet. Uma conexão Site-to-Site por Azure VPN Gateway pode ser apropriada.

Se apenas um profissional remoto precisa acessar a VNet, o cenário aponta para Point-to-Site. A escolha final ainda depende dos requisitos completos.$content$,null,null,3),
  ('7b100000-0000-4000-8000-000000000004','explanation','O que é Azure ExpressRoute?',
   $content$Azure ExpressRoute estende uma rede on-premises à Microsoft Cloud por uma conexão privada com a ajuda de um connectivity provider. O caminho normal da conexão não passa pela Internet pública.

ExpressRoute pode oferecer conectividade híbrida com latência e performance mais previsíveis do que um caminho típico pela Internet. Ele não é uma VPN pela Internet nem simplesmente “Internet mais rápida”.$content$,null,null,4),
  ('7b100000-0000-4000-8000-000000000005','example','Conectividade híbrida privada e previsível',
   $content$Uma organização possui grande volume de comunicação entre seu datacenter e o Azure e precisa de conectividade privada com comportamento mais previsível. ExpressRoute pode ser apropriado por usar um provider para conectar a rede à Microsoft Cloud sem a Internet pública como caminho normal.

O tamanho da empresa, sozinho, não torna ExpressRoute obrigatório.$content$,null,null,5),
  ('7b100000-0000-4000-8000-000000000006','important','Comparação sem regras absolutas',
   $content$VPN Gateway usa túneis VPN criptografados e, para conexões híbridas, normalmente utiliza a Internet pública; tende a ter implantação mais simples e custo menor.

ExpressRoute fornece conexão privada via provider; pode oferecer maior previsibilidade e normalmente envolve custo e provisionamento maiores. Preço, desempenho e segurança dependem da arquitetura, localização, serviço contratado e configuração.$content$,null,null,6),
  ('7b100000-0000-4000-8000-000000000007','visual_experience','VPN Gateway versus ExpressRoute',null,null,
   '76000000-0000-4000-8000-000000000011',7),
  ('7b100000-0000-4000-8000-000000000008','exam_trap','Não confunda os mecanismos de conectividade',
   $content$VPN Gateway não é ExpressRoute. ExpressRoute não é VPN pela Internet e não significa apenas “Internet mais rápida”: é conectividade privada com a Microsoft Cloud.

VNet Peering conecta VNets Azure pelo backbone da Microsoft e também não é VPN Gateway nem ExpressRoute. Conexão privada, sozinha, não torna toda a arquitetura automaticamente mais segura; controles de ponta a ponta continuam necessários.$content$,null,null,8),
  ('7b100000-0000-4000-8000-000000000009','exam_tip','Identifique o caminho e o ponto conectado',
   $content$Escritório ou rede on-premises usando túnel criptografado pela Internet: pense em VPN Gateway/Site-to-Site. Dispositivo remoto individual: Point-to-Site. Conexão privada via connectivity provider, sem a Internet pública como caminho normal: pense em ExpressRoute.$content$,null,null,9),
  ('7b100000-0000-4000-8000-000000000010','summary','Resumo para memória ativa',null,
   '{"items":["VPN Gateway envia tráfego por túneis VPN criptografados.","S2S conecta uma rede on-premises; P2S conecta um dispositivo remoto.","Conexões VPN híbridas normalmente usam a Internet pública como transporte.","ExpressRoute oferece conectividade privada via connectivity provider.","ExpressRoute não usa a Internet pública como caminho normal e pode ser mais previsível.","VPN Gateway, ExpressRoute e VNet Peering são mecanismos diferentes."]}'::jsonb,null,10);

insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, visual_experience_id, display_order, is_published
)
select seed.id, lesson.id, seed.type, seed.title, seed.content, seed.config,
  seed.visual_experience_id, seed.display_order, true
from stage_874_block_seed seed
join public.lessons lesson on lesson.topic_id = '32000000-0000-4000-8000-000000000003'
  and lesson.slug = 'vpn-gateway-vs-expressroute';

create temporary table stage_874_flashcard_update (
  id uuid primary key, front_text text not null, back_text text not null, hint text
) on commit drop;

insert into stage_874_flashcard_update values
  ('72000000-0000-4000-8000-000000000029','Qual é a finalidade do Azure VPN Gateway?','Criar túneis VPN criptografados para conectar uma VNet a redes on-premises, dispositivos remotos ou, em cenários suportados, outras VNets.','Conectividade por túnel criptografado.'),
  ('72000000-0000-4000-8000-000000000030','Qual é a diferença entre VPN Site-to-Site e Point-to-Site?','S2S conecta uma rede on-premises à VNet; P2S conecta um dispositivo ou usuário remoto à VNet.','Rede versus dispositivo.'),
  ('72000000-0000-4000-8000-000000000031','Qual é a finalidade do Azure ExpressRoute?','Fornecer conectividade privada entre uma rede on-premises e a Microsoft Cloud por meio de um connectivity provider, sem a Internet pública como caminho normal.','Conexão privada via provider.'),
  ('72000000-0000-4000-8000-000000000032','Quando considerar VPN Gateway ou ExpressRoute?','VPN atende túnel criptografado normalmente pela Internet; ExpressRoute atende conexão privada via provider quando previsibilidade é um requisito importante.','Escolha pelo caminho e requisito.');

update public.flashcards card
set front_text = seed.front_text, back_text = seed.back_text, hint = seed.hint
from stage_874_flashcard_update seed where card.id = seed.id;

create temporary table stage_874_question_seed (
  id uuid primary key, question_text text not null, difficulty text not null,
  explanation text not null, display_order integer not null
) on commit drop;

insert into stage_874_question_seed values
  ('68000000-0000-4000-8000-000000000035','Qual opção cria túneis criptografados para conectar uma Azure VNet a uma rede on-premises pela Internet pública?','easy','Azure VPN Gateway permite conexões híbridas por túneis VPN criptografados, normalmente usando a Internet pública como transporte.',1),
  ('68000000-0000-4000-8000-000000000036','Qual alternativa diferencia Site-to-Site de Point-to-Site?','easy','S2S conecta uma rede on-premises à VNet; P2S conecta um dispositivo ou usuário remoto à VNet.',2),
  ('68000000-0000-4000-8000-000000000037','Uma empresa precisa de conectividade privada entre seu datacenter e a Microsoft Cloud por meio de um connectivity provider. Qual serviço é mais alinhado?','medium','ExpressRoute estende a rede on-premises à Microsoft Cloud por uma conexão privada fornecida por um connectivity provider.',3),
  ('68000000-0000-4000-8000-000000000038','Qual comparação entre VPN Gateway e ExpressRoute está correta?','medium','VPN Gateway usa túnel criptografado, normalmente pela Internet pública em conexões híbridas; ExpressRoute usa uma conexão privada via provider.',4),
  ('68000000-0000-4000-8000-000000000039','Uma organização quer conectar uma filial por túnel criptografado de implantação mais simples e também avalia uma conexão privada mais previsível para seu datacenter principal. Qual análise é mais adequada?','hard','VPN Gateway pode atender a filial pela Internet com túnel criptografado; ExpressRoute pode atender o datacenter por conexão privada via provider. São tendências condicionadas aos requisitos, não regras absolutas.',5);

insert into public.questions (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select seed.id, certification.id, domain.id, topic.id, lesson.id,
  seed.question_text, 'single_choice', seed.difficulty, seed.explanation, true, seed.display_order
from stage_874_question_seed seed
join public.certifications certification on certification.code = 'az-900'
join public.domains domain on domain.certification_id = certification.id and domain.title = 'Describe Azure architecture and services'
join public.topics topic on topic.domain_id = domain.id and topic.title = 'Networking Services'
join public.lessons lesson on lesson.topic_id = topic.id and lesson.slug = 'vpn-gateway-vs-expressroute';

create temporary table stage_874_option_seed (
  id uuid primary key, question_id uuid not null, option_text text not null,
  is_correct boolean not null, explanation text not null, display_order integer not null
) on commit drop;

insert into stage_874_option_seed values
  ('7f100000-0000-4000-8000-000000000157','68000000-0000-4000-8000-000000000035','Azure VPN Gateway.',true,'Correta. Ele cria os túneis VPN criptografados descritos.',1),
  ('7f100000-0000-4000-8000-000000000158','68000000-0000-4000-8000-000000000035','Azure ExpressRoute.',false,'Incorreta. ExpressRoute usa conectividade privada via provider, não um túnel VPN pela Internet.',2),
  ('7f100000-0000-4000-8000-000000000159','68000000-0000-4000-8000-000000000035','VNet Peering.',false,'Incorreta. Peering conecta VNets Azure e não representa a conexão híbrida descrita.',3),
  ('7f100000-0000-4000-8000-000000000160','68000000-0000-4000-8000-000000000035','Azure Public DNS.',false,'Incorreta. DNS resolve nomes e não cria túneis VPN.',4),
  ('7f100000-0000-4000-8000-000000000161','68000000-0000-4000-8000-000000000036','S2S conecta uma rede; P2S conecta um dispositivo remoto.',true,'Correta. Essa é a diferença conceitual entre os cenários.',1),
  ('7f100000-0000-4000-8000-000000000162','68000000-0000-4000-8000-000000000036','S2S conecta um dispositivo; P2S conecta duas Regions.',false,'Incorreta. P2S é dispositivo a VNet e S2S é rede a VNet.',2),
  ('7f100000-0000-4000-8000-000000000163','68000000-0000-4000-8000-000000000036','S2S usa ExpressRoute; P2S usa VNet Peering.',false,'Incorreta. Ambos são tipos de cenário VPN Gateway.',3),
  ('7f100000-0000-4000-8000-000000000164','68000000-0000-4000-8000-000000000036','Não há diferença no ponto conectado.',false,'Incorreta. Rede versus dispositivo é a diferença central.',4),
  ('7f100000-0000-4000-8000-000000000165','68000000-0000-4000-8000-000000000037','Azure ExpressRoute.',true,'Correta. O cenário descreve conexão privada via connectivity provider.',1),
  ('7f100000-0000-4000-8000-000000000166','68000000-0000-4000-8000-000000000037','Azure VPN Gateway Point-to-Site.',false,'Incorreta. P2S conecta um dispositivo remoto por VPN.',2),
  ('7f100000-0000-4000-8000-000000000167','68000000-0000-4000-8000-000000000037','Global VNet Peering.',false,'Incorreta. Peering conecta VNets Azure, não o datacenter por provider.',3),
  ('7f100000-0000-4000-8000-000000000168','68000000-0000-4000-8000-000000000037','Azure Private DNS.',false,'Incorreta. Private DNS resolve nomes privados e não fornece o circuito.',4),
  ('7f100000-0000-4000-8000-000000000169','68000000-0000-4000-8000-000000000038','VPN usa túnel criptografado pelo caminho público; ExpressRoute usa conexão privada via provider.',true,'Correta. Essa é a distinção fundamental entre os mecanismos.',1),
  ('7f100000-0000-4000-8000-000000000170','68000000-0000-4000-8000-000000000038','ExpressRoute é uma VPN mais rápida executada na Internet pública.',false,'Incorreta. ExpressRoute não usa a Internet pública como caminho normal.',2),
  ('7f100000-0000-4000-8000-000000000171','68000000-0000-4000-8000-000000000038','VPN Gateway e ExpressRoute são nomes para o mesmo gateway.',false,'Incorreta. São opções distintas de conectividade híbrida.',3),
  ('7f100000-0000-4000-8000-000000000172','68000000-0000-4000-8000-000000000038','VNet Peering substitui obrigatoriamente ambos os serviços.',false,'Incorreta. Peering resolve um cenário diferente de conectividade VNet a VNet.',4),
  ('7f100000-0000-4000-8000-000000000173','68000000-0000-4000-8000-000000000039','VPN Gateway para a filial e ExpressRoute para o datacenter, sujeitos aos requisitos completos.',true,'Correta. Cada mecanismo se alinha ao requisito dominante descrito.',1),
  ('7f100000-0000-4000-8000-000000000174','68000000-0000-4000-8000-000000000039','ExpressRoute é obrigatório para toda empresa grande e VPN só serve para testes.',false,'Incorreta. Porte da empresa não cria uma regra obrigatória.',2),
  ('7f100000-0000-4000-8000-000000000175','68000000-0000-4000-8000-000000000039','Usar apenas Public DNS, pois ele cria ambos os caminhos de rede.',false,'Incorreta. DNS não fornece esses mecanismos de conectividade.',3),
  ('7f100000-0000-4000-8000-000000000176','68000000-0000-4000-8000-000000000039','Usar VNet Peering para conectar diretamente as duas redes on-premises.',false,'Incorreta. VNet Peering conecta VNets Azure, não substitui automaticamente conectividade híbrida.',4);

insert into public.question_options (id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_874_option_seed;

do $$
declare target_lesson_id uuid;
begin
  select id into strict target_lesson_id from public.lessons
  where topic_id = '32000000-0000-4000-8000-000000000003' and slug = 'vpn-gateway-vs-expressroute';
  if (select count(*) from public.lesson_content_blocks where lesson_id = target_lesson_id and is_published) <> 10
    or (select count(*) from public.visual_experiences where lesson_id = target_lesson_id and is_published) <> 1
    or (select count(*) from public.flashcards where lesson_id = target_lesson_id and is_published) <> 4
    or (select count(*) from public.questions where lesson_id = target_lesson_id and is_published) <> 5 then
    raise exception '8.7.4 final content counts are invalid';
  end if;
  if exists (
    select 1 from public.questions question left join public.question_options option on option.question_id = question.id
    where question.lesson_id = target_lesson_id and question.is_published group by question.id
    having count(option.id) <> 4 or count(option.id) filter (where option.is_correct) <> 1
  ) then raise exception '8.7.4 Question options are invalid'; end if;
  if (select count(*) from public.questions where lesson_id = target_lesson_id and difficulty = 'easy') <> 2
    or (select count(*) from public.questions where lesson_id = target_lesson_id and difficulty = 'medium') <> 2
    or (select count(*) from public.questions where lesson_id = target_lesson_id and difficulty = 'hard') <> 1 then
    raise exception '8.7.4 Question difficulty distribution is invalid';
  end if;
end;
$$;

commit;

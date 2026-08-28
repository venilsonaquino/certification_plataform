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
      and topic.title = 'Networking Services'
      and lesson.slug in ('vnet-peering', 'azure-dns')
  ) <> 2 then
    raise exception '8.7.3 expected exactly two scoped Lessons';
  end if;

  if exists (
    select 1 from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000003'
      and lesson.slug in ('vnet-peering', 'azure-dns')
  ) then
    raise exception 'A scoped 8.7.3 Lesson already contains Content Blocks';
  end if;

  if exists (
    select 1 from public.visual_experiences visual
    join public.lessons lesson on lesson.id = visual.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000003'
      and lesson.slug in ('vnet-peering', 'azure-dns')
  ) then
    raise exception '8.7.3 must not create or replace a scoped Visual Experience';
  end if;

  if (
    select count(*) from public.flashcards card
    join public.lessons lesson on lesson.id = card.lesson_id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000003'
      and lesson.slug in ('vnet-peering', 'azure-dns') and card.is_published
  ) <> 6 then
    raise exception '8.7.3 expected six published historical Flashcards';
  end if;

  if (select count(*) from public.questions where lesson_id = (select id from public.lessons where topic_id = '32000000-0000-4000-8000-000000000003' and slug = 'vnet-peering')) <> 0
    or (select count(*) from public.questions where lesson_id = (select id from public.lessons where topic_id = '32000000-0000-4000-8000-000000000003' and slug = 'azure-dns')) <> 10
    or (select count(*) from public.questions where id between '63000000-0000-4000-8000-000000000091' and '63000000-0000-4000-8000-000000000100') <> 10
    or (select count(*) from public.question_options where question_id between '63000000-0000-4000-8000-000000000091' and '63000000-0000-4000-8000-000000000100') <> 40 then
    raise exception 'Historical Peering/DNS Question inventory is not the audited state';
  end if;
end;
$$;

update public.lessons
set estimated_minutes = 10
where topic_id = '32000000-0000-4000-8000-000000000003'
  and slug in ('vnet-peering', 'azure-dns');

create temporary table stage_873_block_seed (
  id uuid primary key, lesson_slug text not null, type text not null,
  title text, content text, config jsonb, display_order integer not null
) on commit drop;

insert into stage_873_block_seed values
  ('7b0f0000-0000-4000-8000-000000000001','vnet-peering','explanation','O que é VNet Peering?',
   $content$Azure Virtual Network Peering conecta duas ou mais Azure Virtual Networks para permitir comunicação privada entre recursos. O tráfego entre as VNets conectadas usa a infraestrutura de backbone privada da Microsoft, sem precisar ser roteado pela Internet pública.

Cada VNet continua sendo um recurso separado, com seu próprio espaço de endereços e suas próprias configurações. Para fins de conectividade, os recursos podem usar o caminho privado criado pelo peering.$content$,null,1),
  ('7b0f0000-0000-4000-8000-000000000002','vnet-peering','important','Local Peering e Global Peering',
   $content$Virtual Network Peering conecta VNets na mesma Azure Region. Global Virtual Network Peering conecta VNets localizadas em Azure Regions diferentes.

Para o AZ-900, reconheça essa diferença conceitual. Não é necessário memorizar limites, preços ou configurações avançadas de gateway transit, service chaining ou routing.$content$,null,2),
  ('7b0f0000-0000-4000-8000-000000000003','vnet-peering','example','Aplicação e serviços internos em VNets separadas',
   $content$Uma empresa possui a VNet-A para sua aplicação web e a VNet-B para serviços internos. As duas VNets precisam trocar tráfego privado, mas devem continuar como redes separadas.

VNet Peering pode fornecer o caminho privado entre elas pelo backbone da Microsoft. Regras e configurações de rede ainda determinam qual comunicação será efetivamente permitida.$content$,null,3),
  ('7b0f0000-0000-4000-8000-000000000004','vnet-peering','important','Peering e VPN resolvem cenários diferentes',
   $content$VNet Peering: VNet ↔ VNet pela infraestrutura privada da Microsoft.

VPN: Network ↔ túnel criptografado ↔ Network, normalmente sobre conectividade baseada em Internet. VPN Gateway será estudado posteriormente.

Ambos podem conectar redes, mas não são o mesmo mecanismo. O requisito do cenário determina a escolha.$content$,null,4),
  ('7b0f0000-0000-4000-8000-000000000005','vnet-peering','important','Peering não libera todo o tráfego',
   $content$Criar o peering fornece conectividade entre os espaços de endereços das VNets, mas não elimina controles de rede. Regras de segurança, rotas e configurações dos recursos ainda podem permitir ou bloquear tráfego.

Também não transforma as VNets em uma única VNet: elas continuam administrativamente separadas.$content$,null,5),
  ('7b0f0000-0000-4000-8000-000000000006','vnet-peering','exam_trap','Peering não é VPN Gateway nem ExpressRoute',
   $content$VNet Peering não é VPN Gateway, não é ExpressRoute e não representa tráfego pela Internet pública. Peering conecta VNets pelo backbone da Microsoft; VPN e ExpressRoute são opções distintas que serão estudadas em outra etapa.

“Parecem uma rede para conectividade” não significa que os recursos ou as VNets foram fundidos.$content$,null,6),
  ('7b0f0000-0000-4000-8000-000000000007','vnet-peering','exam_tip','Procure duas VNets e comunicação privada',
   $content$Se o cenário apresenta duas VNets Azure que precisam trocar tráfego privado, Peering é uma candidata forte. Mesma Region indica Virtual Network Peering; Regions diferentes indicam Global Virtual Network Peering.$content$,null,7),
  ('7b0f0000-0000-4000-8000-000000000008','vnet-peering','summary','Resumo para memória ativa',null,
   '{"items":["VNet Peering conecta duas ou mais VNets Azure.","O tráfego usa o backbone privado da Microsoft.","As VNets permanecem recursos separados.","Peering local conecta VNets na mesma Region; Global Peering conecta Regions diferentes.","Regras e configurações ainda podem limitar a comunicação.","Peering não é VPN Gateway nem ExpressRoute."]}'::jsonb,8),

  ('7b0f0000-0000-4000-8000-000000000009','azure-dns','explanation','DNS resolve nomes em endereços',
   $content$Domain Name System (DNS) resolve nomes legíveis para endereços IP usados na comunicação de rede. Por exemplo: api.contoso.com → resolução DNS → 20.x.x.x.

O nome DNS e o endereço IP não são a mesma coisa. O registro DNS associa o nome à informação necessária para que o cliente encontre o destino.$content$,null,1),
  ('7b0f0000-0000-4000-8000-000000000010','azure-dns','example','Nome estável, endereço resolvido',
   $content$Usuários acessam www.contoso.com em vez de memorizar o endereço IP do serviço. A resolução DNS retorna o endereço associado ao nome para que a comunicação possa prosseguir.

DNS facilita localizar serviços por nomes; ele não substitui conectividade, autenticação ou controles de segurança.$content$,null,2),
  ('7b0f0000-0000-4000-8000-000000000011','azure-dns','explanation','O que é Azure DNS?',
   $content$Azure DNS fornece hospedagem e resolução DNS usando a infraestrutura do Microsoft Azure. Ele permite administrar zonas e registros DNS com ferramentas e controles do Azure.

Azure DNS inclui opções para nomes públicos e privados. Hospedar uma zona pública não significa que o Azure registra ou vende o nome de domínio.$content$,null,3),
  ('7b0f0000-0000-4000-8000-000000000012','azure-dns','important','Azure Public DNS versus Azure Private DNS',
   $content$Azure Public DNS hospeda zonas e registros usados no contexto público da Internet, como www.contoso.com.

Azure Private DNS resolve nomes privados em Virtual Networks vinculadas, como database.internal.contoso. Os registros privados não são publicados como registros públicos da Internet.

Public e Private DNS tratam contextos de resolução diferentes; “private” não significa apenas esconder um registro público com firewall.$content$,null,4),
  ('7b0f0000-0000-4000-8000-000000000013','azure-dns','example','Escolhendo o contexto de resolução',
   $content$Uma organização quer que clientes da Internet encontrem www.contoso.com: Azure Public DNS pode hospedar os registros públicos.

A mesma organização quer que workloads em uma VNet resolvam database.internal.contoso: Azure Private DNS pode hospedar a zona privada vinculada ao ambiente virtual apropriado.$content$,null,5),
  ('7b0f0000-0000-4000-8000-000000000014','azure-dns','important','Serviço gerenciado, não uma VM obrigatória',
   $content$Usar Azure DNS não exige implantar uma VM executando DNS Server. Azure Public DNS e Azure Private DNS são serviços gerenciados.

Uma arquitetura pode usar outras soluções DNS quando houver requisitos específicos, mas isso não transforma uma VM em requisito padrão do Azure DNS. DNS Private Resolver não será aprofundado nesta Lesson.$content$,null,6),
  ('7b0f0000-0000-4000-8000-000000000015','azure-dns','exam_trap','Não confunda nome, endereço e serviço',
   $content$DNS não é endereço IP: DNS resolve o nome para um endereço ou outro dado de registro. Azure DNS não é obrigatoriamente uma VM com DNS Server. Azure Private DNS não é Azure Public DNS escondido por firewall.

Azure DNS hospeda zonas e registros, mas não atua como registrador para comprar o domínio.$content$,null,7),
  ('7b0f0000-0000-4000-8000-000000000016','azure-dns','exam_tip','Público para Internet; privado para VNets',
   $content$Se o requisito é hospedar registros de um nome acessível no contexto público da Internet, pense em Azure Public DNS. Se nomes internos precisam ser resolvidos em Virtual Networks vinculadas, pense em Azure Private DNS.$content$,null,8),
  ('7b0f0000-0000-4000-8000-000000000017','azure-dns','summary','Resumo para memória ativa',null,
   '{"items":["DNS resolve nomes para endereços usados na comunicação.","Azure DNS fornece hospedagem e resolução DNS na infraestrutura Azure.","Azure Public DNS atende zonas e registros no contexto público.","Azure Private DNS atende resolução privada em Virtual Networks vinculadas.","Azure DNS não exige uma VM executando DNS Server.","Hospedar DNS não é o mesmo que registrar ou comprar um domínio."]}'::jsonb,9);

insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, display_order, is_published
)
select seed.id, lesson.id, seed.type, seed.title, seed.content, seed.config,
  seed.display_order, true
from stage_873_block_seed seed
join public.lessons lesson
  on lesson.topic_id = '32000000-0000-4000-8000-000000000003'
 and lesson.slug = seed.lesson_slug;

create temporary table stage_873_flashcard_update (
  id uuid primary key, front_text text not null, back_text text not null, hint text
) on commit drop;

insert into stage_873_flashcard_update values
  ('72000000-0000-4000-8000-000000000023','Qual é a finalidade do VNet Peering?','Conectar duas ou mais Azure VNets para comunicação privada pelo backbone da Microsoft, mantendo cada VNet como recurso separado.','VNet ↔ VNet.'),
  ('72000000-0000-4000-8000-000000000024','VNet Peering é o mesmo que VPN Gateway?','Não. Peering conecta VNets pelo backbone da Microsoft; VPN usa um mecanismo de túnel criptografado e é uma opção distinta.','Peering não é VPN.'),
  ('72000000-0000-4000-8000-000000000025','Qual é a diferença entre local e Global VNet Peering?','Virtual Network Peering conecta VNets na mesma Azure Region; Global Virtual Network Peering conecta VNets em Regions diferentes.','Mesma Region versus Regions diferentes.'),
  ('72000000-0000-4000-8000-000000000026','Qual é a função básica do DNS?','Resolver nomes legíveis, como api.contoso.com, para endereços usados na comunicação, como um endereço IP.','Nome → resolução → endereço.'),
  ('72000000-0000-4000-8000-000000000027','Qual é a diferença entre Azure Public DNS e Azure Private DNS?','Public DNS hospeda registros no contexto público da Internet; Private DNS resolve nomes privados em Virtual Networks vinculadas.','Internet versus ambiente de VNet.'),
  ('72000000-0000-4000-8000-000000000028','Azure DNS exige uma VM com DNS Server ou registra domínios?','Não. É um serviço gerenciado de hospedagem e resolução DNS; também não atua como registrador para comprar o domínio.','Serviço gerenciado, não registrar.');

update public.flashcards card
set front_text = seed.front_text, back_text = seed.back_text, hint = seed.hint
from stage_873_flashcard_update seed
where card.id = seed.id;

create temporary table stage_873_peering_question_seed (
  id uuid primary key, question_text text not null, difficulty text not null,
  explanation text not null, display_order integer not null
) on commit drop;

insert into stage_873_peering_question_seed values
  ('68000000-0000-4000-8000-000000000030','Qual é a finalidade principal do Azure VNet Peering?','easy','VNet Peering conecta VNets Azure para comunicação privada pelo backbone da Microsoft, mantendo cada VNet como recurso separado.',1),
  ('68000000-0000-4000-8000-000000000031','Qual alternativa diferencia Virtual Network Peering de Global Virtual Network Peering?','easy','O peering local conecta VNets na mesma Azure Region; Global Peering conecta VNets em Azure Regions diferentes.',2),
  ('68000000-0000-4000-8000-000000000032','Uma aplicação na VNet-A precisa acessar serviços internos na VNet-B sem rotear o tráfego pela Internet pública. Qual opção é mais alinhada?','medium','VNet Peering cria conectividade privada entre as VNets usando o backbone da Microsoft.',3),
  ('68000000-0000-4000-8000-000000000033','Qual comparação entre VNet Peering e VPN é conceitualmente correta?','medium','Peering conecta VNets Azure pelo backbone da Microsoft; VPN utiliza um túnel criptografado como mecanismo distinto de conectividade entre redes.',4),
  ('68000000-0000-4000-8000-000000000034','Duas VNets possuem peering, mas uma aplicação não alcança um serviço na outra VNet. Qual análise é mais adequada?','hard','Peering fornece o caminho privado, mas regras, rotas e configurações dos recursos ainda podem limitar o tráfego. As VNets também permanecem separadas.',5);

insert into public.questions (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select seed.id, certification.id, domain.id, topic.id, lesson.id,
  seed.question_text, 'single_choice', seed.difficulty, seed.explanation, true,
  seed.display_order
from stage_873_peering_question_seed seed
join public.certifications certification on certification.code = 'az-900'
join public.domains domain on domain.certification_id = certification.id and domain.title = 'Describe Azure architecture and services'
join public.topics topic on topic.domain_id = domain.id and topic.title = 'Networking Services'
join public.lessons lesson on lesson.topic_id = topic.id and lesson.slug = 'vnet-peering';

create temporary table stage_873_peering_option_seed (
  id uuid primary key, question_id uuid not null, option_text text not null,
  is_correct boolean not null, explanation text not null, display_order integer not null
) on commit drop;

insert into stage_873_peering_option_seed values
  ('7f100000-0000-4000-8000-000000000137','68000000-0000-4000-8000-000000000030','Conectar VNets para comunicação privada pelo backbone da Microsoft.',true,'Correta. Essa é a finalidade fundamental do VNet Peering.',1),
  ('7f100000-0000-4000-8000-000000000138','68000000-0000-4000-8000-000000000030','Transformar várias VNets em um único recurso com um único endereço.',false,'Incorreta. As VNets continuam recursos separados.',2),
  ('7f100000-0000-4000-8000-000000000139','68000000-0000-4000-8000-000000000030','Criar um túnel VPN obrigatório pela Internet pública.',false,'Incorreta. Peering não exige um túnel pela Internet pública.',3),
  ('7f100000-0000-4000-8000-000000000140','68000000-0000-4000-8000-000000000030','Fornecer conectividade dedicada entre uma empresa e a Microsoft.',false,'Incorreta. Isso descreve outro cenário de conectividade, não a finalidade do peering.',4),
  ('7f100000-0000-4000-8000-000000000141','68000000-0000-4000-8000-000000000031','Local conecta VNets na mesma Region; Global conecta VNets em Regions diferentes.',true,'Correta. Essa é a distinção de reconhecimento exigida em Fundamentals.',1),
  ('7f100000-0000-4000-8000-000000000142','68000000-0000-4000-8000-000000000031','Local conecta subnets; Global conecta Resource Groups.',false,'Incorreta. Ambos conectam VNets, não escopos de gerenciamento.',2),
  ('7f100000-0000-4000-8000-000000000143','68000000-0000-4000-8000-000000000031','Local usa Internet pública; Global sempre usa VPN.',false,'Incorreta. O tráfego de peering usa o backbone da Microsoft.',3),
  ('7f100000-0000-4000-8000-000000000144','68000000-0000-4000-8000-000000000031','Não existe diferença relacionada à Region.',false,'Incorreta. A localização das VNets diferencia local e global.',4),
  ('7f100000-0000-4000-8000-000000000145','68000000-0000-4000-8000-000000000032','Configurar VNet Peering entre VNet-A e VNet-B.',true,'Correta. O requisito é conectividade privada VNet a VNet no Azure.',1),
  ('7f100000-0000-4000-8000-000000000146','68000000-0000-4000-8000-000000000032','Publicar os dois serviços com endereços públicos.',false,'Incorreta. Isso não atende ao requisito de evitar o caminho público.',2),
  ('7f100000-0000-4000-8000-000000000147','68000000-0000-4000-8000-000000000032','Mover os recursos para o mesmo Resource Group.',false,'Incorreta. Resource Group não fornece conectividade de rede.',3),
  ('7f100000-0000-4000-8000-000000000148','68000000-0000-4000-8000-000000000032','Criar registros Azure Public DNS para as VNets.',false,'Incorreta. DNS público não conecta os espaços de rede.',4),
  ('7f100000-0000-4000-8000-000000000149','68000000-0000-4000-8000-000000000033','Peering usa o backbone para VNet a VNet; VPN usa um túnel criptografado como mecanismo distinto.',true,'Correta. Os mecanismos podem conectar redes, mas não são equivalentes.',1),
  ('7f100000-0000-4000-8000-000000000150','68000000-0000-4000-8000-000000000033','Peering e VPN Gateway são dois nomes para o mesmo recurso.',false,'Incorreta. São opções distintas de conectividade.',2),
  ('7f100000-0000-4000-8000-000000000151','68000000-0000-4000-8000-000000000033','Peering sempre exige criptografar um túnel pela Internet pública.',false,'Incorreta. O tráfego de peering permanece no backbone da Microsoft.',3),
  ('7f100000-0000-4000-8000-000000000152','68000000-0000-4000-8000-000000000033','VPN só pode conectar VNets na mesma Azure Region.',false,'Incorreta. Essa não é a distinção conceitual entre os mecanismos.',4),
  ('7f100000-0000-4000-8000-000000000153','68000000-0000-4000-8000-000000000034','Verificar regras, rotas e configurações; peering não libera automaticamente todo tráfego.',true,'Correta. O caminho existe, mas controles ainda se aplicam.',1),
  ('7f100000-0000-4000-8000-000000000154','68000000-0000-4000-8000-000000000034','Concluir que Peering nunca permite comunicação privada.',false,'Incorreta. Comunicação privada é justamente uma capacidade do peering.',2),
  ('7f100000-0000-4000-8000-000000000155','68000000-0000-4000-8000-000000000034','Mover as VNets para o mesmo Resource Group para liberar o tráfego.',false,'Incorreta. Resource Group não determina permissão de tráfego.',3),
  ('7f100000-0000-4000-8000-000000000156','68000000-0000-4000-8000-000000000034','Substituir Peering por Azure Public DNS, que libera regras de rede.',false,'Incorreta. DNS resolve nomes e não libera controles de tráfego.',4);

insert into public.question_options (id, question_id, option_text, is_correct, explanation, display_order)
select id, question_id, option_text, is_correct, explanation, display_order from stage_873_peering_option_seed;

create temporary table stage_873_dns_question_update (
  id uuid primary key, question_text text not null, difficulty text not null,
  explanation text not null, display_order integer not null
) on commit drop;

insert into stage_873_dns_question_update values
  ('63000000-0000-4000-8000-000000000091','Qual é a função básica do Domain Name System (DNS)?','easy','DNS resolve nomes legíveis, como api.contoso.com, para endereços usados pelos dispositivos na comunicação de rede.',1),
  ('63000000-0000-4000-8000-000000000092','O que o Azure DNS oferece?','easy','Azure DNS fornece hospedagem e resolução DNS usando a infraestrutura do Azure, incluindo opções públicas e privadas.',2),
  ('63000000-0000-4000-8000-000000000093','Qual cenário é mais alinhado ao Azure Public DNS?','easy','Azure Public DNS hospeda zonas e registros usados para resolução no contexto público da Internet.',3),
  ('63000000-0000-4000-8000-000000000094','Qual cenário é mais alinhado ao Azure Private DNS?','medium','Azure Private DNS resolve nomes privados em Virtual Networks vinculadas sem publicar esses registros como DNS público da Internet.',4),
  ('63000000-0000-4000-8000-000000000095','Qual comparação entre Azure Public DNS e Azure Private DNS está correta?','medium','Public DNS atende o contexto público da Internet; Private DNS atende resolução privada em Virtual Networks vinculadas.',5),
  ('63000000-0000-4000-8000-000000000096','Uma equipe quer resolução DNS privada em uma VNet sem administrar uma VM com DNS Server. Qual opção é mais alinhada?','medium','Azure Private DNS é um serviço gerenciado para resolução de nomes privados em VNets vinculadas e não exige uma VM DNS como requisito padrão.',6),
  ('63000000-0000-4000-8000-000000000097','Uma empresa registrou contoso.com e quer hospedar seus registros públicos no Azure. Qual afirmação é correta?','medium','Azure Public DNS pode hospedar a zona e os registros, mas Azure DNS não atua como registrador para comprar o domínio.',7),
  ('63000000-0000-4000-8000-000000000098','Qual afirmação diferencia corretamente um nome DNS de um endereço IP?','medium','O nome é uma identificação legível; a resolução DNS retorna um endereço ou outro dado de registro usado para localizar o destino.',8),
  ('63000000-0000-4000-8000-000000000099','Uma organização precisa publicar www.contoso.com para clientes da Internet e resolver database.internal.contoso apenas em suas VNets. Qual combinação é mais adequada?','hard','Use Azure Public DNS para os registros públicos e Azure Private DNS para o namespace privado vinculado às VNets apropriadas.',9),
  ('63000000-0000-4000-8000-000000000100','Duas VNets conectadas por Peering precisam acessar uma API por api.internal.contoso. Qual análise separa corretamente conectividade e resolução?','hard','Peering fornece conectividade privada entre as VNets; uma zona Azure Private DNS vinculada conforme necessário fornece a resolução do nome privado. Um mecanismo não substitui automaticamente o outro.',10);

update public.questions question
set question_text = seed.question_text, difficulty = seed.difficulty,
  explanation = seed.explanation, display_order = seed.display_order
from stage_873_dns_question_update seed
where question.id = seed.id;

create temporary table stage_873_dns_option_update (
  id uuid primary key, option_text text not null, is_correct boolean not null,
  explanation text not null, display_order integer not null
) on commit drop;

insert into stage_873_dns_option_update values
  ('74000000-0000-4000-8000-000000000361','Resolver nomes legíveis para endereços usados na comunicação.',true,'Correta. Essa é a função fundamental do DNS.',1),
  ('74000000-0000-4000-8000-000000000362','Atribuir automaticamente endereços públicos a todos os recursos.',false,'Incorreta. DNS resolve nomes; não atribui IPs a todos os recursos.',2),
  ('74000000-0000-4000-8000-000000000363','Criar conectividade privada entre duas VNets.',false,'Incorreta. Essa é uma função de conectividade, como Peering.',3),
  ('74000000-0000-4000-8000-000000000364','Criptografar todo o tráfego entre cliente e servidor.',false,'Incorreta. Resolução DNS não equivale a criptografia de tráfego.',4),
  ('74000000-0000-4000-8000-000000000365','Hospedagem e resolução DNS usando a infraestrutura do Azure.',true,'Correta. Azure DNS oferece serviços públicos e privados de DNS.',1),
  ('74000000-0000-4000-8000-000000000366','Registro e venda obrigatória de nomes de domínio.',false,'Incorreta. Azure DNS não atua como registrador de domínio.',2),
  ('74000000-0000-4000-8000-000000000367','Uma VM obrigatória com DNS Server administrada pelo cliente.',false,'Incorreta. Azure DNS possui opções gerenciadas.',3),
  ('74000000-0000-4000-8000-000000000368','Uma rede virtual que substitui subnets e Peering.',false,'Incorreta. DNS e VNet possuem finalidades diferentes.',4),
  ('74000000-0000-4000-8000-000000000369','Hospedar os registros de www.contoso.com para resolução pública na Internet.',true,'Correta. Esse é um cenário de Azure Public DNS.',1),
  ('74000000-0000-4000-8000-000000000370','Resolver database.internal.contoso somente em VNets vinculadas.',false,'Incorreta. Esse é um cenário de Azure Private DNS.',2),
  ('74000000-0000-4000-8000-000000000371','Conectar duas VNets na mesma Region pelo backbone da Microsoft.',false,'Incorreta. Esse cenário descreve VNet Peering.',3),
  ('74000000-0000-4000-8000-000000000372','Criar um túnel criptografado entre a empresa e o Azure.',false,'Incorreta. Esse é um cenário de VPN, não DNS público.',4),
  ('74000000-0000-4000-8000-000000000373','Resolver database.internal.contoso em Virtual Networks vinculadas.',true,'Correta. Esse é um cenário de Azure Private DNS.',1),
  ('74000000-0000-4000-8000-000000000374','Publicar www.contoso.com para resolução na Internet.',false,'Incorreta. Esse é um cenário de Azure Public DNS.',2),
  ('74000000-0000-4000-8000-000000000375','Registrar e comprar o domínio contoso.com.',false,'Incorreta. Azure DNS não é registrador de domínios.',3),
  ('74000000-0000-4000-8000-000000000376','Substituir a conectividade de rede entre VNets.',false,'Incorreta. DNS resolve nomes e não substitui conectividade.',4),
  ('74000000-0000-4000-8000-000000000377','Public atende resolução pública; Private atende nomes em VNets vinculadas.',true,'Correta. Os serviços atendem contextos diferentes.',1),
  ('74000000-0000-4000-8000-000000000378','Private é apenas Public DNS oculto por firewall.',false,'Incorreta. Azure Private DNS usa zonas privadas vinculadas a VNets.',2),
  ('74000000-0000-4000-8000-000000000379','Public exige VM DNS; Private nunca usa zonas.',false,'Incorreta. Ambos são serviços gerenciados baseados em zonas DNS.',3),
  ('74000000-0000-4000-8000-000000000380','Public conecta VNets; Private cria túneis VPN.',false,'Incorreta. DNS não fornece esses mecanismos de conectividade.',4),
  ('74000000-0000-4000-8000-000000000381','Usar Azure Private DNS e vincular a zona à VNet apropriada.',true,'Correta. O serviço gerenciado resolve os nomes privados.',1),
  ('74000000-0000-4000-8000-000000000382','Implantar obrigatoriamente uma VM DNS para usar Azure Private DNS.',false,'Incorreta. A VM não é um requisito padrão do serviço.',2),
  ('74000000-0000-4000-8000-000000000383','Publicar os nomes internos somente no Azure Public DNS.',false,'Incorreta. Isso colocaria os registros no contexto público.',3),
  ('74000000-0000-4000-8000-000000000384','Usar VNet Peering como substituto da resolução de nomes.',false,'Incorreta. Peering fornece conectividade, não hospedagem DNS.',4),
  ('74000000-0000-4000-8000-000000000385','Azure DNS hospeda os registros; o domínio precisa ser registrado separadamente.',true,'Correta. Hospedagem DNS e registro do domínio são responsabilidades distintas.',1),
  ('74000000-0000-4000-8000-000000000386','Azure DNS compra automaticamente o domínio ao criar a zona.',false,'Incorreta. Criar uma zona não registra nem compra o domínio.',2),
  ('74000000-0000-4000-8000-000000000387','Somente uma VM DNS pode hospedar registros públicos no Azure.',false,'Incorreta. Azure Public DNS é um serviço gerenciado.',3),
  ('74000000-0000-4000-8000-000000000388','O domínio deixa de precisar de registros quando usa Azure DNS.',false,'Incorreta. Registros continuam representando as associações DNS.',4),
  ('74000000-0000-4000-8000-000000000389','O nome é legível; DNS resolve o nome para um endereço ou dado de registro.',true,'Correta. Nome e endereço são conceitos relacionados, mas distintos.',1),
  ('74000000-0000-4000-8000-000000000390','Nome DNS e endereço IP são sempre o mesmo valor.',false,'Incorreta. DNS associa o nome a informações usadas para localizar o destino.',2),
  ('74000000-0000-4000-8000-000000000391','O endereço IP é uma zona DNS privada.',false,'Incorreta. Zona DNS organiza registros; IP identifica um endereço de rede.',3),
  ('74000000-0000-4000-8000-000000000392','DNS converte qualquer endereço IP em uma VNet.',false,'Incorreta. DNS não cria nem converte recursos de rede.',4),
  ('74000000-0000-4000-8000-000000000393','Azure Public DNS para www e Azure Private DNS para database.internal.',true,'Correta. Cada namespace é atendido no contexto apropriado.',1),
  ('74000000-0000-4000-8000-000000000394','Azure Private DNS para ambos, publicando os dois na Internet.',false,'Incorreta. Zonas privadas não publicam registros como DNS público.',2),
  ('74000000-0000-4000-8000-000000000395','Azure Public DNS para ambos e firewall para transformar um deles em privado.',false,'Incorreta. Firewall não transforma Public DNS em Azure Private DNS.',3),
  ('74000000-0000-4000-8000-000000000396','VNet Peering para ambos, sem usar qualquer serviço DNS.',false,'Incorreta. Peering não hospeda nem resolve nomes DNS.',4),
  ('74000000-0000-4000-8000-000000000397','Peering fornece conectividade; Private DNS fornece resolução do nome quando configurado e vinculado.',true,'Correta. Conectividade e resolução são capacidades complementares.',1),
  ('74000000-0000-4000-8000-000000000398','Peering cria automaticamente todos os registros DNS privados.',false,'Incorreta. Peering não cria uma zona nem seus registros DNS.',2),
  ('74000000-0000-4000-8000-000000000399','Private DNS substitui o caminho de rede fornecido pelo Peering.',false,'Incorreta. DNS resolve o nome, mas não fornece a conectividade entre VNets.',3),
  ('74000000-0000-4000-8000-000000000400','Public DNS transforma automaticamente o tráfego entre as VNets em privado.',false,'Incorreta. DNS público não altera o caminho de rede do tráfego.',4);

update public.question_options
set is_correct = false
where question_id between '63000000-0000-4000-8000-000000000091'
  and '63000000-0000-4000-8000-000000000100';

update public.question_options option
set option_text = seed.option_text, is_correct = seed.is_correct,
  explanation = seed.explanation, display_order = seed.display_order
from stage_873_dns_option_update seed
where option.id = seed.id;

do $$
begin
  if exists (
    select 1
    from public.lessons lesson
    left join public.lesson_content_blocks block on block.lesson_id = lesson.id and block.is_published
    where lesson.topic_id = '32000000-0000-4000-8000-000000000003'
      and lesson.slug in ('vnet-peering', 'azure-dns')
    group by lesson.id, lesson.slug
    having count(block.id) <> case lesson.slug when 'vnet-peering' then 8 else 9 end
  ) then raise exception '8.7.3 final block counts are invalid'; end if;

  if exists (
    select 1 from public.lessons lesson
    left join public.questions question on question.lesson_id = lesson.id and question.is_published
    where lesson.topic_id = '32000000-0000-4000-8000-000000000003'
      and lesson.slug in ('vnet-peering', 'azure-dns')
    group by lesson.id, lesson.slug
    having count(question.id) <> case lesson.slug when 'vnet-peering' then 5 else 10 end
  ) then raise exception '8.7.3 final Question counts are invalid'; end if;

  if exists (
    select 1 from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    left join public.question_options option on option.question_id = question.id
    where lesson.topic_id = '32000000-0000-4000-8000-000000000003'
      and lesson.slug in ('vnet-peering', 'azure-dns') and question.is_published
    group by question.id
    having count(option.id) <> 4 or count(option.id) filter (where option.is_correct) <> 1
  ) then raise exception '8.7.3 Question options are invalid'; end if;
end;
$$;

commit;

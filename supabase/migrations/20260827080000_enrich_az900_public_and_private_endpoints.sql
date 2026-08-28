begin;

do $$
declare target_lesson_id uuid;
begin
  select lesson.id into strict target_lesson_id
  from public.lessons lesson join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900' and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Networking Services' and lesson.slug = 'public-vs-private-endpoints';
  if exists (select 1 from public.lesson_content_blocks where lesson_id = target_lesson_id) then
    raise exception 'The Public vs Private Endpoints Lesson already contains Content Blocks';
  end if;
  if exists (select 1 from public.visual_experiences where lesson_id = target_lesson_id)
    or exists (select 1 from public.visual_experiences where id = '76000000-0000-4000-8000-000000000012') then
    raise exception 'The endpoint visual target or planned UUID is already in use';
  end if;
  if (select count(*) from public.flashcards where lesson_id = target_lesson_id and is_published) <> 3
    or exists (select 1 from public.questions where lesson_id = target_lesson_id) then
    raise exception 'Expected three published Flashcards and no Questions before 8.7.5';
  end if;
end; $$;

update public.lessons set estimated_minutes = 12
where topic_id = '32000000-0000-4000-8000-000000000003' and slug = 'public-vs-private-endpoints';

insert into public.visual_experiences (id,lesson_id,type,title,description,config,display_order,is_published)
select '76000000-0000-4000-8000-000000000012',lesson.id,'comparison','Public Endpoint versus Private Endpoint',
  'Compare o endereço e o caminho de acesso a um serviço Azure. Public não significa irrestrito; Private Endpoint não desabilita automaticamente o acesso público.',
  $json$
  {
    "columns":[
      {"id":"public-endpoint","title":"Public Endpoint","description":"Endpoint alcançável por conectividade pública, sujeito aos controles do serviço."},
      {"id":"private-endpoint","title":"Private Endpoint","description":"Interface na VNet/subnet com IP privado para um recurso compatível com Private Link."}
    ],
    "rows":[
      {"id":"path","label":"Caminho conceitual","values":{"public-endpoint":"Aplicação → rede pública → public endpoint → serviço Azure","private-endpoint":"Aplicação → VNet → IP privado → private endpoint → Private Link → serviço Azure"}},
      {"id":"address","label":"Endereço","values":{"public-endpoint":"Nome DNS e/ou endereço público","private-endpoint":"IP privado da VNet"}},
      {"id":"vnet","label":"VNet necessária","values":{"public-endpoint":"Não necessariamente","private-endpoint":"Sim, associado a uma subnet"}},
      {"id":"internet","label":"Internet pública","values":{"public-endpoint":"Pode fazer parte do caminho","private-endpoint":"Não é o caminho do Private Link"}},
      {"id":"public-access","label":"Exposição pública","values":{"public-endpoint":"Possível, com controles ainda aplicáveis","private-endpoint":"Pode ser evitada, mas exige configurar o acesso público separadamente"}},
      {"id":"use","label":"Uso comum","values":{"public-endpoint":"Serviço acessível por conectividade pública","private-endpoint":"Recurso específico acessível privadamente por IP da VNet"}}
    ]
  }
  $json$::jsonb,1,true
from public.lessons lesson where lesson.topic_id = '32000000-0000-4000-8000-000000000003'
  and lesson.slug = 'public-vs-private-endpoints';

create temporary table stage_875_block_seed (
  id uuid primary key,type text not null,title text,content text,config jsonb,
  visual_experience_id uuid,display_order integer not null
) on commit drop;

insert into stage_875_block_seed values
  ('7b110000-0000-4000-8000-000000000001','explanation','O que é um Public Endpoint?',
   $content$Public Endpoint permite acessar um serviço por conectividade pública. Normalmente o cliente usa um nome DNS público e/ou endereço publicamente roteável para alcançar o endpoint do serviço.

“Public” descreve o caminho ou alcance de rede. Não significa que qualquer pessoa está automaticamente autenticada ou autorizada.$content$,null,null,1),
  ('7b110000-0000-4000-8000-000000000002','important','Público não significa sem segurança',
   $content$Um serviço com Public Endpoint ainda pode exigir autenticação e autorização e aplicar firewall, listas de endereços permitidos e outras regras de rede suportadas.

Endpoint acessível publicamente não é sinônimo de acesso irrestrito. A segurança resulta do conjunto de controles e configurações.$content$,null,null,2),
  ('7b110000-0000-4000-8000-000000000003','explanation','O que é um Private Endpoint?',
   $content$Private Endpoint é uma network interface associada a uma subnet de uma VNet. Ela recebe um IP privado dessa VNet e conecta o cliente privadamente a um recurso ou subresource compatível com Azure Private Link.

O tráfego para o recurso pode permanecer no backbone da Microsoft, reduzindo a dependência de exposição pela Internet pública.$content$,null,null,3),
  ('7b110000-0000-4000-8000-000000000004','important','Private Link e Private Endpoint',
   $content$Azure Private Link é a tecnologia que permite acesso privado a serviços compatíveis. Private Endpoint é a interface com IP privado criada na VNet do consumidor para acessar um recurso específico por essa tecnologia.

Private Endpoint não representa todo o Azure Private Link e não é VPN Gateway.$content$,null,null,4),
  ('7b110000-0000-4000-8000-000000000005','important','Private Endpoint e acesso público podem coexistir',
   $content$Criar um Private Endpoint não desabilita necessariamente o Public Endpoint do serviço. Dependendo do serviço e da configuração, acesso público e privado podem coexistir.

Para exigir acesso somente privado, normalmente também é necessário bloquear ou desabilitar o acesso público do recurso quando essa opção for suportada.$content$,null,null,5),
  ('7b110000-0000-4000-8000-000000000006','important','Private Endpoint versus Service Endpoint',
   $content$Em nível Fundamentals, Service Endpoint permite restringir/otimizar o acesso de uma subnet a serviços Azure suportados, enquanto o serviço continua sendo alcançado por seu endpoint público.

Private Endpoint cria uma interface com IP privado na VNet para o recurso ou subresource específico. Service Endpoint não cria esse IP privado para o recurso.$content$,null,null,6),
  ('7b110000-0000-4000-8000-000000000007','dotnet_example','API ASP.NET Core acessando Azure SQL',
   $content$Com Public Endpoint, uma API ASP.NET Core pode acessar o hostname público do Azure SQL, sujeito a firewall, autenticação e demais controles.

Com Private Endpoint, a equipe cria uma interface privada para o Azure SQL em uma subnet. A aplicação continua usando o hostname apropriado, enquanto a resolução configurada no ambiente retorna o IP privado. Configuração detalhada de Private DNS fica fora desta Lesson.$content$,null,null,7),
  ('7b110000-0000-4000-8000-000000000008','visual_experience','Public Endpoint versus Private Endpoint',null,null,
   '76000000-0000-4000-8000-000000000012',8),
  ('7b110000-0000-4000-8000-000000000009','exam_trap','Evite três conclusões automáticas',
   $content$Public Endpoint não significa serviço sem segurança nem usuário automaticamente autorizado. Private Endpoint não é todo o Private Link nem VPN Gateway. Criar um Private Endpoint não remove automaticamente o Public Endpoint.

Service Endpoint e Private Endpoint também não são sinônimos: o primeiro mantém o endpoint público do serviço; o segundo fornece IP privado na VNet para o recurso.$content$,null,null,9),
  ('7b110000-0000-4000-8000-000000000010','exam_tip','Procure o tipo de endereço e caminho',
   $content$Se o cenário exige acesso direto por conectividade pública, procure Public Endpoint e verifique os controles. Se exige que um recurso Azure compatível seja alcançado por IP privado da VNet, procure Private Endpoint/Private Link.$content$,null,null,10),
  ('7b110000-0000-4000-8000-000000000011','summary','Resumo para memória ativa',null,
   '{"items":["Public Endpoint usa conectividade pública, mas controles ainda podem limitar o acesso.","Private Endpoint é uma interface em subnet com IP privado da VNet.","Azure Private Link fornece o mecanismo; Private Endpoint é o ponto de acesso privado.","Private Endpoint é específico para um recurso ou subresource suportado.","Public e Private Endpoints podem coexistir conforme serviço e configuração.","Service Endpoint mantém o endpoint público; Private Endpoint cria um IP privado para o recurso."]}'::jsonb,null,11);

insert into public.lesson_content_blocks (id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.visual_experience_id,seed.display_order,true
from stage_875_block_seed seed join public.lessons lesson
  on lesson.topic_id = '32000000-0000-4000-8000-000000000003' and lesson.slug = 'public-vs-private-endpoints';

create temporary table stage_875_flashcard_update (
  id uuid primary key,front_text text not null,back_text text not null,hint text
) on commit drop;
insert into stage_875_flashcard_update values
  ('72000000-0000-4000-8000-000000000033','O que caracteriza um Public Endpoint?','Permite alcançar um serviço por conectividade pública, normalmente por nome DNS e/ou endereço público, sujeito a autenticação, firewall e regras aplicáveis.','Público não significa irrestrito.'),
  ('72000000-0000-4000-8000-000000000034','O que é um Private Endpoint?','É uma network interface em uma subnet que recebe IP privado da VNet para acessar um recurso compatível com Azure Private Link.','Interface e IP privado.'),
  ('72000000-0000-4000-8000-000000000035','Criar um Private Endpoint desabilita automaticamente o acesso público?','Não necessariamente. Public e Private Endpoints podem coexistir; o acesso público deve ser bloqueado separadamente quando suportado e exigido.','Coexistência é possível.');
update public.flashcards card set front_text=seed.front_text,back_text=seed.back_text,hint=seed.hint
from stage_875_flashcard_update seed where card.id=seed.id;

create temporary table stage_875_flashcard_seed (
  id uuid primary key,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_875_flashcard_seed values
  ('7e200000-0000-4000-8000-000000000001','Qual é a relação entre Azure Private Link e Private Endpoint?','Private Link é a tecnologia de acesso privado; Private Endpoint é a interface com IP privado usada pelo cliente para acessar o recurso.','Mecanismo versus interface.',4),
  ('7e200000-0000-4000-8000-000000000002','Qual é a diferença básica entre Service Endpoint e Private Endpoint?','Service Endpoint mantém o endpoint público do serviço; Private Endpoint cria um IP privado na VNet para o recurso específico.','Endpoint público versus IP privado.',5);
insert into public.flashcards (id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_875_flashcard_seed seed join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000003' and lesson.slug='public-vs-private-endpoints';

create temporary table stage_875_question_seed (
  id uuid primary key,question_text text not null,difficulty text not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_875_question_seed values
  ('68000000-0000-4000-8000-000000000040','Qual afirmação sobre Public Endpoint está correta?','easy','Public Endpoint permite acesso por conectividade pública, mas autenticação, firewall e regras de rede ainda podem limitar o acesso.',1),
  ('68000000-0000-4000-8000-000000000041','O que um Azure Private Endpoint cria na rede do consumidor?','easy','Ele cria uma network interface em uma subnet com um IP privado da VNet para alcançar um recurso compatível com Private Link.',2),
  ('68000000-0000-4000-8000-000000000042','Uma API precisa acessar Azure SQL usando um IP privado de sua VNet. Qual opção é mais alinhada?','medium','Private Endpoint fornece uma interface com IP privado na subnet para acessar o recurso Azure SQL por Azure Private Link.',3),
  ('68000000-0000-4000-8000-000000000043','Qual comparação entre Service Endpoint e Private Endpoint está correta em Fundamentals?','medium','Service Endpoint mantém o endpoint público do serviço; Private Endpoint fornece um IP privado na VNet para o recurso específico.',4),
  ('68000000-0000-4000-8000-000000000044','Uma equipe criou um Private Endpoint para um serviço Azure. Ela pode concluir que o acesso público foi removido?','hard','Não necessariamente. Private Endpoint e acesso público podem coexistir; o recurso também precisa ser configurado para bloquear acesso público quando suportado e exigido.',5);
insert into public.questions (id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_875_question_seed seed join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure architecture and services'
join public.topics topic on topic.domain_id=domain.id and topic.title='Networking Services'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug='public-vs-private-endpoints';

create temporary table stage_875_option_seed (
  id uuid primary key,question_id uuid not null,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_875_option_seed values
  ('7f100000-0000-4000-8000-000000000177','68000000-0000-4000-8000-000000000040','Ele usa conectividade pública, mas controles ainda podem restringir o acesso.',true,'Correta. Público descreve o caminho, não autorização irrestrita.',1),
  ('7f100000-0000-4000-8000-000000000178','68000000-0000-4000-8000-000000000040','Ele autoriza automaticamente qualquer pessoa na Internet.',false,'Incorreta. Autenticação, autorização e regras continuam aplicáveis.',2),
  ('7f100000-0000-4000-8000-000000000179','68000000-0000-4000-8000-000000000040','Ele exige sempre uma VNet e um IP privado.',false,'Incorreta. Essas características descrevem Private Endpoint.',3),
  ('7f100000-0000-4000-8000-000000000180','68000000-0000-4000-8000-000000000040','Ele substitui autenticação e firewall do serviço.',false,'Incorreta. O endpoint não substitui controles de segurança.',4),
  ('7f100000-0000-4000-8000-000000000181','68000000-0000-4000-8000-000000000041','Uma network interface em uma subnet com IP privado da VNet.',true,'Correta. Essa interface representa o Private Endpoint.',1),
  ('7f100000-0000-4000-8000-000000000182','68000000-0000-4000-8000-000000000041','Um novo endereço público para qualquer serviço Azure.',false,'Incorreta. Private Endpoint usa IP privado e recurso suportado.',2),
  ('7f100000-0000-4000-8000-000000000183','68000000-0000-4000-8000-000000000041','Um túnel VPN obrigatório para toda a VNet.',false,'Incorreta. Private Endpoint não é VPN Gateway.',3),
  ('7f100000-0000-4000-8000-000000000184','68000000-0000-4000-8000-000000000041','Uma zona DNS pública que elimina a subnet.',false,'Incorreta. DNS e Private Endpoint têm papéis diferentes.',4),
  ('7f100000-0000-4000-8000-000000000185','68000000-0000-4000-8000-000000000042','Criar um Private Endpoint para o recurso Azure SQL na subnet apropriada.',true,'Correta. Ele fornece o IP privado para o recurso suportado.',1),
  ('7f100000-0000-4000-8000-000000000186','68000000-0000-4000-8000-000000000042','Usar somente o Public Endpoint sem regras adicionais.',false,'Incorreta. Isso não atende ao requisito explícito de IP privado.',2),
  ('7f100000-0000-4000-8000-000000000187','68000000-0000-4000-8000-000000000042','Criar VNet Peering sem configurar acesso ao Azure SQL.',false,'Incorreta. Peering conecta VNets, mas não cria o endpoint privado do recurso.',3),
  ('7f100000-0000-4000-8000-000000000188','68000000-0000-4000-8000-000000000042','Criar Azure Public DNS para transformar o SQL em privado.',false,'Incorreta. DNS público não cria um caminho privado.',4),
  ('7f100000-0000-4000-8000-000000000189','68000000-0000-4000-8000-000000000043','Service Endpoint usa o endpoint público; Private Endpoint cria IP privado para o recurso.',true,'Correta. Essa é a distinção de reconhecimento em Fundamentals.',1),
  ('7f100000-0000-4000-8000-000000000190','68000000-0000-4000-8000-000000000043','Ambos criam uma network interface privada para o recurso.',false,'Incorreta. Service Endpoint não cria a NIC privada do recurso.',2),
  ('7f100000-0000-4000-8000-000000000191','68000000-0000-4000-8000-000000000043','Service Endpoint é outro nome para Private Link.',false,'Incorreta. São mecanismos distintos.',3),
  ('7f100000-0000-4000-8000-000000000192','68000000-0000-4000-8000-000000000043','Private Endpoint sempre publica o recurso na Internet.',false,'Incorreta. Ele oferece acesso por IP privado.',4),
  ('7f100000-0000-4000-8000-000000000193','68000000-0000-4000-8000-000000000044','Não. O acesso público pode coexistir e deve ser configurado separadamente.',true,'Correta. Criar o Private Endpoint não remove necessariamente o público.',1),
  ('7f100000-0000-4000-8000-000000000194','68000000-0000-4000-8000-000000000044','Sim. Azure sempre exclui o Public Endpoint automaticamente.',false,'Incorreta. O comportamento depende do serviço e da configuração.',2),
  ('7f100000-0000-4000-8000-000000000195','68000000-0000-4000-8000-000000000044','Sim. Private Link impede qualquer configuração pública coexistente.',false,'Incorreta. Acesso público e privado podem coexistir.',3),
  ('7f100000-0000-4000-8000-000000000196','68000000-0000-4000-8000-000000000044','Não, porque Private Endpoint funciona apenas como Public DNS.',false,'Incorreta. Private Endpoint é uma interface com IP privado.',4);
insert into public.question_options (id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_875_option_seed;

do $$ declare target_lesson_id uuid;
begin
  select id into strict target_lesson_id from public.lessons where topic_id='32000000-0000-4000-8000-000000000003' and slug='public-vs-private-endpoints';
  if (select count(*) from public.lesson_content_blocks where lesson_id=target_lesson_id and is_published)<>11
    or (select count(*) from public.visual_experiences where lesson_id=target_lesson_id and is_published)<>1
    or (select count(*) from public.flashcards where lesson_id=target_lesson_id and is_published)<>5
    or (select count(*) from public.questions where lesson_id=target_lesson_id and is_published)<>5 then
    raise exception '8.7.5 final content counts are invalid'; end if;
  if exists (select 1 from public.questions question left join public.question_options option on option.question_id=question.id
    where question.lesson_id=target_lesson_id and question.is_published group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1) then
    raise exception '8.7.5 Question options are invalid'; end if;
  if (select count(*) from public.questions where lesson_id=target_lesson_id and difficulty='easy')<>2
    or (select count(*) from public.questions where lesson_id=target_lesson_id and difficulty='medium')<>2
    or (select count(*) from public.questions where lesson_id=target_lesson_id and difficulty='hard')<>1 then
    raise exception '8.7.5 difficulty distribution is invalid'; end if;
end; $$;

commit;

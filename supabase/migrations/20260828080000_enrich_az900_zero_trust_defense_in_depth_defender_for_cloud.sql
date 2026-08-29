begin;

do $$
declare target_count integer;
begin
  select count(*) into target_count
  from public.lessons lesson
  join public.topics topic on topic.id=lesson.topic_id
  join public.domains domain on domain.id=topic.domain_id
  join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900' and domain.title='Describe Azure architecture and services'
    and topic.id='32000000-0000-4000-8000-000000000005' and topic.title='Identity, Access and Security'
    and lesson.slug in ('zero-trust-and-defense-in-depth','defender-for-cloud');
  if target_count<>2 then raise exception '8.9.5 expected two existing target Lessons'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000005'
      and lesson.slug in ('zero-trust-and-defense-in-depth','defender-for-cloud')) then
    raise exception '8.9.5 expected target Lessons without Content Blocks';
  end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000005'
      and lesson.slug in ('zero-trust-and-defense-in-depth','defender-for-cloud'))
    or exists(select 1 from public.visual_experiences where id='76000000-0000-4000-8000-000000000015') then
    raise exception '8.9.5 Visual Experience preconditions are invalid';
  end if;
  if exists(select 1 from public.lessons lesson
    where lesson.topic_id='32000000-0000-4000-8000-000000000005'
      and lesson.slug in ('zero-trust-and-defense-in-depth','defender-for-cloud')
      and (exists(select 1 from public.flashcards where lesson_id=lesson.id)
        or exists(select 1 from public.questions where lesson_id=lesson.id))) then
    raise exception '8.9.5 expected target Lessons without existing practice';
  end if;
end; $$;

update public.lessons
set estimated_minutes=case slug when 'zero-trust-and-defense-in-depth' then 14 else 12 end
where topic_id='32000000-0000-4000-8000-000000000005'
  and slug in ('zero-trust-and-defense-in-depth','defender-for-cloud');

insert into public.visual_experiences(id,lesson_id,type,title,description,config,display_order,is_published)
select '76000000-0000-4000-8000-000000000015',lesson.id,'architecture',
  'Camadas de Defense in Depth',
  'Selecione uma camada para entender como controles complementares protegem o ativo central.',
  $json$
  {
    "nodes": [
      {"id":"physical","label":"Physical","kind":"external","description":"Proteção física de datacenters, instalações, hardware e acesso ao local.","x":50,"y":8},
      {"id":"identity-access","label":"Identity & Access","kind":"service","description":"Autenticação, autorização e controle de acesso para pessoas e workloads.","x":50,"y":22},
      {"id":"perimeter","label":"Perimeter","kind":"zone","description":"Controles na entrada do ambiente ajudam a filtrar e responder a tráfego indesejado.","x":50,"y":36},
      {"id":"network","label":"Network","kind":"group","description":"Segmentação e controles de tráfego reduzem comunicação e movimentação não autorizadas.","x":50,"y":50},
      {"id":"compute","label":"Compute","kind":"resource","description":"Proteções para máquinas virtuais, containers e outros workloads de computação.","x":50,"y":64},
      {"id":"application","label":"Application","kind":"service","description":"Controles no software, nas APIs, nas dependências e no ciclo de desenvolvimento.","x":50,"y":78},
      {"id":"data","label":"Data","kind":"resource","description":"Proteção da informação armazenada, transmitida e processada, o ativo central.","x":50,"y":92}
    ],
    "edges": [
      {"id":"physical-identity","source":"physical","target":"identity-access","label":"camada seguinte"},
      {"id":"identity-perimeter","source":"identity-access","target":"perimeter","label":"camada seguinte"},
      {"id":"perimeter-network","source":"perimeter","target":"network","label":"camada seguinte"},
      {"id":"network-compute","source":"network","target":"compute","label":"camada seguinte"},
      {"id":"compute-application","source":"compute","target":"application","label":"camada seguinte"},
      {"id":"application-data","source":"application","target":"data","label":"protege"}
    ]
  }
  $json$::jsonb,1,true
from public.lessons lesson
where lesson.topic_id='32000000-0000-4000-8000-000000000005'
  and lesson.slug='zero-trust-and-defense-in-depth';

create temporary table stage_895_block_seed(
  id uuid primary key,lesson_slug text not null,type text not null,title text,content text,config jsonb,
  visual_experience_id uuid,display_order integer not null
) on commit drop;
insert into stage_895_block_seed values
('7b190000-0000-4000-8000-000000000001','zero-trust-and-defense-in-depth','explanation','Zero Trust é uma estratégia de segurança',
$content$Zero Trust é uma estratégia e um modelo de segurança. Não é um produto Azure nem um serviço Microsoft específico.

Sua ideia central é substituir confiança implícita por verificação explícita. Estar dentro da rede corporativa não torna automaticamente confiáveis um usuário, dispositivo, workload ou solicitação.$content$,null,null,1),
('7b190000-0000-4000-8000-000000000002','zero-trust-and-defense-in-depth','important','Never trust, always verify no contexto correto',
$content$“Never trust, always verify” não significa desconfiar de todas as pessoas ou bloquear todo acesso. Significa não conceder confiança automaticamente com base apenas em localização de rede ou em uma validação anterior.

O acesso deve ser explicitamente verificado, limitado e reavaliado conforme os sinais e o contexto disponíveis.$content$,null,null,2),
('7b190000-0000-4000-8000-000000000003','zero-trust-and-defense-in-depth','explanation','Princípio 1 — Verify explicitly',
$content$Autentique e autorize usando os sinais e o contexto disponíveis, como identidade, dispositivo, localização, recurso solicitado e risco quando aplicável.

A decisão deve considerar a solicitação atual; a origem interna, sozinha, não comprova que o acesso é seguro.$content$,null,null,3),
('7b190000-0000-4000-8000-000000000004','zero-trust-and-defense-in-depth','explanation','Princípio 2 — Use least privilege access',
$content$Conceda somente o acesso necessário, pelo tempo e no escopo necessários.

Least privilege limita a exposição e o impacto potencial de uma identidade comprometida. Ele não significa negar toda permissão, mas evitar privilégios e alcance maiores que o requisito.$content$,null,null,4),
('7b190000-0000-4000-8000-000000000005','zero-trust-and-defense-in-depth','explanation','Princípio 3 — Assume breach',
$content$Projete controles assumindo que uma violação pode acontecer ou já pode existir no ambiente.

O objetivo é reduzir o alcance de um incidente, dificultar movimento não autorizado, melhorar visibilidade e permitir detecção e resposta — não declarar que todo usuário já é um invasor.$content$,null,null,5),
('7b190000-0000-4000-8000-000000000006','zero-trust-and-defense-in-depth','example','Vários serviços contribuem para Zero Trust',
$content$User → Microsoft Entra ID → Conditional Access → MFA quando necessário → Azure RBAC / Least Privilege → Azure Resource.

Entra ID ajuda a verificar a identidade, Conditional Access avalia contexto, MFA pode reforçar a autenticação e RBAC limita ações e scope. Nenhum desses recursos, isoladamente, “é” Zero Trust; juntos podem apoiar a estratégia.$content$,null,null,6),
('7b190000-0000-4000-8000-000000000007','zero-trust-and-defense-in-depth','exam_trap','Zero Trust não é bloqueio, firewall ou produto',
$content$Zero Trust não significa bloquear todo acesso, não é sinônimo de firewall e não é um produto Microsoft específico.

Na prova, procure uma estratégia baseada em verify explicitly, least privilege e assume breach.$content$,null,null,7),
('7b190000-0000-4000-8000-000000000008','zero-trust-and-defense-in-depth','explanation','O que é Defense in Depth?',
$content$Defense in Depth é a estratégia de usar múltiplas camadas de proteção. Se uma camada falhar ou for contornada, outras continuam oferecendo controles complementares.

O valor está em não depender de uma única barreira. Nenhuma quantidade de camadas garante ausência de incidentes.$content$,null,null,8),
('7b190000-0000-4000-8000-000000000009','zero-trust-and-defense-in-depth','important','Camadas conceituais, não uma receita rígida',
$content$Uma representação comum inclui Physical, Identity and Access, Perimeter, Network, Compute, Application e Data.

Essas camadas ajudam a raciocinar sobre proteção, mas não impõem uma sequência única de produtos ou uma arquitetura obrigatória para toda organização.$content$,null,null,9),
('7b190000-0000-4000-8000-000000000010','zero-trust-and-defense-in-depth','visual_experience','Explore as camadas de proteção',null,null,
'76000000-0000-4000-8000-000000000015',10),
('7b190000-0000-4000-8000-000000000011','zero-trust-and-defense-in-depth','example','Controles complementares protegem os dados',
$content$Uma aplicação pode combinar segurança física do datacenter, controle de identidade, filtragem de entrada, segmentação de rede, proteção do workload, validações na aplicação e proteção dos dados.

Uma falha em um controle de perímetro, por exemplo, não deveria remover automaticamente os controles de identidade, aplicação e dados.$content$,null,null,11),
('7b190000-0000-4000-8000-000000000012','zero-trust-and-defense-in-depth','important','Zero Trust versus Defense in Depth',
$content$| Estratégia | Pergunta principal | Foco |
| --- | --- | --- |
| Zero Trust | Devemos confiar automaticamente nesta solicitação? | Verificar explicitamente, limitar privilégio e assumir violação. |
| Defense in Depth | Quais proteções permanecem se um controle falhar? | Múltiplas camadas independentes ou complementares. |

As estratégias são diferentes e podem ser utilizadas juntas.$content$,null,null,12),
('7b190000-0000-4000-8000-000000000013','zero-trust-and-defense-in-depth','exam_trap','Confiança e acesso versus múltiplas camadas',
$content$Zero Trust orienta decisões de confiança e acesso. Defense in Depth organiza proteção em múltiplas camadas.

“Verificar uma solicitação interna e limitar seu acesso” aponta para Zero Trust. “Manter outras proteções quando uma camada falhar” aponta para Defense in Depth.$content$,null,null,13),
('7b190000-0000-4000-8000-000000000014','zero-trust-and-defense-in-depth','exam_tip','Identifique o verbo do cenário',
$content$Cenários com verificar, limitar acesso ou assumir comprometimento apontam para princípios de Zero Trust. Cenários com sobreposição, redundância de controles ou várias camadas apontam para Defense in Depth.$content$,null,null,14),
('7b190000-0000-4000-8000-000000000015','zero-trust-and-defense-in-depth','summary','Resumo para memória ativa',null,
'{"items":["Zero Trust é uma estratégia, não um produto.","Seus princípios são verify explicitly, use least privilege access e assume breach.","Localização interna não gera confiança automática.","Defense in Depth usa múltiplas camadas de proteção.","As camadas são conceituais, não uma receita rígida.","Zero Trust e Defense in Depth são diferentes e podem trabalhar juntos."]}'::jsonb,null,15),

('7b190000-0000-4000-8000-000000000016','defender-for-cloud','explanation','O que é Microsoft Defender for Cloud?',
$content$Microsoft Defender for Cloud é um serviço de segurança que ajuda organizações a avaliar e melhorar a postura de segurança de ambientes cloud e a proteger workloads contra ameaças conforme as capacidades e os planos habilitados.

Em AZ-900, reconheça duas ideias: security posture e workload protection.$content$,null,null,1),
('7b190000-0000-4000-8000-000000000017','defender-for-cloud','important','Dois focos em nível Fundamentals',
$content$**Security posture:** avaliar configurações e apresentar achados, recomendações e secure score para orientar melhorias.

**Workload protection:** ajudar a detectar e proteger workloads contra ameaças conforme os recursos habilitados.

Os focos se complementam, mas não são sinônimos.$content$,null,null,2),
('7b190000-0000-4000-8000-000000000018','defender-for-cloud','explanation','Security posture, recomendações e secure score',
$content$Defender for Cloud avalia recursos e configurações em relação a padrões de segurança e gera recomendações acionáveis para melhorar a postura.

Secure score resume achados de postura em uma medida que ajuda a acompanhar e priorizar melhorias. Ele não é uma garantia de que o ambiente está invulnerável.$content$,null,null,3),
('7b190000-0000-4000-8000-000000000019','defender-for-cloud','example','Configuração que pode ser melhorada',
$content$Uma equipe recebe uma recomendação indicando exposição desnecessária em um recurso. Ela analisa o contexto e corrige a configuração para melhorar a postura de segurança.

O serviço ajuda a identificar e priorizar a melhoria; a organização continua responsável por avaliar e executar a resposta apropriada.$content$,null,null,4),
('7b190000-0000-4000-8000-000000000020','defender-for-cloud','explanation','Workload protection',
$content$Workload protection ajuda a detectar e responder a ameaças que afetam workloads como servidores, containers, armazenamento, bancos de dados e funções, dependendo das capacidades habilitadas.

Não é necessário memorizar planos, arquitetura CNAPP, CSPM ou CWPP para este objetivo de Fundamentals.$content$,null,null,5),
('7b190000-0000-4000-8000-000000000021','defender-for-cloud','example','Postura e proteção no mesmo serviço',
$content$Defender for Cloud pode recomendar a correção de uma configuração insegura e também, com proteção apropriada habilitada, gerar alertas relacionados a ameaças em workloads.

A recomendação trata de postura; a detecção de ameaça exemplifica workload protection.$content$,null,null,6),
('7b190000-0000-4000-8000-000000000022','defender-for-cloud','important','Serviço não elimina responsabilidade',
$content$Defender for Cloud fornece avaliações, recomendações e capacidades de proteção, mas não torna o ambiente automaticamente seguro.

O cliente precisa revisar achados, habilitar capacidades adequadas e responder conforme sua responsabilidade compartilhada.$content$,null,null,7),
('7b190000-0000-4000-8000-000000000023','defender-for-cloud','exam_trap','Defender for Cloud não é um simples antivírus',
$content$Microsoft Defender for Cloud não é sinônimo de Microsoft Defender Antivirus. Seu escopo inclui postura de segurança e proteção de workloads cloud, não apenas verificação antimalware em um dispositivo.$content$,null,null,8),
('7b190000-0000-4000-8000-000000000024','defender-for-cloud','exam_trap','Defender for Cloud não é Microsoft Sentinel',
$content$Defender for Cloud ajuda com security posture, recomendações e workload protection. Microsoft Sentinel é outro serviço, voltado a SIEM/SOAR.

Para esta Lesson, basta reconhecer que os produtos não são equivalentes; detalhes de Sentinel ficam fora do escopo.$content$,null,null,9),
('7b190000-0000-4000-8000-000000000025','defender-for-cloud','exam_tip','Procure postura e proteção de workloads',
$content$Questões que pedem recomendações, secure score ou avaliação da postura cloud apontam para Defender for Cloud. Cenários de proteção contra ameaças em workloads também podem apontar para o serviço, conforme capacidades habilitadas.$content$,null,null,10),
('7b190000-0000-4000-8000-000000000026','defender-for-cloud','summary','Resumo para memória ativa',null,
'{"items":["Defender for Cloud ajuda a melhorar a postura e proteger workloads.","Recomendações orientam correções de configurações e riscos encontrados.","Secure score ajuda a resumir e acompanhar a postura.","Workload protection depende das capacidades e planos habilitados.","Defender for Cloud não é apenas antivírus nem é Microsoft Sentinel.","O serviço não elimina a responsabilidade do cliente."]}'::jsonb,null,11);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.visual_experience_id,seed.display_order,true
from stage_895_block_seed seed join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug=seed.lesson_slug;

create temporary table stage_895_flashcard_seed(
  id uuid primary key,lesson_slug text not null,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_895_flashcard_seed values
('7e400000-0000-4000-8000-000000000029','zero-trust-and-defense-in-depth','O que é Zero Trust?','Uma estratégia de segurança que substitui confiança implícita por verificação explícita.','Não é um produto.',1),
('7e400000-0000-4000-8000-000000000030','zero-trust-and-defense-in-depth','Quais são os três princípios de Zero Trust?','Verify explicitly, use least privilege access e assume breach.','Verificar, limitar, assumir.',2),
('7e400000-0000-4000-8000-000000000031','zero-trust-and-defense-in-depth','O que significa verify explicitly?','Autenticar e autorizar usando os sinais e o contexto disponíveis.','Sem confiança automática.',3),
('7e400000-0000-4000-8000-000000000032','zero-trust-and-defense-in-depth','O que significa least privilege?','Conceder somente o acesso necessário, pelo tempo e escopo necessários.','Menor privilégio.',4),
('7e400000-0000-4000-8000-000000000033','zero-trust-and-defense-in-depth','O que significa assume breach?','Projetar controles esperando que uma violação possa acontecer ou já existir.','Limitar impacto.',5),
('7e400000-0000-4000-8000-000000000034','zero-trust-and-defense-in-depth','O que é Defense in Depth?','Uma estratégia que usa múltiplas camadas de proteção.','Uma camada pode falhar.',6),
('7e400000-0000-4000-8000-000000000035','zero-trust-and-defense-in-depth','Zero Trust e Defense in Depth são o mesmo conceito?','Não. Zero Trust orienta confiança e acesso; Defense in Depth usa múltiplas camadas.','Podem trabalhar juntos.',7),
('7e400000-0000-4000-8000-000000000036','defender-for-cloud','Quais são os dois focos de Defender for Cloud em Fundamentals?','Security posture e workload protection.','Postura + proteção.',1),
('7e400000-0000-4000-8000-000000000037','defender-for-cloud','Como recomendações ajudam a postura de segurança?','Indicam achados e ações para melhorar configurações e reduzir riscos.','Orientação acionável.',2),
('7e400000-0000-4000-8000-000000000038','defender-for-cloud','Para que serve secure score no Defender for Cloud?','Para resumir e acompanhar a postura com base em achados e recomendações.','Não garante invulnerabilidade.',3),
('7e400000-0000-4000-8000-000000000039','defender-for-cloud','O que é workload protection no Defender for Cloud?','Ajuda a detectar e proteger workloads contra ameaças conforme capacidades habilitadas.','Proteção de cargas.',4),
('7e400000-0000-4000-8000-000000000040','defender-for-cloud','Defender for Cloud é apenas antivírus?','Não. Ele abrange postura de segurança e proteção de workloads cloud.','Não confundir com Defender Antivirus.',5);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_895_flashcard_seed seed join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug=seed.lesson_slug;

create temporary table stage_895_question_seed(
  id uuid primary key,lesson_slug text not null,question_text text not null,difficulty text not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_895_question_seed values
('68000000-0000-4000-8000-000000000109','zero-trust-and-defense-in-depth','Qual conjunto contém os três princípios de Zero Trust?','easy','Zero Trust é orientado por verify explicitly, use least privilege access e assume breach.',1),
('68000000-0000-4000-8000-000000000110','zero-trust-and-defense-in-depth','Qual estratégia usa múltiplas camadas para que outras proteções permaneçam se um controle falhar?','easy','Defense in Depth reduz a dependência de uma única barreira usando controles em várias camadas.',2),
('68000000-0000-4000-8000-000000000111','zero-trust-and-defense-in-depth','Um usuário está na rede corporativa, mas a solicitação ainda é avaliada por identidade, dispositivo e contexto. Qual princípio está sendo aplicado?','medium','Verify explicitly evita confiança automática baseada somente na localização da rede.',3),
('68000000-0000-4000-8000-000000000112','zero-trust-and-defense-in-depth','Uma identidade recebe apenas leitura em um único Resource Group durante o período necessário. Qual princípio é mais diretamente representado?','medium','Least privilege limita permissões, duração e scope ao necessário.',4),
('68000000-0000-4000-8000-000000000113','zero-trust-and-defense-in-depth','Uma arquitetura verifica cada solicitação, limita privilégios e mantém controles nas camadas de identidade, rede, aplicação e dados. Qual interpretação está correta?','hard','O cenário combina princípios de Zero Trust com Defense in Depth; as estratégias são distintas e complementares.',5),
('68000000-0000-4000-8000-000000000114','defender-for-cloud','Quais são as duas ideias principais de Microsoft Defender for Cloud em nível AZ-900?','easy','Defender for Cloud ajuda a avaliar e melhorar security posture e a proteger workloads conforme capacidades habilitadas.',1),
('68000000-0000-4000-8000-000000000115','defender-for-cloud','Qual recurso do Defender for Cloud apresenta orientação acionável para melhorar configurações de segurança?','easy','Security recommendations apresentam achados e ações para melhorar a postura.',2),
('68000000-0000-4000-8000-000000000116','defender-for-cloud','Uma equipe quer identificar configurações de recursos cloud que podem ser melhoradas e acompanhar sua postura. Qual serviço é mais apropriado?','medium','Defender for Cloud avalia postura, fornece recomendações e apresenta secure score.',3),
('68000000-0000-4000-8000-000000000117','defender-for-cloud','Uma organização quer ajudar a detectar ameaças contra workloads cloud conforme proteções habilitadas. Qual capacidade está sendo descrita?','medium','Workload protection no Defender for Cloud ajuda a detectar e proteger cargas contra ameaças.',4),
('68000000-0000-4000-8000-000000000118','defender-for-cloud','Um relatório mostra uma recomendação de configuração e um alerta de ameaça em um workload. Como classificar os dois resultados?','hard','A recomendação está ligada à security posture; o alerta de ameaça está ligado à workload protection.',5);
insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_895_question_seed seed join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure architecture and services'
join public.topics topic on topic.domain_id=domain.id and topic.id='32000000-0000-4000-8000-000000000005'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug=seed.lesson_slug;

create temporary table stage_895_option_seed(
  id uuid primary key,question_id uuid not null,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_895_option_seed values
('7f190000-0000-4000-8000-000000000001','68000000-0000-4000-8000-000000000109','Verify explicitly, use least privilege access e assume breach.',true,'Correta. São os três princípios fundamentais.',1),
('7f190000-0000-4000-8000-000000000002','68000000-0000-4000-8000-000000000109','Authenticate once, trust the network e allow permanently.',false,'Zero Trust evita confiança implícita e permanente.',2),
('7f190000-0000-4000-8000-000000000003','68000000-0000-4000-8000-000000000109','Physical, network e data.',false,'São exemplos de camadas, não os princípios de Zero Trust.',3),
('7f190000-0000-4000-8000-000000000004','68000000-0000-4000-8000-000000000109','Detect, respond e recover.',false,'Essa tríade não representa os princípios solicitados.',4),
('7f190000-0000-4000-8000-000000000005','68000000-0000-4000-8000-000000000110','Defense in Depth.',true,'Correta. A estratégia emprega múltiplas camadas.',1),
('7f190000-0000-4000-8000-000000000006','68000000-0000-4000-8000-000000000110','Zero Trust.',false,'Zero Trust orienta confiança e acesso; não é o nome da estratégia em camadas.',2),
('7f190000-0000-4000-8000-000000000007','68000000-0000-4000-8000-000000000110','Use least privilege access.',false,'Least privilege limita acesso, mas não representa sozinho múltiplas camadas.',3),
('7f190000-0000-4000-8000-000000000008','68000000-0000-4000-8000-000000000110','Assume breach.',false,'Assume breach é um princípio de Zero Trust, não o nome da estratégia em camadas.',4),
('7f190000-0000-4000-8000-000000000009','68000000-0000-4000-8000-000000000111','Verify explicitly.',true,'Correta. A solicitação usa sinais atuais, sem confiar na rede.',1),
('7f190000-0000-4000-8000-000000000010','68000000-0000-4000-8000-000000000111','Trust every internal request.',false,'Isso é confiança implícita, contrariando Zero Trust.',2),
('7f190000-0000-4000-8000-000000000011','68000000-0000-4000-8000-000000000111','Defense in Depth apenas.',false,'O foco do cenário é avaliar explicitamente a solicitação.',3),
('7f190000-0000-4000-8000-000000000012','68000000-0000-4000-8000-000000000111','High availability.',false,'Alta disponibilidade trata continuidade do serviço.',4),
('7f190000-0000-4000-8000-000000000013','68000000-0000-4000-8000-000000000112','Use least privilege access.',true,'Correta. Permissão, tempo e scope foram limitados.',1),
('7f190000-0000-4000-8000-000000000014','68000000-0000-4000-8000-000000000112','Assume breach apenas.',false,'Assume breach é relacionado, mas o requisito direto é menor privilégio.',2),
('7f190000-0000-4000-8000-000000000015','68000000-0000-4000-8000-000000000112','Grant permanent ownership.',false,'Privilégio permanente e amplo contraria o cenário.',3),
('7f190000-0000-4000-8000-000000000016','68000000-0000-4000-8000-000000000112','Trust based on network location.',false,'Localização não deve gerar confiança automática.',4),
('7f190000-0000-4000-8000-000000000017','68000000-0000-4000-8000-000000000113','Zero Trust e Defense in Depth trabalham juntos no cenário.',true,'Correta. Há princípios de acesso e múltiplas camadas.',1),
('7f190000-0000-4000-8000-000000000018','68000000-0000-4000-8000-000000000113','Somente Defense in Depth, porque Zero Trust é um produto.',false,'Zero Trust é uma estratégia, não um produto.',2),
('7f190000-0000-4000-8000-000000000019','68000000-0000-4000-8000-000000000113','Somente Zero Trust, porque camadas são irrelevantes.',false,'As camadas demonstram Defense in Depth.',3),
('7f190000-0000-4000-8000-000000000020','68000000-0000-4000-8000-000000000113','As duas expressões são sinônimas.',false,'As estratégias possuem focos distintos.',4),
('7f190000-0000-4000-8000-000000000021','68000000-0000-4000-8000-000000000114','Security posture e workload protection.',true,'Correta. São os dois focos esperados.',1),
('7f190000-0000-4000-8000-000000000022','68000000-0000-4000-8000-000000000114','Security posture e cost optimization.',false,'Cost optimization não é o segundo foco de segurança solicitado.',2),
('7f190000-0000-4000-8000-000000000023','68000000-0000-4000-8000-000000000114','Authentication e access authorization.',false,'Esses conceitos não resumem os dois focos do serviço.',3),
('7f190000-0000-4000-8000-000000000024','68000000-0000-4000-8000-000000000114','SIEM e SOAR centralizados.',false,'Essa descrição aponta para Microsoft Sentinel, não para os dois focos pedidos.',4),
('7f190000-0000-4000-8000-000000000025','68000000-0000-4000-8000-000000000115','Security recommendations.',true,'Correta. Elas oferecem orientação acionável.',1),
('7f190000-0000-4000-8000-000000000026','68000000-0000-4000-8000-000000000115','Secure score.',false,'Secure score resume postura; as recomendações trazem a orientação acionável.',2),
('7f190000-0000-4000-8000-000000000027','68000000-0000-4000-8000-000000000115','Workload protection.',false,'Workload protection trata ameaças; não é o nome da orientação de configuração.',3),
('7f190000-0000-4000-8000-000000000028','68000000-0000-4000-8000-000000000115','Microsoft Defender Antivirus.',false,'Defender Antivirus não apresenta as recomendações cloud descritas.',4),
('7f190000-0000-4000-8000-000000000029','68000000-0000-4000-8000-000000000116','Microsoft Defender for Cloud.',true,'Correta. Ele avalia postura e fornece recomendações.',1),
('7f190000-0000-4000-8000-000000000030','68000000-0000-4000-8000-000000000116','Microsoft Defender Antivirus.',false,'Antivirus não oferece a avaliação ampla de postura cloud solicitada.',2),
('7f190000-0000-4000-8000-000000000031','68000000-0000-4000-8000-000000000116','Microsoft Sentinel.',false,'Sentinel é SIEM/SOAR; não é o serviço de postura descrito.',3),
('7f190000-0000-4000-8000-000000000032','68000000-0000-4000-8000-000000000116','Conditional Access.',false,'Conditional Access avalia condições para decisões de acesso.',4),
('7f190000-0000-4000-8000-000000000033','68000000-0000-4000-8000-000000000117','Workload protection.',true,'Correta. O foco é detectar e proteger cargas.',1),
('7f190000-0000-4000-8000-000000000034','68000000-0000-4000-8000-000000000117','Secure score apenas.',false,'Secure score resume postura, não é a proteção de workload descrita.',2),
('7f190000-0000-4000-8000-000000000035','68000000-0000-4000-8000-000000000117','Resource hierarchy.',false,'Hierarchy organiza scopes de recursos.',3),
('7f190000-0000-4000-8000-000000000036','68000000-0000-4000-8000-000000000117','Storage access tier.',false,'Access tier relaciona padrão de acesso e custo.',4),
('7f190000-0000-4000-8000-000000000037','68000000-0000-4000-8000-000000000118','Postura para a recomendação; workload protection para o alerta.',true,'Correta. Os resultados representam os dois focos.',1),
('7f190000-0000-4000-8000-000000000038','68000000-0000-4000-8000-000000000118','Workload protection para ambos.',false,'A recomendação de configuração pertence à postura.',2),
('7f190000-0000-4000-8000-000000000039','68000000-0000-4000-8000-000000000118','Postura para ambos.',false,'A detecção de ameaça representa workload protection.',3),
('7f190000-0000-4000-8000-000000000040','68000000-0000-4000-8000-000000000118','Antivírus para ambos.',false,'Defender for Cloud não se reduz a antivírus.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_895_option_seed;

do $$
declare lesson_record record;
begin
  for lesson_record in
    select id,slug,
      case slug when 'zero-trust-and-defense-in-depth' then 15 else 11 end expected_blocks,
      case slug when 'zero-trust-and-defense-in-depth' then 7 else 5 end expected_cards
    from public.lessons where topic_id='32000000-0000-4000-8000-000000000005'
      and slug in ('zero-trust-and-defense-in-depth','defender-for-cloud')
  loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_record.id and is_published)<>lesson_record.expected_blocks
      or (select count(*) from public.flashcards where lesson_id=lesson_record.id and is_published)<>lesson_record.expected_cards
      or (select count(*) from public.questions where lesson_id=lesson_record.id and is_published)<>5 then
      raise exception '8.9.5 final inventory is invalid for %',lesson_record.slug;
    end if;
  end loop;
  if (select count(*) from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000005'
      and lesson.slug in ('zero-trust-and-defense-in-depth','defender-for-cloud'))<>1 then
    raise exception '8.9.5 expected exactly one scoped Visual Experience';
  end if;
end; $$;

commit;

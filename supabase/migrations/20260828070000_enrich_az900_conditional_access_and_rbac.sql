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
    and lesson.slug in ('conditional-access','azure-rbac');
  if target_count<>2 then raise exception '8.9.4 expected two existing target Lessons'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug in ('conditional-access','azure-rbac')) then
    raise exception '8.9.4 expected target Lessons without Content Blocks';
  end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug in ('conditional-access','azure-rbac'))
    or exists(select 1 from public.visual_experiences where id='76000000-0000-4000-8000-000000000014') then
    raise exception '8.9.4 Visual Experience preconditions are invalid';
  end if;
  if exists(select 1 from public.lessons lesson where lesson.topic_id='32000000-0000-4000-8000-000000000005'
    and lesson.slug='conditional-access' and (exists(select 1 from public.flashcards where lesson_id=lesson.id)
      or exists(select 1 from public.questions where lesson_id=lesson.id))) then
    raise exception '8.9.4 expected Conditional Access without existing practice';
  end if;
  if not exists(select 1 from public.lessons lesson where lesson.topic_id='32000000-0000-4000-8000-000000000005'
    and lesson.slug='azure-rbac' and (select count(*) from public.flashcards where lesson_id=lesson.id and is_published)=3
      and (select count(*) from public.questions where lesson_id=lesson.id and is_published)=1)
    or not exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where question.id='60000000-0000-4000-8000-000000000010' and lesson.slug='azure-rbac') then
    raise exception '8.9.4 historical RBAC practice inventory is invalid';
  end if;
end; $$;

update public.lessons set estimated_minutes=case slug when 'conditional-access' then 12 else 12 end
where topic_id='32000000-0000-4000-8000-000000000005' and slug in ('conditional-access','azure-rbac');

insert into public.visual_experiences(id,lesson_id,type,title,description,config,display_order,is_published)
select '76000000-0000-4000-8000-000000000014',lesson.id,'architecture',
  'Como uma Role Assignment controla acesso',
  'Security Principal, Role Definition e Scope se combinam em uma Role Assignment aplicada aos recursos Azure.',
  $json$
  {
    "nodes": [
      {"id":"security-principal","label":"Security Principal","kind":"external","description":"Quem solicita acesso: user, group, service principal ou managed identity.","x":18,"y":18},
      {"id":"role-definition","label":"Role Definition","kind":"service","description":"O que pode ser feito: coleção de permissões representada por uma Azure role.","x":50,"y":18},
      {"id":"scope","label":"Scope","kind":"group","description":"Onde o acesso se aplica: management group, subscription, resource group ou resource.","x":82,"y":18},
      {"id":"role-assignment","label":"Role Assignment","kind":"service","description":"Combina principal, role e scope para conceder acesso.","x":50,"y":52},
      {"id":"azure-resources","label":"Azure Resources","kind":"resource","description":"Recursos alcançados pela atribuição dentro do scope definido.","x":50,"y":84}
    ],
    "edges": [
      {"id":"principal-assignment","source":"security-principal","target":"role-assignment","label":"quem"},
      {"id":"role-assignment-edge","source":"role-definition","target":"role-assignment","label":"o quê"},
      {"id":"scope-assignment","source":"scope","target":"role-assignment","label":"onde"},
      {"id":"assignment-resources","source":"role-assignment","target":"azure-resources","label":"autoriza"}
    ]
  }
  $json$::jsonb,1,true
from public.lessons lesson
where lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug='azure-rbac';

create temporary table stage_894_block_seed(
  id uuid primary key,lesson_slug text not null,type text not null,title text,content text,config jsonb,
  visual_experience_id uuid,display_order integer not null
) on commit drop;
insert into stage_894_block_seed values
('7b180000-0000-4000-8000-000000000001','conditional-access','explanation','O que é Conditional Access?',
$content$Microsoft Entra Conditional Access é um mecanismo de políticas que reúne sinais e condições para tomar decisões de acesso e aplicar controles organizacionais.

Ele ajuda a responder se um acesso deve ser permitido, bloqueado ou condicionado a um controle adicional. Configuração detalhada de policies fica fora desta Lesson.$content$,null,null,1),
('7b180000-0000-4000-8000-000000000002','conditional-access','important','Sinais em nível Fundamentals',
$content$Conditional Access pode considerar sinais como usuário ou grupo, localização, dispositivo, aplicação ou recurso e risco quando aplicável.

Os sinais fornecem contexto para a decisão. Nenhum sinal isolado representa obrigatoriamente uma regra universal; a policy define como o contexto será avaliado.$content$,null,null,2),
('7b180000-0000-4000-8000-000000000003','conditional-access','explanation','O modelo if-then',
$content$O modelo conceitual é:

Signal → Condition / Policy → Decision → Allow, Block ou Require additional control.

**IF** uma condição definida for atendida, **THEN** a policy aplica uma decisão ou controle. Para AZ-900, reconheça o raciocínio; não é necessário construir uma policy.$content$,null,null,3),
('7b180000-0000-4000-8000-000000000004','conditional-access','example','Condição sensível exige MFA',
$content$IF um usuário tentar acessar uma aplicação definida em uma condição considerada sensível,

THEN exigir MFA antes de conceder acesso.

Conditional Access decide quando o controle será exigido; MFA executa a verificação adicional da identidade.$content$,null,null,4),
('7b180000-0000-4000-8000-000000000005','conditional-access','example','Bloqueio baseado em condição',
$content$Uma organização define que determinado acesso não deve ser permitido quando uma combinação específica de sinais ocorrer. A policy avalia o contexto e pode bloquear o acesso.

O exemplo demonstra decisão condicional, não uma configuração de portal ou uma regra recomendada para toda organização.$content$,null,null,5),
('7b180000-0000-4000-8000-000000000006','conditional-access','important','Decisões e controles possíveis',
$content$Em Fundamentals, associe Conditional Access a decisões como permitir ou bloquear e a controles adicionais como exigir MFA ou um requisito compatível de dispositivo.

O serviço não é um fator de autenticação. Ele reúne sinais, avalia a policy e aplica a decisão.$content$,null,null,6),
('7b180000-0000-4000-8000-000000000007','conditional-access','exam_trap','Conditional Access não é MFA',
$content$MFA é um método ou controle de autenticação com múltiplos fatores. Conditional Access é o policy engine que pode decidir quando exigir MFA.

MFA sempre habilitado para um usuário não prova, por si só, que uma policy de Conditional Access foi responsável pelo prompt.$content$,null,null,7),
('7b180000-0000-4000-8000-000000000008','conditional-access','important','Authentication, Conditional Access e RBAC',
$content$| Conceito | Pergunta principal |
| --- | --- |
| Authentication | Quem é você? |
| Conditional Access | Em quais condições pode acessar? |
| Azure RBAC | O que pode fazer e em qual scope? |

Microsoft Entra ID pode autenticar a identidade; Conditional Access avalia condições; Azure RBAC autoriza ações sobre recursos Azure.$content$,null,null,8),
('7b180000-0000-4000-8000-000000000009','conditional-access','exam_tip','Procure condição seguida de decisão',
$content$Questões como “quando determinada condição ocorrer, exigir MFA ou bloquear acesso” apontam para Conditional Access. Procure a estrutura if-then e não apenas a presença da palavra MFA.$content$,null,null,9),
('7b180000-0000-4000-8000-000000000010','conditional-access','exam_trap','Conditional Access não define ações de gerenciamento no recurso',
$content$Conditional Access avalia as condições para o acesso. Ele não substitui Azure RBAC para decidir se uma identidade pode ler, alterar ou excluir um recurso Azure.

Também não é um método de autenticação nem uma role atribuída a um scope.$content$,null,null,10),
('7b180000-0000-4000-8000-000000000011','conditional-access','summary','Resumo para memória ativa',null,
'{"items":["Conditional Access é um mecanismo de policies baseado em sinais e condições.","O modelo é IF condição, THEN decisão ou controle.","Usuário, localização, dispositivo, aplicação e risco podem atuar como sinais.","Decisões podem permitir, bloquear ou exigir controle adicional.","Conditional Access pode exigir MFA, mas não é MFA.","RBAC controla ações no recurso; Conditional Access avalia condições de acesso."]}'::jsonb,null,11),

('7b180000-0000-4000-8000-000000000012','azure-rbac','explanation','O que é Azure RBAC?',
$content$Azure Role-Based Access Control, ou Azure RBAC, é o sistema de autorização do Azure usado para controlar acesso a recursos Azure.

Ele ajuda a responder: **WHO can do WHAT at WHICH SCOPE?** RBAC não autentica a identidade e não decide condições de sign-in.$content$,null,null,1),
('7b180000-0000-4000-8000-000000000013','azure-rbac','important','Os elementos de uma Role Assignment',
$content$Security Principal + Role Definition + Scope = Role Assignment.

- **Security Principal:** quem recebe o acesso.
- **Role Definition:** quais ações são permitidas.
- **Scope:** onde a permissão se aplica.
- **Role Assignment:** vínculo dos três elementos que concede o acesso.$content$,null,null,2),
('7b180000-0000-4000-8000-000000000014','azure-rbac','explanation','Security Principal: quem?',
$content$Um security principal pode representar conceitualmente um user, group, service principal ou managed identity.

Pessoas, grupos e identidades de aplicações ou workloads podem receber uma role. Para a prova, reconheça os tipos; criação e gerenciamento detalhados ficam fora desta Lesson.$content$,null,null,3),
('7b180000-0000-4000-8000-000000000015','azure-rbac','explanation','Role Definition: o que pode fazer?',
$content$Uma role definition é uma coleção de permissões. A role Reader é associada à visualização; Contributor permite gerenciar recursos dentro do scope, sem conceder automaticamente a capacidade de atribuir roles.

Não é necessário memorizar todas as built-in roles nem a sintaxe de role definitions.$content$,null,null,4),
('7b180000-0000-4000-8000-000000000016','azure-rbac','explanation','Scope: onde se aplica?',
$content$Os quatro níveis conceituais, do mais amplo ao mais específico, são:

Management Group → Subscription → Resource Group → Resource.

O scope conecta RBAC à Resource Hierarchy já estudada e determina o conjunto de recursos alcançado pela atribuição.$content$,null,null,5),
('7b180000-0000-4000-8000-000000000017','azure-rbac','important','Herança e menor scope necessário',
$content$Uma role atribuída em um scope pai normalmente é herdada pelos scopes filhos. Reader em um Resource Group, por exemplo, alcança os recursos dentro desse grupo.

Escolher o scope mais restrito que atende ao requisito reduz o alcance desnecessário da permissão.$content$,null,null,6),
('7b180000-0000-4000-8000-000000000018','azure-rbac','explanation','Role Assignment concede acesso',
$content$A Role Assignment associa um security principal a uma role definition em um scope específico.

Exemplo: João + Reader + Resource Group da aplicação = João pode visualizar os recursos desse grupo, conforme a role e o scope definidos.$content$,null,null,7),
('7b180000-0000-4000-8000-000000000019','azure-rbac','visual_experience','Principal, Role, Scope e Assignment',null,null,
'76000000-0000-4000-8000-000000000014',8),
('7b180000-0000-4000-8000-000000000020','azure-rbac','example','Reader em um Resource Group',
$content$Um analista precisa visualizar recursos e configurações de um único Resource Group, sem alterá-los. Uma Role Assignment pode combinar o usuário, a role Reader e o scope do Resource Group.

Atribuir uma role mais ampla em toda a Subscription aumentaria o alcance sem necessidade.$content$,null,null,9),
('7b180000-0000-4000-8000-000000000021','azure-rbac','example','Identidade de workload em um único recurso',
$content$Uma managed identity de aplicação precisa acessar somente um recurso específico. Azure RBAC pode associar a identidade a uma role adequada no scope desse recurso.

O exemplo demonstra security principal, role e scope sem exigir credenciais ou custom roles.$content$,null,null,10),
('7b180000-0000-4000-8000-000000000022','azure-rbac','important','Três controles, três perguntas',
$content$Authentication → Quem é você?

Conditional Access → Em quais condições pode acessar?

Azure RBAC → O que pode fazer e em qual scope?

Os controles podem participar do mesmo fluxo, mas resolvem decisões diferentes.$content$,null,null,11),
('7b180000-0000-4000-8000-000000000023','azure-rbac','exam_trap','Role sem scope não explica a permissão completa',
$content$Saber apenas que uma pessoa possui Reader ou Contributor não revela onde a role se aplica. A Role Assignment precisa combinar principal, role e scope.

Azure RBAC é autorização de recursos Azure; não autentica usuários e não é Conditional Access.$content$,null,null,12),
('7b180000-0000-4000-8000-000000000024','azure-rbac','exam_tip','Procure quem, ação e alcance',
$content$“Permitir que João visualize recursos de um Resource Group” ou “controlar o que um grupo pode fazer em uma Subscription” aponta para Azure RBAC. Identifique principal, ação desejada e scope.$content$,null,null,13),
('7b180000-0000-4000-8000-000000000025','azure-rbac','summary','Resumo para memória ativa',null,
'{"items":["Azure RBAC é o sistema de autorização para recursos Azure.","Uma Role Assignment combina security principal, role definition e scope.","Principals incluem user, group, service principal e managed identity.","Scopes seguem Management Group, Subscription, Resource Group e Resource.","Permissões em scopes pais normalmente são herdadas pelos filhos.","Authentication, Conditional Access e RBAC respondem perguntas diferentes."]}'::jsonb,null,14);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.visual_experience_id,seed.display_order,true
from stage_894_block_seed seed join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug=seed.lesson_slug;

create temporary table stage_894_flashcard_update(
  id uuid primary key,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_894_flashcard_update values
('70000000-0000-4000-8000-000000000031','O que o Azure RBAC controla?','Quem pode executar quais ações sobre recursos Azure e em qual scope.','Who, what, where.',1),
('70000000-0000-4000-8000-000000000032','Quais são os três elementos de uma Role Assignment?','Security principal, role definition e scope.','Quem + o quê + onde.',2),
('70000000-0000-4000-8000-000000000033','O que ocorre com uma role atribuída em um Resource Group?','Ela se aplica ao grupo e normalmente é herdada pelos recursos dentro dele.','Scope pai alcança filhos.',3);
update public.flashcards card set front_text=seed.front_text,back_text=seed.back_text,hint=seed.hint,display_order=seed.display_order
from stage_894_flashcard_update seed where card.id=seed.id;

create temporary table stage_894_flashcard_seed(
  id uuid primary key,lesson_slug text not null,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_894_flashcard_seed values
('7e400000-0000-4000-8000-000000000021','conditional-access','O que é Conditional Access?','É o mecanismo de policies que usa sinais e condições para tomar decisões de acesso.','Signal → policy → decision.',1),
('7e400000-0000-4000-8000-000000000022','conditional-access','Qual é o modelo conceitual de Conditional Access?','IF uma condição for atendida, THEN aplicar uma decisão ou controle.','If-then.',2),
('7e400000-0000-4000-8000-000000000023','conditional-access','Conditional Access e MFA são o mesmo conceito?','Não. Conditional Access pode decidir quando exigir MFA; MFA executa a autenticação multifator.','Policy versus controle.',3),
('7e400000-0000-4000-8000-000000000024','conditional-access','Quais sinais Conditional Access pode considerar?','Usuário/grupo, localização, dispositivo, aplicação/recurso e risco quando aplicável.','Contexto do acesso.',4),
('7e400000-0000-4000-8000-000000000025','conditional-access','Conditional Access controla o que alguém pode alterar em um recurso Azure?','Não. Essa autorização sobre recursos é função do Azure RBAC.','Condição versus ação.',5),
('7e400000-0000-4000-8000-000000000026','azure-rbac','Quais security principals podem receber uma Azure role?','Users, groups, service principals e managed identities.','Quem recebe.',4),
('7e400000-0000-4000-8000-000000000027','azure-rbac','Quais são os níveis de scope do Azure RBAC?','Management Group, Subscription, Resource Group e Resource.','Do amplo ao específico.',5),
('7e400000-0000-4000-8000-000000000028','azure-rbac','Authentication, Conditional Access e RBAC respondem quais perguntas?','Quem é você; em quais condições pode acessar; o que pode fazer e em qual scope.','Identidade, condição, autorização.',6);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_894_flashcard_seed seed join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug=seed.lesson_slug;

create temporary table stage_894_question_seed(
  id uuid primary key,lesson_slug text not null,question_text text not null,difficulty text not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_894_question_seed values
('68000000-0000-4000-8000-000000000100','conditional-access','Qual descrição representa Microsoft Entra Conditional Access?','easy','Conditional Access usa sinais e condições para tomar decisões de acesso e aplicar controles organizacionais.',1),
('68000000-0000-4000-8000-000000000101','conditional-access','Qual estrutura representa o modelo conceitual de uma policy de Conditional Access?','easy','Conditional Access segue um modelo if-then: se a condição ocorrer, aplique uma decisão ou controle.',2),
('68000000-0000-4000-8000-000000000102','conditional-access','Uma organização quer exigir MFA quando um usuário acessar uma aplicação sob determinada condição. Qual recurso decide quando exigir o controle?','medium','Conditional Access avalia os sinais e a policy e pode exigir MFA como controle adicional.',3),
('68000000-0000-4000-8000-000000000103','conditional-access','Uma policy deve bloquear um acesso quando uma combinação definida de localização e dispositivo ocorrer. Qual conceito atende?','medium','Conditional Access combina sinais como localização e dispositivo para aplicar uma decisão de acesso, inclusive bloqueio.',4),
('68000000-0000-4000-8000-000000000104','conditional-access','Um usuário foi autenticado, uma condição exige MFA e depois ele poderá apenas visualizar um Resource Group. Qual mapeamento está correto?','hard','Authentication verifica a identidade; Conditional Access exige MFA pela condição; Azure RBAC com Reader no scope controla a ação permitida.',5),
('68000000-0000-4000-8000-000000000105','azure-rbac','Qual é a finalidade principal do Azure RBAC?','easy','Azure RBAC é o sistema de autorização que controla quem pode fazer o quê em recursos Azure e em qual scope.',2),
('68000000-0000-4000-8000-000000000106','azure-rbac','Quais elementos formam uma Role Assignment?','easy','Uma Role Assignment combina security principal, role definition e scope.',3),
('68000000-0000-4000-8000-000000000107','azure-rbac','Uma managed identity precisa de acesso a um único recurso Azure. Qual combinação conceitual deve ser criada?','medium','Uma Role Assignment associa a managed identity a uma role apropriada no scope do recurso específico.',4),
('68000000-0000-4000-8000-000000000108','azure-rbac','Uma equipe precisa visualizar todos os recursos de um Resource Group sem alterá-los e sem ampliar o acesso à Subscription. Qual abordagem é mais alinhada?','hard','Atribuir Reader ao grupo no scope do Resource Group concede visualização no alcance necessário e evita ampliar a permissão para toda a Subscription.',5);
insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_894_question_seed seed join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure architecture and services'
join public.topics topic on topic.domain_id=domain.id and topic.id='32000000-0000-4000-8000-000000000005'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug=seed.lesson_slug;

create temporary table stage_894_option_seed(
  id uuid primary key,question_id uuid not null,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_894_option_seed values
('7f180000-0000-4000-8000-000000000001','68000000-0000-4000-8000-000000000100','Um mecanismo de policies baseado em sinais e condições.',true,'Correta. Ele toma decisões de acesso conforme contexto.',1),
('7f180000-0000-4000-8000-000000000002','68000000-0000-4000-8000-000000000100','Uma role que concede acesso a recursos Azure.',false,'Isso descreve autorização por RBAC.',2),
('7f180000-0000-4000-8000-000000000003','68000000-0000-4000-8000-000000000100','Um método biométrico específico.',false,'Conditional Access não é método de autenticação.',3),
('7f180000-0000-4000-8000-000000000004','68000000-0000-4000-8000-000000000100','Uma rede privada entre datacenters.',false,'Isso não é controle de identidade.',4),
('7f180000-0000-4000-8000-000000000005','68000000-0000-4000-8000-000000000101','IF condição, THEN decisão ou controle.',true,'Correta. Esse é o modelo conceitual.',1),
('7f180000-0000-4000-8000-000000000006','68000000-0000-4000-8000-000000000101','WHO, WHAT e WHICH SCOPE.',false,'Essa fórmula descreve Azure RBAC.',2),
('7f180000-0000-4000-8000-000000000007','68000000-0000-4000-8000-000000000101','CAPEX seguido de OPEX.',false,'Isso pertence a custos.',3),
('7f180000-0000-4000-8000-000000000008','68000000-0000-4000-8000-000000000101','Scale up seguido de scale out.',false,'Isso pertence a escalabilidade.',4),
('7f180000-0000-4000-8000-000000000009','68000000-0000-4000-8000-000000000102','Conditional Access.',true,'Correta. A policy decide quando MFA é exigido.',1),
('7f180000-0000-4000-8000-000000000010','68000000-0000-4000-8000-000000000102','Azure RBAC.',false,'RBAC controla ações e scope nos recursos.',2),
('7f180000-0000-4000-8000-000000000011','68000000-0000-4000-8000-000000000102','Azure DNS.',false,'DNS não avalia sinais de identidade.',3),
('7f180000-0000-4000-8000-000000000012','68000000-0000-4000-8000-000000000102','Resource Group.',false,'Resource Group é um scope possível, não o policy engine.',4),
('7f180000-0000-4000-8000-000000000013','68000000-0000-4000-8000-000000000103','Conditional Access.',true,'Correta. Localização e dispositivo podem atuar como sinais.',1),
('7f180000-0000-4000-8000-000000000014','68000000-0000-4000-8000-000000000103','Uma Role Assignment Reader.',false,'Reader não avalia localização ou dispositivo.',2),
('7f180000-0000-4000-8000-000000000015','68000000-0000-4000-8000-000000000103','Single Sign-On.',false,'SSO reduz logins repetidos.',3),
('7f180000-0000-4000-8000-000000000016','68000000-0000-4000-8000-000000000103','Azure Storage Explorer.',false,'Storage Explorer gerencia dados de armazenamento.',4),
('7f180000-0000-4000-8000-000000000017','68000000-0000-4000-8000-000000000104','Authentication, Conditional Access e Azure RBAC.',true,'Correta. Cada controle responde a uma decisão distinta.',1),
('7f180000-0000-4000-8000-000000000018','68000000-0000-4000-8000-000000000104','Azure RBAC executa as três decisões sozinho.',false,'RBAC não autentica nem avalia sinais de sign-in.',2),
('7f180000-0000-4000-8000-000000000019','68000000-0000-4000-8000-000000000104','Conditional Access autentica e define Reader.',false,'Conditional Access não substitui autenticação nem role assignment.',3),
('7f180000-0000-4000-8000-000000000020','68000000-0000-4000-8000-000000000104','MFA define sozinho o scope do Resource Group.',false,'MFA não define permissões ou scope.',4),
('7f180000-0000-4000-8000-000000000021','68000000-0000-4000-8000-000000000105','Controlar autorização sobre recursos Azure.',true,'Correta. RBAC controla quem pode fazer o quê e onde.',1),
('7f180000-0000-4000-8000-000000000022','68000000-0000-4000-8000-000000000105','Autenticar usuários com biometria.',false,'RBAC não é método de autenticação.',2),
('7f180000-0000-4000-8000-000000000023','68000000-0000-4000-8000-000000000105','Avaliar localização durante o sign-in.',false,'Esse cenário aponta para Conditional Access.',3),
('7f180000-0000-4000-8000-000000000024','68000000-0000-4000-8000-000000000105','Fornecer SSO entre aplicações.',false,'SSO não é a finalidade do RBAC.',4),
('7f180000-0000-4000-8000-000000000025','68000000-0000-4000-8000-000000000106','Security principal, role definition e scope.',true,'Correta. Os três formam a atribuição.',1),
('7f180000-0000-4000-8000-000000000026','68000000-0000-4000-8000-000000000106','User, password e device.',false,'Esses itens não formam uma Role Assignment.',2),
('7f180000-0000-4000-8000-000000000027','68000000-0000-4000-8000-000000000106','Signal, policy e MFA.',false,'Essa sequência pertence a Conditional Access.',3),
('7f180000-0000-4000-8000-000000000028','68000000-0000-4000-8000-000000000106','Tenant, region e zone.',false,'Esses conceitos não formam uma Role Assignment.',4),
('7f180000-0000-4000-8000-000000000029','68000000-0000-4000-8000-000000000107','Role Assignment para a managed identity no scope do recurso.',true,'Correta. Combina principal, role e scope específico.',1),
('7f180000-0000-4000-8000-000000000030','68000000-0000-4000-8000-000000000107','Conditional Access atribuído ao Resource Group.',false,'Conditional Access não é uma Azure role.',2),
('7f180000-0000-4000-8000-000000000031','68000000-0000-4000-8000-000000000107','MFA no scope da Subscription.',false,'MFA não usa scopes de RBAC.',3),
('7f180000-0000-4000-8000-000000000032','68000000-0000-4000-8000-000000000107','SSO configurado como role.',false,'SSO não é uma role definition.',4),
('7f180000-0000-4000-8000-000000000033','68000000-0000-4000-8000-000000000108','Reader para o grupo no scope do Resource Group.',true,'Correta. Atende leitura no menor alcance descrito.',1),
('7f180000-0000-4000-8000-000000000034','68000000-0000-4000-8000-000000000108','Contributor para o grupo no Management Group.',false,'Permite alterações e amplia excessivamente o scope.',2),
('7f180000-0000-4000-8000-000000000035','68000000-0000-4000-8000-000000000108','Reader para o grupo em todas as Subscriptions.',false,'O requisito está limitado a um Resource Group.',3),
('7f180000-0000-4000-8000-000000000036','68000000-0000-4000-8000-000000000108','Bloquear o grupo com Conditional Access.',false,'Bloqueio não concede a leitura solicitada.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_894_option_seed;

do $$
declare lesson_record record;
begin
  for lesson_record in
    select id,slug,case slug when 'conditional-access' then 11 else 14 end expected_blocks,
      case slug when 'conditional-access' then 5 else 6 end expected_cards,
      case slug when 'conditional-access' then 5 else 5 end expected_questions
    from public.lessons where topic_id='32000000-0000-4000-8000-000000000005'
      and slug in ('conditional-access','azure-rbac')
  loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_record.id and is_published)<>lesson_record.expected_blocks
      or (select count(*) from public.flashcards where lesson_id=lesson_record.id and is_published)<>lesson_record.expected_cards
      or (select count(*) from public.questions where lesson_id=lesson_record.id and is_published)<>lesson_record.expected_questions then
      raise exception '8.9.4 final inventory is invalid for %',lesson_record.slug; end if;
  end loop;
  if (select count(*) from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug in ('conditional-access','azure-rbac'))<>1 then
    raise exception '8.9.4 expected exactly one scoped Visual Experience'; end if;
  if (select count(*) from public.question_options where question_id='60000000-0000-4000-8000-000000000010')<>4 then
    raise exception '8.9.4 historical RBAC Question Options were not preserved'; end if;
end; $$;

commit;

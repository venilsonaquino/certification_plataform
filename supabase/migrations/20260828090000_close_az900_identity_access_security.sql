begin;

do $$
begin
  if not exists(select 1 from public.lessons lesson
    where lesson.topic_id='32000000-0000-4000-8000-000000000005'
      and lesson.slug='authentication-vs-authorization' and lesson.is_published
      and lesson.content is not null and btrim(lesson.content)<>'' and lesson.estimated_minutes=8) then
    raise exception '8.9.6 Authentication vs Authorization Lesson precondition is invalid'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug='authentication-vs-authorization')
    or exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug='authentication-vs-authorization') then
    raise exception '8.9.6 expected the support Lesson without blocks or cards'; end if;
  if (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug='authentication-vs-authorization'
      and question.id between '63000000-0000-4000-8000-000000000011' and '63000000-0000-4000-8000-000000000020')<>10
    or (select count(*) from public.question_options
      where question_id between '63000000-0000-4000-8000-000000000011' and '63000000-0000-4000-8000-000000000020')<>40 then
    raise exception '8.9.6 historical Question inventory is invalid'; end if;
end; $$;

create temporary table stage_896_block_seed(
  id uuid primary key,type text not null,title text,content text,config jsonb,display_order integer not null
) on commit drop;
insert into stage_896_block_seed values
('7b1a0000-0000-4000-8000-000000000001','explanation','Authentication: quem é você?',
$content$Authentication, ou autenticação, é o processo de verificar a identidade apresentada por uma pessoa, dispositivo, aplicação ou workload.

Uma autenticação bem-sucedida confirma a identidade para aquele fluxo, mas não concede automaticamente permissão para todo recurso ou ação.$content$,null,1),
('7b1a0000-0000-4000-8000-000000000002','explanation','Authorization: o que pode fazer?',
$content$Authorization, ou autorização, determina quais recursos e ações uma identidade autenticada pode acessar ou executar.

A decisão depende das permissões aplicáveis. No Azure, RBAC é um exemplo de mecanismo de autorização sobre recursos Azure.$content$,null,2),
('7b1a0000-0000-4000-8000-000000000003','important','Comparação direta',
$content$| Conceito | Pergunta | Exemplo |
| --- | --- | --- |
| Authentication | Quem é você? | Microsoft Entra ID verifica a identidade. |
| Authorization | O que pode fazer? | Azure RBAC determina ações em um scope. |

Os conceitos são complementares, mas não são sinônimos.$content$,null,3),
('7b1a0000-0000-4000-8000-000000000004','example','Login concluído, acesso negado',
$content$Uma pessoa entra corretamente na aplicação, mas não pode abrir um relatório restrito.

A autenticação funcionou. A autorização não concedeu permissão para aquele recurso. Um login válido nunca implica acesso irrestrito.$content$,null,4),
('7b1a0000-0000-4000-8000-000000000005','important','Como os controles se relacionam',
$content$MFA reforça a autenticação usando múltiplos fatores. Conditional Access avalia sinais e pode decidir quando exigir MFA ou aplicar outra decisão. Azure RBAC autoriza ações sobre recursos Azure.

Cada controle responde a uma pergunta diferente e pode participar do mesmo fluxo.$content$,null,5),
('7b1a0000-0000-4000-8000-000000000006','exam_trap','Autenticado não significa autorizado',
$content$Authentication não define o que a identidade pode fazer. Authorization não substitui a verificação da identidade.

Também não confunda Conditional Access, que avalia condições de acesso, com RBAC, que controla ações e scope nos recursos Azure.$content$,null,6),
('7b1a0000-0000-4000-8000-000000000007','exam_tip','Separe identidade de permissão',
$content$Se o cenário pergunta quem está solicitando acesso ou como comprovar identidade, pense em authentication. Se pergunta quais ações ou recursos são permitidos, pense em authorization.$content$,null,7),
('7b1a0000-0000-4000-8000-000000000008','summary','Resumo para memória ativa',null,
'{"items":["Authentication verifica quem a identidade é.","Authorization determina o que a identidade pode fazer.","Login bem-sucedido não concede acesso irrestrito.","MFA reforça autenticação; Conditional Access avalia condições.","Azure RBAC autoriza ações sobre recursos e scopes."]}'::jsonb,8);
insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.display_order,true
from stage_896_block_seed seed cross join public.lessons lesson
where lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug='authentication-vs-authorization';

insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from(values
  ('7e400000-0000-4000-8000-000000000041'::uuid,'O que authentication verifica?','Quem a identidade é.','Identidade.',1),
  ('7e400000-0000-4000-8000-000000000042'::uuid,'O que authorization determina?','O que uma identidade pode acessar ou fazer.','Permissão.',2),
  ('7e400000-0000-4000-8000-000000000043'::uuid,'Login bem-sucedido garante acesso a todo recurso?','Não. A identidade ainda depende da autorização aplicável.','Autenticado não significa autorizado.',3)
) seed(id,front_text,back_text,hint,display_order)
cross join public.lessons lesson
where lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug='authentication-vs-authorization';

create temporary table stage_896_question_update(
  id uuid primary key,question_text text not null,explanation text not null
) on commit drop;
insert into stage_896_question_update values
('63000000-0000-4000-8000-000000000011','O que authentication verifica?','Authentication verifica a identidade apresentada por uma pessoa, dispositivo, aplicação ou workload.'),
('63000000-0000-4000-8000-000000000012','O que authorization determina?','Authorization determina quais recursos e ações uma identidade autenticada pode acessar ou executar.'),
('63000000-0000-4000-8000-000000000013','Qual sequência representa corretamente um fluxo típico de controle de acesso?','Primeiro a identidade é autenticada; depois a autorização aplicável determina recursos e ações permitidos.'),
('63000000-0000-4000-8000-000000000014','Um usuário entra corretamente, mas não pode abrir um relatório restrito. Qual conceito explica a negação?','A autenticação funcionou, mas a autorização não concedeu acesso ao relatório específico.'),
('63000000-0000-4000-8000-000000000015','Qual processo é diretamente reforçado quando uma organização exige MFA?','MFA reforça authentication ao exigir fatores independentes para verificar a identidade.'),
('63000000-0000-4000-8000-000000000016','Funcionários entram normalmente, mas apenas o financeiro pode abrir relatórios sensíveis. Qual conceito restringe o recurso?','Authorization determina quais identidades já autenticadas possuem permissão para abrir os relatórios.'),
('63000000-0000-4000-8000-000000000017','Todos os funcionários autenticados conseguem ver dados além do necessário. Qual ajuste atende diretamente ao problema?','Revisar a autorização e aplicar menor privilégio reduz permissões ao necessário para cada função.'),
('63000000-0000-4000-8000-000000000018','Qual comparação entre Conditional Access e Azure RBAC está correta?','Conditional Access avalia condições de acesso; Azure RBAC autoriza ações sobre recursos Azure em um scope.'),
('63000000-0000-4000-8000-000000000019','Uma identidade comprometida passou pela autenticação e possuía permissões excessivas. Qual análise está correta?','O cenário envolve a proteção da autenticação e também a autorização excessiva; reforçar apenas um lado não resolve ambos.'),
('63000000-0000-4000-8000-000000000020','Uma aplicação atende departamentos distintos. Qual estratégia combina corretamente authentication e authorization?','Verificar a identidade com autenticação adequada e limitar os dados permitidos por função combina os dois controles.');
update public.questions question set question_text=seed.question_text,explanation=seed.explanation
from stage_896_question_update seed where question.id=seed.id;

create temporary table stage_896_option_update(
  id uuid primary key,option_text text not null,is_correct boolean not null,explanation text not null
) on commit drop;
insert into stage_896_option_update values
('74000000-0000-4000-8000-000000000041','Quais ações a identidade pode executar.',false,'Isso descreve authorization.'),
('74000000-0000-4000-8000-000000000042','Se o contexto atende a uma policy de acesso.',false,'Essa avaliação aponta para Conditional Access.'),
('74000000-0000-4000-8000-000000000043','Quem a identidade apresentada é.',true,'Correta. Authentication verifica identidade.'),
('74000000-0000-4000-8000-000000000044','Em qual scope uma Azure role se aplica.',false,'Scope participa da autorização por RBAC.'),
('74000000-0000-4000-8000-000000000045','Quem a identidade apresentada é.',false,'Isso descreve authentication.'),
('74000000-0000-4000-8000-000000000046','Quando uma policy deve exigir MFA.',false,'Essa decisão aponta para Conditional Access.'),
('74000000-0000-4000-8000-000000000047','Quantas aplicações participam de SSO.',false,'SSO não define permissões sobre recursos.'),
('74000000-0000-4000-8000-000000000048','Quais recursos e ações são permitidos.',true,'Correta. Authorization determina permissões.'),
('74000000-0000-4000-8000-000000000049','Autenticar a identidade e então aplicar a autorização.',true,'Correta. Identidade verificada precede a decisão de permissão.'),
('74000000-0000-4000-8000-000000000050','Autorizar todas as ações e depois verificar a identidade.',false,'Permissão não deve ser concedida antes da identidade ser verificada.'),
('74000000-0000-4000-8000-000000000051','Usar Conditional Access no lugar de authentication.',false,'Conditional Access não substitui a autenticação.'),
('74000000-0000-4000-8000-000000000052','Usar Azure RBAC para autenticar a identidade.',false,'RBAC é autorização, não autenticação.'),
('74000000-0000-4000-8000-000000000053','Falha de authentication, porque o login não ocorreu.',false,'O login foi concluído corretamente.'),
('74000000-0000-4000-8000-000000000054','Authorization, porque falta permissão para o relatório.',true,'Correta. A identidade foi autenticada, mas não autorizada.'),
('74000000-0000-4000-8000-000000000055','Conditional Access, porque toda negação ocorre no sign-in.',false,'A negação descrita ocorre ao acessar o recurso.'),
('74000000-0000-4000-8000-000000000056','SSO, porque o usuário deveria entrar novamente.',false,'Repetir login não concede a permissão ausente.'),
('74000000-0000-4000-8000-000000000057','Authorization, porque MFA define os recursos permitidos.',false,'MFA não determina permissões de recurso.'),
('74000000-0000-4000-8000-000000000058','SSO, porque MFA reduz múltiplos logins.',false,'SSO e MFA resolvem problemas diferentes.'),
('74000000-0000-4000-8000-000000000059','Authentication, porque MFA reforça a verificação da identidade.',true,'Correta. MFA é um controle de autenticação.'),
('74000000-0000-4000-8000-000000000060','Azure RBAC, porque MFA atribui uma role.',false,'MFA não cria Role Assignments.'),
('74000000-0000-4000-8000-000000000061','Authentication, pois as credenciais diferem por departamento.',false,'O cenário informa que todos já conseguem entrar.'),
('74000000-0000-4000-8000-000000000062','Conditional Access, pois ele define o conteúdo do relatório.',false,'Conditional Access não define permissões internas do relatório.'),
('74000000-0000-4000-8000-000000000063','SSO, pois ele limita quais relatórios podem ser abertos.',false,'SSO reduz prompts de login, não autoriza relatórios.'),
('74000000-0000-4000-8000-000000000064','Authorization, pois define quem pode abrir o recurso.',true,'Correta. O cenário aplica permissões após o login.'),
('74000000-0000-4000-8000-000000000065','Revisar permissões e aplicar least privilege.',true,'Correta. O problema é autorização excessiva.'),
('74000000-0000-4000-8000-000000000066','Exigir MFA sem alterar permissões.',false,'MFA não reduz as permissões existentes.'),
('74000000-0000-4000-8000-000000000067','Habilitar SSO para todos os departamentos.',false,'SSO não corrige acesso excessivo.'),
('74000000-0000-4000-8000-000000000068','Atribuir uma role ainda mais ampla.',false,'Isso aumentaria o acesso em vez de limitá-lo.'),
('74000000-0000-4000-8000-000000000069','Conditional Access e RBAC são sinônimos.',false,'Eles tomam decisões diferentes.'),
('74000000-0000-4000-8000-000000000070','Conditional Access avalia condições; RBAC autoriza ações e scope.',true,'Correta. Condição de acesso difere de autorização no recurso.'),
('74000000-0000-4000-8000-000000000071','Conditional Access autoriza ações; RBAC exige MFA.',false,'As responsabilidades estão invertidas.'),
('74000000-0000-4000-8000-000000000072','MFA e RBAC são dois métodos de authentication.',false,'RBAC é autorização sobre recursos Azure.'),
('74000000-0000-4000-8000-000000000073','Somente authentication precisa ser revisada.',false,'Permissões excessivas também contribuíram.'),
('74000000-0000-4000-8000-000000000074','Somente authorization precisa ser revisada.',false,'A identidade comprometida também exige controles de autenticação adequados.'),
('74000000-0000-4000-8000-000000000075','Authentication e authorization precisam ser avaliadas separadamente.',true,'Correta. Houve identidade comprometida e acesso excessivo.'),
('74000000-0000-4000-8000-000000000076','Adicionar apenas mais camadas de rede resolve ambos.',false,'Camadas de rede não substituem os dois controles.'),
('74000000-0000-4000-8000-000000000077','Authentication forte e a mesma permissão ampla para todos.',false,'A autenticação não corrige autorização excessiva.'),
('74000000-0000-4000-8000-000000000078','Authorization por função sem verificar identidades.',false,'A autorização depende de uma identidade verificada.'),
('74000000-0000-4000-8000-000000000079','SSO sem diferenciação de permissões.',false,'SSO não substitui autenticação adequada nem autorização.'),
('74000000-0000-4000-8000-000000000080','Authentication adequada e authorization por função com least privilege.',true,'Correta. Combina verificação de identidade e permissão necessária.');
update public.question_options option set option_text=seed.option_text,is_correct=seed.is_correct,explanation=seed.explanation
from stage_896_option_update seed where option.id=seed.id;

do $$
begin
  if not exists(select 1 from public.lessons lesson where lesson.topic_id='32000000-0000-4000-8000-000000000005'
    and lesson.slug='authentication-vs-authorization'
    and (select count(*) from public.lesson_content_blocks where lesson_id=lesson.id and is_published)=8
    and (select count(*) from public.flashcards where lesson_id=lesson.id and is_published)=3
    and (select count(*) from public.questions where lesson_id=lesson.id and is_published)=10) then
    raise exception '8.9.6 final support Lesson inventory is invalid'; end if;
  if (select count(*) from public.question_options
    where question_id between '63000000-0000-4000-8000-000000000011' and '63000000-0000-4000-8000-000000000020')<>40 then
    raise exception '8.9.6 historical Question Options were not preserved'; end if;
end; $$;

commit;

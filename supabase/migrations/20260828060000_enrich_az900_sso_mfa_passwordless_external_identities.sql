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
    and lesson.slug in ('single-sign-on','mfa-and-passwordless','external-identities');
  if target_count<>3 then raise exception '8.9.3 expected three existing target Lessons'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000005'
      and lesson.slug in ('single-sign-on','mfa-and-passwordless','external-identities')) then
    raise exception '8.9.3 expected no existing Content Blocks in target Lessons';
  end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000005'
      and lesson.slug in ('single-sign-on','mfa-and-passwordless','external-identities')) then
    raise exception '8.9.3 must not replace or create Visual Experiences';
  end if;
  if exists(select 1 from public.lessons lesson where lesson.topic_id='32000000-0000-4000-8000-000000000005'
    and lesson.slug in ('single-sign-on','mfa-and-passwordless','external-identities')
    and (exists(select 1 from public.flashcards card where card.lesson_id=lesson.id)
      or exists(select 1 from public.questions question where question.lesson_id=lesson.id))) then
    raise exception '8.9.3 expected target Lessons without existing practice';
  end if;
end; $$;

update public.lessons
set estimated_minutes=case slug when 'single-sign-on' then 8 when 'mfa-and-passwordless' then 12 else 10 end
where topic_id='32000000-0000-4000-8000-000000000005'
  and slug in ('single-sign-on','mfa-and-passwordless','external-identities');

create temporary table stage_893_block_seed(
  id uuid primary key,lesson_slug text not null,type text not null,title text,content text,config jsonb,display_order integer not null
) on commit drop;
insert into stage_893_block_seed values
('7b170000-0000-4000-8000-000000000001','single-sign-on','explanation','O que é Single Sign-On?',
$content$Single Sign-On, ou SSO, permite que um usuário autenticado acesse múltiplas aplicações ou serviços integrados sem fornecer novamente suas credenciais em cada aplicação, dentro do fluxo suportado.

O usuário ainda precisa ser autenticado. Depois, o provedor de identidade pode confirmar essa identidade às aplicações integradas.$content$,null,1),
('7b170000-0000-4000-8000-000000000002','single-sign-on','important','Por que organizações usam SSO?',
$content$SSO reduz logins repetidos, melhora a experiência do usuário e diminui a necessidade de administrar credenciais separadas para cada aplicação.

Quando Microsoft Entra ID atua como provedor de identidade, a organização também pode centralizar o gerenciamento da identidade usada pelas aplicações integradas.$content$,null,2),
('7b170000-0000-4000-8000-000000000003','single-sign-on','example','Um sign-in, várias aplicações',
$content$Uma colaboradora entra usando sua identidade da Contoso. Dentro do fluxo suportado, ela abre o Microsoft 365, um portal SaaS e uma aplicação corporativa integrada sem digitar novamente suas credenciais em cada aplicação.

Isso representa SSO; cada aplicação ainda pode avaliar se ela possui acesso autorizado.$content$,null,3),
('7b170000-0000-4000-8000-000000000004','single-sign-on','exam_trap','SSO não é reutilização de senha',
$content$Usar a mesma senha manualmente em vários sistemas não é SSO. Nesse caso, o usuário continua autenticando separadamente em cada sistema e ainda amplia o impacto de uma senha comprometida.

SSO depende de um fluxo de identidade integrado, não apenas de credenciais iguais.$content$,null,4),
('7b170000-0000-4000-8000-000000000005','single-sign-on','exam_trap','SSO não é MFA nem ausência de autenticação',
$content$SSO reduz prompts de login entre aplicações integradas. MFA exige múltiplos fatores. Passwordless autentica sem depender da senha tradicional.

SSO não elimina a autenticação e não determina, sozinho, quais recursos o usuário pode acessar.$content$,null,5),
('7b170000-0000-4000-8000-000000000006','single-sign-on','example','Experiência centralizada com Microsoft Entra ID',
$content$Três aplicações confiam no Microsoft Entra ID como provedor de identidade. O usuário autentica no Entra ID e, enquanto o fluxo e a sessão forem válidos, as aplicações recebem a confirmação de identidade sem solicitar um login independente a cada abertura.$content$,null,6),
('7b170000-0000-4000-8000-000000000007','single-sign-on','exam_tip','Procure a redução de logins repetidos',
$content$Se o requisito diz “autenticar uma vez e acessar várias aplicações integradas”, pense em SSO. Se diz “comprovar identidade com mais de um fator”, pense em MFA. Os dois podem coexistir.$content$,null,7),
('7b170000-0000-4000-8000-000000000008','single-sign-on','summary','Resumo para memória ativa',null,
'{"items":["SSO permite usar várias aplicações integradas após um processo de autenticação suportado.","SSO reduz logins repetidos e melhora a experiência do usuário.","Microsoft Entra ID pode centralizar a identidade usada pelas aplicações.","SSO não é reutilizar a mesma senha.","SSO não é MFA e não elimina autenticação ou autorização."]}'::jsonb,8),

('7b170000-0000-4000-8000-000000000009','mfa-and-passwordless','explanation','O que é Multifactor Authentication?',
$content$Multifactor Authentication, ou MFA, exige dois ou mais fatores de autenticação de categorias diferentes. O objetivo é reduzir a dependência de uma única evidência de identidade.

Se uma senha for comprometida, um fator independente pode dificultar que outra pessoa conclua a autenticação.$content$,null,1),
('7b170000-0000-4000-8000-000000000010','mfa-and-passwordless','important','As três categorias conceituais',
$content$| Categoria | Significado | Exemplo conceitual |
| --- | --- | --- |
| Something you know | Algo que você sabe | Senha |
| Something you have | Algo que você possui | Dispositivo ou chave compatível |
| Something you are | Característica biométrica | Face ou impressão digital |

Para AZ-900, reconheça as categorias. Não é necessário decorar todos os métodos suportados.$content$,null,2),
('7b170000-0000-4000-8000-000000000011','mfa-and-passwordless','example','Dois fatores independentes',
$content$Uma pessoa informa sua senha e confirma a autenticação pelo Microsoft Authenticator em um dispositivo registrado. O cenário combina algo que ela sabe com algo que possui.

Outra implementação compatível pode combinar uma credencial com biometria. O ponto é usar fatores independentes, não apenas repetir um passo.$content$,null,3),
('7b170000-0000-4000-8000-000000000012','mfa-and-passwordless','exam_trap','Duas senhas não formam MFA',
$content$Duas senhas continuam pertencendo à categoria “algo que você sabe”. Pedir login duas vezes também não cria fatores independentes.

Senha e PIN podem continuar na mesma categoria conceitual dependendo do mecanismo. Para identificar MFA, procure evidências de categorias diferentes.$content$,null,4),
('7b170000-0000-4000-8000-000000000013','mfa-and-passwordless','exam_trap','MFA não é Conditional Access',
$content$MFA é o uso de múltiplos fatores para autenticação. Conditional Access é outro conceito e pode, conforme política e sinais, exigir MFA como um controle.

Não trate o mecanismo de autenticação e a decisão de quando exigi-lo como o mesmo recurso. Conditional Access será estudado na próxima etapa.$content$,null,5),
('7b170000-0000-4000-8000-000000000014','mfa-and-passwordless','explanation','O que é Passwordless Authentication?',
$content$Passwordless Authentication verifica a identidade sem usar a senha tradicional como credencial principal do usuário.

A autenticação continua existindo. O usuário demonstra posse, presença ou outra prova suportada por um mecanismo sem senha.$content$,null,6),
('7b170000-0000-4000-8000-000000000015','mfa-and-passwordless','important','Métodos passwordless atuais',
$content$Exemplos conceituais incluem passkeys baseadas em FIDO2, Windows Hello for Business e Microsoft Authenticator em modo passwordless, além de outros métodos suportados.

O aluno não precisa memorizar toda a lista nem configurar os métodos. Reconheça a finalidade: remover a dependência da senha tradicional sem remover a verificação de identidade.$content$,null,7),
('7b170000-0000-4000-8000-000000000016','mfa-and-passwordless','example','Removendo a senha do sign-in',
$content$Uma organização substitui o uso diário de senhas por passkeys compatíveis. O usuário desbloqueia a credencial no dispositivo por um mecanismo local suportado e o serviço verifica a identidade sem receber uma senha tradicional.

Isso é passwordless; não é acesso anônimo.$content$,null,8),
('7b170000-0000-4000-8000-000000000017','mfa-and-passwordless','exam_trap','Passwordless não é SSO nem login automático',
$content$Passwordless descreve como a identidade é autenticada sem senha tradicional. SSO descreve a reutilização de uma autenticação válida entre aplicações integradas.

Passwordless não significa ausência de autenticação, identidade não verificada ou acesso automático a qualquer recurso.$content$,null,9),
('7b170000-0000-4000-8000-000000000018','mfa-and-passwordless','important','SSO, MFA e Passwordless',
$content$| Conceito | Objetivo principal |
| --- | --- |
| SSO | Reduzir logins repetidos entre aplicações integradas |
| MFA | Exigir múltiplos fatores independentes |
| Passwordless | Remover a dependência da senha tradicional |

Os conceitos não são mutuamente exclusivos. Uma organização pode usar um método passwordless, exigir uma autenticação forte e oferecer SSO para aplicações integradas.$content$,null,10),
('7b170000-0000-4000-8000-000000000019','mfa-and-passwordless','example','Três requisitos, três conceitos',
$content$“Acessar várias aplicações depois de um único sign-in” → SSO.

“Comprovar a identidade usando fatores de categorias diferentes” → MFA.

“Remover a senha tradicional como credencial principal” → Passwordless.

Um mesmo fluxo pode combinar os três quando a implementação oferece suporte.$content$,null,11),
('7b170000-0000-4000-8000-000000000020','mfa-and-passwordless','exam_tip','Identifique o objetivo central',
$content$Não escolha pela palavra “segurança” isoladamente. Procure o objetivo: menos logins aponta para SSO; múltiplos fatores aponta para MFA; ausência da senha tradicional aponta para Passwordless.$content$,null,12),
('7b170000-0000-4000-8000-000000000021','mfa-and-passwordless','summary','Resumo para memória ativa',null,
'{"items":["MFA usa dois ou mais fatores de categorias diferentes.","As categorias são algo que você sabe, possui ou é.","Duas senhas ou dois prompts não constituem MFA.","Passwordless autentica sem usar a senha tradicional como credencial principal.","Passkeys, Windows Hello for Business e Authenticator passwordless são exemplos.","SSO, MFA e Passwordless podem ser combinados."]}'::jsonb,13),

('7b170000-0000-4000-8000-000000000022','external-identities','explanation','O que são External Identities?',
$content$Microsoft Entra External ID permite colaboração e acesso de usuários externos a aplicações e recursos autorizados de uma organização.

Em um cenário B2B, um parceiro pode usar sua identidade de origem para colaborar, enquanto a organização que possui o recurso mantém um objeto e aplica os controles de acesso necessários.$content$,null,1),
('7b170000-0000-4000-8000-000000000023','external-identities','important','Home tenant, resource tenant e guest',
$content$**Home tenant** é a organização ou provedor de origem que autentica o usuário externo.

**Resource tenant** é a organização que possui a aplicação ou o recurso acessado.

**Guest/external user** é o colaborador externo representado no resource tenant e autorizado a acessar apenas o necessário.$content$,null,2),
('7b170000-0000-4000-8000-000000000024','external-identities','example','Consultora da Fabrikam na Contoso',
$content$A Contoso precisa permitir que uma consultora da Fabrikam acesse um aplicativo interno. Em vez de administrar para ela uma senha corporativa completamente separada, a Contoso usa colaboração B2B para que a consultora autentique com sua identidade de origem, conforme a configuração suportada.

Fabrikam é o home tenant; Contoso é o resource tenant.$content$,null,3),
('7b170000-0000-4000-8000-000000000025','external-identities','explanation','Colaboração sem transformar o parceiro em funcionário',
$content$A presença de um objeto guest no diretório de recursos permite reconhecer e controlar a colaboração. Isso não transforma automaticamente o parceiro em usuário interno comum.

O resource tenant continua decidindo quais aplicações e dados serão disponibilizados ao colaborador externo.$content$,null,4),
('7b170000-0000-4000-8000-000000000026','external-identities','important','Autenticação de origem e acesso no recurso',
$content$No cenário conceitual B2B, o usuário normalmente autentica por sua organização ou provedor de identidade de origem. O resource tenant verifica a colaboração e concede somente o acesso autorizado ao recurso.

Configuração cross-tenant, políticas detalhadas e protocolos ficam fora desta Lesson.$content$,null,5),
('7b170000-0000-4000-8000-000000000027','external-identities','exam_trap','External não significa irrestrito ou administrador',
$content$External user não é automaticamente um usuário interno comum. External Identity não concede acesso irrestrito. Guest não recebe privilégios administrativos automaticamente.

A identidade externa deve receber apenas o acesso necessário para a colaboração e esse acesso deve ser administrado ao longo do tempo.$content$,null,6),
('7b170000-0000-4000-8000-000000000028','external-identities','example','Fornecedor com acesso limitado',
$content$Um fornecedor precisa consultar somente o dashboard do seu projeto. A organização adiciona a identidade externa para colaboração e limita o acesso ao aplicativo necessário.

Convidar a identidade e autorizar ações são decisões relacionadas, mas distintas.$content$,null,7),
('7b170000-0000-4000-8000-000000000029','external-identities','exam_tip','Procure colaboração entre organizações',
$content$Parceiro, fornecedor ou consultor que usa sua identidade de origem para acessar um recurso de outra organização aponta para Microsoft Entra External ID e colaboração B2B.

Não conclua que todo convidado é administrador ou que a colaboração remove controles de acesso.$content$,null,8),
('7b170000-0000-4000-8000-000000000030','external-identities','exam_trap','B2B não é uma conta interna sem limites',
$content$Um objeto guest pode existir no resource tenant, mas representa uma relação de colaboração externa. O acesso depende do que foi autorizado e pode ser revisado ou removido.

Detalhes de configuração de cross-tenant access ficam fora do AZ-900 nesta Lesson.$content$,null,9),
('7b170000-0000-4000-8000-000000000031','external-identities','summary','Resumo para memória ativa',null,
'{"items":["External ID permite colaboração com usuários externos.","B2B pode permitir que o parceiro use sua identidade de origem.","Home tenant autentica a identidade; resource tenant possui o recurso.","Guest/external user não é automaticamente um usuário interno ou administrador.","Acesso externo deve ser limitado ao necessário e administrado ao longo do tempo."]}'::jsonb,10);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.display_order,true
from stage_893_block_seed seed join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug=seed.lesson_slug;

create temporary table stage_893_flashcard_seed(
  id uuid primary key,lesson_slug text not null,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_893_flashcard_seed values
('7e400000-0000-4000-8000-000000000005','single-sign-on','Qual é o objetivo principal do SSO?','Permitir acesso a várias aplicações integradas sem repetir credenciais em cada uma após uma autenticação suportada.','Menos logins repetidos.',1),
('7e400000-0000-4000-8000-000000000006','single-sign-on','Usar a mesma senha em vários sistemas é SSO?','Não. Isso continua sendo autenticação separada em cada sistema.','Integração, não senha repetida.',2),
('7e400000-0000-4000-8000-000000000007','single-sign-on','SSO elimina a autenticação?','Não. O usuário é autenticado e a identidade é reconhecida pelas aplicações integradas.','Um sign-in ainda existe.',3),
('7e400000-0000-4000-8000-000000000008','single-sign-on','SSO e MFA são o mesmo conceito?','Não. SSO reduz logins repetidos; MFA exige fatores independentes.','Experiência versus fatores.',4),
('7e400000-0000-4000-8000-000000000009','mfa-and-passwordless','O que caracteriza MFA?','Dois ou mais fatores de autenticação de categorias diferentes.','Fatores independentes.',1),
('7e400000-0000-4000-8000-000000000010','mfa-and-passwordless','Quais são as categorias conceituais de fatores?','Algo que você sabe, algo que possui e algo que é.','Know, have, are.',2),
('7e400000-0000-4000-8000-000000000011','mfa-and-passwordless','Duas senhas constituem MFA?','Não. Ambas pertencem à categoria algo que você sabe.','Duas evidências da mesma categoria.',3),
('7e400000-0000-4000-8000-000000000012','mfa-and-passwordless','O que é Passwordless Authentication?','Autenticação sem usar a senha tradicional como credencial principal do usuário.','Sem senha, com verificação.',4),
('7e400000-0000-4000-8000-000000000013','mfa-and-passwordless','Quais são exemplos de métodos passwordless?','Passkeys/FIDO2, Windows Hello for Business e Microsoft Authenticator passwordless.','Não é preciso decorar todos.',5),
('7e400000-0000-4000-8000-000000000014','mfa-and-passwordless','Passwordless significa ausência de autenticação?','Não. A identidade continua sendo verificada por um mecanismo sem senha tradicional.','Não é acesso anônimo.',6),
('7e400000-0000-4000-8000-000000000015','mfa-and-passwordless','SSO, MFA e Passwordless podem ser combinados?','Sim. Eles resolvem objetivos diferentes e não são mutuamente exclusivos.','Menos logins, fatores, sem senha.',7),
('7e400000-0000-4000-8000-000000000016','external-identities','Para que serve Microsoft Entra External ID em B2B?','Para permitir colaboração autorizada de parceiros e convidados usando identidades externas.','Colaboração entre organizações.',1),
('7e400000-0000-4000-8000-000000000017','external-identities','O que é o home tenant de um usuário externo?','É a organização ou provedor de origem que autentica esse usuário.','Origem da identidade.',2),
('7e400000-0000-4000-8000-000000000018','external-identities','O que é o resource tenant em colaboração B2B?','É a organização que possui a aplicação ou o recurso acessado.','Destino do acesso.',3),
('7e400000-0000-4000-8000-000000000019','external-identities','Guest recebe acesso irrestrito ou privilégios administrativos automaticamente?','Não. O usuário externo recebe somente o acesso autorizado para a colaboração.','Guest não é admin.',4),
('7e400000-0000-4000-8000-000000000020','external-identities','Usuário externo é o mesmo que funcionário interno comum?','Não. Ele representa uma relação de colaboração externa, mesmo quando possui um objeto guest no resource tenant.','Externo continua externo.',5);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_893_flashcard_seed seed join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000005' and lesson.slug=seed.lesson_slug;

create temporary table stage_893_question_seed(
  id uuid primary key,lesson_slug text not null,question_text text not null,difficulty text not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_893_question_seed values
('68000000-0000-4000-8000-000000000085','single-sign-on','Qual é o principal objetivo do Single Sign-On?','easy','SSO permite acessar múltiplas aplicações integradas após uma autenticação suportada, reduzindo prompts de login repetidos.',1),
('68000000-0000-4000-8000-000000000086','single-sign-on','Um funcionário digita a mesma senha separadamente em três aplicações. Isso caracteriza SSO?','easy','Não. Reutilizar uma senha ainda exige autenticação independente em cada aplicação e não constitui um fluxo integrado de SSO.',2),
('68000000-0000-4000-8000-000000000087','single-sign-on','Uma empresa quer que usuários autentiquem uma vez no Microsoft Entra ID e abram aplicações integradas sem novos prompts de credenciais. Qual conceito atende?','medium','Single Sign-On centraliza a experiência de autenticação e reduz logins repetidos nas aplicações integradas.',3),
('68000000-0000-4000-8000-000000000088','single-sign-on','Qual comparação entre SSO e MFA está correta?','medium','SSO reduz logins repetidos entre aplicações; MFA exige múltiplos fatores para comprovar identidade. Eles podem ser combinados.',4),
('68000000-0000-4000-8000-000000000089','single-sign-on','Uma solução precisa reduzir logins repetidos sem assumir que todos os usuários terão acesso a todas as aplicações. Qual interpretação é correta?','hard','SSO pode reutilizar a autenticação entre aplicações integradas, mas cada aplicação ainda pode avaliar o acesso autorizado do usuário.',5),
('68000000-0000-4000-8000-000000000090','mfa-and-passwordless','O que caracteriza uma autenticação multifator?','easy','MFA exige dois ou mais fatores de categorias diferentes, como algo que o usuário sabe e algo que possui.',1),
('68000000-0000-4000-8000-000000000091','mfa-and-passwordless','Qual opção é um exemplo de Passwordless Authentication?','easy','Uma passkey pode autenticar o usuário sem usar a senha tradicional como credencial principal.',2),
('68000000-0000-4000-8000-000000000092','mfa-and-passwordless','Uma aplicação solicita duas senhas diferentes ao usuário. Isso atende ao conceito de MFA?','medium','Não. As duas evidências pertencem à categoria algo que o usuário sabe; MFA exige categorias diferentes.',3),
('68000000-0000-4000-8000-000000000093','mfa-and-passwordless','Uma empresa quer eliminar a senha tradicional do sign-in, mantendo a verificação de identidade. Qual abordagem deve considerar?','medium','Passwordless Authentication usa métodos como passkeys, Windows Hello for Business ou Authenticator passwordless para verificar a identidade sem senha tradicional.',4),
('68000000-0000-4000-8000-000000000094','mfa-and-passwordless','Uma organização deseja acesso a várias aplicações, fatores independentes e ausência de senha tradicional. Qual análise é correta?','hard','SSO, MFA e Passwordless têm objetivos diferentes e podem ser combinados quando a implementação oferece suporte.',5),
('68000000-0000-4000-8000-000000000095','external-identities','Qual é a finalidade de Microsoft Entra External ID em um cenário B2B?','easy','External ID permite colaboração autorizada com parceiros e convidados externos.',1),
('68000000-0000-4000-8000-000000000096','external-identities','Em colaboração B2B, o que representa o resource tenant?','easy','É a organização que possui a aplicação ou o recurso que será acessado pelo usuário externo.',2),
('68000000-0000-4000-8000-000000000097','external-identities','Uma consultora da Fabrikam precisa acessar um aplicativo da Contoso usando sua identidade de origem. Qual recurso conceitual atende?','medium','Microsoft Entra External ID com colaboração B2B permite que um parceiro use sua identidade externa para acessar recursos autorizados.',3),
('68000000-0000-4000-8000-000000000098','external-identities','Qual afirmação sobre um guest user está correta?','medium','Um guest representa colaboração externa e recebe somente o acesso autorizado; não se torna administrador automaticamente.',4),
('68000000-0000-4000-8000-000000000099','external-identities','Fabrikam autentica sua consultora, enquanto Contoso possui o aplicativo e limita o acesso dela. Como os papéis são classificados?','hard','Fabrikam é o home tenant da identidade; Contoso é o resource tenant que possui o recurso e controla a colaboração.',5);
insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_893_question_seed seed join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure architecture and services'
join public.topics topic on topic.domain_id=domain.id and topic.id='32000000-0000-4000-8000-000000000005'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug=seed.lesson_slug;

create temporary table stage_893_option_seed(
  id uuid primary key,question_id uuid not null,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_893_option_seed values
('7f170000-0000-4000-8000-000000000001','68000000-0000-4000-8000-000000000085','Reduzir logins repetidos entre aplicações integradas.',true,'Correta. Esse é o objetivo central do SSO.',1),
('7f170000-0000-4000-8000-000000000002','68000000-0000-4000-8000-000000000085','Exigir sempre três fatores biométricos.',false,'Isso não descreve SSO.',2),
('7f170000-0000-4000-8000-000000000003','68000000-0000-4000-8000-000000000085','Remover toda forma de autenticação.',false,'SSO ainda depende de autenticação.',3),
('7f170000-0000-4000-8000-000000000004','68000000-0000-4000-8000-000000000085','Conceder acesso irrestrito a todas as aplicações.',false,'SSO não elimina autorização.',4),
('7f170000-0000-4000-8000-000000000005','68000000-0000-4000-8000-000000000086','Não; são três autenticações separadas com uma senha reutilizada.',true,'Correta. Credenciais iguais não criam SSO.',1),
('7f170000-0000-4000-8000-000000000006','68000000-0000-4000-8000-000000000086','Sim; qualquer senha igual em sistemas diferentes é SSO.',false,'SSO exige um fluxo integrado.',2),
('7f170000-0000-4000-8000-000000000007','68000000-0000-4000-8000-000000000086','Sim; isso transforma automaticamente a senha em MFA.',false,'Uma única senha não constitui MFA.',3),
('7f170000-0000-4000-8000-000000000008','68000000-0000-4000-8000-000000000086','Não; porque SSO só funciona sem identidade.',false,'SSO usa uma identidade autenticada.',4),
('7f170000-0000-4000-8000-000000000009','68000000-0000-4000-8000-000000000087','Single Sign-On.',true,'Correta. O requisito é autenticar uma vez e acessar aplicações integradas.',1),
('7f170000-0000-4000-8000-000000000010','68000000-0000-4000-8000-000000000087','Multifactor Authentication.',false,'MFA trata de fatores, não de reduzir logins entre apps.',2),
('7f170000-0000-4000-8000-000000000011','68000000-0000-4000-8000-000000000087','Microsoft Entra Domain Services.',false,'Domain Services atende protocolos tradicionais.',3),
('7f170000-0000-4000-8000-000000000012','68000000-0000-4000-8000-000000000087','Azure Files.',false,'Azure Files é armazenamento.',4),
('7f170000-0000-4000-8000-000000000013','68000000-0000-4000-8000-000000000088','SSO reduz logins; MFA usa múltiplos fatores.',true,'Correta. Os objetivos são diferentes.',1),
('7f170000-0000-4000-8000-000000000014','68000000-0000-4000-8000-000000000088','SSO e MFA são sinônimos.',false,'Os conceitos não são sinônimos.',2),
('7f170000-0000-4000-8000-000000000015','68000000-0000-4000-8000-000000000088','SSO exige duas senhas; MFA elimina logins.',false,'As descrições estão incorretas.',3),
('7f170000-0000-4000-8000-000000000016','68000000-0000-4000-8000-000000000088','SSO e MFA não podem coexistir.',false,'Eles podem ser combinados.',4),
('7f170000-0000-4000-8000-000000000017','68000000-0000-4000-8000-000000000089','SSO reduz prompts, mas cada app ainda avalia acesso autorizado.',true,'Correta. SSO não concede acesso irrestrito.',1),
('7f170000-0000-4000-8000-000000000018','68000000-0000-4000-8000-000000000089','SSO concede acesso a toda aplicação existente.',false,'Acesso ainda depende de autorização.',2),
('7f170000-0000-4000-8000-000000000019','68000000-0000-4000-8000-000000000089','SSO elimina identidade e autenticação.',false,'SSO depende de identidade autenticada.',3),
('7f170000-0000-4000-8000-000000000020','68000000-0000-4000-8000-000000000089','SSO exige compartilhar a senha com cada aplicação.',false,'Integração evita essa interpretação.',4),
('7f170000-0000-4000-8000-000000000021','68000000-0000-4000-8000-000000000090','Dois ou mais fatores de categorias diferentes.',true,'Correta. A independência das categorias caracteriza MFA.',1),
('7f170000-0000-4000-8000-000000000022','68000000-0000-4000-8000-000000000090','Duas senhas digitadas em sequência.',false,'As duas pertencem à mesma categoria.',2),
('7f170000-0000-4000-8000-000000000023','68000000-0000-4000-8000-000000000090','O mesmo login solicitado duas vezes.',false,'Repetir um prompt não cria fatores.',3),
('7f170000-0000-4000-8000-000000000024','68000000-0000-4000-8000-000000000090','Uma aplicação acessada por SSO.',false,'SSO não implica MFA automaticamente.',4),
('7f170000-0000-4000-8000-000000000025','68000000-0000-4000-8000-000000000091','Entrar usando uma passkey compatível.',true,'Correta. Passkey é um exemplo passwordless.',1),
('7f170000-0000-4000-8000-000000000026','68000000-0000-4000-8000-000000000091','Digitar a mesma senha em duas aplicações.',false,'Isso continua dependente da senha.',2),
('7f170000-0000-4000-8000-000000000027','68000000-0000-4000-8000-000000000091','Compartilhar uma senha com colegas.',false,'Isso é inseguro e não passwordless.',3),
('7f170000-0000-4000-8000-000000000028','68000000-0000-4000-8000-000000000091','Remover toda verificação de identidade.',false,'Passwordless mantém autenticação.',4),
('7f170000-0000-4000-8000-000000000029','68000000-0000-4000-8000-000000000092','Não; ambos são algo que o usuário sabe.',true,'Correta. MFA exige categorias diferentes.',1),
('7f170000-0000-4000-8000-000000000030','68000000-0000-4000-8000-000000000092','Sim; qualquer número de senhas constitui MFA.',false,'Quantidade não substitui categorias independentes.',2),
('7f170000-0000-4000-8000-000000000031','68000000-0000-4000-8000-000000000092','Sim; duas senhas tornam o fluxo passwordless.',false,'O fluxo continua dependente de senhas.',3),
('7f170000-0000-4000-8000-000000000032','68000000-0000-4000-8000-000000000092','Não; porque MFA só aceita biometria.',false,'MFA pode combinar diferentes categorias.',4),
('7f170000-0000-4000-8000-000000000033','68000000-0000-4000-8000-000000000093','Passwordless Authentication.',true,'Correta. O objetivo é autenticar sem senha tradicional.',1),
('7f170000-0000-4000-8000-000000000034','68000000-0000-4000-8000-000000000093','Reutilização de senha.',false,'Isso mantém e amplia dependência da senha.',2),
('7f170000-0000-4000-8000-000000000035','68000000-0000-4000-8000-000000000093','Somente Single Sign-On.',false,'SSO não remove necessariamente a senha.',3),
('7f170000-0000-4000-8000-000000000036','68000000-0000-4000-8000-000000000093','Anonymous access.',false,'Passwordless ainda verifica identidade.',4),
('7f170000-0000-4000-8000-000000000037','68000000-0000-4000-8000-000000000094','Os três conceitos podem ser combinados.',true,'Correta. Eles resolvem objetivos diferentes.',1),
('7f170000-0000-4000-8000-000000000038','68000000-0000-4000-8000-000000000094','SSO impede o uso de MFA.',false,'SSO e MFA podem coexistir.',2),
('7f170000-0000-4000-8000-000000000039','68000000-0000-4000-8000-000000000094','Passwordless elimina a necessidade de verificar identidade.',false,'Passwordless continua autenticando.',3),
('7f170000-0000-4000-8000-000000000040','68000000-0000-4000-8000-000000000094','MFA significa apenas pedir o login novamente.',false,'MFA exige fatores independentes.',4),
('7f170000-0000-4000-8000-000000000041','68000000-0000-4000-8000-000000000095','Permitir colaboração autorizada com usuários externos.',true,'Correta. Esse é o cenário B2B.',1),
('7f170000-0000-4000-8000-000000000042','68000000-0000-4000-8000-000000000095','Transformar todo convidado em administrador.',false,'Guest não é administrador automaticamente.',2),
('7f170000-0000-4000-8000-000000000043','68000000-0000-4000-8000-000000000095','Fornecer armazenamento de objetos.',false,'Esse é um requisito de storage.',3),
('7f170000-0000-4000-8000-000000000044','68000000-0000-4000-8000-000000000095','Criar redes virtuais entre empresas.',false,'External ID trata de identidade e colaboração.',4),
('7f170000-0000-4000-8000-000000000045','68000000-0000-4000-8000-000000000096','A organização que possui o recurso acessado.',true,'Correta. Esse é o resource tenant.',1),
('7f170000-0000-4000-8000-000000000046','68000000-0000-4000-8000-000000000096','A organização de origem que autentica o usuário.',false,'Essa é o home tenant.',2),
('7f170000-0000-4000-8000-000000000047','68000000-0000-4000-8000-000000000096','Um dispositivo de autenticação.',false,'Tenant é uma instância organizacional de identidade.',3),
('7f170000-0000-4000-8000-000000000048','68000000-0000-4000-8000-000000000096','Uma categoria de MFA.',false,'Resource tenant não é fator.',4),
('7f170000-0000-4000-8000-000000000049','68000000-0000-4000-8000-000000000097','Microsoft Entra External ID com B2B.',true,'Correta. O cenário é colaboração externa.',1),
('7f170000-0000-4000-8000-000000000050','68000000-0000-4000-8000-000000000097','Azure Data Box.',false,'Data Box transfere dados fisicamente.',2),
('7f170000-0000-4000-8000-000000000051','68000000-0000-4000-8000-000000000097','Microsoft Entra Domain Services.',false,'Domain Services atende domínio tradicional.',3),
('7f170000-0000-4000-8000-000000000052','68000000-0000-4000-8000-000000000097','Azure DNS.',false,'DNS não gerencia colaboração B2B.',4),
('7f170000-0000-4000-8000-000000000053','68000000-0000-4000-8000-000000000098','Representa colaboração externa com acesso autorizado.',true,'Correta. Guest não recebe acesso irrestrito.',1),
('7f170000-0000-4000-8000-000000000054','68000000-0000-4000-8000-000000000098','É sempre administrador do resource tenant.',false,'Guest não é admin automaticamente.',2),
('7f170000-0000-4000-8000-000000000055','68000000-0000-4000-8000-000000000098','Torna-se automaticamente funcionário interno.',false,'A colaboração continua externa.',3),
('7f170000-0000-4000-8000-000000000056','68000000-0000-4000-8000-000000000098','Pode acessar todos os recursos sem autorização.',false,'Acesso continua limitado ao autorizado.',4),
('7f170000-0000-4000-8000-000000000057','68000000-0000-4000-8000-000000000099','Fabrikam é home tenant; Contoso é resource tenant.',true,'Correta. Origem autentica; destino possui o recurso.',1),
('7f170000-0000-4000-8000-000000000058','68000000-0000-4000-8000-000000000099','Contoso é home tenant; Fabrikam é resource tenant.',false,'Os papéis estão invertidos.',2),
('7f170000-0000-4000-8000-000000000059','68000000-0000-4000-8000-000000000099','Ambas são home tenant e não existe resource tenant.',false,'O cenário possui origem e organização do recurso.',3),
('7f170000-0000-4000-8000-000000000060','68000000-0000-4000-8000-000000000099','Guest é o tenant e Contoso é um fator de autenticação.',false,'Guest é usuário externo; tenant e fator são conceitos diferentes.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_893_option_seed;

do $$
declare lesson_record record;
begin
  for lesson_record in
    select id,slug,
      case slug when 'single-sign-on' then 8 when 'mfa-and-passwordless' then 13 else 10 end as expected_blocks,
      case slug when 'single-sign-on' then 4 when 'mfa-and-passwordless' then 7 else 5 end as expected_cards
    from public.lessons
    where topic_id='32000000-0000-4000-8000-000000000005'
      and slug in ('single-sign-on','mfa-and-passwordless','external-identities')
  loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_record.id and is_published)
        <>lesson_record.expected_blocks
      or exists(select 1 from public.visual_experiences where lesson_id=lesson_record.id)
      or (select count(*) from public.questions where lesson_id=lesson_record.id and is_published)<>5
      or (select count(*) from public.flashcards where lesson_id=lesson_record.id and is_published)<>lesson_record.expected_cards then
      raise exception '8.9.3 final content or Question count is invalid for %',lesson_record.slug;
    end if;
    if exists(select 1 from public.questions question left join public.question_options option on option.question_id=question.id
      where question.lesson_id=lesson_record.id and question.is_published group by question.id
      having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1) then
      raise exception '8.9.3 Question Options are invalid for %',lesson_record.slug;
    end if;
  end loop;
end; $$;

commit;

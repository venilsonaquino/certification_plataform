begin;

do $$
declare
  target_lesson_id uuid;
begin
  select lesson.id into strict target_lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id=lesson.topic_id
  join public.domains domain on domain.id=topic.domain_id
  join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900'
    and domain.title='Describe Azure architecture and services'
    and topic.id='32000000-0000-4000-8000-000000000005'
    and topic.title='Identity, Access and Security'
    and lesson.slug='entra-id-and-domain-services';

  if exists(select 1 from public.lesson_content_blocks where lesson_id=target_lesson_id) then
    raise exception '8.9.2 expected the target Lesson to have no Content Blocks';
  end if;
  if (select count(*) from public.visual_experiences where lesson_id=target_lesson_id)<>1
    or not exists(select 1 from public.visual_experiences
      where id='76000000-0000-4000-8000-000000000003' and lesson_id=target_lesson_id and is_published) then
    raise exception '8.9.2 expected the existing published Entra ID visual';
  end if;
  if (select count(*) from public.flashcards where lesson_id=target_lesson_id and is_published)<>3 then
    raise exception '8.9.2 expected three historical Flashcards';
  end if;
  if exists(select 1 from public.questions where lesson_id=target_lesson_id) then
    raise exception '8.9.2 expected no existing Questions for the target Lesson';
  end if;
end; $$;

update public.lessons
set estimated_minutes=12
where topic_id='32000000-0000-4000-8000-000000000005'
  and slug='entra-id-and-domain-services';

create temporary table stage_892_block_seed(
  id uuid primary key,
  type text not null,
  title text,
  content text,
  config jsonb,
  visual_experience_id uuid,
  display_order integer not null
) on commit drop;

insert into stage_892_block_seed values
('7b160000-0000-4000-8000-000000000001','explanation','O que é Microsoft Entra ID?',
$content$Microsoft Entra ID é o serviço cloud de identity and access management da Microsoft. Ele permite gerenciar identidades, autenticar usuários e sistemas e apoiar o controle de acesso a aplicações e recursos.

Azure, Microsoft 365 e aplicações integradas podem usar identidades do Entra ID. Em nível AZ-900, reconheça o serviço e sua finalidade; configuração detalhada de protocolos, políticas ou licenciamento fica fora desta Lesson.$content$,null,null,1),
('7b160000-0000-4000-8000-000000000002','important','Identidades e objetos do diretório',
$content$Um diretório Microsoft Entra pode representar users, groups, applications e devices.

- **Users** representam pessoas ou contas usadas por sistemas.
- **Groups** ajudam a organizar identidades.
- **Applications** representam aplicações que participam do acesso.
- **Devices** representam dispositivos registrados ou associados ao diretório.

Esses objetos apoiam identity and access management; não é necessário aprender sua configuração administrativa nesta etapa.$content$,null,null,2),
('7b160000-0000-4000-8000-000000000003','explanation','Microsoft Entra tenant',
$content$Um Microsoft Entra tenant é uma instância, ou diretório dedicado, do Microsoft Entra ID associado a uma organização.

Contoso
→ Microsoft Entra tenant
  → Users
  → Groups
  → Applications
  → Devices

O tenant estabelece o limite organizacional do diretório. Cross-tenant access, tenant restrictions, configuração B2B e administrative units ficam fora desta Lesson.$content$,null,null,3),
('7b160000-0000-4000-8000-000000000004','exam_trap','Tenant não é Azure Subscription',
$content$Microsoft Entra tenant e Azure Subscription são conceitos diferentes. O tenant é o diretório de identidades; a subscription é um contêiner de cobrança e gerenciamento de recursos Azure.

Eles podem possuir relações — por exemplo, uma subscription confia em um tenant para identidades —, mas não são sinônimos nem representam a mesma fronteira.$content$,null,null,4),
('7b160000-0000-4000-8000-000000000005','visual_experience','Fluxo de autenticação com Microsoft Entra ID',null,null,'76000000-0000-4000-8000-000000000003',5),
('7b160000-0000-4000-8000-000000000006','explanation','Identity, authentication e authorization',
$content$**Identity** descreve quem é o usuário, aplicação, dispositivo ou sistema.

**Authentication** comprova essa identidade, por exemplo durante um sign-in.

**Authorization** determina o que a identidade autenticada pode fazer ou acessar.

Microsoft Entra ID gerencia identidades e participa da autenticação. Regras específicas de autorização podem ser aplicadas por mecanismos diferentes, que serão estudados em Lessons posteriores.$content$,null,null,6),
('7b160000-0000-4000-8000-000000000007','exam_trap','Authentication não é Authorization',
$content$Conseguir entrar prova que a identidade foi autenticada; isso não garante permissão para executar qualquer ação.

Identity → quem é.

Authentication → comprovar quem é.

Authorization → decidir o que pode fazer.

Não escolha uma tecnologia de autenticação quando o requisito pergunta apenas por permissões, nem assuma que autenticar concede acesso irrestrito.$content$,null,null,7),
('7b160000-0000-4000-8000-000000000008','example','Aplicação moderna usando identidade cloud',
$content$Uma aplicação SaaS moderna precisa autenticar colaboradores da Contoso. Ela integra o sign-in ao Microsoft Entra ID e reconhece as identidades do tenant da organização.

O Entra ID fornece a base de identidade e autenticação. A aplicação ainda avalia quais funcionalidades cada identidade poderá usar.$content$,null,null,8),
('7b160000-0000-4000-8000-000000000009','explanation','O que é Microsoft Entra Domain Services?',
$content$Microsoft Entra Domain Services fornece serviços de domínio gerenciados compatíveis com necessidades tradicionais de domínio. Ele atende workloads que dependem de recursos como domain join, Group Policy, LDAP, Kerberos e NTLM.

O serviço integra-se ao Microsoft Entra ID, mas continua sendo um serviço diferente. Seu objetivo comum é dar suporte a aplicações e workloads legados que ainda não usam autenticação cloud moderna.$content$,null,null,9),
('7b160000-0000-4000-8000-000000000010','important','Domínio gerenciado sem manter Domain Controllers',
$content$A Microsoft implanta e administra a infraestrutura principal e os domain controllers do domínio gerenciado. O cliente não precisa criar VMs com Windows Server, promover controladores de domínio, aplicar patches neles ou manter sua disponibilidade para esse serviço.

Isso não significa ausência de responsabilidade: a organização ainda administra seus workloads, acessos e configurações aplicáveis.$content$,null,null,10),
('7b160000-0000-4000-8000-000000000011','example','Aplicação legada migrada para Azure',
$content$Uma aplicação legada foi migrada para Azure e precisa de LDAP, Kerberos ou NTLM, Group Policy e domain join. Modernizá-la agora não é viável.

Microsoft Entra Domain Services pode fornecer compatibilidade com esses requisitos sem a equipe implantar e manter manualmente domain controllers para o domínio gerenciado. A Lesson não exige configurar nenhum desses protocolos.$content$,null,null,11),
('7b160000-0000-4000-8000-000000000012','important','Microsoft Entra ID versus Domain Services',
$content$| Aspecto | Microsoft Entra ID | Microsoft Entra Domain Services |
| --- | --- | --- |
| Tipo | Cloud IAM | Managed domain services |
| Foco principal | Identidade e autenticação moderna | Compatibilidade com domínio tradicional |
| Domain join tradicional | Não da mesma forma que AD DS | Sim |
| LDAP | Não como AD DS tradicional | Sim |
| Kerberos / NTLM | Não como serviço de domínio tradicional | Sim |
| Group Policy | Não | Sim |
| Domain controllers mantidos pelo cliente | Não | Não |
| Cenário comum | Aplicações modernas e cloud | Aplicações legadas dependentes de AD DS |

Um serviço não substitui completamente o outro. Domain Services integra-se ao Entra ID para atender uma necessidade diferente.$content$,null,null,12),
('7b160000-0000-4000-8000-000000000013','exam_tip','Moderno ou legado?',
$content$Aplicação moderna ou cloud-native que precisa de identidade e autenticação → normalmente Microsoft Entra ID.

Aplicação legada que exige domain join, LDAP, Kerberos/NTLM ou Group Policy → considere Microsoft Entra Domain Services.

Procure o requisito técnico do cenário. A simples presença de uma aplicação no Azure não exige Domain Services.$content$,null,null,13),
('7b160000-0000-4000-8000-000000000014','exam_trap','Quatro confusões que a prova pode explorar',
$content$Microsoft Entra ID não é Active Directory Domain Services simplesmente hospedado na nuvem.

Microsoft Entra Domain Services não é o mesmo serviço que Microsoft Entra ID, embora se integre a ele.

Microsoft Entra Domain Services não equivale a VMs com Windows Server que o cliente administra como domain controllers.

Domain Services não é obrigatório para aplicações modernas; ele é considerado quando requisitos tradicionais de domínio permanecem.$content$,null,null,14),
('7b160000-0000-4000-8000-000000000015','summary','Resumo para memória ativa',null,
'{"items":["Microsoft Entra ID é o serviço cloud de identity and access management da Microsoft.","Um tenant é o diretório dedicado de uma organização e não é uma Azure Subscription.","Identity descreve quem é; authentication comprova; authorization determina o que pode fazer.","Entra Domain Services fornece domain join, Group Policy, LDAP, Kerberos e NTLM gerenciados.","Microsoft mantém os domain controllers do domínio gerenciado.","Entra ID atende identidade moderna; Domain Services atende compatibilidade com workloads legados."]}'::jsonb,null,15);

insert into public.lesson_content_blocks(
  id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published
)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.visual_experience_id,seed.display_order,true
from stage_892_block_seed seed
join public.lessons lesson on lesson.topic_id='32000000-0000-4000-8000-000000000005'
  and lesson.slug='entra-id-and-domain-services';

create temporary table stage_892_flashcard_update(
  id uuid primary key,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_892_flashcard_update values
('70000000-0000-4000-8000-000000000028','Qual é a função principal do Microsoft Entra ID?','Gerenciar identidades e apoiar autenticação e controle de acesso a aplicações e recursos.','Cloud identity and access management.',1),
('70000000-0000-4000-8000-000000000029','Microsoft Entra ID e Microsoft Entra Domain Services são o mesmo serviço?','Não. Entra ID é cloud IAM; Domain Services fornece recursos tradicionais de domínio gerenciados.','Moderno versus compatibilidade legada.',2),
('70000000-0000-4000-8000-000000000030','Quando considerar Microsoft Entra Domain Services?','Quando um workload precisa de domain join, Group Policy, LDAP, Kerberos ou NTLM sem manter domain controllers.','Aplicação legada.',3);
update public.flashcards card
set front_text=seed.front_text,back_text=seed.back_text,hint=seed.hint,display_order=seed.display_order
from stage_892_flashcard_update seed where card.id=seed.id;

create temporary table stage_892_flashcard_seed(
  id uuid primary key,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_892_flashcard_seed values
('7e400000-0000-4000-8000-000000000001','O que é um Microsoft Entra tenant?','É a instância ou diretório dedicado do Microsoft Entra ID de uma organização.','Diretório da organização.',4),
('7e400000-0000-4000-8000-000000000002','Microsoft Entra tenant é o mesmo que Azure Subscription?','Não. Tenant é o diretório de identidades; subscription organiza cobrança e recursos Azure.','Identidade versus recursos/cobrança.',5),
('7e400000-0000-4000-8000-000000000003','Qual é a sequência entre identity, authentication e authorization?','Identity diz quem é; authentication comprova a identidade; authorization determina o que ela pode fazer.','Quem é → comprovar → permitir.',6),
('7e400000-0000-4000-8000-000000000004','Quem mantém os domain controllers do Microsoft Entra Domain Services?','A Microsoft mantém a infraestrutura e os domain controllers do domínio gerenciado.','Serviço gerenciado.',7);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_892_flashcard_seed seed
join public.lessons lesson on lesson.topic_id='32000000-0000-4000-8000-000000000005'
  and lesson.slug='entra-id-and-domain-services';

create temporary table stage_892_question_seed(
  id uuid primary key,question_text text not null,difficulty text not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_892_question_seed values
('68000000-0000-4000-8000-000000000080','Qual descrição representa melhor o Microsoft Entra ID?','easy','Microsoft Entra ID é o serviço cloud de identity and access management usado para gerenciar identidades, autenticar e apoiar o controle de acesso.',1),
('68000000-0000-4000-8000-000000000081','Qual afirmação diferencia corretamente um Microsoft Entra tenant de uma Azure Subscription?','easy','O tenant é o diretório de identidades da organização; a subscription é um contêiner de cobrança e gerenciamento de recursos Azure.',2),
('68000000-0000-4000-8000-000000000082','Uma aplicação SaaS moderna precisa autenticar colaboradores usando as identidades cloud da organização. Qual serviço é o mais alinhado?','medium','Microsoft Entra ID fornece identidade e autenticação cloud para aplicações modernas e serviços como Azure e Microsoft 365.',3),
('68000000-0000-4000-8000-000000000083','Uma aplicação legada migrada para Azure exige LDAP, Kerberos e domain join e não pode ser modernizada agora. Qual serviço deve ser considerado?','medium','Microsoft Entra Domain Services fornece protocolos e recursos tradicionais de domínio gerenciados sem o cliente manter domain controllers.',4),
('68000000-0000-4000-8000-000000000084','Uma empresa usa aplicações modernas e uma aplicação legada que exige Group Policy e NTLM. Qual abordagem conceitual é mais adequada?','hard','Microsoft Entra ID atende identidade e autenticação moderna; Microsoft Entra Domain Services pode atender a compatibilidade tradicional da aplicação legada. Os serviços são distintos e complementares no cenário.',5);
insert into public.questions(
  id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order
)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_892_question_seed seed
join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure architecture and services'
join public.topics topic on topic.domain_id=domain.id and topic.id='32000000-0000-4000-8000-000000000005'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug='entra-id-and-domain-services';

create temporary table stage_892_option_seed(
  id uuid primary key,question_id uuid not null,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_892_option_seed values
('7f160000-0000-4000-8000-000000000001','68000000-0000-4000-8000-000000000080','Um serviço cloud de identity and access management.',true,'Correta. Entra ID gerencia identidades e participa de autenticação e acesso.',1),
('7f160000-0000-4000-8000-000000000002','68000000-0000-4000-8000-000000000080','Um serviço gerenciado de bancos de dados relacionais.',false,'Esse é um requisito de dados, não de identidade.',2),
('7f160000-0000-4000-8000-000000000003','68000000-0000-4000-8000-000000000080','Um serviço de armazenamento de objetos.',false,'Object storage não descreve o Entra ID.',3),
('7f160000-0000-4000-8000-000000000004','68000000-0000-4000-8000-000000000080','Uma rede virtual dedicada à organização.',false,'VNet é um recurso de networking.',4),
('7f160000-0000-4000-8000-000000000005','68000000-0000-4000-8000-000000000081','Tenant é o diretório de identidades; subscription organiza cobrança e recursos Azure.',true,'Correta. Os conceitos se relacionam, mas possuem finalidades diferentes.',1),
('7f160000-0000-4000-8000-000000000006','68000000-0000-4000-8000-000000000081','Tenant e subscription são nomes diferentes para o mesmo contêiner.',false,'Tenant e subscription não são sinônimos.',2),
('7f160000-0000-4000-8000-000000000007','68000000-0000-4000-8000-000000000081','Tenant contém apenas recursos físicos; subscription contém apenas usuários.',false,'A descrição inverte e distorce as finalidades.',3),
('7f160000-0000-4000-8000-000000000008','68000000-0000-4000-8000-000000000081','Subscription autentica usuários; tenant define apenas o preço do Azure.',false,'Identidades pertencem ao contexto do tenant; subscription organiza recursos e cobrança.',4),
('7f160000-0000-4000-8000-000000000009','68000000-0000-4000-8000-000000000082','Microsoft Entra ID.',true,'Correta. Ele atende identidade e autenticação cloud moderna.',1),
('7f160000-0000-4000-8000-000000000010','68000000-0000-4000-8000-000000000082','Microsoft Entra Domain Services.',false,'Domain Services é considerado para dependências tradicionais de domínio.',2),
('7f160000-0000-4000-8000-000000000011','68000000-0000-4000-8000-000000000082','Azure VPN Gateway.',false,'VPN Gateway oferece conectividade, não identity management.',3),
('7f160000-0000-4000-8000-000000000012','68000000-0000-4000-8000-000000000082','Azure Storage Explorer.',false,'Storage Explorer é uma ferramenta de gerenciamento de armazenamento.',4),
('7f160000-0000-4000-8000-000000000013','68000000-0000-4000-8000-000000000083','Microsoft Entra Domain Services.',true,'Correta. Ele fornece compatibilidade de domínio gerenciada para o workload legado.',1),
('7f160000-0000-4000-8000-000000000014','68000000-0000-4000-8000-000000000083','Somente Microsoft Entra ID, pois ele oferece LDAP tradicional por padrão.',false,'Entra ID não é um serviço AD DS tradicional com LDAP e domain join da mesma forma.',2),
('7f160000-0000-4000-8000-000000000015','68000000-0000-4000-8000-000000000083','Azure DNS.',false,'DNS não fornece os serviços de domínio exigidos pelo cenário.',3),
('7f160000-0000-4000-8000-000000000016','68000000-0000-4000-8000-000000000083','Azure Files.',false,'File shares não atendem autenticação Kerberos e domain join como serviço de domínio.',4),
('7f160000-0000-4000-8000-000000000017','68000000-0000-4000-8000-000000000084','Usar Entra ID para identidade moderna e considerar Entra Domain Services para a dependência tradicional.',true,'Correta. Cada serviço atende uma necessidade diferente e eles podem coexistir.',1),
('7f160000-0000-4000-8000-000000000018','68000000-0000-4000-8000-000000000084','Substituir todas as aplicações modernas por Domain Services.',false,'Aplicações modernas não exigem automaticamente serviços tradicionais de domínio.',2),
('7f160000-0000-4000-8000-000000000019','68000000-0000-4000-8000-000000000084','Usar apenas Entra ID porque Group Policy e NTLM são recursos nativos equivalentes dele.',false,'Esses recursos tradicionais apontam para Domain Services no cenário descrito.',3),
('7f160000-0000-4000-8000-000000000020','68000000-0000-4000-8000-000000000084','Implantar obrigatoriamente VMs próprias como domain controllers e não usar nenhum serviço gerenciado.',false,'Domain Services evita a manutenção manual de domain controllers para o domínio gerenciado.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_892_option_seed;

do $$
declare target_lesson_id uuid;
begin
  select id into strict target_lesson_id from public.lessons
  where topic_id='32000000-0000-4000-8000-000000000005' and slug='entra-id-and-domain-services';

  if (select count(*) from public.lesson_content_blocks where lesson_id=target_lesson_id and is_published)<>15
    or (select count(*) from public.lesson_content_blocks where lesson_id=target_lesson_id and type='visual_experience'
      and visual_experience_id='76000000-0000-4000-8000-000000000003')<>1 then
    raise exception '8.9.2 final Content Block inventory is invalid';
  end if;
  if (select count(*) from public.flashcards where lesson_id=target_lesson_id and is_published)<>7 then
    raise exception '8.9.2 final Flashcard inventory is invalid';
  end if;
  if (select count(*) from public.questions where lesson_id=target_lesson_id and is_published)<>5
    or (select count(*) from public.questions where lesson_id=target_lesson_id and difficulty='easy')<>2
    or (select count(*) from public.questions where lesson_id=target_lesson_id and difficulty='medium')<>2
    or (select count(*) from public.questions where lesson_id=target_lesson_id and difficulty='hard')<>1 then
    raise exception '8.9.2 final Question inventory is invalid';
  end if;
  if exists(select 1 from public.questions question left join public.question_options option on option.question_id=question.id
    where question.lesson_id=target_lesson_id and question.is_published group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1) then
    raise exception '8.9.2 final Question Options are invalid';
  end if;
end; $$;

commit;

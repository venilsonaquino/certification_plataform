begin;

do $$
declare target_count integer;
begin
  select count(*) into target_count from public.lessons lesson
  join public.topics topic on topic.id=lesson.topic_id join public.domains domain on domain.id=topic.domain_id
  join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900' and domain.title='Describe Azure management and governance'
    and topic.id='33000000-0000-4000-8000-000000000002' and topic.title='Governance and Compliance'
    and lesson.slug in('azure-policy','resource-locks');
  if target_count<>2 then raise exception '9.5.3 expected two existing target Lessons'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000002' and lesson.slug in('azure-policy','resource-locks'))
    or exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000002' and lesson.slug in('azure-policy','resource-locks'))
    or exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000002' and lesson.slug in('azure-policy','resource-locks')) then
    raise exception '9.5.3 expected target Lessons without structured content or practice'; end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000002' and lesson.slug in('azure-policy','resource-locks')) then
    raise exception '9.5.3 must not create or reuse Visual Experiences'; end if;
end; $$;

update public.lessons set estimated_minutes=case slug when 'azure-policy' then 12 else 10 end
where topic_id='33000000-0000-4000-8000-000000000002' and slug in('azure-policy','resource-locks');

create temporary table stage_953_blocks(id uuid primary key,lesson_slug text,type text,title text,content text,config jsonb,display_order integer) on commit drop;
insert into stage_953_blocks values
('7b240000-0000-4000-8000-000000000001','azure-policy','explanation','O que é Azure Policy?',
$c$Azure Policy é um serviço de governança que ajuda a **impor padrões organizacionais e avaliar compliance em escala**. Ele compara propriedades e estado dos recursos Azure com regras de negócio.

Policy trata o estado desejado dos recursos. Não determina principalmente quem pode executar uma ação; esse é o papel do Azure RBAC.$c$,null,1),
('7b240000-0000-4000-8000-000000000002','azure-policy','important','Definition, assignment, scope e compliance',
$c$| Conceito | Papel |
| --- | --- |
| Policy definition | descreve a condição e o efeito da regra |
| Assignment | aplica uma definition ou initiative |
| Scope | define quais recursos serão avaliados |
| Compliance | mostra se o estado avaliado atende à regra |

Fluxo mental: **definition → assignment em um scope → avaliação → estado de compliance**.$c$,null,2),
('7b240000-0000-4000-8000-000000000003','azure-policy','explanation','Scope e hierarquia',
$c$Uma assignment pode alcançar Management Group, Subscription, Resource Group ou recurso. Em geral, recursos abaixo do scope entram na avaliação, respeitando exclusões e detalhes da assignment.

Uma Policy atribuída a uma Subscription pode avaliar Resource Groups e resources abaixo dela. Isso não transforma Policy em RBAC.$c$,null,3),
('7b240000-0000-4000-8000-000000000004','azure-policy','important','Audit versus Deny',
$c$| Effect | Resultado conceitual |
| --- | --- |
| Audit | registra e marca o recurso como não conforme sem bloquear a solicitação |
| Deny | bloqueia criação ou alteração que produziria estado não conforme |

Existem outros effects e remediation, mas AZ-900 exige reconhecer principalmente avaliação, audit e enforcement.$c$,null,4),
('7b240000-0000-4000-8000-000000000005','azure-policy','example','Allowed Locations',
$c$Uma organização atribui uma definition que permite recursos somente em regiões aprovadas. Com `audit`, uma implantação fora da lista pode ser identificada como não conforme. Com `deny`, a criação ou alteração incompatível pode ser bloqueada.$c$,null,5),
('7b240000-0000-4000-8000-000000000006','azure-policy','explanation','Compliance e remediation',
$c$O painel de compliance ajuda a identificar recursos compliant e non-compliant. Alguns effects e remediation tasks podem alterar ou implantar configurações relacionadas, mas Policy não corrige todo recurso automaticamente em qualquer cenário.

Para Fundamentals, reconheça avaliação contínua, visibilidade e possíveis respostas à não conformidade.$c$,null,6),
('7b240000-0000-4000-8000-000000000007','azure-policy','important','Policy versus controles próximos',
$c$| Conceito | Pergunta principal |
| --- | --- |
| Tags | Como classificar recursos com metadados? |
| Azure Policy | O estado/configuração atende às regras? |
| Azure RBAC | Quem pode fazer o quê em qual scope? |
| Resource Locks | Como impedir exclusão ou alteração acidental? |
| Conditional Access | Quais condições de identidade permitem o acesso? |
| Microsoft Purview | Como descobrir, classificar e governar dados? |$c$,null,7),
('7b240000-0000-4000-8000-000000000008','azure-policy','exam_trap','Permissão não garante compliance',
$c$Um usuário pode ter permissão RBAC para criar uma VM e ainda assim receber uma negação de Azure Policy se a configuração violar uma regra atribuída.

RBAC autoriza a ação; Policy avalia o estado resultante. Os controles trabalham juntos.$c$,null,8),
('7b240000-0000-4000-8000-000000000009','azure-policy','exam_trap','Policy não é Tag nem Lock',
$c$Tag registra metadados e não impõe sozinha uma regra. Resource Lock protege contra determinadas exclusões ou alterações, mas não avalia um catálogo de padrões.

Policy pode exigir uma Tag ou restringir regiões; isso não torna Tag ou Lock sinônimos de Policy.$c$,null,9),
('7b240000-0000-4000-8000-000000000010','azure-policy','example','Exigir uma Tag',
$c$Uma Policy pode avaliar se recursos possuem `Environment` e usar um effect adequado para auditar ou ajudar a impor o padrão. A Tag continua sendo o metadado; Policy é o mecanismo que avalia ou aplica a regra.$c$,null,10),
('7b240000-0000-4000-8000-000000000011','azure-policy','exam_tip','Identifique regra sobre estado do recurso',
$c$Cenários sobre regiões permitidas, SKUs autorizados, Tags obrigatórias ou recursos não conformes apontam para Azure Policy. Cenários sobre permissões apontam para RBAC; sinais de login apontam para Conditional Access.$c$,null,11),
('7b240000-0000-4000-8000-000000000012','azure-policy','summary','Resumo para memória ativa',null,
'{"items":["Azure Policy impõe padrões e avalia compliance dos recursos.","Definition descreve regra e effect; assignment aplica a regra a um scope.","Scopes superiores podem alcançar recursos abaixo na hierarquia.","Audit identifica não conformidade; Deny pode bloquear estado não conforme.","Policy avalia estado; RBAC autoriza identidades.","Tags, Locks, Conditional Access e Purview resolvem problemas diferentes."]}'::jsonb,12),

('7b240000-0000-4000-8000-000000000013','resource-locks','explanation','O que são Resource Locks?',
$c$Resource Locks protegem recursos Azure contra exclusão ou alteração acidental. Eles adicionam uma camada de proteção ao management plane mesmo quando uma identidade possui permissões de gerenciamento.

Locks não substituem autorização, Policy ou backup.$c$,null,1),
('7b240000-0000-4000-8000-000000000014','resource-locks','important','Delete e Read-only',
$c$| Portal | Nome técnico | Efeito conceitual |
| --- | --- | --- |
| Delete | `CanNotDelete` | permite leitura e alteração, mas impede exclusão |
| Read-only | `ReadOnly` | permite leitura, mas impede exclusão e atualização |

ReadOnly é mais restritivo que CanNotDelete.$c$,null,2),
('7b240000-0000-4000-8000-000000000015','resource-locks','explanation','Scopes suportados',
$c$Locks podem ser aplicados a uma Subscription, Resource Group ou recurso individual. A escolha do scope determina o alcance da proteção.

Um lock no recurso protege somente aquele alvo; um lock em scope superior pode alcançar recursos filhos.$c$,null,3),
('7b240000-0000-4000-8000-000000000016','resource-locks','important','Herança de Locks',
$c$Quando aplicado em uma Subscription ou Resource Group, o lock é herdado pelos recursos abaixo desse scope. O lock mais restritivo efetivo prevalece quando mais de um lock se aplica.

Mover ou reorganizar recursos não deve ser tratado como forma de ignorar a proteção.$c$,null,4),
('7b240000-0000-4000-8000-000000000017','resource-locks','example','Proteger o banco de produção',
$c$Um banco crítico recebe um lock `CanNotDelete`. Administradores autorizados ainda podem ajustar configurações permitidas, mas precisam remover o lock com a permissão adequada antes de excluir o recurso.$c$,null,5),
('7b240000-0000-4000-8000-000000000018','resource-locks','exam_trap','Owner não ignora o Lock',
$c$Ter a role Owner não permite simplesmente ignorar um Resource Lock. O lock se aplica a usuários autorizados e prevalece sobre suas permissões para a operação bloqueada.

Uma identidade com permissão apropriada pode remover o lock primeiro; isso é diferente de contorná-lo.$c$,null,6),
('7b240000-0000-4000-8000-000000000019','resource-locks','important','Lock versus RBAC, Policy e backup',
$c$| Controle | Finalidade |
| --- | --- |
| Azure RBAC | autorizar ações de identidades em scopes |
| Azure Policy | avaliar ou impor padrões de configuração |
| Resource Locks | impedir exclusão ou alteração acidental |
| Backup | manter cópia recuperável dos dados ou workload |

Esses mecanismos são complementares, não substitutos.$c$,null,7),
('7b240000-0000-4000-8000-000000000020','resource-locks','exam_trap','Lock não é backup',
$c$Um lock reduz risco de operações administrativas acidentais, mas não cria cópia dos dados, não recupera corrupção e não garante disponibilidade.

Proteção contra exclusão e capacidade de recuperação são necessidades diferentes.$c$,null,8),
('7b240000-0000-4000-8000-000000000021','resource-locks','explanation','Management plane e impacto',
$c$Resource Locks atuam principalmente sobre operações enviadas ao Azure Resource Manager, o management plane. O comportamento de operações no data plane pode variar por serviço.

Para o AZ-900, memorize a proteção administrativa e não assuma que um lock substitui controles de acesso aos dados.$c$,null,9),
('7b240000-0000-4000-8000-000000000022','resource-locks','example','ReadOnly pode interromper operações esperadas',
$c$Uma equipe aplica `ReadOnly` a um Resource Group inteiro. Operações de atualização necessárias aos recursos filhos podem falhar porque o lock herdado é mais restritivo do que o pretendido.

Locks devem ser aplicados deliberadamente e testados conforme o serviço.$c$,null,10),
('7b240000-0000-4000-8000-000000000023','resource-locks','exam_tip','Leia a operação que precisa ser impedida',
$c$Se o requisito é impedir somente exclusão, procure `CanNotDelete`. Se também precisa impedir alterações administrativas, procure `ReadOnly`. Se o requisito é recuperar dados depois de perda ou corrupção, procure backup, não Lock.$c$,null,11),
('7b240000-0000-4000-8000-000000000024','resource-locks','summary','Resumo para memória ativa',null,
'{"items":["Resource Locks protegem contra exclusão ou alteração acidental.","CanNotDelete impede exclusão; ReadOnly impede exclusão e atualização.","Locks podem ser aplicados a Subscription, Resource Group ou recurso.","Locks em scopes superiores são herdados pelos recursos filhos.","Owner não ignora um lock; é preciso removê-lo com permissão adequada.","Locks não substituem RBAC, Policy ou backup."]}'::jsonb,12);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,null,seed.display_order,true
from stage_953_blocks seed join public.lessons lesson on lesson.topic_id='33000000-0000-4000-8000-000000000002' and lesson.slug=seed.lesson_slug;

create temporary table stage_953_cards(id uuid primary key,lesson_slug text,front_text text,back_text text,hint text,display_order integer) on commit drop;
insert into stage_953_cards values
('7e430000-0000-4000-8000-000000000001','azure-policy','Qual é a finalidade do Azure Policy?','Impor padrões e avaliar compliance das configurações de recursos Azure.','Estado dos recursos.',1),
('7e430000-0000-4000-8000-000000000002','azure-policy','O que uma Policy definition descreve?','A condição da regra e o effect quando ela é atendida.','Regra.',2),
('7e430000-0000-4000-8000-000000000003','azure-policy','O que uma Policy assignment faz?','Aplica uma definition ou initiative a um scope.','Aplicação da regra.',3),
('7e430000-0000-4000-8000-000000000004','azure-policy','Qual a diferença entre Audit e Deny?','Audit identifica não conformidade sem bloquear; Deny pode bloquear estado não conforme.','Observar versus impedir.',4),
('7e430000-0000-4000-8000-000000000005','azure-policy','Policy e RBAC possuem a mesma finalidade?','Não. Policy avalia estado; RBAC autoriza ações de identidades.','Compliance versus acesso.',5),
('7e430000-0000-4000-8000-000000000006','azure-policy','Tag e Azure Policy são sinônimos?','Não. Tag é metadado; Policy pode avaliar ou impor uma regra sobre Tags.','Dado versus regra.',6),
('7e430000-0000-4000-8000-000000000007','resource-locks','O que CanNotDelete impede?','A exclusão do recurso; leitura e alterações autorizadas continuam possíveis.','Delete lock.',1),
('7e430000-0000-4000-8000-000000000008','resource-locks','O que ReadOnly impede?','Exclusão e atualização administrativa do recurso.','Mais restritivo.',2),
('7e430000-0000-4000-8000-000000000009','resource-locks','Onde Resource Locks podem ser aplicados?','Em Subscription, Resource Group ou recurso individual.','Scope.',3),
('7e430000-0000-4000-8000-000000000010','resource-locks','Locks de Resource Group alcançam recursos filhos?','Sim. Locks aplicados em scopes superiores são herdados.','Herança.',4),
('7e430000-0000-4000-8000-000000000011','resource-locks','A role Owner ignora Resource Locks?','Não. Para uma operação bloqueada, o lock precisa ser removido com permissão adequada.','Permissão não é bypass.',5),
('7e430000-0000-4000-8000-000000000012','resource-locks','Resource Lock substitui backup?','Não. Lock não cria cópia nem recupera dados perdidos ou corrompidos.','Proteção versus recuperação.',6);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true from stage_953_cards seed
join public.lessons lesson on lesson.topic_id='33000000-0000-4000-8000-000000000002' and lesson.slug=seed.lesson_slug;

create temporary table stage_953_questions(id uuid primary key,lesson_slug text,question_text text,difficulty text,explanation text,display_order integer) on commit drop;
insert into stage_953_questions values
('68000000-0000-4000-8000-000000000134','azure-policy','Uma organização quer identificar recursos criados fora das regiões aprovadas sem bloquear inicialmente as implantações. O que deve usar?','easy','Azure Policy com effect Audit pode identificar e marcar recursos não conformes sem bloquear a solicitação.',1),
('68000000-0000-4000-8000-000000000135','azure-policy','Qual elemento aplica uma Policy definition a uma Subscription ou Resource Group?','easy','Uma Policy assignment associa a definition ou initiative ao scope que será avaliado.',2),
('68000000-0000-4000-8000-000000000136','azure-policy','Um desenvolvedor tem permissão RBAC para criar VMs, mas uma configuração é negada por Azure Policy. Isso é contraditório?','medium','Não. RBAC autoriza a ação da identidade; Policy pode bloquear o estado resultante quando ele viola uma regra.',3),
('68000000-0000-4000-8000-000000000137','azure-policy','Uma empresa quer exigir a Tag Environment em novos recursos. Qual interpretação está correta?','medium','A Tag é o metadado; Azure Policy é o mecanismo que pode avaliar ou ajudar a impor o padrão.',4),
('68000000-0000-4000-8000-000000000138','azure-policy','Uma regra deve avaliar recursos em várias Subscriptions de um Management Group e bloquear configurações não conformes. Qual sequência conceitual é adequada?','hard','Definir a regra, atribuí-la no scope apropriado e usar um effect como Deny permite avaliar os recursos descendentes e bloquear estados incompatíveis.',5),
('68000000-0000-4000-8000-000000000139','resource-locks','Uma equipe quer permitir alterações em um banco, mas impedir sua exclusão acidental. Qual lock é adequado?','easy','CanNotDelete permite operações autorizadas de leitura e alteração, mas impede exclusão.',1),
('68000000-0000-4000-8000-000000000140','resource-locks','Qual lock impede exclusão e atualização administrativa?','easy','ReadOnly permite leitura, mas bloqueia exclusão e atualização no management plane.',2),
('68000000-0000-4000-8000-000000000141','resource-locks','Um Resource Group possui CanNotDelete. O que acontece com os recursos filhos?','medium','O lock aplicado no scope superior é herdado e protege os recursos filhos contra exclusão.',3),
('68000000-0000-4000-8000-000000000142','resource-locks','Um usuário com role Owner tenta excluir um recurso protegido por CanNotDelete. Qual resultado é esperado?','medium','O lock prevalece para a operação. A identidade precisa remover o lock com a permissão adequada antes da exclusão.',4),
('68000000-0000-4000-8000-000000000143','resource-locks','Uma empresa aplicou ReadOnly a recursos críticos e concluiu que não precisa mais de backup ou RBAC. Qual análise está correta?','hard','A conclusão está errada: Lock protege operações administrativas específicas, RBAC controla autorização e backup oferece recuperação.',5);
insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_953_questions seed join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure management and governance'
join public.topics topic on topic.domain_id=domain.id and topic.id='33000000-0000-4000-8000-000000000002'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug=seed.lesson_slug;

create temporary table stage_953_options(id uuid primary key,question_id uuid,option_text text,is_correct boolean,explanation text,display_order integer) on commit drop;
insert into stage_953_options values
('7f240000-0000-4000-8000-000000000001','68000000-0000-4000-8000-000000000134','Azure Policy com Audit.',true,'Correta. Audit sinaliza não conformidade sem bloquear.',1),
('7f240000-0000-4000-8000-000000000002','68000000-0000-4000-8000-000000000134','Resource Lock ReadOnly.',false,'Lock impede operações, mas não avalia regiões permitidas.',2),
('7f240000-0000-4000-8000-000000000003','68000000-0000-4000-8000-000000000134','Microsoft Purview.',false,'Purview governa dados, não configurações de recursos.',3),
('7f240000-0000-4000-8000-000000000004','68000000-0000-4000-8000-000000000134','Azure RBAC Reader.',false,'RBAC controla autorização.',4),
('7f240000-0000-4000-8000-000000000005','68000000-0000-4000-8000-000000000135','Policy assignment.',true,'Correta. Assignment aplica a regra ao scope.',1),
('7f240000-0000-4000-8000-000000000006','68000000-0000-4000-8000-000000000135','Resource Tag.',false,'Tag é metadado.',2),
('7f240000-0000-4000-8000-000000000007','68000000-0000-4000-8000-000000000135','Role assignment.',false,'Role assignment pertence ao RBAC.',3),
('7f240000-0000-4000-8000-000000000008','68000000-0000-4000-8000-000000000135','Data Map.',false,'Data Map pertence ao Purview.',4),
('7f240000-0000-4000-8000-000000000009','68000000-0000-4000-8000-000000000136','Não. RBAC autoriza; Policy avalia o estado resultante.',true,'Correta. Os controles são complementares.',1),
('7f240000-0000-4000-8000-000000000010','68000000-0000-4000-8000-000000000136','Sim. Owner sempre ignora Policy.',false,'Permissão não elimina avaliação de Policy.',2),
('7f240000-0000-4000-8000-000000000011','68000000-0000-4000-8000-000000000136','Sim. Policy substitui toda autorização.',false,'Policy não substitui RBAC.',3),
('7f240000-0000-4000-8000-000000000012','68000000-0000-4000-8000-000000000136','Não. A VM foi bloqueada por uma Tag.',false,'Tag sozinha não bloqueia a criação.',4),
('7f240000-0000-4000-8000-000000000013','68000000-0000-4000-8000-000000000137','Tag é metadado; Policy pode avaliar ou impor a regra.',true,'Correta. São papéis distintos.',1),
('7f240000-0000-4000-8000-000000000014','68000000-0000-4000-8000-000000000137','A Tag concede automaticamente compliance.',false,'Tag não executa avaliação.',2),
('7f240000-0000-4000-8000-000000000015','68000000-0000-4000-8000-000000000137','RBAC cria a Tag em todos os recursos.',false,'RBAC controla autorização.',3),
('7f240000-0000-4000-8000-000000000016','68000000-0000-4000-8000-000000000137','Purview bloqueia recursos sem a Tag.',false,'Purview governa dados.',4),
('7f240000-0000-4000-8000-000000000017','68000000-0000-4000-8000-000000000138','Definition, assignment no Management Group e effect Deny.',true,'Correta. A assignment define o alcance e Deny pode bloquear.',1),
('7f240000-0000-4000-8000-000000000018','68000000-0000-4000-8000-000000000138','Tag, lock em cada VM e role Reader.',false,'Isso não representa avaliação central de compliance.',2),
('7f240000-0000-4000-8000-000000000019','68000000-0000-4000-8000-000000000138','Purview Catalog e effect ReadOnly.',false,'Mistura capacidades não relacionadas.',3),
('7f240000-0000-4000-8000-000000000020','68000000-0000-4000-8000-000000000138','Conditional Access sem assignment.',false,'Conditional Access trata acesso de identidades.',4),
('7f240000-0000-4000-8000-000000000021','68000000-0000-4000-8000-000000000139','CanNotDelete.',true,'Correta. Impede exclusão e permite alterações autorizadas.',1),
('7f240000-0000-4000-8000-000000000022','68000000-0000-4000-8000-000000000139','ReadOnly.',false,'ReadOnly também impediria alterações.',2),
('7f240000-0000-4000-8000-000000000023','68000000-0000-4000-8000-000000000139','Azure Policy Audit.',false,'Audit não impede exclusão.',3),
('7f240000-0000-4000-8000-000000000024','68000000-0000-4000-8000-000000000139','Resource Tag Protected=true.',false,'Tag não bloqueia operações.',4),
('7f240000-0000-4000-8000-000000000025','68000000-0000-4000-8000-000000000140','ReadOnly.',true,'Correta. Bloqueia atualização e exclusão.',1),
('7f240000-0000-4000-8000-000000000026','68000000-0000-4000-8000-000000000140','CanNotDelete.',false,'CanNotDelete permite alterações.',2),
('7f240000-0000-4000-8000-000000000027','68000000-0000-4000-8000-000000000140','Reader RBAC.',false,'Role não é Resource Lock.',3),
('7f240000-0000-4000-8000-000000000028','68000000-0000-4000-8000-000000000140','Policy Audit.',false,'Audit sinaliza compliance.',4),
('7f240000-0000-4000-8000-000000000029','68000000-0000-4000-8000-000000000141','Herdam a proteção contra exclusão.',true,'Correta. Locks de scopes superiores são herdados.',1),
('7f240000-0000-4000-8000-000000000030','68000000-0000-4000-8000-000000000141','Não são afetados por locks do grupo.',false,'Locks são herdados.',2),
('7f240000-0000-4000-8000-000000000031','68000000-0000-4000-8000-000000000141','Recebem automaticamente backup.',false,'Lock não cria backup.',3),
('7f240000-0000-4000-8000-000000000032','68000000-0000-4000-8000-000000000141','Perdem todas as roles RBAC.',false,'Lock não remove role assignments.',4),
('7f240000-0000-4000-8000-000000000033','68000000-0000-4000-8000-000000000142','A exclusão é bloqueada até o lock ser removido adequadamente.',true,'Correta. Owner não ignora o lock.',1),
('7f240000-0000-4000-8000-000000000034','68000000-0000-4000-8000-000000000142','A exclusão sempre funciona porque Owner tem acesso total.',false,'Lock prevalece sobre a permissão para essa operação.',2),
('7f240000-0000-4000-8000-000000000035','68000000-0000-4000-8000-000000000142','O recurso é excluído e restaurado por Policy.',false,'Policy não restaura o recurso.',3),
('7f240000-0000-4000-8000-000000000036','68000000-0000-4000-8000-000000000142','A role Owner é convertida em Reader.',false,'O lock bloqueia a operação, não altera a role.',4),
('7f240000-0000-4000-8000-000000000037','68000000-0000-4000-8000-000000000143','Errada: Lock, RBAC e backup atendem necessidades distintas.',true,'Correta. Os controles são complementares.',1),
('7f240000-0000-4000-8000-000000000038','68000000-0000-4000-8000-000000000143','Correta: ReadOnly substitui todos os controles.',false,'Lock não oferece autorização nem recuperação.',2),
('7f240000-0000-4000-8000-000000000039','68000000-0000-4000-8000-000000000143','Errada apenas porque CanNotDelete seria um backup melhor.',false,'Nenhum lock é backup.',3),
('7f240000-0000-4000-8000-000000000040','68000000-0000-4000-8000-000000000143','Correta somente para usuários sem role Owner.',false,'Locks também afetam usuários autorizados, incluindo Owner.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_953_options;

do $$ declare lesson_record record; begin
  for lesson_record in select id from public.lessons where topic_id='33000000-0000-4000-8000-000000000002'
    and slug in('azure-policy','resource-locks') loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_record.id and is_published)<>12
      or (select count(*) from public.flashcards where lesson_id=lesson_record.id and is_published)<>6
      or (select count(*) from public.questions where lesson_id=lesson_record.id and is_published)<>5 then
      raise exception '9.5.3 final inventory is invalid'; end if;
  end loop;
end; $$;

commit;

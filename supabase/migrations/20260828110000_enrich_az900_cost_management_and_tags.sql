begin;

do $$
declare target_count integer;
begin
  select count(*) into target_count from public.lessons lesson
  join public.topics topic on topic.id=lesson.topic_id join public.domains domain on domain.id=topic.domain_id
  join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900' and domain.title='Describe Azure management and governance'
    and topic.id='33000000-0000-4000-8000-000000000001' and topic.title='Cost Management'
    and lesson.slug in ('azure-cost-management','resource-tags');
  if target_count<>2 then raise exception '9.3 expected two existing target Lessons'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000001'
      and lesson.slug in ('azure-cost-management','resource-tags')) then
    raise exception '9.3 expected target Lessons without Content Blocks'; end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000001'
      and lesson.slug in ('azure-cost-management','resource-tags')) then
    raise exception '9.3 must not create or reuse a Visual Experience'; end if;
  if exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000001'
      and lesson.slug in ('azure-cost-management','resource-tags')) then
    raise exception '9.3 expected target Lessons without Flashcards'; end if;
  if (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000001' and lesson.slug='azure-cost-management')<>10
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000001' and lesson.slug='resource-tags')<>0
    or (select count(*) from public.questions where id between '63000000-0000-4000-8000-000000000071'
      and '63000000-0000-4000-8000-000000000080')<>10 then
    raise exception '9.3 historical Question inventory is invalid'; end if;
end; $$;

update public.lessons set estimated_minutes=case slug when 'azure-cost-management' then 12 else 10 end
where topic_id='33000000-0000-4000-8000-000000000001'
  and slug in ('azure-cost-management','resource-tags');

create temporary table stage_93_block_seed(
  id uuid primary key,lesson_slug text not null,type text not null,title text,content text,config jsonb,
  visual_experience_id uuid,display_order integer not null
) on commit drop;
insert into stage_93_block_seed values
('7b210000-0000-4000-8000-000000000001','azure-cost-management','explanation','O que é Azure Cost Management?',
$content$Azure Cost Management reúne capacidades para monitorar, analisar e ajudar a controlar gastos Azure.

Ele ajuda a acompanhar custos, entender onde o dinheiro está sendo gasto, observar tendências, acompanhar budgets e identificar recursos ou categorias responsáveis por custos. Não é necessário dominar práticas FinOps avançadas para o AZ-900.$content$,null,null,1),
('7b210000-0000-4000-8000-000000000002','azure-cost-management','important','Cost Analysis responde onde e como',
$content$Cost Analysis permite analisar custos e consumo do Azure. Em Fundamentals, reconheça perguntas como:

- Qual serviço está gerando maior custo?
- Quanto uma Subscription gastou?
- Quanto o ambiente Production consumiu?
- Como o gasto mudou ao longo do tempo?

Filtros e agrupamentos ajudam a explorar essas respostas sem exigir memorização da interface.$content$,null,null,2),
('7b210000-0000-4000-8000-000000000003','azure-cost-management','example','Investigar um aumento de custo',
$content$O gasto de um Resource Group aumentou em relação ao mês anterior. A equipe usa Cost Analysis para comparar períodos e agrupar ou filtrar os dados até identificar quais recursos ou serviços contribuíram para a mudança.

Análise mostra onde investigar; não prova automaticamente que todo aumento é desperdício.$content$,null,null,3),
('7b210000-0000-4000-8000-000000000004','azure-cost-management','important','Actual Cost versus Forecast',
$content$| Conceito | Significado |
| --- | --- |
| Actual Cost | custo que já ocorreu no período observado |
| Forecast | projeção de gasto futuro baseada nos custos e comportamento observados |

Forecast é uma estimativa, não uma garantia. Não é necessário calcular a projeção na prova.$content$,null,null,4),
('7b210000-0000-4000-8000-000000000005','azure-cost-management','example','Tendência e projeção',
$content$Uma equipe observa o Actual Cost acumulado neste mês e consulta o Forecast para avaliar a projeção até o fim do período.

Se o comportamento da carga mudar, a projeção também pode deixar de representar o resultado final.$content$,null,null,5),
('7b210000-0000-4000-8000-000000000006','azure-cost-management','explanation','Budgets acompanham um valor planejado',
$content$Um Budget define um valor para acompanhar gastos em relação a um limite planejado durante um período.

Ele oferece visibilidade sobre a aproximação ou ultrapassagem do valor. Budget não é a mesma coisa que prever o custo e não substitui a análise dos recursos que geraram o gasto.$content$,null,null,6),
('7b210000-0000-4000-8000-000000000007','azure-cost-management','explanation','Alerts e thresholds',
$content$Budgets podem usar thresholds para gerar alerts ou notificações quando condições definidas forem alcançadas, como uma porcentagem do valor planejado.

A notificação permite que pessoas ou processos responsáveis avaliem e respondam. Detalhes de automação ficam fora desta Lesson.$content$,null,null,7),
('7b210000-0000-4000-8000-000000000008','azure-cost-management','exam_trap','Budget não é hard spending limit',
$content$Criar ou atingir um Budget **não significa desligar recursos automaticamente**.

Budget serve principalmente para acompanhamento, visibilidade e alerts. A equipe ainda precisa investigar e decidir a resposta adequada.$content$,null,null,8),
('7b210000-0000-4000-8000-000000000009','azure-cost-management','important','Pricing Calculator versus Cost Management',
$content$| Ferramenta | Principal uso |
| --- | --- |
| Pricing Calculator | estimar custo de arquitetura ou uso planejado |
| Cost Management / Cost Analysis | acompanhar e analisar gastos no ambiente Azure |

Antes de criar a solução → Pricing Calculator. Durante ou depois do uso dos recursos → Cost Management.$content$,null,null,9),
('7b210000-0000-4000-8000-000000000010','azure-cost-management','exam_trap','Estimate não é Actual Cost',
$content$Pricing Calculator não é Cost Analysis.

Uma **estimate** é uma projeção baseada em hipóteses planejadas. **Actual Cost** representa custo já observado. Forecast também é projeção, mas usa comportamento e custos observados durante a operação.$content$,null,null,10),
('7b210000-0000-4000-8000-000000000011','azure-cost-management','example','Analisar custos por Environment',
$content$Recursos marcados consistentemente com `Environment=Production` podem apoiar filtros ou agrupamentos conceituais para analisar custos do ambiente Production.

Tags ajudam a classificar os recursos, mas a qualidade do relatório depende da aplicação consistente dos metadados.$content$,null,null,11),
('7b210000-0000-4000-8000-000000000012','azure-cost-management','exam_tip','Identifique a pergunta do cenário',
$content$“Quanto provavelmente custará antes da implantação?” aponta para Pricing Calculator. “Quanto gastamos, onde gastamos ou qual é a projeção operacional?” aponta para Cost Management. “Avisar ao atingir um threshold” aponta para Budget com alert.$content$,null,null,12),
('7b210000-0000-4000-8000-000000000013','azure-cost-management','summary','Resumo para memória ativa',null,
'{"items":["Cost Management monitora, analisa e ajuda a controlar gastos Azure.","Cost Analysis mostra onde e como os custos estão sendo gerados.","Actual Cost já ocorreu; Forecast projeta gasto futuro.","Budget acompanha gasto contra um valor planejado.","Alerts notificam thresholds; Budget não desliga recursos automaticamente.","Pricing Calculator planeja estimates; Cost Management acompanha a operação."]}'::jsonb,null,13),

('7b210000-0000-4000-8000-000000000014','resource-tags','explanation','O que são Azure Tags?',
$content$Azure Tags são metadados em formato **key/value** usados para organizar e classificar recursos Azure.

Exemplos: `Environment=Production`, `Department=Finance`, `Project=CertificationPlatform` e `Owner=BackendTeam`. A organização deve definir chaves e valores consistentes para que os metadados sejam úteis.$content$,null,null,1),
('7b210000-0000-4000-8000-000000000015','resource-tags','important','Onde Tags podem ser aplicadas?',
$content$Em nível AZ-900, Tags podem ser aplicadas a:

- resources;
- Resource Groups;
- Subscriptions.

Management Groups não são apresentados como alvo de Tags nesta Lesson. Nem todo recurso oferece necessariamente o mesmo suporte ou comportamento em todos os cenários.$content$,null,null,2),
('7b210000-0000-4000-8000-000000000016','resource-tags','explanation','Organização, filtros e reporting',
$content$Tags ajudam a classificar recursos por ambiente, departamento, projeto, responsável ou centro de custo. Essas classificações podem apoiar filtros, reporting e análise de custos.

Uma Tag descreve o recurso; ela não move o recurso para outro scope nem muda sua posição na hierarquia.$content$,null,null,3),
('7b210000-0000-4000-8000-000000000017','resource-tags','example','Custos por ambiente',
$content$Uma organização aplica `Environment=Production` aos recursos do ambiente de produção e `Environment=Development` aos recursos de desenvolvimento.

Com uso consistente, a equipe pode filtrar ou agrupar custos por Environment. A Tag não altera o preço do recurso por si só.$content$,null,null,4),
('7b210000-0000-4000-8000-000000000018','resource-tags','important','Tags não são herdadas automaticamente',
$content$Tags aplicadas a um Resource Group ou Subscription **não são automaticamente herdadas** pelos recursos filhos.

Se a organização precisar impor ou copiar Tags, pode usar mecanismos como Azure Policy. Para esta Lesson, basta reconhecer a ausência de herança automática; configuração de Policy fica fora do escopo.$content$,null,null,5),
('7b210000-0000-4000-8000-000000000019','resource-tags','exam_trap','Tag no Resource Group não aparece sozinha nos recursos',
$content$Um Resource Group com `Environment=Production` não faz com que VMs, databases e Storage Accounts dentro dele recebam automaticamente a mesma Tag.

Verifique as Tags efetivamente aplicadas aos recursos antes de depender delas em filtros ou relatórios.$content$,null,null,6),
('7b210000-0000-4000-8000-000000000020','resource-tags','important','Tags versus controles próximos',
$content$| Conceito | Pergunta principal |
| --- | --- |
| Tags | Como classificar e organizar recursos? |
| Azure RBAC | Quem pode fazer o quê em qual scope? |
| Resource Locks | Como proteger contra determinadas alterações ou exclusões? |
| Azure Policy | Como avaliar ou aplicar regras de governança? |

Os três controles são citados apenas para diferenciação.$content$,null,null,7),
('7b210000-0000-4000-8000-000000000021','resource-tags','exam_trap','Tags não concedem permissão',
$content$Tags não são permissions, security controls ou resource hierarchy.

Adicionar `Owner=BackendTeam` não concede acesso ao time. Azure RBAC controla autorização; a Tag apenas registra um metadado.$content$,null,null,8),
('7b210000-0000-4000-8000-000000000022','resource-tags','example','Project e Department',
$content$Recursos de uma aplicação recebem `Project=CertificationPlatform` e `Department=Engineering`. As Tags apoiam inventário e relatórios por projeto ou área.

Se alguns recursos não receberem as Tags, os agrupamentos podem ficar incompletos.$content$,null,null,9),
('7b210000-0000-4000-8000-000000000023','resource-tags','explanation','Tags não substituem a hierarquia',
$content$Management Groups, Subscriptions, Resource Groups e resources formam scopes de organização e gerenciamento. Tags são metadados aplicados a scopes suportados.

Uma Tag não cria relação pai-filho, não muda o Resource Group e não substitui naming standards.$content$,null,null,10),
('7b210000-0000-4000-8000-000000000024','resource-tags','exam_tip','Procure classificação key/value',
$content$Cenários que pedem organizar, filtrar ou analisar custos por Environment, Department, Project ou Owner apontam para Tags. Cenários de permissão apontam para RBAC, não Tags.$content$,null,null,11),
('7b210000-0000-4000-8000-000000000025','resource-tags','important','Consistência determina utilidade',
$content$`Environment=Prod` e `Environment=Production` são valores diferentes. Uma convenção consistente reduz fragmentação em filtros e relatórios.

Tags ajudam a atribuir contexto, mas não garantem automaticamente alocação perfeita de todo custo compartilhado.$content$,null,null,12),
('7b210000-0000-4000-8000-000000000026','resource-tags','summary','Resumo para memória ativa',null,
'{"items":["Tags são metadados key/value para organizar e classificar recursos.","Resources, Resource Groups e Subscriptions podem receber Tags.","Tags apoiam filtros, reporting e análise de custos.","Tags de scopes pais não são herdadas automaticamente pelos recursos.","Tags não concedem acesso, não bloqueiam alterações e não criam hierarquia.","Chaves e valores consistentes tornam relatórios mais úteis."]}'::jsonb,null,13);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.visual_experience_id,seed.display_order,true
from stage_93_block_seed seed join public.lessons lesson
  on lesson.topic_id='33000000-0000-4000-8000-000000000001' and lesson.slug=seed.lesson_slug;

create temporary table stage_93_flashcard_seed(
  id uuid primary key,lesson_slug text not null,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_93_flashcard_seed values
('7e400000-0000-4000-8000-000000000057','azure-cost-management','Para que serve Azure Cost Management?','Para monitorar, analisar e ajudar a controlar gastos Azure.','Operação financeira.',1),
('7e400000-0000-4000-8000-000000000058','azure-cost-management','O que Cost Analysis ajuda a descobrir?','Onde e como os custos e o consumo estão sendo gerados.','Filtrar e agrupar.',2),
('7e400000-0000-4000-8000-000000000059','azure-cost-management','Budget é um hard spending limit?','Não. Ele acompanha um valor planejado e pode gerar alerts.','Não desliga recursos.',3),
('7e400000-0000-4000-8000-000000000060','azure-cost-management','Atingir um Budget desliga recursos automaticamente?','Não. Budget e alerts fornecem visibilidade e notificação.','Ação não é automática por padrão.',4),
('7e400000-0000-4000-8000-000000000061','azure-cost-management','Qual é a diferença entre Actual Cost e Forecast?','Actual Cost já ocorreu; Forecast projeta gasto futuro.','Realizado versus previsto.',5),
('7e400000-0000-4000-8000-000000000062','azure-cost-management','Pricing Calculator e Cost Management têm o mesmo uso?','Não. Calculator estima o planejado; Cost Management acompanha a operação.','Antes versus durante.',6),
('7e400000-0000-4000-8000-000000000063','azure-cost-management','Como um alert de Budget ajuda a equipe?','Notifica quando um threshold definido é alcançado para permitir avaliação e resposta.','Visibilidade.',7),
('7e400000-0000-4000-8000-000000000064','resource-tags','O que é uma Azure Tag?','Um metadado key/value usado para organizar e classificar recursos.','Chave e valor.',1),
('7e400000-0000-4000-8000-000000000065','resource-tags','Cite um exemplo de Tag.','Environment=Production.','Também pode ser Department, Project ou Owner.',2),
('7e400000-0000-4000-8000-000000000066','resource-tags','Onde Tags podem ser aplicadas em Fundamentals?','Em resources, Resource Groups e Subscriptions.','Não Management Groups.',3),
('7e400000-0000-4000-8000-000000000067','resource-tags','Tags ajudam na análise de custos?','Sim. Podem apoiar filtros e agrupamentos por classificação consistente.','Exemplo: Environment.',4),
('7e400000-0000-4000-8000-000000000068','resource-tags','Tags de um Resource Group são herdadas automaticamente?','Não. Os recursos filhos não recebem automaticamente as Tags do grupo.','Sem herança automática.',5),
('7e400000-0000-4000-8000-000000000069','resource-tags','Uma Tag concede permissão ao recurso?','Não. Tags são metadados; Azure RBAC controla autorização.','Classificação não é acesso.',6);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_93_flashcard_seed seed join public.lessons lesson
  on lesson.topic_id='33000000-0000-4000-8000-000000000001' and lesson.slug=seed.lesson_slug;

create temporary table stage_93_historical_question_update(
  id uuid primary key,question_text text not null,explanation text not null
) on commit drop;
insert into stage_93_historical_question_update values
('63000000-0000-4000-8000-000000000071','Qual é a finalidade principal do Azure Cost Management?','Azure Cost Management reúne capacidades para monitorar, analisar e ajudar a controlar gastos Azure durante a operação.'),
('63000000-0000-4000-8000-000000000072','O que um Budget representa no Azure Cost Management?','Budget é um valor definido para acompanhar gastos de um período e pode gerar alerts; não é um hard spending limit.'),
('63000000-0000-4000-8000-000000000073','Uma equipe quer descobrir quais serviços estão gerando maior custo. Qual capacidade deve usar?','Cost Analysis permite explorar custos, aplicar filtros ou agrupamentos conceituais e identificar recursos, serviços ou categorias responsáveis.'),
('63000000-0000-4000-8000-000000000074','Uma empresa quer ser avisada quando o gasto atingir 80% do valor planejado. Qual solução atende ao cenário?','Um Budget com alert configurado no threshold desejado fornece a notificação, sem desligar automaticamente os recursos.'),
('63000000-0000-4000-8000-000000000075','Qual afirmação diferencia Actual Cost de Forecast?','Actual Cost representa custo já ocorrido; Forecast é uma projeção de gasto futuro baseada em custos e comportamento observados.'),
('63000000-0000-4000-8000-000000000076','O custo de um Resource Group aumentou em relação ao mês anterior. Como investigar?','Cost Analysis pode comparar períodos e detalhar ou agrupar os dados para identificar recursos e serviços que contribuíram para o aumento.'),
('63000000-0000-4000-8000-000000000077','Uma arquitetura ainda está sendo planejada, mas outro ambiente já está em operação. Qual associação está correta?','Pricing Calculator estima a arquitetura planejada; Cost Management acompanha e analisa os gastos do ambiente em operação.'),
('63000000-0000-4000-8000-000000000078','Recursos usam Tags de Department consistentes. Como isso pode ajudar em Cost Analysis?','Tags podem apoiar filtros e agrupamentos para analisar custos por Department, desde que tenham sido aplicadas consistentemente aos recursos relevantes.'),
('63000000-0000-4000-8000-000000000079','Um relatório mostra Actual Cost acumulado e Forecast até o fim do período. Qual interpretação é correta?','Actual Cost já foi observado; Forecast projeta o futuro e pode mudar se o comportamento do consumo mudar.'),
('63000000-0000-4000-8000-000000000080','Um Budget atingiu 100%, mas os recursos continuam executando. Isso indica falha?','Não. Budget acompanha gastos e pode notificar thresholds; ele não funciona como hard spending limit nem desliga recursos automaticamente.');
update public.questions question set question_text=seed.question_text,explanation=seed.explanation
from stage_93_historical_question_update seed where question.id=seed.id;

create temporary table stage_93_historical_option_update(
  id uuid primary key,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_93_historical_option_update values
('74000000-0000-4000-8000-000000000281','Monitorar, analisar e ajudar a controlar gastos Azure.',true,'Correta. Essa é a finalidade conceitual do serviço.',1),
('74000000-0000-4000-8000-000000000282','Estimar exclusivamente uma arquitetura ainda não implantada.',false,'Esse é o foco principal da Pricing Calculator.',2),
('74000000-0000-4000-8000-000000000283','Controlar permissões de gerenciamento dos recursos.',false,'Azure RBAC controla autorização, não Cost Management.',3),
('74000000-0000-4000-8000-000000000284','Impedir exclusões acidentais de recursos.',false,'Resource Locks atendem essa finalidade.',4),
('74000000-0000-4000-8000-000000000285','Um valor planejado usado para acompanhar gastos no período.',true,'Correta. Budget compara gastos com um valor definido.',1),
('74000000-0000-4000-8000-000000000286','Uma garantia de que a fatura nunca ultrapassará o valor.',false,'Budget não é hard spending limit.',2),
('74000000-0000-4000-8000-000000000287','Uma estimate criada antes da implantação.',false,'Estimate planejada pertence à Pricing Calculator.',3),
('74000000-0000-4000-8000-000000000288','Uma regra que exclui recursos ao atingir o valor.',false,'Budget não exclui recursos automaticamente.',4),
('74000000-0000-4000-8000-000000000289','Cost Analysis.',true,'Correta. A capacidade ajuda a identificar onde o custo ocorre.',1),
('74000000-0000-4000-8000-000000000290','Azure Pricing Calculator apenas.',false,'Calculator estima um desenho planejado, não analisa gasto ocorrido.',2),
('74000000-0000-4000-8000-000000000291','Azure RBAC.',false,'RBAC controla autorização.',3),
('74000000-0000-4000-8000-000000000292','Resource Locks.',false,'Locks protegem contra alterações e exclusões.',4),
('74000000-0000-4000-8000-000000000293','Um Budget com alert no threshold de 80%.',true,'Correta. O alert notifica ao atingir a condição definida.',1),
('74000000-0000-4000-8000-000000000294','Uma Tag chamada Budget=80.',false,'Tag classifica; não cria alert de gasto.',2),
('74000000-0000-4000-8000-000000000295','Uma Pricing Calculator aberta durante todo o mês.',false,'Calculator não monitora thresholds operacionais.',3),
('74000000-0000-4000-8000-000000000296','Um Resource Lock na Subscription.',false,'Lock não monitora gastos nem envia budget alert.',4),
('74000000-0000-4000-8000-000000000297','Actual Cost já ocorreu; Forecast projeta gasto futuro.',true,'Correta. Realizado e previsto representam momentos diferentes.',1),
('74000000-0000-4000-8000-000000000298','Actual Cost e Forecast são sempre o mesmo valor.',false,'Forecast pode variar e não é custo realizado.',2),
('74000000-0000-4000-8000-000000000299','Forecast é uma fatura final já emitida.',false,'Forecast é projeção, não fatura.',3),
('74000000-0000-4000-8000-000000000300','Actual Cost é uma estimate antes da implantação.',false,'Actual Cost representa custo observado.',4),
('74000000-0000-4000-8000-000000000301','Comparar períodos e detalhar custos no Cost Analysis.',true,'Correta. A análise ajuda a localizar a origem da mudança.',1),
('74000000-0000-4000-8000-000000000302','Excluir o Resource Group antes de investigar.',false,'Excluir sem análise pode interromper serviços necessários.',2),
('74000000-0000-4000-8000-000000000303','Usar somente a estimate anterior à implantação.',false,'Estimate planejada não identifica sozinha o gasto operacional atual.',3),
('74000000-0000-4000-8000-000000000304','Assumir que todo aumento é erro de cobrança.',false,'Aumento pode refletir mudança real de consumo ou configuração.',4),
('74000000-0000-4000-8000-000000000305','Pricing Calculator para o planejado; Cost Management para a operação.',true,'Correta. As ferramentas atendem momentos diferentes.',1),
('74000000-0000-4000-8000-000000000306','Cost Management para criar a estimate; Calculator para faturas.',false,'A associação está invertida.',2),
('74000000-0000-4000-8000-000000000307','Pricing Calculator para ambos os cenários.',false,'Calculator não substitui análise de custos ocorridos.',3),
('74000000-0000-4000-8000-000000000308','Cost Analysis para ambos antes de existir consumo.',false,'Sem operação, o planejamento é papel da Calculator.',4),
('74000000-0000-4000-8000-000000000309','Filtrar ou agrupar custos pela Tag Department.',true,'Correta. Tags consistentes apoiam a classificação para análise.',1),
('74000000-0000-4000-8000-000000000310','Conceder acesso aos departamentos por meio da Tag.',false,'Tags não concedem autorização.',2),
('74000000-0000-4000-8000-000000000311','Desligar automaticamente recursos com a mesma Tag.',false,'Tags não executam desligamento.',3),
('74000000-0000-4000-8000-000000000312','Mover recursos de Subscription usando a Tag.',false,'Tags não alteram a hierarquia ou o scope do recurso.',4),
('74000000-0000-4000-8000-000000000313','Actual Cost é observado; Forecast é projeção e pode mudar.',true,'Correta. Forecast depende do comportamento observado.',1),
('74000000-0000-4000-8000-000000000314','Forecast é garantia do custo final.',false,'Forecast não é garantia.',2),
('74000000-0000-4000-8000-000000000315','Actual Cost contém apenas recursos futuros.',false,'Actual Cost trata custos já ocorridos.',3),
('74000000-0000-4000-8000-000000000316','Os dois valores são estimates pré-implantação.',false,'Actual Cost vem da operação, não do planejamento prévio.',4),
('74000000-0000-4000-8000-000000000317','Não. Budget não desliga recursos automaticamente.',true,'Correta. Ele acompanha e pode notificar.',1),
('74000000-0000-4000-8000-000000000318','Sim. Todo Budget deve interromper recursos em 100%.',false,'Budget não é hard spending limit.',2),
('74000000-0000-4000-8000-000000000319','Sim. O comportamento prova que Cost Analysis falhou.',false,'Cost Analysis e Budget possuem funções distintas.',3),
('74000000-0000-4000-8000-000000000320','Não, porque Budget serve apenas para estimar antes da implantação.',false,'Budget acompanha gastos operacionais; não é Pricing Calculator.',4);
update public.question_options option set is_correct=false
where option.id in(select seed.id from stage_93_historical_option_update seed);
update public.question_options option set option_text=seed.option_text,is_correct=seed.is_correct,
  explanation=seed.explanation,display_order=seed.display_order
from stage_93_historical_option_update seed where option.id=seed.id;

create temporary table stage_93_question_seed(
  id uuid primary key,question_text text not null,difficulty text not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_93_question_seed values
('68000000-0000-4000-8000-000000000124','Qual opção representa uma Azure Tag válida?','easy','Azure Tags usam pares key/value, como Environment=Production, para classificar recursos.',1),
('68000000-0000-4000-8000-000000000125','Uma empresa quer organizar relatórios de custo por Environment. O que deve aplicar consistentemente aos recursos?','easy','Tags como Environment=Production e Environment=Development podem apoiar filtros e agrupamentos de custos quando aplicadas de forma consistente.',2),
('68000000-0000-4000-8000-000000000126','Em quais scopes as Tags podem ser aplicadas no contexto Fundamentals desta Lesson?','medium','Tags podem ser aplicadas a resources, Resource Groups e Subscriptions; Management Groups não são ensinados como alvo de Tags.',3),
('68000000-0000-4000-8000-000000000127','Um Resource Group possui Environment=Production. Suas VMs recebem automaticamente a mesma Tag?','medium','Não. Tags aplicadas ao Resource Group ou Subscription não são automaticamente herdadas pelos recursos filhos.',4),
('68000000-0000-4000-8000-000000000128','Uma equipe adicionou Owner=BackendTeam a uma VM e concluiu que o time agora pode administrá-la e que ela não pode ser excluída. Qual análise está correta?','hard','A Tag somente classifica a VM. Azure RBAC controla autorização e Resource Locks protegem contra determinadas alterações ou exclusões; Tags não substituem esses controles.',5);
insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_93_question_seed seed join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure management and governance'
join public.topics topic on topic.domain_id=domain.id and topic.id='33000000-0000-4000-8000-000000000001'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug='resource-tags';

create temporary table stage_93_option_seed(
  id uuid primary key,question_id uuid not null,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_93_option_seed values
('7f210000-0000-4000-8000-000000000001','68000000-0000-4000-8000-000000000124','Environment=Production.',true,'Correta. É um par key/value.',1),
('7f210000-0000-4000-8000-000000000002','68000000-0000-4000-8000-000000000124','Reader no scope da Subscription.',false,'Isso descreve uma atribuição RBAC, não uma Tag.',2),
('7f210000-0000-4000-8000-000000000003','68000000-0000-4000-8000-000000000124','ReadOnly Lock.',false,'Isso descreve Resource Lock.',3),
('7f210000-0000-4000-8000-000000000004','68000000-0000-4000-8000-000000000124','Management Group pai.',false,'Isso descreve hierarquia, não key/value.',4),
('7f210000-0000-4000-8000-000000000005','68000000-0000-4000-8000-000000000125','Tags de Environment.',true,'Correta. Tags classificam os recursos para apoiar análise.',1),
('7f210000-0000-4000-8000-000000000006','68000000-0000-4000-8000-000000000125','Roles RBAC chamadas Production.',false,'RBAC trata autorização, não classificação de custos.',2),
('7f210000-0000-4000-8000-000000000007','68000000-0000-4000-8000-000000000125','Resource Locks por ambiente.',false,'Locks não classificam custos.',3),
('7f210000-0000-4000-8000-000000000008','68000000-0000-4000-8000-000000000125','Novas Subscriptions criadas diariamente.',false,'Não é necessário criar Subscriptions diárias para classificar recursos.',4),
('7f210000-0000-4000-8000-000000000009','68000000-0000-4000-8000-000000000126','Resources, Resource Groups e Subscriptions.',true,'Correta. São os alvos cobertos nesta Lesson.',1),
('7f210000-0000-4000-8000-000000000010','68000000-0000-4000-8000-000000000126','Somente Management Groups.',false,'Management Groups não são o alvo ensinado para Tags.',2),
('7f210000-0000-4000-8000-000000000011','68000000-0000-4000-8000-000000000126','Somente usuários e grupos do Entra ID.',false,'Tags organizam recursos e scopes suportados, não identidades.',3),
('7f210000-0000-4000-8000-000000000012','68000000-0000-4000-8000-000000000126','Somente Budgets do Cost Management.',false,'Budget não é um recurso filho marcado neste conceito.',4),
('7f210000-0000-4000-8000-000000000013','68000000-0000-4000-8000-000000000127','Não. A herança automática de Tags não ocorre.',true,'Correta. A Tag precisa ser aplicada ou imposta separadamente.',1),
('7f210000-0000-4000-8000-000000000014','68000000-0000-4000-8000-000000000127','Sim. Toda Tag do Resource Group é sempre herdada.',false,'Tags não possuem herança automática para recursos filhos.',2),
('7f210000-0000-4000-8000-000000000015','68000000-0000-4000-8000-000000000127','Sim, mas somente se a VM estiver desligada.',false,'Estado da VM não cria herança de Tags.',3),
('7f210000-0000-4000-8000-000000000016','68000000-0000-4000-8000-000000000127','Não, porque VMs não podem receber Tags.',false,'VMs são resources e podem receber Tags.',4),
('7f210000-0000-4000-8000-000000000017','68000000-0000-4000-8000-000000000128','A conclusão está errada; Tag não concede acesso nem bloqueia exclusão.',true,'Correta. RBAC e Locks possuem essas funções distintas.',1),
('7f210000-0000-4000-8000-000000000018','68000000-0000-4000-8000-000000000128','A conclusão está correta porque Owner é uma role automática.',false,'Owner como valor de Tag não cria role assignment.',2),
('7f210000-0000-4000-8000-000000000019','68000000-0000-4000-8000-000000000128','A Tag substitui RBAC, mas não Resource Locks.',false,'Tag não substitui nenhum dos dois controles.',3),
('7f210000-0000-4000-8000-000000000020','68000000-0000-4000-8000-000000000128','A Tag substitui Locks, mas não RBAC.',false,'Tag não impede alterações ou exclusões.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_93_option_seed;

do $$
declare lesson_record record;
begin
  for lesson_record in select id,slug from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000001'
      and slug in ('azure-cost-management','resource-tags')
  loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_record.id and is_published)<>13
      or (select count(*) from public.flashcards where lesson_id=lesson_record.id and is_published)
        <>(case lesson_record.slug when 'azure-cost-management' then 7 else 6 end)
      or (select count(*) from public.questions where lesson_id=lesson_record.id and is_published)
        <>(case lesson_record.slug when 'azure-cost-management' then 10 else 5 end) then
      raise exception '9.3 final inventory is invalid for %',lesson_record.slug;
    end if;
  end loop;
end; $$;

commit;

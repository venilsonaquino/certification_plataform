begin;

do $$ begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000003' and slug='azure-arc')<>1 then
    raise exception '9.6.3 expected the existing Azure Arc Lesson'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug='azure-arc')
    or exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug='azure-arc') then
    raise exception '9.6.3 expected Azure Arc without structured content'; end if;
  if (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug='azure-arc')<>10 then
    raise exception '9.6.3 historical Azure Arc Question inventory changed'; end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug='azure-arc') then
    raise exception '9.6.3 must not create a Visual Experience'; end if;
end; $$;

update public.lessons set estimated_minutes=12
where topic_id='33000000-0000-4000-8000-000000000003' and slug='azure-arc';

create temporary table stage_963_blocks(id uuid primary key,type text,title text,content text,config jsonb,display_order integer) on commit drop;
insert into stage_963_blocks values
('7b260000-0000-4000-8000-000000000001','explanation','O que é Azure Arc?',
$c$Azure Arc é um serviço e conjunto de capacidades que **estende experiências de gerenciamento e governança do Azure a recursos suportados que podem estar fora do Azure**.

Esses recursos podem permanecer em datacenters próprios, edge, ambientes hospedados ou outras clouds. Arc cria uma ponte de gerenciamento; não muda automaticamente onde o workload executa.$c$,null,1),
('7b260000-0000-4000-8000-000000000002','important','O problema que Arc ajuda a resolver',
$c$Uma organização pode ter recursos distribuídos entre:

**Azure + On-premises + Other Clouds**

Sem uma abordagem central, inventário, organização e governança podem ficar fragmentados. Para tipos de recurso suportados, Azure Arc permite trazê-los para uma experiência de gerenciamento baseada no Azure.$c$,null,2),
('7b260000-0000-4000-8000-000000000003','example','Modelo conceitual',
$c$```text
On-Premises Server
Other Cloud Server
Hybrid Resources
        ↓
     Azure Arc
        ↓
Azure Management / Governance
```

O diagrama representa uma relação de gerenciamento. Os recursos não são transportados fisicamente para um datacenter Microsoft.$c$,null,3),
('7b260000-0000-4000-8000-000000000004','important','Azure Arc-enabled Servers',
$c$Azure Arc-enabled Servers permite representar servidores **Windows ou Linux executando fora do Azure** como recursos gerenciáveis no Azure.

O servidor pode estar em datacenter próprio, edge, ambiente hospedado ou outra cloud. Ele continua executando onde está, mas ganha uma representação no Azure e capacidades de gerenciamento compatíveis com seu tipo e configuração.$c$,null,4),
('7b260000-0000-4000-8000-000000000005','example','Servidor VMware continua local',
$c$Um servidor Windows executa em uma VM VMware no datacenter da empresa. Depois de habilitado para Azure Arc, ele aparece como recurso gerenciável no Azure.

O hypervisor, a VM e o workload continuam no ambiente local. Arc oferece capacidades de gerenciamento e governança; não realiza migração automática.$c$,null,5),
('7b260000-0000-4000-8000-000000000006','exam_trap','Arc-enabled Server não é Azure VM',
$c$Um servidor Arc-enabled não se transforma em Azure Virtual Machine e não passa automaticamente a executar em infraestrutura Microsoft.

**Local de execução** e **experiência de gerenciamento** são conceitos separados.$c$,null,6),
('7b260000-0000-4000-8000-000000000007','important','Hybrid versus multicloud',
$c$| Modelo | Significado | Exemplo conceitual |
| --- | --- | --- |
| Hybrid | combina ambiente local e cloud | datacenter on-premises + Azure |
| Multicloud | utiliza mais de um provedor cloud | Azure + outra cloud |

Azure Arc pode oferecer gerenciamento e governança mais consistentes para **determinados recursos suportados** nesses ambientes. Isso não significa suporte idêntico a qualquer recurso de qualquer cloud.$c$,null,7),
('7b260000-0000-4000-8000-000000000008','example','Hybrid e multicloud na mesma organização',
$c$Uma empresa mantém servidores no datacenter próprio, usa workloads Azure e possui servidores em outra cloud. O ambiente é híbrido por combinar on-premises e cloud, e multicloud por usar mais de um provedor. Recursos elegíveis podem ser representados por Azure Arc para reduzir a fragmentação do gerenciamento.$c$,null,8),
('7b260000-0000-4000-8000-000000000009','important','Capacidades dependem do recurso',
$c$Para recursos suportados e conforme tipo/configuração, Azure Arc **pode habilitar** capacidades como inventário, organização, Tags, Azure Policy, integração com monitoramento e recursos de segurança aplicáveis.

Não presuma que toda funcionalidade Azure funciona da mesma forma em todo recurso Arc-enabled. Arc amplia o alcance do gerenciamento, respeitando suporte e configuração.$c$,null,9),
('7b260000-0000-4000-8000-000000000010','important','Azure Arc e conceitos próximos',
$c$| Serviço ou conceito | Principal finalidade |
| --- | --- |
| Azure Arc | gerenciar e governar recursos suportados fora do Azure |
| Azure Migrate | avaliar, planejar e ajudar a migrar workloads para Azure |
| Azure portal | interface gráfica de administração |
| Azure Policy | avaliar ou aplicar regras de governança |
| Azure Resource Manager | camada de gerenciamento de recursos Azure |

ARM será aprofundado em outra etapa.$c$,null,10),
('7b260000-0000-4000-8000-000000000011','exam_trap','Arc não é migração nem conectividade',
$c$- **Azure Arc ≠ Azure Migrate:** Arc gerencia onde o recurso já está; Migrate ajuda a movê-lo para Azure.
- **Azure Arc ≠ VPN ou ExpressRoute:** Arc não é uma solução de conectividade de rede.
- **Azure Arc ≠ Azure Virtual Desktop:** Arc não entrega desktops virtuais.
- **Azure Arc ≠ ferramenta exclusiva para Kubernetes:** Arc inclui outros cenários, como Arc-enabled Servers.

Arc também não exige que o workload seja migrado para Azure.$c$,null,11),
('7b260000-0000-4000-8000-000000000012','exam_tip','Leia se o recurso deve ficar ou migrar',
$c$“Os servidores devem permanecer on-premises, mas quero governá-los usando capacidades Azure” aponta para **Azure Arc**.

“Quero avaliar e mover as VMs VMware para Azure” aponta para **Azure Migrate**. A palavra *mover* é decisiva.$c$,null,12),
('7b260000-0000-4000-8000-000000000013','summary','Resumo para memória ativa',null,
'{"items":["Azure Arc estende gerenciamento e governança do Azure a recursos suportados fora do Azure.","Arc atende cenários on-premises, edge, hybrid e multicloud.","Arc-enabled Servers representa servidores Windows/Linux externos como recursos gerenciáveis no Azure.","O servidor continua executando no ambiente original; Arc não o transforma em Azure VM.","Azure Arc gerencia onde está; Azure Migrate ajuda a mover para Azure.","Capacidades como inventário, Tags, Policy, monitoring e security dependem do recurso e da configuração."]}'::jsonb,13);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,null,seed.display_order,true
from stage_963_blocks seed join public.lessons lesson
  on lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug='azure-arc';

create temporary table stage_963_cards(id uuid primary key,front_text text,back_text text,hint text,display_order integer) on commit drop;
insert into stage_963_cards values
('7e450000-0000-4000-8000-000000000001','Qual é a finalidade principal do Azure Arc?','Estender gerenciamento e governança Azure a recursos suportados que podem estar fora do Azure.','Alcance do gerenciamento.',1),
('7e450000-0000-4000-8000-000000000002','O que caracteriza um ambiente hybrid?','A combinação de recursos locais e cloud, como on-premises + Azure.','Local + cloud.',2),
('7e450000-0000-4000-8000-000000000003','O que caracteriza multicloud?','O uso de mais de um provedor cloud, como Azure + outra cloud.','Múltiplos provedores.',3),
('7e450000-0000-4000-8000-000000000004','O que é um Azure Arc-enabled Server?','Um servidor Windows/Linux fora do Azure representado como recurso gerenciável no Azure.','Servidor externo.',4),
('7e450000-0000-4000-8000-000000000005','Um Arc-enabled Server passa a executar no Azure?','Não. Ele permanece onde está e recebe representação/capacidades de gerenciamento Azure.','Local de execução.',5),
('7e450000-0000-4000-8000-000000000006','Azure Arc e Azure Migrate têm a mesma finalidade?','Não. Arc gerencia recursos onde estão; Migrate ajuda a avaliá-los e movê-los para Azure.','Gerenciar versus migrar.',6),
('7e450000-0000-4000-8000-000000000007','Toda capacidade Azure funciona igualmente em qualquer recurso Arc-enabled?','Não. As capacidades dependem do tipo de recurso, suporte e configuração.','Limite de suporte.',7);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_963_cards seed join public.lessons lesson
  on lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug='azure-arc';

-- As dez Questions históricas permanecem nos mesmos UUIDs; somente conteúdo e alternativas são corrigidos.
create temporary table stage_963_questions(id uuid primary key,question_text text,explanation text) on commit drop;
insert into stage_963_questions values
('63000000-0000-4000-8000-000000000031','Qual afirmação define corretamente Azure Arc?','Azure Arc estende experiências de gerenciamento e governança do Azure a recursos suportados que podem executar fora do Azure.'),
('63000000-0000-4000-8000-000000000032','Um servidor Linux habilitado para Azure Arc precisa estar hospedado no Azure?','Não. Um Arc-enabled Server pode continuar em datacenter próprio, edge, ambiente hospedado ou outra cloud.'),
('63000000-0000-4000-8000-000000000033','Qual cenário representa multicloud?','Usar Azure e outro provedor cloud caracteriza multicloud. Hybrid combina recursos locais e cloud.'),
('63000000-0000-4000-8000-000000000034','Uma empresa manterá servidores no datacenter local, mas quer inventário e governança baseados no Azure. Qual serviço atende ao requisito?','Azure Arc representa recursos externos suportados no Azure e habilita capacidades de gerenciamento e governança sem exigir migração.'),
('63000000-0000-4000-8000-000000000035','Uma empresa usa servidores no Azure e em outra cloud e busca gerenciamento mais consistente para recursos elegíveis. Qual opção é adequada?','Azure Arc pode estender experiências Azure a recursos suportados em ambientes multicloud, sem prometer suporte idêntico para todos eles.'),
('63000000-0000-4000-8000-000000000036','Uma organização quer avaliar e mover VMs VMware locais para Azure. Qual serviço está mais diretamente ligado ao objetivo?','Azure Migrate ajuda a avaliar, planejar e migrar workloads. Azure Arc gerencia e governa recursos onde eles já executam.'),
('63000000-0000-4000-8000-000000000037','Após habilitar um servidor VMware local para Azure Arc, qual afirmação está correta?','O servidor continua no VMware local e ganha representação e capacidades de gerenciamento Azure; ele não se torna uma Azure VM.'),
('63000000-0000-4000-8000-000000000038','Qual afirmação descreve corretamente capacidades do Azure Arc?','Para tipos de recurso suportados e conforme a configuração, Arc pode habilitar inventário, organização, Policy e integrações de gerenciamento aplicáveis.'),
('63000000-0000-4000-8000-000000000039','Uma empresa combina datacenter próprio, Azure e outra cloud. Quer manter os servidores onde estão e aplicar governança Azure quando suportada. Qual desenho é adequado?','Habilitar recursos elegíveis com Azure Arc oferece uma experiência de gerenciamento mais consistente sem migrá-los automaticamente.'),
('63000000-0000-4000-8000-000000000040','Uma equipe afirma que Azure Arc substitui VPN, ExpressRoute e Azure Migrate. Qual análise está correta?','A afirmação está errada. Arc estende gerenciamento; VPN/ExpressRoute tratam conectividade e Azure Migrate trata avaliação e migração.');
update public.questions question set question_text=seed.question_text,explanation=seed.explanation
from stage_963_questions seed where question.id=seed.id;

create temporary table stage_963_options(id uuid primary key,option_text text,is_correct boolean,explanation text) on commit drop;
insert into stage_963_options values
('74000000-0000-4000-8000-000000000121','Migra automaticamente todos os recursos externos para Azure.',false,'Arc não realiza migração automática.'),
('74000000-0000-4000-8000-000000000122','Estende gerenciamento e governança Azure a recursos externos suportados.',true,'Correta. Essa é a finalidade central do Azure Arc.'),
('74000000-0000-4000-8000-000000000123','Cria exclusivamente redes VPN híbridas.',false,'Arc não é solução de conectividade VPN.'),
('74000000-0000-4000-8000-000000000124','Fornece somente desktops virtuais.',false,'Azure Virtual Desktop atende esse objetivo.'),
('74000000-0000-4000-8000-000000000125','Sim. Arc transforma obrigatoriamente o servidor em Azure VM.',false,'Arc-enabled Server não é Azure VM.'),
('74000000-0000-4000-8000-000000000126','Não. O servidor pode permanecer fora do Azure.',true,'Correta. O local de execução é preservado.'),
('74000000-0000-4000-8000-000000000127','Sim. Arc funciona apenas em datacenters Microsoft.',false,'Arc existe justamente para recursos externos.'),
('74000000-0000-4000-8000-000000000128','Não, porque Arc suporta apenas Kubernetes.',false,'Arc também inclui Arc-enabled Servers.'),
('74000000-0000-4000-8000-000000000129','Azure e outra cloud.',true,'Correta. São dois provedores cloud.'),
('74000000-0000-4000-8000-000000000130','Somente um datacenter local.',false,'Isso não envolve múltiplos provedores cloud.'),
('74000000-0000-4000-8000-000000000131','Uma Subscription e dois Resource Groups no Azure.',false,'São scopes dentro do mesmo provedor.'),
('74000000-0000-4000-8000-000000000132','Duas Availability Zones da mesma região.',false,'Zones não representam multicloud.'),
('74000000-0000-4000-8000-000000000133','Azure Arc.',true,'Correta. Arc estende gerenciamento a servidores externos.'),
('74000000-0000-4000-8000-000000000134','Azure Migrate.',false,'Migrate é voltado à avaliação e migração.'),
('74000000-0000-4000-8000-000000000135','ExpressRoute.',false,'ExpressRoute oferece conectividade privada.'),
('74000000-0000-4000-8000-000000000136','Azure Virtual Desktop.',false,'AVD entrega desktops e aplicações virtuais.'),
('74000000-0000-4000-8000-000000000137','Azure Arc para os recursos suportados.',true,'Correta. Arc atende gerenciamento híbrido e multicloud.'),
('74000000-0000-4000-8000-000000000138','Azure Migrate para governá-los sem mover.',false,'Migrate tem finalidade de avaliação e migração.'),
('74000000-0000-4000-8000-000000000139','VPN Gateway para aplicar Azure Policy.',false,'VPN não aplica regras de governança.'),
('74000000-0000-4000-8000-000000000140','Azure Virtual Desktop para representar servidores.',false,'AVD não representa servidores externos.'),
('74000000-0000-4000-8000-000000000141','Azure Migrate.',true,'Correta. O requisito explícito é mover workloads.'),
('74000000-0000-4000-8000-000000000142','Azure Arc.',false,'Arc gerencia recursos onde estão.'),
('74000000-0000-4000-8000-000000000143','Azure Policy isoladamente.',false,'Policy avalia regras; não executa migração.'),
('74000000-0000-4000-8000-000000000144','Azure portal.',false,'Portal é interface de administração.'),
('74000000-0000-4000-8000-000000000145','Permanece no VMware e aparece como recurso gerenciável no Azure.',true,'Correta. Arc muda a experiência de gerenciamento.'),
('74000000-0000-4000-8000-000000000146','É movido fisicamente para um datacenter Microsoft.',false,'Arc não move o servidor.'),
('74000000-0000-4000-8000-000000000147','É convertido automaticamente em Azure VM.',false,'Arc-enabled Server não é Azure VM.'),
('74000000-0000-4000-8000-000000000148','Passa a funcionar somente com Azure Virtual Desktop.',false,'AVD não é requisito para Arc.'),
('74000000-0000-4000-8000-000000000149','As capacidades dependem do recurso suportado e da configuração.',true,'Correta. Arc não promete paridade universal.'),
('74000000-0000-4000-8000-000000000150','Toda capacidade Azure funciona igualmente em qualquer recurso.',false,'O suporte varia por tipo e configuração.'),
('74000000-0000-4000-8000-000000000151','Arc oferece apenas conectividade de rede.',false,'Arc é gerenciamento e governança.'),
('74000000-0000-4000-8000-000000000152','Arc funciona exclusivamente com Kubernetes.',false,'Arc também atende servidores e outros recursos suportados.'),
('74000000-0000-4000-8000-000000000153','Habilitar recursos elegíveis com Azure Arc.',true,'Correta. Preserva o local e centraliza capacidades aplicáveis.'),
('74000000-0000-4000-8000-000000000154','Migrar obrigatoriamente tudo antes de governar.',false,'Arc não exige migração.'),
('74000000-0000-4000-8000-000000000155','Usar apenas VPN para criar inventário Azure.',false,'VPN não fornece representação e governança Arc.'),
('74000000-0000-4000-8000-000000000156','Converter servidores externos em Azure Virtual Desktop.',false,'AVD não atende o requisito.'),
('74000000-0000-4000-8000-000000000157','Errada: os serviços atendem gerenciamento, conectividade e migração distintos.',true,'Correta. Azure Arc não substitui esses serviços.'),
('74000000-0000-4000-8000-000000000158','Correta: Arc substitui qualquer serviço híbrido.',false,'Arc tem finalidade específica.'),
('74000000-0000-4000-8000-000000000159','Correta apenas para servidores Linux.',false,'O sistema operacional não muda a distinção.'),
('74000000-0000-4000-8000-000000000160','Errada apenas porque Arc é exclusivo para Kubernetes.',false,'Arc não é exclusivo para Kubernetes.');

update public.question_options set is_correct=false
where id between '74000000-0000-4000-8000-000000000121' and '74000000-0000-4000-8000-000000000160';
update public.question_options option set option_text=seed.option_text,is_correct=seed.is_correct,explanation=seed.explanation
from stage_963_options seed where option.id=seed.id;

do $$ declare lesson_uuid uuid; begin
  select id into strict lesson_uuid from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000003' and slug='azure-arc';
  if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_uuid and is_published)<>13
    or (select count(*) from public.flashcards where lesson_id=lesson_uuid and is_published)<>7
    or (select count(*) from public.questions where lesson_id=lesson_uuid and is_published)<>10 then
    raise exception '9.6.3 final artifact inventory is invalid'; end if;
end; $$;

commit;

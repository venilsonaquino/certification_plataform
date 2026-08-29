begin;

do $$ begin
  if (select count(*) from public.lessons
      where topic_id='33000000-0000-4000-8000-000000000004'
        and slug in('azure-advisor','azure-service-health'))<>2 then
    raise exception '9.7.2 expected two existing target Lessons';
  end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug in('azure-advisor','azure-service-health'))
    or exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004'
        and lesson.slug in('azure-advisor','azure-service-health')) then
    raise exception '9.7.2 expected targets without structured content';
  end if;
  if (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004' and lesson.slug='azure-advisor')<>10
    or exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004' and lesson.slug='azure-service-health') then
    raise exception '9.7.2 historical Question inventory changed';
  end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000004') then
    raise exception '9.7.2 must not create or reuse a Visual Experience';
  end if;
end; $$;

update public.lessons set estimated_minutes=12
where topic_id='33000000-0000-4000-8000-000000000004'
  and slug in('azure-advisor','azure-service-health');

create temporary table stage_972_blocks(
  id uuid primary key, lesson_slug text, type text, title text, content text,
  config jsonb, display_order integer
) on commit drop;

insert into stage_972_blocks values
('7b280000-0000-4000-8000-000000000001','azure-advisor','explanation','O que é Azure Advisor?',
$c$Azure Advisor é um serviço que analisa a configuração e o uso de recursos Azure e fornece **recomendações personalizadas** para ajudar a melhorar o ambiente. Para a prova, associe diretamente: **Azure Advisor → recommendations**.$c$,null,1),
('7b280000-0000-4000-8000-000000000002','azure-advisor','important','Cinco categorias de recomendações',
$c$| Categoria | Finalidade conceitual |
| --- | --- |
| Reliability | melhorar resiliência e continuidade |
| Security | identificar oportunidades relacionadas à segurança |
| Performance | melhorar desempenho dos recursos |
| Cost | encontrar oportunidades de otimização de gastos |
| Operational Excellence | melhorar práticas operacionais e gerenciamento |

Reconheça as áreas; não é necessário memorizar detalhes internos de cada recomendação.$c$,null,2),
('7b280000-0000-4000-8000-000000000003','azure-advisor','example','Recomendação de custo',
$c$Uma VM permanece pouco utilizada durante semanas. Azure Advisor pode analisar esse padrão e recomendar avaliar um tamanho menor. A recomendação indica uma oportunidade; a equipe ainda verifica requisitos, impacto e contexto antes de agir.$c$,null,3),
('7b280000-0000-4000-8000-000000000004','azure-advisor','example','Uma categoria para cada objetivo',
$c$Distribuir uma carga crítica para reduzir risco de indisponibilidade se relaciona a **Reliability**. Tratar uma configuração insegura aponta para **Security**. Melhorar velocidade indica **Performance**. Reduzir desperdício aponta para **Cost**. Aprimorar processos de operação indica **Operational Excellence**.$c$,null,4),
('7b280000-0000-4000-8000-000000000005','azure-advisor','important','Advisor versus ferramentas próximas',
$c$| Ferramenta | Pergunta principal |
| --- | --- |
| Azure Advisor | Como posso melhorar meu ambiente? |
| Azure Monitor | O que mostram métricas, logs e telemetria? |
| Azure Service Health | Um evento da plataforma pode afetar meus serviços? |
| Azure Cost Management | Como analisar e controlar meus gastos? |

Advisor pode recomendar otimização de custo, mas não substitui a análise de gastos do Cost Management.$c$,null,5),
('7b280000-0000-4000-8000-000000000006','azure-advisor','important','Advisor versus Service Health',
$c$**Azure Advisor** analisa o ambiente e responde com **recommendations**: “esta configuração pode ser otimizada”. **Azure Service Health** comunica eventos relevantes da plataforma: “este serviço ou região possui manutenção planejada”. Um trata melhoria; o outro trata informações de saúde do Azure.$c$,null,6),
('7b280000-0000-4000-8000-000000000007','azure-advisor','explanation','Recomendação não é ordem automática',
$c$Uma recomendação deve ser avaliada conforme impacto, prioridade, custo e requisitos da carga. Algumas experiências podem facilitar uma ação, mas Azure Advisor não é um mecanismo universal que aplica automaticamente toda mudança sugerida.$c$,null,7),
('7b280000-0000-4000-8000-000000000008','azure-advisor','example','Escolher o serviço pelo cenário',
$c$“Quero recomendações para reduzir custo e melhorar confiabilidade” aponta para Advisor. “Quero receber informação sobre manutenção do Azure” aponta para Service Health. “Quero ver CPU da VM” aponta para Azure Monitor. “Quero comparar gasto real com budget” aponta para Cost Management.$c$,null,8),
('7b280000-0000-4000-8000-000000000009','azure-advisor','exam_trap','Advisor não monitora outages nem corrige tudo',
$c$Azure Advisor não é Azure Monitor, Service Health ou Cost Management. Ele também não aplica automaticamente todas as recomendações. **Advisor analisa e recomenda**; a decisão e a execução dependem do cenário e da ação apropriada.$c$,null,9),
('7b280000-0000-4000-8000-000000000010','azure-advisor','exam_tip','Procure recomendações personalizadas',
$c$Se a questão pedir o serviço que fornece recomendações personalizadas para melhorar custo, segurança, performance, reliability ou operational excellence, a resposta provável é **Azure Advisor**.$c$,null,10),
('7b280000-0000-4000-8000-000000000011','azure-advisor','summary','Resumo para memória ativa',null,
'{"items":["Azure Advisor analisa recursos e configurações Azure.","Seu resultado central são recomendações personalizadas.","As categorias são Reliability, Security, Performance, Cost e Operational Excellence.","Advisor recomenda; não aplica universalmente toda mudança.","Monitor trata telemetria; Service Health trata eventos da plataforma; Cost Management trata gastos."]}'::jsonb,11),

('7b280000-0000-4000-8000-000000000012','azure-service-health','explanation','O que é Azure Service Health?',
$c$Azure Service Health é uma experiência personalizada que informa sobre eventos do Azure que podem afetar os serviços, regiões e recursos usados pelo cliente. Para a prova, associe Service Health a **informação relevante para seu ambiente**.$c$,null,1),
('7b280000-0000-4000-8000-000000000013','azure-service-health','important','Eventos comunicados pelo Service Health',
$c$| Evento | Ideia central |
| --- | --- |
| Service issues | problemas ativos em serviços Azure relevantes |
| Planned maintenance | manutenção planejada que pode causar impacto |
| Health advisories | avisos que exigem conhecimento ou possível ação do cliente |

A experiência é personalizada para subscriptions, serviços e regiões relacionados ao cliente.$c$,null,2),
('7b280000-0000-4000-8000-000000000014','azure-service-health','example','Manutenção planejada relevante',
$c$Uma empresa usa um serviço Azure em determinada região e quer saber se uma manutenção planejada pode afetar sua Subscription. Azure Service Health apresenta a informação personalizada e pode apoiar notificações sobre esse evento.$c$,null,3),
('7b280000-0000-4000-8000-000000000015','azure-service-health','explanation','Azure Status: visão pública e global',
$c$Azure Status oferece uma visão pública e ampla da integridade de serviços e regiões Azure. A pergunta típica é: **“Existe um problema amplo ou global no Azure?”** Não é uma visão personalizada da sua Subscription.$c$,null,4),
('7b280000-0000-4000-8000-000000000016','azure-service-health','explanation','Azure Resource Health: recurso específico',
$c$Azure Resource Health mostra a saúde atual e histórica de um recurso Azure específico, como uma VM. Conforme o tipo de recurso, estados podem incluir available, unavailable, degraded ou unknown. O importante é reconhecer o escopo individual, não memorizar rigidamente cada estado.$c$,null,5),
('7b280000-0000-4000-8000-000000000017','azure-service-health','important','Azure Status versus Service Health versus Resource Health',
$c$| Ferramenta | Principal pergunta |
| --- | --- |
| Azure Status | Existe problema amplo/global no Azure? |
| Service Health | Existe incidente, manutenção ou advisory relevante para meus serviços? |
| Resource Health | Qual é a saúde deste recurso específico? |

Pense em três níveis: **global → personalizado → recurso individual**.$c$,null,6),
('7b280000-0000-4000-8000-000000000018','azure-service-health','example','Três cenários de saúde',
$c$Ver uma interrupção ampla e pública aponta para **Azure Status**. Saber se manutenção planejada afeta serviços da sua Subscription aponta para **Service Health**. Investigar por que uma VM específica aparece indisponível aponta para **Resource Health**.$c$,null,7),
('7b280000-0000-4000-8000-000000000019','azure-service-health','important','Service Health versus Advisor',
$c$Service Health responde se um evento da plataforma pode afetar o ambiente. Advisor responde como o ambiente pode ser melhorado. “Região com manutenção planejada” é Service Health; “configuração pode ser otimizada” é Advisor.$c$,null,8),
('7b280000-0000-4000-8000-000000000020','azure-service-health','exam_trap','Resource Health não é monitoramento detalhado',
$c$Resource Health informa a condição de um recurso específico, mas não substitui métricas detalhadas de CPU, memória ou telemetria. Para métricas e monitoring data, procure **Azure Monitor**.$c$,null,9),
('7b280000-0000-4000-8000-000000000021','azure-service-health','exam_trap','Health information não é otimização',
$c$Azure Service Health não fornece recomendações gerais de otimização e Advisor não é monitor de outages. Também não confunda Azure Status global com Service Health personalizado ou Resource Health específico.$c$,null,10),
('7b280000-0000-4000-8000-000000000022','azure-service-health','exam_tip','Global, personalizado ou específico?',
$c$Use o escopo do cenário: **broad/global → Azure Status**; **relevante para meus serviços/Subscription → Service Health**; **um recurso específico → Resource Health**.$c$,null,11),
('7b280000-0000-4000-8000-000000000023','azure-service-health','summary','Resumo para memória ativa',null,
'{"items":["Service Health apresenta eventos Azure personalizados para o cliente.","Cobre service issues, planned maintenance e health advisories.","Azure Status oferece visão pública e global.","Resource Health mostra a saúde de um recurso específico.","Resource Health não substitui métricas e telemetria do Azure Monitor.","Advisor recomenda melhorias; Service Health comunica eventos da plataforma."]}'::jsonb,12);

insert into public.lesson_content_blocks(
  id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published
)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,null,seed.display_order,true
from stage_972_blocks seed join public.lessons lesson
  on lesson.topic_id='33000000-0000-4000-8000-000000000004' and lesson.slug=seed.lesson_slug;

create temporary table stage_972_cards(
  id uuid primary key, lesson_slug text, front_text text, back_text text,
  hint text, display_order integer
) on commit drop;

insert into stage_972_cards values
('7e470000-0000-4000-8000-000000000001','azure-advisor','Qual é o resultado central do Azure Advisor?','Recomendações personalizadas para ajudar a melhorar recursos e configurações Azure.','Recommendations.',1),
('7e470000-0000-4000-8000-000000000002','azure-advisor','Quais são as cinco categorias do Azure Advisor?','Reliability, Security, Performance, Cost e Operational Excellence.','Áreas de melhoria.',2),
('7e470000-0000-4000-8000-000000000003','azure-advisor','Qual categoria do Advisor procura oportunidades de economia?','Cost.','Otimização de gastos.',3),
('7e470000-0000-4000-8000-000000000004','azure-advisor','O Azure Advisor aplica automaticamente todas as recomendações?','Não. As recomendações precisam ser avaliadas e implementadas conforme o cenário.','Recomenda, não ordena.',4),
('7e470000-0000-4000-8000-000000000005','azure-advisor','Advisor e Azure Monitor têm a mesma finalidade?','Não. Advisor recomenda melhorias; Monitor trabalha com métricas, logs e telemetria.','Recommendations versus data.',5),
('7e470000-0000-4000-8000-000000000006','azure-advisor','Advisor e Service Health respondem à mesma pergunta?','Não. Advisor trata melhorias; Service Health informa eventos da plataforma relevantes ao cliente.','Melhoria versus saúde.',6),
('7e470000-0000-4000-8000-000000000007','azure-advisor','Advisor substitui Azure Cost Management?','Não. Advisor pode recomendar economia; Cost Management analisa e controla gastos.','Recomendação versus gestão.',7),
('7e470000-0000-4000-8000-000000000008','azure-service-health','O que é Azure Service Health?','Uma experiência personalizada sobre eventos Azure que podem afetar serviços e recursos do cliente.','Personalized health.',1),
('7e470000-0000-4000-8000-000000000009','azure-service-health','Quais eventos centrais aparecem no Service Health?','Service issues, planned maintenance e health advisories.','Eventos da plataforma.',2),
('7e470000-0000-4000-8000-000000000010','azure-service-health','Qual ferramenta mostra uma visão pública e global do Azure?','Azure Status.','Broad/global.',3),
('7e470000-0000-4000-8000-000000000011','azure-service-health','Qual ferramenta mostra eventos relevantes para minha Subscription?','Azure Service Health.','Personalized.',4),
('7e470000-0000-4000-8000-000000000012','azure-service-health','Qual ferramenta mostra a saúde de uma VM específica?','Azure Resource Health.','Individual resource.',5),
('7e470000-0000-4000-8000-000000000013','azure-service-health','Resource Health é usado para consultar CPU detalhada da VM?','Não. Métricas detalhadas apontam para Azure Monitor.','Saúde não é métrica.',6),
('7e470000-0000-4000-8000-000000000014','azure-service-health','Onde verificar manutenção planejada que pode afetar meus serviços?','Azure Service Health.','Evento personalizado.',7),
('7e470000-0000-4000-8000-000000000015','azure-service-health','Como lembrar os três escopos de saúde?','Azure Status é global; Service Health é personalizado; Resource Health é específico.','Global → personalizado → recurso.',8);

insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_972_cards seed join public.lessons lesson
  on lesson.topic_id='33000000-0000-4000-8000-000000000004' and lesson.slug=seed.lesson_slug;

-- Corrige as dez Questions históricas de Advisor sem substituir seus UUIDs.
update public.questions set
  question_text=case id
    when '63000000-0000-4000-8000-000000000021' then 'Qual serviço analisa recursos Azure e fornece recomendações personalizadas para melhorar o ambiente?'
    when '63000000-0000-4000-8000-000000000022' then 'Quais áreas representam as categorias conceituais do Azure Advisor?'
    when '63000000-0000-4000-8000-000000000023' then 'Qual afirmação descreve corretamente como tratar uma recomendação do Azure Advisor?'
    when '63000000-0000-4000-8000-000000000024' then 'Uma VM está subutilizada e a empresa quer uma recomendação para otimizar custo. Qual serviço deve consultar?'
    when '63000000-0000-4000-8000-000000000025' then 'Uma manutenção planejada do Azure pode afetar serviços usados pela empresa. Qual ferramenta fornece informação personalizada sobre esse evento?'
    when '63000000-0000-4000-8000-000000000026' then 'Uma recomendação sugere aumentar a resiliência de uma aplicação crítica. A qual categoria do Advisor ela se relaciona principalmente?'
    when '63000000-0000-4000-8000-000000000027' then 'Uma equipe precisa analisar métricas de CPU e telemetria, não recomendações. Qual serviço está mais alinhado?'
    when '63000000-0000-4000-8000-000000000028' then 'Uma organização quer analisar gasto real, budgets e tendências de custo. Qual ferramenta atende mais diretamente?'
    when '63000000-0000-4000-8000-000000000029' then 'Uma recomendação do Advisor sugere alterar uma configuração crítica. Qual abordagem é mais adequada?'
    when '63000000-0000-4000-8000-000000000030' then 'Uma equipe precisa de recomendações de melhoria e também de avisos sobre incidentes da plataforma. Qual associação está correta?'
  end,
  explanation=case id
    when '63000000-0000-4000-8000-000000000021' then 'Azure Advisor analisa configurações e uso de recursos e fornece recomendações personalizadas de melhoria.'
    when '63000000-0000-4000-8000-000000000022' then 'As categorias são Reliability, Security, Performance, Cost e Operational Excellence.'
    when '63000000-0000-4000-8000-000000000023' then 'Advisor recomenda; a equipe avalia impacto, requisitos e contexto antes de implementar a mudança.'
    when '63000000-0000-4000-8000-000000000024' then 'Azure Advisor pode identificar recursos subutilizados e recomendar oportunidades de otimização de custo.'
    when '63000000-0000-4000-8000-000000000025' then 'Service Health apresenta eventos de plataforma personalizados para serviços, regiões e subscriptions relacionados ao cliente.'
    when '63000000-0000-4000-8000-000000000026' then 'Reliability reúne recomendações voltadas a resiliência e continuidade de cargas importantes.'
    when '63000000-0000-4000-8000-000000000027' then 'Azure Monitor é a plataforma para coletar e analisar métricas, logs e telemetria; Advisor fornece recomendações.'
    when '63000000-0000-4000-8000-000000000028' then 'Azure Cost Management atende análise, budgets e controle de gastos; Advisor pode apenas recomendar oportunidades de economia.'
    when '63000000-0000-4000-8000-000000000029' then 'Recomendações devem ser avaliadas conforme contexto, prioridade e impacto antes de uma implementação apropriada.'
    when '63000000-0000-4000-8000-000000000030' then 'Advisor fornece recomendações; Service Health informa incidentes, manutenção e advisories relevantes ao ambiente.'
  end
where id between '63000000-0000-4000-8000-000000000021'
  and '63000000-0000-4000-8000-000000000030';

update public.question_options set is_correct=false
where id between '74000000-0000-4000-8000-000000000081'
  and '74000000-0000-4000-8000-000000000120';

update public.question_options set
  option_text=case id
    when '74000000-0000-4000-8000-000000000081' then 'Azure Advisor.'
    when '74000000-0000-4000-8000-000000000082' then 'Azure Monitor.'
    when '74000000-0000-4000-8000-000000000083' then 'Azure Service Health.'
    when '74000000-0000-4000-8000-000000000084' then 'Azure Cost Management.'
    when '74000000-0000-4000-8000-000000000085' then 'Service issues, planned maintenance, advisories, metrics e logs.'
    when '74000000-0000-4000-8000-000000000086' then 'Reliability, Security, Performance, Cost e Operational Excellence.'
    when '74000000-0000-4000-8000-000000000087' then 'Compute, Storage, Networking, Identity e Databases.'
    when '74000000-0000-4000-8000-000000000088' then 'Available, Unavailable, Degraded, Unknown e Global.'
    when '74000000-0000-4000-8000-000000000089' then 'Ela deve sempre ser aplicada imediatamente e sem revisão.'
    when '74000000-0000-4000-8000-000000000090' then 'Ela é somente uma notificação de outage global.'
    when '74000000-0000-4000-8000-000000000091' then 'Ela deve ser avaliada conforme contexto e impacto antes da implementação.'
    when '74000000-0000-4000-8000-000000000092' then 'Ela bloqueia automaticamente novos deployments até ser aceita.'
    when '74000000-0000-4000-8000-000000000093' then 'Azure Monitor.'
    when '74000000-0000-4000-8000-000000000094' then 'Azure Service Health.'
    when '74000000-0000-4000-8000-000000000095' then 'Azure Cost Management.'
    when '74000000-0000-4000-8000-000000000096' then 'Azure Advisor.'
    when '74000000-0000-4000-8000-000000000097' then 'Azure Advisor.'
    when '74000000-0000-4000-8000-000000000098' then 'Azure Service Health.'
    when '74000000-0000-4000-8000-000000000099' then 'Azure Status.'
    when '74000000-0000-4000-8000-000000000100' then 'Azure Resource Health.'
    when '74000000-0000-4000-8000-000000000101' then 'Cost.'
    when '74000000-0000-4000-8000-000000000102' then 'Reliability.'
    when '74000000-0000-4000-8000-000000000103' then 'Performance.'
    when '74000000-0000-4000-8000-000000000104' then 'Operational Excellence.'
    when '74000000-0000-4000-8000-000000000105' then 'Azure Advisor.'
    when '74000000-0000-4000-8000-000000000106' then 'Azure Service Health.'
    when '74000000-0000-4000-8000-000000000107' then 'Azure Monitor.'
    when '74000000-0000-4000-8000-000000000108' then 'Azure Cost Management.'
    when '74000000-0000-4000-8000-000000000109' then 'Azure Advisor.'
    when '74000000-0000-4000-8000-000000000110' then 'Azure Service Health.'
    when '74000000-0000-4000-8000-000000000111' then 'Azure Monitor.'
    when '74000000-0000-4000-8000-000000000112' then 'Azure Cost Management.'
    when '74000000-0000-4000-8000-000000000113' then 'Avaliar contexto, prioridade e impacto antes de implementar.'
    when '74000000-0000-4000-8000-000000000114' then 'Aplicar toda recomendação automaticamente, sem validação.'
    when '74000000-0000-4000-8000-000000000115' then 'Ignorar recomendações porque nunca são personalizadas.'
    when '74000000-0000-4000-8000-000000000116' then 'Esperar que Service Health faça a alteração sugerida.'
    when '74000000-0000-4000-8000-000000000117' then 'Advisor informa incidentes; Service Health otimiza custos.'
    when '74000000-0000-4000-8000-000000000118' then 'Advisor recomenda melhorias; Service Health informa eventos relevantes da plataforma.'
    when '74000000-0000-4000-8000-000000000119' then 'Azure Status personaliza recomendações; Advisor mostra CPU.'
    when '74000000-0000-4000-8000-000000000120' then 'Azure Monitor aplica toda recomendação; Advisor mostra outages globais.'
  end,
  is_correct=id in(
    '74000000-0000-4000-8000-000000000081','74000000-0000-4000-8000-000000000086',
    '74000000-0000-4000-8000-000000000091','74000000-0000-4000-8000-000000000096',
    '74000000-0000-4000-8000-000000000098','74000000-0000-4000-8000-000000000102',
    '74000000-0000-4000-8000-000000000107','74000000-0000-4000-8000-000000000112',
    '74000000-0000-4000-8000-000000000113','74000000-0000-4000-8000-000000000118'
  ),
  explanation=case when id in(
    '74000000-0000-4000-8000-000000000081','74000000-0000-4000-8000-000000000086',
    '74000000-0000-4000-8000-000000000091','74000000-0000-4000-8000-000000000096',
    '74000000-0000-4000-8000-000000000098','74000000-0000-4000-8000-000000000102',
    '74000000-0000-4000-8000-000000000107','74000000-0000-4000-8000-000000000112',
    '74000000-0000-4000-8000-000000000113','74000000-0000-4000-8000-000000000118'
  ) then 'Correta. A opção aplica a finalidade e o escopo adequados ao cenário.'
  else 'Incorreta. A opção confunde recomendações, monitoring data, eventos de saúde ou gestão de custos.' end
where id between '74000000-0000-4000-8000-000000000081'
  and '74000000-0000-4000-8000-000000000120';

create temporary table stage_972_questions(
  id uuid primary key, lesson_slug text, question_text text, difficulty text,
  explanation text, display_order integer
) on commit drop;

insert into stage_972_questions values
('68000000-0000-4000-8000-000000000169','azure-service-health','Uma manutenção planejada do Azure pode afetar serviços usados por uma Subscription. Onde consultar informação personalizada?','easy','Azure Service Health apresenta manutenção e outros eventos da plataforma relevantes aos serviços, regiões e subscriptions do cliente.',1),
('68000000-0000-4000-8000-000000000170','azure-service-health','Um administrador quer uma visão pública e global de um incidente amplo no Azure. Qual opção deve consultar?','easy','Azure Status fornece a visão pública e global da integridade de serviços e regiões Azure.',2),
('68000000-0000-4000-8000-000000000171','azure-service-health','Uma VM específica aparece indisponível e a equipe quer consultar sua saúde atual e histórica. Qual experiência atende ao cenário?','medium','Azure Resource Health apresenta a saúde de recursos específicos e pode ajudar a investigar eventos que os afetam.',3),
('68000000-0000-4000-8000-000000000172','azure-service-health','A equipe quer analisar a métrica de CPU de uma VM e ser avisada quando ultrapassar um limite. Qual serviço é mais alinhado?','medium','Métricas e condições de telemetria apontam para Azure Monitor; Resource Health trata a condição geral de um recurso específico.',4),
('68000000-0000-4000-8000-000000000173','azure-service-health','Uma empresa quer saber se um incidente regional do Azure afeta especificamente os serviços usados por sua Subscription. Qual opção é mais adequada?','hard','Service Health fornece uma visão personalizada de eventos relevantes ao ambiente; Azure Status é amplo e Resource Health é individual.',5);

insert into public.questions(
  id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,
  difficulty,explanation,is_published,display_order
)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,
  'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_972_questions seed
join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id
  and domain.title='Describe Azure management and governance'
join public.topics topic on topic.domain_id=domain.id
  and topic.id='33000000-0000-4000-8000-000000000004'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug=seed.lesson_slug;

create temporary table stage_972_options(
  id uuid primary key, question_id uuid, option_text text, is_correct boolean,
  explanation text, display_order integer
) on commit drop;

insert into stage_972_options values
('7f280000-0000-4000-8000-000000000001','68000000-0000-4000-8000-000000000169','Azure Service Health.',true,'Correta. A visão é personalizada para eventos relevantes ao cliente.',1),
('7f280000-0000-4000-8000-000000000002','68000000-0000-4000-8000-000000000169','Azure Advisor.',false,'Advisor fornece recomendações de melhoria.',2),
('7f280000-0000-4000-8000-000000000003','68000000-0000-4000-8000-000000000169','Azure Status.',false,'Status oferece visão global, não personalizada.',3),
('7f280000-0000-4000-8000-000000000004','68000000-0000-4000-8000-000000000169','Azure Resource Health.',false,'Resource Health trata um recurso específico.',4),
('7f280000-0000-4000-8000-000000000005','68000000-0000-4000-8000-000000000170','Azure Service Health.',false,'Service Health é personalizado ao ambiente.',1),
('7f280000-0000-4000-8000-000000000006','68000000-0000-4000-8000-000000000170','Azure Status.',true,'Correta. Azure Status oferece visão pública e global.',2),
('7f280000-0000-4000-8000-000000000007','68000000-0000-4000-8000-000000000170','Azure Resource Health.',false,'Resource Health trata recursos específicos.',3),
('7f280000-0000-4000-8000-000000000008','68000000-0000-4000-8000-000000000170','Azure Monitor.',false,'Monitor trabalha com dados de monitoramento.',4),
('7f280000-0000-4000-8000-000000000009','68000000-0000-4000-8000-000000000171','Azure Status.',false,'Status apresenta visão global.',1),
('7f280000-0000-4000-8000-000000000010','68000000-0000-4000-8000-000000000171','Azure Service Health.',false,'Service Health apresenta eventos personalizados mais amplos.',2),
('7f280000-0000-4000-8000-000000000011','68000000-0000-4000-8000-000000000171','Azure Resource Health.',true,'Correta. O escopo é uma VM específica.',3),
('7f280000-0000-4000-8000-000000000012','68000000-0000-4000-8000-000000000171','Azure Advisor.',false,'Advisor fornece recomendações de melhoria.',4),
('7f280000-0000-4000-8000-000000000013','68000000-0000-4000-8000-000000000172','Azure Resource Health.',false,'Resource Health não substitui análise detalhada de métricas.',1),
('7f280000-0000-4000-8000-000000000014','68000000-0000-4000-8000-000000000172','Azure Service Health.',false,'Service Health comunica eventos da plataforma.',2),
('7f280000-0000-4000-8000-000000000015','68000000-0000-4000-8000-000000000172','Azure Advisor.',false,'Advisor fornece recomendações, não a telemetria detalhada.',3),
('7f280000-0000-4000-8000-000000000016','68000000-0000-4000-8000-000000000172','Azure Monitor.',true,'Correta. Métricas e condições de telemetria pertencem ao Monitor.',4),
('7f280000-0000-4000-8000-000000000017','68000000-0000-4000-8000-000000000173','Azure Service Health.',true,'Correta. O evento deve ser relevante à Subscription e seus serviços.',1),
('7f280000-0000-4000-8000-000000000018','68000000-0000-4000-8000-000000000173','Azure Status.',false,'Status é amplo e global, não personalizado.',2),
('7f280000-0000-4000-8000-000000000019','68000000-0000-4000-8000-000000000173','Azure Resource Health.',false,'Resource Health trata uma instância específica.',3),
('7f280000-0000-4000-8000-000000000020','68000000-0000-4000-8000-000000000173','Azure Advisor.',false,'Advisor trata recomendações de melhoria.',4);

insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_972_options;

do $$ declare lesson_row record; begin
  for lesson_row in select id,slug from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000004'
      and slug in('azure-advisor','azure-service-health') loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='azure-advisor' then 11 else 12 end)
      or (select count(*) from public.flashcards where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='azure-advisor' then 7 else 8 end)
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='azure-advisor' then 10 else 5 end) then
      raise exception '9.7.2 final artifact inventory invalid for %',lesson_row.slug;
    end if;
  end loop;
end; $$;

commit;

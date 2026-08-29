begin;

do $$ begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000004'
      and slug in('azure-monitor','log-analytics','azure-monitor-alerts','application-insights'))<>4 then
    raise exception '9.7.3 expected four target Lessons'; end if;
  if exists(select 1 from public.lesson_content_blocks b join public.lessons l on l.id=b.lesson_id
      where l.topic_id='33000000-0000-4000-8000-000000000004' and l.slug in('azure-monitor','log-analytics','azure-monitor-alerts','application-insights'))
    or exists(select 1 from public.flashcards f join public.lessons l on l.id=f.lesson_id
      where l.topic_id='33000000-0000-4000-8000-000000000004' and l.slug in('azure-monitor','log-analytics','azure-monitor-alerts','application-insights'))
    or exists(select 1 from public.visual_experiences v join public.lessons l on l.id=v.lesson_id
      where l.topic_id='33000000-0000-4000-8000-000000000004') then
    raise exception '9.7.3 structured artifact preconditions invalid'; end if;
  if exists(select 1 from public.questions q join public.lessons l on l.id=q.lesson_id
      where l.topic_id='33000000-0000-4000-8000-000000000004' and l.slug in('azure-monitor','log-analytics','azure-monitor-alerts'))
    or (select count(*) from public.questions q join public.lessons l on l.id=q.lesson_id
      where l.topic_id='33000000-0000-4000-8000-000000000004' and l.slug='application-insights')<>10 then
    raise exception '9.7.3 Question preconditions invalid'; end if;
end; $$;

update public.lessons set estimated_minutes=case slug
  when 'azure-monitor' then 12 when 'application-insights' then 12 else 10 end
where topic_id='33000000-0000-4000-8000-000000000004'
  and slug in('azure-monitor','log-analytics','azure-monitor-alerts','application-insights');

insert into public.visual_experiences(id,lesson_id,type,title,description,config,display_order,is_published)
select '76000000-0000-4000-8000-000000000017',id,'architecture','Do sinal à análise e à resposta',
  'Explore como recursos e aplicações enviam metrics e logs ao Azure Monitor e como suas capacidades analisam ou respondem à telemetria.',
  $json${"nodes":[
    {"id":"resources","label":"Azure Resources","kind":"resource","description":"Infraestrutura e serviços geram dados operacionais.","x":18,"y":8},
    {"id":"applications","label":"Applications","kind":"external","description":"Aplicações geram telemetria sobre requests, failures e dependencies.","x":82,"y":8},
    {"id":"metrics","label":"Metrics","kind":"group","description":"Valores numéricos coletados ao longo do tempo.","x":30,"y":32},
    {"id":"logs","label":"Logs","kind":"group","description":"Eventos e registros detalhados sobre operações e comportamento.","x":70,"y":32},
    {"id":"monitor","label":"Azure Monitor","kind":"service","description":"Plataforma central que coleta, analisa e permite responder à telemetria.","x":50,"y":55},
    {"id":"log-analytics","label":"Log Analytics","kind":"service","description":"Experiência para consultar e analisar logs.","x":18,"y":86},
    {"id":"alerts","label":"Azure Monitor Alerts","kind":"service","description":"Avalia condições e pode gerar notificações ou ações.","x":50,"y":86},
    {"id":"app-insights","label":"Application Insights","kind":"service","description":"APM para performance, failures e dependencies de aplicações.","x":82,"y":86}
  ],"edges":[
    {"id":"resources-metrics","source":"resources","target":"metrics","label":"gera"},
    {"id":"resources-logs","source":"resources","target":"logs","label":"gera"},
    {"id":"apps-metrics","source":"applications","target":"metrics","label":"telemetria"},
    {"id":"apps-logs","source":"applications","target":"logs","label":"telemetria"},
    {"id":"metrics-monitor","source":"metrics","target":"monitor","label":"coleta"},
    {"id":"logs-monitor","source":"logs","target":"monitor","label":"coleta"},
    {"id":"monitor-la","source":"monitor","target":"log-analytics","label":"análise"},
    {"id":"monitor-alerts","source":"monitor","target":"alerts","label":"resposta"},
    {"id":"monitor-ai","source":"monitor","target":"app-insights","label":"APM"}
  ]}$json$::jsonb,1,true
from public.lessons where topic_id='33000000-0000-4000-8000-000000000004' and slug='azure-monitor';

create temporary table stage_973_blocks(id uuid primary key,lesson_slug text,type text,title text,content text,config jsonb,visual_id uuid,display_order integer) on commit drop;
insert into stage_973_blocks values
('7b290000-0000-4000-8000-000000000001','azure-monitor','explanation','O que é Azure Monitor?',
$c$Azure Monitor é a plataforma central de monitoramento e observabilidade da Microsoft para **coletar, analisar e responder** a dados de telemetria de recursos, infraestrutura e aplicações.$c$,null,null,1),
('7b290000-0000-4000-8000-000000000002','azure-monitor','visual_experience','Explore o fluxo do Azure Monitor',null,null,'76000000-0000-4000-8000-000000000017',2),
('7b290000-0000-4000-8000-000000000003','azure-monitor','important','Da origem à resposta',
$c$`Resources / Applications → Telemetry → Azure Monitor → Analysis / Visualization / Alerts`. Telemetry é o conjunto de dados que ajuda a entender saúde, desempenho e operação; metrics e logs são sinais centrais.$c$,null,null,3),
('7b290000-0000-4000-8000-000000000004','azure-monitor','important','Metrics versus Logs',
$c$| Sinal | O que representa | Exemplos |
| --- | --- | --- |
| Metrics | valores numéricos em série temporal | CPU percentage, request count, latency, storage usage |
| Logs | registros e eventos detalhados | activity, traces, diagnostics, application events |

Metrics favorecem tendências e limites; logs favorecem investigação e contexto histórico.$c$,null,null,4),
('7b290000-0000-4000-8000-000000000005','azure-monitor','example','CPU e investigação',
$c$Acompanhar CPU de uma VM ao longo do tempo usa uma **metric**. Investigar eventos detalhados ocorridos antes de uma falha usa **logs**. Ambos podem integrar a experiência ampla do Azure Monitor.$c$,null,null,5),
('7b290000-0000-4000-8000-000000000006','azure-monitor','important','Monitor versus ferramentas de health',
$c$| Pergunta | Ferramenta |
| --- | --- |
| Este recurso específico está disponível? | Resource Health |
| Como o recurso está se comportando? | Azure Monitor |
| Há manutenção ou incidente da plataforma relevante para mim? | Service Health |
| Como posso melhorar custo ou reliability? | Azure Advisor |$c$,null,null,6),
('7b290000-0000-4000-8000-000000000007','azure-monitor','important','Mapa das ferramentas de monitoring',
$c$| Ferramenta | Finalidade principal |
| --- | --- |
| Azure Monitor | coletar e analisar telemetria |
| Metrics | valores numéricos ao longo do tempo |
| Logs | eventos e dados detalhados |
| Log Analytics | consultar e analisar logs |
| Alerts | reagir a condições monitoradas |
| Application Insights | APM de aplicações |$c$,null,null,7),
('7b290000-0000-4000-8000-000000000008','azure-monitor','example','Escolha pelo sinal',
$c$CPU em 95% aponta para Azure Monitor Metrics. Uma consulta de eventos detalhados aponta para Log Analytics. Uma notificação quando CPU cruza um threshold aponta para Alerts. Performance e failures de uma aplicação web apontam para Application Insights.$c$,null,null,8),
('7b290000-0000-4000-8000-000000000009','azure-monitor','exam_trap','Monitor não é Advisor nem Service Health',
$c$Azure Monitor trabalha com monitoring data e telemetria. Advisor fornece recommendations; Service Health comunica eventos da plataforma; Resource Health mostra a condição de um recurso específico. Resource Health não é uma metric.$c$,null,null,9),
('7b290000-0000-4000-8000-000000000010','azure-monitor','exam_tip','Numérico ou detalhado?',
$c$“Valor numérico ao longo do tempo” aponta para **Metric**. “Investigar eventos e detalhes históricos” aponta para **Logs**. Coletar, analisar e responder à telemetria aponta para **Azure Monitor**.$c$,null,null,10),
('7b290000-0000-4000-8000-000000000011','azure-monitor','summary','Resumo para memória ativa',null,
'{"items":["Azure Monitor coleta, analisa e permite responder à telemetria.","Metrics são valores numéricos em série temporal.","Logs registram eventos e detalhes.","Monitor pode apoiar análise, visualização e alerts.","Advisor recomenda; Service Health comunica eventos; Resource Health trata um recurso específico."]}'::jsonb,null,11),

('7b290000-0000-4000-8000-000000000012','log-analytics','explanation','O que é Log Analytics?',
$c$Log Analytics é a experiência/ferramenta do ecossistema Azure Monitor usada para **consultar e analisar dados de logs**. Para a prova: “quero consultar logs” → Log Analytics.$c$,null,null,1),
('7b290000-0000-4000-8000-000000000013','log-analytics','important','Fluxo conceitual de logs',
$c$`Resources / Applications → Logs → Azure Monitor → Log Analytics → Queries / Analysis`. Log Analytics trabalha sobre dados coletados; ele não é a origem de todo evento.$c$,null,null,2),
('7b290000-0000-4000-8000-000000000014','log-analytics','important','KQL apenas como contexto',
$c$KQL — Kusto Query Language — pode ser usada para consultar logs. No AZ-900, reconheça o nome e a finalidade; não é necessário memorizar sintaxe, operators, joins ou administração avançada de workspaces.$c$,null,null,3),
('7b290000-0000-4000-8000-000000000015','log-analytics','important','Logs versus Metrics',
$c$Metrics são valores numéricos em série temporal. Logs contêm eventos e detalhes úteis para investigação. Log Analytics é a ferramenta de consulta/análise dos logs; não é o nome de uma metric.$c$,null,null,4),
('7b290000-0000-4000-8000-000000000016','log-analytics','example','Investigar falhas recentes',
$c$Uma equipe quer consultar erros e eventos registrados nas últimas horas para entender uma falha. Log Analytics oferece a experiência de query e análise; a prova não exige escrever a consulta.$c$,null,null,5),
('7b290000-0000-4000-8000-000000000017','log-analytics','exam_trap','Log Analytics não é Azure Monitor inteiro',
$c$Azure Monitor é a plataforma ampla. Log Analytics é uma de suas experiências para logs. Também não confunda logs detalhados com metrics numéricas.$c$,null,null,6),
('7b290000-0000-4000-8000-000000000018','log-analytics','exam_tip','Procure consulta de logs',
$c$Se o cenário pede consultar, filtrar ou analisar registros e eventos coletados, identifique **Log Analytics**. Se pede um valor numérico ao longo do tempo, pense em Metrics.$c$,null,null,7),
('7b290000-0000-4000-8000-000000000019','log-analytics','summary','Resumo para memória ativa',null,
'{"items":["Log Analytics consulta e analisa logs do Azure Monitor.","Logs contêm eventos e detalhes históricos.","KQL é contexto; sintaxe não é requisito de AZ-900.","Metrics são numéricas; logs são detalhados.","Log Analytics é parte do ecossistema Azure Monitor."]}'::jsonb,null,8),

('7b290000-0000-4000-8000-000000000020','azure-monitor-alerts','explanation','O que são Azure Monitor Alerts?',
$c$Azure Monitor Alerts avalia sinais e condições de monitoramento e pode gerar **notificações ou ações** quando uma condição definida é atendida.$c$,null,null,1),
('7b290000-0000-4000-8000-000000000021','azure-monitor-alerts','important','Fluxo de um alert',
$c$`Metric / Log / Signal → Condition → Alert → Notification / Action`. O sinal fornece dados; a condição expressa o que deve ser avaliado; o alert representa a reação quando a condição é atendida.$c$,null,null,2),
('7b290000-0000-4000-8000-000000000022','azure-monitor-alerts','example','CPU acima do threshold',
$c$Uma regra avalia a metric de CPU. Quando `CPU > threshold`, o alert é disparado e pode notificar a equipe. A metric existe continuamente; o alert depende da condição configurada.$c$,null,null,3),
('7b290000-0000-4000-8000-000000000023','azure-monitor-alerts','example','Falhas da aplicação',
$c$Uma condição acompanha a quantidade de failed requests. Ao ultrapassar o limite definido, um alert pode gerar notificação ou ação para que a equipe investigue.$c$,null,null,4),
('7b290000-0000-4000-8000-000000000024','azure-monitor-alerts','important','Monitoramento versus Alert',
$c$Azure Monitor coleta e analisa telemetria. Alerts reagem quando uma condição monitorada é atendida. Nem todo dado gera automaticamente um alert; é necessária uma condição ou regra apropriada.$c$,null,null,5),
('7b290000-0000-4000-8000-000000000025','azure-monitor-alerts','exam_trap','Alert não é Metric',
$c$Uma metric é um sinal numérico. Um alert usa metric, log ou outro sinal para avaliar uma condição. Também não trate cada sinal coletado como notificação automática.$c$,null,null,6),
('7b290000-0000-4000-8000-000000000026','azure-monitor-alerts','exam_tip','Procure condição e reação',
$c$Threshold, condição atendida, notificação ou ação apontam para **Azure Monitor Alerts**. Apenas visualizar CPU ou latency descreve monitoring data, não necessariamente um alert.$c$,null,null,7),
('7b290000-0000-4000-8000-000000000027','azure-monitor-alerts','summary','Resumo para memória ativa',null,
'{"items":["Alerts avaliam sinais e condições.","O sinal pode ser metric, log ou outro monitoring signal.","Condição atendida pode gerar notificação ou ação.","Alert não é a própria metric.","Dados não geram alerts automaticamente sem regras apropriadas."]}'::jsonb,null,8),

('7b290000-0000-4000-8000-000000000028','application-insights','explanation','O que é Application Insights?',
$c$Application Insights é a capacidade de **Application Performance Monitoring — APM** integrada ao Azure Monitor. Ela ajuda a observar performance, comportamento e falhas de aplicações por meio de application telemetry.$c$,null,null,1),
('7b290000-0000-4000-8000-000000000029','application-insights','important','Sinais de uma aplicação',
$c$Application Insights ajuda a observar application requests, failed requests, response times, dependencies, exceptions e outros dados de performance quando a aplicação está configurada para emitir essa telemetria.$c$,null,null,2),
('7b290000-0000-4000-8000-000000000030','application-insights','important','Fluxo conceitual de APM',
$c$`Application → Application Telemetry → Application Insights → Performance / Failures / Dependencies`. O foco é a aplicação; Azure Monitor possui escopo mais amplo.$c$,null,null,3),
('7b290000-0000-4000-8000-000000000031','application-insights','dotnet_example','ASP.NET Core API e SQL Database',
$c$`User → ASP.NET Core API → SQL Database`. Application Insights pode ajudar a observar quantidade de requests, response time, failed requests, exceptions e a dependency SQL. Este é contexto conceitual, não um tutorial de instalação ou SDK.$c$,null,null,4),
('7b290000-0000-4000-8000-000000000032','application-insights','example','Encontrar a origem da lentidão',
$c$Uma API responde lentamente. A telemetria mostra response time elevado e uma dependency de banco demorando mais. Application Insights ajuda a investigar o desempenho da aplicação e suas dependências.$c$,null,null,5),
('7b290000-0000-4000-8000-000000000033','application-insights','important','Application Insights dentro do Azure Monitor',
$c$Azure Monitor é a plataforma ampla de telemetria para recursos e aplicações. Application Insights é a capacidade especializada em APM. Ele não é um produto sem relação com Monitor nem representa todo o Azure Monitor.$c$,null,null,6),
('7b290000-0000-4000-8000-000000000034','application-insights','important','Application Insights versus outras ferramentas',
$c$Performance e failures de aplicação apontam para Application Insights. Logs consultados apontam para Log Analytics. Condição e notificação apontam para Alerts. Recomendações apontam para Advisor; manutenção da plataforma aponta para Service Health.$c$,null,null,7),
('7b290000-0000-4000-8000-000000000035','application-insights','exam_trap','APM não é health da plataforma',
$c$Application Insights monitora aplicações; não comunica manutenção regional do Azure e não fornece recomendações gerais de custo. Service Health e Advisor têm essas finalidades distintas.$c$,null,null,8),
('7b290000-0000-4000-8000-000000000036','application-insights','exam_tip','Procure performance da aplicação',
$c$Requests, failed requests, response time, exceptions, dependencies e application performance apontam para **Application Insights**.$c$,null,null,9),
('7b290000-0000-4000-8000-000000000037','application-insights','summary','Resumo para memória ativa',null,
'{"items":["Application Insights é APM integrado ao Azure Monitor.","Observa requests, failures, response times e dependencies.","Usa application telemetry para investigar performance.","Azure Monitor é amplo; Application Insights é especializado em aplicações.","Não é Advisor nem Service Health."]}'::jsonb,null,10);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published)
select s.id,l.id,s.type,s.title,s.content,s.config,s.visual_id,s.display_order,true from stage_973_blocks s
join public.lessons l on l.topic_id='33000000-0000-4000-8000-000000000004' and l.slug=s.lesson_slug;

create temporary table stage_973_cards(id uuid primary key,lesson_slug text,front_text text,back_text text,hint text,display_order integer) on commit drop;
insert into stage_973_cards values
('7e480000-0000-4000-8000-000000000001','azure-monitor','Qual é a finalidade do Azure Monitor?','Coletar, analisar e permitir responder à telemetria de recursos, infraestrutura e aplicações.','Monitoring data.',1),
('7e480000-0000-4000-8000-000000000002','azure-monitor','O que é uma Metric?','Um valor numérico coletado ao longo do tempo.','Time-series.',2),
('7e480000-0000-4000-8000-000000000003','azure-monitor','O que são Logs?','Registros e eventos detalhados sobre comportamento e operações.','Detalhes históricos.',3),
('7e480000-0000-4000-8000-000000000004','azure-monitor','CPU 95% aponta para qual conceito?','Azure Monitor Metric.','Valor numérico.',4),
('7e480000-0000-4000-8000-000000000005','azure-monitor','Advisor e Monitor têm a mesma finalidade?','Não. Advisor recomenda melhorias; Monitor trabalha com telemetria.','Recommendations versus data.',5),
('7e480000-0000-4000-8000-000000000006','azure-monitor','Resource Health e Monitor respondem à mesma pergunta?','Não. Resource Health mostra condição específica; Monitor mostra comportamento por telemetria.','Saúde versus comportamento.',6),
('7e480000-0000-4000-8000-000000000007','log-analytics','Para que serve Log Analytics?','Para consultar e analisar dados de logs no ecossistema Azure Monitor.','Queries.',1),
('7e480000-0000-4000-8000-000000000008','log-analytics','KQL precisa ser memorizada para AZ-900?','Não. Basta reconhecer KQL como linguagem usada para consultar logs.','Contexto.',2),
('7e480000-0000-4000-8000-000000000009','log-analytics','Log Analytics analisa Metrics ou Logs principalmente?','Logs.','Registros detalhados.',3),
('7e480000-0000-4000-8000-000000000010','log-analytics','Qual ferramenta usar para investigar eventos registrados?','Log Analytics.','Consulta de logs.',4),
('7e480000-0000-4000-8000-000000000011','log-analytics','Log Analytics é todo o Azure Monitor?','Não. É uma experiência do ecossistema Monitor para logs.','Parte da plataforma.',5),
('7e480000-0000-4000-8000-000000000012','log-analytics','Qual a diferença curta entre Metrics e Logs?','Metrics são numéricas e temporais; Logs trazem eventos e detalhes.','Sinal versus registro.',6),
('7e480000-0000-4000-8000-000000000013','azure-monitor-alerts','O que faz Azure Monitor Alerts?','Avalia sinais e condições e pode gerar notificações ou ações.','Reação.',1),
('7e480000-0000-4000-8000-000000000014','azure-monitor-alerts','Qual é o fluxo conceitual de um alert?','Signal → condition → alert → notification/action.','Etapas.',2),
('7e480000-0000-4000-8000-000000000015','azure-monitor-alerts','Alert e Metric são a mesma coisa?','Não. O alert pode usar a metric para avaliar uma condição.','Dado versus reação.',3),
('7e480000-0000-4000-8000-000000000016','azure-monitor-alerts','Todo dado coletado gera automaticamente um alert?','Não. Alerts precisam de condições ou regras apropriadas.','Configuração.',4),
('7e480000-0000-4000-8000-000000000017','azure-monitor-alerts','CPU acima de um threshold deve notificar a equipe. Qual recurso usar?','Azure Monitor Alerts.','Condição.',5),
('7e480000-0000-4000-8000-000000000018','azure-monitor-alerts','O que pode ocorrer quando uma condição de alert é atendida?','Uma notificação ou ação pode ser disparada.','Resposta.',6),
('7e480000-0000-4000-8000-000000000019','application-insights','O que é Application Insights?','Uma capacidade de APM integrada ao Azure Monitor.','Aplicações.',1),
('7e480000-0000-4000-8000-000000000020','application-insights','Quais sinais centrais Application Insights observa?','Requests, failures, response times, dependencies e application telemetry.','APM.',2),
('7e480000-0000-4000-8000-000000000021','application-insights','Application Insights e Azure Monitor são idênticos?','Não. Insights é especializado em aplicações dentro da plataforma Monitor.','Especializado versus amplo.',3),
('7e480000-0000-4000-8000-000000000022','application-insights','Qual ferramenta ajuda a investigar performance de uma API web?','Application Insights.','APM.',4),
('7e480000-0000-4000-8000-000000000023','application-insights','O que uma dependency representa no contexto de APM?','Um serviço externo chamado pela aplicação, como um banco de dados.','Relação externa.',5),
('7e480000-0000-4000-8000-000000000024','application-insights','Application Insights informa manutenção regional da plataforma?','Não. Isso aponta para Service Health.','Escopo.',6);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select s.id,l.id,s.front_text,s.back_text,s.hint,s.display_order,true from stage_973_cards s
join public.lessons l on l.topic_id='33000000-0000-4000-8000-000000000004' and l.slug=s.lesson_slug;

create temporary table stage_973_questions(id uuid primary key,lesson_slug text,question_text text,difficulty text,explanation text,display_order integer) on commit drop;
insert into stage_973_questions values
('68000000-0000-4000-8000-000000000174','azure-monitor','Qual plataforma central coleta e analisa telemetria de recursos e aplicações Azure?','easy','Azure Monitor é a plataforma ampla de monitoring e observability para telemetria.',1),
('68000000-0000-4000-8000-000000000175','azure-monitor','Qual sinal representa valores numéricos coletados ao longo do tempo?','easy','Metrics são séries temporais numéricas, como CPU percentage e latency.',2),
('68000000-0000-4000-8000-000000000176','azure-monitor','Uma equipe quer acompanhar CPU de uma VM ao longo do dia. Qual opção atende diretamente?','medium','Azure Monitor Metrics apresenta valores numéricos ao longo do tempo.',3),
('68000000-0000-4000-8000-000000000177','azure-monitor','Uma equipe quer recommendations para reduzir custo, não monitoring data. Qual serviço deve usar?','medium','Azure Advisor fornece recomendações personalizadas; Monitor trabalha com telemetria.',4),
('68000000-0000-4000-8000-000000000178','azure-monitor','Uma VM está unavailable e também mostra CPU alta. Qual associação está correta?','hard','Resource Health trata a condição do recurso; Azure Monitor Metric mostra CPU.',5),
('68000000-0000-4000-8000-000000000179','log-analytics','Qual ferramenta é usada para consultar e analisar logs do Azure Monitor?','easy','Log Analytics fornece a experiência de queries e análise de logs.',1),
('68000000-0000-4000-8000-000000000180','log-analytics','Qual afirmação diferencia Logs de Metrics?','easy','Logs contêm eventos detalhados; Metrics são valores numéricos em série temporal.',2),
('68000000-0000-4000-8000-000000000181','log-analytics','Uma equipe quer investigar eventos registrados antes de uma falha. Qual ferramenta é mais adequada?','medium','Log Analytics permite consultar e analisar os logs coletados.',3),
('68000000-0000-4000-8000-000000000182','log-analytics','Qual conhecimento de KQL é esperado em nível AZ-900?','medium','Basta reconhecer KQL como contexto para consultas de logs, sem memorizar sintaxe.',4),
('68000000-0000-4000-8000-000000000183','log-analytics','Uma equipe afirma que Log Analytics é toda a plataforma Azure Monitor. Qual análise está correta?','hard','A afirmação está errada: Log Analytics é uma experiência específica para logs dentro do ecossistema Monitor.',5),
('68000000-0000-4000-8000-000000000184','azure-monitor-alerts','O que Azure Monitor Alerts faz?','easy','Avalia sinais e condições e pode produzir notificações ou ações.',1),
('68000000-0000-4000-8000-000000000185','azure-monitor-alerts','Qual sequência representa conceitualmente um alert?','easy','Signal → condition → alert → notification/action.',2),
('68000000-0000-4000-8000-000000000186','azure-monitor-alerts','A equipe quer ser notificada quando CPU superar um threshold. Qual recurso deve configurar?','medium','Azure Monitor Alert avalia a metric e reage quando a condição é atendida.',3),
('68000000-0000-4000-8000-000000000187','azure-monitor-alerts','Qual afirmação diferencia Metric de Alert?','medium','Metric é o sinal numérico; Alert avalia uma condição sobre sinais.',4),
('68000000-0000-4000-8000-000000000188','azure-monitor-alerts','Uma equipe acredita que todo dado do Monitor gera automaticamente uma notificação. Qual análise está correta?','hard','A crença está errada: alerts precisam de condições e regras apropriadas.',5);
insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select s.id,c.id,d.id,t.id,l.id,s.question_text,'single_choice',s.difficulty,s.explanation,true,s.display_order
from stage_973_questions s join public.certifications c on c.code='az-900'
join public.domains d on d.certification_id=c.id and d.title='Describe Azure management and governance'
join public.topics t on t.id='33000000-0000-4000-8000-000000000004' and t.domain_id=d.id
join public.lessons l on l.topic_id=t.id and l.slug=s.lesson_slug;

create temporary table stage_973_options(id uuid primary key,question_id uuid,option_text text,is_correct boolean,explanation text,display_order integer) on commit drop;
insert into stage_973_options
select ('7f290000-0000-4000-8000-'||lpad(((q.n-174)*4+o.n)::text,12,'0'))::uuid,
  ('68000000-0000-4000-8000-'||lpad(q.n::text,12,'0'))::uuid,
  case
    when q.n=174 then (array['Azure Monitor.','Azure Advisor.','Azure Service Health.','Azure Cost Management.'])[o.n]
    when q.n=175 then (array['Logs.','Metrics.','Health advisories.','Recommendations.'])[o.n]
    when q.n=176 then (array['Azure Status.','Azure Monitor Metrics.','Azure Advisor.','Resource Locks.'])[o.n]
    when q.n=177 then (array['Azure Monitor.','Azure Advisor.','Log Analytics.','Resource Health.'])[o.n]
    when q.n=178 then (array['Monitor mostra availability; Resource Health recomenda custo.','Resource Health trata availability; Monitor Metric mostra CPU.','Service Health mostra CPU; Advisor mostra availability.','Log Analytics substitui ambos.'])[o.n]
    when q.n=179 then (array['Log Analytics.','Azure Status.','Azure Advisor.','Resource Health.'])[o.n]
    when q.n=180 then (array['Logs são numéricos; Metrics são eventos.','Logs trazem eventos detalhados; Metrics são séries numéricas.','São sempre o mesmo dado.','Metrics existem apenas para aplicações.'])[o.n]
    when q.n=181 then (array['Azure Advisor.','Log Analytics.','Azure Status.','Resource Locks.'])[o.n]
    when q.n=182 then (array['Memorizar joins avançados.','Reconhecer KQL como contexto, sem exigir sintaxe.','Administrar ingestion avançada.','Criar workspaces complexos.'])[o.n]
    when q.n=183 then (array['Correta: são sinônimos.','Errada: Log Analytics é uma experiência para logs dentro do Monitor.','Correta apenas para Metrics.','Errada porque Log Analytics é Service Health.'])[o.n]
    when q.n=184 then (array['Fornece recommendations.','Avalia condições e pode gerar notificações ou ações.','Mostra somente outages globais.','Armazena arquivos.'])[o.n]
    when q.n=185 then (array['Signal → condition → alert → notification/action.','Alert → resource group → metric → region.','Notification → Advisor → cost → alert.','Log → Status → lock → action.'])[o.n]
    when q.n=186 then (array['Azure Advisor.','Azure Monitor Alerts.','Azure Status.','Resource Health apenas.'])[o.n]
    when q.n=187 then (array['Metric é sinal; Alert avalia condição sobre sinais.','Alert é a própria CPU.','Metric sempre envia notificações.','São serviços sem relação.'])[o.n]
    else (array['Correta: todo dado gera alert.','Errada: alerts precisam de condições e regras.','Correta somente para logs.','Errada porque Monitor não possui alerts.'])[o.n] end,
  o.n=case q.n when 174 then 1 when 175 then 2 when 176 then 2 when 177 then 2 when 178 then 2
    when 179 then 1 when 180 then 2 when 181 then 2 when 182 then 2 when 183 then 2
    when 184 then 2 when 185 then 1 when 186 then 2 when 187 then 1 else 2 end,
  case when o.n=case q.n when 174 then 1 when 175 then 2 when 176 then 2 when 177 then 2 when 178 then 2
    when 179 then 1 when 180 then 2 when 181 then 2 when 182 then 2 when 183 then 2
    when 184 then 2 when 185 then 1 when 186 then 2 when 187 then 1 else 2 end
    then 'Correta. A opção aplica a finalidade ou o fluxo adequado.' else 'Incorreta. A opção confunde telemetria, health, recommendations ou alerts.' end,
  o.n
from generate_series(174,188) q(n) cross join generate_series(1,4) o(n);
insert into public.question_options select * from stage_973_options;

-- Simplifica cinco Questions históricas de Application Insights sem trocar UUIDs.
update public.questions set question_text=case id
  when '63000000-0000-4000-8000-000000000003' then 'Qual afirmação descreve o foco do Application Insights?'
  when '63000000-0000-4000-8000-000000000005' then 'Uma equipe quer acompanhar requests, failures e response time de uma aplicação web. Qual ferramenta deve usar?'
  when '63000000-0000-4000-8000-000000000006' then 'Uma API está lenta e a equipe quer investigar a dependency de banco de dados. Qual ferramenta é mais alinhada?'
  when '63000000-0000-4000-8000-000000000009' then 'Qual cenário aponta mais diretamente para Application Insights?'
  when '63000000-0000-4000-8000-000000000010' then 'Uma equipe precisa distinguir Application Insights de Service Health. Qual afirmação está correta?' end,
  explanation=case id
  when '63000000-0000-4000-8000-000000000003' then 'Application Insights oferece APM para observar performance, failures, requests e dependencies de aplicações.'
  when '63000000-0000-4000-8000-000000000005' then 'Application Insights é a capacidade especializada em application telemetry e performance.'
  when '63000000-0000-4000-8000-000000000006' then 'Dependencies e response time são sinais de APM analisados com Application Insights.'
  when '63000000-0000-4000-8000-000000000009' then 'Performance, requests, failures e dependencies de aplicações apontam para Application Insights.'
  when '63000000-0000-4000-8000-000000000010' then 'Application Insights monitora aplicações; Service Health comunica eventos da plataforma relevantes ao cliente.' end
where id in('63000000-0000-4000-8000-000000000003','63000000-0000-4000-8000-000000000005','63000000-0000-4000-8000-000000000006','63000000-0000-4000-8000-000000000009','63000000-0000-4000-8000-000000000010');

update public.question_options set is_correct=false where id between '74000000-0000-4000-8000-000000000009' and '74000000-0000-4000-8000-000000000012'
  or id between '74000000-0000-4000-8000-000000000017' and '74000000-0000-4000-8000-000000000024'
  or id between '74000000-0000-4000-8000-000000000033' and '74000000-0000-4000-8000-000000000040';
update public.question_options set option_text=case id
  when '74000000-0000-4000-8000-000000000009' then 'APM para performance e comportamento de aplicações.' when '74000000-0000-4000-8000-000000000010' then 'Avisos de manutenção da plataforma.' when '74000000-0000-4000-8000-000000000011' then 'Recomendações gerais de custo.' when '74000000-0000-4000-8000-000000000012' then 'Saúde de uma VM específica.'
  when '74000000-0000-4000-8000-000000000017' then 'Application Insights.' when '74000000-0000-4000-8000-000000000018' then 'Azure Advisor.' when '74000000-0000-4000-8000-000000000019' then 'Azure Status.' when '74000000-0000-4000-8000-000000000020' then 'Resource Health.'
  when '74000000-0000-4000-8000-000000000021' then 'Log Analytics apenas.' when '74000000-0000-4000-8000-000000000022' then 'Application Insights.' when '74000000-0000-4000-8000-000000000023' then 'Service Health.' when '74000000-0000-4000-8000-000000000024' then 'Azure Cost Management.'
  when '74000000-0000-4000-8000-000000000033' then 'Investigar performance e failures de uma aplicação web.' when '74000000-0000-4000-8000-000000000034' then 'Consultar uma interrupção global pública.' when '74000000-0000-4000-8000-000000000035' then 'Receber recommendations de custo.' when '74000000-0000-4000-8000-000000000036' then 'Proteger um recurso contra exclusão.'
  when '74000000-0000-4000-8000-000000000037' then 'Insights monitora aplicações; Service Health comunica eventos da plataforma.' when '74000000-0000-4000-8000-000000000038' then 'Insights comunica manutenção; Service Health mede response time.' when '74000000-0000-4000-8000-000000000039' then 'São exatamente o mesmo serviço.' when '74000000-0000-4000-8000-000000000040' then 'Service Health fornece APM; Insights mostra outages globais.' end,
  is_correct=id in('74000000-0000-4000-8000-000000000009','74000000-0000-4000-8000-000000000017','74000000-0000-4000-8000-000000000022','74000000-0000-4000-8000-000000000033','74000000-0000-4000-8000-000000000037'),
  explanation=case when id in('74000000-0000-4000-8000-000000000009','74000000-0000-4000-8000-000000000017','74000000-0000-4000-8000-000000000022','74000000-0000-4000-8000-000000000033','74000000-0000-4000-8000-000000000037') then 'Correta. A opção aplica o foco APM.' else 'Incorreta. Confunde APM com health, recommendations, custos ou locks.' end
where id between '74000000-0000-4000-8000-000000000009' and '74000000-0000-4000-8000-000000000012'
  or id between '74000000-0000-4000-8000-000000000017' and '74000000-0000-4000-8000-000000000024'
  or id between '74000000-0000-4000-8000-000000000033' and '74000000-0000-4000-8000-000000000040';

commit;

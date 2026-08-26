begin;

do $$
declare
  target_count integer;
begin
  select count(*)
  into target_count
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Benefits of Cloud Services'
    and lesson.slug in (
      'high-availability',
      'scalability',
      'elasticity',
      'reliability',
      'predictability',
      'security-and-governance-benefits',
      'manageability'
    );

  if target_count <> 7 then
    raise exception 'Cloud benefits enrichment expected exactly 7 target lessons, found %', target_count;
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and topic.title = 'Cloud Service Types'
  ) then
    raise exception 'Cloud Service Types must remain unconverted before 8.4.4';
  end if;
end;
$$;

create temporary table cloud_benefits_block_seed (
  id uuid primary key,
  lesson_slug text not null,
  type text not null,
  title text,
  content text,
  config jsonb,
  display_order integer not null,
  is_published boolean not null
) on commit drop;

insert into cloud_benefits_block_seed values
  (
    '7b010000-0000-4000-8000-000000000001',
    'high-availability',
    'explanation',
    'O que é High Availability?',
    $content$High Availability é a capacidade de manter um serviço acessível pelo maior tempo possível. O objetivo é reduzir downtime planejado ou não planejado, evitando que a falha de um único componente interrompa toda a aplicação.

Isso normalmente envolve redundância: mais de uma instância ou caminho capaz de atender à carga. Se um componente falha ou entra em manutenção, outro pode continuar o atendimento e preservar a continuidade do serviço.$content$,
    null,
    1,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000002',
    'high-availability',
    'important',
    'Availability e Reliability se relacionam',
    $content$Availability enfatiza se o serviço está acessível quando necessário. Reliability é mais ampla: considera a capacidade de operar corretamente, resistir a falhas e se recuperar. Redundância pode contribuir para as duas, mas os conceitos não são sinônimos nem têm uma fronteira absoluta.$content$,
    null,
    2,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000003',
    'high-availability',
    'example',
    'Continuidade durante manutenção',
    $content$Uma API é executada em duas instâncias. Durante a atualização de uma delas, a outra continua respondendo às requisições. A redundância reduz o período em que o serviço ficaria indisponível se existisse apenas uma instância.$content$,
    null,
    3,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000004',
    'high-availability',
    'dotnet_example',
    'Uma API .NET sem ponto único de falha',
    $content$Uma ASP.NET Core API pode ser publicada em múltiplas instâncias atrás de um balanceador. As instâncias devem ser preparadas para atender requisições independentemente, enquanto estado importante permanece em serviços adequados e redundantes. Se uma instância deixa de responder, as demais preservam o atendimento.$content$,
    null,
    4,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000005',
    'high-availability',
    'exam_tip',
    'SLA é um conceito relacionado',
    $content$Um Service Level Agreement, ou SLA, expressa o compromisso de disponibilidade de um serviço, normalmente como uma porcentagem de uptime em determinado período. O SLA não cria redundância por si só; ele descreve um nível de serviço e suas condições.$content$,
    null,
    5,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000006',
    'high-availability',
    'exam_trap',
    'Alta disponibilidade não significa zero downtime',
    $content$Arquiteturas altamente disponíveis reduzem interrupções e pontos únicos de falha, mas não prometem que nenhuma falha ocorrerá. Na prova, desconfie de alternativas com termos absolutos como “nunca fica indisponível”.$content$,
    null,
    6,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000007',
    'high-availability',
    'summary',
    'Resumo',
    null,
    $json${"items": ["High Availability busca reduzir downtime.", "Redundância evita que um único componente interrompa todo o serviço.", "Continuidade permite manter atendimento durante falhas ou manutenção.", "SLA expressa um compromisso relacionado à disponibilidade.", "Alta disponibilidade reduz riscos, mas não elimina falhas."]}$json$::jsonb,
    7,
    true
  ),

  (
    '7b020000-0000-4000-8000-000000000001',
    'scalability',
    'explanation',
    'Duas direções de Scalability',
    $content$Scalability é a capacidade de ajustar recursos para atender mudanças de demanda.

Vertical scaling altera a capacidade de um recurso individual. Scale up adiciona CPU, memória ou outra capacidade; scale down reduz essa capacidade.

Horizontal scaling altera a quantidade de recursos. Scale out adiciona instâncias; scale in remove instâncias que deixaram de ser necessárias.$content$,
    null,
    1,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000002',
    'scalability',
    'important',
    'Tamanho versus quantidade',
    $content$Use esta associação: vertical muda o tamanho de uma unidade; horizontal muda a quantidade de unidades. As duas abordagens podem aumentar ou reduzir capacidade, mas apresentam limites, custos e requisitos de arquitetura diferentes.$content$,
    null,
    2,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000003',
    'scalability',
    'example',
    'VM maior ou mais instâncias',
    $content$Trocar uma VM de 2 vCPUs por outra de 8 vCPUs é scale up. Voltar para a VM menor é scale down. Manter o mesmo tamanho e passar de duas para seis VMs é scale out; remover quatro quando a demanda cai é scale in.$content$,
    null,
    3,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000004',
    'scalability',
    'dotnet_example',
    'Escalando uma API .NET',
    $content$Uma ASP.NET Core API com alto uso de CPU pode receber uma instância maior, aplicando scale up. Se a aplicação for preparada para executar em paralelo sem depender de estado local, também pode receber novas instâncias atrás de um balanceador, aplicando scale out.$content$,
    null,
    4,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000005',
    'scalability',
    'exam_tip',
    'Reconheça os verbos da questão',
    $content$Mais CPU ou memória no mesmo recurso indica scale up. Mais cópias ou instâncias indicam scale out. Reduzir o tamanho indica scale down; reduzir a quantidade indica scale in.$content$,
    null,
    5,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000006',
    'scalability',
    'exam_trap',
    'Scalability não implica automação',
    $content$Um sistema pode ser escalável mesmo quando a decisão de aumentar ou reduzir recursos é manual. Quando o ajuste acompanha dinamicamente a demanda, o cenário também envolve elasticity.$content$,
    null,
    6,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000007',
    'scalability',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Scalability ajusta capacidade para atender demanda.", "Scale up e down alteram o tamanho de um recurso.", "Scale out e in alteram a quantidade de instâncias.", "VM maior é escala vertical; mais instâncias é escala horizontal.", "Escalabilidade não exige ajuste automático."]}$json$::jsonb,
    7,
    true
  ),

  (
    '7b030000-0000-4000-8000-000000000001',
    'elasticity',
    'explanation',
    'Capacidade acompanhando a demanda',
    $content$Elasticity é a capacidade de ajustar recursos conforme a demanda muda. Quando o tráfego sobe, a capacidade pode crescer. Quando o tráfego cai, recursos excedentes podem ser reduzidos.

Esse movimento em ambas as direções ajuda a manter desempenho durante picos e a evitar capacidade ociosa permanente depois que o pico termina.$content$,
    null,
    1,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000002',
    'elasticity',
    'important',
    'Elasticidade responde à variação',
    $content$Elasticidade é especialmente útil quando a demanda é variável ou difícil de prever. Regras e métricas podem orientar o aumento e a redução automática, mas o benefício depende de configuração e limites adequados.$content$,
    null,
    2,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000003',
    'elasticity',
    'example',
    'Loja durante uma promoção',
    $content$Uma loja virtual adiciona capacidade quando uma promoção aumenta o número de acessos. Depois da campanha, a capacidade retorna ao nível normal. O ambiente acompanhou a demanda em vez de manter recursos de pico durante todo o mês.$content$,
    null,
    3,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000004',
    'elasticity',
    'dotnet_example',
    'Autoscaling para uma API .NET',
    $content$Uma API ASP.NET Core pode executar em várias instâncias. Uma regra de autoscaling adiciona instâncias quando uma métrica permanece acima do limite definido e remove instâncias quando a carga diminui. A aplicação precisa suportar essa distribuição e o limite mínimo evita remover capacidade essencial.$content$,
    null,
    4,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000005',
    'elasticity',
    'exam_tip',
    'Procure crescimento e redução conforme a demanda',
    $content$Questões sobre adicionar recursos durante um pico e removê-los depois normalmente descrevem elasticity. O retorno da capacidade para baixo é tão importante quanto o crescimento.$content$,
    null,
    5,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000006',
    'elasticity',
    'exam_trap',
    'Scalability versus Elasticity',
    $content$Scalability é a capacidade de aumentar ou reduzir recursos. Elasticity enfatiza usar essa capacidade de forma dinâmica para acompanhar a demanda, frequentemente por automação. Os conceitos se sobrepõem: elasticidade utiliza mecanismos de escala, mas nem toda escala é elástica.$content$,
    null,
    6,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000007',
    'elasticity',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Elasticity faz a capacidade acompanhar a demanda.", "Recursos crescem quando a demanda sobe.", "Recursos podem ser reduzidos quando a demanda cai.", "Autoscaling é um mecanismo comum para aplicar elasticidade.", "Elasticity usa scalability, mas os termos não são equivalentes."]}$json$::jsonb,
    7,
    true
  ),

  (
    '7b040000-0000-4000-8000-000000000001',
    'reliability',
    'explanation',
    'Operar e se recuperar diante de falhas',
    $content$Reliability é a capacidade de um sistema executar sua função de forma consistente e se recuperar quando algo falha. Uma arquitetura confiável combina resiliência, redundância e mecanismos de recuperação para limitar o impacto de problemas.

A nuvem oferece recursos para criar essas arquiteturas, mas a aplicação e os dados ainda precisam ser projetados, configurados e operados corretamente.$content$,
    null,
    1,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000002',
    'reliability',
    'important',
    'Falhas continuam possíveis',
    $content$Cloud computing não elimina falhas de hardware, software, rede ou configuração. O benefício é poder usar redundância, monitoramento e recuperação para resistir melhor a elas e restaurar o serviço com menos impacto.$content$,
    null,
    2,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000003',
    'reliability',
    'example',
    'Recuperação sem perder o resultado',
    $content$Um processamento grava checkpoints e mantém cópias dos dados. Se uma instância falha, outra retoma o trabalho a partir de um ponto conhecido, em vez de reiniciar todo o processo ou perder informações já confirmadas.$content$,
    null,
    3,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000004',
    'reliability',
    'dotnet_example',
    'Resiliência em uma aplicação .NET',
    $content$Uma aplicação .NET trata falhas transitórias com tentativas limitadas e espera progressiva, sem repetir indefinidamente uma operação. Para tarefas assíncronas, mensagens persistentes permitem que outro worker continue o processamento se uma instância parar.$content$,
    null,
    4,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000005',
    'reliability',
    'exam_tip',
    'Reliability combina resistência e recuperação',
    $content$Se o cenário destaca continuar produzindo resultados corretos, limitar o impacto de falhas e recuperar a operação, pense em reliability. Redundância é um meio; não é o benefício completo.$content$,
    null,
    5,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000006',
    'reliability',
    'exam_trap',
    'Availability versus Reliability',
    $content$Availability pergunta se o serviço está acessível; reliability considera também operação consistente, resiliência e recuperação. Um sistema pode estar online e ainda produzir respostas incorretas. Na prática os conceitos se apoiam, portanto evite tratá-los como opostos absolutos.$content$,
    null,
    6,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000007',
    'reliability',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Reliability busca operação consistente e recuperação.", "Resiliência limita o impacto de falhas.", "Redundância e recuperação apoiam a continuidade.", "A nuvem não elimina falhas.", "Availability e Reliability se relacionam, mas têm ênfases diferentes."]}$json$::jsonb,
    7,
    true
  ),

  (
    '7b050000-0000-4000-8000-000000000001',
    'predictability',
    'explanation',
    'Previsibilidade de performance e cost',
    $content$Predictability ajuda uma organização a estimar e controlar o comportamento técnico e financeiro de uma solução.

Performance predictability usa medições, padrões de carga, dimensionamento e opções de escala para planejar capacidade. Cost predictability usa consumo observado e modelos de preço para estimar como decisões de arquitetura afetam gastos.$content$,
    null,
    1,
    true
  ),
  (
    '7b050000-0000-4000-8000-000000000002',
    'predictability',
    'important',
    'Previsibilidade melhora decisões, não garante valores fixos',
    $content$Monitoramento e estimativas reduzem incerteza, mas demanda, configuração e uso podem mudar. Autoscaling pode ajudar a manter performance e ajustar capacidade; ao mesmo tempo, aumentar recursos também pode elevar custos.$content$,
    null,
    2,
    true
  ),
  (
    '7b050000-0000-4000-8000-000000000003',
    'predictability',
    'example',
    'Planejar e acompanhar',
    $content$Antes de lançar uma aplicação, a equipe estima quantidade e tamanho de recursos com base na carga esperada e no modelo de preço. Depois do lançamento, acompanha métricas de performance e consumo para comparar o resultado real com a previsão e ajustar o plano.$content$,
    null,
    3,
    true
  ),
  (
    '7b050000-0000-4000-8000-000000000004',
    'predictability',
    'dotnet_example',
    'Medindo uma API .NET',
    $content$Uma equipe registra tempo de resposta, taxa de requisições e erros de uma ASP.NET Core API. Esses dados ajudam a dimensionar instâncias e regras de escala. O consumo medido também ajuda a relacionar o perfil de uso com a estimativa de custo.$content$,
    null,
    4,
    true
  ),
  (
    '7b050000-0000-4000-8000-000000000005',
    'predictability',
    'exam_tip',
    'Duas dimensões na mesma alternativa',
    $content$No AZ-900, predictability pode se referir a performance e a cost. Monitoramento, dimensionamento, autoscaling e modelos de preço fornecem informações e mecanismos para planejar as duas dimensões.$content$,
    null,
    5,
    true
  ),
  (
    '7b050000-0000-4000-8000-000000000006',
    'predictability',
    'exam_trap',
    'Autoscaling não torna o custo invariável',
    $content$Autoscaling ajusta capacidade conforme regras e demanda. Ele pode reduzir desperdício quando remove recursos ociosos, mas uma demanda maior pode exigir mais capacidade e aumentar o gasto. Predictability não significa custo sempre igual.$content$,
    null,
    6,
    true
  ),
  (
    '7b050000-0000-4000-8000-000000000007',
    'predictability',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Predictability se aplica a performance e cost.", "Monitoramento fornece dados para planejar.", "Dimensionamento e autoscaling ajudam a ajustar capacidade.", "Modelos de preço apoiam estimativas financeiras.", "Previsibilidade reduz incerteza, mas não garante resultados invariáveis."]}$json$::jsonb,
    7,
    true
  ),

  (
    '7b060000-0000-4000-8000-000000000001',
    'security-and-governance-benefits',
    'explanation',
    'Security como benefício da nuvem',
    $content$Cloud providers oferecem recursos de segurança que podem ser usados de forma consistente e em escala. Identity controla quem pode acessar recursos; encryption ajuda a proteger dados; security services detectam ou bloqueiam ameaças; controls limitam ações e exposição.

Esses recursos facilitam a proteção, mas precisam ser selecionados, configurados, monitorados e usados de acordo com o Shared Responsibility Model.$content$,
    null,
    1,
    true
  ),
  (
    '7b060000-0000-4000-8000-000000000002',
    'security-and-governance-benefits',
    'important',
    'Cloud não significa automaticamente seguro',
    $content$O provider protege partes da plataforma, enquanto o cliente mantém responsabilidades sobre dados, identidades, acessos, configurações e uso, em graus diferentes conforme o serviço. Um recurso disponível não protege nada se for configurado ou utilizado de forma inadequada.$content$,
    null,
    2,
    true
  ),
  (
    '7b060000-0000-4000-8000-000000000003',
    'security-and-governance-benefits',
    'example',
    'Controles aplicados em conjunto',
    $content$Uma aplicação exige identidade autenticada, concede somente as permissões necessárias, criptografa dados e registra eventos relevantes. Cada controle trata uma parte do risco; nenhum controle isolado torna toda a solução segura.$content$,
    null,
    3,
    true
  ),
  (
    '7b060000-0000-4000-8000-000000000004',
    'security-and-governance-benefits',
    'explanation',
    'Governance como benefício da nuvem',
    $content$Governance estabelece regras organizacionais para que recursos sejam criados e operados de modo padronizado. Policies e outros controles ajudam a aplicar requisitos de localização, nomenclatura, configuração, custo e compliance.

O objetivo é aumentar controle e consistência em escala. Nesta etapa, policy é um conceito geral; os mecanismos específicos do Azure serão estudados depois.$content$,
    null,
    4,
    true
  ),
  (
    '7b060000-0000-4000-8000-000000000005',
    'security-and-governance-benefits',
    'example',
    'Uma regra organizacional consistente',
    $content$Uma organização determina que recursos devem usar regiões aprovadas, possuir identificação do centro de custo e seguir configurações mínimas. Em vez de depender apenas de conferência manual, regras e controles de governança ajudam a padronizar o ambiente e demonstrar compliance.$content$,
    null,
    5,
    true
  ),
  (
    '7b060000-0000-4000-8000-000000000006',
    'security-and-governance-benefits',
    'dotnet_example',
    'Aplicação .NET dentro das regras',
    $content$Ao publicar uma API .NET, a equipe usa identidade para acesso, criptografia para dados e controles de rede para reduzir exposição. A organização também exige padrões de nomes, regiões permitidas e identificação de custos. Segurança protege a carga; governança orienta e controla como todo o ambiente deve ser administrado.$content$,
    null,
    6,
    true
  ),
  (
    '7b060000-0000-4000-8000-000000000007',
    'security-and-governance-benefits',
    'exam_tip',
    'Identifique o objetivo principal',
    $content$Identity, encryption e proteção contra ameaças apontam principalmente para security. Padronização, policies, compliance e regras organizacionais apontam principalmente para governance. Uma mesma medida pode contribuir para as duas.$content$,
    null,
    7,
    true
  ),
  (
    '7b060000-0000-4000-8000-000000000008',
    'security-and-governance-benefits',
    'exam_trap',
    'Security versus Governance',
    $content$Security reduz riscos e protege identidades, dados, aplicações e infraestrutura. Governance define direção, padrões, responsabilidades e controles para manter o ambiente alinhado às regras da organização. Os conceitos se sobrepõem: uma policy pode impor uma configuração de segurança e servir aos dois objetivos.$content$,
    null,
    8,
    true
  ),
  (
    '7b060000-0000-4000-8000-000000000009',
    'security-and-governance-benefits',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Security inclui identity, encryption, security services e controls.", "Shared Responsibility continua válido na nuvem.", "Governance promove padronização, policies, compliance e controle.", "Regras organizacionais ajudam a administrar recursos de modo consistente.", "Security e Governance têm ênfases diferentes, mas podem se sobrepor."]}$json$::jsonb,
    9,
    true
  ),

  (
    '7b070000-0000-4000-8000-000000000001',
    'manageability',
    'explanation',
    'Múltiplas formas de administrar Azure',
    $content$Manageability é o benefício de provisionar, configurar, monitorar e alterar recursos de maneira controlada. O Azure pode ser administrado por uma interface gráfica no Portal, por comandos com CLI ou PowerShell, por APIs e por definições de Infrastructure as Code.

Essas opções atendem desde tarefas exploratórias até operações repetíveis e automatizadas.$content$,
    null,
    1,
    true
  ),
  (
    '7b070000-0000-4000-8000-000000000002',
    'manageability',
    'important',
    'Gerenciar na nuvem e gerenciar pela nuvem',
    $content$Manageability in the cloud descreve recursos e capacidades para operar o ambiente, como escala e monitoramento. Manageability of the cloud descreve as formas de interagir com os recursos, como Portal, CLI, PowerShell, APIs e templates. As formulações podem se sobrepor em cenários reais.$content$,
    null,
    2,
    true
  ),
  (
    '7b070000-0000-4000-8000-000000000003',
    'manageability',
    'example',
    'Da exploração à repetição',
    $content$Uma pessoa cria um recurso pelo Portal para conhecer as opções. Quando a equipe precisa repetir o mesmo ambiente em desenvolvimento e produção, descreve a infraestrutura como código e automatiza a implantação para aumentar consistência.$content$,
    null,
    3,
    true
  ),
  (
    '7b070000-0000-4000-8000-000000000004',
    'manageability',
    'dotnet_example',
    'Operando o ambiente de uma API .NET',
    $content$A equipe pode consultar uma aplicação pelo Portal, executar comandos com Azure CLI ou PowerShell, integrar uma ferramenta por API e recriar a infraestrutura da ASP.NET Core API por Infrastructure as Code. São interfaces diferentes para administrar recursos de maneira consistente.$content$,
    null,
    4,
    true
  ),
  (
    '7b070000-0000-4000-8000-000000000005',
    'manageability',
    'exam_tip',
    'Portal não é a única opção',
    $content$Questões conceituais podem listar Portal, CLI, PowerShell, APIs e Infrastructure as Code como formas válidas de administrar Azure. A melhor interface depende da tarefa, da repetição e do nível de automação necessário.$content$,
    null,
    5,
    true
  ),
  (
    '7b070000-0000-4000-8000-000000000006',
    'manageability',
    'exam_trap',
    'Automação não elimina governança',
    $content$CLI, scripts, APIs e Infrastructure as Code tornam operações repetíveis, mas também precisam seguir permissões, revisão e regras organizacionais. Automatizar uma configuração incorreta apenas repete o erro com mais velocidade.$content$,
    null,
    6,
    true
  ),
  (
    '7b070000-0000-4000-8000-000000000007',
    'manageability',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Manageability permite provisionar, configurar, monitorar e alterar recursos.", "Portal oferece uma interface gráfica.", "CLI e PowerShell permitem administração por comandos.", "APIs permitem integração com ferramentas.", "Infrastructure as Code favorece repetição, automação e consistência."]}$json$::jsonb,
    7,
    true
  );

do $$
begin
  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug in (
      'high-availability',
      'scalability',
      'elasticity',
      'reliability',
      'predictability',
      'security-and-governance-benefits',
      'manageability'
    )
      and not exists (
        select 1
        from cloud_benefits_block_seed seed
        where seed.id = block.id
          and seed.lesson_slug = lesson.slug
      )
  ) then
    raise exception 'A target lesson already has content blocks outside the 8.4.3 seed';
  end if;

  if (select count(*) from cloud_benefits_block_seed) <> 51 then
    raise exception 'Cloud benefits block seed expected 51 rows';
  end if;
end;
$$;

with target_lessons as (
  select lesson.id, lesson.slug
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Benefits of Cloud Services'
),
resolved_seed as (
  select seed.*, target.id as lesson_id
  from cloud_benefits_block_seed seed
  join target_lessons target on target.slug = seed.lesson_slug
)
insert into public.lesson_content_blocks (
  id,
  lesson_id,
  type,
  title,
  content,
  config,
  display_order,
  is_published
)
select
  seed.id,
  seed.lesson_id,
  seed.type,
  seed.title,
  seed.content,
  seed.config,
  seed.display_order,
  seed.is_published
from resolved_seed seed
order by seed.lesson_slug, seed.display_order
on conflict (id) do update set
  lesson_id = excluded.lesson_id,
  type = excluded.type,
  title = excluded.title,
  content = excluded.content,
  config = excluded.config,
  visual_experience_id = null,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

update public.lessons lesson
set estimated_minutes = case lesson.slug
  when 'high-availability' then 10
  when 'scalability' then 10
  when 'elasticity' then 10
  when 'reliability' then 10
  when 'predictability' then 10
  when 'security-and-governance-benefits' then 12
  when 'manageability' then 10
  else lesson.estimated_minutes
end
from public.topics topic
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where lesson.topic_id = topic.id
  and certification.code = 'az-900'
  and domain.title = 'Describe cloud concepts'
  and topic.title = 'Benefits of Cloud Services'
  and lesson.slug in (
    'high-availability',
    'scalability',
    'elasticity',
    'reliability',
    'predictability',
    'security-and-governance-benefits',
    'manageability'
  );

do $$
declare
  published_block_count integer;
  enriched_lesson_count integer;
begin
  select count(*), count(distinct lesson.id)
  into published_block_count, enriched_lesson_count
  from public.lesson_content_blocks block
  join public.lessons lesson on lesson.id = block.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Benefits of Cloud Services'
    and block.is_published;

  if published_block_count <> 51 or enriched_lesson_count <> 7 then
    raise exception 'Unexpected benefits lesson/block count: lessons %, blocks %', enriched_lesson_count, published_block_count;
  end if;

  if exists (
    select 1
    from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and topic.title = 'Benefits of Cloud Services'
      and (lesson.content is null or btrim(lesson.content) = '')
  ) then
    raise exception 'Legacy lessons.content must remain available after benefits enrichment';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and topic.title = 'Cloud Service Types'
  ) then
    raise exception 'Cloud Service Types were modified by 8.4.3';
  end if;
end;
$$;

commit;

begin;

update public.domains
set
  title = 'Describe cloud concepts',
  description = 'Fundamentos de computação em nuvem, benefícios e modelos de serviço.',
  exam_weight_min = 25,
  exam_weight_max = 30,
  display_order = 1
where certification_id = (select id from public.certifications where code = 'az-900')
  and id = '20000000-0000-4000-8000-000000000001';

update public.domains
set
  title = 'Describe Azure architecture and services',
  description = 'Componentes arquitetônicos e serviços de computação, rede, armazenamento, identidade e segurança.',
  exam_weight_min = 35,
  exam_weight_max = 40,
  display_order = 2
where certification_id = (select id from public.certifications where code = 'az-900')
  and id = '20000000-0000-4000-8000-000000000002';

update public.domains
set
  title = 'Describe Azure management and governance',
  description = 'Custos, governança, implantação, administração e monitoramento de recursos do Azure.',
  exam_weight_min = 30,
  exam_weight_max = 35,
  display_order = 3
where certification_id = (select id from public.certifications where code = 'az-900')
  and id = '20000000-0000-4000-8000-000000000003';

insert into public.topics (id, domain_id, title, description, display_order)
values
  ('30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'Cloud Computing', 'Conceitos básicos, modelos de nuvem, consumo e computação sem servidor.', 1),
  ('31000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000001', 'Benefits of Cloud Services', 'Benefícios operacionais e de negócio oferecidos por serviços em nuvem.', 2),
  ('31000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000001', 'Cloud Service Types', 'Responsabilidades e usos de IaaS, PaaS e SaaS.', 3),
  ('30000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000002', 'Core Architectural Components', 'Organização física e lógica dos recursos no Azure.', 1),
  ('32000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000002', 'Compute Services', 'Opções do Azure para hospedar aplicações e cargas de computação.', 2),
  ('32000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000002', 'Networking Services', 'Conectividade, isolamento e acesso público ou privado no Azure.', 3),
  ('32000000-0000-4000-8000-000000000004', '20000000-0000-4000-8000-000000000002', 'Storage Services', 'Serviços, camadas, redundância e movimentação de dados.', 4),
  ('32000000-0000-4000-8000-000000000005', '20000000-0000-4000-8000-000000000002', 'Identity, Access and Security', 'Identidades, autenticação, autorização e proteção em camadas.', 5),
  ('33000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000003', 'Cost Management', 'Fatores de custo, estimativas, controle e organização de gastos.', 1),
  ('33000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000003', 'Governance and Compliance', 'Políticas, bloqueios e governança de dados no Azure.', 2),
  ('33000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000003', 'Resource Management and Deployment', 'Ferramentas e abordagens para administrar e implantar recursos.', 3),
  ('33000000-0000-4000-8000-000000000004', '20000000-0000-4000-8000-000000000003', 'Monitoring', 'Recomendações, integridade, métricas, logs, alertas e telemetria.', 4)
on conflict (id) do update set
  domain_id = excluded.domain_id,
  title = excluded.title,
  description = excluded.description,
  display_order = excluded.display_order;

update public.lessons
set topic_id = '31000000-0000-4000-8000-000000000002', slug = 'high-availability'
where id = '40000000-0000-4000-8000-000000000002';

update public.lessons
set topic_id = '31000000-0000-4000-8000-000000000003', slug = 'infrastructure-as-a-service'
where id = '40000000-0000-4000-8000-000000000003';

update public.lessons
set slug = 'resources-and-resource-groups'
where id = '40000000-0000-4000-8000-000000000006';

update public.lessons
set slug = 'subscriptions-and-management-groups'
where id = '40000000-0000-4000-8000-000000000007';

create temporary table az900_lesson_seed (
  topic_id uuid not null,
  slug text not null,
  title text not null,
  short_description text not null,
  explanation text not null,
  example text not null,
  exam_tip text not null,
  estimated_minutes integer not null,
  display_order integer not null
) on commit drop;

insert into az900_lesson_seed values
  ('30000000-0000-4000-8000-000000000001', 'what-is-cloud-computing', 'What is Cloud Computing?', 'Entenda o que significa consumir recursos de TI pela internet.', 'A nuvem entrega computação, armazenamento e rede sob demanda sem exigir que você compre toda a infraestrutura.', 'Uma API ASP.NET Core pode usar servidores e banco de dados no Azure em vez de equipamentos mantidos no escritório.', 'Nuvem significa acesso sob demanda, elasticidade e cobrança conforme o uso.', 8, 1),
  ('30000000-0000-4000-8000-000000000001', 'shared-responsibility-model', 'Shared Responsibility Model', 'Separe o que é responsabilidade do provedor e do cliente.', 'A Microsoft protege a infraestrutura física; o cliente continua responsável por dados, identidades e configurações, em graus diferentes conforme o serviço.', 'No Azure SQL Database, a Microsoft administra o servidor, mas sua equipe ainda controla usuários e permissões da aplicação.', 'A responsabilidade do cliente diminui de IaaS para PaaS e SaaS, mas nunca desaparece.', 10, 2),
  ('30000000-0000-4000-8000-000000000001', 'public-private-hybrid-cloud', 'Public, Private and Hybrid Cloud', 'Compare os três modelos de implantação de nuvem.', 'Nuvem pública usa infraestrutura de um provedor, privada é dedicada a uma organização e híbrida conecta os dois ambientes.', 'Um backend pode ficar no Azure enquanto um banco legado permanece no datacenter da empresa, formando um cenário híbrido.', 'Escolha o modelo pelo nível de controle, investimento, escala e requisitos regulatórios.', 10, 3),
  ('30000000-0000-4000-8000-000000000001', 'choosing-a-cloud-model', 'Choosing a Cloud Model', 'Associe cada modelo de nuvem a necessidades reais.', 'O modelo adequado depende de regras de dados, integração com sistemas existentes, velocidade de expansão e orçamento.', 'Uma aplicação React pública pode usar nuvem pública, enquanto dados regulados permanecem em uma infraestrutura privada conectada.', 'A prova costuma apresentar um requisito e pedir o modelo público, privado ou híbrido mais adequado.', 8, 4),
  ('30000000-0000-4000-8000-000000000001', 'consumption-based-model', 'Consumption-Based Model', 'Entenda pagamento conforme o consumo e ajuste de capacidade.', 'Em vez de comprar capacidade máxima antecipadamente, você mede o uso e paga pelos recursos consumidos.', 'Uma API com tráfego sazonal pode aumentar recursos durante uma campanha e reduzi-los depois.', 'O modelo de consumo reduz desperdício, mas exige monitoramento para controlar gastos.', 8, 5),
  ('30000000-0000-4000-8000-000000000001', 'capex-vs-opex', 'CapEx vs OpEx', 'Diferencie investimento de capital e despesa operacional.', 'CapEx envolve comprar ativos antecipadamente; OpEx representa gastos recorrentes associados ao uso de serviços.', 'Comprar servidores é CapEx, enquanto pagar mensalmente pelos recursos de uma aplicação no Azure se aproxima de OpEx.', 'A nuvem favorece custos operacionais e reduz a necessidade de grande investimento inicial.', 8, 6),
  ('30000000-0000-4000-8000-000000000001', 'serverless-computing', 'Serverless Computing', 'Compreenda execução de código sem administrar servidores.', 'Serverless abstrai a infraestrutura e pode cobrar principalmente por execução, embora servidores continuem existindo sob gestão do provedor.', 'Uma Azure Function pode processar uma mensagem quando um pedido é criado, sem manter uma VM sempre ligada.', 'Serverless enfatiza eventos, escala automática e menor gerenciamento de infraestrutura.', 8, 7),

  ('31000000-0000-4000-8000-000000000002', 'high-availability', 'High Availability', 'Mantenha serviços acessíveis mesmo quando componentes falham.', 'Alta disponibilidade combina redundância e arquitetura para reduzir interrupções.', 'Duas instâncias de uma API podem atender usuários enquanto uma delas passa por manutenção.', 'Disponibilidade é medida ao longo do tempo e pode ser formalizada em um SLA.', 8, 1),
  ('31000000-0000-4000-8000-000000000002', 'scalability', 'Scalability', 'Aumente ou reduza capacidade conforme a demanda.', 'Escala vertical altera a potência de um recurso; escala horizontal altera a quantidade de instâncias.', 'Uma API pode usar uma VM maior ou distribuir requisições entre várias instâncias.', 'Vertical significa tamanho; horizontal significa quantidade.', 8, 2),
  ('31000000-0000-4000-8000-000000000002', 'elasticity', 'Elasticity', 'Ajuste recursos automaticamente diante de variações rápidas.', 'Elasticidade é a capacidade de acompanhar a demanda, crescendo e diminuindo sem intervenção constante.', 'Um site de vendas adiciona instâncias durante uma promoção e remove quando o tráfego normaliza.', 'Elasticidade evita falta de capacidade e também excesso permanente de recursos.', 8, 3),
  ('31000000-0000-4000-8000-000000000002', 'reliability', 'Reliability', 'Recupere-se de falhas e continue entregando resultados corretos.', 'Confiabilidade usa redundância, recuperação e design resiliente para reduzir o impacto de falhas.', 'Uma aplicação grava cópias dos dados para continuar funcionando se um componente ficar indisponível.', 'Confiabilidade não elimina falhas; reduz impacto e melhora recuperação.', 8, 4),
  ('31000000-0000-4000-8000-000000000002', 'predictability', 'Predictability', 'Planeje desempenho e custos com ferramentas e padrões mensuráveis.', 'Serviços de nuvem oferecem métricas, modelos de preço e opções de escala que tornam resultados mais previsíveis.', 'Uma equipe estima o custo mensal da API antes do lançamento e acompanha o consumo depois.', 'Previsibilidade se aplica tanto ao desempenho quanto aos custos.', 8, 5),
  ('31000000-0000-4000-8000-000000000002', 'security-and-governance-benefits', 'Security and Governance', 'Use controles centralizados para proteger e padronizar recursos.', 'A nuvem oferece ferramentas de identidade, políticas, criptografia e conformidade integradas.', 'Uma política pode impedir que bancos SQL sejam criados em regiões não aprovadas.', 'O provedor oferece recursos de proteção, mas o cliente precisa configurá-los corretamente.', 10, 6),
  ('31000000-0000-4000-8000-000000000002', 'manageability', 'Manageability', 'Administre recursos por portais, APIs e automação.', 'A capacidade de gerenciamento permite provisionar, monitorar e alterar recursos de modo consistente.', 'A equipe cria o mesmo ambiente de backend com um template em vez de repetir cliques manuais.', 'Gerenciamento na nuvem inclui portal, linha de comando, APIs e infraestrutura como código.', 8, 7),

  ('31000000-0000-4000-8000-000000000003', 'infrastructure-as-a-service', 'Infrastructure as a Service (IaaS)', 'Entenda o modelo com maior controle do cliente.', 'Em IaaS, o provedor cuida do hardware e virtualização, enquanto o cliente administra sistema operacional, aplicações e dados.', 'Hospedar uma API ASP.NET Core em uma Azure Virtual Machine exige atualizar o sistema e configurar o servidor web.', 'IaaS oferece flexibilidade e controle, mas exige mais gerenciamento.', 10, 1),
  ('31000000-0000-4000-8000-000000000003', 'platform-as-a-service', 'Platform as a Service (PaaS)', 'Use uma plataforma gerenciada para desenvolver e publicar aplicações.', 'Em PaaS, o provedor também administra sistema operacional e runtime, deixando a equipe focada na aplicação e nos dados.', 'No Azure App Service, você publica a API sem manter o sistema operacional do servidor.', 'PaaS reduz tarefas operacionais em comparação com IaaS.', 10, 2),
  ('31000000-0000-4000-8000-000000000003', 'software-as-a-service', 'Software as a Service (SaaS)', 'Consuma uma aplicação pronta administrada pelo provedor.', 'SaaS entrega software completo acessado normalmente pela web, com pouca administração técnica pelo cliente.', 'Microsoft 365 é utilizado como produto pronto, sem que a empresa mantenha servidores da aplicação.', 'SaaS oferece menos controle técnico e a menor carga de gerenciamento.', 8, 3),
  ('31000000-0000-4000-8000-000000000003', 'choosing-iaas-paas-saas', 'Choosing IaaS, PaaS or SaaS', 'Compare controle, responsabilidade e velocidade entre os modelos.', 'A escolha equilibra personalização e esforço operacional: IaaS maximiza controle, PaaS acelera desenvolvimento e SaaS entrega solução pronta.', 'Uma VM, um App Service e o Microsoft 365 representam, respectivamente, IaaS, PaaS e SaaS.', 'Identifique quem administra sistema operacional, runtime, aplicação e dados em cada modelo.', 12, 4),

  ('30000000-0000-4000-8000-000000000002', 'azure-datacenters', 'Azure Datacenters', 'Conheça a base física dos serviços do Azure.', 'Datacenters são instalações com servidores, rede, energia e refrigeração que sustentam a nuvem.', 'Sua API não escolhe um prédio específico; normalmente escolhe uma região que reúne datacenters.', 'Datacenter é infraestrutura física, enquanto região é uma área geográfica do Azure.', 6, 1),
  ('30000000-0000-4000-8000-000000000002', 'azure-regions', 'Azure Regions', 'Entenda como serviços são organizados geograficamente.', 'Uma região contém um ou mais datacenters próximos e permite escolher onde recursos e dados serão hospedados.', 'Uma aplicação brasileira pode escolher uma região próxima para reduzir latência e atender requisitos de dados.', 'A escolha de região afeta latência, disponibilidade de serviços, conformidade e preço.', 8, 2),
  ('30000000-0000-4000-8000-000000000002', 'availability-zones', 'Availability Zones', 'Distribua recursos entre locais fisicamente separados em uma região.', 'Zonas de disponibilidade têm energia, rede e refrigeração independentes para limitar falhas compartilhadas.', 'Instâncias da API em zonas diferentes podem manter o serviço ativo se uma zona falhar.', 'Região é área geográfica; zona é uma separação física dentro de uma região compatível.', 8, 3),
  ('30000000-0000-4000-8000-000000000002', 'region-pairs-and-sovereign-regions', 'Region Pairs and Sovereign Regions', 'Diferencie emparelhamento regional e regiões isoladas por requisitos específicos.', 'Pares de regiões ajudam no planejamento de recuperação, enquanto regiões soberanas atendem necessidades governamentais ou regulatórias.', 'Uma estratégia de continuidade pode manter cópias em uma região pareada distante.', 'Pares ajudam na resiliência geográfica; regiões soberanas têm limites operacionais e regulatórios próprios.', 10, 4),
  ('30000000-0000-4000-8000-000000000002', 'resources-and-resource-groups', 'Resources and Resource Groups', 'Organize componentes relacionados em contêineres lógicos.', 'Um recurso é uma instância de serviço; um resource group reúne recursos para administração conjunta.', 'API, banco SQL e monitoramento do mesmo sistema podem ficar no mesmo resource group.', 'Um recurso pertence a apenas um resource group por vez, mas grupos podem conter tipos e regiões diferentes.', 10, 5),
  ('30000000-0000-4000-8000-000000000002', 'subscriptions-and-management-groups', 'Subscriptions and Management Groups', 'Compreenda limites de cobrança e organização em escala.', 'Subscriptions separam cobrança e acesso; management groups organizam várias subscriptions para aplicar governança.', 'Uma empresa usa subscriptions distintas para produção e desenvolvimento sob o mesmo management group.', 'Management groups ficam acima de subscriptions, que ficam acima de resource groups.', 10, 6),
  ('30000000-0000-4000-8000-000000000002', 'azure-resource-hierarchy', 'Azure Resource Hierarchy', 'Visualize a relação entre escopos de gerenciamento do Azure.', 'A hierarquia parte de management groups, passa por subscriptions e resource groups e chega aos recursos.', 'Uma policy aplicada no management group pode alcançar as subscriptions e recursos abaixo dele.', 'Configurações podem ser herdadas de escopos superiores para inferiores.', 10, 7),

  ('32000000-0000-4000-8000-000000000002', 'comparing-compute-options', 'Comparing Compute Options', 'Compare máquinas virtuais, contêineres e funções.', 'VMs oferecem controle do sistema; contêineres empacotam aplicações; funções executam código orientado a eventos.', 'Um backend legado pode usar VM, uma API portátil pode usar contêiner e uma rotina curta pode usar Function.', 'Escolha pela necessidade de controle, portabilidade, duração e padrão de execução.', 10, 1),
  ('32000000-0000-4000-8000-000000000002', 'azure-virtual-machines', 'Azure Virtual Machines', 'Execute sistemas completos em servidores virtuais.', 'VMs fornecem CPU, memória, disco e rede com controle do sistema operacional.', 'Uma aplicação ASP.NET Core que depende de software específico pode ser instalada em uma VM Windows ou Linux.', 'Você administra sistema operacional, patches e software dentro da VM.', 12, 2),
  ('32000000-0000-4000-8000-000000000002', 'vm-scale-sets-and-availability-sets', 'VM Scale Sets and Availability Sets', 'Diferencie escala automática de distribuição contra falhas.', 'Scale Sets gerenciam várias VMs semelhantes e podem escalar; Availability Sets distribuem VMs contra falhas de hardware e manutenção.', 'Uma API com muitas instâncias usa Scale Set para crescer conforme o tráfego.', 'Scale Set trata escala; Availability Set trata distribuição de VMs em domínios de falha e atualização.', 10, 3),
  ('32000000-0000-4000-8000-000000000002', 'azure-virtual-desktop', 'Azure Virtual Desktop', 'Entregue desktops e aplicativos Windows remotamente.', 'Azure Virtual Desktop virtualiza a experiência de desktop para usuários acessarem de diferentes dispositivos.', 'Uma equipe remota acessa ferramentas corporativas em um ambiente Windows controlado.', 'AVD é voltado à experiência de desktop e aplicações para usuários, não à hospedagem comum de APIs.', 8, 4),
  ('32000000-0000-4000-8000-000000000002', 'virtual-machine-resources', 'Resources Required for Virtual Machines', 'Reconheça componentes necessários ao funcionamento de uma VM.', 'VMs normalmente dependem de discos, interface de rede, rede virtual e endereço IP, além do tamanho de computação.', 'Ao criar uma VM para um backend, você também configura disco do sistema e conectividade de rede.', 'A VM não é isolada: armazenamento e rede são recursos associados.', 10, 5),
  ('32000000-0000-4000-8000-000000000002', 'azure-app-service', 'Azure App Service', 'Hospede aplicações web e APIs em uma plataforma gerenciada.', 'App Service gerencia infraestrutura, sistema operacional e runtime para aplicações web.', 'Uma API ASP.NET Core pode ser publicada diretamente e escalar sem administrar uma VM.', 'App Service é PaaS e reduz tarefas de manutenção do servidor.', 10, 6),
  ('32000000-0000-4000-8000-000000000002', 'azure-functions', 'Azure Functions', 'Execute pequenos trechos de código orientados a eventos.', 'Functions é uma opção serverless que reage a gatilhos como HTTP, filas ou temporizadores.', 'Uma função envia uma notificação quando um pedido entra em uma fila.', 'Functions combina execução por evento, escala automática e cobrança baseada em uso conforme o plano.', 10, 7),
  ('32000000-0000-4000-8000-000000000002', 'containers-on-azure', 'Containers on Azure', 'Empacote aplicação e dependências de forma portátil.', 'Contêineres compartilham o kernel do host e iniciam mais rapidamente que VMs completas.', 'Frontend, API e worker podem ser empacotados separadamente e implantados de modo consistente.', 'Contêiner não é uma VM pequena; ele isola processos e depende do sistema do host.', 10, 8),
  ('32000000-0000-4000-8000-000000000002', 'choosing-application-hosting', 'Choosing Application Hosting', 'Selecione VM, App Service, contêiner ou Function para cada carga.', 'A escolha considera controle, dependências, padrão de tráfego e esforço operacional desejado.', 'Um sistema legado usa VM, a API web usa App Service e um processamento assíncrono usa Function.', 'Maior controle geralmente significa maior responsabilidade de gerenciamento.', 12, 9),

  ('32000000-0000-4000-8000-000000000003', 'virtual-networks-and-subnets', 'Virtual Networks and Subnets', 'Isole e organize recursos em redes privadas do Azure.', 'Uma VNet define um espaço de endereços; subnets dividem esse espaço para separar grupos de recursos.', 'A API fica em uma subnet e o banco em outra com regras de acesso mais restritas.', 'VNet é a rede; subnet é uma divisão interna dela.', 12, 1),
  ('32000000-0000-4000-8000-000000000003', 'vnet-peering', 'VNet Peering', 'Conecte redes virtuais diretamente pela rede da Microsoft.', 'Peering permite comunicação privada entre VNets sem exigir um gateway público.', 'As VNets de frontend e backend podem trocar tráfego privado mesmo administradas separadamente.', 'Peering conecta VNets, mas não as transforma em uma única rede.', 8, 2),
  ('32000000-0000-4000-8000-000000000003', 'azure-dns', 'Azure DNS', 'Hospede e resolva nomes de domínio usando o Azure.', 'DNS traduz nomes legíveis em endereços utilizados na comunicação de rede.', 'O domínio api.exemplo.com pode apontar para o endpoint público do backend.', 'Azure DNS hospeda zonas DNS; ele não registra o domínio por você.', 8, 3),
  ('32000000-0000-4000-8000-000000000003', 'vpn-gateway-vs-expressroute', 'VPN Gateway vs ExpressRoute', 'Compare conectividade criptografada pela internet e conexão privada dedicada.', 'VPN Gateway cria túneis pela internet; ExpressRoute oferece conexão privada por um provedor de conectividade.', 'Uma filial pequena usa VPN, enquanto uma empresa com tráfego previsível e alto volume escolhe ExpressRoute.', 'VPN usa internet pública protegida; ExpressRoute não percorre a internet pública.', 10, 4),
  ('32000000-0000-4000-8000-000000000003', 'public-vs-private-endpoints', 'Public vs Private Endpoints', 'Diferencie acesso pela internet e acesso privado por uma VNet.', 'Endpoint público pode ser alcançado externamente; private endpoint atribui acesso ao serviço por endereço privado.', 'Um Azure SQL Database usado apenas pelo backend pode expor um private endpoint na VNet.', 'Private endpoint reduz exposição pública e mantém tráfego na rede privada.', 10, 5),

  ('32000000-0000-4000-8000-000000000004', 'storage-accounts-and-services', 'Storage Accounts and Services', 'Conheça o contêiner que reúne serviços de armazenamento do Azure.', 'Uma storage account fornece namespace e configurações para blobs, files, queues e tables.', 'Uma aplicação guarda imagens em Blob Storage e mensagens em Queue Storage dentro de contas adequadas.', 'Escolha tipo de conta, desempenho, redundância e acesso conforme a carga.', 10, 1),
  ('32000000-0000-4000-8000-000000000004', 'blob-storage', 'Blob Storage', 'Armazene grandes quantidades de dados não estruturados.', 'Blob Storage é adequado para imagens, documentos, backups e outros objetos.', 'Um frontend React envia arquivos que a API grava em um container de blobs.', 'Blob é armazenamento de objetos, não um disco tradicional nem banco relacional.', 8, 2),
  ('32000000-0000-4000-8000-000000000004', 'azure-files', 'Azure Files', 'Use compartilhamentos de arquivos gerenciados na nuvem.', 'Azure Files oferece compartilhamentos acessíveis por protocolos comuns como SMB e NFS.', 'Servidores diferentes podem acessar o mesmo compartilhamento de documentos da aplicação.', 'Azure Files é compartilhamento gerenciado; Blob Storage é armazenamento de objetos.', 8, 3),
  ('32000000-0000-4000-8000-000000000004', 'managed-disks', 'Managed Disks', 'Forneça armazenamento persistente para máquinas virtuais.', 'Managed Disks abstrai a administração das contas de armazenamento usadas pelos discos de VM.', 'O sistema operacional e os dados de uma VM permanecem em discos gerenciados.', 'Discos são ligados a VMs; não substituem serviços de objetos ou compartilhamentos.', 8, 4),
  ('32000000-0000-4000-8000-000000000004', 'storage-tiers', 'Storage Tiers', 'Equilibre frequência de acesso e custo dos dados.', 'Camadas hot, cool, cold e archive oferecem custos diferentes de armazenamento e acesso.', 'Logs recentes ficam em hot e arquivos raramente consultados podem ir para archive.', 'Quanto menor a frequência de acesso, menor tende a ser o armazenamento e maior pode ser o custo ou tempo de recuperação.', 10, 5),
  ('32000000-0000-4000-8000-000000000004', 'storage-redundancy-options', 'LRS, ZRS, GRS and GZRS', 'Compare cópias locais, entre zonas e entre regiões.', 'LRS replica localmente, ZRS entre zonas, GRS entre regiões e GZRS combina zonas na primária com replicação geográfica.', 'Dados críticos de uma aplicação podem usar redundância geográfica para suportar desastre regional.', 'Mais alcance de redundância aumenta resiliência e normalmente também o custo.', 12, 6),
  ('32000000-0000-4000-8000-000000000004', 'moving-files-to-azure', 'Moving Files with AzCopy, Storage Explorer and File Sync', 'Escolha ferramentas para copiar e sincronizar arquivos.', 'AzCopy automatiza transferências, Storage Explorer oferece interface gráfica e File Sync mantém servidores sincronizados com Azure Files.', 'Uma equipe usa AzCopy em um script para enviar backups e Storage Explorer para inspeção manual.', 'Associe linha de comando a AzCopy, interface gráfica a Storage Explorer e sincronização híbrida a File Sync.', 12, 7),
  ('32000000-0000-4000-8000-000000000004', 'azure-migrate-and-data-box', 'Azure Migrate and Azure Data Box', 'Compare avaliação de migração e transferência física de grandes volumes.', 'Azure Migrate ajuda a descobrir e planejar migrações; Data Box transporta dados em um dispositivo físico.', 'Uma empresa avalia servidores com Azure Migrate e envia petabytes sem depender da internet usando Data Box.', 'Migrate planeja e acompanha cargas; Data Box resolve transferência de dados em grande escala.', 10, 8),

  ('32000000-0000-4000-8000-000000000005', 'entra-id-and-domain-services', 'Microsoft Entra ID and Domain Services', 'Diferencie identidade em nuvem e serviços de domínio gerenciados.', 'Entra ID gerencia identidades e acesso; Domain Services oferece recursos compatíveis com domínio tradicional sem administrar controladores.', 'Usuários entram em uma aplicação web com Entra ID, enquanto uma aplicação legada usa recursos de domínio gerenciado.', 'Entra ID não é o mesmo que Active Directory Domain Services tradicional.', 12, 1),
  ('32000000-0000-4000-8000-000000000005', 'authentication-vs-authorization', 'Authentication vs Authorization', 'Separe comprovação de identidade e permissão de acesso.', 'Autenticação confirma quem você é; autorização determina o que você pode fazer.', 'O usuário entra na API com sua identidade e depois uma função decide se pode excluir registros.', 'Primeiro autenticar, depois autorizar.', 8, 2),
  ('32000000-0000-4000-8000-000000000005', 'single-sign-on', 'Single Sign-On', 'Acesse várias aplicações com uma única autenticação.', 'SSO reduz solicitações de senha ao reutilizar uma identidade confiável entre aplicações.', 'O colaborador entra uma vez e acessa portal, dashboard React e ferramentas corporativas.', 'SSO melhora experiência e centraliza controle de acesso.', 8, 3),
  ('32000000-0000-4000-8000-000000000005', 'mfa-and-passwordless', 'Multi-Factor Authentication and Passwordless', 'Fortaleça autenticação com fatores adicionais ou métodos sem senha.', 'MFA combina categorias de evidência; passwordless usa métodos como biometria ou chaves de segurança.', 'Além da senha, um administrador confirma o login em um aplicativo autenticador.', 'MFA exige mais de um fator; duas senhas continuam sendo o mesmo tipo de fator.', 10, 4),
  ('32000000-0000-4000-8000-000000000005', 'external-identities', 'External Identities', 'Permita colaboração segura com pessoas de fora da organização.', 'Identidades externas concedem acesso controlado a parceiros e clientes sem criar toda a identidade internamente.', 'Um fornecedor recebe acesso somente ao dashboard necessário para seu projeto.', 'Acesso externo deve seguir menor privilégio e ser revisado.', 8, 5),
  ('32000000-0000-4000-8000-000000000005', 'conditional-access', 'Conditional Access', 'Aplique decisões de acesso com base em sinais e condições.', 'Conditional Access pode considerar usuário, localização, dispositivo, risco e aplicação antes de permitir acesso.', 'Um login administrativo fora do país exige MFA ou é bloqueado.', 'Conditional Access funciona como mecanismo if-then para políticas de acesso.', 10, 6),
  ('32000000-0000-4000-8000-000000000005', 'azure-rbac', 'Azure Role-Based Access Control (RBAC)', 'Conceda ações específicas em escopos definidos.', 'RBAC associa uma identidade a uma função em um escopo como subscription, resource group ou recurso.', 'Um desenvolvedor pode ler logs de uma API sem receber permissão para excluir o resource group.', 'RBAC responde quem pode fazer o quê em qual escopo.', 12, 7),
  ('32000000-0000-4000-8000-000000000005', 'zero-trust-and-defense-in-depth', 'Zero Trust and Defense in Depth', 'Combine verificação contínua com várias camadas de proteção.', 'Zero Trust assume violação e verifica explicitamente; defesa em profundidade usa camadas físicas, de identidade, perímetro, rede, computação, aplicação e dados.', 'Mesmo autenticado, um usuário recebe apenas o acesso mínimo e a API mantém controles adicionais.', 'Zero Trust é uma abordagem; defesa em profundidade organiza camadas de proteção.', 12, 8),
  ('32000000-0000-4000-8000-000000000005', 'defender-for-cloud', 'Microsoft Defender for Cloud', 'Melhore postura de segurança e proteção de cargas.', 'Defender for Cloud avalia configurações, fornece recomendações e ajuda a proteger recursos contra ameaças.', 'O serviço alerta que uma VM da aplicação possui uma porta desnecessariamente exposta.', 'Defender for Cloud combina gerenciamento de postura e proteção de cargas.', 10, 9),

  ('33000000-0000-4000-8000-000000000001', 'azure-cost-factors', 'Factors That Affect Azure Costs', 'Reconheça variáveis que alteram o preço dos recursos.', 'Região, tipo de recurso, tamanho, tempo de uso, tráfego e modelo de compra influenciam o custo.', 'A mesma API pode custar diferente ao mudar o tamanho da VM ou transferir muitos dados entre regiões.', 'Preço depende da configuração e do consumo, não apenas do nome do serviço.', 10, 1),
  ('33000000-0000-4000-8000-000000000001', 'pricing-calculator', 'Azure Pricing Calculator', 'Estime o custo de uma solução antes de implantá-la.', 'A calculadora de preços combina serviços, regiões, tamanhos e consumo esperado em uma estimativa.', 'A equipe simula App Service, Azure SQL e armazenamento para prever o custo do backend.', 'A calculadora gera estimativas; o custo real depende do uso e da configuração final.', 8, 2),
  ('33000000-0000-4000-8000-000000000001', 'azure-cost-management', 'Azure Cost Management', 'Acompanhe, analise e controle gastos já realizados ou previstos.', 'Cost Management oferece análise, budgets e alertas para entender tendências e evitar surpresas.', 'Um budget avisa quando o ambiente de desenvolvimento se aproxima do limite mensal.', 'Budget e alerta informam; não desligam recursos automaticamente por padrão.', 10, 3),
  ('33000000-0000-4000-8000-000000000001', 'resource-tags', 'Resource Tags', 'Adicione metadados para organização e relatórios.', 'Tags são pares chave-valor usados para classificar recursos por projeto, ambiente ou centro de custo.', 'API e banco recebem a tag Environment=Production para facilitar filtros e relatórios.', 'Tags ajudam organização e custos, mas não substituem RBAC nem resource groups.', 8, 4),

  ('33000000-0000-4000-8000-000000000002', 'microsoft-purview', 'Microsoft Purview', 'Descubra, classifique e governe dados em diferentes ambientes.', 'Purview oferece recursos de governança de dados, catálogo e compreensão da origem e uso das informações.', 'A organização identifica quais bancos possuem dados pessoais usados por suas APIs.', 'Purview está ligado à governança de dados, não ao bloqueio de criação de recursos.', 10, 1),
  ('33000000-0000-4000-8000-000000000002', 'azure-policy', 'Azure Policy', 'Avalie e imponha padrões sobre configurações de recursos.', 'Azure Policy compara recursos com regras e pode auditar, negar ou corrigir configurações.', 'Uma policy impede criar armazenamento sem criptografia ou fora de regiões permitidas.', 'Policy controla conformidade de recursos; RBAC controla ações de identidades.', 10, 2),
  ('33000000-0000-4000-8000-000000000002', 'resource-locks', 'Resource Locks', 'Proteja recursos contra exclusão ou alteração acidental.', 'Locks podem impedir exclusão ou tornar um recurso somente leitura, mesmo para usuários com permissões de gerenciamento.', 'Um lock CanNotDelete protege o banco de produção contra remoção acidental.', 'Locks são herdados por recursos filhos e não substituem controle de acesso.', 8, 3),

  ('33000000-0000-4000-8000-000000000003', 'azure-portal', 'Azure Portal', 'Administre recursos por uma interface web gráfica.', 'O portal reúne criação, configuração, monitoramento e suporte em uma experiência visual.', 'Um iniciante cria um App Service e acompanha métricas sem usar linha de comando.', 'Portal é interface gráfica; as mesmas operações podem ser automatizadas por outras ferramentas.', 8, 1),
  ('33000000-0000-4000-8000-000000000003', 'azure-cloud-shell', 'Azure Cloud Shell', 'Use uma linha de comando pronta no navegador.', 'Cloud Shell oferece ambiente autenticado com Azure CLI ou Azure PowerShell sem instalação local.', 'Um desenvolvedor abre o portal e executa um comando para listar resource groups.', 'Cloud Shell é o ambiente; CLI e PowerShell são ferramentas disponíveis nele.', 8, 2),
  ('33000000-0000-4000-8000-000000000003', 'azure-cli', 'Azure CLI', 'Automatize o Azure com comandos multiplataforma.', 'Azure CLI usa comandos az e funciona bem em scripts e terminais de diferentes sistemas.', 'Um pipeline executa az webapp deploy para publicar uma API.', 'CLI é orientada a comandos az e retorna resultados úteis para automação.', 8, 3),
  ('33000000-0000-4000-8000-000000000003', 'azure-powershell', 'Azure PowerShell', 'Administre recursos com cmdlets do PowerShell.', 'Azure PowerShell usa módulos e objetos do PowerShell para criar e consultar recursos.', 'Uma equipe Windows usa Get-AzResource para processar objetos em um script.', 'PowerShell usa cmdlets Az; Azure CLI usa comandos az.', 8, 4),
  ('33000000-0000-4000-8000-000000000003', 'azure-arc', 'Azure Arc', 'Estenda gerenciamento do Azure a recursos fora do Azure.', 'Azure Arc conecta servidores, clusters e serviços de dados de outros ambientes ao plano de gerenciamento do Azure.', 'Um servidor local aparece no Azure para receber inventário e políticas centralizadas.', 'Arc amplia gerenciamento e governança; não move automaticamente o recurso para o Azure.', 10, 5),
  ('33000000-0000-4000-8000-000000000003', 'infrastructure-as-code', 'Infrastructure as Code', 'Defina infraestrutura em arquivos versionáveis e repetíveis.', 'IaC descreve o estado desejado dos recursos e reduz diferenças entre ambientes criados manualmente.', 'Desenvolvimento e produção da API são criados a partir do mesmo template com parâmetros diferentes.', 'IaC melhora consistência, revisão, automação e repetibilidade.', 10, 6),
  ('33000000-0000-4000-8000-000000000003', 'azure-resource-manager-and-arm-templates', 'Azure Resource Manager and ARM Templates', 'Entenda o plano de gerenciamento e os templates declarativos do Azure.', 'ARM recebe solicitações de gerenciamento e organiza recursos; ARM templates descrevem recursos em JSON de forma declarativa.', 'Um template cria App Service, banco e monitoramento em uma única implantação consistente.', 'ARM é o serviço de gerenciamento; ARM template é uma forma de declarar a infraestrutura.', 12, 7),

  ('33000000-0000-4000-8000-000000000004', 'azure-advisor', 'Azure Advisor', 'Receba recomendações personalizadas para melhorar recursos.', 'Advisor analisa configurações e sugere melhorias em custo, desempenho, confiabilidade, segurança e excelência operacional.', 'O serviço recomenda redimensionar uma VM pouco utilizada para reduzir gastos.', 'Advisor recomenda; a equipe decide e aplica a mudança.', 8, 1),
  ('33000000-0000-4000-8000-000000000004', 'azure-service-health', 'Azure Service Health', 'Acompanhe incidentes e manutenções que afetam seus serviços.', 'Service Health mostra problemas do Azure relevantes para suas regiões e recursos, além de avisos de manutenção.', 'A equipe recebe um alerta sobre uma indisponibilidade regional que afeta a API.', 'Service Health é personalizado para seus serviços; Azure Status oferece visão pública ampla.', 8, 2),
  ('33000000-0000-4000-8000-000000000004', 'azure-monitor', 'Azure Monitor', 'Centralize métricas, logs, alertas e telemetria.', 'Azure Monitor coleta e analisa sinais de aplicações e infraestrutura para apoiar operação e diagnóstico.', 'CPU da VM, erros da API e disponibilidade podem ser acompanhados em uma solução de monitoramento.', 'Azure Monitor é a plataforma ampla que inclui recursos como Log Analytics e Application Insights.', 10, 3),
  ('33000000-0000-4000-8000-000000000004', 'log-analytics', 'Log Analytics', 'Consulte logs centralizados com linguagem de consulta.', 'Log Analytics usa workspaces e consultas KQL para explorar registros coletados pelo Azure Monitor.', 'A equipe consulta erros das últimas duas horas em vários backends.', 'Log Analytics é voltado à análise de logs; métricas são séries numéricas ao longo do tempo.', 10, 4),
  ('33000000-0000-4000-8000-000000000004', 'azure-monitor-alerts', 'Azure Monitor Alerts', 'Notifique ou acione automações quando uma condição ocorrer.', 'Alertas avaliam métricas ou logs e usam action groups para enviar notificações ou chamar ações.', 'Um alerta avisa a equipe quando a taxa de erros da API ultrapassa o limite.', 'Regra define a condição; action group define quem ou o que será acionado.', 8, 5),
  ('33000000-0000-4000-8000-000000000004', 'application-insights', 'Application Insights', 'Observe desempenho e comportamento de aplicações.', 'Application Insights coleta telemetria como requisições, dependências, exceções e tempos de resposta.', 'Uma API ASP.NET Core mostra qual chamada ao SQL Database está causando lentidão.', 'Application Insights é monitoramento de aplicações dentro do ecossistema Azure Monitor.', 10, 6);

insert into public.lessons (
  topic_id,
  slug,
  title,
  short_description,
  content,
  estimated_minutes,
  display_order,
  is_published
)
select
  topic_id,
  slug,
  title,
  short_description,
  format(
    E'# %s\n\n## O que você precisa entender\n%s\n\n## Explicação simples\n%s\n\n## Exemplo\n%s\n\n## O que lembrar para a prova\n%s',
    title,
    short_description,
    explanation,
    example,
    exam_tip
  ),
  estimated_minutes,
  display_order,
  true
from az900_lesson_seed
order by topic_id, display_order
on conflict (topic_id, slug) do update set
  title = excluded.title,
  short_description = excluded.short_description,
  content = excluded.content,
  estimated_minutes = excluded.estimated_minutes,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

commit;

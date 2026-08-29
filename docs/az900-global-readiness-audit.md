# AZ-900 Global Readiness Audit

Auditoria executada em 29 de agosto de 2026 sobre a certificação `AZ-900 — Microsoft Azure Fundamentals`, sem criação ou correção de conteúdo curricular.

## Curriculum Version

Fonte de verdade: [Study guide for Exam AZ-900](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-900).

Skills measured from: `July 20, 2026`.

| Domain oficial | Peso |
| --- | ---: |
| Describe cloud concepts | 25–30% |
| Describe Azure architecture and services | 35–40% |
| Describe Azure management and governance | 30–35% |

O guia contém 57 bullets oficiais: 15 no Domain 1, 27 no Domain 2 e 15 no Domain 3. As matrizes históricas do projeto dividem alguns bullets compostos em subconceitos atômicos; esta auditoria normaliza o status pelo texto oficial sem descartar o detalhamento pedagógico existente.

## Global Inventory

| Domain | Topics | Lessons | Blocks | Visuals | Flashcards | Questions | Easy / Medium / Hard | Minutes | Covered | Partial | Missing |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: |
| Domain 1 — Describe cloud concepts | 3 | 18 | 129 | 4 | 84 | 153 | 48 / 77 / 28 | 184 | 15 | 0 | 0 |
| Domain 2 — Describe Azure architecture and services | 5 | 38 | 357 | 11 | 183 | 219 | 81 / 94 / 44 | 410 | 27 | 0 | 0 |
| Domain 3 — Describe Azure management and governance | 4 | 20 | 226 | 2 | 130 | 140 | 49 / 63 / 28 | 224 | 15 | 0 | 0 |
| **AZ-900** | **12** | **76** | **712** | **17** | **397** | **512** | **178 / 234 / 100** | **818** | **57** | **0** | **0** |

O banco remoto é a autoridade para os totais. A Etapa 10.2 restaurou os 35 blocks ausentes identificados pela auditoria, sem alterar o total de Lessons, Visual Experiences, Flashcards, Questions ou minutos.

## Topic Inventory

| Domain | Topic | Lessons | Blocks | Visuals | Flashcards | Questions | Avg cards/Lesson | Minutes |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | Cloud Computing | 7 | 48 | 3 | 37 | 72 | 5.29 | 72 |
| 1 | Benefits of Cloud Services | 7 | 51 | 0 | 28 | 61 | 4.00 | 72 |
| 1 | Cloud Service Types | 4 | 30 | 1 | 19 | 20 | 4.75 | 40 |
| 2 | Core Architectural Components | 7 | 55 | 2 | 37 | 42 | 5.29 | 70 |
| 2 | Azure Compute Services | 9 | 73 | 2 | 34 | 51 | 3.78 | 96 |
| 2 | Azure Networking Services | 5 | 48 | 3 | 23 | 30 | 4.60 | 56 |
| 2 | Azure Storage Services | 8 | 76 | 1 | 40 | 46 | 5.00 | 88 |
| 2 | Azure Identity, Access and Security | 9 | 105 | 3 | 49 | 50 | 5.44 | 100 |
| 3 | Azure Cost Management | 4 | 50 | 0 | 26 | 30 | 6.50 | 44 |
| 3 | Governance and Compliance | 3 | 37 | 0 | 20 | 15 | 6.67 | 34 |
| 3 | Resource Management and Deployment | 7 | 79 | 1 | 45 | 55 | 6.43 | 78 |
| 3 | Monitoring | 6 | 60 | 1 | 39 | 40 | 6.50 | 68 |

## Official Objective Coverage Matrix

Esta é a visão normalizada pelos 57 bullets do guia oficial atual. Os slugs indicam a evidência curricular principal; Flashcards e Questions associados foram validados em todos os casos.

### Domain 1 — Describe cloud concepts

| Official objective | Primary Lesson evidence | Status | Notes |
| --- | --- | --- | --- |
| Define cloud computing | `what-is-cloud-computing` | Covered | Blocks, exemplo, prática e summary. |
| Describe the shared responsibility model | `shared-responsibility-model` | Covered | Blocks e visual On-Prem/IaaS/PaaS/SaaS. |
| Define cloud models, including public, private, and hybrid | `public-private-hybrid-cloud` | Covered | Comparação e visual. |
| Identify appropriate use cases for each cloud model | `choosing-a-cloud-model` | Covered | Cenários e exam traps. |
| Describe the consumption-based model | `consumption-based-model` | Covered | Consumo, flexibilidade e custo conforme uso. |
| Compare cloud pricing models | `consumption-based-model`, `capex-vs-opex` | Covered | Comparação explícita, prática e distinção entre pricing e natureza do gasto. |
| Describe serverless | `serverless-computing` | Covered | Abstração, eventos e trap “serverless ≠ sem servidores”. |
| Describe the benefits of high availability and scalability in the cloud | `high-availability`, `scalability` | Covered | Sete blocks e um summary por Lesson, comparações explícitas e prática preservada. |
| Describe the benefits of reliability and predictability in the cloud | `reliability`, `predictability` | Covered | Sete blocks e um summary por Lesson, diferenciação conceitual e prática preservada. |
| Describe the benefits of security and governance in the cloud | `security-and-governance-benefits` | Covered | Blocks, comparação, prática e summary. |
| Describe the benefits of manageability in the cloud | `manageability` | Covered | Blocks, ferramentas conceituais, prática e summary. |
| Describe infrastructure as a service (IaaS) | `infrastructure-as-a-service` | Covered | Responsabilidade, VM, prática e summary. |
| Describe platform as a service (PaaS) | `platform-as-a-service` | Covered | App Service/.NET, prática e summary. |
| Describe software as a service (SaaS) | `software-as-a-service` | Covered | Serviço pronto, responsabilidade residual, prática e summary. |
| Identify appropriate use cases for each cloud service type | `choosing-iaas-paas-saas` | Covered | Cenários, comparação visual e prática. |

### Domain 2 — Describe Azure architecture and services

| Official objective | Primary Lesson evidence | Status | Notes |
| --- | --- | --- | --- |
| Describe Azure regions, region pairs, and sovereign regions | `azure-regions`, `region-pairs-and-sovereign-regions` | Covered | Conceitos separados, cenários e traps. |
| Describe availability zones | `availability-zones` | Covered | Blocks e visual de isolamento físico. |
| Describe Azure datacenters | `azure-datacenters` | Covered | Infraestrutura física e relação com Regions. |
| Describe Azure resources and resource groups | `resources-and-resource-groups` | Covered | Organização, ciclo de vida e limites conceituais. |
| Describe subscriptions | `subscriptions-and-management-groups` | Covered | Billing/access/management e limites. |
| Describe management groups | `subscriptions-and-management-groups` | Covered | Organização e governança acima de subscriptions. |
| Describe the hierarchy of resource groups, subscriptions, and management groups | `azure-resource-hierarchy` | Covered | Blocks e visual da hierarquia completa. |
| Compare compute types, including containers, virtual machines, and functions | `comparing-compute-options` | Covered | Matriz, cenários e prática. |
| Describe virtual machine options, including VMs, VM Scale Sets, availability sets, and Azure Virtual Desktop | `azure-virtual-machines`, `vm-scale-sets-and-availability-sets`, `azure-virtual-desktop` | Covered | Cobertura distribuída e prática por opção. |
| Describe the resources required for virtual machines | `virtual-machine-resources` | Covered | Compute, disks, NIC/VNet e visual. |
| Describe application hosting options, including web apps, containers, and virtual machines | `choosing-application-hosting`, `azure-app-service`, `containers-on-azure` | Covered | Comparação por controle, operação e portabilidade. |
| Describe virtual networking, including VNets, subnets, peering, Azure DNS, VPN Gateway, and ExpressRoute | `virtual-networks-and-subnets`, `vnet-peering`, `azure-dns`, `vpn-gateway-vs-expressroute` | Covered | Todos os componentes do bullet têm blocks e prática. |
| Define public and private endpoints | `public-vs-private-endpoints` | Covered | Comparação, visual e cenários. |
| Compare Azure Storage services | `storage-accounts-and-services`, `blob-storage`, `azure-files`, `managed-disks` | Covered | Comparação entre serviços e casos de uso. |
| Describe storage tiers | `storage-tiers` | Covered | Hot/Cool/Cold/Archive e trade-offs. |
| Describe redundancy options | `storage-redundancy-options` | Covered | LRS/ZRS/GRS/GZRS, visual e prática. |
| Describe storage account options and storage types | `storage-accounts-and-services` | Covered | Account/namespace, GPv2 e tipos fundamentais. |
| Identify options for moving files, including AzCopy, Storage Explorer, and File Sync | `moving-files-to-azure` | Covered | Três opções comparadas por cenário. |
| Describe migration options, including Azure Migrate and Azure Data Box | `azure-migrate-and-data-box` | Covered | Workloads versus transferência física. |
| Describe directory services, including Entra ID and Entra Domain Services | `entra-id-and-domain-services` | Covered | Comparação, visual e cenário legado. |
| Describe authentication methods, including SSO, MFA, and passwordless | `single-sign-on`, `mfa-and-passwordless` | Covered | Métodos separados, comparados e praticados. |
| Describe external identities in Azure | `external-identities` | Covered | B2B, tenants e acesso limitado. |
| Describe Microsoft Entra Conditional Access | `conditional-access` | Covered | Sinais, decisões e controles. |
| Describe Azure role-based access control (RBAC) | `azure-rbac` | Covered | Principal, role, scope, herança e visual. |
| Describe the concept of Zero Trust | `zero-trust-and-defense-in-depth` | Covered | Princípios e cenários. |
| Describe the purpose of the defense-in-depth model | `zero-trust-and-defense-in-depth` | Covered | Camadas, visual e distinção de Zero Trust. |
| Describe the purpose of Microsoft Defender for Cloud | `defender-for-cloud` | Covered | Posture, recomendações e workload protection em nível Fundamentals. |

### Domain 3 — Describe Azure management and governance

| Official objective | Primary Lesson evidence | Status | Notes |
| --- | --- | --- | --- |
| Describe factors that can affect costs in Azure | `azure-cost-factors` | Covered | Fatores, cenários e prática. |
| Explore the pricing calculator | `pricing-calculator` | Covered | Estimativa pré-implantação e limitações. |
| Describe cost management capabilities in Azure | `azure-cost-management` | Covered | Análise, budgets, alerts e forecasts em nível Fundamentals. |
| Describe the purpose of tags | `resource-tags` | Covered | Metadados, organização/custos e limites. |
| Describe the purpose of Microsoft Purview in Azure | `microsoft-purview` | Covered | Governança de dados em profundidade adequada. |
| Describe the purpose of Azure Policy | `azure-policy` | Covered | Avaliação/efeitos e distinções de RBAC/locks. |
| Describe the purpose of resource locks | `resource-locks` | Covered | Delete/ReadOnly e limites. |
| Describe the Azure portal | `azure-portal` | Covered | GUI e cenários. |
| Describe Azure Cloud Shell, Azure CLI, and Azure PowerShell | `azure-cloud-shell`, `azure-cli`, `azure-powershell` | Covered | Ambiente versus famílias de ferramentas. |
| Describe the purpose of Azure Arc | `azure-arc` | Covered | Gestão fora de Azure versus migração. |
| Describe infrastructure as code (IaC) | `infrastructure-as-code` | Covered | Declaração, repetibilidade e idempotência conceitual. |
| Describe Azure Resource Manager (ARM) and ARM templates | `azure-resource-manager-and-arm-templates` | Covered | Camada de gestão, templates e visual. |
| Describe the purpose of Azure Advisor | `azure-advisor` | Covered | Recomendações e categorias. |
| Describe Azure Service Health | `azure-service-health` | Covered | Service Health, Resource Health e Health advisories. |
| Describe Azure Monitor, including Log Analytics, alerts, and Application Insights | `azure-monitor`, `log-analytics`, `azure-monitor-alerts`, `application-insights` | Covered | Pipeline de telemetria, visual e prática por componente. |

## Domain 1

- Status: **CLOSED**.
- Lessons: 18.
- Blocks: 129.
- Visuals: 4.
- Flashcards: 84.
- Questions: 153.
- Minutes: 184.
- Official objectives: 15 Covered / 0 Partial / 0 Missing.

As cinco Lessons que estavam sem `lesson_content_blocks` foram restauradas aditivamente na Etapa 10.2:

| Lesson | Blocks | Flashcards | Questions | Impacto oficial |
| --- | ---: | ---: | ---: | --- |
| `high-availability` | 7 | 4 | 10 | Disponibilidade, redundância, comparação, tip/trap e summary |
| `scalability` | 7 | 4 | 10 | Scale up/down, scale out/in, comparação, tip/trap e summary |
| `elasticity` | 7 | 4 | 10 | Ajuste dinâmico, cenário, limite de automação e summary |
| `reliability` | 7 | 4 | 10 | Resiliência, recuperação, comparação, tip/trap e summary |
| `predictability` | 7 | 4 | 10 | Performance/cost predictability, conexões, tip/trap e summary |

Os UUIDs, slugs, fallbacks, 20 Flashcards, 50 Questions e tempos foram preservados. Os dois bullets compostos agora possuem evidência estruturada suficiente e passaram a Covered.

## Domain 2

- Status: **CLOSED**.
- Lessons: 38.
- Blocks: 357.
- Visuals: 11.
- Flashcards: 183.
- Questions: 219.
- Minutes: 410.
- Official objectives: 27 Covered / 0 Partial / 0 Missing.

As 38 Lessons possuem blocks, fallback, summary, Flashcards e pelo menos cinco Questions. Core Architecture, Compute/Networking, Storage e Identity/Access/Security permanecem coerentes com o guia de julho de 2026.

## Domain 3

- Status: **CLOSED**.
- Lessons: 20.
- Blocks: 226.
- Visuals: 2.
- Flashcards: 130.
- Questions: 140.
- Minutes: 224.
- Official objectives: 15 Covered / 0 Partial / 0 Missing.

Cost Management, Governance/Compliance, Management/Deployment e Monitoring permanecem completos e passaram novamente pelos fluxos globais.

## Cross-Domain Issues

| Comparação | Resultado |
| --- | --- |
| Region vs Availability Zone | Compatível: Region é área geográfica; Zone é local físico isolado dentro de Region compatível. |
| Resource Group vs Subscription | Compatível: Resource Group organiza recursos; Subscription é limite de billing/access/management e contém Resource Groups. |
| Authentication vs Authorization | Compatível: identidade é verificada antes de permissões determinarem ações. |
| MFA vs Conditional Access | Compatível: MFA é método de autenticação; Conditional Access usa sinais e pode exigir MFA. |
| Conditional Access vs RBAC | Compatível: Conditional Access decide condições de entrada; RBAC autoriza ações em scopes Azure. |
| RBAC vs Azure Policy | Compatível: RBAC controla quem pode agir; Policy avalia/impõe padrões de recursos. |
| Policy vs Resource Locks | Compatível: Policy governa compliance; Locks protegem contra exclusão/alteração administrativa. |
| Tags vs Policy | Compatível: Tags são metadados; Policy pode exigir ou controlar sua aplicação, mas tags não impõem regras sozinhas. |
| Azure Monitor vs Advisor | Compatível: Monitor trabalha com telemetria; Advisor fornece recomendações. |
| Monitor vs Service Health | Compatível: Monitor analisa comportamento; Service Health comunica eventos da plataforma relevantes ao cliente. |
| Resource Health vs Service Health | Compatível: recurso individual versus visão personalizada de incidentes/manutenção/advisories. |
| Pricing Calculator vs Cost Management | Compatível: estimativa pré-implantação versus acompanhamento/controle do gasto real e previsto. |
| Azure Arc vs Azure Migrate | Compatível: gerenciar recursos onde estão versus migrar workloads para Azure. |
| Blob vs Files vs Managed Disks | Compatível: objeto, compartilhamento gerenciado e disco de bloco para VM. |
| LRS vs ZRS vs GRS/GZRS | Compatível: alcance local, zonal e geográfico sem prometer failover ou leitura secundária automáticos. |
| Portal vs Cloud Shell vs CLI vs PowerShell | Compatível: GUI, ambiente de terminal e duas famílias de ferramentas. |
| IaC vs ARM vs ARM Template | Compatível: prática declarativa, camada de gerenciamento e formato declarativo JSON. |

Nenhuma contradição factual foi encontrada entre as versões estruturadas desses conceitos.

## Content Depth Issues

| Occurrence | Classification | Note |
| --- | --- | --- |
| KQL em Log Analytics | OK as context | Apenas nome/finalidade; nenhuma sintaxe exigida. |
| ARM Template JSON e Bicep | OK as context | Exemplos conceituais; sem deployment modes, linked templates ou state. |
| LDAP, Kerberos e NTLM em Entra Domain Services | OK as context | Explicam o cenário legado sem ensinar protocolos internamente. |
| CIDR ilustrativo em VNet | OK as context | Mostra organização; não cria simulador nem exige cálculo. |
| RA-GRS/RA-GZRS | OK as context | Usados apenas para diferenciar leitura da região secundária. |
| Questions hard de Cloud Benefits | Should simplify | Algumas exigem decisão arquitetural/operacional além do verbo oficial “describe”. |
| Exemplo legado `az webapp deploy` em Azure CLI | Should simplify | Correto, mas operacional demais para o objetivo oficial. |
| TCO em fallback de CapEx/OpEx | OK as context | Não é tratado como objetivo independente. |

Não foram encontradas ocorrências autoritativas de OAuth/OIDC detalhado, BGP, route tables avançadas, PIM, custom roles detalhadas, KQL avançado, Terraform state, Defender plans detalhados, Purview avançado ou FinOps avançado. Nenhum item foi classificado `Out of scope`.

## Visual Issues

| UUID | Lesson | Topic | Purpose | Classification | Validation |
| --- | --- | --- | --- | --- | --- |
| `76000000-0000-4000-8000-000000000001` | `choosing-iaas-paas-saas` | Cloud Service Types | Comparar controle, responsabilidade e cenário | Useful | Valid |
| `76000000-0000-4000-8000-000000000002` | `availability-zones` | Core Architectural Components | Region e isolamento entre Zones | Essential | Valid |
| `76000000-0000-4000-8000-000000000003` | `entra-id-and-domain-services` | Identity, Access and Security | Fluxo de autenticação Entra | Useful | Valid |
| `76000000-0000-4000-8000-000000000004` | `shared-responsibility-model` | Cloud Computing | Responsabilidade On-Prem/IaaS/PaaS/SaaS | Essential | Valid |
| `76000000-0000-4000-8000-000000000005` | `public-private-hybrid-cloud` | Cloud Computing | Comparar cloud models | Useful | Valid |
| `76000000-0000-4000-8000-000000000006` | `capex-vs-opex` | Cloud Computing | Comparar natureza do gasto | Useful | Valid |
| `76000000-0000-4000-8000-000000000007` | `azure-resource-hierarchy` | Core Architectural Components | Hierarquia management group → resource | Essential | Valid |
| `76000000-0000-4000-8000-000000000008` | `virtual-machine-resources` | Compute | Relacionar compute, disks e networking | Essential | Valid |
| `76000000-0000-4000-8000-000000000009` | `vm-scale-sets-and-availability-sets` | Compute | Escala versus distribuição contra falhas | Useful | Valid |
| `76000000-0000-4000-8000-000000000010` | `virtual-networks-and-subnets` | Networking | VNet, subnets e recursos | Essential | Valid |
| `76000000-0000-4000-8000-000000000011` | `vpn-gateway-vs-expressroute` | Networking | Comparar conectividade híbrida | Useful | Valid |
| `76000000-0000-4000-8000-000000000012` | `public-vs-private-endpoints` | Networking | Comparar caminho público/privado | Useful | Valid |
| `76000000-0000-4000-8000-000000000013` | `storage-redundancy` | Storage | Alcance das cópias LRS/ZRS/GRS/GZRS | Essential | Valid |
| `76000000-0000-4000-8000-000000000014` | `azure-rbac` | Identity, Access and Security | Principal + role + scope | Essential | Valid |
| `76000000-0000-4000-8000-000000000015` | `zero-trust-and-defense-in-depth` | Identity, Access and Security | Camadas de defense in depth | Essential | Valid |
| `76000000-0000-4000-8000-000000000016` | `azure-resource-manager-and-arm-templates` | Resource Management and Deployment | Ferramentas → ARM → Resource Providers | Useful | Valid |
| `76000000-0000-4000-8000-000000000017` | `azure-monitor` | Monitoring | Telemetria → análise/resposta | Essential | Valid |

Todos estão publicados, têm config JSON válido, Lesson/block correspondentes e renderer com fallback. Os testes automatizados cobrem teclado, conteúdo inválido isolado e renderização responsiva. Não há visual classificado como Unnecessary ou Needs correction. Region Pairs/Sovereign Regions, Storage services e Conditional Access são candidatos visuais possíveis, mas os comparison blocks atuais são suficientes; não constituem lacuna.

## Flashcard Issues

- Total: 397.
- Média global: 5.22 cards por Lesson.
- Domain 1: 84; Domain 2: 183; Domain 3: 130.
- Menor média por Topic: Compute, 3.78 por Lesson.
- Maior média por Topic: Governance and Compliance, 6.67 por Lesson.
- Lessons sem card: 0.
- Duplicatas exatas normalizadas globais: 0.

Há repetição semântica intencional em comparações cross-domain, especialmente Resource Group/scope, RBAC/Policy, Monitor/Advisor e service types/shared responsibility. Ela reforça contextos diferentes e não justifica exclusão automática. Não foi detectado Topic com escassez material de memória ativa. Revisão editorial futura pode encurtar cards importados mais longos, mas não é blocker.

## Question Issues

- Total: 512.
- Easy: 178 (34.8%).
- Medium: 234 (45.7%).
- Hard: 100 (19.5%).
- Média: 6.74 Questions por Lesson.
- Lessons com menos de cinco Questions: 0.
- Duplicatas exatas normalizadas globais: 0.
- Questions com quantidade diferente de quatro options: 0.
- Questions sem exatamente uma opção correta: 0.
- Questions sem explanation: 0.
- Hierarquia Domain/Topic/Lesson inconsistente: 0.

A distribuição bruta do banco é Domain 1 29.9%, Domain 2 42.8% e Domain 3 27.3%. Ela não deve ser usada por amostragem global simples para um Mock; o futuro selecionador precisa estratificar por peso oficial. Há volume suficiente para um mock de 40 itens em 11/15/14 por Domain sem repetição dentro da tentativa.

## Topic Quiz Issues

Todas as 12 seleções atuais têm dez Questions, representam todas as Lessons de seu Topic e usam round-robin por `lesson_id`. Nenhuma Lesson fica fora, pois o maior Topic possui nove Lessons.

| Severity | Issue | Impact |
| --- | --- | --- |
| Medium | Seleção determinística por `display_order` e UUID | Após concluir e refazer um Topic Quiz, o algoritmo volta às mesmas primeiras dez Questions; bancos maiores não rotacionam a prática. |

Não há concentração crítica dentro de uma tentativa: Topics de 3–4 Lessons usam no máximo 3–4 itens por Lesson; Topics de 5–9 Lessons usam no máximo 2.

## Estimated Study Time

| Component | Estimate |
| --- | ---: |
| Lessons (`estimated_minutes`) | 818 min / 13h38 |
| Uma passagem pelos 397 Flashcards (~30 s/card) | ~199 min / 3h19 |
| 76 Lesson Quizzes × 5 itens (~75 s/item) | ~475 min / 7h55 |
| 12 Topic Quizzes × 10 itens (~75 s/item) | ~150 min / 2h30 |
| **Caminho base, sem revisões repetidas** | **~1,642 min / 27h22** |
| Review + spaced repetition inicial | ~3–5 h adicionais |
| **Estimated full AZ-900 study path** | **~30–32 h** |

As Lessons variam entre 10 e 14 minutos; não foi encontrada Lesson simples com 40 minutos nem Lesson complexa com 3 minutos. O total curricular por Domain é 184 / 410 / 224 minutos.

## Legacy Content Issues

- `lessons.content` permanece não vazio nas 76 Lessons e continua sendo fallback.
- Nenhuma Lesson depende exclusivamente do fallback após a restauração dos 35 blocks da Etapa 10.2.
- Em Lessons convertidas, migrations posteriores corrigiram blocks/cards/questions sem atualizar sistematicamente `lessons.content`; não foi detectada contradição factual crítica, mas não existe garantia automática de paridade semântica.
- Os cinco fallbacks de Benefits foram preservados byte a byte e comparados com os novos blocks; nenhuma contradição factual relevante foi encontrada.
- Os exemplos legados de Azure CLI e algumas explicações históricas de Azure Arc são mais operacionais que os blocks atuais.
- O fallback não deve ser removido; a ação futura é reconciliar diferenças in-place.

## Database Integrity

Validação em produção:

- 3 Domains, 12 Topics e 76 Lessons;
- 712 blocks publicados e ordem contínua nas 76 Lessons;
- 17 visuais válidos, vinculados à mesma Lesson do block;
- 397 Flashcards e 512 Questions;
- quatro options distintas, uma correta e explanation em todas as Questions;
- nenhuma duplicata exata normalizada global de Question ou Flashcard;
- nenhuma inconsistência entre `question.domain_id`, `topic_id` e `lesson_id`;
- nenhuma referência órfã em progresso, quizzes ou spaced repetition;
- RLS habilitado nas tabelas auditadas;
- usuário autenticado não possui escrita curricular direta nem acesso direto ao gabarito;
- isolamento entre dois usuários temporários aprovado;
- fixtures removidos por rollback.

## Technical Validation

| Check | Result |
| --- | --- |
| Global SQL inventory/integrity validator | Passed; 10.2 validator confirmed 712 blocks and all 76 Lessons structured |
| Domain 1 Benefits cleanup | Passed: 5 Lessons, 35 blocks, order 1–7, 5 summaries, immutable fallback hashes |
| 76 Lesson Quizzes | Passed, cinco Questions cada |
| 12 Topic Quizzes | Passed, todas as Lessons representadas |
| Review | Passed |
| Lesson completion/progress | Passed |
| Flashcard review/spaced repetition | Passed |
| RLS/user isolation | Passed |
| Orphan references | None |
| Protected route/mobile UI | Passed at 390×844 with no horizontal overflow or console errors; two existing React Router v7 future warnings remain |
| Typecheck | Passed (`tsc --noEmit`) |
| Lint | Passed (zero warnings) |
| Vitest | Passed: 8 files, 79/79 tests |
| Build | Passed: 1,821 modules; non-blocking 656.67 kB bundle warning |
| `git diff --check` | Passed; only the existing Windows LF-to-CRLF advisory was emitted |
| `db:push:dry-run` | Passed: remote database is up to date; no migrations pending |

## Blockers

| Severity | Area | Problem | Required Action |
| --- | --- | --- | --- |
| P2 | Topic Quiz | Retakes usam deterministicamente as mesmas primeiras Questions. | 10.3: adicionar rotação sem perder round-robin, persistência e isolamento. |
| P3 | Legacy fallback | Não há verificação automática global de paridade semântica entre fallback e blocks; alguns fallbacks são mais operacionais. | Revisão editorial futura in-place, sem remover fallback. |
| P3 | Coverage documentation | Matrizes históricas contam subconceitos atômicos, não apenas os 57 bullets oficiais. | Manter detalhe, mas sempre publicar também a visão normalizada oficial. |
| P3 | Future Mock weighting | Banco bruto não segue sozinho os pesos oficiais. | Seleção futura deve estratificar 25–30 / 35–40 / 30–35. |
| P3 | Frontend bundle | Bundle principal supera 500 kB minificado. | Avaliar code splitting em etapa técnica futura, sem bloquear conteúdo. |

P0: 0. P1: 0. P2: 1. P3: 4.

## Etapa 10.2 Delta

- Problema anterior: cinco Lessons de Benefits sem Content Blocks; dois objetivos oficiais Partial.
- Correção: 35 blocks determinísticos adicionados, sete por Lesson, com `display_order` 1–7 e um summary final em cada uma.
- Preservação: Lesson/Topic/Domain UUIDs, slugs, `lessons.content`, 20 Flashcards, 50 Questions, options e histórico não foram alterados.
- Cobertura após a correção: Domain 1 15/0/0; global 57/0/0.
- P1 de conteúdo: **RESOLVED**.
- Estado: curriculum coverage complete; practice blocker remains.

## Final Readiness

**Classification: CONTENT READY**

Motivo: os 57 objetivos oficiais estão Covered e não resta P0/P1. A plataforma ainda não está `READY FOR MOCK DEVELOPMENT`, porque a rotação de retakes do Topic Quiz permanece como blocker P2 para a Etapa 10.3 e a validação final pertence à 10.4.

Status por Domain:

- Domain 1: CLOSED — 15 Covered / 0 Partial / 0 Missing.
- Domain 2: CLOSED — 27 Covered / 0 Partial / 0 Missing.
- Domain 3: CLOSED — 15 Covered / 0 Partial / 0 Missing.

## Recommended Roadmap

### 10.2 — Global Content Cleanup

**Concluída.** Foram restaurados Content Blocks e summaries somente em `high-availability`, `scalability`, `elasticity`, `reliability` e `predictability`, preservando UUIDs, fallback, prática e histórico.

### 10.3 — Global Practice Balancing

Recomendada. Não é necessário aumentar artificialmente o banco. Implementar rotação de Topic Quiz preservando round-robin e validar que retakes usam combinações diferentes. Preparar metadados/consultas para futura seleção por pesos oficiais, sem criar Mock Exam.

### 10.4 — Final Pre-Mock Validation

Reexecutar os 57 objetivos oficiais, integridade global, 76 Lesson Quizzes, 12 Topic Quizzes, Review, spaced repetition, RLS, isolamento, mobile e acessibilidade. Somente declarar `READY FOR MOCK DEVELOPMENT` depois de eliminar o P2 de prática e concluir esta validação.

### 11.x — Mock Exam System

Bloqueada até a conclusão das Etapas 10.2–10.4.

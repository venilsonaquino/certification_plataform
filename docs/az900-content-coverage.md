# AZ-900 content coverage

## Domain 1 — Describe cloud concepts

Auditoria realizada em 25 de agosto de 2026 e atualizada em 29 de agosto de 2026 após a Etapa 10.2, sobre o Domain **Describe cloud concepts (25–30%)**.

Referências curriculares primárias:

- [Study guide for Exam AZ-900 — skills measured from July 20, 2026](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-900)
- [Microsoft Learn — Describe cloud concepts learning path](https://learn.microsoft.com/en-us/training/paths/microsoft-azure-fundamentals-describe-cloud-concepts/)

O guia oficial vigente organiza este Domain em três grupos: cloud computing, benefícios dos serviços de nuvem e tipos de serviço de nuvem. Além dos objetivos solicitados pelo projeto, ele usa a formulação mais ampla **compare cloud pricing models**; por isso essa formulação aparece separadamente na matriz.

### Critérios

- **Covered:** há conteúdo conceitualmente correto e evidência de aplicação ou reforço em flashcards/questions; o título da Lesson, sozinho, não é suficiente.
- **Partial:** o conceito existe, mas a explicação, a prática ou a distribuição dos artefatos é insuficiente.
- **Missing:** não há conteúdo utilizável para o objetivo.

## Inventário atual

| Item | Quantidade |
| --- | ---: |
| Topics | 3 |
| Lessons publicadas | 18 |
| Lesson Content Blocks publicados | 129 |
| Flashcards publicados | 84 |
| Questions publicadas | 153 |

As 18 Lessons do Domain usam Content Blocks e preservam `lessons.content` como fallback. A Etapa 10.2 restaurou aditivamente os 35 blocks ausentes de `high-availability`, `scalability`, `elasticity`, `reliability` e `predictability`, sem alterar Lessons, Flashcards, Questions ou histórico.

| # | Topic / Lesson | Blocks | Flashcards | Questions |
| ---: | --- | ---: | ---: | ---: |
| 1 | Cloud Computing / `what-is-cloud-computing` | 6 | 7 | 11 |
| 2 | Cloud Computing / `shared-responsibility-model` | 8 | 7 | 11 |
| 3 | Cloud Computing / `public-private-hybrid-cloud` | 6 | 7 | 10 |
| 4 | Cloud Computing / `choosing-a-cloud-model` | 7 | 4 | 10 |
| 5 | Cloud Computing / `consumption-based-model` | 7 | 4 | 10 |
| 6 | Cloud Computing / `capex-vs-opex` | 7 | 4 | 10 |
| 7 | Cloud Computing / `serverless-computing` | 7 | 4 | 10 |
| 8 | Benefits of Cloud Services / `high-availability` | 7 | 4 | 10 |
| 9 | Benefits of Cloud Services / `scalability` | 7 | 4 | 10 |
| 10 | Benefits of Cloud Services / `elasticity` | 7 | 4 | 10 |
| 11 | Benefits of Cloud Services / `reliability` | 7 | 4 | 10 |
| 12 | Benefits of Cloud Services / `predictability` | 7 | 4 | 10 |
| 13 | Benefits of Cloud Services / `security-and-governance-benefits` | 9 | 4 | 6 |
| 14 | Benefits of Cloud Services / `manageability` | 7 | 4 | 5 |
| 15 | Cloud Service Types / `infrastructure-as-a-service` | 7 | 4 | 5 |
| 16 | Cloud Service Types / `platform-as-a-service` | 7 | 4 | 5 |
| 17 | Cloud Service Types / `software-as-a-service` | 7 | 4 | 5 |
| 18 | Cloud Service Types / `choosing-iaas-paas-saas` | 9 | 7 | 5 |

## Coverage matrix

| Objective | Lesson(s) | Status | Notes |
| --- | --- | --- | --- |
| Cloud Computing | `what-is-cloud-computing` | Covered | Seis blocks ensinam recursos de TI sob demanda, compute, storage, networking, provisionamento rápido, escala e consumo; 7 flashcards e 11 questions reforçam definição e cenários. |
| Shared Responsibility Model | `shared-responsibility-model` | Covered | Aula de referência com 8 blocks, visual On-Premises/IaaS/PaaS/SaaS, 7 flashcards e 11 questions. Diferencia responsabilidades sem afirmar que elas desaparecem em SaaS. |
| Public / Private / Hybrid Cloud | `public-private-hybrid-cloud` | Covered | Seis blocks e uma comparação responsiva definem operação, dedicação, localização e integração sem reduzir Private Cloud a servidor local; 7 flashcards e 10 questions reforçam o objetivo. |
| Casos de uso dos modelos de cloud | `choosing-a-cloud-model`; `public-private-hybrid-cloud` | Covered | A Lesson de escolha agora é centrada em cenários de escala pública, controle dedicado e integração com legado, incluindo armadilha de prova; possui 10 questions específicas. |
| Consumption-Based Model | `consumption-based-model` | Covered | Sete blocks explicam pagamento pelo consumo, pay-as-you-go, redução de capacidade ociosa, capacidade ajustável e relação entre custo e uso; 4 flashcards e 10 questions. |
| CapEx vs OpEx | `capex-vs-opex` | Covered | Sete blocks e uma comparação responsiva distinguem investimento antecipado e despesa recorrente, com a nuance de que classificação contábil depende do contrato e da organização; 4 flashcards e 10 questions. |
| Cloud pricing models — formulação oficial atual | `consumption-based-model`; `capex-vs-opex`; `predictability` | Covered | Sete blocks comparam explicitamente pay-as-you-go e compromisso planejado por flexibilidade e previsibilidade; os traps separam pricing model de CapEx/OpEx. Dois Flashcards e uma Question de cenário reforçam a comparação. |
| Serverless Computing | `serverless-computing` | Covered | Sete blocks explicam que os servidores existem, mas são abstraídos e administrados pelo provider; cobrem execução por eventos, escala automática e Azure Functions apenas como exemplo, com 4 flashcards e 10 questions. |
| High Availability | `high-availability` | Covered | Sete blocks cobrem disponibilidade durante falhas, redundância, múltiplas instâncias, downtime, comparação com Reliability, tip/trap e summary; 4 Flashcards e 10 Questions foram preservados. |
| Scalability | `scalability` | Covered | Sete blocks diferenciam scale up/down e scale out/in, com VM maior versus mais VMs, comparação com Elasticity, tip/trap e summary; 4 Flashcards e 10 Questions foram preservados. |
| Elasticity | `elasticity` | Covered | Sete blocks cobrem ajuste dinâmico, aumento/redução conforme demanda, cenário de e-commerce, limite de automação, comparação com Scalability e summary; prática preservada. |
| Reliability | `reliability` | Covered | Sete blocks cobrem operação correta, resiliência, redundância, recuperação, comparação com High Availability, tip/trap e summary; prática preservada. |
| Predictability | `predictability` | Covered | Sete blocks distinguem performance e cost predictability, conectam scaling/consumption às ferramentas posteriores sem aprofundá-las e incluem tip/trap e summary; prática preservada. |
| Security | `security-and-governance-benefits` | Covered | Nove blocks, 4 flashcards e 6 questions cobrem identity, encryption, controls, Shared Responsibility e cenários de configuração incorreta. |
| Governance | `security-and-governance-benefits` | Covered | Nove blocks, 4 flashcards e 6 questions cobrem padronização, policies, compliance, regras organizacionais e sobreposição com Security. |
| Manageability | `manageability` | Covered | Sete blocks, 4 flashcards e 5 questions cobrem Portal, CLI, PowerShell, APIs, Infrastructure as Code e escolha por cenário. |
| IaaS | `infrastructure-as-a-service`; `choosing-iaas-paas-saas`; `shared-responsibility-model` | Covered | Sete blocks, 4 flashcards e 5 questions distinguem responsabilidades, usam Azure Virtual Machines e cobrem controle do SO por conceito e cenário. |
| PaaS | `platform-as-a-service`; `choosing-iaas-paas-saas`; `shared-responsibility-model` | Covered | Sete blocks, 4 flashcards e 5 questions cobrem stack gerenciada, Azure App Service, publicação ASP.NET Core e limites de controle do SO. |
| SaaS | `software-as-a-service`; `choosing-iaas-paas-saas`; `shared-responsibility-model` | Covered | Sete blocks ensinam software pronto com Microsoft 365 e preservam responsabilidades do cliente sobre usuários, acessos, dados e configurações; possui 5 questions próprias. |
| Casos de uso IaaS/PaaS/SaaS | `choosing-iaas-paas-saas` | Covered | Nove blocks, comparação responsiva reutilizada, três cenários, 7 flashcards e 5 questions cobrem controle de SO, publicação em plataforma e consumo de software pronto. |

### Resultado consolidado

- Objetivos atômicos **Covered:** 20.
- Objetivos atômicos **Partial:** nenhum.
- Objetivos solicitados **Missing:** nenhum.
- Na formulação oficial atual, que agrupa High Availability + Scalability e Reliability + Predictability e não lista Elasticity isoladamente, o resultado normalizado é **15 Covered, 0 Partial e 0 Missing**.

## Problemas e riscos detectados

### Lessons ausentes

Não há Lesson ausente para os objetivos solicitados. Os 19 objetivos estão mapeados nas 18 Lessons existentes; Security e Governance compartilham intencionalmente uma Lesson.

### Lessons superficiais

Não resta Lesson superficial por ausência estrutural. As cinco Lessons identificadas na Etapa 10.1 agora possuem sete blocks e um summary final cada, mantendo o fallback e a prática existentes.

### Duplicação

- Nenhuma duplicata exata foi encontrada após normalizar os enunciados das 153 questions.
- Nenhuma duplicata exata foi encontrada após normalizar as frentes dos 84 flashcards.
- Há sobreposição pedagógica intencional entre definição e escolha de cloud models, e entre as Lessons individuais de IaaS/PaaS/SaaS e a Lesson comparativa. Não é recomendável remover essas Lessons.

### Conteúdo fora de ordem ou potencialmente profundo demais

As questions `62000000-0000-4000-8000-000000000079` e `62000000-0000-4000-8000-000000000080` foram corrigidas no mesmo UUID. Agora testam redundância e SLA sem antecipar Availability Zones ou Regions.

Algumas questions `hard` de Benefits pedem decisões de arquitetura/operação mais detalhadas do que o verbo oficial “describe”. Elas podem permanecer como aprofundamento, desde que o quiz da Lesson não dependa apenas desse nível de complexidade.

### Correção conceitual

Não foi encontrada afirmação claramente incorreta nos conteúdos auditados. Os blocks restaurados preservam as seguintes nuances:

- nuvem frequentemente desloca investimento inicial para consumo operacional, mas classificação CapEx/OpEx depende do contrato e da contabilidade da organização;
- Availability e Reliability se relacionam, mas não são sinônimos;
- Scalability é capacidade de crescer/reduzir; Elasticity enfatiza ajuste dinâmico conforme a demanda;
- SaaS reduz a carga operacional do cliente, mas não elimina responsabilidades sobre dados, identidades, acessos e uso.

## Lacunas em Flashcards

Todos os objetivos solicitados possuem flashcards associados direta ou comparativamente. Não existe Lesson sem flashcard neste Domain.

Não há lacuna essencial de memória ativa. Os 84 cards cobrem todos os objetivos do Domain; dois cards existentes foram ajustados na 8.4.7, nos mesmos UUIDs, para reforçar pay-as-you-go versus compromisso e pricing model versus CapEx/OpEx.

## Lacunas em Questions

| Lesson | Questions próprias | Avaliação |
| --- | ---: | --- |
| `security-and-governance-benefits` | 6 | Cobertura de Security, Governance, Shared Responsibility, comparação e cenários. |
| `manageability` | 5 | Cobertura conceitual e por cenário de Portal, comandos, APIs e IaC. |
| `infrastructure-as-a-service` | 5 | Cobertura de responsabilidades, Azure Virtual Machines e controle do SO. |
| `platform-as-a-service` | 5 | Cobertura de responsabilidades, Azure App Service, .NET e limites de controle do SO. |

Não resta Lesson sem prática: todas possuem pelo menos cinco questions. As Lessons acima usam distribuição aproximada de 2 easy / 2–3 medium / 1 hard; as Lessons importadas anteriormente mantêm conjuntos maiores de 10–11 itens.

## Ordem pedagógica

A ordem atual já corresponde à progressão recomendada:

```text
Cloud Computing
→ Shared Responsibility
→ Public / Private / Hybrid
→ casos de uso dos cloud models
→ Consumption-Based Model
→ CapEx vs OpEx
→ Serverless
→ Cloud Benefits
→ IaaS / PaaS / SaaS
→ escolha por cenário
```

Não é recomendada mudança de `display_order` nesta etapa. Ao enriquecer as Lessons, apenas crie transições explícitas entre:

- Consumption-Based Model e pricing/CapEx/OpEx;
- High Availability e Reliability;
- Scalability e Elasticity;
- modelos de serviço e Shared Responsibility.

## Integridade e arquitetura

- Nenhum UUID foi alterado.
- Foram corrigidos 31 flashcards e quatro questions existentes no mesmo UUID; 34 distratores foram substituídos por alternativas plausíveis e 20 questions originais foram adicionadas.
- Progresso, histórico de quiz, histórico de flashcards e links permanecem preservados.
- A FK por `lesson_id` permite auditar cobertura com precisão, mas também evidencia que questions comparativas podem cobrir um objetivo sem estar associadas à Lesson individual correspondente. Relatórios futuros devem considerar objetivo + Lesson, não apenas contagem por Lesson.
- A coexistência de `lessons.content` e `lesson_content_blocks` preserva o fallback. A regressão estrutural encontrada na Etapa 10.1 foi corrigida aditivamente na Etapa 10.2, sem remover ou reescrever o conteúdo legado.

Consultas reproduzíveis usadas nesta auditoria:

- `supabase/tests/inspect_az900_domain1_coverage.sql`
- `supabase/tests/inspect_az900_domain1_artifact_quality.sql`
- `supabase/tests/validate_az900_cloud_computing_lesson_blocks.sql`
- `supabase/tests/validate_az900_cloud_benefits_lesson_blocks.sql`
- `supabase/tests/validate_az900_cloud_service_types_lesson_blocks.sql`
- `supabase/tests/validate_az900_domain1_practice_content.sql`
- `supabase/tests/validate_az900_domain1_final.sql`
- `supabase/tests/validate_az900_cloud_pricing_models.sql`

## Validação consolidada — após a Etapa 8.4.7

O Domain 1 foi validado no Supabase de produção com 18 Lessons publicadas, 129 Content Blocks publicados, 84 Flashcards e 153 Questions. As estimativas variam entre 10 e 12 minutos, totalizando 184 minutos. `consumption-based-model` passou de 8 para 10 minutos após receber a comparação de pricing.

As quatro Visual Experiences usadas neste Domain estão publicadas e ligadas à mesma Lesson do respectivo block:

- `Modelo de responsabilidade compartilhada` — `shared-responsibility-model`;
- `Public, Private e Hybrid Cloud` — `public-private-hybrid-cloud`;
- `CapEx e OpEx` — `capex-vs-opex`;
- `IaaS, PaaS e SaaS por cenário` — `choosing-iaas-paas-saas`.

O validador final confirmou:

- `display_order` contínuo em todas as Lessons;
- todos os 129 blocks publicados e com `config` válido;
- exatamente um `summary` final por Lesson, com 3–6 itens;
- `exam_tip` nas 18 Lessons e 16 `exam_trap` nos conceitos que exigem diferenciação;
- fallback não vazio em `lessons.content` nas 18 Lessons;
- mínimo de quatro Flashcards e cinco Questions por Lesson;
- quatro alternativas distintas, uma resposta correta e explicação didática em cada Question publicada;
- RLS habilitado, leitura de conteúdo restrita a usuários autenticados e escrita direta negada;
- ausência de referências órfãs em progresso, revisões de Flashcards e histórico de Quiz.

Regressão concluída:

- fluxo de Lesson e fallback: 79/79 testes Vitest passaram;
- Lesson Quiz, Topic Quiz, Review, Spaced Repetition, conclusão e isolamento de progresso: validadores SQL transacionais passaram em produção;
- rota protegida redireciona usuário não autenticado para `/login` sem erros de console;
- login em 1280×720 e 390×844 não apresentou overflow horizontal;
- `typecheck`, `lint` e `build` passaram;
- Supabase remoto está atualizado (`db push --dry-run` sem migrations pendentes).

Após a Etapa 10.2, todas as 18 Lessons podem usar o renderer estruturado e continuam protegidas pelo fallback legado. High Availability, Scalability, Elasticity, Reliability e Predictability voltaram a possuir cobertura estruturada sem alteração de prática ou histórico.

## Checkpoint — Etapa 10.2

**Domain 1: CLOSED — P1 da auditoria global resolvido**

| Indicador final | Resultado |
| --- | ---: |
| Objetivos oficiais Covered | 15 |
| Objetivos oficiais Partial | 0 |
| Objetivos Missing | 0 |
| Lessons publicadas | 18 |
| Content Blocks publicados | 129 |
| Visual Experiences utilizadas pelo Domain | 4 |
| Flashcards publicados | 84 |
| Questions publicadas | 153 |
| Tempo estimado | 184 minutos |

O checkpoint confirmou ausência de referências órfãs em progresso, tentativas e respostas de Quiz, revisões de Flashcards e spaced repetition. RLS está habilitado nas tabelas curriculares e de usuário; conteúdo publicado é legível por usuários autenticados, questões e gabaritos permanecem protegidos pelo fluxo de Quiz, e escrita curricular direta é negada.

O estado local `supabase/.temp/` foi removido do tracking e adicionado ao `.gitignore`, sem apagar os arquivos locais. A varredura do índice não encontrou `.env`, chaves, tokens, senhas ou connection strings privadas; `.env.example` contém somente nomes de variáveis com valores vazios. As migrations estão ordenadas, sem versões duplicadas, sem arquivos temporários e sem alterações em migrations antigas. O Supabase remoto não possui migration pendente.

## Domain 2 — Core Architectural Components

Auditoria realizada em 26 de agosto de 2026, sem alteração curricular no banco, para o Topic **Core Architectural Components** do Domain **Describe Azure architecture and services (35–40%)**.

Referências curriculares e factuais primárias:

- [Study guide for Exam AZ-900 — skills measured from July 20, 2026](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-900)
- [What are Azure regions?](https://learn.microsoft.com/en-us/azure/reliability/regions-overview)
- [What are Azure Availability Zones?](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview)
- [Azure management groups](https://learn.microsoft.com/en-us/azure/governance/management-groups/)

Esta seção não cobre Compute, Containers, Functions, Networking, Storage, Identity ou RBAC. Menções desses serviços usadas apenas como exemplos foram avaliadas, mas não contam como cobertura dos respectivos objetivos.

### Critérios da auditoria

- **Covered:** explicação suficiente e tecnicamente correta, prática coerente e, quando útil, apoio visual.
- **Partial:** existe Lesson e prática, mas o conteúdo é legado/superficial, está mal distribuído ou contém afirmações que exigem correção.
- **Missing:** não existe conteúdo utilizável para o objetivo.
- **Ready:** a Lesson já possui a estrutura pedagógica necessária, incluindo Content Blocks e summary.
- **Needs enrichment:** o registro pode ser preservado, mas o conteúdo precisa ser enriquecido ou corrigido.

### Inventário do Topic

| Item | Quantidade |
| --- | ---: |
| Lessons publicadas | 7 |
| Lesson Content Blocks publicados | 55 |
| Visual Experiences publicadas | 2 |
| Flashcards publicados | 37 |
| Questions publicadas | 42 |
| Tempo estimado total | 70 minutos |

Após a Etapa 8.5.5, as sete Lessons usam Content Blocks estruturados e preservam `lessons.content` como fallback.

| # | Lesson / slug real | Min. | Blocks | Visual | Flashcards | Questions (E/M/H) | Status | Avaliação |
| ---: | --- | ---: | ---: | --- | ---: | ---: | --- | --- |
| 1 | Azure Datacenters / `azure-datacenters` | 10 | 7 | Nenhum | 4 | 10 (3/5/2) | Ready | Sete blocks cobrem infraestrutura física, relação Geography/Region/Datacenter, escolha de localização, exam trap, exam tip e summary. As 10 questions agora medem Datacenters e suas diferenças. |
| 2 | Azure Regions / `azure-regions` | 10 | 7 | Nenhum | 7 | 6 (2/3/1) | Ready | Sete blocks cobrem geography, datacenters conectados, implantação e fatores de escolha, com cenário ASP.NET Core, exam trap, exam tip e summary. |
| 3 | Availability Zones / `availability-zones` | 10 | 9 | Architecture | 7 | 5 (1/3/1) | Ready | Nove blocks cobrem definição, isolamento, suporte variável, zonal versus zone-redundant, exemplo .NET, exam tip/trap e summary. O visual foi corrigido e reutilizado. |
| 4 | Region Pairs and Sovereign Regions / `region-pairs-and-sovereign-regions` | 10 | 9 | Nenhum | 4 | 5 (2/2/1) | Ready | Nove blocks separam os conceitos, cobrem paired/nonpaired regions, limites de automação, sovereign clouds, data residency, dois exam traps, exam tip e summary. |
| 5 | Resources and Resource Groups / `resources-and-resource-groups` | 10 | 7 | Nenhum | 7 | 6 (3/2/1) | Ready | Sete blocks cobrem Resource, Resource Group, pertencimento, Regions diferentes, ciclo de vida, tags sem herança automática, exam tip/trap e summary. |
| 6 | Subscriptions and Management Groups / `subscriptions-and-management-groups` | 10 | 8 | Nenhum | 4 | 5 (2/2/1) | Ready | Oito blocks separam Subscription e Management Group, cobrem acesso, quotas/limites, organização, billing sem invoice obrigatória, governança conceitual, exam tip/trap e summary. |
| 7 | Azure Resource Hierarchy / `azure-resource-hierarchy` | 10 | 8 | Architecture | 4 | 5 (2/2/1) | Ready | Oito blocks apresentam a ordem dos escopos, exemplo, limites de Policy/RBAC, exam tip/trap, summary e uma visualização vertical acessível da hierarquia. |

Não há Lesson ausente e não é recomendada a criação de novos slugs. Os sete registros existentes acomodam todos os objetivos oficiais e devem ser preservados.

### Coverage matrix

| Objective | Lesson | Content | Visual | Flashcards | Questions | Status | Notes |
| --- | --- | --- | --- | ---: | ---: | --- | --- |
| Azure Datacenters | `azure-datacenters` | 7 blocks estruturados | Not necessary | 4 | 10 | Covered | Explica infraestrutura física, responsabilidade do provider, escolha de Region e diferenças entre Datacenter, Region e Zone. Possui summary, exam tip, exam trap e prática coerente. |
| Azure Regions | `azure-regions` | 7 blocks estruturados | Not necessary | 7 | 6 | Covered | Explica geography, uma ou mais instalações conectadas, localização de implantação e escolha por latência, serviços, residência/compliance, preço e resiliência. Possui cenário .NET e prática coerente. |
| Region Pairs | `region-pairs-and-sovereign-regions` | 4 blocks dedicados + exam tip + summary compartilhados | Not necessary | 3 dos 4 | 3 dos 5 | Covered | Define a associação feita pela Microsoft entre algumas Regions, distingue paired/nonpaired e condiciona geo-replication, geo-redundancy e disaster recovery ao serviço, à configuração e à arquitetura. |
| Sovereign Regions | `region-pairs-and-sovereign-regions` | 3 blocks dedicados + exam tip + summary compartilhados | Not necessary | 1 dos 4 | 2 dos 5 | Covered | Explica sovereign cloud, requisitos específicos, isolamento/operação e disponibilidade variável, além de separar soberania de data residency. |
| Availability Zones | `availability-zones` | 9 blocks estruturados | Reuse | 7 | 5 | Covered | Define Zone como agrupamento lógico de um ou mais datacenters, explica isolamento e suporte, diferencia zonal/zone-redundant e reutiliza o visual corrigido no mesmo UUID. |
| Azure Resources | `resources-and-resource-groups` | 7 blocks estruturados | Not necessary | 1 dos 7 | 1 dos 6 | Covered | Define Resource como entidade gerenciável, fornece exemplos e diferencia o item individual do container lógico. |
| Resource Groups | `resources-and-resource-groups` | 7 blocks estruturados | Not necessary | 6 dos 7 | 5 dos 6 | Covered | Explica organização, pertencimento, ciclo de vida, Regions diferentes e ausência de herança automática de tags, com prática corrigida. |
| Subscriptions | `subscriptions-and-management-groups` | 8 blocks estruturados | Not necessary | 2 dos 4 | 2 dos 5 | Covered | Cobre Resources, acesso, quotas/limites, organização e relação de billing sem tratar Subscription como invoice independente. |
| Management Groups | `subscriptions-and-management-groups` | 8 blocks estruturados | Not necessary | 2 dos 4 | 3 dos 5 | Covered | Define o escopo acima das Subscriptions, organização e governança centralizada sem aprofundar implementação de Policy/RBAC. |
| Hierarchy entre Resource Groups, Subscriptions e Management Groups | `azure-resource-hierarchy`; `subscriptions-and-management-groups`; `resources-and-resource-groups` | 23 blocks complementares | Reuse | 4 | 5 | Covered | A ordem Management Groups → Subscriptions → Resource Groups → Resources está explícita; a visualização mostra Tenant/Root como contexto e a prática evita regras universais de sobrescrita. |

### Resultado de cobertura

- **Covered:** 10 objetivos.
- **Partial:** 0 objetivos.
- **Missing:** 0 objetivos.
- **Lessons Ready:** 7.
- **Lessons Needs enrichment:** 0.
- **Lessons Missing:** 0.

Todos os dez objetivos auditados de Core Architectural Components estão `Covered`. A Etapa 8.5.5 fechou Azure Resources, Resource Groups, Subscriptions, Management Groups e Resource Hierarchy sem avançar para Compute, Networking, Storage ou Identity.

### Visual Experiences

Existem duas experiências no Topic:

| ID | Lesson | Tipo | Status de publicação | Classificação | Decisão futura |
| --- | --- | --- | --- | --- | --- |
| `76000000-0000-4000-8000-000000000002` | `availability-zones` | `architecture` | Publicada | Reuse | Atualizada na 8.5.3 no mesmo UUID: Region → três Zones → “1+ Datacenters”, com independência de energia, refrigeração e networking. |
| `76000000-0000-4000-8000-000000000007` | `azure-resource-hierarchy` | `architecture` | Publicada | Reuse | Criada na 8.5.5 como hierarquia vertical Tenant/Root → Management Groups → Subscriptions → Resource Groups → Resources, com detalhes acessíveis por node. |

As duas configurações são renderizáveis, responsivas e acessíveis. A experiência de Availability Zones representa uma Region contendo três Zones, cada uma ligada a um agrupamento de um ou mais datacenters. A nova experiência de Resource Hierarchy usa uma única coluna em mobile e mantém uma representação textual para leitores de tela. Nenhuma nova interação é necessária para as outras Lessons do Topic.

### Auditoria de Flashcards

| Lesson | Cards | Avaliação |
| --- | ---: | --- |
| `azure-datacenters` | 4 | Quatro UUIDs preservados e textos ajustados para definição, relação Region → Datacenters, seleção de Region e diferença Datacenter versus Region. |
| `azure-regions` | 7 | Quatro cards ajustados nos mesmos UUIDs; a repetição sobre latência foi substituída por geography e os fatores de escolha agora incluem resiliência. |
| `availability-zones` | 7 | Os sete cards foram corrigidos nos mesmos UUIDs. Agora cobrem definição 1+ datacenters, isolamento, Region versus Zone, suporte variável e zonal versus zone-redundant, sem antecipar Availability Sets. |
| `region-pairs-and-sovereign-regions` | 4 | Os quatro UUIDs foram preservados e os cards agora testam definição do pair, paired versus nonpaired, finalidade possível sem automação e Sovereign Region versus data residency. |
| `resources-and-resource-groups` | 7 | O card de tags foi corrigido no mesmo UUID; a cobertura inclui Resource, Resource Group, pertencimento, ciclo de vida, Regions e tags sem herança automática. |
| `subscriptions-and-management-groups` | 4 | Dois cards foram corrigidos nos mesmos UUIDs para representar Subscription como escopo e retirar a exigência de faturamento independente. |
| `azure-resource-hierarchy` | 4 | Dois cards foram corrigidos nos mesmos UUIDs; agora ensinam amplitude de escopo sem regra universal de sobrescrita de Policy ou RBAC. |

Não há duplicata exata de frente entre os 37 Flashcards. A Etapa 8.5.5 corrigiu cinco cards nos mesmos UUIDs, sem criar, remover ou reassociar registros.

### Auditoria de Questions

| Lesson | Total | Easy | Medium | Hard | Avaliação |
| --- | ---: | ---: | ---: | ---: | --- |
| `azure-datacenters` | 10 | 3 | 5 | 2 | As 10 questions foram reescritas nos mesmos UUIDs e agora testam definição, componentes físicos, responsabilidade, relação e diferenças, sem antecipar Zones ou Region Pairs. |
| `azure-regions` | 6 | 2 | 3 | 1 | Boa distribuição por conceito e cenário; uma question foi ajustada para incluir preço aplicável e opções de resiliência entre os fatores de escolha. |
| `availability-zones` | 5 | 1 | 3 | 1 | As cinco questions foram ajustadas nos mesmos UUIDs e cobrem cenário, definição, zonal versus zone-redundant, suporte variável e responsabilidade, sem depender de VMs. |
| `region-pairs-and-sovereign-regions` | 5 | 2 | 2 | 1 | As cinco questions foram corrigidas nos mesmos UUIDs e cobrem definição, nonpaired regions, Sovereign Region versus data residency e ausência de replicação/failover automático. |
| `resources-and-resource-groups` | 6 | 3 | 2 | 1 | Três questions foram corrigidas nos mesmos UUIDs para testar Regions diferentes, tags sem herança automática e pertencimento a um único Resource Group por vez. |
| `subscriptions-and-management-groups` | 5 | 2 | 2 | 1 | Três questions foram corrigidas nos mesmos UUIDs para testar Subscription, billing compartilhado e Management Group sem aprofundamento operacional. |
| `azure-resource-hierarchy` | 5 | 2 | 2 | 1 | Quatro questions foram reorientadas nos mesmos UUIDs para ordem, containers, escopos progressivos e cenário de organização, retirando Policy/RBAC detalhados. |
| **Total** | **42** | **15** | **19** | **8** | Quantidade e distribuição suficientes; a prática das sete Lessons está coerente com o recorte de Fundamentals. |

Não resta duplicata exata normalizada entre as 42 Questions do Topic. A duplicata sobre Region Pairs foi eliminada na Etapa 8.5.2 ao reescrever, no mesmo UUID, a Question que estava incorretamente associada a `azure-datacenters`. As Etapas 8.5.4 e 8.5.5 preservaram todos os UUIDs de Questions, opções e Lessons; nenhuma Question foi apagada, criada ou reassociada.

### Inconsistências e riscos

As inconsistências curriculares encontradas na auditoria foram corrigidas. `lessons.content` permanece preservado como fallback nas sete Lessons. Azure Policy e Azure RBAC aparecem somente como exemplos de mecanismos aplicáveis em diferentes escopos; suas regras específicas continuam fora desta etapa.

### Plano exato para 8.5.2–8.5.6

| Etapa | Lessons envolvidas | Lacunas a fechar | Visual Experience |
| --- | --- | --- | --- |
| 8.5.2 — Datacenters + Regions | `azure-datacenters`; `azure-regions` | Concluída: definições, relação geography/region/datacenter, rede de baixa latência, fatores de escolha e prática corrigida. | Nenhuma criada, conforme planejado. |
| 8.5.3 — Availability Zones | `availability-zones` | Concluída: definição 1+ datacenters, isolamento, suporte variável, responsabilidade e zonal versus zone-redundant. | Visual reutilizado e atualizado no mesmo UUID `76000000-0000-4000-8000-000000000002`; nenhuma nova experiência criada. |
| 8.5.4 — Region Pairs + Sovereign Regions | `region-pairs-and-sovereign-regions` | Concluída: os conceitos foram separados, nonpaired regions foram cobertas e promessas automáticas de replicação, failover ou continuidade foram removidas. | Nenhuma criada, conforme planejado. |
| 8.5.5 — Resource Hierarchy | `resources-and-resource-groups`; `subscriptions-and-management-groups`; `azure-resource-hierarchy` | Concluída: Resource, ciclo de vida e tags de Resource Group, escopos de Subscription, Management Groups e hierarquia foram enriquecidos sem aprofundar Policy/RBAC. | Uma única visualização vertical criada em `azure-resource-hierarchy`; nenhuma nas duas Lessons auxiliares. |
| 8.5.6 — Practice + fechamento | As sete Lessons do Topic | Concluída: auditoria final confirmou associação, precisão, distribuição e ausência de duplicatas exatas; nenhuma correção adicional ou reassociação foi necessária. | Nenhuma nova; as experiências de Availability Zones e Resource Hierarchy foram mantidas. |

### Preservação histórica

Nenhum UUID, registro curricular ou dado de usuário foi alterado nesta auditoria. Alterar slugs ou recriar Lessons, Questions e Flashcards quebraria ou fragmentaria referências em `user_lesson_progress`, `quiz_attempts`, `quiz_answers`, `quiz_attempt_questions`, `flashcard_reviews` e `user_flashcard_progress`. As etapas futuras devem fazer updates in-place e, se uma Question precisar mudar de Lesson, manter seu UUID e validar o significado do histórico já registrado.

**Checkpoint da Etapa 8.5.1:** auditoria concluída; nenhuma Lesson enriquecida, nenhum simulador criado e nenhum conteúdo de Compute, Networking, Storage ou Identity implementado.

### Atualização — Etapa 8.5.2

`azure-datacenters` e `azure-regions` foram enriquecidas com 14 Content Blocks publicados, sete por Lesson. Ambas possuem `exam_tip`, `exam_trap`, summary com 5–6 itens, `display_order` contínuo e estimativa de 10 minutos. O conteúdo legado foi preservado como fallback.

Oito Flashcards, 11 Questions e 44 alternativas foram ajustados in-place. Todos os UUIDs de Lessons, Flashcards, Questions e Question Options foram preservados; a quantidade permaneceu em 37 Flashcards e 42 Questions no Topic. Nenhuma Visual Experience foi criada ou alterada, incluindo `76000000-0000-4000-8000-000000000002`.

O validador `supabase/tests/validate_az900_datacenters_regions.sql` confirmou blocks, summaries, ordem, publicação, fallback, prática, ausência de duplicações exatas, leitura autenticada e ausência de referências históricas órfãs. Lesson Quiz e Topic Quiz também passaram em validadores transacionais de produção.

### Atualização — Etapa 8.5.3

`availability-zones` foi enriquecida com nove Content Blocks publicados: `explanation`, `important`, `visual_experience`, `explanation`, `important`, `dotnet_example`, `exam_tip`, `exam_trap` e `summary`. A estimativa passou de 8 para 10 minutos, com o conteúdo legado preservado como fallback.

A Visual Experience `76000000-0000-4000-8000-000000000002` manteve seu UUID e passou a representar uma Azure Region com três Zones e um agrupamento “1+ Datacenters” sob cada uma. As descrições comunicam independência de energia, refrigeração e networking. Nenhuma nova Visual Experience foi criada.

Os sete Flashcards, as cinco Questions e suas 20 alternativas foram corrigidos in-place. O conteúdo agora cobre definição, isolamento, suporte variável, Region versus Zone e zonal versus zone-redundant, sem Availability Sets ou aprofundamento de Compute. O validador `supabase/tests/validate_az900_availability_zones.sql` confirmou integridade curricular, RLS de leitura, ausência de duplicações e preservação histórica.

### Atualização — Etapa 8.5.5

`resources-and-resource-groups`, `subscriptions-and-management-groups` e `azure-resource-hierarchy` foram enriquecidas com 23 Content Blocks publicados, respectivamente 7, 8 e 8. As três mantêm estimativa de 10 minutos e preservam `lessons.content` como fallback.

Foi criada uma única Visual Experience `architecture`, vinculada a `azure-resource-hierarchy`, representando Tenant/Root → Management Groups → Subscriptions → Resource Groups → Resources. O renderer adapta hierarquias de uma coluna a 320 px sem overflow horizontal, mantém nodes interativos, região focável e representação textual para leitores de tela.

Cinco Flashcards e dez Questions foram corrigidos in-place, preservando UUIDs e histórico. Tags não são apresentadas como automaticamente herdadas, Subscriptions não são tratadas como invoices independentes e a prática de hierarquia não ensina regras universais de sobrescrita de Policy/RBAC.

### Atualização — Etapa 8.5.6

A auditoria final revalidou as sete Lessons do Topic. Todas estão publicadas, possuem `lessons.content` preservado como fallback, estimativa de 10 minutos e Content Blocks publicados com ordem contínua, summary e reforço de prova. O inventário final permanece em 7 Lessons, 55 Content Blocks, 37 Flashcards, 42 Questions, 2 Visual Experiences e 70 minutos.

Nenhuma Question ou Flashcard precisou ser alterado, criado, apagado ou reassociado nesta etapa. A revisão confirmou que Availability Zone não é tratada como um único Datacenter; Region Pair não implica pareamento universal, replicação ou failover automático; tags não são apresentadas como herdadas automaticamente; Subscription não é definida como invoice obrigatoriamente independente; e Resource Hierarchy não ensina regras universais de sobrescrita de Azure Policy ou RBAC.

A distribuição final de Questions é 15 easy, 19 medium e 8 hard. Cada Lesson possui entre 5 e 10 Questions, permitindo seleção útil por Lesson e pelo Topic sem impor uma quantidade artificialmente uniforme. As duas Visual Experiences do Topic permanecem vinculadas aos mesmos UUIDs: Availability Zones (`76000000-0000-4000-8000-000000000002`) e Resource Hierarchy (`76000000-0000-4000-8000-000000000007`).

Resultado curricular final: 10 objetivos `Covered`, 0 `Partial` e 0 `Missing`.

**Core Architectural Components: CLOSED**

## Domain 2 — Azure Compute Services

Auditoria realizada em 27 de agosto de 2026 para o Topic **Compute Services** do Domain **Describe Azure architecture and services (35–40%)**. O recorte segue o [guia oficial do AZ-900](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-900), com skills measured a partir de 20 de julho de 2026, e o módulo [Describe Azure compute services](https://learn.microsoft.com/en-us/training/modules/describe-azure-compute-networking-services/).

Esta etapa audita somente Compute. VNet, Subnet, Peering, Azure DNS, VPN Gateway, ExpressRoute, endpoints, Storage, Entra ID e RBAC não contam como cobertura. AI, Machine Learning e IoT/Edge aparecem no módulo de treinamento atual, mas não no objetivo de Compute dos skills measured adotados pelo projeto e, portanto, não foram adicionados ao escopo.

### Inventário das Lessons

O Topic possui 9 Lessons publicadas, 73 Content Blocks, 2 Visual Experiences, 34 Flashcards, 51 Questions e 96 minutos estimados. Todas preservam conteúdo legado em `lessons.content`; as nove Lessons concluídas nas etapas 8.6.2–8.6.5 estão `Ready`. O fechamento corrigiu o inventário histórico: as Questions `60000000-0000-4000-8000-000000000007` (VM) e `60000000-0000-4000-8000-000000000008` (App Service) já pertenciam ao Topic e foram preservadas, embora as contagens intermediárias as tivessem omitido.

| # | Lesson / slug real | Min. | Blocks | Visual | Flashcards | Questions (E/M/H) | Publicada | Status | Avaliação |
| ---: | --- | ---: | ---: | --- | ---: | ---: | --- | --- | --- |
| 1 | Comparing Compute Options / `comparing-compute-options` | 10 | 9 | Nenhum | 4 | 5 (2/2/1) | Sim | Ready | Matriz textual compara controle do SO, guest OS, portabilidade, eventos, gestão e startup; três cenários e exemplos .NET equilibram VM, container e Function. |
| 2 | Azure Virtual Machines / `azure-virtual-machines` | 12 | 7 | Nenhum | 4 | 6 (2/3/1) | Sim | Ready | Blocks cobrem IaaS, Shared Responsibility, casos de uso, exemplo .NET, custo/lifecycle, exam tip, exam trap e summary; a Question histórica adicional testa responsabilidade geral do guest OS. |
| 3 | VM Scale Sets and Availability Sets / `vm-scale-sets-and-availability-sets` | 12 | 9 | Architecture | 4 | 5 (2/2/1) | Sim | Ready | Separa escala, autoscale configurado, fault/update domains e Availability Zones; remove absolutos e inclui comparação visual. |
| 4 | Azure Virtual Desktop / `azure-virtual-desktop` | 10 | 7 | Nenhum | 3 | 5 (2/2/1) | Sim | Ready | Cobre desktop completo, RemoteApp, tipos de sessão, acesso por dispositivos, cenário corporativo e AVD versus VM/RDP. |
| 5 | Resources Required for Virtual Machines / `virtual-machine-resources` | 10 | 8 | Architecture | 3 | 5 (2/2/1) | Sim | Ready | Estrutura e visual relacionam VM size, OS/data disks, NIC, VNet/subnet, IP configuration e Public IP opcional; prática e lifecycle foram corrigidos. |
| 6 | Azure App Service / `azure-app-service` | 10 | 8 | Nenhum | 4 | 5 (2/2/1) | Sim | Ready | PaaS para web/APIs, responsabilidades, escala condicionada, App Service versus VM, cenário ASP.NET Core e prática Fundamentals estão explícitos. |
| 7 | Azure Functions / `azure-functions` | 10 | 8 | Nenhum | 3 | 10 (3/5/2) | Sim | Ready | Serverless, infraestrutura abstraída, triggers, eventos, escala/cobrança condicionadas e prática Fundamentals substituem Premium, cold start e configuração avançada. |
| 8 | Containers on Azure / `containers-on-azure` | 10 | 8 | Nenhum | 4 | 5 (2/2/1) | Sim | Ready | Define aplicação + dependências, kernel compartilhado, portabilidade, startup típico e ACI versus AKS apenas em nível conceitual. |
| 9 | Choosing Application Hosting / `choosing-application-hosting` | 12 | 9 | Nenhum | 5 | 5 (2/2/1) | Sim | Ready | Matriz, três cenários, exam tip/trap e prática própria comparam Web Apps, containers e VMs por controle, portabilidade e operação. |

Não há Lesson ausente e não é recomendada a criação de novos slugs. Os nove registros existentes acomodam todos os objetivos oficiais e seus UUIDs devem ser preservados.

### Coverage Matrix

| Objective | Lesson(s) | Content | Visual | Flashcards | Questions | Status | Notes |
| --- | --- | --- | --- | ---: | ---: | --- | --- |
| Compare VMs / Containers / Functions | `comparing-compute-options`; `containers-on-azure`; `azure-functions`; `azure-virtual-machines` | 9 blocks comparativos + apoio | Not necessary | 11 relevantes | 20 distribuídas, com 5 próprias equilibradas | Covered | Matriz estruturada, cenários e exemplos .NET comparam controle, guest OS, portabilidade, eventos, gestão e startup sem absolutos. |
| Azure Virtual Machines | `azure-virtual-machines` | 7 blocks + fallback | Not necessary | 4 | 5 | Covered | Definição IaaS, responsabilidades, casos de uso, controle versus PaaS, exam tip/trap, summary e prática coerente estão explícitos. |
| Virtual Machine Scale Sets | `vm-scale-sets-and-availability-sets` | 9 blocks + fallback | Architecture compartilhada | 4 | 5 | Covered | Gerenciamento e escala de múltiplas instâncias, autoscale condicionado à configuração, cenários, exam tip/trap e prática estão explícitos. |
| Availability Sets | `vm-scale-sets-and-availability-sets` | 9 blocks + fallback | Architecture compartilhada | 4 | 5 | Covered | Fault domains, update domains, limites de disponibilidade e comparação com Scale Sets e Availability Zones possuem conteúdo e prática coerentes. |
| Azure Virtual Desktop | `azure-virtual-desktop` | 7 blocks + fallback | Not necessary | 3 | 5 | Covered | Desktop/app virtualization, desktop completo, RemoteApp, sessões, dispositivos, cenário empresarial e AVD versus VM/RDP estão cobertos. |
| Resources required for VMs | `virtual-machine-resources`; `azure-virtual-machines` | 8 blocks + fallback | Architecture | 3 | 5 próprias + apoio em VM | Covered | Compute, storage e networking são relacionados explicitamente; Public IP é opcional, o visual é navegável e a prática cobre cada componente sem aprofundar Networking/Storage. |
| Azure Web Apps | `azure-app-service`; `choosing-application-hosting` | 8 blocks + apoio | Not necessary | 4 | 5 próprias + cenários comparativos | Covered | Conceito PaaS, responsabilidades, escala condicionada, App Service versus VM, exemplo ASP.NET Core, exam trap, summary e prática 2/2/1 estão explícitos. |
| Containers | `containers-on-azure`; `comparing-compute-options` | 8 blocks + apoio | Not necessary | 8 relevantes | 5 próprias + cenários comparativos | Covered | Conceito, kernel compartilhado, portabilidade, ACI/AKS Fundamentals, exam trap, summary e prática 2/2/1 estão explícitos. |
| Azure Functions | `azure-functions`; `comparing-compute-options` | 8 blocks + apoio | Not necessary | 5 relevantes | 10 próprias + cenários comparativos | Covered | Serverless, event-driven, triggers, infraestrutura abstraída e condicionantes de plano/configuração têm prática sem aprofundamento de hosting. |
| Application hosting options | `choosing-application-hosting`; `azure-app-service`; `containers-on-azure`; `azure-virtual-machines` | 9 blocks comparativos + apoio | Not necessary | 5 próprias + apoio | 5 próprias + prática das opções | Covered | Matriz estruturada, cenários Web Apps/container/VM, critérios de controle, portabilidade e operação, exam tip/trap, summary e prática própria fecham o objetivo. |

### Resultado de cobertura

- **Covered:** 10 objetivos.
- **Partial:** 0 objetivos.
- **Missing:** 0 objetivos.
- **Lessons Ready:** 9.
- **Lessons Needs enrichment:** 0.
- **Lessons Missing:** 0.

### Auditoria de Flashcards

| Lesson | Flashcards | Avaliação |
| --- | ---: | --- |
| `comparing-compute-options` | 4 | Corrigidos in-place para controle do SO, Function orientada a eventos com plano condicionado, kernel compartilhado e portabilidade. |
| `azure-virtual-machines` | 4 | Três cards foram corrigidos in-place: definição/responsabilidade, desalocação versus custos associados e VM versus serviço gerenciado. O card de patches já estava correto. |
| `vm-scale-sets-and-availability-sets` | 4 | Os quatro cards foram corrigidos in-place: finalidade do Scale Set, diferença para Availability Set, fault domains e update domains sem garantias absolutas. |
| `azure-virtual-desktop` | 3 | Os três cards foram corrigidos in-place para definição, cenário centralizado e sessões individuais ou compartilhadas, preservando os UUIDs. |
| `virtual-machine-resources` | 3 | Os três cards foram corrigidos in-place para compute/storage/networking, OS disk versus data disk e exclusão condicionada à configuração; o card de NSG deixou de antecipar Networking. |
| `azure-app-service` | 4 | Os quatro cards foram corrigidos in-place para definição PaaS, responsabilidades, App Service versus VM e cenário web/API; runtimes e deployment slots deixaram de ser exigidos. |
| `azure-functions` | 3 | Corrigidos in-place: definição, trigger e escala/cobrança agora evitam absolutos e permanecem em Fundamentals. |
| `containers-on-azure` | 4 | Corrigidos in-place para container versus VM, ACI, AKS e escolha conceitual entre execução simples e orquestração. |
| `choosing-application-hosting` | 5 | Cinco cards novos cobrem Web Apps, containers, VMs, critérios de escolha e ausência de regra universal para aplicações web. |

Não foi encontrada duplicata exata de frente. Há sobreposição semântica intencional entre os cards de comparação e os cards específicos de VM, container e Functions; ela deve ser reduzida apenas onde não contribuir para recuperação ativa.

### Auditoria de Questions

| Lesson | Total | Easy | Medium | Hard | Avaliação |
| --- | ---: | ---: | ---: | ---: | --- |
| `comparing-compute-options` | 5 | 2 | 2 | 1 | As cinco Questions e vinte opções foram reescritas in-place; VM, container e Function aparecem como respostas corretas em conceitos e cenários plausíveis. |
| `azure-virtual-machines` | 6 | 2 | 3 | 1 | A Question histórica de responsabilidade geral foi preservada; o cenário hard foi reescrito in-place para testar desalocação de compute versus custos associados. A questão de patches possui recuperação específica e não é duplicata exata. |
| `vm-scale-sets-and-availability-sets` | 5 | 2 | 2 | 1 | As cinco Questions e vinte options foram corrigidas in-place para retirar absolutos e testar escala, configuração, fault/update domains e Zones. |
| `azure-virtual-desktop` | 5 | 2 | 2 | 1 | Questões originais cobrem definição, RemoteApp, cenário empresarial, tipos de sessão e AVD versus VM/RDP. |
| `virtual-machine-resources` | 5 | 2 | 2 | 1 | Questões originais cobrem VM size, OS disk, data disk, NIC, VNet/subnet, IP privado e Public IP opcional. |
| `azure-app-service` | 5 | 2 | 2 | 1 | A Question histórica foi preservada e corrigida in-place; quatro Questions novas cobrem PaaS, responsabilidades e cenários App Service versus VM. |
| `azure-functions` | 10 | 3 | 5 | 2 | As dez Questions e quarenta opções foram preservadas e reescritas em Fundamentals: serverless, triggers, eventos, escala condicionada e escolha de compute. |
| `containers-on-azure` | 5 | 2 | 2 | 1 | Cinco Questions originais cobrem conceito, kernel compartilhado, ACI, AKS e portabilidade em cenário .NET. |
| `choosing-application-hosting` | 5 | 2 | 2 | 1 | Cinco Questions próprias, principalmente por cenário, distribuem respostas corretas entre Web Apps, containers e VMs. |
| **Total** | **51** | **19** | **22** | **10** | Todas as nove Lessons possuem pelo menos cinco Questions; o Topic Quiz seleciona uma de cada Lesson e uma segunda da primeira rodada, sem concentração em Functions ou VMs. |

Não há duplicata textual exata entre as 51 Questions. As Questions históricas de VM e App Service, omitidas das contagens intermediárias, foram preservadas. O algoritmo do Topic Quiz usa rodadas por `lesson_id`: com nove Lessons publicadas e dez vagas, seleciona pelo menos uma Question de cada Lesson e no máximo duas de uma mesma Lesson. Functions e VMs não dominam a seleção.

### Visual Experiences

Existem duas Visual Experiences `architecture` em Compute: recursos de VM em `virtual-machine-resources` e Scale Set versus Availability Set em `vm-scale-sets-and-availability-sets`.

| Conceito | Classificação | Decisão recomendada |
| --- | --- | --- |
| VM architecture/resources | Reuse | A arquitetura criada na 8.6.2 mostra VNet, subnet, NIC, VM size/compute, OS disk, data disks e Public IP opcional sem simular provisionamento. |
| VM Scale Sets vs Availability Sets | Reuse | A arquitetura criada na 8.6.3 separa escala de quantidade e distribuição por fault domains, com nota de que Zones oferecem isolamento físico maior. |
| Containers vs VMs vs Functions | Not necessary | Uma matriz textual estruturada em Content Block `important` foi usada porque a engine não possui tipo `comparison`; nenhuma interação é necessária. |
| Application hosting comparison | Not necessary | Uma matriz textual estruturada e três cenários em Content Blocks cobrem Web Apps/containers/VMs sem duplicar visual. |
| Azure Virtual Desktop | Not necessary | Explicação, cenário e exam trap atendem melhor ao nível AZ-900. |

### Inconsistências e conteúdo fora do recorte

- VM não deve ser confundida com VM Scale Set; o cenário hard mal posicionado foi reescrito sem antecipar a 8.6.3.
- Availability Set não é Availability Zone e não garante continuidade sozinho; a comparação agora está explícita em blocks, visual e prática.
- Container não é uma VM pequena: os blocks, cards e Questions agora reforçam kernel compartilhado, guest OS e portabilidade; ACI/AKS ficam em Fundamentals.
- Azure Functions é serverless orientado a eventos, não um container genérico. Premium/cold start, application settings e decomposição avançada foram retirados da prática.
- Azure App Service/Web Apps é PaaS para aplicações web e APIs, não uma VM gerenciada pelo usuário. Cards de deployment slots e runtimes foram substituídos in-place por responsabilidades e escolha de hosting.
- Azure Virtual Desktop entrega desktops/aplicativos virtualizados; a diferença para uma VM comum com RDP agora possui exam trap, card e Question de cenário.
- O card de NSG em `virtual-machine-resources` foi substituído in-place por OS disk versus data disk; Networking aprofundado continua fora do recorte.
- Menções a Storage triggers, VNet, NIC e IP são contexto válido, mas não contam como cobertura de Storage ou Networking.
- Não há Lesson, card ou Question de AI, Machine Learning ou IoT/Edge no Topic; esses temas permanecem fora do recorte adotado.

### Plano exato para 8.6.2–8.6.6

| Etapa | Lessons / slugs reais | Lacunas e prática futura | Visual |
| --- | --- | --- | --- |
| 8.6.2 — Virtual Machines + recursos necessários — concluída | `azure-virtual-machines`; `virtual-machine-resources` | 15 blocks, seis cards corrigidos in-place, uma Question reescrita e cinco Questions novas fecharam os dois objetivos sem alterar Lessons ou slugs. | Uma arquitetura simples em `virtual-machine-resources`, criada e vinculada. |
| 8.6.3 — VM Scale Sets + Availability Sets + Azure Virtual Desktop — concluída | `vm-scale-sets-and-availability-sets`; `azure-virtual-desktop` | 16 blocks, sete cards e cinco Questions corrigidos in-place, mais cinco Questions novas para AVD, fecharam os três objetivos. | Uma arquitetura VMSS/Availability Set criada; nenhum visual para AVD. |
| 8.6.4 — Containers + Functions + comparação de Compute Types — concluída | `containers-on-azure`; `azure-functions`; `comparing-compute-options` | 25 blocks, 11 cards corrigidos, 15 Questions corrigidas e 5 novas fecharam os três objetivos com comparação estruturada e prática Fundamentals. | Nenhuma Visual Experience; matriz textual em block `important`. |
| 8.6.5 — Application Hosting — concluída | `azure-app-service`; `choosing-application-hosting`; apoio conceitual sem reescrita de `containers-on-azure` e `azure-virtual-machines` | 17 blocks, quatro cards corrigidos, cinco cards novos, uma Question histórica corrigida e nove Questions novas fecharam Web Apps e application hosting. | Nenhuma Visual Experience; matriz textual e três cenários. |
| 8.6.6 — Practice + fechamento — concluída | As nove Lessons do Topic | Auditoria final confirmou 73 blocks, 34 cards, 51 Questions válidas, seleção round-robin das nove Lessons, fallback, histórico, RLS, Review e spaced repetition. Nenhuma Question ou Flashcard adicional foi necessária. | Nenhuma nova; as duas experiências justificadas foram preservadas e validadas. |

### Preservação histórica

Na 8.6.2, os dois registros de Lesson e seus slugs permaneceram intactos, assim como os UUIDs dos sete Flashcards e das cinco Questions preexistentes. Seis cards e uma Question foram corrigidos in-place; cinco Questions receberam UUIDs novos. `lessons.content` continua disponível como fallback, protegendo progress, Quiz history e spaced repetition.

Na 8.6.3, os registros e slugs das duas Lessons permaneceram intactos. Os sete Flashcards, cinco Questions e vinte Question Options preexistentes foram corrigidos in-place; somente as cinco Questions de AVD e suas options receberam UUIDs novos. Nenhum registro histórico foi excluído ou reassociado.

Na 8.6.4, os três registros de Lesson, seus slugs, 11 Flashcards, 15 Questions e 60 Question Options preexistentes permaneceram intactos. Textos foram corrigidos in-place; somente as cinco Questions de Containers e suas vinte opções receberam UUIDs novos. Nenhum Visual Experience foi criado, nenhum registro histórico foi excluído e `lessons.content` continua como fallback.

Na 8.6.5, os dois registros de Lesson e seus slugs permaneceram intactos. Os quatro Flashcards de App Service, a Question histórica `60000000-0000-4000-8000-000000000008` e suas quatro options foram corrigidos in-place. Somente cinco Flashcards de Choosing Hosting, quatro Questions adicionais de App Service, cinco Questions de Choosing Hosting e suas options receberam UUIDs novos. Nenhum histórico foi excluído ou reassociado.

**Checkpoint da Etapa 8.6.1:** auditoria concluída; 0 Lessons enriquecidas, 0 Questions ou Flashcards criados/editados e 0 Visual Experiences criadas.

**Checkpoint da Etapa 8.6.2:** `azure-virtual-machines` e `virtual-machine-resources` estão `Covered`; 15 blocks, 1 Visual Experience, 7 Flashcards preservados (6 corrigidos), 10 Questions no recorte (1 corrigida e 5 novas) e 22 minutos estimados.

**Checkpoint da Etapa 8.6.3:** VM Scale Sets, Availability Sets e Azure Virtual Desktop estão `Covered`; 16 blocks, 1 Visual Experience, 7 Flashcards corrigidos in-place, 5 Questions corrigidas in-place, 5 Questions novas e 22 minutos estimados.

**Checkpoint da Etapa 8.6.4:** Containers, Azure Functions e comparação VM/container/Function estão `Covered`; 25 blocks, 0 Visual Experiences, 11 Flashcards corrigidos in-place, 15 Questions corrigidas in-place, 5 Questions novas e 30 minutos estimados.

**Checkpoint da Etapa 8.6.5:** Azure Web Apps e Application Hosting Options estão `Covered`; 17 blocks, 0 Visual Experiences, 4 Flashcards corrigidos, 5 Flashcards novos, 1 Question corrigida, 9 Questions novas e 22 minutos estimados.

**Closure da Etapa 8.6.6 — Azure Compute Services: CLOSED.** Os 10 objetivos estão `Covered`, com 0 `Partial` e 0 `Missing`. O Topic possui 9 Lessons, 73 Content Blocks, 2 Visual Experiences, 34 Flashcards, 51 Questions (19 easy / 22 medium / 10 hard) e 96 minutos estimados. A etapa final não criou nem reescreveu conteúdo: validou cobertura, precisão, prática, round-robin do Topic Quiz, fluxo de estudo, RLS e integridade histórica.

## Domain 2 — Azure Networking Services

Auditoria realizada em 27 de agosto de 2026 para o Topic **Networking Services** do Domain **Describe Azure architecture and services (35–40%)**. O recorte segue o [guia oficial do AZ-900](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-900) e o módulo [Describe Azure networking services](https://learn.microsoft.com/en-us/training/modules/describe-azure-networking-services/): virtual networking, subnets/endpoints, VPN Gateway, ExpressRoute e Azure DNS. VNet Peering permanece explícito no currículo adotado pelo projeto e no conteúdo oficial de virtual networking.

NSG detalhado, UDR/route tables, Azure Firewall, Application Gateway, Load Balancer, NAT Gateway, Bastion, Private DNS Zones detalhadas, BGP, configuração de ExpressRoute e cálculos avançados de CIDR não contam como cobertura.

### Inventário das Lessons

O Topic `32000000-0000-4000-8000-000000000003` possui 5 Lessons publicadas, 48 Content Blocks, 3 Visual Experiences, 23 Flashcards, 30 Questions e 56 minutos estimados. Todas preservam `lessons.content` e as cinco Lessons estão `Ready`.

| # | Lesson / slug real | Min. | Blocks | Visual | Flashcards | Questions (E/M/H) | Publicada | Status | Avaliação |
| ---: | --- | ---: | ---: | --- | ---: | ---: | --- | --- | --- |
| 1 | Virtual Networks and Subnets / `virtual-networks-and-subnets` | 12 | 10 | Architecture | 8 | 5 (2/2/1) | Sim | Ready | Blocks cobrem VNet, address space conceitual, subnets, segmentação, comunicação condicionada e diferenças para Zone/Resource Group; arquitetura e prática estão alinhadas a Fundamentals. |
| 2 | VNet Peering / `vnet-peering` | 10 | 8 | Nenhum | 3 | 5 (2/2/1) | Sim | Ready | Cobre finalidade, backbone privado, VNets separadas, local/global, comunicação condicionada e Peering versus VPN/ExpressRoute, com cenários e prática Fundamentals. |
| 3 | Azure DNS / `azure-dns` | 10 | 9 | Nenhum | 3 | 10 (3/5/2) | Sim | Ready | Cobre resolução nome/endereço, Azure DNS, Public versus Private DNS, serviço gerenciado, registro de domínio, exam tip/trap e prática revisada sem TTL/TXT/migração. |
| 4 | VPN Gateway vs ExpressRoute / `vpn-gateway-vs-expressroute` | 12 | 10 | Comparison | 4 | 5 (2/2/1) | Sim | Ready | Cobre VPN Gateway, S2S/P2S, ExpressRoute via provider, caminhos público/privado, cenários e comparação condicionada, com visual acessível e prática Fundamentals. |
| 5 | Public vs Private Endpoints / `public-vs-private-endpoints` | 12 | 11 | Comparison | 5 | 5 (2/2/1) | Sim | Ready | Cobre acesso público com controles, Private Endpoint/NIC/IP privado, Private Link, coexistência pública, contraste com Service Endpoint e cenário .NET. |

Não há Lesson ausente e não se recomenda criar novos slugs. Os cinco registros existentes acomodam os oito objetivos, inclusive os pares VNet/Subnets, VPN/ExpressRoute e Public/Private Endpoints. Preservar esses registros evita quebrar progress, Quiz history, Review e spaced repetition.

### Coverage Matrix

| Objective | Lesson(s) | Content | Visual | Flashcards | Questions | Status | Notes |
| --- | --- | --- | --- | ---: | ---: | --- | --- |
| Azure Virtual Network | `virtual-networks-and-subnets` | 10 blocks + fallback | Architecture | 8 compartilhados | 5 | Covered | Define rede privada lógica, isolamento, espaço de endereços, recursos e comunicação condicionada; inclui cenário, summary, exam tip/trap e arquitetura acessível. |
| Subnets | `virtual-networks-and-subnets` | 10 blocks + fallback | Architecture | 8 compartilhados | 5 | Covered | Explica faixa contida na VNet, organização/segmentação, exemplo web/API/dados e diferenças para VNet, Zone e Resource Group sem cálculo de CIDR. |
| VNet Peering | `vnet-peering` | 8 blocks + fallback | Not necessary | 3 | 5 | Covered | Explica comunicação privada pelo backbone, VNets separadas, local/global, regras ainda aplicáveis e distinção para VPN Gateway/ExpressRoute. |
| Azure DNS | `azure-dns` | 9 blocks + fallback | Not necessary | 3 | 10 | Covered | Ensina DNS básico, hospedagem/resolução Azure, Public versus Private DNS, ausência de VM obrigatória e distinção de registrador; prática inteira revisada. |
| Azure VPN Gateway | `vpn-gateway-vs-expressroute` | 10 blocks + fallback | Comparison | 4 compartilhados | 5 | Covered | Explica túneis criptografados, Internet pública como transporte híbrido, S2S/P2S, VNet-to-VNet conceitual, cenários e traps. |
| Azure ExpressRoute | `vpn-gateway-vs-expressroute` | 10 blocks + fallback | Comparison | 4 compartilhados | 5 | Covered | Explica conexão privada via connectivity provider, ausência da Internet pública no caminho normal, previsibilidade condicionada e diferença para VPN/Peering. |
| Public Endpoints | `public-vs-private-endpoints` | 11 blocks + fallback | Comparison | 5 compartilhados | 5 | Covered | Explica conectividade pública, nome/endereço público e controles de autenticação, firewall e rede; Public não significa acesso irrestrito. |
| Private Endpoints | `public-vs-private-endpoints` | 11 blocks + fallback | Comparison | 5 compartilhados | 5 | Covered | Explica NIC em subnet, IP privado, Private Link, recurso/subresource, coexistência pública e contraste Fundamentals com Service Endpoint. |

### Resultado de cobertura

- **Covered:** 8 objetivos.
- **Partial:** 0 objetivos.
- **Missing:** 0 objetivos.
- **Lessons Ready:** 5.
- **Lessons Needs enrichment:** 0.
- **Lessons Missing:** 0.

### Auditoria de Flashcards

| Lesson | Flashcards | Avaliação |
| --- | ---: | --- |
| `virtual-networks-and-subnets` | 8 | Os 8 UUIDs foram preservados e os textos corrigidos in-place. O conjunto agora separa VNet, subnet, relação hierárquica, finalidade, comunicação condicionada, escopo regional, address space conceitual e diferenças para Zone/Resource Group. |
| `vnet-peering` | 3 | Os UUIDs foram preservados e os cards agora isolam finalidade, Peering versus VPN e local versus Global Peering; removida a impressão de que as VNets são fundidas. |
| `azure-dns` | 3 | Os UUIDs foram preservados e os cards agora cobrem função básica do DNS, Public versus Private DNS e serviço gerenciado versus VM/registrador. |
| `vpn-gateway-vs-expressroute` | 4 | Os UUIDs foram preservados e os cards agora cobrem finalidade do VPN Gateway, S2S/P2S, finalidade do ExpressRoute e escolha condicionada por caminho/requisito. |
| `public-vs-private-endpoints` | 5 | Três UUIDs foram preservados e corrigidos; dois cards curtos foram adicionados para Private Link e Service Endpoint. O conjunto elimina absolutos sobre exposição pública e alcance. |

Total: 23 Flashcards. Não há duplicata textual exata de frente nem associação a Lesson errada. Os 21 UUIDs históricos foram preservados; apenas 2 cards novos foram adicionados para conceitos que não cabiam em memória ativa curta nos cards existentes.

### Auditoria de Questions

| Lesson | Total | Easy | Medium | Hard | Avaliação |
| --- | ---: | ---: | ---: | ---: | --- |
| `virtual-networks-and-subnets` | 5 | 2 | 2 | 1 | Prática original cobre definição, relação VNet/subnet, address space conceitual, cenário .NET e comunicação condicionada, sem cálculo de CIDR. |
| `vnet-peering` | 5 | 2 | 2 | 1 | Prática original cobre finalidade, local/global, cenário VNet a VNet, comparação com VPN e comunicação condicionada. |
| `azure-dns` | 10 | 3 | 5 | 2 | Os 10 UUIDs e 40 options foram preservados e reescritos; cobrem DNS, Azure DNS, Public/Private, VM não obrigatória, domínio e cenário integrado com Peering. |
| `vpn-gateway-vs-expressroute` | 5 | 2 | 2 | 1 | Prática cobre túnel híbrido, S2S/P2S, ExpressRoute via provider, comparação explícita e cenário combinado sem regras absolutas. |
| `public-vs-private-endpoints` | 5 | 2 | 2 | 1 | Prática cobre Public Endpoint com controles, NIC/IP privado, cenário Azure SQL, Service Endpoint e coexistência do acesso público. |
| **Total** | **30** | **11** | **13** | **6** | As cinco Lessons possuem prática própria e o Topic Quiz pode distribuir questões por todo o Topic. |

Não há duplicata textual exata nem Question associada à Lesson errada. As 10 Questions de Azure DNS foram corrigidas in-place: saíram TTL, TXT, migração de provedor, redundância e distratores absurdos; entraram Public/Private DNS, serviço gerenciado, domínio e separação entre conectividade e resolução.

### Precisão conceitual e conteúdo fora do recorte

- VNet e subnet estão comparadas explicitamente: VNet é a rede lógica; subnet é uma subdivisão interna; nenhuma delas é Availability Zone.
- Peering não usa a internet pública para o tráfego entre VNets, porém não transforma VNets em uma única rede e não substitui VPN Gateway para conectividade on-premises.
- Azure DNS hospeda zonas/registros; não compra o domínio e não exige instalar uma VM com DNS Server. A prática foi revisada para DNS básico, Azure DNS e Public/Private DNS, sem exigir TTL, TXT ou migração de provedor.
- VPN Gateway usa túneis criptografados sobre a internet pública; ExpressRoute fornece conectividade privada por um connectivity provider. ExpressRoute não é “VPN pela internet” nem necessariamente uma linha física exclusiva para cada cliente.
- Public Endpoint usa endereço publicamente roteável, mas pode possuir autenticação, firewall e outros controles; “público” não significa automaticamente inseguro.
- Private Endpoint cria uma interface com IP privado na VNet para um serviço via Private Link. Criá-lo não desabilita automaticamente o acesso público do serviço, e redes conectadas podem alcançar o endereço quando DNS/routing/configuração permitem.
- Private Endpoint não é Public Endpoint protegido por firewall, VPN nem Service Endpoint; a Lesson e a prática ensinam essas distinções em nível Fundamentals.
- CIDR, regras de rede e routing aparecem apenas como contexto conceitual. BGP, UDR/route tables, configuração detalhada e demais tópicos de AZ-104 não são exigidos nas Lessons ou na prática.

### Visual Experiences

Existem 3 Visual Experiences associadas a Networking: a arquitetura de VNet/Subnets, a comparação VPN Gateway versus ExpressRoute e a comparação Public versus Private Endpoint. Peering e DNS permanecem corretamente sem visual.

| Conceito | Classificação | Decisão recomendada |
| --- | --- | --- |
| VNet + Subnets | Reuse | Arquitetura criada com VNet `10.0.0.0/16`, três subnets `/24` e recursos web/API/dados; possui descrições textuais e deixa regras de comunicação como configuração separada. |
| VNet Peering | Not necessary | A comparação textual com VPN Gateway e ExpressRoute é suficiente; a Lesson funciona sem depender do visual de outra Lesson. |
| Azure DNS | Not necessary | Explicação, resolução nome/endereço, cenário e exam trap são mais úteis que interação. |
| VPN Gateway vs ExpressRoute | Reuse | Comparison criada com caminhos conceituais, transporte, túnel VPN, implantação, custo relativo, previsibilidade e cenário; linguagem evita absolutos. |
| Public vs Private Endpoints | Reuse | Comparison criada com caminho, endereço, VNet, Internet, exposição e uso; deixa explícito que Private Endpoint não desativa sozinho o acesso público. |

### Plano exato para 8.7.2–8.7.6

| Etapa | Lessons / slugs reais | Lacunas e prática futura | Visual |
| --- | --- | --- | --- |
| 8.7.2 — Virtual Networks + Subnets (concluída) | `virtual-networks-and-subnets` | 10 blocks criados; 8 cards corrigidos in-place; 5 Questions adicionadas em 2/2/1. VNet e Subnets estão Covered. | Sim: uma arquitetura VNet + três subnets, mobile e teclado, sem simulador de CIDR. |
| 8.7.3 — VNet Peering + Azure DNS (concluída) | `vnet-peering`; `azure-dns` | 17 blocks criados; 6 cards corrigidos in-place; 5 Questions de Peering adicionadas; 10 Questions e 40 options DNS corrigidas in-place. Ambos os objetivos estão Covered. | Nenhum visual: comparações textuais são suficientes e foram validadas como `Not necessary`. |
| 8.7.4 — VPN Gateway + ExpressRoute (concluída) | `vpn-gateway-vs-expressroute` | 10 blocks criados; 4 cards corrigidos in-place; 5 Questions adicionadas em 2/2/1. VPN Gateway e ExpressRoute estão Covered. | Sim: Comparison simples dos caminhos público/túnel VPN e privado/provider. |
| 8.7.5 — Public vs Private Endpoints (concluída) | `public-vs-private-endpoints` | 11 blocks criados; 3 cards corrigidos, 2 cards adicionados e 5 Questions novas em 2/2/1. Public e Private Endpoints estão Covered. | Sim: Comparison de caminho público versus IP privado/Private Link. |
| 8.7.6 — Practice + fechamento (concluída) | As cinco Lessons do Topic | 30 Questions validadas; Topic Quiz round-robin, Lesson Quiz, Review, spaced repetition, RLS, fallback e integridade histórica cobertos pelo validador de fechamento. | Nenhum novo; os três visuais justificados nas 8.7.2, 8.7.4 e 8.7.5 foram preservados e validados. |

### Preservação histórica e checkpoint

Os cinco UUIDs e slugs de Lesson foram preservados, assim como os 21 Flashcards originais. Dois Flashcards receberam UUIDs novos. As 10 Questions de DNS e suas 40 options foram revisadas in-place; 20 Questions receberam UUIDs novos nas outras quatro Lessons. Nenhum registro histórico foi apagado e `lessons.content` permanece como fallback.

**Checkpoint da Etapa 8.7.1:** auditoria concluída; 5 Lessons encontradas, 0 Ready, 5 Needs enrichment, 0 Missing; 8 objetivos Partial, 0 Covered e 0 Missing; 0 Content Blocks, 0 Visual Experiences, 21 Flashcards, 10 Questions (3 easy / 5 medium / 2 hard) e 48 minutos estimados. Nenhum conteúdo curricular foi modificado.

**Checkpoint da Etapa 8.7.2:** `virtual-networks-and-subnets` está `Ready`; Azure Virtual Network e Subnets estão `Covered`; 10 blocks, 1 Architecture Visual Experience, 8 Flashcards preservados e corrigidos, 5 Questions novas (2 easy / 2 medium / 1 hard) e 12 minutos estimados. O Topic possui agora 2 objetivos Covered, 6 Partial e 0 Missing. Nenhum UUID histórico foi substituído.

**Checkpoint da Etapa 8.7.3:** `vnet-peering` e `azure-dns` estão `Ready`; VNet Peering e Azure DNS estão `Covered`; 17 blocks, 0 novos visuais, 6 Flashcards preservados e corrigidos, 5 Questions novas de Peering e 10 Questions/40 options DNS corrigidas in-place. O Topic possui agora 4 objetivos Covered, 4 Partial e 0 Missing, com 52 minutos estimados. Nenhum UUID histórico foi substituído.

**Checkpoint da Etapa 8.7.4:** `vpn-gateway-vs-expressroute` está `Ready`; Azure VPN Gateway e Azure ExpressRoute estão `Covered`; 10 blocks, 1 Comparison Visual Experience, 4 Flashcards preservados e corrigidos e 5 Questions novas (2 easy / 2 medium / 1 hard). O Topic possui agora 6 objetivos Covered, 2 Partial e 0 Missing, com 54 minutos estimados. Nenhum UUID histórico foi substituído.

**Checkpoint da Etapa 8.7.5:** `public-vs-private-endpoints` está `Ready`; Public Endpoint e Private Endpoint estão `Covered`; 11 blocks, 1 Comparison Visual Experience, 3 Flashcards corrigidos, 2 Flashcards novos e 5 Questions novas (2 easy / 2 medium / 1 hard). O Topic possui agora 8 objetivos Covered, 0 Partial e 0 Missing, com 56 minutos estimados. Todos os UUIDs históricos foram preservados.

**Closure da Etapa 8.7.6 — Azure Networking Services: CLOSED.** Os 8 objetivos estão `Covered`, com 0 `Partial` e 0 `Missing`. O Topic possui 5 Lessons, 48 Content Blocks, 3 Visual Experiences, 23 Flashcards, 30 Questions (11 easy / 13 medium / 6 hard) e 56 minutos estimados. A etapa final não criou nem reescreveu conteúdo curricular: consolidou a matriz e adicionou validação de cobertura, precisão, prática, round-robin do Topic Quiz, fluxo de estudo, RLS, isolamento entre usuários e integridade histórica.

## Domain 2 — Azure Storage Services

Auditoria realizada em 28 de agosto de 2026 para o Topic **Storage Services** do Domain **Describe Azure architecture and services (35–40%)**. O recorte segue o [guia oficial do AZ-900](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-900), com skills measured a partir de 20 de julho de 2026, e o módulo [Describe Azure storage services](https://learn.microsoft.com/en-us/training/modules/describe-azure-storage-services/).

O escopo inclui comparação de serviços, tiers, redundância, storage accounts, movimentação de arquivos e migração. Data Lake pode aparecer como contexto, mas analytics; lifecycle management; SAS/access keys; RBAC; encryption detalhada; immutability; object replication; NFS/SMB avançados; firewall/private endpoints; SKUs, IOPS e throughput detalhados não contam como cobertura.

### Inventário das Lessons

O Topic `32000000-0000-4000-8000-000000000004` possui 8 Lessons publicadas, 76 Content Blocks, 1 Visual Experience, 40 Flashcards, 46 Questions e 88 minutos estimados. As oito Lessons concluídas nas etapas 8.8.2–8.8.5 preservam `lessons.content` como fallback e estão `Ready`; nenhuma permanece `Needs enrichment` ou ausente.

| # | Lesson / slug real | Min. | Blocks | Visual | Flashcards | Questions (E/M/H) | Publicada | Status | Avaliação |
| ---: | --- | ---: | ---: | --- | ---: | ---: | --- | --- | --- |
| 1 | Storage Accounts and Services / `storage-accounts-and-services` | 12 | 10 | Nenhum | 5 | 5 (2/2/1) | Sim | Ready | Define account/namespace, GPv2, Blob/Files/Queue/Table, comparação dos cinco serviços, cenários, exam tip/trap e summary sem aprofundar SKUs. |
| 2 | Blob Storage / `blob-storage` | 10 | 7 | Nenhum | 4 | 5 (2/2/1) | Sim | Ready | Ensina object storage, casos de uso, hierarquia account/container/blob, cenário .NET e diferenças para Files/Disks sem blob types ou lifecycle. |
| 3 | Azure Files / `azure-files` | 10 | 7 | Nenhum | 3 | 10 (3/5/2) | Sim | Ready | Ensina file share gerenciado, SMB/NFS conceituais, comparação Blob/Files/Disks e cenários; as 10 Questions/40 options foram revisadas in-place. |
| 4 | Managed Disks / `managed-disks` | 10 | 7 | Nenhum | 3 | 5 (2/2/1) | Sim | Ready | Ensina disco persistente de VM, OS/data disks e diferenças para Files/Blob Container sem SKUs, IOPS ou performance tiers. |
| 5 | Storage Tiers / `storage-tiers` | 12 | 11 | Nenhum | 6 | 5 (2/2/1) | Sim | Ready | Cobre Hot/Cool/Cold online, Archive offline, trade-offs, reidratação, comparação, quatro cenários, Smart tier opcional, exam tip/trap e summary. |
| 6 | LRS, ZRS, GRS and GZRS / `storage-redundancy-options` | 12 | 14 | Architecture | 8 | 6 (2/2/2) | Sim | Ready | Cobre LRS/ZRS/GRS/RA-GRS/GZRS/RA-GZRS, alcance das falhas, replicação síncrona/assíncrona, leitura secundária, failover condicionado, cenários, exam tip/trap e summary. |
| 7 | Moving Files with AzCopy, Storage Explorer and File Sync / `moving-files-to-azure` | 12 | 10 | Nenhum | 6 | 5 (2/2/1) | Sim | Ready | Compara AzCopy CLI, Storage Explorer GUI e File Sync híbrido; inclui Azure Files central, Windows Server como cache, cenários, exam tip/trap e summary. |
| 8 | Azure Migrate and Azure Data Box / `azure-migrate-and-data-box` | 10 | 10 | Nenhum | 5 | 5 (2/2/1) | Sim | Ready | Distingue assessment/planejamento/migração de workloads e transporte físico de dados, com comparação, cenários, exam tip/trap e summary. |

Não se recomenda criar novas Lessons ou slugs. Queue Storage e Table Storage cabem na Lesson `storage-accounts-and-services`; tiers e redundância já possuem Lessons próprias; movimentação e migração estão corretamente agrupadas em pares/trios conceituais.

### Coverage Matrix

| Objective | Lesson(s) | Content | Visual | Flashcards | Questions | Status | Notes |
| --- | --- | --- | --- | ---: | ---: | --- | --- |
| Compare Azure Storage Services | `storage-accounts-and-services`; apoio das Lessons específicas | 10 blocks comparativos + apoio | Not necessary | 15 distribuídos em quatro Lessons | 25 distribuídas | Covered | Tabela, cenários, cards e Questions comparam Blob, Files, Queue, Table e Managed Disks por dado, acesso e uso. |
| Blob Storage | `blob-storage`; `storage-accounts-and-services` | 7 blocks + apoio | Not necessary | 4 | 5 | Covered | Object storage, dados não estruturados, hierarquia account/container/blob, cenário .NET, comparação, exam tip/trap e summary estão explícitos. |
| Azure Files | `azure-files`; `storage-accounts-and-services` | 7 blocks + apoio | Not necessary | 3 | 10 | Covered | File share gerenciado, protocolos conceituais, cenários e diferenças para Blob/Disks possuem conteúdo e prática revisada. |
| Queue Storage | `storage-accounts-and-services` | 2 blocks dedicados + comparação | Not necessary | 1 dedicado + comparação | 3 relevantes | Covered | Mensagens assíncronas simples, API→Queue→worker e distinção para Service Bus estão explícitos. |
| Table Storage | `storage-accounts-and-services` | 2 blocks dedicados + comparação | Not necessary | 1 dedicado + comparação | 3 relevantes | Covered | NoSQL chave/atributo, cenário, distinção para SQL e prática estão explícitos sem partition key design. |
| Managed Disks | `managed-disks`; `storage-accounts-and-services` | 7 blocks + apoio | Not necessary | 3 | 5 | Covered | Disco persistente de VM, OS/data disks e diferenças para Files/Blob têm conteúdo, cenários e prática 2/2/1. |
| Storage Tiers | `storage-tiers` | 11 blocks + fallback | Not necessary | 6 | 5 | Covered | Hot/Cool/Cold/Archive, online/offline, custo relativo, frequência, reidratação, comparação, cenários, exam tip/trap e summary possuem prática 2/2/1. |
| Storage Redundancy | `storage-redundancy-options` | 14 blocks + fallback | Architecture | 8 | 6 (2/2/2) | Covered | Comparação explícita de LRS/ZRS/GRS/RA-GRS/GZRS/RA-GZRS, alcance local/zonal/geográfico, secundária assíncrona, leitura apenas nas variantes RA e failover condicionado possuem conteúdo e prática. |
| Storage Account options/types | `storage-accounts-and-services` | 10 blocks + fallback | Not necessary | 5 | 5 | Covered | Finalidade, namespace, GPv2, serviços suportados, características da conta e distinção account/container/disk estão explícitos. |
| AzCopy | `moving-files-to-azure` | 5 blocks relevantes + fallback | Not necessary | 3 relevantes | 4 relevantes | Covered | CLI para copiar dados de/para/entre Azure Storage, blobs/files, automação, cenários e diferença para sincronização e migração estão explícitos. |
| Azure Storage Explorer | `moving-files-to-azure` | 4 blocks relevantes + fallback | Not necessary | 1 dedicado + comparação | 3 relevantes | Covered | Aplicação gráfica para visualizar e gerenciar recursos e dados suportados de Azure Storage, sem tutorial de menus. |
| Azure File Sync | `moving-files-to-azure`; apoio em `azure-files` | 6 blocks relevantes + fallback | Not necessary | 3 relevantes | 3 relevantes | Covered | Azure Files central, Windows Server sincronizado/cache local, cenário híbrido, cloud tiering conceitual e diferença para AzCopy possuem prática. |
| Azure Migrate | `azure-migrate-and-data-box` | 7 blocks relevantes + fallback | Not necessary | 3 relevantes | 4 relevantes | Covered | Descoberta, assessment de readiness/custo, planejamento e migração de workloads suportados possuem comparação, cenário e prática. |
| Azure Data Box | `azure-migrate-and-data-box` | 6 blocks relevantes + fallback | Not necessary | 3 relevantes | 4 relevantes | Covered | Dispositivo físico para grande volume quando a rede é limitada/impraticável, fluxo conceitual e diferença para Migrate possuem prática. |
| File Movement Options | `moving-files-to-azure` | 10 blocks + fallback | Not necessary | 6 | 5 (2/2/1) | Covered | Comparação CLI/GUI/sincronização, três cenários, exam tip/trap, summary e prática diferenciam AzCopy, Storage Explorer e File Sync. |
| Migration Options | `azure-migrate-and-data-box` | 10 blocks + fallback | Not necessary | 5 | 5 (2/2/1) | Covered | Comparação assessment/migração versus transporte físico, cenários, exam tip/trap, summary e prática diferenciam Migrate e Data Box. |

Os 16 objetivos solicitados no fechamento estão `Covered`: 14 objetivos atômicos e 2 agrupamentos comparativos. Os agrupamentos consolidam os objetivos relacionados e são contabilizados separadamente apenas neste checkpoint final.

### Resultado de cobertura

- **Covered:** 16 objetivos (14 atômicos + 2 agrupamentos).
- **Partial:** 0 objetivos.
- **Missing:** 0 objetivos.
- **Lessons Ready:** 8.
- **Lessons Needs enrichment:** 0.
- **Lessons Missing:** 0.

### Auditoria de Flashcards

| Lesson | Flashcards | Avaliação |
| --- | ---: | --- |
| `storage-accounts-and-services` | 5 | Corrigidos in-place para account, GPv2, Queue, Table e account versus container; removidos SKUs, Networking e a associação imprecisa de Managed Disks à conta. |
| `blob-storage` | 4 | Corrigidos in-place para definição, hierarquia, Blob versus Files e cenário de imagens; removidos blob types e tiers, que pertencem à 8.8.3. |
| `azure-files` | 3 | Corrigidos in-place para definição, cenário de file share e Azure Files versus Managed Disk; removida a repetição semântica. |
| `managed-disks` | 3 | Corrigidos in-place para definição, OS/data disks e recurso gerenciado versus blob comum; removidos unmanaged disks e lista de SKUs. |
| `storage-tiers` | 6 | Cards novos cobrem Hot, Cool, Cold versus Archive, Archive, trade-off e Archive versus backup sem preços ou regras de lifecycle. |
| `storage-redundancy-options` | 8 | Três cards históricos corrigidos in-place e cinco novos cobrem LRS, ZRS, GRS, GZRS, variantes RA, leitura secundária e a diferença entre redundância e failover automático. |
| `moving-files-to-azure` | 6 | Cards novos cobrem AzCopy, Storage Explorer, File Sync, CLI versus GUI, cópia versus sincronização e cenário híbrido. |
| `azure-migrate-and-data-box` | 5 | Cards novos cobrem Migrate, Data Box, readiness, rede limitada e workload assessment versus transporte físico. |

Total: 40 Flashcards. Os 15 cards do recorte 8.8.2 e os 3 cards históricos de redundância preservaram UUIDs e foram corrigidos in-place; 22 cards novos foram adicionados nas etapas 8.8.3–8.8.5. Não há duplicata exata, associação errada ou detalhe avançado nas oito Lessons.

### Auditoria de Questions

| Lesson | Total | Easy | Medium | Hard | Avaliação |
| --- | ---: | ---: | ---: | ---: | --- |
| `storage-accounts-and-services` | 5 | 2 | 2 | 1 | Prática nova cobre account, GPv2, Queue, Table e cenário comparativo sem detalhes de SKU. |
| `blob-storage` | 5 | 2 | 2 | 1 | Prática nova cobre object storage, imagens, hierarquia e comparação por cenário. |
| `azure-files` | 10 | 3 | 5 | 2 | Os 10 UUIDs e 40 options foram preservados e reescritos; distratores plausíveis e cenários cobrem Files versus Blob/Disks sem backup ou File Sync. |
| `managed-disks` | 5 | 2 | 2 | 1 | Prática nova cobre disco de VM, OS/data disks e comparação com Blob/Files. |
| `storage-tiers` | 5 | 2 | 2 | 1 | Prática nova diferencia os quatro tiers com cenários inequívocos, online/offline, reidratação e trade-off. |
| `storage-redundancy-options` | 6 | 2 | 2 | 2 | A Question histórica sobre GZRS foi preservada; cinco novas cobrem LRS, ZRS, RA-GRS, RA-GZRS e recuperação regional com distratores plausíveis. |
| `moving-files-to-azure` | 5 | 2 | 2 | 1 | Prática nova diferencia CLI, GUI e sincronização híbrida com cenários e distratores plausíveis. |
| `azure-migrate-and-data-box` | 5 | 2 | 2 | 1 | Prática nova diferencia assessment/migração de workloads e transporte físico de grande volume. |
| **Total** | **46** | **17** | **19** | **10** | Todas as oito Lessons possuem Lesson Quiz útil; o Topic Quiz round-robin inclui as oito Lessons e limita cada uma a no máximo duas Questions por tentativa de dez. |

Não há Question textual exatamente duplicada nem associação à Lesson errada. As 10 Questions e 40 options de Azure Files foram corrigidas in-place; 35 Questions e 140 options novas foram adicionadas às sete Lessons inicialmente sem prática suficiente. A Question e as quatro options históricas de redundância permanecem intactas.

### Precisão conceitual e conteúdo fora do recorte

- Blob Storage é object storage para dados não estruturados; Azure Files é file share gerenciado. A distinção possui comparação estruturada, cenário, cards e Questions.
- Azure Files não é Managed Disk: Files atende compartilhamento de arquivos; Managed Disk fornece block storage persistente para VMs. Blocks, cards e Questions consolidam a diferença.
- Queue Storage não é equivalente ao Service Bus, e Table Storage não é SQL Database. Conteúdo comparativo, cenários e prática previnem essas confusões sem aprofundar arquitetura de mensageria ou bancos relacionais.
- Archive é tier offline e exige reidratação antes da leitura; não é backup automático. Cold permanece online. Essas distinções agora estão explícitas em blocks, cards e Questions.
- LRS protege cópias dentro de um datacenter; ZRS usa zonas na região primária; GRS/GZRS replicam de forma assíncrona para uma secundária. RA-GRS/RA-GZRS acrescentam leitura, não escrita normal, e redundância geográfica não garante troca automática da aplicação. Essas diferenças agora estão explícitas.
- Storage Account é o recurso comum que expõe serviços como Blob, Files, Queue e Table, não um único blob container. Managed Disks abstraem a infraestrutura subjacente e não devem ser ensinados como objetos armazenados pelo aluno dentro da mesma conta general-purpose.
- Azure File Sync mantém uma relação híbrida com Azure Files; AzCopy realiza transferências por CLI e Storage Explorer oferece gestão gráfica. Comparação, cenários e prática agora impedem confundir cópia com sincronização contínua.
- Azure Migrate apoia descoberta, avaliação, planejamento e migração de workloads; Data Box resolve transferência física de grande volume quando a rede não é prática. Comparação, cenários e prática agora distinguem os dois.
- Detalhes de comandos, endpoints do File Sync, appliances, replicação, ondas de migração, capacidades exatas e logística de Data Box foram mantidos fora do conteúdo Fundamentals.

### Visual Experiences

Existe 1 Visual Experience associada ao Topic de Storage.

| Conceito | Classificação | Decisão recomendada |
| --- | --- | --- |
| Storage Services Comparison | Not necessary | Uma matriz/comparison em Content Block é suficiente para Blob, Files, Queue, Table e Managed Disks; não criar interação. |
| Storage Tiers | Not necessary | Comparison block com frequência, custo relativo e disponibilidade é suficiente. |
| Storage Redundancy | Reuse | Uma única Architecture Visual Experience compara LRS, ZRS, GRS/RA-GRS e GZRS/RA-GZRS, separando alcance, replicação assíncrona e leitura RA sem números de durabilidade ou promessa universal de failover. |
| File Movement | Not necessary | Comparação textual por CLI, GUI e sincronização híbrida é mais direta. |
| Migration | Not necessary | Dois cenários contrastando avaliação/migração e transferência física são suficientes. |

### Plano exato para 8.8.2–8.8.6

| Etapa | Lessons / slugs reais | Lacunas e prática futura | Visual |
| --- | --- | --- | --- |
| 8.8.2 — Storage Accounts + Storage Services (concluída) | `storage-accounts-and-services`; `blob-storage`; `azure-files`; `managed-disks` | 31 blocks criados; comparação Blob/Files/Queue/Table/Disks; 15 cards e 10 Questions/40 options corrigidos in-place; 15 Questions/60 options adicionadas. | Nenhuma Visual Experience; comparison block foi suficiente. |
| 8.8.3 — Storage Tiers (concluída) | `storage-tiers` | 11 blocks, 6 cards e 5 Questions/20 options criados; Hot/Cool/Cold/Archive, online/offline, reidratação e trade-offs estão Covered. Smart tier ficou como nota opcional. | Nenhuma; comparison block foi suficiente. |
| 8.8.4 — Storage Redundancy (concluída) | `storage-redundancy-options` | 14 blocks, 3 cards corrigidos in-place, 5 cards novos e 5 Questions/20 options novas; a Question e as options históricas foram preservadas. | 1 Architecture Visual Experience criada e validada. |
| 8.8.5 — File Movement + Migration (concluída) | `moving-files-to-azure`; `azure-migrate-and-data-box` | 20 blocks, 11 cards e 10 Questions/40 options criados; CLI/GUI/sync híbrido e workload migration/transporte offline agora possuem comparação e cenários. | Nenhuma; comparison blocks foram suficientes. |
| 8.8.6 — Practice + fechamento (concluída) | As oito Lessons do Topic | Auditoria final de 76 blocks, 40 cards e 46 Questions; Topic Quiz round-robin, Lesson Quiz, Review, spaced repetition, progress, RLS, isolamento e integridade histórica consolidados em validator transacional. Nenhum conteúdo novo foi necessário. | Nenhum novo; o único visual de redundância foi preservado e validado. |

### Preservação histórica e checkpoint

Os oito registros e slugs de Lesson trabalhados nas etapas 8.8.2–8.8.5 permaneceram intactos. Os 15 Flashcards do recorte 8.8.2, os 3 Flashcards de redundância, as 10 Questions de Azure Files e suas 40 options foram corrigidos in-place; 35 Questions/140 options, 22 Flashcards e 1 Visual Experience receberam UUIDs novos. A Question e as quatro options históricas de redundância permaneceram intactas. Nenhum registro de prática foi excluído ou reassociado, `lessons.content` continua como fallback e progress, Quiz history, Review e spaced repetition permanecem preservados.

**Checkpoint da Etapa 8.8.1:** auditoria concluída; 8 Lessons encontradas, 0 Ready, 8 Needs enrichment, 0 Missing; 14 objetivos Partial, 0 Covered e 0 Missing; 0 Content Blocks, 0 Visual Experiences, 18 Flashcards, 11 Questions (3 easy / 5 medium / 3 hard) e 78 minutos estimados. Nenhum conteúdo curricular ou dado de prática foi modificado.

**Checkpoint da Etapa 8.8.2:** Storage Account options/types, comparação dos serviços, Blob, Azure Files, Queue, Table e Managed Disks estão `Covered`; 31 blocks, 0 Visual Experiences, 15 Flashcards corrigidos in-place, 10 Questions/40 options corrigidas in-place e 15 Questions/60 options novas. O Topic possui agora 7 objetivos Covered, 7 Partial e 0 Missing, com 26 Questions (9 easy / 11 medium / 6 hard) e 86 minutos estimados. Nenhum UUID histórico foi substituído.

**Checkpoint da Etapa 8.8.3:** Storage Tiers está `Covered`; 11 blocks, 0 Visual Experiences, 6 Flashcards novos e 5 Questions/20 options novas em distribuição 2 easy / 2 medium / 1 hard. O Topic possui agora 8 objetivos Covered, 6 Partial e 0 Missing, com 42 blocks, 24 Flashcards, 31 Questions (11 easy / 13 medium / 7 hard) e 88 minutos estimados. Nenhum UUID histórico foi alterado.

**Checkpoint da Etapa 8.8.4:** Storage Redundancy está `Covered`; 14 blocks, 1 Architecture Visual Experience, 3 Flashcards corrigidos in-place, 5 Flashcards novos e 5 Questions/20 options novas. A prática total da Lesson é 2 easy / 2 medium / 2 hard. O Topic possui agora 9 objetivos Covered, 5 Partial e 0 Missing, com 56 blocks, 1 visual, 29 Flashcards, 36 Questions (13 easy / 15 medium / 8 hard) e 88 minutos estimados. A Question, as quatro options, todos os registros e slugs históricos foram preservados.

**Checkpoint da Etapa 8.8.5:** AzCopy, Azure Storage Explorer, Azure File Sync, Azure Migrate e Azure Data Box estão `Covered`; os agrupamentos File Movement Options e Migration Options também possuem finalidade, comparação, cenário, exam tip/trap, summary, cards e Questions. Foram criados 20 blocks, 11 Flashcards e 10 Questions/40 options em distribuição 4 easy / 4 medium / 2 hard, sem Visual Experience. O Topic possui agora 14 objetivos Covered, 0 Partial e 0 Missing, com 76 blocks, 1 visual, 40 Flashcards, 46 Questions (17 easy / 19 medium / 10 hard) e 88 minutos estimados. Todos os UUIDs e slugs históricos foram preservados.

**Closure da Etapa 8.8.6 — Azure Storage Services: CLOSED.** Os 16 objetivos auditados estão `Covered` (14 atômicos + File Movement Options + Migration Options), com 0 `Partial` e 0 `Missing`. O Topic possui 8 Lessons, 76 Content Blocks, 1 Architecture Visual Experience, 40 Flashcards, 46 Questions (17 easy / 19 medium / 10 hard) e 88 minutos estimados. A etapa final não criou nem reescreveu conteúdo curricular: consolidou cobertura, precisão, escopo AZ-900, summaries, ordem, fallback, prática, Topic Quiz round-robin, Lesson Quiz, Review, spaced repetition, progress, RLS, isolamento entre usuários e integridade histórica no validador `supabase/tests/validate_az900_storage_services_closure.sql`.

## Domain 2 — Azure Identity, Access and Security

Auditoria realizada em 28 de agosto de 2026 para o Topic **Identity, Access and Security** do Domain **Describe Azure architecture and services (35–40%)**. O recorte segue o [guia oficial do AZ-900](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-900) e o módulo [Describe Azure identity, access, and security](https://learn.microsoft.com/en-us/training/modules/describe-azure-identity-access-security/).

O escopo desta auditoria inclui Microsoft Entra ID, Microsoft Entra Domain Services, SSO, MFA, passwordless, identidades externas/guest, Conditional Access, Azure RBAC, Zero Trust, defesa em profundidade e Microsoft Defender for Cloud. Autenticação versus autorização é uma Lesson de apoio já existente. Detalhes operacionais de PIM, Identity Protection, access reviews, entitlement management, protocolos de federação, criação de custom roles, planos/licenciamento do Defender, Microsoft Sentinel, criptografia e Key Vault não contam como cobertura deste recorte.

### Inventário das Lessons

O Topic `32000000-0000-4000-8000-000000000005` possui 9 Lessons publicadas, 105 Content Blocks, 3 Visual Experiences, 49 Flashcards, 50 Questions e 100 minutos estimados. As nove Lessons estão `Ready`, publicadas e preservam `lessons.content` como fallback.

| # | Lesson / slug real | Min. | Blocks | Visual | Flashcards | Questions (E/M/H) | Publicada | Status | Avaliação |
| ---: | --- | ---: | ---: | --- | ---: | ---: | --- | --- | --- |
| 1 | Microsoft Entra ID and Domain Services / `entra-id-and-domain-services` | 12 | 15 | Flow reutilizado | 7 | 5 (2/2/1) | Sim | Ready | Ensina cloud IAM, objetos, tenant, identity/authentication/authorization, managed domain, protocolos tradicionais, cenário legado, comparação, exam tips/traps e summary. |
| 2 | Authentication vs Authorization / `authentication-vs-authorization` | 8 | 8 | Nenhum | 3 | 10 (3/5/2) | Sim | Ready | Consolida quem é versus o que pode fazer, login sem permissão, relação com MFA/Conditional Access/RBAC, comparação, cenário, tip/trap e summary. As 10 Questions históricas foram corrigidas in-place. |
| 3 | Single Sign-On / `single-sign-on` | 8 | 8 | Nenhum | 4 | 5 (2/2/1) | Sim | Ready | Cobre conceito, benefícios, integração com Entra ID, cenário, reutilização de senha, SSO versus MFA, autorização, exam tip/traps e summary. |
| 4 | Multi-Factor Authentication and Passwordless / `mfa-and-passwordless` | 12 | 13 | Nenhum | 7 | 5 (2/2/1) | Sim | Ready | Ensina categorias de fatores, fatores independentes, métodos passwordless atuais, comparação SSO/MFA/Passwordless, cenários, traps e summary. |
| 5 | External Identities / `external-identities` | 10 | 10 | Nenhum | 5 | 5 (2/2/1) | Sim | Ready | Cobre colaboração B2B, home/resource tenant, guest/external user, identidade de origem, acesso limitado, cenários, exam tip/traps e summary. |
| 6 | Conditional Access / `conditional-access` | 12 | 11 | Nenhum | 5 | 5 (2/2/1) | Sim | Ready | Ensina sinais, if-then, decisões, MFA como controle possível, comparação Authentication/Conditional Access/RBAC, cenários, exam tip/traps e summary. |
| 7 | Azure Role-Based Access Control (RBAC) / `azure-rbac` | 12 | 14 | Architecture | 6 | 5 (2/2/1) | Sim | Ready | Cobre autorização, security principals, role definitions, quatro scopes, herança, role assignment, menor scope, comparação, visual, prática e summary. |
| 8 | Zero Trust and Defense in Depth / `zero-trust-and-defense-in-depth` | 14 | 15 | Architecture | 7 | 5 (2/2/1) | Sim | Ready | Ensina Zero Trust como estratégia, seus três princípios, confiança não implícita, conexão com controles já estudados, Defense in Depth, sete camadas, comparação, visual, cenários, traps e summary. |
| 9 | Microsoft Defender for Cloud / `defender-for-cloud` | 12 | 11 | Nenhum | 5 | 5 (2/2/1) | Sim | Ready | Cobre security posture, recomendações, secure score, workload protection, responsabilidade e distinções de Defender Antivirus e Microsoft Sentinel em nível Fundamentals. |

Não se recomenda criar novas Lessons ou slugs. Os nove registros existentes cobrem a decomposição pedagógica necessária e devem ser enriquecidos in-place para preservar histórico.

### Coverage Matrix

| Objective | Lesson(s) | Content | Visual | Flashcards | Questions | Status | Notes |
| --- | --- | --- | --- | ---: | ---: | --- | --- |
| Microsoft Entra ID | `entra-id-and-domain-services` | 15 blocks compartilhados + fallback | Flow reutilizado | 6 relevantes | 4 relevantes | Covered | Cloud IAM, users/groups/applications/devices, tenant, tenant versus subscription, identity/authentication/authorization, cenário moderno, traps e summary estão explícitos e praticados. |
| Microsoft Entra Domain Services | `entra-id-and-domain-services` | 15 blocks compartilhados + fallback | Flow contextual de Entra ID | 4 relevantes | 3 relevantes | Covered | Managed domain, domain join, Group Policy, LDAP, Kerberos/NTLM, domain controllers gerenciados, cenário legado e comparação com Entra ID possuem conteúdo e prática. |
| Single Sign-On (SSO) | `single-sign-on` | 8 blocks + fallback | Not necessary | 4 | 5 (2/2/1) | Covered | Conceito, benefícios, integração centralizada, cenários e traps distinguem SSO de senha reutilizada, MFA e ausência de autenticação. |
| Multi-Factor Authentication (MFA) | `mfa-and-passwordless`; apoio em `authentication-vs-authorization` | 13 blocks compartilhados + fallback | Not necessary | 4 relevantes | 4 relevantes | Covered | Dois ou mais fatores independentes, know/have/are, duas senhas, MFA versus SSO e distinção contextual de Conditional Access possuem prática. |
| Passwordless authentication | `mfa-and-passwordless` | 13 blocks compartilhados + fallback | Not necessary | 4 relevantes | 3 relevantes | Covered | Conceito correto, passkeys/FIDO2, Windows Hello for Business, Authenticator passwordless, verificação de identidade e comparação com SSO/MFA estão explícitos. |
| External identities / guest access | `external-identities` | 10 blocks + fallback | Not necessary | 5 | 5 (2/2/1) | Covered | Colaboração B2B, home/resource tenant, guest/external user, identidade de origem, acesso limitado e cenário Contoso/Fabrikam possuem prática. |
| Conditional Access | `conditional-access` | 11 blocks + fallback | Not necessary | 5 | 5 (2/2/1) | Covered | Sinais, if-then, allow/block/controle adicional, MFA como possível controle e comparação com MFA/RBAC possuem cenários e prática. |
| Azure RBAC | `azure-rbac`; apoio em `authentication-vs-authorization` | 14 blocks + fallback | Architecture | 6 | 5 (2/2/1) | Covered | Authorization, security principal, role definition, scope, role assignment, hierarchy, herança, menor scope e comparação possuem prática e visual. |
| Zero Trust | `zero-trust-and-defense-in-depth` | 15 blocks compartilhados + fallback | Not necessary | 6 relevantes | 4 relevantes | Covered | Estratégia, verify explicitly, least privilege, assume breach, ausência de confiança implícita, controles complementares e traps possuem conteúdo e prática. |
| Defense in Depth | `zero-trust-and-defense-in-depth` | 15 blocks compartilhados + fallback | Architecture | 3 relevantes | 3 relevantes | Covered | Múltiplas camadas, finalidade, sete camadas conceituais, falha de um controle, comparação com Zero Trust e visual possuem cenários e prática. |
| Microsoft Defender for Cloud | `defender-for-cloud` | 11 blocks + fallback | Not necessary | 5 | 5 (2/2/1) | Covered | Security posture, recomendações, secure score, workload protection, limites, responsabilidade e distinções de antivírus/Sentinel estão explícitos e praticados. |

### Resultado de cobertura

- **Covered:** 11 objetivos.
- **Partial:** 0 objetivos.
- **Missing:** 0 objetivos.
- **Lessons Ready:** 9.
- **Lessons Needs enrichment:** 0.
- **Lessons Missing:** 0.

### Auditoria de Flashcards

| Lesson | Flashcards | Avaliação |
| --- | ---: | --- |
| `entra-id-and-domain-services` | 7 | Três UUIDs históricos corrigidos in-place e quatro cards novos cobrem finalidade do Entra ID, Entra versus Domain Services, cenário legado, tenant, tenant versus subscription, identity/authentication/authorization e gerenciamento dos domain controllers. |
| `authentication-vs-authorization` | 3 | Cards novos cobrem authentication, authorization e a armadilha “autenticado não significa autorizado”. |
| `single-sign-on` | 4 | Cards novos cobrem finalidade, senha reutilizada, autenticação preservada e SSO versus MFA. |
| `mfa-and-passwordless` | 7 | Cards novos cobrem MFA, categorias, duas senhas, passwordless, métodos atuais, verificação de identidade e combinação dos três conceitos. |
| `external-identities` | 5 | Cards novos cobrem B2B, home tenant, resource tenant, limites de guest e externo versus interno. |
| `conditional-access` | 5 | Cards novos cobrem definição, if-then, Conditional Access versus MFA, sinais e diferença para RBAC. |
| `azure-rbac` | 6 | Três UUIDs históricos corrigidos in-place e três cards novos cobrem finalidade, role assignment, herança, principals, scope hierarchy e comparação dos controles. |
| `zero-trust-and-defense-in-depth` | 7 | Cards novos cobrem estratégia, três princípios, verify explicitly, least privilege, assume breach, Defense in Depth e comparação. |
| `defender-for-cloud` | 5 | Cards novos cobrem postura, recomendações, secure score, workload protection e distinção de antivírus. |

Total: 49 Flashcards. A 8.9.6 adicionou somente 3 cards para a lacuna de memória ativa da Lesson de apoio. Não há duplicata exata nem Lesson sem Flashcards.

### Auditoria de Questions

| Lesson | Total | Easy | Medium | Hard | Avaliação |
| --- | ---: | ---: | ---: | ---: | --- |
| `entra-id-and-domain-services` | 5 | 2 | 2 | 1 | Prática nova cobre cloud IAM, tenant versus subscription, cenário SaaS moderno, workload legado e coexistência Entra ID/Domain Services. |
| `authentication-vs-authorization` | 10 | 3 | 5 | 2 | Dez UUIDs históricos preservados e conteúdo corrigido in-place para definições, fluxo, login sem permissão, MFA, autorização, least privilege, Conditional Access versus RBAC e cenários combinados. |
| `single-sign-on` | 5 | 2 | 2 | 1 | Prática nova cobre conceito, senha reutilizada, cenário integrado, SSO versus MFA e SSO sem acesso irrestrito. |
| `mfa-and-passwordless` | 5 | 2 | 2 | 1 | Prática nova cobre fatores, passkey, duas senhas, cenário passwordless e combinação SSO/MFA/Passwordless. |
| `external-identities` | 5 | 2 | 2 | 1 | Prática nova cobre B2B, resource tenant, cenário Contoso/Fabrikam, guest e home/resource tenant. |
| `conditional-access` | 5 | 2 | 2 | 1 | Prática nova cobre definição, if-then, MFA condicional, bloqueio por sinais e comparação Authentication/Conditional Access/RBAC. |
| `azure-rbac` | 5 | 2 | 2 | 1 | A Question histórica Reader/Resource Group foi preservada; quatro novas cobrem finalidade, elementos da assignment, managed identity e menor scope. |
| `zero-trust-and-defense-in-depth` | 5 | 2 | 2 | 1 | Prática nova cobre os três princípios, confiança não implícita, least privilege, camadas e uso conjunto das estratégias. |
| `defender-for-cloud` | 5 | 2 | 2 | 1 | Prática nova cobre dois focos, recomendações, postura, workload protection e classificação de cenários. |
| **Total** | **50** | **19** | **21** | **10** | As nove Lessons possuem Questions e participam do Topic Quiz round-robin. |

Não há Question textual exatamente duplicada nem associação quebrada. A 8.9.6 removeu a repetição semântica excessiva e os distratores frágeis das 10 Questions históricas de autenticação/autorização, mantendo seus UUIDs, difficulty e associações. Nenhuma Question exige configuração ou administração avançada fora do escopo AZ-900.

### Precisão conceitual e riscos de conteúdo

- Microsoft Entra ID não deve ser ensinado como Active Directory Domain Services hospedado. Microsoft Entra Domain Services fornece recursos de domínio gerenciados para necessidades compatíveis/legadas, sem o cliente administrar controladores de domínio.
- SSO reduz prompts de autenticação entre aplicações confiáveis, mas não elimina autorização, Conditional Access ou necessidade de proteger a sessão.
- MFA combina fatores de categorias diferentes; duas senhas não constituem MFA. Passwordless remove a senha do fluxo, mas não é sinônimo automático de MFA ou de segurança absoluta.
- External Identities não significa acesso irrestrito: convidados continuam sujeitos a autenticação, autorização, políticas, menor privilégio e revisão.
- Conditional Access toma decisões a partir de sinais e controles; não substitui autenticação, RBAC ou todas as demais camadas de segurança.
- Azure RBAC é autorização sobre recursos Azure por identidade, função e escopo. Não autentica usuários e não é sinônimo de Conditional Access.
- Zero Trust é uma estratégia guiada por princípios; Defense in Depth organiza controles em camadas. Nenhum dos dois garante ausência de incidentes.
- Defender for Cloud melhora postura e proteção de workloads, mas não torna o ambiente automaticamente seguro nem substitui operação e responsabilidade do cliente.
- O fallback atual não contém erro factual crítico. As lacunas são principalmente profundidade, estrutura pedagógica, prática e comparação; portanto nenhuma correção curricular foi aplicada nesta auditoria.

### Visual Experiences

Existem 3 Visual Experiences associadas ao Topic, publicadas e com configurações válidas: o flow de Entra ID e duas arquiteturas para Azure RBAC e Defense in Depth.

| Conceito | Classificação | Decisão recomendada |
| --- | --- | --- |
| Fluxo de autenticação com Microsoft Entra ID | Reuse | O flow `Usuário → Entrar → Microsoft Entra ID → Token → Aplicação` foi preservado e contextualiza identidade/autenticação. |
| SSO, MFA, Passwordless e External Identities | Not necessary | Comparações e cenários em Content Blocks são mais úteis que interações separadas. |
| Conditional Access | Not necessary | O fluxo `Signal → Policy → Decision` e cenários if-then foram implementados em Content Blocks; um segundo visual não acrescentaria valor proporcional. |
| Azure RBAC | Reuse | Uma Architecture Visual Experience mostra `Security Principal + Role Definition + Scope → Role Assignment → Azure Resources`, com nodes acessíveis e layout horizontal responsivo. |
| Zero Trust | Not necessary | Os três princípios cabem em explanation/comparison; uma experiência separada duplicaria a Lesson combinada. |
| Defense in Depth | Reuse | Uma Architecture Visual Experience apresenta sete camadas selecionáveis, de Physical a Data, com descrições curtas, navegação acessível e layout responsivo. |
| Microsoft Defender for Cloud | Not necessary | Conteúdo estruturado, comparação postura/proteção e cenários são suficientes em Fundamentals. |

### Plano exato para 8.9.2–8.9.6

| Etapa | Lessons / slugs reais | Lacunas e prática futura | Visual |
| --- | --- | --- | --- |
| 8.9.2 — Microsoft Entra ID + Domain Services (concluída) | `entra-id-and-domain-services` | 15 blocks; 3 cards corrigidos in-place, 4 cards novos e 5 Questions/20 options novas em 2/2/1. Microsoft Entra ID e Domain Services estão Covered. | Flow existente reutilizado e ligado à Lesson; nenhuma Visual Experience criada. |
| 8.9.3 — SSO, MFA, Passwordless + External Identities (concluída) | `single-sign-on`; `mfa-and-passwordless`; `external-identities` | 31 blocks, 16 cards e 15 Questions/60 options novas em três distribuições 2/2/1. As 10 Questions históricas de `authentication-vs-authorization` foram auditadas e permaneceram intactas por estarem associadas a outro objetivo. | Nenhuma Visual Experience; comparisons e cenários foram suficientes. |
| 8.9.4 — Conditional Access + Azure RBAC (concluída) | `conditional-access`; `azure-rbac` | 25 blocks, 3 cards históricos corrigidos, 8 cards novos, 1 Question histórica preservada e 9 Questions/36 options novas. Ambas as Lessons possuem prática 2/2/1. | Uma Architecture Visual Experience criada apenas para RBAC; Conditional Access usa blocks, sem segundo visual. |
| 8.9.5 — Zero Trust + Defense in Depth + Defender for Cloud (concluída) | `zero-trust-and-defense-in-depth`; `defender-for-cloud` | 26 blocks, 12 cards e 10 Questions/40 options novas em duas distribuições 2/2/1. Os três objetivos estão Covered. | Uma Architecture Visual Experience criada apenas para Defense in Depth; nenhum visual separado para Zero Trust ou Defender. |
| 8.9.6 — Practice + fechamento (concluída) | As nove Lessons do Topic | 8 blocks e 3 cards adicionados apenas à Lesson de apoio; 10 Questions/40 options históricas corrigidas in-place. Lesson Quiz, Topic Quiz, Review, spaced repetition, fallback, RLS, isolamento e histórico validados. | Nenhum novo; os 3 visuais existentes foram validados. |

### Preservação histórica e checkpoint

Os nove UUIDs e slugs de Lesson foram preservados. Até a 8.9.6, 6 Flashcards históricos foram corrigidos in-place; 43 Flashcards, 39 Questions, 156 options e 2 Visual Experiences receberam UUIDs novos. Dez Questions históricas de autenticação/autorização e suas 40 options foram corrigidas in-place; a Question histórica de RBAC e suas options permaneceram intactas. Nenhuma Question foi reassociada entre Lessons e nenhum registro histórico foi removido.

**Checkpoint da Etapa 8.9.1:** auditoria concluída; 9 Lessons encontradas, 0 Ready, 9 Needs enrichment, 0 Missing; 11 objetivos Partial, 0 Covered e 0 Missing; 0 Content Blocks, 1 Visual Experience, 6 Flashcards, 11 Questions (3 easy / 6 medium / 2 hard) e 90 minutos estimados. Nenhum conteúdo curricular, Question, Flashcard, Visual Experience, UUID ou slug foi modificado.

**Checkpoint da Etapa 8.9.2:** Microsoft Entra ID e Microsoft Entra Domain Services estão `Covered`; `entra-id-and-domain-services` está `Ready` com 15 Content Blocks, 1 Flow reutilizado, 7 Flashcards e 5 Questions (2 easy / 2 medium / 1 hard). O Topic possui agora 2 objetivos Covered, 9 Partial e 0 Missing, com 15 blocks, 1 visual, 10 Flashcards, 16 Questions (5 easy / 8 medium / 3 hard) e 90 minutos estimados. Todos os UUIDs históricos e o fallback foram preservados; nenhuma Visual Experience foi criada.

**Checkpoint da Etapa 8.9.3:** Single Sign-On, MFA, Passwordless Authentication e External Identities/Guest Access estão `Covered`; `single-sign-on`, `mfa-and-passwordless` e `external-identities` estão `Ready` com 31 novos Content Blocks, 16 novos Flashcards e 15 novas Questions (6 easy / 6 medium / 3 hard). O Topic possui agora 6 objetivos Covered, 5 Partial e 0 Missing, com 46 blocks, 1 visual, 26 Flashcards, 31 Questions (11 easy / 14 medium / 6 hard) e 94 minutos estimados. Nenhuma Visual Experience foi criada e todos os UUIDs históricos e fallbacks foram preservados.

**Checkpoint da Etapa 8.9.4:** Conditional Access e Azure RBAC estão `Covered`; `conditional-access` e `azure-rbac` estão `Ready` com 25 novos Content Blocks, 1 nova Architecture Visual Experience, 3 Flashcards históricos corrigidos, 8 novos Flashcards e 9 novas Questions (4 easy / 3 medium / 2 hard). A Question histórica de RBAC e suas quatro options foram preservadas. O Topic possui agora 8 objetivos Covered, 3 Partial e 0 Missing, com 71 blocks, 2 visuais, 34 Flashcards, 40 Questions (15 easy / 17 medium / 8 hard) e 96 minutos estimados.

**Checkpoint da Etapa 8.9.5:** Zero Trust, Defense in Depth e Microsoft Defender for Cloud estão `Covered`; `zero-trust-and-defense-in-depth` e `defender-for-cloud` estão `Ready` com 26 novos Content Blocks, 1 nova Architecture Visual Experience, 12 novos Flashcards e 10 novas Questions (4 easy / 4 medium / 2 hard). O Topic possui agora 11 objetivos Covered, 0 Partial e 0 Missing, com 97 blocks, 3 visuais, 46 Flashcards, 50 Questions (19 easy / 21 medium / 10 hard) e 100 minutos estimados. Todos os UUIDs históricos e fallbacks foram preservados.

**Closure da Etapa 8.9.6 — Azure Identity, Access and Security: CLOSED.** Os 11 objetivos estão `Covered`, com 0 `Partial` e 0 `Missing`. O Topic possui 9 Lessons, 105 Content Blocks, 3 Visual Experiences, 49 Flashcards, 50 Questions (19 easy / 21 medium / 10 hard) e 100 minutos estimados. A Lesson de apoio `authentication-vs-authorization` recebeu 8 blocks e 3 cards; suas 10 Questions e 40 options históricas foram corrigidas in-place. O fechamento validou as nove Lessons no Topic Quiz round-robin, Lesson Quiz, Review, spaced repetition, progress, RLS, isolamento entre usuários, fallbacks e integridade histórica.

### Fechamento do Domain 2

Checagem final dos cinco grandes Topics:

| Topic | Status | Covered | Partial | Missing |
| --- | --- | ---: | ---: | ---: |
| Core Architectural Components | CLOSED | 10 | 0 | 0 |
| Azure Compute Services | CLOSED | 10 | 0 | 0 |
| Azure Networking Services | CLOSED | 8 | 0 | 0 |
| Azure Storage Services | CLOSED | 16 | 0 | 0 |
| Azure Identity, Access and Security | CLOSED | 11 | 0 | 0 |

Os cinco Topics preservam suas Lessons, práticas e visuais e passaram pelos validadores de fechamento correspondentes. Inventário consolidado do Domain: 38 Lessons, 357 Content Blocks, 11 Visual Experiences, 183 Flashcards, 219 Questions e 410 minutos estimados.

**Domain 2 — Describe Azure architecture and services: CLOSED**

## Domain 3 — Describe Azure management and governance

### Azure Cost Management — Auditoria da Etapa 9.1

Escopo auditado: somente o Topic `Cost Management` (`33000000-0000-4000-8000-000000000001`). A matriz segue o [guia oficial atual do AZ-900](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-900), com habilidades medidas a partir de 20 de julho de 2026: fatores que afetam custos, exploração do Azure Pricing Calculator, capacidades de Cost Management e finalidade das tags. Reservations, Savings Plans e Spot pricing aparecem no [módulo oficial de Cost Management](https://learn.microsoft.com/en-us/training/modules/describe-cost-management-azure/), mas são tratados abaixo apenas como conteúdo complementar, não como objetivos oficiais independentes.

#### Inventário atual

| # | Lesson / slug real | Min | Publicada | Blocks | Visuals | Flashcards | Questions E/M/H | Classificação |
| ---: | --- | ---: | :---: | ---: | ---: | ---: | --- | --- |
| 1 | Factors That Affect Azure Costs / `azure-cost-factors` | 12 | Sim | 14 | 0 | 8 | 3/5/2 | Ready |
| 2 | Azure Pricing Calculator / `pricing-calculator` | 10 | Sim | 10 | 0 | 5 | 2/2/1 | Ready |
| 3 | Azure Cost Management / `azure-cost-management` | 12 | Sim | 13 | 0 | 7 | 3/5/2 | Ready |
| 4 | Resource Tags / `resource-tags` | 10 | Sim | 13 | 0 | 6 | 2/2/1 | Ready |
| **Total** | **4 Lessons** | **44** | **4** | **50** | **0** | **26** | **10/14/6** | **4 Ready / 0 Needs enrichment / 0 Missing** |

Todos os quatro registros, UUIDs e slugs reais permanecem preservados. Após a 9.3, as quatro Lessons possuem Content Blocks, summary, Flashcards e Questions suficientes, mantendo `lessons.content` como fallback.

#### Matriz de cobertura

| Objective | Lesson | Content | Visual | Flashcards | Questions | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Factors that affect Azure costs | `azure-cost-factors` | 14 blocks + fallback | Not necessary | 8 | 10 (3/5/2) | Covered | Tipo, quantidade, configuração, consumo, tempo, Region, transferência, pay-as-you-go, Reservations, Savings Plans e Spot possuem comparação, cenários, traps, summary e prática revisada. |
| Azure Pricing Calculator | `pricing-calculator` | 10 blocks + fallback | Not necessary | 5 | 5 (2/2/1) | Covered | Finalidade, inputs, fluxo, estimate, limitações e comparação explícita com Cost Management possuem cenários e prática. |
| Cost Management capabilities in Azure | `azure-cost-management` | 13 blocks + fallback | Not necessary | 7 | 10 (3/5/2) | Covered | Cost Analysis, acompanhamento, Actual Cost, Forecast, Budgets, alerts e comparação com Pricing Calculator possuem cenários, traps, summary e prática revisada. |
| Purpose of tags | `resource-tags` | 13 blocks + fallback | Not necessary | 6 | 5 (2/2/1) | Covered | Key/value, scopes suportados, organização, reporting, custos, ausência de herança e diferenças de RBAC/Locks/Policy possuem cenários e prática. |

**Resultado final da Etapa 9.4:** 4 `Covered`, 0 `Partial`, 0 `Missing`. Conteúdo, prática, fluxo de estudo, RLS, isolamento e integridade histórica foram validados em produção.

#### Qualidade factual e lacunas

- **Fatores de custo:** tipo, quantidade, configuração, tempo, consumo, unidades provisionadas, Region e transferência estão explícitos sem preços numéricos. O exam trap deixa claro que desalocar compute não elimina necessariamente discos e outros custos associados.
- **Pricing Calculator versus Cost Management:** a Lesson agora compara planejamento/estimate antes da implantação com acompanhamento e análise durante a operação. A calculadora não é apresentada como fatura ou garantia de custo final.
- **TCO:** não aparece neste Topic. Há uma questão legada no conteúdo de CapEx/OpEx do Domain 1. Como TCO não é objetivo independente no guia oficial atual, deve permanecer apenas como contexto legado/cross-domain, sem orientar a criação de uma nova Lesson nesta trilha.
- **Cost Management:** Cost Analysis, acompanhamento, Actual Cost, Forecast, Budgets, alerts, tendências e agrupamento estão explícitos. Exportações, APIs, invoices e billing scopes avançados permanecem fora do recorte Fundamentals. As 10 Questions históricas foram simplificadas in-place, removendo chargeback e processos organizacionais excessivos.
- **Tags:** a Lesson define `key/value`, apresenta exemplos, cobre resources/Resource Groups/Subscriptions e conecta classificação a filtros, reporting e custos. Exam traps deixam explícito que não há herança automática e que Tags não substituem RBAC, Resource Locks, Azure Policy ou hierarquia.
- **Modelos complementares:** Pay-as-you-go, Reservations, Savings Plans e Spot possuem comparação Fundamentals, cards e cenários. Permanecem complementares, sem objetivos oficiais ou Lessons independentes e sem detalhes de eligibility, billing ou SKUs.

#### Auditoria da prática

| Lesson | Questions | Easy | Medium | Hard | Flashcards | Observação |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `azure-cost-factors` | 10 | 3 | 5 | 2 | 8 | Dez UUIDs históricos preservados; textos e 40 options foram corrigidos in-place para cenários plausíveis, incluindo custo residual ao parar compute e Spot. |
| `pricing-calculator` | 5 | 2 | 2 | 1 | 5 | Prática nova cobre finalidade, 20 VMs, mudança de Region/size, gasto já ocorrido e estimate versus fatura. |
| `azure-cost-management` | 10 | 3 | 5 | 2 | 7 | Dez UUIDs históricos preservados; textos e 40 options corrigidos in-place para Cost Analysis, Actual/Forecast, Budget/alert, Calculator e Tags em custos. |
| `resource-tags` | 5 | 2 | 2 | 1 | 6 | Prática nova cobre key/value, custos por Environment, scopes suportados, ausência de herança e distinção de RBAC/Locks. |

Não há Questions textualmente idênticas nem Questions com quantidade inválida de options. As quatro Lessons possuem prática suficiente para Lesson Quiz e participação no Topic Quiz. Os distratores absurdos do conjunto histórico de Cost Management foram substituídos por confusões plausíveis, preservando UUIDs.

#### Visual Experiences

| Conceito | Classificação | Decisão recomendada |
| --- | --- | --- |
| Fatores que afetam custos | Not necessary | Uma lista agrupada e cenários curtos são mais claros que uma interação. |
| Pricing Calculator versus Cost Management | Not necessary | Usar comparison block com `antes do deployment` versus `durante a operação`. |
| Cost optimization models | Not necessary | Tabela curta pode comparar flexibilidade, previsibilidade e interrupção sem simulador. |
| Tags | Not necessary | Exemplos `key=value`, filtros e exam traps são suficientes. |

Não existe Visual Experience associada às quatro Lessons e nenhuma é necessária para fechar os objetivos. Não criar calculadora, dashboard ou simulador evita duplicar ferramentas Azure e mantém o foco Fundamentals.

#### Plano exato para 9.2–9.4

| Etapa | Lessons / slugs reais | Lacunas a tratar | Visual |
| --- | --- | --- | --- |
| 9.2 — Cost factors + Pricing Calculator (concluída) | `azure-cost-factors`; `pricing-calculator` | 24 blocks, 13 cards e 5 Questions/20 options novas; 10 Questions/40 options históricas corrigidas in-place. Os dois objetivos estão Covered. | Nenhuma Visual Experience; comparison blocks foram suficientes. |
| 9.3 — Cost Management + Tags (concluída) | `azure-cost-management`; `resource-tags` | 26 blocks, 13 cards e 5 Questions/20 options novas; 10 Questions/40 options históricas corrigidas in-place. Os dois objetivos estão Covered. | Nenhuma Visual Experience; comparison blocks foram suficientes. |
| 9.4 — Practice + fechamento (concluída) | As quatro Lessons | Nenhum conteúdo novo foi necessário. Inventário, precisão, Lesson Quiz, Topic Quiz balanceado, Review, spaced repetition, progress, RLS, isolamento, histórico e fallbacks foram validados em produção com dados temporários removidos no mesmo checkpoint. | Nenhum; 0 Visual Experiences é a decisão final. |

#### Preservação e limitações registradas na auditoria 9.1

Nenhum UUID, slug, Lesson, Content Block, Visual Experience, Flashcard ou Question foi alterado na auditoria 9.1. Naquele momento, o executor `supabase test db` não concluiu por ausência de Docker/`pg_prove`. A limitação foi superada no fechamento: as migrations 9.4 executaram diretamente em produção as invariantes de conteúdo, prática, RLS, referências históricas e o fluxo mutável completo, com usuários temporários removidos antes do commit final.

**Checkpoint da Etapa 9.1:** auditoria concluída; 4 Lessons encontradas, 0 Ready, 4 Needs enrichment e 0 Missing; 0 objetivos Covered, 4 Partial e 0 Missing; 0 Content Blocks, 0 Visual Experiences, 0 Flashcards, 20 Questions (6 easy / 10 medium / 4 hard) e 36 minutos estimados. Nenhum conteúdo pedagógico foi criado ou enriquecido.

**Checkpoint da Etapa 9.2:** Factors that affect Azure costs e Azure Pricing Calculator estão `Covered`; `azure-cost-factors` e `pricing-calculator` estão `Ready` com 24 Content Blocks, 13 Flashcards e 15 Questions (5 easy / 7 medium / 3 hard). Os 10 UUIDs históricos de Questions e seus 40 UUIDs de options foram preservados e corrigidos in-place; 5 Questions e 20 options novas foram adicionadas somente à Pricing Calculator. O Topic possui agora 2 objetivos Covered, 2 Partial e 0 Missing, com 24 blocks, 0 visuais, 13 cards, 25 Questions (8 easy / 12 medium / 5 hard) e 40 minutos estimados. Fallbacks, histórico e associações foram preservados.

**Checkpoint da Etapa 9.3:** Cost Management capabilities in Azure e Purpose of tags estão `Covered`; `azure-cost-management` e `resource-tags` estão `Ready` com 26 Content Blocks, 13 Flashcards e 15 Questions (5 easy / 7 medium / 3 hard). Os 10 UUIDs históricos de Questions e seus 40 UUIDs de options foram preservados e corrigidos in-place; 5 Questions e 20 options novas foram adicionadas somente a Resource Tags. O Topic possui agora 4 objetivos Covered, 0 Partial e 0 Missing, com 50 blocks, 0 visuais, 26 cards, 30 Questions (10 easy / 14 medium / 6 hard) e 44 minutos estimados. Fallbacks, histórico e associações foram preservados.

**Closure da Etapa 9.4 — Azure Cost Management: CLOSED.** Os 4 objetivos oficiais estão `Covered`, com 0 `Partial` e 0 `Missing`. O Topic possui 4 Lessons Ready, 50 Content Blocks, 0 Visual Experiences, 26 Flashcards, 30 Questions (10 easy / 14 medium / 6 hard) e 44 minutos estimados. Nenhuma Question ou Flashcard foi corrigida ou criada no fechamento. O Topic Quiz de dez itens incluiu as quatro Lessons, com no máximo três Questions por Lesson em três tentativas isoladas. Lesson Quiz, respostas, Review, conclusão, progress, Flashcard review, spaced repetition, RLS, isolamento entre usuários, fallbacks e referências históricas foram validados em produção; todos os dados temporários foram removidos.

**Azure Cost Management: CLOSED**

### Governance and Compliance — Auditoria da Etapa 9.5.1

Escopo auditado: somente o Topic `Governance and Compliance` (`33000000-0000-4000-8000-000000000002`) do Domain `Describe Azure management and governance`. A matriz segue o [guia oficial atual do AZ-900](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-900), com habilidades medidas a partir de 20 de julho de 2026. O guia possui exatamente três objetivos neste grupo: Microsoft Purview, Azure Policy e resource locks. O Service Trust Portal aparece no [módulo Learn de governança e conformidade](https://learn.microsoft.com/en-us/training/modules/describe-features-tools-azure-for-governance-compliance/), mas não como objetivo independente no guia da prova; por isso é tratado apenas como conteúdo suplementar.

#### Inventário atual

| # | Lesson / slug real | Min | Publicada | Blocks | Visuals | Flashcards | Questions E/M/H | Classificação |
| ---: | --- | ---: | :---: | ---: | ---: | ---: | --- | --- |
| 1 | Microsoft Purview / `microsoft-purview` | 12 | Sim | 13 | 0 | 7 | 2/2/1 | Ready |
| 2 | Azure Policy / `azure-policy` | 12 | Sim | 12 | 0 | 7 | 2/2/1 | Ready |
| 3 | Resource Locks / `resource-locks` | 10 | Sim | 12 | 0 | 6 | 2/2/1 | Ready |
| **Total** | **3 Lessons** | **34** | **3** | **37** | **0** | **20** | **6/6/3** | **3 Ready / 0 Needs enrichment / 0 Missing** |

Os três registros usam `lessons.content` como fallback e estão ordenados pedagogicamente como Purview → Policy → Locks. Nenhuma Lesson possui Content Blocks, Visual Experience, Flashcard ou Question associada no estado versionado. A migration preserva registros existentes por `on conflict (topic_id, slug)` e não fixa UUIDs novos para essas Lessons; portanto os UUIDs reais gerados no banco não podem ser inferidos com segurança do repositório. A leitura REST remota com o papel `anon` foi negada por falta de `SELECT` em `lessons`, como esperado. Nenhum UUID foi inventado ou alterado nesta auditoria.

#### Matriz de cobertura oficial

| Objective | Lesson | Content | Visual | Flashcards | Questions | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Describe the purpose of Microsoft Purview in Azure | `microsoft-purview` | 13 blocks + fallback | Not necessary | 7 | 5 (2/2/1) | Covered | Finalidade, Data Governance, discovery, metadados, Data Map, Unified Catalog, classification, compliance conceitual, alcance multicloud e diferenças de Azure Policy, Defender for Cloud, Azure Storage e banco de dados possuem scenarios, traps e summary. |
| Describe the purpose of Azure Policy | `azure-policy` | 12 blocks + fallback | Not necessary | 7 | 5 (2/2/1) | Covered | Finalidade, definition, assignment, scope, compliance, Audit/Deny, exemplos, remediation conceitual e diferenças de Tags, RBAC, Locks, Conditional Access e Purview possuem traps, summary e prática. |
| Describe the purpose of resource locks | `resource-locks` | 12 blocks + fallback | Not necessary | 6 | 5 (2/2/1) | Covered | `CanNotDelete`, `ReadOnly`, scopes, herança, Owner, management plane e diferenças de RBAC, Policy e backup possuem cenários, traps, summary e prática. |

**Resultado após a Etapa 9.5.3:** 3 `Covered`, 0 `Partial`, 0 `Missing`. As três Lessons possuem estrutura, comparação e prática suficientes; o fechamento integral do Topic permanece reservado à 9.5.4.

#### Service Trust Portal — conteúdo suplementar

| Item | Lesson / artefato atual | Status | Decisão |
| --- | --- | --- | --- |
| Service Trust Portal | Nenhum | Missing (Supplemental) | Pode receber uma menção curta em uma Lesson existente durante a 9.5.2, sem criar objetivo oficial, Lesson própria ou requisito de fechamento. |

A ausência do Service Trust Portal não conta como `Missing` na matriz oficial e não impede o fechamento futuro dos três objetivos do guia da prova.

#### Qualidade factual e riscos de confusão

- **Microsoft Purview:** o fallback associa corretamente o produto a descoberta, classificação, catálogo, linhagem/origem e governança de dados em diferentes ambientes. Não o apresenta como banco de dados, antivírus ou recurso exclusivo do Azure Storage. A Lesson ainda precisa conectar, em nível Fundamentals, governança de dados a capacidades de compliance e risco e diferenciá-la de Microsoft Defender for Cloud.
- **Azure Policy:** definition → assignment → scope → compliance, Audit/Deny, Allowed Locations, Tags obrigatórias e remediation conceitual estão explícitos. Policy é separada de RBAC e Conditional Access e não é apresentada como controle de acesso.
- **Resource Locks:** `CanNotDelete` e `ReadOnly`, scopes, herança, Owner e management plane estão explícitos. A Lesson diferencia proteção administrativa de autorização, avaliação de compliance e recuperação por backup.
- **Tags / Policy / RBAC / Locks / Purview:** a comparação agora está explícita. Tags classificam metadados; Policy avalia ou impõe padrões; RBAC autoriza ações de identidades; Locks protegem contra exclusão/alteração; Purview governa o patrimônio de dados. Conditional Access é separado como decisão de acesso baseada em sinais de identidade.
- **Conteúdo fora de escopo:** não foi detectado conteúdo avançado nas três Lessons. Referências a Azure Policy em Lessons/Questions de Azure Arc pertencem a outro Topic e não foram contadas como cobertura ou prática de Governance and Compliance.

#### Auditoria da prática

| Lesson | Questions | Easy | Medium | Hard | Flashcards | Lacuna principal |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `microsoft-purview` | 5 | 2 | 2 | 1 | 7 | Cenários cobrem discovery/catalog, classification, Data Map/Unified Catalog, diferença de Policy e diferença de Defender for Cloud. |
| `azure-policy` | 5 | 2 | 2 | 1 | 7 | Cenários cobrem Audit, assignment, RBAC versus Policy, Tags obrigatórias e Deny em scope hierárquico; card dedicado reforça compliant/non-compliant. |
| `resource-locks` | 5 | 2 | 2 | 1 | 6 | Cenários cobrem CanNotDelete, ReadOnly, herança, Owner e separação de Lock/RBAC/backup. |

Não há itens duplicados ou fora de escopo. As três Lessons possuem prática suficiente para Lesson Quiz, Topic Quiz distribuído e spaced repetition.

#### Visual Experiences

| Conceito | Classificação | Decisão recomendada |
| --- | --- | --- |
| Microsoft Purview | Not necessary | Explanation, example e comparison blocks são suficientes para o nível Fundamentals. |
| Azure Policy | Not necessary | Um fluxo textual `definition → assignment → scope → evaluation/compliance` e cenários curtos são mais claros que uma interação. |
| Resource Locks | Not necessary | Comparação `CanNotDelete` versus `ReadOnly` cabe em um comparison block. |
| Tags / Policy / RBAC / Locks / Purview | Not necessary | Uma tabela comparativa curta evita duplicar visuais existentes de RBAC e hierarquia. |

Não existe Visual Experience associada ao Topic. Nenhuma experiência existente oferece ganho suficiente para classificação `Reuse` ou `Upgrade later`, e criar interação nova não é necessário para fechar esses objetivos.

#### Plano exato para 9.5.2–9.5.4

| Etapa | Lessons / slugs reais | Lacunas a tratar | Visual |
| --- | --- | --- | --- |
| 9.5.2 — Microsoft Purview (concluída) | `microsoft-purview` | 13 blocks, 7 Flashcards e 5 Questions/20 options novas em 2/2/1. Finalidade, Data Governance, discovery, Data Map, Unified Catalog, classification, compliance conceitual e comparações estão Covered. Service Trust Portal permaneceu somente suplementar e não foi detalhado. | Nenhuma Visual Experience criada. |
| 9.5.3 — Azure Policy + Resource Locks (concluída) | `azure-policy`; `resource-locks` | 24 blocks, 12 Flashcards e 10 Questions/40 options novas, cada Lesson em 2/2/1. Policy definition/assignment/scope/compliance/Audit/Deny, Locks `CanNotDelete`/`ReadOnly`/herança/Owner e comparações estão Covered. | Nenhuma Visual Experience criada; comparison blocks foram suficientes. |
| 9.5.4 — Practice + fechamento (concluída) | As três Lessons | Um Flashcard de compliant/non-compliant foi adicionado como única lacuna. Duplicação, dificuldade, Lesson Quiz, Topic Quiz balanceado, Review, spaced repetition, fallbacks, RLS, isolamento, histórico e referências órfãs foram validados em produção. | Nenhuma Visual Experience criada; 0 é a decisão final. |

#### Preservação e riscos arquiteturais

- O Topic possui UUID estável `33000000-0000-4000-8000-000000000002`; seus três slugs reais foram preservados.
- A migration curricular faz upsert por `(topic_id, slug)`, mantendo registros existentes, mas não registra em código os UUIDs gerados para essas três Lessons. Alterar slug, excluir/recriar Lesson ou tentar fixar UUID retroativamente criaria risco desnecessário para `user_lesson_progress`, quiz history, flashcard reviews e links.
- As próximas etapas devem localizar cada Lesson pelo Topic e slug, atualizar o registro existente e preservar todos os UUIDs encontrados no banco.
- A negação de leitura para `anon` é coerente com a superfície atual de segurança, mas limita auditorias remotas administrativas sem sessão autenticada/service role. Isso não justifica ampliar privilégios públicos.

**Checkpoint da Etapa 9.5.1:** auditoria concluída; 3 Lessons encontradas, 0 Ready, 3 Needs enrichment e 0 Missing; 0 objetivos Covered, 3 Partial e 0 Missing; 0 Content Blocks, 0 Visual Experiences, 0 Flashcards, 0 Questions e 28 minutos estimados. Nenhum conteúdo pedagógico, Question, Flashcard, Visual Experience, UUID ou slug foi modificado.

**Checkpoint da Etapa 9.5.2:** Microsoft Purview está `Covered`; `microsoft-purview` está `Ready` com 13 Content Blocks, 0 Visual Experiences, 7 Flashcards e 5 Questions (2 easy / 2 medium / 1 hard). O Topic possui agora 1 objetivo Covered, 2 Partial e 0 Missing, com 13 blocks, 0 visuais, 7 cards, 5 Questions e 30 minutos estimados. O UUID e slug históricos da Lesson, o fallback e todo histórico foram preservados; Azure Policy, Resource Locks e Service Trust Portal não foram implementados.

**Checkpoint da Etapa 9.5.3:** Azure Policy e Resource Locks estão `Covered`; `azure-policy` e `resource-locks` estão `Ready` com 24 novos Content Blocks, 12 novos Flashcards e 10 novas Questions (4 easy / 4 medium / 2 hard). O Topic possui agora 3 objetivos Covered, 0 Partial e 0 Missing, com 37 blocks, 0 visuais, 19 cards, 15 Questions (6 easy / 6 medium / 3 hard) e 34 minutos estimados. UUIDs, slugs, fallbacks e histórico foram preservados. Lesson Quiz, Topic Quiz, progress, spaced repetition, RLS e limpeza de dados temporários passaram em produção.

**Closure da Etapa 9.5.4 — Governance and Compliance: CLOSED.** Os 3 objetivos oficiais estão `Covered`, com 0 `Partial` e 0 `Missing`. O Topic possui 3 Lessons Ready, 37 Content Blocks, 0 Visual Experiences, 20 Flashcards, 15 Questions (6 easy / 6 medium / 3 hard) e 34 minutos estimados. Um único Flashcard de compliance foi adicionado; nenhuma Question foi corrigida ou criada no fechamento. Lesson Quiz, Topic Quiz de dez itens cobrindo as três Lessons com no máximo quatro Questions por Lesson, Review, completion, progress, spaced repetition, RLS, isolamento entre usuários, fallbacks, integridade histórica e limpeza dos dados temporários foram validados em produção. Service Trust Portal permanece `Supplemental` e não bloqueia o fechamento.

**Governance and Compliance: CLOSED**

### Tools for Managing and Deploying Azure Resources — Etapas 9.6.1–9.6.5 — CLOSED

Escopo auditado: somente o Topic real `Resource Management and Deployment` (`33000000-0000-4000-8000-000000000003`) do Domain `Describe Azure management and governance`. O nome curricular usado nesta seção acompanha o grupo **Tools for Managing and Deploying Azure Resources**. A matriz segue o [guia oficial atual do AZ-900](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-900), com habilidades medidas a partir de 20 de julho de 2026: Azure portal; Cloud Shell, Azure CLI e Azure PowerShell; Azure Arc; Infrastructure as Code; Azure Resource Manager e ARM templates. Os objetivos combinados do guia foram separados abaixo em oito linhas para permitir uma auditoria pedagógica mais precisa.

#### Inventário atual

| # | Lesson / slug real | Min | Publicada | Blocks | Visuals | Flashcards | Questions E/M/H | Classificação |
| ---: | --- | ---: | :---: | ---: | ---: | ---: | --- | --- |
| 1 | Azure Portal / `azure-portal` | 10 | Sim | 10 | 0 | 6 | 2/2/1 | Ready |
| 2 | Azure Cloud Shell / `azure-cloud-shell` | 10 | Sim | 10 | 0 | 6 | 3/5/2 | Ready |
| 3 | Azure CLI / `azure-cli` | 10 | Sim | 10 | 0 | 6 | 3/5/2 | Ready |
| 4 | Azure PowerShell / `azure-powershell` | 10 | Sim | 10 | 0 | 6 | 2/2/1 | Ready |
| 5 | Azure Arc / `azure-arc` | 12 | Sim | 13 | 0 | 7 | 3/5/2 | Ready |
| 6 | Infrastructure as Code / `infrastructure-as-code` | 12 | Sim | 12 | 0 | 6 | 2/2/1 | Ready |
| 7 | Azure Resource Manager and ARM Templates / `azure-resource-manager-and-arm-templates` | 14 | Sim | 14 | 1 | 8 | 4/4/2 | Ready |
| **Total** | **7 Lessons** | **78** | **7** | **79** | **1** | **45** | **19/25/11** | **7 Ready / 0 Needs enrichment / 0 Missing** |

Todas as Lessons continuam publicadas e preservam `lessons.content` como fallback. A 9.6.2 estruturou somente Portal, Cloud Shell, CLI e PowerShell; Arc, IaC e ARM/Templates permanecem no estado auditado. O Topic usa UUID estável `33000000-0000-4000-8000-000000000003`, e as migrations localizam as Lessons existentes por Topic e slug, sem substituir seus UUIDs nem referências históricas.

#### Matriz de cobertura oficial

| Objective | Lesson(s) | Content | Visual | Flashcards | Questions | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Azure Portal | `azure-portal` | 10 blocks | Not necessary | 6 | 5 (2/2/1) | Covered | GUI no navegador, criação/configuração/visualização/administração, cenários, comparação com os outros métodos, trap de não exclusividade e summary. |
| Azure Cloud Shell | `azure-cloud-shell` | 10 blocks | Not necessary | 6 | 10 (3/5/2) | Covered | Terminal interativo autenticado e hospedado, Bash/PowerShell, ferramentas preconfiguradas e distinção explícita ambiente versus ferramenta. Três Questions desviantes foram corrigidas in-place. |
| Azure CLI | `azure-cli` | 10 blocks | Not necessary | 6 | 10 (3/5/2) | Covered | Comandos `az`, exemplos ilustrativos, multiplataforma, scripting/repetibilidade e comparação atual com PowerShell. Três Questions desviantes foram corrigidas in-place. |
| Azure PowerShell | `azure-powershell` | 10 blocks | Not necessary | 6 | 5 (2/2/1) | Covered | Módulos/cmdlets Az, padrão Verb-AzNoun, exemplos, objetos, automação, multiplataforma e contraste com CLI e Cloud Shell. |
| Azure Arc | `azure-arc` | 13 blocks | Not necessary | 7 | 10 (3/5/2) | Covered | Finalidade, recursos fora do Azure, hybrid/multicloud, Arc-enabled Servers, capacidades condicionadas a suporte, Arc versus Migrate, cenários, traps e summary. As 10 Questions históricas foram preservadas e corrigidas in-place. |
| Infrastructure as Code | `infrastructure-as-code` | 12 blocks | Not necessary | 6 | 5 (2/2/1) | Covered | Definição, manual versus IaC, repeatability, consistency, automation, version control, ambientes reproduzíveis, declarative versus imperative, cenários, traps e summary. |
| Azure Resource Manager | `azure-resource-manager-and-arm-templates` | 14 blocks compartilhados | Architecture — 1 | 8 compartilhados | 10 (4/4/2) compartilhadas | Covered | ARM como management/deployment layer comum; Portal/CLI/PowerShell/Templates/API → ARM → Resource Providers → resources, com cenários e distinções explícitas. |
| ARM Templates | `azure-resource-manager-and-arm-templates` | 14 blocks compartilhados | Architecture — 1 | 8 compartilhados | 10 (4/4/2) compartilhadas | Covered | JSON declarativo, IaC, repeatability, parameters/variables/resources/outputs conceituais, cenários, ARM versus template e Bicep apenas como contexto moderno. |

**Resultado consolidado após a 9.6.5:** 8 `Covered`, 0 `Partial`, 0 `Missing`. As sete Lessons estão `Ready`; a distribuição da prática e o fluxo completo do Topic foram validados no fechamento.

#### Qualidade factual e riscos encontrados

- **Azure Portal:** o fallback descreve corretamente uma interface gráfica web para criar, configurar, visualizar e administrar recursos. O exam tip existente nega implicitamente exclusividade ao mencionar outras ferramentas; não foi encontrada a afirmação incorreta de que Portal é a única forma de administração.
- **Cloud Shell:** o fallback separa corretamente ambiente e ferramentas: Cloud Shell é o terminal autenticado baseado em navegador; Azure CLI e Azure PowerShell podem ser executados nele. A prática histórica confirma Bash e PowerShell, mas dedica Questions a Azure Files, sessões interativas versus CI/CD e permissões, diluindo o foco oficial.
- **Azure CLI:** o fallback cobre comandos `az`, multiplataforma, scripts e automação. Não há confusão com Azure PowerShell, mas o exemplo `az webapp deploy` e parte das Questions exigem detalhes operacionais desnecessários para a prova.
- **Azure PowerShell:** o fallback cobre módulos/cmdlets Az, objetos e scripting. A distinção de CLI está correta, sem dezenas de comandos, porém o objetivo não possui qualquer prática.
- **Azure Arc:** o fallback cobre recursos on-premises, outras nuvens e gerenciamento/governança centralizados, deixando explícito que Arc não move automaticamente o recurso para Azure. Não afirma transformar servidores em Azure VMs nem limitar Arc a Kubernetes. A prática histórica é excessivamente concentrada em variações do mesmo benefício e inclui Arc-enabled Kubernetes, conectividade e segmentação com profundidade desnecessária.
- **Infrastructure as Code:** estado desejado, arquivos versionáveis, consistência, automação e repetibilidade aparecem corretamente. Terraform internals, GitOps, modules, pipelines avançados e state management não aparecem. Falta ensinar de modo explícito provisioning manual versus deployment declarativo/repetível.
- **ARM:** o fallback define corretamente a camada de gerenciamento que recebe solicitações e organiza recursos. Não o apresenta como hardware ou ferramenta de linha de comando, mas não conecta explicitamente todas as ferramentas ao mesmo management plane.
- **ARM Templates:** o fallback mantém ARM Template como arquivo JSON declarativo e dá exemplo de implantação consistente. Bicep está ausente; uma menção breve futura pode contextualizar a alternativa moderna, sem substituir o objetivo oficial de ARM Templates.

#### Auditoria da prática

| Lesson | Questions | Easy | Medium | Hard | Flashcards | Observação |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `azure-portal` | 5 | 2 | 2 | 1 | 6 | Cenários cobrem GUI, inspeção visual, repetição, Cloud Shell e métodos alternativos. |
| `azure-cloud-shell` | 10 | 3 | 5 | 2 | 6 | UUIDs históricos preservados; os itens sobre persistência, CI/CD e segurança operacional foram substituídos in-place por ambiente versus ferramenta, uso fora do Cloud Shell e autenticação integrada. |
| `azure-cli` | 10 | 3 | 5 | 2 | 6 | UUIDs históricos preservados; os itens sobre JSON, custo de scripts e exclusão foram substituídos in-place por CLI versus PowerShell, repetibilidade e CLI dentro do Cloud Shell. |
| `azure-powershell` | 5 | 2 | 2 | 1 | 6 | Cenários cobrem cmdlets Az, multiplataforma, objetos PowerShell, ferramenta versus ambiente e escolha entre CLI/PowerShell. |
| `azure-arc` | 10 | 3 | 5 | 2 | 7 | UUIDs históricos preservados; as 10 Questions foram orientadas a cenários e agora cobrem finalidade, servidor externo, hybrid/multicloud, Arc versus Migrate, Arc-enabled Server, suporte variável e traps próximos. |
| `infrastructure-as-code` | 5 | 2 | 2 | 1 | 6 | Cenários cobrem definição, declarative, ambientes reproduzíveis, version control e automação imperative versus declarative. |
| `azure-resource-manager-and-arm-templates` | 10 | 4 | 4 | 2 | 8 | Cobre management layer, ferramentas → ARM, Resource Providers, template JSON, parameters/resources/outputs, repetição, ARM versus template e Bicep como contexto. |

Não foram detectadas Questions textualmente idênticas dentro do Topic, mas há repetição conceitual relevante nos três conjuntos históricos. As 30 Questions possuem quatro options e distribuição uniforme 3/5/2 por Lesson; essa aparente abundância não compensa a ausência total de Questions nas outras quatro Lessons nem a falta de Flashcards em todo o Topic.

#### Visual Experiences

| Conceito | Classificação | Decisão recomendada |
| --- | --- | --- |
| Portal / Cloud Shell / CLI / PowerShell | Not necessary | Um comparison block é suficiente para diferenciar interface gráfica, ambiente e ferramentas. |
| Azure Arc | Missing (optional) | Um diagrama simples `resources outside Azure → Azure Arc → Azure management/governance` pode ajudar, mas não é requisito para fechar o objetivo. |
| Infrastructure as Code | Not necessary | Comparação manual versus declarativo/repetível cabe em blocks. |
| Azure Resource Manager | Implemented | Uma única Architecture Experience mostra `Portal / CLI / PowerShell / ARM Template / REST API → ARM → Resource Providers → Azure Resources`. |
| ARM Templates | Not necessary | Explanation/comparison com JSON, declarativo e repeatability é suficiente junto ao visual de ARM. |

Existe uma única Visual Experience, associada a `azure-resource-manager-and-arm-templates`. O fluxo ARM concentra o ganho pedagógico necessário; não há visual redundante para Portal, Arc, IaC ou ARM Template.

#### Plano exato para 9.6.2–9.6.5

| Etapa | Lessons / slugs reais | Lacunas a tratar | Visual |
| --- | --- | --- | --- |
| 9.6.2 — Portal + Cloud Shell + CLI + PowerShell | `azure-portal`; `azure-cloud-shell`; `azure-cli`; `azure-powershell` | **Concluída:** conteúdo, cenários, comparação GUI/ambiente/ferramentas, 24 cards, 10 Questions novas e seis históricas corrigidas in-place. | Não utilizada; tabelas em blocks foram suficientes. |
| 9.6.3 — Azure Arc | `azure-arc` | **Concluída:** 13 blocks, hybrid/multicloud, recursos fora do Azure, Arc-enabled Servers, Arc versus Migrate, 7 cards e 10 Questions históricas corrigidas in-place. | Não utilizada; modelo conceitual e comparison table nos blocks foram suficientes. |
| 9.6.4 — IaC + ARM + ARM Templates | `infrastructure-as-code`; `azure-resource-manager-and-arm-templates` | **Concluída:** 26 blocks, 14 cards, 15 Questions, manual versus IaC, declarative/imperative, ARM management layer, Resource Providers, ARM Template JSON e Bicep contextual. | Uma Architecture Experience criada para o fluxo comum de ARM; nenhum visual separado para IaC/template. |
| 9.6.5 — Practice + fechamento | As sete Lessons | **Concluída:** duplicações, difficulty, Lesson Quiz, Topic Quiz com as sete Lessons, Review, spaced repetition, fallback, RLS, isolamento, UUIDs e histórico validados sem criar conteúdo redundante. | Nenhum visual novo; a Architecture Experience de ARM foi validada. |

#### Preservação e riscos arquiteturais

- Nenhum UUID ou slug de Lesson foi substituído; referências de progresso continuam apontando para os registros originais.
- Os UUIDs das 30 Questions históricas (`63000000-0000-4000-8000-000000000031`–`060`) e de suas options foram preservados. Correções ocorreram in-place.
- As sete Lessons foram enriquecidas por Topic e slug, preservando progress, quiz history e flashcard history.
- O Topic Quiz de 10 itens inclui as sete Lessons e limita concentração a no máximo duas Questions por Lesson.
- `lessons.content` permanece publicado e válido como fallback em todas as Lessons.

**Checkpoint da Etapa 9.6.2:** 7 Lessons no Topic, das quais 4 Ready e 3 Needs enrichment; 4 objetivos Covered, 4 Partial e 0 Missing; 40 Content Blocks, 0 Visual Experiences, 24 Flashcards, 40 Questions (13 easy / 19 medium / 8 hard) e 72 minutos estimados. As quatro Lessons-alvo totalizam 40 minutos. Nenhum UUID de Lesson, Flashcard ou Question histórico foi substituído; seis Questions e suas options foram corrigidas in-place.

**Checkpoint da Etapa 9.6.3:** 7 Lessons no Topic, das quais 5 Ready e 2 Needs enrichment; 5 objetivos Covered, 3 Partial e 0 Missing; 53 Content Blocks, 0 Visual Experiences, 31 Flashcards, 40 Questions (13 easy / 19 medium / 8 hard) e 74 minutos estimados. Azure Arc possui 13 blocks, 7 cards e mantém suas 10 Questions (3 easy / 5 medium / 2 hard) nos UUIDs históricos. Não foi criada Visual Experience porque o fluxo conceitual e a comparação cabem de forma clara nos blocks.

**Checkpoint da Etapa 9.6.4:** 7 Lessons Ready; 8 objetivos Covered, 0 Partial e 0 Missing; 79 Content Blocks, 1 Visual Experience, 45 Flashcards, 55 Questions (19 easy / 25 medium / 11 hard) e 78 minutos estimados. IaC recebeu 12 blocks, 6 cards e 5 Questions; ARM/Templates recebeu 14 blocks, 8 cards, 10 Questions e a única Architecture Experience do Topic. O fechamento formal permanece para a 9.6.5.

**Checkpoint da Etapa 9.6.5 — CLOSED:** 7 Lessons Ready; 8 objetivos Covered, 0 Partial e 0 Missing; 79 Content Blocks, 1 Visual Experience, 45 Flashcards, 55 Questions (19 easy / 25 medium / 11 hard) e 78 minutos. Nenhum card ou Question adicional foi necessário no fechamento. Lesson Quiz, Topic Quiz distribuído pelas sete Lessons, Review, progress, spaced repetition, isolamento entre usuários, fallback, UUIDs históricos, RLS, grants e referências órfãs foram validados. **Tools for Managing and Deploying Azure Resources: CLOSED.**

### Azure Monitoring Tools — Etapas 9.7.1–9.7.4 — CLOSED

Escopo auditado: somente o Topic real `Monitoring` (`33000000-0000-4000-8000-000000000004`) do Domain `Describe Azure management and governance`. A matriz segue o [guia oficial atual do AZ-900](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-900), com habilidades medidas a partir de 20 de julho de 2026: Azure Advisor; Azure Service Health; e Azure Monitor, incluindo Log Analytics, Azure Monitor alerts e Azure Monitor Application Insights. As seis Lessons reais foram mantidas dentro do mesmo Topic; nenhum Topic, slug, UUID ou conteúdo foi criado ou alterado nesta auditoria.

#### Inventário atual

| # | Lesson / slug real | Min | Publicada | Blocks | Visuals | Flashcards | Questions E/M/H | Classificação |
| ---: | --- | ---: | :---: | ---: | ---: | ---: | --- | --- |
| 1 | Azure Advisor / `azure-advisor` | 12 | Sim | 11 | 0 | 7 | 3/5/2 | Ready |
| 2 | Azure Service Health / `azure-service-health` | 12 | Sim | 12 | 0 | 8 | 2/2/1 | Ready |
| 3 | Azure Monitor / `azure-monitor` | 12 | Sim | 11 | 1 | 6 | 2/2/1 | Ready |
| 4 | Log Analytics / `log-analytics` | 10 | Sim | 8 | 0 | 6 | 2/2/1 | Ready |
| 5 | Azure Monitor Alerts / `azure-monitor-alerts` | 10 | Sim | 8 | 0 | 6 | 2/2/1 | Ready |
| 6 | Application Insights / `application-insights` | 12 | Sim | 10 | 0 | 6 | 3/5/2 | Ready |
| **Total** | **6 Lessons** | **68** | **6** | **60** | **1** | **39** | **14/18/8** | **6 Ready / 0 Needs enrichment / 0 Missing** |

Todas as Lessons possuem `lessons.content` publicado e utilizável como fallback e agora também contam com conteúdo estruturado, summary, exam tip/trap, Flashcards e prática. Uma única Architecture Experience compartilhada está associada a Azure Monitor.

#### Matriz de cobertura oficial

| Objective | Lesson(s) | Content | Visual | Flashcards | Questions | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Azure Advisor | `azure-advisor` | 11 blocks | Not necessary | 7 | 10 (3/5/2) | Covered | Finalidade, recommendations, cinco categorias, decisão humana, cenários e comparações com Monitor, Service Health e Cost Management. As 10 Questions históricas foram corrigidas in-place. |
| Azure Service Health | `azure-service-health` | 12 blocks | Not necessary | 8 | 5 (2/2/1) | Covered | Personalized health information, service issues, planned maintenance, health advisories, Azure Status, Resource Health, comparação global/personalizado/específico e prática por cenário. |
| Azure Monitor | `azure-monitor` | 11 blocks | Architecture — 1 | 6 | 5 (2/2/1) | Covered | Plataforma central, telemetry, metrics, logs, analysis/visualization/alerts, cenários e comparação com Advisor e health tools. |
| Log Analytics | `log-analytics` | 8 blocks | Reuse Monitor flow | 6 | 5 (2/2/1) | Covered | Consulta e análise conceitual de logs, KQL apenas como contexto, Metrics versus Logs, cenário, trap e prática. |
| Azure Monitor Alerts | `azure-monitor-alerts` | 8 blocks | Reuse Monitor flow | 6 | 5 (2/2/1) | Covered | Signal → condition → alert → notification/action, CPU threshold, falhas de aplicação e distinção entre Metric e Alert. |
| Application Insights | `application-insights` | 10 blocks | Reuse Monitor flow | 6 | 10 (3/5/2) | Covered | APM, requests, failures, response times, dependencies, application telemetry, exemplo ASP.NET Core e prática histórica simplificada in-place. |

**Resultado final após a 9.7.4:** 6 `Covered`, 0 `Partial`, 0 `Missing`. As seis Lessons estão `Ready`; conteúdo estruturado, prática, visual, fallbacks e fluxos de estudo foram validados em produção.

#### Qualidade factual e problemas encontrados

- **Azure Advisor:** 11 blocks estruturam a finalidade, as cinco categorias conceituais, cenários, decisão humana e comparação com Monitor, Service Health e Cost Management. O exam trap deixa explícito que Advisor analisa e recomenda, mas não aplica universalmente toda mudança nem monitora outages.
- **Azure Service Health:** 12 blocks cobrem service issues, planned maintenance, health advisories, Azure Status e Resource Health. A comparação `global → personalizado → recurso específico` está explícita, assim como a diferença entre Resource Health e métricas detalhadas do Azure Monitor.
- **Azure Monitor:** 11 blocks e um visual cobrem o ciclo `resources/apps → telemetry → Monitor → analysis/visualization/alerts`, Metrics versus Logs e diferenças para Advisor, Service Health e Resource Health.
- **Log Analytics:** 8 blocks mantêm o foco em consulta/análise de logs; KQL aparece somente como contexto, sem sintaxe, joins, ingestion ou administração de workspace.
- **Azure Monitor Alerts:** 8 blocks cobrem signal, condition, alert e notification/action sem aprofundar Action Groups, processing rules ou thresholds dinâmicos.
- **Application Insights:** 10 blocks cobrem APM, requests, failures, response times, dependencies e application telemetry. O exemplo ASP.NET Core é conceitual, sem SDK, connection strings, sampling ou configuração de OpenTelemetry.

#### Auditoria da prática

| Lesson | Questions | Easy | Medium | Hard | Flashcards | Observação |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `azure-advisor` | 10 | 3 | 5 | 2 | 7 | UUIDs históricos preservados; os dez itens agora usam cenários Fundamentals e distratores próximos entre Advisor, Monitor, Service Health e Cost Management. |
| `azure-service-health` | 5 | 2 | 2 | 1 | 8 | Cobre manutenção personalizada, Azure Status global, Resource Health específico, CPU como Azure Monitor e incidente regional relevante à Subscription. |
| `azure-monitor` | 5 | 2 | 2 | 1 | 6 | Cobre plataforma, Metrics, CPU, Advisor versus Monitor e Resource Health versus Monitor. |
| `log-analytics` | 5 | 2 | 2 | 1 | 6 | Cobre consulta de logs, Logs versus Metrics, KQL conceitual e relação com Azure Monitor. |
| `azure-monitor-alerts` | 5 | 2 | 2 | 1 | 6 | Cobre signal/condition, CPU threshold, Metric versus Alert e necessidade de regra apropriada. |
| `application-insights` | 10 | 3 | 5 | 2 | 6 | UUIDs históricos preservados; cinco itens avançados foram simplificados in-place para APM, performance, failures, dependencies e distinção de Service Health. |

Não foram detectadas Questions textualmente idênticas. Todas possuem quatro options distintas, exatamente uma resposta correta e explicação suficiente; os distratores absurdos do conjunto histórico de Advisor foram substituídos in-place por confusões reais de prova. Cada Lesson possui pelo menos cinco Questions para Lesson Quiz. O Topic Quiz de dez itens representa as seis Lessons, sem concentrar mais de dois itens em uma única Lesson. Não restam lacunas de prática ou Flashcards neste Topic.

#### Visual Experiences

| Conceito | Classificação | Decisão recomendada |
| --- | --- | --- |
| Advisor versus Service Health versus Monitor | Not necessary | Um comparison block curto é suficiente: recommendations versus eventos de saúde personalizados versus monitoring data. |
| Azure Status / Service Health / Resource Health | Not necessary | Uma comparação em três linhas comunica melhor os diferentes escopos que uma interação. |
| Azure Monitor flow | Implemented | Uma única Architecture Experience mostra `Resources / Apps → Metrics + Logs → Azure Monitor → Log Analytics / Alerts / Application Insights`. |
| Log Analytics, Alerts e Application Insights isoladamente | Not necessary | Devem reutilizar o eventual fluxo de Monitor, sem experiências independentes. |

Existe uma única Visual Experience associada a `azure-monitor`, com oito nós e nove conexões. Log Analytics, Alerts e Application Insights reutilizam conceitualmente esse fluxo; nenhuma experiência separada foi criada.

#### Roadmap recomendado para 9.7.2–9.7.4

| Etapa | Lessons / slugs reais | Lacunas a tratar | Visual |
| --- | --- | --- | --- |
| 9.7.2 — Azure Advisor + Azure Service Health | `azure-advisor`; `azure-service-health` | **Concluída:** 23 blocks, 15 cards, 10 Questions históricas de Advisor corrigidas in-place e 5 Questions novas de Service Health. Recommendations, categorias, incidentes/manutenção/advisories e comparações de health estão Covered. | Nenhum visual criado; comparison blocks foram suficientes. |
| 9.7.3 — Azure Monitor + Log Analytics + Alerts + Application Insights | `azure-monitor`; `log-analytics`; `azure-monitor-alerts`; `application-insights` | **Concluída:** 37 blocks, 24 cards, 15 Questions novas e cinco Questions históricas simplificadas in-place. Plataforma, signals, queries, alerts e APM estão Covered. | Uma Architecture Experience compartilhada criada em Azure Monitor; nenhuma experiência por componente. |
| 9.7.4 — Practice + fechamento + Domain 3 | As seis Lessons | **Concluída:** duplicações, difficulty, distratores, Lesson Quiz, Topic Quiz nas seis Lessons, Review, spaced repetition, fallbacks, RLS, isolamento, histórico e matriz final do Domain 3 foram validados. Nenhuma Question ou Flashcard foi adicionada ou corrigida. | Visual da 9.7.3 reutilizado e validado; nenhum novo. |

#### Preservação e riscos arquiteturais

- O Topic possui UUID estável `33000000-0000-4000-8000-000000000004`; seus seis slugs reais devem permanecer inalterados.
- A migration curricular faz upsert por `(topic_id, slug)`, mas não fixa em código os UUIDs gerados para essas Lessons. Excluir/recriar Lesson ou alterar slug arriscaria `user_lesson_progress`, quiz history, flashcard reviews, spaced repetition e links.
- As próximas etapas devem localizar cada Lesson pelo Topic e slug e atualizar o registro existente. `lessons.content` deve permanecer como fallback.
- Os UUIDs históricos das Questions de Application Insights (`63000000-0000-4000-8000-000000000001`–`010`) e Azure Advisor (`63000000-0000-4000-8000-000000000021`–`030`), assim como suas options, devem ser preservados; correções devem ocorrer in-place.
- A leitura curricular remota exige sessão autenticada/service role por RLS. O projeto vinculado está sincronizado com as migrations, mas não foi ampliado o acesso público nem exportado histórico de usuário para esta auditoria.

**Checkpoint da Etapa 9.7.1:** auditoria concluída; 6 Lessons encontradas, 0 Ready, 6 Needs enrichment e 0 Missing; 0 objetivos Covered, 6 Partial e 0 Missing; 0 Content Blocks, 0 Visual Experiences, 0 Flashcards, 20 Questions (6 easy / 10 medium / 4 hard) e 54 minutos estimados. Nenhum conteúdo pedagógico, Flashcard, Question, Visual Experience, UUID ou slug foi modificado.

**Checkpoint da Etapa 9.7.2:** Azure Advisor e Azure Service Health estão `Covered` e `Ready`; o Topic possui agora 2 objetivos Covered, 4 Partial e 0 Missing, com 23 Content Blocks, 0 Visual Experiences, 15 Flashcards, 25 Questions (8 easy / 12 medium / 5 hard) e 62 minutos estimados. Os UUIDs das 10 Questions e 40 options históricas de Advisor foram preservados e corrigidos in-place. Lesson Quiz, seleção do Topic Quiz, fallbacks, RLS, grants, integridade histórica e ausência de mudanças fora de escopo foram validados em produção.

**Checkpoint da Etapa 9.7.3:** as seis Lessons estão `Ready`; 6 objetivos Covered, 0 Partial e 0 Missing; 60 Content Blocks, 1 Visual Experience, 39 Flashcards, 40 Questions (14 easy / 18 medium / 8 hard) e 68 minutos estimados. Azure Monitor, Log Analytics e Alerts receberam cinco Questions cada; os 10 UUIDs e 40 options históricos de Application Insights foram preservados, com cinco Questions e 20 options simplificadas in-place. Lesson Quiz, Topic Quiz com as seis Lessons, visual, fallbacks, RLS e integridade histórica foram validados em produção.

**Closure da Etapa 9.7.4 — Azure Monitoring Tools: CLOSED.** Os 6 objetivos oficiais e seus subconceitos Azure Status, Resource Health, Metrics e Logs estão `Covered`, com 0 `Partial` e 0 `Missing`. O Topic possui 6 Lessons Ready, 60 Content Blocks, 1 Visual Experience, 39 Flashcards, 40 Questions (14 easy / 18 medium / 8 hard) e 68 minutos estimados. O block existente `7b290000-0000-4000-8000-000000000007` foi consolidado in-place como mapa das oito ferramentas/conceitos, mantendo o tipo válido `important`; nenhuma Question, Flashcard, Lesson, slug, Topic ou Visual Experience foi criada. Lesson Quiz, Topic Quiz de dez itens cobrindo as seis Lessons com no máximo dois itens por Lesson, Review, completion, progress, spaced repetition, RLS, isolamento entre usuários, fallbacks, UUIDs históricos e referências órfãs foram validados em produção.

**Azure Monitoring Tools: CLOSED**

### Fechamento final do Domain 3

| Bloco | Objectives Covered | Partial | Missing | Status |
| --- | ---: | ---: | ---: | --- |
| Azure Cost Management | 4 | 0 | 0 | CLOSED |
| Governance and Compliance | 3 | 0 | 0 | CLOSED |
| Tools for Managing and Deploying Azure Resources | 8 | 0 | 0 | CLOSED |
| Azure Monitoring Tools | 6 | 0 | 0 | CLOSED |
| **Domain 3 — total** | **21** | **0** | **0** | **CLOSED** |

O Domain 3 possui 20 Lessons publicadas, 226 Content Blocks, 2 Visual Experiences, 130 Flashcards, 140 Questions (49 easy / 63 medium / 28 hard) e 224 minutos estimados. Nenhum dos quatro blocos possui objetivo `Partial` ou `Missing`.

**Domain 3 — Describe Azure Management and Governance: CLOSED**

## Checkpoint — Etapa 13.5.4

A consistência Lesson ↔ Flashcard foi auditada sobre os três Domains: 397 Flashcards publicados em 76 Lessons. A classificação inicial encontrou 386 `SUPPORTED`, 6 `PARTIALLY_SUPPORTED`, 5 `NOT_SUPPORTED` e 0 `AMBIGUOUS`. Dois gaps legítimos foram fechados em Content Blocks existentes (`choosing-a-cloud-model` e `virtual-networks-and-subnets`) e nove Flashcards foram reescritos nos mesmos UUIDs. O resultado final é 397 `SUPPORTED`, sem cards movidos, removidos ou despublicados e sem Lesson publicada sem Flashcards.

**AZ-900 Content ↔ Flashcard Consistency: READY**

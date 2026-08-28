# AZ-900 content coverage

## Domain 1 — Describe cloud concepts

Auditoria realizada em 25 de agosto de 2026 e atualizada em 26 de agosto de 2026 após a Etapa 8.4.7, sobre o Domain **Describe cloud concepts (25–30%)**.

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

Todas as 18 Lessons do Domain usam Content Blocks. O conteúdo em `lessons.content` foi mantido em todas elas como fallback seguro.

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
| High Availability | `high-availability` | Covered | Sete blocks, 4 flashcards e 10 questions cobrem redução de downtime, redundância, continuidade e SLA, sem antecipar Availability Zones. |
| Scalability | `scalability` | Covered | Sete blocks distinguem scale up/down de scale out/in, com VM maior versus mais instâncias e exemplo .NET; 4 flashcards e 10 questions reforçam aplicação e limites. |
| Elasticity | `elasticity` | Covered | Sete blocks explicam crescimento e redução conforme a demanda e comparam Scalability versus Elasticity sem oposição absoluta; 4 flashcards e 10 questions incluem autoscaling. |
| Reliability | `reliability` | Covered | Sete blocks ensinam resiliência, recuperação, redundância e continuidade, além de comparar Availability versus Reliability e afirmar que a nuvem não elimina falhas; possui 4 flashcards e 10 questions. |
| Predictability | `predictability` | Covered | Sete blocks abrangem previsibilidade de performance e cost por monitoramento, dimensionamento, autoscaling e modelos de preço, sem aprofundar ferramentas do Domain 3; possui 4 flashcards e 10 questions. |
| Security | `security-and-governance-benefits` | Covered | Nove blocks, 4 flashcards e 6 questions cobrem identity, encryption, controls, Shared Responsibility e cenários de configuração incorreta. |
| Governance | `security-and-governance-benefits` | Covered | Nove blocks, 4 flashcards e 6 questions cobrem padronização, policies, compliance, regras organizacionais e sobreposição com Security. |
| Manageability | `manageability` | Covered | Sete blocks, 4 flashcards e 5 questions cobrem Portal, CLI, PowerShell, APIs, Infrastructure as Code e escolha por cenário. |
| IaaS | `infrastructure-as-a-service`; `choosing-iaas-paas-saas`; `shared-responsibility-model` | Covered | Sete blocks, 4 flashcards e 5 questions distinguem responsabilidades, usam Azure Virtual Machines e cobrem controle do SO por conceito e cenário. |
| PaaS | `platform-as-a-service`; `choosing-iaas-paas-saas`; `shared-responsibility-model` | Covered | Sete blocks, 4 flashcards e 5 questions cobrem stack gerenciada, Azure App Service, publicação ASP.NET Core e limites de controle do SO. |
| SaaS | `software-as-a-service`; `choosing-iaas-paas-saas`; `shared-responsibility-model` | Covered | Sete blocks ensinam software pronto com Microsoft 365 e preservam responsabilidades do cliente sobre usuários, acessos, dados e configurações; possui 5 questions próprias. |
| Casos de uso IaaS/PaaS/SaaS | `choosing-iaas-paas-saas` | Covered | Nove blocks, comparação responsiva reutilizada, três cenários, 7 flashcards e 5 questions cobrem controle de SO, publicação em plataforma e consumo de software pronto. |

### Resultado consolidado

- Objetivos solicitados **Covered:** 19.
- Objetivos solicitados **Partial:** nenhum.
- Objetivos solicitados **Missing:** nenhum.
- Objetivo adicional da formulação oficial atual **Covered:** comparação de cloud pricing models.
- Total consolidado: **20 Covered, 0 Partial e 0 Missing**.

## Problemas e riscos detectados

### Lessons ausentes

Não há Lesson ausente para os objetivos solicitados. Os 19 objetivos estão mapeados nas 18 Lessons existentes; Security e Governance compartilham intencionalmente uma Lesson.

### Lessons superficiais

Não restam Lessons exclusivamente legadas nem lacunas curriculares no Domain 1. Todas possuem Content Blocks e mantêm o conteúdo anterior como fallback. Permanece apenas a oportunidade editorial de revisar gradualmente os cenários longos importados, sem reduzir a cobertura útil.

### Duplicação

- Nenhuma duplicata exata foi encontrada após normalizar os enunciados das 153 questions.
- Nenhuma duplicata exata foi encontrada após normalizar as frentes dos 84 flashcards.
- Há sobreposição pedagógica intencional entre definição e escolha de cloud models, e entre as Lessons individuais de IaaS/PaaS/SaaS e a Lesson comparativa. Não é recomendável remover essas Lessons.

### Conteúdo fora de ordem ou potencialmente profundo demais

As questions `62000000-0000-4000-8000-000000000079` e `62000000-0000-4000-8000-000000000080` foram corrigidas no mesmo UUID. Agora testam redundância e SLA sem antecipar Availability Zones ou Regions.

Algumas questions `hard` de Benefits pedem decisões de arquitetura/operação mais detalhadas do que o verbo oficial “describe”. Elas podem permanecer como aprofundamento, desde que o quiz da Lesson não dependa apenas desse nível de complexidade.

### Correção conceitual

Não foi encontrada afirmação claramente incorreta nos conteúdos auditados. Pontos que exigem nuance na futura reescrita:

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
- A coexistência de `lessons.content` e `lesson_content_blocks` funciona como planejado: a auditoria pós-8.4.5 encontrou as 18 Lessons convertidas e todo o conteúdo legado preservado como fallback.

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
- `exam_tip` nas 18 Lessons e 15 `exam_trap` nos conceitos que exigem diferenciação;
- fallback não vazio em `lessons.content` nas 18 Lessons;
- mínimo de quatro Flashcards e cinco Questions por Lesson;
- quatro alternativas distintas, uma resposta correta e explicação didática em cada Question publicada;
- RLS habilitado, leitura de conteúdo restrita a usuários autenticados e escrita direta negada;
- ausência de referências órfãs em progresso, revisões de Flashcards e histórico de Quiz.

Regressão concluída:

- fluxo de Lesson e fallback: 77/77 testes Vitest passaram;
- Lesson Quiz, Topic Quiz, Review, Spaced Repetition, conclusão e isolamento de progresso: validadores SQL transacionais passaram em produção;
- rota protegida redireciona usuário não autenticado para `/login` sem erros de console;
- login em 1280×720 e 390×844 não apresentou overflow horizontal;
- `typecheck`, `lint` e `build` passaram;
- Supabase remoto está atualizado (`db push --dry-run` sem migrations pendentes).

O Domain 1 pode ser estudado de ponta a ponta e todos os seus objetivos estão `Covered`. A Etapa 8.4.7 acrescentou somente uma comparação curta em `consumption-based-model`, ajustou conteúdo complementar nas Lessons existentes e reforçou a prática sem criar nova Lesson, novo sistema de custos ou conteúdo do Domain 2.

## Checkpoint — Etapa 8.4.8

**Domain 1: CLOSED**

| Indicador final | Resultado |
| --- | ---: |
| Objetivos Covered | 20 |
| Objetivos Partial | 0 |
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

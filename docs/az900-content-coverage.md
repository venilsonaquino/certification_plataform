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
| Lesson Content Blocks publicados | 32 |
| Visual Experiences publicadas | 1 |
| Flashcards publicados | 37 |
| Questions publicadas | 42 |
| Tempo estimado total | 70 minutos |

Após a Etapa 8.5.4, `azure-datacenters`, `azure-regions`, `availability-zones` e `region-pairs-and-sovereign-regions` usam Content Blocks estruturados e preservam `lessons.content` como fallback. As outras três Lessons continuam somente com o conteúdo legado.

| # | Lesson / slug real | Min. | Blocks | Visual | Flashcards | Questions (E/M/H) | Status | Avaliação |
| ---: | --- | ---: | ---: | --- | ---: | ---: | --- | --- |
| 1 | Azure Datacenters / `azure-datacenters` | 10 | 7 | Nenhum | 4 | 10 (3/5/2) | Ready | Sete blocks cobrem infraestrutura física, relação Geography/Region/Datacenter, escolha de localização, exam trap, exam tip e summary. As 10 questions agora medem Datacenters e suas diferenças. |
| 2 | Azure Regions / `azure-regions` | 10 | 7 | Nenhum | 7 | 6 (2/3/1) | Ready | Sete blocks cobrem geography, datacenters conectados, implantação e fatores de escolha, com cenário ASP.NET Core, exam trap, exam tip e summary. |
| 3 | Availability Zones / `availability-zones` | 10 | 9 | Architecture | 7 | 5 (1/3/1) | Ready | Nove blocks cobrem definição, isolamento, suporte variável, zonal versus zone-redundant, exemplo .NET, exam tip/trap e summary. O visual foi corrigido e reutilizado. |
| 4 | Region Pairs and Sovereign Regions / `region-pairs-and-sovereign-regions` | 10 | 9 | Nenhum | 4 | 5 (2/2/1) | Ready | Nove blocks separam os conceitos, cobrem paired/nonpaired regions, limites de automação, sovereign clouds, data residency, dois exam traps, exam tip e summary. |
| 5 | Resources and Resource Groups / `resources-and-resource-groups` | 10 | 0 | Nenhum | 7 | 6 (3/2/1) | Needs enrichment | Cobre recurso, agrupamento e pertencimento, mas não possui estrutura de Lesson enriquecida; um flashcard mistura herança de tags e policies de forma incorreta. |
| 6 | Subscriptions and Management Groups / `subscriptions-and-management-groups` | 10 | 0 | Nenhum | 4 | 5 (2/2/1) | Needs enrichment | Apresenta os dois escopos e um cenário, porém simplifica assinatura como faturamento isolado e não desenvolve limites/organização. |
| 7 | Azure Resource Hierarchy / `azure-resource-hierarchy` | 10 | 0 | Nenhum | 4 | 5 (2/2/1) | Needs enrichment | A sequência conceitual existe, mas prática e cards antecipam Azure Policy/RBAC e trazem regras frágeis sobre sobrescrita de políticas. |

Não há Lesson ausente e não é recomendada a criação de novos slugs. Os sete registros existentes acomodam todos os objetivos oficiais e devem ser preservados.

### Coverage matrix

| Objective | Lesson | Content | Visual | Flashcards | Questions | Status | Notes |
| --- | --- | --- | --- | ---: | ---: | --- | --- |
| Azure Datacenters | `azure-datacenters` | 7 blocks estruturados | Not necessary | 4 | 10 | Covered | Explica infraestrutura física, responsabilidade do provider, escolha de Region e diferenças entre Datacenter, Region e Zone. Possui summary, exam tip, exam trap e prática coerente. |
| Azure Regions | `azure-regions` | 7 blocks estruturados | Not necessary | 7 | 6 | Covered | Explica geography, uma ou mais instalações conectadas, localização de implantação e escolha por latência, serviços, residência/compliance, preço e resiliência. Possui cenário .NET e prática coerente. |
| Region Pairs | `region-pairs-and-sovereign-regions` | 4 blocks dedicados + exam tip + summary compartilhados | Not necessary | 3 dos 4 | 3 dos 5 | Covered | Define a associação feita pela Microsoft entre algumas Regions, distingue paired/nonpaired e condiciona geo-replication, geo-redundancy e disaster recovery ao serviço, à configuração e à arquitetura. |
| Sovereign Regions | `region-pairs-and-sovereign-regions` | 3 blocks dedicados + exam tip + summary compartilhados | Not necessary | 1 dos 4 | 2 dos 5 | Covered | Explica sovereign cloud, requisitos específicos, isolamento/operação e disponibilidade variável, além de separar soberania de data residency. |
| Availability Zones | `availability-zones` | 9 blocks estruturados | Reuse | 7 | 5 | Covered | Define Zone como agrupamento lógico de um ou mais datacenters, explica isolamento e suporte, diferencia zonal/zone-redundant e reutiliza o visual corrigido no mesmo UUID. |
| Azure Resources | `resources-and-resource-groups` | Legado curto | Not necessary | 1 dos 7 | 1 dos 6 | Partial | Definição utilizável, mas pouco reforço direto e sem estrutura pedagógica enriquecida. |
| Resource Groups | `resources-and-resource-groups` | Legado curto | Not necessary | 6 dos 7 | 5 dos 6 | Partial | Boa base prática; precisa corrigir herança de tags e separar organização, ciclo de vida e escopo de gerenciamento. |
| Subscriptions | `subscriptions-and-management-groups` | Legado curto | Not necessary | 2 dos 4 | 2 dos 5 | Partial | Cobre boundary de cobrança/acesso, mas usa formulações absolutas sobre faturamento independente. |
| Management Groups | `subscriptions-and-management-groups` | Legado curto | Not necessary | 2 dos 4 | 3 dos 5 | Partial | Cobre agrupamento de subscriptions e aplicação centralizada, ainda sem explicação estruturada. |
| Hierarchy entre Resource Groups, Subscriptions e Management Groups | `azure-resource-hierarchy`; `subscriptions-and-management-groups`; `resources-and-resource-groups` | Legado curto | Missing | 4 | 5 | Partial | A ordem Management Groups → Subscriptions → Resource Groups → Resources existe; falta um visual único da hierarquia e a prática precisa evitar aprofundamento prematuro em Policy/RBAC. |

### Resultado de cobertura

- **Covered:** 5 objetivos.
- **Partial:** 5 objetivos.
- **Missing:** 0 objetivos.
- **Lessons Ready:** 4.
- **Lessons Needs enrichment:** 3.
- **Lessons Missing:** 0.

Azure Datacenters, Azure Regions, Availability Zones, Region Pairs e Sovereign Regions estão `Covered`. Os cinco objetivos de Resource Hierarchy permanecem `Partial` e não foram alterados pela Etapa 8.5.4.

### Visual Experiences

Existe uma única experiência no Topic:

| ID | Lesson | Tipo | Status de publicação | Classificação | Decisão futura |
| --- | --- | --- | --- | --- | --- |
| `76000000-0000-4000-8000-000000000002` | `availability-zones` | `architecture` | Publicada | Reuse | Atualizada na 8.5.3 no mesmo UUID: Region → três Zones → “1+ Datacenters”, com independência de energia, refrigeração e networking. |

A configuração atual é renderizável, responsiva e acessível e representa uma Region contendo três Zones, cada uma ligada a um agrupamento de um ou mais datacenters. Para Datacenters/Regions e Region Pairs/Sovereign Regions, uma nova interação não é necessária. Para Resource Hierarchy, uma visualização simples de hierarquia é materialmente útil e está `Missing`; deve haver apenas uma, ligada à Lesson `azure-resource-hierarchy`.

### Auditoria de Flashcards

| Lesson | Cards | Avaliação |
| --- | ---: | --- |
| `azure-datacenters` | 4 | Quatro UUIDs preservados e textos ajustados para definição, relação Region → Datacenters, seleção de Region e diferença Datacenter versus Region. |
| `azure-regions` | 7 | Quatro cards ajustados nos mesmos UUIDs; a repetição sobre latência foi substituída por geography e os fatores de escolha agora incluem resiliência. |
| `availability-zones` | 7 | Os sete cards foram corrigidos nos mesmos UUIDs. Agora cobrem definição 1+ datacenters, isolamento, Region versus Zone, suporte variável e zonal versus zone-redundant, sem antecipar Availability Sets. |
| `region-pairs-and-sovereign-regions` | 4 | Os quatro UUIDs foram preservados e os cards agora testam definição do pair, paired versus nonpaired, finalidade possível sem automação e Sovereign Region versus data residency. |
| `resources-and-resource-groups` | 7 | Boa quantidade; o card 7 afirma que tags aplicadas ao Resource Group afetam todos os recursos, mas tags não são herdadas automaticamente sem Policy. |
| `subscriptions-and-management-groups` | 4 | Cobertura mínima; o card 4 sugere que toda subscription tem faturamento próprio, embora várias possam compartilhar a mesma relação/conta de cobrança. |
| `azure-resource-hierarchy` | 4 | Cards 2 e 4 são conceitualmente frágeis: políticas e permissões não obedecem a uma regra geral de “sobrescrita pelo nível mais específico”; também antecipam Policy/RBAC. |

Não há duplicata exata de frente entre os 37 Flashcards. A Etapa 8.5.4 corrigiu os quatro cards da Lesson no mesmo UUID, sem criar, remover ou reassociar registros.

### Auditoria de Questions

| Lesson | Total | Easy | Medium | Hard | Avaliação |
| --- | ---: | ---: | ---: | ---: | --- |
| `azure-datacenters` | 10 | 3 | 5 | 2 | As 10 questions foram reescritas nos mesmos UUIDs e agora testam definição, componentes físicos, responsabilidade, relação e diferenças, sem antecipar Zones ou Region Pairs. |
| `azure-regions` | 6 | 2 | 3 | 1 | Boa distribuição por conceito e cenário; uma question foi ajustada para incluir preço aplicável e opções de resiliência entre os fatores de escolha. |
| `availability-zones` | 5 | 1 | 3 | 1 | As cinco questions foram ajustadas nos mesmos UUIDs e cobrem cenário, definição, zonal versus zone-redundant, suporte variável e responsabilidade, sem depender de VMs. |
| `region-pairs-and-sovereign-regions` | 5 | 2 | 2 | 1 | As cinco questions foram corrigidas nos mesmos UUIDs e cobrem definição, nonpaired regions, Sovereign Region versus data residency e ausência de replicação/failover automático. |
| `resources-and-resource-groups` | 6 | 3 | 2 | 1 | Cobre definição, cenário e ciclo de vida; as duas questões de definição têm leve redundância com a questão introdutória. |
| `subscriptions-and-management-groups` | 5 | 2 | 2 | 1 | Distribuição adequada; algumas explicações aprofundam policies, quotas e access antes das Lessons correspondentes. |
| `azure-resource-hierarchy` | 5 | 2 | 2 | 1 | A questão 2 testa RBAC explicitamente e está fora do recorte; questões 4 e 5 aprofundam Azure Policy e exceções, tornando o objetivo Fundamentals ambíguo. |
| **Total** | **42** | **15** | **19** | **8** | Quantidade suficiente, mas a associação e a precisão precisam ser corrigidas antes do fechamento do Topic. |

Não resta duplicata exata normalizada entre as 42 Questions do Topic. A duplicata sobre Region Pairs foi eliminada na Etapa 8.5.2 ao reescrever, no mesmo UUID, a Question que estava incorretamente associada a `azure-datacenters`; a Etapa 8.5.4 preservou todos os cinco UUIDs da Lesson. Nenhuma Question foi apagada, criada ou reassociada.

### Inconsistências e riscos

- Tags em Resource Groups não são herdadas automaticamente pelos recursos. A herança requer uma definição de Azure Policy apropriada.
- “Política mais específica prevalece” e “permissões são sobrescritas” não são regras gerais válidas para Azure Policy/RBAC.
- Questões de RBAC e detalhes de Azure Policy pertencem a etapas posteriores e devem ser substituídas ou reorientadas na 8.5.6.
- `lessons.content` foi preservado como fallback nas sete Lessons. Nas três Lessons ainda legadas, continua sendo o único conteúdo até a Etapa 8.5.5.

### Plano exato para 8.5.2–8.5.6

| Etapa | Lessons envolvidas | Lacunas a fechar | Visual Experience |
| --- | --- | --- | --- |
| 8.5.2 — Datacenters + Regions | `azure-datacenters`; `azure-regions` | Concluída: definições, relação geography/region/datacenter, rede de baixa latência, fatores de escolha e prática corrigida. | Nenhuma criada, conforme planejado. |
| 8.5.3 — Availability Zones | `availability-zones` | Concluída: definição 1+ datacenters, isolamento, suporte variável, responsabilidade e zonal versus zone-redundant. | Visual reutilizado e atualizado no mesmo UUID `76000000-0000-4000-8000-000000000002`; nenhuma nova experiência criada. |
| 8.5.4 — Region Pairs + Sovereign Regions | `region-pairs-and-sovereign-regions` | Concluída: os conceitos foram separados, nonpaired regions foram cobertas e promessas automáticas de replicação, failover ou continuidade foram removidas. | Nenhuma criada, conforme planejado. |
| 8.5.5 — Resource Hierarchy | `resources-and-resource-groups`; `subscriptions-and-management-groups`; `azure-resource-hierarchy` | Recurso, ciclo de vida de Resource Group, boundaries de Subscription, Management Groups e hierarquia/escopo sem aprofundar Policy ou RBAC. | Criar uma única visualização simples de hierarquia em `azure-resource-hierarchy`; nenhuma nas duas Lessons auxiliares. |
| 8.5.6 — Practice + fechamento | As sete Lessons do Topic | Corrigir/reassociar prática preservando IDs, remover duplicação, substituir itens fora do escopo, validar Lesson/Topic Quiz e atualizar esta matriz. | Nenhuma nova; validar a de Zones e a hierarquia criada na 8.5.5. |

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

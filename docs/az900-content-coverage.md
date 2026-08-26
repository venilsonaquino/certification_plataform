# AZ-900 content coverage

## Domain 1 — Describe cloud concepts

Auditoria realizada em 25 de agosto de 2026 e atualizada em 26 de agosto de 2026 após a validação final da Etapa 8.4.6, sobre o Domain **Describe cloud concepts (25–30%)**.

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
| Lesson Content Blocks publicados | 128 |
| Flashcards publicados | 84 |
| Questions publicadas | 153 |

Todas as 18 Lessons do Domain usam Content Blocks. O conteúdo em `lessons.content` foi mantido em todas elas como fallback seguro.

| # | Topic / Lesson | Blocks | Flashcards | Questions |
| ---: | --- | ---: | ---: | ---: |
| 1 | Cloud Computing / `what-is-cloud-computing` | 6 | 7 | 11 |
| 2 | Cloud Computing / `shared-responsibility-model` | 8 | 7 | 11 |
| 3 | Cloud Computing / `public-private-hybrid-cloud` | 6 | 7 | 10 |
| 4 | Cloud Computing / `choosing-a-cloud-model` | 7 | 4 | 10 |
| 5 | Cloud Computing / `consumption-based-model` | 6 | 4 | 10 |
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
| Consumption-Based Model | `consumption-based-model` | Covered | Seis blocks explicam pagamento pelo consumo, redução de capacidade ociosa, capacidade ajustável e relação entre custo e uso; 4 flashcards e 10 questions. |
| CapEx vs OpEx | `capex-vs-opex` | Covered | Sete blocks e uma comparação responsiva distinguem investimento antecipado e despesa recorrente, com a nuance de que classificação contábil depende do contrato e da organização; 4 flashcards e 10 questions. |
| Cloud pricing models — formulação oficial atual | `consumption-based-model`; `capex-vs-opex`; `predictability` | Partial | O conteúdo cobre consumo e CapEx/OpEx, mas não apresenta uma comparação explícita e coesa entre formas de precificação/compromisso. |
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
- Objetivo adicional da formulação oficial atual **Partial:** comparação ampla de cloud pricing models.

## Problemas e riscos detectados

### Lessons ausentes

Não há Lesson ausente para os objetivos solicitados. Os 19 objetivos estão mapeados nas 18 Lessons existentes; Security e Governance compartilham intencionalmente uma Lesson.

### Lessons superficiais

Não restam Lessons exclusivamente legadas no Domain 1. Todas possuem Content Blocks e mantêm o conteúdo anterior como fallback. Prioridades de cobertura que ainda permanecem:

1. comparação mais ampla de cloud pricing models, além de CapEx/OpEx;
2. revisão gradual dos cenários longos importados, sem reduzir a cobertura útil.

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

Não há lacuna essencial de memória ativa. Os 84 cards cobrem os objetivos solicitados; 29 foram encurtados ou corrigidos sem alterar seus UUIDs. A comparação ampla de cloud pricing models permanece como oportunidade curricular adicional.

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
- Foram corrigidos 29 flashcards e três questions existentes no mesmo UUID; 34 distratores foram substituídos por alternativas plausíveis e 20 questions originais foram adicionadas.
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

## Validação final — Etapa 8.4.6

O Domain 1 foi validado no Supabase de produção com 18 Lessons publicadas, 128 Content Blocks publicados, 84 Flashcards e 153 Questions. As estimativas variam entre 8 e 12 minutos, totalizando 182 minutos. Nenhuma estimativa precisou ser alterada.

As quatro Visual Experiences usadas neste Domain estão publicadas e ligadas à mesma Lesson do respectivo block:

- `Modelo de responsabilidade compartilhada` — `shared-responsibility-model`;
- `Public, Private e Hybrid Cloud` — `public-private-hybrid-cloud`;
- `CapEx e OpEx` — `capex-vs-opex`;
- `IaaS, PaaS e SaaS por cenário` — `choosing-iaas-paas-saas`.

O validador final confirmou:

- `display_order` contínuo em todas as Lessons;
- todos os 128 blocks publicados e com `config` válido;
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

O material solicitado pelo projeto pode ser estudado de ponta a ponta. Permanece `Partial`, por honestidade curricular, apenas a formulação oficial adicional **compare cloud pricing models**, que pede uma comparação mais ampla do que Consumption-Based Model e CapEx/OpEx. Não foi criado conteúdo novo na 8.4.6.

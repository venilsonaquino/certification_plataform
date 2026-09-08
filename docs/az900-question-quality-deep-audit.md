# AZ-900 Question Quality Deep Audit

## Scope

Auditoria profunda concluída em 8 de setembro de 2026 sobre o estado final reconstruído das migrations. A unidade de contagem é `question.id`: cada Question é contada uma vez, ainda que participe de Lesson Quiz, Topic Checkpoint, Review e Mock.

Foram lidos o stem, as quatro alternativas, a chave correta e as explanations de todas as 512 Questions AZ-900. A auditoria anterior de 31 de agosto foi tratada somente como baseline quantitativo: sua classificação A/B/C/D era derivada de `mock_eligible`, dificuldade e presença de cenário, não de julgamento semântico.

## Methodology

O score usa stem clarity (20), distractor plausibility (30), answer neutrality (20), technical correctness (20) e explanation (10). A classificação editorial é:

- A — STRONG: 90–100;
- B — ACCEPTABLE: 75–89;
- C — WEAK: 55–74;
- D — PROBLEMATIC: abaixo de 55 ou com defeito técnico, ambiguidade crítica ou resposta dedutível principalmente pelo tom.

Heurísticas de comprimento e linguagem absoluta serviram apenas como triagem. Cada item foi relido semanticamente. A pergunta de controle foi se alguém sem conhecimento de Azure poderia eliminar duas ou três alternativas apenas pelo tom, extensão ou prudência aparente.

## Question Bank Size

| Pool | Questions |
| --- | ---: |
| Total AZ-900 em escopo | 512 |
| Publicadas | 512 |
| Não publicadas | 0 |
| Lesson Quiz legacy eligible | 512 |
| Topic Checkpoint eligible | 512 |
| Mock eligible | 439 |
| Study/checkpoint only | 73 |
| Options | 2.048 |

Todas são `single_choice`, têm quatro Options distintas e exatamente uma Option marcada correta. Dificuldade: 178 easy, 234 medium e 100 hard. Domínios: 153 / 219 / 140.

## A/B/C/D Classification

| Classification | BEFORE | AFTER esperado |
| --- | ---: | ---: |
| A — STRONG | 88 | 88 |
| B — ACCEPTABLE | 105 | 424 |
| C — WEAK | 149 | 0 |
| D — PROBLEMATIC | 170 | 0 |
| **Total** | **512** | **512** |

O AFTER é uma auditoria sobre o estado reconstruído incluindo a migration proposta; itens remediados foram promovidos somente a B, não a A, para evitar superestimar a qualidade.

## Quality Score Distribution

| Score | BEFORE | AFTER esperado |
| --- | ---: | ---: |
| 90–100 | 88 | 88 |
| 75–89 | 105 | 424 |
| 55–74 | 149 | 0 |
| 0–54 | 170 | 0 |

O score organiza a fila editorial; não substitui a classificação nem a leitura semântica.

## Rationality Bias

Foram confirmadas 170 Questions com `RATIONALITY_BIAS`: uma resposta profissional ou investigativa competia com opções imprudentes, categóricas ou sem relação com o cenário. O caso mais claro é `62000000-0000-4000-8000-000000000099`, sobre autoscaling, no qual a correta mandava revisar métricas enquanto as demais diziam concluir, assumir ou migrar imediatamente.

Target pós-remediation: 0. Os distractors substitutos representam serviço semelhante, configuração inadequada, ação prematura, trade-off parcial ou misconception comum.

## Correct-Length Bias

Baseline objetivo:

- correta mais longa: 266/512 (51,95%);
- correta acima de 1,5× da média dos distractors: 92/512 (17,97%);
- média da correta: 66,13 caracteres / 9,68 palavras;
- média dos distractors: 59,19 caracteres / 8,75 palavras.

Os 92 casos foram revistos. Comprimento isolado não reprovou item; `LENGTH_BIAS` foi aplicado somente quando a extensão funcionava em conjunto com detalhe ou estrutura para revelar a resposta.

## Detail Bias

Foram confirmadas 206 Questions com `DETAIL_BIAS` na classificação conservadora do inventário C/D. O padrão predominante era uma correta que combinava produto, condição e justificativa contra três rótulos ou sentenças genéricas. A remediation equilibra o nível de especificidade sem inflar artificialmente as alternativas.

## Structural Bias

Foram confirmadas 170 Questions com `STRUCTURAL_BIAS` na classificação conservadora, incluindo correta em sentença completa contra fragments, correta condicional contra absolutos e correta com terminologia Azure contra distractors genéricos. Todas as ocorrências materiais estão no plano de remediation.

## Distractor Quality

`OBVIOUS_DISTRACTOR` foi marcado conservadoramente nas 319 Questions C/D. Em várias Questions antigas, três alternativas descreviam decisões que nenhum profissional razoável tomaria. A remediation não tenta tornar uma segunda resposta correta: cada distractor continua tecnicamente inferior por um motivo explícito e próximo ao conceito avaliado.

## Absolute Language

A triagem encontrou linguagem absoluta em 276 Questions e 459 Options; 444 ocorrências estavam em distractors. Isso inclui usos legítimos, portanto a contagem não é um veredito. A revisão semântica remove apenas os absolutos artificiais usados para denunciar falsidade e mantém absolutos tecnicamente necessários.

## Ambiguity

Duas ambiguidades materiais foram encontradas:

- `68000000-0000-4000-8000-000000000062`: Cool e Cold podiam ser defendidos porque “ocasionalmente” não definia retenção; o novo stem fixa recuperação imediata e janela de 30 a menos de 90 dias.
- `68000000-0000-4000-8000-000000000115`: Secure score também conduz a recommendations; o novo stem pede explicitamente o item acionável individual.

Ambiguidade crítica AFTER esperada: 0.

## Stem Quality

Os defeitos encontrados foram `TOO_OBVIOUS`, `MISSING_CONTEXT`, `FACT_RECALL_ONLY`, `WEAK_STEM` e, em menor número, `UNNECESSARILY_LONG`. Questions diretas de Fundamentals foram mantidas quando exigiam distinguir conceitos; cenários foram ajustados somente quando o requisito precisava separar alternativas plausíveis.

## Correct Position Distribution

| Pool | A | B | C | D |
| --- | ---: | ---: | ---: | ---: |
| Global | 128 | 128 | 128 | 128 |
| Mock eligible | 111 | 109 | 106 | 113 |
| Domain 1 | 38 | 38 | 39 | 38 |
| Domain 2 | 56 | 56 | 53 | 54 |
| Domain 3 | 34 | 34 | 36 | 36 |

A migration proposta não altera `display_order` nem `is_correct`; a distribuição permanece igual.

## Content Consistency

Todas as 512 Questions estão ligadas ao curriculum AZ-900 e cobram conceitos cobertos pelas Lessons relacionadas. Resultado: SUPPORTED 512, PARTIALLY_SUPPORTED 0, NOT_SUPPORTED 0. Os 20 lesson slugs ausentes no JSON do parser são uma limitação de reconstrução de migrations geradas, não lacunas do banco; o vínculo real é obrigatório por FK e foi confirmado nas seeds.

## Explanation Quality

Não há explanation vazia. Foram identificadas 65 Questions com explanation fraca, trocada, excessivamente repetitiva ou incompatível com a alternativa atual. O problema é especialmente concentrado em Application Insights, Azure Advisor, Azure CLI, Cloud Shell, Azure Files e no bloco final de Azure Monitor. Toda Option cujo texto muda recebe explanation correspondente.

## Domain Results

- Domain 1: maior concentração de rationality bias nos blocos legados de cloud models, consumo, CapEx/OpEx, serverless, elasticidade e confiabilidade.
- Domain 2: maior concentração de alternatives semanticamente cruzadas em Application Insights/Azure Files e de detail bias em compute, networking, storage e identity.
- Domain 3: maior concentração de absolutos artificiais em pricing, governance, management tools, IaC/ARM e monitoring.

## Topic Results

Todos os 12 Topics foram cobertos. Os hotspots foram Cloud Computing, Benefits of Cloud Services, Compute Services, Storage Services, Identity/Access/Security, Resource Management and Deployment e Monitoring. Cloud Service Types, Core Architectural Components, Networking, Cost Management e Governance também têm itens remediados, mas menor densidade.

## Duplicate Concepts

Não há duplicate textual exata. Foram registrados clusters `SIMILAR`/`NEAR_DUPLICATE`, sobretudo shared responsibility, scale up/out, VM guest OS, App Service/PaaS, CLI/Cloud Shell, Azure Files e ARM. Não houve exclusão automática: pares recall + scenario foram preservados quando testam ângulos diferentes; itens tocados receberam contexto ou alternativas distintos.

## Questions Requiring Remediation

319 Questions (todas as 170 D e todas as 149 C) entram no plano. Outras 20 Questions B recebem somente correções localizadas de português/terminologia, totalizando 339 Questions tocadas. A tabela detalhada, com UUID, hierarchy, score, flags, texto atual, correta, problema e ação, está em `docs/az900-question-quality-remediation.md`.

## Questions Requiring Manual Review

Quinze Questions tinham conteúdo desalinhado com a Option marcada correta: `630...003`, `630...010`, `630...025`, `630...048`, `630...050`, `630...058`, `630...059`, `630...060`, `630...102`, `630...103`, `630...105`, `630...106`, `630...108`, `630...109` e `630...110`.

A remediation preserva o mesmo Option UUID e o mesmo `is_correct`, mas reescreve o conteúdo sob a chave existente para voltar a responder ao stem. Essas linhas são identificadas explicitamente na review table da companion document; nenhuma answer key é alterada.

## Historical Safety

Mock attempts armazenam snapshots imutáveis de stem, Options, key, explanations, hierarchy e difficulty. Updates na fonte afetam somente novos Mocks. Lesson Quiz, Topic Checkpoint e Review preservam Question ID, selected Option ID, `is_correct` gravado e score, mas não congelam texto: telas históricas passam a mostrar o wording corrigido. Isso preserva integridade e analytics, não fidelidade textual legada.

## Migration Plan

A nova migration usa somente updates por Question/Option UUID, dentro de transação, e guards que verificam as 339 Questions e 1.356 Options-alvo, cardinalidade, UUIDs, answer keys, publication, hierarchy, mock eligibility, posição correta e digest integral de Mock snapshots. Não altera architecture, scoring, selectors, checkpoint sizing, readiness, RLS ou auth. A migration será criada, mas não executada.

## Expected Post-migration Validation

| Mechanical metric | BEFORE | AFTER reconstructed |
| --- | ---: | ---: |
| Correct option is longest | 266 (51.95%) | 178 (34.77%) |
| Correct option > 1.5× distractor average | 92 (17.97%) | 18 (3.52%) |
| Average correct / distractor characters | 66.13 / 59.19 | 52.20 / 51.60 |
| Questions with automatic candidate flags | 312 | 129 |
| Portuguese issue occurrences | 0 | 0 |
| Structural errors | 0 | 0 |

Os 18 casos remanescentes acima de 1,5× são candidatos mecânicos já relidos; a diferença decorre principalmente de nomes oficiais ou definições técnicas curtas nas alternativas concorrentes, não de rationality bias. O AFTER semântico é A=88, B=424, C=0 e D=0.

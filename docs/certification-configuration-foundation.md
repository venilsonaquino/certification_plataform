# Certification Configuration Foundation

## Context

Etapa 14.2, primeira implementação da Fase 14. A fundação introduz contratos, validação, registry, resolver e um snapshot explícito do AZ-900 sem alterar Topic Checkpoint, Mock, Readiness, Recommendations, rotas, navegação ou banco.

Gate de entrada confirmado em `docs/multi-certification-architecture.md`:

- `Multi-Certification Architecture V2: READY`
- `AZ-900 V2 Regression Contract: ACTIVE`
- `AZ-204 Foundation Gate: OPEN`

## 14.1 Decisions

- Conteúdo permanece no modelo relacional Certification → Domain → Topic → Lesson.
- Configuração de runtime é pequena, tipada, validada e versionada.
- Checkpoint e Mock continuarão server-authoritative; suas policies relacionais serão introduzidas nas etapas próprias.
- Readiness e Recommendations permanecem engines TypeScript puros e receberão configuração explícita na 14.5.
- Não existe fallback silencioso de uma Certification desconhecida para AZ-900.
- Capabilities iniciais são somente Checkpoint, Flashcards, Mock e Readiness.
- Configuração não reinterpreta attempts/snapshots históricos.

## Goals

- Descrever fielmente o comportamento AZ-900 atual em uma configuração agregada.
- Permitir configurações estruturalmente diferentes sem branches por código no contrato.
- Falhar de forma controlada para Certification sem registro.
- Validar invariantes locais sem consultar Supabase.
- Tornar objetos de configuração imutáveis também em runtime.
- Criar uma fronteira estável que os engines consumirão incrementalmente.

## Non-Goals

- Migrar qualquer engine para consumir a configuração.
- Criar policies/tabelas SQL ou migration.
- Adicionar config, registro, conteúdo, card ou rota AZ-204.
- Aplicar capabilities à navegação.
- Criar Question Types, Labs ou outras features.
- Remover constantes legadas antes de seus gates de paridade.

## Runtime Config Contract

`CertificationRuntimeConfig` contém:

```text
certificationCode
configVersion
capabilities
├─ checkpoint
├─ flashcards
├─ mockExam
└─ readiness
checkpoint
├─ enabled / policyVersion / eligibleQuestionTypes
├─ sizing brackets + pool clamp
├─ Lesson coverage
├─ rotation
└─ difficulty strategy/weights
mock
├─ enabled / policyVersion / eligibleQuestionTypes
├─ questionCount / timeLimitSeconds
├─ allocations por Domain ID
└─ difficulty allocations globais e por Domain
readiness
└─ configuração completa já usada pelo engine AZ-900
recommendations
└─ configuração completa já usada pelo recommendation engine AZ-900
```

Todos os contratos usam propriedades `readonly`. `deepFreezeRuntimeConfig` percorre o objeto validado e congela também arrays e objetos aninhados.

## Storage Strategy

A estratégia continua híbrida:

- TypeScript guarda o runtime aggregate, capabilities, Readiness e Recommendations.
- As policies autoritativas de Checkpoint e Mock serão tabelas relacionais pequenas nas etapas 14.3 e 14.4, pois os selectors executam no PostgreSQL e não devem confiar em parâmetros do browser.
- O snapshot TypeScript de Checkpoint/Mock criado agora descreve os valores que UI/config resolution precisarão conhecer e prepara a paridade; ele ainda não governa execução.
- `certifications` continua tabela de identidade/catálogo. Nenhum `config JSONB` foi criado.

## Resolver

`getCertificationRuntimeConfig(certificationCode)` normaliza somente espaços e caixa, usa um registry explícito e retorna a configuração registrada. `hasCertificationRuntimeConfig` permite consultar disponibilidade sem capturar exceção.

O registry contém somente:

```text
az-900 → AZ900_RUNTIME_CONFIG
```

Não há import dinâmico, inferência por nome de arquivo, display name ou quantidade de Domains.

## Validation

O schema Zod valida:

- código canônico e versões não vazias;
- capability coerente com `enabled` de Checkpoint/Mock;
- Question Types elegíveis quando a feature está habilitada;
- brackets de Checkpoint positivos, contíguos, ordenados e com faixa final aberta;
- pesos de dificuldade do Checkpoint somando 1;
- tamanho e timer positivos do Mock;
- Domain IDs únicos e UUID válidos;
- allocations globais, por Domain e por dificuldade somando os respectivos totais;
- versões de Readiness/Recommendations;
- source/Domain/recency weights em faixas válidas;
- pesos de Domain do Readiness somando 1, sem exigir exatamente três Domains;
- limites de recência crescentes;
- thresholds de classificação, evidência, consistency, safeguards e prioridade coerentes.

Validação de currículo — existência/pertencimento de Domain, capacidade do pool e conteúdo publicado — permanece separada e será executada no servidor nas etapas dos engines. O schema TypeScript não acessa Supabase.

## Versioning

Versões capturadas:

| Area | Version |
|---|---|
| Runtime aggregate | `az900-runtime-v1` |
| Checkpoint policy snapshot | `az900-checkpoint-v1` |
| Mock policy | `az900-mock-v1` |
| Readiness calculation | `az900-readiness-v1` |
| Recommendations calculation | `az900-study-recommendations-v1` |

Uma versão publicada não deve mudar de significado. Mudanças de comportamento exigem nova versão e regression closure.

## AZ-900 Runtime Config

`AZ900_RUNTIME_CONFIG` é construído de um literal validado e depois profundamente congelado. Para evitar duplicação manual, as seções Readiness e Recommendations referenciam as constantes existentes durante esta transição; o parse Zod produz o snapshot agregado validado sem modificar as fontes atuais.

Capabilities AZ-900: Checkpoint, Flashcards, Mock e Readiness habilitados.

## Checkpoint Configuration Snapshot

Valores capturados diretamente de `20260901010000_improve_topic_quiz_checkpoint_selection.sql`:

| Published Lessons | Questions |
|---:|---:|
| 1–3 | 12 |
| 4–5 | 15 |
| 6+ | 20 |

- clamp ao pool elegível: ativo;
- Question Type: `single_choice`;
- uma questão por Lesson elegível quando viável: ativa;
- rotation: unseen, penalidade da última tentativa e least recently seen;
- dificuldade: 30% easy, 50% medium e 20% hard, com floor de medium/hard e remainder para easy;
- policy snapshot: `az900-checkpoint-v1`.

O SQL atual continua sendo a source of execution até 14.3.

## Mock Configuration Snapshot

Valores capturados de `src/types/mockExam.ts`, `20260830061000_add_mock_eligibility_and_selection.sql` e `20260830072000_add_mock_timer_and_history.sql`:

- 40 Questions;
- 3.600 segundos;
- Domain allocations 11 / 15 / 14 para os UUIDs reais dos três Domains AZ-900;
- difficulty allocation global 12 easy / 20 medium / 8 hard;
- difficulty por Domain: 3/6/2, 5/7/3 e 4/7/3;
- Question Type `single_choice` e eligibility editorial `mock_eligible` no selector existente;
- policy `az900-mock-v1`.

Não houve divergência entre docs, TypeScript e SQL. O selector SQL atual continua sendo a source of execution até 14.4.

## Readiness Configuration Snapshot

A seção reutiliza integralmente `AZ900_READINESS_CONFIG`, sem copiar seus valores para uma segunda constante. Foram preservados `calculationVersion`, source weights, Domain weights 0,275/0,375/0,350, recency 14/30/60, classification 60/80, evidence thresholds, consistency, trend e safeguards.

O contrato aceita quantidade variável de Domain weights. O engine e os serviços ainda consomem a constante legada diretamente até 14.5.

Recommendations também reutiliza `AZ900_STUDY_RECOMMENDATION_CONFIG`, inclusive `az900-study-recommendations-v1`, limites, availability, modifiers, thresholds e Lesson ranking.

## Capabilities

Implementadas apenas no contrato/config/validation:

- `checkpoint`;
- `flashcards`;
- `mockExam`;
- `readiness`.

Não existe enforcement em menu, route ou CTA nesta etapa. Review permanece core e `labs` permanece adiado.

## Temporary Dual Sources of Truth

| Area | Current Execution Source | New Config Available | Engine Migration |
|---|---|---|---|
| Checkpoint | `calculate_topic_checkpoint_size` + `start_topic_quiz_unchecked` | YES — snapshot `az900-checkpoint-v1` | 14.3 |
| Mock | `start_mock_exam_internal` + `mock_exam_time_limit_seconds` + `AZ900_PRACTICE_MOCK_CONFIGURATION` | YES — snapshot `az900-mock-v1` | 14.4 |
| Readiness | `AZ900_READINESS_CONFIG` passado/default em `calculateAz900Readiness` | YES — mesma constante composta no aggregate | 14.5 |
| Recommendations | `AZ900_STUDY_RECOMMENDATION_CONFIG` e imports diretos de Readiness AZ-900 | YES — mesma constante composta no aggregate | 14.5 |

Esse estado é deliberadamente transitório. A configuração nova não é anunciada como source of execution antes de cada engine atravessar seu gate de paridade.

## Historical Compatibility

Nenhuma tabela, row, ID ou snapshot foi alterado. Mock continua abrindo `total_questions`, `time_limit_seconds`, allocations, `selection_policy_version` e Question snapshots persistidos. Checkpoints ativos/históricos continuam usando `total_questions` e sua seleção persistida. Readiness continua calculando `az900-readiness-v1` com a constante existente.

Configs futuras afetam novos attempts/cálculos somente depois da migração explícita de cada engine. Não existe estratégia de reset.

## Unknown Certification Behavior

Certification desconhecida ou sem registro lança `CertificationRuntimeConfigNotFoundError` contendo o código normalizado. `az-204` não está registrado e nunca recebe `AZ900_RUNTIME_CONFIG`. A falha é controlada e fail-closed.

A fixture `test-001` existe somente no teste: possui dois Domains, Checkpoint 7/9, Mock de 25 Questions, timer de 2.700 segundos e Domain weights 0,4/0,6. Ela valida genericidade sem entrar no registry ou banco.

## Tests

A suíte focal cobre:

- resolve/validation/versionamento AZ-900;
- normalização de código;
- erro controlado para AZ-204/unknown e ausência de fallback;
- fixture de segunda Certification com topologia/valores diferentes;
- rejeição simultânea de brackets, Mock allocation e Readiness thresholds inválidos;
- deep freeze de aggregate, objetos, arrays, Readiness e Recommendations;
- fixture não registrada.

## Regression

Nenhum import de engine/page/service foi migrado para o resolver. Portanto, o comportamento observável permanece no caminho anterior. A regressão completa valida Study Path, Progressive Unlocking, Checkpoint, Flashcards, Review, Mock, Readiness e Recommendations.

Migration criada: **NO**.

## Next Migration Steps

1. 14.3 — materializar policy autoritativa do Checkpoint e migrar start/summary com paridade 12/15/20, coverage e rotation.
2. 14.4 — materializar policy relacional do Mock e remover guard/topologia/timer AZ-900 do selector.
3. 14.5 — fazer Readiness/Recommendations receberem config explicitamente, mantendo golden results V1.
4. 14.6 — aplicar capabilities e isolation/slug guards.
5. 14.7 — validar AZ-204 Empty Shell, ainda sem conteúdo real.

## Decision

A fundação é suficiente para configurar uma segunda Certification com topologia e valores diferentes sem duplicar engine ou herdar AZ-900. A configuração AZ-900 descreve a baseline real, está validada/versionada/congelada e ainda não participa da execução, evitando mudança prematura de comportamento.

**Certification Configuration Foundation: READY**

**AZ-900 Runtime Behavior: PRESERVED**

**Generic Checkpoint Configuration Gate: OPEN**

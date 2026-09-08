# Generic Topic Checkpoint Configuration

## Context

Etapa 14.3 da Fase 14. O Topic Checkpoint deixa de executar regras AZ-900 embutidas em uma função global e passa a resolver uma policy versionada pela Certification do Topic. O comportamento AZ-900 V2 continua 12/15/20, com coverage, rotation, difficulty balancing, resume e desbloqueio por conclusão.

Gate 14.2 confirmado:

- `Certification Configuration Foundation: READY`
- `AZ-900 Runtime Behavior: PRESERVED`
- `Generic Checkpoint Configuration Gate: OPEN`

## Goals

- Tornar sizing e seleção configuráveis por Certification sem duplicar RPC.
- Preservar exatamente a seleção AZ-900 para novos attempts.
- Preservar attempts ativos e históricos sem reconstrução.
- Manter progressive unlocking, Review e Readiness desacoplados da policy.
- Falhar fechado quando não existe policy ativa/habilitada.
- Manter configuração autoritativa no PostgreSQL e o runtime TypeScript apenas como referência de versão/capability.

## Non-Goals

- Criar ou habilitar AZ-204.
- Alterar Mock, Readiness, Recommendations, Flashcards, Review, sidebar ou routes.
- Adicionar Question Types.
- Recalibrar pesos, tamanho, coverage ou rotation AZ-900.
- Reescrever attempts existentes.

## Data Model

`certification_checkpoint_policies` guarda uma policy imutavelmente identificada por Certification + version:

- `is_active`, `is_enabled`;
- `eligible_question_types`;
- `clamp_to_eligible_pool`;
- `require_lesson_coverage`;
- `rotation_strategy` e penalidade da tentativa anterior;
- pesos easy/medium/hard.

`certification_checkpoint_sizing_brackets` guarda faixas normalizadas `minimum_lessons`, `maximum_lessons` e `question_count` por policy. Existe no máximo uma policy ativa por Certification e uma única faixa aberta por policy.

Constraint triggers diferidos garantem que uma policy ativa comece em uma Lesson, tenha uma faixa final aberta e não possua lacunas, overlaps ou faixas fora de ordem. Counts respeitam o limite atual de 20 de `quiz_attempts`.

A policy nasce inativa enquanto recebe seus brackets. A primeira ativação grava `published_at`; depois disso, definição e brackets não podem ser alterados. Qualquer mudança pedagógica exige outra `policy_version`, enquanto apenas `is_active`/`is_enabled` permanecem controles operacionais.

As tabelas possuem RLS, nenhum grant direto para `anon` ou `authenticated`, e são lidas somente pelos contratos server-authoritative.

## AZ-900 Policy

Policy ativa: `az900-checkpoint-v1`.

| Published Lessons | Target Questions |
|---:|---:|
| 1–3 | 12 |
| 4–5 | 15 |
| 6+ | 20 |

Demais valores:

- eligible type: `single_choice`;
- clamp ao pool: true;
- uma questão por Lesson elegível quando viável: true;
- rotation: `unseen_then_least_recent`;
- penalidade da tentativa anterior: true;
- difficulty weights: 0,30 / 0,50 / 0,20;
- rounding preservado: floor para hard/medium e remainder para easy.

Isso continua produzindo 4/6/2 para 12, 5/7/3 para 15 e 6/10/4 para 20.

## Generic Engine

`calculate_topic_checkpoint_size(certification_id, lesson_count, pool_count)` resolve a policy ativa e a faixa aplicável. Sem policy, sem Lessons ou sem pool, retorna zero. O helper legado sem Certification é removido.

`start_topic_quiz_unchecked(topic_id)`:

1. retoma primeiro um attempt ativo, preservando seu snapshot;
2. deriva Certification pelo Topic;
3. resolve policy ativa/habilitada;
4. calcula o pool pelos Question Types configurados;
5. calcula tamanho pela policy;
6. mantém coverage, unseen, previous-attempt penalty, least-recent, balanceamento de Lesson e dificuldade;
7. grava o novo attempt e sua `checkpoint_policy_version`;
8. congela Question IDs e ordem em `quiz_attempt_questions`.

Não existe `startAz900TopicCheckpoint` ou branch por código.

## Progressive Unlocking

`start_topic_quiz(topic_id)` continua sendo o único contrato público de start e ainda chama `is_topic_checkpoint_available`. O guard agora também exige uma policy ativa/habilitada para a Certification, mas mantém todas as regras de Lessons concluídas e grandfathering.

Score continua sem controlar progressão: qualquer attempt `completed` libera o próximo Topic. A policy não contém nota mínima.

## Sizing and Summaries

`get_topic_quiz_summaries(certification_id)` resolve a mesma policy usada no start para:

- contar somente Questions dos tipos elegíveis;
- calcular `target_question_count` pela mesma função;
- manter `active_total_questions` do attempt persistido;
- manter último score e respostas do usuário.

Assim, UI e start não possuem fontes divergentes. Um attempt legado de 10 Questions continua exibindo e retomando 10, independentemente do alvo atual.

## Coverage and Rotation

O kernel de seleção permanece único. Coverage é controlada pela policy; no AZ-900 ela permanece obrigatória quando a Lesson possui pool elegível. Rotation continua user-scoped e Topic-scoped:

1. unseen;
2. fora do attempt anterior;
3. least recently seen;
4. balanceamento por Lesson;
5. difficulty como best effort;
6. ordem editorial/UUID como desempate.

Nenhum histórico de outra Certification ou usuário participa porque Questions pertencem ao Topic alvo e histórico exige o mesmo usuário + Topic.

## Historical Compatibility

`quiz_attempts.checkpoint_policy_version` é nullable por compatibilidade. Attempts existentes não são atualizados nem recebem versão inventada; seus `total_questions` e Question IDs continuam sendo o snapshot histórico. Novos Topic attempts gravam a versão resolvida.

Lesson Quiz e Review Quiz mantêm a coluna nula. A constraint impede versão de Checkpoint em outros tipos de Quiz.

Review e Readiness continuam lendo answers/attempt type e não dependem da nova tabela de policies. Portanto, a evidência histórica permanece intacta.

## TypeScript Runtime Config

A duplicidade transitória da 14.2 foi encerrada para Checkpoint. `CertificationRuntimeConfig.checkpoint` agora contém somente:

```text
enabled
policyVersion
```

Os valores executáveis 12/15/20, coverage, rotation, eligibility e difficulty vivem apenas na policy SQL. O runtime aggregate aponta para `az900-checkpoint-v1` e será usado por capabilities/UI em etapa posterior.

## Validation

A migration valida:

- policy AZ-900 e todos os valores congelados;
- sizing 1/3/4/5/6/8 Lessons;
- clamp por pool e pool vazio;
- uso da policy nos contratos start/summary;
- remoção da assinatura legacy do sizing;
- grants e ausência de acesso direto às tabelas;
- fixture rollback-only `test-001` com sizing 7/9, coverage e pesos diferentes.

A fixture não persiste Certification ou conteúdo fake.

## Migration

Arquivo:

- `20260902010000_add_certification_checkpoint_configuration.sql`

A mudança é aditiva para tabelas/attempt metadata e substitui funções com a mesma API pública. Não altera assinatura de `start_topic_quiz(uuid)` nem `get_topic_quiz_summaries(uuid)`.

Migration criada: **YES**. Aplicação remota: **PENDING**. O dry-run do Supabase reconheceu somente esta migration como pendente e não alterou o banco.

## Regression Contract

Permanecem obrigatórios:

- 12/15/20 e clamp ao pool;
- representação de todas as Lessons quando viável;
- ausência de duplicatas;
- rotation de retake;
- resume idempotente;
- locks e grandfathering;
- próximo Topic liberado por completion, não score;
- Review/Readiness evidence;
- user/certification isolation;
- Lesson/Review Quiz sem alteração;
- UUIDs e histórico intactos.

## Next Step

A próxima etapa pode generalizar Mock configuration/selection. Checkpoint não precisa de outra refatoração para criar uma policy diferente por Certification; somente curriculum validation e seed específico serão necessários quando o AZ-204 for autorizado.

## Decision

O Topic Checkpoint possui agora uma única source of execution configurável e server-authoritative. AZ-900 mantém sua policy V2, enquanto uma segunda Certification pode definir outras faixas e pesos sem alterar ou duplicar o engine.

**Generic Topic Checkpoint Configuration: READY**

**AZ-900 Checkpoint Behavior: PRESERVED**

**Generic Mock Configuration Gate: OPEN**

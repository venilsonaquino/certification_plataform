# Topic Checkpoint + Progressive Unlocking

## Scope

A ETAPA 13.5.2 implementa a progressão pedagógica sequencial do AZ-900, apresenta o Topic Quiz como Checkpoint e retira o Lesson Quiz apenas da jornada primária da Lesson. Não altera Questions, scoring, rotação, Review, Readiness, Mock ou Flashcards.

## Architecture Source

`docs/az900-learning-flow-architecture.md` é a fonte autoritativa. A implementação segue `HIDE_FROM_PRIMARY_FLOW` para Lesson Quiz, `REBRAND_AS_CHECKPOINT + CHANGE_BEHAVIOR` para Topic Quiz e hard lock pedagógico derivado com compatibilidade legada monotônica.

## Progression Rules

```text
Lesson completed
→ next Lesson available

All published Topic Lessons completed
→ Topic Checkpoint available

Checkpoint submitted at any score
→ first Lesson of next Topic available

Checkpoint performance
→ Review + Readiness
→ never controls progression
```

A ordem usa Domain, Topic e Lesson `display_order`, com UUID apenas como desempate determinístico no enforcement SQL. A transição funciona entre Topics do mesmo Domain e entre Domains. O último Checkpoint encerra a trilha e oferece as experiências existentes de Review e Mock sem iniciar uma prova automaticamente.

## Lesson Availability

O resolver puro `resolveStudyProgression` deriva `locked`, `available`, `in_progress` ou `completed` a partir do currículo publicado, `user_lesson_progress` e histórico de Topic Quiz. A primeira Lesson publicada está disponível; `in_progress` não libera a seguinte; `completed` libera a próxima Lesson do mesmo Topic.

Não existe mutation de unlock nem coluna `is_unlocked`. A Trilha renderiza uma Lesson bloqueada como conteúdo não interativo, com texto do pré-requisito. A Lesson disponível continua usando a rota existente.

## Checkpoint Availability

O Checkpoint usa as tabelas, RPCs, attempts, answers, scoring, retake e rotation do `topic_quiz`. Seus estados são derivados:

| Estado | Regra |
|---|---|
| `locked` | ainda há Lesson publicada não concluída |
| `available` | todas as Lessons publicadas foram concluídas |
| `in_progress` | existe attempt ativo, sempre retomável |
| `completed` | existe attempt concluído, independentemente do score |
| `unavailable` | Topic sem Lesson publicada ou sem Questions publicadas |

A UI mostra no máximo dez questões por tentativa, não o tamanho bruto do pool. Attempt ativo exibe `Continuar Checkpoint`; concluído preserva resultado e retake.

## Next Topic Rule

Um attempt de Topic Quiz com `status = completed` libera o próximo Topic. `score_percentage` não participa do predicado. Portanto 45%, 95% e 0% possuem a mesma semântica de progressão, embora produzam evidências distintas para remediation e Readiness.

## Completion vs Performance

Completion responde se a sequência foi cumprida. Performance responde quão forte é a evidência de domínio. A implementação não introduz nota mínima e não altera thresholds ou pesos de Readiness.

## Legacy Compatibility

Nenhum progresso ou attempt foi reescrito. O grandfathering mantém uma visão monotônica:

- uma Lesson `in_progress` ou `completed` permanece acessível;
- atividade em Lesson posterior mantém todo o prefixo curricular necessário acessível;
- attempt ativo ou concluído mantém o Checkpoint acessível;
- atividade em Topic posterior mantém seus predecessores acessíveis;
- Topic Quiz concluído conta como Checkpoint concluído sem exigir completion retroativa;
- Lesson Quiz history, rota, services, Review signal e Readiness evidence permanecem válidos.

## Deep Links

A rota de Lesson consulta o mesmo resolver antes de chamar `start_lesson_progress`. Conteúdo bloqueado não vira 404: mostra `Esta aula ainda está bloqueada`, explica o pré-requisito e oferece CTA para a Lesson ou Checkpoint anterior.

A rota de Checkpoint valida disponibilidade antes de montar o hook que retoma ou inicia tentativa. O enforcement SQL repete os predicados críticos nos RPCs, evitando bypass do fluxo suportado por chamada direta.

## Study Today

Study Today consome `nextAction` do resolver. Ele sugere somente Lesson disponível/em andamento. Quando todas as Lessons do Topic foram concluídas, o Checkpoint disponível ou ativo substitui a lista de aulas como próximo passo natural. O estado de conclusão exige todos os Checkpoints concluídos, não apenas 100% das Lessons.

## Review

Internamente a experiência continua sendo `topic_quiz`; respostas incorretas continuam em `quiz_answers` e entram no Review existente. Não foi criada uma source duplicada `checkpoint`.

## Readiness

Readiness continua recebendo `topic_quiz` com os pesos e thresholds atuais. Lesson Quiz histórico permanece válido. A UI do resultado explicita que performance orienta Review e Readiness, mas não bloqueia a trilha.

## Data Model

Não foi criada coluna ou tabela. A migration `20260831010000_enforce_progressive_unlocking.sql` é necessária apenas para enforcement server-side:

- adiciona predicados derivados e owner-aware de disponibilidade;
- envolve `start_lesson_progress`, `complete_lesson_progress` e `start_topic_quiz`;
- preserva as implementações anteriores sob funções internas sem permissão de execução pelo cliente;
- mantém os nomes e retornos públicos usados pelo frontend.

## Security

Progressive unlocking é regra pedagógica, não proteção de conteúdo. RLS continua isolando dados de usuário. Os predicados usam somente `auth.uid()`; o cliente não fornece `user_id`. Funções internas sem validação tiveram execução revogada para `anon` e `authenticated`.

## Accessibility

Locks possuem ícone e texto; cor/opacidade não são o único sinal. Lesson bloqueada não é `<a>`. Checkpoint bloqueado não possui CTA funcional e explica quantas aulas faltam. Botões e links mantêm área mínima de toque, foco nativo e layout vertical responsivo em telas estreitas.

## Tests

Cobertura automatizada adicionada:

- resolver: aluno novo, first completion, mid Topic, last completion, Checkpoint locked/available/active, 45%, 95%, próximo Topic, próximo Domain, fim da certificação, legado e catálogo inválido;
- Study Path: estados bloqueado/disponível/concluído, ausência de link bloqueado, tamanho da tentativa e continue Checkpoint;
- Lesson Page: acesso permitido, Lesson Quiz ausente do fluxo primário e deep link bloqueado sem mutation;
- Topic Checkpoint: deep link bloqueado não inicia attempt;
- Study Today: fim de trilha e Checkpoint como próxima ação;
- Dashboard: CTA usa Checkpoint disponível, não Lesson bloqueada.

Validação final: 39 arquivos e 232 testes passaram; typecheck, lint, build, diff check e DB dry-run também passaram.

## Known Limitations

- Topic sem Lessons ou sem Questions é tratado como configuration blocker; a aplicação não inventa bypass automático.
- Lesson Quiz segue acessível por rota legada durante a depreciação.
- A 13.5.3 implementou Flashcards Home, Free Study sem scheduling e availability por Lesson completion, preservando o fluxo legado.
- Readiness ainda aceita Lesson Quiz histórico e será recalibrado apenas na etapa prevista pela arquitetura.
- Unlocking orienta a experiência educacional; não deve ser tratado como autorização de acesso a conteúdo sigiloso.

## Decision

```text
13.5.1 prerequisite: PASS
Architecture decision used: hard lock derivado + grandfathering monotônico
Lesson Quiz primary-flow status: HIDE_FROM_PRIMARY_FLOW
Progression strategy: completion/submission based
Progression state persisted: NO
Migration created: YES — enforcement RPC, sem estado novo
First Lesson: PASS
Sequential Lesson unlock: PASS
Checkpoint lock: PASS
Checkpoint unlock: PASS
Active Checkpoint: PASS
Low-score Checkpoint progression: PASS
High-score Checkpoint progression: PASS
Next Topic unlock: PASS
Next Domain unlock: PASS
Certification completion: PASS
Legacy compatibility: PASS
Deep-link behavior: PASS
Study Today: PASS
Dashboard: PASS
Review integration: PASS — source topic_quiz preservada
Readiness integration: PASS — evidência e configuração preservadas
Lesson Quiz historical compatibility: PASS
Flashcards regression: PASS
Mock regression: PASS
Mobile: PASS — layout responsivo e regressão de navegação aprovados
Accessibility: PASS
Typecheck: PASS
Lint: PASS
Tests: 232 / 232
Build: PASS — 1.855 modules transformed
git diff --check: PASS
DB dry run: PASS — migration detected, nothing applied
P0: 0
P1: 0
P2: 0
P3: 0
```

**AZ-900 Topic Checkpoint + Progressive Unlocking: READY**

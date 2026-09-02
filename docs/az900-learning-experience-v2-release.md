# AZ-900 Learning Experience V2

## Scope

Validação final e re-freeze executados em 2 de setembro de 2026 sobre a Fase 13.5 completa. Esta closure valida, documenta e congela a experiência AZ-900 antes da Fase 14. Nenhuma feature, AZ-204, Domain Quiz, Lab, novo Question Type, generalização de Mock ou recalibração ampla de Readiness foi criada.

| Item | Baseline |
| --- | --- |
| Branch | `master` |
| Commit auditado | `18a89e850ae32f120aa9cb4729e3de02fbe90e1f` |
| Currículo | 3 Domains, 12 Topics, 76 Lessons, 712 Content Blocks |
| Retenção | 397 Flashcards; 76/76 Lessons representadas |
| Avaliação | 512 Questions; 2.048 options; 439 mock-eligible |
| Mock | `az900-mock-v1`; 40 Questions; 11/15/14; 12/20/8; 3.600 s |
| Readiness | `az900-readiness-v1` |
| Recommendations | `az900-study-recommendations-v1` |
| Database | 109 migrations; remoto alinhado; 0 pendentes |

Pré-condições: Topic Checkpoint + Progressive Unlocking, Checkpoint Coverage + Sizing, Flashcards Experience, Content ↔ Flashcard Consistency e Question + Editorial Quality estão `READY`, todas com P0 = 0 e P1 = 0.

## Learning Model

```text
Lesson                              → Teach
Lesson Completion                   → Unlock next learning step
Flashcards                          → Recall
All Topic Lessons completed         → Unlock Checkpoint
Checkpoint                          → 12–20 Questions according to Topic size
Checkpoint selection                → Cover all Lessons when pool allows
Checkpoint errors                   → Review
Checkpoint performance              → Readiness
Checkpoint completion at any score  → Unlock next Topic
Mock                                → Whole-certification assessment
Readiness                           → Interpret learning evidence
Recommendations                     → Indicate the next useful study action
```

Completion/submission controla progressão. Performance controla remediação e Readiness. Nenhuma feature compete pelo mesmo papel.

## New Student Journey

Fixtures automatizadas confirmam zero Lessons concluídas, zero Checkpoints e ausência de histórico: Dashboard e Study Today apontam para a primeira Lesson; Lessons futuras e o primeiro Checkpoint permanecem bloqueados; Readiness mostra falta de evidência, não score zero; Flashcards futuros ficam fora dos counts disponíveis.

O walkthrough privado autenticado no navegador foi `NOT EXECUTED`: a sessão in-app disponível não possuía credenciais controladas. Não foi criado usuário persistente artificial nem alterado histórico real. O fluxo privado está coberto por testes DOM, resolver puro e validators SQL aplicados.

## Progressive Unlocking

- A primeira Lesson da trilha está disponível.
- `in_progress` não libera a seguinte; `completed` libera.
- A última Lesson concluída libera o Checkpoint do Topic.
- Checkpoint concluído com qualquer score libera a primeira Lesson do Topic seguinte.
- A transição atravessa Domains sem dead end.
- O último Checkpoint encerra a trilha guiada sem iniciar Mock automaticamente.
- Locks são derivados do currículo, progresso e attempts; não existe `is_unlocked` persistido.

Deep link de Lesson válida e bloqueada apresenta estado controlado, motivo e CTA para o pré-requisito. Deep link de Checkpoint bloqueado não inicia attempt. O backend repete os predicados de disponibilidade, impedindo bypass pelo cliente.

## Topic Checkpoint

O nome técnico `topic_quiz` foi preservado para histórico, Review e Readiness. A experiência apresenta `Checkpoint do Tópico`. Start, options, navegação, feedback, resume, submit, result, revisão de respostas e desempenho por Lesson permanecem server-backed.

O resultado oferece **Ir para a próxima aula** quando existe Topic seguinte, inclusive na fronteira de Domain. Nota baixa não bloqueia; ela produz erro para Review e evidência para Readiness.

## Checkpoint Dynamic Sizing

Fonte única: `calculate_topic_checkpoint_size(lesson_count, pool_count)` no PostgreSQL.

| Lessons publicadas | Alvo |
| ---: | ---: |
| 1–3 | 12 |
| 4–5 | 15 |
| 6+ | 20 |

O alvo nunca excede o pool. Nenhum novo attempt usa 10 fixo quando o pool comporta a configuração. Attempts existentes preservam seu snapshot original.

## Checkpoint Lesson Coverage

| Topic | Lessons | Lessons com pool | Pool elegível | Alvo | Tamanho validado | Cobertura possível | Cobertura atingida |
| --- | ---: | ---: | ---: | ---: | ---: | :---: | :---: |
| Cloud Computing | 7 | 7 | 72 | 20 | 20 | Sim | Sim |
| Benefits of Cloud Services | 7 | 7 | 61 | 20 | 20 | Sim | Sim |
| Cloud Service Types | 4 | 4 | 20 | 15 | 15 | Sim | Sim |
| Core Architectural Components | 7 | 7 | 42 | 20 | 20 | Sim | Sim |
| Compute Services | 9 | 9 | 51 | 20 | 20 | Sim | Sim |
| Networking Services | 5 | 5 | 30 | 15 | 15 | Sim | Sim |
| Storage Services | 8 | 8 | 46 | 20 | 20 | Sim | Sim |
| Identity, Access, and Security | 9 | 9 | 50 | 20 | 20 | Sim | Sim |
| Cost Management | 4 | 4 | 30 | 15 | 15 | Sim | Sim |
| Governance and Compliance | 3 | 3 | 15 | 12 | 12 | Sim | Sim |
| Resource Management and Deployment | 7 | 7 | 55 | 20 | 20 | Sim | Sim |
| Monitoring | 6 | 6 | 40 | 20 | 20 | Sim | Sim |

Resumo: 12 Topics; média do pool 42,67; distribuição 12/15/20 = 1/3/8; Topics abaixo do target = 0; Lessons sem Questions elegíveis = 0. O validator aplicado também cobre fixture desigual com uma Lesson de pool pequeno e uma Lesson de pool zero: a pequena participa e a vazia não bloqueia.

## Checkpoint Retake Rotation

Ordem: cobertura obrigatória → unseen → fora do attempt anterior → least recent → dificuldade e ordem editorial como desempate. Não há duplicata na tentativa.

- Networking Services, pool 30/alvo 15: overlap Attempt 1 × Attempt 2 = 0.
- Benefits of Cloud Services, pool 61/alvo 20: a terceira tentativa mantém as sete Lessons, usa pelo menos 13 Questions inéditas e só repete quando necessário para cobrir Lesson cujo pool individual já foi esgotado.
- O histórico inteiro, não apenas o attempt anterior, participa da seleção.

## Flashcards

Flashcards possuem hub próprio, item de navegação, overview, Daily Review e catálogo Domain → Topic. `disponíveis de total` distingue cards liberados de todo o catálogo. Cards liberam após completion da Lesson; um card com histórico anterior permanece disponível por grandfathering sem liberar toda a Lesson.

O reparo `20260901020000_fix_flashcard_review_overview.sql` removeu o erro 400 do overview, manteve o contrato e validou a chamada com fixture autenticada descartada em subtransação.

## Free Study

Free Study carrega somente cards publicados e disponíveis no escopo Certification + Topic ou Lesson. Reveal/next não chama `submit_flashcard_review`, não cria progresso e não altera scheduling.

## Spaced Repetition

Daily Review mantém até 20 cards, prioriza due e limita novos a 5. Ratings `again/hard/good/easy`, intervalos, persistence, próxima revisão e conclusão permanecem server-owned. Free Study e Daily Review não compartilham efeitos colaterais.

## Review

Review corrige erros de avaliações. Erros de Checkpoint preservam Topic, Question, selected/correct option e explanation e alimentam Review Quiz. Flashcards não dominam essa tela. Mock possui Review próprio baseado em snapshot.

## Question Quality

| Métrica | Resultado final |
| --- | ---: |
| Questions / options | 512 / 2.048 |
| Mock-eligible | 439 |
| Erros estruturais | 0 |
| A/B/C/D editorial | 228 / 211 / 73 / 0 |
| Correta é a mais longa | 266/512 — 51,95% |
| Correta > 1,5× distractors | 92/512 — 17,97% |
| Posição correta global | 128 / 128 / 128 / 128 |
| Weak/obviously wrong confirmado | 0 |
| Content → Question | 512 SUPPORTED |

Os 392 candidatos quantitativos são fila de manutenção, não defeitos confirmados. Não houve manipulação da answer key para buscar distribuição artificial.

## Portuguese Editorial Quality

O validator encontrou zero ocorrência conhecida nos campos human-facing auditados. Questions, options e explanations foram corrigidas in-place; UUIDs, slugs, termos oficiais e snapshots históricos foram preservados. Smoke de Login, navegação, estados de Checkpoint e Flashcards não mostrou erro óbvio de acentuação.

## Mock Exam

Start, timer, 40 Questions, answers, resume, submit, result, review, history e retake passaram. Checkpoint 12/15/20 não alterou Mock 40, Domain allocation 11/15/14, dificuldade 12/20/8, timer de 3.600 s ou `az900-mock-v1`. Attempts históricos usam snapshots imutáveis.

## Readiness

Readiness recebe Checkpoints, Lesson Quiz histórico e Mock; Review Quiz continua com peso zero. O aumento do Checkpoint cria mais evidência, mas thresholds não foram alterados silenciosamente.

Um teste de regressão específico confirma que um único Checkpoint de 20 Questions, mesmo com 90%, permanece com uma sessão, não torna o Topic nem o estado global `strong` e mantém `no_finalized_mock`. Strong ainda exige volume amplo, múltiplas sessões, cobertura de Domains, consistência, recência e pelo menos três Mocks.

## Recommendations

As recomendações permanecem determinísticas e apontam para rotas reais de Lesson, Flashcards, Checkpoint ou Mock. Não promovem Lesson Quiz legado. Ausência de pool/card impede CTA enganoso; atividade histórica posterior aciona grandfathering antes que uma recomendação possa levar a conteúdo hoje sequencialmente anterior.

## Study Today

Novo aluno recebe a primeira Lesson; mid Topic recebe a próxima Lesson válida; Topic concluído recebe `Fazer Checkpoint`; attempt ativo recebe `Continuar Checkpoint`; currículo concluído oferece Flashcards, Review e Mock sem iniciar avaliação automaticamente.

## Dashboard

Fixtures de novo aluno, mid Topic e Checkpoint disponível confirmam que o CTA principal usa a próxima ação do resolver. Não há CTA para Lesson bloqueada, Lesson Quiz deprecated ou rota antiga de Flashcards.

## Progress

`Progresso de estudo` continua medindo Lessons/currículo. Checkpoint não é transformado em Lesson para inflar percentual. Readiness permanece métrica separada de evidência.

## Legacy Compatibility

- Lesson/Checkpoint iniciado ou concluído continua acessível.
- Atividade fora da sequência preserva o prefixo necessário por grandfathering monotônico.
- Lesson Quiz histórico continua em Review, Readiness e Recommendations sem voltar ao fluxo principal.
- Attempt ativo legado de 10 Questions é retomado com o mesmo UUID, tamanho e conjunto.
- Topic Quiz histórico conta como Checkpoint concluído, independentemente do score.
- Flashcard com histórico preserva acesso e schedule.
- Mock histórico preserva snapshots e answer key.

## Security

RPCs novas derivam owner de `auth.uid()`, não aceitam `user_id` do cliente e usam `SET search_path = ''`. Helpers unchecked não são executáveis por `anon`/`authenticated`. Score, answer key, scheduling e lifecycle permanecem server-owned. Erros exibidos pela UI são genéricos e não expõem SQL, stack ou secrets.

## RLS

Progress, Quiz, Flashcards e Mock permanecem owner-only por RLS/RPC. Testes de troca de usuário remontam a árvore privada e descartam estado antigo. Validators SQL autenticados foram executados durante o deployment das migrations de sizing e overview.

Execução fresh completa e teste SQL A/B ad hoc nesta rodada: `NOT EXECUTED`, pois Docker e Podman não estão instalados. Essa limitação não foi convertida em PASS fictício.

## Mobile

O smoke real em 390×844 confirmou `innerWidth = scrollWidth = 390`, sem overflow e sem erro/warning de aplicação. A rota privada terminou em Login corretamente. O fluxo privado responsivo é coberto por testes de navegação, Lesson, Checkpoint, Viewer, Review, Mock e Readiness; walkthrough visual privado autenticado: `NOT EXECUTED` por ausência de credencial controlada.

## Accessibility

Há headings, labels, radios, progressbars, dialogs, estados textuais além de cor, links bloqueados removidos, botões com nomes explícitos e retorno de foco no menu mobile. Flashcard Viewer e ratings possuem controles semânticos. Axe automatizado permanece como dívida P3.

## Performance

| Artefato | Baseline anterior | Final | Variação |
| --- | ---: | ---: | ---: |
| Main JS | 431,80 kB / 124,15 gzip | 431,94 kB / 124,20 gzip | +0,14 / +0,05 kB |
| Maior async (`schemas`) | 74,80 / 20,00 gzip | 74,80 / 20,00 gzip | 0 |
| Lesson | 53,79 / 13,70 gzip | 53,79 / 13,70 gzip | 0 |
| Readiness | 48,54 / 13,71 gzip | 48,54 / 13,71 gzip | 0 |
| CSS | 51,96 / 8,92 gzip | 51,96 / 8,92 gzip | 0 |

Build: 1.858 módulos; nenhum warning de chunk acima de 500 kB. Catálogo, progressão, Flashcards, Readiness e Mock mantêm consultas batched; nenhum N+1 crítico foi introduzido.

## Database

As seis migrations da Fase 13.5 foram adicionadas em um único commit; o diff contra o pai mostra somente status `A`, sem edição de histórico:

1. `20260831010000_enforce_progressive_unlocking.sql`;
2. `20260831020000_add_flashcards_experience.sql`;
3. `20260831030000_align_flashcards_with_lesson_content.sql`;
4. `20260831040000_audit_az900_question_editorial_quality.sql`;
5. `20260901010000_improve_topic_quiz_checkpoint_selection.sql`;
6. `20260901020000_fix_flashcard_review_overview.sql`.

Não houve reset de histórico ou troca de Question, Option ou Flashcard UUID. O dry-run remoto retornou `upToDate: true`, `migrations: []`, `seeds: []`, `roles: []`.

## Remaining Content Debt

`Checkpoint Question Coverage Debt`: nenhum — 76/76 Lessons possuem Questions elegíveis.

Débitos não bloqueantes:

- P2: schema fresh e SQL A/B ad hoc não executados sem container runtime;
- P2: walkthrough visual privado autenticado não executado sem credencial controlada;
- P2: rewrite SPA permanece responsabilidade do host de produção;
- P3: sem axe automatizado;
- P3: sem observabilidade externa;
- P3: 392 sinais quantitativos de Questions e 32 candidatos lexicais não semânticos permanecem no backlog;
- P3: rotas históricas de Lesson Quiz e `/review/flashcards` permanecem por compatibilidade deliberada.

## Regression Contract V2

### Learning

- Study Today, Study Path, Lesson Completion e progressive unlocking usam a mesma ordem curricular.
- Checkpoint desbloqueia após todas as Lessons e libera o próximo Topic com qualquer score.
- Sizing, Lesson coverage e retake rotation permanecem server-owned.

### Retention

- Flashcards Home separa Free Study de Daily Review.
- Free Study não altera schedule; spaced repetition mantém due/new/ratings.
- Conteúdo bloqueado não entra em sessões ou counts; histórico tem grandfathering restrito ao card.

### Remediation

- Review trata erros de Questions; Review Quiz preserva esse ciclo.
- Flashcards e Mock Review continuam experiências distintas.

### Assessment

- Mock mantém configuração e snapshots AZ-900.
- Readiness interpreta evidência, nunca controla lock e não produz false Strong.

### Platform

- Auth, RLS, user isolation, Certification scope, navigation, progress e compatibilidade histórica são obrigatórios.
- Gates mínimos: typecheck, lint, todos os testes, build, diff check, validators e DB dry-run.

## Multi-Certification Constraints

A Fase 14 não pode hardcodar universalmente 12/15/20. Essa política pertence hoje ao modelo AZ-900 e poderá virar Certification Configuration somente durante a arquitetura multi-certification. Também permanecem específicos e congelados: `az900-mock-v1`, `az900-readiness-v1`, `az900-study-recommendations-v1`, pesos, pools, timer e conteúdo.

Generalizar implementação não autoriza mudar resultados AZ-900, UUIDs, histórico, snapshots, routes ou a separação pedagógica V2. Qualquer mudança exige versão e closure explícitas.

## Blockers

| Prioridade | Quantidade | Estado |
| --- | ---: | --- |
| P0 | 0 | Nenhum leak, corrupção, scoring incorreto ou quebra de isolamento confirmado |
| P1 | 0 | Nenhum fluxo principal, Mock, Readiness, Auth ou banco bloqueado |
| P2 | 3 | Limitações de ambiente/hosting registradas em Remaining Content Debt |
| P3 | 4 | Melhorias de validação, observabilidade e manutenção não bloqueantes |

## Final Validation Report

```text
13.5.2 Progressive Unlocking: PASS
13.5.2.1 Checkpoint Sizing: PASS
13.5.3 Flashcards: PASS
13.5.4 Flashcard Consistency: PASS
13.5.5 Question + Editorial: PASS
New Student: PASS-AUTO
Lesson Completion: PASS-AUTO
Sequential Unlocking: PASS-AUTO/SQL
Locked Deep Links: PASS-AUTO
Checkpoint Lock: PASS-AUTO/SQL
Checkpoint Unlock: PASS-AUTO/SQL
Dynamic Checkpoint Sizing: PASS-SQL
1–3 Lesson Topics: PASS-SQL
4–5 Lesson Topics: PASS-SQL
6+ Lesson Topics: PASS-SQL
Small Question Pools: PASS-SQL
Lesson Coverage: PASS-SQL
Retake Rotation: PASS-SQL
Legacy 10-Question Attempts: PASS-SQL
Active Legacy Attempt: PASS-SQL
Low Score Progression: PASS-AUTO
Next Topic: PASS-AUTO
Next Domain: PASS-AUTO
Flashcards Home: PASS-AUTO
Free Study: PASS-AUTO
Daily Review: PASS-AUTO/SQL
Flashcard ↔ Lesson: PASS-EDITORIAL — 397/397 SUPPORTED
Review: PASS-AUTO
Question Quality: PASS-VALIDATOR
Portuguese: PASS-VALIDATOR/SMOKE
Study Today: PASS-AUTO
Dashboard: PASS-AUTO
Progress: PASS-AUTO
Mock: PASS-AUTO
Historical Mock: PASS-AUTO/SQL
Readiness: PASS-AUTO
Readiness after larger Checkpoints: PASS-AUTO
False Strong Safeguards: PASS-AUTO
Recommendations: PASS-AUTO
Legacy User: PASS-AUTO/SQL
Auth: PASS-AUTO/SMOKE
User Isolation: PASS-AUTO — SQL A/B ad hoc desta rodada NOT EXECUTED
Certification Scope: PASS-AUTO/STATIC
Mobile: PASS-AUTO/PUBLIC-SMOKE — private authenticated walkthrough NOT EXECUTED
Accessibility: PASS-AUTO/PUBLIC-SMOKE
Performance: PASS
Database: PASS
Typecheck: PASS
Lint: PASS — zero warnings
Tests: 248 / 248
Build: PASS — 1.858 módulos
git diff --check: PASS
DB dry run: PASS — remote up to date; zero pendências
P0: 0
P1: 0
P2: 3
P3: 4
```

## Final Decision

A pergunta central recebe resposta positiva: a plataforma ensina primeiro, reforça depois, avalia o conhecimento e usa erros/evidências para orientar o estudo. O contrato V2 está coberto por testes, validators, migrations aplicadas e documentação; as limitações restantes não são P0/P1.

**AZ-900 Learning Experience V2: RELEASE READY**

**AZ-900 Learning Experience V2 Baseline: FROZEN**

**Multi-Certification Refactor Gate: OPEN**

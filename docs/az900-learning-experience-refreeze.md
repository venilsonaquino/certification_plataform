# AZ-900 Learning Experience V2 — Final Validation + Re-Freeze

## Contexto

Validação final executada em 1º de setembro de 2026 após as ETAPAS 13.5.1–13.5.5. O objetivo desta closure é congelar a experiência pedagógica AZ-900 V2 antes da refatoração multi-certificação, sem iniciar a Fase 14 e sem generalizar código, dados ou configuração.

Baseline técnica auditada:

| Item | Valor |
| --- | --- |
| Branch | `master` |
| Commit HEAD de referência | `aa053980b2a17d33ea67587b0dac75ee5374411b` |
| Estado Git | worktree com as ETAPAS 13.5.1–13.5.6 ainda não commitadas/taggeadas |
| Currículo | 3 Domains, 12 Topics, 76 Lessons, 712 Content Blocks |
| Prática | 397 Flashcards, 512 Questions, 2.048 alternativas |
| Mock | 439 Questions elegíveis; política `az900-mock-v1` |
| Readiness | `az900-readiness-v1`; recommendations `az900-study-recommendations-v1` |
| Migrations | 107 arquivos locais; banco vinculado alinhado; 0 pendentes |

## Pre-Conditions

| Pré-requisito | Estado |
| --- | --- |
| `az900-learning-flow-architecture.md` | READY; P0 = 0; P1 = 0 |
| `az900-topic-checkpoint-progressive-unlocking.md` | READY; P0 = 0; P1 = 0 |
| `az900-flashcards-experience.md` | READY; P0 = 0; P1 = 0 |
| `az900-flashcard-content-consistency.md` | READY; 397/397 `SUPPORTED`; P0 = 0; P1 = 0 |
| `az900-question-editorial-audit.md` | READY; D = 0; `NOT_SUPPORTED` = 0; P0 = 0; P1 = 0 |
| `az900-release-closure.md` | release closure anterior aprovada |
| `production-hardening.md` | READY; P0 = 0; P1 = 0 |

Gate de entrada: **PASS**.

## User Fixtures

As fixtures controladas são determinísticas e não dependem de dados pessoais reais:

| Fixture | Estado simulado | Evidência principal |
| --- | --- | --- |
| A — New Student | sem progresso ou attempts | resolver + Readiness + UI |
| B — Mid Topic | primeira Lesson `completed`; seguinte disponível | resolver + Study Path |
| C — Topic Completed | todas as Lessons concluídas; Checkpoint disponível | resolver + Study Today + Dashboard |
| D — Low Checkpoint | attempt concluído com 45% | resolver parametrizado |
| E — Strong Checkpoint | attempt concluído com 95% | resolver parametrizado |
| F — Legacy Student | Lesson/Checkpoint fora de sequência e histórico antigo | grandfathering do resolver |
| G — Certification Complete | todas as Lessons e Checkpoints concluídos | resolver + Study Today |
| H — Flashcards Due | cards vencidos e novos já elegíveis | Viewer/overview/queue mocks |
| I — Locked Flashcard | Lesson não concluída e nenhum progresso legado do card | UI + RPC contract estático |

As jornadas privadas foram validadas com Vitest/Testing Library e contratos SQL versionados. Não havia credenciais de usuário controlado para um walkthrough autenticado no navegador; nenhum PASS manual privado foi inventado.

## End-to-End Journeys

1. **Novo aluno:** Dashboard/Study Today apontam somente para a primeira Lesson; demais Lessons e Checkpoint aparecem bloqueados e sem link funcional.
2. **Progressão:** completar a Lesson libera a próxima; concluir todas as Lessons do Topic torna o Checkpoint a próxima ação; nenhuma nota mínima participa do unlock.
3. **Checkpoint:** 45% e 95% concluem igualmente a etapa e liberam o próximo Topic; o resultado continua alimentando Review/Readiness; attempt ativo é retomável; retake e histórico técnico de `topic_quiz` permanecem.
4. **Flashcards:** completion da Lesson libera seus cards; Free Study usa flip/next sem gravar scheduling; Daily Review prioriza due, limita novos e persiste ratings; cards legados com histórico permanecem acessíveis.
5. **Assessment:** erros de Checkpoint/Review alimentam Revisão; Mock preserva 40 Questions, timer, snapshots, resume, submit, result, review, history e retake; Readiness interpreta evidência sem controlar progressão nem prometer aprovação.
6. **Fim da trilha:** o último Checkpoint encerra a jornada guiada e oferece continuidade por Revisão, Flashcards e Simulados, sem iniciar Mock automaticamente.

## Validation Matrix

Legenda: `PASS-AUTO` = suíte executada; `PASS-BROWSER` = navegador executado; `PASS-STATIC` = código/SQL inspecionado; `NOT EXECUTED` = ambiente indisponível.

| Área | Caso | Resultado | Evidência |
| --- | --- | --- | --- |
| Progression | aluno novo, mid Topic e sequência de Lessons | PASS-AUTO | `studyProgression.test.ts` |
| Progression | Checkpoint bloqueado/disponível/ativo | PASS-AUTO | resolver, Study Path e Topic Checkpoint page |
| Progression | score baixo 45% e alto 95% | PASS-AUTO | teste parametrizado; ambos liberam próximo Topic |
| Progression | transição entre Domains e último Checkpoint | PASS-AUTO | resolver e estado de fim de trilha |
| Legacy | progresso fora de ordem e Checkpoint histórico | PASS-AUTO | grandfathering monotônico |
| Deep links | Lesson/Checkpoint bloqueados sem mutation/bypass no cliente | PASS-AUTO | páginas e links bloqueados |
| Server lock | wrappers de Lesson/Checkpoint owner-aware | PASS-STATIC | migration `20260831010000` |
| Retake | Topic Checkpoint rotation/history | PASS | validator SQL de rotação da baseline já aplicada; engine não alterada |
| Flashcards | Home, Domain/Topic, counts e empty states | PASS-AUTO | páginas e service tests |
| Flashcards | Free Study sem escrita | PASS-AUTO | Viewer e Topic session |
| Flashcards | Daily Review, due/new, rating e retorno | PASS-AUTO | Viewer/Review page/hook |
| Flashcards | card de Lesson bloqueada excluído; legado preservado | PASS-STATIC/AUTO | RPC + estados de UI |
| Review | somente remediação por erros; vazio e erro distintos | PASS-AUTO | Review engine/regressão |
| Mock | start, execução, persistência, resume, timer e submit | PASS-AUTO | suíte Mock |
| Mock | result, review, history, retake e answer-key isolation | PASS-AUTO | suíte Mock + schema DTO |
| Readiness | New/Weak/Improving/Strong/Lucky/Stale | PASS-AUTO | 31 fixtures finais + engine |
| Readiness | progressão separada de performance | PASS-AUTO | Readiness e Progress pages |
| Recommendations | ações reais e determinísticas | PASS-AUTO | engine/service/UI |
| Navigation | oito itens canônicos; Lesson Quiz/Flashcards fora do fluxo primário | PASS-AUTO | navigation/Lesson tests |
| Routes | rotas legadas preservadas; CTA sem destino morto | PASS-AUTO/STATIC | router + helpers + page tests |
| Certification | queries novas recebem Certification explícita | PASS-AUTO/STATIC | Flashcard services/RPCs |
| User | hooks descartam resposta antiga e estado troca por owner | PASS-AUTO | Auth/Readiness/Flashcard hooks |
| Mobile | menu por teclado e componentes responsivos privados | PASS-AUTO | navigation/visual/page tests |
| Mobile público | 390×844, `innerWidth = scrollWidth = 390`, CTA 48 px | PASS-BROWSER | Login após deep link privado |
| Accessibility | headings, labels, radios, estados textuais, foco e teclado | PASS-AUTO/BROWSER | componentes e Login |
| Empty/error | catálogo vazio, conteúdo bloqueado, retry e Error Boundary | PASS-AUTO | páginas, renderer e boundary |
| Performance | lazy routes, consultas batched, sem warning de chunk | PASS | build e service tests |
| Editorial | Questions e Flashcards sem erro estrutural/confirmado | PASS | validadores permanentes |
| DB dry-run | histórico remoto alinhado, sem seeds/roles | PASS | `upToDate: true`; 0 migrations pendentes |
| Schema fresh | migrations desde zero | NOT EXECUTED | Docker/Podman indisponíveis |
| SQL A/B | isolamento runtime entre dois usuários | NOT EXECUTED | Docker/Podman indisponíveis |

## Bugs Found

| ID | Prioridade | Problema | Estado |
| --- | --- | --- | --- |
| LX-01 | P3 | Readiness ainda mostrava `Topic Quiz/Lesson Quiz` e Revisão usava `Quiz` genérico após o rebrand | FIXED |
| LX-02 | P3 | BrowserRouter e cinco harnesses de teste emitiam warnings dos future flags do React Router | FIXED |

Nenhum bug P0, P1 ou P2 foi confirmado nesta rodada.

## Fixes Applied

- Microcopy de Readiness alinhada a `Checkpoint`, `tópico`, `domínio` e evidência histórica de Quiz de aula.
- Empty state de Revisão diferencia Checkpoint e quiz de revisão.
- `BrowserRouter` habilita os dois flags de compatibilidade já exercitados pela suíte.
- MemoryRouters adicionados nas ETAPAS 13.5.2/13.5.3 usam os mesmos flags, eliminando warnings do gate.
- Nenhum schema, scoring, unlock, scheduling, Question, Flashcard, UUID ou histórico foi alterado na 13.5.6.

## Regression Contract

Durante qualquer trabalho futuro, permanecem obrigatórios:

- `Lesson teaches → Flashcard recalls → Checkpoint evaluates → Review remediates → Mock evaluates → Readiness interprets`;
- completion/submission controla progressão; score controla somente remediação e Readiness;
- primeira Lesson disponível, sequência por completion, Checkpoint após todas as Lessons e próximo Topic após qualquer score;
- locks derivados, owner-aware, sem `is_unlocked` persistido e com grandfathering monotônico;
- Lesson Quiz e Flashcards por Lesson fora do fluxo primário, com deep links/histórico legados preservados;
- Free Study sem scheduling; Daily Review com due/new/ratings; cards bloqueados fora de filas e counts;
- Review de Questions separado de Flashcards e Mock Review;
- Mock e Readiness sem claims oficiais, gabarito durante attempt ou false Strong;
- UUIDs, answer keys, snapshots e históricos imutáveis;
- rotas inválidas/deep links seguros, estados vazio/erro distintos e navegação mobile acessível.

## Performance

Build final:

| Artefato | Minificado | Gzip |
| --- | ---: | ---: |
| Main JS | 431,80 kB | 124,15 kB |
| `schemas` | 74,80 kB | 20,00 kB |
| Lesson | 53,79 kB | 13,70 kB |
| Readiness | 48,54 kB | 13,71 kB |
| CSS | 51,96 kB | 8,92 kB |

Foram transformados 1.858 módulos. Não houve warning de chunk acima de 500 kB. Catálogo, Readiness, recommendations, Flashcards e Mock mantêm consultas batched; os testes de service confirmam ausência de N+1 nos contratos auditados.

## Security

- RPCs novas derivam owner de `auth.uid()` e não aceitam `user_id` do cliente.
- Helpers unchecked perderam grants para `public`, `anon` e `authenticated`.
- Certification/Topic/Lesson permanecem validados no mesmo escopo das consultas.
- RLS, score server-owned, snapshots e answer-key isolation não foram alterados.
- Deep links privados redirecionam para Login sem renderizar conteúdo protegido.
- SQL A/B desta rodada: **NOT EXECUTED**, por ausência factual de Docker/Podman.

## Mobile

- Navegação privada: regressão automatizada de oito itens, abertura/fechamento por teclado e retorno de foco.
- Login real no navegador: 390×844, sem overflow horizontal, inputs e botão com 48 px, layout estável.
- Deep link privado e rota inválida: ambos terminaram em `/login` sem tela branca.
- Console final: 0 errors, 0 warnings.

## Accessibility

Os testes cobrem heading hierarchy, nomes acessíveis, labels, radios, progressbars, dialogs, estados não dependentes apenas de cor, foco do menu e navegação por teclado. O smoke confirmou labels e `autocomplete=email/current-password`. Não há axe automatizado; isso permanece dívida de melhoria, não defeito observado.

## Content/Editorial

| Gate | Resultado |
| --- | --- |
| Flashcards | 397 publicados; 76 Lessons; 0 erro estrutural; 0 candidato editorial confirmado |
| Flashcard semantic support | 397 `SUPPORTED`; 0 parcial/não suportado/ambíguo |
| Questions | 512 publicadas; 2.048 options; 0 erro estrutural; D = 0 |
| Mock pool | 439 elegíveis; cobertura preservada |
| Posição correta | 128/128/128/128 global |
| Português conhecido | 0 ocorrências |
| Content → Question | 512 `SUPPORTED` |

Os 392 sinais quantitativos de Questions e 32 candidatos lexicais não semânticos de Flashcards continuam como filas de manutenção, não como defeitos confirmados.

## Data/Migrations

Migrations aplicadas no Supabase vinculado após autorização explícita:

1. `20260831010000_enforce_progressive_unlocking.sql`;
2. `20260831020000_add_flashcards_experience.sql`;
3. `20260831030000_align_flashcards_with_lesson_content.sql`;
4. `20260831040000_audit_az900_question_editorial_quality.sql`.

O dry-run de confirmação retornou `dryRun: true`, `upToDate: true`, `migrations: []`, `seeds: []` e `roles: []`. A ETAPA 13.5.6 não criou migration.

## Remaining Debt

P0 = 0. P1 = 0.

| Prioridade | Item |
| --- | --- |
| P2 | Schema fresh e SQL A/B não executados por ausência de Docker/Podman |
| P2 | Fallback SPA ainda depende de rewrite no host de produção |
| P2 | Baseline está em worktree; não existe commit/tag exclusivo das ETAPAS 13.5.x |
| P3 | Sem axe automatizado |
| P3 | Sem observabilidade externa |
| P3 | 392 sinais quantitativos e 32 candidatos lexicais permanecem no backlog editorial não bloqueante |
| P3 | Rotas/histórico de Lesson Quiz e URL antiga de Flashcards permanecem por compatibilidade deliberada |

## Multi-Certification Regression Contract

A Fase 14 pode generalizar implementação, mas não pode alterar o resultado AZ-900 congelado:

1. Preservar os 3 Domains, 12 Topics, 76 Lessons, 712 blocks, 397 Flashcards, 512 Questions e 439 mock-eligible.
2. Tornar configuração certification-scoped sem mudar `az900-mock-v1`, `az900-readiness-v1` ou `az900-study-recommendations-v1`.
3. Preservar Mock 40 / 11-15-14 / 12-20-8 / 3.600 s e seus snapshots.
4. Preservar a progressão V2 e o grandfathering sem criar bypass cross-certification ou cross-user.
5. Preservar disponibilidade e scheduling de Flashcards por Certification, Lesson e owner.
6. Preservar Review, Readiness e Recommendations para evidência histórica de `lesson_quiz` e atual de `topic_quiz`.
7. Preservar todas as rotas públicas/privadas e compatibilidades legadas enquanto houver histórico dependente.
8. Manter UUIDs e relações de conteúdo; nenhuma migração de generalização pode recriar Questions, Options ou Flashcards.
9. Executar, no mínimo: typecheck, lint, 242 testes ou mais, build, diff check, validadores editorial/Flashcards, DB dry-run e SQL A/B quando o runtime estiver disponível.
10. Qualquer divergência AZ-900 exige versão/configuração nova e closure explícita; não pode ser consequência incidental da abstração.

## Final Gates

```text
Typecheck: PASS
Lint: PASS — zero warnings
Tests: PASS — 44 / 44 arquivos; 242 / 242 testes
Build: PASS — 1.858 módulos; main 431,80 kB / 124,15 kB gzip
git diff --check: PASS — apenas avisos ambientais LF/CRLF
Question validator: PASS — 512 Questions; 2.048 options; D = 0
Flashcard validator: PASS — 397 cards; 0 erro estrutural/editorial confirmado
Browser smoke: PASS — guard, rota inválida, 390×844, zero overflow, zero console warnings/errors
DB dry run: PASS — remote database up to date; 0 migrations pendentes
Schema fresh: NOT EXECUTED — Docker/Podman indisponíveis
SQL A/B: NOT EXECUTED — Docker/Podman indisponíveis
P0: 0
P1: 0
P2: 3
P3: 4
```

## Final Decision

A baseline AZ-900 Learning Experience V2 está funcionalmente pronta, implantada no banco vinculado e protegida por contrato de regressão. O freeze se refere a comportamento, conteúdo, identidade e resultados; o worktree ainda não foi commitado/taggeado.

**AZ-900 Learning Experience V2: RELEASE READY**

**AZ-900 Learning Experience V2 Baseline: FROZEN**

**Multi-Certification Refactor Gate: OPEN**

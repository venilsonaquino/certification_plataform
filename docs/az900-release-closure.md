# AZ-900 Release Closure

## Release Scope

Release gate executado em **31 de agosto de 2026** para congelar a baseline comportamental da experiência **Microsoft Azure Fundamentals (AZ-900)** antes de qualquer generalização multi-certificação.

Esta closure valida o produto existente. Não adiciona funcionalidades, conteúdo, AZ-204, capabilities, tabelas de configuração, Labs, Story Mode ou Map.

Metadata da baseline:

| Item | Valor |
| --- | --- |
| Data | 2026-08-31 |
| Branch | `master` |
| Commit HEAD | `04b19e32fd6d1adf897e73d13bf40f84f4d8334a` |
| Estado Git | Working tree contém o hardening 13.3 e este documento; checkpoint ainda não commitado/taggeado |
| Testes | 215/215 em 35 arquivos |
| Migrations | 103 arquivos; remoto atualizado; 0 pendentes |
| Readiness calculation version | `az900-readiness-v1` |
| Study recommendation version | `az900-study-recommendations-v1` |
| Mock selection policy | `az900-mock-v1` |

Closures revalidados por documentação e código:

| Closure | Evidência | Estado |
| --- | --- | --- |
| Navigation Cleanup | `docs/product-navigation-cleanup.md` e testes canônicos de navegação | PASS |
| Product Acceptance | `docs/az900-product-acceptance.md` | PASS |
| Production Hardening | `docs/production-hardening.md` | PASS |
| Curriculum/Content | `docs/az900-content-coverage.md` e `docs/az900-global-readiness-audit.md` | PASS |
| Mock Exam | `docs/az900-mock-exam-validation.md` | PASS |
| Readiness | `docs/az900-readiness-final-validation.md` | PASS |

## Supported Features

A baseline AZ-900 suporta:

- autenticação por login, cadastro, refresh de sessão e logout;
- seleção de certificação com AZ-900 habilitada e certificação inválida tratada com estado seguro;
- Dashboard da certificação;
- Estudo do Dia para aluno novo, parcial e currículo concluído;
- Trilha de estudos com 3 Domains, 12 Topics e 76 Lessons;
- Lessons com conteúdo estruturado e fallback legado;
- Content Blocks, mídia, Visual Experiences e Azure Lab blocks embutidos;
- conclusão e progresso de Lesson;
- Lesson Quiz;
- Topic Quiz com rotação de retake;
- Flashcards por Lesson;
- revisão espaçada de Flashcards;
- revisão de erros e Review Quiz;
- Practice Mock com seleção, execução, timer, persistência, resume, submit, expiração, resultado, review, histórico e retake;
- Readiness, evidência, weak topics, tendência e recomendações determinísticas;
- Progresso de estudo separado de Readiness.

## Unsupported/Future Features

Continuam fora da experiência pronta:

- Map;
- Labs Page independente;
- Story Mode;
- Quiz genérico;
- AZ-204;
- arquitetura/capabilities multi-certificação;
- configuração genérica de Mock ou Readiness.

Map, Labs Page, Story Mode e Generic Quiz não estão na sidebar, navegação mobile, Dashboard, CTAs ou router principal. Os Lesson, Topic e Review Quizzes permanecem porque são fluxos reais e especializados.

## Curriculum

A cobertura oficial normalizada permanece:

| Domain | Topics | Lessons | Objectives Covered | Partial | Missing | Minutes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Describe cloud concepts | 3 | 18 | 15 | 0 | 0 | 184 |
| Describe Azure architecture and services | 5 | 38 | 27 | 0 | 0 | 410 |
| Describe Azure management and governance | 4 | 20 | 15 | 0 | 0 | 224 |
| **Total** | **12** | **76** | **57** | **0** | **0** | **818** |

Todas as Lessons estão publicadas, ordenadas, associadas a Topic/Domain e possuem fallback `lessons.content`. Os validadores SQL curriculares versionados cobrem estrutura, cobertura, conteúdo, Questions, Flashcards, navegação, persistência e referências órfãs. Nenhum objetivo desapareceu desde a closure 10.4.

## Content

Baseline de conteúdo:

- 712 Content Blocks publicados;
- 17 Visual Experiences;
- 397 Flashcards;
- 512 Questions;
- 76 summaries e fallback legado preservado.

Tipos reais de Content Block:

`explanation`, `important`, `example`, `dotnet_example`, `exam_tip`, `exam_trap`, `summary`, `image`, `video`, `visual_experience` e `azure_lab`.

`comparison` é um tipo de Visual Experience, não um Content Block independente. Renderer, validação Zod, fallback de block inválido, conteúdo legado, visual responsivo e isolamento de falha possuem testes automatizados. Nenhum tipo foi criado nesta etapa.

## Lesson Quiz

- Uma tentativa seleciona Questions da Lesson correta.
- Resposta, score, explanation, resultado, retake e retorno à Lesson usam a engine existente.
- A closure curricular validou as 76 Lesson Quizzes com cinco Questions cada.
- A conclusão de Lesson e o Quiz continuam independentes e persistentes.

Status: **PASS**.

## Topic Quiz

- Os 12 Topics possuem seleção distribuída entre suas Lessons.
- Retake usa histórico por usuário, prioriza unseen e minimiza overlap.
- A dificuldade alvo permanece 3 easy / 5 medium / 2 hard em dez itens.
- `Cloud Service Types` e `Governance and Compliance` mantêm o overlap mínimo inevitável documentado pelo tamanho do pool; não há FAIL.

Status: **PASS**.

## Flashcards

- 397 cards publicados e associados a Lessons válidas;
- frente/verso, dica, reveal, rating, resumo e retorno testados;
- fila vencida/nova, due state e agendamento pertencem ao backend;
- nenhum card vazio, órfão ou duplicado exato na closure curricular.

Status: **PASS**.

## Review

- Erros de Quiz alimentam revisão; respostas corretas não são classificadas como erro.
- Filtros, estado vazio, tentativa ativa, Review Quiz, resultado e retorno são funcionais.
- Flashcard Review permanece separado da revisão de Questions.
- Estado de erro não é confundido com estado vazio.

Status: **PASS**.

## Mock Exam

Question Bank aprovado:

- 512 Questions totais;
- 439 `mock_eligible` na closure do Mock;
- somente publicadas, associadas a Domain/Topic/Lesson, com quatro opções distintas, uma correta, difficulty e explanation válida;
- nenhum dump ou item oficial foi introduzido.

Configuração congelada do AZ-900:

| Regra | Baseline |
| --- | --- |
| Questions por Attempt | 40 únicas |
| Domain allocation | 11 / 15 / 14 |
| Difficulty allocation | 12 easy / 20 medium / 8 hard |
| Timer | 3.600 segundos (60 minutos) |
| Selection policy | `az900-mock-v1` |
| Topic policy | Cobrir os 12 Topics quando o pool saudável permite |
| Rotation | unseen-first, penalidade do Mock anterior e least-recently-seen |

A sugestão 10/20/10 presente no checklist da etapa não corresponde ao runtime aprovado. A baseline real e validada é **12/20/8**; nenhuma regra foi alterada para ajustar documentação.

O fluxo Start → Answer → Navigate → Refresh/Resume → Change Answer → Submit está coberto por testes. Timer e snapshot são server-backed. Expiração preserva respostas, calcula unanswered e rejeita novas mutações. Resultados mostram total, answered, correct, incorrect, unanswered, Practice Score, breakdowns e duração. Não existe conversão 700/1000, Official Pass ou previsão de aprovação.

O Review libera selected/correct answer, status, explanation e contexto curricular somente após finalização. A execução ativa não recebe gabarito. Retake cria novo UUID e preserva histórico; History é paginado, newest-first e não carrega snapshots em massa.

Status de Question Bank, Selection, Execution, Timer, Result, Review e History/Retake: **PASS**.

## Readiness

A baseline usa `AZ900_READINESS_CONFIG`, versão `az900-readiness-v1`, com evidência de Mock, Topic Quiz e Lesson Quiz; Review Quiz tem peso zero. A configuração mantém pesos dos três Domains, recência, suficiência, consistência, tendência e safeguards.

As fixtures cobrem New Student, Lesson Only, Weak, Improving, Strong, Lucky Mock, Weak Domain e Stale Evidence. Os 31 testes finais confirmam:

- 100% de Lessons sem avaliação não produz Strong;
- um único Mock alto não produz Strong automaticamente;
- média alta com Domain fraco aciona safeguard;
- evidência stale recebe penalização;
- baixa coverage não produz Strong;
- ausência de evidência usa score `null`, não zero.

Weak Topics, prioridade, reasons, ranking de Lessons, ações e CTAs usam `az900-study-recommendations-v1`. A UI cobre ausência, developing, strong, weak Domain, declining e stale evidence sem prometer aprovação.

Status de Engine, False Strong Safeguards, Recommendations e UI: **PASS**.

## Study Progress

`Progresso de estudo` mede conclusão de Lessons/currículo e minutos estimados. `Readiness` mede evidência de assessment, performance, recência, consistência e fraquezas. Navegação, headings, cards e textos continuam separando explicitamente os dois conceitos.

Status: **PASS**.

## Navigation

Navegação canônica desktop/mobile, nesta ordem:

1. Dashboard;
2. Estudo do Dia;
3. Trilha de estudos;
4. Revisão;
5. Simulados;
6. Readiness;
7. Progresso de estudo.

Rotas funcionais:

| Área | Rota |
| --- | --- |
| Auth | `/login`, `/register` |
| Certification selection | `/certifications` |
| Dashboard | `/certifications/:certificationCode/dashboard` |
| Study Today | `/certifications/:certificationCode/study-today` |
| Study Path | `/certifications/:certificationCode/study` |
| Lesson | `/certifications/:certificationCode/study/:lessonSlug` |
| Lesson Quiz | `/certifications/:certificationCode/study/:lessonSlug/quiz` |
| Lesson Flashcards | `/certifications/:certificationCode/study/:lessonSlug/flashcards` |
| Topic Quiz | `/certifications/:certificationCode/topics/:topicId/quiz` |
| Review | `/certifications/:certificationCode/review` |
| Review Quiz | `/certifications/:certificationCode/review/quiz` |
| Flashcard Review | `/certifications/:certificationCode/review/flashcards` |
| Mock list/history | `/certifications/:certificationCode/exams` |
| Mock execution | `/certifications/:certificationCode/exams/:attemptId` |
| Mock result | `/certifications/:certificationCode/exams/:attemptId/result` |
| Mock review | `/certifications/:certificationCode/exams/:attemptId/review` |
| Readiness | `/certifications/:certificationCode/readiness` |
| Study Progress | `/certifications/:certificationCode/progress` |

Todas as páginas são lazy-loaded e possuem fallback de rota. Identificador/slug inválido usa estado seguro ou redirect controlado. Deep links públicos para rota privada restauram a intenção após auth pelo guard; no smoke sem sessão, readiness direta e rota inválida redirecionaram para `/login` sem tela branca ou console error. A validação autenticada das telas privadas é comportamental/automatizada nesta rodada.

Status: **PASS**.

## Authentication

- guard privado não renderiza conteúdo antes da sessão;
- refresh e renovação usam o cliente oficial Supabase;
- logout limpa estado de UI do Mock;
- login do usuário B remonta toda a árvore privada por `user.id`;
- estado React/cache do usuário A não é reutilizado;
- certificação inválida não renderiza conteúdo privado.

Status: **PASS**.

## Security

- nenhum secret foi encontrado versionado;
- o navegador usa apenas URL e publishable key do Supabase;
- score, `is_correct`, expiração e lifecycle críticos são server-owned;
- erros técnicos não são exibidos em produção;
- active Mock DTO não expõe resposta correta, explanation, difficulty ou IDs curriculares;
- o produto informa explicitamente: “Não é um simulador oficial da Microsoft.”;
- não foram encontrados claims de garantia, probabilidade de aprovação, produto/parceiro oficial ou pontuação 700/1000 na UI.

Status: **PASS**.

## RLS

RLS e contracts owner-only cobrem lesson progress, quiz attempts/answers, flashcard reviews/progress, Mock attempts/snapshots/answers e fontes do Readiness. RPCs derivam o proprietário de `auth.uid()`, e funções `SECURITY DEFINER` usam `SET search_path = ''`.

Os validadores SQL versionados e closures anteriores registram isolamento A/B aprovado. Nesta execução, Supabase local e SQL A/B foram **NOT EXECUTED** porque Docker e Podman não estão disponíveis. Isso é uma limitação de evidência local, não um PASS inventado. O dry-run remoto confirmou o schema versionado sem migrations pendentes.

Status estrutural/automatizado: **PASS**. SQL A/B desta rodada: **NOT EXECUTED**.

## Performance

Baseline de build:

- main JS: 430,45 kB / 123,80 kB gzip;
- `schemas`: 74,80 kB / 20,00 kB gzip;
- Lesson: 54,92 kB / 13,77 kB gzip;
- Readiness: 48,51 kB / 13,70 kB gzip;
- CSS: 51,11 kB / 8,80 kB gzip;
- 1.854 módulos transformados;
- nenhum warning de chunk acima de 500 kB.

Consultas principais permanecem batched: catálogo em três queries, Readiness por RPC consolidada + catálogo, Mock execution em sync + load de 40 snapshots, Result/Review/History por RPCs dedicadas. Não foi encontrado N+1 crítico.

Status: **PASS**.

## Accessibility

Smoke e testes cobrem labels de formulário, autocomplete, headings, links/botões nomeados, radios para Questions, dialogs, progressbars, estados textuais além de cor, focus management do menu mobile e navegação por teclado nas Visual Experiences. O Login mobile possui CTA de 48 px e campos rotulados.

Não há suíte axe automatizada. A ausência dela é melhoria de validação, não defeito impeditivo observado.

Status: **PASS**.

## Mobile

O smoke em 390 × 844 confirmou Login sem overflow horizontal (`innerWidth = scrollWidth = 390`), CTA de 48 px, labels e autocomplete corretos, sem warnings/errors. As páginas privadas usam layouts responsivos e possuem testes DOM específicos para navegação, Lesson, Visual Experience, Questions, Mock e Readiness. A inspeção visual privada autenticada não foi repetida por ausência de credenciais de teste.

Status: **PASS**.

## Production Validation

| Verificação | Resultado |
| --- | --- |
| Typecheck | PASS |
| Lint | PASS, zero warnings |
| Vitest | PASS — 215/215, 35 arquivos |
| Build | PASS |
| `git diff --check` | PASS; apenas aviso ambiental LF/CRLF |
| `db:push:dry-run` | PASS — remoto atualizado, 0 migrations |
| Migrations | 103, ordem válida, prefixos não duplicados, nenhuma migration modificada nesta etapa |
| Schema fresh local | NOT EXECUTED — Docker/Podman indisponível |
| SQL A/B local | NOT EXECUTED — Docker/Podman indisponível |
| Browser smoke | PASS — deep link privado, rota inválida, mobile e console |

Comparação com 13.3:

- testes permanecem 215/215;
- bundle permanece 430,45 kB no main;
- migrations permanecem sem alterações e sem pendências;
- nenhum comportamento esperado mudou.

## Regression Baseline

Durante a Fase 14, devem permanecer aprovados:

- inventário e cobertura dos 57 objetivos;
- renderer/Zod/fallback de Content Blocks e Visual Experiences;
- conteúdo legado `lessons.content`;
- Lesson completion/progress;
- 76 Lesson Quizzes;
- 12 Topic Quizzes e retake rotation;
- Flashcards e spaced repetition;
- Review e Review Quiz;
- Mock Question Bank, selection, execution, timer, persistence, result, review, history e retake;
- answer-key isolation e scoring server-owned;
- Readiness Engine, fixtures, false-Strong safeguards e recommendations;
- separação Study Progress/Readiness;
- sete itens canônicos de navegação;
- Auth guards, troca de usuário e cleanup de estado;
- RLS/RPC ownership e validadores A/B;
- lazy routes, Error Boundary, mensagens seguras e build de produção.

Contrato técnico mínimo: `npm run typecheck`, `npm run lint`, `npm run test:run`, `npm run build`, `git diff --check` e `npm run db:push:dry-run`.

## Multi-Certification Debt

| Item encontrado | Classificação | Direção futura |
| --- | --- | --- |
| `code = 'az-900'` em contratos/queries curriculares | MUST GENERALIZE BEFORE AZ-204 | Resolver certification por contexto/configuração, preservando IDs |
| Assunção de exatamente 3 Domains | MUST GENERALIZE BEFORE AZ-204 | Tornar engine orientada à lista/configuração da certification |
| `AZ900_READINESS_CONFIG` | MUST GENERALIZE BEFORE AZ-204 | Separar engine genérica de config versionada por certification |
| `calculateAz900Readiness` e serviços AZ-900 | MUST GENERALIZE BEFORE AZ-204 | Extrair contrato genérico sem alterar resultados AZ-900 |
| `az900-readiness-v1` | CAN REMAIN CERTIFICATION-SPECIFIC | Manter como versão de configuração/baseline AZ-900 |
| `az900-study-recommendations-v1` | CAN REMAIN CERTIFICATION-SPECIFIC | Manter thresholds/política versionados por certification |
| 40 Questions | MUST GENERALIZE BEFORE AZ-204 | Remover literal do runtime; carregar configuração da certification |
| Domain allocation 11/15/14 | CAN REMAIN CERTIFICATION-SPECIFIC | Deve virar dado/configuração, não lógica duplicada |
| Difficulty allocation 12/20/8 | CAN REMAIN CERTIFICATION-SPECIFIC | Deve virar dado/configuração; preservar baseline AZ-900 |
| Timer 3.600 segundos | CAN REMAIN CERTIFICATION-SPECIFIC | Configuração por certification/mock policy |
| `az900-mock-v1` | CAN REMAIN CERTIFICATION-SPECIFIC | Versão da política AZ-900 |
| SQL/RPC e validators nomeados AZ-900 | MUST GENERALIZE BEFORE AZ-204 | Generalizar contratos de runtime; preservar validators AZ-900 como regressão |
| Títulos/microcopy AZ-900 na UI | MUST GENERALIZE BEFORE AZ-204 | Derivar código/nome do contexto da certification |
| Curriculum, Questions e pesos oficiais | CAN REMAIN CERTIFICATION-SPECIFIC | Conteúdo/configuração são naturalmente específicos |
| Closures e documentação histórica AZ-900 | DOCUMENTATION ONLY | Preservar como evidência imutável da baseline |

O alvo futuro não é eliminar configuração específica. É impedir lógica duplicada ou literais AZ-900 no runtime compartilhado, mantendo currículo, Questions, pesos, thresholds e versões como dados/configuração da certificação.

## Blockers

| Prioridade | Quantidade | Itens |
| --- | ---: | --- |
| P0 | 0 | Nenhum security leak, cross-user leak, perda/corrupção, answer-key leak ou scoring incorreto encontrado |
| P1 | 0 | Nenhum fluxo principal, currículo, Mock, Readiness, Auth ou RLS crítico quebrado |
| P2 | 3 | Schema fresh/SQL A-B não executados localmente; fallback SPA depende do host; checkpoint 13.3/13.4 ainda não commitado/taggeado |
| P3 | 5 | Sem observabilidade externa; deep link de Domain abre trilha no topo; labels formais de Readiness em inglês; sem paridade semântica automática entre blocks e fallback legado; polish editorial de diacríticos em itens legados |

Os itens P2/P3 devem permanecer no backlog. Nenhum deles altera o critério P0=0/P1=0 nem representa defeito crítico observado.

## Final Decision

Currículo, conteúdo, fluxo de estudo, quizzes, Flashcards, Review, Mock, Readiness, progresso, navegação, Auth, RLS, isolamento automatizado, performance e build satisfazem o release gate. “Frozen” significa preservar comportamento, dados e testes durante a refatoração; correções futuras continuam permitidas.

**AZ-900 Learning Experience: RELEASE READY**

**AZ-900 Baseline: FROZEN FOR MULTI-CERTIFICATION REFACTOR**


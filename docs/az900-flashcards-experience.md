# AZ-900 Flashcards Experience

## Scope

A ETAPA 13.5.3 transforma Flashcards em uma experiência própria, separa estudo livre de revisão diária e aplica a disponibilidade por Lesson completion definida na arquitetura. Não altera conteúdo, Questions, Mock, Readiness ou o algoritmo de repetição espaçada.

## Learning Role

```text
Lesson teaches.
Flashcard recalls.
Checkpoint evaluates.
Review remediates mistakes.
Mock evaluates the whole certification.
Readiness interprets evidence.
```

Flashcards são active recall, memorização e spaced repetition de conceitos previamente ensinados. Review é remediação baseada em erros objetivos de avaliações.

## Previous Experience

Flashcards eram descobertos principalmente dentro da Lesson ou por uma seção na página Review. A rota diária retornava para Review, e o mesmo Viewer sempre exigia rating e alterava o schedule. A fila incluía todo card publicado da Certification, mesmo quando sua Lesson ainda não havia sido concluída.

## New Experience

A navegação principal agora contém `Flashcards` entre Trilha de estudos e Revisão. O hub diferencia explicitamente:

- **Daily Review:** fila selecionada pelo sistema, com ratings e scheduling;
- **Free Study:** Topic escolhido pelo aluno, com flip/next e nenhuma escrita no schedule.

O card de Flashcards foi removido do fluxo primário da Lesson (`REMOVE_FROM_PRIMARY_FLOW`). A rota por Lesson permanece como Free Study legado.

## Flashcards Home

`/certifications/:certificationCode/flashcards` apresenta:

1. Revisão de hoje, com tamanho da sessão, vencidos, novos e próxima revisão;
2. catálogo em batch por Domain e Topic;
3. counts `disponíveis de total` que respeitam publicação e unlocking;
4. quantidade já revisada somente quando existe `user_flashcard_progress` real;
5. estados para catálogo vazio, aluno novo bloqueado e fila em dia.

## Daily Review

`/certifications/:certificationCode/flashcards/review` reutiliza `get_flashcard_study_queue`, `submit_flashcard_review`, interval calculation, ratings, persistence e `next_review_at`. Due cards continuam prioritários; novos continuam limitados por sessão. Back button, empty state e completion retornam ao hub.

A URL histórica `/review/flashcards` permanece funcional e renderiza a mesma página, mas não é mais promovida pela UI.

## Free Study

Decisão: **Estratégia B**.

Free Study revela resposta e avança para o próximo card sem chamar `submit_flashcard_review`. Não cria `flashcard_reviews`, não altera `user_flashcard_progress` e não recalcula `next_review_at`. Isso evita que navegação voluntária distorça a fila diária.

O Viewer existente recebeu apenas `mode = 'study' | 'review'`; não existe segundo Viewer nem framework de sessão paralelo.

## Domain Navigation

Domains são accordions responsivos no hub. Cada Domain soma os counts dos Topics retornados pela única RPC de catálogo. Domains com zero disponível continuam visíveis para comunicar avanço necessário, sem CTA enganoso.

## Topic Navigation

O aluno segue Domain → Topic → Free Study pela rota mínima `/flashcards/topics/:topicId`. Breadcrumbs usam Certification → Flashcards → Domain → Topic. Não foi criada página intermediária de Domain nem sessão global adicional.

## Unlocking

Estratégia C implementada:

```text
Lesson completed
→ associated published Flashcards available
```

Cards de Lessons não concluídas não entram em Free Study, Daily Review ou counts disponíveis. Availability é derivada de Flashcard → Lesson + `user_lesson_progress`; não existe `flashcard_unlocked`.

## Lesson Relationship

Todo card possui `lesson_id` obrigatório. A rota legada `/study/:lessonSlug/flashcards` consulta a mesma availability server-side e opera em modo Free Study. O fluxo primário da Lesson permanece focado em conteúdo, completion e próxima etapa.

## Legacy Compatibility

Um card com `user_flashcard_progress` do usuário permanece disponível mesmo quando não há completion sequencial da Lesson. Isso preserva agenda e acesso previamente demonstrado sem liberar outros cards futuros da mesma Lesson. Nenhum review, schedule ou UUID foi removido ou reescrito.

## Spaced Repetition

O algoritmo, ratings `again/hard/good/easy`, intervalos, limite diário, prioridade due, limite de novos e persistence foram preservados. A migration apenas filtra eligibility e amplia o overview com `due_count`, `new_count` e `total_flashcard_count`.

## Review Separation

Review não carrega mais overview ou CTA de Flashcards. Sua microcopy agora descreve exclusivamente histórico de erros, Review Quiz e recorrência de dificuldade. Flashcards comunicam recuperação ativa e repetição espaçada no próprio hub.

## Data Queries

- `get_flashcard_catalog_overview(certification_id)`: uma RPC retorna todos os Domain/Topic counts; não há N+1.
- `get_flashcard_review_overview(certification_id)`: resumo diário e counts totais/disponíveis.
- `get_available_flashcards(certification_id, topic_id | lesson_id)`: sessão Free Study certification-scoped.
- `get_flashcard_study_queue`: scheduling existente com eligibility derivada.

A Home executa duas consultas paralelas de propósito distinto; cada sessão executa uma consulta scoped.

## Security

Todas as RPCs exigem `auth.uid()` e não recebem `user_id`. Histórico privado é ligado somente ao usuário autenticado. Certification e Topic/Lesson são validados na mesma consulta. RLS existente continua isolando `flashcard_reviews` e `user_flashcard_progress`; funções unchecked não são executáveis por `anon` ou `authenticated`.

Unlocking é regra pedagógica, não mecanismo de confidencialidade do catálogo publicado.

## Accessibility

O hub possui headings hierárquicos, summaries semânticos, links explícitos e estados bloqueados com texto e ícone. Topic com zero disponível não é link. Viewer mantém reveal por botão/teclado, foco nativo e controles com área mínima; Free Study substitui ratings por CTA explícito de próximo card.

## Tests

Cobertura adicionada:

- navegação desktop/mobile contém Flashcards e preserva os demais itens;
- Home diferencia Daily Review/Free Study, usa counts disponíveis e explica lock;
- catálogo agrupa Domain/Topic em uma RPC;
- Free Study envia Certification + Topic, trata empty state e nunca persiste rating;
- Daily Review preserva due/new, next review, completion return e submit com rating;
- Lesson perde a ação primária sem remover a rota legada;
- serviço mantém certification scope explícito;
- regressão integral cobre Dashboard, Study Today, progressão, Checkpoint, Review, Mock, Readiness, Auth e navegação.

## Known Limitations

- `estudados` significa cards com histórico real de spaced repetition; sessões Free Study não são contabilizadas por decisão de produto.
- A URL histórica sob Review continua disponível durante depreciação.
- A Home organiza por Domain, mas inicia sessões somente por Topic para evitar uma segunda Study Path complexa.
- A consistência semântica Flashcard ↔ Lesson foi auditada na Etapa 13.5.4: 397/397 cards publicados terminaram `SUPPORTED`.
- O validator editorial permanente complementa a revisão humana com checks estruturais e candidatos lexicais, sem fingir validação semântica automática.

## Decision

```text
13.5.2 prerequisite: PASS
Dedicated Flashcards navigation: PASS
Flashcards Home: PASS
Daily Review: PASS
Free Study: PASS — strategy B, no scheduling writes
Study by Domain: PASS
Study by Topic: PASS
Flashcard availability strategy: C — Lesson completed; reviewed-card grandfathering
Cards from locked Lessons: PASS — excluded from queue, Free Study and available counts
Legacy Flashcards: PASS
Spaced Repetition regression: PASS
Review separation: PASS
Dashboard integration: PASS — CTA uses new review route
Study Today integration: PASS — no conflicting Flashcard action exists
Certification isolation: PASS
User isolation: PASS by owner-aware RPC/RLS contract
Lesson Flashcard legacy flow: PASS
Migration: YES — eligibility/query contract; no persisted unlock state
Mobile: PASS — responsive components and mobile navigation tests
Accessibility: PASS
Typecheck: PASS
Lint: PASS
Tests: 242 / 242
Build: PASS — 1.858 modules transformed
git diff --check: PASS
DB dry run: PASS — 13.5.2 and 13.5.3 migrations detected; nothing applied
P0: 0
P1: 0
P2: 0
P3: 0
```

**AZ-900 Flashcards Experience: READY**

# AZ-900 Learning Flow Architecture

## Context

Auditoria arquitetural da Etapa 13.5.1, executada em 31 de agosto de 2026 sobre a baseline posterior à Etapa 13.4. A baseline estava apta para continuação: `docs/az900-release-closure.md` e `docs/az900-product-acceptance.md` registram P0 = 0 e P1 = 0; nesta etapa, typecheck, lint, 215/215 testes e build também passaram.

O inventário congelado contém 3 Domains, 12 Topics, 76 Lessons, 712 Content Blocks, 397 Flashcards e 512 Questions. Nenhuma mudança funcional, curricular ou de banco faz parte desta etapa.

## Problems Observed

- O Quiz de cinco Questions depois de toda Lesson interrompe o ritmo e repete um recorte muito próximo do conteúdo recém-lido.
- O retake de Lesson Quiz usa novamente as mesmas cinco primeiras Questions; não existe rotação.
- A Trilha exibe status, mas todas as Lessons e Topic Quizzes são navegáveis desde o início.
- Flashcards possuem dois pontos de entrada — Lesson e Revisão — sem uma identidade de produto própria.
- A fila diária considera todos os cards publicados da certificação; pode apresentar conteúdo de Lessons ainda não estudadas.
- Não há validação automática de rastreabilidade semântica entre Lesson, Flashcard e Question.
- O banco versionado contém conteúdo legado sem diacríticos e a UI ainda mistura termos em português e inglês.
- A posição e o comprimento de alternativas podem oferecer pistas; o gate atual assegura estrutura, não equilíbrio editorial.

## Goals

Estabelecer a seguinte responsabilidade pedagógica:

```text
Lesson ensina
↓
Flashcard reforça por active recall e spaced repetition
↓
Topic Checkpoint verifica recuperação e aplicação entre Lessons
↓
Review corrige erros recorrentes
↓
Mock mistura o currículo inteiro
↓
Readiness interpreta evidência
```

Progressão e performance devem permanecer ortogonais:

```text
Completion controls progression.
Performance controls remediation and Readiness.
```

## Non-Goals

Esta etapa não remove Lesson Quiz, altera banco ou RPC, cria migration, bloqueia conteúdo, renomeia tipos internos, cria Flashcards Home, altera seleção/scoring, muda Review, Mock, Readiness ou Recommendation Engine, revisa Questions/Flashcards em massa, corrige acentos em massa, inicia AZ-204 ou Multi-Certification.

Progressive unlocking serve a orientação, sequência e percepção de avanço. Vidas, moedas, streak obrigatório, punição, grinding e bloqueio por nota são non-goals.

## Current Learning Flow

O código de `LessonPage` confirma a ordem real:

```text
Breadcrumb + Lesson header
→ Lesson Content
→ Complete Lesson
→ Lesson Flashcards
→ Lesson Quiz
→ Previous / Next
```

`LessonCompletion` também oferece `Próxima aula` após completion, antes dos cards de Flashcards e Quiz. Assim, há dois caminhos concorrentes: seguir imediatamente para a próxima Lesson ou permanecer para reforço/avaliação.

As rotas atuais são:

| Experiência | Rota |
| --- | --- |
| Lesson | `/certifications/:certificationCode/study/:lessonSlug` |
| Lesson Quiz | `/certifications/:certificationCode/study/:lessonSlug/quiz` |
| Lesson Flashcards | `/certifications/:certificationCode/study/:lessonSlug/flashcards` |
| Topic Quiz | `/certifications/:certificationCode/topics/:topicId/quiz` |
| Question Review | `/certifications/:certificationCode/review` |
| Review Quiz | `/certifications/:certificationCode/review/quiz` |
| Daily Flashcards | `/certifications/:certificationCode/review/flashcards` |

## Lesson Responsibility

Lesson é a única experiência responsável por ensinar conteúdo novo. Conceitos necessários para Flashcards, Checkpoints ou Mock precisam estar explícitos em Content Blocks ou no fallback publicado da Lesson correspondente.

Completion é uma declaração de estudo, persistida separadamente de qualquer Quiz. Ela deve controlar sequência futura sem alegar domínio.

## Lesson Quiz Audit

### Implementação atual

- Page: `LessonQuizPage`; hook: `useLessonQuiz` sobre a engine compartilhada `useQuizAttempt`.
- Service: `quizService`, por meio de `start_lesson_quiz`, `getActiveLessonQuiz`, `getQuizAttempt`, `submit_quiz_answer`, resultado e review de respostas.
- Persistência: `quiz_attempts`, `quiz_attempt_questions` e `quiz_answers` owner-only. Attempts possuem lifecycle `in_progress`/`completed`, score, timestamps e histórico; respostas são imutáveis após o primeiro envio.
- Seleção: no máximo cinco Questions `single_choice` publicadas da mesma Lesson, ordenadas por `question.display_order, id`.
- Retake: cria outro attempt, mas seleciona novamente o mesmo conjunto fixo; não considera histórico.
- Feedback/scoring: feedback após cada resposta; o servidor calcula acerto, finalização e percentual quando todas são respondidas.
- Review: todo erro em `quiz_answers`, inclusive Lesson Quiz, entra em `get_user_question_stats` e pode alimentar Review Quiz.
- Readiness: `lesson_quiz` tem peso 0,35; Topic Quiz 0,65; Mock 1,0; Review Quiz 0.
- Recommendations: erros de Lesson Quiz têm peso 2 no ranking de Lesson, abaixo de Topic Quiz (3) e Mock (5). A engine não possui CTA de Lesson Quiz.

### Quantidade por Lesson

O inventário validado contém 512 Questions para 76 Lessons:

| Questions na Lesson | Lessons |
| ---: | ---: |
| 5 | 46 |
| 6 | 5 |
| 10 | 23 |
| 11 | 2 |
| **Total** | **76** |

Média: **6,74**; mediana: **5**; mínimo: **5**; máximo: **11**. Toda tentativa seleciona exatamente cinco. Em 46 Lessons, o Quiz esgota o pool; nas demais, sempre usa as cinco primeiras e ignora de forma estável o restante. Não existe configuração por Certification nem rotação de retake.

Como as Questions têm `lesson_id` e aparecem imediatamente após a Lesson, o mecanismo favorece reconhecimento e memória de curtíssimo prazo. Ele pode ser útil como prática opcional, mas não é a melhor evidência principal de entendimento nem o melhor próximo passo obrigatório.

### Decisão

**HIDE_FROM_PRIMARY_FLOW**.

Não remover agora. Na implementação futura, retirar o card da sequência principal, preservar rota, engine, histórico e Review, e manter acesso transitório por histórico/deep link ou por uma área secundária de prática. Após período de compatibilidade e ajuste de Readiness, reavaliar `DEPRECATE`; `REMOVE_FUTURE` não está decidido nesta auditoria.

## Topic Quiz Audit

- Page/route: `TopicQuizPage`, `/topics/:topicId/quiz`; hook compartilhado `useQuizAttempt`.
- Pool: todas as Questions `single_choice` publicadas do Topic, com relação curricular real via `topic_id` e normalmente `lesson_id`.
- Seleção: até 10 itens; distribui entre Lessons, busca 3 easy / 5 medium / 2 hard, prioriza unseen, penaliza o attempt anterior e depois usa least-recently-seen.
- Attempts/answers/scoring: mesmos contracts persistentes e server-owned do Lesson Quiz.
- Resume: um único attempt `in_progress` por usuário/Topic; a página o retoma.
- Retake/history: histórico preservado, último score e attempt ativo aparecem na Trilha; a rotação foi validada em dois attempts por Topic.
- Resultado: score total, revisão de cada resposta e desempenho por Lesson.
- Review: erros entram na fila geral de Questions.
- Readiness: fonte com peso 0,65 e thresholds próprios de cobertura/sessões.
- Recommendations: baixo desempenho e erros repetidos influenciam prioridade; ações `assess_topic` e `retake_topic_quiz` já apontam para essa rota.

O Topic Quiz já possui quase toda a infraestrutura necessária para ser um Checkpoint. Faltam disponibilidade derivada da conclusão das Lessons, linguagem de Checkpoint e integração de progressão entre Topics. Não é necessário renomear tabela, `quiz_type`, service ou RPC para obter a experiência desejada.

## Topic Checkpoint Proposal

Decisão: **REBRAND_AS_CHECKPOINT + CHANGE_BEHAVIOR**, mantendo internamente `Topic Quiz`.

O Checkpoint verifica se o aluno recupera e aplica conceitos de múltiplas Lessons do Topic. Não deve repetir uma única Lesson, exigir passagem por nota nem alegar certificação.

```text
Topic
│
├── Lesson 1 (completed)
│      └── Flashcards become available
│
├── Lesson 2 (completed)
│      └── Flashcards become available
│
├── Lesson N (completed)
│      └── Flashcards become available
│
└── Topic Checkpoint (available after all published Lessons)
       │
       ├── errors → Question Review
       ├── evidence → Readiness
       └── submitted at any score → next Topic
```

## Progressive Unlocking

Estratégia recomendada: **Hard Lock no fluxo suportado**, baseado apenas em completion/submission e aplicado em route/service, com estado explicativo. O conteúdo não é segredo; o lock é uma regra pedagógica, não uma fronteira de confidencialidade.

Regras derivadas:

1. A primeira Lesson do primeiro Topic está `AVAILABLE`.
2. A próxima Lesson fica `AVAILABLE` quando a Lesson anterior, na ordem curricular global, está `completed`.
3. O Checkpoint fica disponível quando todas as Lessons publicadas do Topic estão `completed`.
4. Submeter o Checkpoint, com qualquer score, libera a primeira Lesson do próximo Topic.
5. O Checkpoint do último Topic de um Domain libera o primeiro Topic do próximo Domain; não há prova de Domain.
6. O último Checkpoint conclui a trilha guiada e oferece Review, Flashcards e Mock como escolhas; não inicia Mock automaticamente.

Exigir submission do Checkpoint, e não apenas conclusão das Lessons, dá ao mecanismo uma função clara sem transformar score em punição. Um resultado de 45% libera o próximo Topic, mas gera erros, fraqueza e evidência para Review/Readiness.

Estados de apresentação necessários, preferencialmente derivados:

```text
LOCKED
AVAILABLE
IN_PROGRESS
COMPLETED
CHECKPOINT_AVAILABLE
CHECKPOINT_COMPLETED
```

Não criar `is_unlocked` persistido. Derivar de `domain.display_order`, `topic.display_order`, `lesson.display_order`, `user_lesson_progress` e attempts de Topic Quiz.

### Ordem curricular real

Domains, Topics e Lessons possuem `display_order`; o serviço curricular ordena a hierarquia e `flattenStudyPath` preserva essa sequência. O snapshot atual é:

| Ordem | Topic | Lessons | Question pool | Checkpoint size |
| ---: | --- | ---: | ---: | ---: |
| 1.1 | Cloud Computing | 7 | 72 | 10 |
| 1.2 | Benefits of Cloud Services | 7 | 61 | 10 |
| 1.3 | Cloud Service Types | 4 | 20 | 10 |
| 2.1 | Core Architectural Components | 7 | 42 | 10 |
| 2.2 | Compute Services | 9 | 51 | 10 |
| 2.3 | Networking Services | 5 | 30 | 10 |
| 2.4 | Storage Services | 8 | 46 | 10 |
| 2.5 | Identity, Access and Security | 9 | 50 | 10 |
| 3.1 | Cost Management | 4 | 30 | 10 |
| 3.2 | Governance and Compliance | 3 | 15 | 10 |
| 3.3 | Resource Management and Deployment | 7 | 55 | 10 |
| 3.4 | Monitoring | 6 | 40 | 10 |

Todos os Topics e Lessons atuais estão publicados e ordenados. A ordem é confiável para AZ-900; empates ou valores inválidos devem falhar em validação editorial futura, não ser resolvidos silenciosamente na UI.

### Edge cases

- Topic sem Lesson publicada: não criar checkpoint desbloqueável automaticamente; mostrar estado indisponível e registrar erro de catálogo.
- Lesson não publicada: excluí-la da sequência e da regra `all published Lessons`; não apagar progresso histórico.
- Topic sem Questions: conclusão das Lessons não cria uma ação impossível; sinalizar `Checkpoint indisponível` e permitir avanço administrativo somente por política explícita. No AZ-900 atual isso não ocorre.
- Pool com menos de 10: o contract atual permite o total disponível; o AZ-900 atual possui pelo menos 15 por Topic.
- Attempt de Checkpoint em andamento: permanece acessível mesmo se a regra curricular mudar.
- Checkpoint concluído no legado: conta como concluído e nunca é bloqueado retroativamente.

## Completion vs Performance

| Sinal | Controla progressão | Controla remediation/Readiness |
| --- | :---: | :---: |
| Lesson completed | Sim | Cobertura de estudo, não domínio |
| Checkpoint submitted | Sim, libera próximo Topic | Sim, pelo score e erros |
| Checkpoint score | Não | Sim |
| Mock score | Não | Sim |
| Readiness | Não | Interpreta evidência |

Progression responde “o aluno concluiu a sequência?”. Readiness responde “há evidência suficiente de domínio?”. Um nunca deve ser usado como proxy do outro.

## Study Today Integration

Hoje `buildDailyStudyPlan` procura primeiro qualquer Lesson `in_progress`; senão, a primeira não concluída na lista global, e adiciona Lessons subsequentes até a meta de tempo. Ele não conhece lock nem Checkpoint.

Responsabilidade futura:

```text
Study Path derives availability.
Study Today selects the next available action.
```

Study Today deve consumir o mesmo resolver canônico de progressão da Trilha, sugerir no máximo Lessons disponíveis e inserir o Checkpoint quando ele for a próxima ação. Não deve reimplementar a regra ou saltar um Checkpoint pendente.

## Lesson Navigation

Hoje `Previous`, `Next`, o CTA de `LessonCompletion`, cards da Trilha e deep link manual navegam livremente. Após a mudança:

- Previous pode abrir qualquer Lesson já disponível ou preservada por compatibilidade.
- Next e o CTA após completion devem consultar a mesma disponibilidade; no fim do Topic, apontam para o Checkpoint, não diretamente para o próximo Topic.
- A Trilha mostra locked/available/in-progress/completed com texto, não apenas cor/ícone.
- Deep link bloqueado renderiza uma página/estado `Aula bloqueada — conclua <aula anterior>`, com CTA para o pré-requisito e retorno à Trilha. Não redirecionar silenciosamente.
- O route loader/page deve consultar a decisão autoritativa antes de renderizar a Lesson. Alterar apenas o botão seria Soft Lock e deixaria URLs inconsistentes.
- RPCs de início de progresso e Checkpoint devem validar os mesmos pré-requisitos para impedir bypass pelo cliente.

## Flashcards Current State

### Lesson Flashcards

`Lesson → /study/:lessonSlug/flashcards` carrega todos os cards publicados da Lesson, usa `FlashcardViewer`, exige reveal antes do rating e persiste review + schedule.

### Daily Flashcard Review

`Review → /review/flashcards` usa `get_flashcard_study_queue`: até 20 cards, priorizando vencidos e depois até cinco novos. A fila percorre Domain/Topic/Lesson/card por ordem.

O problema é que `eligible_cards` filtra apenas Certification, Lesson publicada e card publicado; não verifica `user_lesson_progress`. Portanto qualquer card publicado pode aparecer como `new` antes de sua Lesson ser estudada.

Os fluxos compartilham viewer, rating, `flashcard_reviews`, `user_flashcard_progress` e algoritmo de intervalo. Na UX, porém, Flashcards aparecem dentro de Review e da Lesson; isso mistura parcialmente os conceitos, embora Question Review e spaced repetition sejam contracts técnicos separados.

## Flashcards Future Role

```text
Lesson teaches.
Flashcard recalls.
```

Flashcards servem a active recall e spaced repetition. Não devem introduzir definições, exceções ou decisões que não estejam ensinadas explicitamente na Lesson.

## Flashcards Navigation Proposal

Recomendação: **YES**, adicionar futuramente `Flashcards` à navegação principal, separado de `Revisão`.

- Flashcards Home concentra memória e repetição espaçada, melhora descoberta e dá identidade à prática.
- Review permanece centrado em erros de Questions.
- A Lesson continua oferecendo a sessão contextual recém-desbloqueada.
- O card de Flashcards deve sair da página Review quando a home dedicada estiver pronta, evitando dois “centros” concorrentes.

Dados necessários para a home:

- contagem due/new e `next_review_at`;
- cards publicados e progresso do usuário;
- relação card → Lesson → Topic → Domain → Certification;
- completion da Lesson para disponibilidade;
- agregações por Domain/Topic e link para sessão filtrada;
- estados vazio, tudo em dia, indisponível e erro.

Tudo existe no modelo atual; faltam queries/RPCs agregados e apresentação.

## Flashcard Unlocking

Comparação:

| Opção | Benefício | Risco |
| --- | --- | --- |
| A — todos desde o início | máxima liberdade | fila apresenta conteúdo não estudado |
| B — após acessar Lesson | início rápido de recall | mero deep link/access cria elegibilidade sem estudo concluído |
| C — após completar Lesson | fronteira clara e derivável | exige adaptar fila e compatibilidade |

Recomendação: **C — desbloquear ao completar a Lesson**. Ao completar, os cards associados passam a ser candidatos `new`; somente após o primeiro rating passam a ter schedule. O algoritmo de intervalo atual é compatível, pois não depende da origem do card; apenas o CTE `eligible_cards` precisa considerar completion.

## Review Responsibility

Review é recuperação dirigida por erros em Questions. Hoje `get_user_question_stats` lê `quiz_answers` sem filtrar `quiz_type`, então agrega erros de Lesson Quiz, Topic Quiz e Review Quiz. Review Quiz pode, portanto, continuar produzindo evidência de erro para ciclos posteriores.

Mock usa tabelas próprias e **não** alimenta a fila geral de Question Review. Seus erros aparecem em Mock Review e influenciam Readiness/recommendations. Se o produto quiser um inbox unificado no futuro, isso será mudança explícita; não deve ser presumida nesta fase.

Ocultar Lesson Quiz reduz sinal imediato de erro, mas não quebra Review: Topic Checkpoints e Review Quiz continuam alimentando a fila. A perda é aceitável e é compensada por um sinal menos fragmentado; Mock continua com sua revisão dedicada.

## Mock Responsibility

Mock avalia a certificação inteira em 40 Questions, respeitando pesos de Domain, dificuldades, diversidade de Topic, timer, histórico e rotação. Ele não ensina, não controla lock e não inicia automaticamente no fim da trilha.

## Readiness Responsibility

Readiness interpreta evidências de Mock, Topic Quiz e Lesson Quiz; Review Quiz tem peso zero. Mock + Topic Checkpoint são suficientes como fontes principais, desde que a implementação futura ajuste pesos, suficiência e fixtures para não esperar o volume produzido por Lesson Quiz.

Não remover `lesson_quiz` do evidence contract imediatamente: evidência histórica deve continuar válida. Uma versão futura de configuração deve reduzir/eliminar sua contribuição prospectiva ou tratá-la como evidência legada de menor peso, preservando `az900-readiness-v1` para reprodutibilidade quando necessário.

Recommendations não recomendam Lesson Quiz, mas usam seus erros para ranquear Lessons. A futura versão deve manter leitura de histórico legado e recalibrar ranking/explicações para priorizar Mock + Checkpoint. As ações atuais `assess_topic`/`retake_topic_quiz` podem apenas mudar de label para Checkpoint.

## Content-to-Flashcard Consistency

Schema e dados validam uma cadeia obrigatória:

```text
Flashcard.lesson_id NOT NULL
→ Lesson.topic_id
→ Topic.domain_id
→ Domain.certification_id
```

Os 397 cards publicados estão associados a Lessons válidas; não há órfãos na closure. Isso comprova integridade referencial, não cobertura semântica.

Princípio adotado:

```text
Every Flashcard claim must be traceable to explicit Lesson content.
```

Metodologia da 13.5.4:

1. Extrair front, back e hint por Lesson.
2. Decompor cada card em claims verificáveis.
3. Procurar suporte explícito em Content Blocks publicados e fallback, registrando block/order/trecho sem depender de Question explanations.
4. Classificar `SUPPORTED`, `PARTIALLY_SUPPORTED`, `NOT_SUPPORTED` ou `AMBIGUOUS`.
5. Revisar `PARTIALLY_SUPPORTED`/`NOT_SUPPORTED` por humano; decidir se a Lesson ensina primeiro ou se o card deve ser ajustado.
6. Preservar UUID, Lesson e histórico; corrigir in-place.

## Content-to-Question Consistency

`questions` possui `certification_id`, `domain_id`, `topic_id` e `lesson_id`; as colunas são nullable para flexibilidade estrutural, mas todas as 512 Questions AZ-900 publicadas têm hierarquia completa e coerente.

Regra adotada: toda Question de Checkpoint deve avaliar um conceito explicitamente ensinado em alguma Lesson publicada do mesmo Topic. Explicações de Question, Flashcards ou Mock não contam como fonte de ensino.

Metodologia futura:

1. Decompor stem, resposta correta e justificativa em claims/pré-requisitos.
2. Mapear cada claim a Content Blocks publicados do Topic.
3. Classificar com a mesma escala de suporte dos Flashcards.
4. Marcar literalidade excessiva, profundidade fora do AZ-900 e associação curricular incorreta separadamente.
5. Corrigir conteúdo ou Question in-place e revalidar Lesson/Topic/Mock pools.

## Question Quality Findings

### Seleção e repetição

- Lesson Quiz: pool real de 5–11, mas seleção fixa das primeiras cinco; retake repete o mesmo recorte.
- Topic Checkpoint: pools de 15–72, seleção de 10, rotação user-aware e cobertura equilibrada de Lessons.
- Mock: 439/512 Questions elegíveis, com política própria e rotação.

### Posição da correta

O schema assegura quatro options distintas e exatamente uma correta, mas nenhuma regra de seleção embaralha options ou equilibra `display_order`. A auditoria estática dos payloads versionados encontrou forte concentração histórica na primeira posição; como updates in-place e dados gerados por migrations não permitem reconstruir com segurança os 512 registros finais sem leitura autenticada do banco, esta etapa não declara percentuais finais inventados.

Consequência: Lesson Quiz, Topic Checkpoint e Mock compartilham a mesma posição persistida da correta. A distribuição final A/B/C/D deve ser medida diretamente no banco na 13.5.5 e balanceada editorialmente ou por snapshot/shuffle seguro, preservando answer-key isolation.

### Comprimento da correta

Métrica adotada para a próxima auditoria:

```text
correct_option_length = length(trim(correct option))
average_distractor_length = avg(length(trim(each incorrect option)))
ratio = correct_option_length / average_distractor_length
```

`ratio > 1.5` é flag de revisão, não reprovação automática. Também revisar `ratio < 0.67`, diferenças de detalhamento/tom, paralelismo gramatical e respostas com enumerações exclusivas. O validador atual usou uma heurística muito conservadora — correta ≥ 50 caracteres e ≥ 2,5 vezes o maior distractor — e encontrou zero; isso não exclui viés em 1,5× da média.

### Distractor quality

Amostras versionadas antigas exibem distractors obviamente irrelevantes (por exemplo, opções sobre quantidade de cadeiras, preferência pessoal ou ferramentas sem relação com o cenário). Diversos recortes foram corrigidos in-place nas closures de Domain, que registram distractors plausíveis, mas não existe rubric global persistida.

A 13.5.5 deve amostrar no mínimo duas Questions por Topic e incluir todos os outliers de comprimento, todos os `mock_eligible = false` próximos do gate e uma amostra A/B/C/D. Cada distractor recebe `PLAUSIBLE`, `WEAK`, `OBVIOUSLY_WRONG` ou `AMBIGUOUS`; a classificação é por opção e a Question herda a pior severidade.

Conclusão: há risco real de pistas por posição, tamanho e qualidade, classificado P2 editorial. Não há evidência de scoring incorreto ou answer-key leak.

## Portuguese Editorial Findings

A UI TypeScript/TSX não apresenta ocorrências problemáticas dos termos-alvo; `voce@exemplo.com` é um endereço de exemplo, não a palavra “você”. O débito está concentrado em conteúdo legado versionado, especialmente batches iniciais de Questions/options/explanations.

Uma busca textual somente leitura nas migrations encontrou ocorrências sem diacríticos dos tokens exatos: `nao` 706, `autenticacao` 62, `aplicacao` 301, `configuracao` 75, `informacao` 6 e `questao` 7. Esses números medem o histórico versionado, não o snapshot final: migrations posteriores corrigem parte do conteúdo in-place. Exemplos ainda auditáveis incluem “aplicacao”, “configuracao”, “regioes”, “politicas” e “nao”.

A 13.5.5 deve consultar o snapshot final e separar:

```text
HUMAN-FACING CONTENT
from
CODE / SLUG / ID / EMAIL / TECHNICAL TERM
```

É proibido executar replace global como `replace('nao', 'não')`. Correções devem ser por registro/campo, revisadas em contexto, preservando UUIDs, slugs, identifiers, source references e termos oficiais.

## Backward Compatibility

Nenhum histórico pode ser resetado. Regras de grandfathering:

- Lesson `started` ou `completed` continua acessível.
- Para evitar ilhas, qualquer atividade legada em uma Lesson libera também seus pré-requisitos anteriores na sequência.
- Attempt de Topic Quiz `in_progress` permanece acessível.
- Qualquer Topic Quiz `completed` conta como Checkpoint concluído, independentemente do score ou de completion retroativa das Lessons.
- Atividade em Topic/Domain posterior preserva o prefixo curricular necessário para alcançá-la.
- History, answers, Review stats, Readiness e Recommendation Engine continuam lendo Lesson Quiz legado.
- URLs antigas de Lesson Quiz permanecem funcionais durante depreciação; a UI primária apenas deixa de promovê-las.
- Mock history e Flashcard schedules permanecem intactos.

O resolver deve produzir uma visão derivada e monotônica: introduzir a regra nunca reduz acesso que o usuário demonstravelmente já possuía.

## Data Model Impact

| Experiência | Nova coluna/tabela necessária? | Migration de deployment esperada? | Motivo |
| --- | --- | --- | --- |
| Progressive unlocking | **NO** | **YES** em 13.5.2 | estados deriváveis; RPC/service precisa aplicar regra e compatibilidade |
| Topic Checkpoint | **NO** | **YES** se `start_topic_quiz` validar unlock | nome técnico e tabelas existentes bastam |
| Flashcards Home | **NO** | **NO/UNKNOWN** para UI; **YES** para unlock C | agregação pode usar modelo atual; fila RPC precisa filtrar completion |

`user_lesson_progress.status/completed_at`, ordem curricular e attempts completos fornecem informação suficiente. Não criar `is_unlocked`, `checkpoint_completed` ou duplicação equivalente.

Completion atual é idempotente: `start_lesson_progress` cria/atualiza acesso e `complete_lesson_progress` persiste `status = completed`, `completed_at` e `last_accessed_at`; repeated completion retorna o estado concluído sem depender de score. Esse contract alimenta unlocking futuro.

## Security

- Availability precisa ser calculada com `auth.uid()`; nunca aceitar `user_id` do cliente.
- Validar prerequisite no backend para iniciar progresso/Checkpoint; UI é defesa de experiência, não autoridade.
- Preservar RLS owner-only de progress/attempts/answers e answer-key isolation.
- Não tornar gabarito legível para implementar locks ou shuffle.
- Manter erro de catálogo distinto de “bloqueado”.
- O conteúdo curricular publicado não é sensível; o lock não deve ser apresentado como controle de segurança.

## Accessibility

- Todo item bloqueado comunica texto `Bloqueado` e a ação necessária, por exemplo `Conclua a aula anterior`.
- Não depender apenas de cadeado, opacidade ou cor.
- Links bloqueados não devem ser links falsos; usar estado não interativo com descrição ou link para o pré-requisito.
- A página de deep link bloqueado precisa de heading, explicação, CTA nomeado e retorno à Trilha.
- Progress e Checkpoint mantêm labels, valores e focus states acessíveis.

## Testing Strategy

Perfis obrigatórios para 13.5.2–13.5.6:

| Perfil | Estado/expectativa |
| --- | --- |
| A — New Student | somente primeira Lesson disponível |
| B — Mid Topic | 2/5 concluídas; próxima Lesson disponível; demais bloqueadas |
| C — Topic Lessons Completed | Checkpoint disponível; próximo Topic bloqueado |
| D — Low Checkpoint | 45%; próximo Topic disponível; fraqueza em Review/Readiness |
| E — Strong Checkpoint | 90%; próximo Topic disponível; evidência forte |
| F — Legacy Student | Lesson/Topic Quiz history preservado e acesso não reduzido |
| G — Certification Complete | todas Lessons/Checkpoints; oferece Review, Flashcards e Mock |
| H — Flashcards due | cards estudados vencidos têm prioridade |
| I — Flashcard from locked Lesson | não aparece em fila/home quando unlock C estiver ativo |

Adicionar testes unitários do resolver como função pura, integração de RPC/RLS, deep links, Study Today, Previous/Next, mudanças de publicação, attempt em andamento, Topic sem Lesson/Questions e troca de usuário. Reexecutar os validadores de Quiz, Review, Flashcards, Mock e Readiness.

## Recommended Architecture

| Experience | Responsibility | Entra quando |
| --- | --- | --- |
| Lesson | Ensinar | próxima unidade disponível |
| Flashcards | Memorizar/recuperar conteúdo já ensinado | após completion da Lesson; depois por schedule |
| Topic Checkpoint | Validar entendimento entre Lessons | todas as Lessons publicadas do Topic concluídas |
| Review | Remediar erros de Questions | após erros em Checkpoint/Review Quiz e histórico legado |
| Mock | Avaliar o currículo completo | ação livre, especialmente após avanço curricular |
| Readiness | Interpretar quantidade, qualidade, recência e consistência da evidência | continuamente; nunca controla lock |

Resolver canônico futuro:

```text
catalog order + lesson progress + topic attempts + legacy grandfathering
                              │
                              ├── Study Path states
                              ├── Study Today next action
                              ├── Lesson route/navigation
                              ├── Checkpoint availability
                              └── Flashcard eligibility
```

## Implementation Roadmap

Ordem confirmada:

```text
13.5.1 — Architecture (este documento)
↓
13.5.2 — Topic Checkpoint + Progressive Unlocking
↓
13.5.3 — Flashcards Experience Redesign
↓
13.5.4 — Content ↔ Flashcard Consistency Audit
↓
13.5.5 — Question Quality + Portuguese Editorial Audit
↓
13.5.6 — Learning Experience Validation + Re-Freeze
↓
14.1 — Multi-Certification
```

Dependências justificam a ordem: progressão define disponibilidade; a Flashcards Home consome essa disponibilidade; auditorias semânticas usam a nova responsabilidade pedagógica; qualidade/editorial ocorre após a cobertura; validação final congela o comportamento antes da Fase 14.

## Technical Validation

Validação executada em 31 de agosto de 2026, após a auditoria e sem alterar código, schema ou dados:

| Gate | Resultado |
|---|---|
| `npm run typecheck` | PASS |
| `npm run lint` | PASS |
| `npm run test:run` | PASS — 35 arquivos, 215 testes |
| `npm run build` | PASS — 1.854 módulos transformados |
| `git diff --check` | PASS |
| `npm run db:push:dry-run` | PASS — banco remoto atualizado; zero migrations, seeds ou roles pendentes |
| Migrations locais | 103 existentes; 0 criada ou alterada nesta etapa |

O escopo do diff permanece exclusivamente documental: este arquivo é o único artefato novo da ETAPA 13.5.1.

## Decision

```text
Current Lesson Flow:
Content → Complete Lesson → Flashcards → Lesson Quiz → Previous/Next

Lesson Quiz:
HIDE_FROM_PRIMARY_FLOW

Topic Quiz:
REBRAND_AS_CHECKPOINT + CHANGE_BEHAVIOR

Progressive Unlocking:
Hard Lock no fluxo suportado, completion/submission based, server-authoritative

Unlock source:
display_order + user_lesson_progress + completed/in-progress Topic Quiz attempts + legacy grandfathering

Checkpoint unlock rule:
all published Lessons in Topic completed

Next Topic unlock rule:
Checkpoint submitted at any score

Flashcards:
current global new-card queue can expose locked-Lesson content; identity split across Lesson and Review

Dedicated Flashcards navigation:
YES

Flashcard availability strategy:
C — Lesson completed

Review responsibility:
Question-error remediation; current queue covers Lesson/Topic/Review Quiz, not Mock tables

Mock responsibility:
whole-certification assessment with dedicated review

Readiness implications:
Mock + Checkpoint should become primary; preserve Lesson Quiz legacy evidence and version/recalibrate config

Flashcard ↔ Lesson consistency:
referential integrity PASS; semantic traceability requires 13.5.4

Question predictability findings:
P2 editorial risk from fixed option order, length/detail asymmetry and weak distractors

Correct answer length bias:
current 2.5×-longest heuristic found zero; use 1.5× average as review flag in 13.5.5

Correct option distribution:
not enforced or shuffled; exact final A/B/C/D snapshot must be measured in 13.5.5

Portuguese/accent findings:
legacy versioned content contains many unaccented forms; UI terms sampled are clean; targeted field-level edit required

Migration expected for 13.5.2:
YES for RPC/contract changes; NO new state column/table expected

Migration expected for 13.5.3:
YES if Flashcard queue enforces completion; NO new table expected

Backward compatibility risks:
relocking legacy progress, orphaning in-progress attempts, changing historical Readiness, breaking old URLs

Technical validation:
typecheck PASS; lint PASS; 215/215 tests PASS; build PASS; diff check PASS; DB dry-run PASS; 0 migrations changed

Typecheck:
PASS

Lint:
PASS

Tests:
215 / 215

Build:
PASS

DB dry run:
PASS — remote database up to date; no pending migration

P0: 0
P1: 0
P2: 4 — option predictability; semantic Flashcard coverage unknown; semantic Question coverage not automated; unlocking compatibility complexity
P3: 2 — Portuguese editorial polish; mixed Portuguese/English product vocabulary
```

## Implementation Status — 13.5.2

Implementado em 31 de agosto de 2026:

- resolver determinístico e único de disponibilidade em `studyProgression`;
- Lesson Quiz ocultado apenas do fluxo primário da Lesson;
- Topic Quiz apresentado como Checkpoint do Tópico, sem renomear seus dados internos;
- sequência Lesson completion → próxima Lesson → Checkpoint submission → próximo Topic;
- grandfathering monotônico para progresso e attempts legados;
- deep links, Lesson Navigation, Trilha, Study Today e Dashboard alinhados ao resolver;
- enforcement equivalente nos RPCs de Lesson progress e Topic Quiz, sem estado de unlock persistido;
- Review, Readiness, Mock, Flashcards e rotas legadas preservados.

Implementado na 13.5.3:

- Flashcards possuem área própria na navegação e hub por Domain/Topic;
- Daily Review usa o scheduling existente e retorna ao hub de Flashcards;
- Free Study usa flip/next e não altera spaced repetition;
- cards liberam após Lesson completion, com grandfathering por histórico de card;
- Review ficou restrito à remediação de erros de avaliações;
- o card de Flashcards saiu do fluxo primário da Lesson, preservando a rota legada;
- availability, counts e sessões são certification-scoped e owner-aware.

Os contratos e validações estão em `docs/az900-topic-checkpoint-progressive-unlocking.md` e `docs/az900-flashcards-experience.md`.

As funções de Lesson, Lesson Quiz, Checkpoint, progressão, Flashcards, Review, Mock e Readiness; as regras de compatibilidade; o impacto de dados; e o roadmap estão definidos e a 13.5.2 materializou a progressão aprovada.

**AZ-900 Learning Flow Architecture: READY**

## Etapa 13.5.4 — Content ↔ Flashcard Consistency

A auditoria editorial reconstruiu 397 Flashcards publicados em 76 Lessons e comparou cada card com todos os Content Blocks da Lesson associada. Onze inconsistências iniciais foram resolvidas: dois blocks receberam complementos concisos e nove cards foram reescritos in-place, sem mover UUIDs ou perder histórico. O estado final é 397 `SUPPORTED`, 0 `PARTIALLY_SUPPORTED`, 0 `NOT_SUPPORTED` e 0 `AMBIGUOUS`.

O validator `npm run validate:flashcards` mantém verificações estruturais, de tamanho e duplicidade, mas deixa a decisão semântica explicitamente editorial.

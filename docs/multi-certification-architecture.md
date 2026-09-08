# Multi-Certification Architecture

## Context

Etapa 14.1, executada como auditoria arquitetural sobre o commit `9e35c01b6bfbb910d98ed43e6fc4d3eb1fb60759`. O AZ-204 é o caso de teste da arquitetura; esta etapa não o habilita, não cria conteúdo e não altera runtime ou banco.

A pergunta de decisão é: **como AZ-900 e AZ-204 podem usar os mesmos motores sem duplicação, mistura de dados ou regressão do AZ-900?** A resposta é manter conteúdo no modelo relacional existente, extrair parâmetros específicos para policies pequenas e versionadas, e fazer os engines consumirem configuração explícita em vez de inferirem pelo código da certificação.

## AZ-900 V2 Baseline

Os três marcadores obrigatórios existem em `docs/az900-learning-experience-v2-release.md`:

- `AZ-900 Learning Experience V2: RELEASE READY`
- `AZ-900 Learning Experience V2 Baseline: FROZEN`
- `Multi-Certification Refactor Gate: OPEN`

O contrato congelado cobre Progressive Unlocking, Topic Checkpoint dinâmico com coverage/rotation, Flashcards Home/Free Study/Daily Review/Spaced Repetition, Review, Mock com snapshots e histórico, Readiness com safeguards/recomendações, Auth, RLS, progresso e isolamento de usuário. A baseline documentada contém 3 Domains, 12 Topics, 76 Lessons, 712 Content Blocks, 397 Flashcards e 512 Questions, das quais 439 são elegíveis para Mock. P0 = 0 e P1 = 0.

## Goals

- Reutilizar um único conjunto de engines para AZ-900 e AZ-204.
- Tornar explícita a fronteira entre engine, configuração e conteúdo.
- Resolver configuração por `certification.id/code` sem cadeias `if/else` por certificação.
- Preservar URLs, IDs, progresso, attempts, answers, reviews, snapshots e comportamento AZ-900.
- Manter seleção, timer e histórico autoritativos no servidor.
- Permitir um AZ-204 vazio e controlado para provar resolução, isolamento e empty states antes de conteúdo real.

## Non-Goals

- Criar ou habilitar AZ-204, Domains, Topics, Lessons, Questions ou Flashcards nesta etapa.
- Implementar novos Question Types, Labs, Story Mode, Map ou sandbox Azure.
- Criar plugin framework, DSL de certificação, event bus, micro-frontends ou dynamic module loader.
- Recalibrar AZ-900, remover Lesson Quiz histórico ou reescrever RLS.
- Colocar toda a aplicação em uma coluna `config JSONB`.

## Current Architecture

`certifications` já é o aggregate root do catálogo. A aplicação resolve `:certificationCode`, carrega a entidade, propaga `currentCertification` pelo contexto e busca o currículo por `certification_id`. Conteúdo e progresso seguem relações estáveis:

```text
certifications
  └─ domains
      └─ topics
          └─ lessons
              ├─ lesson_content_blocks ── visual_experiences
              ├─ questions ── question_options
              └─ flashcards

auth.users
  ├─ user_lesson_progress ── lessons
  ├─ quiz_attempts ── quiz_attempt_questions ── quiz_answers
  ├─ flashcard_reviews / user_flashcard_progress ── flashcards
  └─ mock_exam_attempts ── frozen questions/options ── answers
```

Propriedades reais de Certification: `id`, `code`, `name`, `provider`, `description`, `level`, `is_enabled`, `display_order`, `created_at`, `updated_at`. Type, service, context, provider, seleção e cards são `ALREADY_GENERIC`. Configuração pedagógica/runtime ainda não faz parte desse modelo e é `NEEDS_CONFIG`; não deve ser misturada à identidade.

O cadastro baseline já contém um registro AZ-204 desabilitado. Ele é somente catálogo e não equivale a um shell validado; esta etapa não o modifica.

## Already Generic

Foram confirmados 22 itens reutilizáveis, detalhados no inventário:

- resolução da Certification, contexto, catálogo e rotas;
- hierarquia e carregamento de currículo;
- cálculo de progresso e próxima ação;
- resolver e guards de Progressive Unlocking;
- persistência de Quiz/Checkpoint/Review;
- persistência, disponibilidade e repetição espaçada de Flashcards;
- Review filtrada por usuário + certificação;
- persistência/lifecycle histórico do Mock, exceto start/selection/config;
- coletor/taxonomia do Readiness;
- renderers de Content Blocks e Visual Experiences;
- RLS baseada em proprietário e relações.

Não haverá `Az900StudyPath`, `Az204StudyPath`, `startAz204Mock` nem engines duplicados.

## Runtime Hardcodes

Os blockers de runtime estão concentrados:

1. Checkpoint: sizing 12/15/20, `single_choice` e dificuldade 30/50/20 dentro do SQL global.
2. Mock: guard `certification.code = 'az-900'`, exatamente três Domains, 40 questões, 11/15/14, 12/20/8, 3600 segundos e `az900-mock-v1` dentro de SQL/TS/UI.
3. Readiness: `calculateAz900Readiness`, default `AZ900_READINESS_CONFIG` e tipos/wrappers AZ-900.
4. Recommendations: imports diretos do Readiness AZ-900 mesmo quando RecommendationConfig é argumento.
5. Navigation: todas as features são sempre visíveis; não existe capability gate.
6. Lesson route: slug é único somente por Topic, enquanto o lookup da URL é por certificação.

Os textos/títulos de páginas de Mock e uma mensagem de Readiness também conhecem AZ-900. Eles não comprometem dados, mas comprometem a identidade correta.

## Certification Content

Curriculum, Questions, options, Flashcards, Content Blocks, Visual Experiences e seus mapeamentos de objetivo oficial continuam dados específicos. Migrations e validators `az900_*` permanecem específicos e congelados. AZ-204 deverá receber IDs próprios e migrations editoriais próprias; nunca reutilizar UUID de conteúdo AZ-900 nem transformar seed editorial em configuração de engine.

Classificação dos blocos:

- `GENERIC`: explanation, important, example, exam_tip, exam_trap, summary, image, video, visual_experience e seus renderers.
- `AZURE_REUSABLE`: dotnet_example e azure_lab como formatos; o payload permanece conteúdo da Lesson.
- `AZ900_SPECIFIC`: texto, exemplos, visuais e labs associados às Lessons AZ-900, não os componentes renderizadores.

## Certification Configuration

Configuração representa diferenças legítimas entre certificações. Ela deve ser pequena, tipada, validada, versionada e resolvida antes do engine. Conteúdo não entra nela.

```text
Certification
│
├── Curriculum (database content)
│   ├── Domains
│   ├── Topics
│   ├── Lessons + Content Blocks + Visuals
│   ├── Questions + Options
│   └── Flashcards
│
├── Checkpoint Policy (server-authoritative)
├── Mock Policy (server-authoritative)
├── Readiness + Recommendation Config (typed runtime)
└── Capabilities (small typed runtime contract)
          │
          ▼
Generic Platform Engines
├── Learning Progression
├── Checkpoint Engine
├── Flashcards Engine
├── Review Engine
├── Mock Engine
├── Readiness Engine
└── Recommendation Engine
```

## Curriculum

Certification → Domain → Topic → Lesson é realmente genérico. `getCertificationContent` filtra Domains por Certification, Topics por esses Domains e Lessons por esses Topics. Nenhum runtime pressupõe exatamente três Domains para a trilha, progresso ou progressão; essa suposição existe apenas no Mock selector/config AZ-900 e em validadores específicos.

As ordens `display_order` são o contrato da sequência. Configurações que referenciam Domains devem usar IDs estáveis, não `display_order`, embora a ordem continue útil para apresentação.

AZ-900 e AZ-204 podem ter a mesma Lesson slug sem conflito: cada página procura o slug apenas no currículo carregado da certificação atual. Contudo, o schema permite o mesmo slug em Topics diferentes da mesma certificação e `findLessonStudyContext` seleciona a primeira ocorrência. Antes de inserir conteúdo AZ-204, deve existir uma garantia de unicidade por Certification ou uma rota desambiguada. Preferência: adicionar constraint/índice derivado por Certification se viável; se isso exigir desnormalização, evoluir para rota com Topic ID e manter redirect das URLs AZ-900.

## Progressive Unlocking

O resolver TypeScript e os guards SQL derivam ordem, pré-requisitos, conclusão e grandfathering das relações reais. Não há código AZ-900, nomes de Domains ou arrays fixos. O mesmo resolver funciona para AZ-204 sem saber que AZ-900 existe.

Contrato preservado:

```text
Lesson available/completed
  → próxima Lesson do Topic
  → todas as Lessons concluídas
  → Topic Checkpoint available/completed
  → primeiro conteúdo do próximo Topic
```

Deep-link guards e Study Today usam o mesmo progresso. Novas configurações não devem criar uma segunda definição de disponibilidade.

## Topic Checkpoint

O engine conceitual comum permanece responsável por eligibility, criação/resume do attempt, seleção, answers, result, retake, history, rotation, Review e liberação do próximo Topic. A persistência já é genérica e o wrapper público respeita os guards de progressão.

A policy específica deve conter apenas:

- `enabled`;
- `policyVersion`;
- `eligibleQuestionTypes` (inicialmente `single_choice`);
- sizing brackets e clamp ao pool;
- `lessonCoverage` (`requiredWhenPoolExists` no AZ-900 V1);
- dificuldade alvo/estratégia;
- rotation strategy (`unseen_then_least_recent`, com penalidade do último attempt).

O engine não deve escolher defaults AZ-900 quando a policy estiver ausente. Capability desabilitada/sem policy produz estado indisponível explícito.

## Checkpoint Sizing

A única source of truth de runtime está em `public.calculate_topic_checkpoint_size(lesson_count, pool_count)` e é consumida tanto por `start_topic_quiz_unchecked` quanto por `get_topic_quiz_summaries`. A UI somente exibe `target_question_count`; não replica faixas. A própria migration contém assertions 12/15/20, e os testes/documentos de regressão congelam o comportamento.

Config AZ-900 equivalente:

```text
policyVersion: az900-checkpoint-v1
1..3 published Lessons  -> 12 Questions
4..5 published Lessons  -> 15 Questions
6+ published Lessons    -> 20 Questions
effective size          -> min(target, eligible pool)
```

Outra Certification poderá fornecer outros brackets à mesma função/selector. A assinatura futura deve resolver uma policy por Certification/Topic no servidor; não deve confiar em números enviados pelo navegador.

## Flashcards

Flashcards Home, browsing Domain/Topic, Free Study, Daily Review e Spaced Repetition já são genéricos. Catálogo, overview, availability e study queue recebem `p_certification_id`; cards são ligados a Lessons, e availability é derivada de `user_lesson_progress` da mesma Lesson. Review state é user scoped e não cria `az900FlashcardAvailability`.

Ao abrir `/certifications/az-204/flashcards`, as consultas ficam isoladas. Com shell sem conteúdo, o resultado correto é empty state, não cards AZ-900. Limites de 20 cards/dia e 5 novos são defaults globais de produto hoje; só devem virar config por certificação se surgir requisito real.

## Review

`get_user_question_stats(p_certification_id)` combina `attempt.user_id = auth.uid()`, `attempt.certification_id` e `question.certification_id`. `start_review_quiz` aplica o mesmo escopo e `getActiveReviewQuiz` filtra certificação. Portanto, um usuário no AZ-204 não recebe erro AZ-900 na Review Page.

Fontes atuais:

- erros de Topic Checkpoint;
- histórico de Lesson Quiz;
- Review Quiz subsequente.

Mock possui review próprio por attempt e alimenta Readiness/recomendações, mas não é agregado atualmente ao `get_user_question_stats`. Isso é comportamento existente, não blocker. O roadmap deve adicionar testes multi-certificação explícitos antes do shell, sem redesenhar Review.

Lesson Quiz seguirá `GENERIC_LEGACY_SUPPORT`: manter route, tables, services, attempts, Review e evidence source; remover do primary flow não autoriza apagar história. `lesson_quiz` continua com peso 0,35 em `az900-readiness-v1`. Novos alunos podem gerar pouca ou nenhuma evidência dessa fonte; a futura config AZ-204 decide peso, e o engine trata ausência normalmente. Depreciação física fica para outra fase.

## Mock Exam

Persistência, snapshots, answer lifecycle, submit/scoring, result, completed review, history e retake já são estruturalmente genéricos. Attempts antigos devem continuar abrindo os snapshots congelados de pergunta, opções, resposta correta, Domain, Topic, Lesson e versão; nunca reconstruir uma tentativa usando conteúdo ou config atual.

O start/selector ainda é AZ-900-specific. A arquitetura alvo separa:

**Generic Mock Engine**

- resolve/create/resume attempt por usuário + certificação;
- valida pool e seleciona por uma policy recebida/resolvida no servidor;
- congela snapshot e policy efetiva;
- mantém timer, answer, submit, score, review, history e retake.

**Certification Mock Policy**

- `enabled`, `policyVersion`;
- `questionCount`, `timeLimitSeconds`;
- `eligibleQuestionTypes` e flag editorial `mock_eligible`;
- `domainAllocations` por Domain ID;
- `difficultyAllocations`;
- coverage/diversity/rotation policy.

AZ-900 deve ser materializado primeiro com 40 questões, 3600 segundos, 11/15/14 por Domain e 12/20/8 por dificuldade. A validação exige que allocations somem `questionCount`, Domains existam e pertençam à Certification, tempo seja positivo, tipos sejam suportados, cada pool tenha capacidade e a versão não esteja vazia.

O timer deve continuar server-authoritative. O valor efetivo é congelado em `mock_exam_attempts.time_limit_seconds`; alterações futuras só afetam novos attempts. Domain allocation deve usar UUID, não posição 1/2/3. `selection_policy_version`, `domain_allocation` e `difficulty_allocation` já preservam parte do contexto histórico.

Rotas de execution/result/review validam que `attempt.certificationId === currentCertification.id`, evitando abrir attempt AZ-900 sob URL AZ-204. A primeira quebra funcional de um AZ-204 habilitado ocorre em **Start Mock**, pois o RPC rejeita qualquer código diferente de `az-900`; a página de Mock abre e history vazio funciona até esse clique. Antes disso, a navegação já apresenta incorretamente a feature como disponível.

## Readiness

O coletor SQL, taxonomy builder, evidence types e a maior parte do algoritmo são genéricos. A função já recebe `ReadinessConfig`, mas seu nome/default e os wrappers sempre selecionam AZ-900. Target:

```ts
calculateCertificationReadiness(bundle, config)
```

Sem default implícito. Para compatibilidade durante a migração, `calculateAz900Readiness` pode ser um alias temporário testado, removido somente depois que todos os callers resolverem config.

Campos que variam legitimamente: `calculationVersion`, source weights, Domain weights, evidence thresholds, recency, consistency, trend, safeguards e classification thresholds. O algoritmo de agregação, reasons, evidence levels e safeguards continua comum.

O novo sizing de Checkpoint não precisa ser conhecido pelo Readiness. O coletor trabalha com respostas individuais, questões distintas, número de sessões e timestamps; thresholds são parte da ReadinessConfig. Um único Checkpoint maior aumenta answers/distinct questions, mas não inventa sessões nem mock attempts, e os safeguards impedem classificação forte sem amplitude. Essa separação deve permanecer.

## Recommendations

O catálogo usa Certification ID, Topic/Lesson IDs, evidência e rotas parametrizadas; não conhece títulos nem estrutura AZ-900. O ranking é reutilizável, mas ainda consulta diretamente `AZ900_READINESS_CONFIG` para recency, safeguards e Domain weights, além do default AZ-900 de RecommendationConfig.

Target:

```text
calculateStudyRecommendations(
  readiness,
  evidenceBundle,
  catalog,
  recommendationConfig,
  readinessConfig
)
```

Actions de Mock/Flashcards/Checkpoint devem respeitar capabilities e policy availability; conteúdo locked não deve ser recomendado como ação navegável. IDs e routes continuam derivados do catálogo atual.

## Navigation

Dashboard, Estudo do Dia, Trilha e Progresso são core. Flashcards, Review, Simulados e Readiness dependem de engine/policy/conteúdo e podem variar. Routes continuam únicas, mas menu, CTA e route guard precisam usar o mesmo capability contract para não oferecer caminho inválido.

Não criar dezenas de flags. Conjunto inicial necessário:

```text
checkpoint
flashcards
mockExam
readiness
```

Review acompanha assessments/checkpoint e pode permanecer core enquanto tiver empty state; se uma certificação futura não tiver Questions, a decisão pode ser revisitada. `labs` fica DEFER até existir um produto além do bloco instrucional `azure_lab`.

## Capabilities

Capabilities descrevem disponibilidade de superfícies, não detalhes do algoritmo. Elas não substituem config nem publicação de conteúdo. Regras:

- capability habilitada exige config válida quando o engine é configurável;
- capability desabilitada remove item/CTA e route guard mostra estado controlado;
- ausência de conteúdo gera empty state, não capability falsa automaticamente;
- `is_enabled` da Certification controla acesso à jornada inteira; capability controla uma feature dentro dela.

## Security

Não foi encontrada policy RLS dependente do código `az-900`. Conteúdo publicado é legível por usuários autenticados; dados pessoais são protegidos por `auth.uid()`. Security-definer RPCs validam owner e/ou derivam Certification pelas relações.

Config de seleção precisa ser server-authoritative. O navegador pode pedir “iniciar”, mas não fornecer allocations, timer ou versão arbitrários. Policies normalizadas devem ser somente leitura para authenticated, ou acessadas internamente pelos RPCs. IDs de Domain presentes em config devem ser validados contra a mesma Certification.

## User + Certification Isolation

| Feature | User scoped | Certification scoped | Safe today? | Action |
|---|---|---|---|---|
| Progress | RLS por `user_id` | UI consulta somente Lesson IDs do currículo atual; relação Lesson → Certification | Sim | Adicionar fixture A/B; não duplicar `certification_id` sem necessidade. |
| Study Today | Usa progress map do usuário | Recebe Domains e summaries da Certification atual | Sim | Aplicar capabilities aos CTAs finais. |
| Checkpoint | Attempts/RLS por usuário | Topic deriva Certification; summaries recebem `p_certification_id` | Sim para dados | Generalizar policy/sizing, não o storage. |
| Flashcards | Reviews/progress por usuário | RPCs filtram `p_certification_id` pela hierarquia | Sim | Validar empty state AZ-204. |
| Review | Stats/attempts por usuário | Stats/start/active filtram Certification | Sim | Criar regressão explícita cross-cert. |
| Mock | Attempts e subrows owner-only | Attempts/history/start recebem Certification; páginas checam attempt vs contexto | Persistência sim; start não | Generalizar selector/config e manter checks. |
| Readiness | Coletor usa `auth.uid()` | RPC e currículo recebem Certification ID | Coleta sim; cálculo não | Resolver config correta sem default AZ-900. |

RLS não representa “certificação selecionada” como claim de segurança, nem precisa: o limite sensível é o proprietário. O isolamento de certificação é integridade/query scope, garantido por FKs e parâmetros; deve ser testado junto com RLS.

## Versioning

Cada policy/config possui identificador imutável e significativo:

- `az900-checkpoint-v1`;
- `az900-mock-v1` (já persistido);
- `az900-readiness-v1` (já retornado);
- `az900-study-recommendations-v1` (já retornado);
- futuros `az204-*-v1` somente após validação.

Checkpoint precisa congelar `policy_version` no attempt em evolução aditiva; attempts antigos sem valor são interpretados pelo contrato histórico que já congela `total_questions` e a lista de perguntas. Mock já congela policy e allocations. Readiness é cálculo derivado: resultados apresentados devem expor `calculationVersion`; histórico materializado futuro deve guardar essa versão e `evidenceAsOf`.

Uma policy publicada não muda de significado. Ajuste cria V2 e só afeta novas seleções/cálculos conforme regra explícita. Nunca editar V1 para “apontar” a comportamento novo.

## Backward Compatibility

São invariantes:

- URLs AZ-900 atuais e links salvos continuam válidos;
- UUIDs de Certification/Domain/Topic/Lesson/Question/Flashcard não mudam;
- user_lesson_progress e Flashcard history não são resetados;
- Checkpoint/Lesson/Review attempts e answers permanecem acessíveis;
- Mock histórico abre snapshots, não catálogo vivo;
- `az900-readiness-v1` produz o mesmo resultado para o mesmo bundle/config;
- grandfathering de progressão continua válido;
- validators/release docs AZ-900 não são substituídos por testes genéricos mais fracos.

Estratégias baseadas em reset, reseed destrutivo ou regeneração de attempt são rejeitadas.

## Runtime Config Proposal

Recomendação híbrida, evitando tanto hardcode disperso quanto JSON gigante:

1. **TypeScript tipado e validado** para contrato agregado, capabilities, Readiness, Recommendations e presentation metadata. Um registry resolve por código normalizado e falha fechado quando não há config.
2. **Tabelas relacionais pequenas e autoritativas** para Checkpoint e Mock policies consumidas por SQL, com allocations/brackets em linhas relacionadas e versions imutáveis.
3. **`certifications` permanece identidade/catálogo**. Não adicionar uma coluna por parâmetro nem `config JSONB` monolítico.

Conceito, não implementação:

```ts
interface CertificationRuntimeConfig {
  version: string
  certificationCode: string
  capabilities: {
    checkpoint: boolean
    flashcards: boolean
    mockExam: boolean
    readiness: boolean
  }
  checkpoint: CheckpointPolicyRef | null
  mock: MockPolicyRef | null
  readiness: ReadinessConfig | null
  recommendations: StudyRecommendationConfig | null
}
```

O registry TS não replica allocations autoritativas; guarda referências/metadata necessárias à UI. O servidor resolve a policy por Certification ID. Validação no startup/test garante código conhecido, versão única e coerência capability/config. Validação SQL garante sums, bounds, ownership dos Domains, tipos suportados e capacidade.

## Migration Strategy

1. Criar tipos, schema validator e resolver de `CertificationRuntimeConfig`; registrar AZ-900 com equivalência, sem trocar engines.
2. Adicionar policy de Checkpoint versionada e preencher AZ-900; fazer summary/start consumirem a mesma policy; executar todo o V2 regression contract.
3. Adicionar policy relacional do Mock e preencher exatamente 40/3600/11-15-14/12-20-8; generalizar selector mantendo snapshots e `az900-mock-v1`.
4. Extrair Readiness/Recommendations genéricos com config explícita e testes golden de paridade AZ-900.
5. Aplicar capabilities, route guards, copy dinâmica, slug safety e testes de isolamento A/B.
6. Somente então validar AZ-204 como shell desabilitado/controle, sem conteúdo real, habilitando-o apenas em ambiente de teste quando configs/empty states estiverem completos.

Cada mudança é aditiva primeiro. Hardcodes só são removidos depois da paridade; aliases antigos só desaparecem quando callers e testes migrarem.

## AZ-204 Empty Shell

O shell futuro usa o registro AZ-204 já existente, ainda sem currículo. A validação controlada deve provar:

- selector/card/route context resolvem AZ-204 sem branch;
- config resolver retorna perfil AZ-204 explícito ou falha fechado;
- Dashboard, Study Today, Study, Progress, Flashcards e Review mostram empty states corretos;
- features sem policy são ocultadas/bloqueadas por capabilities;
- nenhum count, history, due card, erro ou readiness AZ-900 aparece;
- chamadas com attempt AZ-900 em URL AZ-204 são rejeitadas/redirecionadas;
- Progressive Unlocking tolera currículo vazio;
- ligar uma fixture mínima temporária de teste não contamina AZ-900;
- desligar/remover a fixture não exige reset de dados.

Não inserir conteúdo AZ-204 em 14.1–14.6. O shell é teste arquitetural, não lançamento.

## Risks

| Risk | Level | Mitigation |
|---|---|---|
| Generalizar o selector SQL do Mock e alterar seleção/snapshots AZ-900 | HIGH | Policy equivalente, golden allocation tests, histórico antes/depois e rollout aditivo. |
| Readiness/Recommendations mudarem score por default/config incompleta | HIGH | Config obrigatória, fixtures golden de `az900-readiness-v1`, sem default silencioso. |
| Checkpoint perder coverage/rotation ou mudar attempts ativos | HIGH | Uma source of truth, attempts ativos imutáveis, testes 12/15/20, coverage e retakes. |
| Mistura cross-cert em Review/evidence | HIGH | Fixtures com mesmo usuário e dados A/B; assertions negativas em RPCs. |
| RLS/security-definer aceitar IDs de outra Certification | HIGH | Validar relações dentro dos RPCs e testes authenticated user A/B. |
| Slug duplicado dentro da mesma Certification | MEDIUM | Constraint/validator ou rota desambiguada com compatibilidade. |
| Capabilities divergirem de configs/rotas | MEDIUM | Resolver único, schema validation e route/menu tests. |
| Copy AZ-900 permanecer em telas comuns | MEDIUM | Audit textual e identidade vinda do contexto/config. |
| Flashcards/progresso/content renderers | LOW | Já são relacionais/genéricos; manter regressões existentes. |
| Criar abstrações para Labs/question types sem requisito | LOW se evitado | Manter DEFER. |

Não foram encontrados P0/P1 na baseline. Os itens HIGH são riscos de implementação futura, não defeitos ativos do AZ-900 congelado.

## Roadmap

### 14.2 — Certification Configuration Foundation

Tipos/validator/resolver tipados, perfil AZ-900 equivalente, referências de policy e contrato mínimo de capabilities. Sem trocar algoritmo nem habilitar AZ-204.

### 14.3 — Generic Topic Checkpoint Policy

Policy SQL versionada, brackets, eligibility/difficulty/coverage/rotation; migração aditiva e paridade completa V2, incluindo attempts ativos/legados.

### 14.4 — Generic Mock Exam Engine

Policies/allocations relacionais, selector sem guard por código, timer por policy, copy dinâmica e regressão de snapshots/history.

### 14.5 — Generic Readiness + Recommendations

Config explícita, rename/alias seguro, remoção dos imports AZ-900 internos, capabilities nas actions e golden tests de paridade.

### 14.6 — Certification Isolation, Slugs + Capabilities

Route/menu/CTA guards, garantia de slug, matriz user + certification em testes SQL/DOM e empty states. Revisar Review, Flashcards, Mock attempts e evidence com usuário A/B.

### 14.7 — AZ-204 Empty Shell Validation

Config controlada, nenhuma carga curricular real, validação de routes/empty states/fail-closed/isolation. O conteúdo AZ-204 começa somente em etapa posterior aprovada.

## Decision

A arquitetura atual já possui uma base multi-certificação forte no catálogo, currículo, contexto, rotas, progresso e persistência. AZ-204 não exige duplicação de engines. O caminho seguro é uma generalização incremental orientada por policies/configs versionadas, preservando o banco relacional como source of truth de conteúdo e o servidor como autoridade de seleção.

As cinco condições antes de habilitar o shell são: Checkpoint configurável, Mock configurável, Readiness/Recommendations com config explícita, capability guards e slug/isolamento testados. Nenhuma exige reset ou mutação da baseline AZ-900.

**Multi-Certification Architecture V2: READY**

**AZ-900 V2 Regression Contract: ACTIVE**

**AZ-204 Foundation Gate: OPEN**

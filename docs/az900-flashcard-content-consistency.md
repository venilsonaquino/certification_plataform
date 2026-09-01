# AZ-900 Flashcard Content Consistency

## Scope

Auditoria editorial da cadeia `Certification → Domain → Topic → Lesson → Lesson Content Blocks → Flashcards` após a Etapa 13.5.3.

Pré-condição: **AZ-900 Flashcards Experience: READY**, com P0 = 0 e P1 = 0.

O inventário reconstruído a partir das migrations contém 397 Flashcards publicados, associados a 76 Lessons publicadas. Nenhuma Lesson publicada ficou sem Flashcards.

## Methodology

1. Reconstrução do estado final dos Flashcards pelas migrations, acompanhando inserts, updates diretos e rewrites por `CASE`, sempre pelo UUID.
2. Leitura dos Content Blocks de cada Lesson, incluindo `explanation`, `important`, `example`, `dotnet_example`, `exam_tip`, `exam_trap`, `summary`, `visual_experience` e demais tipos existentes.
3. Comparação semântica por Lesson. Correspondência conceitual foi aceita; igualdade literal não foi exigida.
4. Conteúdo existente somente em Questions, explanations, verso do próprio card ou Review não contou como ensino.
5. Heurísticas estruturais e lexicais foram usadas somente para gerar candidatos. A classificação final foi editorial.
6. UUID, associação histórica e estado de spaced repetition foram preservados em todas as correções.

Princípio aplicado: **Lesson teaches. Flashcard recalls.**

O validator permanente pode ser executado com `npm run validate:flashcards`. Ele detecta cards vazios, associação não reconstruída, respostas/frentes excessivamente longas, duplicatas exatas e duplicatas frontais muito próximas. A lista lexical é declaradamente não semântica e não aprova conteúdo por keyword overlap.

## Classification

| Classificação | Inicial | Final |
| --- | ---: | ---: |
| SUPPORTED | 386 | 397 |
| PARTIALLY_SUPPORTED | 6 | 0 |
| NOT_SUPPORTED | 5 | 0 |
| AMBIGUOUS | 0 | 0 |
| **Total** | **397** | **397** |

Classificação inicial por Domain:

| Domain | Total | Supported | Partial | Not supported | Ambiguous | Final |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 — Describe cloud concepts | 84 | 75 | 5 | 4 | 0 | 84 Supported |
| 2 — Describe Azure architecture and services | 183 | 181 | 1 | 1 | 0 | 183 Supported |
| 3 — Describe Azure management and governance | 130 | 130 | 0 | 0 | 0 | 130 Supported |

## Initial Findings

Onze cards exigiram correção. Cinco introduziam conhecimento não presente na Lesson e seis dependiam de detalhe, exemplo ou formulação mais absoluta do que o conteúdo sustentava.

| Flashcard ID | Lesson | Inicial | Problema | Resolução | Final |
| --- | --- | --- | --- | --- | --- |
| `71000000-0000-4000-8000-000000000016` | `choosing-a-cloud-model` | NOT_SUPPORTED | Definia residência de dados sem a Lesson ensinar o conceito. | Lesson melhorada; card preservado. | SUPPORTED |
| `71000000-0000-4000-8000-000000000028` | `serverless-computing` | PARTIALLY_SUPPORTED | Exigia unidades específicas de cobrança não ensinadas. | Card reescrito para execução/consumo. | SUPPORTED |
| `71000000-0000-4000-8000-000000000037` | `elasticity` | PARTIALLY_SUPPORTED | Tratava automação como parte absoluta da definição. | Card reescrito para ajuste dinâmico. | SUPPORTED |
| `71000000-0000-4000-8000-000000000039` | `elasticity` | PARTIALLY_SUPPORTED | Presumia redução automática sem configuração. | Card reescrito para redução de capacidade conforme demanda. | SUPPORTED |
| `71000000-0000-4000-8000-000000000040` | `elasticity` | NOT_SUPPORTED | Introduzia Azure Autoscale, VM Scale Sets e App Service nessa Lesson. | Card reescrito para suporte/configuração do mecanismo. | SUPPORTED |
| `71000000-0000-4000-8000-000000000044` | `reliability` | PARTIALLY_SUPPORTED | Introduzia backup automatizado como exemplo não ensinado. | Card reescrito para recuperação de operação/dados. | SUPPORTED |
| `71000000-0000-4000-8000-000000000049` | `security-and-governance-benefits` | NOT_SUPPORTED | Introduzia investimento físico, equipes e certificações do provider. | Card reescrito para identity, encryption, services e controls. | SUPPORTED |
| `71000000-0000-4000-8000-000000000050` | `security-and-governance-benefits` | NOT_SUPPORTED | Dependia de certificações do provider não ensinadas. | Card reescrito para uso/configuração dos controles. | SUPPORTED |
| `71000000-0000-4000-8000-000000000055` | `manageability` | PARTIALLY_SUPPORTED | Exigia autoscale por métrica de CPU, além do conteúdo. | Card reescrito para escala e monitoramento. | SUPPORTED |
| `71000000-0000-4000-8000-000000000099` | `azure-resource-hierarchy` | PARTIALLY_SUPPORTED | Introduzia budgets e uma promessa ampla de centralização. | Card reescrito para escopo de governança e acesso. | SUPPORTED |
| `72000000-0000-4000-8000-000000000020` | `virtual-networks-and-subnets` | NOT_SUPPORTED | Afirmava o escopo regional da VNet sem ensiná-lo. | Lesson melhorada; card preservado. | SUPPORTED |

## Domain 1

Resultado final: **PASS — 84/84 SUPPORTED**.

| Topic | Lessons | Flashcards | Final |
| --- | ---: | ---: | --- |
| Cloud Computing | 7 | 37 | 37 Supported |
| Benefits of Cloud Services | 7 | 28 | 28 Supported |
| Cloud Service Types | 4 | 19 | 19 Supported |

As nove inconsistências do Domain foram resolvidas sem mover ou recriar cards.

## Domain 2

Resultado final: **PASS — 183/183 SUPPORTED**.

| Topic | Lessons | Flashcards | Final |
| --- | ---: | ---: | --- |
| Core Architectural Components | 7 | 37 | 37 Supported |
| Azure Compute Services | 9 | 34 | 34 Supported |
| Azure Networking Services | 5 | 23 | 23 Supported |
| Azure Storage Services | 8 | 40 | 40 Supported |
| Azure Identity, Access and Security | 9 | 49 | 49 Supported |

O gap regional da VNet e a granularidade do card de Resource Hierarchy foram resolvidos. Nenhuma associação de Lesson mudou.

## Domain 3

Resultado final: **PASS — 130/130 SUPPORTED**.

| Topic | Lessons | Flashcards | Final |
| --- | ---: | ---: | --- |
| Azure Cost Management | 4 | 26 | 26 Supported |
| Governance and Compliance | 3 | 20 | 20 Supported |
| Tools for Managing and Deploying Azure Resources | 7 | 45 | 45 Supported |
| Azure Monitoring Tools | 6 | 39 | 39 Supported |

Nenhuma correção curricular ou de card foi necessária no Domain 3.

## Lesson Improvements

```text
Lesson ID: resolved by slug choosing-a-cloud-model
Gap: data residency appeared in a Flashcard but was not explicitly taught.
Content block changed: 7a030000-0000-4000-8000-000000000001
Flashcards supported after change: 71000000-0000-4000-8000-000000000016

Lesson ID: resolved by slug virtual-networks-and-subnets
Gap: regional scope of a VNet was not explicit.
Content block changed: 7b0e0000-0000-4000-8000-000000000001
Flashcards supported after change: 72000000-0000-4000-8000-000000000020
```

Os blocks foram complementados de forma concisa, sem alterar tipo, UUID, ordering, renderer ou fallback.

## Flashcards Rewritten

Nove Flashcards foram reescritos in-place. Os UUIDs e todas as referências de `flashcard_reviews` e `user_flashcard_progress` permanecem válidos.

- `71000000-0000-4000-8000-000000000028`
- `71000000-0000-4000-8000-000000000037`
- `71000000-0000-4000-8000-000000000039`
- `71000000-0000-4000-8000-000000000040`
- `71000000-0000-4000-8000-000000000044`
- `71000000-0000-4000-8000-000000000049`
- `71000000-0000-4000-8000-000000000050`
- `71000000-0000-4000-8000-000000000055`
- `71000000-0000-4000-8000-000000000099`

## Flashcards Moved

Nenhum. A associação atual era pedagogicamente adequada e foi preservada.

## Flashcards Removed/Unpublished

Nenhum. Todos possuem valor pedagógico após as correções.

## Redundancy

- Duplicatas exatas normalizadas: 0.
- Duplicatas frontais de alta similaridade detectadas pelo validator: 0.
- O par “o que é Cloud Shell?” versus “Cloud Shell e CLI são sinônimos?” foi revisado e mantido: definição e diferenciação avaliam recuperações distintas.
- Cards excessivamente amplos: 0.
- Frentes acima de 260 caracteres: 0.
- Versos acima de 600 caracteres: 0.

## Distribution

| Métrica | Resultado |
| --- | ---: |
| Flashcards publicados | 397 |
| Lessons publicadas com Flashcards | 76 |
| Lessons publicadas sem Flashcards | 0 |
| Mínimo por Lesson | 3 |
| Máximo por Lesson | 8 |

A faixa 3–8 é coerente com o tamanho e a função das Lessons; nenhum outlier exigiu redistribuição.

## Terminology

- A terminologia existente foi preservada: Microsoft Entra ID, Azure RBAC, Azure Policy, Cloud Shell e nomes atuais dos serviços.
- Termos técnicos já usados nas Lessons, como `serverless`, `Elasticity`, `Reliability`, `Identity` e `Shared Responsibility Model`, foram mantidos nos cards relacionados.
- Erros evidentes nos nove cards alterados foram corrigidos sem iniciar a auditoria global de português.

## Remaining Issues

- Unsupported concepts remaining: 0.
- AMBIGUOUS: 0.
- Candidatos confirmados para 13.5.5: 0. O Question Bank não foi auditado nem alterado nesta etapa.
- A lista lexical do validator continua sendo uma fila de inspeção, não uma classificação semântica automática.

## Validation

Amostra editorial manual:

| Domain | Fluxo amostrado | Resultado |
| --- | --- | --- |
| 1 | `choosing-a-cloud-model` → residência de dados → card preservado | PASS — revisão natural após a Lesson |
| 2 | `virtual-networks-and-subnets` → escopo regional → card preservado | PASS — sem conhecimento externo |
| 3 | `azure-policy` → compliance → card de compliant/non-compliant | PASS — conceito explícito nos blocks |

O smoke test no navegador confirmou a proteção da rota e o redirecionamento para Login. A sessão disponível não estava autenticada; por isso o walkthrough pedagógico foi concluído diretamente sobre os Content Blocks e cards versionados. Os fluxos autenticados permanecem cobertos pela regressão automatizada.

Regressão funcional:

```text
Study Path: PASS
Lesson: PASS
Lesson completion: PASS
Progressive Unlocking: PASS
Topic Checkpoint: PASS
Flashcards Home: PASS
Free Study: PASS
Daily Review: PASS
Spaced Repetition: PASS
Review: PASS
Mock: PASS
Readiness: PASS — unchanged
Progress: PASS
User history: PASS — UUIDs and relationships preserved
```

## Decision

```text
13.5.3 prerequisite: PASS
Total Flashcards: 397

Initial classification:
SUPPORTED: 386
PARTIALLY_SUPPORTED: 6
NOT_SUPPORTED: 5
AMBIGUOUS: 0

Final classification:
SUPPORTED: 397
PARTIALLY_SUPPORTED: 0
NOT_SUPPORTED: 0
AMBIGUOUS: 0

Lessons changed: 2
Flashcards rewritten: 9
Flashcards moved: 0
Flashcards unpublished/removed: 0
Duplicate Flashcards resolved: 0
Unsupported concepts remaining: 0

Domain 1: PASS
Domain 2: PASS
Domain 3: PASS
Flashcards Home regression: PASS
Free Study: PASS
Daily Review: PASS
Spaced Repetition: PASS
Progressive Unlocking: PASS
Topic Checkpoint: PASS
User history: PASS
```

```text
Typecheck: PASS
Lint: PASS
Tests: 242 / 242
Build: PASS — 1,858 modules transformed
git diff --check: PASS
DB dry run: PASS — migrations 13.5.2, 13.5.3 and 13.5.4 detected; nothing applied
Editorial validator: PASS — 397 cards, 76 Lessons, 0 structural errors, 0 duplicate/length candidates
P0: 0
P1: 0
P2: 0
P3: 0
```

**AZ-900 Content ↔ Flashcard Consistency: READY**

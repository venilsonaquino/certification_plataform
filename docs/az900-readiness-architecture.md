# AZ-900 Readiness Architecture

Auditoria arquitetural da Etapa 12.1, realizada após o fechamento do **AZ-900 Mock Exam System**. Este documento descreve como transformar o histórico real da plataforma em sinais explicáveis de preparação. Ele não implementa score, não estima probabilidade de aprovação e não equipara resultados internos à escala oficial da prova.

## Goals

- Responder, com evidência rastreável, em quais Domains e Topics o aluno está forte ou precisa revisar.
- Distinguir desempenho, cobertura curricular, consistência, tendência, recência e quantidade de evidência.
- Usar os 3 Domains e os 12 Topics reais da trilha AZ-900 sem converter conclusão de conteúdo em conhecimento comprovado.
- Produzir classificações determinísticas e testáveis, acompanhadas de motivos, contagens e nível de confiança.
- Permitir recomendações futuras de estudo sem IA e sem alterar o Mock Exam.

## Non-Goals

- Declarar chance de aprovação, probabilidade de passar, equivalência com 700/1000 ou garantia de resultado.
- Declarar `exam ready` a partir de um único Mock ou de conclusão de Lessons.
- Somar ou tirar média simples de todas as atividades.
- Alterar as engines de Lesson, Flashcard, Quiz, Review ou Mock Exam.
- Implementar fórmula, migration, RPC, componente React ou recomendação nesta etapa.

## Available Evidence

| Fonte | Registros reais | Sinais disponíveis | Limites observados |
| --- | --- | --- | --- |
| Lessons | `user_lesson_progress` | `status`, `started_at`, `completed_at`, `last_accessed_at`; cobertura e sequência concluída | Não mede compreensão, tempo real nem qualidade da leitura. `completed_at` é preservado na primeira conclusão. |
| Flashcards | `flashcard_reviews`, `user_flashcard_progress` | avaliações `again`, `hard`, `good`, `easy`; contagem de revisões; revisões bem-sucedidas; intervalo; última revisão; próxima revisão; cards novos/vencidos | Não existe resposta objetiva correta/incorreta. A avaliação é auto-relatada; `good/easy` não equivale a acerto de prova. |
| Lesson Quiz | `quiz_attempts`, `quiz_attempt_questions`, `quiz_answers` | tentativas concluídas, até 5 Questions por tentativa, score, resposta por Question, acertos, erros e timestamps | Escopo pequeno, feedback imediato e seleção determinística dos primeiros itens reduzem independência entre retakes. |
| Topic Quiz | as mesmas tabelas de Quiz com `quiz_type = 'topic'` | até 10 Questions, histórico de tentativas, score, respostas, performance por Lesson/Topic e retakes | O resumo atual expõe apenas o último score, mas o histórico bruto existe. Não há snapshot agregado de tendência. |
| Topic Quiz rotation | `start_topic_quiz` atual | prioriza Questions ainda não vistas, reduz repetição da tentativa anterior, distribui Lessons e busca 3 easy / 5 medium / 2 hard quando o pool permite | Rotação melhora diversidade, mas não torna tentativas completamente independentes quando o pool é limitado. |
| Review Quiz | Quiz com `quiz_type = 'review'` e `get_user_question_stats` | erros recorrentes, taxa de erro por Question, último resultado e recência | Amostra deliberadamente enviesada para erros anteriores. Serve para remediação, não como avaliação ampla equivalente a Topic Quiz ou Mock. |
| Mock Exam | `mock_exam_attempts`, `mock_exam_attempt_questions`, `mock_exam_answers` | status, 40 Questions, Practice Score, acertos, erros, não respondidas, duração, retakes, recência e allocations | Somente tentativas finalizadas produzem resultado. Abandono não mede proficiência; expiração pode misturar conhecimento com gestão do tempo. |
| Mock breakdown | snapshots imutáveis por Question e RPC de resultado | Domain, Topic e difficulty breakdown reconstruíveis de acordo com o conteúdo visto na tentativa | A dificuldade é classificação editorial, não parâmetro psicométrico calibrado. |

### Sinais que não existem

- Acerto/incorreto objetivo de Flashcard.
- Percentual de leitura dentro de uma Lesson, compreensão, atenção ou tempo real de estudo.
- Tempo de resposta por Question de Quiz; há apenas início/fim da tentativa e `answered_at`.
- Uso de dica, grau de confiança da resposta ou motivo do erro.
- Mapeamento atômico Question → objetivo oficial; a granularidade disponível é Lesson/Topic/Domain.
- Calibração psicométrica, poder de discriminação ou equivalência com questões oficiais.
- Resultado oficial de prova ou prática externa.
- Snapshot histórico de Readiness, versão de cálculo ou histórico de recomendações.
- RPC consolidada de evidências de Readiness.

## Evidence Quality

Hierarquia recomendada, baseada no comportamento real de cada fluxo:

1. **Strong evidence — Mock Exam finalizado:** cobre múltiplos Domains e Topics, não entrega feedback durante a execução e preserva snapshots imutáveis. É a principal evidência de performance global.
2. **Medium evidence — Topic Quiz concluído:** mede um Topic diretamente e possui rotação de retake. É a principal evidência dirigida para confirmar ou contestar um sinal do Mock naquele Topic.
3. **Supporting evidence — Lesson Quiz concluído:** ajuda a localizar lacunas dentro do Topic, mas tem amostra de até cinco itens, feedback imediato e menor diversidade.
4. **Remediation evidence — Review Quiz e erros recorrentes:** é valioso para encontrar conceitos persistentes, mas sua seleção já é condicionada por erro. Não deve elevar ou reduzir sozinho o status global.
5. **Learning progress evidence — Lessons e Flashcards:** demonstra exposição, continuidade e necessidade de revisão. Contextualiza confiança e recomendações, mas não adiciona proficiência comprovada.

Os pesos futuros devem ser aplicados por fonte dentro de cada nível, e não por atividade individual. Repetir muitas vezes o mesmo Quiz ou a mesma Question não pode sobrepor evidência mais ampla nem aumentar indefinidamente a confiança.

## Mock Exam Signals

- Considerar performance somente de tentativas `completed` ou `expired` que possuam resultado final materializado.
- Usar a resposta por snapshot para agrupar acertos, erros e não respondidas por Domain, Topic e difficulty, sem depender da taxonomia curricular atual ter permanecido idêntica.
- Tratar `practice_score_percentage` como score de prática da plataforma, nunca como pontuação oficial.
- Separar `unanswered` de `incorrect`: não respondidas reduzem cobertura efetiva e podem indicar problema de execução/tempo; não devem ser automaticamente atribuídas a desconhecimento do Topic.
- Tentativas `abandoned` e `in_progress` informam atividade, mas não performance. Não entram em accuracy, tendência nem consistência.
- Usar `submitted_at` como timestamp de evidência; para expirada, usar o momento de finalização registrado pelo ciclo de expiração.
- Conservar `elapsed_seconds`, taxa de não respondidas e status como sinais auxiliares de execução, sem transformá-los em proficiência curricular.
- Limitar o efeito de retakes altamente repetidos e contar Questions distintas, tentativas e fontes separadamente.

## Topic Quiz Signals

- Usar somente tentativas `completed` e suas `quiz_answers`.
- Calcular acurácia por Topic a partir das respostas, acompanhada de total de Questions, Questions distintas, tentativas e última evidência.
- Preservar score por tentativa para consistência e tendência; o `last_score_percentage` atual não é suficiente sozinho.
- Dar crédito à rotação existente, registrando também sobreposição de Question entre tentativas. Repetições continuam válidas como recuperação, mas contam menos para cobertura nova.
- Topic Quiz confirma conhecimento direcionado. Não substitui o Mock para classificação global porque o aluno escolhe o Topic e recebe feedback a cada resposta.

## Lesson Quiz Signals

- Usar tentativas concluídas, respostas, acertos, erros e recência como evidência de apoio à Lesson e ao Topic pai.
- Agregar por Question distinta para impedir que cinco itens repetidos dominem o Topic.
- Não permitir que conclusão ou repetição de Lesson Quiz eleve sozinha um Topic a `Strong`.
- Usar erros persistentes para detalhar a recomendação futura de Lesson, não para rotular um Topic com amostra insuficiente.
- A agregação futura deve separar `quiz_type`: o `get_user_question_stats` atual mistura respostas de Lesson, Topic e Review Quiz, e portanto não pode ser consumido diretamente como evidência independente de Readiness.

## Flashcard Signals

- Interpretar `again` e `hard` recentes, cards vencidos e intervalos curtos como necessidade de recuperação ativa.
- Interpretar `good/easy`, intervalos crescentes e histórico de revisões como estabilidade de estudo, não como acerto objetivo.
- Usar cards novos/vencidos e `next_review_at` para ordenar recomendações futuras.
- Nunca converter `successful_review_count` diretamente em accuracy de Readiness: hoje “sucesso” deriva da avaliação do próprio aluno.
- Flashcards podem reforçar um Weak Topic já sustentado por avaliação, mas não criam nem resolvem esse rótulo sozinhos.

## Recency

Recomenda-se um modelo inicial de **buckets de tempo**, por ser compreensível, configurável e fácil de testar. Exponential decay não é necessário na primeira versão.

Política candidata para validação na 12.2:

- `fresh`: até 14 dias;
- `recent`: 15–30 dias;
- `aging`: 31–60 dias;
- `stale`: acima de 60 dias.

Os limites são parâmetros propostos, não fórmula aprovada. Recência deve reduzir o peso efetivo e a confiança da evidência, sem alterar o score histórico original. Usar `submitted_at`/finalização para Mock, `completed_at` para Quiz, `answered_at` para resposta, `reviewed_at` para Flashcard e `completed_at`/`last_accessed_at` para Lesson. Conclusão de Lesson permanece como cobertura histórica; seu envelhecimento apenas sinaliza revisão possível.

## Consistency

- Exigir pelo menos três tentativas finalizadas e comparáveis para classificar tendência global ou por Domain. Com menos, retornar `Insufficient Data`.
- Ordenar cronologicamente e comparar uma janela recente curta com a janela anterior; mediana ou média ponderada por quantidade de respostas é suficiente.
- Classificar `Improving`, `Stable` ou `Declining` somente quando a diferença superar uma faixa de tolerância definida e testada na 12.2. Oscilações pequenas ficam `Stable`.
- Medir consistência pela dispersão dos últimos 3–5 Mocks, junto da cobertura e de não respondidas. Um pico isolado não elimina variação anterior.
- Para Topic, exigir amostras mínimas em ambas as janelas. Não gerar trend quando poucos itens daquele Topic foram selecionados.
- Não usar regressão estatística complexa na primeira versão.

## Domain Readiness

Cada um dos 3 Domains recebe um resultado com `status`, `confidence`, `trend`, `reasons` e um resumo de evidências.

Ordem de influência proposta:

1. respostas de Mocks finalizados naquele Domain;
2. Topic Quizzes dos Topics filhos;
3. Lesson Quizzes como apoio e localização;
4. conclusão das Lessons e estado de Flashcards como contexto de cobertura/revisão.

Um Domain só pode ser `Strong` com evidência recente suficiente, cobertura de seus Topics e performance consistente. Concluir todas as Lessons não remove `Needs Review`; da mesma forma, um Domain com bom resultado em poucos itens deve permanecer `Insufficient Evidence` ou `Developing` com baixa confiança.

Contrato conceitual futuro:

```text
DomainReadiness
  domainId, title
  status, confidence, trend
  assessedQuestions, distinctQuestions, finalizedAttempts
  sourceBreakdown, coverage, lastEvidenceAt
  reasons[]
```

## Topic Readiness

Os 12 Topics reais são avaliados separadamente:

- Cloud Computing; Benefits of Cloud Services; Cloud Service Types.
- Core Architectural Components; Azure Compute Services; Azure Networking Services; Azure Storage Services; Azure Identity, Access and Security.
- Azure Cost Management; Governance and Compliance; Tools for Managing and Deploying Azure Resources; Azure Monitoring Tools.

Fontes: respostas de Mock do Topic, Topic Quiz, Lesson Quiz, recência, Questions distintas e quantidade de sessões. Lesson/Flashcard entram apenas como contexto e recomendação.

Política de suficiência candidata para testes: ao menos 8 respostas efetivas, distribuídas em 2 sessões, e diversidade mínima de Questions. Para `Strong`, exigir evidência de pelo menos uma fonte de avaliação ampla (Mock) ou repetição consistente em múltiplos Topic Quizzes, além de cobertura suficiente. Esses números devem ser validados contra os pools reais antes de congelar a versão 1.

## Weak Topic Detection

Usar dois estados internos para evitar rótulos prematuros:

- **Watch candidate:** desempenho baixo em uma fonte com amostra mínima, ou erro recorrente em Questions distintas.
- **Confirmed weak:** duas fontes concordam (por exemplo, Mock + Topic Quiz) ou Mocks recentes repetem o padrão em pelo menos duas tentativas, sempre com evidência suficiente.

Também considerar:

- recorrência deve distinguir a mesma Question repetida de erros em conceitos/Questions distintas;
- um erro isolado nunca confirma fraqueza;
- não respondidas em Mock indicam primeiro lacuna de execução/cobertura, não erro conceitual;
- duas sessões recentes satisfatórias podem resolver o candidato, sem apagar o histórico;
- Flashcards `again/hard` e Review Quiz ajudam a ordenar Lessons recomendadas, mas não confirmam fraqueza sozinhos.

## Global Classification

Categorias iniciais recomendadas:

- **Not Enough Evidence:** não há avaliação ampla ou a amostra/cobertura é insuficiente.
- **Needs Review:** há lacunas importantes e sustentadas por evidência suficiente.
- **Developing:** existe progresso mensurável, mas cobertura, consistência ou alguns Domains ainda não sustentam `Strong`.
- **Strong:** evidência recente, ampla e consistente, sem lacuna crítica confirmada.

Não incluir `Mock Ready` na primeira versão. O nome sugere uma conclusão mais forte do que os dados internos podem garantir. Se o produto quiser futuramente uma categoria superior, ela deve ser descrita como “forte evidência de prática na plataforma”, exigir múltiplos Mocks recentes e consistentes, cobertura dos 3 Domains/12 Topics e nenhum Domain fraco, sem alegar aprovação.

Uma eventual escala numérica pode existir internamente para ordenar estados, mas a UI deve priorizar categoria, confiança, evidência e motivos. O número não pode ser apresentado como probabilidade.

## Insufficient Evidence

`Insufficient Evidence` é um resultado válido, não um erro. Deve aparecer por Domain/Topic quando qualquer condição mínima falhar:

- poucas respostas efetivas;
- apenas uma sessão;
- pouca diversidade de Questions;
- evidência exclusivamente antiga;
- apenas Lessons/Flashcards, sem avaliação objetiva;
- Mock com muitas não respondidas e cobertura efetiva baixa.

Globalmente, sem Mock finalizado o estado inicial deve ser `Not Enough Evidence`, mesmo que haja Lessons concluídas. Um único Mock produz leitura provisória, não `Strong`. Todo resultado deve expor `assessedQuestions`, `distinctQuestions`, `attemptsBySource`, `lastEvidenceAt`, `coverage` e os requisitos ainda ausentes.

## Data Model

### Fonte de verdade

Manter como fonte os registros existentes:

- `user_lesson_progress`;
- `flashcard_reviews` e `user_flashcard_progress`;
- `quiz_attempts`, `quiz_attempt_questions` e `quiz_answers`;
- `mock_exam_attempts`, `mock_exam_attempt_questions` e `mock_exam_answers`;
- taxonomia `domains`, `topics`, `lessons` e `questions`.

Nenhuma tabela nova é necessária para a primeira entrega calculada on demand. Também não é necessário alterar UUIDs nem reescrever histórico.

### Read model recomendado para 12.2

Adicionar futuramente uma RPC owner-only que retorne agregados neutros, não a classificação final e nunca gabaritos/textos de Questions:

```text
ReadinessEvidenceBundle
  certificationId, calculatedAt, evidenceAsOf
  lessonCoverage
  flashcardReviewSummary
  quizEvidence[] by source/domain/topic/attempt/question
  mockEvidence[] by domain/topic/difficulty/attempt
  sourceCounts and lastEvidenceAt
```

O contrato precisa preservar identificadores de tentativa/Question suficientes para deduplicação e diversidade, mas a resposta ao browser pode ser resumida. A função deve fixar `auth.uid()` internamente e aceitar somente `certification_id`.

### Snapshot futuro opcional

Somente quando houver requisito de histórico de Readiness, notificações ou análise longitudinal independente do acesso, considerar `readiness_snapshots` append-only com `user_id`, `certification_id`, `calculation_version`, componentes, evidência, razões e `calculated_at`. Snapshot seria cache/auditoria, nunca fonte de verdade, e exigiria política explícita de retenção e RLS.

## Calculation Strategy

Recomendação: **calculated on demand na versão inicial**, com arquitetura híbrida de execução:

1. PostgreSQL agrega com segurança o histórico bruto em um `ReadinessEvidenceBundle` neutro.
2. Um engine TypeScript puro, determinístico e versionado (`az900-readiness-v1`) aplica suficiência, recência, qualidade, consistência, trend e classificações.
3. A camada de serviço valida o payload, e a UI apenas apresenta resultado e motivos.

Isso evita duplicar dados, concentra autorização no banco e mantém a política de classificação testável sem enterrá-la em SQL. O cálculo deve ser reproduzível para o mesmo `evidenceAsOf`, configuração e versão. Cache de consulta no cliente é aceitável; persistência não é necessária agora.

O engine deve operar na seguinte ordem:

1. filtrar estados elegíveis e separar não respondidas;
2. agregar por fonte, tentativa, Question distinta, Topic e Domain;
3. calcular cobertura e suficiência;
4. aplicar qualidade e bucket de recência;
5. avaliar performance, consistência e trend;
6. detectar Weak Topics;
7. classificar Topics, Domains e global;
8. emitir razões e requisitos faltantes.

Não usar `average(all quiz scores)` nem `latest mock score`. Repetição deve ter teto por fonte; evidência não independente precisa ser deduplicada ou ter contribuição reduzida.

## Security

- Toda evidência de estudo é privada e deve permanecer sob RLS por `auth.uid()`.
- RPC futura deve ser `SECURITY DEFINER` somente se necessária para agregação, com `search_path = ''`, autenticação obrigatória, validação da certificação, grants apenas a `authenticated` e isolamento por usuário testado.
- Não aceitar `user_id` informado pelo cliente.
- Não devolver `correct_option_key`, `is_correct` de opções curriculares, textos de gabarito ou snapshots completos desnecessários.
- O engine no cliente não pode consultar dados de outro usuário nem tabelas protegidas além dos contratos existentes.
- Snapshot futuro deve ter select owner-only e nenhuma escrita direta pelo usuário; criação deve ocorrer por função controlada.
- Testes devem cobrir acesso anônimo, usuário estrangeiro, tentativa estrangeira e ausência de vazamento de respostas.

## UX Recommendations

- Mostrar categoria e confiança juntas: por exemplo, `Developing · evidência moderada`.
- Explicar cada resultado em linguagem factual: “2 Mocks recentes, 19 respostas neste Domain, Topic Quiz em 68%”.
- Separar “desempenho de conteúdo” de “execução do Mock” quando houver muitas não respondidas.
- Mostrar `Insufficient Evidence` com ação concreta: fazer um Mock ou Topic Quiz, em vez de exibir zero.
- Mostrar trend apenas com dados mínimos; caso contrário, “dados insuficientes para tendência”.
- Em Weak Topics, ligar Topic às Lessons e práticas existentes, sem criar conteúdo ou usar IA.
- Exibir quando a evidência está antiga e a data da última avaliação.
- Evitar cores/vermelho como única comunicação e não apresentar o índice interno como chance de aprovação.

## Risks

| Risco | Mitigação arquitetural |
| --- | --- |
| Um Mock excepcional domina o resultado | exigir múltiplas tentativas, consistência, cobertura e confiança mínima |
| Retakes repetem Questions | contar Questions distintas, sobreposição e teto por fonte |
| Topic Quiz é auto-selecionado | limitar seu efeito global e combinar com Mock |
| Review Quiz é amostra enviesada | usar apenas como remediação/recorrência, não como performance ampla |
| Review Quiz realimenta as estatísticas de erro atuais | separar `quiz_type` na agregação e impedir que a própria remediação seja contada como uma nova fonte independente |
| Flashcard parece acerto objetivo | nomear como autoavaliação e nunca calcular accuracy |
| Não respondidas viram erro conceitual | separar accuracy respondida, cobertura e execução/tempo |
| Conteúdo/taxonomia muda depois da tentativa | usar snapshots do Mock e IDs históricos; versionar cálculo |
| Recência apaga progresso antigo | reduzir peso/confiança sem reescrever o histórico |
| Poucos itens geram score falso | estado explícito `Insufficient Evidence` e mínimos por sessão/diversidade |
| Um número é interpretado como chance de aprovação | priorizar categorias, motivos e disclaimer; não usar escala oficial |
| RPC agregadora vaza histórico/gabarito | owner-only, retorno mínimo, Zod no boundary e testes adversariais de RLS |
| Snapshot duplica ou diverge da verdade | começar on demand; snapshot futuro apenas append-only, versionado e derivado |

## Implementation Roadmap

### 12.2 — Readiness Calculation Engine

- Definir contratos versionados de evidence/result/config.
- Criar agregação owner-only dos históricos reais, sem expor gabaritos.
- Implementar engine puro para suficiência, Domain, Topic, recência, consistência e trend.
- Calibrar mínimos e buckets contra os pools reais dos 12 Topics.
- Testes determinísticos: nenhum dado, apenas Lessons, um Mock, Mocks consistentes, pico isolado, queda, expiração parcial, retakes repetidos e evidência antiga.

### 12.3 — Weak Topics + Study Recommendations

- Implementar candidato/confirmado/recuperado com razões rastreáveis.
- Mapear Topic → Lessons publicadas e escolher revisão a partir de erros, Lesson Quiz e Flashcards vencidos.
- Recomendações determinísticas e sem IA.
- Testar erro isolado, fontes discordantes, recorrência e recuperação.

### 12.4 — Readiness UI

- Status global e confiança, cards dos 3 Domains, lista dos 12 Topics e tendências válidas.
- Evidência por fonte, Mocks recentes, não respondidas e atualização/recência.
- Estados loading, erro, sem evidência, evidência antiga, desktop/mobile e acessibilidade.

### 12.5 — Readiness Validation + Closure

- Validar perfis: iniciante, estudo sem avaliação, um Mock alto, Mocks consistentes, em melhora, em queda, lacuna localizada e Mock expirado.
- Validar RLS, isolamento entre usuários, ausência de gabaritos, performance e regressão completa.
- Confirmar versionamento, documentação, limites de interpretação e fechamento do sistema.

## Implementation Status — 12.2

Status do engine: implementado para validação final da Etapa 12.2.

### Contratos e separação

- `src/types/readiness.ts` separa `ReadinessEvidenceBundle` de `TopicReadiness`, `DomainReadiness` e `GlobalReadiness`.
- `src/features/readiness/readinessConfig.ts` centraliza todos os pesos, mínimos, buckets e thresholds sob a versão `az900-readiness-v1`.
- `src/features/readiness/readinessMetrics.ts` contém recência, performance ponderada, consistency, trend e níveis de evidência.
- `src/features/readiness/readinessEngine.ts` interpreta o bundle de modo puro, determinístico e independente de React.
- `src/services/readinessService.ts` valida o boundary, monta a taxonomia e chama o engine; nenhuma UI consome o resultado nesta etapa.

### Pesos implementados

| Fonte | Peso | Uso |
| --- | ---: | --- |
| Mock Exam | 1.00 | principal evidência de performance |
| Topic Quiz | 0.65 | confirmação dirigida por Topic |
| Lesson Quiz | 0.35 | apoio/localização |
| Review Quiz | 0.00 | recorrência e remediação, fora do score |
| Lesson/Flashcard | 0.00 | contexto de aprendizagem, fora do score |

Repetições não aumentam o score indefinidamente: performance é consolidada por `source + questionId`, preservando recuperação com recência, enquanto suficiência também exige Questions distintas e múltiplas sessões.

Os pesos globais fixos usam os pontos médios dos intervalos curriculares e somam 1: Domain 1 = 0.275, Domain 2 = 0.375, Domain 3 = 0.350.

### Algoritmos implementados

- Recência: buckets `fresh` (0–14 dias), `recent` (15–30), `aging` (31–60) e `stale` (>60), com fatores 1.0/0.8/0.6/0.4.
- Consistency: últimas cinco tentativas comparáveis da fonte mais forte disponível; mínimo de três; range até 8 = high, até 18 = moderate, acima = low.
- Trend: até cinco tentativas comparáveis, separadas em duas janelas cronológicas não sobrepostas; diferença de pelo menos 6 pontos determina improving/declining.
- Topic: exige performance, sessões, Questions distintas, fonte, recência e consistency. Ausência/pouca evidência retorna `insufficient_evidence`, nunca zero.
- Domain: combina evidência direta, cobertura de Topics e Weak Topics confirmados. Um Topic crítico bloqueia `strong`.
- Global: média interna dos Domains pelos pesos fixos, acrescida de gates de Mock, cobertura, Domain fraco, recência, consistency e não respondidas.

### Suficiência e safeguards

- Topic suficiente: 8 respostas, 2 sessões e 5 Questions distintas; forte: 16/3/8.
- Domain suficiente: 20 respostas, 2 sessões e 75% dos Topics classificáveis; forte: 40/3/100%.
- Global forte: ao menos 120 respostas, 3 Mocks, todos os Domains classificáveis e evidência não stale.
- `Strong` global ainda exige três Mocks, todos os Domains `strong`, score interno >= 80, consistency disponível/não baixa e no máximo 10% de itens de Mock não respondidos.
- Um Mock alto, Lessons concluídas, prática antiga, ausência de Mock ou um Domain fraco não produzem `Strong`.

Os números são configuração versionada da plataforma, não escala oficial nem probabilidade de aprovação.

### Query strategy e segurança

A migration `20260830076000_add_readiness_evidence_contract.sql` adiciona somente a RPC on-demand `get_readiness_evidence(certification_id)`. Ela reúne, em uma passagem contratual, respostas finalizadas de Quiz/Mock e estado de Lessons/Flashcards. Não cria tabela nem snapshot e não devolve gabaritos ou textos de Questions.

A taxonomia é carregada em batches pelo serviço existente. A identidade não é argumento: a RPC usa `auth.uid()`, exige autenticação e possui grant apenas para `authenticated`. A migration de validação aplicada em produção verifica assinatura, grants e os predicados de ownership de todas as fontes sem criar dados. O teste SQL transacional `validate_readiness_evidence_isolation.sql` também alterna usuários A/B para execução em um Supabase local.

### Testes implementados

As fixtures determinísticas cobrem New Student, Lesson Completion Only, Weak, Improving, Consistent Strong, One Lucky Mock e Strong Overall with Weak Domain. Casos adicionais cobrem ausência/uma evidência no Topic, fontes conflitantes, recência, trend, erros recorrentes, cobertura de Domain, ausência de Mock, evidência stale e não respondidas.

## Implementation Status — 12.3

Status do motor de recomendações: implementado como consumidor separado do resultado da 12.2. O `Study Recommendation Engine` não recalcula nem altera classificações, thresholds ou pesos do `Readiness Engine`; ele recebe `GlobalReadiness`, o mesmo bundle de evidências e um catálogo curricular publicado para converter sinais já calculados em ações válidas.

### Contratos e fluxo

```text
ReadinessEvidenceBundle
        +
GlobalReadiness (12.2)
        +
Published curriculum catalog
        ↓
Study Recommendation Engine
        ↓
ReadinessRecommendationViewModel
```

- `src/types/studyRecommendation.ts` define o DTO enxuto para Topics, Domains, Lessons, ações e explicação estruturada.
- `src/features/readiness/studyRecommendationConfig.ts` centraliza prioridades, modificadores, limites, disponibilidade de ações e ranking de Lessons sob `az900-study-recommendations-v1`.
- `src/features/readiness/studyRecommendationEngine.ts` é puro, determinístico, sem React, persistência, IA ou chamadas externas.
- `src/services/studyRecommendationService.ts` reutiliza a agregação owner-only da 12.2 e carrega apenas metadata curricular publicada em batches.
- O trace numérico interno é retornado separadamente do view model e não precisa ser exposto pela futura UI.

### Weak Topics e prioridades

O engine preserva a diferença estabelecida na 12.2 entre `confirmed`, `watch`, `needs_review`, `developing` e `insufficient_evidence`. Um Topic `strong` não entra na lista. `Insufficient Evidence` gera ação de avaliação e nunca recebe reason code de fraqueza por ausência de dados.

As prioridades externas são `critical`, `high`, `medium` e `low`. `critical` exige simultaneamente Weak Topic confirmado, evidência forte e evidência não stale. Mock continua sendo a evidência mais relevante: baixa performance e erros recorrentes em Mocks recebem modificadores maiores do que sinais equivalentes de Topic Quiz. Trend, consistency, recência e estado do Domain refinam a ordenação sem substituir a classificação da 12.2.

Reason codes possíveis:

- `confirmed_weak_topic`, `low_mock_performance`, `repeated_mock_errors`;
- `low_topic_quiz_performance`, `repeated_topic_quiz_errors`;
- `declining_trend`, `inconsistent_performance`, `insufficient_evidence`;
- `stale_evidence`, `domain_weakness`, `developing_performance`, `improving_performance`.

O peso curricular do Domain é somente um modificador pequeno de desempate. Ele não consegue transformar evidência insuficiente em fraqueza confirmada nem superar diferenças materiais de performance, recorrência, recência ou trend. Evidência stale limita a prioridade abaixo de `high`; a ação resultante favorece reavaliação em vez de declarar uma fraqueza crítica atual.

### Ranking de Lessons e ações

Somente Lessons publicadas reais do Topic podem ser recomendadas. O ranking usa erros vinculados por `lessonId`, com maior peso para Mock, seguido de Topic Quiz e Lesson Quiz; recência, repetição da mesma Question e Flashcards vencidos refinam a ordem. Acertos reduzem o score interno. Uma Lesson sem erro não é incluída apenas por pertencer ao Topic, e o score é usado somente para ordenação.

O resultado limita a carga cognitiva a três Topics globais, até dois Topics de foco no resumo de cada Domain e até três Lessons por Topic. As ações existentes são ordenadas como estudo antes de nova avaliação:

1. `review_lesson`, se uma Lesson específica possui evidência de erro;
2. `review_flashcards`, somente se a Lesson selecionada possui card publicado;
3. `retake_topic_quiz` ou `assess_topic`, somente com pool publicado mínimo de cinco Questions;
4. `take_another_mock`, somente para evidência insuficiente sem Mock anterior e com ao menos 40 Questions mock-eligible publicadas.

Todas as rotas usam os helpers reais da aplicação e IDs/slugs do catálogo. Nenhum workflow automático, CTA fictício ou loop obrigatório foi criado.

### Explicabilidade, eficiência e isolamento

Cada Topic expõe reason codes e uma explicação factual estruturada: performance em Mock, Topic Quiz e Lesson Quiz; erros recentes; Questions com erro recorrente; data da evidência mais recente; evidence level e trend. Pesos e scores internos permanecem apenas no debug trace.

O serviço faz uma carga da taxonomia/evidência da 12.2 e duas consultas curriculares paralelas: Questions publicadas da certificação e Flashcards publicados para todos os IDs de Lesson. Não existe N+1, tabela, snapshot, cache global ou persistência de recomendações. Evidência privada continua vindo exclusivamente da RPC owner-only baseada em `auth.uid()`; as consultas adicionais leem apenas catálogo curricular publicado e não aceitam `user_id`.

Os testes determinísticos cobrem Topics fortes, fracos e sem evidência; recorrência em Mock; trend declining/improving; Domain fraco; prevenção de Lesson incorreta; disponibilidade de Flashcards e Topic Quiz; rotas reais; limites; desempate por Domain; evidência antiga; execução A/B sem cache; ordem de ações; e conflito entre Mock baixo e Topic Quiz alto. A validação detalhada está em `docs/az900-study-recommendation-validation.md`.

## Implementation Status — 12.4

Status da interface: implementada na rota protegida `/certifications/:certificationCode/readiness`, com entrada `Readiness` na navegação principal desktop/mobile. A página segue os padrões visuais existentes de cards, estados de dados, grid responsivo, links React Router e progress bars acessíveis, sem redesenhar o Dashboard ou criar navegação paralela.

### DTO, serviço e hook

`readinessDashboardService.ts` executa a orquestração fora do React: carrega o bundle owner-only e até dez resumos recentes de Mock em paralelo, calcula a 12.2 uma única vez, passa exatamente esse resultado ao motor da 12.3 e retorna somente `GlobalReadiness`, `ReadinessRecommendationViewModel` e até cinco resumos finalizados de Mock. Assessment answers e learning events brutos não chegam à página.

`useCertificationReadiness` controla loading, erro amigável e retry. Sua chave inclui `user.id` e `certificationId`; troca de usuário/certificação descarta imediatamente o estado anterior, respostas atrasadas são ignoradas pelo cleanup e logout limpa o DTO. Não existe cache global compartilhado.

### Overall status e Evidence

- A UI mostra somente as classificações aprovadas: `Not Enough Evidence`, `Needs Review`, `Developing` e `Strong`.
- Não exibe Readiness Score numérico, chance de aprovação, `Passed` ou `Failed`.
- Evidence level, trend, contagens reais de Mock/Topic Quiz e última avaliação vêm diretamente do trace.
- Learning Progress é exibido separadamente de Assessment Readiness; 100% de Lessons continua compatível com `Not Enough Evidence`.
- Evidência stale produz aviso explícito de reavaliação sem recalcular recência em React.
- “Como o Readiness é calculado?” explica a hierarquia das fontes sem revelar pesos internos.

### Domains e Priority Topics

Os três Domain cards mostram classificação textual, Evidence, trend, `topicCoverage`, Topics que pedem atenção e última evidência. Cor nunca é o único sinal. A UI não recalcula score/classificação e não reordena recomendações.

Priority Topics respeita a lista já limitada e ordenada pela 12.3. Cada card apresenta prioridade, evidence level, trend, reason codes traduzidos por um mapping determinístico central, métricas objetivas e até três Lessons reais. Reason codes internos não aparecem como texto cru.

### Actions e Recent Performance

As ações são renderizadas somente quando existem no DTO: Lesson, Flashcards, Topic Quiz e Mock usam as rotas já validadas pela 12.3. O resumo superior mostra no máximo três ações, preservando a ordem de Topic/action da engine. Nenhuma lógica de Start Mock ou player foi duplicada.

Recent Performance contém no máximo cinco Mocks `completed`/`expired`, com data, status e Practice Score. Trend é textual (`Improving`, `Stable`, `Declining`, `Insufficient Data`) e não há gráfico, prediction ou benchmark oficial.

### Estados, responsividade e acessibilidade

- New Student recebe empty state informativo e CTAs existentes, sem `0% readiness`, `weak` ou alerta crítico.
- Loading usa skeleton com altura reservada; erro oculta mensagem técnica e oferece retry.
- Desktop usa grid de três Domains; mobile empilha cards e CTAs, sem tabela ou overflow horizontal.
- Headings seguem níveis 1–4, regions usam nomes acessíveis, progress bars têm ARIA completo, links/botões mantêm alvo mínimo de 44 px e ícones decorativos usam `aria-hidden`.
- Status, Evidence, trend e prioridade sempre possuem texto; nenhuma informação depende somente de cor.

A validação real em 1440 × 900 e 390 × 844 confirmou grid/stack, ausência de overflow e zero erros de console no preview isolado dos componentes. O preview temporário foi removido após o teste. A validação completa está em `docs/az900-readiness-ui-validation.md`.

### Compatibilidade do perfil Strong + Weak Domain

A UI consegue exibir um Domain `needs_review` sempre que esse estado estiver presente no DTO. Entretanto, o safeguard aprovado na 12.2 impede `Global Strong` quando qualquer Domain está `needs_review`; o perfil G real permanece globalmente `Needs Review`. A 12.4 preserva essa decisão e não fabrica uma combinação que a engine atual proíbe.

---

**Checkpoint da Etapa 12.1:** arquitetura recomendada para a primeira versão é cálculo on demand sobre histórico bruto, com agregação segura no banco e engine TypeScript puro/versionado. Nenhuma migration, fórmula, UI, alteração de Mock ou IA foi implementada.

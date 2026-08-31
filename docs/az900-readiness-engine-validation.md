# Readiness Engine Validation

Validação da Etapa 12.2 do `AZ-900 Readiness Calculation Engine`. O resultado é uma classificação interna de prática da Certification Academy. `readinessScore` significa desempenho normalizado dentro deste modelo; não é probabilidade, pontuação Microsoft nem conversão para 700/1000.

## Configuration

Configuração única: `AZ900_READINESS_CONFIG`, versão `az900-readiness-v1`.

| Grupo | Regra |
| --- | --- |
| Source weights | Mock 1.00; Topic Quiz 0.65; Lesson Quiz 0.35; Review Quiz 0 |
| Domain weights | D1 0.275; D2 0.375; D3 0.350 |
| Classification | Needs Review abaixo de 60; Strong a partir de 80, sujeito aos gates |
| Recency | 0–14d 1.0; 15–30d 0.8; 31–60d 0.6; >60d 0.4 |
| Topic sufficient/strong | 8/16 respostas; 2/3 sessões; 5/8 Questions distintas |
| Domain sufficient/strong | 20/40 respostas; 2/3 sessões; 75%/100% de cobertura |
| Global strong | 120 respostas e ao menos 3 Mocks, além dos safeguards |
| Consistency | mínimo 3; range <=8 high, <=18 moderate, >18 low |
| Trend | mínimo 3; mudança >=6 improving, <=-6 declining |
| Weak threshold | abaixo de 60; crítico abaixo de 50 |
| Unanswered strong ceiling | no máximo 10% dos itens de Mock |

Todos os valores estão centralizados e versionados. Nenhum threshold é repetido no engine.

## Evidence Rules

- Somente Quiz `completed` e Mock `completed/expired` entram como avaliação.
- Mock, Topic Quiz e Lesson Quiz influenciam performance nessa ordem.
- Review Quiz possui peso zero e serve apenas como histórico de remediação/recorrência.
- Lessons e Flashcards alimentam `learningProgress`, mas não elevam `readinessScore`.
- Flashcard rating é autoavaliação; não existe correct/incorrect objetivo.
- Não respondidas ficam fora da accuracy conceitual e entram como cobertura/execução.
- Performance repetida é consolidada por fonte e Question; recência continua distinguindo recuperação recente de resultado antigo.
- Suficiência exige simultaneamente volume, sessões e diversidade.

## Topic Readiness

Cada Topic recebe `readinessScore | null`, classification, evidence level, trend, consistency e trace. O score pondera Questions consolidadas por fonte e recência. `Strong` exige evidência forte, score >=80, ao menos três Mocks ou três Topic Quizzes comparáveis, consistency calculável/não baixa e evidência não stale.

Se Mock repetidamente baixo conflitar com Topic Quiz alto, o Topic permanece `needs_review`. O inverso também ocorre quando Topic Quiz repete erros apesar de Mock alto. Isso preserva a hierarquia sem ignorar evidência dirigida consistente.

## Domain Readiness

O Domain usa suas respostas diretas e a cobertura dos Topics filhos. Topics somente `sufficient`/`strong` contam como cobertos. `Strong` requer 100% de cobertura, evidence forte, score >=80, consistency calculável/não baixa, recência e ausência de Weak Topic confirmado.

Um Topic confirmado ou crítico impede `Strong`, mesmo quando a performance média dos demais Topics é alta.

## Global Readiness

O score interno global combina scores disponíveis dos três Domains pelos pesos 0.275/0.375/0.350. A classificação não é a média isolada:

- `not_enough_evidence`: nenhuma avaliação ou menos de oito respostas efetivas;
- `needs_review`: Domain fraco ou score agregado abaixo de 60;
- `developing`: existe prática, mas algum gate de Strong ainda falta;
- `strong`: evidence forte, score >=80, três Mocks, todos os Domains Strong, consistency e recência válidas e <=10% não respondidas.

Não existe `Mock Ready` nesta versão.

## Recency

Buckets de tempo aplicam fatores explícitos. O score bruto continua no trace; o score ponderado privilegia evidência recente. `evidenceAsOf` é parte obrigatória do bundle, tornando testes reproduzíveis e permitindo que a mesma evidência envelheça de maneira intencional.

## Consistency

O engine escolhe a fonte mais forte que tenha ao menos três tentativas comparáveis: Mock, depois Topic Quiz, depois Lesson Quiz. Usa até as cinco mais recentes e mede o range. Assim, 84/85/86 é estável; 52/98/65 é inconsistente, mesmo com média semelhante.

## Trend

As últimas cinco tentativas comparáveis são divididas em janelas anterior e recente, sem sobreposição. A média das janelas define `improving`, `stable` ou `declining`. Com menos de três tentativas, retorna `insufficient_data`.

## Insufficient Evidence

Ausência de evidência retorna score `null`, não zero. Topic e Domain usam `insufficient_evidence`; global usa `not_enough_evidence`. Uma sessão, poucas Questions distintas, pouca cobertura ou exclusivamente progresso de aprendizagem não autorizam classificação forte.

## Test Profiles

| Perfil | Fixture | Resultado esperado/validado |
| --- | --- | --- |
| A — New Student | sem atividade | Not Enough Evidence; Topics null/insufficient |
| B — Lesson Completion Only | 100% Lessons, sem avaliação | Not Enough Evidence; nunca Strong |
| C — Weak | Mocks 45/50/55 + Topic Quiz baixo | Needs Review; 12 Weak Topics confirmados |
| D — Improving | Mocks 55/65/75/82 | Developing; trend Improving |
| E — Consistent Strong | Mocks 84/86/85/88 + ampla prática dirigida | Strong; 3 Domains Strong |
| F — One Lucky Mock | Mocks 55/58/92 | não Strong; consistency Low |
| G — Weak Domain | D1/D2 fortes, D3 repetidamente baixo | Needs Review; weak Domain bloqueia exagero |

As fixtures usam amostras uniformes por Topic para isolar a semântica do engine. A RPC real consome a distribuição de 40 Questions e os snapshots reais do Mock.

## Edge Cases

- Topic nunca avaliado: `insufficient_evidence`, score null.
- Uma única sessão: evidence limited.
- Mock baixo versus Topic Quiz alto: Needs Review por `low_mock_performance`.
- Mock alto versus Topic Quiz baixo: Needs Review por `repeated_topic_quiz_errors`.
- Evidência antiga e recente: recência aumenta a contribuição recente.
- Trend improving/stable/declining e consistency high/moderate/low.
- Um único Mock de 95%: nunca Strong.
- Topic Quizzes altos sem Mock: no máximo Developing global.
- Evidência stale: nunca Strong.
- Mais de 10% de Mock unanswered: bloqueia Strong sem transformar automaticamente o Topic em erro.
- Domain com pouca cobertura: `insufficient_evidence`.
- Mesmo bundle + mesmo `evidenceAsOf`: resultado idêntico.

## Known Limitations

- Thresholds são política v1 e precisam de calibração futura com dados agregados e anônimos; não são psicometria oficial.
- Dificuldade é editorial, portanto aparece no evidence contract, mas ainda não altera o score.
- O engine não mede tempo por Question, confiança, hints nem leitura real de Lesson porque esses sinais não existem.
- Question-level objective mapping termina em Topic/Lesson; não há vínculo atômico com cada objetivo oficial.
- Readiness não é persistido; não existe série histórica própria até haver requisito real.
- Recommendations, Lesson ranking e UI pertencem às Etapas 12.3/12.4.

## Decision

O modelo permanece on demand, determinístico e explicável: PostgreSQL coleta evidência owner-only sem gabaritos; TypeScript interpreta a evidência com configuração versionada. Nenhuma tabela ou snapshot foi criado. A regressão técnica, o dry-run e a validação remota de assinatura/grants/ownership foram executados. O teste A/B transacional permanece disponível para ambientes locais; nesta execução ele não rodou porque Docker/Podman não está instalado.

**AZ-900 Readiness Calculation Engine: READY.** O resultado autoriza a Etapa 12.3 apenas para Weak Topics e recomendações determinísticas; nenhuma recomendação foi implementada nesta etapa.

# Study Recommendation Validation

Validação da Etapa 12.3 do AZ-900. O motor é determinístico, calculado on demand e interpreta o resultado da 12.2 sem alterar o Readiness Calculation Engine. O resultado não representa probabilidade de aprovação nem percentual de fraqueza.

## Priority Rules

| Priority | Regra de produto |
| --- | --- |
| `critical` | Weak Topic confirmado, evidência forte, baixa performance sustentada e evidência atual. |
| `high` | Weak/needs review com evidência suficiente ou sinais relevantes concordantes. |
| `medium` | Topic developing, inconsistente ou candidato que ainda requer confirmação. |
| `low` | Reforço, evidência insuficiente ou reavaliação sem base para alegar fraqueza. |

A pontuação interna serve apenas para ordenar. Base state, reason modifiers e thresholds estão centralizados em `studyRecommendationConfig.ts`. Mock possui modificadores maiores do que Topic/Lesson Quiz. Domain weight aplica somente um pequeno desempate. Evidência stale limita a prioridade abaixo de `high`.

## Reason Codes

| Code | Significado objetivo |
| --- | --- |
| `confirmed_weak_topic` | A regra de confirmação da 12.2 foi satisfeita. |
| `low_mock_performance` | Mocks elegíveis sustentam baixa performance no Topic. |
| `repeated_mock_errors` | A mesma Question do Topic foi errada em Mocks distintos. |
| `low_topic_quiz_performance` | Múltiplos Topic Quizzes sustentam baixa performance. |
| `repeated_topic_quiz_errors` | Erros de Topic Quiz se repetiram entre tentativas. |
| `declining_trend` | O trend válido da 12.2 está declining. |
| `inconsistent_performance` | A consistency válida da 12.2 está low. |
| `insufficient_evidence` | O Topic não atingiu os mínimos de evidência. |
| `stale_evidence` | A evidência mais recente está no bucket stale. |
| `domain_weakness` | O Domain pai está `needs_review`. |
| `developing_performance` | O Topic está `developing`. |
| `improving_performance` | O trend válido está improving e reduz prioridade. |

Reasons de Lesson são separados: `mock_errors`, `topic_quiz_errors`, `lesson_quiz_errors`, `recurring_question_errors`, `recent_incorrect_answers` e `due_flashcards`.

## Weak Topic Rules

- O estado de Weak Topic vem do output da 12.2; a 12.3 não reclassifica Readiness.
- `confirmed` possui base maior do que `watch`; erro isolado não confirma fraqueza.
- Baixa performance recorrente em Mock continua relevante mesmo quando Topic Quiz está alto.
- Topics `strong` não são recomendados.
- Trend, consistency, recência e recorrência refinam prioridade e explicação.
- O resumo de Domain contém no máximo dois Topics já selecionados entre as três prioridades globais.

## Insufficient Evidence

Pouca evidência é tratada como necessidade de avaliação, não como baixa proficiência. O Topic recebe `insufficient_evidence`, prioridade baixa e, quando existe pool funcional, ação `assess_topic`. Sem Mock anterior e com banco mock-eligible suficiente, `take_another_mock` pode vir depois da avaliação dirigida. Não são emitidos `confirmed_weak_topic` nem textos livres alegando fraqueza.

## Lesson Ranking

O ranking considera apenas Lessons publicadas reais e com pelo menos um erro vinculado. A ordem interna aplica:

1. erro em Mock;
2. erro em Topic Quiz;
3. erro em Lesson Quiz;
4. recência do erro;
5. repetição da mesma Question entre tentativas;
6. Flashcard vencido como reforço secundário;
7. acertos como redução limitada do score.

Empates usam `displayOrder` e ID, garantindo estabilidade. Lessons sem erro não superam Lessons com erros recorrentes só por pertencerem ao Topic. O limite é três Lessons por Topic; o score não entra no view model.

## Actions

| Action | Gate de disponibilidade |
| --- | --- |
| `review_lesson` | Existe Lesson publicada selecionada por evidência de erro. |
| `review_flashcards` | A Lesson recomendada possui Flashcard publicado. |
| `retake_topic_quiz` | Topic classificável e ao menos 5 Questions publicadas. |
| `assess_topic` | Topic com evidência insuficiente e ao menos 5 Questions publicadas. |
| `take_another_mock` | Sem Mock anterior e ao menos 40 Questions mock-eligible publicadas. |

A ordem evita o loop “Topic fraco → novo Mock” sem estudo: Lesson e Flashcards vêm antes do Topic Quiz; Mock, quando válido, vem por último. Rotas são montadas pelos helpers existentes com certification code normalizado, Topic ID e Lesson slug reais.

## Test Profiles

| Perfil/caso | Resultado validado |
| --- | --- |
| A — Strong Topic / Consistent Strong | Nenhuma recomendação desnecessária. |
| B — Weak Student | Top 3 críticos, reasons de confirmação e Lessons ligadas a erros. |
| C — New Student | Assessment sem rótulo de fraqueza. |
| D — Repeated Mock Errors | Recorrência aumenta a prioridade. |
| E — Declining | Trend aumenta prioridade. |
| F — Improving | Trend reduz prioridade sem apagar necessidade válida. |
| G — Wrong Lesson avoidance | Lesson apenas acertada não supera Lesson com erros. |
| H — Domain weighting tie-break | Diferença pequena e incapaz de dominar evidência. |
| I — Max recommendations | Máximo de 3 Topics e 3 Lessons por Topic. |
| J — Deterministic | Mesmo input/config produz output idêntico. |
| Strong Overall + Weak Domain | Recomendações concentram-se no Domain fraco. |
| Mock baixo + Topic Quiz alto | O Topic Quiz não esconde fraqueza recorrente em Mock. |
| User A / User B | Execuções não compartilham cache nem evidência. |

## Edge Cases

- Evidência stale não pode produzir `critical` e orienta reavaliação.
- Topic sem pool mínimo não recebe CTA de Topic Quiz.
- Lesson sem Flashcards não recebe CTA de Flashcards.
- Lesson removida ou não publicada não existe no catálogo e não pode ser retornada.
- Catálogo sem Lessons não dispara consulta de Flashcards.
- Questions com `topic_id` nulo são descartadas do catálogo de recomendações.
- Empates são resolvidos deterministicamente por título/ID para Topics e display order/ID para Lessons.
- Review Quiz e Flashcards ajudam na localização/remediação, mas não substituem a evidência objetiva da 12.2.
- O view model não contém histórico bruto, score interno ou pesos.

## Known Limitations

- A granularidade depende do `lesson_id` histórico da Question; erros sem Lesson podem priorizar o Topic, mas não uma Lesson específica.
- O engine detecta recorrência por Question ID; não faz análise semântica de conceitos equivalentes.
- O mínimo de 5 Questions para Topic Quiz e 40 mock-eligible para Mock reflete os fluxos atuais e deve acompanhar futuras mudanças de engine.
- Não existe histórico/snapshot de recomendações, personalização por calendário, IA, notificação ou workflow automático.
- Esta etapa prepara contratos para a UI, mas não implementa Dashboard, charts ou visual score.

## Decision

Os contratos, gates, limites e testes satisfazem a Etapa 12.3: Weak Topics são consumidos do Readiness real, insuficiência é separada de fraqueza, Lessons/ações apontam apenas para conteúdo publicado disponível, Mock mantém maior influência, e o resultado é explicável, determinístico, batched e isolado por usuário. Após regressão técnica completa e dry-run do banco sem migration nova, o sistema pode ser declarado `AZ-900 Study Recommendation Engine: READY` e encaminhado para a futura UI da 12.4.

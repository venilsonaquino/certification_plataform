# AZ-900 Readiness Final Validation

Validação de encerramento da Etapa 12.5, executada em 30 de agosto de 2026. O sistema avaliado é interno à Certification Academy: ele descreve evidência de prática e não estima probabilidade de aprovação, pontuação oficial ou garantia de resultado no exame AZ-900.

## Architecture

A implementação está alinhada às decisões das Etapas 12.1–12.4:

- PostgreSQL entrega um bundle neutro e owner-only por `get_readiness_evidence(certification_id)`;
- o engine TypeScript puro `az900-readiness-v1` calcula Topics, Domains, Global, recência, consistência e tendência;
- o recommendation engine consome o resultado de Readiness e um catálogo publicado, sem reclassificá-lo;
- a UI consome DTOs de Readiness, Recommendations e Recent Mock Summary, sem fórmula duplicada;
- o cálculo é on demand, sem snapshots, IA, probabilidade de aprovação ou alteração das engines existentes.

Não foi encontrada divergência estrutural entre a arquitetura planejada e a implementação real.

## Evidence Model

Existem seis fontes funcionais: Mock Exam, Topic Quiz, Lesson Quiz, Review Quiz, Lessons e Flashcards. As três primeiras contribuem para performance em ordem de força; Review Quiz serve para remediação/recorrência; Lessons e Flashcards compõem apenas Learning Progress.

O cenário com 100% das Lessons concluídas e Flashcards revisados, mas sem avaliação, retorna `not_enough_evidence`, score `null` e mantém o progresso de estudo alto. Ausência de evidência nunca é convertida em 0% ou em `needs_review`.

## Topic Readiness

- Topic sem avaliação: `insufficient_evidence`, score `null`.
- Um único erro: evidência `limited`, sem Weak Topic confirmado e sem prioridade crítica.
- Erros baixos recorrentes em Mock e Topic Quiz: Weak Topic confirmado com razões objetivas.
- Mock baixo + Topic Quiz alto permanece `needs_review` por `low_mock_performance`.
- Mock alto + Topic Quiz baixo recorrente permanece `needs_review` por `repeated_topic_quiz_errors`.
- Topics locais fracos continuam visíveis e recomendados mesmo quando o restante do Domain tem bom desempenho.

## Domain Readiness

Os três Domains usam os pesos fixos `0.275 / 0.375 / 0.350`, que somam exatamente 1. O teste reconstrói o score global a partir dos resultados dos Domains e confirma igualdade exata após arredondamento. Um Topic confirmado fraco impede que seu Domain seja promovido a `strong`; evidência insuficiente não vira reprovação.

## Global Readiness

Os estados finais são `not_enough_evidence`, `needs_review`, `developing` e `strong`. A classificação não é uma média simples: exige volume, diversidade, cobertura, múltiplas sessões, Mock finalizado, recência, consistência e ausência de lacuna crítica. Topic Quiz forte sem Mock e um único Mock de 95% permanecem `developing`.

## Recency

A política usa timestamps absolutos e os buckets centralizados `fresh` (até 14 dias), `recent`, `aging` e `stale`. No teste com a mesma Question, trocar o acerto recente de 2 dias pelo acerto antigo de 120 dias altera o score de `71.43` para `28.57`, confirmando maior influência da evidência recente. O boundary exato de 14 dias e um timestamp `-03:00` produzem o mesmo resultado UTC esperado.

Evidência forte porém stale reduz o evidence level para `sufficient`, bloqueia `strong` e produz recomendação de reavaliação.

## Consistency

A métrica usa até cinco tentativas comparáveis da fonte mais forte disponível. Fixtures exatas de 100 respostas por tentativa validaram:

| Scores | Range | Classification |
| --- | ---: | --- |
| 84, 85, 86, 85 | 2 | `high` |
| 50, 95, 55, 90 | 45 | `low` |

Um único Mock retorna `insufficient_data`. O perfil Lucky Mock não se torna `strong` apesar do pico final.

## Trend

O resultado determinístico validado foi:

- 55, 65, 75 → `improving`;
- 84, 85, 83 → `stable`;
- 85, 74, 63 → `declining`;
- uma tentativa → `insufficient_data`.

O perfil declining não permanece `strong` por causa de resultados antigos e recebe razão amigável de revisão.

## False Strong Safeguards

A suíte conceitualmente chamada `falseStrongSafeguards` cobre e bloqueia `strong` em todos os sete casos obrigatórios:

1. 100% Lessons e zero assessment;
2. um Mock de 95%;
3. score global bom com Domain fraco;
4. evidência forte antiga;
5. baixa cobertura de Topics;
6. performance extremamente inconsistente;
7. muitos Topic Quizzes altos e nenhum Mock.

## Weak Topics

Erros recorrentes em três Mocks e três Topic Quizzes confirmam prioridade `critical` com `low_mock_performance`, `repeated_mock_errors` e `low_topic_quiz_performance`. Um erro isolado não confirma fraqueza. Uma lacuna localizada continua visível, bloqueia overclassification do Domain/Global e permanece entre as recomendações.

## Recommendations

- Máximo de três Priority Topics e três Lessons por Topic.
- No cenário com cinco Lessons, A com cinco erros fica antes de B com três; C com zero não supera ambas.
- Insufficient Evidence gera `assess_topic`, não uma alegação de fraqueza.
- `review_lesson`, `review_flashcards`, `retake_topic_quiz`, `assess_topic` e `take_another_mock` possuem gates de catálogo e rotas reais.
- Todos os 12 reason codes internos possuem mapping amigável; nenhum code precisa vazar na UI.
- Três execuções idênticas retornam Readiness, recomendações e ordenação exatamente iguais.

## UI

A rota protegida `/certifications/:certificationCode/readiness` cobre New Student, Developing, Strong, Weak Domain, stale, loading e error. A página mostra Overall status, Evidence, Learning Progress, três Domains, até três Priority Topics, ações e até cinco Mocks recentes.

New Student recebe `Not Enough Evidence`, explicação e CTAs sem cards vermelhos ou 0% enganoso. Developing responde “o que fazer agora” por prioridades e ações. Strong mantém Topics restantes visíveis quando existirem. Declining usa texto não alarmista. `How is this calculated?` diferencia avaliação de estudo, descreve Mock/Topic/Lesson Quiz, recência e não chama conclusão de Lesson de mastery. Nenhum número é apresentado como chance, probabilidade, score oficial ou garantia.

Validação visual da 12.4 — sem mudança posterior de UI — passou em desktop 1440×900 e mobile 390×844, sem erro de console nem overflow horizontal significativo.

## Security

- O RPC de evidência é `SECURITY DEFINER`, fixa `search_path = ''`, exige autenticação e deriva ownership exclusivamente de `auth.uid()`.
- O cliente envia apenas `certification_id`; não existe parâmetro `user_id`.
- Quiz, Mock, Lesson progress, Flashcard reviews e Flashcard progress possuem predicates owner-only.
- `public`/`anon` não executam o RPC; somente `authenticated` possui grant.
- A migration 077, já aplicada no remoto, valida assinatura, grants, `auth.uid()` e predicates de todas as fontes.
- Mock history e Quiz history também filtram `auth.uid()`/owner e não retornam snapshots de Questions no dashboard.
- O teste de hook A/B confirma chave `user.id + certificationId`, limpeza no logout e descarte de respostas atrasadas após troca de usuário.

O teste SQL transacional A/B está versionado em `supabase/tests/validate_readiness_evidence_isolation.sql`. Nesta máquina, ele não executou porque o PostgreSQL local do Supabase não está ativo em `127.0.0.1:54322`; a validação estática remota e os testes de aplicação passaram. Não foi identificado vazamento.

## Accessibility

- Um `h1`, headings hierárquicos e regions nomeadas.
- Status, Evidence, trend e prioridade possuem texto e não dependem apenas de cor.
- Progressbars expõem nome, mínimo, máximo e valor.
- Links, buttons e disclosure usam elementos semânticos e focus styles.
- Ícones decorativos ficam fora da árvore acessível.
- Recent Performance tem alternativa textual e não depende de chart.
- CTAs mobile medem pelo menos 44 px na validação visual.

## Performance

O dashboard executa em paralelo um RPC consolidado de evidência e uma consulta paginada de Mock history limitada a 10; entrega no máximo cinco resumos. O catálogo de recomendações é buscado em lotes e não carrega answers, snapshots nem centenas de Questions para renderizar a UI. Não há N+1 por Topic ou Lesson.

O build de produção gerou JavaScript de `755.80 kB` (`200.77 kB` gzip) e emitiu o warning não bloqueante de chunk acima de 500 kB. Code splitting permanece oportunidade de polish, sem impacto na correção do Readiness.

## Regression

A suíte reexecuta:

- Mock Exam: Start, 40 Questions, persistência, timer, Submit, Result, Review, Retake e History;
- Lesson Quiz: attempts, answers, scoring e progress;
- Topic Quiz: seleção, retake rotation, scoring e histórico;
- Flashcards/Spaced Repetition: review, schedules e due cards;
- Lesson: conteúdo, conclusão, Flashcards, Quiz e navegação;
- payload compatível com metadata opcional ausente;
- tentativa inválida/estado estrutural grave tratado pelo contrato de validação, sem derrubar silenciosamente o dashboard.

Readiness permanece consumidor read-only desses fluxos e não altera scoring, histórico ou agendamento.

## Test Profiles

| Profile | Expected | Actual | Evidence | Trend | Weak Topics | Result |
| --- | --- | --- | --- | --- | ---: | --- |
| New Student | Not Enough Evidence | `not_enough_evidence` | `insufficient` | `insufficient_data` | 0 | PASS |
| Lesson Only | Not Enough Evidence | `not_enough_evidence` | `insufficient` | `insufficient_data` | 0 | PASS |
| Topic Quiz Only | Developing / not Strong | `developing` | `sufficient` | `stable` | 0 | PASS |
| One Strong Mock | Not Strong | `developing` | `limited` | `insufficient_data` | 0 | PASS |
| Lucky Mock | Not Strong | `developing` | `strong` | `improving` | 0 | PASS |
| Weak | Needs Review | `needs_review` | `strong` | `improving` | 12 | PASS |
| Improving | Developing | `developing` | `strong` | `improving` | 0 | PASS |
| Declining | Not Strong | `developing` | `strong` | `declining` | 12 | PASS |
| Consistent Strong | Strong | `strong` | `strong` | `stable` | 0 | PASS |
| Weak Domain | Not overclassified | `needs_review` | `strong` | `stable` | 4 | PASS |
| Stale Strong | Reduced confidence | `developing` | `sufficient` | `stable` | 0 | PASS |

Nota: os Mocks de algumas fixtures possuem dez itens por Topic; percentuais como 84/85/86 quantizam para scores por tentativa de 80/90. Por isso o perfil Strong agregado pode exibir consistency `moderate`, sem violar o gate (`not low`). A matemática de consistency `high` foi validada separadamente com 100 respostas por tentativa.

## Blockers

| Priority | Count | Finding | Closure impact |
| --- | ---: | --- | --- |
| P0 | 0 | Nenhum problema de segurança, isolamento ou cálculo fundamental encontrado. | Nenhum |
| P1 | 0 | Nenhum falso Strong, ausência como zero ou recomendação sistematicamente incorreta. | Nenhum |
| P2 | 1 | O teste SQL transacional local A/B não pôde executar sem o PostgreSQL/Docker local; migrations remotas, validação estática e testes A/B de aplicação passaram. | Limitação de evidência operacional; não altera nem compromete a interpretação do aluno. |
| P3 | 1 | Bundle principal acima de 500 kB minificado. | Polish/performance futura; build válido. |

Validação técnica final:

| Check | Result |
| --- | --- |
| `npm run typecheck` | PASS |
| `npm run lint` | PASS, zero warnings |
| `npm run test:run` | PASS — 202/202 tests, 26/26 files |
| `npm run build` | PASS — 1 warning de chunk |
| `git diff --check` | PASS — somente avisos informativos LF→CRLF |
| `npm run db:push:dry-run` | PASS — remoto atualizado, 0 migrations pendentes |
| SQL isolation local | NOT RUN — PostgreSQL local indisponível |

## Final Decision

Arquitetura, separação Study/Readiness, suficiência, Topics, Domains, Global, recência, consistência, tendência, false-Strong safeguards, recomendações, UI, isolamento, performance e regressões satisfazem os critérios da Etapa 12.5. P0 = 0 e P1 = 0; o P2 registrado é uma limitação do ambiente local de validação, não um defeito de produto ou risco de interpretação.

**AZ-900 Readiness System: CLOSED**


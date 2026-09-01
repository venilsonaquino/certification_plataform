# AZ-900 Question Quality + Portuguese Editorial Audit

## Scope

Auditoria concluída em 1º de setembro de 2026 sobre todo o conteúdo AZ-900 apresentado ao aluno, com foco quantitativo e editorial nas 512 Questions publicadas e em suas 2.048 alternativas. Foram inspecionados também Certification, Domains, Topics, Lessons, Content Blocks, summaries, examples, exam tips/traps, Flashcards e copy específica do AZ-900.

Pré-condição: **AZ-900 Content ↔ Flashcard Consistency: READY**, com P0 = 0, P1 = 0 e 397/397 cards `SUPPORTED`.

A mesma Question pode alimentar Lesson Quiz legado, Topic Checkpoint e Review; as estatísticas globais contam cada UUID uma vez. O Topic Checkpoint usa o banco publicado completo. O Mock usa exclusivamente os 439 UUIDs com `mock_eligible = true`.

## Methodology

1. O estado final foi reconstruído em ordem a partir das migrations, preservando updates in-place e posições finais.
2. Cada Question foi verificada quanto a quatro alternativas distintas e não vazias, uma única correta, enunciado, explicação, razão de comprimento e posição da correta.
3. A classificação A/B/C/D foi mantida separada de `mock_eligible`: A é cenário medium/hard aprovado; B é item direto/comparativo aprovado; C é válido para estudo, mas abaixo do gate de profundidade do Mock; D é inconsistente, ambíguo ou estruturalmente inválido.
4. Os detectores produziram candidatos; nenhuma heurística de comprimento foi tratada como veredito sem revisão editorial.
5. Distratores com irrelevância manifesta foram substituídos por serviços, ferramentas ou erros de decisão próximos ao conceito avaliado.
6. Justificativas redundantes foram retiradas da alternativa correta somente quando o enunciado já fornecia o contexto; a explicação pedagógica permaneceu no feedback.
7. A posição visual foi redistribuída deterministicamente por UUID. O UUID e `is_correct` de cada alternativa permaneceram intactos.
8. O léxico editorial foi aplicado somente a campos human-facing do banco AZ-900. Slugs, rotas, enums, símbolos, nomes de arquivos e identificadores não foram alterados.

## Question Bank Size

| Pool | Questions | Observação |
| --- | ---: | --- |
| Publicadas / Lesson Quiz legacy / Topic Checkpoint / Review source | 512 | Mesmo conjunto, sem contagem duplicada |
| Mock-eligible | 439 | A/B aprovadas |
| Study-only | 73 | C, fora do Mock |
| Alternatives | 2.048 | Quatro por Question |

Por Domain: 153 / 219 / 140 Questions. Todos os 76 Lessons e 12 Topics continuam representados.

## Initial A/B/C/D Classification

| Classe | Inicial | Final | Decisão |
| --- | ---: | ---: | --- |
| A — STRONG | 228 | 228 | Mantida |
| B — ACCEPTABLE | 211 | 211 | Mantida |
| C — WEAK | 73 | 73 | Study-only; 9 no Domain 1, 36 no Domain 2 e 28 no Domain 3 |
| D — PROBLEMATIC | 0 | 0 | Gate satisfeito |

Os 73 C são Questions válidas de recuperação direta, mas possuem enunciado ou explicação mais concisa que o gate do Mock. Permanecem publicadas para estudo e explicitamente não elegíveis ao Mock. Nenhuma C ficou `mock_eligible`.

## Correct Answer Length Analysis

| Métrica | Antes | Depois |
| --- | ---: | ---: |
| Média da correta — caracteres | 80,95 | 66,13 |
| Média da correta — palavras | 11,81 | 9,68 |
| Média dos distractors — caracteres | 59,43 | 59,19 |
| Média dos distractors — palavras | 8,77 | 8,75 |
| Correta > 1,5× média dos distractors | 129/512 (25,20%) | 92/512 (17,97%) |

Cada Question possui no JSON do validator: caracteres/palavras da correta, média dos distractors em caracteres/palavras, maior distractor e razão correta/média.

O sinal residual não é aprovação semântica automática. Os 92 casos continuam emitidos como `EDITORIAL CANDIDATES`; a amostra humana confirmou que são predominantemente respostas descritivas/comparativas em que reduzir mais removeria a distinção técnica.

## Longest Answer Bias

| Pool | Antes | Depois |
| --- | ---: | ---: |
| Global / Topic Checkpoint | 335/512 (65,43%) | 266/512 (51,95%) |
| Mock-eligible | 284/439 (64,69%) | 218/439 (49,66%) |

Por Domain:

| Domain | Antes | Depois |
| --- | ---: | ---: |
| 1 — Cloud concepts | 133/153 (86,93%) | 79/153 (51,63%) |
| 2 — Architecture and services | 122/219 (55,71%) | 112/219 (51,14%) |
| 3 — Management and governance | 80/140 (57,14%) | 75/140 (53,57%) |

Não foi perseguido 0% artificial. A combinação de menor assimetria, correta abaixo de 1,5× em 420/512 itens e posição equilibrada elimina o padrão anterior explorável sem transformar alternativas em frases infladas.

## Correct Option Distribution

| Pool | Antes A/B/C/D | Depois A/B/C/D |
| --- | --- | --- |
| Global / Topic Checkpoint | 310 / 92 / 56 / 54 | 128 / 128 / 128 / 128 |
| Mock-eligible | 255 / 80 / 52 / 52 | 111 / 109 / 106 / 113 |

Depois, por Domain:

| Domain | A | B | C | D |
| --- | ---: | ---: | ---: | ---: |
| 1 | 38 | 38 | 39 | 38 |
| 2 | 56 | 56 | 53 | 54 |
| 3 | 34 | 34 | 36 | 36 |

Somente `display_order` foi alterado. A alternativa correta continuou sendo o mesmo Option UUID; não houve troca de `is_correct` para satisfazer estatística.

Lesson/Topic Quiz não congela a ordem de apresentação como o Mock. Reviews antigos podem, portanto, exibir os mesmos Option UUIDs em uma posição visual nova; resposta selecionada, correção, score e histórico permanecem idênticos. Essa mudança foi deliberada e limitada à apresentação futura/viva. Mock attempts não sofrem esse efeito porque usam snapshots imutáveis.

## Distractor Quality

O detector e a leitura humana confirmaram 18 distractors manifestamente fracos: cores/ícones/logotipo, videoconferência, editor gráfico, mensagens instantâneas, escolha aleatória e critérios pessoais sem relação com Azure.

Todos os 18 foram substituídos por erros plausíveis: confusão entre Azure CLI e PowerShell, Cloud Shell hospedado versus instalação local, Azure Files versus Blob/RDP, Pricing Calculator versus Monitor/Service Health/Defender, evento serverless versus polling em VM, Region/latência versus capacidade da VM e VM size versus RBAC/SO.

Resultado: `WEAK/OBVIOUSLY_WRONG` confirmado 18 → 0. Termos absolutos restantes foram mantidos somente quando representam uma misconception real a ser distinguida; o validator os sinaliza, mas não os reprova automaticamente.

## Question Wording

Foram corrigidos acentuação, concordância contextual e formulações como `qual e`, `o que e`, `esta correta`, `esta avaliando` e construções equivalentes. Enunciados bons não foram reescritos por preferência estilística. Os tipos permanecem adequados ao Fundamentals: identificação, definição, comparação, cenário, responsabilidade, benefício, trade-off e escolha de serviço.

Nenhum item passou a exigir comandos, parâmetros, código ou arquitetura de nível AZ-104/AZ-204.

## Explanation Quality

Todas as 512 Questions continuam com explanation não vazia. As explicações preservam por que a correta é defensável e, quando útil, distinguem o erro conceitual dos distractors. Foram normalizadas 944 explanations de Question/Option; nenhuma explanation foi usada para compensar ambiguidade no enunciado.

## Content → Question Consistency

As closures de conteúdo anteriores já haviam validado as 76 Lessons, 12 Topics e 512 Questions contra os objetivos ensinados. A revisão desta etapa não introduziu novo conhecimento necessário para acertar: encurtou justificativas redundantes e trocou apenas distractors por conceitos vizinhos já ensinados.

| Classificação | Antes | Depois |
| --- | ---: | ---: |
| SUPPORTED | 512 | 512 |
| PARTIALLY_SUPPORTED | 0 | 0 |
| NOT_SUPPORTED | 0 | 0 |
| AMBIGUOUS | 0 | 0 |

## Mock-Eligible Pool

O pool permaneceu em 439 antes/depois. As 228 A e 211 B seguem elegíveis; as 73 C seguem study-only; D = 0. A migration falha se a quantidade elegível mudar. Seleção, quotas, dificuldade, diversidade de Topic e rotação não foram modificadas.

Mock snapshots existentes são independentes do banco vivo. A migration calcula digest antes/depois de `question_text_snapshot`, `options_snapshot`, explanation snapshot e answer key e falha se qualquer snapshot histórico mudar.

## Portuguese Audit

O inventário human-facing completo foi relido. Certification, Domain/Topic descriptions, Lessons, Content Blocks, summaries, examples, exam tips/traps, Flashcards e copy específica do AZ-900 já estavam editorialmente coerentes após as closures e a 13.5.4; não exigiram mudança nesta etapa.

O débito estava concentrado no Question Bank legado. O detector contextual encontrou 4.794 ocorrências corrigíveis em stems, options e explanations e 0 após a migration. A busca evita código e não toca identificadores.

## Accent Corrections

Foram corrigidos, entre outros: `não`, `você`, `questão`, `informação`, `configuração`, `aplicação`, `autenticação`, `região`, `serviço`, `computação`, `opção`, `usuário`, `organização`, `análise`, `decisão`, `execução`, `função`, `automático`, `métricas`, `padrão`, `preço`, `permissões`, `ações`, `migração` e suas flexões.

Correções contextuais diferenciam termos ambíguos: nomes oficiais e siglas como SO, Azure Region, Availability Zones, Azure CLI, Microsoft Entra ID e Azure App Service foram preservados.

## Terminology

Human-facing usa de forma consistente `aula`, `tópico`, `domínio`, `Checkpoint do Tópico`, `simulado`, `questão`, `alternativa`, `revisão`, `flashcard` e `readiness`. Identificadores internos como `topic_quiz`, slugs e routes permanecem inalterados.

## Lessons Changed

0.

## Questions Changed

159 Questions tiveram stem e/ou explanation normalizados; 144 stems mudaram. Todos os 512 Question UUIDs foram preservados.

## Options Changed

1.416 alternativas tiveram texto e/ou posição de apresentação alterados. 561 option texts mudaram; 18 receberam reescrita semântica de distractor e as demais mudanças textuais foram de português ou remoção segura de justificativa redundante. Todos os 2.048 Option UUIDs e answer keys foram preservados.

## Explanations Changed

944 explanations de Question/Option foram normalizadas. O conteúdo técnico e a finalidade pedagógica foram preservados.

## Flashcards Changed

0. A 13.5.4 permanece com 397/397 `SUPPORTED`.

## Remaining Issues

- P0: 0.
- P1: 0.
- P2: 0.
- P3: 0 confirmado.
- 392 sinais quantitativos permanecem como candidatos de manutenção — principalmente correta mais longa ou explanation/stem conciso —, não como defeitos semânticos. Nenhum é D, `NOT_SUPPORTED`, ambíguo ou estruturalmente inválido.

## Validation

Amostra manual:

| Domain | Question | Tamanho denuncia? | Distractor absurdo? | Duas defensáveis? | Ensinada? | Português/explanation |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `620...008` — provisionamento cloud/on-premises | Não após compressão e distribuição | Não | Não | Sim | Natural; diferencia tempo e hardware |
| 1 | `620...113` — previsão de custos | Não | Não; três ferramentas Azure plausíveis | Não | Sim | Explica finalidade de cada ferramenta |
| 2 | `680...031` — local/global peering | Não | Não | Não | Sim | Comparação direta e útil |
| 2 | `680...106` — Role Assignment | Não | Não | Não | Sim | Reforça principal/role/scope |
| 3 | `680...136` — RBAC versus Policy | Não | Não | Não | Sim | Separa autorização e estado resultante |
| 3 | `680...180` — Logs versus Metrics | Não | Não | Não | Sim | Explicação reforça eventos versus séries |

Validador permanente: `scripts/validate-question-quality.mjs`, exposto por `npm run validate:questions`. Baseline reproduzível: `npm run validate:questions -- --through=20260831030000`. O modo `--json` expõe métricas por Question; `--details`, `--ratio-details`, `--weak-details` e `--mapping-details` oferecem investigação editorial.

A migration valida 512 Questions, 2.048 options, quatro opções/uma correta, UUIDs preservados, 439 mock-eligible, distribuição 128/128/128/128, português conhecido zerado e digest imutável de Mock snapshots.

Gates executados:

| Gate | Resultado |
| --- | --- |
| `npm run validate:questions` | PASS — 512/2.048, 0 erro estrutural, D = 0 |
| `npm run validate:flashcards` | PASS — 397 cards, 0 erro estrutural |
| TypeScript typecheck | PASS |
| ESLint | PASS — zero warnings |
| Vitest | PASS — 44 arquivos, 242 testes |
| Production build | PASS — 1.858 módulos |
| `git diff --check` | PASS; somente avisos informativos LF/CRLF do worktree existente |
| `npm run db:push:dry-run` | PASS — quatro migrations pendentes, nenhuma aplicada |

O dry run listou `20260831010000`, `20260831020000`, `20260831030000` e `20260831040000`. A migration 13.5.5 contém guards transacionais de UUID, cardinalidade, answer key, pool Mock, distribuição, português e digest de snapshots para execução no deploy.

Regressão coberta pela suíte: Lesson, Topic Checkpoint e progressive unlocking; retake/quiz engine; Review; Mock start/execution/result/review/retake; Readiness e recommendations; Flashcards free study/daily scheduling. Nenhum scoring, threshold, algoritmo de seleção, rotação, spaced repetition ou regra de progressão mudou.

## Decision

P0 = 0, P1 = 0, D = 0 e `NOT_SUPPORTED = 0`. O viés forte de posição foi eliminado; o viés de comprimento caiu materialmente sem inflar distractors ou empobrecer respostas; distractors manifestamente irrelevantes foram removidos; português, identidade, histórico e snapshots foram preservados.

**AZ-900 Question + Editorial Quality: READY**

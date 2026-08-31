# AZ-900 Readiness UI Validation

Validação da interface implementada na Etapa 12.4. A página apresenta somente os resultados das engines 12.2/12.3 e resumos owner-scoped; não contém fórmula de Readiness, IA, previsão de aprovação ou histórico bruto.

## Overall Status

- Rota protegida: `/certifications/:certificationCode/readiness`.
- Entrada disponível na navegação principal desktop e mobile.
- Labels aprovados: `Not Enough Evidence`, `Needs Review`, `Developing`, `Strong`.
- Cada classificação possui explicação curta e determinística.
- Readiness Score interno, chance de aprovação, `Passed` e `Failed` não são exibidos.

## Evidence

- Evidence level textual: `Insufficient`, `Limited`, `Sufficient`, `Strong`.
- Contagens reais de Mocks e Topic Quizzes vêm de `sourceCounts`.
- Total de respostas, Questions distintas e sessões vem do trace agregado.
- Learning Progress possui progressbar próprio e aviso explícito de que conclusão não equivale a domínio.
- O painel expansível explica qualidade e recência das fontes sem mostrar magic numbers.

## Domains

Os três Domains são exibidos em cards com classificação, evidence level, trend, cobertura percentual de Topics, até dois Topics que pedem atenção, última evidência e link para a trilha. `Insufficient Evidence` usa texto explícito, sem zeros interpretados como reprovação.

## Priority Topics

Somente os até três Topics já selecionados e ordenados pela 12.3 são renderizados. Cada card mostra prioridade textual, evidence level, trend, razões amigáveis, métricas objetivas e Lessons recomendadas. A UI não faz `sort`, não promove Topic e não adiciona Lesson.

## Recommendations

- Summary Actions limita a três itens na ordem da engine.
- Lesson CTA usa o slug real.
- Flashcard CTA só aparece no DTO quando há cards publicados.
- Topic Quiz CTA só aparece quando o pool foi validado pela 12.3.
- Mock CTA aponta para o fluxo existente de Mock Exams e não duplica Start.
- Não existe ação fictícia, IA ou calendário automático.

## Trends

`Improving`, `Stable`, `Declining` e `Insufficient Data` usam mapping textual. Declining é comunicado sem linguagem alarmista. Trend não é recalculado, inferido da lista de Mocks ou convertido em prediction.

## Recent Performance

O serviço busca até dez itens para não perder Mocks finalizados quando existe tentativa ativa e entrega no máximo cinco resumos `completed`/`expired`: attempt, data, status e Practice Score. Answers e snapshots não entram no DTO da UI. O texto esclarece que Practice Score não é pontuação oficial nem previsão.

## Empty States

- New Student: `Not enough evidence yet`, explicação e ações de estudo/assessment existentes.
- Lesson-heavy: Learning Progress pode ser 100%, enquanto Overall continua `Not Enough Evidence`.
- Strong: estado positivo e nenhuma revisão prioritária, sem pass/fail.
- Loading: skeleton sem salto estrutural brusco.
- Error: mensagem amigável e `Tentar novamente`; erro Supabase não é renderizado.
- Stale: aviso para nova avaliação vindo do bucket já calculado.

## Navigation

Foram verificados hrefs reais para:

- Readiness → Lesson;
- Readiness → Topic Quiz;
- Readiness → Flashcards;
- Readiness → Mock Exams;
- Readiness → Study path.

A rota segue o mesmo React Router protegido da certificação e aceita o `certificationCode` corrente.

## Mobile

Validação visual em 390 × 844 confirmou cards empilhados, Domain grid com uma coluna, CTA com largura disponível e altura mínima entre 44 e 50 px, sem tabela horizontal ou overflow (`scrollWidth <= innerWidth`). Desktop 1440 × 900 confirmou três colunas de Domain e cards de conteúdo equilibrados. Nenhuma biblioteca de charts foi adicionada.

## Accessibility

- Um `h1` por página e headings de seção hierárquicos.
- Regions nomeadas por `aria-labelledby`.
- Status, Evidence, trend e prioridade aparecem em texto, além de cor.
- Progress bars expõem label, mínimo, máximo e valor atual.
- Links e botões usam elementos semânticos e focus styles existentes.
- Ícones decorativos são ocultados da árvore acessível.
- Recent Performance possui resumo textual; não depende de gráfico.

## Security

O hook é keyed por `user.id + certificationId`, não possui cache global e ignora resposta atrasada após troca de usuário. Logout limpa o state. Evidência privada vem das RPCs owner-only da 12.2/Mock; catálogo adicional contém apenas currículo publicado e não aceita `user_id` do cliente.

## Regression

Os testes da UI reutilizam fixtures reais New Student, Lesson Completion Only, Weak, Improving, Consistent Strong e Strong Overall with Weak Domain. As suítes 12.2 e 12.3 são reexecutadas integralmente, junto com Mock Start/Execution/Result/Review/History/Retake e Study/Lesson/Quiz/Flashcard/Review.

## Known Limitations

- Não há gráfico: a lista de até cinco Practice Scores comunica melhor o pequeno histórico atual.
- A data usa formato absoluto em pt-BR; não há relógio relativo ao vivo.
- A UI não abre um Domain em âncora específica porque a Study Page atual não expõe rota por Domain.
- A 12.2 bloqueia Global `Strong` quando existe Domain `needs_review`; por isso o perfil G real aparece globalmente `Needs Review`, mantendo o Domain fraco visível. A UI suportaria a combinação se o contrato futuro permitisse, mas não sobrescreve a engine.
- Não existem Dashboard de IA, recomendações generativas, notificações ou plano automático.

## Decision

Overall status, Evidence, Domains, Priority Topics, recomendações, Recent Performance, trend, recência, estados insuficiente/loading/error, responsividade, acessibilidade e isolamento estão implementados sobre contratos determinísticos. Após regressão completa, build e dry-run sem migration nova, a Etapa 12.4 pode ser declarada `AZ-900 Readiness UI: READY`.

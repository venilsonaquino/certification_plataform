# Product Navigation Cleanup

Auditoria e limpeza da navegação do produto na Etapa 13.1. Nenhuma engine, dado curricular, histórico de usuário ou estrutura de banco foi alterada.

## Before

| Item | Audit status | Finding |
| --- | --- | --- |
| Dashboard | FUNCTIONAL | Resumo de estudo, progresso, próxima aula e revisão de Flashcards. |
| Estudo do Dia | FUNCTIONAL | Sequência diária baseada no progresso real. |
| Trilha de estudos | FUNCTIONAL | Domains, Topics, Lessons e Topic Quizzes. |
| Mapa | PLACEHOLDER / REDUNDANT | Exibia somente um título e não acrescentava função à trilha. |
| Laboratórios | PLACEHOLDER / INTERNAL/FUTURE | Exibia somente um título; AZ-900 não possui Labs implementados. |
| Story Mode | PLACEHOLDER / INTERNAL/FUTURE | Exibia somente um título e era uma ideia futura. |
| Quiz | PLACEHOLDER / REDUNDANT | Exibia somente um título; Lesson, Topic e Review Quiz já têm fluxos próprios. |
| Revisão | FUNCTIONAL | Erros, Review Quiz e revisão diária de Flashcards. |
| Simulados | FUNCTIONAL | Start, Resume, Execution, Result, Review, Retake e History. |
| Readiness | FUNCTIONAL | Evidência de avaliação, recência, consistência, trend e recomendações. |
| Progresso | FUNCTIONAL | Conclusão do currículo e tempo estimado estudado. |

## After

A navegação principal contém, nesta ordem:

1. Dashboard
2. Estudo do Dia
3. Trilha de estudos
4. Revisão
5. Simulados
6. Readiness
7. Progresso de estudo

Desktop e mobile reutilizam a mesma fonte canônica, portanto não podem divergir na lista de features expostas.

## Removed placeholders

Foram removidos da navegação, do router e do código morto:

- Mapa (`/map`, `MapPage`);
- Laboratórios (`/labs`, `LabsPage`);
- Story Mode (`/story`, `StoryModePage`);
- Quiz genérico (`/quiz`, `QuizPage`).

As rotas válidas de Lesson Quiz (`/study/:lessonSlug/quiz`), Topic Quiz (`/topics/:topicId/quiz`) e Review Quiz (`/review/quiz`) foram preservadas.

## Preserved core features

Permanecem expostos e funcionais Dashboard, Study Today, Study Path, Lesson, Lesson/Topic/Review Quiz, Flashcards, Spaced Repetition, Mock Exams completos, Readiness e Progress. A estrutura `/certifications/:certificationCode/*` não foi alterada.

## Why Progress and Readiness remain separate

**Progresso de estudo** mede exposição e avanço curricular: aulas concluídas/restantes, percentual do currículo, minutos estimados e progresso por Domain.

**Readiness** interpreta evidência de performance de Mock Exam, Topic Quiz e Lesson Quiz, junto de cobertura, recência, consistência, tendência e Weak Topics. Concluir conteúdo não comprova domínio; por isso os indicadores continuam separados e nenhuma fórmula foi alterada.

## Future capabilities

Labs, Story Mode e Map permanecem ideias futuras, sem promessa de implementação. Labs is a future certification capability and should be reconsidered during the Multi-Certification Capability phase, especialmente para certificações práticas como AZ-204. Nenhuma capability, feature flag ou configuração AZ-204 foi criada nesta etapa.

## Validation

- Testes canônicos garantem a lista de sete itens e a ausência dos quatro placeholders.
- A página de Progresso continua funcional com a nomenclatura `Progresso de estudo`.
- Os testes existentes de Readiness, Lessons, Quizzes, Flashcards e Mock Exams permanecem como regressão.
- Sidebar e MobileNavigation mantêm links semânticos, indicador ativo textual/visual, ícones decorativos e itens com altura mínima de 44 px.
- Nenhuma migration foi criada e nenhum dado de usuário foi alterado.

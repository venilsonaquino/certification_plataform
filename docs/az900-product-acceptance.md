# AZ-900 Product Acceptance

Aceitação de produto da Etapa 13.2. A avaliação considera a jornada completa do aluno e preserva todas as engines, dados curriculares, históricos e políticas de segurança existentes.

## Scope

Foram auditados Login, cadastro, seleção de certificação, Dashboard, Estudo do Dia, Trilha, Lesson, três níveis de Quiz, Flashcards, Revisão, Mock Exam, Readiness, recomendações e Progresso de estudo. O cleanup da Etapa 13.1 está `READY`, com P0 = 0 e P1 = 0.

Não foram implementados novos sistemas, Labs, IA, AZ-204, capabilities, generalizações ou migrations.

## User Journey

A jornada funcional validada é:

```text
Login → escolher AZ-900 → Dashboard → Estudo do Dia → Trilha → Lesson
→ Lesson Quiz / Flashcards → Topic Quiz → Revisão → Review Quiz
→ Practice Mock → Resultado → Review → Readiness → ação recomendada
```

Cada superfície possui identificação da certificação, ação principal, retorno explícito ou navegação global, estado vazio e estado de erro controlado. Os retornos Readiness → Lesson, Readiness → Topic Quiz, Readiness → Mock, Mock Review → Lesson, Lesson → Quiz → Lesson e Review → Quiz → Review usam rotas reais.

## Certification Selection

- Login e cadastro possuem labels, autocomplete, validação de campo, mensagens amigáveis e loading no CTA.
- Erros do Supabase são convertidos em mensagens de produto; payloads técnicos não são renderizados.
- `Escolha sua certificação` mostra código, nome, provider e disponibilidade.
- Certificação habilitada possui CTA nomeado; certificação desabilitada é artigo não clicável com `aria-disabled` e `Em breve`.
- `Trocar certificação` retorna para `/certifications` em desktop e mobile.
- Validação visual de Login/Register passou em 1440×900 e 390×844, sem overflow horizontal; campos e CTA medem 48 px no mobile.

## Dashboard

O Dashboard identifica a certificação, mostra progresso geral, próxima aula, última atividade, tempo estimado e fila de Flashcards. O CTA destacado leva ao Estudo do Dia. Ele permanece resumo e próximo passo, sem duplicar Progresso, Readiness ou Mock History. Simulados e Readiness continuam acessíveis na navegação principal.

## Study Today

- Aluno novo recebe `Seu estudo começa aqui` e a primeira sequência curricular.
- Progresso existente retoma a Lesson em andamento ou segue a ordem da trilha.
- A meta continua limitada a aproximadamente 30 minutos, sem novo algoritmo.
- Currículo 100% concluído não é mais um dead end: oferece Practice Mock, Revisão e acesso à trilha concluída.
- Falha de dados oferece Retry e ausência real de Lessons usa empty state explícito.

## Study Path

A hierarquia Certification → Domain → Topic → Lesson permanece visível. Domains são expansíveis; Topics mostram numeração, descrição, conclusão e Topic Quiz; Lessons apresentam título, duração e status textual `Não iniciada`, `Em andamento` ou `Concluída`. Estado não depende apenas de cor.

## Lesson Experience

Lessons usam breadcrumb curricular, retorno à origem, título, duração, status, Content Blocks, mídia, Visual Experiences, Azure Lab blocks embutidos, conclusão, Flashcards, Lesson Quiz e anterior/próxima. Um block inválido é isolado pelo renderer e não derruba a Lesson.

A navegação linear cobre primeira, intermediária e última Lesson sem loop. A conclusão é idempotente, preservada pelo backend e descrita como `Aula concluída`, nunca mastery.

## Lesson Quiz

O cabeçalho identifica a Lesson e o Quiz; a tentativa mostra quantidade, progresso, alternativas semânticas, feedback somente após resposta, explicação e revisão detalhada no resultado. O link superior retorna à Lesson e retake reutiliza a engine existente. Scoring não foi alterado.

## Topic Quiz

O cabeçalho usa `Quiz do Tópico`, identifica o Topic e explica que as questões combinam suas Lessons. Resultado, desempenho por Lesson, revisão e retake permanecem funcionais. A rotação da Etapa 10.3 não foi modificada.

Os níveis ficam distintos: Lesson Quiz avalia uma Lesson; Topic Quiz avalia um Topic; Practice Mock avalia a certificação completa.

## Flashcards

Flashcards por Lesson orientam lembrar antes de revelar, oferecem dica, frente/verso, rating, progresso, agendamento, resumo e retorno à Lesson. A Revisão diária se identifica como `Revisão espaçada`, usa cards vencidos/novos e retorna à tela Revisão. Empty states diferenciam ausência de cards de fila em dia.

## Review

A tela explica que Questions surgem do histórico de erros e que Flashcards usam revisão espaçada. Mostra contagem, prioridades, filtros, tentativa ativa e CTA principal. Sem erros, apresenta `Nenhum erro para revisar` como estado positivo e direciona à trilha. Review Quiz preserva resultado, retorno e atualização do histórico.

## Mock Exam

- Start explica Practice Mock, 40 questões, 60 minutos da plataforma, ausência de feedback, respostas editáveis e caráter não oficial.
- Resume, novo Mock, histórico, paginação e estados agora usam microcopy consistente em português.
- Execution preserva timer, navigator, answered/unanswered, alteração de resposta, refresh/resume, resumo e submit dialog.
- Durante execução não são expostos gabarito, explicação, Domain, Topic, Lesson ou difficulty.
- Resultado mostra Practice Score, corretas/incorretas/não respondidas, duração e breakdowns por Domain, Topic e dificuldade, sem Passed/Failed.
- Review libera resposta correta, explicação e contexto curricular somente depois da finalização e oferece `Revisar aula`.
- Retake e histórico usam os contratos existentes; nenhuma regra de Mock foi alterada.

## Readiness

Readiness responde estado geral, evidence level, Domains, Topics prioritários, tendência, Mocks recentes e próximas ações. Ausência de evidência continua score `null`, com texto positivo e CTA de estudo. A UI não mostra probabilidade, garantia ou pontuação oficial.

A microcopy geral foi harmonizada em português, preservando os termos técnicos Readiness, Domain, Topic, Mock e Topic Quiz. O cálculo, thresholds e evidence RPC não foram alterados.

## Study Progress

`Progresso de estudo` mede Lessons concluídas/restantes, percentual curricular, minutos estimados e conclusão por Domain. `Readiness` mede evidência de assessment, performance, recência, consistência e weak areas. Os progressbars total e por Domain agora possuem nome e valor acessíveis.

## Navigation

A navegação contém somente Dashboard, Estudo do Dia, Trilha de estudos, Revisão, Simulados, Readiness e Progresso de estudo. Não existem CTAs para Mapa, Labs, Story Mode ou Quiz genérico. Links especializados de Lesson/Topic/Review Quiz foram preservados.

Breadcrumbs refletem Certification → Domain → Topic → Lesson e Flashcards. Mock Result/Review, Quiz e Revisão possuem retornos explícitos para o pai funcional.

## Empty States

Foram validados usuário novo, zero conclusão, zero Flashcards, nenhum erro, nenhum Mock, Readiness insuficiente, conteúdo indisponível e currículo 100% concluído. Estados vazios são informativos e, quando existe ação útil, apontam para um fluxo implementado.

## Loading and Errors

Certifications, Dashboard, Study Today, Study, Lesson, Quizzes, Flashcards, Review, Mock, Readiness e Progress possuem loading dedicado. Falhas estruturais não são mascaradas, mas a UI mostra mensagens amigáveis e Retry quando a operação pode ser repetida. Stack traces, SQL e payloads Supabase não são exibidos.

## Mobile

As páginas usam grids responsivos, cards empilháveis, CTAs com altura mínima de 44 px, filtros roláveis e dialogs limitados ao viewport. Login/Register foram verificados em 390×844 sem overflow. Navigation, Readiness, Mock, questions e submit dialog possuem testes DOM responsivos; as validações visuais anteriores de Readiness/Mock permanecem válidas porque sua estrutura não foi redesenhada nesta etapa.

## Accessibility

- Heading hierarchy e regions nomeadas.
- Links e buttons com nomes claros e focus styles.
- Forms associados a labels, `aria-invalid` e `aria-describedby`.
- Dialog de submit com nome, foco inicial e Escape.
- Radios para opções; status correto/incorreto também em texto e ícone.
- Progressbars com min/max/current e nome acessível.
- Mobile menu com estado expandido, Escape e restauração de foco.
- Nenhum estado essencial depende somente de cor.

## Product Debt

- **P3:** links de Domain em Readiness abrem a trilha no topo, pois a Study Page ainda não expõe deep link por Domain.
- **P3:** labels formais de classificação (`Strong`, `Developing`, `Needs Review`) permanecem em inglês por contrato de produto; um glossário futuro pode avaliar tradução sem alterar semântica.

## Technical Debt

- **P3:** bundle principal permanece acima de 500 kB minificado; code splitting amplo pertence à Etapa 13.3.
- A execução visual autenticada depende de sessão/credenciais; a aceitação dos fluxos privados foi coberta por testes comportamentais e contratos owner-only, enquanto Login/Register receberam inspeção real no navegador local.
- Algumas páginas possuem JSX muito compacto, mas reorganização ampla não pertence ao acceptance.

## Multi-Certification Debt

- `AZ900_READINESS_CONFIG`, `calculateAz900Readiness` e pesos dos três Domains.
- Practice Mock fixo em 40 Questions e alocação AZ-900.
- Títulos `AZ-900 Practice Mock` e políticas versionadas específicas.
- Readiness e recommendation engines específicas do AZ-900.

Esses hardcodes são esperados e não foram generalizados. Capabilities, AZ-204, Labs e configuração multi-certificação pertencem à Fase 14.

## Blockers

| Priority | Count | Status |
| --- | ---: | --- |
| P0 | 0 | Nenhum leak, perda de dados, answer-key leak ou fluxo impossível. |
| P1 | 0 | Nenhum CTA quebrado, atividade inconcluível ou estado pedagogicamente enganoso. |
| P2 | 0 | As fricções encontradas nesta etapa foram corrigidas. |
| P3 | 3 | Deep link de Domain, glossário de status e bundle/code splitting. |

## Decision

Os fluxos principais do AZ-900 permanecem funcionais, seguros, compreensíveis e conectados. A etapa não alterou scoring, seleção, Readiness, recomendações, RLS, histórico ou banco. Com P0 = 0 e P1 = 0, o produto atende ao critério de aceitação.

**AZ-900 Product Experience: ACCEPTED**

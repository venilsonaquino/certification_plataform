# Production Hardening

## Scope

Esta etapa valida e endurece a aplicação AZ-900 existente para produção. O escopo cobre segurança do cliente e do banco, autenticação, isolamento entre usuários, integridade de dados, concorrência, tratamento de falhas, consultas, bundle, migrations e regressão. Nenhuma funcionalidade pedagógica, nova certificação ou generalização multi-certificação foi adicionada.

Inventário inicial de riscos:

| Área | Prioridade inicial | Risco observado | Resultado |
| --- | --- | --- | --- |
| Segurança/RLS | P0 potencial | Uma regressão de grants poderia expor conteúdo sensível ou dados de outro usuário | Políticas, grants e RPCs revalidados; nenhum P0/P1 encontrado |
| Autenticação | P2 | Estado React de um usuário poderia sobreviver a uma troca de sessão | Árvore privada passa a remontar por `user.id`; estado local do mock é limpo no logout |
| Concorrência | P2 | Respostas antigas poderiam sobrescrever uma navegação ou sessão mais recente | Hooks e páginas críticas receberam controle de versão da requisição |
| Confiabilidade | P2 | Uma exceção não tratada poderia deixar a aplicação em branco | Error Boundary global e fallback de carregamento adicionados |
| Bundle | P2 | Todas as páginas eram carregadas de forma eager; chunk inicial com 755,16 kB | Lazy loading por rota; chunk inicial reduzido para 430,45 kB |
| Banco local | P2 | Validação completa desde zero requer Supabase local | Não executada: Docker/Podman indisponível neste ambiente |
| Observabilidade | P3 | Não há coletor externo de erros em produção | Débito documentado; mensagens técnicas não são exibidas ao usuário |

## Security Audit

- O cliente usa apenas `VITE_SUPABASE_URL` e `VITE_SUPABASE_PUBLISHABLE_KEY`. A chave pública é adequada ao navegador desde que RLS e grants permaneçam ativos.
- `.env` local está ignorado pelo Git. O único arquivo de ambiente versionado é `.env.example`, sem valores secretos.
- Não foram encontrados service role keys, access tokens, senhas, connection strings privadas, chaves OpenAI ou secrets Supabase versionados.
- `supabase/config.toml` referencia `env(OPENAI_API_KEY)` sem armazenar o valor.
- Respostas de erro exibidas ao usuário foram normalizadas. Detalhes técnicos são registrados no console somente em desenvolvimento.
- O gabarito do mock não é fornecido durante uma tentativa ativa; respostas e explicações completas são disponibilizadas somente pelo fluxo autorizado de review após a conclusão.

## Authentication

- Rotas privadas aguardam a resolução da sessão antes de renderizar conteúdo autenticado.
- Acesso não autenticado redireciona para login preservando a rota solicitada.
- A árvore privada é remontada com uma chave derivada de `user.id`, impedindo que estado React do usuário A seja reutilizado pelo usuário B.
- Logout remove apenas chaves de UI com prefixo `mock-position:` do `sessionStorage`; dados sem relação com a aplicação não são apagados.
- Tokens continuam sob responsabilidade do cliente oficial do Supabase, com persistência e renovação automática habilitadas.

## RLS

As tabelas de histórico e progresso avaliadas possuem políticas baseadas em `auth.uid()` e não aceitam o identificador de outro usuário como fonte de autoridade:

| Área | Tabelas verificadas | Isolamento esperado |
| --- | --- | --- |
| Lessons | `user_lesson_progress` | Usuário lê e altera apenas o próprio progresso |
| Quiz | `quiz_attempts`, `quiz_attempt_questions`, `quiz_answers` | Tentativas e respostas pertencem ao usuário autenticado |
| Flashcards | `flashcard_reviews`, `user_flashcard_progress` | Revisões e progresso pertencem ao usuário autenticado |
| Mock exams | `mock_exam_attempts`, `mock_exam_attempt_questions`, `mock_exam_answers` | Acesso direto aos detalhes sensíveis é restrito; operações públicas passam por RPCs com verificação de proprietário |

Conteúdo curricular publicado permanece legível por usuário autenticado, enquanto edição curricular não é concedida ao papel comum. A tabela `questions` usa leitura por colunas para não expor a resposta correta pelo catálogo público.

## SECURITY DEFINER

- Todas as funções `SECURITY DEFINER` encontradas declaram `SET search_path = ''`.
- Referências de tabelas e funções são qualificadas por schema.
- Funções públicas sensíveis validam sessão e propriedade usando `auth.uid()`.
- Helpers internos não são concedidos diretamente a `anon` ou `authenticated` quando não constituem API pública.

## RPC Permissions

- Grants públicos foram revogados de RPCs sensíveis e concedidos apenas ao papel necessário.
- RPCs de readiness derivam o usuário de `auth.uid()`; não aceitam `user_id` arbitrário como autoridade.
- Início, sincronização, envio, resultado e review de mock verificam a propriedade da tentativa no servidor.
- Score, acerto e estado final são calculados no servidor. O cliente não é autoridade para `is_correct` ou nota final.
- O grant de leitura de `mock_eligible` necessário ao catálogo de recomendações já estava coberto pela migration `20260830078000_allow_readiness_mock_eligibility_read.sql` anterior a esta etapa.

## Data Integrity

- Tentativas de mock preservam snapshot das questões, alternativas e posição; mudanças futuras no banco de questões não alteram uma tentativa existente.
- O fluxo impede submissão dupla e criação concorrente de múltiplas tentativas ativas pelos invariantes e RPCs existentes.
- Expiração e tempo restante são determinados com dados persistidos no servidor, não apenas pelo timer visual.
- Review, progresso, quiz e flashcards preservam UUIDs e históricos existentes.
- Nenhuma migration destrutiva, regravação de histórico ou mudança de UUID foi feita nesta etapa.

## Query Audit

- O catálogo de certificação monta Domain/Topic/Lesson com três consultas em lote, sem consulta por item.
- Review combina consultas independentes em paralelo e uma contagem, sem loop de consultas por questão.
- Readiness usa uma RPC consolidada de evidências, histórico paginado de mocks e consultas em lote ao catálogo.
- A execução do mock sincroniza as respostas e recebe o snapshot de 40 questões por operações em lote.
- Índices existentes cobrem hierarquia curricular, progresso por usuário, flashcards vencidos, histórico de quiz, tentativa ativa/histórico de mocks e elegibilidade do banco de questões.
- Nenhum índice novo foi necessário nesta etapa.

## N+1

Não foi encontrado N+1 crítico nos fluxos de Dashboard, Study Today, Lessons, Review, Mock Exams ou Readiness. A composição hierárquica é feita em memória após buscas em lote. Consultas adicionais observadas correspondem a agregações ou paginação, não a uma chamada por entidade renderizada.

## Bundle Analysis

Build de produção antes do hardening:

- chunk inicial: 755,16 kB;
- gzip: 200,45 kB;
- alerta do Vite para chunk acima de 500 kB.

Build depois do lazy loading:

- chunk inicial: 430,45 kB;
- gzip: 123,80 kB;
- maior chunk assíncrono: `schemas`, 74,80 kB (20,00 kB gzip);
- nenhum alerta de chunk acima de 500 kB.

Não há bibliotecas pesadas de gráficos, vídeo ou Markdown no caminho inicial. React, Router e Supabase permanecem no núcleo compartilhado.

## Lazy Loading

- Todas as páginas são importadas dinamicamente por rota.
- Um fallback acessível e consistente é exibido enquanto o chunk da página carrega.
- Rotas inválidas continuam produzindo redirecionamento controlado.
- O preview validou abertura direta de `/certifications/az-900/readiness` e de uma rota inexistente sem tela em branco.
- Em produção, o host ainda deve redirecionar URLs desconhecidas para `index.html`; o provedor de deploy não está configurado neste repositório.

## Error Handling

- Um Error Boundary global impede tela branca em exceções de renderização e oferece recarregar ou voltar ao início.
- A Visual Experience mantém boundary local para isolar falhas do conteúdo interativo.
- Falhas de rede em conteúdo, flashcards, quizzes, readiness e mocks exibem mensagens genéricas acionáveis.
- Stack traces e mensagens internas não são apresentadas ao usuário.
- `reportError` mantém detalhes no console apenas durante desenvolvimento. Não há integração externa de observabilidade nesta etapa.

## Race Conditions

- Hooks de review, flashcards, quiz e readiness ignoram respostas antigas quando o contexto solicitado já mudou.
- Páginas de mock ignoram loads obsoletos após navegação/troca de tentativa.
- Início, restart e retake de quiz/mock possuem proteção em memória contra clique repetido enquanto a mutação está em voo.
- Troca do usuário autenticado remonta a área privada, removendo estado derivado da sessão anterior.

## Idempotency

- O backend continua como autoridade para início e submissão do mock.
- Validadores existentes cobrem início duplo, submit duplo, expiração e tentativa já concluída.
- O frontend desabilita/rejeita mutações repetidas enquanto a primeira operação está pendente, reduzindo duplicação acidental sem substituir as garantias do banco.

## Database Migrations

- `db:push:dry-run`: aprovado; remoto e repositório estão alinhados, com `migrations: []` pendentes.
- Ordem de migrations: aceita pelo CLI remoto.
- Migration nova nesta etapa: nenhuma.
- Migrations desde zero em Supabase local: **NOT EXECUTED**. O host não possui Docker nem Podman.
- Validadores SQL A/B locais: **NOT EXECUTED** pelo mesmo motivo.
- Os validadores versionados continuam cobrindo isolamento A/B de mocks, negação de acesso direto às tabelas filhas, proteção do gabarito, duplicidade, expiração, snapshot e idempotência. Essa evidência não substitui uma execução local futura.

## Production Build

- `typecheck`: PASS.
- `lint`: PASS.
- `test:run`: PASS, 35 arquivos e 215 testes.
- `build`: PASS, 1.854 módulos transformados.
- `git diff --check`: PASS; apenas avisos de normalização LF/CRLF do ambiente Windows.
- Preview desktop: PASS para login, rota privada direta e rota inválida.
- Preview mobile em 390 × 844: PASS, sem overflow horizontal (`scrollWidth = innerWidth = 390`).

## User Isolation

- Testes cobrem ausência de flash de conteúdo privado antes da resolução da sessão.
- Testes cobrem remount do estado privado ao alternar de usuário A para usuário B.
- Testes cobrem limpeza do estado local do mock no logout sem apagar outras chaves do navegador.
- Testes de serviços e validações existentes cobrem propriedade das tentativas e leitura autorizada de resultados/review.
- Uma execução SQL local completa com dois usuários permanece recomendada quando Docker estiver disponível.

## Regression

- Navegação e guardas: aprovados.
- Lesson content, Visual Experiences e fallback: aprovados.
- Flashcards, quizzes e review: aprovados.
- Mock start, resume, sync, timer, submit, result, retake, history e review: aprovados.
- Readiness, weak topics e recomendações determinísticas: aprovados.
- Erro global, troca de usuário e resposta assíncrona obsoleta: novos testes aprovados.
- Nenhum erro ou warning de aplicação foi observado no console durante o preview público.

## Remaining Technical Debt

| Prioridade | Débito | Impacto/ação |
| --- | --- | --- |
| P2 | Supabase local indisponível | Executar migrations desde zero e validadores A/B quando Docker/Podman estiver disponível |
| P2 | Regra de SPA depende do host | Configurar rewrite de rotas para `index.html` no provedor real de deploy |
| P3 | Sem observabilidade externa | Integrar rastreamento de erros com remoção de PII antes de ampliar tráfego |

Não há P0 nem P1 em aberto.

## Multi-Certification Debt

O produto permanece deliberadamente específico para AZ-900. Antes de adicionar outra certificação, será necessário externalizar:

- slugs, títulos e textos AZ-900 presentes em rotas e UI;
- quantidade de Domains e respectivos pesos;
- regra de mock com 40 questões, distribuição 11/15/14 e duração de 60 minutos;
- nomes e contratos de funções/readiness específicos da certificação;
- configuração de conteúdo, banco de questões e critérios de prontidão.

Esse débito não bloqueia a produção do AZ-900 e não foi generalizado nesta etapa.

## Blockers

- P0: 0.
- P1: 0.
- Bloqueadores de release identificados: nenhum.
- Limitações de evidência local: Supabase do zero e SQL A/B não executados por ausência de runtime de containers.

## Decision

**READY** para produção do escopo AZ-900, condicionado à configuração normal do host para fallback SPA e das variáveis públicas do Supabase. Segurança, autenticação, isolamento no cliente, tratamento de erros, concorrência, regressão e build estão aprovados; não há P0/P1 aberto. Os itens P2/P3 acima devem permanecer visíveis no backlog operacional.


# Certification Academy

Plataforma visual e interativa de estudos para certificações. O AZ-900 é a primeira certificação disponível, com conteúdo, prática e acompanhamento persistidos no Supabase; o acesso às áreas internas é protegido pelo Supabase Auth.

## Stack

- React
- TypeScript
- Vite
- React Router
- Tailwind CSS
- Supabase Auth e PostgreSQL
- Zod para validação dos contratos vindos do banco
- Vitest e Testing Library

## Executar localmente

Requisitos: Node.js 18.18 ou superior, pnpm e um projeto no Supabase.

```bash
pnpm install
Copy-Item .env.example .env.local
pnpm dev
```

Preencha `.env.local` antes de iniciar:

```env
VITE_SUPABASE_URL=https://SEU_PROJECT_REF.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=SUA_CHAVE_PUBLICA
```

Use apenas a chave pública/publishable (ou a chave `anon` legada) no frontend. Nunca use `service_role` ou uma chave secreta. O Vite exibirá o endereço local no terminal, normalmente `http://localhost:5173`.

## Scripts

```bash
pnpm dev        # servidor de desenvolvimento
pnpm test:run   # suíte de testes em execução única
pnpm typecheck  # verificação de tipos
pnpm lint       # análise estática
pnpm build      # build de produção
pnpm preview    # prévia do build de produção
pnpm supabase   # CLI versionada do Supabase
```

## Escopo atual

O modelo de conteúdo segue `Certification → Domain → Topic → Lesson`. A plataforma já inclui:

- cadastro, login e rotas protegidas;
- progresso por aula e a área **Estudar hoje**;
- quizzes por aula e tópico, pontuação e revisão de erros;
- flashcards com histórico e repetição espaçada;
- experiências visuais interativas vinculadas às aulas;
- blocos ordenados de conteúdo por aula, com renderers para texto, imagens, vídeos, laboratórios e experiências visuais;
- fallback para o conteúdo legado de uma aula que ainda não foi convertida em blocos.

Os blocos especiais são opcionais: uma aula pode usar somente os tipos necessários ao seu objetivo pedagógico. O texto principal permanece em campos textuais pesquisáveis, enquanto `config` guarda apenas dados estruturados próprios de cada tipo. Os contratos são validados no cliente e continuam serializáveis para integrações futuras.

IA, Story Mode, Regions e simuladores avançados ainda não fazem parte do escopo implementado.

## Migrations do banco

As alterações reproduzíveis estão em `supabase/migrations`. Para associar o repositório ao projeto remoto e aplicar somente migrations pendentes:

```bash
pnpm supabase login
pnpm supabase link --project-ref SEU_PROJECT_REF
pnpm db:push:dry-run
pnpm db:push
```

O `project-ref` é o trecho anterior a `.supabase.co` em `VITE_SUPABASE_URL`. O comando `db:push` registra a migration em `supabase_migrations.schema_migrations` e não reaplica migrations já executadas.

Após o push, verifique no **Table Editor** as tabelas de currículo (`certifications`, `domains`, `topics` e `lessons`) e as fundações de estudo (`user_lesson_progress`, `questions`, `quiz_attempts`, `flashcards`, `flashcard_reviews`, `visual_experiences` e `lesson_content_blocks`). As migrations incluem constraints, índices e políticas RLS; preserve a ordem e nunca renomeie uma migration já aplicada.

## Configuração do Supabase

No painel do projeto:

1. Em **Authentication > Providers > Email**, mantenha o provedor de email habilitado.
2. Decida se **Confirm email** ficará habilitado. A interface suporta os dois fluxos.
3. Em **Authentication > URL Configuration**, defina como Site URL o endereço exibido pelo Vite (normalmente `http://localhost:5173`) e inclua esse mesmo endereço entre as Redirect URLs. Se o Vite usar outra porta ou `127.0.0.1`, cadastre também a origem exata em uso.
4. Em produção, substitua o endereço local pelo domínio real e use URLs de redirecionamento exatas.

Depois de alterar as variáveis de ambiente, reinicie o servidor Vite.

## Teste manual da autenticação

1. Acesse `/register`, valide os campos e crie uma conta.
2. Se a confirmação de email estiver ativa, abra o link recebido e depois faça login.
3. Acesse uma rota interna diretamente, recarregue a página e confirme que a sessão permanece ativa.
4. Clique em **Sair** e confirme o redirecionamento para `/login`.
5. Tente acessar novamente uma rota interna e confirme que ela continua protegida.

## Arquitetura de certificações

- O catálogo vem da tabela `public.certifications`; não há catálogo mockado paralelo.
- O contrato `Certification` está em `src/types/certification.ts`.
- Os contratos de conteúdo estão em `src/types/content.ts`.
- O contrato discriminado dos blocos está em `src/types/lessonContentBlock.ts`.
- As queries estão centralizadas em `src/services/certificationService.ts`.
- A leitura e validação dos blocos passa por `src/services/lessonContentBlockService.ts` e `src/lib/lessonContentBlockValidation.ts`.
- `LessonContentRenderer` escolhe entre os blocos publicados e o fallback legado; `LessonContentBlockRenderer` despacha cada tipo para seu renderer especializado.
- A URL é a fonte da certificação ativa.
- O contexto resolve e valida a certificação pelo campo `code` no Supabase.
- As páginas internas seguem `/certifications/:certificationCode/:section`.

Para disponibilizar outra certificação, insira um registro em `certifications`, relacione seus domínios, tópicos e lessons por UUID e, quando o conteúdo estiver pronto, defina `is_enabled = true`. Nenhuma nova tabela ou rota é necessária.

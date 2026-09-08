# Multi-Certification Hardcode Inventory

Auditoria somente leitura da Etapa 14.1 sobre a baseline `9e35c01b6bfbb910d98ed43e6fc4d3eb1fb60759`. O inventário diferencia infraestrutura já reutilizável, acoplamentos que precisam ser removidos dos engines, valores que devem continuar específicos por certificação, conteúdo deliberadamente específico e itens fora do escopo imediato.

## Classificações

- `ALREADY_GENERIC`: pode atender AZ-900 e AZ-204 sem ramificação por código.
- `MUST_GENERALIZE`: acoplamento de runtime ou contrato que impede uma segunda certificação.
- `CONFIG_ONLY`: valor legitimamente específico que deve ser resolvido por configuração, não universalizado.
- `KEEP_SPECIFIC`: conteúdo, validação editorial ou documentação pertencente ao AZ-900.
- `DEFER`: evolução possível, mas desnecessária para provar a arquitetura com o AZ-204 vazio.

## Inventário

| File | Symbol | Current Assumption | Classification | AZ-204 Impact | Action |
|---|---|---|---|---|---|
| `src/types/certification.ts` | `Certification` | Identidade contém `id`, `code`, `name`, `provider`, descrição, nível, disponibilidade e ordem. | ALREADY_GENERIC | O modelo representa qualquer certificação. | Preservar; runtime config deve ser um contrato separado. |
| `src/services/certificationService.ts` | `getCertifications`, `getCertificationByCode` | Catálogo e resolução usam dados, não listas TypeScript de códigos. | ALREADY_GENERIC | AZ-204 já pode ser descoberto pelo código cadastrado. | Preservar. |
| `src/contexts/CertificationProvider.tsx` | `CertificationProvider` | Contexto propaga a certificação resolvida e cria progresso com seu ID. | ALREADY_GENERIC | Toda a subárvore recebe escopo explícito. | Preservar e futuramente anexar config resolvida ao contexto. |
| `src/App.tsx`, `src/lib/routes.ts` | rotas `:certificationCode` e helpers | As mesmas rotas atendem qualquer código. | ALREADY_GENERIC | Não exige árvore de rotas AZ-204. | Preservar URLs AZ-900 e aplicar capabilities por guard, não duplicar rotas. |
| `src/services/certificationService.ts` | `getCertificationContent` | Currículo é carregado por `certification_id` pela cadeia Domain → Topic → Lesson. | ALREADY_GENERIC | Currículos coexistem sem query global. | Preservar. |
| `src/lib/studyPath.ts` | `flattenStudyPath` | Ordem vem dos arrays já ordenados do currículo. | ALREADY_GENERIC | Quantidade e nomes de Domains não importam. | Preservar. |
| `src/lib/progressUtils.ts` | `calculateCertificationProgress` | Totais, minutos e progresso por Domain são derivados do currículo recebido. | ALREADY_GENERIC | Progresso AZ-204 fica isolado pelos Lesson IDs do currículo atual. | Preservar. |
| `src/lib/studyProgression.ts` | `resolveStudyProgression` | Progressão usa ordem, conclusão de Lesson e Checkpoint, sem código AZ-900. | ALREADY_GENERIC | O resolver funciona para qualquer topologia linear de Domains/Topics/Lessons. | Preservar e manter testes parametrizados. |
| `supabase/migrations/20260831010000_enforce_progressive_unlocking.sql` | guards de Lesson e Topic | Disponibilidade é derivada das relações curriculares e de `auth.uid()`. | ALREADY_GENERIC | Deep links AZ-204 obedecem a mesma sequência. | Preservar; adicionar regressão multi-certificação antes de habilitar o shell. |
| `src/pages/StudyTodayPage.tsx` | `buildDailyStudyPlan` + `nextAction` | Próxima ação vem do currículo/progresso/checkpoint atuais. | ALREADY_GENERIC | Não conhece nomes ou contagens AZ-900. | Preservar; CTA de Mock deverá respeitar capability. |
| `public.quiz_attempts`, `quiz_attempt_questions`, `quiz_answers` | persistência de Quiz | Attempt possui `user_id`, `certification_id`, tipo e alvo; perguntas são associadas ao attempt. | ALREADY_GENERIC | Lesson Quiz, Checkpoint e Review podem coexistir por certificação. | Preservar IDs e histórico. |
| `src/services/quizService.ts` | serviços de Quiz | Start/load/answer/result usam IDs e RPCs comuns. | ALREADY_GENERIC | A camada cliente não exige funções `startAz204...`. | Preservar; injetar policy apenas no start do Checkpoint. |
| `public.flashcards`, `flashcard_reviews`, `user_flashcard_progress` | persistência de Flashcards | Cards pertencem a Lessons; estado pertence a usuário + card. | ALREADY_GENERIC | Relação curricular determina a certificação sem coluna duplicada. | Preservar. |
| `src/services/flashcardService.ts`, `20260831020000_add_flashcards_experience.sql`, `20260901020000_fix_flashcard_review_overview.sql` | catálogo, disponibilidade, fila e overview | RPCs recebem `p_certification_id`; disponibilidade segue Lesson progress. | ALREADY_GENERIC | `/az-204/flashcards` não mistura cards AZ-900. | Preservar e testar empty state/isolamento. |
| `src/services/reviewService.ts`, `20260823040000_add_error_review.sql` | `getQuestionReviewStats`, `start_review_quiz` | Stats e tentativas filtram usuário, attempt e `p_certification_id`. | ALREADY_GENERIC | Usuário em AZ-204 não recebe erros AZ-900. | Preservar e acrescentar teste A/B entre certificações. |
| `public.mock_exam_attempts`, `mock_exam_attempt_questions`, `mock_exam_answers` | persistência e snapshots | Attempts têm usuário/certificação; perguntas, opções, respostas e taxonomia são congeladas. | ALREADY_GENERIC | O storage aceita qualquer certificação mesmo com selector atual específico. | Preservar snapshots como autoridade histórica. |
| `src/services/mockExamService.ts` | lifecycle do Mock | API cliente usa certification/attempt IDs e valida payloads, sem selector por código. | ALREADY_GENERIC | Resume, answer, submit, result, review e history são reutilizáveis. | Preservar; resolver config antes do start. |
| `supabase/migrations/20260830076000_add_readiness_evidence_contract.sql` | `get_readiness_evidence` | Coleta assessments/learning por usuário e `p_certification_id`. | ALREADY_GENERIC | Evidência de AZ-900 e AZ-204 permanece separada. | Preservar o coletor e suas fontes legadas. |
| `src/services/readinessService.ts` | `getReadinessEvidenceBundle`/taxonomia | Bundle e taxonomia são construídos do currículo e evidência da certificação informada. | ALREADY_GENERIC | O input do algoritmo já é multi-certificação. | Separar o wrapper AZ-900 do coletor genérico. |
| `src/types/lessonContentBlock.ts`, `LessonContentBlockRenderer.tsx` | renderer de blocos | Dispatch ocorre por tipo de bloco, não por certificação. | ALREADY_GENERIC | AZ-204 reutiliza explanation, example, tip, trap, summary, image, video e visual. | Preservar. |
| `src/types/visualExperience.ts`, `VisualExperienceRenderer.tsx` | renderer visual | Comparison, architecture, flow e responsibility são data-driven. | ALREADY_GENERIC | Visuais AZ-204 podem ser conteúdo, sem plugin por certificação. | Preservar. |
| policies RLS de progress/quiz/flashcard/mock | owner checks e relações | Dados do usuário usam `auth.uid()`; conteúdo é leitura autenticada. | ALREADY_GENERIC | Não há policy com `certification.code = 'az-900'`. | Preservar e validar escopo relacional em fixtures multi-certificação. |
| `lessons_topic_slug_unique` + `findLessonStudyContext` | resolução de Lesson por slug | Banco garante slug somente por Topic; URL resolve o primeiro slug dentro da certificação. | MUST_GENERALIZE | Mesmo slug entre AZ-900/AZ-204 é seguro, mas duplicidade entre Topics da mesma certificação é ambígua. | Antes de conteúdo AZ-204, garantir unicidade por certificação via validação/schema ou incluir Topic/ID na rota, preservando redirects. |
| `20260901010000_improve_topic_quiz_checkpoint_selection.sql` | `calculate_topic_checkpoint_size` | Helper recebe apenas counts e embute faixas 1–3/4–5/6+ e 12/15/20. | MUST_GENERALIZE | AZ-204 não consegue selecionar outra estratégia sem copiar o RPC. | Fazer o selector genérico receber/resolver policy versionada e autoritativa. |
| `20260901010000_improve_topic_quiz_checkpoint_selection.sql` | `start_topic_quiz_unchecked` | Elegibilidade fixa `single_choice` e dificuldade 30/50/20. | MUST_GENERALIZE | Regras diferentes exigiriam editar o engine global. | Separar algoritmo comum de `eligibleQuestionTypes`, difficulty mix e coverage policy. |
| `20260830061000_add_mock_eligibility_and_selection.sql` | `start_mock_exam_internal` | Recusa qualquer certificação cujo código não seja `az-900`. | MUST_GENERALIZE | Start AZ-204 falha imediatamente. | Resolver policy habilitada por certification ID; remover guard por código após paridade AZ-900. |
| `20260830061000_add_mock_eligibility_and_selection.sql` | selector do Mock | Exige três Domains, itera 40 vezes e associa targets pela `display_order`. | MUST_GENERALIZE | Topologia ou tamanho AZ-204 diferente não pode ser representado. | Ler allocations por Domain ID e validar soma/taxonomia antes de selecionar. |
| `20260830072000_add_mock_timer_and_history.sql` | `mock_exam_time_limit_seconds` | Retorna 3600 globalmente. | MUST_GENERALIZE | Todas as certificações herdariam 60 minutos. | Congelar no attempt o tempo da policy resolvida. |
| `src/components/mockExam/MockExamStart.tsx`, páginas de Mock | títulos/copy AZ-900 | UI nomeia AZ-900 e “três Domains” diretamente. | MUST_GENERALIZE | AZ-204 exibiria identidade e descrição erradas. | Derivar código/nome e metadados de config/contexto. |
| `src/features/readiness/readinessEngine.ts`, serviços/hooks/types | `calculateAz900Readiness` e nomes `Az900...` | Algoritmo aceita config, mas wrappers e default apontam sempre para AZ-900. | MUST_GENERALIZE | Readiness AZ-204 usaria tuning AZ-900 silenciosamente. | Expor `calculateCertificationReadiness(bundle, config)` sem default implícito; manter alias compatível temporário. |
| `src/features/readiness/studyRecommendationEngine.ts` | imports diretos de `AZ900_READINESS_CONFIG` | Recency, safeguards e Domain weights ignoram a config passada ao recommendation engine. | MUST_GENERALIZE | Recomendações AZ-204 ficariam parcialmente calibradas pelo AZ-900. | Injetar ReadinessConfig junto da RecommendationConfig. |
| `src/data/navigation.ts`, `src/App.tsx`, `StudyTodayPage.tsx` | todas as features sempre expostas | Mock, Readiness, Flashcards e Review não têm capability guard. | MUST_GENERALIZE | Um shell habilitado expõe rotas sem config/banco suficiente. | Introduzir conjunto pequeno de capabilities e guards/empty states. |
| `src/features/readiness/readinessPresentation.ts` | texto forte menciona AZ-900 | Uma mensagem de classificação é específica. | MUST_GENERALIZE | UI AZ-204 exibiria AZ-900. | Passar identidade formatada ou usar texto neutro. |
| `20260901010000_improve_topic_quiz_checkpoint_selection.sql` | faixas 1–3 → 12, 4–5 → 15, 6+ → 20 | Tamanho pedagógico é tuning AZ-900 V2. | CONFIG_ONLY | Não deve virar regra universal. | Registrar como `az900-checkpoint-v1`; validar ordem, limites e pool clamp. |
| `20260901010000_improve_topic_quiz_checkpoint_selection.sql` | coverage/unseen/least-recent + difficulty mix | Coverage e rotação são genéricos; pesos e precedência são uma policy. | CONFIG_ONLY | AZ-204 pode precisar outro mínimo ou elegibilidade. | Manter kernel, versionar policy e tornar somente os parâmetros comprovadamente variáveis configuráveis. |
| `src/types/mockExam.ts` | `AZ900_PRACTICE_MOCK_CONFIGURATION` | UI declara 40 questões, 60 minutos e `az900-mock-v1`. | CONFIG_ONLY | Valores não podem ser compartilhados implicitamente. | Mover para runtime config AZ-900, mantendo equivalência exata. |
| `20260830061000_add_mock_eligibility_and_selection.sql` | allocations 11/15/14 e 12/20/8 | Distribuições são específicas ao blueprint AZ-900. | CONFIG_ONLY | AZ-204 possui Domains/objetivos diferentes. | Persistir policy/allocations normalizados e referenciar Domain IDs reais. |
| `src/features/readiness/readinessConfig.ts` | `AZ900_READINESS_CONFIG` | Pesos de fonte/Domain, evidência, recency, safeguards e thresholds são tuning AZ-900. | CONFIG_ONLY | Não há calibração válida automática para AZ-204. | Preservar como `az900-readiness-v1` em registry tipado. |
| `src/features/readiness/studyRecommendationConfig.ts` | `AZ900_STUDY_RECOMMENDATION_CONFIG` | Limites, disponibilidade e scores são tuning AZ-900. | CONFIG_ONLY | Recomendações AZ-204 não devem herdar mínimo de 40 mock questions. | Resolver config versionada por certificação. |
| `src/services/flashcardService.ts` | fila 20/dia e 5 novos | Limites são política de produto atualmente global. | CONFIG_ONLY | Pode continuar comum inicialmente, mas não deve ser inferido como universal. | Manter default de plataforma até surgir necessidade real; permitir promoção futura para config sem ramificações. |
| `src/types/quiz.ts` | thresholds Review 70/60/30 | Limiares de apresentação/remediação são globais hoje. | CONFIG_ONLY | Podem ser mantidos inicialmente, mas precisam de decisão explícita. | Tratar como default de plataforma; versionar apenas se a pedagogia AZ-204 divergir. |
| `supabase/migrations/20260822183000_define_complete_az900_curriculum.sql` e enrichments | Domains/Topics/Lessons AZ-900 | Taxonomia e conteúdo pertencem ao exame AZ-900. | KEEP_SPECIFIC | Não devem ser convertidos em DSL genérica. | Manter migrations editoriais específicas. |
| migrations `import_questions*` e `audit_az900_question_editorial_quality.sql` | Questions/options AZ-900 | Banco de questões e revisão editorial são conteúdo AZ-900. | KEEP_SPECIFIC | AZ-204 terá seu próprio conteúdo/UUIDs. | Preservar e adicionar migrations separadas quando autorizado. |
| migrations `import_flashcards*` e `align_flashcards_with_lesson_content.sql` | Flashcards AZ-900 | Cards e consistência são conteúdo AZ-900. | KEEP_SPECIFIC | AZ-204 terá catálogo próprio. | Preservar. |
| `supabase/tests/validate_az900_*.sql` | validators de release/conteúdo | Assertions deliberadamente conhecem 3 Domains, 12 Topics e inventário AZ-900. | KEEP_SPECIFIC | Generalizá-las enfraqueceria o regression contract. | Manter; criar validadores genéricos adicionais, não substituir os específicos. |
| `docs/az900-*.md` | documentação editorial/release | Registra decisões e baseline AZ-900. | KEEP_SPECIFIC | É evidência histórica, não runtime. | Congelar. |
| `20260830061000_add_mock_eligibility_and_selection.sql` | bootstrap de `mock_eligible` AZ-900 | Classificação A/B e filtros editoriais foram aplicados ao banco AZ-900. | KEEP_SPECIFIC | Elegibilidade AZ-204 precisa de auditoria própria. | Não transformar os critérios editoriais atuais em lei universal. |
| `src/types/lessonContentBlock.ts` | `dotnet_example`, `azure_lab` | Tipos são reutilizáveis em Azure; seu conteúdo é específico por Lesson. | KEEP_SPECIFIC | AZ-204 pode aproveitar ambos sem duplicar renderer. | Manter tipos comuns e dados específicos. |
| `src/types/question.ts`, schema/validators | apenas `single_choice` | Todos os engines e snapshots suportam um tipo. | DEFER | Não bloqueia o empty shell, mas limita experiências práticas futuras. | Projetar tipos novos somente após requisitos reais e sem alterar histórico. |
| `azure_lab` | Labs interativos/guiados | Existe bloco instrucional, não um subsistema de execução de Lab. | DEFER | AZ-204 pode se beneficiar, mas não é requisito da fundação. | Manter fora de 14.2–14.7; capability `labs` só quando houver produto definido. |
| produto | Story Mode / Map | Não existem contratos atuais. | DEFER | Nenhum impacto no suporte básico AZ-204. | Não criar abstrações preventivas. |
| produto | sandbox Azure interativo | Não há segurança, provisionamento ou lifecycle definidos. | DEFER | Alto escopo e risco independentes de multi-certificação. | Tratar em iniciativa futura própria. |

## Resumo quantitativo

| Classification | Count |
|---|---:|
| ALREADY_GENERIC | 22 |
| MUST_GENERALIZE | 11 |
| CONFIG_ONLY | 8 |
| KEEP_SPECIFIC | 7 |
| DEFER | 4 |
| **Total** | **52** |

## Blockers reais para habilitar AZ-204

1. O selector SQL do Mock rejeita códigos diferentes de `az-900` e contém topologia/alocações fixas.
2. O Checkpoint não resolve policy por certificação; sizing, tipos elegíveis e mix de dificuldade estão no SQL global.
3. Readiness e Recommendations têm wrappers/defaults/imports diretos AZ-900, o que produziria cálculo válido sintaticamente, porém semanticamente incorreto.
4. Navegação e rotas não possuem capability guard; habilitar um shell exporia engines ainda não configurados.
5. A rota de Lesson precisa de garantia de slug não ambíguo dentro de uma certificação antes da entrada de um segundo currículo.

Não foi encontrada query global capaz de misturar Review ou Flashcards entre AZ-900 e AZ-204. Esses fluxos já recebem `p_certification_id` e combinam o escopo com o proprietário autenticado.

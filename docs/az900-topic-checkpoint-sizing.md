# AZ-900 Topic Checkpoint — cobertura e tamanho dinâmico

## Escopo

Esta etapa aprimora somente o Topic Checkpoint da AZ-900. Ela não altera Lesson Quiz, Review Quiz, Practice Mock, Readiness, pesos do exame ou outras certificações.

Pré-requisito confirmado: `AZ-900 Topic Checkpoint + Progressive Unlocking: READY`, com P0 = 0 e P1 = 0.

## Regra de tamanho

O tamanho de uma nova tentativa é calculado no PostgreSQL por `calculate_topic_checkpoint_size(lesson_count, pool_count)`:

| Aulas publicadas no tópico | Alvo da tentativa |
| ---: | ---: |
| 1–3 | 12 questões |
| 4–5 | 15 questões |
| 6 ou mais | 20 questões |

O resultado é limitado ao pool elegível publicado. Um tópico sem aula ou sem questão elegível continua indisponível. Tentativas ativas existentes são snapshots imutáveis: uma tentativa legada de 10 questões é retomada com as mesmas 10 questões.

## Cobertura pedagógica

A seleção reserva primeiro uma questão para cada aula publicada que possua ao menos uma questão elegível. Aulas com pool pequeno participam normalmente; uma aula sem questões não impede o Checkpoint. Depois da cobertura, as vagas restantes são distribuídas de forma equilibrada entre as aulas.

Questões ligadas diretamente ao tópico, sem aula, entram apenas como pool residual. Questões de outro tópico, não publicadas, de outro tipo ou ligadas a aula não publicada são excluídas.

## Rotação e dificuldade

Dentro da cobertura e do balanceamento, a ordem de preferência é:

1. questões nunca vistas pelo aluno;
2. questões fora da tentativa imediatamente anterior;
3. questões vistas há mais tempo;
4. dificuldade como melhor esforço;
5. ordem editorial estável como desempate.

A distribuição de dificuldade mantém a intenção existente de 30% fáceis, 50% médias e 20% difíceis. Os alvos resultantes são 4/6/2 para 12 questões, 5/7/3 para 15 e 6/10/4 para 20. Em retakes com pool restrito, cobertura e rotação têm prioridade sobre uma composição exata de dificuldade.

Não há duplicatas dentro da mesma tentativa.

## Inventário real da AZ-900

| Tópico | Aulas publicadas | Pool elegível | Antes | Novo alvo | Aulas representáveis |
| --- | ---: | ---: | ---: | ---: | ---: |
| Cloud Computing | 7 | 72 | 10 | 20 | 7 |
| Benefits of Cloud Services | 7 | 61 | 10 | 20 | 7 |
| Cloud Service Types | 4 | 20 | 10 | 15 | 4 |
| Core Architectural Components | 7 | 42 | 10 | 20 | 7 |
| Compute Services | 9 | 51 | 10 | 20 | 9 |
| Networking Services | 5 | 30 | 10 | 15 | 5 |
| Storage Services | 8 | 46 | 10 | 20 | 8 |
| Identity, Access, and Security | 9 | 50 | 10 | 20 | 9 |
| Cost Management | 4 | 30 | 10 | 15 | 4 |
| Governance and Compliance | 3 | 15 | 10 | 12 | 3 |
| Resource Management and Deployment | 7 | 55 | 10 | 20 | 7 |
| Monitoring | 6 | 40 | 10 | 20 | 6 |

Distribuição: 1 tópico com 12 questões, 3 com 15 e 8 com 20. Nenhum tópico possui pool abaixo do alvo e nenhuma aula publicada está sem questões elegíveis; portanto, a cobertura de todas as aulas é viável nos 12 tópicos.

## Contratos e compatibilidade

- `start_topic_quiz(uuid)` permanece como contrato público autenticado e como barreira de progressive unlocking.
- `start_topic_quiz_unchecked(uuid)` permanece interno e concentra a seleção server-side.
- `get_topic_quiz_summaries(uuid)` passa a retornar `target_question_count`, além do tamanho do pool e do total real de uma tentativa ativa.
- O limite de `quiz_attempts.total_questions` passa de 10 para 20; nenhuma linha histórica é reescrita.
- A UI não replica as faixas 12/15/20. Ela apresenta o alvo calculado pelo banco ou, ao retomar uma tentativa, seu `total_questions` persistido.
- O mecanismo de tentativa ativa única e a recuperação após concorrência continuam preservados.

## Experiência após o resultado

Ao concluir um Topic Checkpoint que não seja o último, o resultado oferece a ação primária **Ir para a próxima aula**. O destino é derivado da ordem canônica da trilha, inclusive na passagem entre domínios. O acesso continua protegido pela validação de progressive unlocking já existente; o botão não cria um atalho de autorização.

No último tópico, a ação não é exibida porque não existe próxima aula. A opção de refazer o Checkpoint permanece disponível em todos os casos.

## Validação automatizada

A migration `20260901010000_improve_topic_quiz_checkpoint_selection.sql` contém assertivas transacionais que cobrem:

- todas as faixas de tamanho e limite pelo pool;
- os 12 tópicos reais da AZ-900;
- quantidade exata e ausência de duplicatas;
- cobertura de todas as aulas quando viável;
- balanceamento entre aulas;
- isolamento por tópico e elegibilidade;
- repetição idempotente de uma tentativa ativa;
- retake de 15 questões sem sobreposição em pool de 30;
- terceira tentativa de 20 questões com cobertura completa, ao menos 13 inéditas e repetição somente quando necessária para representar uma aula de pool já esgotado;
- retomada intacta de tentativa legada ativa com 10 questões.

Os fixtures do validador são executados dentro de uma transação e descartados por `rollback`.

Os testes de interface cobrem a exibição do alvo calculado, a preservação do total real legado e a navegação para a próxima aula no mesmo domínio ou no domínio seguinte.

## Critérios de aceite

- P0: 0
- P1: 0
- Tamanho, cobertura e rotação possuem uma única fonte de verdade no banco.
- A UI não contém limite fixo de 10 para novos Checkpoints.
- Tentativas históricas ou ativas não mudam de tamanho.
- Não há alteração de escopo em Mock Exam ou Readiness.

Status condicionado à aplicação e à execução bem-sucedida dos gates: `AZ-900 Topic Checkpoint Coverage + Sizing: READY`.

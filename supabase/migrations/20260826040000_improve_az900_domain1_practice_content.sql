begin;

do $$
declare
  domain_flashcards integer;
  domain_questions integer;
begin
  select count(*)
  into domain_flashcards
  from public.flashcards flashcard
  join public.lessons lesson on lesson.id = flashcard.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and flashcard.is_published;

  select count(*)
  into domain_questions
  from public.questions question
  join public.lessons lesson on lesson.id = question.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and question.is_published;

  if domain_flashcards <> 84 or domain_questions <> 133 then
    raise exception 'Unexpected Domain 1 practice baseline: flashcards %, questions %',
      domain_flashcards, domain_questions;
  end if;
end;
$$;

create temporary table flashcard_correction_seed (
  id uuid primary key,
  front_text text not null,
  back_text text not null,
  hint text
) on commit drop;

insert into flashcard_correction_seed values
  ('71000000-0000-4000-8000-000000000001',
   'Como cloud computing difere de um datacenter on-premises?',
   'Na nuvem, recursos podem ser provisionados como serviço. On-premises exige que a organização opere sua infraestrutura física.',
   'Compare provisionamento e operação.'),
  ('71000000-0000-4000-8000-000000000004',
   'O que significa pay-as-you-go?',
   'O custo acompanha as unidades de recurso consumidas segundo o modelo de preço do serviço.',
   'Consumo não elimina planejamento nem todos os compromissos.'),
  ('71000000-0000-4000-8000-000000000005',
   'Quem continua responsável por dados e identidades nos modelos de serviço?',
   'O cliente mantém responsabilidades sobre seus dados, identidades e acessos, inclusive em SaaS.',
   null),
  ('71000000-0000-4000-8000-000000000007',
   'Quem administra o sistema operacional em PaaS?',
   'O cloud provider. O cliente continua responsável pela aplicação, pelos dados, acessos e configurações sob seu controle.',
   null),
  ('71000000-0000-4000-8000-000000000011',
   'Qual possível desvantagem de uma private cloud?',
   'Ela pode exigir mais operação e capacidade dedicada que a public cloud, mesmo quando hospedada por terceiros.',
   'Private cloud não significa necessariamente servidor local.'),
  ('71000000-0000-4000-8000-000000000014',
   'Qual modelo integra uma aplicação no Azure a um banco legado local?',
   'Hybrid cloud, pois conecta ambientes públicos e privados ou locais.',
   null),
  ('71000000-0000-4000-8000-000000000015',
   'Por que public cloud pode ajudar em cargas variáveis?',
   'Ela permite ajustar capacidade rapidamente e relacionar custo ao consumo, reduzindo capacidade ociosa.',
   null),
  ('71000000-0000-4000-8000-000000000019',
   'Desligar um recurso sempre elimina toda a cobrança?',
   'Não. A cobrança depende do serviço; armazenamento, endereços ou capacidade reservada podem continuar gerando custo.',
   'Remover ou desalocar recursos pode ter efeitos diferentes.'),
  ('71000000-0000-4000-8000-000000000021',
   'Qual é a diferença conceitual entre CapEx e OpEx?',
   'CapEx é investimento antecipado em ativos; OpEx é despesa operacional recorrente.',
   null),
  ('71000000-0000-4000-8000-000000000024',
   'Consumir Azure é sempre classificado como OpEx?',
   'É predominantemente associado a OpEx, mas a classificação depende do contrato e das práticas contábeis da organização.',
   null),
  ('71000000-0000-4000-8000-000000000025',
   'O que é serverless computing?',
   'É um modelo em que o provider abstrai e administra os servidores, enquanto o cliente cuida do código, dos dados e das configurações.',
   null),
  ('71000000-0000-4000-8000-000000000031',
   'Como redundância ajuda na alta disponibilidade?',
   'Ela permite que outro componente continue atendendo quando uma instância falha ou entra em manutenção.',
   null),
  ('71000000-0000-4000-8000-000000000034',
   'Qual limite comum existe no scale up?',
   'Uma única instância possui um tamanho máximo disponível; scale out distribui a carga entre mais instâncias.',
   null),
  ('71000000-0000-4000-8000-000000000036',
   'O que significam scale up e scale down?',
   'Aumentar ou reduzir a capacidade de uma instância, como CPU e memória.',
   'Escala vertical muda o tamanho.'),
  ('71000000-0000-4000-8000-000000000038',
   'Como Scalability difere de Elasticity?',
   'Scalability é a capacidade de ajustar recursos; Elasticity enfatiza ajustá-los dinamicamente conforme a demanda.',
   null),
  ('71000000-0000-4000-8000-000000000043',
   'Como redundância e recuperação ajudam na Reliability?',
   'Redundância limita o impacto de uma falha; recuperação restaura a operação ou os dados.',
   null),
  ('71000000-0000-4000-8000-000000000045',
   'O que é performance predictability?',
   'É a capacidade de estimar o comportamento da solução com base em métricas, carga e dimensionamento.',
   null),
  ('71000000-0000-4000-8000-000000000046',
   'O que é cost predictability?',
   'É a capacidade de estimar e acompanhar custos usando consumo observado e modelos de preço.',
   null),
  ('71000000-0000-4000-8000-000000000047',
   'O que ajuda a prever custos de nuvem?',
   'Conhecer o modelo de preço, dimensionar recursos e acompanhar o consumo.',
   null),
  ('71000000-0000-4000-8000-000000000048',
   'Autoscaling torna o custo invariável?',
   'Não. Ele ajusta capacidade à demanda; mais demanda ainda pode aumentar o consumo e o custo.',
   null),
  ('71000000-0000-4000-8000-000000000050',
   'Certificações do provider tornam o cliente automaticamente compliant?',
   'Não. Elas apoiam a conformidade, mas o cliente ainda precisa configurar controles e cumprir seus próprios requisitos.',
   null),
  ('71000000-0000-4000-8000-000000000053',
   'O que é manageability in the cloud?',
   'É administrar e monitorar recursos na nuvem, incluindo ajustes de capacidade e automação operacional.',
   null),
  ('71000000-0000-4000-8000-000000000054',
   'Quais interfaces podem administrar recursos Azure?',
   'Portal, CLI, PowerShell, APIs e Infrastructure as Code.',
   null),
  ('71000000-0000-4000-8000-000000000056',
   'O Portal é a única forma de administrar Azure?',
   'Não. CLI, PowerShell, APIs e Infrastructure as Code também podem administrar recursos.',
   null),
  ('71000000-0000-4000-8000-000000000059',
   'Quando IaaS tende a ser adequado?',
   'Quando a carga exige controle do sistema operacional ou configurações que uma plataforma gerenciada não oferece.',
   null),
  ('71000000-0000-4000-8000-000000000069',
   'Qual modelo usar quando uma carga exige controle do sistema operacional?',
   'IaaS tende a ser adequado porque o cliente administra o sistema operacional da máquina virtual.',
   null),
  ('71000000-0000-4000-8000-000000000070',
   'Qual modelo permite publicar uma aplicação sem administrar o SO?',
   'PaaS, como Azure App Service.',
   null),
  ('71000000-0000-4000-8000-000000000071',
   'Qual modelo entrega software pronto, como e-mail corporativo?',
   'SaaS.',
   null),
  ('71000000-0000-4000-8000-000000000072',
   'O que muda de IaaS para PaaS e SaaS?',
   'O provider administra progressivamente mais da stack; o cliente administra menos camadas, mas mantém responsabilidades.',
   null);

do $$
begin
  if (select count(*) from flashcard_correction_seed) <> 29 then
    raise exception 'Expected 29 flashcard corrections';
  end if;

  if (
    select count(*)
    from public.flashcards flashcard
    join public.lessons lesson on lesson.id = flashcard.lesson_id
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and flashcard.id in (select id from flashcard_correction_seed)
  ) <> 29 then
    raise exception 'A flashcard correction target is outside Domain 1 or missing';
  end if;
end;
$$;

update public.flashcards flashcard
set front_text = seed.front_text,
    back_text = seed.back_text,
    hint = seed.hint
from flashcard_correction_seed seed
where flashcard.id = seed.id;

create temporary table question_correction_seed (
  id uuid primary key,
  question_text text not null,
  difficulty text not null,
  explanation text not null
) on commit drop;

insert into question_correction_seed values
  ('62000000-0000-4000-8000-000000000079',
   'Uma API usa duas instâncias. Se uma falha, a outra continua atendendo. Qual princípio reduz o downtime nesse cenário?',
   'medium',
   'A redundância evita que uma única instância seja um ponto único de falha e ajuda a manter a continuidade do serviço.'),
  ('62000000-0000-4000-8000-000000000080',
   'O que um SLA de disponibilidade descreve?',
   'medium',
   'Um SLA expressa o compromisso de disponibilidade do serviço, normalmente como percentual e sob condições definidas; não promete zero downtime.'),
  ('64000000-0000-4000-8000-000000000006',
   'Qual fator é importante ao escolher entre IaaS, PaaS e SaaS?',
   'easy',
   'A escolha equilibra o controle necessário sobre a stack e a responsabilidade operacional que a equipe pode assumir.');

update public.questions question
set question_text = seed.question_text,
    difficulty = seed.difficulty,
    explanation = seed.explanation
from question_correction_seed seed
where question.id = seed.id;

create temporary table option_correction_seed (
  id uuid primary key,
  option_text text not null,
  explanation text not null
) on commit drop;

insert into option_correction_seed values
  ('73000000-0000-4000-8000-000000000037', 'Manter on-premises sempre custa menos quando há poucos usuários.', 'Incorreta. Quantidade de usuários isoladamente não determina o custo total.'),
  ('73000000-0000-4000-8000-000000000038', 'Migrar para a nuvem sempre reduz o custo, independentemente do padrão de uso.', 'Incorreta. O custo depende do consumo, da arquitetura e da operação.'),
  ('73000000-0000-4000-8000-000000000040', 'Escolher apenas pelo número de usuários, ignorando consumo e requisitos técnicos.', 'Incorreta. A decisão precisa considerar consumo, custo e requisitos da carga.'),
  ('73000000-0000-4000-8000-000000000121', 'Escolher sempre public cloud porque requisitos de controle não mudam entre cargas.', 'Incorreta. Controle e conformidade podem alterar a escolha do modelo.'),
  ('73000000-0000-4000-8000-000000000123', 'Escolher sempre private cloud quando existirem dados sensíveis, sem avaliar os controles disponíveis.', 'Incorreta. Dados sensíveis não tornam private cloud uma regra automática.'),
  ('73000000-0000-4000-8000-000000000124', 'Escolher hybrid cloud somente quando o provider de public cloud estiver indisponível.', 'Incorreta. Hybrid cloud integra ambientes para atender requisitos, não é apenas contingência do provider.'),
  ('73000000-0000-4000-8000-000000000129', 'Escolher sempre o modelo com menor preço unitário, sem considerar controle ou compliance.', 'Incorreta. Preço isolado não representa todos os requisitos do cenário.'),
  ('73000000-0000-4000-8000-000000000130', 'Escolher pelo local do escritório, mesmo quando os dados e sistemas não possuem restrição de localização.', 'Incorreta. Localização só é decisiva quando afeta requisitos reais.'),
  ('73000000-0000-4000-8000-000000000131', 'Escolher private cloud sempre que a aplicação usar tecnologias Microsoft.', 'Incorreta. A tecnologia da aplicação não determina sozinha o modelo de cloud.'),
  ('73000000-0000-4000-8000-000000000169', 'A capacidade provisionada, mesmo que o serviço cobre somente unidades efetivamente usadas.', 'Incorreta. Em consumo baseado no uso, as unidades consumidas orientam a cobrança.'),
  ('73000000-0000-4000-8000-000000000170', 'Somente o número de usuários cadastrados, para qualquer tipo de recurso.', 'Incorreta. Métricas de cobrança variam por serviço e não são sempre por usuário.'),
  ('73000000-0000-4000-8000-000000000172', 'Uma mensalidade fixa que nunca muda com o uso dos recursos.', 'Incorreta. Isso não descreve cobrança proporcional ao consumo.'),
  ('73000000-0000-4000-8000-000000000249', 'Pelo número de servidores físicos que o cliente administra.', 'Incorreta. Em serverless, os servidores são abstraídos para o cliente.'),
  ('73000000-0000-4000-8000-000000000252', 'Somente por capacidade reservada, mesmo que nenhuma execução ocorra.', 'Incorreta. O modelo serverless frequentemente considera execuções e recursos consumidos.'),
  ('73000000-0000-4000-8000-000000000341', 'Scale out significa sempre adicionar CPU à mesma instância.', 'Incorreta. Adicionar CPU à mesma instância é scale up.'),
  ('73000000-0000-4000-8000-000000000342', 'Scale out sempre custa menos, qualquer que seja a arquitetura.', 'Incorreta. Custo depende da carga, do serviço e da arquitetura.'),
  ('73000000-0000-4000-8000-000000000344', 'Scale up elimina a necessidade de redundância porque a instância fica maior.', 'Incorreta. Uma instância maior ainda pode ser um ponto único de falha.'),
  ('73000000-0000-4000-8000-000000000425', 'Desativar health checks para reduzir o volume de alertas.', 'Incorreta. Isso dificulta detectar falhas rapidamente.'),
  ('73000000-0000-4000-8000-000000000427', 'Aumentar apenas o tamanho da instância, sem monitoramento ou redundância.', 'Incorreta. Mais capacidade não resolve a detecção nem todos os modos de falha.'),
  ('73000000-0000-4000-8000-000000000428', 'Remover backups e tentativas controladas para simplificar a aplicação.', 'Incorreta. Isso reduz a capacidade de recuperação.'),
  ('73000000-0000-4000-8000-000000000446', 'Disponibilidade e confiabilidade.', 'Incorreta. São benefícios relacionados, mas não as duas dimensões de predictability.'),
  ('73000000-0000-4000-8000-000000000447', 'Escalabilidade e elasticidade.', 'Incorreta. São capacidades de ajuste de recursos, não as dimensões de predictability.'),
  ('73000000-0000-4000-8000-000000000448', 'Segurança e governança.', 'Incorreta. São benefícios distintos de performance e cost predictability.'),
  ('75000000-0000-4000-8000-000000000022', 'Escolher SaaS sempre que a equipe precisar de maior controle do sistema operacional.', 'Incorreta. Controle do sistema operacional aponta para IaaS, não SaaS.'),
  ('75000000-0000-4000-8000-000000000023', 'Escolher IaaS sempre que a equipe quiser reduzir ao mínimo o gerenciamento da infraestrutura.', 'Incorreta. IaaS deixa mais camadas sob responsabilidade do cliente.'),
  ('75000000-0000-4000-8000-000000000024', 'Considerar apenas o preço, pois a divisão de responsabilidades é igual nos três modelos.', 'Incorreta. A divisão de responsabilidades muda entre IaaS, PaaS e SaaS.'),
  ('73000000-0000-4000-8000-000000000313', 'Aumentar automaticamente a capacidade durante picos de demanda.', 'Incorreta. Isso descreve elasticity, não a continuidade após falha de uma instância.'),
  ('73000000-0000-4000-8000-000000000314', 'Usar redundância para que outra instância continue atendendo.', 'Correta. A redundância reduz pontos únicos de falha e downtime.'),
  ('73000000-0000-4000-8000-000000000315', 'Trocar a aplicação por um produto SaaS para remover qualquer risco de falha.', 'Incorreta. SaaS não elimina falhas nem garante continuidade absoluta.'),
  ('73000000-0000-4000-8000-000000000316', 'Aumentar somente CPU e memória da instância que já existe.', 'Incorreta. Scale up não oferece continuidade se a única instância falhar.'),
  ('73000000-0000-4000-8000-000000000317', 'A garantia de que o serviço nunca ficará indisponível.', 'Incorreta. Nenhum SLA significa ausência absoluta de downtime.'),
  ('73000000-0000-4000-8000-000000000318', 'O volume máximo de dados que o serviço pode armazenar.', 'Incorreta. Isso é capacidade, não compromisso de disponibilidade.'),
  ('73000000-0000-4000-8000-000000000319', 'A velocidade mínima de cada requisição da aplicação.', 'Incorreta. Um SLA de disponibilidade trata de uptime nas condições definidas.'),
  ('73000000-0000-4000-8000-000000000320', 'O compromisso de disponibilidade do serviço sob condições definidas.', 'Correta. O SLA descreve o nível de serviço e suas condições.');

update public.question_options option
set option_text = seed.option_text,
    explanation = seed.explanation
from option_correction_seed seed
where option.id = seed.id;

create temporary table new_question_seed (
  id uuid primary key,
  lesson_slug text not null,
  question_text text not null,
  difficulty text not null,
  explanation text not null,
  display_order integer not null
) on commit drop;

insert into new_question_seed values
  ('66000000-0000-4000-8000-000000000001', 'infrastructure-as-a-service', 'Em IaaS, quem administra o datacenter físico, o hardware e a virtualização?', 'easy', 'O cloud provider administra essas camadas. O cliente administra o sistema operacional e as camadas superiores da máquina virtual.', 1),
  ('66000000-0000-4000-8000-000000000002', 'infrastructure-as-a-service', 'Qual serviço é um exemplo de IaaS?', 'easy', 'Azure Virtual Machines oferece infraestrutura virtualizada e deixa o sistema operacional sob administração do cliente.', 2),
  ('66000000-0000-4000-8000-000000000003', 'infrastructure-as-a-service', 'Uma aplicação exige acesso administrativo e uma versão específica do sistema operacional. Qual modelo tende a ser adequado?', 'medium', 'IaaS oferece controle do sistema operacional. PaaS administra essa camada e pode não oferecer a configuração exigida.', 3),
  ('66000000-0000-4000-8000-000000000004', 'infrastructure-as-a-service', 'Uma equipe executa uma API em uma Azure Virtual Machine. Quem deve aplicar patches no sistema operacional da VM?', 'medium', 'Em IaaS, o cliente administra o sistema operacional, incluindo patches e configurações.', 4),
  ('66000000-0000-4000-8000-000000000005', 'infrastructure-as-a-service', 'Uma empresa quer migrar uma carga legada com controle do SO sem comprar servidores físicos. Qual opção atende melhor?', 'hard', 'Azure Virtual Machines oferece IaaS: o provider mantém hardware e virtualização, enquanto o cliente controla o sistema operacional.', 5),

  ('66000000-0000-4000-8000-000000000006', 'platform-as-a-service', 'Em PaaS, em quais elementos o cliente concentra seu trabalho?', 'easy', 'O cliente se concentra principalmente na aplicação e nos dados, enquanto o provider administra mais da plataforma.', 2),
  ('66000000-0000-4000-8000-000000000007', 'platform-as-a-service', 'Qual serviço permite publicar uma aplicação web usando um ambiente PaaS?', 'medium', 'Azure App Service é PaaS. Azure Virtual Machines é IaaS, Microsoft 365 é SaaS e Virtual Network é networking.', 3),
  ('66000000-0000-4000-8000-000000000008', 'platform-as-a-service', 'Uma equipe quer publicar uma API ASP.NET Core sem administrar o sistema operacional. Qual opção tende a ser adequada?', 'medium', 'Azure App Service fornece uma plataforma gerenciada para publicar a aplicação sem manter o SO da VM.', 4),
  ('66000000-0000-4000-8000-000000000009', 'platform-as-a-service', 'Uma aplicação exige instalar um driver não suportado pela plataforma. Qual limitação de PaaS é relevante?', 'hard', 'PaaS oferece menos controle sobre o sistema operacional. Se o driver for obrigatório, IaaS pode ser mais adequado.', 5),

  ('66000000-0000-4000-8000-000000000010', 'security-and-governance-benefits', 'Qual conjunto representa controles de cloud security?', 'easy', 'Identidade, criptografia e controles de acesso ajudam a proteger usuários, dados e recursos.', 1),
  ('66000000-0000-4000-8000-000000000011', 'security-and-governance-benefits', 'Qual é o objetivo principal de cloud governance?', 'easy', 'Governance define padrões, políticas e controles para manter recursos alinhados às regras da organização.', 2),
  ('66000000-0000-4000-8000-000000000012', 'security-and-governance-benefits', 'Um banco de dados foi exposto por uma configuração incorreta do cliente. Qual conceito explica que cloud não é automaticamente segura?', 'medium', 'Shared Responsibility: o provider protege suas camadas, mas o cliente ainda precisa configurar corretamente dados, acessos e recursos.', 3),
  ('66000000-0000-4000-8000-000000000013', 'security-and-governance-benefits', 'Uma regra exige região aprovada e identificação do centro de custo em todos os recursos. Qual benefício ela demonstra?', 'medium', 'A regra demonstra governance ao padronizar criação, localização e identificação organizacional dos recursos.', 4),
  ('66000000-0000-4000-8000-000000000014', 'security-and-governance-benefits', 'Uma regra organizacional exige criptografia para todos os dados armazenados. Ela contribui para quais conceitos?', 'medium', 'Ela contribui para governance ao impor um padrão e para security ao exigir proteção dos dados. Os conceitos podem se sobrepor.', 5),
  ('66000000-0000-4000-8000-000000000015', 'security-and-governance-benefits', 'O provider possui certificações de conformidade. O que a organização cliente ainda precisa fazer?', 'hard', 'Ela ainda deve configurar controles, governar seu uso e demonstrar que suas próprias obrigações são atendidas.', 6),

  ('66000000-0000-4000-8000-000000000016', 'manageability', 'Quais interfaces podem ser usadas para administrar recursos Azure?', 'easy', 'Portal, CLI, PowerShell, APIs e Infrastructure as Code são formas válidas de administrar recursos.', 1),
  ('66000000-0000-4000-8000-000000000017', 'manageability', 'Qual benefício principal Infrastructure as Code oferece?', 'easy', 'Ela torna a definição de infraestrutura repetível, versionável e mais consistente entre ambientes.', 2),
  ('66000000-0000-4000-8000-000000000018', 'manageability', 'Uma pessoa quer explorar visualmente um recurso; depois a equipe precisa recriar o ambiente de modo consistente. Quais abordagens combinam melhor?', 'medium', 'Portal ajuda na exploração visual; Infrastructure as Code ajuda a repetir a configuração de forma consistente.', 3),
  ('66000000-0000-4000-8000-000000000019', 'manageability', 'Uma ferramenta interna precisa criar recursos Azure programaticamente. Qual interface é apropriada?', 'medium', 'Uma API permite que outra ferramenta integre e automatize operações de gerenciamento.', 4),
  ('66000000-0000-4000-8000-000000000020', 'manageability', 'Uma equipe precisa revisar e reproduzir a mesma infraestrutura em desenvolvimento e produção. Qual abordagem tende a ser mais adequada?', 'hard', 'Infrastructure as Code permite versionar, revisar e aplicar definições repetíveis, reduzindo divergências entre ambientes.', 5);

with resolved_questions as (
  select seed.*, certification.id as certification_id, domain.id as domain_id,
    topic.id as topic_id, lesson.id as lesson_id
  from new_question_seed seed
  join public.certifications certification on certification.code = 'az-900'
  join public.domains domain
    on domain.certification_id = certification.id
   and domain.title = 'Describe cloud concepts'
  join public.topics topic
    on topic.domain_id = domain.id
  join public.lessons lesson
    on lesson.topic_id = topic.id
   and lesson.slug = seed.lesson_slug
)
insert into public.questions (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select id, certification_id, domain_id, topic_id, lesson_id, question_text,
  'single_choice', difficulty, explanation, true, display_order
from resolved_questions
on conflict (id) do update set
  certification_id = excluded.certification_id,
  domain_id = excluded.domain_id,
  topic_id = excluded.topic_id,
  lesson_id = excluded.lesson_id,
  question_text = excluded.question_text,
  question_type = excluded.question_type,
  difficulty = excluded.difficulty,
  explanation = excluded.explanation,
  is_published = excluded.is_published,
  display_order = excluded.display_order;

create temporary table new_option_seed (
  id uuid primary key,
  question_id uuid not null,
  option_text text not null,
  is_correct boolean not null,
  display_order integer not null
) on commit drop;

insert into new_option_seed values
  ('7d000000-0000-4000-8000-000000000001','66000000-0000-4000-8000-000000000001','O cloud provider.',true,1),
  ('7d000000-0000-4000-8000-000000000002','66000000-0000-4000-8000-000000000001','O cliente que criou a máquina virtual.',false,2),
  ('7d000000-0000-4000-8000-000000000003','66000000-0000-4000-8000-000000000001','A equipe que desenvolve a aplicação SaaS.',false,3),
  ('7d000000-0000-4000-8000-000000000004','66000000-0000-4000-8000-000000000001','O usuário final do sistema operacional.',false,4),
  ('7d000000-0000-4000-8000-000000000005','66000000-0000-4000-8000-000000000002','Azure Virtual Machines.',true,1),
  ('7d000000-0000-4000-8000-000000000006','66000000-0000-4000-8000-000000000002','Azure App Service.',false,2),
  ('7d000000-0000-4000-8000-000000000007','66000000-0000-4000-8000-000000000002','Microsoft 365.',false,3),
  ('7d000000-0000-4000-8000-000000000008','66000000-0000-4000-8000-000000000002','Microsoft Entra ID.',false,4),
  ('7d000000-0000-4000-8000-000000000009','66000000-0000-4000-8000-000000000003','IaaS.',true,1),
  ('7d000000-0000-4000-8000-000000000010','66000000-0000-4000-8000-000000000003','PaaS.',false,2),
  ('7d000000-0000-4000-8000-000000000011','66000000-0000-4000-8000-000000000003','SaaS.',false,3),
  ('7d000000-0000-4000-8000-000000000012','66000000-0000-4000-8000-000000000003','Consumption-based pricing.',false,4),
  ('7d000000-0000-4000-8000-000000000013','66000000-0000-4000-8000-000000000004','O cliente.',true,1),
  ('7d000000-0000-4000-8000-000000000014','66000000-0000-4000-8000-000000000004','O provider, porque toda VM é PaaS.',false,2),
  ('7d000000-0000-4000-8000-000000000015','66000000-0000-4000-8000-000000000004','O usuário final da API.',false,3),
  ('7d000000-0000-4000-8000-000000000016','66000000-0000-4000-8000-000000000004','Ninguém, porque VMs não precisam de patches.',false,4),
  ('7d000000-0000-4000-8000-000000000017','66000000-0000-4000-8000-000000000005','Azure Virtual Machines em IaaS.',true,1),
  ('7d000000-0000-4000-8000-000000000018','66000000-0000-4000-8000-000000000005','Microsoft 365 em SaaS.',false,2),
  ('7d000000-0000-4000-8000-000000000019','66000000-0000-4000-8000-000000000005','Azure App Service em PaaS, com controle total do SO.',false,3),
  ('7d000000-0000-4000-8000-000000000020','66000000-0000-4000-8000-000000000005','Um servidor físico próprio, obrigatoriamente.',false,4),

  ('7d000000-0000-4000-8000-000000000021','66000000-0000-4000-8000-000000000006','Na aplicação e nos dados.',true,1),
  ('7d000000-0000-4000-8000-000000000022','66000000-0000-4000-8000-000000000006','No datacenter físico e na virtualização.',false,2),
  ('7d000000-0000-4000-8000-000000000023','66000000-0000-4000-8000-000000000006','Somente no hardware do servidor.',false,3),
  ('7d000000-0000-4000-8000-000000000024','66000000-0000-4000-8000-000000000006','Em atualizar o software de um produto SaaS.',false,4),
  ('7d000000-0000-4000-8000-000000000025','66000000-0000-4000-8000-000000000007','Azure App Service.',true,1),
  ('7d000000-0000-4000-8000-000000000026','66000000-0000-4000-8000-000000000007','Azure Virtual Machines.',false,2),
  ('7d000000-0000-4000-8000-000000000027','66000000-0000-4000-8000-000000000007','Microsoft 365.',false,3),
  ('7d000000-0000-4000-8000-000000000028','66000000-0000-4000-8000-000000000007','Azure Virtual Network.',false,4),
  ('7d000000-0000-4000-8000-000000000029','66000000-0000-4000-8000-000000000008','Azure App Service.',true,1),
  ('7d000000-0000-4000-8000-000000000030','66000000-0000-4000-8000-000000000008','Azure Virtual Machines, porque exige manter o SO.',false,2),
  ('7d000000-0000-4000-8000-000000000031','66000000-0000-4000-8000-000000000008','Microsoft 365, porque entrega a API como software pronto.',false,3),
  ('7d000000-0000-4000-8000-000000000032','66000000-0000-4000-8000-000000000008','Private Cloud, porque toda aplicação .NET exige ambiente dedicado.',false,4),
  ('7d000000-0000-4000-8000-000000000033','66000000-0000-4000-8000-000000000009','O cliente não controla livremente o sistema operacional da plataforma.',true,1),
  ('7d000000-0000-4000-8000-000000000034','66000000-0000-4000-8000-000000000009','PaaS exige que o cliente compre o hardware físico.',false,2),
  ('7d000000-0000-4000-8000-000000000035','66000000-0000-4000-8000-000000000009','PaaS não permite publicar código de aplicação.',false,3),
  ('7d000000-0000-4000-8000-000000000036','66000000-0000-4000-8000-000000000009','PaaS sempre oferece mais controle do SO que IaaS.',false,4),

  ('7d000000-0000-4000-8000-000000000037','66000000-0000-4000-8000-000000000010','Identidade, criptografia e controle de acesso.',true,1),
  ('7d000000-0000-4000-8000-000000000038','66000000-0000-4000-8000-000000000010','Scale up, scale down e autoscaling.',false,2),
  ('7d000000-0000-4000-8000-000000000039','66000000-0000-4000-8000-000000000010','CapEx, OpEx e consumo.',false,3),
  ('7d000000-0000-4000-8000-000000000040','66000000-0000-4000-8000-000000000010','Portal, CLI e Infrastructure as Code.',false,4),
  ('7d000000-0000-4000-8000-000000000041','66000000-0000-4000-8000-000000000011','Padronizar e controlar recursos segundo regras organizacionais.',true,1),
  ('7d000000-0000-4000-8000-000000000042','66000000-0000-4000-8000-000000000011','Eliminar toda responsabilidade do cliente.',false,2),
  ('7d000000-0000-4000-8000-000000000043','66000000-0000-4000-8000-000000000011','Garantir que nenhuma falha de hardware ocorra.',false,3),
  ('7d000000-0000-4000-8000-000000000044','66000000-0000-4000-8000-000000000011','Aumentar automaticamente o número de instâncias.',false,4),
  ('7d000000-0000-4000-8000-000000000045','66000000-0000-4000-8000-000000000012','Shared Responsibility.',true,1),
  ('7d000000-0000-4000-8000-000000000046','66000000-0000-4000-8000-000000000012','Elasticity.',false,2),
  ('7d000000-0000-4000-8000-000000000047','66000000-0000-4000-8000-000000000012','Cost predictability.',false,3),
  ('7d000000-0000-4000-8000-000000000048','66000000-0000-4000-8000-000000000012','High Availability.',false,4),
  ('7d000000-0000-4000-8000-000000000049','66000000-0000-4000-8000-000000000013','Governance.',true,1),
  ('7d000000-0000-4000-8000-000000000050','66000000-0000-4000-8000-000000000013','Elasticity.',false,2),
  ('7d000000-0000-4000-8000-000000000051','66000000-0000-4000-8000-000000000013','Serverless computing.',false,3),
  ('7d000000-0000-4000-8000-000000000052','66000000-0000-4000-8000-000000000013','Vertical scaling.',false,4),
  ('7d000000-0000-4000-8000-000000000053','66000000-0000-4000-8000-000000000014','Security e Governance.',true,1),
  ('7d000000-0000-4000-8000-000000000054','66000000-0000-4000-8000-000000000014','Somente Security.',false,2),
  ('7d000000-0000-4000-8000-000000000055','66000000-0000-4000-8000-000000000014','Somente Governance.',false,3),
  ('7d000000-0000-4000-8000-000000000056','66000000-0000-4000-8000-000000000014','Scalability e Elasticity.',false,4),
  ('7d000000-0000-4000-8000-000000000057','66000000-0000-4000-8000-000000000015','Configurar controles e cumprir as obrigações da própria organização.',true,1),
  ('7d000000-0000-4000-8000-000000000058','66000000-0000-4000-8000-000000000015','Nada; a certificação transfere toda responsabilidade ao provider.',false,2),
  ('7d000000-0000-4000-8000-000000000059','66000000-0000-4000-8000-000000000015','Somente escolher uma região próxima aos usuários.',false,3),
  ('7d000000-0000-4000-8000-000000000060','66000000-0000-4000-8000-000000000015','Desativar controles próprios para não duplicar os do provider.',false,4),

  ('7d000000-0000-4000-8000-000000000061','66000000-0000-4000-8000-000000000016','Portal, CLI, PowerShell, APIs e Infrastructure as Code.',true,1),
  ('7d000000-0000-4000-8000-000000000062','66000000-0000-4000-8000-000000000016','Somente o Portal.',false,2),
  ('7d000000-0000-4000-8000-000000000063','66000000-0000-4000-8000-000000000016','Somente acesso físico ao datacenter.',false,3),
  ('7d000000-0000-4000-8000-000000000064','66000000-0000-4000-8000-000000000016','Apenas aplicativos SaaS.',false,4),
  ('7d000000-0000-4000-8000-000000000065','66000000-0000-4000-8000-000000000017','Repetibilidade, versionamento e consistência.',true,1),
  ('7d000000-0000-4000-8000-000000000066','66000000-0000-4000-8000-000000000017','Controle físico do hardware Azure.',false,2),
  ('7d000000-0000-4000-8000-000000000067','66000000-0000-4000-8000-000000000017','Eliminação de toda revisão humana.',false,3),
  ('7d000000-0000-4000-8000-000000000068','66000000-0000-4000-8000-000000000017','Garantia de custo fixo em qualquer demanda.',false,4),
  ('7d000000-0000-4000-8000-000000000069','66000000-0000-4000-8000-000000000018','Portal para explorar e Infrastructure as Code para reproduzir.',true,1),
  ('7d000000-0000-4000-8000-000000000070','66000000-0000-4000-8000-000000000018','IaaS para explorar e SaaS para reproduzir.',false,2),
  ('7d000000-0000-4000-8000-000000000071','66000000-0000-4000-8000-000000000018','Autoscaling para explorar e CapEx para reproduzir.',false,3),
  ('7d000000-0000-4000-8000-000000000072','66000000-0000-4000-8000-000000000018','Private Cloud para explorar e SLA para reproduzir.',false,4),
  ('7d000000-0000-4000-8000-000000000073','66000000-0000-4000-8000-000000000019','Uma API de gerenciamento.',true,1),
  ('7d000000-0000-4000-8000-000000000074','66000000-0000-4000-8000-000000000019','Um SLA de disponibilidade.',false,2),
  ('7d000000-0000-4000-8000-000000000075','66000000-0000-4000-8000-000000000019','Um modelo SaaS obrigatório.',false,3),
  ('7d000000-0000-4000-8000-000000000076','66000000-0000-4000-8000-000000000019','Uma compra CapEx de servidores.',false,4),
  ('7d000000-0000-4000-8000-000000000077','66000000-0000-4000-8000-000000000020','Infrastructure as Code versionada e revisada.',true,1),
  ('7d000000-0000-4000-8000-000000000078','66000000-0000-4000-8000-000000000020','Configuração manual diferente em cada ambiente.',false,2),
  ('7d000000-0000-4000-8000-000000000079','66000000-0000-4000-8000-000000000020','Escolher sempre a maior VM disponível.',false,3),
  ('7d000000-0000-4000-8000-000000000080','66000000-0000-4000-8000-000000000020','Usar apenas capturas de tela do Portal.',false,4);

insert into public.question_options (
  id, question_id, option_text, is_correct, explanation, display_order
)
select id, question_id, option_text, is_correct, null, display_order
from new_option_seed
on conflict (id) do update set
  question_id = excluded.question_id,
  option_text = excluded.option_text,
  is_correct = excluded.is_correct,
  explanation = excluded.explanation,
  display_order = excluded.display_order;

do $$
declare
  domain_flashcards integer;
  domain_questions integer;
begin
  if (select count(*) from new_question_seed) <> 20
    or (select count(*) from new_option_seed) <> 80 then
    raise exception 'Practice seed expected 20 questions and 80 options';
  end if;

  select count(*)
  into domain_flashcards
  from public.flashcards flashcard
  join public.lessons lesson on lesson.id = flashcard.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and flashcard.is_published;

  select count(*)
  into domain_questions
  from public.questions question
  join public.lessons lesson on lesson.id = question.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and question.is_published;

  if domain_flashcards <> 84 or domain_questions <> 153 then
    raise exception 'Unexpected Domain 1 practice result: flashcards %, questions %',
      domain_flashcards, domain_questions;
  end if;

  if exists (
    select 1
    from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    where lesson.slug in (
      'infrastructure-as-a-service',
      'platform-as-a-service',
      'security-and-governance-benefits',
      'manageability'
    )
    group by lesson.slug
    having count(*) filter (where question.is_published) < 5
  ) then
    raise exception 'A previously weak Lesson still has fewer than five questions';
  end if;
end;
$$;

commit;

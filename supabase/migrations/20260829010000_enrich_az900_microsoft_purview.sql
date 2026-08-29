begin;

do $$
declare
  target_count integer;
begin
  select count(*) into target_count
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure management and governance'
    and topic.id = '33000000-0000-4000-8000-000000000002'
    and topic.title = 'Governance and Compliance'
    and lesson.slug = 'microsoft-purview';

  if target_count <> 1 then
    raise exception '9.5.2 expected the existing microsoft-purview Lesson';
  end if;

  if exists (
    select 1 from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.topic_id = '33000000-0000-4000-8000-000000000002'
      and lesson.slug = 'microsoft-purview'
  ) then
    raise exception '9.5.2 expected microsoft-purview without Content Blocks';
  end if;

  if exists (
    select 1 from public.visual_experiences visual
    join public.lessons lesson on lesson.id = visual.lesson_id
    where lesson.topic_id = '33000000-0000-4000-8000-000000000002'
      and lesson.slug = 'microsoft-purview'
  ) then
    raise exception '9.5.2 must not create or reuse a Visual Experience';
  end if;

  if exists (
    select 1 from public.flashcards card
    join public.lessons lesson on lesson.id = card.lesson_id
    where lesson.topic_id = '33000000-0000-4000-8000-000000000002'
      and lesson.slug = 'microsoft-purview'
  ) or exists (
    select 1 from public.questions question
    join public.lessons lesson on lesson.id = question.lesson_id
    where lesson.topic_id = '33000000-0000-4000-8000-000000000002'
      and lesson.slug = 'microsoft-purview'
  ) then
    raise exception '9.5.2 expected microsoft-purview without existing practice';
  end if;
end; $$;

update public.lessons
set estimated_minutes = 12
where topic_id = '33000000-0000-4000-8000-000000000002'
  and slug = 'microsoft-purview';

create temporary table stage_952_block_seed (
  id uuid primary key,
  type text not null,
  title text,
  content text,
  config jsonb,
  display_order integer not null
) on commit drop;

insert into stage_952_block_seed values
('7b230000-0000-4000-8000-000000000001', 'explanation', 'O que é Microsoft Purview?',
$content$Microsoft Purview é um conjunto de soluções Microsoft que ajuda organizações a **governar, proteger e gerenciar dados**.

No AZ-900, reconheça principalmente sua finalidade: aumentar a visibilidade sobre o patrimônio de dados, apoiar descoberta, catálogo e classificação e contribuir para governança, segurança e compliance relacionados a dados. Não é necessário administrar os produtos internos da plataforma.$content$, null, 1),

('7b230000-0000-4000-8000-000000000002', 'important', 'O escopo atual da plataforma',
$content$Microsoft Purview reúne capacidades em três áreas amplas:

- **Data Governance:** conhecer, organizar e governar dados;
- **Data Security:** ajudar a compreender e proteger dados sensíveis;
- **Data Compliance:** apoiar requisitos e processos de conformidade relacionados a dados.

Para Fundamentals, memorize a finalidade integrada, não a configuração detalhada de cada produto.$content$, null, 2),

('7b230000-0000-4000-8000-000000000003', 'explanation', 'Data Governance transforma dados em patrimônio compreensível',
$content$Data Governance reúne processos e capacidades usados para conhecer, organizar, controlar e manter confiança nos dados da organização.

Ela ajuda a responder perguntas como:

- Quais dados existem e onde estão?
- Quem é responsável por eles?
- Como estão classificados?
- Os dados são compreensíveis e confiáveis?
- Existem dados pessoais, financeiros ou sensíveis?

Governança não significa apenas armazenar dados; significa criar contexto, responsabilidade e controle sobre eles.$content$, null, 3),

('7b230000-0000-4000-8000-000000000004', 'example', 'Dados espalhados por vários ambientes',
$content$Uma empresa possui dados em serviços Azure, bancos de dados, data lakes e ambientes multicloud. Equipes diferentes conhecem apenas partes desse patrimônio.

Microsoft Purview pode ajudar a aumentar a visibilidade sobre esses ativos, seus metadados, classificações e contexto de negócio. Assim, as equipes conseguem encontrar e compreender melhor os dados que precisam governar.$content$, null, 4),

('7b230000-0000-4000-8000-000000000005', 'explanation', 'Discovery encontra ativos e metadados',
$content$Data discovery ajuda a identificar ativos de dados e coletar informações que os descrevem, chamadas **metadados**.

Metadados podem indicar nome, tipo, localização lógica, origem, classificação ou responsável pelo ativo. Descobrir e descrever ativos reduz pontos cegos e prepara o catálogo; isso não significa copiar todos os dados para um único banco.$content$, null, 5),

('7b230000-0000-4000-8000-000000000006', 'important', 'Data Map e Unified Catalog',
$content$| Capacidade | Papel conceitual |
| --- | --- |
| Data Map | ajuda a capturar e mapear metadados dos ativos de dados |
| Unified Catalog | oferece uma experiência pesquisável para encontrar e compreender dados governados |

Não é necessário memorizar arquitetura interna, configurar scans ou conhecer billing. Para a prova, associe discovery e metadados ao mapa e pesquisa/compreensão ao catálogo.$content$, null, 6),

('7b230000-0000-4000-8000-000000000007', 'explanation', 'Classification identifica a natureza dos dados',
$content$Classification identifica ou categoriza dados de acordo com suas características e sensibilidade.

Exemplos conceituais incluem dados pessoais, financeiros, corporativos e outras informações sensíveis. A classificação ajuda na identificação, governança, proteção e compliance, mas esta Lesson não exige criar regras de classificação.$content$, null, 7),

('7b230000-0000-4000-8000-000000000008', 'example', 'Localizar informações sensíveis',
$content$Uma organização precisa saber onde existem dados pessoais de clientes em diferentes fontes.

Discovery ajuda a localizar e descrever os ativos; classification ajuda a indicar que determinados dados são sensíveis; o catálogo fornece contexto pesquisável para que as equipes autorizadas os compreendam e governem.$content$, null, 8),

('7b230000-0000-4000-8000-000000000009', 'important', 'Purview versus serviços próximos',
$content$| Serviço | Principal finalidade |
| --- | --- |
| Microsoft Purview | governança, descoberta, classificação, segurança e compliance relacionados a dados |
| Azure Policy | governança de configurações de recursos Azure por regras e avaliação de compliance |
| Microsoft Defender for Cloud | postura de segurança e proteção de workloads |

Os serviços podem contribuir para a governança ou segurança de uma organização, mas respondem a problemas diferentes.$content$, null, 9),

('7b230000-0000-4000-8000-000000000010', 'exam_trap', 'Purview não é Policy, Storage ou banco de dados',
$content$Microsoft Purview **não** é:

- Azure Policy para avaliar configurações de recursos;
- Azure Storage para armazenar objetos e arquivos;
- um banco de dados para centralizar todos os dados;
- uma ferramenta exclusiva para fontes hospedadas no Azure.

Purview ajuda a conhecer e governar um patrimônio de dados que pode estar distribuído por Azure, ambientes locais e outras nuvens.$content$, null, 10),

('7b230000-0000-4000-8000-000000000011', 'exam_trap', 'Purview não substitui Defender for Cloud',
$content$Defender for Cloud concentra-se em **security posture e workload protection**. Microsoft Purview concentra-se principalmente em **governança, segurança e compliance relacionados a dados**.

Purview possui um alcance amplo, mas o AZ-900 não exige detalhes de configuração de DLP, eDiscovery, Insider Risk, Information Barriers, Records Management, DSPM ou Communication Compliance.$content$, null, 11),

('7b230000-0000-4000-8000-000000000012', 'exam_tip', 'Procure discovery, catalog e classification',
$content$Se o cenário pede descobrir quais ativos de dados existem, pesquisar um catálogo, compreender metadados ou identificar informações sensíveis, Microsoft Purview é a opção provável.

Se a pergunta pede descobrir quais recursos Azure violam uma regra de configuração, procure Azure Policy. Se pede recomendações de postura ou proteção de workloads, procure Defender for Cloud.$content$, null, 12),

('7b230000-0000-4000-8000-000000000013', 'summary', 'Resumo para memória ativa', null,
'{"items":["Microsoft Purview ajuda a governar, proteger e gerenciar dados.","Data Governance cria visibilidade, contexto, responsabilidade e confiança nos dados.","Discovery identifica ativos e metadados; o Data Map ajuda a mapeá-los.","Unified Catalog ajuda a pesquisar e compreender dados governados.","Classification identifica características e sensibilidade dos dados.","Purview trata principalmente dados; Policy avalia configurações e Defender for Cloud protege workloads."]}'::jsonb, 13);

insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, visual_experience_id, display_order, is_published
)
select seed.id, lesson.id, seed.type, seed.title, seed.content, seed.config, null, seed.display_order, true
from stage_952_block_seed seed
cross join public.lessons lesson
where lesson.topic_id = '33000000-0000-4000-8000-000000000002'
  and lesson.slug = 'microsoft-purview';

create temporary table stage_952_flashcard_seed (
  id uuid primary key,
  front_text text not null,
  back_text text not null,
  hint text,
  display_order integer not null
) on commit drop;

insert into stage_952_flashcard_seed values
('7e420000-0000-4000-8000-000000000001', 'Qual é a finalidade principal do Microsoft Purview?', 'Ajudar organizações a governar, proteger e gerenciar dados.', 'Patrimônio de dados.', 1),
('7e420000-0000-4000-8000-000000000002', 'O que Data Governance ajuda uma organização a compreender?', 'Quais dados existem, onde estão, como são classificados e quem é responsável por eles.', 'Visibilidade e confiança.', 2),
('7e420000-0000-4000-8000-000000000003', 'O que data discovery identifica no Purview?', 'Ativos de dados e os metadados que os descrevem.', 'Encontrar e descrever.', 3),
('7e420000-0000-4000-8000-000000000004', 'Qual é o papel conceitual do Unified Catalog?', 'Oferecer uma experiência pesquisável para encontrar e compreender dados governados.', 'Catálogo pesquisável.', 4),
('7e420000-0000-4000-8000-000000000005', 'O que classification ajuda a identificar?', 'Características e sensibilidade dos dados, como informações pessoais ou financeiras.', 'Natureza dos dados.', 5),
('7e420000-0000-4000-8000-000000000006', 'Purview e Azure Policy possuem a mesma finalidade?', 'Não. Purview governa dados; Policy avalia e impõe padrões de configuração dos recursos Azure.', 'Dados versus configurações.', 6),
('7e420000-0000-4000-8000-000000000007', 'Como Purview difere de Defender for Cloud?', 'Purview trata principalmente governança, segurança e compliance de dados; Defender trata postura e proteção de workloads.', 'Dados versus workloads.', 7);

insert into public.flashcards (
  id, lesson_id, front_text, back_text, hint, display_order, is_published
)
select seed.id, lesson.id, seed.front_text, seed.back_text, seed.hint, seed.display_order, true
from stage_952_flashcard_seed seed
cross join public.lessons lesson
where lesson.topic_id = '33000000-0000-4000-8000-000000000002'
  and lesson.slug = 'microsoft-purview';

create temporary table stage_952_question_seed (
  id uuid primary key,
  question_text text not null,
  difficulty text not null,
  explanation text not null,
  display_order integer not null
) on commit drop;

insert into stage_952_question_seed values
('68000000-0000-4000-8000-000000000129', 'Uma empresa quer descobrir e catalogar ativos de dados distribuídos em várias fontes. Qual serviço atende melhor ao cenário?', 'easy', 'Microsoft Purview ajuda a descobrir ativos e metadados e oferece capacidades de catálogo para compreender dados governados.', 1),
('68000000-0000-4000-8000-000000000130', 'Uma organização precisa identificar quais conjuntos contêm dados pessoais e financeiros. Qual capacidade é mais relevante?', 'easy', 'Classification ajuda a identificar e categorizar dados de acordo com características e sensibilidade.', 2),
('68000000-0000-4000-8000-000000000131', 'Qual associação entre uma capacidade do Microsoft Purview e sua finalidade está correta?', 'medium', 'O Data Map ajuda a capturar e mapear metadados, enquanto o Unified Catalog oferece uma experiência pesquisável para encontrar e compreender dados governados.', 3),
('68000000-0000-4000-8000-000000000132', 'Uma equipe quer saber quais recursos Azure violam uma regra que exige regiões aprovadas. Deve usar Microsoft Purview?', 'medium', 'Não. Esse cenário trata de avaliação de configurações e compliance de recursos, finalidade do Azure Policy. Purview concentra-se principalmente na governança e compreensão de dados.', 4),
('68000000-0000-4000-8000-000000000133', 'Uma empresa possui dados sensíveis no Azure, em bancos locais e em outra nuvem. Também quer recomendações de postura para suas VMs. Qual associação é mais adequada?', 'hard', 'Microsoft Purview ajuda a descobrir, classificar e governar o patrimônio de dados distribuído; Defender for Cloud trata postura de segurança e proteção dos workloads como VMs.', 5);

insert into public.questions (
  id, certification_id, domain_id, topic_id, lesson_id, question_text,
  question_type, difficulty, explanation, is_published, display_order
)
select seed.id, certification.id, domain.id, topic.id, lesson.id, seed.question_text,
  'single_choice', seed.difficulty, seed.explanation, true, seed.display_order
from stage_952_question_seed seed
join public.certifications certification on certification.code = 'az-900'
join public.domains domain on domain.certification_id = certification.id
  and domain.title = 'Describe Azure management and governance'
join public.topics topic on topic.domain_id = domain.id
  and topic.id = '33000000-0000-4000-8000-000000000002'
join public.lessons lesson on lesson.topic_id = topic.id
  and lesson.slug = 'microsoft-purview';

create temporary table stage_952_option_seed (
  id uuid primary key,
  question_id uuid not null,
  option_text text not null,
  is_correct boolean not null,
  explanation text not null,
  display_order integer not null
) on commit drop;

insert into stage_952_option_seed values
('7f230000-0000-4000-8000-000000000001', '68000000-0000-4000-8000-000000000129', 'Microsoft Purview.', true, 'Correta. Purview oferece discovery, metadados e catálogo para governança de dados.', 1),
('7f230000-0000-4000-8000-000000000002', '68000000-0000-4000-8000-000000000129', 'Azure Policy.', false, 'Policy avalia configurações dos recursos Azure, não cria um catálogo de ativos de dados.', 2),
('7f230000-0000-4000-8000-000000000003', '68000000-0000-4000-8000-000000000129', 'Resource Locks.', false, 'Locks protegem contra determinadas alterações ou exclusões.', 3),
('7f230000-0000-4000-8000-000000000004', '68000000-0000-4000-8000-000000000129', 'Azure Pricing Calculator.', false, 'A calculadora estima custos planejados.', 4),

('7f230000-0000-4000-8000-000000000005', '68000000-0000-4000-8000-000000000130', 'Data classification.', true, 'Correta. Classification identifica características e sensibilidade.', 1),
('7f230000-0000-4000-8000-000000000006', '68000000-0000-4000-8000-000000000130', 'Resource locking.', false, 'Lock não identifica a sensibilidade de dados.', 2),
('7f230000-0000-4000-8000-000000000007', '68000000-0000-4000-8000-000000000130', 'Cost forecasting.', false, 'Forecast projeta custos, não classifica informações.', 3),
('7f230000-0000-4000-8000-000000000008', '68000000-0000-4000-8000-000000000130', 'Horizontal scaling.', false, 'Scaling altera capacidade de compute.', 4),

('7f230000-0000-4000-8000-000000000009', '68000000-0000-4000-8000-000000000131', 'Data Map mapeia metadados; Unified Catalog ajuda a pesquisar e compreender dados.', true, 'Correta. Essa é a distinção conceitual esperada em Fundamentals.', 1),
('7f230000-0000-4000-8000-000000000010', '68000000-0000-4000-8000-000000000131', 'Data Map bloqueia exclusões; Unified Catalog concede permissões RBAC.', false, 'Locks e RBAC possuem essas finalidades, não Map e Catalog.', 2),
('7f230000-0000-4000-8000-000000000011', '68000000-0000-4000-8000-000000000131', 'Data Map armazena todos os dados; Unified Catalog substitui os bancos de origem.', false, 'Purview trabalha com metadados e contexto; não exige centralizar os dados em um novo banco.', 3),
('7f230000-0000-4000-8000-000000000012', '68000000-0000-4000-8000-000000000131', 'Data Map estima custos; Unified Catalog protege VMs contra ameaças.', false, 'Essas são finalidades de outras capacidades, não de governança de dados.', 4),

('7f230000-0000-4000-8000-000000000013', '68000000-0000-4000-8000-000000000132', 'Não. Azure Policy avalia regras e compliance de configurações dos recursos.', true, 'Correta. O requisito aponta para Azure Policy.', 1),
('7f230000-0000-4000-8000-000000000014', '68000000-0000-4000-8000-000000000132', 'Sim. Purview substitui Azure Policy para qualquer tipo de compliance.', false, 'Purview não substitui Policy na governança de configurações Azure.', 2),
('7f230000-0000-4000-8000-000000000015', '68000000-0000-4000-8000-000000000132', 'Sim. Purview é o banco que armazena a configuração de todos os recursos.', false, 'Purview não é um banco de configurações de recursos.', 3),
('7f230000-0000-4000-8000-000000000016', '68000000-0000-4000-8000-000000000132', 'Não. Resource Locks avaliam quais regiões são aprovadas.', false, 'Locks protegem contra alterações ou exclusões; não avaliam compliance de configuração.', 4),

('7f230000-0000-4000-8000-000000000017', '68000000-0000-4000-8000-000000000133', 'Purview para o patrimônio de dados; Defender for Cloud para postura e proteção das VMs.', true, 'Correta. Cada serviço atende ao problema correspondente.', 1),
('7f230000-0000-4000-8000-000000000018', '68000000-0000-4000-8000-000000000133', 'Defender for Cloud para catalogar os dados; Purview para proteger as VMs.', false, 'A associação está invertida.', 2),
('7f230000-0000-4000-8000-000000000019', '68000000-0000-4000-8000-000000000133', 'Azure Storage para governar todas as fontes; Purview apenas para calcular custos.', false, 'Storage armazena dados e Purview não é ferramenta de cálculo de custos.', 3),
('7f230000-0000-4000-8000-000000000020', '68000000-0000-4000-8000-000000000133', 'Azure Policy para substituir ambos os serviços em qualquer ambiente.', false, 'Policy não substitui catálogo/classificação de dados nem workload protection.', 4);

insert into public.question_options (
  id, question_id, option_text, is_correct, explanation, display_order
)
select id, question_id, option_text, is_correct, explanation, display_order
from stage_952_option_seed;

do $$
declare
  lesson_record record;
begin
  select id, slug into strict lesson_record
  from public.lessons
  where topic_id = '33000000-0000-4000-8000-000000000002'
    and slug = 'microsoft-purview';

  if (select count(*) from public.lesson_content_blocks where lesson_id = lesson_record.id and is_published) <> 13
    or (select count(*) from public.flashcards where lesson_id = lesson_record.id and is_published) <> 7
    or (select count(*) from public.questions where lesson_id = lesson_record.id and is_published) <> 5 then
    raise exception '9.5.2 final inventory is invalid';
  end if;
end; $$;

commit;

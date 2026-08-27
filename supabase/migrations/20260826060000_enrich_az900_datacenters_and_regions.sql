begin;

do $$
declare
  target_count integer;
begin
  select count(*)
  into target_count
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Core Architectural Components'
    and lesson.slug in ('azure-datacenters', 'azure-regions');

  if target_count <> 2 then
    raise exception '8.5.2 expected exactly two target lessons, found %', target_count;
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug in ('azure-datacenters', 'azure-regions')
  ) then
    raise exception 'A target Lesson already contains Content Blocks outside the 8.5.2 seed';
  end if;
end;
$$;

create temporary table architecture_block_seed (
  id uuid primary key,
  lesson_slug text not null,
  type text not null,
  title text,
  content text,
  config jsonb,
  display_order integer not null,
  is_published boolean not null
) on commit drop;

insert into architecture_block_seed values
  (
    '7b010000-0000-4000-8000-000000000001',
    'azure-datacenters',
    'explanation',
    'A base física do Azure',
    $content$Um Azure Datacenter é uma instalação física que abriga a infraestrutura usada para entregar serviços de nuvem. Dentro dele existem servidores, equipamentos de armazenamento e rede, além dos sistemas que sustentam a operação.

Datacenter é o nível físico. Ele não é um serviço que o cliente cria nem uma localização que normalmente seleciona diretamente ao implantar um recurso.$content$,
    null,
    1,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000002',
    'azure-datacenters',
    'important',
    'Energia, refrigeração, rede e segurança física',
    $content$Além dos servidores, um datacenter depende de alimentação elétrica, refrigeração, conectividade e controles de segurança física. A Microsoft administra essa infraestrutura para manter os serviços Azure em operação.

O nível Fundamentals exige reconhecer esses componentes, não conhecer a topologia interna ou os equipamentos usados em cada instalação.$content$,
    null,
    2,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000003',
    'azure-datacenters',
    'example',
    'O cliente escolhe uma Region',
    $content$Ao publicar uma aplicação, uma equipe normalmente escolhe uma Azure Region compatível, como uma localização disponível no Azure. A plataforma utiliza os datacenters que compõem essa Region; a equipe não escolhe um prédio, uma sala ou um servidor físico específico.$content$,
    null,
    3,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000004',
    'azure-datacenters',
    'important',
    'Geography → Region → Datacenter',
    $content$Uma geography é uma área do mundo que funciona como limite de residência de dados e contém uma ou mais Azure Regions. Uma Region é uma localização de implantação formada por uma ou mais instalações de datacenter conectadas. O datacenter é a instalação física.

Availability Zone é outro conceito dentro de determinadas Regions e será estudado na próxima Lesson. Ela não é sinônimo de Region nem de datacenter.$content$,
    null,
    4,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000005',
    'azure-datacenters',
    'exam_trap',
    'Datacenter, Region e Zone não são sinônimos',
    $content$Datacenter é uma instalação física. Region é uma localização Azure que reúne uma ou mais instalações. Availability Zone é um agrupamento separado dentro de uma Region compatível e será detalhada depois.

Se uma alternativa disser que o cliente normalmente escolhe o datacenter físico ou que Region e Availability Zone são a mesma coisa, desconfie.$content$,
    null,
    5,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000006',
    'azure-datacenters',
    'exam_tip',
    'Identifique o nível físico',
    $content$Na prova, associe servidores, armazenamento, equipamentos de rede, energia e refrigeração ao datacenter. Quando o cenário falar sobre a localização escolhida para implantar recursos, normalmente está descrevendo uma Azure Region.$content$,
    null,
    6,
    true
  ),
  (
    '7b010000-0000-4000-8000-000000000007',
    'azure-datacenters',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Azure Datacenter é uma instalação física.", "Ele contém servidores, armazenamento, rede, energia e refrigeração.", "A Microsoft administra a infraestrutura física dos datacenters Azure.", "Clientes normalmente escolhem uma Azure Region, não um prédio específico.", "Geography, Region, Datacenter e Availability Zone são conceitos diferentes."]}$json$::jsonb,
    7,
    true
  ),

  (
    '7b020000-0000-4000-8000-000000000001',
    'azure-regions',
    'explanation',
    'O que é uma Azure Region?',
    $content$Uma Azure Region é uma localização usada para implantar recursos e serviços Azure. Cada Region pertence a uma geography e é composta por uma ou mais instalações de datacenter.

Os datacenters de uma Region são conectados por infraestrutura de rede de alta capacidade e baixa latência. Para o cliente, a Region funciona como uma opção de localização lógica para a carga de trabalho.$content$,
    null,
    1,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000002',
    'azure-regions',
    'important',
    'Geography → Region → Datacenter',
    $content$A geography estabelece um limite amplo de residência de dados e contém uma ou mais Regions. Cada Region reúne uma ou mais instalações de datacenter conectadas.

Algumas Regions também oferecem Availability Zones, mas Zone não é outro nome para Region. A arquitetura de Zones será tratada separadamente na próxima Lesson.$content$,
    null,
    2,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000003',
    'azure-regions',
    'explanation',
    'Como escolher uma Region',
    $content$A melhor Region depende dos requisitos da solução. Avalie em conjunto:

- proximidade dos usuários e latência esperada;
- disponibilidade dos serviços necessários;
- residência de dados e requisitos de compliance;
- preço, quando houver diferença regional aplicável;
- opções de resiliência oferecidas pela Region e pelos serviços usados.

Nenhum desses fatores deve ser tratado isoladamente como regra universal.$content$,
    null,
    3,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000004',
    'azure-regions',
    'dotnet_example',
    'Uma API ASP.NET Core para usuários no Brasil',
    $content$Uma empresa possui usuários principalmente no Brasil e quer publicar uma API ASP.NET Core no Azure. A equipe pode avaliar uma Region próxima desses usuários para reduzir a latência.

Antes da decisão, também deve confirmar se os serviços usados pela API estão disponíveis nessa Region, verificar requisitos de residência de dados e compliance, comparar preço quando aplicável e considerar as opções de resiliência necessárias.$content$,
    null,
    4,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000005',
    'azure-regions',
    'exam_trap',
    'A Region mais próxima nem sempre é a escolha final',
    $content$Proximidade pode reduzir latência, mas não substitui os demais requisitos. Um serviço necessário pode não estar disponível na Region mais próxima, regras de residência de dados podem restringir a escolha e preço ou opções de resiliência podem variar.

Também não confunda Region com Datacenter ou Availability Zone.$content$,
    null,
    5,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000006',
    'azure-regions',
    'exam_tip',
    'Leia todos os requisitos do cenário',
    $content$Quando uma questão pedir a escolha de Region, procure latência, disponibilidade do serviço, residência de dados/compliance, preço aplicável e resiliência. A alternativa correta tende a equilibrar os requisitos, não escolher automaticamente a localização mais próxima ou mais barata.$content$,
    null,
    6,
    true
  ),
  (
    '7b020000-0000-4000-8000-000000000007',
    'azure-regions',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Uma Azure Region pertence a uma geography.", "Uma Region contém uma ou mais instalações de datacenter conectadas por rede de alta capacidade e baixa latência.", "Region é uma localização usada para implantar recursos Azure.", "Latência e proximidade são fatores de escolha, mas não os únicos.", "Disponibilidade de serviços, residência de dados, compliance, preço e resiliência também devem ser avaliados.", "Region, Datacenter e Availability Zone não são sinônimos."]}$json$::jsonb,
    7,
    true
  );

with target_lessons as (
  select lesson.id, lesson.slug
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Core Architectural Components'
    and lesson.slug in ('azure-datacenters', 'azure-regions')
),
resolved_seed as (
  select seed.*, lesson.id as lesson_id
  from architecture_block_seed seed
  join target_lessons lesson on lesson.slug = seed.lesson_slug
)
insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, visual_experience_id,
  display_order, is_published
)
select
  id, lesson_id, type, title, content, config, null,
  display_order, is_published
from resolved_seed
order by lesson_slug, display_order
on conflict (id) do update set
  lesson_id = excluded.lesson_id,
  type = excluded.type,
  title = excluded.title,
  content = excluded.content,
  config = excluded.config,
  visual_experience_id = excluded.visual_experience_id,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

update public.lessons lesson
set estimated_minutes = 10
from public.topics topic
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where lesson.topic_id = topic.id
  and certification.code = 'az-900'
  and domain.title = 'Describe Azure architecture and services'
  and topic.title = 'Core Architectural Components'
  and lesson.slug in ('azure-datacenters', 'azure-regions');

update public.flashcards
set
  front_text = case id
    when '71000000-0000-4000-8000-000000000073' then 'O que é um Azure Datacenter?'
    when '71000000-0000-4000-8000-000000000074' then 'Como uma Azure Region se relaciona com datacenters?'
    when '71000000-0000-4000-8000-000000000075' then 'O cliente normalmente escolhe um datacenter físico ao implantar um recurso Azure?'
    when '71000000-0000-4000-8000-000000000076' then 'Qual é a diferença entre Datacenter e Region?'
    when '70000000-0000-4000-8000-000000000013' then 'O que é uma Azure Region?'
    when '70000000-0000-4000-8000-000000000015' then 'Quais fatores devem ser avaliados ao escolher uma Azure Region?'
    when '71000000-0000-4000-8000-000000000077' then 'Como Geography e Region se relacionam no Azure?'
    when '71000000-0000-4000-8000-000000000080' then 'O serviço necessário não existe na Region mais próxima. O que a equipe deve fazer?'
    else front_text
  end,
  back_text = case id
    when '71000000-0000-4000-8000-000000000073' then 'É uma instalação física com servidores, armazenamento, rede, energia e refrigeração que sustenta serviços Azure.'
    when '71000000-0000-4000-8000-000000000074' then 'Uma Region contém uma ou mais instalações de datacenter conectadas por rede de alta capacidade e baixa latência.'
    when '71000000-0000-4000-8000-000000000075' then 'Não. O cliente normalmente escolhe uma Azure Region; a Microsoft administra e seleciona a infraestrutura física usada pelo serviço.'
    when '71000000-0000-4000-8000-000000000076' then 'Datacenter é uma instalação física. Region é uma localização Azure formada por uma ou mais instalações de datacenter.'
    when '70000000-0000-4000-8000-000000000013' then 'É uma localização dentro de uma geography, formada por uma ou mais instalações de datacenter conectadas, usada para implantar recursos Azure.'
    when '70000000-0000-4000-8000-000000000015' then 'Latência, disponibilidade dos serviços, residência de dados/compliance, preço aplicável e opções de resiliência.'
    when '71000000-0000-4000-8000-000000000077' then 'Uma geography contém uma ou mais Azure Regions e funciona como um limite amplo de residência de dados.'
    when '71000000-0000-4000-8000-000000000080' then 'Avaliar outra Region que ofereça o serviço e equilibrar latência, compliance, preço e resiliência com esse requisito.'
    else back_text
  end,
  hint = case id
    when '71000000-0000-4000-8000-000000000075' then 'Pense na localização que aparece ao criar o recurso.'
    when '70000000-0000-4000-8000-000000000015' then 'Não use apenas proximidade como critério.'
    else hint
  end
where id in (
  '71000000-0000-4000-8000-000000000073',
  '71000000-0000-4000-8000-000000000074',
  '71000000-0000-4000-8000-000000000075',
  '71000000-0000-4000-8000-000000000076',
  '70000000-0000-4000-8000-000000000013',
  '70000000-0000-4000-8000-000000000015',
  '71000000-0000-4000-8000-000000000077',
  '71000000-0000-4000-8000-000000000080'
);

update public.questions
set
  question_text = case id
    when '63000000-0000-4000-8000-000000000081' then 'O que é um Azure Datacenter?'
    when '63000000-0000-4000-8000-000000000082' then 'Quais componentes fazem parte da infraestrutura física de um Azure Datacenter?'
    when '63000000-0000-4000-8000-000000000083' then 'Ao implantar um recurso Azure, qual localização o cliente normalmente seleciona?'
    when '63000000-0000-4000-8000-000000000084' then 'Qual afirmação descreve corretamente a relação entre Azure Region e Datacenter?'
    when '63000000-0000-4000-8000-000000000085' then 'Quem administra servidores, energia, refrigeração e rede física nos Azure Datacenters?'
    when '63000000-0000-4000-8000-000000000086' then 'Como os datacenters que compõem uma Azure Region trabalham em conjunto?'
    when '63000000-0000-4000-8000-000000000087' then 'Qual afirmação diferencia corretamente Datacenter de Region?'
    when '63000000-0000-4000-8000-000000000088' then 'Por que o cliente normalmente não escolhe um prédio específico ao criar um recurso Azure?'
    when '63000000-0000-4000-8000-000000000089' then 'Uma equipe quer hospedar uma aplicação no Azure e pede para escolher o datacenter físico mais próximo. Qual orientação está correta?'
    when '63000000-0000-4000-8000-000000000090' then 'Qual sequência representa corretamente a relação entre Geography, Region e Datacenter no Azure?'
    when '60000000-0000-4000-8000-000000000004' then 'Ao escolher uma Azure Region para uma nova carga de trabalho, quais fatores devem ser avaliados em conjunto?'
    else question_text
  end,
  explanation = case id
    when '63000000-0000-4000-8000-000000000081' then 'Um Azure Datacenter é uma instalação física que reúne servidores, armazenamento, rede e a infraestrutura necessária para operar serviços Azure.'
    when '63000000-0000-4000-8000-000000000082' then 'Servidores, armazenamento e rede dependem também de energia e refrigeração. Esses elementos pertencem à infraestrutura física administrada pela Microsoft.'
    when '63000000-0000-4000-8000-000000000083' then 'O cliente normalmente seleciona uma Azure Region como localização do recurso. A plataforma utiliza a infraestrutura física que sustenta essa Region.'
    when '63000000-0000-4000-8000-000000000084' then 'Uma Azure Region é formada por uma ou mais instalações de datacenter conectadas. Datacenter é o prédio físico; Region é a localização lógica usada para implantação.'
    when '63000000-0000-4000-8000-000000000085' then 'A Microsoft, como cloud provider, administra a infraestrutura física dos Azure Datacenters. O cliente administra apenas as camadas que lhe cabem no modelo de serviço usado.'
    when '63000000-0000-4000-8000-000000000086' then 'Os datacenters de uma Region são conectados por infraestrutura de rede de alta capacidade e baixa latência para fornecer os serviços daquela localização.'
    when '63000000-0000-4000-8000-000000000087' then 'Datacenter é uma instalação física. Region reúne uma ou mais dessas instalações e é apresentada ao cliente como localização para implantar recursos.'
    when '63000000-0000-4000-8000-000000000088' then 'O Azure abstrai a escolha do prédio e do equipamento físico. O cliente escolhe a Region e configura o serviço, enquanto a Microsoft administra a infraestrutura subjacente.'
    when '63000000-0000-4000-8000-000000000089' then 'A equipe deve escolher uma Region e avaliar requisitos como proximidade, disponibilidade do serviço e compliance. Ela não seleciona diretamente o prédio ou o servidor físico.'
    when '63000000-0000-4000-8000-000000000090' then 'Uma geography contém uma ou mais Regions, e uma Region contém uma ou mais instalações de datacenter. Availability Zone é um conceito distinto, estudado separadamente.'
    when '60000000-0000-4000-8000-000000000004' then 'A escolha deve equilibrar latência, residência de dados e compliance, disponibilidade dos serviços, preço aplicável e opções de resiliência. Proximidade isoladamente não decide todos os cenários.'
    else explanation
  end
where id in (
  '63000000-0000-4000-8000-000000000081',
  '63000000-0000-4000-8000-000000000082',
  '63000000-0000-4000-8000-000000000083',
  '63000000-0000-4000-8000-000000000084',
  '63000000-0000-4000-8000-000000000085',
  '63000000-0000-4000-8000-000000000086',
  '63000000-0000-4000-8000-000000000087',
  '63000000-0000-4000-8000-000000000088',
  '63000000-0000-4000-8000-000000000089',
  '63000000-0000-4000-8000-000000000090',
  '60000000-0000-4000-8000-000000000004'
);

update public.question_options
set option_text = case id
  when '74000000-0000-4000-8000-000000000321' then 'Uma instalação física que abriga servidores, armazenamento, rede e sistemas de suporte.'
  when '74000000-0000-4000-8000-000000000322' then 'Uma localização Azure formada por uma ou mais instalações físicas.'
  when '74000000-0000-4000-8000-000000000323' then 'Um agrupamento lógico usado para organizar recursos de uma solução.'
  when '74000000-0000-4000-8000-000000000324' then 'Um serviço de gerenciamento acessado somente pelo Azure portal.'
  when '74000000-0000-4000-8000-000000000325' then 'Somente contas de usuário e licenças de software.'
  when '74000000-0000-4000-8000-000000000326' then 'Servidores, armazenamento, rede, energia e refrigeração.'
  when '74000000-0000-4000-8000-000000000327' then 'Somente aplicações SaaS consumidas pelos usuários.'
  when '74000000-0000-4000-8000-000000000328' then 'Apenas políticas e relatórios de cobrança.'
  when '74000000-0000-4000-8000-000000000329' then 'O número de série do servidor físico.'
  when '74000000-0000-4000-8000-000000000330' then 'O rack e a sala exatos dentro de um datacenter.'
  when '74000000-0000-4000-8000-000000000331' then 'Uma Azure Region compatível com o recurso.'
  when '74000000-0000-4000-8000-000000000332' then 'O fornecedor de energia do prédio.'
  when '74000000-0000-4000-8000-000000000333' then 'Uma Region e um datacenter são sempre a mesma instalação física.'
  when '74000000-0000-4000-8000-000000000334' then 'Um datacenter contém várias geographies independentes.'
  when '74000000-0000-4000-8000-000000000335' then 'O cliente cria uma Region instalando servidores próprios no Azure.'
  when '74000000-0000-4000-8000-000000000336' then 'Uma Region contém uma ou mais instalações de datacenter conectadas.'
  when '74000000-0000-4000-8000-000000000337' then 'A Microsoft, como cloud provider.'
  when '74000000-0000-4000-8000-000000000338' then 'Cada usuário final da aplicação.'
  when '74000000-0000-4000-8000-000000000339' then 'O cliente, independentemente do modelo de serviço.'
  when '74000000-0000-4000-8000-000000000340' then 'O fabricante da aplicação implantada.'
  when '74000000-0000-4000-8000-000000000341' then 'Eles funcionam isoladamente, sem conectividade entre as instalações.'
  when '74000000-0000-4000-8000-000000000342' then 'Eles são conectados por rede de alta capacidade e baixa latência.'
  when '74000000-0000-4000-8000-000000000343' then 'Eles dependem da rede local do cliente para trocar dados.'
  when '74000000-0000-4000-8000-000000000344' then 'Eles são transformados em Resource Groups automaticamente.'
  when '74000000-0000-4000-8000-000000000345' then 'Datacenter é uma geography; Region é um servidor individual.'
  when '74000000-0000-4000-8000-000000000346' then 'Datacenter e Region são nomes diferentes para o mesmo conceito.'
  when '74000000-0000-4000-8000-000000000347' then 'Datacenter é físico; Region reúne uma ou mais instalações e é usada como localização de implantação.'
  when '74000000-0000-4000-8000-000000000348' then 'Region existe somente dentro do datacenter local do cliente.'
  when '74000000-0000-4000-8000-000000000349' then 'Porque todo recurso Azure é executado sem qualquer infraestrutura física.'
  when '74000000-0000-4000-8000-000000000350' then 'Porque o cliente precisa construir seu próprio datacenter primeiro.'
  when '74000000-0000-4000-8000-000000000351' then 'Porque todos os prédios Azure oferecem exatamente os mesmos serviços e preços.'
  when '74000000-0000-4000-8000-000000000352' then 'Porque o Azure abstrai o prédio; o cliente seleciona a Region e configura o serviço.'
  when '74000000-0000-4000-8000-000000000353' then 'Escolher uma Region considerando proximidade, disponibilidade dos serviços e requisitos regulatórios.'
  when '74000000-0000-4000-8000-000000000354' then 'Solicitar acesso físico e escolher o rack com menor distância dos usuários.'
  when '74000000-0000-4000-8000-000000000355' then 'Escolher qualquer prédio, pois a disponibilidade de serviços nunca varia.'
  when '74000000-0000-4000-8000-000000000356' then 'Comprar servidores e instalá-los diretamente em um Azure Datacenter.'
  when '74000000-0000-4000-8000-000000000357' then 'Datacenter → Geography → Region.'
  when '74000000-0000-4000-8000-000000000358' then 'Geography → Region → Datacenter.'
  when '74000000-0000-4000-8000-000000000359' then 'Region → Datacenter → Geography.'
  when '74000000-0000-4000-8000-000000000360' then 'Geography → Datacenter → Subscription.'
  when '70000000-0000-4000-8000-000000000013' then 'Latência, serviços disponíveis, residência de dados/compliance, preço aplicável e opções de resiliência.'
  when '70000000-0000-4000-8000-000000000014' then 'Somente a distância física até os usuários.'
  when '70000000-0000-4000-8000-000000000015' then 'Somente o preço por unidade do serviço.'
  when '70000000-0000-4000-8000-000000000016' then 'A Region não altera disponibilidade de serviços nem opções de resiliência.'
  else option_text
end
where id between '74000000-0000-4000-8000-000000000321'
             and '74000000-0000-4000-8000-000000000360'
   or id between '70000000-0000-4000-8000-000000000013'
             and '70000000-0000-4000-8000-000000000016';

do $$
declare
  target_lesson_ids uuid[];
begin
  select array_agg(lesson.id order by lesson.display_order)
  into target_lesson_ids
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Core Architectural Components'
    and lesson.slug in ('azure-datacenters', 'azure-regions');

  if (select count(*) from architecture_block_seed) <> 14 then
    raise exception '8.5.2 block seed expected 14 rows';
  end if;

  if (
    select count(*)
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and is_published
  ) <> 14 then
    raise exception '8.5.2 expected 14 published blocks';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = any(target_lesson_ids)
      and type = 'visual_experience'
  ) then
    raise exception '8.5.2 must not create or link Visual Experiences';
  end if;

  if (select count(*) from public.flashcards where lesson_id = any(target_lesson_ids) and is_published) <> 11
    or (select count(*) from public.questions where lesson_id = any(target_lesson_ids) and is_published) <> 16 then
    raise exception '8.5.2 practice counts changed unexpectedly';
  end if;
end;
$$;

commit;

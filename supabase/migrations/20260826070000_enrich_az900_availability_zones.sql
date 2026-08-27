begin;

do $$
declare
  target_lesson_id uuid;
begin
  select lesson.id
  into strict target_lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Core Architectural Components'
    and lesson.slug = 'availability-zones';

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = target_lesson_id
  ) then
    raise exception 'Availability Zones already contains Content Blocks outside the 8.5.3 seed';
  end if;

  if not exists (
    select 1
    from public.visual_experiences
    where id = '76000000-0000-4000-8000-000000000002'
      and lesson_id = target_lesson_id
      and type = 'architecture'
      and is_published
  ) then
    raise exception 'The existing Availability Zones Visual Experience was not found';
  end if;
end;
$$;

update public.visual_experiences visual
set
  title = 'Azure Region, Availability Zones e Datacenters',
  description = 'Uma Region compatível contém Zones fisicamente separadas; cada Zone agrupa um ou mais datacenters e possui energia, refrigeração e networking independentes das demais.',
  config = $json$
  {
    "nodes": [
      {
        "id": "azure-region",
        "label": "Azure Region",
        "kind": "group",
        "description": "Localização Azure que contém as Availability Zones representadas abaixo.",
        "x": 50,
        "y": 10
      },
      {
        "id": "zone-1",
        "label": "Availability Zone 1",
        "kind": "zone",
        "description": "Agrupamento lógico fisicamente separado, com energia, refrigeração e networking independentes das outras Zones.",
        "x": 18,
        "y": 44
      },
      {
        "id": "zone-2",
        "label": "Availability Zone 2",
        "kind": "zone",
        "description": "Agrupamento lógico fisicamente separado, com energia, refrigeração e networking independentes das outras Zones.",
        "x": 50,
        "y": 44
      },
      {
        "id": "zone-3",
        "label": "Availability Zone 3",
        "kind": "zone",
        "description": "Agrupamento lógico fisicamente separado, com energia, refrigeração e networking independentes das outras Zones.",
        "x": 82,
        "y": 44
      },
      {
        "id": "zone-1-datacenters",
        "label": "1+ Datacenters",
        "kind": "group",
        "description": "Uma Zone pode conter um ou mais datacenters; ela não é sinônimo de um único prédio.",
        "x": 18,
        "y": 82
      },
      {
        "id": "zone-2-datacenters",
        "label": "1+ Datacenters",
        "kind": "group",
        "description": "Uma Zone pode conter um ou mais datacenters; ela não é sinônimo de um único prédio.",
        "x": 50,
        "y": 82
      },
      {
        "id": "zone-3-datacenters",
        "label": "1+ Datacenters",
        "kind": "group",
        "description": "Uma Zone pode conter um ou mais datacenters; ela não é sinônimo de um único prédio.",
        "x": 82,
        "y": 82
      }
    ],
    "edges": [
      {"id": "region-zone-1", "source": "azure-region", "target": "zone-1", "label": "contém"},
      {"id": "region-zone-2", "source": "azure-region", "target": "zone-2", "label": "contém"},
      {"id": "region-zone-3", "source": "azure-region", "target": "zone-3", "label": "contém"},
      {"id": "zone-1-datacenters", "source": "zone-1", "target": "zone-1-datacenters", "label": "agrupa 1+"},
      {"id": "zone-2-datacenters", "source": "zone-2", "target": "zone-2-datacenters", "label": "agrupa 1+"},
      {"id": "zone-3-datacenters", "source": "zone-3", "target": "zone-3-datacenters", "label": "agrupa 1+"}
    ]
  }
  $json$::jsonb
where visual.id = '76000000-0000-4000-8000-000000000002';

create temporary table availability_zone_block_seed (
  id uuid primary key,
  type text not null,
  title text,
  content text,
  config jsonb,
  visual_experience_id uuid,
  display_order integer not null,
  is_published boolean not null
) on commit drop;

insert into availability_zone_block_seed values
  (
    '7b030000-0000-4000-8000-000000000001',
    'explanation',
    'O que é uma Availability Zone?',
    $content$Uma Availability Zone é um agrupamento lógico de um ou mais datacenters fisicamente separados dentro de uma Azure Region. Cada Zone funciona como um limite de isolamento físico dentro da Region.

A relação conceitual é: Azure Region → Availability Zones → um ou mais Datacenters por Zone. Region e Zone não são sinônimos, e uma Zone não representa obrigatoriamente um único datacenter.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000002',
    'important',
    'Isolamento contra falhas locais',
    $content$As Zones de uma mesma Region possuem infraestrutura independente para energia, refrigeração e networking. Esse isolamento reduz a chance de uma falha localizada, como um problema de energia em uma Zone, afetar simultaneamente as demais.

Availability Zones fornecem a infraestrutura para aumentar a resiliência. A aplicação e os serviços ainda precisam usar essa capacidade de forma adequada.$content$,
    null,
    null,
    2,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000003',
    'visual_experience',
    'Region, Zones e Datacenters',
    null,
    null,
    '76000000-0000-4000-8000-000000000002',
    3,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000004',
    'explanation',
    'Zonal e zone-redundant',
    $content$Um recurso zonal é associado a uma Availability Zone específica. Isoladamente, ele pode ser afetado se essa Zone ficar indisponível.

Em uma implantação zone-redundant, o serviço distribui ou replica o recurso entre múltiplas Zones quando esse modo é suportado. Alguns serviços gerenciam essa distribuição; recursos zonais exigem uma arquitetura com instâncias em Zones diferentes para obter resiliência zonal.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000005',
    'important',
    'O suporte varia',
    $content$Muitas Azure Regions possuem Availability Zones, mas nem todas necessariamente oferecem esse recurso. O suporte também varia por serviço e pode depender da Region, do tier ou SKU e da configuração escolhida.

Por isso, não memorize uma lista fixa de Regions. Em um cenário real, confirme a documentação do serviço e da Region planejada.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000006',
    'dotnet_example',
    'Uma API ASP.NET Core distribuída entre Zones',
    $content$Uma API ASP.NET Core possui múltiplas instâncias de um serviço compatível distribuídas entre Availability Zones diferentes. Se uma Zone sofrer uma falha de energia, a arquitetura pode continuar atendendo usuários pelos recursos nas outras Zones.

Esse comportamento depende do suporte do serviço e da configuração da solução. Apenas escolher uma Region com Zones não distribui automaticamente qualquer aplicação.$content$,
    null,
    null,
    6,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000007',
    'exam_tip',
    'Reconheça o tipo de implantação',
    $content$Se o recurso está preso a uma Zone específica, ele é zonal. Se o serviço distribui ou replica o recurso entre múltiplas Zones, ele é zone-redundant. Sempre verifique se o cenário informa suporte e configuração adequados.$content$,
    null,
    null,
    7,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000008',
    'exam_trap',
    'O que Availability Zones não significam',
    $content$Availability Zone não é uma Region e não equivale obrigatoriamente a um único datacenter. Usar múltiplas Zones melhora a proteção contra falhas locais, mas não protege por si só contra a perda completa da Region.

Além disso, multi-zone não está automaticamente configurado em todo serviço Azure, e nenhuma arquitetura garante que uma aplicação nunca ficará indisponível.$content$,
    null,
    null,
    8,
    true
  ),
  (
    '7b030000-0000-4000-8000-000000000009',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Availability Zone é um agrupamento lógico de um ou mais datacenters fisicamente separados dentro de uma Region.", "Zones diferentes possuem energia, refrigeração e networking independentes.", "O isolamento zonal aumenta a resiliência contra falhas locais.", "Recurso zonal fica associado a uma Zone específica.", "Recurso zone-redundant é distribuído ou replicado entre múltiplas Zones pelo serviço quando suportado.", "Suporte depende da Region, do serviço e, em alguns casos, do tier, SKU ou configuração."]}$json$::jsonb,
    null,
    9,
    true
  );

with target_lesson as (
  select lesson.id
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Core Architectural Components'
    and lesson.slug = 'availability-zones'
)
insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, visual_experience_id,
  display_order, is_published
)
select
  seed.id, lesson.id, seed.type, seed.title, seed.content, seed.config,
  seed.visual_experience_id, seed.display_order, seed.is_published
from availability_zone_block_seed seed
cross join target_lesson lesson
order by seed.display_order
on conflict (id) do update set
  lesson_id = excluded.lesson_id,
  type = excluded.type,
  title = excluded.title,
  content = excluded.content,
  config = excluded.config,
  visual_experience_id = excluded.visual_experience_id,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

update public.lessons
set estimated_minutes = 10
where slug = 'availability-zones'
  and topic_id = '30000000-0000-4000-8000-000000000002';

update public.flashcards
set
  front_text = case id
    when '70000000-0000-4000-8000-000000000016' then 'O que é uma Availability Zone?'
    when '70000000-0000-4000-8000-000000000017' then 'Como o isolamento entre Availability Zones aumenta a resiliência?'
    when '70000000-0000-4000-8000-000000000018' then 'Qual é a diferença entre Azure Region e Availability Zone?'
    when '71000000-0000-4000-8000-000000000081' then 'Quais infraestruturas são independentes entre Availability Zones?'
    when '71000000-0000-4000-8000-000000000082' then 'O que é um recurso zonal?'
    when '71000000-0000-4000-8000-000000000083' then 'O que é um recurso zone-redundant?'
    when '71000000-0000-4000-8000-000000000084' then 'O suporte a Availability Zones é igual em toda Region e serviço Azure?'
    else front_text
  end,
  back_text = case id
    when '70000000-0000-4000-8000-000000000016' then 'É um agrupamento lógico de um ou mais datacenters fisicamente separados dentro de uma Azure Region.'
    when '70000000-0000-4000-8000-000000000017' then 'Uma falha local em uma Zone não precisa afetar as demais, que possuem infraestrutura independente.'
    when '70000000-0000-4000-8000-000000000018' then 'Region é a localização Azure que pode conter Zones; cada Zone é um agrupamento físico isolado dentro dessa Region.'
    when '71000000-0000-4000-8000-000000000081' then 'Energia, refrigeração e networking são independentes entre as Zones.'
    when '71000000-0000-4000-8000-000000000082' then 'É um recurso associado a uma Availability Zone específica.'
    when '71000000-0000-4000-8000-000000000083' then 'É um recurso que o serviço distribui ou replica entre múltiplas Zones quando esse modo é suportado.'
    when '71000000-0000-4000-8000-000000000084' then 'Não. O suporte pode depender da Region, do serviço, do tier ou SKU e da configuração.'
    else back_text
  end,
  hint = case id
    when '71000000-0000-4000-8000-000000000082' then 'Uma única Zone.'
    when '71000000-0000-4000-8000-000000000083' then 'Múltiplas Zones.'
    else null
  end
where id in (
  '70000000-0000-4000-8000-000000000016',
  '70000000-0000-4000-8000-000000000017',
  '70000000-0000-4000-8000-000000000018',
  '71000000-0000-4000-8000-000000000081',
  '71000000-0000-4000-8000-000000000082',
  '71000000-0000-4000-8000-000000000083',
  '71000000-0000-4000-8000-000000000084'
);

update public.questions
set
  question_text = case id
    when '60000000-0000-4000-8000-000000000005' then 'Uma API usa um serviço compatível com instâncias distribuídas entre Availability Zones. Qual benefício essa arquitetura busca?'
    when '61000000-0000-4000-8000-000000000001' then 'Qual definição descreve corretamente uma Azure Availability Zone?'
    when '61000000-0000-4000-8000-000000000002' then 'Qual alternativa diferencia corretamente um recurso zonal de um recurso zone-redundant?'
    when '61000000-0000-4000-8000-000000000003' then 'O que deve ser confirmado antes de usar Availability Zones com um serviço Azure?'
    when '61000000-0000-4000-8000-000000000004' then 'Uma empresa escolheu uma Region que possui Availability Zones. Qual afirmação continua correta?'
    else question_text
  end,
  explanation = case id
    when '60000000-0000-4000-8000-000000000005' then 'Distribuir instâncias entre Zones ajuda a manter o atendimento quando uma falha local afeta uma delas. O resultado depende do suporte do serviço e da configuração da solução.'
    when '61000000-0000-4000-8000-000000000001' then 'Uma Availability Zone é um agrupamento lógico de um ou mais datacenters fisicamente separados dentro de uma Region, com energia, refrigeração e networking independentes das outras Zones.'
    when '61000000-0000-4000-8000-000000000002' then 'Um recurso zonal é associado a uma Zone específica. Um recurso zone-redundant é distribuído ou replicado pelo serviço entre múltiplas Zones quando esse modo é suportado.'
    when '61000000-0000-4000-8000-000000000003' then 'O suporte pode variar por Region, serviço, tier ou SKU e configuração. Ter Zones na Region não garante que qualquer combinação de serviço e configuração seja compatível.'
    when '61000000-0000-4000-8000-000000000004' then 'Availability Zones oferecem infraestrutura isolada, mas a solução precisa usar corretamente um modo zonal em múltiplas Zones ou zone-redundant. Elas não garantem disponibilidade absoluta nem protegem sozinhas contra a perda completa da Region.'
    else explanation
  end
where id in (
  '60000000-0000-4000-8000-000000000005',
  '61000000-0000-4000-8000-000000000001',
  '61000000-0000-4000-8000-000000000002',
  '61000000-0000-4000-8000-000000000003',
  '61000000-0000-4000-8000-000000000004'
);

update public.question_options
set option_text = case id
  when '70000000-0000-4000-8000-000000000017' then 'Reduzir o impacto de uma falha localizada em uma Zone.'
  when '70000000-0000-4000-8000-000000000018' then 'Proteger automaticamente contra a perda completa da Azure Region.'
  when '70000000-0000-4000-8000-000000000019' then 'Transformar cada instância em um datacenter físico independente.'
  when '70000000-0000-4000-8000-000000000020' then 'Eliminar a necessidade de configurar o serviço e a aplicação.'
  when '71000000-0000-4000-8000-000000000001' then 'Agrupamento lógico de um ou mais datacenters fisicamente separados dentro de uma Region.'
  when '71000000-0000-4000-8000-000000000002' then 'Outro nome para uma Azure Region completa.'
  when '71000000-0000-4000-8000-000000000003' then 'Um único datacenter que sempre hospeda todos os serviços da Region.'
  when '71000000-0000-4000-8000-000000000004' then 'Uma Region Pair usada exclusivamente para recuperação de desastre.'
  when '71000000-0000-4000-8000-000000000005' then 'Zonal fica em uma Zone; zone-redundant usa múltiplas Zones quando suportado.'
  when '71000000-0000-4000-8000-000000000006' then 'Zonal sempre usa múltiplas Regions; zone-redundant usa um datacenter.'
  when '71000000-0000-4000-8000-000000000007' then 'Os dois termos significam que nenhuma configuração é necessária.'
  when '71000000-0000-4000-8000-000000000008' then 'Zone-redundant significa usar obrigatoriamente uma Region Pair.'
  when '71000000-0000-4000-8000-000000000009' then 'Region, serviço, tier ou SKU e configuração compatíveis.'
  when '71000000-0000-4000-8000-000000000010' then 'Apenas que a assinatura possua vários Resource Groups.'
  when '71000000-0000-4000-8000-000000000011' then 'Somente que exista uma Region Pair na mesma geography.'
  when '71000000-0000-4000-8000-000000000012' then 'Nada; todo serviço Azure usa Zones automaticamente.'
  when '71000000-0000-4000-8000-000000000013' then 'A solução ainda precisa usar corretamente a capacidade zonal ou zone-redundant suportada.'
  when '71000000-0000-4000-8000-000000000014' then 'A aplicação está automaticamente protegida contra qualquer indisponibilidade.'
  when '71000000-0000-4000-8000-000000000015' then 'As Zones protegem automaticamente contra a perda completa da Region.'
  when '71000000-0000-4000-8000-000000000016' then 'Todo serviço na Region passa a usar múltiplas Zones sem configuração.'
  else option_text
end
where id between '70000000-0000-4000-8000-000000000017'
             and '70000000-0000-4000-8000-000000000020'
   or id between '71000000-0000-4000-8000-000000000001'
             and '71000000-0000-4000-8000-000000000016';

do $$
declare
  target_lesson_id uuid;
begin
  select id into strict target_lesson_id
  from public.lessons
  where slug = 'availability-zones'
    and topic_id = '30000000-0000-4000-8000-000000000002';

  if (select count(*) from availability_zone_block_seed) <> 9
    or (select count(*) from public.lesson_content_blocks where lesson_id = target_lesson_id and is_published) <> 9 then
    raise exception '8.5.3 expected nine published Content Blocks';
  end if;

  if (select count(*) from public.flashcards where lesson_id = target_lesson_id and is_published) <> 7
    or (select count(*) from public.questions where lesson_id = target_lesson_id and is_published) <> 5 then
    raise exception 'Availability Zones practice counts changed unexpectedly';
  end if;

  if (
    select count(*)
    from public.visual_experiences
    where lesson_id = target_lesson_id
  ) <> 1 then
    raise exception '8.5.3 must preserve exactly one Visual Experience';
  end if;
end;
$$;

commit;

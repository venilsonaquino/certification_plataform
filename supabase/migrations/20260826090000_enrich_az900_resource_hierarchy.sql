begin;

do $$
declare
  scoped_lesson_count integer;
begin
  select count(*)
  into scoped_lesson_count
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe Azure architecture and services'
    and topic.title = 'Core Architectural Components'
    and lesson.slug in (
      'resources-and-resource-groups',
      'subscriptions-and-management-groups',
      'azure-resource-hierarchy'
    );

  if scoped_lesson_count <> 3 then
    raise exception '8.5.5 expected exactly three scoped Lessons';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug in (
      'resources-and-resource-groups',
      'subscriptions-and-management-groups',
      'azure-resource-hierarchy'
    )
      and lesson.topic_id = '30000000-0000-4000-8000-000000000002'
  ) then
    raise exception 'A scoped 8.5.5 Lesson already contains Content Blocks';
  end if;

  if exists (
    select 1
    from public.visual_experiences visual
    join public.lessons lesson on lesson.id = visual.lesson_id
    where lesson.slug in (
      'resources-and-resource-groups',
      'subscriptions-and-management-groups',
      'azure-resource-hierarchy'
    )
      and lesson.topic_id = '30000000-0000-4000-8000-000000000002'
  ) then
    raise exception 'A scoped 8.5.5 Lesson already contains a Visual Experience';
  end if;

  if exists (
    select 1 from public.visual_experiences
    where id = '76000000-0000-4000-8000-000000000007'
  ) then
    raise exception 'The planned Resource Hierarchy Visual Experience UUID is already in use';
  end if;
end;
$$;

insert into public.visual_experiences (
  id, lesson_id, type, title, description, config, display_order, is_published
)
select
  '76000000-0000-4000-8000-000000000007',
  lesson.id,
  'architecture',
  'Hierarquia de recursos do Azure',
  'Do escopo mais amplo ao mais específico: Tenant / Root, Management Groups, Subscriptions, Resource Groups e Resources.',
  $json$
  {
    "nodes": [
      {
        "id": "tenant-root",
        "label": "Tenant / Root",
        "kind": "external",
        "description": "Contexto superior da organização. O root management group representa o topo da hierarquia de Management Groups do tenant.",
        "x": 50,
        "y": 12
      },
      {
        "id": "management-groups",
        "label": "Management Groups",
        "kind": "group",
        "description": "Organizam Subscriptions e oferecem um escopo amplo para governança centralizada.",
        "x": 50,
        "y": 31
      },
      {
        "id": "subscriptions",
        "label": "Subscriptions",
        "kind": "group",
        "description": "Contêm Resource Groups e definem um escopo para recursos, acesso, quotas, organização e relação de billing.",
        "x": 50,
        "y": 50
      },
      {
        "id": "resource-groups",
        "label": "Resource Groups",
        "kind": "group",
        "description": "Containers lógicos que organizam e ajudam a gerenciar o ciclo de vida de Resources relacionados.",
        "x": 50,
        "y": 69
      },
      {
        "id": "resources",
        "label": "Resources",
        "kind": "resource",
        "description": "Entidades gerenciáveis individuais, como VM, Storage Account, VNet ou App Service.",
        "x": 50,
        "y": 88
      }
    ],
    "edges": [
      {"id": "root-management", "source": "tenant-root", "target": "management-groups", "label": "topo"},
      {"id": "management-subscription", "source": "management-groups", "target": "subscriptions", "label": "organizam"},
      {"id": "subscription-resource-group", "source": "subscriptions", "target": "resource-groups", "label": "contêm"},
      {"id": "resource-group-resource", "source": "resource-groups", "target": "resources", "label": "agrupam"}
    ]
  }
  $json$::jsonb,
  1,
  true
from public.lessons lesson
where lesson.id = '98880411-d0cb-47d7-a278-ae295552ad5f'
  and lesson.slug = 'azure-resource-hierarchy'
  and lesson.topic_id = '30000000-0000-4000-8000-000000000002';

create temporary table resource_hierarchy_block_seed (
  id uuid primary key,
  lesson_slug text not null,
  type text not null,
  title text,
  content text,
  config jsonb,
  visual_experience_id uuid,
  display_order integer not null,
  is_published boolean not null
) on commit drop;

insert into resource_hierarchy_block_seed (
  id, lesson_slug, type, title, content, config, visual_experience_id,
  display_order, is_published
)
values
  (
    '7b050000-0000-4000-8000-000000000001',
    'resources-and-resource-groups',
    'explanation',
    'Azure Resources',
    $content$Um Azure Resource é uma entidade gerenciável criada no Azure. É a unidade individual que você provisiona, configura, monitora e, quando necessário, remove.

Virtual Machine, Storage Account, Virtual Network e App Service são exemplos de Resources. Cada um possui identidade e propriedades próprias no Azure Resource Manager.$content$,
    null, null, 1, true
  ),
  (
    '7b050000-0000-4000-8000-000000000002',
    'resources-and-resource-groups',
    'explanation',
    'Resource Groups',
    $content$Resource Group é um container lógico usado para organizar e gerenciar Resources relacionados. Cada Resource pertence a um Resource Group por vez, e cada Resource Group pertence a uma Subscription.

O agrupamento costuma refletir recursos que compartilham uma solução, responsabilidade administrativa ou ciclo de vida. Resource Group não é datacenter, Region nem mecanismo de isolamento físico.$content$,
    null, null, 2, true
  ),
  (
    '7b050000-0000-4000-8000-000000000003',
    'resources-and-resource-groups',
    'example',
    'Organizando uma aplicação',
    $content$Uma aplicação pode usar um App Service, uma Storage Account e uma Virtual Network. Se esses Resources são administrados e evoluem como parte da mesma solução, um Resource Group pode oferecer um escopo lógico comum para organizá-los.

Os Resources do mesmo grupo não precisam obrigatoriamente estar na mesma Azure Region. A localização de cada Resource depende do serviço e da implantação.$content$,
    null, null, 3, true
  ),
  (
    '7b050000-0000-4000-8000-000000000004',
    'resources-and-resource-groups',
    'important',
    'Pense no ciclo de vida',
    $content$Resource Groups ajudam a administrar recursos relacionados em conjunto. Excluir um Resource Group exclui os Resources contidos nele, portanto o ciclo de vida é um critério importante de organização.

Resources podem se conectar a Resources de outros grupos. Ainda assim, dependências entre grupos devem ser consideradas antes de alterar ou excluir um deles.$content$,
    null, null, 4, true
  ),
  (
    '7b050000-0000-4000-8000-000000000005',
    'resources-and-resource-groups',
    'exam_trap',
    'Tags não são herdadas automaticamente',
    $content$Uma tag aplicada ao Resource Group não aparece automaticamente nos Resources do grupo. Tags aplicadas à Subscription também não são automaticamente herdadas por Resource Groups ou Resources.

Mecanismos como Azure Policy podem implementar regras de herança de tags, mas isso exige configuração específica. A simples relação entre escopos não copia tags.$content$,
    null, null, 5, true
  ),
  (
    '7b050000-0000-4000-8000-000000000006',
    'resources-and-resource-groups',
    'exam_tip',
    'Reconheça o container lógico',
    $content$Quando o cenário pede organização e gerenciamento conjunto de Resources relacionados dentro de uma Subscription, Resource Group é o conceito mais provável. Se pede um serviço individual criado no Azure, trata-se de um Resource.$content$,
    null, null, 6, true
  ),
  (
    '7b050000-0000-4000-8000-000000000007',
    'resources-and-resource-groups',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Azure Resource é uma entidade gerenciável individual criada no Azure.", "Resource Group é um container lógico para organizar e gerenciar Resources relacionados.", "Cada Resource pertence a um Resource Group por vez.", "Resources do mesmo grupo podem estar em Azure Regions diferentes.", "Excluir o Resource Group exclui os Resources contidos nele.", "Tags de Resource Group ou Subscription não são herdadas automaticamente."]}$json$::jsonb,
    null, 7, true
  ),
  (
    '7b050000-0000-4000-8000-000000000008',
    'subscriptions-and-management-groups',
    'explanation',
    'Azure Subscriptions',
    $content$Uma Azure Subscription é um escopo importante para organizar e consumir Azure Resources. Ela contém Resource Groups e participa da definição de acesso, quotas e limites, organização administrativa e relação de billing.

Uma organização pode usar várias Subscriptions para separar ambientes, equipes ou workloads sem criar uma nova organização Azure para cada uma.$content$,
    null, null, 1, true
  ),
  (
    '7b050000-0000-4000-8000-000000000009',
    'subscriptions-and-management-groups',
    'important',
    'Subscription e billing',
    $content$A Subscription possui uma relação com a estrutura de billing, mas isso não significa que cada Subscription gere obrigatoriamente uma fatura independente.

Múltiplas Subscriptions podem estar associadas ao mesmo billing account, profile ou outra estrutura de cobrança, dependendo do tipo de contrato. A Subscription continua útil como escopo para analisar e organizar custos.$content$,
    null, null, 2, true
  ),
  (
    '7b050000-0000-4000-8000-000000000010',
    'subscriptions-and-management-groups',
    'example',
    'Separando produção e desenvolvimento',
    $content$Uma empresa pode manter produção em uma Subscription e desenvolvimento em outra. Assim, cada ambiente possui seus próprios escopos administrativos, quotas e visibilidade de custos.

As duas Subscriptions ainda podem fazer parte da mesma estrutura organizacional e de billing. Separação administrativa não implica necessariamente faturas independentes.$content$,
    null, null, 3, true
  ),
  (
    '7b050000-0000-4000-8000-000000000011',
    'subscriptions-and-management-groups',
    'explanation',
    'Management Groups',
    $content$Management Groups organizam Subscriptions. Eles ficam acima das Subscriptions na hierarquia e podem conter outras Management Groups para representar uma estrutura organizacional mais ampla.

Esse nível oferece um escopo para governança centralizada. Conceitualmente, configurações como Azure Policy ou atribuições de Azure RBAC podem ser aplicadas em níveis superiores, mas o comportamento detalhado depende do mecanismo.$content$,
    null, null, 4, true
  ),
  (
    '7b050000-0000-4000-8000-000000000012',
    'subscriptions-and-management-groups',
    'important',
    'Um escopo acima das Subscriptions',
    $content$Use Management Groups quando várias Subscriptions precisam ser organizadas sob um escopo comum. Resource Groups não substituem essa função: eles existem dentro de uma única Subscription e organizam Resources.$content$,
    null, null, 5, true
  ),
  (
    '7b050000-0000-4000-8000-000000000013',
    'subscriptions-and-management-groups',
    'exam_trap',
    'Não confunda os containers',
    $content$Management Group organiza Subscriptions; Resource Group organiza Resources dentro de uma Subscription. Uma Subscription é um escopo de recursos e administração, não sinônimo de invoice nem de billing account.$content$,
    null, null, 6, true
  ),
  (
    '7b050000-0000-4000-8000-000000000014',
    'subscriptions-and-management-groups',
    'exam_tip',
    'Identifique o nível pedido',
    $content$Se o cenário fala de quotas, limites, separação de ambientes ou administração de Resource Groups, pense em Subscription. Se pede organização e governança comum para várias Subscriptions, pense em Management Group.$content$,
    null, null, 7, true
  ),
  (
    '7b050000-0000-4000-8000-000000000015',
    'subscriptions-and-management-groups',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Subscription contém Resource Groups e oferece um escopo para Resources.", "Acesso, quotas, limites, organização e relação de billing estão associados à Subscription.", "Várias Subscriptions podem compartilhar uma estrutura de billing.", "Management Groups organizam Subscriptions.", "Management Groups ficam acima das Subscriptions na hierarquia.", "Escopos superiores podem apoiar governança centralizada sem criar uma regra universal de comportamento."]}$json$::jsonb,
    null, 8, true
  ),
  (
    '7b050000-0000-4000-8000-000000000016',
    'azure-resource-hierarchy',
    'explanation',
    'Do escopo amplo ao específico',
    $content$A hierarquia principal de organização dos Resources no Azure segue esta ordem:

Management Groups → Subscriptions → Resource Groups → Resources.

O tenant e seu root management group fornecem o contexto superior. Para o AZ-900, o essencial é saber o que cada nível organiza e reconhecer que o escopo fica progressivamente mais específico.$content$,
    null, null, 1, true
  ),
  (
    '7b050000-0000-4000-8000-000000000017',
    'azure-resource-hierarchy',
    'visual_experience',
    'Explore a hierarquia',
    null,
    null,
    '76000000-0000-4000-8000-000000000007',
    2,
    true
  ),
  (
    '7b050000-0000-4000-8000-000000000018',
    'azure-resource-hierarchy',
    'explanation',
    'O que cada nível organiza',
    $content$Management Groups organizam Subscriptions. Cada Subscription contém Resource Groups. Cada Resource Group organiza Resources relacionados, e o Resource é a entidade individual gerenciada.

Os níveis superiores são mais amplos; os inferiores são mais específicos. Resource Group é organização lógica, enquanto VM, Storage Account, VNet e App Service são exemplos de Resources.$content$,
    null, null, 3, true
  ),
  (
    '7b050000-0000-4000-8000-000000000019',
    'azure-resource-hierarchy',
    'example',
    'Da organização até a aplicação',
    $content$Uma empresa pode ter um Management Group corporativo que organiza duas Subscriptions: produção e desenvolvimento. Na Subscription de produção, um Resource Group reúne os Resources de uma aplicação, como App Service e Storage Account.

Cada nível responde a uma pergunta diferente: quais Subscriptions pertencem ao conjunto, qual Subscription contém o projeto, qual grupo organiza a solução e quais Resources foram criados.$content$,
    null, null, 4, true
  ),
  (
    '7b050000-0000-4000-8000-000000000020',
    'azure-resource-hierarchy',
    'important',
    'Escopo e efeito',
    $content$Configurações de governança e acesso podem ser atribuídas em diferentes escopos. Um escopo superior pode afetar os níveis abaixo dele, mas os detalhes variam conforme o mecanismo usado.

Nesta etapa, memorize a hierarquia e a amplitude do escopo. Azure Policy e Azure RBAC possuem regras próprias que serão estudadas separadamente.$content$,
    null, null, 5, true
  ),
  (
    '7b050000-0000-4000-8000-000000000021',
    'azure-resource-hierarchy',
    'exam_trap',
    'Não invente uma regra de sobrescrita',
    $content$Não existe uma regra geral dizendo que a Policy ou a permissão mais específica sempre sobrescreve uma configuração superior. Também não é correto afirmar que qualquer configuração superior sempre produz exatamente o mesmo comportamento nos níveis inferiores.

O efeito depende de Azure Policy, Azure RBAC ou do mecanismo em questão. Hierarquia define escopo e organização; não substitui as regras específicas desses serviços.$content$,
    null, null, 6, true
  ),
  (
    '7b050000-0000-4000-8000-000000000022',
    'azure-resource-hierarchy',
    'exam_tip',
    'Leia a hierarquia como containers',
    $content$Pergunte o que o item contém ou organiza. Management Group organiza Subscriptions; Subscription contém Resource Groups; Resource Group organiza Resources; Resource é o item individual.$content$,
    null, null, 7, true
  ),
  (
    '7b050000-0000-4000-8000-000000000023',
    'azure-resource-hierarchy',
    'summary',
    'Resumo',
    null,
    $json${"items": ["A ordem principal é Management Groups → Subscriptions → Resource Groups → Resources.", "Tenant / Root fornece o contexto superior da hierarquia.", "Management Groups organizam Subscriptions.", "Subscriptions contêm Resource Groups.", "Resource Groups organizam Resources relacionados.", "Escopos ficam mais específicos ao descer, sem criar uma regra universal de Policy ou RBAC."]}$json$::jsonb,
    null, 8, true
  );

with target_lessons as (
  select lesson.id, lesson.slug
  from public.lessons lesson
  where lesson.topic_id = '30000000-0000-4000-8000-000000000002'
    and lesson.slug in (
      'resources-and-resource-groups',
      'subscriptions-and-management-groups',
      'azure-resource-hierarchy'
    )
)
insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, visual_experience_id,
  display_order, is_published
)
select
  seed.id, lesson.id, seed.type, seed.title, seed.content, seed.config,
  seed.visual_experience_id, seed.display_order, seed.is_published
from resource_hierarchy_block_seed seed
join target_lessons lesson on lesson.slug = seed.lesson_slug
order by lesson.slug, seed.display_order
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
where topic_id = '30000000-0000-4000-8000-000000000002'
  and slug in (
    'resources-and-resource-groups',
    'subscriptions-and-management-groups',
    'azure-resource-hierarchy'
  );

update public.flashcards
set
  front_text = case id
    when '71000000-0000-4000-8000-000000000092' then 'Tags de um Resource Group são herdadas automaticamente pelos Resources?'
    when '71000000-0000-4000-8000-000000000093' then 'O que uma Azure Subscription representa?'
    when '71000000-0000-4000-8000-000000000096' then 'Múltiplas Subscriptions precisam gerar faturas independentes?'
    when '71000000-0000-4000-8000-000000000098' then 'Como um escopo superior pode se relacionar aos níveis inferiores?'
    when '71000000-0000-4000-8000-000000000100' then 'Uma configuração mais específica sempre sobrescreve a superior?'
    else front_text
  end,
  back_text = case id
    when '71000000-0000-4000-8000-000000000092' then 'Não. Tags do Resource Group ou da Subscription não são herdadas automaticamente. Isso exige configuração, como uma Azure Policy apropriada.'
    when '71000000-0000-4000-8000-000000000093' then 'É um escopo para Resources, acesso, quotas e limites, organização e relação de billing.'
    when '71000000-0000-4000-8000-000000000096' then 'Não. Elas podem compartilhar uma estrutura de billing, embora mantenham escopos administrativos e de custos separados.'
    when '71000000-0000-4000-8000-000000000098' then 'Configurações atribuídas em escopos superiores podem afetar níveis inferiores; o comportamento exato depende do mecanismo usado.'
    when '71000000-0000-4000-8000-000000000100' then 'Não. Policy e RBAC possuem regras próprias; não existe uma regra universal de sobrescrita pela configuração mais específica.'
    else back_text
  end,
  hint = case id
    when '71000000-0000-4000-8000-000000000092' then 'Relação pai/filho não copia tags.'
    when '71000000-0000-4000-8000-000000000093' then 'Escopo administrativo e relação de cobrança.'
    when '71000000-0000-4000-8000-000000000096' then 'Subscription não é sinônimo de invoice.'
    when '71000000-0000-4000-8000-000000000098' then 'Depende do mecanismo.'
    when '71000000-0000-4000-8000-000000000100' then 'Evite regras absolutas.'
    else hint
  end
where id in (
  '71000000-0000-4000-8000-000000000092',
  '71000000-0000-4000-8000-000000000093',
  '71000000-0000-4000-8000-000000000096',
  '71000000-0000-4000-8000-000000000098',
  '71000000-0000-4000-8000-000000000100'
);

update public.questions
set
  question_text = case id
    when '64000000-0000-4000-8000-000000000022' then 'Os Resources contidos no mesmo Resource Group precisam estar obrigatoriamente na mesma Azure Region?'
    when '64000000-0000-4000-8000-000000000023' then 'Uma equipe adicionou a tag Ambiente=Produção a um Resource Group. O que acontece automaticamente com os Resources já existentes no grupo?'
    when '64000000-0000-4000-8000-000000000025' then 'Um Azure Resource pode pertencer simultaneamente a dois Resource Groups?'
    when '65000000-0000-4000-8000-000000000001' then 'Qual definição descreve melhor uma Azure Subscription?'
    when '65000000-0000-4000-8000-000000000003' then 'Uma empresa quer organizar cinco Azure Subscriptions sob um escopo comum de governança. Qual nível deve usar?'
    when '65000000-0000-4000-8000-000000000004' then 'Uma organização usa duas Subscriptions vinculadas à mesma estrutura de billing. Qual afirmação está correta?'
    when '65000000-0000-4000-8000-000000000007' then 'Qual nível da hierarquia contém diretamente os Resource Groups?'
    when '65000000-0000-4000-8000-000000000008' then 'Qual nível fica imediatamente acima das Subscriptions e pode organizá-las?'
    when '65000000-0000-4000-8000-000000000009' then 'Qual sequência apresenta escopos progressivamente mais específicos?'
    when '65000000-0000-4000-8000-000000000010' then 'Uma empresa possui várias Subscriptions, cada uma com projetos organizados em Resource Groups e serviços individuais. Qual estrutura representa corretamente essa organização?'
    else question_text
  end,
  explanation = case id
    when '64000000-0000-4000-8000-000000000022' then 'Resource Group é um container lógico. Os Resources do grupo podem estar em Regions diferentes conforme o suporte e a implantação de cada serviço.'
    when '64000000-0000-4000-8000-000000000023' then 'Tags do Resource Group não são copiadas automaticamente para os Resources. Uma regra específica, como Azure Policy, pode implementar esse comportamento.'
    when '64000000-0000-4000-8000-000000000025' then 'Cada Resource pertence a um Resource Group por vez. Isso não impede que ele se conecte a Resources localizados em outros grupos.'
    when '65000000-0000-4000-8000-000000000001' then 'Subscription é um escopo que contém Resource Groups e participa da organização de Resources, acesso, quotas, limites e relação de billing.'
    when '65000000-0000-4000-8000-000000000003' then 'Management Groups ficam acima das Subscriptions e permitem organizá-las sob um escopo comum de governança.'
    when '65000000-0000-4000-8000-000000000004' then 'Subscriptions podem compartilhar uma estrutura de billing. Elas ainda oferecem separação administrativa, de quotas e de visibilidade de custos, sem exigir invoices independentes.'
    when '65000000-0000-4000-8000-000000000007' then 'A Subscription contém Resource Groups; cada Resource Group organiza os Resources relacionados.'
    when '65000000-0000-4000-8000-000000000008' then 'Management Groups organizam Subscriptions e ficam acima delas na hierarquia de escopos.'
    when '65000000-0000-4000-8000-000000000009' then 'A ordem principal vai do escopo mais amplo ao mais específico: Management Group, Subscription, Resource Group e Resource.'
    when '65000000-0000-4000-8000-000000000010' then 'Management Groups organizam Subscriptions; Subscriptions contêm Resource Groups; Resource Groups organizam os Resources individuais.'
    else explanation
  end
where id in (
  '64000000-0000-4000-8000-000000000022',
  '64000000-0000-4000-8000-000000000023',
  '64000000-0000-4000-8000-000000000025',
  '65000000-0000-4000-8000-000000000001',
  '65000000-0000-4000-8000-000000000003',
  '65000000-0000-4000-8000-000000000004',
  '65000000-0000-4000-8000-000000000007',
  '65000000-0000-4000-8000-000000000008',
  '65000000-0000-4000-8000-000000000009',
  '65000000-0000-4000-8000-000000000010'
);

update public.question_options
set option_text = case id
  when '75000000-0000-4000-8000-000000000085' then 'Não. Resource Group é lógico, e seus Resources podem estar em Regions diferentes.'
  when '75000000-0000-4000-8000-000000000086' then 'Sim. Todo Resource Group corresponde fisicamente a uma única Region.'
  when '75000000-0000-4000-8000-000000000087' then 'Sim. A Region do Resource Group sempre move todos os Resources para ela.'
  when '75000000-0000-4000-8000-000000000088' then 'Não, porque Resource Groups nunca podem conter Resources regionais.'
  when '75000000-0000-4000-8000-000000000089' then 'A tag é copiada imediatamente para todos os Resources sem configuração.'
  when '75000000-0000-4000-8000-000000000090' then 'Nada. Tags não são herdadas automaticamente apenas pela relação com o Resource Group.'
  when '75000000-0000-4000-8000-000000000091' then 'Todos os Resources são recriados para receber a tag.'
  when '75000000-0000-4000-8000-000000000092' then 'O Resource Group é convertido automaticamente em uma Subscription.'
  when '75000000-0000-4000-8000-000000000097' then 'Sim. Todo Resource precisa pertencer a pelo menos dois grupos.'
  when '75000000-0000-4000-8000-000000000098' then 'Não. Cada Resource pertence a um Resource Group por vez.'
  when '75000000-0000-4000-8000-000000000099' then 'Sim, desde que os grupos estejam em Regions diferentes.'
  when '75000000-0000-4000-8000-000000000100' then 'Não, porque Resources existem fora de qualquer Resource Group.'
  when '77000000-0000-4000-8000-000000000001' then 'Um escopo para Resource Groups, acesso, quotas, limites, organização e relação de billing.'
  when '77000000-0000-4000-8000-000000000002' then 'Um servidor físico dedicado que contém todos os Resources da organização.'
  when '77000000-0000-4000-8000-000000000003' then 'Uma invoice que sempre corresponde a exatamente uma forma de pagamento.'
  when '77000000-0000-4000-8000-000000000004' then 'Um Resource Group especial usado somente para armazenar custos.'
  when '77000000-0000-4000-8000-000000000009' then 'Management Group.'
  when '77000000-0000-4000-8000-000000000010' then 'Resource Group.'
  when '77000000-0000-4000-8000-000000000011' then 'Availability Zone.'
  when '77000000-0000-4000-8000-000000000012' then 'Azure Resource individual.'
  when '77000000-0000-4000-8000-000000000013' then 'As duas mantêm escopos administrativos próprios, mas podem compartilhar a estrutura de billing.'
  when '77000000-0000-4000-8000-000000000014' then 'Cada Subscription obrigatoriamente gera uma invoice independente.'
  when '77000000-0000-4000-8000-000000000015' then 'As duas Subscriptions passam a compartilhar quotas e limites automaticamente.'
  when '77000000-0000-4000-8000-000000000016' then 'A relação de billing elimina a possibilidade de separar a visibilidade de custos.'
  when '77000000-0000-4000-8000-000000000025' then 'Subscription.'
  when '77000000-0000-4000-8000-000000000026' then 'Management Group.'
  when '77000000-0000-4000-8000-000000000027' then 'Azure Region.'
  when '77000000-0000-4000-8000-000000000028' then 'Tenant / Root diretamente, sem uma Subscription.'
  when '77000000-0000-4000-8000-000000000029' then 'Resource Group.'
  when '77000000-0000-4000-8000-000000000030' then 'Management Group.'
  when '77000000-0000-4000-8000-000000000031' then 'Resource individual.'
  when '77000000-0000-4000-8000-000000000032' then 'Availability Zone.'
  when '77000000-0000-4000-8000-000000000033' then 'Resource → Management Group → Subscription → Resource Group.'
  when '77000000-0000-4000-8000-000000000034' then 'Management Group → Subscription → Resource Group → Resource.'
  when '77000000-0000-4000-8000-000000000035' then 'Subscription → Resource → Management Group → Resource Group.'
  when '77000000-0000-4000-8000-000000000036' then 'Resource Group → Subscription → Management Group → Resource.'
  when '77000000-0000-4000-8000-000000000037' then 'Subscriptions → Resources → Management Groups → Resource Groups.'
  when '77000000-0000-4000-8000-000000000038' then 'Management Groups → Subscriptions → Resource Groups → Resources.'
  when '77000000-0000-4000-8000-000000000039' then 'Resource Groups → Management Groups → Resources → Subscriptions.'
  when '77000000-0000-4000-8000-000000000040' then 'Resources → Resource Groups → Management Groups → Subscriptions.'
  else option_text
end
where id in (
  '75000000-0000-4000-8000-000000000085', '75000000-0000-4000-8000-000000000086',
  '75000000-0000-4000-8000-000000000087', '75000000-0000-4000-8000-000000000088',
  '75000000-0000-4000-8000-000000000089', '75000000-0000-4000-8000-000000000090',
  '75000000-0000-4000-8000-000000000091', '75000000-0000-4000-8000-000000000092',
  '75000000-0000-4000-8000-000000000097', '75000000-0000-4000-8000-000000000098',
  '75000000-0000-4000-8000-000000000099', '75000000-0000-4000-8000-000000000100',
  '77000000-0000-4000-8000-000000000001', '77000000-0000-4000-8000-000000000002',
  '77000000-0000-4000-8000-000000000003', '77000000-0000-4000-8000-000000000004',
  '77000000-0000-4000-8000-000000000009', '77000000-0000-4000-8000-000000000010',
  '77000000-0000-4000-8000-000000000011', '77000000-0000-4000-8000-000000000012',
  '77000000-0000-4000-8000-000000000013', '77000000-0000-4000-8000-000000000014',
  '77000000-0000-4000-8000-000000000015', '77000000-0000-4000-8000-000000000016',
  '77000000-0000-4000-8000-000000000025', '77000000-0000-4000-8000-000000000026',
  '77000000-0000-4000-8000-000000000027', '77000000-0000-4000-8000-000000000028',
  '77000000-0000-4000-8000-000000000029', '77000000-0000-4000-8000-000000000030',
  '77000000-0000-4000-8000-000000000031', '77000000-0000-4000-8000-000000000032',
  '77000000-0000-4000-8000-000000000033', '77000000-0000-4000-8000-000000000034',
  '77000000-0000-4000-8000-000000000035', '77000000-0000-4000-8000-000000000036',
  '77000000-0000-4000-8000-000000000037', '77000000-0000-4000-8000-000000000038',
  '77000000-0000-4000-8000-000000000039', '77000000-0000-4000-8000-000000000040'
);

do $$
begin
  if (select count(*) from resource_hierarchy_block_seed) <> 23 then
    raise exception '8.5.5 block seed count is invalid';
  end if;

  if (select count(*) from public.lesson_content_blocks where lesson_id = '40000000-0000-4000-8000-000000000006' and is_published) <> 7
    or (select count(*) from public.lesson_content_blocks where lesson_id = '40000000-0000-4000-8000-000000000007' and is_published) <> 8
    or (select count(*) from public.lesson_content_blocks where lesson_id = '98880411-d0cb-47d7-a278-ae295552ad5f' and is_published) <> 8 then
    raise exception '8.5.5 published Content Block counts are invalid';
  end if;

  if (select count(*) from public.visual_experiences where lesson_id = '98880411-d0cb-47d7-a278-ae295552ad5f') <> 1
    or (select count(*) from public.visual_experiences where lesson_id in ('40000000-0000-4000-8000-000000000006','40000000-0000-4000-8000-000000000007')) <> 0 then
    raise exception '8.5.5 must create exactly one Visual Experience on the hierarchy Lesson';
  end if;

  if (select count(*) from public.flashcards where lesson_id in ('40000000-0000-4000-8000-000000000006','40000000-0000-4000-8000-000000000007','98880411-d0cb-47d7-a278-ae295552ad5f') and is_published) <> 15
    or (select count(*) from public.questions where lesson_id in ('40000000-0000-4000-8000-000000000006','40000000-0000-4000-8000-000000000007','98880411-d0cb-47d7-a278-ae295552ad5f') and is_published) <> 16 then
    raise exception '8.5.5 practice counts changed unexpectedly';
  end if;
end;
$$;

commit;

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
    and lesson.slug = 'region-pairs-and-sovereign-regions';

  if target_lesson_id <> '79f8ca50-0ec9-4dda-bade-9b6d918a913c' then
    raise exception 'Unexpected Region Pairs and Sovereign Regions Lesson UUID';
  end if;

  if exists (
    select 1
    from public.lesson_content_blocks
    where lesson_id = target_lesson_id
  ) then
    raise exception 'Region Pairs and Sovereign Regions already contains Content Blocks outside the 8.5.4 seed';
  end if;

  if exists (
    select 1
    from public.visual_experiences
    where lesson_id = target_lesson_id
  ) then
    raise exception '8.5.4 must not create or reuse a Visual Experience';
  end if;
end;
$$;

create temporary table region_pair_block_seed (
  id uuid primary key,
  type text not null,
  title text,
  content text,
  config jsonb,
  visual_experience_id uuid,
  display_order integer not null,
  is_published boolean not null
) on commit drop;

insert into region_pair_block_seed (
  id, type, title, content, config, visual_experience_id, display_order, is_published
)
values
  (
    '7b040000-0000-4000-8000-000000000001',
    'explanation',
    'Region Pairs',
    $content$Azure Regions são independentes. A Microsoft associa algumas delas a outra Region, normalmente dentro da mesma geography, formando um Region Pair.

Essa associação é definida pela Microsoft: o cliente não escolhe arbitrariamente duas Regions e as transforma em um par oficial. Alguns Azure services usam o par definido para recursos de geo-replication, geo-redundancy ou partes de uma estratégia de disaster recovery.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000002',
    'important',
    'Paired e nonpaired regions',
    $content$Nem toda Azure Region possui um Region Pair. Existem paired regions e nonpaired regions.

Uma nonpaired region não é uma Region sem resiliência. Conforme o suporte disponível e a arquitetura escolhida, Availability Zones e capacidades multi-region podem oferecer opções de redundância e recuperação mesmo quando as Regions não formam um par oficial.$content$,
    null,
    null,
    2,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000003',
    'example',
    'Quando um serviço usa o par',
    $content$Considere um serviço de armazenamento configurado em um modo compatível de geo-redundância. Esse serviço pode usar o Region Pair para manter uma cópia em outra Region.

O comportamento vem da capacidade do serviço e da configuração selecionada. Apenas implantar um recurso em uma Region pareada não cria uma cópia nem habilita failover por conta própria.$content$,
    null,
    null,
    3,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000004',
    'exam_trap',
    'Region Pair não é automação universal',
    $content$Region Pair não significa replicação automática de qualquer recurso, backup automático, failover automático de qualquer aplicação, disaster recovery pronto ou alta disponibilidade garantida.

O resultado depende do Azure service, da configuração e da arquitetura adotada. Em questões de prova, procure essas informações antes de concluir que o pareamento sozinho protege a workload.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000005',
    'explanation',
    'Sovereign Regions',
    $content$Sovereign Regions pertencem a ambientes ou geographies de sovereign cloud criados para atender requisitos específicos, especialmente de governos e regulamentação. Esses ambientes podem ter isolamento físico ou operacional, regras próprias de elegibilidade e compromissos específicos de compliance e residência de dados.

O conceito descreve uma oferta Azure separada ou especialmente operada para esses cenários, e não apenas uma Region comum escolhida no Azure público global.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000006',
    'important',
    'Serviços e recursos podem variar',
    $content$Uma sovereign cloud pode usar tecnologias semelhantes às do Azure público global, mas endpoints, operação, disponibilidade de serviços, features e limitações podem ser diferentes.

Por isso, um requisito soberano deve ser avaliado contra a oferta e a documentação aplicáveis. Não presuma que todo serviço ou feature do Azure público esteja disponível da mesma forma.$content$,
    null,
    null,
    6,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000007',
    'exam_trap',
    'Soberania não é sinônimo de data residency',
    $content$Sovereign Region não é qualquer Region escolhida para manter dados em um país ou geography. Da mesma forma, um requisito de data residency não exige automaticamente uma sovereign cloud.

Uma organização pode atender residência de dados usando Regions do Azure público na geography necessária. Sovereign clouds são voltadas a cenários específicos com requisitos adicionais de governo, regulamentação, isolamento ou operação.$content$,
    null,
    null,
    7,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000008',
    'exam_tip',
    'Separe a finalidade dos conceitos',
    $content$Se o enunciado fala de uma associação definida pela Microsoft entre algumas Regions e de capacidades geo-redundantes de um serviço, pense em Region Pair — sem presumir automação.

Se o cenário destaca requisitos específicos de governo, regulamentação ou isolamento operacional, avalie uma sovereign cloud. Residência geográfica por si só não basta para essa conclusão.$content$,
    null,
    null,
    8,
    true
  ),
  (
    '7b040000-0000-4000-8000-000000000009',
    'summary',
    'Resumo',
    null,
    $json${"items": ["A Microsoft associa algumas Azure Regions em Region Pairs, normalmente dentro da mesma geography.", "O cliente não escolhe arbitrariamente quais Regions formam um par oficial.", "Existem paired e nonpaired regions; ambas podem participar de arquiteturas resilientes.", "Region Pair não habilita automaticamente replicação, backup, failover ou disaster recovery.", "Sovereign Regions atendem cenários específicos de governo, regulamentação, isolamento ou operação.", "Data residency não significa automaticamente que uma sovereign cloud seja necessária."]}$json$::jsonb,
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
    and lesson.slug = 'region-pairs-and-sovereign-regions'
)
insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, visual_experience_id,
  display_order, is_published
)
select
  seed.id, lesson.id, seed.type, seed.title, seed.content, seed.config,
  seed.visual_experience_id, seed.display_order, seed.is_published
from region_pair_block_seed seed
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
where id = '79f8ca50-0ec9-4dda-bade-9b6d918a913c'
  and slug = 'region-pairs-and-sovereign-regions'
  and topic_id = '30000000-0000-4000-8000-000000000002';

update public.flashcards
set
  front_text = case id
    when '71000000-0000-4000-8000-000000000085' then 'O que é um Azure Region Pair?'
    when '71000000-0000-4000-8000-000000000086' then 'Uma nonpaired region fica sem opções de resiliência?'
    when '71000000-0000-4000-8000-000000000087' then 'Para que alguns Azure services usam Region Pairs?'
    when '71000000-0000-4000-8000-000000000088' then 'O que distingue uma Sovereign Region de uma Region comum escolhida por data residency?'
    else front_text
  end,
  back_text = case id
    when '71000000-0000-4000-8000-000000000085' then 'É a associação, definida pela Microsoft, entre algumas Azure Regions, normalmente na mesma geography. O cliente não escolhe o par oficial.'
    when '71000000-0000-4000-8000-000000000086' then 'Não. Availability Zones e capacidades multi-region podem ser usadas conforme o suporte e a arquitetura.'
    when '71000000-0000-4000-8000-000000000087' then 'Alguns usam o par para geo-replication, geo-redundancy ou aspectos de disaster recovery. Nada disso é automático para todo recurso.'
    when '71000000-0000-4000-8000-000000000088' then 'Ela pertence a uma sovereign cloud voltada a requisitos específicos de governo, regulamentação ou isolamento. Data residency, por si só, não exige sovereign cloud.'
    else back_text
  end,
  hint = case id
    when '71000000-0000-4000-8000-000000000085' then 'Algumas Regions; associação da Microsoft.'
    when '71000000-0000-4000-8000-000000000086' then 'Nonpaired não significa sem resiliência.'
    when '71000000-0000-4000-8000-000000000087' then 'Depende do serviço e da configuração.'
    when '71000000-0000-4000-8000-000000000088' then 'Requisitos soberanos são mais específicos.'
    else hint
  end
where id in (
  '71000000-0000-4000-8000-000000000085',
  '71000000-0000-4000-8000-000000000086',
  '71000000-0000-4000-8000-000000000087',
  '71000000-0000-4000-8000-000000000088'
);

update public.questions
set
  question_text = case id
    when '64000000-0000-4000-8000-000000000016' then 'Qual afirmação define corretamente um Azure Region Pair?'
    when '64000000-0000-4000-8000-000000000017' then 'O que caracteriza uma Sovereign Region no Azure?'
    when '64000000-0000-4000-8000-000000000018' then 'Uma equipe descobriu que a Azure Region escolhida é nonpaired. Qual conclusão está correta?'
    when '64000000-0000-4000-8000-000000000019' then 'Uma empresa precisa manter dados em uma geography específica, mas não possui requisitos governamentais ou de isolamento soberano. Qual análise é mais adequada?'
    when '64000000-0000-4000-8000-000000000020' then 'Uma aplicação foi implantada em uma Region que possui um Region Pair, mas nenhuma replicação ou estratégia de failover foi configurada. O que o pareamento garante por si só?'
    else question_text
  end,
  explanation = case id
    when '64000000-0000-4000-8000-000000000016' then 'A Microsoft associa algumas Regions, normalmente dentro da mesma geography. O cliente pode escolher onde implantar, mas não define arbitrariamente um Region Pair oficial.'
    when '64000000-0000-4000-8000-000000000017' then 'Sovereign Regions fazem parte de ofertas voltadas a requisitos específicos de governos ou regulamentação e podem ter isolamento, operação e disponibilidade de serviços diferentes do Azure público global.'
    when '64000000-0000-4000-8000-000000000018' then 'Nonpaired não significa sem resiliência. Availability Zones e recursos multi-region podem ser usados quando o serviço, a Region e a arquitetura oferecem suporte.'
    when '64000000-0000-4000-8000-000000000019' then 'Residência de dados pode ser atendida por Regions comuns do Azure público dentro da geography adequada. Uma sovereign cloud só deve ser concluída quando o cenário trouxer requisitos soberanos adicionais.'
    when '64000000-0000-4000-8000-000000000020' then 'O Region Pair é uma associação da Microsoft, não uma configuração da workload. Replicação, backup, failover e disaster recovery dependem do serviço, da configuração e da arquitetura.'
    else explanation
  end
where id in (
  '64000000-0000-4000-8000-000000000016',
  '64000000-0000-4000-8000-000000000017',
  '64000000-0000-4000-8000-000000000018',
  '64000000-0000-4000-8000-000000000019',
  '64000000-0000-4000-8000-000000000020'
);

update public.question_options
set option_text = case id
  when '75000000-0000-4000-8000-000000000061' then 'Uma associação definida pela Microsoft entre algumas Regions, normalmente dentro da mesma geography.'
  when '75000000-0000-4000-8000-000000000062' then 'Uma associação automática existente entre todas as Azure Regions.'
  when '75000000-0000-4000-8000-000000000063' then 'Qualquer conjunto de duas Regions escolhido pelo cliente.'
  when '75000000-0000-4000-8000-000000000064' then 'Duas Availability Zones dentro da mesma Region.'
  when '75000000-0000-4000-8000-000000000065' then 'Uma Region de uma sovereign cloud voltada a requisitos específicos de governo ou regulamentação.'
  when '75000000-0000-4000-8000-000000000066' then 'Qualquer Region pública escolhida para manter dados em uma geography.'
  when '75000000-0000-4000-8000-000000000067' then 'Uma Region que necessariamente oferece todos os serviços do Azure público global.'
  when '75000000-0000-4000-8000-000000000068' then 'Outro nome para toda Private Cloud administrada por uma organização.'
  when '75000000-0000-4000-8000-000000000069' then 'A solução ainda pode usar Availability Zones e recursos multi-region conforme o suporte e a arquitetura.'
  when '75000000-0000-4000-8000-000000000070' then 'A Region não pode participar de nenhuma arquitetura resiliente.'
  when '75000000-0000-4000-8000-000000000071' then 'A Microsoft criará automaticamente um novo Region Pair para a workload.'
  when '75000000-0000-4000-8000-000000000072' then 'A Region passa automaticamente a ser uma Sovereign Region.'
  when '75000000-0000-4000-8000-000000000073' then 'Todo requisito de data residency obriga o uso de uma sovereign cloud.'
  when '75000000-0000-4000-8000-000000000074' then 'Regions públicas na geography necessária podem atender a residência; soberania exige requisitos adicionais.'
  when '75000000-0000-4000-8000-000000000075' then 'Somente um Region Pair garante residência de dados, sem avaliar o serviço.'
  when '75000000-0000-4000-8000-000000000076' then 'O requisito só pode ser atendido em infraestrutura on-premises.'
  when '75000000-0000-4000-8000-000000000077' then 'Replicação automática de todos os recursos para a Region pareada.'
  when '75000000-0000-4000-8000-000000000078' then 'Nenhuma dessas capacidades automaticamente; elas dependem do serviço, da configuração e da arquitetura.'
  when '75000000-0000-4000-8000-000000000079' then 'Failover automático de toda a aplicação durante qualquer interrupção.'
  when '75000000-0000-4000-8000-000000000080' then 'Backup e disaster recovery completos sem configuração adicional.'
  else option_text
end
where id between '75000000-0000-4000-8000-000000000061'
             and '75000000-0000-4000-8000-000000000080';

do $$
declare
  target_lesson_id uuid := '79f8ca50-0ec9-4dda-bade-9b6d918a913c';
begin
  if (select count(*) from region_pair_block_seed) <> 9
    or (select count(*) from public.lesson_content_blocks where lesson_id = target_lesson_id and is_published) <> 9 then
    raise exception '8.5.4 expected nine published Content Blocks';
  end if;

  if (select count(*) from public.flashcards where lesson_id = target_lesson_id and is_published) <> 4
    or (select count(*) from public.questions where lesson_id = target_lesson_id and is_published) <> 5 then
    raise exception 'Region Pairs and Sovereign Regions practice counts changed unexpectedly';
  end if;

  if exists (
    select 1
    from public.visual_experiences
    where lesson_id = target_lesson_id
  ) then
    raise exception '8.5.4 must preserve zero Visual Experiences for this Lesson';
  end if;
end;
$$;

commit;

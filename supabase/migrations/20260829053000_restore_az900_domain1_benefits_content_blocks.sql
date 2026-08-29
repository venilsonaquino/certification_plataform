begin;

do $$
begin
  if (select count(*)
      from public.lessons lesson
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900'
        and domain.title = 'Describe cloud concepts'
        and topic.title = 'Benefits of Cloud Services'
        and lesson.slug in ('high-availability','scalability','elasticity','reliability','predictability')) <> 5 then
    raise exception '10.2 expected exactly five target Lessons';
  end if;

  if exists (
    select 1 from public.lessons lesson
    where lesson.id in (
      '40000000-0000-4000-8000-000000000002',
      '8e04bfc9-03a6-4ae4-be9c-e7238e5c2783',
      'a7bb4f85-9cc1-46ad-9f65-44f978abf851',
      'b74f3c89-867f-409e-b5b2-8ad1713c1428',
      'e709cd4e-c17a-469e-b7a8-70271c79e52e'
    ) and (not lesson.is_published or lesson.content is null or btrim(lesson.content) = '')
  ) then
    raise exception '10.2 target Lesson publication/fallback precondition failed';
  end if;

  if exists (
    select 1 from public.lesson_content_blocks block
    where block.lesson_id in (
      '40000000-0000-4000-8000-000000000002',
      '8e04bfc9-03a6-4ae4-be9c-e7238e5c2783',
      'a7bb4f85-9cc1-46ad-9f65-44f978abf851',
      'b74f3c89-867f-409e-b5b2-8ad1713c1428',
      'e709cd4e-c17a-469e-b7a8-70271c79e52e'
    )
  ) then
    raise exception '10.2 is additive and requires zero existing blocks in every target Lesson';
  end if;

  if exists (
    select 1 from public.lessons lesson
    where lesson.id in (
      '40000000-0000-4000-8000-000000000002',
      '8e04bfc9-03a6-4ae4-be9c-e7238e5c2783',
      'a7bb4f85-9cc1-46ad-9f65-44f978abf851',
      'b74f3c89-867f-409e-b5b2-8ad1713c1428',
      'e709cd4e-c17a-469e-b7a8-70271c79e52e'
    ) and (
      (select count(*) from public.flashcards card where card.lesson_id = lesson.id and card.is_published) <> 4
      or (select count(*) from public.questions question where question.lesson_id = lesson.id and question.is_published) <> 10
    )
  ) then
    raise exception '10.2 practice baseline changed before content restoration';
  end if;
end;
$$;

insert into public.lesson_content_blocks
  (id, lesson_id, type, title, content, config, visual_experience_id, display_order, is_published)
values
  ('7b300000-0000-4000-8000-000000000001','40000000-0000-4000-8000-000000000002','explanation','O que é High Availability?',
   $block$High Availability é a capacidade de manter um serviço disponível mesmo quando componentes individuais apresentam falhas. Na nuvem, isso costuma envolver redundância e recursos capazes de continuar atendendo enquanto o componente afetado é reparado ou substituído.$block$,null,null,1,true),
  ('7b300000-0000-4000-8000-000000000002','40000000-0000-4000-8000-000000000002','important','Redundância reduz pontos únicos de falha',
   $block$Múltiplas instâncias ou cópias de componentes podem reduzir o impacto de uma falha. Essa tolerância conceitual a falhas ajuda a minimizar downtime, mas depende do desenho e da configuração da solução; apenas usar cloud não torna uma aplicação altamente disponível.$block$,null,null,2,true),
  ('7b300000-0000-4000-8000-000000000003','40000000-0000-4000-8000-000000000002','example','Uma instância falha; outra continua',
   $block$Uma aplicação possui várias instâncias atendendo usuários. Se uma instância falhar, as demais podem continuar processando requisições. O serviço permanece acessível enquanto a instância com falha é recuperada.$block$,null,null,3,true),
  ('7b300000-0000-4000-8000-000000000004','40000000-0000-4000-8000-000000000002','important','High Availability versus Reliability',
   $block$High Availability pergunta como manter o serviço acessível e reduzir downtime. Reliability é mais ampla: considera operar corretamente e recuperar-se de falhas ao longo do tempo. Os conceitos se relacionam, mas não são sinônimos.$block$,null,null,4,true),
  ('7b300000-0000-4000-8000-000000000005','40000000-0000-4000-8000-000000000002','exam_tip','Procure disponibilidade durante uma falha',
   $block$Se o cenário destaca múltiplas instâncias e continuidade do atendimento quando uma delas falha, High Availability e redundância são os conceitos centrais. SLA é relacionado à disponibilidade, mas não é necessário calcular percentuais nesta Lesson.$block$,null,null,5,true),
  ('7b300000-0000-4000-8000-000000000006','40000000-0000-4000-8000-000000000002','exam_trap','Alta disponibilidade não elimina falhas',
   $block$High Availability busca minimizar interrupções; ela não promete zero downtime e não impede que componentes falhem. O objetivo é limitar o impacto da falha sobre o acesso ao serviço.$block$,null,null,6,true),
  ('7b300000-0000-4000-8000-000000000007','40000000-0000-4000-8000-000000000002','summary','Resumo para memória ativa',null,
   '{"items":["High Availability mantém o serviço acessível apesar de falhas individuais.","Redundância e múltiplas instâncias reduzem pontos únicos de falha.","O foco é minimizar downtime, não eliminar toda falha.","High Availability e Reliability se relacionam, mas têm focos diferentes."]}'::jsonb,null,7,true),

  ('7b300000-0000-4000-8000-000000000008','8e04bfc9-03a6-4ae4-be9c-e7238e5c2783','explanation','O que é Scalability?',
   $block$Scalability é a capacidade de aumentar ou diminuir recursos para atender mudanças de demanda. O ajuste pode ocorrer alterando a capacidade de um recurso existente ou modificando a quantidade de instâncias.$block$,null,null,1,true),
  ('7b300000-0000-4000-8000-000000000009','8e04bfc9-03a6-4ae4-be9c-e7238e5c2783','important','Scale up/down e scale out/in',
   $block$Scale up aumenta a capacidade de um recurso existente, como adicionar CPU ou RAM; scale down reduz essa capacidade. Scale out adiciona instâncias, como passar de duas VMs para quatro; scale in remove instâncias.$block$,null,null,2,true),
  ('7b300000-0000-4000-8000-000000000010','8e04bfc9-03a6-4ae4-be9c-e7238e5c2783','example','VM maior ou mais VMs',
   $block$Trocar uma VM por um tamanho com mais CPU e memória é scale up. Adicionar novas VMs para dividir o tráfego é scale out. A escolha depende da arquitetura, dos limites do recurso e do padrão de demanda.$block$,null,null,3,true),
  ('7b300000-0000-4000-8000-000000000011','8e04bfc9-03a6-4ae4-be9c-e7238e5c2783','important','Scalability versus Elasticity',
   $block$Scalability descreve a capacidade de ajustar recursos. Elasticity enfatiza que o ajuste acompanha dinamicamente a demanda, crescendo e reduzindo quando necessário. Uma solução pode ser escalável sem realizar esse ajuste automaticamente.$block$,null,null,4,true),
  ('7b300000-0000-4000-8000-000000000012','8e04bfc9-03a6-4ae4-be9c-e7238e5c2783','exam_tip','Identifique o que mudou',
   $block$Mais capacidade na mesma instância aponta para vertical scaling. Mais instâncias apontam para horizontal scaling. Os pares são scale up/down e scale out/in.$block$,null,null,5,true),
  ('7b300000-0000-4000-8000-000000000013','8e04bfc9-03a6-4ae4-be9c-e7238e5c2783','exam_trap','Scalability não é Elasticity',
   $block$Não conclua que todo ajuste escalável é automático. Scalability é a capacidade de crescer ou reduzir; Elasticity acrescenta a adaptação dinâmica conforme a demanda.$block$,null,null,6,true),
  ('7b300000-0000-4000-8000-000000000014','8e04bfc9-03a6-4ae4-be9c-e7238e5c2783','summary','Resumo para memória ativa',null,
   '{"items":["Scalability ajusta capacidade para mudanças de demanda.","Scale up/down altera a capacidade de um recurso existente.","Scale out/in altera a quantidade de instâncias.","Scalability não implica ajuste automático."]}'::jsonb,null,7,true),

  ('7b300000-0000-4000-8000-000000000015','a7bb4f85-9cc1-46ad-9f65-44f978abf851','explanation','O que é Elasticity?',
   $block$Elasticity é a capacidade de ajustar recursos dinamicamente em resposta à demanda: recursos podem aumentar quando a demanda sobe e diminuir quando ela cai. Isso ajuda a alinhar capacidade e consumo ao que a carga precisa em cada período.$block$,null,null,1,true),
  ('7b300000-0000-4000-8000-000000000016','a7bb4f85-9cc1-46ad-9f65-44f978abf851','important','Demanda e recursos acompanham-se',
   $block$`Demand ↑ → Resources ↑` e `Demand ↓ → Resources ↓`. O ajuste pode ser automático quando o serviço e as regras apropriadas estão configurados; não presuma que todo serviço Azure se ajusta sozinho.$block$,null,null,2,true),
  ('7b300000-0000-4000-8000-000000000017','a7bb4f85-9cc1-46ad-9f65-44f978abf851','example','Pico de acessos no e-commerce',
   $block$Durante uma campanha, um e-commerce recebe um pico de acessos e recursos adicionais são alocados. Depois da campanha, a demanda cai e os recursos são reduzidos. Esse ajuste dinâmico é um cenário de Elasticity.$block$,null,null,3,true),
  ('7b300000-0000-4000-8000-000000000018','a7bb4f85-9cc1-46ad-9f65-44f978abf851','important','Elasticity versus Scalability',
   $block$Scalability responde “consigo aumentar ou reduzir capacidade?”. Elasticity responde “consigo ajustar essa capacidade dinamicamente conforme a demanda?”. Elasticity usa a capacidade de escalar, mas destaca o comportamento adaptativo.$block$,null,null,4,true),
  ('7b300000-0000-4000-8000-000000000019','a7bb4f85-9cc1-46ad-9f65-44f978abf851','exam_tip','Procure crescimento e redução dinâmicos',
   $block$Picos temporários, aumento de recursos quando o tráfego sobe e redução após o pico apontam para Elasticity. Se a pergunta menciona apenas adicionar CPU ou instâncias, pode estar testando Scalability.$block$,null,null,5,true),
  ('7b300000-0000-4000-8000-000000000020','a7bb4f85-9cc1-46ad-9f65-44f978abf851','exam_trap','Elasticity requer capacidade e configuração adequadas',
   $block$Cloud não significa que todo recurso escala automaticamente. O serviço precisa oferecer o mecanismo apropriado e, em muitos casos, regras ou configurações definem quando e como ajustar capacidade.$block$,null,null,6,true),
  ('7b300000-0000-4000-8000-000000000021','a7bb4f85-9cc1-46ad-9f65-44f978abf851','summary','Resumo para memória ativa',null,
   '{"items":["Elasticity ajusta recursos dinamicamente conforme a demanda.","Recursos podem crescer no pico e diminuir depois dele.","Elasticity enfatiza adaptação; Scalability enfatiza capacidade de ajuste.","Nem todo serviço escala automaticamente sem configuração."]}'::jsonb,null,7,true),

  ('7b300000-0000-4000-8000-000000000022','b74f3c89-867f-409e-b5b2-8ad1713c1428','explanation','O que é Reliability?',
   $block$Reliability é a capacidade de um sistema continuar funcionando corretamente e recuperar-se de falhas ao longo do tempo. Um desenho resiliente usa mecanismos adequados para limitar impactos e restaurar operação ou dados quando necessário.$block$,null,null,1,true),
  ('7b300000-0000-4000-8000-000000000023','b74f3c89-867f-409e-b5b2-8ad1713c1428','important','Resiliência, redundância e recuperação',
   $block$Redundância oferece componentes alternativos; recuperação ajuda a restaurar serviço ou dados; resiliência permite suportar e responder a falhas. Juntos, esses conceitos contribuem para continuidade e comportamento correto.$block$,null,null,2,true),
  ('7b300000-0000-4000-8000-000000000024','b74f3c89-867f-409e-b5b2-8ad1713c1428','example','Recuperar serviço e dados',
   $block$Um componente falha. A solução continua com um componente redundante e utiliza mecanismos de recuperação para restaurar o estado esperado. Reliability considera tanto continuar entregando o resultado correto quanto recuperar-se do incidente.$block$,null,null,3,true),
  ('7b300000-0000-4000-8000-000000000025','b74f3c89-867f-409e-b5b2-8ad1713c1428','important','Reliability versus High Availability',
   $block$High Availability foca manter acesso ao serviço e reduzir downtime. Reliability tem foco mais amplo: operar corretamente e recuperar-se de falhas ao longo do tempo. Redundância pode apoiar os dois benefícios.$block$,null,null,4,true),
  ('7b300000-0000-4000-8000-000000000026','b74f3c89-867f-409e-b5b2-8ad1713c1428','exam_tip','Procure recuperação e operação correta',
   $block$Quando o cenário destaca resiliência, restauração, redundância e recuperação após falhas, Reliability é o benefício principal. Quando destaca manter o acesso e minimizar downtime, pense primeiro em High Availability.$block$,null,null,5,true),
  ('7b300000-0000-4000-8000-000000000027','b74f3c89-867f-409e-b5b2-8ad1713c1428','exam_trap','Cloud não elimina falhas',
   $block$Reliability não significa que falhas deixam de acontecer. Ela depende de desenho resiliente e mecanismos de recuperação; usar cloud, por si só, não garante que uma aplicação seja confiável.$block$,null,null,6,true),
  ('7b300000-0000-4000-8000-000000000028','b74f3c89-867f-409e-b5b2-8ad1713c1428','summary','Resumo para memória ativa',null,
   '{"items":["Reliability é operar corretamente e recuperar-se de falhas.","Resiliência, redundância e recuperação contribuem para Reliability.","High Availability foca acesso e downtime; Reliability é mais ampla.","Cloud reduz riscos quando bem projetada, mas não elimina falhas."]}'::jsonb,null,7,true),

  ('7b300000-0000-4000-8000-000000000029','e709cd4e-c17a-469e-b7a8-70271c79e52e','explanation','O que é Predictability?',
   $block$Predictability é a capacidade de antecipar melhor o comportamento de uma solução cloud. Em Cloud Concepts, ela inclui prever performance com base em recursos, dimensionamento e dados observados, além de estimar e acompanhar custos.$block$,null,null,1,true),
  ('7b300000-0000-4000-8000-000000000030','e709cd4e-c17a-469e-b7a8-70271c79e52e','important','Performance e Cost Predictability',
   $block$Performance predictability ajuda a planejar capacidade e comportamento usando dimensionamento, monitoramento e scaling. Cost predictability ajuda a estimar, acompanhar e planejar gastos usando modelos de preço e consumo observado.$block$,null,null,2,true),
  ('7b300000-0000-4000-8000-000000000031','e709cd4e-c17a-469e-b7a8-70271c79e52e','example','Planejar uma aplicação para uma campanha',
   $block$Uma equipe estima a carga esperada, dimensiona recursos e acompanha métricas para planejar performance. Também estima o consumo e monitora gastos. As duas análises aumentam previsibilidade, sem garantir resultado fixo ou ilimitado.$block$,null,null,3,true),
  ('7b300000-0000-4000-8000-000000000032','e709cd4e-c17a-469e-b7a8-70271c79e52e','important','Conexões com outros conceitos',
   $block$Scaling e monitoramento apoiam performance predictability. Consumption e modelos de preço apoiam cost predictability. Pricing Calculator ajuda a estimar antes da implantação; Cost Management acompanha e controla gastos depois, sem precisar aprofundar essas ferramentas aqui.$block$,null,null,4,true),
  ('7b300000-0000-4000-8000-000000000033','e709cd4e-c17a-469e-b7a8-70271c79e52e','exam_tip','Identifique a dimensão pedida',
   $block$Dimensionamento, carga e comportamento técnico apontam para performance predictability. Estimativa, consumo e planejamento de gastos apontam para cost predictability. Uma mesma solução pode exigir as duas análises.$block$,null,null,5,true),
  ('7b300000-0000-4000-8000-000000000034','e709cd4e-c17a-469e-b7a8-70271c79e52e','exam_trap','Predictability não é garantia universal',
   $block$Predictability não significa preço fixo universal nem performance infinita. Mudanças de uso, configuração, demanda e modelo de cobrança continuam afetando custo e desempenho.$block$,null,null,6,true),
  ('7b300000-0000-4000-8000-000000000035','e709cd4e-c17a-469e-b7a8-70271c79e52e','summary','Resumo para memória ativa',null,
   '{"items":["Predictability cobre performance e custos.","Dimensionamento, scaling e monitoramento apoiam performance predictability.","Consumo, modelos de preço e acompanhamento apoiam cost predictability.","Predictability não garante preço fixo nem performance infinita."]}'::jsonb,null,7,true);

do $$
begin
  if (select count(*) from public.lesson_content_blocks
      where id between '7b300000-0000-4000-8000-000000000001' and '7b300000-0000-4000-8000-000000000035') <> 35 then
    raise exception '10.2 failed to persist all 35 deterministic Content Blocks';
  end if;
end;
$$;

commit;

begin;

do $$
declare target_count integer;
begin
  select count(*) into target_count
  from public.lessons lesson
  join public.topics topic on topic.id=lesson.topic_id
  join public.domains domain on domain.id=topic.domain_id
  join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900' and domain.title='Describe Azure management and governance'
    and topic.id='33000000-0000-4000-8000-000000000001' and topic.title='Cost Management'
    and lesson.slug in ('azure-cost-factors','pricing-calculator');
  if target_count<>2 then raise exception '9.2 expected two existing target Lessons'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000001'
      and lesson.slug in ('azure-cost-factors','pricing-calculator')) then
    raise exception '9.2 expected target Lessons without Content Blocks';
  end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000001'
      and lesson.slug in ('azure-cost-factors','pricing-calculator')) then
    raise exception '9.2 must not create or reuse a Visual Experience';
  end if;
  if exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
    where lesson.topic_id='33000000-0000-4000-8000-000000000001'
      and lesson.slug in ('azure-cost-factors','pricing-calculator')) then
    raise exception '9.2 expected target Lessons without Flashcards';
  end if;
  if (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000001' and lesson.slug='azure-cost-factors')<>10
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000001' and lesson.slug='pricing-calculator')<>0
    or (select count(*) from public.questions where id between '63000000-0000-4000-8000-000000000061'
      and '63000000-0000-4000-8000-000000000070')<>10 then
    raise exception '9.2 historical Question inventory is invalid';
  end if;
end; $$;

update public.lessons set estimated_minutes=case slug when 'azure-cost-factors' then 12 else 10 end
where topic_id='33000000-0000-4000-8000-000000000001'
  and slug in ('azure-cost-factors','pricing-calculator');

create temporary table stage_92_block_seed(
  id uuid primary key,lesson_slug text not null,type text not null,title text,content text,config jsonb,
  visual_experience_id uuid,display_order integer not null
) on commit drop;
insert into stage_92_block_seed values
('7b200000-0000-4000-8000-000000000001','azure-cost-factors','explanation','Por que o custo varia?',
$content$O custo de uma solução Azure não depende somente do nome do serviço. Tipo de recurso, quantidade, configuração e consumo trabalham juntos.

**Mesmo serviço + configuração ou uso diferente = custo diferente.** Para AZ-900, reconheça os fatores e compare cenários; não memorize preços.$content$,null,null,1),
('7b200000-0000-4000-8000-000000000002','azure-cost-factors','important','Os fatores principais',
$content$- tipo de recurso e serviço escolhido;
- quantidade de recursos provisionados;
- configuração, tamanho, tier ou capacidade;
- tempo de utilização e consumo medido;
- Azure Region;
- tráfego e transferência de dados;
- modelo de preço e opções de compra aplicáveis.

O impacto exato depende do serviço e do cenário.$content$,null,null,2),
('7b200000-0000-4000-8000-000000000003','azure-cost-factors','explanation','Consumo, tempo e unidades provisionadas',
$content$Muitos serviços usam métricas relacionadas ao consumo. Exemplos conceituais incluem horas de compute, quantidade armazenada, volume ou número de operações, transferência de dados e unidades provisionadas.

Alguns componentes variam com uso real; outros dependem da capacidade reservada ou provisionada. Por isso, “consumption-based” não significa que todos os recursos usam a mesma unidade de cobrança.$content$,null,null,3),
('7b200000-0000-4000-8000-000000000004','azure-cost-factors','example','Quantidade e configuração mudam a estimativa',
$content$Uma aplicação pode usar duas VMs pequenas ou várias instâncias maiores. A quantidade de VMs, o VM size e o tempo em execução influenciam a estimativa.

O mesmo raciocínio vale para armazenamento: quantidade de dados, tier e operações podem alterar o custo conforme o serviço.$content$,null,null,4),
('7b200000-0000-4000-8000-000000000005','azure-cost-factors','exam_trap','Parar compute não elimina necessariamente todo custo',
$content$Parar ou desalocar compute pode reduzir a cobrança daquele componente, conforme o recurso, mas recursos associados podem continuar gerando custo. Discos e outros itens provisionados são exemplos possíveis.

**Parar um recurso ≠ eliminar automaticamente todo o custo da solução.**$content$,null,null,5),
('7b200000-0000-4000-8000-000000000006','azure-cost-factors','explanation','Azure Region pode afetar preço',
$content$O mesmo serviço e configuração podem ter preços diferentes conforme a Azure Region escolhida.

A decisão de região não deve usar somente custo. Requisitos do negócio, latency, compliance e availability também podem influenciar a escolha.$content$,null,null,6),
('7b200000-0000-4000-8000-000000000007','azure-cost-factors','exam_trap','Proximidade e preço não são sinônimos',
$content$Todas as Azure Regions não possuem obrigatoriamente o mesmo preço, e a região mais próxima não é automaticamente a mais barata.

Compare a região válida para os requisitos da solução e então considere o custo correspondente.$content$,null,null,7),
('7b200000-0000-4000-8000-000000000008','azure-cost-factors','explanation','Transferência de dados como fator',
$content$Transferência de dados pode afetar custos, especialmente saída de dados, tráfego entre determinados serviços ou regiões e outros cenários específicos de rede.

Nem todo tráfego é cobrado e nem todo tráfego é gratuito. A direção, origem, destino, serviço e volume ajudam a determinar o tratamento aplicável.$content$,null,null,8),
('7b200000-0000-4000-8000-000000000009','azure-cost-factors','exam_tip','Grande volume de dados merece atenção',
$content$Quando uma questão mencionar grande volume de dados sendo movimentado, considere transferência de dados como possível fator de custo. Não é necessário decorar tabelas ou valores para reconhecer o conceito.$content$,null,null,9),
('7b200000-0000-4000-8000-000000000010','azure-cost-factors','explanation','Modelo de preço e compromisso',
$content$O modo de contratação também pode alterar o preço efetivo. Pay-as-you-go prioriza flexibilidade sem compromisso de longo prazo; opções com compromisso podem oferecer economia potencial em cenários elegíveis.

Economia potencial não significa custo zero nem escolha automática. A carga precisa ser compatível com a opção.$content$,null,null,10),
('7b200000-0000-4000-8000-000000000011','azure-cost-factors','important','Pay-as-you-go, Reservations, Savings Plans e Spot',
$content$| Opção | Ideia em Fundamentals | Trade-off principal |
| --- | --- | --- |
| Pay-as-you-go | pagar pelo uso sem compromisso de longo prazo | mais flexibilidade |
| Reservations | compromisso para determinados recursos/cenários | potencial economia para uso previsível |
| Savings Plans | compromisso de gasto elegível por período | preços reduzidos para compute compatível |
| Spot | capacidade Azure não utilizada com preço reduzido | pode ser interrompida |

Eligibility, SKUs e detalhes de billing ficam fora desta Lesson.$content$,null,null,11),
('7b200000-0000-4000-8000-000000000012','azure-cost-factors','exam_trap','Preço reduzido sempre possui contexto',
$content$Reservations e Savings Plans envolvem compromisso; Spot envolve possibilidade de interrupção. Nenhuma opção é automaticamente a melhor para toda carga.

Uma carga crítica que não tolera interrupção não deve ser escolhida para Spot apenas pelo preço.$content$,null,null,12),
('7b200000-0000-4000-8000-000000000013','azure-cost-factors','example','Escolha pelo comportamento da carga',
$content$Uma carga temporária e tolerante a interrupção pode avaliar Spot. Uso estável e previsível pode avaliar opções de compromisso aplicáveis. Uma experiência curta e incerta pode preferir a flexibilidade pay-as-you-go.

Esses são sinais de cenário, não regras contábeis ou recomendações universais.$content$,null,null,13),
('7b200000-0000-4000-8000-000000000014','azure-cost-factors','summary','Resumo para memória ativa',null,
'{"items":["Tipo, quantidade e configuração do recurso podem alterar custo.","Tempo, consumo e capacidade provisionada usam métricas diferentes conforme o serviço.","Region pode afetar preço, mas custo não é o único requisito de escolha.","Transferência de dados pode gerar custo conforme o cenário.","Parar compute não elimina automaticamente custos associados.","Pay-as-you-go, Reservations, Savings Plans e Spot possuem flexibilidade e trade-offs diferentes."]}'::jsonb,null,14),

('7b200000-0000-4000-8000-000000000015','pricing-calculator','explanation','O que é Azure Pricing Calculator?',
$content$Azure Pricing Calculator é uma ferramenta web para **estimar** o custo de uma solução Azure a partir de uma configuração planejada.

Ela apoia planejamento antes da implantação e comparação de alternativas durante o desenho. Não é necessário memorizar ou operar sua interface para o AZ-900.$content$,null,null,1),
('7b200000-0000-4000-8000-000000000016','pricing-calculator','important','Entradas que moldam a estimativa',
$content$Conforme o serviço, a estimativa pode considerar Azure Region, size ou configuração, sistema operacional quando aplicável, tier, quantidade de uso e pricing plan.

Alterar uma entrada pode alterar o resultado mesmo que o nome do serviço permaneça igual.$content$,null,null,2),
('7b200000-0000-4000-8000-000000000017','pricing-calculator','explanation','Fluxo conceitual',
$content$Selecionar serviço → configurar características → informar uso esperado → selecionar opções de preço → obter estimativa.

A qualidade da estimativa depende das hipóteses informadas. Quantidade, horas, volume de dados e transferência esperada precisam representar o cenário planejado.$content$,null,null,3),
('7b200000-0000-4000-8000-000000000018','pricing-calculator','example','Planejar vinte VMs',
$content$Uma empresa quer prever o custo de 20 VMs antes de criá-las. Na Pricing Calculator, ela escolhe Virtual Machines e informa região, size, sistema operacional quando aplicável, quantidade, horas esperadas e opção de preço.

O resultado ajuda a comparar o desenho; não cria as VMs nem garante o valor final.$content$,null,null,4),
('7b200000-0000-4000-8000-000000000019','pricing-calculator','important','Pricing Calculator versus Cost Management',
$content$| Ferramenta | Momento | Pergunta principal |
| --- | --- | --- |
| Pricing Calculator | antes / planejamento | Quanto esta arquitetura provavelmente vai custar? |
| Cost Management | durante a operação | Quanto estou gastando e onde? |

Cost Management será aprofundado na próxima Lesson; aqui basta reconhecer a diferença.$content$,null,null,5),
('7b200000-0000-4000-8000-000000000020','pricing-calculator','exam_trap','Estimate não é fatura',
$content$Pricing Calculator fornece uma **estimate**, não uma garantia exata do custo final.

**Pricing Calculator ≠ fatura. Pricing Calculator ≠ Cost Management.** Uso real, configuração final, transferência de dados e mudanças de preço podem produzir resultado diferente.$content$,null,null,6),
('7b200000-0000-4000-8000-000000000021','pricing-calculator','example','Comparar duas configurações',
$content$Uma equipe compara uma VM menor e outra maior na mesma região. Ao alterar o size e as horas esperadas, a estimativa muda.

Depois da implantação, para investigar o gasto ocorrido no mês, a equipe usa Cost Management, não a Pricing Calculator.$content$,null,null,7),
('7b200000-0000-4000-8000-000000000022','pricing-calculator','exam_tip','Procure planejamento antes da implantação',
$content$“Estimar antes de criar”, “comparar configurações” e “projetar o custo de uma arquitetura” apontam para Azure Pricing Calculator. “Analisar quanto já foi gasto” aponta para Cost Management.$content$,null,null,8),
('7b200000-0000-4000-8000-000000000023','pricing-calculator','important','Uma estimativa depende das hipóteses',
$content$A ferramenta não descobre automaticamente toda a arquitetura futura. Serviços omitidos, uso subestimado ou tráfego não considerado deixam a estimativa incompleta.

Revise as hipóteses quando a arquitetura planejada mudar.$content$,null,null,9),
('7b200000-0000-4000-8000-000000000024','pricing-calculator','summary','Resumo para memória ativa',null,
'{"items":["Pricing Calculator estima custos de uma configuração planejada.","Service, Region, size, tier, uso esperado e pricing plan podem compor a estimativa.","O fluxo é selecionar, configurar, informar uso e comparar a estimate.","A calculadora ajuda antes da implantação e durante o desenho.","Estimate não é fatura nem garantia de custo final.","Cost Management acompanha e analisa gastos durante a operação."]}'::jsonb,null,10);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.visual_experience_id,seed.display_order,true
from stage_92_block_seed seed join public.lessons lesson
  on lesson.topic_id='33000000-0000-4000-8000-000000000001' and lesson.slug=seed.lesson_slug;

create temporary table stage_92_flashcard_seed(
  id uuid primary key,lesson_slug text not null,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_92_flashcard_seed values
('7e400000-0000-4000-8000-000000000044','azure-cost-factors','Quais três características básicas de um recurso podem alterar seu custo?','Tipo, quantidade e configuração ou tamanho.','O que foi provisionado?',1),
('7e400000-0000-4000-8000-000000000045','azure-cost-factors','Quais são exemplos de unidades relacionadas a consumo?','Horas de compute, dados armazenados, operações, transferência e unidades provisionadas.','Uso medido.',2),
('7e400000-0000-4000-8000-000000000046','azure-cost-factors','Todas as Azure Regions possuem o mesmo preço?','Não. Region pode afetar o preço do mesmo serviço e configuração.','Region é fator de custo.',3),
('7e400000-0000-4000-8000-000000000047','azure-cost-factors','Parar compute elimina todo custo associado?','Não necessariamente; armazenamento e outros recursos associados podem continuar gerando custo.','Compute não é a solução inteira.',4),
('7e400000-0000-4000-8000-000000000048','azure-cost-factors','Qual transferência merece atenção como possível fator de custo?','Especialmente saída de dados e determinados tráfegos entre serviços ou regiões.','Depende do cenário.',5),
('7e400000-0000-4000-8000-000000000049','azure-cost-factors','O que caracteriza pay-as-you-go?','Pagamento conforme uso sem compromisso de longo prazo.','Flexibilidade.',6),
('7e400000-0000-4000-8000-000000000050','azure-cost-factors','Como Reservations e Savings Plans diferem conceitualmente?','Reservations comprometem recursos ou cenários aplicáveis; Savings Plans comprometem gasto elegível para compute compatível.','Ambos envolvem compromisso.',7),
('7e400000-0000-4000-8000-000000000051','azure-cost-factors','Qual é o principal trade-off de Azure Spot?','Preço reduzido em troca da possibilidade de interrupção.','Capacidade não utilizada.',8),
('7e400000-0000-4000-8000-000000000052','pricing-calculator','Para que serve Azure Pricing Calculator?','Para estimar o custo de uma solução Azure planejada.','Antes da implantação.',1),
('7e400000-0000-4000-8000-000000000053','pricing-calculator','Quais entradas podem alterar uma estimate?','Service, Region, configuração, tier, uso esperado e pricing plan, conforme aplicável.','Hipóteses da solução.',2),
('7e400000-0000-4000-8000-000000000054','pricing-calculator','Pricing Calculator fornece uma fatura?','Não. Fornece uma estimate, não garantia do custo final.','Planejado versus real.',3),
('7e400000-0000-4000-8000-000000000055','pricing-calculator','Qual ferramenta estima uma arquitetura antes da implantação?','Azure Pricing Calculator.','Planejamento.',4),
('7e400000-0000-4000-8000-000000000056','pricing-calculator','Qual ferramenta ajuda a analisar quanto já foi gasto no Azure?','Azure Cost Management.','Operação, não estimativa prévia.',5);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_92_flashcard_seed seed join public.lessons lesson
  on lesson.topic_id='33000000-0000-4000-8000-000000000001' and lesson.slug=seed.lesson_slug;

create temporary table stage_92_historical_question_update(
  id uuid primary key,question_text text not null,explanation text not null
) on commit drop;
insert into stage_92_historical_question_update values
('63000000-0000-4000-8000-000000000061','Qual característica pode alterar diretamente o custo de um recurso Azure?','Tipo, quantidade e configuração do recurso influenciam o custo; o nome dado ao recurso ou seu Resource Group não define o preço.'),
('63000000-0000-4000-8000-000000000062','Duas VMs com a mesma configuração são planejadas em Azure Regions diferentes. O preço precisa ser idêntico?','Não. Azure Region pode afetar preço mesmo com serviço e configuração semelhantes; requisitos de latency, compliance e availability também importam na escolha.'),
('63000000-0000-4000-8000-000000000063','Uma aplicação enviará grande volume de dados de uma Azure Region para usuários na Internet. Qual fator deve entrar na estimativa?','Transferência de dados, especialmente saída de dados, pode afetar o custo conforme origem, destino, serviço e volume.'),
('63000000-0000-4000-8000-000000000064','Uma equipe dobra a quantidade de instâncias provisionadas para atender crescimento. Qual impacto é mais provável?','A quantidade de recursos provisionados é um fator de custo; aumentar instâncias tende a elevar custo, embora configuração e consumo também precisem ser avaliados.'),
('63000000-0000-4000-8000-000000000065','Uma VM maior é escolhida quando uma configuração menor já atende à carga. Qual impacto é mais provável?','Uma configuração com mais vCPU, memória ou capacidade tende a custar mais. Dimensionamento adequado evita capacidade ociosa, sem garantir um valor específico.'),
('63000000-0000-4000-8000-000000000066','Uma arquitetura transfere grande volume de dados entre duas Azure Regions. Qual análise é adequada?','O tráfego entre regiões pode gerar custo conforme o cenário; ele deve ser estimado sem assumir que todo tráfego Azure é cobrado ou gratuito.'),
('63000000-0000-4000-8000-000000000067','Uma VM é desalocada fora do horário comercial. Qual conclusão sobre custo é correta?','Desalocar a VM pode reduzir o custo de compute, mas discos e outros recursos associados podem continuar gerando custo. Parar compute não zera necessariamente a solução.'),
('63000000-0000-4000-8000-000000000068','Uma empresa prevê uso estável de VMs por longo período. Qual opção pode oferecer economia potencial mediante compromisso para cenário elegível?','Azure Reservations pode oferecer preço reduzido mediante compromisso aplicável a determinados recursos e cargas previsíveis; não é desconto automático para qualquer serviço.'),
('63000000-0000-4000-8000-000000000069','Uma empresa quer projetar realisticamente o custo de uma nova aplicação Azure. Qual abordagem é mais adequada?','Ela deve combinar tipo, quantidade, configuração, Region, tempo, consumo e transferência esperados em uma ferramenta de estimativa, revisando as hipóteses do desenho.'),
('63000000-0000-4000-8000-000000000070','Uma carga de compute temporária tolera interrupções e busca reduzir custo. Qual opção pode ser avaliada?','Azure Spot usa capacidade não utilizada com preço reduzido, mas pode ser interrompida; por isso o requisito de tolerância à interrupção é decisivo.');
update public.questions question set question_text=seed.question_text,explanation=seed.explanation
from stage_92_historical_question_update seed where question.id=seed.id;

create temporary table stage_92_historical_option_update(
  id uuid primary key,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_92_historical_option_update values
('74000000-0000-4000-8000-000000000241','Tipo, quantidade e configuração ou tamanho do recurso.',true,'Correta. Esses elementos alteram capacidade e consumo cobrável.',1),
('74000000-0000-4000-8000-000000000242','Somente o nome atribuído ao recurso.',false,'O nome organiza o recurso, mas não define seu preço.',2),
('74000000-0000-4000-8000-000000000243','Somente o Resource Group que contém o recurso.',false,'Resource Group organiza o recurso; os recursos contidos geram seus próprios custos.',3),
('74000000-0000-4000-8000-000000000244','Somente a conta usada para entrar no portal.',false,'A conta de acesso não substitui fatores como tipo, capacidade e uso.',4),
('74000000-0000-4000-8000-000000000245','Sim, o preço é universalmente idêntico em todas as Regions.',false,'Region pode afetar preço, portanto a igualdade não é garantida.',1),
('74000000-0000-4000-8000-000000000246','Não; Region pode afetar o preço da configuração.',true,'Correta. O mesmo desenho pode ter preços diferentes entre Regions.',2),
('74000000-0000-4000-8000-000000000247','Sim, desde que a Region mais próxima seja escolhida.',false,'Proximidade não garante o mesmo preço nem o menor preço.',3),
('74000000-0000-4000-8000-000000000248','Não, porque a VM mais distante é sempre mais barata.',false,'Não existe regra de que a Region mais distante seja sempre mais barata.',4),
('74000000-0000-4000-8000-000000000249','Somente o número de usuários cadastrados no tenant.',false,'Usuários cadastrados não representam o volume de saída descrito.',1),
('74000000-0000-4000-8000-000000000250','Transferência de dados, incluindo possível egress.',true,'Correta. Direção, destino e volume podem influenciar o custo.',2),
('74000000-0000-4000-8000-000000000251','Somente o tamanho do Resource Group.',false,'Resource Group não possui tamanho de tráfego cobrável.',3),
('74000000-0000-4000-8000-000000000252','Nenhum, pois todo tráfego para Internet é gratuito.',false,'Não se deve assumir que todo tráfego é gratuito.',4),
('74000000-0000-4000-8000-000000000253','O custo tende a aumentar com mais instâncias provisionadas.',true,'Correta. A quantidade de recursos é um fator de custo.',1),
('74000000-0000-4000-8000-000000000254','O custo obrigatoriamente cai pela metade.',false,'Mais instâncias não implicam redução automática.',2),
('74000000-0000-4000-8000-000000000255','A quantidade nunca afeta custo, somente Region.',false,'Quantidade e Region podem afetar custo.',3),
('74000000-0000-4000-8000-000000000256','A mudança afeta apenas a organização visual no portal.',false,'Provisionar instâncias adicionais altera a capacidade da solução.',4),
('74000000-0000-4000-8000-000000000257','O custo tende a aumentar com a configuração maior.',true,'Correta. Mais capacidade tende a elevar o custo.',1),
('74000000-0000-4000-8000-000000000258','O custo é sempre fixo para qualquer VM size.',false,'VM sizes oferecem capacidades e preços diferentes.',2),
('74000000-0000-4000-8000-000000000259','A VM maior sempre recebe desconto automático.',false,'Maior capacidade não gera desconto automático.',3),
('74000000-0000-4000-8000-000000000260','Size afeta desempenho, mas nunca preço.',false,'Configuração e capacidade podem afetar o preço.',4),
('74000000-0000-4000-8000-000000000261','Ignorar o tráfego, pois transferências internas são sempre gratuitas.',false,'Não existe regra de gratuidade para todo tráfego interno.',1),
('74000000-0000-4000-8000-000000000262','Avaliar origem, destino e volume da transferência entre Regions.',true,'Correta. Esses elementos ajudam a estimar o tratamento do tráfego.',2),
('74000000-0000-4000-8000-000000000263','Contar apenas os administradores da Subscription.',false,'Administradores não medem o volume de dados transferido.',3),
('74000000-0000-4000-8000-000000000264','Assumir que todo tráfego Azure possui o mesmo preço.',false,'O tratamento depende do cenário de rede.',4),
('74000000-0000-4000-8000-000000000265','Todo custo da solução vira zero enquanto a VM está desalocada.',false,'Discos e outros recursos podem continuar gerando custo.',1),
('74000000-0000-4000-8000-000000000266','Somente o custo de armazenamento é sempre eliminado.',false,'Armazenamento associado pode permanecer provisionado e cobrável.',2),
('74000000-0000-4000-8000-000000000267','Compute pode diminuir, mas custos associados podem permanecer.',true,'Correta. Deve-se avaliar todos os componentes da solução.',3),
('74000000-0000-4000-8000-000000000268','Desalocar aumenta obrigatoriamente todos os custos.',false,'Não há aumento obrigatório; compute pode ser reduzido conforme o recurso.',4),
('74000000-0000-4000-8000-000000000269','Pay-as-you-go sem qualquer compromisso.',false,'Pay-as-you-go prioriza flexibilidade, não o compromisso do cenário.',1),
('74000000-0000-4000-8000-000000000270','Azure Spot sem risco de interrupção.',false,'Spot pode ser interrompido e não representa compromisso de capacidade estável.',2),
('74000000-0000-4000-8000-000000000271','Aumento automático de VM size.',false,'Aumentar capacidade não é uma opção de economia por compromisso.',3),
('74000000-0000-4000-8000-000000000272','Azure Reservations para recurso e cenário elegíveis.',true,'Correta. Reservations troca compromisso aplicável por economia potencial.',4),
('74000000-0000-4000-8000-000000000273','Combinar os fatores relevantes em uma estimativa e revisar hipóteses.',true,'Correta. Uma projeção útil considera o desenho completo.',1),
('74000000-0000-4000-8000-000000000274','Usar somente o preço de lista de um serviço.',false,'Um único preço omite quantidade, Region, uso e outros componentes.',2),
('74000000-0000-4000-8000-000000000275','Ignorar transferência de dados e recursos associados.',false,'Omissões tornam a estimativa incompleta.',3),
('74000000-0000-4000-8000-000000000276','Tratar a primeira estimate como garantia de fatura.',false,'Estimate é uma projeção baseada em hipóteses, não garantia.',4),
('74000000-0000-4000-8000-000000000277','Azure Reservations, pois nunca há interrupção ou compromisso.',false,'Reservations envolve compromisso e não é definida pela tolerância à interrupção.',1),
('74000000-0000-4000-8000-000000000278','Azure Spot, aceitando a possibilidade de interrupção.',true,'Correta. Spot atende cargas tolerantes a interrupção que buscam preço reduzido.',2),
('74000000-0000-4000-8000-000000000279','Pay-as-you-go, porque garante sempre o menor preço.',false,'Pay-as-you-go oferece flexibilidade, não garantia de menor preço.',3),
('74000000-0000-4000-8000-000000000280','Savings Plans, porque eliminam automaticamente qualquer interrupção.',false,'Savings Plans tratam compromisso de gasto elegível, não garantia operacional.',4);
update public.question_options option set is_correct=false
where option.id in(select seed.id from stage_92_historical_option_update seed);
update public.question_options option set option_text=seed.option_text,is_correct=seed.is_correct,
  explanation=seed.explanation,display_order=seed.display_order
from stage_92_historical_option_update seed where option.id=seed.id;

create temporary table stage_92_question_seed(
  id uuid primary key,question_text text not null,difficulty text not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_92_question_seed values
('68000000-0000-4000-8000-000000000119','Qual é a finalidade principal do Azure Pricing Calculator?','easy','Azure Pricing Calculator estima custos de uma solução planejada com base em serviços, configurações e uso esperado.',1),
('68000000-0000-4000-8000-000000000120','Uma empresa quer estimar o custo de 20 VMs antes de criá-las. Qual ferramenta deve usar?','easy','Azure Pricing Calculator permite configurar quantidade, Region, size, sistema operacional quando aplicável, uso esperado e opção de preço para gerar uma estimate.',2),
('68000000-0000-4000-8000-000000000121','Uma estimativa de VM muda após a equipe selecionar outra Region e outro size. Qual interpretação está correta?','medium','Region e configuração são entradas que podem alterar a estimate, mesmo quando o tipo de serviço permanece Virtual Machines.',3),
('68000000-0000-4000-8000-000000000122','Uma equipe quer saber quanto já gastou neste mês e quais recursos geraram o custo. Qual ferramenta é mais adequada?','medium','Cost Management acompanha e analisa gastos reais e previstos durante a operação; Pricing Calculator é usada para estimativa e planejamento.',4),
('68000000-0000-4000-8000-000000000123','A Pricing Calculator estimou um valor, mas a fatura final foi diferente. Qual explicação é mais adequada?','hard','A calculadora produz uma estimate baseada nas hipóteses informadas. Uso real, configuração final, tráfego, itens omitidos e mudanças aplicáveis podem gerar custo diferente.',5);
insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_92_question_seed seed join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure management and governance'
join public.topics topic on topic.domain_id=domain.id and topic.id='33000000-0000-4000-8000-000000000001'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug='pricing-calculator';

create temporary table stage_92_option_seed(
  id uuid primary key,question_id uuid not null,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_92_option_seed values
('7f200000-0000-4000-8000-000000000001','68000000-0000-4000-8000-000000000119','Estimar o custo de uma configuração Azure planejada.',true,'Correta. A ferramenta apoia planejamento e comparação.',1),
('7f200000-0000-4000-8000-000000000002','68000000-0000-4000-8000-000000000119','Analisar exclusivamente a fatura já emitida.',false,'Fatura e gastos ocorridos pertencem ao acompanhamento operacional.',2),
('7f200000-0000-4000-8000-000000000003','68000000-0000-4000-8000-000000000119','Criar automaticamente todos os recursos estimados.',false,'A calculadora não implanta recursos.',3),
('7f200000-0000-4000-8000-000000000004','68000000-0000-4000-8000-000000000119','Garantir um preço final fixo para qualquer uso.',false,'A estimate não garante o custo final.',4),
('7f200000-0000-4000-8000-000000000005','68000000-0000-4000-8000-000000000120','Azure Pricing Calculator.',true,'Correta. O cenário pede estimativa antes da criação.',1),
('7f200000-0000-4000-8000-000000000006','68000000-0000-4000-8000-000000000120','Azure Cost Management apenas.',false,'Cost Management é mais apropriado para acompanhar e analisar operação.',2),
('7f200000-0000-4000-8000-000000000007','68000000-0000-4000-8000-000000000120','Azure Service Health.',false,'Service Health comunica saúde e eventos de serviços, não estima arquitetura.',3),
('7f200000-0000-4000-8000-000000000008','68000000-0000-4000-8000-000000000120','Azure Resource Locks.',false,'Locks protegem recursos contra alterações ou exclusões.',4),
('7f200000-0000-4000-8000-000000000009','68000000-0000-4000-8000-000000000121','Region e size podem alterar a estimate.',true,'Correta. Ambas são entradas relevantes conforme o serviço.',1),
('7f200000-0000-4000-8000-000000000010','68000000-0000-4000-8000-000000000121','A ferramenta apresentou erro, pois estimates nunca mudam.',false,'Estimates mudam quando hipóteses e configurações mudam.',2),
('7f200000-0000-4000-8000-000000000011','68000000-0000-4000-8000-000000000121','Somente o nome da VM pode alterar seu preço.',false,'Nome não substitui Region, size e uso como fatores.',3),
('7f200000-0000-4000-8000-000000000012','68000000-0000-4000-8000-000000000121','Toda Region e todo size possuem preço idêntico.',false,'Region e configuração podem produzir estimativas diferentes.',4),
('7f200000-0000-4000-8000-000000000013','68000000-0000-4000-8000-000000000122','Azure Cost Management.',true,'Correta. O requisito trata gasto ocorrido e origem do custo.',1),
('7f200000-0000-4000-8000-000000000014','68000000-0000-4000-8000-000000000122','Azure Pricing Calculator apenas.',false,'A calculadora estima uma configuração planejada.',2),
('7f200000-0000-4000-8000-000000000015','68000000-0000-4000-8000-000000000122','Azure Data Box.',false,'Data Box é uma opção de transferência física de dados.',3),
('7f200000-0000-4000-8000-000000000016','68000000-0000-4000-8000-000000000122','Azure DNS.',false,'Azure DNS hospeda e resolve nomes DNS.',4),
('7f200000-0000-4000-8000-000000000017','68000000-0000-4000-8000-000000000123','A estimate depende das hipóteses; uso e configuração reais podem diferir.',true,'Correta. Estimativa não é garantia de fatura.',1),
('7f200000-0000-4000-8000-000000000018','68000000-0000-4000-8000-000000000123','A calculadora sempre garante o valor exato por contrato.',false,'A ferramenta não transforma a projeção em garantia universal.',2),
('7f200000-0000-4000-8000-000000000019','68000000-0000-4000-8000-000000000123','O custo real nunca é afetado por uso ou tráfego.',false,'Uso e transferência podem afetar o custo conforme o cenário.',3),
('7f200000-0000-4000-8000-000000000020','68000000-0000-4000-8000-000000000123','Toda diferença significa obrigatoriamente erro de cobrança.',false,'Diferença pode resultar de hipóteses e operação distintas.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_92_option_seed;

do $$
declare lesson_record record;
begin
  for lesson_record in select id,slug from public.lessons
    where topic_id='33000000-0000-4000-8000-000000000001'
      and slug in ('azure-cost-factors','pricing-calculator')
  loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_record.id and is_published)
        <>(case lesson_record.slug when 'azure-cost-factors' then 14 else 10 end)
      or (select count(*) from public.flashcards where lesson_id=lesson_record.id and is_published)
        <>(case lesson_record.slug when 'azure-cost-factors' then 8 else 5 end)
      or (select count(*) from public.questions where lesson_id=lesson_record.id and is_published)
        <>(case lesson_record.slug when 'azure-cost-factors' then 10 else 5 end) then
      raise exception '9.2 final inventory is invalid for %',lesson_record.slug;
    end if;
  end loop;
end; $$;

commit;

begin;

-- Editorial/pedagogical remediation only. No Question or Option is recreated and
-- no answer key, ordering, hierarchy, publication or eligibility field is changed.
create temporary table az900_quality_question_state_before on commit drop as
select
  question.id,
  question.certification_id,
  question.domain_id,
  question.topic_id,
  question.lesson_id,
  question.question_type,
  question.difficulty,
  question.is_published,
  question.display_order,
  question.mock_eligible
from public.questions question
join public.certifications certification on certification.id = question.certification_id
where certification.code = 'az-900';

create temporary table az900_quality_option_state_before on commit drop as
select option.id, option.question_id, option.is_correct, option.display_order
from public.question_options option
join az900_quality_question_state_before question on question.id = option.question_id;

create temporary table az900_quality_question_content_before on commit drop as
select question.id, question.question_text, question.explanation
from public.questions question
join az900_quality_question_state_before before on before.id = question.id;

create temporary table az900_quality_option_content_before on commit drop as
select option.id, option.option_text, option.explanation
from public.question_options option
join az900_quality_option_state_before before on before.id = option.id;

create temporary table az900_quality_mock_digest_before on commit drop as
select md5(coalesce(string_agg(to_jsonb(snapshot)::text, '' order by snapshot.id), '')) as digest
from public.mock_exam_attempt_questions snapshot;

do $$
declare
  v_questions integer;
  v_published integer;
  v_options integer;
  v_mock_eligible integer;
begin
  select count(*), count(*) filter (where is_published),
         count(*) filter (where mock_eligible)
    into v_questions, v_published, v_mock_eligible
  from az900_quality_question_state_before;
  select count(*) into v_options from az900_quality_option_state_before;

  if (v_questions, v_published, v_options, v_mock_eligible)
     is distinct from (512, 512, 2048, 439) then
    raise exception
      'AZ-900 quality precondition failed: questions %, published %, options %, mock eligible %',
      v_questions, v_published, v_options, v_mock_eligible;
  end if;
end;
$$;

-- REMEDIATION FRAGMENTS ARE ASSEMBLED BELOW. Each row is addressed by UUID.


-- Deep editorial remediation fragment: validator indices 0..127.
-- Deliberately contains no transaction wrapper or guards; the final migration owns those.

create temporary table az900_question_remediation_0_127 (
  id uuid primary key,
  classification text not null,
  flags text[] not null
) on commit drop;

insert into az900_question_remediation_0_127 (id, classification, flags) values
  ('60000000-0000-4000-8000-000000000004','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('60000000-0000-4000-8000-000000000005','C',array['DETAIL_BIAS']),
  ('60000000-0000-4000-8000-000000000006','C',array['WEAK_DISTRACTOR']),
  ('60000000-0000-4000-8000-000000000008','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('61000000-0000-4000-8000-000000000001','C',array['DETAIL_BIAS']),
  ('61000000-0000-4000-8000-000000000002','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('61000000-0000-4000-8000-000000000003','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('61000000-0000-4000-8000-000000000004','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000001','D',array['DETAIL_BIAS','WEAK_STEM']),
  ('62000000-0000-4000-8000-000000000002','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000004','C',array['TOO_OBVIOUS']),
  ('62000000-0000-4000-8000-000000000005','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000007','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000008','D',array['LENGTH_BIAS','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000009','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000010','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000011','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000013','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000014','C',array['WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000015','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000016','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000017','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000019','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000020','D',array['WEAK_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000021','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000022','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000023','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000024','C',array['TOO_OBVIOUS']),
  ('62000000-0000-4000-8000-000000000025','C',array['TOO_OBVIOUS']),
  ('62000000-0000-4000-8000-000000000026','C',array['WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000027','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000028','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000029','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000030','D',array['RATIONALITY_BIAS','WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000031','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000033','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000034','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000035','D',array['RATIONALITY_BIAS','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000036','C',array['WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000037','D',array['RATIONALITY_BIAS','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000038','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000039','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000040','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000041','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000042','C',array['STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000043','C',array['WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000044','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000045','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000046','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000047','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000049','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000050','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000054','D',array['RATIONALITY_BIAS','WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000055','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000056','D',array['RATIONALITY_BIAS','WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000057','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000058','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000059','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000060','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000061','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000062','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000063','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000064','D',array['RATIONALITY_BIAS','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000066','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000067','D',array['RATIONALITY_BIAS','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000068','C',array['STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000069','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000070','D',array['RATIONALITY_BIAS','WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000072','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000073','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000075','C',array['WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000076','D',array['RATIONALITY_BIAS','WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000077','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000078','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000081','C',array['DETAIL_BIAS']),
  ('62000000-0000-4000-8000-000000000082','C',array['WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000086','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000087','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000088','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000089','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000090','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000091','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000092','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000093','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000094','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000095','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000096','D',array['RATIONALITY_BIAS','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000097','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000098','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000099','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000100','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000102','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000103','D',array['OBVIOUS_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000104','C',array['WEAK_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000105','C',array['ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000107','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000108','D',array['ABSOLUTE_DISTRACTOR','STRUCTURAL_BIAS']),
  ('62000000-0000-4000-8000-000000000109','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR','LENGTH_BIAS']),
  ('62000000-0000-4000-8000-000000000110','D',array['RATIONALITY_BIAS','ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000111','C',array['ABSOLUTE_DISTRACTOR']),
  ('62000000-0000-4000-8000-000000000113','C',array['LENGTH_BIAS','DETAIL_BIAS']);

create temporary table az900_question_text_seed_0_127 (
  id uuid primary key,
  question_text text not null,
  explanation text not null
) on commit drop;

insert into az900_question_text_seed_0_127 values
  ('60000000-0000-4000-8000-000000000004','Uma organização precisa escolher uma Azure Region para uma carga de trabalho sujeita a requisitos de residência de dados e baixa latência. Qual conjunto de fatores deve orientar a decisão?','A Region deve ser avaliada por latência, residência de dados e compliance, disponibilidade dos serviços, preço e opções de resiliência; nenhum desses fatores, isoladamente, decide todos os cenários.'),
  ('60000000-0000-4000-8000-000000000008','Uma equipe compara Azure App Service com uma Azure Virtual Machine para hospedar a mesma aplicação. Qual diferença operacional é correta?','No App Service, a Microsoft gerencia a plataforma e grande parte do sistema operacional. Na VM, o cliente controla o sistema operacional convidado e assume sua manutenção.'),
  ('61000000-0000-4000-8000-000000000002','Qual alternativa diferencia corretamente um recurso zonal de um recurso com redundância de zona?','Um recurso zonal é associado a uma zona específica. Quando suportado, um recurso com redundância de zona é distribuído ou replicado entre múltiplas zonas.'),
  ('61000000-0000-4000-8000-000000000003','Antes de implantar um serviço com Availability Zones, o que a equipe deve confirmar?','O suporte a zonas varia por Region, serviço, camada ou SKU e configuração. A existência de zonas na Region não torna todas as combinações compatíveis.'),
  ('61000000-0000-4000-8000-000000000004','Uma empresa selecionou uma Region que oferece Availability Zones. O que ainda é necessário para obter resiliência zonal?','A solução precisa usar uma configuração zonal em várias zonas ou uma configuração com redundância de zona suportada; escolher a Region não habilita a proteção por si só.'),
  ('62000000-0000-4000-8000-000000000001','Qual definição descreve cloud computing?','Cloud computing é a entrega sob demanda de recursos de computação pela rede, com provisionamento flexível e medição de consumo.'),
  ('62000000-0000-4000-8000-000000000005','Uma startup não conhece a demanda futura e quer evitar a compra antecipada de infraestrutura. Qual característica da nuvem atende diretamente a esse objetivo?','O modelo de consumo permite iniciar com poucos recursos, ajustar a capacidade à demanda observada e pagar pelo uso, sem comprar antecipadamente a capacidade máxima.'),
  ('62000000-0000-4000-8000-000000000008','Ao comparar o provisionamento de capacidade adicional na nuvem e em um datacenter próprio, qual diferença é típica?','Recursos de nuvem podem ser provisionados em minutos por software; ampliar um datacenter próprio normalmente envolve aquisição, entrega e instalação de hardware.'),
  ('62000000-0000-4000-8000-000000000009','Uma empresa possui uma carga legada dependente de hardware específico e outras cargas que se beneficiariam da elasticidade. Qual estratégia é adequada?','Uma adoção híbrida ou seletiva permite manter a carga dependente de hardware localmente e migrar as cargas que se beneficiam das características da nuvem.'),
  ('62000000-0000-4000-8000-000000000010','Uma aplicação interna tem uso baixo e previsível. Qual análise deve orientar a decisão entre mantê-la localmente ou migrá-la para a nuvem?','A decisão deve comparar custo total, padrão de consumo, requisitos técnicos e esforço operacional; a quantidade de usuários, sozinha, não determina o melhor ambiente.'),
  ('62000000-0000-4000-8000-000000000019','Um usuário acessou um serviço SaaS com uma senha fraca e causou um incidente. Segundo o modelo de responsabilidade compartilhada, quem responde pela gestão dessa identidade?','Mesmo em SaaS, o cliente administra seus usuários, credenciais, políticas de acesso e dados. O provedor continua responsável pelas camadas do serviço que opera.'),
  ('62000000-0000-4000-8000-000000000020','Uma organização quer reduzir ao máximo a administração de infraestrutura, sistema operacional e aplicação. Qual modelo transfere mais dessas tarefas ao provedor?','SaaS transfere ao provedor a maior parte da pilha, inclusive a aplicação. O cliente ainda gerencia seus dados, identidades, acessos e configurações de uso.'),
  ('62000000-0000-4000-8000-000000000029','Uma multinacional mantém dados regulados em infraestrutura privada e executa campanhas sem dados sensíveis na nuvem pública. Qual modelo descreve a estratégia?','A combinação integrada de ambiente privado e nuvem pública é uma nuvem híbrida, aplicada aqui para equilibrar conformidade e flexibilidade.'),
  ('62000000-0000-4000-8000-000000000030','Um serviço de streaming tem demanda variável, não exige infraestrutura dedicada e prioriza rapidez de escala. Qual modelo de implantação é mais adequado?','A nuvem pública oferece capacidade compartilhada sob demanda e elasticidade, compatíveis com a variação de tráfego e a ausência de requisito de dedicação física.'),
  ('62000000-0000-4000-8000-000000000031','Ao selecionar entre nuvem pública, privada e híbrida, qual conjunto de requisitos é decisivo?','A escolha deve considerar segurança, conformidade, controle, integração, perfil da carga e custo total. O nome do modelo, isoladamente, não garante atendimento.'),
  ('62000000-0000-4000-8000-000000000039','Uma organização de saúde compara nuvem pública e nuvem híbrida para prontuários. Qual avaliação deve preceder a escolha?','A organização deve mapear requisitos legais e controles necessários e verificar como cada arquitetura os atende; dados de saúde podem usar nuvem quando os controles aplicáveis são satisfeitos.'),
  ('62000000-0000-4000-8000-000000000040','Uma empresa mantém sistemas legados localmente e deseja modernizar gradualmente cargas compatíveis em diferentes países. Qual estratégia é mais adequada?','Uma estratégia híbrida permite manter dependências legadas e migrar gradualmente cargas compatíveis, respeitando requisitos de localização, integração e modernização.'),
  ('62000000-0000-4000-8000-000000000049','Uma empresa compara servidores comprados para a demanda máxima com recursos de nuvem ajustados à demanda real. Em qual condição o segundo cenário tende a ser mais eficiente?','Quando a demanda varia, ajustar capacidade e custo ao consumo reduz a ociosidade. A conclusão depende do custo total e não constitui uma regra universal para toda carga.'),
  ('62000000-0000-4000-8000-000000000050','Ambientes de teste permanecem ativos fora do horário de uso e elevam a fatura. Qual ação aproveita melhor o modelo baseado em consumo?','Agendar desligamento ou redução de capacidade evita consumo ocioso. Reservas e rightsizing podem complementar a medida, mas não substituem eliminar recursos sem uso.'),
  ('62000000-0000-4000-8000-000000000059','Uma empresa compara um datacenter próprio com serviços de nuvem pagos por consumo. Qual mudança financeira é típica?','A compra de ativos físicos é tipicamente CapEx, enquanto serviços recorrentes pagos por consumo são tipicamente OpEx; o tratamento contábil final depende das regras aplicáveis.'),
  ('62000000-0000-4000-8000-000000000060','Ao comparar CapEx e OpEx para uma demanda variável, qual diferença de flexibilidade é relevante?','OpEx baseado em consumo costuma acompanhar melhor variações de uso. CapEx compromete capital em ativos adquiridos, cuja capacidade não muda imediatamente com a demanda.'),
  ('62000000-0000-4000-8000-000000000061','Uma empresa compara manter um datacenter próprio com migrar uma carga para a nuvem. Qual análise financeira sustenta uma decisão de longo prazo?','O TCO compara aquisição, operação, manutenção, energia, pessoal, depreciação e consumo de nuvem ao longo do horizonte relevante.'),
  ('62000000-0000-4000-8000-000000000063','Em um modelo serverless, como o consumo costuma ser cobrado?','A cobrança normalmente considera execuções, duração e recursos consumidos. O modelo exato varia por serviço e pode incluir franquias ou outros componentes.'),
  ('62000000-0000-4000-8000-000000000064','Uma rotina deve processar imagens somente quando novos arquivos chegam, com longos períodos sem eventos. Qual abordagem é mais adequada?','Uma função serverless orientada a eventos executa quando o upload ocorre e evita manter uma instância dedicada ociosa entre eventos.'),
  ('62000000-0000-4000-8000-000000000069','Uma aplicação opera continuamente com carga estável. O que deve ser comparado antes de escolher serverless ou máquinas virtuais?','O padrão constante pode favorecer capacidade planejada, enquanto serverless reduz administração. A decisão exige comparar custo total e requisitos operacionais, sem assumir um vencedor universal.'),
  ('62000000-0000-4000-8000-000000000070','Uma arquitetura monolítica será dividida em funções acionadas por uploads, filas e requisições HTTP esporádicas. Qual modelo se alinha a esse desenho?','Serverless é apropriado para componentes pequenos e orientados a eventos, com escala gerenciada. VMs e contêineres continuam possíveis, mas exigem outra forma de operação.'),
  ('62000000-0000-4000-8000-000000000072','Como um provedor normalmente formaliza seu compromisso de disponibilidade para um serviço?','O SLA define a meta ou o compromisso de disponibilidade, as condições de medição e possíveis créditos; não representa promessa de ausência absoluta de falhas.'),
  ('62000000-0000-4000-8000-000000000075','Uma aplicação deve continuar disponível se uma Availability Zone falhar. Qual arquitetura atende ao requisito?','Distribuir instâncias e dados entre zonas compatíveis reduz a dependência de uma única zona. Um backup isolado não fornece failover de serviço em tempo real.'),
  ('62000000-0000-4000-8000-000000000077','Uma aplicação crítica precisa suportar falhas de instância e picos de tráfego. Qual combinação contribui diretamente para alta disponibilidade?','Redundância remove o ponto único de falha, health checks identificam instâncias indisponíveis e o failover direciona tráfego para instâncias saudáveis.'),
  ('62000000-0000-4000-8000-000000000086','Ao escolher entre scale up e scale out para um banco de dados que se aproxima do limite da máquina atual, qual fator é central?','Scale up é limitado pela maior capacidade disponível para uma instância. Scale out amplia capacidade por instâncias, mas pode exigir particionamento e mudanças de arquitetura.'),
  ('62000000-0000-4000-8000-000000000087','Uma aplicação precisa crescer além da capacidade máxima de uma única máquina. Qual abordagem oferece maior espaço de expansão?','Scale out distribui a carga entre instâncias e evita depender apenas do limite físico de uma máquina, embora exija que a arquitetura suporte distribuição.'),
  ('62000000-0000-4000-8000-000000000089','Uma aplicação já atingiu repetidamente o limite da maior máquina disponível. Qual mudança de arquitetura trata essa restrição?','Escalabilidade horizontal distribui a carga por múltiplas instâncias. Ela supera o teto de uma máquina, desde que estado e tráfego possam ser distribuídos.'),
  ('62000000-0000-4000-8000-000000000090','Um novo sistema deve atender picos repentinos e crescimento contínuo sem limite conhecido. Qual capacidade arquitetural é mais adequada?','Um desenho horizontalmente escalável permite adicionar instâncias e pode ser combinado com autoscaling para responder automaticamente à demanda.'),
  ('62000000-0000-4000-8000-000000000092','Qual distinção entre escalabilidade e elasticidade é mais útil em uma decisão de arquitetura?','Escalabilidade é a capacidade de suportar mais ou menos carga; elasticidade enfatiza ajustar recursos conforme a demanda, frequentemente de modo automático e reversível.'),
  ('62000000-0000-4000-8000-000000000094','Uma venda de ingressos produz picos breves e intensos. Qual configuração usa elasticidade para equilibrar desempenho e custo?','Regras de autoscaling aumentam capacidade durante o pico e a reduzem depois. Os limites e tempos devem ser definidos a partir das métricas relevantes.'),
  ('62000000-0000-4000-8000-000000000095','Uma aplicação tem picos no almoço e baixa demanda de madrugada. Qual benefício direto traz o autoscaling orientado por requisições?','A capacidade acompanha o tráfego, ajudando a manter desempenho nos picos e a reduzir recursos ociosos nos períodos de baixa demanda.'),
  ('62000000-0000-4000-8000-000000000097','Novas instâncias entram tarde demais durante picos de tráfego. Qual ajuste deve ser investigado primeiro?','Revisar thresholds, períodos de avaliação, cooldown e tempo de inicialização pode fazer o scale-out ocorrer antes que a saturação afete os usuários.'),
  ('62000000-0000-4000-8000-000000000099','Os custos cresceram embora o tráfego esteja estável em uma aplicação com autoscaling. Qual investigação é mais adequada?','Métricas, thresholds, limites mínimo e máximo e histórico de eventos mostram se a política mantém ou adiciona capacidade além da necessidade observada.'),
  ('62000000-0000-4000-8000-000000000100','Uma aplicação tem picos previsíveis e imprevisíveis. Qual estratégia combina escalabilidade e elasticidade?','Uma arquitetura horizontalmente escalável combinada a regras automáticas, e quando útil agendadas, pode atender crescimento e oscilações de demanda.'),
  ('62000000-0000-4000-8000-000000000103','Quais métricas ajudam a avaliar a confiabilidade e a recuperação de um sistema ao longo do tempo?','MTBF mede o intervalo médio entre falhas e MTTR mede o tempo médio de recuperação. Uptime e taxa de falhas também podem complementar a análise.'),
  ('62000000-0000-4000-8000-000000000107','Falhas permanecem desconhecidas por longos períodos e ampliam a indisponibilidade. Qual prática reduz diretamente o tempo de detecção?','Health checks, telemetria e alertas automatizados reduzem o tempo até a detecção; redundância e backup tratam dimensões diferentes da confiabilidade.'),
  ('62000000-0000-4000-8000-000000000109','Um sistema tem muitas instâncias, mas nunca testou sua recuperação; outro testa regularmente um plano documentado. Qual conclusão é defensável?','Redundância e testes tratam aspectos complementares. A confiabilidade real exige que mecanismos de recuperação existam e sejam validados contra objetivos definidos.'),
  ('62000000-0000-4000-8000-000000000110','Um sistema crítico aceita apenas poucos minutos de indisponibilidade. Qual conjunto de práticas sustenta esse objetivo?','Redundância, monitoramento, failover e testes de recuperação reduzem o tempo de interrupção; backups isolados podem proteger dados sem cumprir o objetivo de disponibilidade.'),
  ('62000000-0000-4000-8000-000000000113','Uma equipe precisa estimar o custo mensal de uma arquitetura Azure antes da implantação. Qual ferramenta deve usar primeiro?','A Pricing Calculator estima o preço de uma arquitetura planejada. Budgets e alertas acompanham gastos; Azure Monitor, Service Health e Defender for Cloud têm outras finalidades.');

insert into az900_question_text_seed_0_127 values
  ('60000000-0000-4000-8000-000000000005','Uma API usa um serviço compatível com instâncias distribuídas entre Availability Zones. Qual benefício essa arquitetura busca?','Distribuir instâncias entre zonas reduz o impacto de uma falha localizada, desde que o serviço e a configuração ofereçam suporte a zonas.'),
  ('60000000-0000-4000-8000-000000000006','Uma equipe deseja aplicar permissões e acompanhar custos de recursos da mesma solução. Qual organização facilita esse gerenciamento conjunto?','Um resource group é um contêiner lógico que oferece um escopo comum para gerenciar acesso, políticas e custos de recursos relacionados.'),
  ('61000000-0000-4000-8000-000000000001','Qual definição descreve corretamente uma Azure Availability Zone?','Uma Availability Zone é formada por um ou mais datacenters fisicamente separados dentro de uma Region, com infraestrutura independente das demais zonas.'),
  ('62000000-0000-4000-8000-000000000002','Qual característica permite provisionar recursos de nuvem sem aguardar uma intervenção manual do provedor?','O autoatendimento sob demanda permite que o cliente provisione recursos por interfaces e automações disponibilizadas pelo provedor.'),
  ('62000000-0000-4000-8000-000000000004','Uma empresa quer reduzir o investimento inicial em servidores e a manutenção do hardware. Qual abordagem atende diretamente a esse objetivo?','A adoção de cloud computing transfere a operação do hardware ao provedor e permite consumir capacidade sem adquiri-la antecipadamente.'),
  ('62000000-0000-4000-8000-000000000007','Uma loja virtual tem picos sazonais e quer pagar de acordo com a capacidade usada em cada período. Qual princípio atende a essa necessidade?','O modelo baseado em consumo relaciona a cobrança ao uso medido, permitindo aumentar ou reduzir recursos conforme a demanda.'),
  ('62000000-0000-4000-8000-000000000011','O que descreve o modelo de responsabilidade compartilhada em cloud computing?','O modelo distribui responsabilidades entre provedor e cliente; essa divisão varia conforme o tipo de serviço, enquanto dados e identidades continuam sob responsabilidade do cliente.'),
  ('62000000-0000-4000-8000-000000000013','No modelo de responsabilidade compartilhada, qual responsabilidade permanece com o cliente em IaaS, PaaS e SaaS?','O cliente continua responsável pela classificação e proteção dos próprios dados e pela gestão das identidades e dos acessos.'),
  ('62000000-0000-4000-8000-000000000014','Uma empresa hospeda uma aplicação em uma Azure Virtual Machine. Quem deve aplicar atualizações de segurança no sistema operacional convidado?','Em IaaS, o provedor opera a infraestrutura física e a virtualização, enquanto o cliente administra e atualiza o sistema operacional convidado.'),
  ('62000000-0000-4000-8000-000000000015','Uma empresa usa um serviço SaaS de e-mail. Qual responsabilidade permanece com o cliente?','Mesmo em SaaS, o cliente administra seus dados, as identidades dos usuários e as políticas de acesso ao serviço.'),
  ('62000000-0000-4000-8000-000000000016','Ao usar um serviço PaaS, como as responsabilidades de gerenciamento são divididas?','O provedor administra infraestrutura, sistema operacional, middleware e runtime; o cliente administra aplicação, dados, identidades e acessos.'),
  ('62000000-0000-4000-8000-000000000017','Ao migrar uma carga de IaaS para SaaS, como a divisão de responsabilidades normalmente muda?','O provedor passa a administrar mais camadas da solução, enquanto o cliente permanece responsável principalmente por dados, identidades, acessos e configurações de uso.'),
  ('62000000-0000-4000-8000-000000000021','Qual característica identifica uma nuvem pública?','Na nuvem pública, um provedor oferece recursos compartilhados entre clientes, com isolamento lógico e acesso por conectividade apropriada.'),
  ('62000000-0000-4000-8000-000000000022','Qual definição descreve uma nuvem privada?','Uma nuvem privada disponibiliza recursos dedicados a uma organização e pode operar no datacenter próprio ou em um provedor.'),
  ('62000000-0000-4000-8000-000000000023','O que define uma nuvem híbrida?','Uma nuvem híbrida integra um ambiente privado ou on-premises a serviços de nuvem pública, permitindo que cargas e dados usem os ambientes adequados.'),
  ('62000000-0000-4000-8000-000000000024','Uma instituição exige infraestrutura dedicada e controle direto do ambiente que armazena dados regulados. Qual modelo atende ao requisito?','Uma nuvem privada oferece recursos dedicados à organização e o nível de controle solicitado, sujeita aos controles de conformidade aplicáveis.'),
  ('62000000-0000-4000-8000-000000000025','Uma empresa mantém sistemas on-premises e usa capacidade de nuvem pública durante picos, com integração entre os ambientes. Qual modelo adotou?','A integração entre infraestrutura on-premises e recursos de nuvem pública caracteriza uma nuvem híbrida.'),
  ('62000000-0000-4000-8000-000000000026','Um portal público tem grande variação de acessos e não exige infraestrutura dedicada. Qual modelo de nuvem é adequado?','A nuvem pública oferece capacidade compartilhada e elástica, compatível com o portal e com a ausência de requisito de dedicação.'),
  ('62000000-0000-4000-8000-000000000027','Uma organização mantém registros sensíveis em ambiente privado e usa a nuvem pública para analisar dados não sensíveis. Qual modelo combina os ambientes?','A nuvem híbrida integra os ambientes privado e público para posicionar cada carga conforme seus requisitos.'),
  ('62000000-0000-4000-8000-000000000028','Ao comparar nuvem pública e privada, qual diferença de controle da infraestrutura está correta?','A nuvem privada oferece maior controle sobre recursos dedicados; na nuvem pública, o provedor administra a infraestrutura física compartilhada.'),
  ('62000000-0000-4000-8000-000000000033','Qual critério é relevante ao escolher entre nuvem pública, privada e híbrida?','Requisitos de controle, conformidade, integração, desempenho e custo total devem orientar a escolha do modelo de implantação.'),
  ('62000000-0000-4000-8000-000000000034','Uma fintech quer manter dados auditáveis em ambiente privado e hospedar um site institucional na nuvem pública. Qual modelo equilibra os requisitos?','Uma nuvem híbrida permite manter a carga regulada no ambiente privado e usar a nuvem pública para a carga que não exige dedicação.'),
  ('62000000-0000-4000-8000-000000000035','Uma equipe quer validar um produto digital com baixo investimento inicial e sem compromisso de capacidade de longo prazo. Qual modelo é mais adequado?','A nuvem pública permite provisionar e remover recursos sob demanda, favorecendo a validação com baixo investimento inicial.'),
  ('62000000-0000-4000-8000-000000000036','Uma fábrica mantém o controle de produção local por latência e usa a nuvem pública para analisar histórico. Qual modelo atende ao desenho?','Uma nuvem híbrida combina a operação local de baixa latência com serviços de nuvem pública para análise.'),
  ('62000000-0000-4000-8000-000000000037','Uma organização quer hospedar um site com baixo custo inicial e não possui requisito de infraestrutura dedicada. Qual modelo tende a ser adequado?','A nuvem pública oferece recursos compartilhados sob demanda e evita a aquisição inicial de infraestrutura dedicada.'),
  ('62000000-0000-4000-8000-000000000038','Qual diferença de custo inicial costuma existir entre nuvem pública e nuvem privada?','A nuvem pública tende a exigir menor investimento inicial; a nuvem privada normalmente envolve recursos dedicados e maior compromisso de infraestrutura.'),
  ('62000000-0000-4000-8000-000000000041','O que caracteriza um modelo de consumo baseado no uso?','A cobrança acompanha unidades medidas de consumo, como tempo de computação, armazenamento ou transferência de dados, conforme o serviço.'),
  ('62000000-0000-4000-8000-000000000042','Qual benefício o modelo baseado em consumo oferece a uma empresa com demanda sazonal?','A empresa pode reduzir o consumo e o gasto nos períodos de baixa e aumentar recursos nos períodos de maior demanda.'),
  ('62000000-0000-4000-8000-000000000043','No modelo baseado em consumo, o que normalmente determina o valor cobrado?','A cobrança considera as unidades consumidas de cada recurso, segundo a métrica e a tarifa definidas para o serviço.'),
  ('62000000-0000-4000-8000-000000000044','Uma rotina de análise executa apenas de madrugada. Qual benefício do modelo baseado em consumo é mais relevante?','Provisionar recursos para a janela de processamento e reduzi-los depois evita pagar continuamente por capacidade ociosa.'),
  ('62000000-0000-4000-8000-000000000045','Um produto ainda está em validação e pode crescer rapidamente. Qual característica do modelo baseado em consumo reduz o risco financeiro inicial?','A equipe pode começar com poucos recursos e aumentar o consumo quando a demanda se confirmar, sem comprar antecipadamente a capacidade máxima.'),
  ('62000000-0000-4000-8000-000000000046','Uma equipe desliga ambientes de teste à noite e nos fins de semana. Qual efeito essa prática pode ter no custo baseado em consumo?','Interromper recursos faturados por tempo de execução reduz as unidades consumidas, embora componentes como armazenamento possam continuar gerando cobrança.'),
  ('62000000-0000-4000-8000-000000000047','Uma empresa realiza poucos eventos por ano. Qual abordagem aproveita melhor o modelo baseado em consumo?','Provisionar capacidade adicional durante cada evento e reduzi-la ao final alinha o gasto ao período de uso efetivo.'),
  ('62000000-0000-4000-8000-000000000054','Uma empresa quer evitar a compra inicial de servidores e pagar a computação conforme o uso. Qual modelo de despesa tende a predominar?','Serviços recorrentes pagos conforme o uso são tipicamente tratados como OpEx, enquanto a compra de servidores é tipicamente CapEx.'),
  ('62000000-0000-4000-8000-000000000055','Uma empresa usa serviços de nuvem pública pagos mensalmente e não compra hardware. Como essas despesas são tipicamente classificadas?','Pagamentos recorrentes por serviços consumidos são tipicamente despesas operacionais, sujeitas às regras contábeis da organização.'),
  ('62000000-0000-4000-8000-000000000056','Uma empresa prefere distribuir os gastos de TI ao longo do ano em vez de fazer uma grande compra inicial. Qual modelo favorece esse objetivo?','OpEx distribui gastos recorrentes ao longo do tempo, enquanto CapEx concentra o investimento na aquisição de ativos.'),
  ('62000000-0000-4000-8000-000000000057','Ao substituir a compra de servidores por serviços de nuvem pagos por consumo, como os gastos normalmente mudam?','A participação de OpEx tende a aumentar, pois pagamentos recorrentes por serviços substituem parte do investimento em ativos físicos.'),
  ('62000000-0000-4000-8000-000000000058','Qual diferença entre CapEx e OpEx é relevante quando a demanda muda?','OpEx baseado em consumo pode acompanhar variações de uso; CapEx representa capacidade adquirida antecipadamente e menos flexível no curto prazo.'),
  ('62000000-0000-4000-8000-000000000062','Qual benefício do serverless computing reduz o trabalho operacional dos desenvolvedores?','O provedor provisiona e escala a infraestrutura de execução, permitindo que a equipe concentre-se no código e na configuração da aplicação.'),
  ('62000000-0000-4000-8000-000000000066','Uma rotina deve validar um arquivo quando ele é adicionado ao armazenamento e não possui frequência previsível. Qual abordagem é adequada?','Uma função serverless acionada pelo evento executa a rotina quando o arquivo chega e evita manter capacidade dedicada continuamente.'),
  ('62000000-0000-4000-8000-000000000067','Um protótipo tem uso esporádico e a equipe quer evitar capacidade ociosa. Qual modelo de computação atende ao requisito?','Serverless permite cobrar pela execução medida e escala a infraestrutura gerenciada conforme os acionamentos.'),
  ('62000000-0000-4000-8000-000000000068','Como serverless computing difere de uma máquina virtual quanto ao gerenciamento?','No serverless, o provedor gerencia a infraestrutura e o escalonamento da plataforma; na VM, o cliente administra o sistema operacional convidado.'),
  ('62000000-0000-4000-8000-000000000073','Qual estratégia aumenta a disponibilidade de uma aplicação diante da falha de uma instância?','Distribuir a aplicação entre instâncias redundantes permite que instâncias saudáveis continuem atendendo quando uma falha.'),
  ('62000000-0000-4000-8000-000000000076','Atualizações de produção deixam um serviço indisponível. Qual prática reduz esse impacto?','Uma implantação gradual atualiza parte das instâncias enquanto as demais continuam atendendo, preservando capacidade durante a mudança.'),
  ('62000000-0000-4000-8000-000000000078','Qual diferença de disponibilidade existe entre uma única instância e múltiplas instâncias redundantes?','Múltiplas instâncias removem o ponto único de falha, desde que tráfego e estado sejam distribuídos de forma compatível.'),
  ('62000000-0000-4000-8000-000000000081','O que significa escalabilidade em cloud computing?','Escalabilidade é a capacidade de ajustar recursos para suportar mudanças de carga, verticalmente ou por meio da adição e remoção de instâncias.'),
  ('62000000-0000-4000-8000-000000000082','O que caracteriza a escalabilidade vertical, ou scale up?','Scale up aumenta a capacidade de uma instância existente, por exemplo ao selecionar uma configuração com mais CPU ou memória.'),
  ('62000000-0000-4000-8000-000000000088','Qual diferença de limite existe entre escalabilidade vertical e horizontal?','Scale up depende da maior configuração disponível para uma instância; scale out amplia capacidade adicionando instâncias.'),
  ('62000000-0000-4000-8000-000000000091','O que caracteriza a elasticidade em cloud computing?','Elasticidade é a capacidade de aumentar e reduzir recursos em resposta à demanda, frequentemente por automação baseada em métricas.'),
  ('62000000-0000-4000-8000-000000000093','Qual mecanismo é usado para implementar elasticidade com base em métricas de utilização?','O autoscaling aplica regras para adicionar ou remover capacidade quando as métricas atendem às condições configuradas.'),
  ('62000000-0000-4000-8000-000000000096','Novas instâncias são adicionadas tarde durante picos de tráfego. Qual ajuste pode antecipar o scale-out?','Reduzir adequadamente o threshold ou o período de avaliação pode disparar o scale-out antes, após validar ruído, cooldown e tempo de inicialização.'),
  ('62000000-0000-4000-8000-000000000098','O que ocorre quando o tráfego cai em um sistema com elasticidade automática, em comparação com capacidade fixa?','A política elástica pode remover capacidade e reduzir o custo associado; a configuração fixa mantém a capacidade provisionada.'),
  ('62000000-0000-4000-8000-000000000102','Qual prática contribui diretamente para recuperar um sistema após uma falha grave?','Um plano de disaster recovery define como restaurar dados e serviços de acordo com objetivos de recuperação estabelecidos.'),
  ('62000000-0000-4000-8000-000000000104','Uma aplicação perdeu dados recentes após uma falha. Qual controle deveria ter sido implementado e validado previamente?','Backups regulares e testes de restauração permitem recuperar dados dentro dos objetivos definidos para a carga.'),
  ('62000000-0000-4000-8000-000000000105','Qual benefício de confiabilidade resulta de monitoramento contínuo com alertas sobre métricas críticas?','Alertas reduzem o tempo de detecção e permitem resposta antecipada, antes que uma degradação provoque uma interrupção maior.'),
  ('62000000-0000-4000-8000-000000000108','Como o failover automático afeta a confiabilidade quando um componente falha?','O failover redireciona o atendimento a componentes saudáveis e reduz o tempo de recuperação em relação a uma intervenção manual.'),
  ('62000000-0000-4000-8000-000000000111','O que significa previsibilidade em cloud computing?','Previsibilidade é a capacidade de estimar o comportamento de desempenho e custos com base em requisitos, medições e padrões de uso.');

update public.questions question
set question_text = seed.question_text,
    explanation = seed.explanation,
    updated_at = now()
from az900_question_text_seed_0_127 seed
where question.id = seed.id;

create temporary table az900_option_text_seed_0_127 (
  id uuid primary key,
  option_text text not null
) on commit drop;

insert into az900_option_text_seed_0_127 values
  ('70000000-0000-4000-8000-000000000014','Latência e proximidade dos usuários, sem validar requisitos de residência de dados.'),
  ('70000000-0000-4000-8000-000000000015','Preço do serviço, mesmo que a SKU necessária não esteja disponível na Region.'),
  ('70000000-0000-4000-8000-000000000016','Opções de resiliência da Region, sem considerar latência, serviços ou compliance.'),
  ('70000000-0000-4000-8000-000000000018','Manter a aplicação disponível durante a falha completa da Region, sem replicação regional.'),
  ('70000000-0000-4000-8000-000000000019','Aumentar a capacidade de cada instância para absorver picos de processamento.'),
  ('70000000-0000-4000-8000-000000000020','Reduzir a latência entre usuários globais e a aplicação hospedada em uma única Region.'),
  ('70000000-0000-4000-8000-000000000022','Colocar os recursos na mesma subscription e usar esse escopo para permissões e custos.'),
  ('70000000-0000-4000-8000-000000000023','Hospedar os recursos na mesma Azure Region para criar um escopo comum de acesso.'),
  ('70000000-0000-4000-8000-000000000024','Aplicar a mesma tag aos recursos e usar a tag como escopo nativo de RBAC.'),
  ('70000000-0000-4000-8000-000000000030','App Service e VM fornecem ao cliente o mesmo controle do sistema operacional convidado.'),
  ('70000000-0000-4000-8000-000000000031','A VM transfere à Microsoft a administração do código e dos dados da aplicação.'),
  ('70000000-0000-4000-8000-000000000032','O App Service exige que o cliente mantenha e aplique patches no sistema operacional convidado.'),
  ('71000000-0000-4000-8000-000000000002','Um par de Regions conectado para apoiar estratégias de recuperação de desastre.'),
  ('71000000-0000-4000-8000-000000000003','Um datacenter escolhido pelo cliente dentro de uma geography do Azure.'),
  ('71000000-0000-4000-8000-000000000004','Um conjunto de recursos replicados entre duas Azure Regions.'),
  ('71000000-0000-4000-8000-000000000006','O recurso zonal usa uma Region inteira; o recurso com redundância de zona usa uma Zone.'),
  ('71000000-0000-4000-8000-000000000007','Ambos distribuem instâncias entre Zones; muda apenas quem escolhe a Region.'),
  ('71000000-0000-4000-8000-000000000008','O recurso com redundância de zona replica dados para uma Region secundária.'),
  ('71000000-0000-4000-8000-000000000010','Que a subscription contenha resource groups em cada uma das Zones desejadas.'),
  ('71000000-0000-4000-8000-000000000011','Que a Region pertença a uma Region Pair com replicação habilitada.'),
  ('71000000-0000-4000-8000-000000000012','Que a Region ofereça Zones, pois isso habilita a distribuição para qualquer SKU.'),
  ('71000000-0000-4000-8000-000000000014','Usar uma instância maior em uma única Zone para reduzir o risco de indisponibilidade.'),
  ('71000000-0000-4000-8000-000000000015','Replicar backups para outra Region, sem distribuir o serviço entre Zones.'),
  ('71000000-0000-4000-8000-000000000016','Selecionar qualquer SKU na Region, pois o suporte zonal é definido apenas pela localização.');

-- The legacy 620/730-series below is intentionally rewritten by explicit option UUID.
insert into az900_option_text_seed_0_127 values
  ('73000000-0000-4000-8000-000000000001','Recursos de computação entregues sob demanda pela rede.'),
  ('73000000-0000-4000-8000-000000000002','Capacidade de servidores adquirida antecipadamente e operada pela própria empresa.'),
  ('73000000-0000-4000-8000-000000000003','Infraestrutura local administrada por um fornecedor contratado.'),
  ('73000000-0000-4000-8000-000000000004','Software instalado e licenciado individualmente em cada dispositivo do usuário.'),
  ('73000000-0000-4000-8000-000000000005','Provisionamento feito por uma equipe do provedor após cada solicitação.'),
  ('73000000-0000-4000-8000-000000000007','Capacidade contratada antecipadamente para todo o prazo do serviço.'),
  ('73000000-0000-4000-8000-000000000008','Acesso aos recursos limitado à rede privada do cliente.'),
  ('73000000-0000-4000-8000-000000000013','Ampliar a infraestrutura local e depreciar os novos ativos ao longo do tempo.'),
  ('73000000-0000-4000-8000-000000000014','Terceirizar a manutenção do hardware que continua no datacenter da empresa.'),
  ('73000000-0000-4000-8000-000000000015','Alugar espaço e energia para instalar novos servidores de propriedade da empresa.'),
  ('73000000-0000-4000-8000-000000000018','Reservar capacidade para vários anos com pagamento antecipado.'),
  ('73000000-0000-4000-8000-000000000019','Dimensionar uma infraestrutura local pela previsão de demanda máxima.'),
  ('73000000-0000-4000-8000-000000000020','Contratar hardware dedicado com capacidade definida para o crescimento esperado.'),
  ('73000000-0000-4000-8000-000000000025','Comprar capacidade para o pico e depreciá-la como investimento de capital.'),
  ('73000000-0000-4000-8000-000000000027','Reservar capacidade fixa segundo a previsão dos picos promocionais.'),
  ('73000000-0000-4000-8000-000000000028','Manter hardware dedicado dimensionado para a maior demanda observada.'),
  ('73000000-0000-4000-8000-000000000029','Nos dois modelos, a capacidade adicional normalmente depende da entrega de hardware.'),
  ('73000000-0000-4000-8000-000000000030','No ambiente local, virtualização permite ampliar a capacidade física em minutos.'),
  ('73000000-0000-4000-8000-000000000031','Na nuvem, ampliar capacidade exige instalar fisicamente novos servidores no datacenter do cliente.'),
  ('73000000-0000-4000-8000-000000000034','Recriar a dependência de hardware em uma VM e migrar as cargas na mesma etapa.'),
  ('73000000-0000-4000-8000-000000000035','Manter todas as cargas no ambiente local até que o sistema legado possa ser substituído.'),
  ('73000000-0000-4000-8000-000000000036','Adotar nuvem privada para todas as cargas por causa do requisito de hardware legado.'),
  ('73000000-0000-4000-8000-000000000037','Comparar apenas a quantidade de usuários com o preço de uma VM básica.'),
  ('73000000-0000-4000-8000-000000000038','Escolher nuvem porque uma aplicação com poucos usuários necessariamente consome poucos recursos.'),
  ('73000000-0000-4000-8000-000000000040','Escolher o ambiente local porque o horário comercial torna o custo de nuvem irrelevante.'),
  ('73000000-0000-4000-8000-000000000065','A parcela do provedor diminui, pois SaaS oferece mais controle da infraestrutura ao cliente.'),
  ('73000000-0000-4000-8000-000000000066','A parcela do cliente aumenta porque ele passa a administrar também a aplicação SaaS.'),
  ('73000000-0000-4000-8000-000000000067','As responsabilidades permanecem iguais, pois dados e identidades existem nos dois modelos.'),
  ('73000000-0000-4000-8000-000000000068','O cliente passa a administrar a aplicação SaaS, enquanto o provedor assume dados e identidades.'),
  ('73000000-0000-4000-8000-000000000073','O provedor de SaaS, por ser responsável pela autenticação oferecida pela plataforma.'),
  ('73000000-0000-4000-8000-000000000075','O provedor e o cliente igualmente, pois a camada SaaS torna toda segurança compartilhada.'),
  ('73000000-0000-4000-8000-000000000076','O fornecedor do mecanismo de autenticação, mesmo quando a política de senha é definida pelo cliente.'),
  ('73000000-0000-4000-8000-000000000077','IaaS, porque o provedor administra o hardware e o cliente administra as demais camadas.'),
  ('73000000-0000-4000-8000-000000000078','Infraestrutura local gerenciada por uma equipe terceirizada.'),
  ('73000000-0000-4000-8000-000000000079','PaaS, porque além da plataforma o provedor também administra a aplicação do cliente.'),
  ('73000000-0000-4000-8000-000000000085','Um ambiente dedicado a várias organizações do mesmo setor.'),
  ('73000000-0000-4000-8000-000000000087','Um ambiente público com isolamento lógico entre vários clientes.'),
  ('73000000-0000-4000-8000-000000000088','Uma integração entre recursos locais e serviços de nuvem pública.'),
  ('73000000-0000-4000-8000-000000000109','A nuvem pública oferece maior controle físico porque o provedor opera mais datacenters.'),
  ('73000000-0000-4000-8000-000000000110','Os dois modelos oferecem controle físico equivalente, mas diferem apenas no faturamento.'),
  ('73000000-0000-4000-8000-000000000111','A nuvem privada reduz o controle da organização em troca de maior elasticidade.'),
  ('73000000-0000-4000-8000-000000000114','Uma estratégia multicloud, porque usa ambientes localizados em países diferentes.'),
  ('73000000-0000-4000-8000-000000000115','Nuvem pública, porque as campanhas são executadas em serviços compartilhados.'),
  ('73000000-0000-4000-8000-000000000116','Nuvem privada, porque os dados regulados permanecem em infraestrutura dedicada.'),
  ('73000000-0000-4000-8000-000000000117','Nuvem privada, priorizando capacidade dedicada e controle do hardware.'),
  ('73000000-0000-4000-8000-000000000118','Infraestrutura on-premises dimensionada para a maior audiência prevista.'),
  ('73000000-0000-4000-8000-000000000120','Nuvem híbrida, mantendo a entrega de vídeo local e usando a nuvem para picos.'),
  ('73000000-0000-4000-8000-000000000121','Preço unitário, porque o menor valor garante o menor custo total.'),
  ('73000000-0000-4000-8000-000000000123','Classificação dos dados, usada isoladamente para definir o modelo de implantação.'),
  ('73000000-0000-4000-8000-000000000124','Tecnologia usada pela aplicação, pois ela determina diretamente o modelo de implantação.'),
  ('73000000-0000-4000-8000-000000000129','Menor preço unitário, sem projetar utilização ou custo operacional.'),
  ('73000000-0000-4000-8000-000000000130','Proximidade do escritório, mesmo quando não há requisito de latência ou localização.'),
  ('73000000-0000-4000-8000-000000000131','Fornecedor do software, independentemente dos requisitos de controle da carga.'),
  ('73000000-0000-4000-8000-000000000137','Nuvem privada para manter capacidade dedicada durante toda a validação.'),
  ('73000000-0000-4000-8000-000000000139','Infraestrutura local reutilizável, adquirida antes da validação do produto.'),
  ('73000000-0000-4000-8000-000000000140','Capacidade reservada de longo prazo para obter previsibilidade no experimento.'),
  ('73000000-0000-4000-8000-000000000145','Nuvem pública com recursos dimensionados conforme a demanda.'),
  ('73000000-0000-4000-8000-000000000146','Nuvem privada hospedada, com recursos dedicados à organização.'),
  ('73000000-0000-4000-8000-000000000147','Infraestrutura própria financiada e depreciada ao longo de vários anos.'),
  ('73000000-0000-4000-8000-000000000148','Servidores dedicados em colocation, cobrados por capacidade reservada.'),
  ('73000000-0000-4000-8000-000000000149','A nuvem privada tende a ter menor custo inicial por usar recursos dedicados.'),
  ('73000000-0000-4000-8000-000000000150','A nuvem pública tende a exigir maior investimento inicial por compartilhar infraestrutura.'),
  ('73000000-0000-4000-8000-000000000152','O custo inicial tende a ser equivalente quando os dois ambientes são hospedados por um provedor.'),
  ('73000000-0000-4000-8000-000000000153','Escolher nuvem pública com base apenas nas certificações divulgadas pelo provedor.'),
  ('73000000-0000-4000-8000-000000000155','Escolher a menor estimativa mensal antes de mapear controles e obrigações regulatórias.'),
  ('73000000-0000-4000-8000-000000000156','Manter os prontuários localmente e usar a nuvem pública para cópias desidentificadas.'),
  ('73000000-0000-4000-8000-000000000157','Migrar primeiro os sistemas legados, usando a nuvem pública como único destino.'),
  ('73000000-0000-4000-8000-000000000158','Manter todas as cargas locais até que seja possível modernizá-las simultaneamente.'),
  ('73000000-0000-4000-8000-000000000159','Usar nuvem privada para todas as cargas, mesmo quando não há requisito de dedicação.'),
  ('73000000-0000-4000-8000-000000000173','Manter capacidade reservada para a janela noturna e reutilizá-la em outras tarefas durante o dia.'),
  ('73000000-0000-4000-8000-000000000174','Comprar servidores para obter custo estável durante todas as janelas de processamento.'),
  ('73000000-0000-4000-8000-000000000175','Usar capacidade de nuvem reservada para o pico, mesmo quando a rotina não está ativa.'),
  ('73000000-0000-4000-8000-000000000178','Reservar desde o lançamento a capacidade estimada para o cenário de maior sucesso.'),
  ('73000000-0000-4000-8000-000000000179','Assumir um compromisso de uso plurianual para reduzir o preço unitário.'),
  ('73000000-0000-4000-8000-000000000180','Comprar hardware suficiente para crescer sem alterar o ambiente após o lançamento.'),
  ('73000000-0000-4000-8000-000000000181','Apenas melhora a segurança, pois recursos desligados continuam gerando o mesmo custo de computação.'),
  ('73000000-0000-4000-8000-000000000182','Aumenta o custo de armazenamento, que passa a ser cobrado como computação ativa.'),
  ('73000000-0000-4000-8000-000000000184','Converte a cobrança variável em capacidade reservada para o restante do mês.'),
  ('73000000-0000-4000-8000-000000000185','Manter capacidade para o maior evento e reutilizá-la entre eventos menores.'),
  ('73000000-0000-4000-8000-000000000187','Comprar hardware para cada local de evento e integrar os servidores à nuvem.'),
  ('73000000-0000-4000-8000-000000000188','Reservar capacidade anual para estabilizar o custo, mesmo com poucos eventos.'),
  ('73000000-0000-4000-8000-000000000194','O primeiro cenário tende a ser mais eficiente porque capacidade ociosa não gera custo operacional.'),
  ('73000000-0000-4000-8000-000000000195','Os cenários têm eficiência semelhante porque ambos foram dimensionados para o mesmo pico.'),
  ('73000000-0000-4000-8000-000000000196','O segundo cenário tende a custar mais porque toda capacidade de nuvem é cobrada continuamente.'),
  ('73000000-0000-4000-8000-000000000197','Migrar os testes para hardware dedicado e manter a mesma janela de funcionamento.'),
  ('73000000-0000-4000-8000-000000000198','Adquirir reservas para cobrir também as horas em que os ambientes ficam ociosos.'),
  ('73000000-0000-4000-8000-000000000200','Aumentar o tamanho dos ambientes para concluir os testes mais rapidamente.'),
  ('73000000-0000-4000-8000-000000000213','CapEx, porque concentra o gasto e elimina a variação mensal.'),
  ('73000000-0000-4000-8000-000000000214','CapEx, financiando a compra dos servidores para distribuir os pagamentos.'),
  ('73000000-0000-4000-8000-000000000216','OpEx, contratando antecipadamente toda a capacidade prevista para vários anos.'),
  ('73000000-0000-4000-8000-000000000217','CapEx, porque o serviço de nuvem é usado por mais de um período contábil.'),
  ('73000000-0000-4000-8000-000000000219','CapEx, porque a capacidade virtual substitui servidores que seriam ativos físicos.'),
  ('73000000-0000-4000-8000-000000000220','OpEx e CapEx em partes iguais, independentemente do contrato e das regras contábeis.'),
  ('73000000-0000-4000-8000-000000000221','CapEx, usando depreciação para tornar o desembolso mensalmente variável.'),
  ('73000000-0000-4000-8000-000000000222','CapEx, adquirindo capacidade para os picos previstos no orçamento anual.'),
  ('73000000-0000-4000-8000-000000000223','OpEx, comprando servidores anualmente para uniformizar os investimentos.'),
  ('73000000-0000-4000-8000-000000000225','Uma transição predominante de CapEx para OpEx.'),
  ('73000000-0000-4000-8000-000000000226','Uma transição predominante de OpEx para CapEx.'),
  ('73000000-0000-4000-8000-000000000227','Uma mudança apenas operacional, sem efeito possível sobre a classificação financeira.'),
  ('73000000-0000-4000-8000-000000000228','A manutenção de CapEx, pois serviços de computação continuam sendo ativos físicos.'),
  ('73000000-0000-4000-8000-000000000229','CapEx costuma acompanhar mais rapidamente a demanda, pois o ativo já foi adquirido.'),
  ('73000000-0000-4000-8000-000000000230','Os dois modelos respondem igualmente à demanda, pois ambos permitem redimensionar recursos.'),
  ('73000000-0000-4000-8000-000000000232','OpEx é menos flexível porque a fatura pode variar de acordo com o consumo.'),
  ('73000000-0000-4000-8000-000000000233','Comparar apenas o desembolso inicial, usando-o como aproximação do custo de longo prazo.'),
  ('73000000-0000-4000-8000-000000000235','Comparar aquisição e primeira fatura, sem incluir operação, manutenção ou crescimento.'),
  ('73000000-0000-4000-8000-000000000236','Comparar capacidade de CPU e preço mensal, sem projetar manutenção nem crescimento.'),
  ('73000000-0000-4000-8000-000000000237','Priorizar CapEx para transformar toda a capacidade futura em um custo conhecido hoje.'),
  ('73000000-0000-4000-8000-000000000238','Manter pay-as-you-go sem budgets, pois a flexibilidade garante previsibilidade.'),
  ('73000000-0000-4000-8000-000000000239','Financiar infraestrutura para dez anos, reduzindo o caixa disponível durante a expansão.'),
  ('73000000-0000-4000-8000-000000000242','Um modelo no qual o código é executado sem servidores físicos na infraestrutura do provedor.'),
  ('73000000-0000-4000-8000-000000000243','Um modelo no qual o cliente escolhe e aplica patches nos servidores que executam cada função.'),
  ('73000000-0000-4000-8000-000000000244','Um modelo para conteúdo estático, sem execução acionada por eventos.'),
  ('73000000-0000-4000-8000-000000000249','Pela quantidade de servidores físicos reservados para cada função.'),
  ('73000000-0000-4000-8000-000000000250','Por uma mensalidade baseada na capacidade máxima, mesmo sem invocações.'),
  ('73000000-0000-4000-8000-000000000252','Por capacidade reservada, calculada antes da implantação da função.'),
  ('73000000-0000-4000-8000-000000000253','Executar um worker em uma VM dedicada que permaneça disponível entre os uploads.'),
  ('73000000-0000-4000-8000-000000000254','Executar um job agendado em uma VM que procure novos arquivos a cada intervalo.'),
  ('73000000-0000-4000-8000-000000000255','Executar o processamento em um contêiner com capacidade mínima permanentemente provisionada.'),
  ('73000000-0000-4000-8000-000000000261','Manter uma VM com um processo que consulta periodicamente o armazenamento.'),
  ('73000000-0000-4000-8000-000000000262','Executar um job agendado que verifica novos arquivos em intervalos definidos.'),
  ('73000000-0000-4000-8000-000000000264','Usar um serviço de contêineres com uma réplica mínima em execução.'),
  ('73000000-0000-4000-8000-000000000265','Um cluster de contêineres com capacidade mínima reservada para o protótipo.'),
  ('73000000-0000-4000-8000-000000000267','Uma VM pequena em execução contínua, redimensionada manualmente quando necessário.'),
  ('73000000-0000-4000-8000-000000000268','Capacidade reservada por um ano para reduzir o preço por hora do protótipo.'),
  ('73000000-0000-4000-8000-000000000269','Nos dois modelos, o cliente mantém o sistema operacional convidado e o runtime.'),
  ('73000000-0000-4000-8000-000000000270','Na VM, o provedor mantém o sistema operacional convidado, como ocorre em serverless.'),
  ('73000000-0000-4000-8000-000000000271','Serverless transfere ao cliente o escalonamento, enquanto a VM o oferece como padrão.'),
  ('73000000-0000-4000-8000-000000000274','Serverless tende a ser mais barato porque não cobra durante uma execução contínua.'),
  ('73000000-0000-4000-8000-000000000275','VMs tendem a ser inadequadas porque cargas constantes exigem acionamento por eventos.'),
  ('73000000-0000-4000-8000-000000000276','Os custos são equivalentes; a escolha depende apenas da linguagem da aplicação.'),
  ('73000000-0000-4000-8000-000000000277','Manter o monólito em uma VM e criar tarefas agendadas para cada tipo de evento.'),
  ('73000000-0000-4000-8000-000000000278','Executar cada componente em uma VM dedicada e permanentemente ativa.'),
  ('73000000-0000-4000-8000-000000000280','Executar os componentes em contêineres com réplicas mínimas provisionadas.'),
  ('73000000-0000-4000-8000-000000000289','Aumentar o tamanho de uma única instância para que ela tolere falhas de hardware.'),
  ('73000000-0000-4000-8000-000000000290','Manter duas réplicas na mesma instância para simplificar o failover.'),
  ('73000000-0000-4000-8000-000000000291','Usar backups frequentes como mecanismo de continuidade imediata do serviço.'),
  ('73000000-0000-4000-8000-000000000297','Usar várias instâncias em uma única Zone e replicar backups para outra Zone.'),
  ('73000000-0000-4000-8000-000000000299','Usar uma instância maior em uma Zone com reinicialização automática.'),
  ('73000000-0000-4000-8000-000000000300','Fazer backups em outra Zone para restaurar o serviço após a falha.'),
  ('73000000-0000-4000-8000-000000000301','Atualizar todas as instâncias na mesma janela, usando reinicialização automática.'),
  ('73000000-0000-4000-8000-000000000302','Criar uma janela de manutenção e retirar todas as instâncias do balanceador.'),
  ('73000000-0000-4000-8000-000000000303','Fazer atualização in-place na única instância e usar backup para rollback.'),
  ('73000000-0000-4000-8000-000000000306','Usar uma única VM maior com autoscaling vertical e backup diário.'),
  ('73000000-0000-4000-8000-000000000307','Usar backups frequentes como mecanismo principal de disponibilidade durante falhas.'),
  ('73000000-0000-4000-8000-000000000308','Distribuir instâncias em uma única zona e redimensioná-las manualmente nos picos.'),
  ('73000000-0000-4000-8000-000000000309','Uma instância maior tende a ser mais disponível porque tem mais capacidade.'),
  ('73000000-0000-4000-8000-000000000310','Múltiplas instâncias aumentam apenas desempenho, não continuidade durante falhas.'),
  ('73000000-0000-4000-8000-000000000312','Múltiplas instâncias reduzem disponibilidade por exigirem balanceamento de carga.'),
  ('73000000-0000-4000-8000-000000000322','A capacidade de recuperar dados de um backup após uma falha.'),
  ('73000000-0000-4000-8000-000000000323','A capacidade de manter o serviço disponível quando uma instância falha.'),
  ('73000000-0000-4000-8000-000000000324','A capacidade de estimar o custo mensal de uma carga estável.'),
  ('73000000-0000-4000-8000-000000000341','O custo unitário de CPU, pois scale out adiciona CPU à instância existente.'),
  ('73000000-0000-4000-8000-000000000342','A quantidade atual de usuários, sem considerar crescimento ou distribuição de estado.'),
  ('73000000-0000-4000-8000-000000000344','A redundância do servidor atual, pois uma instância maior elimina pontos únicos de falha.'),
  ('73000000-0000-4000-8000-000000000345','Continuar com scale up e planejar uma mudança de SKU antes do próximo limite.'),
  ('73000000-0000-4000-8000-000000000347','Capacidade fixa dimensionada para a projeção de usuários dos próximos anos.'),
  ('73000000-0000-4000-8000-000000000348','Scale in progressivo para concentrar usuários na instância existente.'),
  ('73000000-0000-4000-8000-000000000349','Scale up permite crescimento sem limite, desde que a VM seja reiniciada entre upgrades.'),
  ('73000000-0000-4000-8000-000000000350','Scale out é operacionalmente mais simples porque não exige distribuir estado ou tráfego.'),
  ('73000000-0000-4000-8000-000000000351','As duas abordagens têm o mesmo teto porque usam as SKUs disponíveis na Region.'),
  ('73000000-0000-4000-8000-000000000354','Continuar o scale up, trocando a máquina quando uma nova SKU maior surgir.'),
  ('73000000-0000-4000-8000-000000000355','Aplicar throttling para manter a carga dentro da capacidade da única instância.'),
  ('73000000-0000-4000-8000-000000000356','Adicionar uma instância passiva apenas para recuperação de desastre.'),
  ('73000000-0000-4000-8000-000000000357','Usar scale up e programar upgrades antes dos picos previstos.'),
  ('73000000-0000-4000-8000-000000000358','Reservar capacidade fixa para a maior demanda projetada no primeiro ano.'),
  ('73000000-0000-4000-8000-000000000360','Usar uma instância principal maior e uma réplica de leitura para absorver parte da demanda.'),
  ('73000000-0000-4000-8000-000000000361','A capacidade de manter o serviço disponível durante falhas de infraestrutura.'),
  ('73000000-0000-4000-8000-000000000363','A capacidade de aumentar permanentemente a maior instância disponível.'),
  ('73000000-0000-4000-8000-000000000364','A capacidade de prever o custo de uma configuração fixa ao longo do tempo.'),
  ('73000000-0000-4000-8000-000000000366','Elasticidade e escalabilidade são sinônimos porque ambas adicionam recursos.'),
  ('73000000-0000-4000-8000-000000000367','Elasticidade trata recuperação de falhas; escalabilidade trata variação de custo.'),
  ('73000000-0000-4000-8000-000000000368','Elasticidade existe apenas em nuvem pública; escalabilidade existe apenas on-premises.'),
  ('73000000-0000-4000-8000-000000000369','Redimensionamento manual da instância após o operador observar saturação.'),
  ('73000000-0000-4000-8000-000000000370','Capacidade reservada para o maior pico previsto, sem regras baseadas em métricas.'),
  ('73000000-0000-4000-8000-000000000371','Balanceamento entre instâncias fixas, sem adicionar ou remover capacidade.'),
  ('73000000-0000-4000-8000-000000000373','Manter capacidade para o pico anual e usar reservas para reduzir o custo.'),
  ('73000000-0000-4000-8000-000000000374','Aplicar scale up manual pouco antes do início programado das vendas.'),
  ('73000000-0000-4000-8000-000000000376','Adicionar instâncias após alertas manuais confirmarem a lentidão.'),
  ('73000000-0000-4000-8000-000000000377','Eliminar o custo de computação, pois o scale-in remove toda cobrança do serviço.'),
  ('73000000-0000-4000-8000-000000000379','Evitar falhas de segurança, pois o número de instâncias acompanha as requisições.'),
  ('73000000-0000-4000-8000-000000000380','Tornar o custo fixo, porque a política mantém a mesma capacidade durante o dia.'),
  ('73000000-0000-4000-8000-000000000381','Aumentar a capacidade mínima para o nível do pico e manter o autoscaling ativo.'),
  ('73000000-0000-4000-8000-000000000382','Aumentar o período de avaliação para evitar scale-out com picos curtos.'),
  ('73000000-0000-4000-8000-000000000383','Ajustar a regra de scale-in para remover capacidade mais lentamente após o pico.'),
  ('73000000-0000-4000-8000-000000000386','Reservar capacidade máxima durante toda a temporada de eventos.'),
  ('73000000-0000-4000-8000-000000000387','Aplicar scale up manual na VM antes de cada transmissão.'),
  ('73000000-0000-4000-8000-000000000388','Reduzir bitrate para manter a carga dentro da capacidade fixa contratada.'),
  ('73000000-0000-4000-8000-000000000389','A capacidade fixa reduz recursos após a queda; a elasticidade mantém o mínimo original.'),
  ('73000000-0000-4000-8000-000000000390','A elasticidade mantém a capacidade do pico até uma alteração manual.'),
  ('73000000-0000-4000-8000-000000000392','A capacidade fixa reduz o uso por instância, enquanto a elástica mantém a quantidade provisionada.'),
  ('73000000-0000-4000-8000-000000000393','Reduzir o limite máximo de instâncias sem consultar métricas ou eventos de escala.'),
  ('73000000-0000-4000-8000-000000000395','Comprar uma reserva para a capacidade atual e manter as regras sem alteração.'),
  ('73000000-0000-4000-8000-000000000396','Aumentar o período de estabilização antes do scale-in para manter capacidade por mais tempo.'),
  ('73000000-0000-4000-8000-000000000397','Usar capacidade programada para o horário comercial e tratar os demais picos manualmente.'),
  ('73000000-0000-4000-8000-000000000398','Usar apenas autoscaling vertical em uma única instância.'),
  ('73000000-0000-4000-8000-000000000399','Usar escalonamento agendado para picos previstos e ajuste manual para as demais variações.'),
  ('73000000-0000-4000-8000-000000000405','Aumentar a capacidade de uma única instância para reduzir o tempo de recuperação.'),
  ('73000000-0000-4000-8000-000000000407','Coletar mais métricas sem configurar alertas nem procedimentos de recuperação.'),
  ('73000000-0000-4000-8000-000000000408','Criar backups regulares sem testar restauração ou definir failover.'),
  ('73000000-0000-4000-8000-000000000409','Pelo percentual de utilização média de CPU durante os períodos de pico.'),
  ('73000000-0000-4000-8000-000000000410','Pelo custo médio de execução entre duas janelas de manutenção.'),
  ('73000000-0000-4000-8000-000000000412','Pelo número de instâncias provisionadas, sem considerar falhas ou recuperação.'),
  ('73000000-0000-4000-8000-000000000425','Aumentar a capacidade da instância para que a falha seja processada mais rapidamente.'),
  ('73000000-0000-4000-8000-000000000427','Adicionar uma réplica sem health checks, mantendo a detecção manual.'),
  ('73000000-0000-4000-8000-000000000428','Fazer backups mais frequentes para reduzir o tempo até a equipe detectar uma falha.'),
  ('73000000-0000-4000-8000-000000000429','O sistema sem failover tende a ser mais confiável por ter menos componentes.'),
  ('73000000-0000-4000-8000-000000000430','O failover aumenta disponibilidade, mas não afeta o tempo de recuperação.'),
  ('73000000-0000-4000-8000-000000000431','Os dois têm confiabilidade equivalente quando usam a mesma capacidade de computação.'),
  ('73000000-0000-4000-8000-000000000434','A quantidade de instâncias, sozinha, demonstra que o primeiro sistema é mais confiável.'),
  ('73000000-0000-4000-8000-000000000435','Os testes do segundo sistema compensam integralmente a menor redundância em produção.'),
  ('73000000-0000-4000-8000-000000000436','Planos documentados são suficientes; testes e redundância podem ser avaliados separadamente.'),
  ('73000000-0000-4000-8000-000000000437','Backups diários com restauração manual, sem instâncias redundantes.'),
  ('73000000-0000-4000-8000-000000000438','Múltiplas instâncias na mesma zona com monitoramento, sem plano de recuperação zonal.'),
  ('73000000-0000-4000-8000-000000000440','Uma instância de grande porte com backup frequente em armazenamento local.'),
  ('73000000-0000-4000-8000-000000000441','A capacidade de manter desempenho constante com uma quantidade fixa de recursos.'),
  ('73000000-0000-4000-8000-000000000443','A capacidade de garantir que a fatura real seja igual à estimativa inicial.'),
  ('73000000-0000-4000-8000-000000000444','A capacidade de prever falhas individuais e impedir cada indisponibilidade.'),
  ('73000000-0000-4000-8000-000000000449','Azure Service Health, para estimar o efeito financeiro de incidentes futuros.'),
  ('73000000-0000-4000-8000-000000000450','Azure Monitor Metrics, para converter utilização histórica diretamente em preço de uma arquitetura nova.'),
  ('73000000-0000-4000-8000-000000000451','Microsoft Defender for Cloud, para calcular os preços das SKUs recomendadas.'),
  ('73000000-0000-4000-8000-000000000452','Azure Pricing Calculator.');

-- Complete every touched Question with all four existing Option UUIDs.
insert into az900_option_text_seed_0_127 values
  ('70000000-0000-4000-8000-000000000013','Latência, disponibilidade dos serviços, residência de dados, compliance, preço e opções de resiliência.'),
  ('70000000-0000-4000-8000-000000000017','Reduzir o impacto de uma falha localizada em uma Availability Zone.'),
  ('70000000-0000-4000-8000-000000000021','Colocar os recursos relacionados em um resource group.'),
  ('70000000-0000-4000-8000-000000000029','O App Service administra a plataforma e grande parte do sistema operacional; na VM, o cliente administra o sistema operacional convidado.'),
  ('71000000-0000-4000-8000-000000000001','Um ou mais datacenters fisicamente separados dentro de uma Region, com infraestrutura independente das demais zonas.'),
  ('71000000-0000-4000-8000-000000000005','O recurso zonal fica em uma zona; o recurso com redundância de zona usa múltiplas zonas quando o serviço oferece suporte.'),
  ('71000000-0000-4000-8000-000000000009','Region, serviço, camada ou SKU e configuração compatíveis com Availability Zones.'),
  ('71000000-0000-4000-8000-000000000013','Configurar o recurso como zonal em múltiplas zonas ou com redundância de zona, conforme o suporte do serviço.'),
  ('73000000-0000-4000-8000-000000000006','Autoatendimento sob demanda.'),
  ('73000000-0000-4000-8000-000000000016','Migrar as cargas de trabalho para cloud computing.'),
  ('73000000-0000-4000-8000-000000000017','Usar o modelo baseado em consumo para ajustar recursos e cobrança ao uso efetivo.'),
  ('73000000-0000-4000-8000-000000000026','Modelo baseado em consumo, com cobrança de acordo com os recursos utilizados.'),
  ('73000000-0000-4000-8000-000000000032','Na nuvem, recursos podem ser provisionados por software em minutos; no ambiente próprio, a expansão costuma depender de aquisição e instalação de hardware.'),
  ('73000000-0000-4000-8000-000000000033','Adotar a nuvem seletivamente para as cargas que se beneficiam de elasticidade e acesso remoto.'),
  ('73000000-0000-4000-8000-000000000039','Comparar o custo total e os requisitos de manter o servidor dedicado com o consumo sob demanda na nuvem.'),
  ('73000000-0000-4000-8000-000000000042','Uma divisão de responsabilidades entre provedor e cliente que varia conforme o tipo de serviço.'),
  ('73000000-0000-4000-8000-000000000041','Uma divisão em que o provedor administra a segurança da plataforma e também classifica os dados inseridos pelo cliente.'),
  ('73000000-0000-4000-8000-000000000043','Uma divisão definida pela localização dos usuários, independentemente do tipo de serviço contratado.'),
  ('73000000-0000-4000-8000-000000000044','Uma matriz usada para transferir ao provedor as decisões de identidade e acesso do cliente.'),
  ('73000000-0000-4000-8000-000000000049','Manutenção dos servidores físicos usados pelo provedor.'),
  ('73000000-0000-4000-8000-000000000050','Climatização e fornecimento de energia dos datacenters do provedor.'),
  ('73000000-0000-4000-8000-000000000052','Classificação e proteção dos dados e gestão das identidades de acesso.'),
  ('73000000-0000-4000-8000-000000000051','Proteção da rede física entre os datacenters do provedor.'),
  ('73000000-0000-4000-8000-000000000053','A Microsoft, porque a VM é executada sobre hardware do Azure.'),
  ('73000000-0000-4000-8000-000000000054','A Microsoft para patches críticos e o cliente para as demais atualizações.'),
  ('73000000-0000-4000-8000-000000000056','O fornecedor da aplicação instalada na VM, por administrar seu ciclo de versões.'),
  ('73000000-0000-4000-8000-000000000055','O cliente que administra o sistema operacional convidado.'),
  ('73000000-0000-4000-8000-000000000058','Gerenciar identidades dos usuários e políticas de acesso ao e-mail.'),
  ('73000000-0000-4000-8000-000000000057','Aplicar patches no sistema operacional dos servidores que hospedam o SaaS.'),
  ('73000000-0000-4000-8000-000000000059','Atualizar o runtime usado internamente pelo serviço de e-mail.'),
  ('73000000-0000-4000-8000-000000000060','Manter os dispositivos de rede física do datacenter do provedor.'),
  ('73000000-0000-4000-8000-000000000061','O cliente administra hardware e virtualização; o provedor administra apenas o runtime.'),
  ('73000000-0000-4000-8000-000000000064','O provedor administra runtime, middleware e sistema operacional; o cliente administra aplicação, dados e acessos.'),
  ('73000000-0000-4000-8000-000000000062','O provedor administra a aplicação e os dados; o cliente administra middleware e runtime.'),
  ('73000000-0000-4000-8000-000000000063','O provedor administra identidades e dados; o cliente administra o sistema operacional da plataforma.'),
  ('73000000-0000-4000-8000-000000000074','A empresa cliente, que administra suas identidades e políticas de acesso.'),
  ('73000000-0000-4000-8000-000000000080','SaaS.'),
  ('73000000-0000-4000-8000-000000000082','Recursos dedicados a uma organização e operados em seu próprio datacenter.'),
  ('73000000-0000-4000-8000-000000000083','Recursos dedicados a uma organização, mas hospedados por um provedor externo.'),
  ('73000000-0000-4000-8000-000000000081','Recursos oferecidos por um provedor e compartilhados entre clientes com isolamento lógico.'),
  ('73000000-0000-4000-8000-000000000084','Integração de recursos locais com capacidade oferecida por um provedor de nuvem.'),
  ('73000000-0000-4000-8000-000000000086','Um ambiente de nuvem com recursos dedicados a uma única organização.'),
  ('73000000-0000-4000-8000-000000000091','Um ambiente que integra infraestrutura privada ou on-premises a recursos de nuvem pública.'),
  ('73000000-0000-4000-8000-000000000089','Um ambiente privado operado em dois datacenters da mesma organização.'),
  ('73000000-0000-4000-8000-000000000090','Um ambiente que combina serviços de nuvem pública de dois provedores.'),
  ('73000000-0000-4000-8000-000000000092','Um ambiente público que usa sub-redes separadas para cada aplicação.'),
  ('73000000-0000-4000-8000-000000000093','Nuvem pública com isolamento lógico e controles de acesso gerenciados.'),
  ('73000000-0000-4000-8000-000000000096','Nuvem privada com recursos dedicados à instituição.'),
  ('73000000-0000-4000-8000-000000000094','Nuvem híbrida com parte da carga em serviços públicos compartilhados.'),
  ('73000000-0000-4000-8000-000000000095','Nuvem soberana pública que atende requisitos de localização, mas não oferece infraestrutura dedicada.'),
  ('73000000-0000-4000-8000-000000000098','Nuvem privada que recebe capacidade adicional de outro ambiente privado.'),
  ('73000000-0000-4000-8000-000000000099','Nuvem pública acessada por conexão privada a partir do datacenter.'),
  ('73000000-0000-4000-8000-000000000097','Nuvem híbrida, integrando infraestrutura on-premises e nuvem pública.'),
  ('73000000-0000-4000-8000-000000000100','Estratégia multicloud, usando serviços públicos de provedores diferentes.'),
  ('73000000-0000-4000-8000-000000000101','Nuvem privada, para reservar capacidade dedicada ao portal.'),
  ('73000000-0000-4000-8000-000000000102','Nuvem híbrida, mantendo o front-end local e usando a nuvem para picos.'),
  ('73000000-0000-4000-8000-000000000104','Nuvem comunitária, compartilhada apenas por órgãos do mesmo setor.'),
  ('73000000-0000-4000-8000-000000000103','Nuvem pública.'),
  ('73000000-0000-4000-8000-000000000106','Nuvem híbrida.'),
  ('73000000-0000-4000-8000-000000000105','Nuvem pública com criptografia e controles de acesso, inclusive para os registros sensíveis.'),
  ('73000000-0000-4000-8000-000000000107','Nuvem privada para registros e para a análise de dados não sensíveis.'),
  ('73000000-0000-4000-8000-000000000108','Estratégia multicloud, distribuindo as cargas entre dois provedores públicos.'),
  ('73000000-0000-4000-8000-000000000112','A nuvem privada oferece maior controle sobre recursos dedicados; na pública, o provedor administra a infraestrutura física.'),
  ('73000000-0000-4000-8000-000000000113','Nuvem híbrida, mantendo a carga regulada no ambiente privado e o site na nuvem pública.'),
  ('73000000-0000-4000-8000-000000000119','Nuvem pública.'),
  ('73000000-0000-4000-8000-000000000122','Requisitos de controle, conformidade, integração, desempenho e custo total.'),
  ('73000000-0000-4000-8000-000000000132','O nível de controle, os requisitos de conformidade e as necessidades da carga.'),
  ('73000000-0000-4000-8000-000000000133','Nuvem pública com controles de acesso para dados e site institucional.'),
  ('73000000-0000-4000-8000-000000000134','Infraestrutura on-premises para dados e site institucional.'),
  ('73000000-0000-4000-8000-000000000136','Nuvem privada para dados e site institucional.'),
  ('73000000-0000-4000-8000-000000000135','Nuvem híbrida.'),
  ('73000000-0000-4000-8000-000000000138','Nuvem pública, com provisionamento sob demanda e baixo investimento inicial.'),
  ('73000000-0000-4000-8000-000000000141','Nuvem pública para o controle de produção e para a análise histórica.'),
  ('73000000-0000-4000-8000-000000000144','Nuvem híbrida.'),
  ('73000000-0000-4000-8000-000000000142','Nuvem privada hospedada, levando também a análise histórica ao ambiente dedicado.'),
  ('73000000-0000-4000-8000-000000000143','Nuvem privada local para todas as cargas da fábrica.'),
  ('73000000-0000-4000-8000-000000000151','A nuvem pública tende a exigir menor investimento inicial; a privada costuma envolver infraestrutura dedicada.'),
  ('73000000-0000-4000-8000-000000000154','Avaliar os requisitos legais e os controles necessários e verificar como cada arquitetura os atende.'),
  ('73000000-0000-4000-8000-000000000160','Adotar uma nuvem híbrida e migrar gradualmente as cargas compatíveis para a nuvem pública.'),
  ('73000000-0000-4000-8000-000000000162','Uma mensalidade fixa baseada na quantidade de usuários cadastrados.'),
  ('73000000-0000-4000-8000-000000000163','Uma compra antecipada de capacidade para todo o prazo do contrato.'),
  ('73000000-0000-4000-8000-000000000161','Uma cobrança relacionada às unidades de recursos efetivamente consumidas.'),
  ('73000000-0000-4000-8000-000000000164','Uma taxa anual baseada no número de serviços habilitados, e não no consumo.'),
  ('73000000-0000-4000-8000-000000000165','Manter capacidade máxima durante todo o ano para estabilizar o custo mensal.'),
  ('73000000-0000-4000-8000-000000000167','Contratar capacidade fixa para toda a estação de maior demanda.'),
  ('73000000-0000-4000-8000-000000000168','Ampliar a infraestrutura própria antes de cada temporada de pico.'),
  ('73000000-0000-4000-8000-000000000166','Reduzir recursos e gastos nos períodos de menor demanda.'),
  ('73000000-0000-4000-8000-000000000171','As unidades de recursos consumidas segundo a métrica de cobrança do serviço.'),
  ('73000000-0000-4000-8000-000000000169','A capacidade máxima disponível na Region, mesmo quando não foi provisionada.'),
  ('73000000-0000-4000-8000-000000000170','A quantidade de identidades cadastradas no tenant, para qualquer tipo de recurso.'),
  ('73000000-0000-4000-8000-000000000172','O custo do hardware equivalente que seria adquirido para o datacenter.'),
  ('73000000-0000-4000-8000-000000000176','Provisionar recursos durante o processamento noturno e reduzi-los ao final.'),
  ('73000000-0000-4000-8000-000000000177','Começar com poucos recursos e ampliar o consumo quando a demanda se confirmar.'),
  ('73000000-0000-4000-8000-000000000183','Redução das unidades faturadas por tempo de execução fora do horário de uso.'),
  ('73000000-0000-4000-8000-000000000186','Provisionar capacidade adicional durante cada evento e reduzi-la quando o evento terminar.'),
  ('73000000-0000-4000-8000-000000000193','O segundo cenário tende a ser mais eficiente quando a demanda varia, pois reduz capacidade ociosa.'),
  ('73000000-0000-4000-8000-000000000199','Desligar ou reduzir os ambientes fora do horário de uso.'),
  ('73000000-0000-4000-8000-000000000215','OpEx.'),
  ('73000000-0000-4000-8000-000000000218','OpEx.'),
  ('73000000-0000-4000-8000-000000000224','OpEx.'),
  ('73000000-0000-4000-8000-000000000231','OpEx costuma acompanhar melhor variações de consumo no curto prazo.'),
  ('73000000-0000-4000-8000-000000000234','Comparar o custo total de propriedade ao longo do horizonte relevante.'),
  ('73000000-0000-4000-8000-000000000240','Adotar OpEx por meio de serviços de nuvem pagos conforme o uso.'),
  ('73000000-0000-4000-8000-000000000241','Um modelo em que o provedor gerencia a infraestrutura de execução e seu escalonamento.'),
  ('73000000-0000-4000-8000-000000000245','Usar contêineres com capacidade mínima administrada pela equipe de desenvolvimento.'),
  ('73000000-0000-4000-8000-000000000247','Usar uma VM com o runtime e o sistema operacional administrados pela equipe.'),
  ('73000000-0000-4000-8000-000000000248','Contratar capacidade dedicada e programar as execuções da aplicação.'),
  ('73000000-0000-4000-8000-000000000246','Executar código sem provisionar nem administrar os servidores subjacentes.'),
  ('73000000-0000-4000-8000-000000000251','Com base nas execuções, na duração e nos recursos consumidos, conforme o serviço.'),
  ('73000000-0000-4000-8000-000000000256','Uma função serverless acionada quando ocorre o upload.'),
  ('73000000-0000-4000-8000-000000000263','Configurar uma função serverless acionada pelo evento de novo arquivo.'),
  ('73000000-0000-4000-8000-000000000266','Serverless computing, com cobrança baseada na execução medida.'),
  ('73000000-0000-4000-8000-000000000272','No serverless, o provedor administra infraestrutura e escala; na VM, o cliente administra o sistema operacional convidado.'),
  ('73000000-0000-4000-8000-000000000273','Comparar custo total e requisitos operacionais, pois cargas constantes podem favorecer capacidade planejada.'),
  ('73000000-0000-4000-8000-000000000279','Usar funções serverless independentes, acionadas pelos eventos correspondentes.'),
  ('73000000-0000-4000-8000-000000000286','Uma meta interna de disponibilidade definida apenas pela equipe da aplicação.'),
  ('73000000-0000-4000-8000-000000000285','Um SLA que define o compromisso de disponibilidade e suas condições de medição.'),
  ('73000000-0000-4000-8000-000000000287','Um relatório do Azure Monitor que registra o uptime observado pelo cliente.'),
  ('73000000-0000-4000-8000-000000000288','Uma recomendação do Azure Advisor sobre a confiabilidade da arquitetura.'),
  ('73000000-0000-4000-8000-000000000292','Distribuir a aplicação entre instâncias redundantes e encaminhar tráfego para as instâncias saudáveis.'),
  ('73000000-0000-4000-8000-000000000298','Distribuir a aplicação entre múltiplas Availability Zones.'),
  ('73000000-0000-4000-8000-000000000304','Usar uma implantação gradual, atualizando parte das instâncias por vez.'),
  ('73000000-0000-4000-8000-000000000305','Combinar instâncias redundantes, health checks e failover.'),
  ('73000000-0000-4000-8000-000000000311','Múltiplas instâncias redundantes podem continuar atendendo quando uma instância falha.'),
  ('73000000-0000-4000-8000-000000000321','A capacidade de ajustar recursos para suportar variações da carga.'),
  ('73000000-0000-4000-8000-000000000325','Adicionar novas instâncias para dividir a carga entre elas.'),
  ('73000000-0000-4000-8000-000000000327','Reduzir a quantidade de instâncias quando a demanda diminui.'),
  ('73000000-0000-4000-8000-000000000328','Distribuir instâncias entre Regions para atender usuários em locais diferentes.'),
  ('73000000-0000-4000-8000-000000000326','Aumentar a capacidade de uma única instância existente.'),
  ('73000000-0000-4000-8000-000000000343','Os limites de capacidade da instância e a necessidade de crescimento futuro.'),
  ('73000000-0000-4000-8000-000000000346','Escalabilidade horizontal, adicionando instâncias e distribuindo a carga.'),
  ('73000000-0000-4000-8000-000000000352','Scale up é limitado pela maior instância disponível; scale out pode adicionar instâncias.'),
  ('73000000-0000-4000-8000-000000000353','Migrar para escalabilidade horizontal e distribuir carga e estado entre instâncias.'),
  ('73000000-0000-4000-8000-000000000359','Projetar o sistema para scale out e distribuição de carga desde o início.'),
  ('73000000-0000-4000-8000-000000000362','A capacidade de aumentar e reduzir recursos em resposta à demanda.'),
  ('73000000-0000-4000-8000-000000000365','Elasticidade enfatiza o ajuste de recursos conforme a demanda; escalabilidade é a capacidade de suportar mudanças de carga.'),
  ('73000000-0000-4000-8000-000000000372','Autoscaling baseado em regras e métricas de utilização.'),
  ('73000000-0000-4000-8000-000000000375','Configurar autoscaling para aumentar capacidade no pico e reduzi-la depois.'),
  ('73000000-0000-4000-8000-000000000378','Reduzir capacidade ociosa nos períodos de baixa demanda.'),
  ('73000000-0000-4000-8000-000000000384','Revisar thresholds, períodos de avaliação e tempo de inicialização para antecipar o scale-out.'),
  ('73000000-0000-4000-8000-000000000385','Aumentar capacidade durante o evento e reduzi-la depois conforme a demanda.'),
  ('73000000-0000-4000-8000-000000000391','A política elástica pode remover recursos após a queda; a capacidade fixa permanece provisionada.'),
  ('73000000-0000-4000-8000-000000000394','Revisar métricas, thresholds, limites e histórico de eventos do autoscaling.'),
  ('73000000-0000-4000-8000-000000000400','Combinar arquitetura horizontalmente escalável com regras de autoscaling.'),
  ('73000000-0000-4000-8000-000000000406','Implementar e testar um plano de disaster recovery.'),
  ('73000000-0000-4000-8000-000000000411','Medir o tempo médio entre falhas e o tempo médio de recuperação.'),
  ('73000000-0000-4000-8000-000000000413','Aumentar a redundância das instâncias que processam as solicitações.'),
  ('73000000-0000-4000-8000-000000000416','Implementar backups regulares e testar a restauração.'),
  ('73000000-0000-4000-8000-000000000414','Configurar replicação síncrona entre as instâncias da aplicação.'),
  ('73000000-0000-4000-8000-000000000415','Aumentar CPU e memória para reduzir o tempo de processamento das gravações.'),
  ('73000000-0000-4000-8000-000000000418','Reduzir o custo da infraestrutura durante períodos de baixa utilização.'),
  ('73000000-0000-4000-8000-000000000419','Aumentar automaticamente a capacidade quando o volume de entregas cresce.'),
  ('73000000-0000-4000-8000-000000000417','Detectar e tratar problemas mais cedo, reduzindo o tempo até a resposta.'),
  ('73000000-0000-4000-8000-000000000420','Restaurar dados para um ponto anterior quando uma gravação incorreta ocorre.'),
  ('73000000-0000-4000-8000-000000000426','Usar monitoramento automatizado com alertas sobre sinais de falha.'),
  ('73000000-0000-4000-8000-000000000432','O failover automático reduz o tempo de recuperação ao redirecionar o atendimento.'),
  ('73000000-0000-4000-8000-000000000433','Redundância e testes de recuperação são complementares e devem ser validados contra objetivos definidos.'),
  ('73000000-0000-4000-8000-000000000439','Combinar redundância, monitoramento, failover e testes regulares de recuperação.'),
  ('73000000-0000-4000-8000-000000000442','A capacidade de estimar comportamento de desempenho e custos com base em medições e padrões de uso.');

update public.question_options option
set option_text = seed.option_text,
    updated_at = now()
from az900_option_text_seed_0_127 seed
where option.id = seed.id;



-- Fragmento de remediação editorial AZ-900: Questions 128..255 do inventário.
-- Intencionalmente sem BEGIN/COMMIT: o arquivo final da migration controla a transação.

create temporary table az900_remediation_question_seed (
  id uuid primary key,
  question_text text not null,
  explanation text not null
) on commit drop;

insert into az900_remediation_question_seed (id, question_text, explanation) values
('62000000-0000-4000-8000-000000000115','Uma aplicação apresenta tempos de resposta diferentes sob cargas semelhantes. Qual prática ajuda a tornar o desempenho mais previsível?','Testes de carga repetíveis e métricas históricas permitem identificar gargalos e validar se a aplicação mantém comportamento consistente.'),
('62000000-0000-4000-8000-000000000116','Uma organização precisa estimar o custo da nuvem para o orçamento do próximo ano. Qual abordagem produz a previsão mais confiável?','A combinação de estimativas de preço, histórico de consumo e mudanças planejadas considera tanto a tarifa quanto o uso esperado.'),
('62000000-0000-4000-8000-000000000117','O gasto mensal permanece estável, mas o tempo de resposta varia muito nos horários de pico. Qual dimensão da previsibilidade foi afetada?','A variação técnica percebida pelos usuários caracteriza baixa previsibilidade de desempenho, não de custos.'),
('62000000-0000-4000-8000-000000000118','Qual afirmação diferencia corretamente previsibilidade de desempenho e previsibilidade de custos?','A primeira trata do comportamento técnico esperado; a segunda, da capacidade de estimar e controlar os gastos.'),
('62000000-0000-4000-8000-000000000119','Uma manutenção planejada da plataforma pode afetar a aplicação. Qual fonte e qual ação tratam diretamente esse risco?','Azure Service Health informa manutenções relevantes ao ambiente; a equipe deve usar essa informação para revisar a estratégia de resiliência e failover da aplicação.'),
('62000000-0000-4000-8000-000000000120','Um sistema exige custo anual previsível e desempenho estável diante de variações moderadas de demanda. Qual estratégia atende aos dois requisitos?','Estimativa e controle de gastos devem ser combinados com monitoramento de desempenho e ajuste de capacidade.'),
('63000000-0000-4000-8000-000000000001','Qual é a finalidade principal do Application Insights?','Application Insights é a capacidade de APM do Azure Monitor para observar disponibilidade, desempenho e comportamento de aplicações.'),
('63000000-0000-4000-8000-000000000002','Qual conjunto representa telemetria normalmente coletada pelo Application Insights?','Requisições, tempos de resposta, exceções e dependências ajudam a diagnosticar o comportamento de uma aplicação.'),
('63000000-0000-4000-8000-000000000003','Uma equipe precisa observar requisições, falhas e dependências de uma aplicação web. Qual capacidade deve usar?','Application Insights oferece APM e telemetria específica de aplicações. A chave correta existente foi preservada.'),
('63000000-0000-4000-8000-000000000004','Uma loja virtual quer detectar degradação de desempenho antes de receber reclamações. Como usar Application Insights?','Telemetria contínua e alertas por métricas permitem detectar degradações de forma proativa.'),
('63000000-0000-4000-8000-000000000005','Qual ferramenta é mais adequada para acompanhar requisições, falhas e tempo de resposta de uma aplicação web?','Application Insights é especializado em telemetria e desempenho de aplicações.'),
('63000000-0000-4000-8000-000000000006','Uma API está lenta e a equipe quer verificar o tempo gasto em uma dependência de banco de dados. Qual ferramenta é mais adequada?','Application Insights correlaciona requisições e dependências para ajudar a localizar gargalos da aplicação.'),
('63000000-0000-4000-8000-000000000007','A equipe deve ser avisada quando a taxa de exceções ultrapassar um limite. Qual recurso atende ao requisito?','Um alerta baseado em métrica avalia o limite e aciona a notificação configurada.'),
('63000000-0000-4000-8000-000000000008','Como Application Insights se relaciona com Azure Monitor?','Application Insights integra o Azure Monitor e concentra-se na observabilidade de aplicações.'),
('63000000-0000-4000-8000-000000000009','Qual cenário aponta mais diretamente para o uso de Application Insights?','Investigar requisições, falhas e dependências é um caso de APM atendido pelo Application Insights.'),
('63000000-0000-4000-8000-000000000010','Qual afirmação diferencia Application Insights de Azure Service Health?','Application Insights observa a aplicação; Service Health comunica eventos da plataforma relevantes ao cliente. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000021','Qual serviço analisa configurações e uso de recursos Azure para produzir recomendações personalizadas?','Azure Advisor produz recomendações de confiabilidade, segurança, desempenho, custo e excelência operacional.'),
('63000000-0000-4000-8000-000000000022','Quais são categorias de recomendações do Azure Advisor?','As categorias do Advisor são Reliability, Security, Performance, Cost e Operational Excellence.'),
('63000000-0000-4000-8000-000000000023','O Azure Advisor recomendou alterar uma configuração importante. O que a equipe deve fazer antes de implementar a mudança?','Recomendações são orientações; contexto, impacto e requisitos ainda precisam ser avaliados.'),
('63000000-0000-4000-8000-000000000024','Uma VM permanece subutilizada e a empresa busca uma recomendação de otimização. Qual serviço deve consultar?','Azure Advisor pode identificar subutilização e recomendar redimensionamento ou outras oportunidades de economia.'),
('63000000-0000-4000-8000-000000000025','Uma manutenção planejada pode afetar serviços usados pela empresa. Qual ferramenta fornece uma visão personalizada desse evento?','Azure Service Health apresenta incidentes e manutenções relacionados aos serviços e regiões usados pelo cliente. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000026','Uma recomendação do Advisor propõe aumentar a resiliência de uma aplicação. A qual categoria ela pertence principalmente?','Reliability agrupa recomendações de resiliência, disponibilidade e continuidade.'),
('63000000-0000-4000-8000-000000000027','Uma equipe precisa analisar métricas de CPU e logs, não recomendações. Qual serviço deve usar?','Azure Monitor coleta e analisa métricas, logs e outros sinais de telemetria.'),
('63000000-0000-4000-8000-000000000028','Uma organização quer analisar gastos reais, orçamentos e tendências de custo. Qual ferramenta atende diretamente?','Azure Cost Management oferece análise de custos, orçamentos e acompanhamento de gastos.'),
('63000000-0000-4000-8000-000000000029','Uma recomendação do Advisor sugere uma alteração crítica. Qual abordagem é apropriada?','A equipe deve avaliar prioridade, impacto e compatibilidade antes de implementar a recomendação.'),
('63000000-0000-4000-8000-000000000030','Qual associação entre Azure Advisor e Azure Service Health está correta?','Advisor recomenda melhorias no ambiente; Service Health comunica eventos da plataforma relevantes ao cliente.'),
('63000000-0000-4000-8000-000000000031','Qual afirmação define Azure Arc?','Azure Arc estende recursos de gerenciamento e governança do Azure a ambientes externos suportados.'),
('63000000-0000-4000-8000-000000000040','Por que Azure Arc não substitui VPN, ExpressRoute nem Azure Migrate?','Arc trata gerenciamento; VPN e ExpressRoute tratam conectividade; Azure Migrate apoia avaliação e migração.'),
('63000000-0000-4000-8000-000000000041','O que caracteriza o Azure CLI?','Azure CLI é uma ferramenta de linha de comando multiplataforma que usa comandos az para gerenciar o Azure.'),
('63000000-0000-4000-8000-000000000042','Em quais sistemas operacionais o Azure CLI pode ser instalado?','Azure CLI é multiplataforma e oferece suporte a Windows, macOS e Linux.'),
('63000000-0000-4000-8000-000000000043','Qual benefício o Azure CLI oferece em tarefas administrativas repetitivas?','Comandos podem ser reunidos em scripts, tornando execuções repetíveis e consistentes.'),
('63000000-0000-4000-8000-000000000044','Uma pipeline deve criar várias VMs com a mesma configuração. Qual abordagem é mais apropriada?','Um script do Azure CLI automatiza a sequência e reduz variações entre execuções.'),
('63000000-0000-4000-8000-000000000045','Um administrador precisa listar os Resource Groups uma única vez, sem instalar ferramentas. Qual abordagem é adequada?','Um comando Azure CLI no Cloud Shell atende à consulta pontual sem instalação local.'),
('63000000-0000-4000-8000-000000000046','Como o Azure CLI pode reduzir diferenças entre ambientes de desenvolvimento, teste e produção?','Scripts versionados registram e repetem a mesma sequência de configuração em cada ambiente.'),
('63000000-0000-4000-8000-000000000047','Para uma tarefa repetida em muitos recursos, qual vantagem o Azure CLI tem sobre operações manuais no portal?','A execução por script automatiza ações repetitivas e melhora a consistência.'),
('63000000-0000-4000-8000-000000000048','Qual afirmação diferencia Azure CLI de Azure PowerShell?','Azure CLI usa comandos az; Azure PowerShell usa cmdlets do módulo Az. Ambos são multiplataforma. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000049','Qual é o principal benefício de reutilizar um script do Azure CLI em vários ambientes?','O script torna a sequência repetível, favorecendo automação e consistência.'),
('63000000-0000-4000-8000-000000000050','Um administrador precisa executar um comando az pelo navegador, sem instalação local. Qual combinação atende ao requisito?','Azure CLI fornece o comando az e Cloud Shell oferece o ambiente hospedado. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000051','O que é Azure Cloud Shell?','Cloud Shell é um terminal hospedado e acessível pelo navegador, com ferramentas Azure pré-instaladas.'),
('63000000-0000-4000-8000-000000000052','Quais ambientes de shell o Azure Cloud Shell oferece?','Cloud Shell permite escolher Bash ou PowerShell.'),
('63000000-0000-4000-8000-000000000053','Qual vantagem o Cloud Shell oferece em relação à instalação local de ferramentas?','Azure CLI e Azure PowerShell já estão disponíveis no ambiente hospedado.'),
('63000000-0000-4000-8000-000000000054','Um administrador usa um computador gerenciado no qual não pode instalar software. Qual opção permite executar comandos Azure pelo navegador?','Cloud Shell fornece um terminal hospedado sem exigir a instalação local das ferramentas.'),
('63000000-0000-4000-8000-000000000055','Uma equipe usa comandos Bash e PowerShell. Qual capacidade do Cloud Shell é relevante?','O usuário pode alternar entre os ambientes Bash e PowerShell no Cloud Shell.'),
('63000000-0000-4000-8000-000000000056','Novos integrantes precisam executar comandos Azure antes da configuração de seus computadores. Qual solução atende ao requisito?','Cloud Shell disponibiliza pelo navegador as ferramentas já configuradas para a identidade autorizada.'),
('63000000-0000-4000-8000-000000000057','Por que Cloud Shell pode ser mais portátil que uma instalação local do Azure CLI?','O ambiente hospedado pode ser acessado por navegador em dispositivos compatíveis, sem depender de uma instalação específica.'),
('63000000-0000-4000-8000-000000000058','Ao executar az group list no Cloud Shell, o que é o Cloud Shell?','Cloud Shell é o terminal hospedado; az group list é um comando do Azure CLI. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000059','Azure CLI e Azure PowerShell podem ser usados fora do Cloud Shell?','As duas ferramentas também podem ser instaladas ou executadas em ambientes locais e hospedados compatíveis. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000060','Como a autenticação integrada do Cloud Shell afeta as permissões?','Ela facilita o uso da identidade autenticada, mas cada operação continua sujeita às permissões concedidas. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000061','Qual característica pode alterar diretamente o custo de um recurso Azure?','Tipo, quantidade, região, configuração e consumo podem influenciar o custo do recurso.'),
('63000000-0000-4000-8000-000000000066','Uma arquitetura transfere muitos dados entre Azure Regions. O que deve ser considerado na estimativa?','Origem, destino e volume influenciam a cobrança de transferência de dados entre regiões.'),
('63000000-0000-4000-8000-000000000081','O que é um Azure Datacenter?','É uma instalação física com servidores, armazenamento, rede, energia e refrigeração.'),
('63000000-0000-4000-8000-000000000082','Quais elementos pertencem à infraestrutura física de um Azure Datacenter?','Servidores, armazenamento e rede dependem de energia e refrigeração administradas pelo provedor.'),
('63000000-0000-4000-8000-000000000083','Ao criar um recurso Azure, qual localização o cliente normalmente escolhe?','O cliente escolhe uma Azure Region compatível; a plataforma abstrai o prédio e o equipamento.'),
('63000000-0000-4000-8000-000000000084','Como Azure Region e Datacenter se relacionam?','Uma Azure Region contém uma ou mais instalações de datacenter conectadas.'),
('63000000-0000-4000-8000-000000000085','Quem administra a infraestrutura física dos Azure Datacenters?','A Microsoft administra servidores, rede, energia e refrigeração dos datacenters.'),
('63000000-0000-4000-8000-000000000086','Como os datacenters de uma Azure Region são interligados?','Eles usam redes de alta capacidade e baixa latência para sustentar os serviços da região.'),
('63000000-0000-4000-8000-000000000087','Qual afirmação diferencia Datacenter de Azure Region?','Datacenter é uma instalação física; Region é uma localização composta por uma ou mais dessas instalações.'),
('63000000-0000-4000-8000-000000000088','Por que o cliente normalmente escolhe uma Azure Region, e não um prédio específico?','O Azure abstrai a infraestrutura física e apresenta a Region como local de implantação.'),
('63000000-0000-4000-8000-000000000089','Uma equipe quer minimizar latência e atender residência de dados. O que deve avaliar ao escolher onde implantar?','A Azure Region deve ser escolhida considerando proximidade, disponibilidade do serviço e requisitos regulatórios.'),
('63000000-0000-4000-8000-000000000090','Qual sequência representa a hierarquia física de localização no Azure?','Uma Geography contém Regions, e uma Region contém uma ou mais instalações de datacenter.'),
('63000000-0000-4000-8000-000000000098','Qual afirmação diferencia um nome DNS de um endereço IP?','O nome é legível e a resolução DNS retorna o endereço ou outro dado de registro associado.'),
('63000000-0000-4000-8000-000000000101','Qual cenário é atendido diretamente pelo Azure Files?','Azure Files oferece compartilhamentos de arquivos gerenciados por protocolos como SMB e NFS.'),
('63000000-0000-4000-8000-000000000102','Qual comparação entre Azure Files e Blob Storage está correta?','Azure Files oferece compartilhamentos montáveis; Blob Storage armazena objetos. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000103','Qual comparação entre Azure Files e Azure Managed Disks está correta?','Azure Files atende compartilhamento entre máquinas; Managed Disks fornece armazenamento em bloco para VMs. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000104','Várias VMs precisam acessar os mesmos documentos por um compartilhamento montável. Qual serviço é apropriado?','Azure Files fornece um file share gerenciado acessível por várias máquinas autorizadas.'),
('63000000-0000-4000-8000-000000000105','Qual protocolo é comumente usado para montar compartilhamentos do Azure Files?','SMB é um protocolo comum do Azure Files; NFS também está disponível em cenários suportados. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000106','Uma aplicação requer uma estrutura de diretórios compartilhada e montável por várias máquinas. Qual serviço atende melhor?','Azure Files fornece compartilhamentos gerenciados e montáveis. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000107','Uma empresa quer substituir um servidor de arquivos por um serviço Azure gerenciado. Qual serviço deve avaliar?','Azure Files é destinado a compartilhamentos de arquivos gerenciados, sujeito à validação de compatibilidade.'),
('63000000-0000-4000-8000-000000000108','Uma aplicação deve armazenar milhões de fotos como objetos, sem montar um compartilhamento. Qual serviço é apropriado?','Blob Storage é adequado para objetos e dados não estruturados. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000109','Três servidores precisam acessar e atualizar o mesmo conjunto de arquivos por uma estrutura compartilhada. Qual serviço atende diretamente?','Azure Files oferece um compartilhamento gerenciado acessível pelos servidores autorizados. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000110','O requisito é montar uma estrutura de arquivos para várias máquinas. Qual serviço deve ser escolhido?','Azure Files corresponde a file share; Blob Storage a objetos; Managed Disks a armazenamento em bloco para VMs. A chave existente foi preservada.'),
('63000000-0000-4000-8000-000000000119','Uma carga executa continuamente, tem demanda estável e exige controle do ambiente. Qual análise é mais adequada?','O modelo serverless não deve ser escolhido automaticamente; uso contínuo, controle, custo e operação devem ser comparados com containers e VMs.');

update public.questions question
set question_text = seed.question_text,
    explanation = seed.explanation
from az900_remediation_question_seed seed
where question.id = seed.id;

create temporary table az900_remediation_option_seed (
  id uuid primary key,
  option_text text not null
) on commit drop;

insert into az900_remediation_option_seed (id, option_text) values
-- 620...115-120
('73000000-0000-4000-8000-000000000457','Aumentar a capacidade sem medir a carga atual.'),
('73000000-0000-4000-8000-000000000458','Repetir testes de carga e analisar métricas históricas.'),
('73000000-0000-4000-8000-000000000459','Agendar reinicializações nos horários de maior uso.'),
('73000000-0000-4000-8000-000000000460','Trocar o modelo de cobrança da assinatura.'),
('73000000-0000-4000-8000-000000000461','Projetar o ano a partir do consumo de um único dia.'),
('73000000-0000-4000-8000-000000000462','Usar apenas o limite atual do orçamento como previsão.'),
('73000000-0000-4000-8000-000000000463','Somar preços de tabela sem estimar quantidades.'),
('73000000-0000-4000-8000-000000000464','Combinar calculadora de preços, histórico e mudanças planejadas.'),
('73000000-0000-4000-8000-000000000465','Previsibilidade de desempenho.'),
('73000000-0000-4000-8000-000000000466','Previsibilidade de custos.'),
('73000000-0000-4000-8000-000000000467','Responsabilidade compartilhada.'),
('73000000-0000-4000-8000-000000000468','Economia de escala.'),
('73000000-0000-4000-8000-000000000469','As duas medem apenas variações no consumo.'),
('73000000-0000-4000-8000-000000000470','Desempenho estima gastos; custos medem latência.'),
('73000000-0000-4000-8000-000000000471','Desempenho trata do comportamento técnico; custos tratam dos gastos.'),
('73000000-0000-4000-8000-000000000472','As duas dependem exclusivamente do modelo de suporte.'),
('73000000-0000-4000-8000-000000000473','Usar Azure Advisor para redimensionar os recursos antes da manutenção.'),
('73000000-0000-4000-8000-000000000474','Consultar Azure Service Health e revisar a estratégia de resiliência da aplicação.'),
('73000000-0000-4000-8000-000000000475','Usar Cost Management para elevar o orçamento durante a manutenção.'),
('73000000-0000-4000-8000-000000000476','Usar Resource Health para alterar a oferta de suporte da assinatura.'),
('73000000-0000-4000-8000-000000000477','Fixar a capacidade e acompanhar somente o orçamento.'),
('73000000-0000-4000-8000-000000000478','Usar autoscaling e dispensar estimativas de custo.'),
('73000000-0000-4000-8000-000000000479','Reservar capacidade e dispensar métricas de desempenho.'),
('73000000-0000-4000-8000-000000000480','Estimar gastos e monitorar desempenho para ajustar capacidade.'),
-- Application Insights 001-010
('74000000-0000-4000-8000-000000000001','Monitorar disponibilidade e desempenho de aplicações.'),
('74000000-0000-4000-8000-000000000002','Acompanhar integridade de recursos Azure individuais.'),
('74000000-0000-4000-8000-000000000003','Comunicar manutenções planejadas da plataforma.'),
('74000000-0000-4000-8000-000000000004','Recomendar otimizações de custo e segurança.'),
('74000000-0000-4000-8000-000000000005','Uso e custo agregados por assinatura.'),
('74000000-0000-4000-8000-000000000006','Requisições, tempos de resposta, exceções e dependências.'),
('74000000-0000-4000-8000-000000000007','Incidentes globais e manutenções planejadas.'),
('74000000-0000-4000-8000-000000000008','Inventário e conformidade de recursos.'),
('74000000-0000-4000-8000-000000000009','Azure Advisor para recomendações gerais.'),
('74000000-0000-4000-8000-000000000010','Azure Service Health para eventos da plataforma.'),
('74000000-0000-4000-8000-000000000011','Application Insights para telemetria de aplicações.'),
('74000000-0000-4000-8000-000000000012','Resource Health para integridade de um recurso.'),
('74000000-0000-4000-8000-000000000013','Consultar apenas os logs quando houver reclamação.'),
('74000000-0000-4000-8000-000000000014','Criar uma recomendação periódica no Azure Advisor.'),
('74000000-0000-4000-8000-000000000015','Acompanhar somente eventos no Azure Service Health.'),
('74000000-0000-4000-8000-000000000016','Coletar telemetria contínua e configurar alertas por métricas.'),
('74000000-0000-4000-8000-000000000017','Application Insights.'),
('74000000-0000-4000-8000-000000000018','Azure Advisor.'),
('74000000-0000-4000-8000-000000000019','Azure Service Health.'),
('74000000-0000-4000-8000-000000000020','Azure Resource Health.'),
('74000000-0000-4000-8000-000000000021','Log Analytics sem instrumentação da aplicação.'),
('74000000-0000-4000-8000-000000000022','Application Insights.'),
('74000000-0000-4000-8000-000000000023','Azure Service Health.'),
('74000000-0000-4000-8000-000000000024','Azure Cost Management.'),
('74000000-0000-4000-8000-000000000025','Uma consulta manual periódica aos logs.'),
('74000000-0000-4000-8000-000000000026','Uma recomendação de desempenho do Advisor.'),
('74000000-0000-4000-8000-000000000027','Um alerta baseado na métrica de exceções.'),
('74000000-0000-4000-8000-000000000028','Um aviso de manutenção do Service Health.'),
('74000000-0000-4000-8000-000000000029','É um produto separado para monitorar apenas redes.'),
('74000000-0000-4000-8000-000000000030','Azure Monitor é um componente restrito ao Application Insights.'),
('74000000-0000-4000-8000-000000000031','Os dois têm exatamente o mesmo escopo.'),
('74000000-0000-4000-8000-000000000032','É uma capacidade do Azure Monitor voltada a aplicações.'),
('74000000-0000-4000-8000-000000000033','Investigar falhas e dependências de uma aplicação web.'),
('74000000-0000-4000-8000-000000000034','Consultar a disponibilidade pública de todas as regiões.'),
('74000000-0000-4000-8000-000000000035','Avaliar recomendações de custo de uma VM.'),
('74000000-0000-4000-8000-000000000036','Impedir a exclusão de um recurso crítico.'),
('74000000-0000-4000-8000-000000000037','Service Health mede dependências; Insights informa manutenção.'),
('74000000-0000-4000-8000-000000000038','Insights monitora aplicações; Service Health comunica eventos da plataforma.'),
('74000000-0000-4000-8000-000000000039','Insights recomenda custos; Service Health coleta exceções.'),
('74000000-0000-4000-8000-000000000040','Os dois monitoram somente a integridade de VMs.'),
-- Advisor 021-031
('74000000-0000-4000-8000-000000000081','Azure Advisor.'),
('74000000-0000-4000-8000-000000000082','Azure Monitor.'),
('74000000-0000-4000-8000-000000000083','Azure Service Health.'),
('74000000-0000-4000-8000-000000000084','Azure Cost Management.'),
('74000000-0000-4000-8000-000000000085','Compute, Storage, Networking, Identity e Databases.'),
('74000000-0000-4000-8000-000000000086','Reliability, Security, Performance, Cost e Operational Excellence.'),
('74000000-0000-4000-8000-000000000087','Issues, Maintenance, Advisories, Metrics e Logs.'),
('74000000-0000-4000-8000-000000000088','Availability, Integrity, Usage, Billing e Support.'),
('74000000-0000-4000-8000-000000000089','Implementar a recomendação sem avaliar dependências.'),
('74000000-0000-4000-8000-000000000090','Tratá-la como aviso de indisponibilidade da plataforma.'),
('74000000-0000-4000-8000-000000000091','Avaliar contexto, impacto e requisitos antes de implementar.'),
('74000000-0000-4000-8000-000000000092','Adiar a análise até que a recomendação seja obrigatória.'),
('74000000-0000-4000-8000-000000000093','Azure Monitor.'),
('74000000-0000-4000-8000-000000000094','Azure Service Health.'),
('74000000-0000-4000-8000-000000000095','Azure Cost Management.'),
('74000000-0000-4000-8000-000000000096','Azure Advisor.'),
('74000000-0000-4000-8000-000000000097','Azure Service Health.'),
('74000000-0000-4000-8000-000000000098','Azure Advisor.'),
('74000000-0000-4000-8000-000000000099','Azure Status.'),
('74000000-0000-4000-8000-000000000100','Azure Resource Health.'),
('74000000-0000-4000-8000-000000000101','Cost.'),
('74000000-0000-4000-8000-000000000102','Reliability.'),
('74000000-0000-4000-8000-000000000103','Performance.'),
('74000000-0000-4000-8000-000000000104','Operational Excellence.'),
('74000000-0000-4000-8000-000000000105','Azure Advisor.'),
('74000000-0000-4000-8000-000000000106','Azure Service Health.'),
('74000000-0000-4000-8000-000000000107','Azure Monitor.'),
('74000000-0000-4000-8000-000000000108','Azure Cost Management.'),
('74000000-0000-4000-8000-000000000109','Azure Advisor.'),
('74000000-0000-4000-8000-000000000110','Azure Service Health.'),
('74000000-0000-4000-8000-000000000111','Azure Monitor.'),
('74000000-0000-4000-8000-000000000112','Azure Cost Management.'),
('74000000-0000-4000-8000-000000000113','Avaliar prioridade, impacto e compatibilidade.'),
('74000000-0000-4000-8000-000000000114','Aplicar automaticamente toda recomendação de alta prioridade.'),
('74000000-0000-4000-8000-000000000115','Aguardar que o Advisor altere a configuração.'),
('74000000-0000-4000-8000-000000000116','Tratar a recomendação como um incidente ativo.'),
('74000000-0000-4000-8000-000000000117','Advisor informa incidentes; Service Health otimiza recursos.'),
('74000000-0000-4000-8000-000000000118','Advisor recomenda melhorias; Service Health informa eventos.'),
('74000000-0000-4000-8000-000000000119','Advisor coleta métricas; Service Health cria orçamentos.'),
('74000000-0000-4000-8000-000000000120','Advisor aplica políticas; Service Health gerencia permissões.'),
('74000000-0000-4000-8000-000000000121','Move automaticamente todo recurso externo para o Azure.'),
('74000000-0000-4000-8000-000000000122','Estende gerenciamento Azure a ambientes externos suportados.'),
('74000000-0000-4000-8000-000000000123','Fornece conectividade privada entre redes híbridas.'),
('74000000-0000-4000-8000-000000000124','Avalia e executa migrações para o Azure.'),
-- Arc 040 e CLI/Cloud Shell 041-060
('74000000-0000-4000-8000-000000000157','Arc gerencia; conectividade e migração usam serviços distintos.'),
('74000000-0000-4000-8000-000000000158','Arc substitui esses serviços em qualquer ambiente híbrido.'),
('74000000-0000-4000-8000-000000000159','Arc substitui apenas a conectividade de servidores Windows.'),
('74000000-0000-4000-8000-000000000160','Arc executa migração, enquanto Azure Migrate gerencia recursos.'),
('74000000-0000-4000-8000-000000000161','Uma ferramenta multiplataforma que usa comandos az.'),
('74000000-0000-4000-8000-000000000162','Um conjunto de cmdlets do módulo Az.'),
('74000000-0000-4000-8000-000000000163','Um terminal hospedado acessível pelo navegador.'),
('74000000-0000-4000-8000-000000000164','Uma interface visual para administrar recursos.'),
('74000000-0000-4000-8000-000000000165','Apenas Windows.'),
('74000000-0000-4000-8000-000000000166','Windows, macOS e Linux.'),
('74000000-0000-4000-8000-000000000167','Apenas Linux e Cloud Shell.'),
('74000000-0000-4000-8000-000000000168','Apenas máquinas virtuais executadas no Azure.'),
('74000000-0000-4000-8000-000000000169','Fornecer uma interface visual para cada comando.'),
('74000000-0000-4000-8000-000000000170','Substituir controles de acesso por credenciais no script.'),
('74000000-0000-4000-8000-000000000171','Automatizar sequências repetitivas por meio de scripts.'),
('74000000-0000-4000-8000-000000000172','Aplicar automaticamente recomendações do Azure Advisor.'),
('74000000-0000-4000-8000-000000000173','Criar as VMs individualmente pelo portal.'),
('74000000-0000-4000-8000-000000000174','Duplicar uma VM manualmente após cada implantação.'),
('74000000-0000-4000-8000-000000000175','Usar Service Health para repetir a configuração.'),
('74000000-0000-4000-8000-000000000176','Executar um script Azure CLI versionado na pipeline.'),
('74000000-0000-4000-8000-000000000177','Executar Azure CLI no Cloud Shell.'),
('74000000-0000-4000-8000-000000000178','Criar uma pipeline permanente para a consulta.'),
('74000000-0000-4000-8000-000000000179','Exportar a lista pelo Azure Cost Management.'),
('74000000-0000-4000-8000-000000000180','Instalar localmente todas as ferramentas Azure.'),
('74000000-0000-4000-8000-000000000181','Documentar passos manuais diferentes para cada ambiente.'),
('74000000-0000-4000-8000-000000000182','Versionar e executar o mesmo script em cada ambiente.'),
('74000000-0000-4000-8000-000000000183','Clonar os recursos existentes sem registrar a configuração.'),
('74000000-0000-4000-8000-000000000184','Delegar cada ambiente a uma equipe diferente.'),
('74000000-0000-4000-8000-000000000185','O portal registra automaticamente um script reutilizável.'),
('74000000-0000-4000-8000-000000000186','O CLI dispensa autenticação em execuções repetidas.'),
('74000000-0000-4000-8000-000000000187','O CLI permite automatizar as ações com scripts.'),
('74000000-0000-4000-8000-000000000188','O CLI limita-se a consultar recursos.'),
('74000000-0000-4000-8000-000000000189','CLI usa cmdlets Az; PowerShell usa comandos az.'),
('74000000-0000-4000-8000-000000000190','CLI é hospedado; PowerShell só pode ser instalado localmente.'),
('74000000-0000-4000-8000-000000000191','CLI é visual; PowerShell funciona apenas como serviço web.'),
('74000000-0000-4000-8000-000000000192','CLI usa comandos az; PowerShell usa cmdlets do módulo Az.'),
('74000000-0000-4000-8000-000000000193','Repetir a sequência com consistência e automação.'),
('74000000-0000-4000-8000-000000000194','Eliminar a necessidade de autenticação.'),
('74000000-0000-4000-8000-000000000195','Converter comandos automaticamente em operações do portal.'),
('74000000-0000-4000-8000-000000000196','Garantir que os recursos não gerem custos.'),
('74000000-0000-4000-8000-000000000197','Azure PowerShell instalado em uma VM.'),
('74000000-0000-4000-8000-000000000198','Azure CLI executado no Azure Cloud Shell.'),
('74000000-0000-4000-8000-000000000199','Azure portal executado no Azure Arc.'),
('74000000-0000-4000-8000-000000000200','Azure Policy executado no Resource Health.'),
('74000000-0000-4000-8000-000000000201','Uma instalação local do Azure CLI.'),
('74000000-0000-4000-8000-000000000202','Um painel de métricas do Azure Monitor.'),
('74000000-0000-4000-8000-000000000203','Um terminal hospedado acessível pelo navegador.'),
('74000000-0000-4000-8000-000000000204','Um módulo do Azure PowerShell para armazenamento.'),
('74000000-0000-4000-8000-000000000205','Azure CLI e Prompt de Comando.'),
('74000000-0000-4000-8000-000000000206','Azure portal e Visual Studio.'),
('74000000-0000-4000-8000-000000000207','PowerShell e Remote Desktop.'),
('74000000-0000-4000-8000-000000000208','Bash e PowerShell.'),
('74000000-0000-4000-8000-000000000209','As ferramentas Azure já estão disponíveis no ambiente.'),
('74000000-0000-4000-8000-000000000210','As ferramentas precisam ser instaladas a cada sessão.'),
('74000000-0000-4000-8000-000000000211','O ambiente funciona sem conexão com o Azure.'),
('74000000-0000-4000-8000-000000000212','O ambiente substitui as permissões da identidade.'),
('74000000-0000-4000-8000-000000000213','Instalar Azure CLI no computador gerenciado.'),
('74000000-0000-4000-8000-000000000214','Acessar Azure Cloud Shell pelo navegador.'),
('74000000-0000-4000-8000-000000000215','Usar Remote Desktop para entrar em uma VM.'),
('74000000-0000-4000-8000-000000000216','Executar comandos pelo painel do Azure Monitor.'),
('74000000-0000-4000-8000-000000000217','Manter uma VM separada para cada tipo de shell.'),
('74000000-0000-4000-8000-000000000218','Instalar os dois shells no dispositivo antes da sessão.'),
('74000000-0000-4000-8000-000000000219','Alternar entre Bash e PowerShell no Cloud Shell.'),
('74000000-0000-4000-8000-000000000220','Converter automaticamente comandos Bash em cmdlets.'),
('74000000-0000-4000-8000-000000000221','Aguardar a instalação local de todas as ferramentas.'),
('74000000-0000-4000-8000-000000000222','Conceder acesso de Owner para dispensar configuração.'),
('74000000-0000-4000-8000-000000000223','Compartilhar uma instalação local entre os integrantes.'),
('74000000-0000-4000-8000-000000000224','Usar Cloud Shell pelo navegador com acesso autorizado.'),
('74000000-0000-4000-8000-000000000225','Pode ser acessado por navegador sem instalação específica.'),
('74000000-0000-4000-8000-000000000226','Mantém todos os arquivos apenas no dispositivo local.'),
('74000000-0000-4000-8000-000000000227','Funciona somente no computador em que foi criado.'),
('74000000-0000-4000-8000-000000000228','Exige uma VM exclusiva para cada usuário.'),
('74000000-0000-4000-8000-000000000229','A ferramenta que fornece o comando az.'),
('74000000-0000-4000-8000-000000000230','O ambiente de terminal hospedado no navegador.'),
('74000000-0000-4000-8000-000000000231','O Resource Group retornado pelo comando.'),
('74000000-0000-4000-8000-000000000232','O módulo PowerShell que interpreta comandos az.'),
('74000000-0000-4000-8000-000000000233','Não; as duas ferramentas dependem do portal.'),
('74000000-0000-4000-8000-000000000234','Somente Azure CLI pode ser instalada localmente.'),
('74000000-0000-4000-8000-000000000235','Sim; ambas funcionam em ambientes compatíveis fora dele.'),
('74000000-0000-4000-8000-000000000236','Somente Azure PowerShell funciona fora dele.'),
('74000000-0000-4000-8000-000000000237','Substitui as funções RBAC atribuídas ao usuário.'),
('74000000-0000-4000-8000-000000000238','Concede automaticamente a função Owner.'),
('74000000-0000-4000-8000-000000000239','Permite comandos sem autenticação.'),
('74000000-0000-4000-8000-000000000240','Usa a identidade autenticada e respeita suas permissões.'),
-- Cost factors 061,066
('74000000-0000-4000-8000-000000000241','Tipo, quantidade e configuração do recurso.'),
('74000000-0000-4000-8000-000000000242','Nome atribuído ao recurso.'),
('74000000-0000-4000-8000-000000000243','Nome do Resource Group.'),
('74000000-0000-4000-8000-000000000244','Conta usada para acessar o portal.'),
('74000000-0000-4000-8000-000000000261','Somente o número de administradores da assinatura.'),
('74000000-0000-4000-8000-000000000262','Origem, destino e volume transferido.'),
('74000000-0000-4000-8000-000000000263','Apenas o tamanho das VMs de origem.'),
('74000000-0000-4000-8000-000000000264','Somente o tipo do Resource Group.'),
-- Datacenters 081-090
('74000000-0000-4000-8000-000000000321','Uma instalação física que abriga infraestrutura computacional.'),
('74000000-0000-4000-8000-000000000322','Uma localização formada por uma ou mais instalações.'),
('74000000-0000-4000-8000-000000000323','Um contêiner lógico para organizar recursos.'),
('74000000-0000-4000-8000-000000000324','Uma unidade administrativa para políticas e acesso.'),
('74000000-0000-4000-8000-000000000325','Identidades, funções RBAC e licenças.'),
('74000000-0000-4000-8000-000000000326','Servidores, rede, energia e refrigeração.'),
('74000000-0000-4000-8000-000000000327','Aplicações SaaS e contas dos usuários.'),
('74000000-0000-4000-8000-000000000328','Orçamentos, tags e relatórios de cobrança.'),
('74000000-0000-4000-8000-000000000329','O datacenter e o rack específicos.'),
('74000000-0000-4000-8000-000000000330','A Geography sem escolher uma Region.'),
('74000000-0000-4000-8000-000000000331','Uma Azure Region compatível com o recurso.'),
('74000000-0000-4000-8000-000000000332','O fornecedor de energia do datacenter.'),
('74000000-0000-4000-8000-000000000333','Uma Region corresponde sempre a um único prédio.'),
('74000000-0000-4000-8000-000000000334','Um datacenter contém várias Geographies.'),
('74000000-0000-4000-8000-000000000335','Uma Region é criada pelo cliente em seu datacenter.'),
('74000000-0000-4000-8000-000000000336','Uma Region contém uma ou mais instalações conectadas.'),
('74000000-0000-4000-8000-000000000337','A Microsoft.'),
('74000000-0000-4000-8000-000000000338','O cliente que criou a assinatura.'),
('74000000-0000-4000-8000-000000000339','O parceiro que desenvolveu a aplicação.'),
('74000000-0000-4000-8000-000000000340','Os usuários finais do serviço.'),
('74000000-0000-4000-8000-000000000341','Pela rede local do cliente.'),
('74000000-0000-4000-8000-000000000342','Por rede de alta capacidade e baixa latência.'),
('74000000-0000-4000-8000-000000000343','Somente por conexões VPN do cliente.'),
('74000000-0000-4000-8000-000000000344','Por vínculos entre Resource Groups.'),
('74000000-0000-4000-8000-000000000345','Datacenter é uma Geography; Region é um servidor.'),
('74000000-0000-4000-8000-000000000346','Datacenter e Region são termos equivalentes.'),
('74000000-0000-4000-8000-000000000347','Datacenter é físico; Region reúne uma ou mais instalações.'),
('74000000-0000-4000-8000-000000000348','Region existe apenas em instalações do cliente.'),
('74000000-0000-4000-8000-000000000349','O cliente escolhe apenas a Geography.'),
('74000000-0000-4000-8000-000000000350','O Resource Group determina automaticamente o prédio.'),
('74000000-0000-4000-8000-000000000351','Cada serviço é executado fora de infraestrutura física.'),
('74000000-0000-4000-8000-000000000352','O Azure abstrai o prédio e apresenta a Region.'),
('74000000-0000-4000-8000-000000000353','Escolher uma Region conforme proximidade, serviços e regulação.'),
('74000000-0000-4000-8000-000000000354','Escolher diretamente o rack mais próximo.'),
('74000000-0000-4000-8000-000000000355','Escolher qualquer Region e compensar com uma VM maior.'),
('74000000-0000-4000-8000-000000000356','Escolher apenas a Region com menor preço.'),
('74000000-0000-4000-8000-000000000357','Datacenter → Geography → Region.'),
('74000000-0000-4000-8000-000000000358','Geography → Region → Datacenter.'),
('74000000-0000-4000-8000-000000000359','Region → Datacenter → Geography.'),
('74000000-0000-4000-8000-000000000360','Geography → Datacenter → Subscription.'),
-- DNS 098; Files 101-110; Functions 119
('74000000-0000-4000-8000-000000000389','O nome é legível; DNS o resolve para dados de registro.'),
('74000000-0000-4000-8000-000000000390','Nome DNS e endereço IP são o mesmo identificador.'),
('74000000-0000-4000-8000-000000000391','Um endereço IP contém uma zona DNS privada.'),
('74000000-0000-4000-8000-000000000392','DNS transforma um endereço IP em uma VNet.'),
('74000000-0000-4000-8000-000000000401','Compartilhar arquivos por SMB ou NFS entre máquinas.'),
('74000000-0000-4000-8000-000000000402','Armazenar objetos acessados por APIs HTTP.'),
('74000000-0000-4000-8000-000000000403','Fornecer disco em bloco para uma VM.'),
('74000000-0000-4000-8000-000000000404','Arquivar backups com retenção de longo prazo.'),
('74000000-0000-4000-8000-000000000405','Files e Blob oferecem apenas armazenamento em bloco.'),
('74000000-0000-4000-8000-000000000406','Files oferece file shares; Blob armazena objetos.'),
('74000000-0000-4000-8000-000000000407','Files armazena objetos; Blob fornece compartilhamentos SMB.'),
('74000000-0000-4000-8000-000000000408','Files e Blob exigem um disco anexado a uma VM.'),
('74000000-0000-4000-8000-000000000409','Files fornece disco de inicialização exclusivo para uma VM.'),
('74000000-0000-4000-8000-000000000410','Managed Disks fornece compartilhamentos SMB gerenciados.'),
('74000000-0000-4000-8000-000000000411','Files compartilha arquivos; Managed Disks fornece blocos para VMs.'),
('74000000-0000-4000-8000-000000000412','Os dois são serviços de object storage para dados não estruturados.'),
('74000000-0000-4000-8000-000000000413','Azure Managed Disks.'),
('74000000-0000-4000-8000-000000000414','Azure Blob Storage.'),
('74000000-0000-4000-8000-000000000415','Azure NetApp Files.'),
('74000000-0000-4000-8000-000000000416','Azure Files.'),
('74000000-0000-4000-8000-000000000417','SMB.'),
('74000000-0000-4000-8000-000000000418','HTTPS, exclusivamente.'),
('74000000-0000-4000-8000-000000000419','RDP.'),
('74000000-0000-4000-8000-000000000420','iSCSI.'),
('74000000-0000-4000-8000-000000000421','Azure Blob Storage.'),
('74000000-0000-4000-8000-000000000422','Azure Files.'),
('74000000-0000-4000-8000-000000000423','Azure Managed Disks.'),
('74000000-0000-4000-8000-000000000424','Azure Archive Storage.'),
('74000000-0000-4000-8000-000000000425','Azure Managed Disks.'),
('74000000-0000-4000-8000-000000000426','Azure Blob Storage.'),
('74000000-0000-4000-8000-000000000427','Azure Files.'),
('74000000-0000-4000-8000-000000000428','Azure Backup.'),
('74000000-0000-4000-8000-000000000429','Azure Files.'),
('74000000-0000-4000-8000-000000000430','Azure Managed Disks.'),
('74000000-0000-4000-8000-000000000431','Azure Backup.'),
('74000000-0000-4000-8000-000000000432','Azure Blob Storage.'),
('74000000-0000-4000-8000-000000000433','Azure Files.'),
('74000000-0000-4000-8000-000000000434','Azure Blob Storage.'),
('74000000-0000-4000-8000-000000000435','Um Managed Disk separado para cada servidor.'),
('74000000-0000-4000-8000-000000000436','Cópias locais sincronizadas manualmente.'),
('74000000-0000-4000-8000-000000000437','Azure Blob Storage.'),
('74000000-0000-4000-8000-000000000438','Azure Files.'),
('74000000-0000-4000-8000-000000000439','Azure Managed Disks.'),
('74000000-0000-4000-8000-000000000440','Azure Archive Storage.'),
('74000000-0000-4000-8000-000000000473','Escolher Functions apenas por usar cobrança por execução.'),
('74000000-0000-4000-8000-000000000474','Dividir a carga em funções sem avaliar o controle necessário.'),
('74000000-0000-4000-8000-000000000475','Comparar Functions, containers e VMs por uso, controle e custo.'),
('74000000-0000-4000-8000-000000000476','Escolher uma VM apenas por a demanda ser estável.');

update public.question_options option
set option_text = seed.option_text,
    explanation = case
      when option.is_correct then 'Correta. ' || question_seed.explanation
      else 'Incorreta. ' || question_seed.explanation
    end
from az900_remediation_option_seed seed,
     az900_remediation_question_seed question_seed
where option.id = seed.id
  and question_seed.id = option.question_id;



-- Remediation seed for audited AZ-900 questions 256-383.
-- Intentionally contains no transaction wrapper, guards, or remote execution.

create temporary table az900_quality_question_seed_256_383 (
  id uuid primary key,
  question_text text not null,
  explanation text not null
) on commit drop;

insert into az900_quality_question_seed_256_383 (id, question_text, explanation) values
('64000000-0000-4000-8000-000000000004','Como muda a responsabilidade pelo software da aplicação entre SaaS, PaaS e IaaS?','Em SaaS, o provedor mantém a aplicação; em PaaS, o cliente mantém seu código; em IaaS, o cliente também administra o sistema operacional e o runtime.'),
('64000000-0000-4000-8000-000000000005','Uma pequena equipe de TI precisa de um sistema financeiro padrão e não prevê customizações profundas. Qual modelo reduz mais sua carga operacional?','SaaS fornece a aplicação pronta e transfere ao provedor a manutenção da aplicação e das camadas subjacentes.'),
('64000000-0000-4000-8000-000000000006','Qual critério deve orientar a escolha entre IaaS, PaaS e SaaS?','A escolha equilibra o controle necessário sobre a pilha e a responsabilidade operacional que a equipe pode assumir.'),
('64000000-0000-4000-8000-000000000007','Qual modelo de serviço normalmente deixa mais componentes sob gerenciamento do cliente?','IaaS deixa sistema operacional, runtime, aplicação e dados sob responsabilidade do cliente, enquanto o provedor gerencia a infraestrutura física.'),
('64000000-0000-4000-8000-000000000008','Uma aplicação legada requer uma versão específica do sistema operacional e configurações não suportadas por plataformas gerenciadas. Qual modelo é mais adequado?','IaaS oferece controle sobre o sistema operacional e a configuração da máquina virtual.'),
('64000000-0000-4000-8000-000000000009','Uma equipe desenvolverá uma aplicação web, mas não quer administrar sistema operacional nem runtime. Qual modelo atende ao requisito?','PaaS gerencia infraestrutura, sistema operacional e runtime, permitindo que a equipe se concentre no código da aplicação.'),
('64000000-0000-4000-8000-000000000010','Uma empresa adotará folha de pagamento pronta, desenvolverá uma aplicação própria e manterá um legado que exige controle do sistema operacional. Qual combinação é adequada?','SaaS atende o software pronto, PaaS a aplicação própria sem gestão da plataforma e IaaS o legado que exige controle do sistema operacional.'),
('64000000-0000-4000-8000-000000000011','Qual definição descreve uma Azure Region do Azure?','Uma região é uma área geográfica que contém um ou mais datacenters conectados por uma rede de baixa latência.'),
('64000000-0000-4000-8000-000000000012','Quais fatores da aplicação podem ser afetados pela escolha de uma região do Azure?','Latência, disponibilidade regional de serviços, preço e requisitos de residência de dados podem variar conforme a região.'),
('64000000-0000-4000-8000-000000000013','Jogadores sul-americanos enfrentam latência causada pela distância até a região atual. Qual mudança trata mais diretamente essa causa?','Hospedar a aplicação em uma região mais próxima reduz a distância de rede; aumentar compute não corrige, por si só, latência geográfica.'),
('64000000-0000-4000-8000-000000000014','Uma aplicação depende de um banco gerenciado indisponível em uma das regiões candidatas. Como isso deve influenciar a decisão?','A equipe deve confirmar a disponibilidade regional dos serviços necessários e escolher uma região que atenda às dependências.'),
('64000000-0000-4000-8000-000000000015','Uma aplicação europeia tem requisitos de latência, serviço regional e residência de dados. Como escolher a região?','A decisão deve avaliar conjuntamente proximidade dos usuários, disponibilidade dos serviços e obrigações de residência de dados.'),
('64000000-0000-4000-8000-000000000018','Uma workload será implantada em uma região sem par regional. Qual afirmação permanece válida?','Uma região sem par ainda pode participar de uma arquitetura resiliente usando zonas de disponibilidade e soluções multirregionais compatíveis.'),
('64000000-0000-4000-8000-000000000019','Uma empresa precisa manter dados em uma geografia específica, sem requisito de nuvem soberana. Qual opção pode atender?','Regiões públicas na geografia requerida podem atender à residência de dados, conforme as capacidades do serviço e a regulamentação aplicável.'),
('64000000-0000-4000-8000-000000000021','O que é um recurso no Azure?','Um recurso é uma entidade individual gerenciável, como uma máquina virtual, uma rede virtual ou uma conta de armazenamento.'),
('64000000-0000-4000-8000-000000000023','Uma tag é adicionada a um grupo de recursos que já contém vários recursos. Qual é o efeito padrão sobre esses recursos?','Tags aplicadas ao grupo de recursos não são herdadas automaticamente por seus recursos.'),
('64000000-0000-4000-8000-000000000024','O que ocorre quando um grupo de recursos é excluído com sucesso?','Os recursos contidos no grupo também são excluídos, sujeitos ao processamento das dependências e controles aplicáveis.'),
('65000000-0000-4000-8000-000000000001','Qual definição descreve uma assinatura do Azure?','Uma assinatura é um escopo de organização, acesso, quotas, limites e cobrança que contém grupos de recursos.'),
('65000000-0000-4000-8000-000000000002','Qual é a função de um grupo de gerenciamento no Azure?','Grupos de gerenciamento organizam assinaturas para aplicar governança e acesso em um escopo superior.'),
('65000000-0000-4000-8000-000000000005','Uma multinacional precisa aplicar políticas globais e requisitos locais sem eliminar a autonomia das unidades. Como estruturar a governança?','Uma hierarquia de grupos de gerenciamento permite herdar políticas comuns e aplicar controles específicos em ramos inferiores.'),
('65000000-0000-4000-8000-000000000013','Código C# deve executar quando uma mensagem chega a uma fila, sem gerenciamento de servidores. Qual opção é mais adequada?','Azure Functions com trigger de fila oferece execução orientada a eventos sem administração direta de servidores.'),
('65000000-0000-4000-8000-000000000014','Uma aplicação legada exige software instalado diretamente no Windows e configurações específicas do sistema operacional. Qual opção é mais adequada?','Azure Virtual Machines oferece controle administrativo do sistema operacional e do software instalado.'),
('65000000-0000-4000-8000-000000000017','O que o tamanho, ou SKU, de uma máquina virtual representa?','O tamanho define uma combinação de capacidade e limites de compute, incluindo vCPUs, memória e capacidades relacionadas.'),
('65000000-0000-4000-8000-000000000018','Uma aplicação requer sistema operacional específico, software instalado manualmente e configuração de rede detalhada. Qual compute oferece esse controle?','Azure Virtual Machines permite escolher e administrar o sistema operacional, instalar componentes e configurar a rede.'),
('65000000-0000-4000-8000-000000000019','Em uma Azure VM no modelo IaaS, quem responde pelas atualizações de segurança do sistema operacional convidado?','O cliente administra e atualiza o sistema operacional convidado, ainda que possa usar ferramentas de automação da plataforma.'),
('65000000-0000-4000-8000-000000000025','Uma aplicação precisa escalar horizontalmente VMs e atender requisitos de disponibilidade. Qual desenho é adequado?','VM Scale Sets gerencia um conjunto de VMs; autoscale, balanceamento e distribuição devem ser configurados conforme os requisitos.'),
('66000000-0000-4000-8000-000000000004','Uma API executa em uma Azure VM. Quem é responsável por aplicar patches no sistema operacional convidado?','No modelo IaaS, o cliente é responsável pelo sistema operacional convidado, embora possa automatizar o processo.'),
('66000000-0000-4000-8000-000000000005','Uma empresa migrará uma carga legada que exige controle do sistema operacional, mas não quer comprar hardware. Qual opção atende?','Azure Virtual Machines fornece IaaS com controle do sistema operacional sem aquisição de servidores físicos.'),
('66000000-0000-4000-8000-000000000008','Uma equipe quer publicar uma API ASP.NET Core sem administrar o sistema operacional. Qual serviço é adequado?','Azure App Service oferece hospedagem PaaS para aplicações web e APIs, abstraindo a administração do sistema operacional.'),
('66000000-0000-4000-8000-000000000009','Uma aplicação precisa de um driver não suportado pela plataforma gerenciada. Que limitação de PaaS afeta o cenário?','Em PaaS, o cliente não controla livremente o sistema operacional subjacente nem pode instalar qualquer driver.'),
('66000000-0000-4000-8000-000000000015','O provedor de nuvem possui certificações de conformidade. O que ainda cabe ao cliente?','No modelo de responsabilidade compartilhada, o cliente deve configurar seus controles e cumprir as próprias obrigações regulatórias.'),
('66000000-0000-4000-8000-000000000016','Quais interfaces podem administrar recursos pelo Azure Resource Manager?','Portal, CLI, PowerShell, APIs e Infrastructure as Code podem enviar operações de gerenciamento ao Azure Resource Manager.'),
('66000000-0000-4000-8000-000000000018','Uma pessoa explorará visualmente um recurso e depois a equipe reproduzirá o ambiente de modo consistente. Que combinação atende?','O portal apoia a exploração visual; Infrastructure as Code fornece definições versionáveis e repetíveis.'),
('66000000-0000-4000-8000-000000000019','Uma ferramenta interna precisa criar recursos do Azure programaticamente. Qual interface é apropriada?','Uma API de gerenciamento permite integrar a ferramenta às operações do Azure Resource Manager.'),
('66000000-0000-4000-8000-000000000020','Uma equipe precisa revisar e reproduzir a mesma infraestrutura em desenvolvimento e produção. Qual abordagem é adequada?','Infrastructure as Code permite versionar, revisar e aplicar definições consistentes em vários ambientes.'),
('68000000-0000-4000-8000-000000000001','O que o tamanho de uma Azure Virtual Machine representa?','O tamanho define uma combinação de capacidade e limites de compute, como vCPUs, memória e recursos relacionados.'),
('68000000-0000-4000-8000-000000000005','Uma Azure VM deve atender sistemas internos somente pela rede privada. Quais componentes são essenciais?','A VM requer tamanho de compute, disco do sistema operacional e NIC conectada a uma subnet; um IP público não é necessário.'),
('68000000-0000-4000-8000-000000000010','Qual diferença distingue Azure Virtual Desktop de acesso RDP direto a uma VM?','AVD publica e gerencia desktops e aplicações para usuários; RDP fornece acesso remoto direto a uma máquina.'),
('68000000-0000-4000-8000-000000000011','O que uma imagem de container empacota para favorecer execução consistente?','A imagem reúne a aplicação e suas dependências, sem incluir necessariamente um sistema operacional convidado completo.'),
('68000000-0000-4000-8000-000000000013','Uma equipe quer executar um container isolado sem administrar VMs nem um cluster Kubernetes. Qual serviço é mais direto?','Azure Container Instances executa containers isolados sem que a equipe gerencie servidores ou um orquestrador.'),
('68000000-0000-4000-8000-000000000015','Uma API deve usar em teste e produção o mesmo pacote de runtime e bibliotecas, sem exigir controle do sistema operacional. Qual opção atende?','Uma imagem de container empacota a aplicação e as dependências para execução consistente em ambientes compatíveis.'),
('68000000-0000-4000-8000-000000000019','Uma API exige componente instalado diretamente no Windows Server e alterações profundas no sistema operacional. Qual compute é mais adequado?','Uma máquina virtual oferece o controle do sistema operacional convidado exigido pelo cenário.'),
('68000000-0000-4000-8000-000000000021','Qual requisito aponta mais diretamente para o uso de containers?','Containers são adequados quando aplicação e dependências devem viajar juntas em uma imagem portátil.'),
('68000000-0000-4000-8000-000000000022','Uma aplicação legada precisa instalar componentes diretamente no Windows Server. Qual opção é mais adequada?','Azure Virtual Machines oferece acesso administrativo ao sistema operacional convidado.'),
('68000000-0000-4000-8000-000000000023','Como Web Apps, containers e VMs diferem quanto a controle e responsabilidade?','Web Apps reduz tarefas de plataforma; containers controlam o pacote da aplicação; VMs oferecem mais controle do sistema operacional.'),
('68000000-0000-4000-8000-000000000028','Uma equipe quer separar frontend, API e dados em segmentos da mesma rede privada lógica. Qual desenho atende?','Uma VNet pode conter subnets distintas para organizar cada camada e aplicar controles de rede.'),
('68000000-0000-4000-8000-000000000029','Dois recursos estão em subnets diferentes da mesma VNet. O que determina se podem trocar tráfego privado?','A VNet fornece conectividade privada, mas regras de segurança, rotas e configurações dos recursos determinam o tráfego efetivo.'),
('68000000-0000-4000-8000-000000000034','Duas VNets têm peering, mas uma aplicação não alcança a outra rede. Qual verificação é mais adequada?','Peering fornece conectividade privada, mas regras de segurança, rotas e configurações dos recursos ainda podem bloquear o tráfego.'),
('68000000-0000-4000-8000-000000000036','Qual diferença caracteriza conexões VPN Site-to-Site e Point-to-Site?','Site-to-Site conecta uma rede on-premises à VNet; Point-to-Site conecta um dispositivo cliente à VNet.'),
('68000000-0000-4000-8000-000000000039','Uma filial aceita túnel criptografado pela Internet, enquanto o datacenter principal requer conexão privada por provedor. Qual combinação se alinha?','VPN Gateway atende o túnel pela Internet; ExpressRoute fornece conectividade privada por meio de um provedor.'),
('68000000-0000-4000-8000-000000000040','O que caracteriza um endpoint público de um serviço Azure?','Ele é alcançável por conectividade pública, mas autenticação, firewall e regras de rede ainda podem restringir o acesso.'),
('68000000-0000-4000-8000-000000000044','Criar um Private Endpoint remove automaticamente o acesso público ao serviço?','Não. Acesso público e privado podem coexistir; o acesso público deve ser configurado separadamente conforme o serviço.'),
('68000000-0000-4000-8000-000000000048','Qual capacidade caracteriza uma conta de armazenamento General-purpose v2?','Uma conta GPv2 pode disponibilizar Blob, Files, Queue e Table e atende a muitos cenários gerais de armazenamento.');

update public.questions question
set question_text = seed.question_text,
    explanation = seed.explanation,
    updated_at = now()
from az900_quality_question_seed_256_383 seed
where question.id = seed.id;

create temporary table az900_quality_option_seed_256_383 (
  id uuid primary key,
  option_text text not null,
  explanation text not null
) on commit drop;

insert into az900_quality_option_seed_256_383 (id, option_text, explanation) values
('75000000-0000-4000-8000-000000000013','O cliente mantém a aplicação nos três modelos; muda apenas a propriedade do hardware.','Incorreta. Em SaaS, o provedor mantém a aplicação; em PaaS, o cliente mantém seu código; em IaaS, o cliente também administra o sistema operacional e o runtime.'),
('75000000-0000-4000-8000-000000000016','O provedor mantém a aplicação em SaaS; o cliente mantém seu código em PaaS e também o sistema operacional e o runtime em IaaS.','Correta. Em SaaS, o provedor mantém a aplicação; em PaaS, o cliente mantém seu código; em IaaS, o cliente também administra o sistema operacional e o runtime.'),
('75000000-0000-4000-8000-000000000014','O cliente mantém o sistema operacional em SaaS e PaaS, mas não em IaaS.','Incorreta. Em SaaS, o provedor mantém a aplicação; em PaaS, o cliente mantém seu código; em IaaS, o cliente também administra o sistema operacional e o runtime.'),
('75000000-0000-4000-8000-000000000015','O provedor mantém a aplicação em IaaS; em SaaS, essa tarefa pertence ao cliente.','Incorreta. Em SaaS, o provedor mantém a aplicação; em PaaS, o cliente mantém seu código; em IaaS, o cliente também administra o sistema operacional e o runtime.'),
('75000000-0000-4000-8000-000000000017','IaaS, porque o controle da VM compensa a administração adicional exigida da pequena equipe.','Incorreta. SaaS fornece a aplicação pronta e transfere ao provedor a manutenção da aplicação e das camadas subjacentes.'),
('75000000-0000-4000-8000-000000000019','PaaS, porque um runtime gerenciado transforma o sistema financeiro existente em uma aplicação pronta.','Incorreta. SaaS fornece a aplicação pronta e transfere ao provedor a manutenção da aplicação e das camadas subjacentes.'),
('75000000-0000-4000-8000-000000000018','SaaS, porque a solução pronta atende ao processo padrão e reduz a manutenção interna.','Correta. SaaS fornece a aplicação pronta e transfere ao provedor a manutenção da aplicação e das camadas subjacentes.'),
('75000000-0000-4000-8000-000000000020','On-premises, porque manter servidores próprios reduz o trabalho operacional de uma equipe pequena.','Incorreta. SaaS fornece a aplicação pronta e transfere ao provedor a manutenção da aplicação e das camadas subjacentes.'),
('75000000-0000-4000-8000-000000000022','A linguagem usada pela aplicação, independentemente do controle ou da operação necessários.','Incorreta. A escolha equilibra o controle necessário sobre a pilha e a responsabilidade operacional que a equipe pode assumir.'),
('75000000-0000-4000-8000-000000000023','A localização dos usuários, pois a divisão de responsabilidades é igual nos três modelos.','Incorreta. A escolha equilibra o controle necessário sobre a pilha e a responsabilidade operacional que a equipe pode assumir.'),
('75000000-0000-4000-8000-000000000024','Somente o preço anunciado, sem considerar as camadas administradas pelo cliente.','Incorreta. A escolha equilibra o controle necessário sobre a pilha e a responsabilidade operacional que a equipe pode assumir.'),
('75000000-0000-4000-8000-000000000021','O equilíbrio entre controle desejado e responsabilidade operacional que a equipe pode assumir.','Correta. A escolha equilibra o controle necessário sobre a pilha e a responsabilidade operacional que a equipe pode assumir.'),
('75000000-0000-4000-8000-000000000025','IaaS.','Correta. IaaS deixa sistema operacional, runtime, aplicação e dados sob responsabilidade do cliente, enquanto o provedor gerencia a infraestrutura física.'),
('75000000-0000-4000-8000-000000000026','PaaS.','Incorreta. IaaS deixa sistema operacional, runtime, aplicação e dados sob responsabilidade do cliente, enquanto o provedor gerencia a infraestrutura física.'),
('75000000-0000-4000-8000-000000000027','SaaS.','Incorreta. IaaS deixa sistema operacional, runtime, aplicação e dados sob responsabilidade do cliente, enquanto o provedor gerencia a infraestrutura física.'),
('75000000-0000-4000-8000-000000000028','Os três deixam a mesma quantidade de componentes sob gerenciamento do cliente.','Incorreta. IaaS deixa sistema operacional, runtime, aplicação e dados sob responsabilidade do cliente, enquanto o provedor gerencia a infraestrutura física.'),
('75000000-0000-4000-8000-000000000029','SaaS, porque o cliente pode escolher o sistema operacional da aplicação pronta.','Incorreta. IaaS oferece controle sobre o sistema operacional e a configuração da máquina virtual.'),
('75000000-0000-4000-8000-000000000031','IaaS, porque permite configurar o sistema operacional da máquina virtual.','Correta. IaaS oferece controle sobre o sistema operacional e a configuração da máquina virtual.'),
('75000000-0000-4000-8000-000000000030','PaaS, porque a plataforma permite alterar livremente o sistema operacional subjacente.','Incorreta. IaaS oferece controle sobre o sistema operacional e a configuração da máquina virtual.'),
('75000000-0000-4000-8000-000000000032','SaaS, porque o provedor entrega uma VM para o cliente instalar a aplicação legada.','Incorreta. IaaS oferece controle sobre o sistema operacional e a configuração da máquina virtual.'),
('75000000-0000-4000-8000-000000000033','IaaS, porque a equipe administra o runtime instalado na máquina virtual.','Incorreta. PaaS gerencia infraestrutura, sistema operacional e runtime, permitindo que a equipe se concentre no código da aplicação.'),
('75000000-0000-4000-8000-000000000035','SaaS, porque a equipe publica seu próprio código na aplicação pronta do provedor.','Incorreta. PaaS gerencia infraestrutura, sistema operacional e runtime, permitindo que a equipe se concentre no código da aplicação.'),
('75000000-0000-4000-8000-000000000034','PaaS, porque o provedor administra o sistema operacional e o runtime.','Correta. PaaS gerencia infraestrutura, sistema operacional e runtime, permitindo que a equipe se concentre no código da aplicação.'),
('75000000-0000-4000-8000-000000000036','On-premises, porque servidores locais removem a necessidade de administrar a plataforma.','Incorreta. PaaS gerencia infraestrutura, sistema operacional e runtime, permitindo que a equipe se concentre no código da aplicação.'),
('75000000-0000-4000-8000-000000000037','IaaS para os três casos, mantendo o mesmo nível de controle e operação.','Incorreta. SaaS atende o software pronto, PaaS a aplicação própria sem gestão da plataforma e IaaS o legado que exige controle do sistema operacional.'),
('75000000-0000-4000-8000-000000000039','SaaS para os três casos, incluindo o desenvolvimento e o legado.','Incorreta. SaaS atende o software pronto, PaaS a aplicação própria sem gestão da plataforma e IaaS o legado que exige controle do sistema operacional.'),
('75000000-0000-4000-8000-000000000040','PaaS para os três casos, inclusive para consumir a folha de pagamento pronta.','Incorreta. SaaS atende o software pronto, PaaS a aplicação própria sem gestão da plataforma e IaaS o legado que exige controle do sistema operacional.'),
('75000000-0000-4000-8000-000000000038','SaaS para a folha pronta, PaaS para a aplicação própria e IaaS para o legado.','Correta. SaaS atende o software pronto, PaaS a aplicação própria sem gestão da plataforma e IaaS o legado que exige controle do sistema operacional.'),
('75000000-0000-4000-8000-000000000041','Uma área geográfica com um ou mais datacenters conectados por rede de baixa latência.','Correta. Uma região é uma área geográfica que contém um ou mais datacenters conectados por uma rede de baixa latência.'),
('75000000-0000-4000-8000-000000000042','Um conjunto de zonas de disponibilidade que necessariamente abrange várias geografias.','Incorreta. Uma região é uma área geográfica que contém um ou mais datacenters conectados por uma rede de baixa latência.'),
('75000000-0000-4000-8000-000000000043','Um par fixo de datacenters usado para replicação de qualquer serviço.','Incorreta. Uma região é uma área geográfica que contém um ou mais datacenters conectados por uma rede de baixa latência.'),
('75000000-0000-4000-8000-000000000044','Um limite lógico de cobrança que contém grupos de recursos.','Incorreta. Uma região é uma área geográfica que contém um ou mais datacenters conectados por uma rede de baixa latência.'),
('75000000-0000-4000-8000-000000000046','Apenas a latência, pois serviços, preços e residência de dados não variam por região.','Incorreta. Latência, disponibilidade regional de serviços, preço e requisitos de residência de dados podem variar conforme a região.'),
('75000000-0000-4000-8000-000000000045','Latência, disponibilidade de serviços, preço e requisitos de residência de dados.','Correta. Latência, disponibilidade regional de serviços, preço e requisitos de residência de dados podem variar conforme a região.'),
('75000000-0000-4000-8000-000000000047','Somente a quantidade de grupos de recursos permitidos na assinatura.','Incorreta. Latência, disponibilidade regional de serviços, preço e requisitos de residência de dados podem variar conforme a região.'),
('75000000-0000-4000-8000-000000000048','Apenas o idioma padrão das aplicações implantadas na região.','Incorreta. Latência, disponibilidade regional de serviços, preço e requisitos de residência de dados podem variar conforme a região.'),
('75000000-0000-4000-8000-000000000050','Mover para uma região mais distante com uma VM de tamanho maior.','Incorreta. Hospedar a aplicação em uma região mais próxima reduz a distância de rede; aumentar compute não corrige, por si só, latência geográfica.'),
('75000000-0000-4000-8000-000000000051','Manter a região e aumentar a capacidade de armazenamento da aplicação.','Incorreta. Hospedar a aplicação em uma região mais próxima reduz a distância de rede; aumentar compute não corrige, por si só, latência geográfica.'),
('75000000-0000-4000-8000-000000000049','Hospedar a aplicação em uma região mais próxima dos jogadores.','Correta. Hospedar a aplicação em uma região mais próxima reduz a distância de rede; aumentar compute não corrige, por si só, latência geográfica.'),
('75000000-0000-4000-8000-000000000052','Manter a região e adicionar mais grupos de recursos à assinatura.','Incorreta. Hospedar a aplicação em uma região mais próxima reduz a distância de rede; aumentar compute não corrige, por si só, latência geográfica.'),
('75000000-0000-4000-8000-000000000053','Escolher a região mesmo assim e substituir o banco gerenciado por uma zona de disponibilidade.','Incorreta. A equipe deve confirmar a disponibilidade regional dos serviços necessários e escolher uma região que atenda às dependências.'),
('75000000-0000-4000-8000-000000000055','Escolher a região e usar um grupo de recursos para disponibilizar o serviço ausente.','Incorreta. A equipe deve confirmar a disponibilidade regional dos serviços necessários e escolher uma região que atenda às dependências.'),
('75000000-0000-4000-8000-000000000056','Escolher a região e usar peering para importar o catálogo de serviços de outra região.','Incorreta. A equipe deve confirmar a disponibilidade regional dos serviços necessários e escolher uma região que atenda às dependências.'),
('75000000-0000-4000-8000-000000000054','Confirmar a disponibilidade dos serviços exigidos antes de selecionar a região.','Correta. A equipe deve confirmar a disponibilidade regional dos serviços necessários e escolher uma região que atenda às dependências.'),
('75000000-0000-4000-8000-000000000058','Avaliar em conjunto latência, disponibilidade do serviço e residência de dados.','Correta. A decisão deve avaliar conjuntamente proximidade dos usuários, disponibilidade dos serviços e obrigações de residência de dados.'),
('75000000-0000-4000-8000-000000000057','Priorizar a menor tarifa e tratar os demais requisitos após a implantação.','Incorreta. A decisão deve avaliar conjuntamente proximidade dos usuários, disponibilidade dos serviços e obrigações de residência de dados.'),
('75000000-0000-4000-8000-000000000059','Priorizar o maior número de zonas, mesmo sem o serviço requerido.','Incorreta. A decisão deve avaliar conjuntamente proximidade dos usuários, disponibilidade dos serviços e obrigações de residência de dados.'),
('75000000-0000-4000-8000-000000000060','Priorizar somente a menor latência, sem validar residência de dados.','Incorreta. A decisão deve avaliar conjuntamente proximidade dos usuários, disponibilidade dos serviços e obrigações de residência de dados.'),
('75000000-0000-4000-8000-000000000070','A região não pode integrar uma solução que use várias regiões.','Incorreta. Uma região sem par ainda pode participar de uma arquitetura resiliente usando zonas de disponibilidade e soluções multirregionais compatíveis.'),
('75000000-0000-4000-8000-000000000071','A plataforma cria um par regional exclusivo para cada workload.','Incorreta. Uma região sem par ainda pode participar de uma arquitetura resiliente usando zonas de disponibilidade e soluções multirregionais compatíveis.'),
('75000000-0000-4000-8000-000000000072','A região passa a oferecer as propriedades de uma nuvem soberana.','Incorreta. Uma região sem par ainda pode participar de uma arquitetura resiliente usando zonas de disponibilidade e soluções multirregionais compatíveis.'),
('75000000-0000-4000-8000-000000000069','A arquitetura ainda pode usar zonas e recursos multirregionais compatíveis.','Correta. Uma região sem par ainda pode participar de uma arquitetura resiliente usando zonas de disponibilidade e soluções multirregionais compatíveis.'),
('75000000-0000-4000-8000-000000000074','Usar regiões públicas na geografia requerida, após validar serviço e regulamentação.','Correta. Regiões públicas na geografia requerida podem atender à residência de dados, conforme as capacidades do serviço e a regulamentação aplicável.'),
('75000000-0000-4000-8000-000000000073','Usar obrigatoriamente uma nuvem soberana para qualquer requisito de residência.','Incorreta. Regiões públicas na geografia requerida podem atender à residência de dados, conforme as capacidades do serviço e a regulamentação aplicável.'),
('75000000-0000-4000-8000-000000000075','Usar qualquer região que pertença a um par regional, independentemente da geografia.','Incorreta. Regiões públicas na geografia requerida podem atender à residência de dados, conforme as capacidades do serviço e a regulamentação aplicável.'),
('75000000-0000-4000-8000-000000000076','Manter os dados on-premises, pois regiões públicas não oferecem opções de residência.','Incorreta. Regiões públicas na geografia requerida podem atender à residência de dados, conforme as capacidades do serviço e a regulamentação aplicável.'),
('75000000-0000-4000-8000-000000000082','Um item de cobrança que representa todos os serviços de uma assinatura.','Incorreta. Um recurso é uma entidade individual gerenciável, como uma máquina virtual, uma rede virtual ou uma conta de armazenamento.'),
('75000000-0000-4000-8000-000000000083','Um limite de governança que contém várias assinaturas.','Incorreta. Um recurso é uma entidade individual gerenciável, como uma máquina virtual, uma rede virtual ou uma conta de armazenamento.'),
('75000000-0000-4000-8000-000000000081','Uma entidade individual gerenciável disponibilizada pelo Azure.','Correta. Um recurso é uma entidade individual gerenciável, como uma máquina virtual, uma rede virtual ou uma conta de armazenamento.'),
('75000000-0000-4000-8000-000000000084','Um contêiner lógico que obrigatoriamente contém recursos de várias regiões.','Incorreta. Um recurso é uma entidade individual gerenciável, como uma máquina virtual, uma rede virtual ou uma conta de armazenamento.'),
('75000000-0000-4000-8000-000000000090','Nenhuma; as tags não são herdadas automaticamente do grupo.','Correta. Tags aplicadas ao grupo de recursos não são herdadas automaticamente por seus recursos.'),
('75000000-0000-4000-8000-000000000089','A tag é copiada para os recursos atuais, mas não para recursos futuros.','Incorreta. Tags aplicadas ao grupo de recursos não são herdadas automaticamente por seus recursos.'),
('75000000-0000-4000-8000-000000000091','A tag é copiada apenas para recursos que compartilham a região do grupo.','Incorreta. Tags aplicadas ao grupo de recursos não são herdadas automaticamente por seus recursos.'),
('75000000-0000-4000-8000-000000000092','A tag substitui as tags existentes em cada recurso do grupo.','Incorreta. Tags aplicadas ao grupo de recursos não são herdadas automaticamente por seus recursos.'),
('75000000-0000-4000-8000-000000000093','Somente o contêiner lógico é excluído; os recursos ficam sem grupo.','Incorreta. Os recursos contidos no grupo também são excluídos, sujeitos ao processamento das dependências e controles aplicáveis.'),
('75000000-0000-4000-8000-000000000094','Os recursos contidos no grupo também são excluídos.','Correta. Os recursos contidos no grupo também são excluídos, sujeitos ao processamento das dependências e controles aplicáveis.'),
('75000000-0000-4000-8000-000000000095','Apenas os recursos sem tag são excluídos; os demais são preservados.','Incorreta. Os recursos contidos no grupo também são excluídos, sujeitos ao processamento das dependências e controles aplicáveis.'),
('75000000-0000-4000-8000-000000000096','Os recursos são movidos para o grupo padrão da assinatura.','Incorreta. Os recursos contidos no grupo também são excluídos, sujeitos ao processamento das dependências e controles aplicáveis.'),
('77000000-0000-4000-8000-000000000002','Um contêiner físico que hospeda todos os recursos da organização.','Incorreta. Uma assinatura é um escopo de organização, acesso, quotas, limites e cobrança que contém grupos de recursos.'),
('77000000-0000-4000-8000-000000000003','Um documento de cobrança associado a uma única forma de pagamento.','Incorreta. Uma assinatura é um escopo de organização, acesso, quotas, limites e cobrança que contém grupos de recursos.'),
('77000000-0000-4000-8000-000000000004','Um grupo de recursos reservado exclusivamente para custos.','Incorreta. Uma assinatura é um escopo de organização, acesso, quotas, limites e cobrança que contém grupos de recursos.'),
('77000000-0000-4000-8000-000000000001','Um escopo para grupos de recursos, acesso, quotas, limites e cobrança.','Correta. Uma assinatura é um escopo de organização, acesso, quotas, limites e cobrança que contém grupos de recursos.'),
('77000000-0000-4000-8000-000000000005','Um escopo acima das assinaturas usado para organização e governança.','Correta. Grupos de gerenciamento organizam assinaturas para aplicar governança e acesso em um escopo superior.'),
('77000000-0000-4000-8000-000000000006','Um contêiner dentro de uma assinatura que agrupa recursos individuais.','Incorreta. Grupos de gerenciamento organizam assinaturas para aplicar governança e acesso em um escopo superior.'),
('77000000-0000-4000-8000-000000000007','Um diretório de identidades associado exclusivamente a uma assinatura.','Incorreta. Grupos de gerenciamento organizam assinaturas para aplicar governança e acesso em um escopo superior.'),
('77000000-0000-4000-8000-000000000008','Um limite de cobrança criado separadamente para cada grupo de recursos.','Incorreta. Grupos de gerenciamento organizam assinaturas para aplicar governança e acesso em um escopo superior.'),
('77000000-0000-4000-8000-000000000017','Aplicar todas as políticas diretamente aos recursos de uma única assinatura global.','Incorreta. Uma hierarquia de grupos de gerenciamento permite herdar políticas comuns e aplicar controles específicos em ramos inferiores.'),
('77000000-0000-4000-8000-000000000019','Criar um grupo de gerenciamento independente para cada recurso implantado.','Incorreta. Uma hierarquia de grupos de gerenciamento permite herdar políticas comuns e aplicar controles específicos em ramos inferiores.'),
('77000000-0000-4000-8000-000000000020','Aplicar apenas políticas locais e repetir manualmente os controles corporativos.','Incorreta. Uma hierarquia de grupos de gerenciamento permite herdar políticas comuns e aplicar controles específicos em ramos inferiores.'),
('77000000-0000-4000-8000-000000000018','Criar uma hierarquia com políticas globais nos níveis superiores e controles locais nos ramos adequados.','Correta. Uma hierarquia de grupos de gerenciamento permite herdar políticas comuns e aplicar controles específicos em ramos inferiores.'),
('77000000-0000-4000-8000-000000000049','Uma VM com um processo que consulta continuamente a fila.','Incorreta. Azure Functions com trigger de fila oferece execução orientada a eventos sem administração direta de servidores.'),
('77000000-0000-4000-8000-000000000051','Azure Container Instances iniciado manualmente para cada mensagem.','Incorreta. Azure Functions com trigger de fila oferece execução orientada a eventos sem administração direta de servidores.'),
('77000000-0000-4000-8000-000000000052','Azure App Service com implantação agendada, sem integração com a fila.','Incorreta. Azure Functions com trigger de fila oferece execução orientada a eventos sem administração direta de servidores.'),
('77000000-0000-4000-8000-000000000050','Azure Functions com trigger de fila.','Correta. Azure Functions com trigger de fila oferece execução orientada a eventos sem administração direta de servidores.'),
('77000000-0000-4000-8000-000000000055','Azure Virtual Machines, pelo controle do sistema operacional convidado.','Correta. Azure Virtual Machines oferece controle administrativo do sistema operacional e do software instalado.'),
('77000000-0000-4000-8000-000000000053','Azure Functions, usando extensões para administrar o Windows subjacente.','Incorreta. Azure Virtual Machines oferece controle administrativo do sistema operacional e do software instalado.'),
('77000000-0000-4000-8000-000000000054','Azure Container Instances, alterando diretamente o kernel do host.','Incorreta. Azure Virtual Machines oferece controle administrativo do sistema operacional e do software instalado.'),
('77000000-0000-4000-8000-000000000056','Azure App Service, instalando componentes com privilégios administrativos no host.','Incorreta. Azure Virtual Machines oferece controle administrativo do sistema operacional e do software instalado.'),
('77000000-0000-4000-8000-000000000066','A imagem do sistema operacional usada para criar a VM.','Incorreta. O tamanho define uma combinação de capacidade e limites de compute, incluindo vCPUs, memória e capacidades relacionadas.'),
('77000000-0000-4000-8000-000000000067','O perfil de permissões RBAC dos administradores da VM.','Incorreta. O tamanho define uma combinação de capacidade e limites de compute, incluindo vCPUs, memória e capacidades relacionadas.'),
('77000000-0000-4000-8000-000000000068','A camada de redundância aplicada ao disco do sistema operacional.','Incorreta. O tamanho define uma combinação de capacidade e limites de compute, incluindo vCPUs, memória e capacidades relacionadas.'),
('77000000-0000-4000-8000-000000000065','A combinação de vCPUs, memória e capacidades relacionadas disponíveis para a VM.','Correta. O tamanho define uma combinação de capacidade e limites de compute, incluindo vCPUs, memória e capacidades relacionadas.'),
('77000000-0000-4000-8000-000000000069','Azure Virtual Machines.','Correta. Azure Virtual Machines permite escolher e administrar o sistema operacional, instalar componentes e configurar a rede.'),
('77000000-0000-4000-8000-000000000070','Azure Functions.','Incorreta. Azure Virtual Machines permite escolher e administrar o sistema operacional, instalar componentes e configurar a rede.'),
('77000000-0000-4000-8000-000000000071','Azure App Service.','Incorreta. Azure Virtual Machines permite escolher e administrar o sistema operacional, instalar componentes e configurar a rede.'),
('77000000-0000-4000-8000-000000000072','Azure Container Instances.','Incorreta. Azure Virtual Machines permite escolher e administrar o sistema operacional, instalar componentes e configurar a rede.'),
('77000000-0000-4000-8000-000000000074','A Microsoft, porque ela administra o sistema operacional convidado em IaaS.','Incorreta. O cliente administra e atualiza o sistema operacional convidado, ainda que possa usar ferramentas de automação da plataforma.'),
('77000000-0000-4000-8000-000000000073','O cliente, que administra o sistema operacional convidado.','Correta. O cliente administra e atualiza o sistema operacional convidado, ainda que possa usar ferramentas de automação da plataforma.'),
('77000000-0000-4000-8000-000000000075','O fabricante do sistema operacional, sem participação do cliente.','Incorreta. O cliente administra e atualiza o sistema operacional convidado, ainda que possa usar ferramentas de automação da plataforma.'),
('77000000-0000-4000-8000-000000000076','O provedor de conectividade usado pela rede virtual.','Incorreta. O cliente administra e atualiza o sistema operacional convidado, ainda que possa usar ferramentas de automação da plataforma.'),
('77000000-0000-4000-8000-000000000097','Um Availability Set, que também gerencia escala horizontal por demanda.','Incorreta. VM Scale Sets gerencia um conjunto de VMs; autoscale, balanceamento e distribuição devem ser configurados conforme os requisitos.'),
('77000000-0000-4000-8000-000000000099','Uma única VM maior, distribuída automaticamente entre domínios de falha.','Incorreta. VM Scale Sets gerencia um conjunto de VMs; autoscale, balanceamento e distribuição devem ser configurados conforme os requisitos.'),
('77000000-0000-4000-8000-000000000100','Um VM Scale Set sem configurar balanceamento, autoscale ou distribuição.','Incorreta. VM Scale Sets gerencia um conjunto de VMs; autoscale, balanceamento e distribuição devem ser configurados conforme os requisitos.'),
('77000000-0000-4000-8000-000000000098','Um VM Scale Set com autoscale, balanceamento e distribuição ajustados aos requisitos.','Correta. VM Scale Sets gerencia um conjunto de VMs; autoscale, balanceamento e distribuição devem ser configurados conforme os requisitos.'),
('7d000000-0000-4000-8000-000000000014','A Microsoft, porque toda VM é uma plataforma gerenciada.','Incorreta. No modelo IaaS, o cliente é responsável pelo sistema operacional convidado, embora possa automatizar o processo.'),
('7d000000-0000-4000-8000-000000000015','O usuário da aplicação, porque ele consome o sistema operacional.','Incorreta. No modelo IaaS, o cliente é responsável pelo sistema operacional convidado, embora possa automatizar o processo.'),
('7d000000-0000-4000-8000-000000000016','O fabricante da API, independentemente de quem administra a VM.','Incorreta. No modelo IaaS, o cliente é responsável pelo sistema operacional convidado, embora possa automatizar o processo.'),
('7d000000-0000-4000-8000-000000000013','O cliente, responsável pelo sistema operacional convidado em IaaS.','Correta. No modelo IaaS, o cliente é responsável pelo sistema operacional convidado, embora possa automatizar o processo.'),
('7d000000-0000-4000-8000-000000000017','Azure Virtual Machines em IaaS.','Correta. Azure Virtual Machines fornece IaaS com controle do sistema operacional sem aquisição de servidores físicos.'),
('7d000000-0000-4000-8000-000000000018','Azure App Service em PaaS, com acesso administrativo ao sistema operacional.','Incorreta. Azure Virtual Machines fornece IaaS com controle do sistema operacional sem aquisição de servidores físicos.'),
('7d000000-0000-4000-8000-000000000019','Azure Functions, instalando componentes persistentes no host de execução.','Incorreta. Azure Virtual Machines fornece IaaS com controle do sistema operacional sem aquisição de servidores físicos.'),
('7d000000-0000-4000-8000-000000000020','Azure Container Instances, administrando diretamente o kernel do host.','Incorreta. Azure Virtual Machines fornece IaaS com controle do sistema operacional sem aquisição de servidores físicos.'),
('7d000000-0000-4000-8000-000000000030','Azure Virtual Machines, mantendo a responsabilidade pelo sistema operacional.','Incorreta. Azure App Service oferece hospedagem PaaS para aplicações web e APIs, abstraindo a administração do sistema operacional.'),
('7d000000-0000-4000-8000-000000000031','Azure Container Instances, desde que a equipe administre o host.','Incorreta. Azure App Service oferece hospedagem PaaS para aplicações web e APIs, abstraindo a administração do sistema operacional.'),
('7d000000-0000-4000-8000-000000000032','Azure Functions, mesmo que a API não siga um modelo orientado a eventos.','Incorreta. Azure App Service oferece hospedagem PaaS para aplicações web e APIs, abstraindo a administração do sistema operacional.'),
('7d000000-0000-4000-8000-000000000029','Azure App Service.','Correta. Azure App Service oferece hospedagem PaaS para aplicações web e APIs, abstraindo a administração do sistema operacional.'),
('7d000000-0000-4000-8000-000000000033','O cliente não controla livremente o sistema operacional da plataforma.','Correta. Em PaaS, o cliente não controla livremente o sistema operacional subjacente nem pode instalar qualquer driver.'),
('7d000000-0000-4000-8000-000000000034','O cliente deve adquirir o hardware usado pelo serviço PaaS.','Incorreta. Em PaaS, o cliente não controla livremente o sistema operacional subjacente nem pode instalar qualquer driver.'),
('7d000000-0000-4000-8000-000000000035','A plataforma não permite implantar código criado pelo cliente.','Incorreta. Em PaaS, o cliente não controla livremente o sistema operacional subjacente nem pode instalar qualquer driver.'),
('7d000000-0000-4000-8000-000000000036','A plataforma oferece mais controle do sistema operacional que IaaS.','Incorreta. Em PaaS, o cliente não controla livremente o sistema operacional subjacente nem pode instalar qualquer driver.'),
('7d000000-0000-4000-8000-000000000058','Delegar ao provedor todas as decisões de configuração e acesso aos dados.','Incorreta. No modelo de responsabilidade compartilhada, o cliente deve configurar seus controles e cumprir as próprias obrigações regulatórias.'),
('7d000000-0000-4000-8000-000000000059','Cumprir somente requisitos que não aparecem nas certificações do provedor.','Incorreta. No modelo de responsabilidade compartilhada, o cliente deve configurar seus controles e cumprir as próprias obrigações regulatórias.'),
('7d000000-0000-4000-8000-000000000057','Configurar seus controles e cumprir as obrigações que permanecem sob sua responsabilidade.','Correta. No modelo de responsabilidade compartilhada, o cliente deve configurar seus controles e cumprir as próprias obrigações regulatórias.'),
('7d000000-0000-4000-8000-000000000060','Usar as configurações padrão como evidência suficiente de conformidade própria.','Incorreta. No modelo de responsabilidade compartilhada, o cliente deve configurar seus controles e cumprir as próprias obrigações regulatórias.'),
('7d000000-0000-4000-8000-000000000062','Portal e CLI, mas não PowerShell nem APIs.','Incorreta. Portal, CLI, PowerShell, APIs e Infrastructure as Code podem enviar operações de gerenciamento ao Azure Resource Manager.'),
('7d000000-0000-4000-8000-000000000063','PowerShell e APIs, mas não o portal nem templates.','Incorreta. Portal, CLI, PowerShell, APIs e Infrastructure as Code podem enviar operações de gerenciamento ao Azure Resource Manager.'),
('7d000000-0000-4000-8000-000000000064','Portal e Infrastructure as Code, mas não ferramentas de linha de comando.','Incorreta. Portal, CLI, PowerShell, APIs e Infrastructure as Code podem enviar operações de gerenciamento ao Azure Resource Manager.'),
('7d000000-0000-4000-8000-000000000061','Portal, CLI, PowerShell, APIs e Infrastructure as Code.','Correta. Portal, CLI, PowerShell, APIs e Infrastructure as Code podem enviar operações de gerenciamento ao Azure Resource Manager.'),
('7d000000-0000-4000-8000-000000000070','CLI para explorar visualmente e portal para versionar o ambiente.','Incorreta. O portal apoia a exploração visual; Infrastructure as Code fornece definições versionáveis e repetíveis.'),
('7d000000-0000-4000-8000-000000000069','Portal para explorar e Infrastructure as Code para reproduzir.','Correta. O portal apoia a exploração visual; Infrastructure as Code fornece definições versionáveis e repetíveis.'),
('7d000000-0000-4000-8000-000000000071','PowerShell para explorar visualmente e tags para reproduzir recursos.','Incorreta. O portal apoia a exploração visual; Infrastructure as Code fornece definições versionáveis e repetíveis.'),
('7d000000-0000-4000-8000-000000000072','API para explorar visualmente e Resource Locks para reproduzir recursos.','Incorreta. O portal apoia a exploração visual; Infrastructure as Code fornece definições versionáveis e repetíveis.'),
('7d000000-0000-4000-8000-000000000074','Uma regra do Azure Policy.','Incorreta. Uma API de gerenciamento permite integrar a ferramenta às operações do Azure Resource Manager.'),
('7d000000-0000-4000-8000-000000000075','Um template de custo do Azure Advisor.','Incorreta. Uma API de gerenciamento permite integrar a ferramenta às operações do Azure Resource Manager.'),
('7d000000-0000-4000-8000-000000000073','Uma API de gerenciamento.','Correta. Uma API de gerenciamento permite integrar a ferramenta às operações do Azure Resource Manager.'),
('7d000000-0000-4000-8000-000000000076','Uma conexão de Azure ExpressRoute.','Incorreta. Uma API de gerenciamento permite integrar a ferramenta às operações do Azure Resource Manager.'),
('7d000000-0000-4000-8000-000000000078','Procedimentos manuais documentados separadamente para cada ambiente.','Incorreta. Infrastructure as Code permite versionar, revisar e aplicar definições consistentes em vários ambientes.'),
('7d000000-0000-4000-8000-000000000079','Scripts não versionados, editados diretamente antes de cada execução.','Incorreta. Infrastructure as Code permite versionar, revisar e aplicar definições consistentes em vários ambientes.'),
('7d000000-0000-4000-8000-000000000080','Capturas de tela das configurações usadas no primeiro ambiente.','Incorreta. Infrastructure as Code permite versionar, revisar e aplicar definições consistentes em vários ambientes.'),
('7d000000-0000-4000-8000-000000000077','Infrastructure as Code versionada e revisada.','Correta. Infrastructure as Code permite versionar, revisar e aplicar definições consistentes em vários ambientes.'),
('7f100000-0000-4000-8000-000000000001','Uma combinação de capacidade e limites de compute.','Correta. O tamanho define uma combinação de capacidade e limites de compute, como vCPUs, memória e recursos relacionados.'),
('7f100000-0000-4000-8000-000000000002','A imagem do sistema operacional instalada na VM.','Incorreta. O tamanho define uma combinação de capacidade e limites de compute, como vCPUs, memória e recursos relacionados.'),
('7f100000-0000-4000-8000-000000000003','A redundância aplicada ao disco de inicialização.','Incorreta. O tamanho define uma combinação de capacidade e limites de compute, como vCPUs, memória e recursos relacionados.'),
('7f100000-0000-4000-8000-000000000004','O segmento de rede ao qual a interface está conectada.','Incorreta. O tamanho define uma combinação de capacidade e limites de compute, como vCPUs, memória e recursos relacionados.'),
('7f100000-0000-4000-8000-000000000017','VM size, OS disk e NIC conectada a uma subnet da VNet.','Correta. A VM requer tamanho de compute, disco do sistema operacional e NIC conectada a uma subnet; um IP público não é necessário.'),
('7f100000-0000-4000-8000-000000000018','VM size, data disk e IP público, sem disco do sistema operacional.','Incorreta. A VM requer tamanho de compute, disco do sistema operacional e NIC conectada a uma subnet; um IP público não é necessário.'),
('7f100000-0000-4000-8000-000000000019','OS disk, IP público e NSG, sem interface de rede.','Incorreta. A VM requer tamanho de compute, disco do sistema operacional e NIC conectada a uma subnet; um IP público não é necessário.'),
('7f100000-0000-4000-8000-000000000020','NIC, data disk e IP público, sem capacidade de compute.','Incorreta. A VM requer tamanho de compute, disco do sistema operacional e NIC conectada a uma subnet; um IP público não é necessário.'),
('7f100000-0000-4000-8000-000000000038','RDP publica desktops para vários usuários; AVD acessa diretamente uma única VM.','Incorreta. AVD publica e gerencia desktops e aplicações para usuários; RDP fornece acesso remoto direto a uma máquina.'),
('7f100000-0000-4000-8000-000000000037','AVD publica e gerencia desktops e aplicações; RDP acessa diretamente uma máquina.','Correta. AVD publica e gerencia desktops e aplicações para usuários; RDP fornece acesso remoto direto a uma máquina.'),
('7f100000-0000-4000-8000-000000000039','AVD e RDP são nomes diferentes para a mesma camada de gerenciamento.','Incorreta. AVD publica e gerencia desktops e aplicações para usuários; RDP fornece acesso remoto direto a uma máquina.'),
('7f100000-0000-4000-8000-000000000040','AVD fornece conectividade híbrida; RDP gerencia pools de sessões.','Incorreta. AVD publica e gerencia desktops e aplicações para usuários; RDP fornece acesso remoto direto a uma máquina.'),
('7f100000-0000-4000-8000-000000000042','A aplicação, suas dependências e um sistema operacional convidado completo.','Incorreta. A imagem reúne a aplicação e suas dependências, sem incluir necessariamente um sistema operacional convidado completo.'),
('7f100000-0000-4000-8000-000000000043','O código-fonte, mas não bibliotecas ou runtime necessários à execução.','Incorreta. A imagem reúne a aplicação e suas dependências, sem incluir necessariamente um sistema operacional convidado completo.'),
('7f100000-0000-4000-8000-000000000041','A aplicação e as dependências necessárias à execução.','Correta. A imagem reúne a aplicação e suas dependências, sem incluir necessariamente um sistema operacional convidado completo.'),
('7f100000-0000-4000-8000-000000000044','A máquina física e as configurações de rede do datacenter.','Incorreta. A imagem reúne a aplicação e suas dependências, sem incluir necessariamente um sistema operacional convidado completo.'),
('7f100000-0000-4000-8000-000000000049','Azure Container Instances.','Correta. Azure Container Instances executa containers isolados sem que a equipe gerencie servidores ou um orquestrador.'),
('7f100000-0000-4000-8000-000000000050','Azure Kubernetes Service.','Incorreta. Azure Container Instances executa containers isolados sem que a equipe gerencie servidores ou um orquestrador.'),
('7f100000-0000-4000-8000-000000000051','Azure App Service com uma VM administrada pela equipe.','Incorreta. Azure Container Instances executa containers isolados sem que a equipe gerencie servidores ou um orquestrador.'),
('7f100000-0000-4000-8000-000000000052','Azure Virtual Machines em um Availability Set.','Incorreta. Azure Container Instances executa containers isolados sem que a equipe gerencie servidores ou um orquestrador.'),
('7f100000-0000-4000-8000-000000000057','Uma VM configurada separadamente em cada ambiente.','Incorreta. Uma imagem de container empacota a aplicação e as dependências para execução consistente em ambientes compatíveis.'),
('7f100000-0000-4000-8000-000000000059','Uma Function que recompila as dependências em cada execução.','Incorreta. Uma imagem de container empacota a aplicação e as dependências para execução consistente em ambientes compatíveis.'),
('7f100000-0000-4000-8000-000000000058','Uma imagem de container com a API, o runtime e as bibliotecas.','Correta. Uma imagem de container empacota a aplicação e as dependências para execução consistente em ambientes compatíveis.'),
('7f100000-0000-4000-8000-000000000060','Um Availability Set contendo as bibliotecas compartilhadas.','Incorreta. Uma imagem de container empacota a aplicação e as dependências para execução consistente em ambientes compatíveis.'),
('7f100000-0000-4000-8000-000000000073','Azure App Service com acesso administrativo ao Windows Server subjacente.','Incorreta. Uma máquina virtual oferece o controle do sistema operacional convidado exigido pelo cenário.'),
('7f100000-0000-4000-8000-000000000074','Azure Container Instances com permissão para alterar o host.','Incorreta. Uma máquina virtual oferece o controle do sistema operacional convidado exigido pelo cenário.'),
('7f100000-0000-4000-8000-000000000076','Azure Virtual Machines com administração do sistema operacional convidado.','Correta. Uma máquina virtual oferece o controle do sistema operacional convidado exigido pelo cenário.'),
('7f100000-0000-4000-8000-000000000075','Azure Functions com instalação persistente de componentes no host.','Incorreta. Uma máquina virtual oferece o controle do sistema operacional convidado exigido pelo cenário.'),
('7f100000-0000-4000-8000-000000000082','Aplicação e dependências empacotadas em uma imagem portátil.','Correta. Containers são adequados quando aplicação e dependências devem viajar juntas em uma imagem portátil.'),
('7f100000-0000-4000-8000-000000000081','Aplicação que precisa controlar diretamente o hardware do datacenter.','Incorreta. Containers são adequados quando aplicação e dependências devem viajar juntas em uma imagem portátil.'),
('7f100000-0000-4000-8000-000000000083','Processo que exige um sistema operacional convidado exclusivo.','Incorreta. Containers são adequados quando aplicação e dependências devem viajar juntas em uma imagem portátil.'),
('7f100000-0000-4000-8000-000000000084','Rotina que precisa apenas de execução orientada a eventos.','Incorreta. Containers são adequados quando aplicação e dependências devem viajar juntas em uma imagem portátil.'),
('7f100000-0000-4000-8000-000000000085','Azure Web Apps com acesso administrativo ao Windows Server.','Incorreta. Azure Virtual Machines oferece acesso administrativo ao sistema operacional convidado.'),
('7f100000-0000-4000-8000-000000000087','Azure Virtual Machines.','Correta. Azure Virtual Machines oferece acesso administrativo ao sistema operacional convidado.'),
('7f100000-0000-4000-8000-000000000086','Azure Container Instances com alteração direta do host.','Incorreta. Azure Virtual Machines oferece acesso administrativo ao sistema operacional convidado.'),
('7f100000-0000-4000-8000-000000000088','Azure Functions com instalação de componentes no sistema operacional.','Incorreta. Azure Virtual Machines oferece acesso administrativo ao sistema operacional convidado.'),
('7f100000-0000-4000-8000-000000000089','Web Apps e containers oferecem o mesmo controle; VMs eliminam a gestão do sistema operacional.','Incorreta. Web Apps reduz tarefas de plataforma; containers controlam o pacote da aplicação; VMs oferecem mais controle do sistema operacional.'),
('7f100000-0000-4000-8000-000000000090','Web Apps controla o sistema operacional; container controla o datacenter; VM controla apenas o código.','Incorreta. Web Apps reduz tarefas de plataforma; containers controlam o pacote da aplicação; VMs oferecem mais controle do sistema operacional.'),
('7f100000-0000-4000-8000-000000000092','Web Apps reduz tarefas de plataforma; container controla o pacote; VM oferece mais controle do sistema operacional.','Correta. Web Apps reduz tarefas de plataforma; containers controlam o pacote da aplicação; VMs oferecem mais controle do sistema operacional.'),
('7f100000-0000-4000-8000-000000000091','Web Apps exige mais gestão do sistema operacional que VM; container não inclui dependências.','Incorreta. Web Apps reduz tarefas de plataforma; containers controlam o pacote da aplicação; VMs oferecem mais controle do sistema operacional.'),
('7f100000-0000-4000-8000-000000000110','Três grupos de recursos, pois cada grupo cria um segmento de rede.','Incorreta. Uma VNet pode conter subnets distintas para organizar cada camada e aplicar controles de rede.'),
('7f100000-0000-4000-8000-000000000111','Três zonas de disponibilidade, pois cada zona substitui uma subnet.','Incorreta. Uma VNet pode conter subnets distintas para organizar cada camada e aplicar controles de rede.'),
('7f100000-0000-4000-8000-000000000112','Três VNets com o mesmo espaço de endereços e sem conectividade entre elas.','Incorreta. Uma VNet pode conter subnets distintas para organizar cada camada e aplicar controles de rede.'),
('7f100000-0000-4000-8000-000000000109','Uma VNet com subnets separadas para frontend, API e dados.','Correta. Uma VNet pode conter subnets distintas para organizar cada camada e aplicar controles de rede.'),
('7f100000-0000-4000-8000-000000000113','Eles podem se comunicar de forma privada, sujeitos às regras, rotas e configurações.','Correta. A VNet fornece conectividade privada, mas regras de segurança, rotas e configurações dos recursos determinam o tráfego efetivo.'),
('7f100000-0000-4000-8000-000000000114','Eles podem se comunicar somente se estiverem no mesmo grupo de recursos.','Incorreta. A VNet fornece conectividade privada, mas regras de segurança, rotas e configurações dos recursos determinam o tráfego efetivo.'),
('7f100000-0000-4000-8000-000000000115','Eles precisam de VNet Peering porque cada subnet funciona como uma VNet.','Incorreta. A VNet fornece conectividade privada, mas regras de segurança, rotas e configurações dos recursos determinam o tráfego efetivo.'),
('7f100000-0000-4000-8000-000000000116','Eles precisam estar na mesma zona de disponibilidade para usar endereços privados.','Incorreta. A VNet fornece conectividade privada, mas regras de segurança, rotas e configurações dos recursos determinam o tráfego efetivo.'),
('7f100000-0000-4000-8000-000000000154','Confirmar apenas o status do peering, pois ele ignora regras e rotas.','Incorreta. Peering fornece conectividade privada, mas regras de segurança, rotas e configurações dos recursos ainda podem bloquear o tráfego.'),
('7f100000-0000-4000-8000-000000000153','Verificar regras de segurança, rotas e configurações dos recursos nas duas VNets.','Correta. Peering fornece conectividade privada, mas regras de segurança, rotas e configurações dos recursos ainda podem bloquear o tráfego.'),
('7f100000-0000-4000-8000-000000000155','Mover as VNets para o mesmo grupo de recursos para liberar o tráfego.','Incorreta. Peering fornece conectividade privada, mas regras de segurança, rotas e configurações dos recursos ainda podem bloquear o tráfego.'),
('7f100000-0000-4000-8000-000000000156','Substituir o peering por DNS público para autorizar a comunicação privada.','Incorreta. Peering fornece conectividade privada, mas regras de segurança, rotas e configurações dos recursos ainda podem bloquear o tráfego.'),
('7f100000-0000-4000-8000-000000000162','Site-to-Site conecta um dispositivo; Point-to-Site conecta uma rede inteira.','Incorreta. Site-to-Site conecta uma rede on-premises à VNet; Point-to-Site conecta um dispositivo cliente à VNet.'),
('7f100000-0000-4000-8000-000000000163','Site-to-Site usa ExpressRoute; Point-to-Site usa VNet Peering.','Incorreta. Site-to-Site conecta uma rede on-premises à VNet; Point-to-Site conecta um dispositivo cliente à VNet.'),
('7f100000-0000-4000-8000-000000000164','Site-to-Site e Point-to-Site conectam duas redes on-premises entre si.','Incorreta. Site-to-Site conecta uma rede on-premises à VNet; Point-to-Site conecta um dispositivo cliente à VNet.'),
('7f100000-0000-4000-8000-000000000161','Site-to-Site conecta uma rede; Point-to-Site conecta um dispositivo cliente.','Correta. Site-to-Site conecta uma rede on-premises à VNet; Point-to-Site conecta um dispositivo cliente à VNet.'),
('7f100000-0000-4000-8000-000000000174','ExpressRoute para a filial e VPN Gateway para o datacenter principal.','Incorreta. VPN Gateway atende o túnel pela Internet; ExpressRoute fornece conectividade privada por meio de um provedor.'),
('7f100000-0000-4000-8000-000000000175','VNet Peering para os dois locais, sem conectividade híbrida adicional.','Incorreta. VPN Gateway atende o túnel pela Internet; ExpressRoute fornece conectividade privada por meio de um provedor.'),
('7f100000-0000-4000-8000-000000000173','VPN Gateway para a filial e ExpressRoute para o datacenter principal.','Correta. VPN Gateway atende o túnel pela Internet; ExpressRoute fornece conectividade privada por meio de um provedor.'),
('7f100000-0000-4000-8000-000000000176','Point-to-Site para conectar diretamente as duas redes locais.','Incorreta. VPN Gateway atende o túnel pela Internet; ExpressRoute fornece conectividade privada por meio de um provedor.'),
('7f100000-0000-4000-8000-000000000178','Uma interface com IP privado obtido de uma subnet da VNet.','Incorreta. Ele é alcançável por conectividade pública, mas autenticação, firewall e regras de rede ainda podem restringir o acesso.'),
('7f100000-0000-4000-8000-000000000179','Um caminho público que dispensa autenticação quando o serviço tem firewall.','Incorreta. Ele é alcançável por conectividade pública, mas autenticação, firewall e regras de rede ainda podem restringir o acesso.'),
('7f100000-0000-4000-8000-000000000180','Uma conexão dedicada por provedor que não usa a Internet pública.','Incorreta. Ele é alcançável por conectividade pública, mas autenticação, firewall e regras de rede ainda podem restringir o acesso.'),
('7f100000-0000-4000-8000-000000000177','Um caminho público cujo acesso ainda pode ser limitado por controles do serviço.','Correta. Ele é alcançável por conectividade pública, mas autenticação, firewall e regras de rede ainda podem restringir o acesso.'),
('7f100000-0000-4000-8000-000000000194','Sim; o endpoint privado desabilita o endpoint público em todos os serviços.','Incorreta. Não. Acesso público e privado podem coexistir; o acesso público deve ser configurado separadamente conforme o serviço.'),
('7f100000-0000-4000-8000-000000000195','Sim; o DNS privado impede tecnicamente qualquer acesso pelo nome público.','Incorreta. Não. Acesso público e privado podem coexistir; o acesso público deve ser configurado separadamente conforme o serviço.'),
('7f100000-0000-4000-8000-000000000196','Não; mas o endpoint privado altera o acesso público para somente leitura.','Incorreta. Não. Acesso público e privado podem coexistir; o acesso público deve ser configurado separadamente conforme o serviço.'),
('7f100000-0000-4000-8000-000000000193','Não; o acesso público deve ser configurado separadamente conforme o serviço.','Correta. Não. Acesso público e privado podem coexistir; o acesso público deve ser configurado separadamente conforme o serviço.'),
('7f100000-0000-4000-8000-000000000209','Pode disponibilizar Blob, Files, Queue e Table.','Correta. Uma conta GPv2 pode disponibilizar Blob, Files, Queue e Table e atende a muitos cenários gerais de armazenamento.'),
('7f100000-0000-4000-8000-000000000210','Disponibiliza somente Blob e exige contas separadas para Files, Queue e Table.','Incorreta. Uma conta GPv2 pode disponibilizar Blob, Files, Queue e Table e atende a muitos cenários gerais de armazenamento.'),
('7f100000-0000-4000-8000-000000000211','Representa um disco gerenciado que pode ser anexado a várias VMs.','Incorreta. Uma conta GPv2 pode disponibilizar Blob, Files, Queue e Table e atende a muitos cenários gerais de armazenamento.'),
('7f100000-0000-4000-8000-000000000212','Fornece apenas compartilhamentos de arquivos por SMB e NFS.','Incorreta. Uma conta GPv2 pode disponibilizar Blob, Files, Queue e Table e atende a muitos cenários gerais de armazenamento.');

update public.question_options option
set option_text = seed.option_text,
    explanation = seed.explanation,
    updated_at = now()
from az900_quality_option_seed_256_383 seed
where option.id = seed.id;


-- Remediation seed for audited AZ-900 questions 384-511.
-- Intentionally contains no transaction wrapper, guards, or remote execution.

create temporary table az900_quality_question_seed (
  id uuid primary key,
  question_text text not null,
  explanation text not null
) on commit drop;

insert into az900_quality_question_seed (id, question_text, explanation) values
('68000000-0000-4000-8000-000000000062','Um conjunto de arquivos é lido cerca de uma vez por mês, deve permanecer online e será mantido por 60 dias. Qual access tier atende melhor ao padrão?','Cool é indicado para dados acessados com pouca frequência que precisam permanecer online. A retenção de 60 dias supera o período mínimo de 30 dias do Cool e não alcança os 90 dias mínimos do Cold.'),
('68000000-0000-4000-8000-000000000069','Uma storage account usa GZRS. Durante uma falha regional, qual consideração deve fazer parte do plano de recuperação?','GZRS replica dados de forma assíncrona para outra região. A recuperação pode exigir failover da conta e preparação da aplicação; acesso de leitura à região secundária antes do failover é uma capacidade de RA-GZRS.'),
('68000000-0000-4000-8000-000000000079','Uma migração precisa avaliar máquinas virtuais e transferir 300 TB de dados quando a conexão de rede não comporta o envio no prazo. Qual combinação atende aos dois requisitos?','Azure Migrate oferece descoberta, avaliação e planejamento dos workloads. Azure Data Box permite transportar fisicamente grandes volumes de dados quando a transferência pela rede é inviável.'),
('68000000-0000-4000-8000-000000000080','Qual capacidade caracteriza o Microsoft Entra ID?','Microsoft Entra ID é o serviço de gerenciamento de identidades e acesso baseado em nuvem. Ele oferece identidades, autenticação e recursos que apoiam autorização, mas não substitui sozinho serviços de domínio tradicionais.'),
('68000000-0000-4000-8000-000000000081','Qual relação entre um Microsoft Entra tenant e uma Azure Subscription está correta?','O tenant é o diretório que representa identidades e a organização. A subscription organiza recursos, limites e cobrança e mantém uma relação de confiança com um tenant.'),
('68000000-0000-4000-8000-000000000082','Uma aplicação SaaS deve autenticar colaboradores com as identidades cloud corporativas. Qual serviço atende diretamente ao requisito?','Microsoft Entra ID fornece identidade e autenticação cloud para aplicações modernas. Domain Services atende dependências tradicionais de domínio; External ID trata colaboração e identidades externas.'),
('68000000-0000-4000-8000-000000000083','Uma aplicação legada no Azure exige LDAP, Kerberos, NTLM e domain join, mas a empresa não quer administrar domain controllers. Qual serviço é mais adequado?','Microsoft Entra Domain Services fornece recursos tradicionais de domínio como serviço gerenciado, evitando que a empresa implante e mantenha domain controllers próprios.'),
('68000000-0000-4000-8000-000000000084','Uma empresa usa aplicações modernas e mantém uma aplicação legada que exige Group Policy e NTLM. Qual desenho atende aos dois tipos de requisito?','Microsoft Entra ID atende identidades e autenticação modernas, enquanto Microsoft Entra Domain Services pode fornecer compatibilidade com recursos tradicionais de domínio para a aplicação legada.'),
('68000000-0000-4000-8000-000000000085','Uma organização quer que o usuário autenticado acesse várias aplicações integradas sem repetir o login em cada uma. Qual capacidade atende ao objetivo?','Single Sign-On reutiliza uma autenticação aceita entre aplicações integradas. Ele reduz prompts de login, mas não elimina autenticação, autorização ou a possibilidade de exigir MFA.'),
('68000000-0000-4000-8000-000000000086','Um funcionário usa a mesma senha, mas precisa digitá-la separadamente em três aplicações. Como esse comportamento deve ser classificado?','O cenário representa reutilização de credencial em autenticações independentes. SSO exige integração para que uma autenticação seja aceita por várias aplicações, sem novos prompts em cada uma.'),
('68000000-0000-4000-8000-000000000088','Qual comparação descreve corretamente Single Sign-On e multifactor authentication?','SSO reduz autenticações repetidas entre aplicações integradas. MFA aumenta a garantia da identidade ao exigir fatores independentes; as duas capacidades podem ser combinadas.'),
('68000000-0000-4000-8000-000000000089','Uma empresa implementa SSO em três aplicações, mas cada usuário deve continuar acessando apenas os recursos autorizados. Qual comportamento é esperado?','SSO reduz prompts de autenticação. A autorização continua sendo avaliada pelas aplicações ou pelos controles associados, portanto uma sessão autenticada não concede acesso irrestrito.'),
('68000000-0000-4000-8000-000000000091','Qual método pode autenticar um usuário sem usar uma senha tradicional como credencial principal?','Uma passkey compatível é um método passwordless. Código enviado após uma senha e perguntas de segurança continuam dependendo de conhecimento ou de uma senha tradicional.'),
('68000000-0000-4000-8000-000000000093','Uma empresa quer retirar a senha tradicional do processo de entrada, mas continuar verificando a identidade do usuário. Qual abordagem deve adotar?','Passwordless Authentication usa métodos como passkeys, Windows Hello for Business ou o modo passwordless do Microsoft Authenticator para verificar identidade sem senha tradicional.'),
('68000000-0000-4000-8000-000000000094','Uma organização precisa reduzir logins repetidos, exigir fatores independentes e dispensar a senha tradicional. Como essas necessidades podem ser atendidas?','SSO, MFA e Passwordless Authentication tratam objetivos diferentes e podem ser combinados quando a implementação e os métodos escolhidos oferecem suporte.'),
('68000000-0000-4000-8000-000000000095','Uma empresa quer permitir que parceiros acessem aplicações específicas usando identidades externas autorizadas. Qual capacidade do Microsoft Entra atende ao cenário B2B?','Microsoft Entra External ID oferece colaboração B2B com usuários externos. A organização de destino controla o acesso concedido sem transformar o convidado em usuário interno ou administrador.'),
('68000000-0000-4000-8000-000000000097','Uma consultora da Fabrikam deve acessar um aplicativo da Contoso com sua identidade de origem, sem receber uma conta interna comum. Qual recurso é mais adequado?','Microsoft Entra External ID com colaboração B2B permite que a identidade externa seja representada como convidada e receba somente o acesso autorizado no resource tenant.'),
('68000000-0000-4000-8000-000000000098','Qual afirmação descreve corretamente um guest user no Microsoft Entra ID?','Um guest user representa uma identidade externa convidada para colaboração. Sua autenticação e seu acesso seguem a configuração aplicável, e o convite não concede privilégios administrativos automaticamente.'),
('68000000-0000-4000-8000-000000000099','Fabrikam autentica sua consultora; Contoso hospeda o aplicativo e decide o acesso concedido. Como os tenants são classificados?','Fabrikam é o home tenant da identidade. Contoso é o resource tenant que possui o aplicativo e controla o acesso da convidada ao recurso.'),
('68000000-0000-4000-8000-000000000102','Uma organização quer exigir MFA somente quando sinais definidos, como localização ou risco, atenderem à policy. Qual recurso decide quando aplicar o controle?','Conditional Access avalia sinais e políticas para permitir, bloquear ou exigir controles, como MFA. MFA é o controle aplicado; Conditional Access determina quando ele será exigido.'),
('68000000-0000-4000-8000-000000000103','Uma policy deve bloquear o acesso quando a combinação de localização e estado do dispositivo não atender aos requisitos. Qual capacidade avalia esses sinais?','Conditional Access combina sinais de identidade, localização e dispositivo com políticas para tomar decisões de acesso. RBAC controla ações sobre recursos, não as condições de sign-in.'),
('68000000-0000-4000-8000-000000000106','Quais três elementos precisam ser combinados para criar uma Azure role assignment?','Uma role assignment associa um security principal a uma role definition em determinado scope. A combinação define quem recebe quais permissões e onde elas se aplicam.'),
('68000000-0000-4000-8000-000000000107','Uma managed identity deve ler dados de apenas uma storage account. Qual configuração aplica Azure RBAC com menor scope?','Uma role assignment associa a managed identity à role adequada no scope da storage account. Conditional Access e MFA não substituem uma role assignment para acesso de workload a recursos Azure.'),
('68000000-0000-4000-8000-000000000112','Uma identidade recebe somente leitura em um Resource Group e apenas durante o período necessário. Qual princípio de Zero Trust é aplicado diretamente?','Least privilege limita permissões, scope e duração ao necessário. Verificar explicitamente e assumir violação também são princípios de Zero Trust, mas não descrevem tão diretamente essa restrição de privilégio.'),
('68000000-0000-4000-8000-000000000113','Uma arquitetura verifica cada solicitação, limita privilégios e mantém controles nas camadas de identidade, rede, aplicação e dados. Qual interpretação é mais completa?','O cenário combina princípios de Zero Trust, como verificar explicitamente e usar menor privilégio, com Defense in Depth, representada por controles em várias camadas.'),
('68000000-0000-4000-8000-000000000115','No Microsoft Defender for Cloud, um administrador quer selecionar um item que descreva uma configuração específica a corrigir e a ação sugerida. Qual recurso deve abrir?','Security recommendations apresentam achados individuais e ações de correção. Secure score resume a postura em uma pontuação e pode refletir o impacto das recomendações, mas não é a orientação individual solicitada.'),
('68000000-0000-4000-8000-000000000117','Uma organização quer detectar ameaças contra máquinas virtuais e outros workloads cloud conforme os planos habilitados. Qual capacidade do Defender for Cloud atende ao objetivo?','Workload protection fornece capacidades de proteção e detecção de ameaças para workloads conforme os planos habilitados. Secure score e recomendações concentram-se na avaliação e melhoria da postura.'),
('68000000-0000-4000-8000-000000000118','O Defender for Cloud mostra uma recomendação para corrigir uma configuração e um alerta sobre atividade suspeita em uma VM. Como classificar os resultados?','A recomendação contribui para security posture management. O alerta de ameaça pertence à workload protection, que identifica e responde a ameaças nos workloads.'),
('68000000-0000-4000-8000-000000000119','Uma equipe está desenhando uma solução Azure e precisa estimar seu custo mensal antes de criar os recursos. Qual ferramenta deve usar?','Azure Pricing Calculator estima o custo de uma configuração planejada com base nos serviços, regiões, tamanhos e uso informados. Ela não implanta recursos nem analisa a fatura já emitida.'),
('68000000-0000-4000-8000-000000000121','A estimativa de uma VM muda quando a equipe seleciona outra Region e outro size, mantendo o mesmo tipo de serviço. O que explica a diferença?','Region e configuração, incluindo o size da VM, são entradas de preço. Por isso duas estimativas do mesmo tipo de serviço podem produzir valores diferentes.'),
('68000000-0000-4000-8000-000000000123','O valor calculado para uma arquitetura foi diferente da fatura após a implantação. Qual explicação deve ser verificada primeiro?','A Pricing Calculator produz uma estimativa com base nas hipóteses informadas. Uso real, configuração final, transferência de dados, descontos e itens omitidos podem mudar a cobrança.'),
('68000000-0000-4000-8000-000000000126','Em quais scopes Azure Tags podem ser aplicadas diretamente no contexto abordado pelo AZ-900?','Tags podem ser aplicadas diretamente a resources, Resource Groups e Subscriptions. Elas não são usadas para marcar usuários do Entra ID nem funcionam como budgets ou role assignments.'),
('68000000-0000-4000-8000-000000000127','Um Resource Group recebeu a Tag Environment=Production. Nenhuma policy adicional foi configurada. O que ocorre com as VMs existentes no grupo?','Tags aplicadas ao Resource Group não são herdadas automaticamente pelos recursos filhos. Uma policy ou processo separado pode adicionar ou impor tags, mas isso não decorre da tag sozinha.'),
('68000000-0000-4000-8000-000000000128','Uma VM recebeu a Tag Owner=BackendTeam. A equipe concluiu que o valor concede acesso administrativo e impede exclusão. Qual análise está correta?','Tags são metadados de organização. Azure RBAC controla autorização e Resource Locks protegem contra operações administrativas específicas; o valor de uma tag não substitui esses controles.'),
('68000000-0000-4000-8000-000000000131','Qual associação entre recursos do Microsoft Purview está correta?','O Data Map captura e mapeia metadados de fontes de dados. O Unified Catalog oferece uma experiência pesquisável para encontrar, compreender e usar dados governados.'),
('68000000-0000-4000-8000-000000000132','Uma equipe quer identificar recursos Azure que usam regiões fora de uma lista aprovada. Qual serviço deve avaliar esse requisito?','Azure Policy avalia configurações de recursos em relação a regras e mostra compliance. Microsoft Purview concentra-se na descoberta, catalogação, classificação e governança de dados.'),
('68000000-0000-4000-8000-000000000133','Uma empresa precisa governar dados distribuídos entre Azure, ambiente local e outra nuvem, além de receber recomendações de postura para VMs. Qual associação atende aos requisitos?','Microsoft Purview ajuda a descobrir, classificar e governar o patrimônio de dados. Microsoft Defender for Cloud avalia a postura e protege workloads como máquinas virtuais.'),
('68000000-0000-4000-8000-000000000136','Um desenvolvedor tem permissão RBAC para criar VMs, mas Azure Policy nega uma configuração fora do padrão. Como interpretar o resultado?','RBAC autoriza a identidade a executar uma ação no scope. Azure Policy avalia o estado solicitado e pode negar uma configuração não conforme; os controles são complementares.'),
('68000000-0000-4000-8000-000000000137','Uma empresa quer exigir a Tag Environment em novos recursos. Qual combinação de papéis está correta?','A tag é o metadado aplicado ao recurso. Azure Policy pode avaliar a presença ou o valor da tag e usar effects apropriados para impor o padrão.'),
('68000000-0000-4000-8000-000000000138','Uma regra deve avaliar recursos em várias Subscriptions de um Management Group e bloquear novas configurações não conformes. Qual desenho é adequado?','Uma policy definition descreve a regra, a assignment no Management Group define o alcance e o effect Deny pode impedir a criação ou alteração não conforme nos scopes descendentes.'),
('68000000-0000-4000-8000-000000000141','Um Resource Group possui um Resource Lock do tipo CanNotDelete. Como o lock afeta os recursos filhos?','Locks aplicados em um scope superior são herdados por recursos filhos. CanNotDelete permite alterações autorizadas, mas bloqueia exclusões até que o lock aplicável seja removido.'),
('68000000-0000-4000-8000-000000000142','Um usuário com a role Owner tenta excluir um recurso protegido por CanNotDelete. O que precisa ocorrer para a exclusão ser aceita?','A permissão RBAC para excluir não ignora o lock. Uma identidade com a permissão adequada precisa remover o lock antes que a exclusão do recurso possa ocorrer.'),
('68000000-0000-4000-8000-000000000143','Uma empresa aplica ReadOnly a recursos críticos e decide retirar backup e controles RBAC. Qual avaliação está correta?','Resource Locks, Azure RBAC e backup atendem riscos distintos. ReadOnly restringe operações administrativas, RBAC controla autorização e backup oferece uma forma de recuperação de dados ou estado.'),
('68000000-0000-4000-8000-000000000145','Um administrador precisa explorar visualmente o estado e as propriedades de uma VM em uma tarefa pontual. Qual ferramenta é mais adequada?','Azure portal é uma interface gráfica apropriada para exploração visual e tarefas pontuais. CLI e PowerShell tendem a ser mais adequados quando a prioridade é repetição e automação.'),
('68000000-0000-4000-8000-000000000146','Uma equipe precisa aplicar a mesma operação a dezenas de recursos com resultado repetível. Qual abordagem é mais adequada?','Azure CLI, Azure PowerShell ou outro método de automação reduz repetição manual e favorece consistência. O portal continua válido, mas é menos eficiente para esse requisito em escala.'),
('68000000-0000-4000-8000-000000000148','Uma equipe afirma que recursos Azure só podem ser administrados pelo Azure portal. Qual evidência refuta a afirmação?','Azure CLI, Azure PowerShell, Cloud Shell, APIs e Infrastructure as Code também podem administrar recursos conforme identidade e permissões aplicáveis.'),
('68000000-0000-4000-8000-000000000150','Qual característica distingue Azure PowerShell de Azure CLI?','Azure PowerShell usa módulos Az, cmdlets e objetos no ecossistema PowerShell. Azure CLI usa comandos az e geralmente produz saída textual ou estruturada; ambas são multiplataforma.'),
('68000000-0000-4000-8000-000000000151','Uma equipe já usa pipelines PowerShell que processam objetos e quer automatizar a administração do Azure. Qual ferramenta se integra melhor ao fluxo existente?','Azure PowerShell oferece cmdlets Az e objetos que se integram ao pipeline PowerShell. Azure CLI também automatiza Azure, mas não corresponde tão diretamente ao requisito descrito.'),
('68000000-0000-4000-8000-000000000152','Um administrador executa Get-AzResourceGroup no Cloud Shell. Qual alternativa identifica corretamente ferramenta e ambiente?','Azure PowerShell é a ferramenta que fornece o cmdlet Get-AzResourceGroup. Cloud Shell é o ambiente de terminal hospedado no navegador onde a ferramenta pode ser executada.'),
('68000000-0000-4000-8000-000000000153','Duas equipes automatizam Azure: uma prefere comandos az e outra trabalha com cmdlets e objetos PowerShell. Qual combinação respeita as preferências?','Azure CLI atende ao padrão de comandos az; Azure PowerShell atende a cmdlets e objetos. As duas ferramentas são multiplataforma e suportam automação.'),
('68000000-0000-4000-8000-000000000154','Qual prática representa Infrastructure as Code?','Infrastructure as Code define e gerencia infraestrutura por arquivos declarativos ou código versionável, tornando deployments repetíveis e reduzindo configuração manual inconsistente.'),
('68000000-0000-4000-8000-000000000155','Em Infrastructure as Code, o que caracteriza uma abordagem declarativa?','Uma definição declarativa descreve o estado desejado. O mecanismo compara e executa as operações necessárias, em vez de exigir que o autor liste cada passo operacional.'),
('68000000-0000-4000-8000-000000000156','Uma empresa precisa reproduzir a infraestrutura em desenvolvimento, teste e produção, variando apenas Region e SKU. Qual abordagem atende melhor?','Uma definição IaC comum com parâmetros por ambiente oferece repetibilidade e permite variações controladas sem manter procedimentos manuais independentes.'),
('68000000-0000-4000-8000-000000000158','Uma equipe automatizou uma sequência ordenada de comandos e concluiu que toda automação é declarativa. Qual distinção corrige a conclusão?','Automação pode ser imperativa e descrever passos. Uma abordagem declarativa descreve principalmente o estado desejado; portanto automação e declaratividade não são sinônimos.'),
('68000000-0000-4000-8000-000000000159','Qual serviço recebe solicitações de gerenciamento feitas por Azure portal, Azure CLI, Azure PowerShell e APIs?','Azure Resource Manager é a camada comum de gerenciamento e deployment. As ferramentas funcionam como clientes e os Resource Providers oferecem tipos e operações dos serviços.'),
('68000000-0000-4000-8000-000000000160','Qual descrição corresponde a um ARM Template?','Um ARM Template é um arquivo JSON declarativo que descreve recursos e configurações para deployment por Azure Resource Manager.'),
('68000000-0000-4000-8000-000000000162','Qual função um Azure Resource Provider exerce no modelo do Azure Resource Manager?','Um Resource Provider disponibiliza tipos de recurso e operações de um serviço, como Microsoft.Compute/virtualMachines, para que Azure Resource Manager possa gerenciá-los.'),
('68000000-0000-4000-8000-000000000163','Uma VM é criada pelo Azure portal e outra pela Azure CLI. O que as duas operações têm em comum?','Portal e CLI são interfaces diferentes, mas ambas enviam solicitações pela camada Azure Resource Manager e dependem dos Resource Providers correspondentes.'),
('68000000-0000-4000-8000-000000000165','Qual alternativa diferencia Azure Resource Manager de um ARM Template?','Azure Resource Manager é a camada de gerenciamento que processa solicitações e deployments. Um ARM Template é um arquivo JSON declarativo que pode ser enviado a essa camada.'),
('68000000-0000-4000-8000-000000000167','Uma VM foi criada visualmente no Azure portal. Qual papel Azure Resource Manager exerceu nessa operação?','O portal atuou como interface cliente e enviou a solicitação pela camada Azure Resource Manager. A criação visual não substitui o serviço de gerenciamento.'),
('68000000-0000-4000-8000-000000000168','Uma equipe usa Bicep para novos deployments. Por que ainda é útil reconhecer ARM Templates no contexto do AZ-900?','Bicep e ARM Templates são formas declarativas que usam Azure Resource Manager. ARM Templates usam JSON e continuam sendo um conceito previsto no objetivo de Infrastructure as Code.'),
('68000000-0000-4000-8000-000000000176','Uma equipe quer comparar a porcentagem de CPU de uma VM ao longo das últimas 24 horas. Qual recurso atende diretamente?','Azure Monitor Metrics armazena e apresenta valores numéricos em séries temporais, como porcentagem de CPU. Logs são mais adequados para eventos e registros detalhados.'),
('68000000-0000-4000-8000-000000000180','Qual alternativa diferencia logs de metrics no Azure Monitor?','Logs registram eventos e detalhes que podem ser consultados. Metrics representam valores numéricos em séries temporais; as duas fontes podem ser usadas em monitoramento e alertas.'),
('68000000-0000-4000-8000-000000000182','Uma equipe precisa consultar dados de log em um workspace do Log Analytics. Qual associação com KQL está correta?','Kusto Query Language é usada para consultar e analisar dados de log no Log Analytics. No nível AZ-900, basta reconhecer essa finalidade, sem memorizar sintaxe avançada.'),
('68000000-0000-4000-8000-000000000183','Uma equipe trata Log Analytics como sinônimo de toda a plataforma Azure Monitor. Qual distinção deve aplicar?','Azure Monitor é a plataforma ampla de observabilidade. Log Analytics é a experiência usada para consultar e analisar logs dentro desse ecossistema.'),
('68000000-0000-4000-8000-000000000184','Uma equipe quer reagir quando um sinal de monitoramento atender a uma condição definida. Qual capacidade deve configurar?','Azure Monitor Alerts avalia sinais segundo condições e pode acionar notificações ou ações. A regra de alerta não é o próprio sinal nem uma recomendação do Advisor.'),
('68000000-0000-4000-8000-000000000185','Qual sequência descreve o fluxo conceitual de um Azure Monitor alert?','Uma regra avalia uma condição sobre um sinal. Quando a condição é atendida, o alerta pode disparar uma notificação ou ação configurada.'),
('68000000-0000-4000-8000-000000000187','Qual alternativa diferencia uma metric de um Azure Monitor alert?','Uma metric é um sinal numérico em série temporal. Um alert avalia uma condição sobre sinais e pode iniciar notificações ou ações quando a condição é atendida.'),
('68000000-0000-4000-8000-000000000188','Uma equipe coleta metrics e logs no Azure Monitor, mas ainda não configurou regras de alerta. Qual comportamento deve esperar?','A coleta de telemetria não gera por si só uma notificação para todo dado. É necessário configurar uma regra que avalie sinais, condições e ações apropriadas.' );

update public.questions question
set question_text = seed.question_text,
    explanation = seed.explanation
from az900_quality_question_seed seed
where question.id = seed.id;

create temporary table az900_quality_option_seed (
  id uuid primary key,
  option_text text not null,
  explanation text not null
) on commit drop;

insert into az900_quality_option_seed (id, option_text, explanation) values
('7f100000-0000-4000-8000-000000000265','Cool.','Correta. O acesso mensal, a disponibilidade online e a retenção de 60 dias correspondem ao Cool.'),
('7f100000-0000-4000-8000-000000000266','Hot.','Hot mantém acesso imediato, mas é otimizado para dados acessados com frequência e tende a ter maior custo de armazenamento.'),
('7f100000-0000-4000-8000-000000000267','Cold.','Cold mantém os dados online, mas sua retenção mínima de 90 dias não combina com a exclusão prevista após 60 dias.'),
('7f100000-0000-4000-8000-000000000268','Archive.','Archive é adequado para retenção offline e exige reidratação antes da leitura, contrariando o acesso imediato.'),
('7f100000-0000-4000-8000-000000000293','Preparar a aplicação e considerar o failover da conta, pois a replicação entre regiões é assíncrona.','Correta. GZRS oferece redundância geográfica, mas a recuperação da aplicação e o failover precisam ser planejados.'),
('7f100000-0000-4000-8000-000000000294','Direcionar gravações para a região secundária assim que a principal falhar, sem realizar failover.','A região secundária não recebe gravações normais antes do failover da conta.'),
('7f100000-0000-4000-8000-000000000295','Tratar a cópia secundária como síncrona e assumir objetivo de perda de dados igual a zero.','A replicação geográfica é assíncrona, portanto dados recentes podem ainda não ter alcançado a região secundária.'),
('7f100000-0000-4000-8000-000000000296','Consultar a região secundária antes do failover usando o endpoint de leitura padrão do GZRS.','Leitura da secundária antes do failover requer RA-GZRS, não apenas GZRS.'),
('7f100000-0000-4000-8000-000000000333','Azure Migrate para avaliar as VMs e Azure Data Box para transportar os dados.','Correta. Cada serviço atende a um requisito distinto do cenário.'),
('7f100000-0000-4000-8000-000000000334','Azure Data Box para avaliar as VMs e Azure Migrate para transportar os dados.','As finalidades estão invertidas: Data Box move dados e Azure Migrate avalia workloads.'),
('7f100000-0000-4000-8000-000000000335','Azure Migrate para avaliar as VMs e Azure Storage Mover para transportar o dispositivo físico.','Storage Mover coordena migração de arquivos pela rede; não é o dispositivo de transporte offline solicitado.'),
('7f100000-0000-4000-8000-000000000336','Azure Advisor para avaliar as VMs e Azure Data Box para transportar os dados.','Advisor fornece recomendações sobre recursos existentes, mas não substitui a avaliação de migração do Azure Migrate.'),
('7f160000-0000-4000-8000-000000000001','Gerenciar identidades e acesso para aplicações e recursos cloud.','Correta. Essa é a função central do Microsoft Entra ID.'),
('7f160000-0000-4000-8000-000000000002','Fornecer LDAP e domain join gerenciados para aplicações legadas.','Essa função corresponde ao Microsoft Entra Domain Services.'),
('7f160000-0000-4000-8000-000000000003','Definir permissões de gerenciamento em scopes de recursos Azure.','Azure RBAC define permissões em scopes; ele usa identidades, mas não é o diretório de identidades.'),
('7f160000-0000-4000-8000-000000000004','Avaliar sinais de sign-in e aplicar controles condicionais.','Conditional Access usa identidades do Entra ID, mas é uma capacidade de decisão de acesso, não a definição do serviço inteiro.'),
('7f160000-0000-4000-8000-000000000005','O tenant contém identidades; a subscription organiza recursos e cobrança e confia em um tenant.','Correta. Os contêineres possuem finalidades distintas e relacionadas.'),
('7f160000-0000-4000-8000-000000000006','O tenant organiza cobrança; a subscription funciona como diretório principal de identidades.','A alternativa inverte as finalidades dos dois conceitos.'),
('7f160000-0000-4000-8000-000000000007','O tenant e a subscription são o mesmo limite administrativo, com nomes diferentes.','Tenant e subscription são contêineres distintos, embora mantenham uma relação.'),
('7f160000-0000-4000-8000-000000000008','A subscription pode confiar em vários tenants ao mesmo tempo para seu diretório principal.','Uma subscription mantém relação de confiança com um único tenant por vez.'),
('7f160000-0000-4000-8000-000000000009','Microsoft Entra ID.','Correta. O serviço atende identidade e autenticação cloud de colaboradores.'),
('7f160000-0000-4000-8000-000000000010','Microsoft Entra Domain Services.','Domain Services é indicado quando a aplicação exige recursos tradicionais como LDAP, Kerberos ou domain join.'),
('7f160000-0000-4000-8000-000000000011','Microsoft Entra External ID.','External ID atende principalmente consumidores, parceiros e convidados, não o diretório corporativo descrito.'),
('7f160000-0000-4000-8000-000000000012','Azure RBAC.','RBAC autoriza ações em recursos Azure, mas não fornece o serviço de autenticação da aplicação SaaS.'),
('7f160000-0000-4000-8000-000000000013','Microsoft Entra Domain Services.','Correta. Ele oferece recursos tradicionais de domínio de forma gerenciada.'),
('7f160000-0000-4000-8000-000000000014','Microsoft Entra ID sem um serviço de domínio adicional.','Entra ID não fornece por si só o conjunto tradicional de LDAP, Kerberos, NTLM e domain join solicitado.'),
('7f160000-0000-4000-8000-000000000015','Active Directory Domain Services em VMs administradas pela empresa.','Essa alternativa pode oferecer compatibilidade, mas exige administrar domain controllers, contrariando o requisito operacional.'),
('7f160000-0000-4000-8000-000000000016','Microsoft Entra External ID.','External ID trata identidades externas e colaboração, não serviços de domínio tradicionais para a aplicação.'),
('7f160000-0000-4000-8000-000000000017','Entra ID para as aplicações modernas e Entra Domain Services para a dependência legada.','Correta. A combinação atende autenticação moderna e recursos tradicionais de domínio.'),
('7f160000-0000-4000-8000-000000000018','Entra Domain Services para todas as aplicações, usando NTLM também nas aplicações modernas.','A dependência legada não exige que as aplicações modernas abandonem os protocolos modernos do Entra ID.'),
('7f160000-0000-4000-8000-000000000019','Entra ID para ambos os casos, tratando Group Policy e NTLM como capacidades equivalentes.','Entra ID não oferece diretamente os recursos tradicionais exigidos pela aplicação legada.'),
('7f160000-0000-4000-8000-000000000020','Entra ID para as aplicações modernas e domain controllers próprios em VMs para a aplicação legada.','A solução pode funcionar, mas acrescenta administração de domain controllers quando há uma opção gerenciada alinhada ao requisito.'),
('7f170000-0000-4000-8000-000000000001','Single Sign-On.','Correta. SSO reduz prompts de login entre aplicações integradas.'),
('7f170000-0000-4000-8000-000000000002','Multifactor authentication.','MFA exige fatores independentes para aumentar a garantia da identidade; não tem como objetivo principal reduzir logins entre aplicações.'),
('7f170000-0000-4000-8000-000000000003','Passwordless Authentication.','Passwordless remove a senha tradicional do fluxo, mas não implica reutilização da sessão entre várias aplicações.'),
('7f170000-0000-4000-8000-000000000004','Conditional Access.','Conditional Access decide quando permitir, bloquear ou exigir controles; ele não é a capacidade de login único.'),
('7f170000-0000-4000-8000-000000000005','Reutilização de senha em três autenticações independentes.','Correta. Digitar a credencial em cada aplicação não constitui SSO.'),
('7f170000-0000-4000-8000-000000000006','SSO, porque a mesma credencial foi aceita pelas três aplicações.','SSO evita novos prompts por meio de integração; o simples uso da mesma senha não cria login único.'),
('7f170000-0000-4000-8000-000000000007','MFA, porque três aplicações equivalem a três fatores.','Fatores são categorias independentes de evidência, não a quantidade de aplicações acessadas.'),
('7f170000-0000-4000-8000-000000000008','Passwordless, porque a senha ficou armazenada na memória do usuário.','O usuário continua usando uma senha tradicional, portanto o fluxo não é passwordless.'),
('7f170000-0000-4000-8000-000000000013','SSO reduz novos prompts entre aplicações; MFA exige fatores independentes.','Correta. As capacidades possuem objetivos distintos e podem trabalhar juntas.'),
('7f170000-0000-4000-8000-000000000014','SSO elimina a autorização; MFA determina quais recursos o usuário pode administrar.','SSO não elimina autorização, e MFA comprova identidade em vez de definir permissões sobre recursos.'),
('7f170000-0000-4000-8000-000000000015','SSO exige múltiplos fatores; MFA reutiliza uma autenticação entre aplicações.','A alternativa troca as finalidades principais de SSO e MFA.'),
('7f170000-0000-4000-8000-000000000016','SSO substitui MFA quando as aplicações usam o mesmo provedor de identidade.','Aplicações integradas podem combinar SSO com MFA conforme a política de acesso.'),
('7f170000-0000-4000-8000-000000000017','O SSO reduz prompts, enquanto a autorização continua limitando o acesso em cada aplicação.','Correta. Autenticação compartilhada não significa autorização irrestrita.'),
('7f170000-0000-4000-8000-000000000018','O SSO concede acesso às três aplicações sempre que a identidade é autenticada em uma delas.','Cada aplicação ainda pode exigir que o usuário esteja autorizado.'),
('7f170000-0000-4000-8000-000000000019','O SSO centraliza autenticação e substitui as roles e permissões das aplicações.','SSO trata autenticação; roles e permissões continuam controlando autorização.'),
('7f170000-0000-4000-8000-000000000020','O SSO exige que todas as aplicações atribuam o mesmo nível de acesso ao usuário.','A integração de autenticação não obriga políticas de autorização idênticas.'),
('7f170000-0000-4000-8000-000000000025','Entrar usando uma passkey compatível.','Correta. A passkey autentica sem a senha tradicional como credencial principal.'),
('7f170000-0000-4000-8000-000000000026','Entrar com senha e confirmar um código enviado ao telefone.','O fluxo adiciona um fator, mas continua usando a senha tradicional.'),
('7f170000-0000-4000-8000-000000000027','Entrar com uma senha armazenada em um gerenciador de senhas.','O gerenciador melhora o uso de credenciais, mas o método ainda depende de senha.'),
('7f170000-0000-4000-8000-000000000028','Entrar respondendo a perguntas de segurança sem digitar a senha.','Perguntas de segurança são conhecimento compartilhado e não representam o método passwordless recomendado.'),
('7f170000-0000-4000-8000-000000000033','Passwordless Authentication.','Correta. A abordagem mantém autenticação sem exigir a senha tradicional.'),
('7f170000-0000-4000-8000-000000000034','Single Sign-On baseado em senha.','SSO reduz prompts, mas pode continuar usando uma senha na autenticação inicial.'),
('7f170000-0000-4000-8000-000000000035','MFA com senha e código temporário.','Esse fluxo reforça a autenticação, porém ainda depende da senha tradicional.'),
('7f170000-0000-4000-8000-000000000036','Self-service password reset.','A redefinição recupera o acesso, mas mantém a senha como credencial.'),
('7f170000-0000-4000-8000-000000000037','Combinar SSO, MFA e Passwordless Authentication conforme o suporte da implementação.','Correta. As capacidades tratam objetivos complementares.'),
('7f170000-0000-4000-8000-000000000038','Usar SSO com senha e considerar que a sessão compartilhada já fornece fatores independentes.','SSO reduz prompts, mas não transforma uma credencial em múltiplos fatores nem remove a senha.'),
('7f170000-0000-4000-8000-000000000039','Usar MFA com senha e código e considerar que isso também oferece login único.','MFA aumenta a garantia da identidade, mas não fornece SSO por si só nem elimina a senha.'),
('7f170000-0000-4000-8000-000000000040','Usar Passwordless Authentication e considerar que ela concede acesso a todas as aplicações.','Passwordless muda o método de autenticação, mas não substitui SSO nem autorização.'),
('7f170000-0000-4000-8000-000000000041','Microsoft Entra External ID com colaboração B2B.','Correta. A capacidade integra identidades externas e mantém o acesso sob controle da organização de destino.'),
('7f170000-0000-4000-8000-000000000042','Microsoft Entra ID apenas para identidades internas de colaboradores.','O diretório corporativo atende colaboradores, mas a necessidade destacada é colaboração com identidades externas.'),
('7f170000-0000-4000-8000-000000000043','Microsoft Entra Domain Services.','Domain Services fornece compatibilidade de domínio tradicional, não colaboração B2B.'),
('7f170000-0000-4000-8000-000000000044','Azure RBAC sem convidar ou representar a identidade externa.','RBAC pode autorizar um principal existente, mas não cria por si só a colaboração e a identidade externa.'),
('7f170000-0000-4000-8000-000000000049','Microsoft Entra External ID com colaboração B2B.','Correta. A consultora pode usar sua identidade de origem como convidada no resource tenant.'),
('7f170000-0000-4000-8000-000000000050','Criar uma conta de colaborador interna comum para a consultora na Contoso.','Uma conta interna pode dar acesso, mas não atende ao requisito de usar a identidade de origem.'),
('7f170000-0000-4000-8000-000000000051','Microsoft Entra Domain Services com domain join do aplicativo.','Domain Services atende protocolos tradicionais de domínio, não a colaboração B2B descrita.'),
('7f170000-0000-4000-8000-000000000052','Uma role assignment sem uma identidade representada no tenant da Contoso.','A autorização precisa estar associada a uma identidade; a role assignment isolada não integra a identidade externa.'),
('7f170000-0000-4000-8000-000000000053','Uma identidade externa representada no resource tenant é limitada ao acesso autorizado.','Correta. O convite não torna o guest interno nem concede privilégios automaticamente.'),
('7f170000-0000-4000-8000-000000000054','Uma identidade externa que recebe a role Owner quando aceita o convite.','O aceite do convite não atribui automaticamente a role Owner.'),
('7f170000-0000-4000-8000-000000000055','Uma cópia integral da identidade convertida em colaborador interno do resource tenant.','O guest representa colaboração externa e não muda automaticamente o vínculo da pessoa.'),
('7f170000-0000-4000-8000-000000000056','Uma identidade autorizada a todos os recursos do tenant por padrão.','O acesso do guest deve ser explicitamente concedido e pode ser restrito.'),
('7f170000-0000-4000-8000-000000000057','Fabrikam é o home tenant; Contoso é o resource tenant.','Correta. O primeiro autentica a identidade e o segundo possui o aplicativo.'),
('7f170000-0000-4000-8000-000000000058','Contoso é o home tenant; Fabrikam é o resource tenant.','A alternativa inverte a origem da identidade e a organização que possui o recurso.'),
('7f170000-0000-4000-8000-000000000059','Fabrikam e Contoso são resource tenants porque ambas participam do acesso.','Participar do fluxo não muda o papel do tenant de origem da identidade.'),
('7f170000-0000-4000-8000-000000000060','Fabrikam é o resource tenant; a consultora individual é o home tenant.','Um usuário não é um tenant; Fabrikam é o tenant de origem da identidade.'),
('7f180000-0000-4000-8000-000000000009','Conditional Access.','Correta. A policy avalia sinais e decide quando exigir MFA.'),
('7f180000-0000-4000-8000-000000000010','Multifactor authentication.','MFA é o controle de verificação adicional, mas não decide com base em sinais quando deve ser exigido.'),
('7f180000-0000-4000-8000-000000000011','Azure RBAC.','RBAC autoriza ações em scopes de recursos Azure; ele não avalia localização ou risco no sign-in.'),
('7f180000-0000-4000-8000-000000000012','Security defaults.','Security defaults fornece uma proteção predefinida, mas não representa a policy condicional baseada nos sinais descritos.'),
('7f180000-0000-4000-8000-000000000013','Conditional Access.','Correta. Essa capacidade avalia sinais de sign-in e aplica decisões de acesso.'),
('7f180000-0000-4000-8000-000000000014','Azure RBAC.','RBAC avalia a role e o scope para autorizar ações, não a localização e o estado do dispositivo no sign-in.'),
('7f180000-0000-4000-8000-000000000015','Multifactor authentication.','MFA comprova identidade com fatores adicionais, mas não é o mecanismo que combina os sinais e decide bloquear.'),
('7f180000-0000-4000-8000-000000000016','Single Sign-On.','SSO reduz prompts de autenticação entre aplicações integradas, mas não avalia essas condições de acesso.'),
('7f180000-0000-4000-8000-000000000025','Security principal, role definition e scope.','Correta. A atribuição conecta quem, quais permissões e onde elas valem.'),
('7f180000-0000-4000-8000-000000000026','Identity, authentication method e Conditional Access policy.','Esses elementos participam de autenticação e acesso, mas não formam uma Azure role assignment.'),
('7f180000-0000-4000-8000-000000000027','User, group e managed identity.','Todos podem ser tipos de security principal, mas a lista não inclui role definition nem scope.'),
('7f180000-0000-4000-8000-000000000028','Management Group, Subscription e Resource Group.','Todos podem ser scopes, mas a lista não inclui o principal nem a definição da role.'),
('7f180000-0000-4000-8000-000000000029','Atribuir à managed identity uma role de leitura no scope da storage account.','Correta. A role e o scope atendem ao acesso necessário com menor abrangência.'),
('7f180000-0000-4000-8000-000000000030','Atribuir à managed identity uma role de leitura no scope da Subscription.','A role pode permitir a leitura, mas o scope é mais amplo que a única storage account solicitada.'),
('7f180000-0000-4000-8000-000000000031','Criar uma Conditional Access policy no scope da storage account.','Conditional Access trata decisões de acesso de identidade e não substitui Azure RBAC no recurso.'),
('7f180000-0000-4000-8000-000000000032','Habilitar MFA para a managed identity antes de acessar a storage account.','Managed identities usam identidade de workload; MFA não é a configuração RBAC necessária.'),
('7f190000-0000-4000-8000-000000000013','Usar acesso com menor privilégio.','Correta. Permissão, scope e duração foram limitados ao necessário.'),
('7f190000-0000-4000-8000-000000000014','Verificar explicitamente cada solicitação.','É um princípio de Zero Trust, mas o cenário enfatiza a redução de privilégio, scope e tempo.'),
('7f190000-0000-4000-8000-000000000015','Assumir violação e segmentar os recursos.','Também é um princípio relacionado, mas não descreve diretamente a concessão mínima apresentada.'),
('7f190000-0000-4000-8000-000000000016','Aplicar Defense in Depth em várias camadas.','Defense in Depth é complementar, mas o cenário descreve especificamente uma permissão limitada.'),
('7f190000-0000-4000-8000-000000000017','Combinar Zero Trust para decisões de acesso e Defense in Depth para controles em camadas.','Correta. O cenário contém elementos das duas estratégias.'),
('7f190000-0000-4000-8000-000000000018','Aplicar apenas Zero Trust, pois a validação de cada solicitação torna controles em camadas redundantes.','A verificação representa Zero Trust, mas os controles nas várias camadas também caracterizam Defense in Depth.'),
('7f190000-0000-4000-8000-000000000019','Aplicar apenas Defense in Depth, pois limitar privilégios é somente um controle de camada.','A limitação de privilégios e a verificação explícita também representam princípios de Zero Trust.'),
('7f190000-0000-4000-8000-000000000020','Tratar Zero Trust e Defense in Depth como dois nomes para a mesma estratégia.','As estratégias são complementares, mas possuem focos conceituais distintos.'),
('7f190000-0000-4000-8000-000000000025','Security recommendations.','Correta. Cada recomendação descreve o achado e a ação de remediação relacionada.'),
('7f190000-0000-4000-8000-000000000026','Secure score.','Secure score resume a postura em uma pontuação; não é o item individual com a ação de correção solicitada.'),
('7f190000-0000-4000-8000-000000000027','Security alerts.','Alerts comunicam atividade suspeita ou ameaças, não a orientação de melhoria de uma configuração específica.'),
('7f190000-0000-4000-8000-000000000028','Workload protection plans.','Os planos habilitam proteções para workloads, mas não são o item individual de correção de postura.'),
('7f190000-0000-4000-8000-000000000033','Workload protection.','Correta. Essa capacidade protege workloads e detecta ameaças conforme os planos habilitados.'),
('7f190000-0000-4000-8000-000000000034','Secure score.','A pontuação resume a postura; ela não constitui o mecanismo de detecção de ameaças contra workloads.'),
('7f190000-0000-4000-8000-000000000035','Security recommendations.','Recommendations orientam melhorias de configuração, mas não são a capacidade de detecção de ameaças descrita.'),
('7f190000-0000-4000-8000-000000000036','Azure Policy compliance.','Policy avalia recursos em relação a regras; isso não substitui workload protection.'),
('7f190000-0000-4000-8000-000000000037','Postura para a recomendação; workload protection para o alerta.','Correta. Os dois resultados pertencem aos focos distintos do Defender for Cloud.'),
('7f190000-0000-4000-8000-000000000038','Workload protection para a recomendação; postura para o alerta.','A associação está invertida: configuração aponta para postura e ameaça para workload protection.'),
('7f190000-0000-4000-8000-000000000039','Postura para os dois resultados.','A recomendação pertence à postura, mas o alerta de atividade suspeita pertence à proteção contra ameaças.'),
('7f190000-0000-4000-8000-000000000040','Workload protection para os dois resultados.','O alerta pertence à workload protection, mas a recomendação de configuração é um resultado de postura.'),
('7f200000-0000-4000-8000-000000000001','Azure Pricing Calculator.','Correta. A ferramenta estima custos de uma solução planejada antes da implantação.'),
('7f200000-0000-4000-8000-000000000002','Azure Cost Management.','Cost Management acompanha, analisa e controla gastos de recursos em uso; não é a ferramenta principal para modelar a arquitetura futura.'),
('7f200000-0000-4000-8000-000000000003','Azure Advisor.','Advisor recomenda melhorias para recursos existentes, inclusive de custo, mas não monta a estimativa detalhada da solução planejada.'),
('7f200000-0000-4000-8000-000000000004','TCO Calculator.','TCO Calculator compara custos de workloads locais com Azure; não é a escolha direta para estimar a configuração Azure descrita.'),
('7f200000-0000-4000-8000-000000000009','Region e size são entradas que podem alterar o preço estimado.','Correta. O preço varia conforme localização e configuração do recurso.'),
('7f200000-0000-4000-8000-000000000010','Somente a quantidade de VMs altera a estimativa; Region e size são informativos.','Quantidade importa, mas Region e size também participam da estimativa.'),
('7f200000-0000-4000-8000-000000000011','Region altera a moeda exibida, enquanto size não altera o consumo estimado.','O size muda a capacidade e o preço; Region também pode afetar preços, não apenas a moeda.'),
('7f200000-0000-4000-8000-000000000012','Size altera o nome da VM, enquanto Region afeta somente a latência.','Ambos são fatores de configuração com impacto possível no preço.'),
('7f200000-0000-4000-8000-000000000017','As hipóteses da estimativa podem diferir do uso e da configuração que foram efetivamente cobrados.','Correta. A estimativa depende das entradas e não garante a fatura final.'),
('7f200000-0000-4000-8000-000000000018','A Pricing Calculator usa preços de lista, portanto a diferença só pode vir de um desconto contratual.','Descontos são um fator possível, mas uso, configuração, transferência e itens omitidos também podem causar diferença.'),
('7f200000-0000-4000-8000-000000000019','A estimativa inclui automaticamente todo tráfego e crescimento futuros, mas não inclui o preço do serviço principal.','A ferramenta calcula apenas com as entradas fornecidas e inclui os serviços selecionados.'),
('7f200000-0000-4000-8000-000000000020','A fatura usa a configuração planejada, enquanto a calculadora mede o consumo real após a implantação.','A alternativa inverte os papéis: a calculadora planeja e a fatura reflete consumo e configuração reais.'),
('7f210000-0000-4000-8000-000000000009','Resources, Resource Groups e Subscriptions.','Correta. Esses são scopes aos quais Tags podem ser aplicadas diretamente no contexto estudado.'),
('7f210000-0000-4000-8000-000000000010','Management Groups, tenants e usuários.','Esses elementos não correspondem aos alvos de Tags listados no conteúdo desta Lesson.'),
('7f210000-0000-4000-8000-000000000011','Usuários, grupos e service principals.','Esses são objetos de identidade, não recursos ou scopes marcados com Azure Tags.'),
('7f210000-0000-4000-8000-000000000012','Budgets, invoices e cost alerts.','Esses objetos de custo não substituem resources, Resource Groups e Subscriptions como alvos de Tags.'),
('7f210000-0000-4000-8000-000000000013','As VMs mantêm suas Tags atuais; não há herança automática da Tag do Resource Group.','Correta. A aplicação no scope pai não copia a tag para os recursos filhos.'),
('7f210000-0000-4000-8000-000000000014','As VMs recebem Environment=Production por herança quando a Tag do grupo é salva.','Azure Tags não são herdadas automaticamente dessa forma.'),
('7f210000-0000-4000-8000-000000000015','As VMs recebem a Tag quando forem reiniciadas e sincronizarem metadados.','O estado da VM não controla herança de Tags.'),
('7f210000-0000-4000-8000-000000000016','As VMs recebem a Tag somente se também herdarem as role assignments do grupo.','Herança de RBAC e aplicação de Tags são mecanismos diferentes.'),
('7f210000-0000-4000-8000-000000000017','A conclusão está errada; Tag não concede acesso nem bloqueia exclusão.','Correta. RBAC e Resource Locks atendem a essas necessidades.'),
('7f210000-0000-4000-8000-000000000018','A Tag concede a role Owner, mas a proteção contra exclusão exige CanNotDelete.','Um valor de Tag chamado Owner não cria uma role assignment.'),
('7f210000-0000-4000-8000-000000000019','A Tag bloqueia a exclusão, mas o acesso administrativo exige Azure RBAC.','Tags não bloqueiam operações; essa proteção corresponde a Resource Locks.'),
('7f210000-0000-4000-8000-000000000020','A Tag concede acesso e bloqueia exclusão quando aplicada diretamente à VM.','Aplicar a Tag diretamente não muda sua natureza de metadado.'),
('7f230000-0000-4000-8000-000000000009','Data Map mapeia metadados; Unified Catalog ajuda a localizar e compreender dados.','Correta. As capacidades apoiam o conhecimento e a governança do patrimônio de dados.'),
('7f230000-0000-4000-8000-000000000010','Data Map armazena os dados de negócio; Unified Catalog substitui os bancos de origem.','Purview trabalha principalmente com metadados e contexto, sem exigir centralização de todos os dados de negócio.'),
('7f230000-0000-4000-8000-000000000011','Data Map avalia configurações de recursos; Unified Catalog aplica Azure Policy.','Avaliação de recursos e enforcement de policy pertencem ao Azure Policy, não a essas capacidades do Purview.'),
('7f230000-0000-4000-8000-000000000012','Data Map detecta ameaças em VMs; Unified Catalog calcula o secure score.','Essas funções se relacionam ao Defender for Cloud, não ao catálogo e mapa de dados.'),
('7f230000-0000-4000-8000-000000000013','Azure Policy.','Correta. Policy avalia configurações de recursos e seu estado de compliance.'),
('7f230000-0000-4000-8000-000000000014','Microsoft Purview.','Purview governa e ajuda a compreender dados; não é o mecanismo principal para restringir regiões de recursos.'),
('7f230000-0000-4000-8000-000000000015','Resource Locks.','Locks protegem contra exclusão ou alteração, mas não avaliam uma lista de regiões aprovadas.'),
('7f230000-0000-4000-8000-000000000016','Azure RBAC.','RBAC controla quem pode agir em determinado scope, mas não avalia se a Region escolhida atende a uma regra.'),
('7f230000-0000-4000-8000-000000000017','Microsoft Purview para os dados e Defender for Cloud para as VMs.','Correta. Cada serviço atende ao requisito correspondente.'),
('7f230000-0000-4000-8000-000000000018','Defender for Cloud para os dados e Microsoft Purview para as VMs.','A associação está invertida em relação aos focos principais dos serviços.'),
('7f230000-0000-4000-8000-000000000019','Azure Policy para catalogar os dados e Defender for Cloud para aplicar classificação.','Policy avalia configurações de recursos, e Defender for Cloud não substitui o catálogo e a classificação do Purview.'),
('7f230000-0000-4000-8000-000000000020','Microsoft Purview para ambos, usando o catálogo como proteção de workload.','Purview não fornece a proteção e as recomendações de postura para VMs solicitadas.'),
('7f240000-0000-4000-8000-000000000009','RBAC autoriza a ação; Policy pode negar o estado não conforme.','Correta. Os controles avaliam dimensões diferentes e podem produzir esse resultado.'),
('7f240000-0000-4000-8000-000000000010','RBAC autoriza a ação e, por isso, a Policy deve registrar compliance sem negar a criação.','Uma policy com effect Deny pode bloquear a configuração mesmo quando a identidade possui permissão RBAC.'),
('7f240000-0000-4000-8000-000000000011','Policy substitui RBAC e passa a definir todas as ações permitidas ao desenvolvedor.','Policy governa o estado dos recursos, mas não substitui as atribuições de autorização do RBAC.'),
('7f240000-0000-4000-8000-000000000012','A negação indica que a role foi removida temporariamente pela Policy.','Policy não precisa remover a role para negar uma configuração não conforme.'),
('7f240000-0000-4000-8000-000000000013','Tag é o metadado; Azure Policy pode avaliar ou impor a regra.','Correta. Os dois recursos exercem papéis complementares.'),
('7f240000-0000-4000-8000-000000000014','Tag é a regra; Azure Policy apenas exibe o valor sem avaliar compliance.','A tag armazena metadados, enquanto Policy define e avalia a regra.'),
('7f240000-0000-4000-8000-000000000015','Azure RBAC cria a Tag porque a role Contributor contém o valor Environment.','RBAC concede permissões; ele não define automaticamente o metadado exigido.'),
('7f240000-0000-4000-8000-000000000016','Resource Lock adiciona a Tag e impede que recursos sem ela sejam criados.','Locks protegem operações administrativas e não impõem a presença de Tags.'),
('7f240000-0000-4000-8000-000000000017','Criar uma policy definition, atribuí-la ao Management Group e usar o effect Deny.','Correta. A definição, o scope da assignment e o effect atendem ao requisito.'),
('7f240000-0000-4000-8000-000000000018','Criar uma Tag no Management Group e usar CanNotDelete nas Subscriptions.','Tags e locks não avaliam nem bloqueiam configurações com base na regra solicitada.'),
('7f240000-0000-4000-8000-000000000019','Criar uma policy definition e atribuí-la separadamente a cada VM existente.','Uma assignment no Management Group oferece o alcance central solicitado, enquanto a opção proposta não cobre adequadamente novas configurações em todas as Subscriptions.'),
('7f240000-0000-4000-8000-000000000020','Criar uma role definition no Management Group e usar Reader como effect.','Role definitions pertencem ao RBAC, e Reader não é um effect de Azure Policy.'),
('7f240000-0000-4000-8000-000000000029','Herdam a proteção contra exclusão do lock aplicado ao Resource Group.','Correta. Locks de scopes superiores se aplicam aos recursos filhos.'),
('7f240000-0000-4000-8000-000000000030','Podem ser excluídos, mas não podem receber alterações de configuração.','Esse comportamento se aproxima de ReadOnly; CanNotDelete bloqueia exclusão e permite alterações autorizadas.'),
('7f240000-0000-4000-8000-000000000031','Ficam protegidos apenas quando cada recurso recebe uma cópia do lock.','O lock no Resource Group é herdado; não é necessário copiá-lo para cada filho.'),
('7f240000-0000-4000-8000-000000000032','Herdam a proteção somente se também herdarem uma role assignment.','A aplicação do lock não depende da herança de Azure RBAC.'),
('7f240000-0000-4000-8000-000000000033','Remover o lock com a permissão adequada e depois excluir o recurso.','Correta. A role Owner não ignora o Resource Lock.'),
('7f240000-0000-4000-8000-000000000034','Usar a role Owner para excluir diretamente, pois ela tem precedência sobre o lock.','O lock prevalece para a operação até ser removido adequadamente.'),
('7f240000-0000-4000-8000-000000000035','Alterar CanNotDelete para ReadOnly e excluir o recurso mantendo o novo lock.','ReadOnly também restringe a operação e não permite a exclusão enquanto estiver aplicado.'),
('7f240000-0000-4000-8000-000000000036','Atribuir Contributor ao mesmo usuário para complementar a role Owner.','Contributor não supera o lock e já possui menos permissões que Owner.'),
('7f240000-0000-4000-8000-000000000037','Manter RBAC e backup, pois cada controle atende a um risco diferente do ReadOnly.','Correta. Lock, autorização e recuperação não são substitutos.'),
('7f240000-0000-4000-8000-000000000038','Retirar RBAC, mas manter backup, pois ReadOnly passa a controlar quem pode ler os dados.','ReadOnly restringe operações administrativas; ele não substitui a autorização do RBAC.'),
('7f240000-0000-4000-8000-000000000039','Retirar backup, mas manter RBAC, pois ReadOnly permite restaurar o estado anterior.','Resource Lock não cria cópia nem oferece recuperação de dados.'),
('7f240000-0000-4000-8000-000000000040','Trocar ReadOnly por CanNotDelete e retirar os outros controles.','CanNotDelete também não substitui RBAC nem backup.'),
('7f250000-0000-4000-8000-000000000005','Azure portal.','Correta. A interface gráfica é adequada à exploração visual pontual.'),
('7f250000-0000-4000-8000-000000000006','Azure CLI.','CLI pode consultar a VM, mas não é a escolha mais alinhada ao requisito visual e pontual.'),
('7f250000-0000-4000-8000-000000000007','Azure PowerShell.','PowerShell também pode consultar propriedades, mas é mais alinhado a comandos e automação.'),
('7f250000-0000-4000-8000-000000000008','ARM Template.','ARM Template declara infraestrutura para deployment, não é a interface de exploração solicitada.'),
('7f250000-0000-4000-8000-000000000009','Usar comandos ou scripts parametrizados para executar a operação em escala.','Correta. A automação favorece consistência e repetibilidade.'),
('7f250000-0000-4000-8000-000000000010','Repetir a operação manualmente no portal em cada recurso.','O portal pode realizar a tarefa, mas a repetição manual não atende tão bem ao requisito de escala e repetibilidade.'),
('7f250000-0000-4000-8000-000000000011','Exportar um ARM Template depois de cada alteração manual e não reutilizá-lo.','A exportação sem reutilização não automatiza a operação repetida solicitada.'),
('7f250000-0000-4000-8000-000000000012','Aplicar um Resource Lock aos recursos antes de repetir a operação.','Locks protegem contra operações específicas, mas não executam nem automatizam a mudança.'),
('7f250000-0000-4000-8000-000000000017','CLI, PowerShell, APIs e IaC também administram recursos por Azure Resource Manager.','Correta. O portal é uma das interfaces disponíveis.'),
('7f250000-0000-4000-8000-000000000018','Cloud Shell oferece terminal, mas só permite consultar recursos criados no portal.','Cloud Shell pode executar comandos de administração conforme as permissões do usuário.'),
('7f250000-0000-4000-8000-000000000019','Azure CLI administra recursos, mas precisa ser iniciada por uma página do portal.','CLI pode ser executada em vários ambientes, incluindo instalação local e Cloud Shell.'),
('7f250000-0000-4000-8000-000000000020','ARM Templates criam recursos, mas alterações posteriores exigem exclusivamente o portal.','Deployments declarativos podem criar e atualizar recursos sem exclusividade do portal.'),
('7f250000-0000-4000-8000-000000000025','Usa módulos Az, cmdlets e objetos no ambiente PowerShell.','Correta. Essas características distinguem Azure PowerShell.'),
('7f250000-0000-4000-8000-000000000026','Usa comandos iniciados por az e apresenta a mesma sintaxe em qualquer shell.','Comandos az caracterizam Azure CLI, não Azure PowerShell.'),
('7f250000-0000-4000-8000-000000000027','Oferece apenas uma interface gráfica para administrar recursos no navegador.','Essa descrição se aproxima do Azure portal, não de uma ferramenta PowerShell.'),
('7f250000-0000-4000-8000-000000000028','Executa exclusivamente no Windows porque processa objetos .NET.','PowerShell moderno e os módulos Az são multiplataforma em ambientes compatíveis.'),
('7f250000-0000-4000-8000-000000000029','Azure PowerShell.','Correta. Cmdlets Az e objetos se integram ao pipeline já adotado.'),
('7f250000-0000-4000-8000-000000000030','Azure CLI.','CLI também automatiza Azure, mas usa comandos az e não corresponde tão diretamente ao pipeline de objetos descrito.'),
('7f250000-0000-4000-8000-000000000031','Azure portal.','O portal é adequado a tarefas visuais, não à integração direta com o script PowerShell existente.'),
('7f250000-0000-4000-8000-000000000032','ARM Template.','Templates oferecem IaC declarativa, mas não são a ferramenta de cmdlets solicitada para o pipeline existente.'),
('7f250000-0000-4000-8000-000000000033','Azure PowerShell é a ferramenta; Cloud Shell é o ambiente hospedado.','Correta. O cmdlet pertence ao PowerShell executado dentro do terminal cloud.'),
('7f250000-0000-4000-8000-000000000034','Cloud Shell é a ferramenta; Azure PowerShell é o serviço de hospedagem.','A alternativa inverte o ambiente e a ferramenta.'),
('7f250000-0000-4000-8000-000000000035','Get-AzResourceGroup pertence à Azure CLI; Cloud Shell converte o comando para PowerShell.','Get-AzResourceGroup é um cmdlet do Azure PowerShell; não há essa conversão.'),
('7f250000-0000-4000-8000-000000000036','Azure PowerShell e Cloud Shell são duas interfaces gráficas equivalentes.','PowerShell é uma ferramenta de linha de comando e Cloud Shell é um terminal hospedado.'),
('7f250000-0000-4000-8000-000000000037','Azure CLI para comandos az e Azure PowerShell para cmdlets e objetos.','Correta. A combinação segue os ecossistemas preferidos pelas equipes.'),
('7f250000-0000-4000-8000-000000000038','Azure PowerShell para comandos az e Azure CLI para cmdlets e objetos.','A alternativa inverte as sintaxes e os modelos das ferramentas.'),
('7f250000-0000-4000-8000-000000000039','Azure CLI para ambas, pois ela converte cmdlets PowerShell em comandos az.','Azure CLI não converte automaticamente os cmdlets do pipeline PowerShell.'),
('7f250000-0000-4000-8000-000000000040','Azure PowerShell para ambas, pois comandos az são aliases dos cmdlets Az.','Comandos az pertencem à CLI e não são aliases gerais dos cmdlets do Azure PowerShell.'),
('7f260000-0000-4000-8000-000000000001','Definir a infraestrutura em arquivos ou código versionável e reutilizável.','Correta. Essa é a prática de Infrastructure as Code.'),
('7f260000-0000-4000-8000-000000000002','Registrar em um documento os passos manuais executados no portal.','Documentação melhora repetição humana, mas não define nem implanta a infraestrutura como código.'),
('7f260000-0000-4000-8000-000000000003','Exportar métricas dos recursos para comparar sua utilização.','Coleta de métricas é monitoramento, não definição da infraestrutura.'),
('7f260000-0000-4000-8000-000000000004','Proteger recursos existentes com Resource Locks.','Locks protegem operações administrativas, mas não descrevem Infrastructure as Code.'),
('7f260000-0000-4000-8000-000000000005','Descrever o estado desejado dos recursos.','Correta. O mecanismo determina como alcançar o estado declarado.'),
('7f260000-0000-4000-8000-000000000006','Listar em ordem cada comando necessário para modificar os recursos.','Uma sequência de passos caracteriza uma abordagem imperativa.'),
('7f260000-0000-4000-8000-000000000007','Capturar o estado atual sem indicar o resultado esperado.','Uma definição declarativa precisa expressar o estado desejado.'),
('7f260000-0000-4000-8000-000000000008','Executar o deployment apenas por uma interface gráfica.','A interface usada não define se a especificação é declarativa.'),
('7f260000-0000-4000-8000-000000000009','Uma definição IaC comum com parâmetros para Region e SKU de cada ambiente.','Correta. A abordagem mantém consistência e controla as diferenças.'),
('7f260000-0000-4000-8000-000000000010','Um procedimento manual separado para cada ambiente, revisado pela mesma pessoa.','A revisão pode reduzir erros, mas os procedimentos independentes não oferecem a mesma repetibilidade da IaC parametrizada.'),
('7f260000-0000-4000-8000-000000000011','Um Resource Lock em cada ambiente para copiar a configuração do anterior.','Locks não copiam nem reproduzem configurações.'),
('7f260000-0000-4000-8000-000000000012','Um único template com Region e SKU fixos, editado diretamente antes de cada deployment.','Editar valores fixos pode funcionar, mas é mais sujeito a divergência do que parâmetros explícitos por ambiente.'),
('7f260000-0000-4000-8000-000000000017','Automação pode ser imperativa; declarativa descreve principalmente o estado desejado.','Correta. Os conceitos se sobrepõem, mas não são equivalentes.'),
('7f260000-0000-4000-8000-000000000018','Toda automação é declarativa quando pode ser executada mais de uma vez.','Repetibilidade não transforma uma sequência de comandos em declaração de estado.'),
('7f260000-0000-4000-8000-000000000019','Automação é declarativa quando roda na CLI e imperativa quando roda no portal.','A interface de execução não determina o modelo declarativo ou imperativo.'),
('7f260000-0000-4000-8000-000000000020','IaC é sempre imperativa porque qualquer deployment executa operações.','A execução realiza operações, mas a definição pode descrever declarativamente o estado desejado.'),
('7f260000-0000-4000-8000-000000000021','Azure Resource Manager.','Correta. ARM é a camada comum de gerenciamento e deployment.'),
('7f260000-0000-4000-8000-000000000022','Azure Resource Provider.','Providers oferecem tipos e operações específicos, enquanto ARM recebe e coordena as solicitações de gerenciamento.'),
('7f260000-0000-4000-8000-000000000023','Resource Group.','Resource Group é um contêiner lógico de recursos, não a camada que recebe as solicitações.'),
('7f260000-0000-4000-8000-000000000024','ARM Template.','Template é uma definição declarativa enviada para deployment, não o serviço que recebe todas as interfaces.'),
('7f260000-0000-4000-8000-000000000025','Um arquivo JSON declarativo que define recursos para deployment por ARM.','Correta. Essa é a função de um ARM Template.'),
('7f260000-0000-4000-8000-000000000026','A API de gerenciamento usada diretamente por todos os Resource Providers.','ARM Template é um documento declarativo, não a API de gerenciamento.'),
('7f260000-0000-4000-8000-000000000027','O serviço que autentica usuários antes de um deployment.','Autenticação envolve identidade; o template descreve recursos e configurações.'),
('7f260000-0000-4000-8000-000000000028','Um arquivo de métricas que registra o resultado de cada deployment.','O template define o estado desejado e não é um registro de telemetria.'),
('7f260000-0000-4000-8000-000000000033','Fornecer tipos de recurso e operações de um serviço para gerenciamento por ARM.','Correta. Essa é a função conceitual de um Resource Provider.'),
('7f260000-0000-4000-8000-000000000034','Receber todas as solicitações do portal e substituir Azure Resource Manager.','O provider trabalha com ARM e não substitui a camada comum.'),
('7f260000-0000-4000-8000-000000000035','Armazenar os ARM Templates usados por uma Subscription.','O provider expõe tipos e operações; ele não é um repositório de templates.'),
('7f260000-0000-4000-8000-000000000036','Agrupar recursos que compartilham ciclo de vida e permissões.','Essa é uma finalidade de Resource Group, não de Resource Provider.'),
('7f260000-0000-4000-8000-000000000037','As duas solicitações passam por Azure Resource Manager.','Correta. Portal e CLI são clientes da mesma camada de gerenciamento.'),
('7f260000-0000-4000-8000-000000000038','A solicitação do portal usa ARM, enquanto a CLI chama o Resource Provider sem ARM.','As interfaces enviam solicitações pela camada ARM.'),
('7f260000-0000-4000-8000-000000000039','A solicitação da CLI usa ARM, enquanto o portal grava a VM diretamente na Subscription.','O portal também usa ARM; a Subscription não é um mecanismo direto de criação.'),
('7f260000-0000-4000-8000-000000000040','As duas ferramentas são Resource Providers diferentes para Virtual Machines.','Portal e CLI são interfaces clientes; Microsoft.Compute é o provider relacionado à VM.'),
('7f260000-0000-4000-8000-000000000045','ARM é a camada de gerenciamento; ARM Template é um arquivo declarativo.','Correta. Um é o serviço que processa solicitações e o outro é uma definição de deployment.'),
('7f260000-0000-4000-8000-000000000046','ARM é um arquivo JSON; ARM Template é o serviço que executa o deployment.','A alternativa inverte a camada de gerenciamento e o documento declarativo.'),
('7f260000-0000-4000-8000-000000000047','ARM e ARM Template são nomes equivalentes para o mesmo componente.','ARM processa templates, mas não é o próprio arquivo.'),
('7f260000-0000-4000-8000-000000000048','ARM define apenas permissões; ARM Template fornece tipos de recurso.','RBAC trata permissões, e Resource Providers fornecem tipos; a distinção proposta está incorreta.'),
('7f260000-0000-4000-8000-000000000053','O portal enviou a solicitação por Azure Resource Manager.','Correta. A experiência visual continua usando a camada ARM.'),
('7f260000-0000-4000-8000-000000000054','O portal criou a VM diretamente e usou ARM apenas para mostrar o resultado.','ARM processa a solicitação de gerenciamento, não somente a visualização posterior.'),
('7f260000-0000-4000-8000-000000000055','O portal atuou como Resource Provider da VM e substituiu Microsoft.Compute.','Portal é interface cliente; não substitui o Resource Provider do serviço.'),
('7f260000-0000-4000-8000-000000000056','ARM seria usado apenas se a mesma VM fosse criada por CLI ou PowerShell.','Portal, CLI e PowerShell usam a camada comum Azure Resource Manager.'),
('7f260000-0000-4000-8000-000000000057','Bicep e ARM Templates são declarativos, usam ARM e representam formatos diferentes.','Correta. Reconhecer a relação preserva o conceito de IaC exigido.'),
('7f260000-0000-4000-8000-000000000058','Bicep substitui Azure Resource Manager, enquanto ARM Templates ainda dependem dele.','Bicep também usa Azure Resource Manager para deployments.'),
('7f260000-0000-4000-8000-000000000059','Bicep é declarativo, enquanto ARM Templates executam apenas sequências imperativas.','ARM Templates também descrevem recursos de forma declarativa.'),
('7f260000-0000-4000-8000-000000000060','Bicep e ARM Templates usam JSON como formato de autoria.','ARM Templates usam JSON; Bicep possui sua própria linguagem e sintaxe.'),
('7f290000-0000-4000-8000-000000000009','Azure Monitor Logs.','Logs registram eventos e detalhes, mas não são o recurso mais direto para comparar uma série numérica de CPU.'),
('7f290000-0000-4000-8000-000000000010','Azure Monitor Metrics.','Correta. Metrics apresenta valores numéricos ao longo do tempo.'),
('7f290000-0000-4000-8000-000000000011','Azure Resource Health.','Resource Health informa a condição de disponibilidade do recurso, não a série temporal de uso de CPU.'),
('7f290000-0000-4000-8000-000000000012','Azure Advisor.','Advisor fornece recomendações, mas não é a fonte direta da série temporal solicitada.'),
('7f290000-0000-4000-8000-000000000025','Logs são séries numéricas; Metrics registram eventos com detalhes textuais.','A alternativa inverte as características predominantes das duas fontes.'),
('7f290000-0000-4000-8000-000000000026','Logs trazem eventos detalhados; Metrics representam séries temporais numéricas.','Correta. Essa é a distinção conceitual entre as fontes.'),
('7f290000-0000-4000-8000-000000000027','Logs e Metrics contêm o mesmo formato e diferem apenas no período de retenção.','As fontes possuem modelos e finalidades distintas, não apenas retenções diferentes.'),
('7f290000-0000-4000-8000-000000000028','Metrics são exclusivas de aplicações; Logs são exclusivos de máquinas virtuais.','Ambas podem ser usadas por diferentes tipos de recursos e aplicações.'),
('7f290000-0000-4000-8000-000000000033','KQL provisiona o workspace e define sua capacidade de armazenamento.','Provisionamento do workspace não é a finalidade da linguagem de consulta.'),
('7f290000-0000-4000-8000-000000000034','KQL consulta e analisa dados de log no Log Analytics.','Correta. A linguagem é usada para trabalhar com dados armazenados em tabelas de logs.'),
('7f290000-0000-4000-8000-000000000035','KQL coleta metrics dos recursos sem uma configuração de monitoramento.','KQL consulta dados disponíveis; não substitui a coleta de telemetria.'),
('7f290000-0000-4000-8000-000000000036','KQL calcula o custo dos dados retidos no workspace.','A linguagem pode analisar dados, mas a estimativa de preço não é sua função conceitual.'),
('7f290000-0000-4000-8000-000000000037','Log Analytics é a plataforma completa, e Azure Monitor é apenas sua linguagem de consulta.','Azure Monitor é a plataforma ampla, e KQL é a linguagem de consulta usada no Log Analytics.'),
('7f290000-0000-4000-8000-000000000038','Log Analytics é uma experiência para consultar logs dentro do Azure Monitor.','Correta. Ele é uma parte do ecossistema de monitoramento, não seu sinônimo completo.'),
('7f290000-0000-4000-8000-000000000039','Log Analytics armazena somente metrics, enquanto Azure Monitor mantém apenas logs.','A distinção não separa a plataforma e a experiência dessa forma.'),
('7f290000-0000-4000-8000-000000000040','Log Analytics substitui Azure Monitor quando um workspace é criado.','Criar um workspace não substitui a plataforma de monitoramento.'),
('7f290000-0000-4000-8000-000000000041','Azure Advisor recommendation.','Advisor recomenda melhorias; não avalia continuamente um sinal para reagir à condição.'),
('7f290000-0000-4000-8000-000000000042','Azure Monitor alert rule.','Correta. A regra avalia o sinal e pode acionar notificações ou ações.'),
('7f290000-0000-4000-8000-000000000043','Azure Resource Health event.','Resource Health comunica a condição de um recurso, mas não substitui a regra configurável descrita.'),
('7f290000-0000-4000-8000-000000000044','Azure Monitor metric.','A metric pode ser o sinal avaliado, mas sozinha não define a condição nem a ação.'),
('7f290000-0000-4000-8000-000000000045','Sinal → condição avaliada → alerta acionado → notificação ou ação.','Correta. Essa sequência representa o fluxo conceitual.'),
('7f290000-0000-4000-8000-000000000046','Condição → notificação → coleta do sinal → criação da regra.','A coleta e a regra precisam existir antes que a condição gere uma notificação.'),
('7f290000-0000-4000-8000-000000000047','Recomendação → alteração automática → metric → alerta.','Recomendação do Advisor não é a etapa inicial necessária de um Monitor alert.'),
('7f290000-0000-4000-8000-000000000048','Ação → Resource Health → condição → coleta de logs.','A sequência não representa a avaliação de um sinal por uma regra de alerta.'),
('7f290000-0000-4000-8000-000000000053','Metric é um sinal numérico; alert avalia condições sobre sinais.','Correta. O alert usa sinais e pode acionar uma resposta.'),
('7f290000-0000-4000-8000-000000000054','Metric é a notificação; alert é o valor numérico armazenado.','A alternativa inverte o sinal medido e o mecanismo de avaliação.'),
('7f290000-0000-4000-8000-000000000055','Metric e alert são duas formas de armazenar a mesma série temporal.','A metric armazena valores; o alert avalia condições e não é outra cópia da série.'),
('7f290000-0000-4000-8000-000000000056','Alert coleta a telemetria; metric define quem recebe a ação.','A coleta produz o sinal, e a regra de alerta define condições e ações.'),
('7f290000-0000-4000-8000-000000000057','Cada ponto de telemetria cria uma notificação padrão, mesmo sem regra.','A coleta não cria automaticamente notificações para cada dado.'),
('7f290000-0000-4000-8000-000000000058','A equipe precisa configurar alert rules com condições e ações adequadas.','Correta. A regra transforma sinais avaliados em alertas e respostas.'),
('7f290000-0000-4000-8000-000000000059','Somente logs geram notificações sem regra; metrics exigem condições.','Logs e metrics podem ser sinais, mas as notificações dependem de configuração de alerta.'),
('7f290000-0000-4000-8000-000000000060','A equipe precisa habilitar Azure Advisor, que converte toda telemetria em alertas.','Advisor oferece recomendações e não substitui as regras do Azure Monitor Alerts.');

update public.question_options option
set option_text = seed.option_text,
    explanation = seed.explanation
from az900_quality_option_seed seed
where option.id = seed.id;

create temp table az900_postaudit_question_seed_a (
  id uuid primary key,
  classification text not null,
  question_text text not null,
  explanation text not null
) on commit drop;

create temp table az900_postaudit_option_seed_a (
  id uuid primary key,
  option_text text not null,
  explanation text not null
) on commit drop;

insert into az900_postaudit_question_seed_a (id, classification, question_text, explanation)
values
  ('60000000-0000-4000-8000-000000000004', 'D', 'Uma organização precisa escolher uma Azure Region para uma carga de trabalho sujeita a requisitos de residência de dados e baixa latência. Qual conjunto de fatores deve orientar a decisão?', 'A escolha de uma Azure Region deve considerar em conjunto latência, disponibilidade regional dos serviços e SKUs necessários, residência de dados, compliance, custos e opções de resiliência. Avaliar apenas um subconjunto pode inviabilizar requisitos técnicos ou regulatórios.'),
  ('60000000-0000-4000-8000-000000000008', 'D', 'Uma equipe compara Azure App Service com uma Azure Virtual Machine para hospedar a mesma aplicação. Qual diferença operacional é correta?', 'Azure App Service é uma oferta PaaS: a Microsoft administra a plataforma e grande parte do sistema operacional. Em uma Azure VM, o cliente controla e mantém o sistema operacional convidado, além da aplicação e dos dados.'),
  ('61000000-0000-4000-8000-000000000001', 'C', 'Qual definição descreve corretamente uma Azure Availability Zone?', 'Uma Availability Zone é formada por um ou mais datacenters fisicamente separados dentro de uma Azure Region. As zonas possuem energia, refrigeração e rede independentes para reduzir falhas correlacionadas.'),
  ('61000000-0000-4000-8000-000000000002', 'D', 'Qual alternativa diferencia corretamente um recurso zonal de um recurso com redundância de zona?', 'Um recurso zonal é implantado em uma zona escolhida. Quando o serviço oferece suporte à redundância de zona, a plataforma distribui ou replica o recurso entre várias zonas da mesma região.'),
  ('62000000-0000-4000-8000-000000000003', 'B', 'Em cloud computing, o que caracteriza o acesso amplo à rede (broad network access)?', 'Acesso amplo à rede significa que os recursos de nuvem ficam disponíveis por mecanismos de rede padronizados e podem ser usados por diferentes tipos de dispositivo, como computadores, tablets e smartphones.'),
  ('62000000-0000-4000-8000-000000000006', 'B', 'Um funcionário precisa acessar os sistemas corporativos de casa, de um hotel e do escritório, usando diferentes dispositivos. Qual característica de cloud computing viabiliza esse cenário?', 'Acesso amplo à rede permite acessar serviços de nuvem por mecanismos de rede padronizados e por diferentes dispositivos. A autorização de acesso continua sujeita aos controles de identidade e segurança da organização.'),
  ('62000000-0000-4000-8000-000000000012', 'B', 'No modelo de responsabilidade compartilhada, quem é responsável pela segurança física dos datacenters, independentemente do tipo de serviço contratado?', 'O provedor de nuvem controla e protege a infraestrutura física de seus datacenters, incluindo instalações, energia e refrigeração, tanto em IaaS como em PaaS e SaaS.'),
  ('62000000-0000-4000-8000-000000000017', 'D', 'Ao migrar uma carga de IaaS para SaaS, como a divisão de responsabilidades normalmente muda?', 'Em SaaS, o provedor administra mais camadas da pilha do que em IaaS. A parcela operacional do cliente diminui, embora ele continue responsável por aspectos como dados, identidades, acessos e configurações de uso.'),
  ('62000000-0000-4000-8000-000000000018', 'D', 'Nos modelos IaaS, PaaS e SaaS, quem gerencia o sistema operacional que sustenta o serviço?', 'Em IaaS, o cliente gerencia o sistema operacional convidado de suas máquinas virtuais. Em PaaS e SaaS, o provedor gerencia o sistema operacional subjacente.'),
  ('62000000-0000-4000-8000-000000000051', 'D', 'O que significa a sigla CapEx no contexto de investimentos em TI?', 'CapEx significa Capital Expenditure, ou despesa de capital. Em TI, normalmente representa investimento em ativos de longo prazo, como a compra de servidores físicos.'),
  ('62000000-0000-4000-8000-000000000052', 'D', 'O que significa a sigla OpEx no contexto de custos de TI?', 'OpEx significa Operational Expenditure, ou despesa operacional. Serviços de nuvem cobrados de forma recorrente conforme o consumo são um exemplo típico de OpEx.'),
  ('62000000-0000-4000-8000-000000000053', 'B', 'Qual alternativa representa um exemplo típico de despesa classificada como CapEx?', 'A compra de servidores físicos para um datacenter próprio é um investimento em ativos de longo prazo e constitui um exemplo típico de CapEx. Cobranças recorrentes ou baseadas no consumo são normalmente OpEx.'),
  ('62000000-0000-4000-8000-000000000059', 'D', 'Ao comparar financeiramente um datacenter próprio com serviços de nuvem pagos por consumo, qual análise sustenta uma decisão de longo prazo?', 'O custo total de propriedade, ou TCO, compara despesas de aquisição, operação, manutenção, energia, pessoal, crescimento e consumo ao longo de um horizonte relevante, em vez de considerar apenas os desembolsos iniciais.'),
  ('62000000-0000-4000-8000-000000000060', 'D', 'Uma empresa tem demanda variável e precisa preservar flexibilidade financeira no curto prazo. Qual abordagem é mais compatível com esse objetivo?', 'Serviços de nuvem pagos conforme o uso adotam um modelo OpEx que acompanha melhor variações de demanda e evita comprometer antecipadamente capital em capacidade ociosa. Budgets e monitoramento continuam necessários.'),
  ('62000000-0000-4000-8000-000000000061', 'D', 'Qual definição descreve corretamente serverless computing?', 'Em serverless computing, o provedor gerencia a infraestrutura de execução, o provisionamento e o escalonamento. O cliente desenvolve e configura o código ou serviço sem administrar os servidores subjacentes.'),
  ('62000000-0000-4000-8000-000000000065', 'D', 'Uma API recebe poucas chamadas na maior parte do tempo, mas enfrenta picos imprevisíveis. Qual característica de serverless atende diretamente a esse padrão?', 'Em serverless, o provedor ajusta a capacidade de execução de acordo com o volume de solicitações. Isso permite atender a picos sem provisionar manualmente servidores nem manter capacidade fixa para a maior carga.'),
  ('62000000-0000-4000-8000-000000000074', 'D', 'Durante um pico de acessos, um servidor de e-commerce falha e o tráfego é redirecionado automaticamente para outra instância saudável. Qual princípio é demonstrado?', 'Redundância com failover mantém instâncias alternativas disponíveis e redireciona o tráfego quando uma delas falha. O objetivo é preservar a disponibilidade, não ajustar capacidade em resposta à demanda.'),
  ('62000000-0000-4000-8000-000000000083', 'B', 'O que é escalabilidade horizontal (scale out) em cloud computing?', 'Escalabilidade horizontal, ou scale out, adiciona instâncias para distribuir a carga de trabalho. A remoção de instâncias quando a demanda cai é chamada scale in.'),
  ('62000000-0000-4000-8000-000000000084', 'B', 'Uma aplicação web está lenta e a equipe adiciona servidores idênticos para dividir as requisições. Qual tipo de escalabilidade está sendo aplicado?', 'Adicionar instâncias para distribuir a carga caracteriza escalabilidade horizontal, ou scale out. Aumentar CPU ou memória de um único servidor seria escalabilidade vertical.'),
  ('62000000-0000-4000-8000-000000000085', 'B', 'Um banco de dados precisa de mais capacidade, e a equipe aumenta a CPU e a memória do servidor existente. Qual tipo de escalabilidade está sendo aplicado?', 'Aumentar os recursos de uma instância existente caracteriza escalabilidade vertical, ou scale up. Adicionar outras instâncias caracterizaria escalabilidade horizontal.'),
  ('62000000-0000-4000-8000-000000000097', 'D', 'Uma plataforma de transmissão enfrenta picos durante eventos e quer atender à demanda sem manter capacidade máxima fora deles. Qual ação demonstra elasticidade?', 'Elasticidade ajusta recursos conforme a demanda: a plataforma pode ampliar capacidade durante o evento e reduzi-la depois. Manter permanentemente a capacidade máxima é escalabilidade sem elasticidade.'),
  ('62000000-0000-4000-8000-000000000106', 'B', 'Uma equipe simula falhas em componentes críticos para verificar se os mecanismos de recuperação funcionam. Qual conceito essa prática ajuda a validar?', 'A simulação controlada de falhas verifica se redundância, failover e recuperação funcionam como planejado. Esses testes ajudam a validar a confiabilidade da solução.'),
  ('62000000-0000-4000-8000-000000000112', 'B', 'A previsibilidade em cloud computing geralmente é dividida em quais duas dimensões principais?', 'A previsibilidade em cloud computing abrange desempenho, relacionado ao comportamento esperado da carga, e custos, relacionado à estimativa e ao controle dos gastos.'),
  ('62000000-0000-4000-8000-000000000114', 'B', 'Uma empresa configura alertas que notificam a equipe quando os gastos se aproximam do limite do orçamento. Qual dimensão da previsibilidade essa prática reforça?', 'Alertas de orçamento ajudam a acompanhar gastos e agir antes que o limite planejado seja ultrapassado. Portanto, reforçam diretamente a previsibilidade de custos.'),
  ('63000000-0000-4000-8000-000000000011', 'B', 'O que a autenticação verifica?', 'A autenticação confirma quem é a identidade apresentada por uma pessoa, um dispositivo, uma aplicação ou uma carga de trabalho. Ela não determina, por si só, quais ações são permitidas.'),
  ('63000000-0000-4000-8000-000000000012', 'B', 'O que a autorização determina?', 'A autorização determina quais recursos uma identidade autenticada pode acessar e quais ações pode executar. A autenticação ocorre antes para verificar a identidade.'),
  ('63000000-0000-4000-8000-000000000032', 'D', 'Um servidor Linux habilitado para Azure Arc precisa estar hospedado no Azure?', 'Não. Um servidor habilitado para Azure Arc pode continuar em um datacenter próprio, em um ambiente de borda ou em outro provedor de nuvem e ser projetado no plano de gerenciamento do Azure.'),
  ('63000000-0000-4000-8000-000000000033', 'D', 'Qual cenário representa uma estratégia multicloud?', 'Multicloud usa serviços de mais de um provedor de nuvem, como Azure e outro provedor. Usar várias regiões, zonas ou assinaturas do mesmo provedor não caracteriza multicloud.'),
  ('63000000-0000-4000-8000-000000000038', 'D', 'Qual afirmação descreve corretamente capacidades do Azure Arc?', 'As capacidades do Azure Arc variam conforme o tipo de recurso conectado e sua configuração. Recursos compatíveis podem receber inventário, organização, Azure Policy e integrações de gerenciamento aplicáveis, sem paridade automática com todos os recursos nativos do Azure.' );

insert into az900_postaudit_option_seed_a (id, option_text, explanation)
values
  ('70000000-0000-4000-8000-000000000014', 'Latência, residência de dados e custos, sem verificar a oferta regional de serviços.', 'Incorreta. A região pode atender a latência e compliance, mas não oferecer o serviço ou a SKU exigida pela solução.'),
  ('70000000-0000-4000-8000-000000000015', 'Preço, descontos e proximidade dos usuários, sem avaliar requisitos regulatórios.', 'Incorreta. Preço e proximidade não substituem a validação de residência de dados e compliance.'),
  ('70000000-0000-4000-8000-000000000016', 'Resiliência, redundância e capacidade, sem verificar latência ou residência de dados.', 'Incorreta. Resiliência e capacidade não eliminam requisitos de desempenho nem obrigações sobre localização dos dados.'),
  ('70000000-0000-4000-8000-000000000013', 'Latência, oferta de serviços, residência de dados, compliance, custos e resiliência.', 'Correta. O conjunto cobre fatores técnicos, regulatórios, financeiros e de continuidade que variam entre regiões.'),

  ('70000000-0000-4000-8000-000000000030', 'Nos dois serviços, o cliente gerencia o sistema operacional convidado.', 'Incorreta. Na VM, o cliente gerencia o sistema operacional convidado; no App Service, essa camada faz parte da plataforma gerenciada.'),
  ('70000000-0000-4000-8000-000000000031', 'Na VM, a Microsoft gerencia o código e os dados da aplicação.', 'Incorreta. O cliente continua responsável pelo código, pelos dados e pelas configurações da aplicação hospedada na VM.'),
  ('70000000-0000-4000-8000-000000000032', 'No App Service, o cliente aplica patches no sistema operacional convidado.', 'Incorreta. O App Service abstrai o sistema operacional subjacente, cuja manutenção é responsabilidade da Microsoft.'),
  ('70000000-0000-4000-8000-000000000029', 'O App Service fornece uma plataforma gerenciada; na VM, o cliente mantém o sistema operacional convidado.', 'Correta. A diferença reflete o modelo PaaS do App Service e o maior controle e responsabilidade do cliente em IaaS.'),

  ('71000000-0000-4000-8000-000000000002', 'Duas Azure Regions emparelhadas para recuperação de desastre.', 'Incorreta. Uma Availability Zone fica dentro de uma região; duas regiões constituem um escopo geográfico diferente.'),
  ('71000000-0000-4000-8000-000000000003', 'Um datacenter individual escolhido diretamente pelo cliente.', 'Incorreta. Uma zona pode conter um ou mais datacenters e é selecionada como zona lógica, não como instalação física específica.'),
  ('71000000-0000-4000-8000-000000000001', 'Um ou mais datacenters separados, com energia, refrigeração e rede independentes.', 'Correta. Esse isolamento físico dentro da região reduz o risco de uma única falha afetar várias zonas.'),
  ('71000000-0000-4000-8000-000000000004', 'Um conjunto de recursos replicados automaticamente entre duas regiões.', 'Incorreta. Uma Availability Zone é infraestrutura física dentro de uma região e não implica replicação automática entre regiões.'),

  ('71000000-0000-4000-8000-000000000006', 'O recurso zonal usa a região inteira; o redundante de zona usa uma única zona.', 'Incorreta. A relação está invertida: o recurso zonal ocupa uma zona específica, enquanto a redundância de zona abrange várias zonas.'),
  ('71000000-0000-4000-8000-000000000007', 'Os dois ficam em uma única zona; muda apenas quem escolhe a região.', 'Incorreta. Um recurso com redundância de zona usa várias zonas quando o serviço oferece essa capacidade.'),
  ('71000000-0000-4000-8000-000000000008', 'O recurso redundante de zona é replicado para uma região secundária.', 'Incorreta. Redundância de zona opera entre zonas da mesma região; redundância geográfica envolve outra região.'),
  ('71000000-0000-4000-8000-000000000005', 'O recurso zonal usa uma zona; o redundante de zona usa várias zonas.', 'Correta. A primeira implantação é vinculada a uma zona, enquanto a segunda distribui ou replica o recurso entre zonas suportadas.'),

  ('73000000-0000-4000-8000-000000000011', 'Os recursos ficam disponíveis pela rede e podem ser acessados por diversos tipos de dispositivo.', 'Correta. Broad network access usa mecanismos padronizados para oferecer acesso por clientes heterogêneos.'),
  ('73000000-0000-4000-8000-000000000009', 'Os recursos só podem ser acessados pela rede interna da organização.', 'Incorreta. Essa restrição não representa a disponibilidade ampla por mecanismos de rede padronizados.'),
  ('73000000-0000-4000-8000-000000000010', 'O acesso é restrito a dispositivos com um sistema operacional específico.', 'Incorreta. O conceito prevê acesso por diferentes tipos de cliente e não depende de um único sistema operacional.'),
  ('73000000-0000-4000-8000-000000000012', 'O acesso exige hardware dedicado fornecido pelo provedor de nuvem.', 'Incorreta. Broad network access não exige um dispositivo físico exclusivo do provedor.'),

  ('73000000-0000-4000-8000-000000000021', 'Elasticidade de recursos computacionais.', 'Incorreta. Elasticidade ajusta capacidade conforme a demanda; não define o uso do serviço por redes e dispositivos variados.'),
  ('73000000-0000-4000-8000-000000000022', 'Responsabilidade compartilhada entre cliente e provedor.', 'Incorreta. Responsabilidade compartilhada distribui tarefas de segurança e operação; não descreve a forma de acesso.'),
  ('73000000-0000-4000-8000-000000000024', 'Conversão de despesas CapEx em OpEx.', 'Incorreta. O modelo financeiro não explica o acesso a partir de locais e dispositivos diferentes.'),
  ('73000000-0000-4000-8000-000000000023', 'Acesso amplo à rede.', 'Correta. Essa característica permite usar o serviço por mecanismos de rede padronizados em diferentes dispositivos.'),

  ('73000000-0000-4000-8000-000000000046', 'O cliente que contrata o serviço.', 'Incorreta. O cliente protege dados, identidades e configurações sob seu controle, mas não opera a segurança física do datacenter do provedor.'),
  ('73000000-0000-4000-8000-000000000045', 'O provedor de nuvem.', 'Correta. A infraestrutura física permanece sob controle e responsabilidade do provedor em todos os modelos de serviço.'),
  ('73000000-0000-4000-8000-000000000047', 'Uma empresa de segurança contratada pelo cliente.', 'Incorreta. Eventuais fornecedores do provedor não transferem ao cliente a responsabilidade pela instalação física.'),
  ('73000000-0000-4000-8000-000000000048', 'Um órgão regulador externo ao provedor.', 'Incorreta. O órgão pode estabelecer ou fiscalizar requisitos, mas não opera a segurança física do datacenter.'),

  ('73000000-0000-4000-8000-000000000066', 'A parcela do cliente aumenta, pois ele passa a administrar mais camadas.', 'Incorreta. A migração para SaaS reduz as camadas técnicas administradas pelo cliente.'),
  ('73000000-0000-4000-8000-000000000067', 'As parcelas permanecem iguais nos dois modelos de serviço.', 'Incorreta. O provedor assume mais camadas em SaaS do que em IaaS.'),
  ('73000000-0000-4000-8000-000000000065', 'A parcela do cliente diminui, pois o provedor administra mais camadas em SaaS.', 'Correta. O provedor passa a gerenciar aplicação e infraestrutura subjacente, enquanto o cliente conserva responsabilidades sobre seus dados e acessos.'),
  ('73000000-0000-4000-8000-000000000068', 'O cliente deixa de ser responsável por identidades e dados.', 'Incorreta. Dados, identidades e acessos continuam sendo responsabilidades do cliente mesmo em SaaS.'),

  ('73000000-0000-4000-8000-000000000069', 'O cliente gerencia o sistema operacional nos três modelos.', 'Incorreta. Em PaaS e SaaS, o sistema operacional subjacente é gerenciado pelo provedor.'),
  ('73000000-0000-4000-8000-000000000070', 'O provedor gerencia o sistema operacional nos três modelos.', 'Incorreta. Em IaaS, o cliente administra o sistema operacional convidado.'),
  ('73000000-0000-4000-8000-000000000072', 'O cliente gerencia o sistema operacional em PaaS, mas não em IaaS.', 'Incorreta. Essa divisão está invertida: o cliente gerencia o sistema operacional em IaaS e o provedor o gerencia em PaaS.'),
  ('73000000-0000-4000-8000-000000000071', 'O cliente gerencia o sistema operacional em IaaS; o provedor o gerencia em PaaS e SaaS.', 'Correta. O nível de abstração aumenta de IaaS para PaaS e SaaS, transferindo essa camada ao provedor.'),

  ('73000000-0000-4000-8000-000000000202', 'Capital Expenditure.', 'Correta. CapEx é a sigla de Capital Expenditure, que significa despesa de capital.'),
  ('73000000-0000-4000-8000-000000000201', 'Capacity Expenditure.', 'Incorreta. Capacity Expenditure não é a expansão correspondente à sigla CapEx.'),
  ('73000000-0000-4000-8000-000000000203', 'Contract Expenditure.', 'Incorreta. Contract Expenditure não é o significado contábil de CapEx.'),
  ('73000000-0000-4000-8000-000000000204', 'Connectivity Expenditure.', 'Incorreta. Connectivity Expenditure não corresponde à sigla CapEx.'),

  ('73000000-0000-4000-8000-000000000206', 'Optimization Expenditure.', 'Incorreta. Optimization Expenditure não é o significado contábil da sigla OpEx.'),
  ('73000000-0000-4000-8000-000000000205', 'Operational Expenditure.', 'Correta. OpEx é a sigla de Operational Expenditure, que significa despesa operacional.'),
  ('73000000-0000-4000-8000-000000000207', 'Ownership Expenditure.', 'Incorreta. Ownership Expenditure não corresponde à sigla OpEx.'),
  ('73000000-0000-4000-8000-000000000208', 'Provisioning Expenditure.', 'Incorreta. Provisioning Expenditure não é a expansão de OpEx.'),

  ('73000000-0000-4000-8000-000000000209', 'Pagamento mensal de armazenamento em nuvem.', 'Incorreta. Uma cobrança recorrente por serviço normalmente é classificada como OpEx.'),
  ('73000000-0000-4000-8000-000000000210', 'Cobrança de uma máquina virtual por hora de uso.', 'Incorreta. Uma cobrança variável conforme o consumo normalmente é uma despesa operacional.'),
  ('73000000-0000-4000-8000-000000000212', 'Compra de servidores físicos para um datacenter próprio.', 'Correta. A aquisição cria ativos de longo prazo e representa um exemplo típico de CapEx.'),
  ('73000000-0000-4000-8000-000000000211', 'Cobrança por transferência de dados entre regiões.', 'Incorreta. A cobrança pelo consumo de transferência é normalmente OpEx, não aquisição de ativo de capital.'),

  ('73000000-0000-4000-8000-000000000234', 'Comparar o custo total de propriedade no horizonte relevante.', 'Correta. O TCO inclui os custos de aquisição e os custos recorrentes de operar cada alternativa ao longo do tempo.'),
  ('73000000-0000-4000-8000-000000000233', 'Comparar apenas o desembolso inicial de cada alternativa.', 'Incorreta. O desembolso inicial não captura manutenção, operação, crescimento nem consumo futuro.'),
  ('73000000-0000-4000-8000-000000000235', 'Comparar aquisição e primeira fatura, excluindo custos operacionais.', 'Incorreta. Uma análise de longo prazo precisa incluir os custos de operação de ambas as alternativas.'),
  ('73000000-0000-4000-8000-000000000236', 'Comparar CPU e preço mensal, sem projetar manutenção ou crescimento.', 'Incorreta. Capacidade e preço mensal isolados não representam o custo total de propriedade.'),

  ('73000000-0000-4000-8000-000000000237', 'Adquirir em CapEx toda a capacidade estimada para os próximos anos.', 'Incorreta. Essa aquisição compromete capital antecipadamente e pode deixar capacidade ociosa quando a demanda variar.'),
  ('73000000-0000-4000-8000-000000000240', 'Adotar OpEx com serviços de nuvem pagos conforme o uso.', 'Correta. O consumo sob demanda reduz o compromisso inicial e permite que o gasto acompanhe mais de perto a utilização.'),
  ('73000000-0000-4000-8000-000000000238', 'Usar pay-as-you-go sem budgets nem monitoramento de custos.', 'Incorreta. A flexibilidade de consumo não elimina a necessidade de acompanhar e controlar os gastos.'),
  ('73000000-0000-4000-8000-000000000239', 'Financiar infraestrutura fixa para dez anos antes de validar a demanda.', 'Incorreta. O compromisso de longo prazo reduz a flexibilidade financeira diante de demanda incerta.'),

  ('73000000-0000-4000-8000-000000000242', 'Um modelo em que não existem servidores físicos no provedor.', 'Incorreta. Os servidores existem, mas sua administração fica abstraída para o cliente.'),
  ('73000000-0000-4000-8000-000000000243', 'Um modelo em que o cliente aplica patches nos servidores de cada função.', 'Incorreta. A manutenção da infraestrutura subjacente é responsabilidade do provedor.'),
  ('73000000-0000-4000-8000-000000000241', 'Um modelo em que o provedor gerencia a infraestrutura de execução e o escalonamento.', 'Correta. O cliente se concentra no código ou serviço, enquanto o provedor provisiona e escala a infraestrutura subjacente.'),
  ('73000000-0000-4000-8000-000000000244', 'Um modelo restrito a conteúdo estático, sem execução acionada por eventos.', 'Incorreta. Serverless também executa código sob demanda em resposta a eventos e solicitações.'),

  ('73000000-0000-4000-8000-000000000258', 'Configurar manualmente novos servidores antes de cada pico.', 'Incorreta. Essa abordagem exige previsão e intervenção manual, ao contrário do escalonamento gerenciado de serverless.'),
  ('73000000-0000-4000-8000-000000000259', 'Manter capacidade fixa dimensionada para o maior pico possível.', 'Incorreta. Capacidade fixa para o pico desperdiçaria recursos durante os períodos de poucas chamadas.'),
  ('73000000-0000-4000-8000-000000000257', 'Usar escalonamento gerenciado conforme o volume de chamadas.', 'Correta. O provedor ajusta a capacidade de execução para acompanhar a variação de solicitações.'),
  ('73000000-0000-4000-8000-000000000260', 'Suspender a API em horários programados de baixa demanda.', 'Incorreta. Uma suspensão programada não responde aos picos imprevisíveis e pode tornar a API indisponível.'),

  ('73000000-0000-4000-8000-000000000293', 'Elasticidade para ajustar capacidade ao volume de acessos.', 'Incorreta. O cenário descreve a substituição de uma instância com falha, não uma mudança de capacidade causada pela demanda.'),
  ('73000000-0000-4000-8000-000000000294', 'Consumo baseado no uso para cobrar apenas a instância ativa.', 'Incorreta. O comportamento observado trata de continuidade do serviço, não do modelo de cobrança.'),
  ('73000000-0000-4000-8000-000000000296', 'Responsabilidade compartilhada para dividir a correção da falha.', 'Incorreta. Responsabilidade compartilhada distribui obrigações entre cliente e provedor, mas não é o mecanismo de redirecionamento.'),
  ('73000000-0000-4000-8000-000000000295', 'Redundância com failover automático.', 'Correta. Uma instância alternativa recebe o tráfego quando a instância original falha.'),

  ('73000000-0000-4000-8000-000000000331', 'Adicionar instâncias para distribuir a carga.', 'Correta. Scale out amplia a capacidade por meio de mais instâncias.'),
  ('73000000-0000-4000-8000-000000000329', 'Aumentar CPU e memória de uma única instância.', 'Incorreta. Aumentar recursos de uma instância é escalabilidade vertical, ou scale up.'),
  ('73000000-0000-4000-8000-000000000330', 'Reduzir o número de instâncias em execução.', 'Incorreta. Remover instâncias é scale in, o sentido oposto ao scale out perguntado.'),
  ('73000000-0000-4000-8000-000000000332', 'Substituir o sistema por outro produto.', 'Incorreta. Trocar o produto não define uma estratégia de escalabilidade horizontal.'),

  ('73000000-0000-4000-8000-000000000333', 'Escalabilidade vertical.', 'Incorreta. Escalabilidade vertical aumenta recursos de um único servidor; o cenário adiciona servidores.'),
  ('73000000-0000-4000-8000-000000000336', 'Escalabilidade horizontal.', 'Correta. A equipe executa scale out ao adicionar instâncias para repartir as requisições.'),
  ('73000000-0000-4000-8000-000000000334', 'Elasticidade com redução automática após o pico.', 'Incorreta. O cenário informa apenas a adição de servidores, sem remoção automática conforme a demanda.'),
  ('73000000-0000-4000-8000-000000000335', 'Alta disponibilidade por failover.', 'Incorreta. Embora várias instâncias também possam favorecer disponibilidade, a ação descrita tem como objetivo dividir a carga.'),

  ('73000000-0000-4000-8000-000000000338', 'Escalabilidade horizontal.', 'Incorreta. Escalabilidade horizontal adicionaria outras instâncias em vez de ampliar a existente.'),
  ('73000000-0000-4000-8000-000000000339', 'Redundância geográfica.', 'Incorreta. Redundância geográfica replica dados ou recursos entre regiões e não descreve o aumento de CPU e memória.'),
  ('73000000-0000-4000-8000-000000000337', 'Escalabilidade vertical.', 'Correta. A equipe executa scale up ao ampliar os recursos da mesma instância.'),
  ('73000000-0000-4000-8000-000000000340', 'Consumo baseado no uso.', 'Incorreta. O modelo de cobrança não define se a capacidade aumenta na mesma instância ou por meio de novas instâncias.'),

  ('73000000-0000-4000-8000-000000000386', 'Manter capacidade máxima durante toda a temporada.', 'Incorreta. A capacidade permaneceria alocada mesmo fora dos picos, sem se ajustar à demanda.'),
  ('73000000-0000-4000-8000-000000000387', 'Aplicar scale up manual antes de cada transmissão.', 'Incorreta. A intervenção manual pode ampliar capacidade, mas não demonstra ajuste elástico conforme a demanda real.'),
  ('73000000-0000-4000-8000-000000000385', 'Aumentar a capacidade durante o evento e reduzi-la depois.', 'Correta. A alocação cresce e diminui para acompanhar a demanda, que é o comportamento elástico.'),
  ('73000000-0000-4000-8000-000000000388', 'Reduzir a qualidade para caber na capacidade fixa.', 'Incorreta. Essa medida adapta a carga à capacidade, em vez de adaptar os recursos à demanda.'),

  ('73000000-0000-4000-8000-000000000421', 'Elasticidade diante de picos de tráfego.', 'Incorreta. O teste altera condições de falha, não a demanda que orienta a elasticidade.'),
  ('73000000-0000-4000-8000-000000000422', 'Consumo baseado no uso.', 'Incorreta. A forma de cobrança não demonstra se a recuperação funciona diante de falhas.'),
  ('73000000-0000-4000-8000-000000000424', 'Previsibilidade de custos.', 'Incorreta. O teste avalia comportamento técnico durante falhas, e não a estimativa de gastos.'),
  ('73000000-0000-4000-8000-000000000423', 'Confiabilidade da solução.', 'Correta. Exercitar falhas permite verificar se os mecanismos de recuperação preservam o funcionamento esperado.'),

  ('73000000-0000-4000-8000-000000000446', 'Disponibilidade e confiabilidade.', 'Incorreta. Esses são benefícios da nuvem, mas não as duas dimensões de previsibilidade.'),
  ('73000000-0000-4000-8000-000000000445', 'Previsibilidade de desempenho e previsibilidade de custos.', 'Correta. As duas dimensões tratam do comportamento da carga e dos gastos esperados.'),
  ('73000000-0000-4000-8000-000000000447', 'Escalabilidade e elasticidade.', 'Incorreta. Esses conceitos descrevem ajuste de capacidade, e não as dimensões de previsibilidade.'),
  ('73000000-0000-4000-8000-000000000448', 'Segurança e governança.', 'Incorreta. Segurança e governança são áreas distintas de previsibilidade de desempenho e custos.'),

  ('73000000-0000-4000-8000-000000000453', 'Previsibilidade de desempenho.', 'Incorreta. Alertas de orçamento acompanham gastos, não latência, throughput ou capacidade.'),
  ('73000000-0000-4000-8000-000000000454', 'Elasticidade.', 'Incorreta. O alerta notifica sobre gastos, mas não adiciona nem remove recursos automaticamente.'),
  ('73000000-0000-4000-8000-000000000456', 'Alta disponibilidade.', 'Incorreta. O alerta não executa failover nem mantém o serviço disponível durante falhas.'),
  ('73000000-0000-4000-8000-000000000455', 'Previsibilidade de custos.', 'Correta. A notificação permite acompanhar a tendência de gastos em relação ao limite planejado.'),

  ('74000000-0000-4000-8000-000000000043', 'A identidade apresentada.', 'Correta. A autenticação verifica quem é a entidade que tenta acessar o ambiente.'),
  ('74000000-0000-4000-8000-000000000041', 'As ações que a identidade pode executar.', 'Incorreta. As ações permitidas são determinadas pela autorização.'),
  ('74000000-0000-4000-8000-000000000042', 'A exigência de MFA por uma política.', 'Incorreta. Uma política de Acesso Condicional pode exigir MFA, mas isso não define o propósito da autenticação.'),
  ('74000000-0000-4000-8000-000000000044', 'O escopo em que uma função é atribuída.', 'Incorreta. O escopo participa da autorização por RBAC e não verifica a identidade.'),

  ('74000000-0000-4000-8000-000000000045', 'A identidade apresentada.', 'Incorreta. Verificar quem é a identidade corresponde à autenticação.'),
  ('74000000-0000-4000-8000-000000000048', 'Os recursos e as ações permitidos para a identidade.', 'Correta. A autorização avalia as permissões concedidas à identidade já autenticada.'),
  ('74000000-0000-4000-8000-000000000046', 'A política que exige MFA.', 'Incorreta. A exigência de MFA é uma condição de autenticação e acesso, não a definição de autorização.'),
  ('74000000-0000-4000-8000-000000000047', 'As aplicações incluídas no SSO.', 'Incorreta. SSO reduz solicitações repetidas de entrada, mas não determina permissões sobre recursos.'),

  ('74000000-0000-4000-8000-000000000125', 'Sim. O Azure Arc oferece suporte apenas a Azure VMs.', 'Incorreta. Azure Arc foi projetado para gerenciar servidores executados fora do Azure, além dos recursos compatíveis no Azure.'),
  ('74000000-0000-4000-8000-000000000126', 'Não. O servidor pode permanecer fora do Azure.', 'Correta. O agente conecta o servidor ao plano de gerenciamento do Azure sem mudar seu local de execução.'),
  ('74000000-0000-4000-8000-000000000127', 'Sim. O agente do Azure Arc migra o sistema operacional para o Azure.', 'Incorreta. O agente conecta o recurso para gerenciamento; ele não migra o servidor nem seu sistema operacional.'),
  ('74000000-0000-4000-8000-000000000128', 'Não. O Azure Arc é restrito a dispositivos de rede.', 'Incorreta. Azure Arc oferece suporte a servidores e outros tipos de recurso compatíveis, não apenas a dispositivos de rede.'),

  ('74000000-0000-4000-8000-000000000130', 'Um datacenter próprio integrado a uma única nuvem.', 'Incorreta. Esse cenário é híbrido porque combina ambiente local e um provedor de nuvem.'),
  ('74000000-0000-4000-8000-000000000131', 'Duas assinaturas do mesmo provedor de nuvem.', 'Incorreta. Múltiplas assinaturas continuam dentro de um único provedor.'),
  ('74000000-0000-4000-8000-000000000129', 'Azure e serviços de outro provedor de nuvem.', 'Correta. O uso de dois provedores de nuvem caracteriza uma estratégia multicloud.'),
  ('74000000-0000-4000-8000-000000000132', 'Duas Azure Regions na mesma assinatura.', 'Incorreta. Regiões diferentes do Azure continuam pertencendo ao mesmo provedor.'),

  ('74000000-0000-4000-8000-000000000150', 'As mesmas extensões e políticas funcionam em todos os recursos conectados.', 'Incorreta. Extensões, políticas e integrações disponíveis variam conforme o tipo de recurso e a configuração.'),
  ('74000000-0000-4000-8000-000000000151', 'O Azure Arc fornece inventário, mas não recursos de governança.', 'Incorreta. Azure Policy e outras integrações de governança podem ser aplicadas a tipos de recurso compatíveis.'),
  ('74000000-0000-4000-8000-000000000152', 'O Azure Arc gerencia exclusivamente clusters Kubernetes.', 'Incorreta. Além de Kubernetes, Azure Arc oferece suporte a servidores e outros recursos compatíveis.'),
  ('74000000-0000-4000-8000-000000000149', 'As capacidades disponíveis dependem do tipo de recurso e da configuração.', 'Correta. Cada tipo de recurso habilitado para Arc possui um conjunto específico de funcionalidades e pré-requisitos.');

update public.questions as question
set
  question_text = seed.question_text,
  explanation = seed.explanation,
  updated_at = now()
from az900_postaudit_question_seed_a as seed
where question.id = seed.id;

update public.question_options as option
set
  option_text = seed.option_text,
  explanation = seed.explanation,
  updated_at = now()
from az900_postaudit_option_seed_a as seed
where option.id = seed.id;


-- Refinamento editorial pós-auditoria: bloco B (29 Questions, 116 Options).
-- Preserva UUIDs, is_correct, display_order e todos os metadados pedagógicos.

create temporary table az900_postaudit_question_seed_b (
  id uuid primary key,
  classification text not null,
  question_text text not null,
  explanation text not null
) on commit drop;

create temporary table az900_postaudit_option_seed_b (
  id uuid primary key,
  option_text text not null,
  explanation text not null
) on commit drop;

insert into az900_postaudit_question_seed_b (id, classification, question_text, explanation) values
  ('63000000-0000-4000-8000-000000000104', 'C', 'Várias VMs precisam acessar os mesmos documentos armazenados em uma Azure Storage Account por meio de um compartilhamento montável via SMB. Qual serviço é apropriado?', 'Azure Files fornece compartilhamentos de arquivos gerenciados que podem ser montados por SMB em várias máquinas autorizadas.'),
  ('65000000-0000-4000-8000-000000000024', 'C', 'Duas VMs na mesma Azure Region precisam ser distribuídas entre agrupamentos lógicos de falha e de atualização para reduzir o risco de indisponibilidade simultânea. Qual recurso atende ao requisito?', 'Um Availability Set distribui VMs entre fault domains e update domains dentro de um datacenter para reduzir falhas correlacionadas e o impacto de manutenção planejada.'),
  ('66000000-0000-4000-8000-000000000008', 'C', 'Uma equipe quer publicar uma Web API ASP.NET Core tradicional em uma plataforma web gerenciada, sem administrar sistema operacional nem cluster de containers. Qual serviço é adequado?', 'Azure App Service é uma oferta PaaS gerenciada para hospedar aplicações web e APIs sem que a equipe administre o sistema operacional subjacente.'),
  ('63000000-0000-4000-8000-000000000062', 'C', 'Duas VMs com a mesma configuração são planejadas em Azure Regions diferentes. O preço precisa ser idêntico?', 'Não. Os preços dos serviços podem variar entre Azure Regions, mesmo quando a configuração técnica é equivalente.'),
  ('63000000-0000-4000-8000-000000000063', 'C', 'Uma aplicação enviará grande volume de dados de uma Azure Region para usuários na Internet. Qual fator deve entrar na estimativa?', 'O volume de transferência de dados de saída deve ser considerado, pois a cobrança pode variar conforme origem, destino e quantidade transferida.'),
  ('63000000-0000-4000-8000-000000000064', 'C', 'Uma equipe dobra de duas para quatro a quantidade de instâncias provisionadas com a mesma configuração e pelo mesmo período. Qual impacto é mais provável?', 'Mantidas as demais condições, aumentar a quantidade de instâncias eleva o consumo de compute e tende a aumentar o custo.'),
  ('63000000-0000-4000-8000-000000000065', 'C', 'Mantendo Region, horas de execução e quantidade de VMs, a equipe seleciona um size com mais vCPUs e memória. Qual fator de preço foi alterado diretamente?', 'O size define a capacidade de compute da VM e pode alterar o preço, mesmo quando Region, duração e quantidade permanecem iguais.'),
  ('63000000-0000-4000-8000-000000000067', 'C', 'Uma VM é desalocada fora do horário comercial, mas seus discos gerenciados são mantidos. Qual conclusão sobre custo é correta?', 'A desalocação pode interromper a cobrança da instância de compute, enquanto discos e outros recursos associados podem continuar gerando custos.'),
  ('63000000-0000-4000-8000-000000000070', 'C', 'Uma carga de compute temporária tolera interrupções e busca reduzir custo. Qual opção pode ser avaliada?', 'Azure Spot Virtual Machines oferecem capacidade ociosa com desconto, mas podem ser removidas quando o Azure precisa recuperar essa capacidade.'),
  ('63000000-0000-4000-8000-000000000118', 'C', 'Por que a forma de escalar e de cobrar uma aplicação no Azure Functions pode variar?', 'Escalabilidade, instâncias disponíveis e cobrança dependem do plano de hospedagem, da configuração e do padrão de execução da aplicação.'),
  ('63000000-0000-4000-8000-000000000119', 'C', 'Uma carga executa continuamente, tem demanda estável e exige controle do ambiente. Qual análise é mais adequada?', 'A escolha deve comparar Functions, containers e VMs considerando modelo de execução, controle operacional, comportamento de escala e custo total.'),
  ('64000000-0000-4000-8000-000000000020', 'C', 'Uma aplicação foi implantada em uma Azure Region que possui um Region Pair, mas nenhuma replicação nem estratégia de failover foi configurada. O que o pareamento faz automaticamente com a aplicação?', 'O Region Pair não replica recursos nem executa failover da aplicação por si só; essas capacidades dependem dos serviços escolhidos e da arquitetura configurada.'),
  ('65000000-0000-4000-8000-000000000012', 'C', 'Um componente executa código quando chegam mensagens a uma fila, possui uso intermitente e deve escalar sem administração de sistema operacional ou cluster. Qual serviço é mais adequado?', 'Azure Functions é apropriado para execução orientada a eventos e escala gerenciada sem exigir administração de sistema operacional ou cluster.'),
  ('65000000-0000-4000-8000-000000000020', 'C', 'Uma equipe desalocou uma Azure VM e concluiu que toda a solução deixou de gerar custos. Qual análise está correta?', 'A desalocação interrompe a cobrança da instância de compute, mas discos gerenciados, endereços IP reservados e outros recursos associados ainda podem ser cobrados.'),
  ('66000000-0000-4000-8000-000000000015', 'C', 'O provedor de nuvem possui certificações de conformidade. O que ainda cabe ao cliente?', 'As certificações do provedor não substituem as responsabilidades do cliente por configuração, acesso, classificação de dados e cumprimento das obrigações aplicáveis à própria solução.'),
  ('63000000-0000-4000-8000-000000000069', 'B', 'Uma empresa quer projetar realisticamente o custo de uma nova aplicação Azure. Qual abordagem é mais adequada?', 'Uma estimativa útil combina os serviços e padrões de uso previstos e é revisada quando as premissas mudam.'),
  ('63000000-0000-4000-8000-000000000072', 'B', 'Um Budget representa o quê no Azure Cost Management?', 'Um Budget define um valor planejado para acompanhar gastos em um período e pode acionar alertas; ele não impõe um limite rígido à cobrança.'),
  ('63000000-0000-4000-8000-000000000074', 'B', 'Uma empresa quer ser avisada quando o gasto atingir 80% do valor planejado. Qual solução atende ao cenário?', 'Um orçamento com alerta configurado no limite de 80% notifica os destinatários quando a condição de custo é atingida.'),
  ('63000000-0000-4000-8000-000000000075', 'B', 'Qual afirmação diferencia custo real de previsão no Azure Cost Management?', 'O custo real registra uso já ocorrido, enquanto a previsão projeta o gasto esperado com base nos dados disponíveis.'),
  ('63000000-0000-4000-8000-000000000076', 'B', 'O custo de um Resource Group aumentou em relação ao mês anterior. Como investigar?', 'Cost Analysis permite comparar períodos, agrupar ou filtrar custos e detalhar os recursos que contribuíram para a variação.'),
  ('64000000-0000-4000-8000-000000000001', 'B', 'O que caracteriza o modelo Software as a Service (SaaS)?', 'Em SaaS, o provedor entrega e opera a aplicação completa; o cliente gerencia principalmente o uso, os dados e as configurações sob sua responsabilidade.'),
  ('64000000-0000-4000-8000-000000000002', 'B', 'Qual das opções a seguir é um exemplo típico de aplicação SaaS?', 'Um serviço de e-mail corporativo pronto para uso pela internet é SaaS porque o provedor opera a aplicação e a infraestrutura subjacente.'),
  ('64000000-0000-4000-8000-000000000011', 'D', 'Qual definição descreve uma Azure Region?', 'Uma Azure Region é uma área geográfica que contém um ou mais datacenters conectados por uma rede de baixa latência.'),
  ('65000000-0000-4000-8000-000000000016', 'B', 'O que é uma máquina virtual no Azure?', 'Uma Azure Virtual Machine é um servidor virtualizado cuja configuração inclui sistema operacional, tamanho e outros parâmetros administrados pelo cliente.'),
  ('68000000-0000-4000-8000-000000000031', 'C', 'Qual alternativa diferencia Virtual Network Peering regional de Global Virtual Network Peering?', 'O peering regional conecta redes virtuais na mesma Azure Region; o Global Virtual Network Peering conecta redes virtuais em Azure Regions diferentes.'),
  ('68000000-0000-4000-8000-000000000033', 'C', 'Qual comparação entre Virtual Network Peering e uma conexão VPN é conceitualmente correta?', 'VNet Peering conecta redes virtuais pelo backbone da Microsoft, enquanto uma VPN estabelece um túnel criptografado por meio de um gateway.'),
  ('68000000-0000-4000-8000-000000000038', 'C', 'Qual comparação entre VPN Gateway e ExpressRoute está correta?', 'VPN Gateway estabelece túneis criptografados sobre conectividade pública; ExpressRoute oferece conexão privada ao backbone da Microsoft por meio de um provedor de conectividade.'),
  ('68000000-0000-4000-8000-000000000043', 'C', 'Qual comparação entre Service Endpoint e Private Endpoint está correta?', 'Um Service Endpoint mantém o endpoint público do serviço e estende a identidade da VNet até ele; um Private Endpoint atribui ao recurso um endereço IP privado na VNet.'),
  ('68000000-0000-4000-8000-000000000186', 'C', 'A equipe quer receber uma notificação quando a utilização de CPU de uma VM superar um limite definido. Qual recurso deve configurar?', 'Azure Monitor Alerts avalia métricas, como utilização de CPU, e pode acionar notificações ou automações quando uma condição é atendida.');

insert into az900_postaudit_option_seed_b (id, option_text, explanation) values
  ('74000000-0000-4000-8000-000000000413', 'Azure Managed Disks.', 'Incorreta. Managed Disks são volumes de armazenamento em bloco associados a VMs e não oferecem um compartilhamento SMB comum a várias máquinas.'),
  ('74000000-0000-4000-8000-000000000416', 'Azure Files.', 'Correta. Azure Files oferece file shares gerenciados que podem ser montados por SMB em várias VMs autorizadas.'),
  ('74000000-0000-4000-8000-000000000414', 'Azure Blob Storage.', 'Incorreta. Blob Storage é armazenamento de objetos acessado por APIs e não fornece diretamente um compartilhamento de arquivos montável via SMB.'),
  ('74000000-0000-4000-8000-000000000415', 'Azure NetApp Files.', 'Incorreta. Azure NetApp Files também oferece armazenamento de arquivos corporativo, mas o requisito Fundamentals de um compartilhamento SMB em uma Storage Account aponta para Azure Files.'),
  ('77000000-0000-4000-8000-000000000093', 'Virtual Machine Scale Set.', 'Incorreta. Um scale set gerencia e escala um conjunto de VMs; o agrupamento explícito em fault domains e update domains é a função de um Availability Set.'),
  ('77000000-0000-4000-8000-000000000095', 'Availability Zone.', 'Incorreta. Uma Availability Zone fornece isolamento físico entre zonas, enquanto o enunciado pede agrupamentos lógicos dentro da mesma região sem exigir isolamento entre datacenters.'),
  ('77000000-0000-4000-8000-000000000094', 'Availability Set.', 'Correta. Availability Sets distribuem VMs entre fault domains e update domains para reduzir indisponibilidade correlacionada.'),
  ('77000000-0000-4000-8000-000000000096', 'Proximity Placement Group.', 'Incorreta. Um Proximity Placement Group aproxima recursos fisicamente para reduzir latência; ele não é o mecanismo pedido para fault domains e update domains.'),
  ('7d000000-0000-4000-8000-000000000030', 'Azure Virtual Machines.', 'Incorreta. VMs permitem hospedar a API, mas deixam a administração do sistema operacional com a equipe.'),
  ('7d000000-0000-4000-8000-000000000031', 'Azure Container Instances.', 'Incorreta. ACI executa containers sem cluster, mas pressupõe uma imagem de container; o cenário pede uma plataforma web gerenciada para uma Web API tradicional.'),
  ('7d000000-0000-4000-8000-000000000032', 'Azure Functions acionado por uma fila.', 'Incorreta. Functions é apropriado para execução orientada a eventos; o requisito descreve uma API web tradicional hospedada continuamente.'),
  ('7d000000-0000-4000-8000-000000000029', 'Azure App Service.', 'Correta. App Service hospeda APIs ASP.NET Core em uma plataforma web gerenciada sem administração do sistema operacional.'),
  ('74000000-0000-4000-8000-000000000245', 'Sim, porque a moeda de cobrança é a mesma.', 'Incorreta. Usar a mesma moeda não torna idênticos os preços praticados em Azure Regions diferentes.'),
  ('74000000-0000-4000-8000-000000000247', 'Sim, desde que as VMs estejam na mesma assinatura.', 'Incorreta. A assinatura organiza cobrança e acesso, mas não elimina diferenças regionais de preço.'),
  ('74000000-0000-4000-8000-000000000248', 'Não, porque a região afeta somente a latência.', 'Incorreta. A escolha da região pode afetar disponibilidade de serviços, latência, residência de dados e também preço.'),
  ('74000000-0000-4000-8000-000000000246', 'Não, porque a Azure Region pode afetar o preço.', 'Correta. A mesma configuração pode ter preços distintos conforme a Azure Region selecionada.'),
  ('74000000-0000-4000-8000-000000000250', 'O volume de dados transferidos para fora do Azure.', 'Correta. O tráfego de saída para a Internet pode gerar cobrança conforme o volume e a origem dos dados.'),
  ('74000000-0000-4000-8000-000000000249', 'A quantidade de registros na zona do Azure DNS.', 'Incorreta. Registros DNS não representam o volume de dados que a aplicação transfere para usuários na Internet.'),
  ('74000000-0000-4000-8000-000000000251', 'A quantidade de Resource Groups usados pela aplicação.', 'Incorreta. Resource Groups são contêineres lógicos e sua quantidade não mede o tráfego de saída.'),
  ('74000000-0000-4000-8000-000000000252', 'A reserva de capacidade de compute da aplicação.', 'Incorreta. Reserva de compute e transferência de dados são fatores de custo distintos; o cenário destaca tráfego de saída.'),
  ('74000000-0000-4000-8000-000000000254', 'Uma reserva existente é cancelada automaticamente.', 'Incorreta. Aumentar instâncias não implica cancelamento automático de reservas; compromissos e cobertura devem ser analisados separadamente.'),
  ('74000000-0000-4000-8000-000000000253', 'O consumo de compute aumenta e o custo tende a subir.', 'Correta. Dobrar instâncias equivalentes pelo mesmo período aumenta o consumo de compute, salvo efeitos específicos de descontos ou compromissos.'),
  ('74000000-0000-4000-8000-000000000255', 'O preço unitário de cada instância cai obrigatoriamente pela metade.', 'Incorreta. Escalar de duas para quatro instâncias não reduz automaticamente o preço unitário pela metade.'),
  ('74000000-0000-4000-8000-000000000256', 'A mudança afeta somente a quantidade exibida no portal.', 'Incorreta. Instâncias adicionais representam recursos provisionados e podem alterar consumo e custo.'),
  ('74000000-0000-4000-8000-000000000258', 'A duração mensal da execução.', 'Incorreta. O stem mantém as horas de execução constantes.'),
  ('74000000-0000-4000-8000-000000000259', 'A Azure Region selecionada.', 'Incorreta. A Region permanece a mesma no cenário.'),
  ('74000000-0000-4000-8000-000000000257', 'O size e a capacidade de compute.', 'Correta. Mais vCPUs e memória caracterizam a mudança de size.'),
  ('74000000-0000-4000-8000-000000000260', 'A quantidade de instâncias.', 'Incorreta. A quantidade de VMs não mudou.'),
  ('74000000-0000-4000-8000-000000000267', 'A cobrança de compute pode parar, mas os discos podem continuar cobrados.', 'Correta. Desalocar libera a capacidade de compute, mas não exclui discos e outros recursos cobrados separadamente.'),
  ('74000000-0000-4000-8000-000000000265', 'Compute e discos continuam com a mesma cobrança de antes.', 'Incorreta. A instância desalocada deixa de cobrar compute, embora recursos persistentes possam continuar cobrados.'),
  ('74000000-0000-4000-8000-000000000266', 'Compute continua cobrado, mas os discos deixam de cobrar.', 'Incorreta. A relação está invertida: a desalocação interrompe compute, enquanto discos persistentes podem continuar cobrados.'),
  ('74000000-0000-4000-8000-000000000268', 'Compute e discos deixam de gerar qualquer custo.', 'Incorreta. A desalocação não exclui os discos nem garante custo zero para todos os recursos associados.'),
  ('74000000-0000-4000-8000-000000000277', 'Azure Reservations.', 'Incorreta. Reservations oferecem desconto mediante compromisso de uso; a tolerância a interrupções caracteriza melhor Spot.'),
  ('74000000-0000-4000-8000-000000000279', 'Pay-as-you-go.', 'Incorreta. Pay-as-you-go evita compromisso, mas não explora capacidade ociosa sujeita a remoção para obter descontos de Spot.'),
  ('74000000-0000-4000-8000-000000000280', 'Azure Savings Plan for Compute.', 'Incorreta. Savings Plan reduz custos mediante compromisso de gasto; ele não depende de a carga tolerar interrupções.'),
  ('74000000-0000-4000-8000-000000000278', 'Azure Spot Virtual Machines.', 'Correta. Spot reduz custos para cargas interrompíveis usando capacidade ociosa que pode ser recuperada pelo Azure.'),
  ('74000000-0000-4000-8000-000000000469', 'Apenas o runtime escolhido determina escala e cobrança.', 'Incorreta. O runtime influencia a execução, mas o plano de hospedagem, a configuração e o uso também determinam escala e cobrança.'),
  ('74000000-0000-4000-8000-000000000471', 'Toda Function usa capacidade dedicada com preço mensal fixo.', 'Incorreta. Functions oferece diferentes planos, inclusive modelos baseados em consumo e planos com capacidade dedicada.'),
  ('74000000-0000-4000-8000-000000000472', 'Somente o tipo de trigger determina o custo total.', 'Incorreta. Triggers iniciam execuções, mas duração, recursos, instâncias, plano e outros componentes também influenciam o custo.'),
  ('74000000-0000-4000-8000-000000000470', 'O plano, a configuração e o padrão de uso determinam escala e cobrança.', 'Correta. Azure Functions possui planos e comportamentos de escala distintos, e a cobrança depende das escolhas e do consumo.'),
  ('74000000-0000-4000-8000-000000000475', 'Comparar Functions, containers e VMs por execução, controle, escala e custo.', 'Correta. Esses critérios relacionam o perfil da carga às diferenças operacionais e econômicas entre as opções.'),
  ('74000000-0000-4000-8000-000000000473', 'Escolher Functions somente pela linguagem usada no código.', 'Incorreta. A linguagem suportada é um requisito, mas não substitui a análise de execução, controle, escala e custo.'),
  ('74000000-0000-4000-8000-000000000474', 'Escolher containers somente porque a aplicação pode ser empacotada.', 'Incorreta. Empacotamento favorece containers, mas demanda estável, operação, escala e custo ainda precisam ser comparados.'),
  ('74000000-0000-4000-8000-000000000476', 'Escolher VMs somente porque a demanda é estável.', 'Incorreta. Carga estável pode favorecer VMs em alguns casos, mas o controle exigido e o custo total também são decisivos.'),
  ('75000000-0000-4000-8000-000000000077', 'Replica todos os recursos para a região pareada.', 'Incorreta. O pareamento não replica automaticamente todos os recursos; cada serviço e a arquitetura definem sua estratégia de replicação.'),
  ('75000000-0000-4000-8000-000000000078', 'Não replica nem executa failover da aplicação por si só.', 'Correta. Region Pair é uma relação de plataforma; continuidade da aplicação exige recursos e configurações apropriados.'),
  ('75000000-0000-4000-8000-000000000079', 'Cria uma cópia restaurável de cada recurso.', 'Incorreta. Backups e cópias restauráveis não são criados automaticamente apenas porque a região possui um par.'),
  ('75000000-0000-4000-8000-000000000080', 'Redireciona automaticamente o tráfego para a região pareada.', 'Incorreta. Redirecionamento e failover precisam ser projetados e configurados; o Region Pair não os ativa sozinho.'),
  ('77000000-0000-4000-8000-000000000046', 'Azure Virtual Machines.', 'Incorreta. VMs exigem administração do sistema operacional convidado.'),
  ('77000000-0000-4000-8000-000000000047', 'Azure Kubernetes Service.', 'Incorreta. AKS introduz a administração de um cluster de containers.'),
  ('77000000-0000-4000-8000-000000000045', 'Azure Functions.', 'Correta. Functions atende execução por eventos com escala e infraestrutura gerenciadas.'),
  ('77000000-0000-4000-8000-000000000048', 'Azure App Service Web Apps.', 'Incorreta. Web Apps atende hospedagem web contínua; Functions é mais direto para o componente acionado pela fila.'),
  ('77000000-0000-4000-8000-000000000078', 'Desligar no sistema operacional interrompe compute e discos.', 'Incorreta. Desligar o sistema operacional pode manter a VM alocada, e discos persistentes são cobrados separadamente.'),
  ('77000000-0000-4000-8000-000000000079', 'Desalocar interrompe apenas a cobrança dos discos.', 'Incorreta. A desalocação interrompe a cobrança da instância de compute; os discos mantidos podem continuar cobrados.'),
  ('77000000-0000-4000-8000-000000000077', 'Desalocar para compute, mas discos e rede associados podem continuar cobrados.', 'Correta. Recursos persistentes e certos componentes de rede têm ciclos de cobrança próprios.'),
  ('77000000-0000-4000-8000-000000000080', 'Allocated deixa de cobrar compute; Deallocated continua cobrando compute.', 'Incorreta. A afirmação inverte o comportamento: uma VM alocada pode cobrar compute, enquanto a desalocada não cobra a instância de compute.'),
  ('7d000000-0000-4000-8000-000000000058', 'Apenas verificar as certificações publicadas pelo provedor.', 'Incorreta. Certificações do provedor são evidências relevantes, mas não cumprem as obrigações específicas da solução do cliente.'),
  ('7d000000-0000-4000-8000-000000000059', 'Aceitar todos os controles padrão sem avaliar a configuração.', 'Incorreta. Controles padrão precisam ser avaliados e configurados de acordo com os requisitos e riscos do cliente.'),
  ('7d000000-0000-4000-8000-000000000057', 'Configurar controles e cumprir as obrigações que permanecem com o cliente.', 'Correta. O cliente continua responsável por seus dados, identidades, configurações e requisitos aplicáveis, conforme o modelo de serviço.'),
  ('7d000000-0000-4000-8000-000000000060', 'Transferir ao provedor a classificação de dados e as decisões de acesso.', 'Incorreta. Classificação dos dados e decisões de acesso permanecem sob responsabilidade do cliente.'),
  ('74000000-0000-4000-8000-000000000274', 'Usar somente o preço de lista de um serviço.', 'Incorreta. Uma aplicação geralmente combina serviços, quantidades, regiões, transferência e padrões de uso.'),
  ('74000000-0000-4000-8000-000000000275', 'Ignorar transferência de dados e recursos associados.', 'Incorreta. Transferência e recursos complementares podem compor parte relevante do custo total.'),
  ('74000000-0000-4000-8000-000000000273', 'Combinar os fatores relevantes em uma estimativa e revisar as premissas.', 'Correta. A estimativa deve refletir a arquitetura e ser atualizada quando uso, preços ou requisitos mudarem.'),
  ('74000000-0000-4000-8000-000000000276', 'Tratar a primeira estimativa como garantia do valor da fatura.', 'Incorreta. Uma estimativa depende de premissas e não garante o valor faturado.'),
  ('74000000-0000-4000-8000-000000000286', 'Uma garantia de que a fatura não ultrapassará o valor.', 'Incorreta. Budget acompanha e alerta, mas não bloqueia automaticamente consumo nem limita a fatura.'),
  ('74000000-0000-4000-8000-000000000285', 'Uma estimativa planejada usada para acompanhar gastos no período.', 'Correta. Um Budget estabelece um valor de referência e pode gerar alertas conforme os gastos evoluem.'),
  ('74000000-0000-4000-8000-000000000287', 'Uma estimativa criada somente antes da implantação.', 'Incorreta. Budget acompanha custos durante um período e não é apenas uma estimativa prévia de arquitetura.'),
  ('74000000-0000-4000-8000-000000000288', 'Uma regra que exclui recursos quando o valor é atingido.', 'Incorreta. Atingir um Budget não exclui recursos automaticamente.'),
  ('74000000-0000-4000-8000-000000000294', 'Uma tag chamada Budget=80.', 'Incorreta. Tags ajudam a organizar e filtrar custos, mas não avaliam um limite nem enviam alertas por si mesmas.'),
  ('74000000-0000-4000-8000-000000000295', 'A Pricing Calculator mantida aberta durante o mês.', 'Incorreta. A calculadora produz estimativas; ela não monitora o gasto realizado nem notifica sobre limites.'),
  ('74000000-0000-4000-8000-000000000296', 'Um Resource Lock na assinatura.', 'Incorreta. Locks protegem recursos contra exclusão ou alteração e não monitoram percentuais de orçamento.'),
  ('74000000-0000-4000-8000-000000000293', 'Um orçamento com alerta no limite de 80%.', 'Correta. Budget alerts notificam destinatários quando o gasto atinge o limite configurado.'),
  ('74000000-0000-4000-8000-000000000297', 'Custo real é gasto ocorrido; previsão projeta gasto futuro.', 'Correta. Custo real reflete uso registrado, enquanto previsão estima a evolução futura.'),
  ('74000000-0000-4000-8000-000000000298', 'Custo real e previsão são sempre o mesmo valor.', 'Incorreta. Um é histórico realizado e o outro é uma projeção que pode mudar.'),
  ('74000000-0000-4000-8000-000000000299', 'Previsão é uma fatura final já emitida.', 'Incorreta. Forecast é uma projeção e não uma fatura concluída.'),
  ('74000000-0000-4000-8000-000000000300', 'Custo real é uma estimativa anterior à implantação.', 'Incorreta. Custo real se baseia no uso ocorrido, e não em uma estimativa prévia.'),
  ('74000000-0000-4000-8000-000000000302', 'Excluir o Resource Group antes de investigar.', 'Incorreta. Excluir recursos elimina a carga, mas não identifica a causa da variação e pode causar indisponibilidade.'),
  ('74000000-0000-4000-8000-000000000301', 'Comparar períodos e detalhar custos no Cost Analysis.', 'Correta. Cost Analysis permite decompor a variação por recurso, serviço, tag e outros atributos.'),
  ('74000000-0000-4000-8000-000000000303', 'Usar somente a estimativa anterior à implantação.', 'Incorreta. A estimativa não mostra quais recursos efetivamente aumentaram o gasto no período.'),
  ('74000000-0000-4000-8000-000000000304', 'Assumir que o aumento é um erro de cobrança.', 'Incorreta. A variação deve ser investigada antes de concluir se decorre de uso, preço, configuração ou erro.'),
  ('75000000-0000-4000-8000-000000000002', 'O cliente instala o sistema operacional na máquina que acessará a aplicação.', 'Incorreta. No SaaS, o usuário acessa a aplicação pronta; não instala o sistema operacional do serviço.'),
  ('75000000-0000-4000-8000-000000000003', 'O cliente desenvolve a aplicação e o provedor gerencia somente a plataforma.', 'Incorreta. Essa descrição se aproxima de PaaS, no qual o cliente fornece o código da própria aplicação.'),
  ('75000000-0000-4000-8000-000000000001', 'O provedor entrega e opera uma aplicação completa acessível pela internet.', 'Correta. SaaS disponibiliza software pronto para uso e transfere ao provedor a operação da aplicação e da pilha subjacente.'),
  ('75000000-0000-4000-8000-000000000004', 'O provedor entrega infraestrutura virtual e o cliente administra o restante.', 'Incorreta. Essa divisão caracteriza IaaS, não SaaS.'),
  ('75000000-0000-4000-8000-000000000006', 'Uma máquina virtual na qual o cliente instala sistema operacional e aplicações.', 'Incorreta. Uma VM é um recurso de IaaS administrado pelo cliente.'),
  ('75000000-0000-4000-8000-000000000007', 'Uma plataforma em que o cliente publica o código da própria aplicação.', 'Incorreta. Esse cenário caracteriza PaaS, pois o cliente desenvolve a aplicação sobre uma plataforma gerenciada.'),
  ('75000000-0000-4000-8000-000000000008', 'Um servidor físico dedicado sem virtualização.', 'Incorreta. Infraestrutura física dedicada não é um exemplo típico de software entregue como serviço.'),
  ('75000000-0000-4000-8000-000000000005', 'Um serviço de e-mail corporativo pronto para uso pelo navegador.', 'Correta. O usuário consome a aplicação pronta, enquanto o provedor opera o software e a infraestrutura.'),
  ('75000000-0000-4000-8000-000000000041', 'Uma área geográfica com um ou mais datacenters conectados por rede de baixa latência.', 'Correta. Essa é a definição de uma Azure Region.'),
  ('75000000-0000-4000-8000-000000000042', 'Um conjunto de Availability Zones que abrange várias geografias.', 'Incorreta. Availability Zones pertencem a uma região compatível; uma região não é definida como várias geografias.'),
  ('75000000-0000-4000-8000-000000000043', 'Um par fixo de datacenters que replica qualquer serviço.', 'Incorreta. Region Pair relaciona regiões e não implica replicação automática de qualquer serviço.'),
  ('75000000-0000-4000-8000-000000000044', 'Um limite de cobrança que contém Resource Groups.', 'Incorreta. Uma assinatura é um escopo de cobrança e organização; isso não define uma Azure Region.'),
  ('77000000-0000-4000-8000-000000000062', 'Um compartilhamento de arquivos gerenciado acessível por SMB.', 'Incorreta. Essa descrição corresponde a Azure Files, não a uma máquina virtual.'),
  ('77000000-0000-4000-8000-000000000063', 'Uma ferramenta de linha de comando para administrar recursos.', 'Incorreta. Uma ferramenta administrativa não fornece um servidor virtualizado.'),
  ('77000000-0000-4000-8000-000000000061', 'Um servidor virtualizado configurável por sistema operacional, tamanho e outros parâmetros.', 'Correta. A VM fornece compute virtualizado com configuração e sistema operacional administrados pelo cliente.'),
  ('77000000-0000-4000-8000-000000000064', 'Um conjunto de políticas aplicado a recursos de uma assinatura.', 'Incorreta. Políticas governam recursos, mas não constituem uma máquina virtual.'),
  ('7f100000-0000-4000-8000-000000000142', 'O peering regional exige a mesma assinatura; o global exige assinaturas diferentes.', 'Incorreta. Tanto o peering regional quanto o global podem conectar VNets entre assinaturas; a diferença pedida é a relação entre regiões.'),
  ('7f100000-0000-4000-8000-000000000143', 'O peering regional usa VPN Gateway; o global usa ExpressRoute.', 'Incorreta. Ambos são tipos de VNet Peering e usam o backbone da Microsoft, sem depender desses gateways para estabelecer o peering.'),
  ('7f100000-0000-4000-8000-000000000141', 'O regional conecta VNets na mesma região; o global conecta VNets em regiões diferentes.', 'Correta. A localização relativa das VNets distingue as duas modalidades.'),
  ('7f100000-0000-4000-8000-000000000144', 'O regional é bidirecional; o global permite tráfego em apenas um sentido.', 'Incorreta. A direção efetiva depende das conexões e regras configuradas, não dessa distinção regional ou global.'),
  ('7f100000-0000-4000-8000-000000000149', 'Peering usa o backbone para conectar VNets; VPN usa um túnel criptografado.', 'Correta. Os mecanismos de conectividade são distintos, embora ambos possam interligar redes.'),
  ('7f100000-0000-4000-8000-000000000150', 'Peering e VPN usam gateways; a diferença é somente a largura de banda.', 'Incorreta. VNet Peering não exige VPN Gateway e a distinção não se limita ao desempenho.'),
  ('7f100000-0000-4000-8000-000000000151', 'Peering cria um túnel pela Internet; VPN permanece no backbone sem túnel.', 'Incorreta. A afirmação inverte os mecanismos: peering usa o backbone e VPN usa túnel criptografado.'),
  ('7f100000-0000-4000-8000-000000000152', 'Peering conecta rede local ao Azure; VPN conecta apenas VNets.', 'Incorreta. VPN pode conectar rede local e VNets; VNet Peering é específico para conexão entre VNets.'),
  ('7f100000-0000-4000-8000-000000000170', 'ExpressRoute é uma VPN de maior capacidade na Internet pública.', 'Incorreta. ExpressRoute usa conectividade privada por meio de um provedor e não é uma VPN pública.'),
  ('7f100000-0000-4000-8000-000000000169', 'VPN usa túnel sobre conectividade pública; ExpressRoute usa conexão privada por provedor.', 'Correta. Essa é a diferença fundamental entre os dois mecanismos de conectividade híbrida.'),
  ('7f100000-0000-4000-8000-000000000171', 'VPN Gateway e ExpressRoute são nomes para o mesmo gateway.', 'Incorreta. São ofertas e caminhos de conectividade distintos, com gateways próprios no Azure.'),
  ('7f100000-0000-4000-8000-000000000172', 'VPN sempre oferece latência mais previsível que ExpressRoute.', 'Incorreta. O caminho privado do ExpressRoute é a opção associada a conectividade mais consistente e previsível.'),
  ('7f100000-0000-4000-8000-000000000190', 'Ambos atribuem um endereço IP privado ao recurso na VNet.', 'Incorreta. Private Endpoint cria uma interface com IP privado; Service Endpoint mantém o endpoint público do serviço.'),
  ('7f100000-0000-4000-8000-000000000191', 'Service Endpoint exige VPN Gateway; Private Endpoint não usa DNS.', 'Incorreta. Service Endpoint não exige VPN Gateway, e resolução DNS é uma consideração importante para Private Endpoint.'),
  ('7f100000-0000-4000-8000-000000000189', 'Service Endpoint usa o endpoint público; Private Endpoint cria um IP privado.', 'Correta. O primeiro estende a identidade da VNet ao serviço; o segundo expõe o recurso por um endereço privado na VNet.'),
  ('7f100000-0000-4000-8000-000000000192', 'Service Endpoint desabilita acesso público; Private Endpoint o mantém obrigatório.', 'Incorreta. Nenhuma dessas conclusões decorre automaticamente; controles de acesso público são configurados separadamente.'),
  ('7f290000-0000-4000-8000-000000000049', 'Azure Advisor.', 'Incorreta. Advisor produz recomendações de otimização, mas não é o mecanismo que avalia uma métrica de CPU e dispara a notificação pedida.'),
  ('7f290000-0000-4000-8000-000000000050', 'Azure Monitor Alerts.', 'Correta. Uma regra de alerta pode avaliar a métrica de CPU e acionar um action group quando o limite for ultrapassado.'),
  ('7f290000-0000-4000-8000-000000000051', 'Azure Service Health Alerts.', 'Incorreta. Service Health informa incidentes, manutenção e avisos da plataforma; não monitora o percentual de CPU de uma VM.'),
  ('7f290000-0000-4000-8000-000000000052', 'VM insights.', 'Incorreta. VM insights ajuda a analisar desempenho e dependências, mas a notificação por condição é configurada com Azure Monitor Alerts.');

update public.questions as question
set question_text = seed.question_text,
    explanation = seed.explanation,
    updated_at = now()
from az900_postaudit_question_seed_b as seed
where question.id = seed.id;

update public.question_options as option
set option_text = seed.option_text,
    explanation = seed.explanation,
    updated_at = now()
from az900_postaudit_option_seed_b as seed
where option.id = seed.id;


create temporary table az900_quality_target_question_ids on commit drop as
select id from az900_question_remediation_0_127
union
select id from az900_remediation_question_seed
union
select id from az900_quality_question_seed_256_383
union
select id from az900_quality_question_seed
union
select id from az900_postaudit_question_seed_a
union
select id from az900_postaudit_question_seed_b;

create temporary table az900_quality_target_option_ids on commit drop as
select id from az900_option_text_seed_0_127
union
select id from az900_remediation_option_seed
union
select id from az900_quality_option_seed_256_383
union
select id from az900_quality_option_seed
union
select id from az900_postaudit_option_seed_a
union
select id from az900_postaudit_option_seed_b;

do $$
declare
  v_questions integer;
  v_published integer;
  v_options integer;
  v_mock_eligible integer;
  v_target_questions integer;
  v_distinct_target_questions integer;
  v_target_options integer;
  v_distinct_target_options integer;
  v_distribution integer[];
begin
  if (select count(*) from az900_question_remediation_0_127) <> 101
    or (select count(*) from az900_remediation_question_seed) <> 72
    or (select count(*) from az900_quality_question_seed_256_383) <> 53
    or (select count(*) from az900_quality_question_seed) <> 69
    or (select count(*) from az900_postaudit_question_seed_a) <> 29
    or (select count(*) from az900_postaudit_question_seed_b) <> 29 then
    raise exception 'AZ-900 remediation Question seed count differs from the audited partitions';
  end if;

  if (select count(*) from az900_option_text_seed_0_127) <> 404
    or (select count(*) from az900_remediation_option_seed) <> 288
    or (select count(*) from az900_quality_option_seed_256_383) <> 212
    or (select count(*) from az900_quality_option_seed) <> 276
    or (select count(*) from az900_postaudit_option_seed_a) <> 116
    or (select count(*) from az900_postaudit_option_seed_b) <> 116 then
    raise exception 'AZ-900 remediation Option seed count differs from four Options per target Question';
  end if;

  select count(*), count(distinct id)
    into v_target_questions, v_distinct_target_questions
  from az900_quality_target_question_ids;
  select count(*), count(distinct id)
    into v_target_options, v_distinct_target_options
  from az900_quality_target_option_ids;

  if (v_target_questions, v_distinct_target_questions)
     is distinct from (339, 339) then
    raise exception 'Expected 339 unique changed Questions, got % rows / % unique',
      v_target_questions, v_distinct_target_questions;
  end if;
  if (v_target_options, v_distinct_target_options)
     is distinct from (1356, 1356) then
    raise exception 'Expected 1356 unique target Options, got % rows / % unique',
      v_target_options, v_distinct_target_options;
  end if;

  if exists (
    select 1
    from az900_quality_target_question_ids target
    left join az900_quality_question_state_before before on before.id = target.id
    where before.id is null
  ) then
    raise exception 'A remediation Question UUID is not part of the approved AZ-900 inventory';
  end if;

  if exists (
    select 1
    from az900_quality_target_option_ids target
    left join az900_quality_option_state_before before on before.id = target.id
    left join az900_quality_target_question_ids question on question.id = before.question_id
    where before.id is null or question.id is null
  ) then
    raise exception 'A remediation Option UUID is missing or does not belong to a target Question';
  end if;

  if exists (
    select target.id
    from az900_quality_target_question_ids target
    join az900_quality_option_state_before option on option.question_id = target.id
    left join az900_quality_target_option_ids seeded on seeded.id = option.id
    group by target.id
    having count(seeded.id) <> 4
  ) then
    raise exception 'Every remediation Question must explicitly seed its four existing Options';
  end if;

  if exists (
    select 1
    from az900_quality_question_content_before before
    join public.questions question on question.id = before.id
    left join az900_quality_target_question_ids target on target.id = before.id
    where target.id is null
      and (question.question_text, question.explanation)
          is distinct from (before.question_text, before.explanation)
  ) then
    raise exception 'Question content outside the audited remediation set changed';
  end if;

  if exists (
    select 1
    from az900_quality_option_content_before before
    join public.question_options option on option.id = before.id
    left join az900_quality_target_option_ids target on target.id = before.id
    where target.id is null
      and (option.option_text, option.explanation)
          is distinct from (before.option_text, before.explanation)
  ) then
    raise exception 'Option content outside the audited remediation set changed';
  end if;

  if exists (
    select 1
    from az900_quality_target_question_ids target
    join az900_quality_question_content_before before on before.id = target.id
    join public.questions question on question.id = target.id
    where (question.question_text, question.explanation)
          is not distinct from (before.question_text, before.explanation)
  ) then
    raise exception 'A target Question received no editorial change';
  end if;

  if exists (
    with current_state as (
      select
        question.id,
        question.certification_id,
        question.domain_id,
        question.topic_id,
        question.lesson_id,
        question.question_type,
        question.difficulty,
        question.is_published,
        question.display_order,
        question.mock_eligible
      from public.questions question
      join public.certifications certification on certification.id = question.certification_id
      where certification.code = 'az-900'
    )
    select 1
    from az900_quality_question_state_before before
    full join current_state current on current.id = before.id
    where before.id is null or current.id is null
       or (current.certification_id, current.domain_id, current.topic_id, current.lesson_id,
           current.question_type, current.difficulty, current.is_published,
           current.display_order, current.mock_eligible)
          is distinct from
          (before.certification_id, before.domain_id, before.topic_id, before.lesson_id,
           before.question_type, before.difficulty, before.is_published,
           before.display_order, before.mock_eligible)
  ) then
    raise exception 'Question UUID, hierarchy, difficulty, publication, order or eligibility changed';
  end if;

  if exists (
    with current_state as (
      select option.id, option.question_id, option.is_correct, option.display_order
      from public.question_options option
      join az900_quality_question_state_before question on question.id = option.question_id
    )
    select 1
    from az900_quality_option_state_before before
    full join current_state current on current.id = before.id
    where before.id is null or current.id is null
       or (current.question_id, current.is_correct, current.display_order)
          is distinct from (before.question_id, before.is_correct, before.display_order)
  ) then
    raise exception 'Option UUID, ownership, answer key or display order changed';
  end if;

  select count(*), count(*) filter (where question.is_published),
         count(*) filter (where question.mock_eligible)
    into v_questions, v_published, v_mock_eligible
  from public.questions question
  join public.certifications certification on certification.id = question.certification_id
  where certification.code = 'az-900';

  select count(*) into v_options
  from public.question_options option
  join az900_quality_question_state_before question on question.id = option.question_id;

  if (v_questions, v_published, v_options, v_mock_eligible)
     is distinct from (512, 512, 2048, 439) then
    raise exception
      'AZ-900 quality postcondition failed: questions %, published %, options %, mock eligible %',
      v_questions, v_published, v_options, v_mock_eligible;
  end if;

  if exists (
    select 1
    from public.questions question
    join az900_quality_question_state_before approved on approved.id = question.id
    where btrim(question.question_text) = '' or btrim(coalesce(question.explanation, '')) = ''
  ) then
    raise exception 'Blank stem or Question explanation remains';
  end if;

  if exists (
    select 1
    from public.question_options option
    join az900_quality_question_state_before question on question.id = option.question_id
    group by option.question_id
    having count(*) <> 4
       or count(*) filter (where option.is_correct) <> 1
       or count(distinct lower(btrim(option.option_text))) <> 4
       or count(*) filter (where btrim(option.option_text) = '') > 0
  ) then
    raise exception 'Option cardinality, uniqueness, text or answer-key invariant failed';
  end if;

  select array_agg(position_count order by display_order)
    into v_distribution
  from (
    select option.display_order, count(*)::integer as position_count
    from public.question_options option
    join az900_quality_question_state_before question on question.id = option.question_id
    where option.is_correct
    group by option.display_order
  ) distribution;

  if v_distribution <> array[128, 128, 128, 128] then
    raise exception 'Correct-option position distribution changed: %', v_distribution;
  end if;

  if (select digest from az900_quality_mock_digest_before) <>
     (select md5(coalesce(string_agg(to_jsonb(snapshot)::text, '' order by snapshot.id), ''))
      from public.mock_exam_attempt_questions snapshot) then
    raise exception 'Historical Mock snapshots changed';
  end if;
end;
$$;

commit;


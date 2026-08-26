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
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Cloud Computing'
    and lesson.slug in (
      'what-is-cloud-computing',
      'public-private-hybrid-cloud',
      'choosing-a-cloud-model',
      'consumption-based-model',
      'capex-vs-opex',
      'serverless-computing'
    );

  if target_count <> 6 then
    raise exception 'Cloud Computing enrichment expected exactly 6 target lessons, found %', target_count;
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'shared-responsibility-model'
      and block.type = 'visual_experience'
      and block.visual_experience_id = '76000000-0000-4000-8000-000000000004'
      and block.is_published
  ) then
    raise exception 'Shared Responsibility reference lesson is not intact';
  end if;
end;
$$;

insert into public.visual_experiences (
  id,
  lesson_id,
  type,
  title,
  description,
  config,
  display_order,
  is_published
)
select
  '76000000-0000-4000-8000-000000000005',
  lesson.id,
  'comparison',
  'Public, Private e Hybrid Cloud',
  'Compare quem opera a infraestrutura, como o ambiente é usado e quando cada modelo costuma fazer sentido.',
  $json$
  {
    "columns": [
      {
        "id": "public",
        "title": "Public Cloud",
        "description": "Infraestrutura operada por um cloud provider e oferecida a vários clientes."
      },
      {
        "id": "private",
        "title": "Private Cloud",
        "description": "Ambiente de nuvem dedicado ao uso de uma única organização."
      },
      {
        "id": "hybrid",
        "title": "Hybrid Cloud",
        "description": "Integra ambientes privados ou locais com serviços de nuvem pública."
      }
    ],
    "rows": [
      {
        "id": "operation",
        "label": "Operação da infraestrutura",
        "values": {
          "public": "O cloud provider opera a infraestrutura compartilhada.",
          "private": "A organização ou um provedor contratado opera um ambiente dedicado.",
          "hybrid": "A operação é dividida entre os ambientes integrados."
        }
      },
      {
        "id": "control",
        "label": "Controle e dedicação",
        "values": {
          "public": "Menos controle sobre a infraestrutura física e rápida expansão.",
          "private": "Maior controle sobre um ambiente exclusivo da organização.",
          "hybrid": "Combina controle local ou privado com capacidade da nuvem pública."
        }
      },
      {
        "id": "location",
        "label": "Localização",
        "values": {
          "public": "Executada nos datacenters do provedor.",
          "private": "Pode estar no datacenter da organização ou hospedada por terceiros.",
          "hybrid": "Conecta recursos que podem estar em locais e plataformas diferentes."
        }
      },
      {
        "id": "scenario",
        "label": "Cenário típico",
        "values": {
          "public": "Aplicação pública que precisa provisionar e escalar rapidamente.",
          "private": "Carga que exige ambiente dedicado e controles específicos.",
          "hybrid": "Aplicação no Azure integrada a sistemas ou dados mantidos localmente."
        }
      }
    ]
  }
  $json$::jsonb,
  1,
  true
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and domain.title = 'Describe cloud concepts'
  and lesson.slug = 'public-private-hybrid-cloud'
on conflict (id) do update set
  lesson_id = excluded.lesson_id,
  type = excluded.type,
  title = excluded.title,
  description = excluded.description,
  config = excluded.config,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

insert into public.visual_experiences (
  id,
  lesson_id,
  type,
  title,
  description,
  config,
  display_order,
  is_published
)
select
  '76000000-0000-4000-8000-000000000006',
  lesson.id,
  'comparison',
  'CapEx e OpEx',
  'Compare quando o gasto acontece, como a capacidade é adquirida e exemplos comuns em tecnologia.',
  $json$
  {
    "columns": [
      {
        "id": "capex",
        "title": "CapEx",
        "description": "Capital Expenditure: investimento antecipado em ativos."
      },
      {
        "id": "opex",
        "title": "OpEx",
        "description": "Operational Expenditure: despesa operacional recorrente."
      }
    ],
    "rows": [
      {
        "id": "timing",
        "label": "Momento do gasto",
        "values": {
          "capex": "O investimento principal acontece antes de utilizar a capacidade.",
          "opex": "O gasto ocorre ao longo da operação e pode acompanhar o uso."
        }
      },
      {
        "id": "capacity",
        "label": "Capacidade",
        "values": {
          "capex": "A capacidade é comprada antecipadamente e pode ficar ociosa.",
          "opex": "A capacidade contratada pode ser ajustada conforme a necessidade."
        }
      },
      {
        "id": "example",
        "label": "Exemplo",
        "values": {
          "capex": "Comprar servidores, armazenamento e equipamentos de rede.",
          "opex": "Consumir recursos do Azure e receber cobrança recorrente pelo serviço."
        }
      },
      {
        "id": "nuance",
        "label": "Atenção",
        "values": {
          "capex": "O ativo adquirido pode ser depreciado conforme as regras contábeis aplicáveis.",
          "opex": "A classificação final depende do contrato e das práticas contábeis da organização."
        }
      }
    ]
  }
  $json$::jsonb,
  1,
  true
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and domain.title = 'Describe cloud concepts'
  and lesson.slug = 'capex-vs-opex'
on conflict (id) do update set
  lesson_id = excluded.lesson_id,
  type = excluded.type,
  title = excluded.title,
  description = excluded.description,
  config = excluded.config,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

create temporary table cloud_computing_block_seed (
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

insert into cloud_computing_block_seed values
  (
    '7a010000-0000-4000-8000-000000000001',
    'what-is-cloud-computing',
    'explanation',
    'O que é Cloud Computing?',
    $content$Cloud computing é a entrega de recursos de tecnologia da informação sob demanda por uma rede. Em vez de comprar e instalar toda a infraestrutura antes de usá-la, você pode provisionar compute, storage e networking quando precisar.

Compute fornece processamento para aplicações, storage mantém dados e arquivos, e networking conecta usuários, sistemas e recursos. Esses componentes podem ser criados em minutos e ajustados conforme a necessidade.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7a010000-0000-4000-8000-000000000002',
    'what-is-cloud-computing',
    'important',
    'Sob demanda não significa sem planejamento',
    $content$A nuvem acelera o provisionamento e permite ajustar capacidade, mas os recursos ainda precisam de configuração, segurança, monitoramento e controle de custos. Criar rapidamente não elimina a responsabilidade de administrar bem o que foi criado.$content$,
    null,
    null,
    2,
    true
  ),
  (
    '7a010000-0000-4000-8000-000000000003',
    'what-is-cloud-computing',
    'example',
    'Uma loja durante uma campanha',
    $content$Uma loja online pode provisionar capacidade adicional de compute durante uma campanha, armazenar imagens e pedidos em serviços de storage e usar networking para conectar a aplicação aos usuários e ao banco de dados.

Quando a demanda diminui, a empresa pode reduzir parte da capacidade. O custo fica relacionado aos recursos e ao tempo de uso, de acordo com o serviço contratado.$content$,
    null,
    null,
    3,
    true
  ),
  (
    '7a010000-0000-4000-8000-000000000004',
    'what-is-cloud-computing',
    'dotnet_example',
    'Uma API ASP.NET Core na nuvem',
    $content$Uma equipe pode publicar uma API ASP.NET Core usando compute no Azure, armazenar arquivos em um serviço de storage e conectá-la a outros recursos pela rede.

A infraestrutura pode ser provisionada sem comprar servidores físicos e pode crescer quando o número de requisições aumentar. A equipe continua responsável pelo código, pelos dados, pelos acessos e pelas configurações que controla.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7a010000-0000-4000-8000-000000000005',
    'what-is-cloud-computing',
    'exam_tip',
    'O que lembrar para a prova',
    $content$Associe cloud computing a recursos de TI sob demanda, provisionamento rápido, capacidade ajustável e custo relacionado ao consumo. Compute, storage e networking são categorias fundamentais de recursos, não modelos de implantação da nuvem.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7a010000-0000-4000-8000-000000000006',
    'what-is-cloud-computing',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Cloud computing entrega recursos de TI sob demanda.", "Compute fornece processamento para executar cargas de trabalho.", "Storage mantém dados e arquivos.", "Networking conecta usuários, aplicações e recursos.", "O provisionamento pode acontecer rapidamente e a capacidade pode ser ajustada.", "O custo pode acompanhar os recursos consumidos, conforme o modelo contratado."]}$json$::jsonb,
    null,
    6,
    true
  ),

  (
    '7a020000-0000-4000-8000-000000000001',
    'public-private-hybrid-cloud',
    'explanation',
    'Três modelos de implantação',
    $content$Public Cloud usa infraestrutura operada por um cloud provider e disponibilizada como serviço. Os recursos de diferentes clientes são isolados logicamente, embora a infraestrutura do provedor seja compartilhada.

Private Cloud é um ambiente de nuvem dedicado a uma única organização. Ele pode estar no datacenter da própria organização ou ser hospedado e operado por terceiros.

Hybrid Cloud integra ambientes privados ou locais com uma nuvem pública, permitindo que sistemas, dados e processos trabalhem entre os dois ambientes.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7a020000-0000-4000-8000-000000000002',
    'public-private-hybrid-cloud',
    'visual_experience',
    'Compare os modelos de cloud',
    null,
    null,
    '76000000-0000-4000-8000-000000000005',
    2,
    true
  ),
  (
    '7a020000-0000-4000-8000-000000000003',
    'public-private-hybrid-cloud',
    'example',
    'Integração com um sistema legado',
    $content$Uma empresa pode executar uma nova aplicação no Azure e manter temporariamente um banco legado em seu datacenter. Quando os dois ambientes são conectados e fazem parte da mesma solução, temos um cenário de Hybrid Cloud.

O fato de um recurso ser acessado apenas por funcionários não o transforma automaticamente em Private Cloud. O modelo depende de como a infraestrutura é dedicada e operada.$content$,
    null,
    null,
    3,
    true
  ),
  (
    '7a020000-0000-4000-8000-000000000004',
    'public-private-hybrid-cloud',
    'important',
    'Private Cloud não define uma localização física',
    $content$Private Cloud significa um ambiente de nuvem dedicado a uma organização. Ele não precisa estar dentro do prédio ou do datacenter da empresa; pode ser hospedado por um provedor externo, desde que seja dedicado à organização.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7a020000-0000-4000-8000-000000000005',
    'public-private-hybrid-cloud',
    'exam_tip',
    'Como diferenciar na prova',
    $content$Procure o requisito central do cenário: expansão rápida e infraestrutura do provider sugerem Public Cloud; ambiente exclusivo e controles específicos sugerem Private Cloud; integração entre ambientes sugere Hybrid Cloud.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7a020000-0000-4000-8000-000000000006',
    'public-private-hybrid-cloud',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Public Cloud usa infraestrutura operada por um cloud provider.", "Private Cloud é dedicada a uma única organização.", "Private Cloud pode estar on-premises ou ser hospedada por terceiros.", "Hybrid Cloud integra ambientes privados ou locais com nuvem pública.", "A escolha depende de controle, integração, escala, custo e requisitos regulatórios."]}$json$::jsonb,
    null,
    6,
    true
  ),

  (
    '7a030000-0000-4000-8000-000000000001',
    'choosing-a-cloud-model',
    'explanation',
    'Escolha pelo requisito do cenário',
    $content$Não existe um modelo de cloud universalmente melhor. A escolha entre Public, Private e Hybrid Cloud depende de requisitos como velocidade de expansão, ambiente dedicado, integração com sistemas existentes, controle, conformidade e orçamento.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7a030000-0000-4000-8000-000000000002',
    'choosing-a-cloud-model',
    'example',
    'Cenário 1 — Public Cloud',
    $content$Uma aplicação pública precisa ser lançada rapidamente e deve crescer durante campanhas imprevisíveis. Não existe requisito de infraestrutura dedicada.

Public Cloud é uma escolha adequada porque oferece provisionamento rápido e capacidade ajustável sem a organização operar a infraestrutura física.$content$,
    null,
    null,
    2,
    true
  ),
  (
    '7a030000-0000-4000-8000-000000000003',
    'choosing-a-cloud-model',
    'example',
    'Cenário 2 — Private Cloud',
    $content$Uma organização precisa de um ambiente de nuvem exclusivo, com controles específicos sobre a infraestrutura e requisitos que impedem o uso de um ambiente compartilhado.

Private Cloud atende ao requisito de dedicação. Isso não determina se o ambiente ficará no datacenter da organização ou será hospedado por terceiros.$content$,
    null,
    null,
    3,
    true
  ),
  (
    '7a030000-0000-4000-8000-000000000004',
    'choosing-a-cloud-model',
    'example',
    'Cenário 3 — Hybrid Cloud',
    $content$Uma nova aplicação é executada no Azure, mas ainda precisa consultar um banco de dados legado mantido no ambiente local durante uma migração gradual.

Hybrid Cloud permite integrar os dois ambientes enquanto a organização moderniza seus sistemas no ritmo adequado.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7a030000-0000-4000-8000-000000000005',
    'choosing-a-cloud-model',
    'exam_trap',
    'Não escolha apenas por uma palavra isolada',
    $content$Dados sensíveis não exigem automaticamente Private Cloud, e usar Azure não torna automaticamente uma solução Hybrid Cloud. Analise o conjunto de requisitos: dedicação, controles, integração, conectividade, escala e conformidade.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7a030000-0000-4000-8000-000000000006',
    'choosing-a-cloud-model',
    'exam_tip',
    'Elimine pelas características',
    $content$Public Cloud prioriza agilidade e escala na infraestrutura do provider. Private Cloud prioriza um ambiente dedicado. Hybrid Cloud aparece quando ambientes distintos precisam permanecer integrados.$content$,
    null,
    null,
    6,
    true
  ),
  (
    '7a030000-0000-4000-8000-000000000007',
    'choosing-a-cloud-model',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Use Public Cloud para agilidade, elasticidade e infraestrutura operada pelo provider.", "Use Private Cloud quando o requisito central for um ambiente dedicado à organização.", "Use Hybrid Cloud quando ambientes privados ou locais precisarem ser integrados à nuvem pública.", "Localização física, isoladamente, não define Private Cloud.", "Escolha o modelo a partir dos requisitos completos do cenário."]}$json$::jsonb,
    null,
    7,
    true
  ),

  (
    '7a040000-0000-4000-8000-000000000001',
    'consumption-based-model',
    'explanation',
    'Capacidade e custo relacionados ao uso',
    $content$No modelo baseado em consumo, a organização utiliza recursos conforme a necessidade e o custo é relacionado ao que foi consumido, de acordo com as métricas e condições do serviço.

Em vez de comprar antecipadamente toda a capacidade estimada para o maior pico, é possível aumentar ou reduzir recursos ao longo do tempo.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7a040000-0000-4000-8000-000000000002',
    'consumption-based-model',
    'important',
    'Capacidade ociosa ainda pode gerar custo',
    $content$Pay for what you consume não significa que todo recurso parado deixa automaticamente de custar. Uma VM ligada, storage ocupado ou uma capacidade reservada pode continuar sendo cobrada. É necessário acompanhar e ajustar os recursos conforme as regras de cada serviço.$content$,
    null,
    null,
    2,
    true
  ),
  (
    '7a040000-0000-4000-8000-000000000003',
    'consumption-based-model',
    'example',
    'Demanda sazonal',
    $content$Uma loja pode aumentar a capacidade da aplicação durante a Black Friday e reduzi-la depois. Assim, ela evita manter o ano inteiro toda a capacidade necessária apenas para o maior pico.

O benefício depende de ajustar os recursos; deixar capacidade desnecessária provisionada reduz a eficiência do modelo.$content$,
    null,
    null,
    3,
    true
  ),
  (
    '7a040000-0000-4000-8000-000000000004',
    'consumption-based-model',
    'dotnet_example',
    'Ambientes de uma aplicação .NET',
    $content$Uma equipe pode manter o ambiente de produção de uma API ASP.NET Core disponível continuamente e criar ambientes de teste apenas quando forem usados.

Remover ou reduzir os recursos de teste fora do período de trabalho diminui capacidade ociosa. O efeito financeiro exato depende dos serviços e planos escolhidos.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7a040000-0000-4000-8000-000000000005',
    'consumption-based-model',
    'exam_tip',
    'O que lembrar para a prova',
    $content$Relacione o modelo de consumo a pagamento baseado no uso, capacidade ajustável e menor necessidade de comprar capacidade máxima antecipadamente. Também reconheça que recursos mal dimensionados ou esquecidos podem continuar gerando custo.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7a040000-0000-4000-8000-000000000006',
    'consumption-based-model',
    'summary',
    'Resumo',
    null,
    $json${"items": ["O custo se relaciona ao consumo conforme as métricas do serviço.", "A capacidade pode ser aumentada ou reduzida conforme a necessidade.", "Ajustar recursos reduz capacidade ociosa.", "Não é necessário comprar antecipadamente toda a capacidade de pico.", "Recursos esquecidos ou superdimensionados podem continuar gerando custo."]}$json$::jsonb,
    null,
    6,
    true
  ),

  (
    '7a050000-0000-4000-8000-000000000001',
    'capex-vs-opex',
    'explanation',
    'Investimento antecipado e despesa operacional',
    $content$CapEx, ou capital expenditure, representa investimento antecipado em ativos que serão utilizados ao longo do tempo. Em tecnologia, comprar servidores, storage e equipamentos de rede é um exemplo comum.

OpEx, ou operational expenditure, representa despesas recorrentes da operação. Consumir recursos do Azure e receber cobrança periódica pelo serviço é predominantemente associado a OpEx.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7a050000-0000-4000-8000-000000000002',
    'capex-vs-opex',
    'visual_experience',
    'Compare CapEx e OpEx',
    null,
    null,
    '76000000-0000-4000-8000-000000000006',
    2,
    true
  ),
  (
    '7a050000-0000-4000-8000-000000000003',
    'capex-vs-opex',
    'example',
    'Capacidade para um novo sistema',
    $content$No modelo tradicional, uma empresa pode comprar servidores dimensionados para o pico esperado antes de iniciar o sistema. Esse investimento em ativos é um exemplo de CapEx e parte da capacidade pode ficar ociosa.

Ao consumir capacidade do Azure ao longo da operação, o gasto é normalmente recorrente e pode acompanhar a necessidade. Esse padrão é predominantemente associado a OpEx.$content$,
    null,
    null,
    3,
    true
  ),
  (
    '7a050000-0000-4000-8000-000000000004',
    'capex-vs-opex',
    'important',
    'A classificação contábil exige contexto',
    $content$CapEx e OpEx são conceitos financeiros. Embora serviços de nuvem sejam frequentemente tratados como despesa operacional, a classificação final depende do contrato, das regras contábeis aplicáveis e das práticas da organização.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7a050000-0000-4000-8000-000000000005',
    'capex-vs-opex',
    'exam_tip',
    'Reconheça o padrão do cenário',
    $content$Compra antecipada de hardware e formação de um ativo apontam para CapEx. Cobrança recorrente por serviços consumidos durante a operação aponta predominantemente para OpEx.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7a050000-0000-4000-8000-000000000006',
    'capex-vs-opex',
    'exam_trap',
    'Evite afirmações absolutas',
    $content$Cloud não significa que toda despesa será sempre OpEx, e comprar qualquer item não o transforma automaticamente em CapEx. Para a prova, identifique o contraste conceitual; em situações reais, considere contrato e regras contábeis.$content$,
    null,
    null,
    6,
    true
  ),
  (
    '7a050000-0000-4000-8000-000000000007',
    'capex-vs-opex',
    'summary',
    'Resumo',
    null,
    $json${"items": ["CapEx é investimento antecipado em ativos.", "Comprar servidores é um exemplo comum de CapEx.", "OpEx é despesa operacional recorrente.", "Consumir serviços do Azure é predominantemente associado a OpEx.", "A nuvem reduz a necessidade de comprar antecipadamente toda a capacidade.", "A classificação contábil final depende do contexto da organização."]}$json$::jsonb,
    null,
    7,
    true
  ),

  (
    '7a060000-0000-4000-8000-000000000001',
    'serverless-computing',
    'explanation',
    'Infraestrutura abstraída',
    $content$Em serverless computing, servidores continuam executando o código, mas a infraestrutura é abstraída para quem desenvolve a solução. O cloud provider provisiona, mantém e ajusta os servidores necessários ao serviço.

O desenvolvedor publica código ou funções sem administrar diretamente máquinas virtuais e pode usar um modelo orientado a eventos.$content$,
    null,
    null,
    1,
    true
  ),
  (
    '7a060000-0000-4000-8000-000000000002',
    'serverless-computing',
    'important',
    'Menos infraestrutura, não responsabilidade zero',
    $content$O provider administra os servidores e a plataforma do serviço, mas a equipe ainda é responsável pelo código, pelas configurações, pelos dados, pelas identidades e pelo comportamento seguro da solução.$content$,
    null,
    null,
    2,
    true
  ),
  (
    '7a060000-0000-4000-8000-000000000003',
    'serverless-computing',
    'example',
    'Processamento acionado por evento',
    $content$Uma função pode ser executada quando um arquivo é enviado para storage, quando uma mensagem chega a uma fila ou quando uma requisição HTTP é recebida.

O serviço pode adicionar capacidade automaticamente quando os eventos aumentam e reduzir quando a demanda cai, dentro dos limites e características do plano escolhido.$content$,
    null,
    null,
    3,
    true
  ),
  (
    '7a060000-0000-4000-8000-000000000004',
    'serverless-computing',
    'dotnet_example',
    'Azure Functions com .NET',
    $content$Uma Azure Function escrita em C# pode validar uma imagem assim que o arquivo chega ao storage. A equipe implementa a função e configura o gatilho; o Azure administra os servidores usados para executá-la.

Azure Functions é um exemplo de serviço serverless, não a definição inteira do conceito.$content$,
    null,
    null,
    4,
    true
  ),
  (
    '7a060000-0000-4000-8000-000000000005',
    'serverless-computing',
    'exam_tip',
    'Sinais de um cenário serverless',
    $content$Procure execução por eventos, ausência de administração direta de servidores, escala gerenciada e cobrança relacionada à execução ou ao consumo do serviço. Nem toda carga de trabalho será necessariamente mais barata em serverless.$content$,
    null,
    null,
    5,
    true
  ),
  (
    '7a060000-0000-4000-8000-000000000006',
    'serverless-computing',
    'exam_trap',
    'Serverless não significa ausência de servidores',
    $content$Os servidores continuam existindo. A diferença é que o cloud provider administra a infraestrutura e a apresenta de forma abstraída para a equipe que cria a aplicação.$content$,
    null,
    null,
    6,
    true
  ),
  (
    '7a060000-0000-4000-8000-000000000007',
    'serverless-computing',
    'summary',
    'Resumo',
    null,
    $json${"items": ["Servidores continuam existindo em soluções serverless.", "A infraestrutura é abstraída e administrada pelo cloud provider.", "A execução pode ser acionada por eventos.", "A capacidade pode ser ajustada automaticamente pelo serviço.", "A equipe continua responsável pelo código, pelos dados e pelas configurações.", "Azure Functions é um exemplo de computação serverless."]}$json$::jsonb,
    null,
    7,
    true
  );

do $$
begin
  if exists (
    select 1
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug in (
      'what-is-cloud-computing',
      'public-private-hybrid-cloud',
      'choosing-a-cloud-model',
      'consumption-based-model',
      'capex-vs-opex',
      'serverless-computing'
    )
      and not exists (
        select 1
        from cloud_computing_block_seed seed
        where seed.id = block.id
          and seed.lesson_slug = lesson.slug
      )
  ) then
    raise exception 'A target lesson already has content blocks outside the 8.4.2 seed';
  end if;

  if (select count(*) from cloud_computing_block_seed) <> 39 then
    raise exception 'Cloud Computing block seed expected 39 rows';
  end if;
end;
$$;

with target_lessons as (
  select lesson.id, lesson.slug
  from public.lessons lesson
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Cloud Computing'
),
resolved_seed as (
  select seed.*, target.id as lesson_id
  from cloud_computing_block_seed seed
  join target_lessons target on target.slug = seed.lesson_slug
)
insert into public.lesson_content_blocks (
  id,
  lesson_id,
  type,
  title,
  content,
  config,
  visual_experience_id,
  display_order,
  is_published
)
select
  seed.id,
  seed.lesson_id,
  seed.type,
  seed.title,
  seed.content,
  seed.config,
  seed.visual_experience_id,
  seed.display_order,
  seed.is_published
from resolved_seed seed
order by seed.lesson_slug, seed.display_order
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
set estimated_minutes = case lesson.slug
  when 'what-is-cloud-computing' then 10
  when 'public-private-hybrid-cloud' then 10
  when 'choosing-a-cloud-model' then 10
  when 'consumption-based-model' then 8
  when 'capex-vs-opex' then 10
  when 'serverless-computing' then 10
  else lesson.estimated_minutes
end
from public.topics topic
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where lesson.topic_id = topic.id
  and certification.code = 'az-900'
  and domain.title = 'Describe cloud concepts'
  and topic.title = 'Cloud Computing'
  and lesson.slug in (
    'what-is-cloud-computing',
    'public-private-hybrid-cloud',
    'choosing-a-cloud-model',
    'consumption-based-model',
    'capex-vs-opex',
    'serverless-computing'
  );

do $$
declare
  published_block_count integer;
  enriched_lesson_count integer;
begin
  select count(*), count(distinct lesson.id)
  into published_block_count, enriched_lesson_count
  from public.lesson_content_blocks block
  join public.lessons lesson on lesson.id = block.lesson_id
  join public.topics topic on topic.id = lesson.topic_id
  join public.domains domain on domain.id = topic.domain_id
  join public.certifications certification on certification.id = domain.certification_id
  where certification.code = 'az-900'
    and domain.title = 'Describe cloud concepts'
    and topic.title = 'Cloud Computing'
    and lesson.slug <> 'shared-responsibility-model'
    and block.is_published;

  if published_block_count <> 39 or enriched_lesson_count <> 6 then
    raise exception 'Unexpected enriched lesson/block count: lessons %, blocks %', enriched_lesson_count, published_block_count;
  end if;

  if (
    select count(*)
    from public.visual_experiences
    where id in (
      '76000000-0000-4000-8000-000000000005',
      '76000000-0000-4000-8000-000000000006'
    )
      and type = 'comparison'
      and is_published
  ) <> 2 then
    raise exception 'The two comparison visual experiences were not persisted';
  end if;

  if exists (
    select 1
    from public.lessons lesson
    join public.topics topic on topic.id = lesson.topic_id
    join public.domains domain on domain.id = topic.domain_id
    join public.certifications certification on certification.id = domain.certification_id
    where certification.code = 'az-900'
      and domain.title = 'Describe cloud concepts'
      and topic.title = 'Cloud Computing'
      and lesson.slug in (
        'what-is-cloud-computing',
        'public-private-hybrid-cloud',
        'choosing-a-cloud-model',
        'consumption-based-model',
        'capex-vs-opex',
        'serverless-computing'
      )
      and (lesson.content is null or btrim(lesson.content) = '')
  ) then
    raise exception 'Legacy lessons.content must remain available after enrichment';
  end if;
end;
$$;

commit;

begin;

do $$ begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000003'
      and slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates'))<>2 then
    raise exception '9.6.4 expected two existing target Lessons'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates'))
    or exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates'))
    or exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates')) then
    raise exception '9.6.4 expected target Lessons without structured content or practice'; end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003'
        and lesson.slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates'))
    or exists(select 1 from public.visual_experiences where id='76000000-0000-4000-8000-000000000016') then
    raise exception '9.6.4 Visual Experience preconditions are invalid'; end if;
end; $$;

update public.lessons set estimated_minutes=case slug
  when 'infrastructure-as-code' then 12 else 14 end
where topic_id='33000000-0000-4000-8000-000000000003'
  and slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates');

insert into public.visual_experiences(id,lesson_id,type,title,description,config,display_order,is_published)
select '76000000-0000-4000-8000-000000000016',lesson.id,'architecture',
  'Ferramentas, Azure Resource Manager e recursos',
  'Selecione os elementos para acompanhar como diferentes ferramentas usam a camada comum de gerenciamento e os Resource Providers.',
  $json${
    "nodes":[
      {"id":"azure-portal","label":"Azure Portal","kind":"external","description":"Interface gráfica que envia solicitações de gerenciamento.","x":8,"y":10},
      {"id":"azure-cli","label":"Azure CLI","kind":"external","description":"Ferramenta de comandos az que envia solicitações de gerenciamento.","x":29,"y":10},
      {"id":"azure-powershell","label":"Azure PowerShell","kind":"external","description":"Cmdlets Az que enviam solicitações de gerenciamento.","x":50,"y":10},
      {"id":"arm-template","label":"ARM Template","kind":"external","description":"Definição JSON declarativa enviada para deployment pelo ARM.","x":71,"y":10},
      {"id":"rest-api","label":"REST / API","kind":"external","description":"Aplicações e SDKs também usam APIs de gerenciamento.","x":92,"y":10},
      {"id":"resource-manager","label":"Azure Resource Manager","kind":"service","description":"Camada comum que recebe, autentica, autoriza e coordena solicitações sobre recursos.","x":50,"y":42},
      {"id":"resource-providers","label":"Resource Providers","kind":"group","description":"Serviços que fornecem tipos de recurso, como Microsoft.Compute e Microsoft.Storage.","x":50,"y":68},
      {"id":"azure-resources","label":"Azure Resources","kind":"resource","description":"VMs, Storage Accounts, VNets, App Services e outros recursos gerenciáveis.","x":50,"y":92}
    ],
    "edges":[
      {"id":"portal-arm","source":"azure-portal","target":"resource-manager","label":"solicitação"},
      {"id":"cli-arm","source":"azure-cli","target":"resource-manager","label":"solicitação"},
      {"id":"powershell-arm","source":"azure-powershell","target":"resource-manager","label":"solicitação"},
      {"id":"template-arm","source":"arm-template","target":"resource-manager","label":"deployment"},
      {"id":"api-arm","source":"rest-api","target":"resource-manager","label":"solicitação"},
      {"id":"arm-providers","source":"resource-manager","target":"resource-providers","label":"coordena"},
      {"id":"providers-resources","source":"resource-providers","target":"azure-resources","label":"fornecem tipos"}
    ]
  }$json$::jsonb,1,true
from public.lessons lesson where lesson.topic_id='33000000-0000-4000-8000-000000000003'
  and lesson.slug='azure-resource-manager-and-arm-templates';

create temporary table stage_964_blocks(id uuid primary key,lesson_slug text,type text,title text,content text,config jsonb,visual_id uuid,display_order integer) on commit drop;
insert into stage_964_blocks values
('7b270000-0000-4000-8000-000000000001','infrastructure-as-code','explanation','O que é Infrastructure as Code?',
$c$Infrastructure as Code — **IaC** — é a prática de definir e gerenciar infraestrutura usando arquivos ou código, em vez de realizar toda configuração manualmente.

A definição pode ser armazenada, revisada e usada em deployments automatizados para criar ou configurar ambientes de forma mais previsível.$c$,null,null,1),
('7b270000-0000-4000-8000-000000000002','infrastructure-as-code','important','Benefícios centrais de IaC',
$c$- **Repeatability:** a mesma definição pode ser aplicada novamente.
- **Consistency:** ambientes seguem uma fonte comum.
- **Automation:** reduz etapas manuais repetitivas.
- **Version control:** mudanças na definição podem ser acompanhadas.
- **Reproducibility:** ambientes semelhantes ficam mais fáceis de recriar.

IaC reduz configuração manual, mas ainda exige revisão, testes e permissões adequadas.$c$,null,null,2),
('7b270000-0000-4000-8000-000000000003','infrastructure-as-code','important','Manual Provisioning versus IaC',
$c$| Manual Provisioning | Infrastructure as Code |
| --- | --- |
| Portal → clicks → configure → create | Infrastructure definition → deployment → resources |
| A sequência precisa ser repetida manualmente | A definição pode ser reutilizada |
| Maior chance de variações entre ambientes | Favorece consistência e reprodução |
| Útil para exploração e tarefas pontuais | Útil para deployments repetíveis e automatizados |

Não são categorias absolutas: equipes podem explorar no portal e depois formalizar a infraestrutura como código.$c$,null,null,3),
('7b270000-0000-4000-8000-000000000004','infrastructure-as-code','example','Development, Test e Production',
$c$Uma equipe usa a mesma definição de infraestrutura para três ambientes:

- Development → template + parâmetros de desenvolvimento
- Test → mesmo template + parâmetros de teste
- Production → mesmo template + parâmetros de produção

A base comum reduz diferenças acidentais, enquanto parâmetros permitem valores apropriados a cada ambiente.$c$,null,null,4),
('7b270000-0000-4000-8000-000000000005','infrastructure-as-code','explanation','Declarative versus imperative',
$c$| Abordagem | O que descreve |
| --- | --- |
| Declarative | o estado desejado: “quero estes recursos e propriedades” |
| Imperative | a sequência de ações: “crie A, configure A, crie B, conecte B” |

O mecanismo declarativo determina como alcançar o estado descrito. ARM Templates são principalmente declarativos.$c$,null,null,5),
('7b270000-0000-4000-8000-000000000006','infrastructure-as-code','example','Descrever o estado desejado',
$c$Uma definição declara que o ambiente deve conter um Storage Account, um App Service e uma Virtual Network. O autor descreve os recursos desejados; não precisa representar a implantação como uma lista manual de clicks ou comandos em ordem.$c$,null,null,6),
('7b270000-0000-4000-8000-000000000007','infrastructure-as-code','exam_trap','Declarative não é sequência manual',
$c$Uma lista de comandos “crie A, depois B” pode automatizar uma tarefa, mas continua descrevendo passos imperativos. Uma definição declarativa descreve principalmente **o estado que deve existir**.

Automação e declaratividade são conceitos relacionados, mas não são sinônimos.$c$,null,null,7),
('7b270000-0000-4000-8000-000000000008','infrastructure-as-code','important','Version control registra a definição',
$c$Arquivos de IaC podem ser mantidos em version control. Isso ajuda a revisar alterações, entender a evolução da infraestrutura e colaborar sobre uma fonte comum.

Version control não garante que toda alteração esteja correta; ele oferece histórico e processo para administrá-la.$c$,null,null,8),
('7b270000-0000-4000-8000-000000000009','infrastructure-as-code','example','Recriar um ambiente',
$c$Após perder um ambiente de testes descartável, a equipe reutiliza a definição versionada e seus parâmetros para criar uma configuração equivalente. Esse cenário demonstra reprodução e consistência, não restauração automática de dados.$c$,null,null,9),
('7b270000-0000-4000-8000-000000000010','infrastructure-as-code','exam_trap','IaC não garante infraestrutura perfeita',
$c$Uma definição repetível também pode repetir um erro. IaC reduz variações manuais e melhora consistência, mas não substitui validação, segurança, revisão ou backup.$c$,null,null,10),
('7b270000-0000-4000-8000-000000000011','infrastructure-as-code','exam_tip','Procure os sinais de IaC',
$c$Deployments repetíveis, configuração consistente, automação, infraestrutura versionada e ambientes reproduzíveis apontam para **Infrastructure as Code**.$c$,null,null,11),
('7b270000-0000-4000-8000-000000000012','infrastructure-as-code','summary','Resumo para memória ativa',null,
'{"items":["IaC define e gerencia infraestrutura por arquivos ou código.","Favorece repeatability, consistency, automation e version control.","A mesma definição com parâmetros diferentes pode atender dev, test e production.","Declarative descreve o estado desejado; imperative descreve passos.","ARM Templates são declarativos.","IaC reduz trabalho manual, mas não elimina testes, segurança ou revisão."]}'::jsonb,null,12),

('7b270000-0000-4000-8000-000000000013','azure-resource-manager-and-arm-templates','explanation','O que é Azure Resource Manager?',
$c$Azure Resource Manager — **ARM** — é o serviço e a **camada de gerenciamento e deployment do Azure**. Ele recebe solicitações para criar, atualizar, organizar ou excluir recursos e coordena essas operações de forma consistente.

ARM não é hardware nem um recurso específico dentro de uma Subscription.$c$,null,null,1),
('7b270000-0000-4000-8000-000000000014','azure-resource-manager-and-arm-templates','important','Múltiplas ferramentas, camada comum',
$c$Azure portal, Azure CLI, Azure PowerShell, ARM Templates, REST APIs e SDKs podem enviar solicitações de gerenciamento. Azure Resource Manager recebe essas solicitações, realiza verificações de autenticação/autorização e as encaminha ao serviço Azure apropriado.

O Portal não substitui ARM; ele é uma das interfaces que usam essa camada.$c$,null,null,2),
('7b270000-0000-4000-8000-000000000015','azure-resource-manager-and-arm-templates','visual_experience','Explore o fluxo comum de gerenciamento',null,null,
'76000000-0000-4000-8000-000000000016',3),
('7b270000-0000-4000-8000-000000000016','azure-resource-manager-and-arm-templates','explanation','ARM e Resource Providers',
$c$Um **Resource Provider** fornece tipos de recurso e operações para um serviço Azure. ARM coordena a solicitação com o provider apropriado.

- `Microsoft.Compute` → tipos de recursos de compute.
- `Microsoft.Storage` → tipos de recursos de storage.

O AZ-900 exige entender essa relação, não memorizar namespaces, API versions ou processos de registro.$c$,null,null,4),
('7b270000-0000-4000-8000-000000000017','azure-resource-manager-and-arm-templates','exam_trap','ARM não é VM, CLI ou template',
$c$Azure Resource Manager não é uma VM, Resource Group, linha de comando, arquivo de template ou servidor físico. É a camada comum de gerenciamento usada pelas ferramentas para operar recursos Azure.$c$,null,null,5),
('7b270000-0000-4000-8000-000000000018','azure-resource-manager-and-arm-templates','explanation','O que é ARM Template?',
$c$Um **ARM Template** é um arquivo **JSON declarativo** que define infraestrutura Azure. Ele descreve recursos e propriedades que devem existir e é enviado ao Azure Resource Manager para deployment.

ARM é a camada de gerenciamento; ARM Template é uma definição de Infrastructure as Code usada por essa camada.$c$,null,null,6),
('7b270000-0000-4000-8000-000000000019','azure-resource-manager-and-arm-templates','important','Deployment consistente e repetível',
$c$```text
ARM Template
     ↓
Azure Resource Manager
     ↓
Azure Resources
```

Como definição declarativa, o template favorece deployments automatizados, consistentes e repetíveis. O mesmo template pode ser reutilizado com valores diferentes para ambientes distintos.$c$,null,null,7),
('7b270000-0000-4000-8000-000000000020','azure-resource-manager-and-arm-templates','important','Estrutura conceitual do template',
$c$| Elemento | Papel conceitual |
| --- | --- |
| Parameters | valores que podem variar entre deployments, como região ou SKU |
| Variables | valores reutilizados dentro da definição |
| Resources | infraestrutura que será criada ou configurada |
| Outputs | valores retornados depois do deployment |

Para Fundamentals, reconheça a finalidade. Não é necessário escrever JSON.$c$,null,null,8),
('7b270000-0000-4000-8000-000000000021','azure-resource-manager-and-arm-templates','example','Mesmo template, parâmetros diferentes',
$c$Um ARM Template define App Service e Storage Account. Development usa um SKU menor; Production usa outro SKU e região, fornecidos por parameters. A definição dos tipos de recurso permanece consistente sem exigir cópias manuais independentes.$c$,null,null,9),
('7b270000-0000-4000-8000-000000000022','azure-resource-manager-and-arm-templates','important','ARM Templates e Bicep',
$c$| Opção | Contexto |
| --- | --- |
| ARM Template | definição declarativa em JSON |
| Bicep | linguagem declarativa moderna da Microsoft com sintaxe de autoria mais simples |

Ambos implantam recursos por Azure Resource Manager. A Microsoft recomenda Bicep para nova autoria, mas o objetivo oficial continua exigindo reconhecer ARM, ARM Templates e IaC. Bicep não substitui esses conceitos nesta Lesson.$c$,null,null,10),
('7b270000-0000-4000-8000-000000000023','azure-resource-manager-and-arm-templates','exam_trap','ARM e ARM Template não são sinônimos',
$c$ARM é o serviço/camada de gerenciamento. ARM Template é um arquivo JSON declarativo processado por ARM.

Também não confunda template declarativo com uma sequência manual de comandos. Ele descreve principalmente o estado desejado.$c$,null,null,11),
('7b270000-0000-4000-8000-000000000024','azure-resource-manager-and-arm-templates','example','Solicitação do Portal e deployment de template',
$c$Uma pessoa cria um Storage Account pelo portal; outra implanta o mesmo tipo de recurso por ARM Template. As interfaces de entrada diferem, mas ambas usam Azure Resource Manager e o Resource Provider correspondente para administrar o recurso.$c$,null,null,12),
('7b270000-0000-4000-8000-000000000025','azure-resource-manager-and-arm-templates','exam_tip','Reconheça camada e definição',
$c$“Qual camada recebe solicitações do Portal, CLI e PowerShell?” → **Azure Resource Manager**.

“Qual arquivo JSON declarativo define recursos para deployment repetível?” → **ARM Template**.$c$,null,null,13),
('7b270000-0000-4000-8000-000000000026','azure-resource-manager-and-arm-templates','summary','Resumo para memória ativa',null,
'{"items":["Azure Resource Manager é a camada comum de gerenciamento e deployment do Azure.","Portal, CLI, PowerShell, templates e APIs enviam solicitações por ARM.","Resource Providers fornecem tipos de recursos, como Microsoft.Compute e Microsoft.Storage.","ARM Template é JSON declarativo usado para definir infraestrutura Azure.","Parameters variam valores; resources definem infraestrutura; outputs retornam valores.","ARM Templates favorecem deployments consistentes e repetíveis.","Bicep é uma linguagem declarativa moderna que também usa ARM; não substitui o objetivo de ARM Templates."]}'::jsonb,null,14);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.visual_id,seed.display_order,true
from stage_964_blocks seed join public.lessons lesson
  on lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug=seed.lesson_slug;

create temporary table stage_964_cards(id uuid primary key,lesson_slug text,front_text text,back_text text,hint text,display_order integer) on commit drop;
insert into stage_964_cards values
('7e460000-0000-4000-8000-000000000001','infrastructure-as-code','O que é Infrastructure as Code?','A prática de definir e gerenciar infraestrutura usando arquivos ou código.','IaC.',1),
('7e460000-0000-4000-8000-000000000002','infrastructure-as-code','Que benefício de IaC permite repetir uma definição?','Repeatability, favorecendo deployments consistentes.','Reutilização.',2),
('7e460000-0000-4000-8000-000000000003','infrastructure-as-code','Como IaC ajuda dev, test e production?','A mesma definição pode ser usada com parâmetros apropriados para cada ambiente.','Reprodução.',3),
('7e460000-0000-4000-8000-000000000004','infrastructure-as-code','O que uma abordagem declarative descreve?','O estado desejado da infraestrutura.','O quê, não a sequência.',4),
('7e460000-0000-4000-8000-000000000005','infrastructure-as-code','O que uma abordagem imperative descreve?','Uma sequência de ações ou comandos para alcançar o resultado.','Passos.',5),
('7e460000-0000-4000-8000-000000000006','infrastructure-as-code','Por que manter IaC em version control?','Para acompanhar, revisar e colaborar sobre mudanças na definição.','Histórico.',6),
('7e460000-0000-4000-8000-000000000007','azure-resource-manager-and-arm-templates','O que é Azure Resource Manager?','A camada de gerenciamento e deployment que coordena operações sobre recursos Azure.','ARM.',1),
('7e460000-0000-4000-8000-000000000008','azure-resource-manager-and-arm-templates','Portal, CLI e PowerShell usam qual camada comum?','Azure Resource Manager.','Solicitações de gerenciamento.',2),
('7e460000-0000-4000-8000-000000000009','azure-resource-manager-and-arm-templates','Qual o papel de um Resource Provider?','Fornecer tipos de recurso e operações que ARM pode gerenciar.','Microsoft.Compute.',3),
('7e460000-0000-4000-8000-000000000010','azure-resource-manager-and-arm-templates','O que é um ARM Template?','Um arquivo JSON declarativo que define infraestrutura Azure.','Definição IaC.',4),
('7e460000-0000-4000-8000-000000000011','azure-resource-manager-and-arm-templates','ARM e ARM Template são a mesma coisa?','Não. ARM é a camada de gerenciamento; template é a definição JSON processada por ela.','Serviço versus arquivo.',5),
('7e460000-0000-4000-8000-000000000012','azure-resource-manager-and-arm-templates','Para que servem parameters em ARM Template?','Para fornecer valores que podem variar entre deployments.','Região ou SKU.',6),
('7e460000-0000-4000-8000-000000000013','azure-resource-manager-and-arm-templates','O que a seção resources representa?','A infraestrutura que será criada ou configurada.','Recursos desejados.',7),
('7e460000-0000-4000-8000-000000000014','azure-resource-manager-and-arm-templates','Como Bicep se relaciona com ARM?','É uma linguagem declarativa moderna que também implanta recursos por Azure Resource Manager.','Contexto moderno.',8);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true from stage_964_cards seed
join public.lessons lesson on lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug=seed.lesson_slug;

create temporary table stage_964_questions(id uuid primary key,lesson_slug text,question_text text,difficulty text,explanation text,display_order integer) on commit drop;
insert into stage_964_questions values
('68000000-0000-4000-8000-000000000154','infrastructure-as-code','Qual afirmação define Infrastructure as Code?','easy','IaC define e gerencia infraestrutura com arquivos ou código, reduzindo a dependência de configuração manual.',1),
('68000000-0000-4000-8000-000000000155','infrastructure-as-code','O que caracteriza uma definição declarative?','easy','Ela descreve o estado desejado; o mecanismo determina as operações necessárias para alcançá-lo.',2),
('68000000-0000-4000-8000-000000000156','infrastructure-as-code','Uma empresa quer reproduzir infraestrutura em dev, test e production com diferenças de região e SKU. Qual abordagem é apropriada?','medium','Uma definição IaC comum com parameters por ambiente favorece consistência, repetição e variações controladas.',3),
('68000000-0000-4000-8000-000000000157','infrastructure-as-code','Uma equipe deseja revisar o histórico das mudanças feitas na infraestrutura definida como código. Qual prática ajuda diretamente?','medium','Manter os arquivos de IaC em version control permite acompanhar e revisar mudanças na definição.',4),
('68000000-0000-4000-8000-000000000158','infrastructure-as-code','Uma equipe automatizou uma sequência de comandos e concluiu que toda automação é necessariamente declarative. Qual análise está correta?','hard','A conclusão é incorreta: automação pode ser imperative; declarative descreve principalmente o estado desejado.',5),
('68000000-0000-4000-8000-000000000159','azure-resource-manager-and-arm-templates','Qual camada recebe solicitações de gerenciamento do Portal, CLI, PowerShell e APIs?','easy','Azure Resource Manager é a camada comum de gerenciamento e deployment do Azure.',1),
('68000000-0000-4000-8000-000000000160','azure-resource-manager-and-arm-templates','Qual opção descreve um ARM Template?','easy','ARM Template é um arquivo JSON declarativo usado para definir recursos Azure.',2),
('68000000-0000-4000-8000-000000000161','azure-resource-manager-and-arm-templates','Qual elemento de ARM Template permite variar região ou SKU entre deployments?','easy','Parameters recebem valores que podem variar por deployment sem duplicar toda a definição.',3),
('68000000-0000-4000-8000-000000000162','azure-resource-manager-and-arm-templates','Qual é o papel conceitual de um Resource Provider?','easy','O Resource Provider fornece tipos de recurso e operações para um serviço que ARM pode gerenciar.',4),
('68000000-0000-4000-8000-000000000163','azure-resource-manager-and-arm-templates','Uma pessoa cria um recurso pelo Portal e outra usa Azure CLI. Qual afirmação está correta?','medium','As interfaces diferem, mas ambas enviam solicitações pela camada comum Azure Resource Manager.',5),
('68000000-0000-4000-8000-000000000164','azure-resource-manager-and-arm-templates','Uma empresa quer implantar a mesma infraestrutura JSON várias vezes de modo consistente. Qual opção atende diretamente?','medium','ARM Template fornece uma definição JSON declarativa processada por ARM para deployments repetíveis.',6),
('68000000-0000-4000-8000-000000000165','azure-resource-manager-and-arm-templates','Qual afirmação diferencia Azure Resource Manager de ARM Template?','medium','ARM é a camada/serviço de gerenciamento; ARM Template é um arquivo declarativo usado em deployments.',7),
('68000000-0000-4000-8000-000000000166','azure-resource-manager-and-arm-templates','Um template deve retornar após o deployment o nome de um recurso criado. Qual elemento conceitual atende a isso?','medium','Outputs retornam valores depois do deployment; resources descrevem a infraestrutura e parameters fornecem entradas.',8),
('68000000-0000-4000-8000-000000000167','azure-resource-manager-and-arm-templates','Uma equipe afirma que Azure Portal substitui Azure Resource Manager porque o recurso foi criado visualmente. Qual análise está correta?','hard','A afirmação está errada: Portal é uma interface que envia a solicitação pela camada Azure Resource Manager.',9),
('68000000-0000-4000-8000-000000000168','azure-resource-manager-and-arm-templates','Uma equipe prefere Bicep para nova autoria e conclui que não precisa entender ARM Templates no AZ-900. Qual análise está correta?','hard','Bicep é uma opção declarativa moderna que usa ARM, mas o objetivo oficial ainda exige reconhecer ARM Templates JSON e IaC.',10);
insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_964_questions seed join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure management and governance'
join public.topics topic on topic.domain_id=domain.id and topic.id='33000000-0000-4000-8000-000000000003'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug=seed.lesson_slug;

create temporary table stage_964_options(id uuid primary key,question_id uuid,option_text text,is_correct boolean,explanation text,display_order integer) on commit drop;
insert into stage_964_options values
('7f260000-0000-4000-8000-000000000001','68000000-0000-4000-8000-000000000154','Definir e gerenciar infraestrutura com arquivos ou código.',true,'Correta. Essa é a prática IaC.',1),
('7f260000-0000-4000-8000-000000000002','68000000-0000-4000-8000-000000000154','Configurar tudo exclusivamente por clicks.',false,'Isso descreve provisionamento manual.',2),
('7f260000-0000-4000-8000-000000000003','68000000-0000-4000-8000-000000000154','Migrar automaticamente qualquer workload.',false,'IaC não é serviço de migração.',3),
('7f260000-0000-4000-8000-000000000004','68000000-0000-4000-8000-000000000154','Monitorar somente custos Azure.',false,'IaC não é ferramenta exclusiva de custos.',4),
('7f260000-0000-4000-8000-000000000005','68000000-0000-4000-8000-000000000155','Descreve o estado desejado.',true,'Correta. Declarative foca o resultado esperado.',1),
('7f260000-0000-4000-8000-000000000006','68000000-0000-4000-8000-000000000155','Exige listar manualmente todos os clicks.',false,'Isso não define abordagem declarative.',2),
('7f260000-0000-4000-8000-000000000007','68000000-0000-4000-8000-000000000155','Descreve apenas uma sequência de comandos.',false,'Isso caracteriza imperative.',3),
('7f260000-0000-4000-8000-000000000008','68000000-0000-4000-8000-000000000155','Elimina a necessidade de definir recursos.',false,'A definição precisa declarar os recursos.',4),
('7f260000-0000-4000-8000-000000000009','68000000-0000-4000-8000-000000000156','IaC com uma definição comum e parameters por ambiente.',true,'Correta. Favorece consistência com variações controladas.',1),
('7f260000-0000-4000-8000-000000000010','68000000-0000-4000-8000-000000000156','Repetir manualmente todos os clicks sem registro.',false,'Eleva a chance de divergência.',2),
('7f260000-0000-4000-8000-000000000011','68000000-0000-4000-8000-000000000156','Usar somente Resource Locks.',false,'Locks não reproduzem infraestrutura.',3),
('7f260000-0000-4000-8000-000000000012','68000000-0000-4000-8000-000000000156','Criar uma Subscription por parâmetro.',false,'Subscription não substitui IaC.',4),
('7f260000-0000-4000-8000-000000000013','68000000-0000-4000-8000-000000000157','Version control.',true,'Correta. Registra o histórico da definição.',1),
('7f260000-0000-4000-8000-000000000014','68000000-0000-4000-8000-000000000157','Availability Zone.',false,'Zone não registra mudanças em arquivos.',2),
('7f260000-0000-4000-8000-000000000015','68000000-0000-4000-8000-000000000157','Resource Lock.',false,'Lock protege operações, não versiona definições.',3),
('7f260000-0000-4000-8000-000000000016','68000000-0000-4000-8000-000000000157','Azure Migrate.',false,'Migrate não é version control.',4),
('7f260000-0000-4000-8000-000000000017','68000000-0000-4000-8000-000000000158','Incorreta: automação pode seguir passos imperative.',true,'Correta. Automação e declaratividade não são sinônimos.',1),
('7f260000-0000-4000-8000-000000000018','68000000-0000-4000-8000-000000000158','Correta: todo script é declarative.',false,'Scripts podem descrever ações imperative.',2),
('7f260000-0000-4000-8000-000000000019','68000000-0000-4000-8000-000000000158','Correta somente se executado no Portal.',false,'A interface não determina isso.',3),
('7f260000-0000-4000-8000-000000000020','68000000-0000-4000-8000-000000000158','Incorreta porque IaC nunca pode automatizar.',false,'IaC pode apoiar automação.',4),
('7f260000-0000-4000-8000-000000000021','68000000-0000-4000-8000-000000000159','Azure Resource Manager.',true,'Correta. ARM é a camada comum.',1),
('7f260000-0000-4000-8000-000000000022','68000000-0000-4000-8000-000000000159','Azure Virtual Machine.',false,'VM é um recurso, não a camada.',2),
('7f260000-0000-4000-8000-000000000023','68000000-0000-4000-8000-000000000159','Resource Group.',false,'Resource Group é um container.',3),
('7f260000-0000-4000-8000-000000000024','68000000-0000-4000-8000-000000000159','Azure Migrate.',false,'Migrate trata migração.',4),
('7f260000-0000-4000-8000-000000000025','68000000-0000-4000-8000-000000000160','Arquivo JSON declarativo que define recursos Azure.',true,'Correta. Essa é a definição de ARM Template.',1),
('7f260000-0000-4000-8000-000000000026','68000000-0000-4000-8000-000000000160','Uma CLI exclusiva para Azure.',false,'Template é arquivo, não CLI.',2),
('7f260000-0000-4000-8000-000000000027','68000000-0000-4000-8000-000000000160','Um servidor físico de gerenciamento.',false,'ARM Template não é hardware.',3),
('7f260000-0000-4000-8000-000000000028','68000000-0000-4000-8000-000000000160','Uma ferramenta de monitoramento.',false,'Template define infraestrutura.',4),
('7f260000-0000-4000-8000-000000000029','68000000-0000-4000-8000-000000000161','Parameters.',true,'Correta. Fornecem valores variáveis.',1),
('7f260000-0000-4000-8000-000000000030','68000000-0000-4000-8000-000000000161','Outputs.',false,'Outputs retornam valores.',2),
('7f260000-0000-4000-8000-000000000031','68000000-0000-4000-8000-000000000161','Resources.',false,'Resources definem infraestrutura.',3),
('7f260000-0000-4000-8000-000000000032','68000000-0000-4000-8000-000000000161','Resource Locks.',false,'Locks não são elemento de template.',4),
('7f260000-0000-4000-8000-000000000033','68000000-0000-4000-8000-000000000162','Fornecer tipos de recurso e operações para um serviço Azure.',true,'Correta. ARM coordena com providers.',1),
('7f260000-0000-4000-8000-000000000034','68000000-0000-4000-8000-000000000162','Substituir Azure Resource Manager.',false,'Providers trabalham com ARM.',2),
('7f260000-0000-4000-8000-000000000035','68000000-0000-4000-8000-000000000162','Criar usuários no Entra ID exclusivamente.',false,'Não é a definição geral de provider.',3),
('7f260000-0000-4000-8000-000000000036','68000000-0000-4000-8000-000000000162','Armazenar o JSON do template.',false,'Provider fornece tipos/operações.',4),
('7f260000-0000-4000-8000-000000000037','68000000-0000-4000-8000-000000000163','Ambas usam Azure Resource Manager como camada comum.',true,'Correta. As interfaces de entrada diferem.',1),
('7f260000-0000-4000-8000-000000000038','68000000-0000-4000-8000-000000000163','Portal substitui ARM; CLI não usa ARM.',false,'Ambas usam ARM.' ,2),
('7f260000-0000-4000-8000-000000000039','68000000-0000-4000-8000-000000000163','CLI é um Resource Provider.',false,'CLI é ferramenta cliente.',3),
('7f260000-0000-4000-8000-000000000040','68000000-0000-4000-8000-000000000163','Portal é um ARM Template.',false,'Portal é interface gráfica.',4),
('7f260000-0000-4000-8000-000000000041','68000000-0000-4000-8000-000000000164','ARM Template.',true,'Correta. Define infraestrutura JSON declarativa.',1),
('7f260000-0000-4000-8000-000000000042','68000000-0000-4000-8000-000000000164','Azure portal manual sem definição.',false,'Não atende diretamente à repetição declarativa.',2),
('7f260000-0000-4000-8000-000000000043','68000000-0000-4000-8000-000000000164','Azure Service Health.',false,'Service Health não define infraestrutura.',3),
('7f260000-0000-4000-8000-000000000044','68000000-0000-4000-8000-000000000164','Azure Advisor.',false,'Advisor fornece recomendações.',4),
('7f260000-0000-4000-8000-000000000045','68000000-0000-4000-8000-000000000165','ARM é a camada; ARM Template é um arquivo declarativo.',true,'Correta. Serviço e definição são distintos.',1),
('7f260000-0000-4000-8000-000000000046','68000000-0000-4000-8000-000000000165','São exatamente o mesmo componente.',false,'ARM processa templates, mas não é o arquivo.',2),
('7f260000-0000-4000-8000-000000000047','68000000-0000-4000-8000-000000000165','ARM é JSON; template é hardware.',false,'Os papéis estão incorretos.',3),
('7f260000-0000-4000-8000-000000000048','68000000-0000-4000-8000-000000000165','Template substitui todo Resource Provider.',false,'Providers continuam fornecendo tipos.',4),
('7f260000-0000-4000-8000-000000000049','68000000-0000-4000-8000-000000000166','Outputs.',true,'Correta. Retornam valores após deployment.',1),
('7f260000-0000-4000-8000-000000000050','68000000-0000-4000-8000-000000000166','Parameters.',false,'Parameters fornecem entradas.',2),
('7f260000-0000-4000-8000-000000000051','68000000-0000-4000-8000-000000000166','Resources.',false,'Resources definem infraestrutura.',3),
('7f260000-0000-4000-8000-000000000052','68000000-0000-4000-8000-000000000166','Variables somente.',false,'Variables reutilizam valores internos.',4),
('7f260000-0000-4000-8000-000000000053','68000000-0000-4000-8000-000000000167','Errada: o Portal envia a solicitação por Azure Resource Manager.',true,'Correta. Portal é cliente da camada ARM.',1),
('7f260000-0000-4000-8000-000000000054','68000000-0000-4000-8000-000000000167','Correta: ARM só existe para CLI.',false,'ARM atende várias ferramentas.',2),
('7f260000-0000-4000-8000-000000000055','68000000-0000-4000-8000-000000000167','Correta: Portal é um Resource Provider.',false,'Portal é interface, não provider.',3),
('7f260000-0000-4000-8000-000000000056','68000000-0000-4000-8000-000000000167','Errada porque ARM é uma VM.',false,'ARM não é VM.',4),
('7f260000-0000-4000-8000-000000000057','68000000-0000-4000-8000-000000000168','Incorreta: Bicep é moderno, mas ARM Templates continuam no objetivo.',true,'Correta. Ambos usam ARM e o objetivo inclui templates JSON.',1),
('7f260000-0000-4000-8000-000000000058','68000000-0000-4000-8000-000000000168','Correta: Bicep não usa Azure Resource Manager.',false,'Bicep também implanta via ARM.',2),
('7f260000-0000-4000-8000-000000000059','68000000-0000-4000-8000-000000000168','Correta: ARM Templates deixaram de ser declarativos.',false,'ARM Templates continuam declarativos.',3),
('7f260000-0000-4000-8000-000000000060','68000000-0000-4000-8000-000000000168','Incorreta apenas porque Bicep é imperative.',false,'Bicep é declarative.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_964_options;

do $$ declare lesson_row record; begin
  for lesson_row in select id,slug from public.lessons where topic_id='33000000-0000-4000-8000-000000000003'
    and slug in('infrastructure-as-code','azure-resource-manager-and-arm-templates') loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='infrastructure-as-code' then 12 else 14 end)
      or (select count(*) from public.flashcards where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='infrastructure-as-code' then 6 else 8 end)
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug='infrastructure-as-code' then 5 else 10 end) then
      raise exception '9.6.4 final artifact inventory invalid for %',lesson_row.slug; end if;
  end loop;
end; $$;

commit;

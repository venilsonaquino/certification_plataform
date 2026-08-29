begin;

do $$ begin
  if (select count(*) from public.lessons where topic_id='33000000-0000-4000-8000-000000000003'
      and slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell'))<>4 then
    raise exception '9.6.2 expected four existing target Lessons'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell'))
    or exists(select 1 from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell')) then
    raise exception '9.6.2 expected target Lessons without structured content'; end if;
  if (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug='azure-cloud-shell')<>10
    or (select count(*) from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug='azure-cli')<>10
    or exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug in('azure-portal','azure-powershell')) then
    raise exception '9.6.2 historical Question inventory changed'; end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
      where lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell')) then
    raise exception '9.6.2 must not create a Visual Experience'; end if;
end; $$;

update public.lessons set estimated_minutes=10
where topic_id='33000000-0000-4000-8000-000000000003'
  and slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell');

create temporary table stage_962_blocks(id uuid primary key,lesson_slug text,type text,title text,content text,config jsonb,display_order integer) on commit drop;
insert into stage_962_blocks values
('7b250000-0000-4000-8000-000000000001','azure-portal','explanation','O que é o Azure portal?',
$c$Azure portal é uma **interface gráfica baseada em navegador** para criar, configurar, visualizar e administrar recursos Azure. Ele reúne páginas, formulários, painéis e buscas em uma experiência visual, sem exigir que o usuário memorize comandos.$c$,null,1),
('7b250000-0000-4000-8000-000000000002','azure-portal','important','O que você faz pela interface gráfica?',
$c$Pelo portal, uma equipe pode criar recursos, alterar configurações, consultar propriedades, acompanhar o estado de implantações e navegar entre Subscriptions, Resource Groups e recursos. As ações continuam sujeitas a autenticação, autorização e políticas.$c$,null,2),
('7b250000-0000-4000-8000-000000000003','azure-portal','example','Criar e conferir uma VM',
$c$Um administrador usa o formulário do portal para escolher Subscription, Resource Group, região e tamanho de uma VM. Depois da implantação, abre a página do recurso para conferir propriedades e estado. O portal guiou a operação; a VM continua sendo um recurso administrado pelo Azure Resource Manager.$c$,null,3),
('7b250000-0000-4000-8000-000000000004','azure-portal','important','Quatro opções de administração',
$c$| Opção | O que é | Melhor sinal no cenário |
| --- | --- | --- |
| Azure portal | GUI no navegador | exploração e tarefa visual guiada |
| Cloud Shell | terminal hospedado no navegador | executar comandos sem instalar localmente |
| Azure CLI | ferramenta de comandos `az` | scripts e preferência por sintaxe CLI |
| Azure PowerShell | cmdlets do módulo Az | scripts e ecossistema PowerShell |

APIs e Infrastructure as Code também podem administrar recursos, mas serão estudadas separadamente.$c$,null,4),
('7b250000-0000-4000-8000-000000000005','azure-portal','example','Inspeção pontual',
$c$Uma analista precisa localizar um Resource Group e verificar visualmente quais recursos ele contém. Para uma tarefa pontual e exploratória, o portal é uma escolha natural. Isso não significa que a mesma consulta não possa ser feita por linha de comando ou API.$c$,null,5),
('7b250000-0000-4000-8000-000000000006','azure-portal','explanation','Escolha por contexto',
$c$GUI é útil para descoberta, aprendizado e operações ocasionais. Comandos e scripts tendem a favorecer repetição e automação. A escolha depende da tarefa, da escala e da familiaridade da equipe; nenhuma interface é universalmente superior.$c$,null,6),
('7b250000-0000-4000-8000-000000000007','azure-portal','exam_trap','Portal não é o único método',
$c$O Azure portal não é a única forma de administrar Azure. Azure CLI, Azure PowerShell, Cloud Shell, APIs e Infrastructure as Code oferecem outros caminhos. Cloud Shell também aparece no navegador, mas é um **terminal**, não a GUI do portal.$c$,null,7),
('7b250000-0000-4000-8000-000000000008','azure-portal','example','Quando preferir automação',
$c$Criar manualmente um recurso único pode ser conveniente no portal. Repetir a mesma configuração dezenas de vezes favorece comandos ou automação reproduzível. O requisito de repetição, não uma regra absoluta, orienta a escolha.$c$,null,8),
('7b250000-0000-4000-8000-000000000009','azure-portal','exam_tip','Procure GUI baseada em navegador',
$c$Se a questão pede uma experiência gráfica, visual e acessível pelo navegador para criar ou configurar recursos, Azure portal é a resposta provável. Se pede um terminal pronto no navegador, procure Cloud Shell.$c$,null,9),
('7b250000-0000-4000-8000-000000000010','azure-portal','summary','Resumo para memória ativa',null,
'{"items":["Azure portal é uma GUI baseada em navegador.","Permite criar, configurar, visualizar e administrar recursos.","É útil para exploração e tarefas visuais guiadas.","Cloud Shell é terminal; portal é interface gráfica.","CLI, PowerShell, APIs e IaC são alternativas de administração."]}'::jsonb,10),

('7b250000-0000-4000-8000-000000000011','azure-cloud-shell','explanation','O que é Azure Cloud Shell?',
$c$Azure Cloud Shell é um **terminal interativo e autenticado, acessível pelo navegador e hospedado pela Microsoft**. Ele oferece um ambiente pronto para executar comandos de administração do Azure sem exigir instalação local das principais ferramentas.$c$,null,1),
('7b250000-0000-4000-8000-000000000012','azure-cloud-shell','important','Hospedado, preconfigurado e autenticado',
$c$A Microsoft mantém o ambiente de shell e disponibiliza ferramentas comuns preconfiguradas. Ao abrir o Cloud Shell com sua conta, a autenticação integrada facilita o uso do Azure CLI ou Azure PowerShell, sempre respeitando as permissões da identidade.$c$,null,2),
('7b250000-0000-4000-8000-000000000013','azure-cloud-shell','important','Bash ou PowerShell',
$c$Cloud Shell oferece experiências **Bash** e **PowerShell**. Bash combina naturalmente com Azure CLI; PowerShell combina com cmdlets Az. A escolha do shell não muda as permissões concedidas à identidade.$c$,null,3),
('7b250000-0000-4000-8000-000000000014','azure-cloud-shell','important','Ambiente versus ferramenta',
$c$| Conceito | Papel |
| --- | --- |
| Cloud Shell | ambiente de terminal hospedado no navegador |
| Azure CLI | ferramenta de linha de comando com comandos `az` |
| Azure PowerShell | ferramenta baseada em cmdlets do módulo Az |

CLI e PowerShell podem ser executados dentro do Cloud Shell ou fora dele, em ambientes compatíveis.$c$,null,4),
('7b250000-0000-4000-8000-000000000015','azure-cloud-shell','example','Administrar sem instalação local',
$c$Em um computador onde não pode instalar software, um administrador abre Cloud Shell no navegador e executa `az group list` para consultar Resource Groups. Cloud Shell fornece o ambiente; `az` identifica a ferramenta Azure CLI.$c$,null,5),
('7b250000-0000-4000-8000-000000000016','azure-cloud-shell','explanation','Uso interativo',
$c$Cloud Shell é especialmente conveniente para comandos interativos e tarefas administrativas rápidas. Ele remove o preparo local inicial, mas não transforma cada comando em automação nem concede permissões adicionais.$c$,null,6),
('7b250000-0000-4000-8000-000000000017','azure-cloud-shell','exam_trap','Cloud Shell não é Azure CLI',
$c$Cloud Shell e Azure CLI não são sinônimos. Cloud Shell é o **ambiente**; Azure CLI é uma das **ferramentas** que podem rodar nele. Da mesma forma, Azure PowerShell também pode ser usado no Cloud Shell e fora dele.$c$,null,7),
('7b250000-0000-4000-8000-000000000018','azure-cloud-shell','example','Escolha guiada pelo requisito',
$c$Para uma GUI visual no navegador, use o portal. Para um terminal já preparado no navegador, use Cloud Shell. Para automatizar com sintaxe `az`, escolha Azure CLI; para trabalhar com cmdlets e objetos PowerShell, escolha Azure PowerShell.$c$,null,8),
('7b250000-0000-4000-8000-000000000019','azure-cloud-shell','exam_tip','Terminal pronto no navegador',
$c$Palavras como **terminal no navegador**, **sem instalação local**, **Bash ou PowerShell** e **ferramentas preconfiguradas** apontam para Azure Cloud Shell.$c$,null,9),
('7b250000-0000-4000-8000-000000000020','azure-cloud-shell','summary','Resumo para memória ativa',null,
'{"items":["Cloud Shell é um terminal interativo hospedado no navegador.","O ambiente é mantido pela Microsoft e vem preconfigurado.","Oferece Bash e PowerShell.","A autenticação integrada usa as permissões da identidade.","Cloud Shell é ambiente; CLI e PowerShell são ferramentas."]}'::jsonb,10),

('7b250000-0000-4000-8000-000000000021','azure-cli','explanation','O que é Azure CLI?',
$c$Azure CLI é uma ferramenta de linha de comando **multiplataforma** para criar, consultar e administrar recursos Azure. Seus comandos começam normalmente com `az` e funcionam bem tanto em tarefas interativas quanto em scripts.$c$,null,1),
('7b250000-0000-4000-8000-000000000022','azure-cli','important','Reconheça a sintaxe az',
$c$Exemplos ilustrativos: `az group list` consulta Resource Groups e `az vm list` consulta VMs. Para o AZ-900, reconheça a finalidade e o prefixo `az`; não é necessário memorizar parâmetros ou construir um tutorial completo.$c$,null,2),
('7b250000-0000-4000-8000-000000000023','azure-cli','example','Consulta rápida',
$c$Uma pessoa prefere terminal e precisa listar VMs. Ela pode executar `az vm list` em uma instalação local compatível ou dentro do Cloud Shell. O comando pertence ao Azure CLI; o local de execução é uma escolha separada.$c$,null,3),
('7b250000-0000-4000-8000-000000000024','azure-cli','explanation','Scripts, repetição e automação',
$c$Comandos podem ser organizados em scripts para repetir operações de maneira consistente. Isso favorece automação e reduz trabalho manual, embora ainda sejam necessários testes, permissões e tratamento adequado de erros.$c$,null,4),
('7b250000-0000-4000-8000-000000000025','azure-cli','important','Azure CLI versus Azure PowerShell',
$c$| Aspecto | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Identificador | comandos `az` | cmdlets do módulo Az |
| Estilo | comandos e opções | `Verb-AzNoun` e objetos PowerShell |
| Plataformas | Windows, macOS e Linux | Windows, macOS e Linux com PowerShell atual |
| Escolha comum | preferência por sintaxe CLI | preferência pelo ecossistema PowerShell |

Ambas administram Azure e apoiam automação; a diferença não é “uma funciona e a outra não”.$c$,null,5),
('7b250000-0000-4000-8000-000000000026','azure-cli','important','Onde pode ser executado?',
$c$Azure CLI pode ser instalada em ambientes compatíveis e também já está disponível no Cloud Shell. Ser multiplataforma descreve a ferramenta; ser hospedado no navegador descreve o ambiente Cloud Shell.$c$,null,6),
('7b250000-0000-4000-8000-000000000027','azure-cli','exam_trap','CLI não é exclusiva de Linux nem do Cloud Shell',
$c$Azure CLI funciona em Windows, macOS e Linux. Ela pode rodar localmente ou em ambientes hospedados como Cloud Shell. Não confunda o prefixo `az` da CLI com os cmdlets `Az` do PowerShell.$c$,null,7),
('7b250000-0000-4000-8000-000000000028','azure-cli','example','Cenário de repetição',
$c$Uma equipe precisa repetir consultas e operações em várias assinaturas e já usa scripts com sintaxe de linha de comando. Azure CLI é uma opção adequada pela automação e repetibilidade; isso não impede o uso de PowerShell por outra equipe.$c$,null,8),
('7b250000-0000-4000-8000-000000000029','azure-cli','exam_tip','Procure comandos az',
$c$Quando o cenário menciona comandos iniciados por `az`, preferência por sintaxe CLI, scripts multiplataforma ou automação por linha de comando, identifique Azure CLI. Terminal no navegador, isoladamente, descreve Cloud Shell.$c$,null,9),
('7b250000-0000-4000-8000-000000000030','azure-cli','summary','Resumo para memória ativa',null,
'{"items":["Azure CLI é uma ferramenta de linha de comando multiplataforma.","Seus comandos usam o prefixo az.","az group list e az vm list são exemplos ilustrativos.","Scripts favorecem automação e repetibilidade.","CLI pode rodar localmente ou no Cloud Shell.","PowerShell usa cmdlets Az e outro estilo de automação."]}'::jsonb,10),

('7b250000-0000-4000-8000-000000000031','azure-powershell','explanation','O que é Azure PowerShell?',
$c$Azure PowerShell é o conjunto de módulos e cmdlets para administrar recursos Azure no ecossistema PowerShell. O módulo **Az** fornece comandos que podem ser usados interativamente ou em scripts.$c$,null,1),
('7b250000-0000-4000-8000-000000000032','azure-powershell','important','Cmdlets do módulo Az',
$c$Cmdlets seguem o padrão PowerShell **Verb-AzNoun**. `Get-AzResourceGroup` consulta Resource Groups e `Get-AzVM` consulta VMs. Para Fundamentals, reconheça o padrão e a finalidade; não memorize instalação ou parâmetros.$c$,null,2),
('7b250000-0000-4000-8000-000000000033','azure-powershell','example','Trabalhar com objetos PowerShell',
$c$Uma equipe que já usa PowerShell executa `Get-AzVM` e continua processando os objetos retornados em seu script. Essa integração com cmdlets, pipeline e objetos do PowerShell pode tornar Azure PowerShell a escolha mais familiar.$c$,null,3),
('7b250000-0000-4000-8000-000000000034','azure-powershell','explanation','Scripts e automação',
$c$Cmdlets podem ser combinados em scripts para consultar ou administrar recursos com consistência. Azure PowerShell apoia automação como Azure CLI; a escolha costuma refletir sintaxe, ecossistema e habilidades da equipe.$c$,null,4),
('7b250000-0000-4000-8000-000000000035','azure-powershell','important','Também é multiplataforma',
$c$Azure PowerShell não deve ser tratado como ferramenta exclusiva do Windows. Com versões atuais e compatíveis do PowerShell, os módulos Az podem ser usados em Windows, macOS e Linux.$c$,null,5),
('7b250000-0000-4000-8000-000000000036','azure-powershell','important','Ferramenta e ambiente',
$c$Azure PowerShell pode rodar em um ambiente local compatível ou no Cloud Shell. O primeiro descreve a ferramenta de cmdlets; o segundo descreve o terminal hospedado no navegador.$c$,null,6),
('7b250000-0000-4000-8000-000000000037','azure-powershell','exam_trap','Az não significa Azure CLI',
$c$`Get-AzVM` é um cmdlet do Azure PowerShell; `az vm list` é um comando Azure CLI. As duas ferramentas podem alcançar objetivos parecidos, mas usam sintaxe e ecossistemas diferentes. Azure PowerShell também não é Windows-only.$c$,null,7),
('7b250000-0000-4000-8000-000000000038','azure-powershell','example','Escolha por familiaridade',
$c$Uma organização já mantém scripts PowerShell que processam objetos e quer incluir operações Azure. Cmdlets Az são uma opção natural. Se a equipe preferisse comandos `az`, Azure CLI também poderia atender muitos dos mesmos cenários.$c$,null,8),
('7b250000-0000-4000-8000-000000000039','azure-powershell','exam_tip','Procure Verb-AzNoun',
$c$Cmdlets como `Get-AzResourceGroup` e `Get-AzVM`, referências a módulos Az, pipeline de objetos ou ecossistema PowerShell apontam para Azure PowerShell.$c$,null,9),
('7b250000-0000-4000-8000-000000000040','azure-powershell','summary','Resumo para memória ativa',null,
'{"items":["Azure PowerShell usa módulos e cmdlets para administrar Azure.","O módulo Az segue o padrão Verb-AzNoun.","Get-AzResourceGroup e Get-AzVM são exemplos.","Cmdlets apoiam tarefas interativas, scripts e automação.","Azure PowerShell é multiplataforma em ambientes compatíveis.","Cloud Shell é ambiente; Azure PowerShell é ferramenta."]}'::jsonb,10);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,null,seed.display_order,true
from stage_962_blocks seed join public.lessons lesson
  on lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug=seed.lesson_slug;

create temporary table stage_962_cards(id uuid primary key,lesson_slug text,front_text text,back_text text,hint text,display_order integer) on commit drop;
insert into stage_962_cards values
('7e440000-0000-4000-8000-000000000001','azure-portal','O que é o Azure portal?','Uma interface gráfica baseada em navegador para administrar recursos Azure.','GUI.',1),
('7e440000-0000-4000-8000-000000000002','azure-portal','Quais ações centrais o portal permite?','Criar, configurar, visualizar e administrar recursos Azure.','Operações visuais.',2),
('7e440000-0000-4000-8000-000000000003','azure-portal','Portal e Cloud Shell são a mesma interface?','Não. Portal é GUI; Cloud Shell é terminal hospedado no navegador.','Visual versus terminal.',3),
('7e440000-0000-4000-8000-000000000004','azure-portal','Quando o portal é uma escolha natural?','Em tarefas visuais, exploratórias ou guiadas no navegador.','Contexto.',4),
('7e440000-0000-4000-8000-000000000005','azure-portal','O portal é o único método de administrar Azure?','Não. CLI, PowerShell, Cloud Shell, APIs e IaC também podem administrar recursos.','Alternativas.',5),
('7e440000-0000-4000-8000-000000000006','azure-portal','Que opção favorece repetição: portal manual ou script?','Um script tende a favorecer automação e repetibilidade.','Escala.',6),
('7e440000-0000-4000-8000-000000000007','azure-cloud-shell','O que é Azure Cloud Shell?','Um terminal interativo, autenticado e hospedado pela Microsoft, acessível pelo navegador.','Ambiente.',1),
('7e440000-0000-4000-8000-000000000008','azure-cloud-shell','Quais shells o Cloud Shell oferece?','Bash e PowerShell.','Duas experiências.',2),
('7e440000-0000-4000-8000-000000000009','azure-cloud-shell','Cloud Shell exige instalar CLI localmente?','Não. O ambiente hospedado já fornece ferramentas preconfiguradas.','Pronto no navegador.',3),
('7e440000-0000-4000-8000-000000000010','azure-cloud-shell','Cloud Shell e Azure CLI são sinônimos?','Não. Cloud Shell é ambiente; Azure CLI é uma ferramenta que pode rodar nele.','Ambiente versus ferramenta.',4),
('7e440000-0000-4000-8000-000000000011','azure-cloud-shell','Azure PowerShell pode rodar fora do Cloud Shell?','Sim. CLI e PowerShell podem ser usados dentro ou fora do Cloud Shell.','Ferramenta portátil.',5),
('7e440000-0000-4000-8000-000000000012','azure-cloud-shell','O Cloud Shell concede permissões extras?','Não. Os comandos respeitam as permissões da identidade autenticada.','Autenticação não é autorização extra.',6),
('7e440000-0000-4000-8000-000000000013','azure-cli','Qual prefixo identifica comandos Azure CLI?','`az`.','Sintaxe.',1),
('7e440000-0000-4000-8000-000000000014','azure-cli','Azure CLI é multiplataforma?','Sim. Funciona em Windows, macOS e Linux.','Plataformas.',2),
('7e440000-0000-4000-8000-000000000015','azure-cli','Para que serve `az group list`?','Para consultar Resource Groups acessíveis no contexto atual.','Exemplo ilustrativo.',3),
('7e440000-0000-4000-8000-000000000016','azure-cli','Por que usar scripts com Azure CLI?','Para automatizar e repetir operações com consistência.','Repetibilidade.',4),
('7e440000-0000-4000-8000-000000000017','azure-cli','Azure CLI só funciona no Cloud Shell?','Não. Pode rodar localmente ou em ambientes hospedados compatíveis.','Local ou hospedado.',5),
('7e440000-0000-4000-8000-000000000018','azure-cli','CLI e PowerShell diferem principalmente em quê?','Na sintaxe e no ecossistema: comandos `az` versus cmdlets Az.','Ferramentas equivalentes em muitos cenários.',6),
('7e440000-0000-4000-8000-000000000019','azure-powershell','O que identifica Azure PowerShell?','Cmdlets dos módulos Az para administrar recursos Azure.','Ferramenta.',1),
('7e440000-0000-4000-8000-000000000020','azure-powershell','Qual padrão os cmdlets Az seguem?','`Verb-AzNoun`, como `Get-AzVM`.','Sintaxe.',2),
('7e440000-0000-4000-8000-000000000021','azure-powershell','Para que serve `Get-AzResourceGroup`?','Para consultar Resource Groups no Azure via PowerShell.','Exemplo.',3),
('7e440000-0000-4000-8000-000000000022','azure-powershell','Azure PowerShell apoia automação?','Sim. Cmdlets podem compor scripts repetíveis.','Scripts.',4),
('7e440000-0000-4000-8000-000000000023','azure-powershell','Azure PowerShell é exclusivo do Windows?','Não. É multiplataforma em ambientes PowerShell compatíveis.','Exam trap.',5),
('7e440000-0000-4000-8000-000000000024','azure-powershell','Azure PowerShell é o mesmo que Cloud Shell?','Não. PowerShell é ferramenta; Cloud Shell é ambiente hospedado.','Ferramenta versus ambiente.',6);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true from stage_962_cards seed
join public.lessons lesson on lesson.topic_id='33000000-0000-4000-8000-000000000003' and lesson.slug=seed.lesson_slug;

create temporary table stage_962_questions(id uuid primary key,lesson_slug text,question_text text,difficulty text,explanation text,display_order integer) on commit drop;
insert into stage_962_questions values
('68000000-0000-4000-8000-000000000144','azure-portal','Uma pessoa quer criar um recurso usando formulários e uma interface gráfica no navegador. Qual ferramenta atende diretamente ao requisito?','easy','Azure portal fornece uma GUI baseada em navegador para criar, configurar, visualizar e administrar recursos.',1),
('68000000-0000-4000-8000-000000000145','azure-portal','Qual atividade combina melhor com o Azure portal?','easy','Explorar visualmente propriedades e estado de recursos é um uso natural da interface gráfica do portal.',2),
('68000000-0000-4000-8000-000000000146','azure-portal','Uma equipe precisa repetir a mesma operação em dezenas de recursos. Qual avaliação é mais adequada?','medium','O portal pode executar ações, mas comandos ou scripts tendem a oferecer mais repetibilidade para tarefas em escala.',3),
('68000000-0000-4000-8000-000000000147','azure-portal','Um requisito pede um terminal já preparado no navegador, não uma interface gráfica. Qual opção é mais direta?','medium','Azure Cloud Shell é o terminal hospedado e preconfigurado no navegador; Azure portal é a GUI.',4),
('68000000-0000-4000-8000-000000000148','azure-portal','Uma equipe conclui que todos os recursos Azure só podem ser administrados pelo portal. Qual análise está correta?','hard','A conclusão está errada: CLI, PowerShell, Cloud Shell, APIs e IaC são outros caminhos de administração.',5),
('68000000-0000-4000-8000-000000000149','azure-powershell','Qual comando representa Azure PowerShell?','easy','Get-AzVM segue o padrão de cmdlet do módulo Az; az vm list representa Azure CLI.',1),
('68000000-0000-4000-8000-000000000150','azure-powershell','Qual afirmação sobre Azure PowerShell está correta?','easy','Azure PowerShell usa módulos Az e funciona em ambientes PowerShell compatíveis em Windows, macOS e Linux.',2),
('68000000-0000-4000-8000-000000000151','azure-powershell','Uma equipe já processa objetos em scripts PowerShell e quer administrar Azure. Qual opção é mais alinhada?','medium','Azure PowerShell integra cmdlets Az ao pipeline e ao ecossistema PowerShell já usado pela equipe.',3),
('68000000-0000-4000-8000-000000000152','azure-powershell','Um administrador executa Get-AzResourceGroup no Cloud Shell. O que é ferramenta e o que é ambiente?','medium','Azure PowerShell é a ferramenta de cmdlets; Cloud Shell é o ambiente de terminal hospedado.',4),
('68000000-0000-4000-8000-000000000153','azure-powershell','Duas equipes precisam automatizar Azure: uma prefere comandos az e outra cmdlets e objetos PowerShell. Qual escolha é válida?','hard','Azure CLI atende a primeira e Azure PowerShell à segunda; ambas são multiplataforma e apoiam automação.',5);
insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_962_questions seed join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure management and governance'
join public.topics topic on topic.domain_id=domain.id and topic.id='33000000-0000-4000-8000-000000000003'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug=seed.lesson_slug;

create temporary table stage_962_options(id uuid primary key,question_id uuid,option_text text,is_correct boolean,explanation text,display_order integer) on commit drop;
insert into stage_962_options values
('7f250000-0000-4000-8000-000000000001','68000000-0000-4000-8000-000000000144','Azure portal.',true,'Correta. É a GUI baseada em navegador.',1),
('7f250000-0000-4000-8000-000000000002','68000000-0000-4000-8000-000000000144','Azure CLI.',false,'CLI usa comandos, não formulários gráficos.',2),
('7f250000-0000-4000-8000-000000000003','68000000-0000-4000-8000-000000000144','Azure PowerShell.',false,'PowerShell usa cmdlets.',3),
('7f250000-0000-4000-8000-000000000004','68000000-0000-4000-8000-000000000144','Azure Arc.',false,'Arc estende gerenciamento; não é a GUI solicitada.',4),
('7f250000-0000-4000-8000-000000000005','68000000-0000-4000-8000-000000000145','Abrir a página de uma VM e conferir suas propriedades.',true,'Correta. É uma tarefa visual e exploratória.',1),
('7f250000-0000-4000-8000-000000000006','68000000-0000-4000-8000-000000000145','Executar necessariamente comandos az.',false,'Comandos az pertencem à CLI.',2),
('7f250000-0000-4000-8000-000000000007','68000000-0000-4000-8000-000000000145','Executar necessariamente cmdlets Az.',false,'Cmdlets pertencem ao PowerShell.',3),
('7f250000-0000-4000-8000-000000000008','68000000-0000-4000-8000-000000000145','Criar um shell hospedado próprio.',false,'Isso não descreve uso do portal.',4),
('7f250000-0000-4000-8000-000000000009','68000000-0000-4000-8000-000000000146','Usar comandos ou scripts para favorecer repetibilidade.',true,'Correta. Automação reduz repetição manual.',1),
('7f250000-0000-4000-8000-000000000010','68000000-0000-4000-8000-000000000146','Repetir tudo manualmente é sempre mais consistente.',false,'Operações manuais em escala elevam variação.',2),
('7f250000-0000-4000-8000-000000000011','68000000-0000-4000-8000-000000000146','O portal deixa de funcionar após a primeira criação.',false,'O portal continua disponível.',3),
('7f250000-0000-4000-8000-000000000012','68000000-0000-4000-8000-000000000146','Automação elimina autenticação e autorização.',false,'Scripts ainda precisam de identidade e permissões.',4),
('7f250000-0000-4000-8000-000000000013','68000000-0000-4000-8000-000000000147','Azure Cloud Shell.',true,'Correta. É o terminal pronto no navegador.',1),
('7f250000-0000-4000-8000-000000000014','68000000-0000-4000-8000-000000000147','Azure portal somente.',false,'Portal é GUI; o requisito pede terminal.',2),
('7f250000-0000-4000-8000-000000000015','68000000-0000-4000-8000-000000000147','Azure Arc.',false,'Arc não é um terminal no navegador.',3),
('7f250000-0000-4000-8000-000000000016','68000000-0000-4000-8000-000000000147','Resource Lock.',false,'Lock protege operações; não oferece terminal.',4),
('7f250000-0000-4000-8000-000000000017','68000000-0000-4000-8000-000000000148','Errada: há outras interfaces e métodos de administração.',true,'Correta. Portal não é exclusivo.',1),
('7f250000-0000-4000-8000-000000000018','68000000-0000-4000-8000-000000000148','Correta: APIs só podem ler recursos.',false,'APIs podem administrar conforme permissões.',2),
('7f250000-0000-4000-8000-000000000019','68000000-0000-4000-8000-000000000148','Correta: CLI existe apenas dentro do portal.',false,'CLI pode rodar em outros ambientes.',3),
('7f250000-0000-4000-8000-000000000020','68000000-0000-4000-8000-000000000148','Correta: PowerShell não administra Azure.',false,'Azure PowerShell administra recursos por cmdlets Az.',4),
('7f250000-0000-4000-8000-000000000021','68000000-0000-4000-8000-000000000149','Get-AzVM.',true,'Correta. É cmdlet do módulo Az.',1),
('7f250000-0000-4000-8000-000000000022','68000000-0000-4000-8000-000000000149','az vm list.',false,'Esse é um comando Azure CLI.',2),
('7f250000-0000-4000-8000-000000000023','68000000-0000-4000-8000-000000000149','Open-AzurePortal.',false,'Não é o exemplo de cmdlet Az apresentado.',3),
('7f250000-0000-4000-8000-000000000024','68000000-0000-4000-8000-000000000149','cloud-shell vm.',false,'Cloud Shell é ambiente, não essa sintaxe.',4),
('7f250000-0000-4000-8000-000000000025','68000000-0000-4000-8000-000000000150','Usa módulos Az e é multiplataforma em ambientes compatíveis.',true,'Correta. Não é exclusivo do Windows.',1),
('7f250000-0000-4000-8000-000000000026','68000000-0000-4000-8000-000000000150','Só funciona no Windows e no portal.',false,'PowerShell atual e módulos Az são multiplataforma.',2),
('7f250000-0000-4000-8000-000000000027','68000000-0000-4000-8000-000000000150','Usa exclusivamente comandos iniciados por az.',false,'Esse padrão identifica Azure CLI.',3),
('7f250000-0000-4000-8000-000000000028','68000000-0000-4000-8000-000000000150','É uma interface gráfica no navegador.',false,'Isso descreve o portal.',4),
('7f250000-0000-4000-8000-000000000029','68000000-0000-4000-8000-000000000151','Azure PowerShell.',true,'Correta. Integra cmdlets e objetos PowerShell.',1),
('7f250000-0000-4000-8000-000000000030','68000000-0000-4000-8000-000000000151','Azure portal obrigatoriamente.',false,'Portal não é a escolha mais alinhada ao script existente.',2),
('7f250000-0000-4000-8000-000000000031','68000000-0000-4000-8000-000000000151','Resource Locks.',false,'Locks não são ferramenta de script.',3),
('7f250000-0000-4000-8000-000000000032','68000000-0000-4000-8000-000000000151','Microsoft Purview.',false,'Purview não é ferramenta de linha de comando geral.',4),
('7f250000-0000-4000-8000-000000000033','68000000-0000-4000-8000-000000000152','Azure PowerShell é a ferramenta; Cloud Shell é o ambiente.',true,'Correta. Separa ferramenta de ambiente.',1),
('7f250000-0000-4000-8000-000000000034','68000000-0000-4000-8000-000000000152','Cloud Shell é a ferramenta; PowerShell é o navegador.',false,'Os papéis estão invertidos.',2),
('7f250000-0000-4000-8000-000000000035','68000000-0000-4000-8000-000000000152','Ambos são exclusivamente interfaces gráficas.',false,'Ambos envolvem linha de comando.',3),
('7f250000-0000-4000-8000-000000000036','68000000-0000-4000-8000-000000000152','Ambos são nomes para Azure CLI.',false,'São conceitos distintos da CLI.',4),
('7f250000-0000-4000-8000-000000000037','68000000-0000-4000-8000-000000000153','CLI para comandos az; PowerShell para cmdlets e objetos.',true,'Correta. A preferência de ecossistema orienta a escolha.',1),
('7f250000-0000-4000-8000-000000000038','68000000-0000-4000-8000-000000000153','Somente CLI, porque PowerShell não automatiza.',false,'PowerShell também apoia automação.',2),
('7f250000-0000-4000-8000-000000000039','68000000-0000-4000-8000-000000000153','Somente PowerShell, porque CLI não é multiplataforma.',false,'CLI é multiplataforma.',3),
('7f250000-0000-4000-8000-000000000040','68000000-0000-4000-8000-000000000153','Nenhuma, porque só o portal administra Azure.',false,'Ambas administram Azure.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_962_options;

-- Simplifica seis itens históricos sem trocar seus UUIDs ou romper tentativas antigas.
update public.questions set question_text='Qual afirmação diferencia corretamente Azure CLI de Azure PowerShell?',
  explanation='Azure CLI usa comandos az; Azure PowerShell usa cmdlets do módulo Az. Ambas são multiplataforma e apoiam automação.'
where id='63000000-0000-4000-8000-000000000048';
update public.questions set question_text='Uma equipe repete a mesma administração em muitos ambientes. Qual benefício central de um script Azure CLI?',
  explanation='O script torna a sequência repetível e favorece automação, reduzindo trabalho manual e variações entre execuções.'
where id='63000000-0000-4000-8000-000000000049';
update public.questions set question_text='Um comando começa com az e precisa rodar sem instalação local. Qual combinação atende ao cenário?',
  explanation='Azure CLI é a ferramenta identificada por az; Cloud Shell é o ambiente hospedado no navegador com a ferramenta preconfigurada.'
where id='63000000-0000-4000-8000-000000000050';
update public.questions set question_text='Um administrador executa az group list no Cloud Shell. O que é o Cloud Shell?',
  explanation='Cloud Shell é o ambiente de terminal hospedado; az group list é um comando da ferramenta Azure CLI.'
where id='63000000-0000-4000-8000-000000000058';
update public.questions set question_text='Azure CLI e Azure PowerShell podem ser usados fora do Cloud Shell?',
  explanation='Sim. Cloud Shell é um ambiente conveniente, mas CLI e PowerShell são ferramentas que também podem rodar em ambientes compatíveis fora dele.'
where id='63000000-0000-4000-8000-000000000059';
update public.questions set question_text='Qual afirmação sobre a autenticação integrada do Cloud Shell está correta?',
  explanation='Ela facilita o uso das ferramentas com a identidade autenticada, mas as operações continuam limitadas pelas permissões dessa identidade.'
where id='63000000-0000-4000-8000-000000000060';

update public.question_options set is_correct=false
where id between '74000000-0000-4000-8000-000000000189' and '74000000-0000-4000-8000-000000000200'
   or id between '74000000-0000-4000-8000-000000000229' and '74000000-0000-4000-8000-000000000240';

update public.question_options set
  option_text=case id
    when '74000000-0000-4000-8000-000000000189' then 'CLI usa cmdlets Az; PowerShell usa comandos az.'
    when '74000000-0000-4000-8000-000000000190' then 'CLI usa comandos az; PowerShell usa cmdlets do módulo Az.'
    when '74000000-0000-4000-8000-000000000191' then 'CLI é GUI; PowerShell é apenas um serviço web.'
    when '74000000-0000-4000-8000-000000000192' then 'CLI funciona só em Linux; PowerShell só em Windows.'
    when '74000000-0000-4000-8000-000000000193' then 'Repete a sequência com consistência e favorece automação.'
    when '74000000-0000-4000-8000-000000000194' then 'Elimina a necessidade de autenticação.'
    when '74000000-0000-4000-8000-000000000195' then 'Transforma todos os comandos em GUI.'
    when '74000000-0000-4000-8000-000000000196' then 'Garante custo zero para os recursos.'
    when '74000000-0000-4000-8000-000000000197' then 'Azure CLI dentro do Azure Cloud Shell.'
    when '74000000-0000-4000-8000-000000000198' then 'Azure portal dentro do Azure Arc.'
    when '74000000-0000-4000-8000-000000000199' then 'Azure PowerShell dentro de Resource Locks.'
    when '74000000-0000-4000-8000-000000000200' then 'Infrastructure as Code dentro do Azure Policy.'
    when '74000000-0000-4000-8000-000000000229' then 'O ambiente de terminal hospedado no navegador.'
    when '74000000-0000-4000-8000-000000000230' then 'O comando az executado no ambiente.'
    when '74000000-0000-4000-8000-000000000231' then 'Uma interface gráfica para criar formulários.'
    when '74000000-0000-4000-8000-000000000232' then 'Um módulo exclusivo de PowerShell.'
    when '74000000-0000-4000-8000-000000000233' then 'Sim, em ambientes locais ou hospedados compatíveis.'
    when '74000000-0000-4000-8000-000000000234' then 'Não, ambas existem somente no Cloud Shell.'
    when '74000000-0000-4000-8000-000000000235' then 'Somente a CLI; PowerShell nunca funciona fora dele.'
    when '74000000-0000-4000-8000-000000000236' then 'Somente PowerShell; CLI existe apenas no portal.'
    when '74000000-0000-4000-8000-000000000237' then 'Facilita o uso, respeitando as permissões da identidade.'
    when '74000000-0000-4000-8000-000000000238' then 'Concede automaticamente acesso de Owner.'
    when '74000000-0000-4000-8000-000000000239' then 'Remove a necessidade de autorização.'
    when '74000000-0000-4000-8000-000000000240' then 'Permite editar recursos sem identidade.' end,
  is_correct=case when id in('74000000-0000-4000-8000-000000000190','74000000-0000-4000-8000-000000000193','74000000-0000-4000-8000-000000000197','74000000-0000-4000-8000-000000000229','74000000-0000-4000-8000-000000000233','74000000-0000-4000-8000-000000000237') then true else false end,
  explanation=case when id in('74000000-0000-4000-8000-000000000190','74000000-0000-4000-8000-000000000193','74000000-0000-4000-8000-000000000197','74000000-0000-4000-8000-000000000229','74000000-0000-4000-8000-000000000233','74000000-0000-4000-8000-000000000237')
    then 'Correta. A opção aplica a distinção conceitual do cenário.' else 'Incorreta. Confunde ferramenta, ambiente, interface ou autorização.' end
where id between '74000000-0000-4000-8000-000000000189' and '74000000-0000-4000-8000-000000000200'
   or id between '74000000-0000-4000-8000-000000000229' and '74000000-0000-4000-8000-000000000240';

do $$ declare lesson_row record; begin
  for lesson_row in select id,slug from public.lessons where topic_id='33000000-0000-4000-8000-000000000003'
    and slug in('azure-portal','azure-cloud-shell','azure-cli','azure-powershell') loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_row.id and is_published)<>10
      or (select count(*) from public.flashcards where lesson_id=lesson_row.id and is_published)<>6
      or (select count(*) from public.questions where lesson_id=lesson_row.id and is_published)
        <>(case when lesson_row.slug in('azure-cloud-shell','azure-cli') then 10 else 5 end) then
      raise exception '9.6.2 final inventory invalid for %',lesson_row.slug; end if;
  end loop;
end; $$;

commit;

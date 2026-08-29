begin;

do $$
declare target_count integer;
begin
  select count(*) into target_count
  from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
  join public.domains domain on domain.id=topic.domain_id
  join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900' and domain.title='Describe Azure architecture and services'
    and topic.id='32000000-0000-4000-8000-000000000004' and topic.title='Storage Services'
    and lesson.slug in ('storage-accounts-and-services','blob-storage','azure-files','managed-disks');
  if target_count<>4 then raise exception '8.8.2 expected four existing Storage Lessons'; end if;
  if exists(select 1 from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000004' and lesson.slug in ('storage-accounts-and-services','blob-storage','azure-files','managed-disks')) then
    raise exception 'A scoped Storage Lesson already contains Content Blocks'; end if;
  if exists(select 1 from public.visual_experiences visual join public.lessons lesson on lesson.id=visual.lesson_id
    where lesson.topic_id='32000000-0000-4000-8000-000000000004' and lesson.slug in ('storage-accounts-and-services','blob-storage','azure-files','managed-disks')) then
    raise exception '8.8.2 must not create or replace Visual Experiences'; end if;
  if exists(select 1 from public.lessons lesson where lesson.topic_id='32000000-0000-4000-8000-000000000004'
    and lesson.slug in ('storage-accounts-and-services','blob-storage','azure-files','managed-disks')
    and (select count(*) from public.flashcards card where card.lesson_id=lesson.id and card.is_published)<>case lesson.slug
      when 'storage-accounts-and-services' then 5 when 'blob-storage' then 4 when 'azure-files' then 3 when 'managed-disks' then 3 end) then
    raise exception 'Unexpected pre-8.8.2 Flashcard inventory'; end if;
  if exists(select 1 from public.lessons lesson where lesson.topic_id='32000000-0000-4000-8000-000000000004'
    and lesson.slug in ('storage-accounts-and-services','blob-storage','azure-files','managed-disks')
    and (select count(*) from public.questions question where question.lesson_id=lesson.id and question.is_published)<>case when lesson.slug='azure-files' then 10 else 0 end) then
    raise exception 'Unexpected pre-8.8.2 Question inventory'; end if;
end; $$;

update public.lessons set estimated_minutes=case slug
  when 'storage-accounts-and-services' then 12 else 10 end
where topic_id='32000000-0000-4000-8000-000000000004'
  and slug in ('storage-accounts-and-services','blob-storage','azure-files','managed-disks');

create temporary table stage_882_block_seed(
  id uuid primary key, slug text not null, type text not null, title text, content text,
  config jsonb, display_order integer not null
) on commit drop;

insert into stage_882_block_seed values
('7b120000-0000-4000-8000-000000000001','storage-accounts-and-services','explanation','O que é uma Azure Storage Account?',
$content$Azure Storage Account é o recurso de nível superior usado para organizar, configurar e acessar dados do Azure Storage. Ela fornece um namespace exclusivo para os serviços disponibilizados pela conta.

Conforme o tipo da conta, esse namespace pode expor Blob Storage, Azure Files, Queue Storage e Table Storage. Performance, redundância e cobrança são características configuradas no contexto da conta e serão aprofundadas nas próximas Lessons.$content$,null,1),
('7b120000-0000-4000-8000-000000000002','storage-accounts-and-services','important','General-purpose v2 (GPv2)',
$content$General-purpose v2, ou GPv2, é o tipo padrão recomendado para muitos cenários de Azure Storage. Uma conta GPv2 pode disponibilizar Blob, Files, Queue e Table.

Para AZ-900, reconheça a finalidade geral. Não é necessário memorizar contas Premium específicas, limites, throughput ou preços.$content$,null,2),
('7b120000-0000-4000-8000-000000000003','storage-accounts-and-services','explanation','Blob Storage e Azure Files',
$content$Blob Storage guarda objetos e grandes volumes de dados não estruturados, como imagens e documentos. Azure Files oferece compartilhamentos de arquivos gerenciados para aplicações e usuários que precisam de um file share.

Os dois podem ser expostos por uma storage account compatível, mas resolvem necessidades diferentes.$content$,null,3),
('7b120000-0000-4000-8000-000000000004','storage-accounts-and-services','explanation','Queue Storage',
$content$Queue Storage armazena mensagens para comunicação assíncrona simples entre componentes. Uma API pode colocar uma mensagem em uma queue e um worker processá-la depois.

Queue Storage não equivale a Azure Service Bus completo. Service Bus possui outras capacidades e fica fora desta etapa.$content$,null,4),
('7b120000-0000-4000-8000-000000000005','storage-accounts-and-services','explanation','Table Storage',
$content$Table Storage armazena dados NoSQL estruturados como entidades de chave e atributos. É apropriado para dados não relacionais simples que não exigem o modelo relacional de um banco SQL.

Para Fundamentals, reconheça o caso de uso. Design detalhado de partition keys fica fora desta Lesson.$content$,null,5),
('7b120000-0000-4000-8000-000000000006','storage-accounts-and-services','important','Comparação dos serviços',
$content$| Serviço | Principal uso |
| --- | --- |
| Blob Storage | Objetos e dados não estruturados |
| Azure Files | Compartilhamentos de arquivos |
| Queue Storage | Mensagens assíncronas simples |
| Table Storage | Dados NoSQL chave/atributo |
| Managed Disks | Discos persistentes para Azure VMs |

Managed Disk aparece na comparação porque é uma opção de storage do Azure, mas é um recurso de disco gerenciado para VMs — não um objeto que o aluno coloca dentro de uma conta GPv2.$content$,null,6),
('7b120000-0000-4000-8000-000000000007','storage-accounts-and-services','example','Cinco requisitos, cinco escolhas',
$content$Fotos de usuários → Blob Storage.

Documentos compartilhados por vários servidores → Azure Files.

API desacoplada de um worker por mensagens simples → Queue Storage.

Entidades NoSQL simples → Table Storage.

Disco do sistema operacional de uma VM → Managed Disk.$content$,null,7),
('7b120000-0000-4000-8000-000000000008','storage-accounts-and-services','exam_tip','Identifique primeiro o formato e o acesso',
$content$Em um cenário de prova, procure o que será armazenado e como será usado: objeto, file share, mensagem, entidade NoSQL ou disco de VM. Isso normalmente elimina alternativas antes de qualquer detalhe de implementação.$content$,null,8),
('7b120000-0000-4000-8000-000000000009','storage-accounts-and-services','exam_trap','A conta não é o dado armazenado',
$content$Storage Account não é Blob Container, um único arquivo nem Managed Disk. A conta é o recurso superior que fornece namespace e configura serviços compatíveis. Um Blob Container organiza blobs dentro do Blob Storage; Managed Disk é um recurso de disco para VM.$content$,null,9),
('7b120000-0000-4000-8000-000000000010','storage-accounts-and-services','summary','Resumo para memória ativa',null,
'{"items":["Storage Account fornece namespace e configuração para serviços Azure Storage.","GPv2 atende muitos cenários e pode expor Blob, Files, Queue e Table.","Blob guarda objetos; Files oferece file shares.","Queue guarda mensagens assíncronas simples; Table guarda entidades NoSQL.","Managed Disk fornece disco persistente para VM e não é um Blob Container."]}'::jsonb,10),

('7b120000-0000-4000-8000-000000000011','blob-storage','explanation','O que é Azure Blob Storage?',
$content$Azure Blob Storage é object storage para grandes volumes de dados não estruturados. Ele é indicado para imagens, vídeos, documentos, backups, arquivos binários e logs.

“Objeto” descreve dados acessados como blobs, não como um disco tradicional ou banco relacional.$content$,null,1),
('7b120000-0000-4000-8000-000000000012','blob-storage','important','Hierarquia conceitual',
$content$Storage Account → Blob Container → Blob.

A storage account fornece o namespace. Um container organiza blobs relacionados. O blob é o objeto armazenado, como uma imagem ou documento. Não é necessário memorizar tipos internos de blob para AZ-900.$content$,null,2),
('7b120000-0000-4000-8000-000000000013','blob-storage','example','Arquivos enviados por usuários',
$content$Uma aplicação recebe milhões de fotos e documentos. Blob Storage é apropriado porque o requisito é armazenar objetos não estruturados em grande escala, e não montar um file share ou anexar um disco a uma VM.$content$,null,3),
('7b120000-0000-4000-8000-000000000014','blob-storage','dotnet_example','API ASP.NET Core salvando uma imagem',
$content$Uma API ASP.NET Core recebe um upload e grava o arquivo como blob em um container. A aplicação mantém metadados de negócio separadamente e usa Blob Storage para o conteúdo binário.

O exemplo ilustra a escolha do serviço; SDK, autenticação e código de upload ficam fora desta Lesson.$content$,null,4),
('7b120000-0000-4000-8000-000000000015','blob-storage','exam_tip','Procure objetos não estruturados',
$content$Imagens, vídeos, documentos, backups e logs normalmente apontam para Blob Storage quando o requisito descreve object storage. Se o requisito pede um compartilhamento montável, considere Azure Files.$content$,null,5),
('7b120000-0000-4000-8000-000000000016','blob-storage','exam_trap','Blob não é file share nem disco de VM',
$content$Blob Storage não é Azure Files e um Blob Container não é Managed Disk. Blob armazena objetos; Files oferece compartilhamentos; Managed Disk fornece block storage persistente para VMs.$content$,null,6),
('7b120000-0000-4000-8000-000000000017','blob-storage','summary','Resumo para memória ativa',null,
'{"items":["Blob Storage é object storage para dados não estruturados.","Imagens, vídeos, documentos, backups e logs são casos comuns.","A hierarquia é Storage Account → Container → Blob.","Blob não é Azure Files nem Managed Disk."]}'::jsonb,7),

('7b120000-0000-4000-8000-000000000018','azure-files','explanation','O que é Azure Files?',
$content$Azure Files oferece compartilhamentos de arquivos totalmente gerenciados na nuvem. Aplicações, VMs e usuários podem usar um file share quando precisam trabalhar com uma estrutura de arquivos compartilhada.

SMB é comum; NFS também é suportado em cenários compatíveis. Configuração de protocolo fica fora desta Lesson.$content$,null,1),
('7b120000-0000-4000-8000-000000000019','azure-files','important','Azure Files versus Blob Storage',
$content$Azure Files → file share gerenciado, adequado quando várias máquinas ou aplicações precisam acessar arquivos por uma estrutura compartilhada.

Blob Storage → object storage, adequado para objetos como imagens, vídeos e documentos acessados pela aplicação.

O fato de ambos armazenarem “arquivos” não os torna equivalentes.$content$,null,2),
('7b120000-0000-4000-8000-000000000020','azure-files','example','Compartilhamento para vários servidores',
$content$Vários servidores precisam ler os mesmos arquivos de configuração e documentos. Um Azure file share pode fornecer uma fonte compartilhada gerenciada sem exigir que cada servidor mantenha uma cópia independente.$content$,null,3),
('7b120000-0000-4000-8000-000000000021','azure-files','dotnet_example','Aplicação .NET com file share',
$content$Uma aplicação .NET legada espera ler e gravar em uma estrutura de diretórios compartilhada. Azure Files pode atender ao padrão de file share, sujeito à compatibilidade e à configuração do cenário.

Isso não significa que toda aplicação baseada em arquivos deve migrar sem avaliação.$content$,null,4),
('7b120000-0000-4000-8000-000000000022','azure-files','exam_tip','File share aponta para Azure Files',
$content$Se o requisito enfatiza compartilhamento montável, múltiplas máquinas e estrutura de diretórios, Azure Files tende a ser mais apropriado que Blob Storage ou um disco anexado a uma VM.$content$,null,5),
('7b120000-0000-4000-8000-000000000023','azure-files','exam_trap','Files não é Blob nem Managed Disk',
$content$Azure Files é file share gerenciado. Blob Storage guarda objetos. Managed Disk fornece disco persistente para uma Azure VM. Nenhuma dessas diferenças significa que um serviço é sempre superior; a escolha depende do requisito.$content$,null,6),
('7b120000-0000-4000-8000-000000000024','azure-files','summary','Resumo para memória ativa',null,
'{"items":["Azure Files oferece file shares gerenciados.","SMB é comum e NFS existe em cenários suportados.","Um file share pode ser acessado por várias máquinas conforme configuração.","Azure Files não é Blob Storage nem Managed Disk."]}'::jsonb,7),

('7b120000-0000-4000-8000-000000000025','managed-disks','explanation','O que é Azure Managed Disk?',
$content$Azure Managed Disk é um recurso Azure de armazenamento em disco para Virtual Machines. O Azure administra a infraestrutura de storage subjacente, enquanto o cliente usa o disco como parte da configuração da VM.

Managed Disk não é simplesmente um arquivo Blob comum administrado pelo usuário.$content$,null,1),
('7b120000-0000-4000-8000-000000000026','managed-disks','important','OS disk e data disk',
$content$OS disk contém o sistema operacional usado para inicializar a VM. Data disk fornece armazenamento persistente adicional para aplicações e dados.

Para AZ-900, reconheça os papéis. Performance tiers, IOPS, throughput e SKUs detalhados ficam fora desta Lesson.$content$,null,2),
('7b120000-0000-4000-8000-000000000027','managed-disks','example','Banco instalado em uma VM',
$content$Uma VM executa um banco gerenciado pela própria equipe. O OS disk contém o sistema operacional; um ou mais data disks podem armazenar os arquivos persistentes da carga.

O exemplo não transforma Managed Disk em serviço de banco ou file share.$content$,null,3),
('7b120000-0000-4000-8000-000000000028','managed-disks','dotnet_example','Aplicação .NET em uma VM',
$content$Uma aplicação .NET instalada em uma Azure VM usa o OS disk para o sistema e um data disk para dados persistentes locais da VM. Se várias máquinas precisassem do mesmo file share, Azure Files representaria outro requisito.$content$,null,4),
('7b120000-0000-4000-8000-000000000029','managed-disks','exam_tip','Disco persistente de VM',
$content$Quando o cenário pede OS disk ou data disk anexado a uma Azure VM, procure Managed Disks. Quando pede objetos ou compartilhamento entre máquinas, procure Blob Storage ou Azure Files.$content$,null,5),
('7b120000-0000-4000-8000-000000000030','managed-disks','exam_trap','Managed Disk não é container nem file share',
$content$Managed Disk não é Blob Container e não é Azure Files. Ele é um recurso de block storage gerenciado para VM. O usuário não administra o disco como um blob comum dentro de uma conta GPv2.$content$,null,6),
('7b120000-0000-4000-8000-000000000031','managed-disks','summary','Resumo para memória ativa',null,
'{"items":["Managed Disk fornece armazenamento em disco para Azure VMs.","OS disk inicializa a VM; data disk adiciona armazenamento persistente.","Azure gerencia a infraestrutura de storage subjacente.","Managed Disk não é Blob Container nem Azure Files."]}'::jsonb,7);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.display_order,true
from stage_882_block_seed seed join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000004' and lesson.slug=seed.slug;

create temporary table stage_882_flashcard_update(
  id uuid primary key, front_text text not null, back_text text not null, hint text
) on commit drop;
insert into stage_882_flashcard_update values
('72000000-0000-4000-8000-000000000036','O que é uma Azure Storage Account?','É o recurso superior que fornece namespace e configura serviços Azure Storage compatíveis, como Blob, Files, Queue e Table.','Conta organiza serviços; não é o dado.'),
('72000000-0000-4000-8000-000000000037','Quais serviços uma conta GPv2 pode disponibilizar?','Blob Storage, Azure Files, Queue Storage e Table Storage. Managed Disk é um recurso separado para discos de VM.','GPv2: quatro serviços principais.'),
('72000000-0000-4000-8000-000000000038','Quando usar Queue Storage?','Para armazenar mensagens e desacoplar de forma assíncrona simples componentes como uma API e um worker.','Mensagens assíncronas simples.'),
('72000000-0000-4000-8000-000000000039','Quando usar Table Storage?','Para entidades NoSQL simples organizadas por chave e atributos, sem exigir um banco relacional.','NoSQL chave/atributo.'),
('72000000-0000-4000-8000-000000000040','Storage Account é o mesmo que Blob Container?','Não. A account é o recurso superior; um container organiza blobs dentro do Blob Storage.','Conta versus container.'),
('72000000-0000-4000-8000-000000000041','Para que tipo de dado Blob Storage é indicado?','Para objetos e grandes volumes de dados não estruturados, como imagens, vídeos, documentos e logs.','Object storage.'),
('72000000-0000-4000-8000-000000000042','Qual é a hierarquia conceitual do Blob Storage?','Storage Account → Blob Container → Blob.','Do recurso superior ao objeto.'),
('72000000-0000-4000-8000-000000000043','Blob Storage e Azure Files são equivalentes?','Não. Blob é object storage; Azure Files oferece compartilhamentos de arquivos gerenciados.','Objeto versus file share.'),
('72000000-0000-4000-8000-000000000044','Onde armazenar milhões de imagens enviadas por usuários?','Em Blob Storage, pois são objetos/dados não estruturados.','Reconheça o cenário.'),
('72000000-0000-4000-8000-000000000045','O que é Azure Files?','É um serviço de compartilhamentos de arquivos gerenciados na nuvem.','File share.'),
('72000000-0000-4000-8000-000000000046','Quando Azure Files tende a ser adequado?','Quando aplicações ou máquinas precisam acessar um file share e uma estrutura de arquivos compartilhada.','Múltiplos consumidores.'),
('72000000-0000-4000-8000-000000000047','Azure Files e Managed Disk são equivalentes?','Não. Files oferece file shares; Managed Disk fornece disco persistente para uma Azure VM.','Compartilhamento versus disco de VM.'),
('72000000-0000-4000-8000-000000000048','O que é Azure Managed Disk?','É um recurso Azure gerenciado que fornece armazenamento em disco persistente para Virtual Machines.','Disco de VM.'),
('72000000-0000-4000-8000-000000000049','Qual é a diferença entre OS disk e data disk?','OS disk contém o sistema operacional de inicialização; data disk adiciona armazenamento persistente para aplicações e dados.','Sistema versus dados.'),
('72000000-0000-4000-8000-000000000050','Managed Disk é um Blob comum administrado pelo usuário?','Não. É um recurso de disco para VM cuja infraestrutura de storage subjacente é gerenciada pelo Azure.','Não é Blob Container.');
update public.flashcards card set front_text=seed.front_text,back_text=seed.back_text,hint=seed.hint
from stage_882_flashcard_update seed where card.id=seed.id;

create temporary table stage_882_existing_question_update(
  id uuid primary key, question_text text not null, difficulty text not null, explanation text not null
) on commit drop;
insert into stage_882_existing_question_update values
('63000000-0000-4000-8000-000000000101','O que caracteriza Azure Files?','easy','Azure Files oferece compartilhamentos de arquivos totalmente gerenciados na nuvem para aplicações e máquinas que precisam de um file share.'),
('63000000-0000-4000-8000-000000000102','Qual comparação entre Azure Files e Blob Storage está correta?','easy','Azure Files oferece file shares gerenciados; Blob Storage guarda objetos e dados não estruturados.'),
('63000000-0000-4000-8000-000000000103','Qual comparação entre Azure Files e Managed Disk está correta?','easy','Azure Files atende compartilhamento de arquivos; Managed Disk fornece disco persistente para uma Azure VM.'),
('63000000-0000-4000-8000-000000000104','Várias VMs precisam acessar os mesmos documentos por um compartilhamento de arquivos. Qual serviço é mais apropriado?','medium','Azure Files fornece um file share gerenciado que pode ser usado por várias máquinas conforme a configuração do cenário.'),
('63000000-0000-4000-8000-000000000105','Qual protocolo é comumente associado aos file shares do Azure Files?','medium','SMB é um protocolo comum para Azure Files; NFS também existe em cenários suportados, sem necessidade de detalhes de configuração no AZ-900.'),
('63000000-0000-4000-8000-000000000106','Uma aplicação espera uma estrutura de diretórios compartilhada e montável. Qual opção tende a atender melhor?','medium','Azure Files é voltado a file shares e estruturas de arquivos compartilhadas, diferentemente de object storage ou disco de uma única VM.'),
('63000000-0000-4000-8000-000000000107','Uma empresa quer substituir conceitualmente um servidor de arquivos por um serviço gerenciado. Qual serviço deve avaliar?','medium','Azure Files é a opção Azure voltada a compartilhamentos de arquivos gerenciados; compatibilidade e configuração ainda devem ser avaliadas.'),
('63000000-0000-4000-8000-000000000108','Uma aplicação precisa guardar milhões de fotos como objetos, sem montar um file share. Qual serviço é mais apropriado?','medium','Blob Storage é adequado a objetos e dados não estruturados. Azure Files seria escolhido quando o requisito central fosse um file share.'),
('63000000-0000-4000-8000-000000000109','Uma solução precisa que três servidores acessem e atualizem o mesmo conjunto de arquivos por uma estrutura compartilhada. Qual escolha é mais alinhada?','hard','Azure Files atende o requisito de file share compartilhado; cópias locais, Blob Storage e discos individuais não oferecem o mesmo padrão de acesso.'),
('63000000-0000-4000-8000-000000000110','Uma equipe compara object storage, file share e disco de VM. O requisito é montar uma estrutura de arquivos para múltiplas máquinas. Qual serviço deve escolher?','hard','Azure Files corresponde a file share. Blob corresponde a object storage e Managed Disk a armazenamento em disco para VM.');
update public.questions question set question_text=seed.question_text,difficulty=seed.difficulty,explanation=seed.explanation
from stage_882_existing_question_update seed where question.id=seed.id;

create temporary table stage_882_existing_option_update(
  id uuid primary key, option_text text not null, is_correct boolean not null, explanation text not null
) on commit drop;
insert into stage_882_existing_option_update
select ('74000000-0000-4000-8000-'||lpad((400+row_number() over())::text,12,'0'))::uuid,
  option_text,is_correct,explanation
from (values
('Um serviço de compartilhamentos de arquivos gerenciados na nuvem.',true,'Correta. Azure Files fornece file shares gerenciados.'),('Um serviço de object storage para blobs.',false,'Blob Storage atende objetos, não file shares.'),('Um disco persistente anexado a uma VM.',false,'Isso descreve Managed Disk.'),('Uma fila de mensagens assíncronas.',false,'Isso descreve Queue Storage.'),
('Files oferece file shares; Blob guarda objetos não estruturados.',true,'Correta. Os padrões de acesso são diferentes.'),('Files e Blob são nomes para o mesmo serviço.',false,'São serviços distintos.'),('Files fornece apenas discos de VM.',false,'Discos de VM usam Managed Disks.'),('Blob sempre oferece uma estrutura de diretórios montável.',false,'Blob é object storage.'),
('Files fornece compartilhamentos; Managed Disk fornece disco para VM.',true,'Correta. File share e disco de VM são requisitos diferentes.'),('Files e Managed Disk são equivalentes.',false,'São recursos diferentes.'),('Managed Disk é uma queue.',false,'Managed Disk não armazena mensagens.'),('Files é um banco SQL.',false,'Files não é banco relacional.'),
('Azure Files.',true,'Correta. O requisito pede um file share gerenciado.'),('Blob Storage.',false,'Blob atende objetos, não o file share solicitado.'),('Queue Storage.',false,'Queue atende mensagens assíncronas.'),('Managed Disk separado para cada VM.',false,'Discos separados não formam o mesmo file share.'),
('SMB.',true,'Correta. SMB é comumente associado a Azure Files.'),('HTTPS como tipo de file share.',false,'HTTPS não é o conceito de protocolo de file share pedido.'),('SQL.',false,'SQL é linguagem de consulta, não protocolo de file share.'),('AMQP.',false,'AMQP é associado a mensageria, não ao file share.'),
('Azure Files.',true,'Correta. Files atende estrutura compartilhada e montável.'),('Blob Storage.',false,'Blob é object storage.'),('Table Storage.',false,'Table é NoSQL chave/atributo.'),('Queue Storage.',false,'Queue armazena mensagens.'),
('Azure Files.',true,'Correta. É o serviço de file shares gerenciados.'),('Managed Disks.',false,'Managed Disk atende disco de VM.'),('Blob Storage.',false,'Blob atende objetos.'),('Table Storage.',false,'Table atende entidades NoSQL.'),
('Blob Storage.',true,'Correta. Fotos como objetos apontam para Blob.'),('Azure Files.',false,'Files seria apropriado para file share.'),('Queue Storage.',false,'Queue armazena mensagens.'),('Managed Disk.',false,'Managed Disk fornece disco a VM.'),
('Azure Files.',true,'Correta. Vários servidores precisam do mesmo file share.'),('Um data disk separado em cada servidor.',false,'Discos separados não compartilham automaticamente o mesmo conjunto.'),('Queue Storage.',false,'Queue não fornece estrutura de arquivos.'),('Table Storage.',false,'Table não fornece file share.'),
('Azure Files.',true,'Correta. O requisito central é um file share.'),('Blob Storage.',false,'Blob atende object storage.'),('Managed Disk.',false,'Managed Disk atende disco de VM.'),('Queue Storage.',false,'Queue atende mensagens assíncronas.')
) values_seed(option_text,is_correct,explanation);
update public.question_options
set is_correct=false
where id between '74000000-0000-4000-8000-000000000401' and '74000000-0000-4000-8000-000000000440';
update public.question_options option set option_text=seed.option_text,is_correct=seed.is_correct,explanation=seed.explanation
from stage_882_existing_option_update seed where option.id=seed.id;

create temporary table stage_882_question_seed(
  id uuid primary key, slug text not null, question_text text not null, difficulty text not null,
  explanation text not null, display_order integer not null
) on commit drop;
insert into stage_882_question_seed values
('68000000-0000-4000-8000-000000000045','storage-accounts-and-services','Qual é a finalidade principal de uma Azure Storage Account?','easy','Ela fornece o recurso superior, namespace e configurações para serviços Azure Storage compatíveis.',1),
('68000000-0000-4000-8000-000000000046','storage-accounts-and-services','Uma API deve colocar mensagens simples para um worker processar depois. Qual serviço é mais apropriado?','easy','Queue Storage permite comunicação assíncrona simples e desacoplamento por mensagens.',2),
('68000000-0000-4000-8000-000000000047','storage-accounts-and-services','Uma aplicação precisa armazenar entidades NoSQL simples por chave e atributos. Qual serviço deve considerar?','medium','Table Storage atende dados NoSQL chave/atributo sem exigir um banco relacional.',3),
('68000000-0000-4000-8000-000000000048','storage-accounts-and-services','Qual afirmação sobre uma conta General-purpose v2 está correta em Fundamentals?','medium','GPv2 é recomendada para muitos cenários e pode disponibilizar Blob, Files, Queue e Table.',4),
('68000000-0000-4000-8000-000000000049','storage-accounts-and-services','Uma solução precisa de fotos, mensagens assíncronas e entidades NoSQL simples. Qual mapeamento está correto?','hard','Blob atende fotos, Queue atende mensagens assíncronas e Table atende entidades NoSQL simples.',5),
('68000000-0000-4000-8000-000000000050','blob-storage','Que tipo de armazenamento o Azure Blob Storage oferece?','easy','Blob Storage é object storage para grandes volumes de dados não estruturados.',1),
('68000000-0000-4000-8000-000000000051','blob-storage','Uma aplicação precisa armazenar milhões de imagens enviadas por usuários. Qual serviço é mais apropriado?','easy','Imagens são objetos/dados não estruturados, um caso típico de Blob Storage.',2),
('68000000-0000-4000-8000-000000000052','blob-storage','Qual sequência representa a hierarquia conceitual do Blob Storage?','medium','Uma Storage Account contém o serviço, containers organizam os objetos e blobs são os objetos armazenados.',3),
('68000000-0000-4000-8000-000000000053','blob-storage','Uma aplicação guarda documentos como objetos e não precisa de file share. Qual serviço deve escolher?','medium','Blob Storage atende objetos; Azure Files seria escolhido para compartilhamento de arquivos.',4),
('68000000-0000-4000-8000-000000000054','blob-storage','Uma equipe compara Blob, Files e Managed Disk para armazenar vídeos acessados pela aplicação como objetos. Qual escolha é mais alinhada?','hard','Blob Storage é próprio para objetos não estruturados; Files é file share e Managed Disk é disco de VM.',5),
('68000000-0000-4000-8000-000000000055','managed-disks','Qual é o uso principal de Azure Managed Disks?','easy','Managed Disks fornecem armazenamento em disco persistente para Azure Virtual Machines.',1),
('68000000-0000-4000-8000-000000000056','managed-disks','Qual disco contém o sistema operacional usado para inicializar uma Azure VM?','easy','O OS disk contém o sistema operacional de inicialização da VM.',2),
('68000000-0000-4000-8000-000000000057','managed-disks','Uma VM precisa de armazenamento persistente adicional para dados da aplicação. Qual recurso deve ser adicionado?','medium','Um data disk gerenciado adiciona armazenamento persistente à VM.',3),
('68000000-0000-4000-8000-000000000058','managed-disks','Qual comparação entre Managed Disk e Azure Files está correta?','medium','Managed Disk fornece disco de VM; Azure Files oferece compartilhamento de arquivos gerenciado.',4),
('68000000-0000-4000-8000-000000000059','managed-disks','Uma aplicação instalada em uma VM precisa de um disco persistente próprio, não de objetos nem de um file share. Qual opção é adequada?','hard','Managed Disk atende armazenamento em disco persistente para a VM.',5);

insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_882_question_seed seed join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure architecture and services'
join public.topics topic on topic.domain_id=domain.id and topic.id='32000000-0000-4000-8000-000000000004'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug=seed.slug;

create temporary table stage_882_option_seed(
  id uuid primary key, question_id uuid not null, option_text text not null, is_correct boolean not null,
  explanation text not null, display_order integer not null
) on commit drop;
insert into stage_882_option_seed
select ('7f100000-0000-4000-8000-'||lpad((196+row_number() over(order by question_id,display_order))::text,12,'0'))::uuid,
  question_id,option_text,is_correct,explanation,display_order
from (values
('68000000-0000-4000-8000-000000000045'::uuid,'Fornecer namespace e configurações para serviços Storage compatíveis.',true,'Correta. A account é o recurso superior.',1),('68000000-0000-4000-8000-000000000045','Representar um único Blob Container.',false,'Container existe dentro do Blob Storage.',2),('68000000-0000-4000-8000-000000000045','Ser um Managed Disk de VM.',false,'Managed Disk é recurso separado.',3),('68000000-0000-4000-8000-000000000045','Executar código de aplicação.',false,'Storage Account não é compute.',4),
('68000000-0000-4000-8000-000000000046','Queue Storage.',true,'Correta. Queue atende mensagens assíncronas simples.',1),('68000000-0000-4000-8000-000000000046','Azure Files.',false,'Files atende file shares.',2),('68000000-0000-4000-8000-000000000046','Table Storage.',false,'Table atende entidades NoSQL.',3),('68000000-0000-4000-8000-000000000046','Managed Disk.',false,'Managed Disk atende disco de VM.',4),
('68000000-0000-4000-8000-000000000047','Table Storage.',true,'Correta. Table atende chave/atributo NoSQL.',1),('68000000-0000-4000-8000-000000000047','Queue Storage.',false,'Queue armazena mensagens.',2),('68000000-0000-4000-8000-000000000047','Azure Files.',false,'Files oferece compartilhamentos.',3),('68000000-0000-4000-8000-000000000047','Managed Disk.',false,'Managed Disk atende VM.',4),
('68000000-0000-4000-8000-000000000048','Pode disponibilizar Blob, Files, Queue e Table.',true,'Correta. GPv2 atende muitos cenários gerais.',1),('68000000-0000-4000-8000-000000000048','É obrigatoriamente um disco Premium.',false,'GPv2 não é Managed Disk.',2),('68000000-0000-4000-8000-000000000048','Representa um único arquivo.',false,'A account é o recurso superior.',3),('68000000-0000-4000-8000-000000000048','Só pode disponibilizar Queue Storage.',false,'GPv2 suporta vários serviços.',4),
('68000000-0000-4000-8000-000000000049','Blob para fotos, Queue para mensagens e Table para entidades.',true,'Correta. Cada serviço atende seu padrão.',1),('68000000-0000-4000-8000-000000000049','Files para fotos, Disk para mensagens e Blob para entidades.',false,'Os serviços estão trocados.',2),('68000000-0000-4000-8000-000000000049','Queue para fotos, Table para mensagens e Files para entidades.',false,'Os serviços estão trocados.',3),('68000000-0000-4000-8000-000000000049','Managed Disk para todos os três requisitos.',false,'Um disco de VM não substitui os três serviços.',4),
('68000000-0000-4000-8000-000000000050','Object storage para dados não estruturados.',true,'Correta. Essa é a finalidade de Blob.',1),('68000000-0000-4000-8000-000000000050','File share gerenciado.',false,'Isso descreve Files.',2),('68000000-0000-4000-8000-000000000050','Mensageria assíncrona simples.',false,'Isso descreve Queue.',3),('68000000-0000-4000-8000-000000000050','Disco de VM.',false,'Isso descreve Managed Disk.',4),
('68000000-0000-4000-8000-000000000051','Blob Storage.',true,'Correta. Imagens são objetos não estruturados.',1),('68000000-0000-4000-8000-000000000051','Queue Storage.',false,'Queue armazena mensagens.',2),('68000000-0000-4000-8000-000000000051','Table Storage.',false,'Table armazena entidades NoSQL.',3),('68000000-0000-4000-8000-000000000051','Managed Disk.',false,'Disk atende VM.',4),
('68000000-0000-4000-8000-000000000052','Storage Account → Container → Blob.',true,'Correta. Vai do recurso superior ao objeto.',1),('68000000-0000-4000-8000-000000000052','Blob → Storage Account → Container.',false,'A ordem está invertida.',2),('68000000-0000-4000-8000-000000000052','Container → Managed Disk → Blob.',false,'Managed Disk não faz parte da hierarquia.',3),('68000000-0000-4000-8000-000000000052','Queue → Container → Azure Files.',false,'Mistura serviços distintos.',4),
('68000000-0000-4000-8000-000000000053','Blob Storage.',true,'Correta. O requisito pede objetos.',1),('68000000-0000-4000-8000-000000000053','Azure Files.',false,'Files seria para file share.',2),('68000000-0000-4000-8000-000000000053','Queue Storage.',false,'Queue seria para mensagens.',3),('68000000-0000-4000-8000-000000000053','Managed Disk.',false,'Disk seria para VM.',4),
('68000000-0000-4000-8000-000000000054','Blob Storage.',true,'Correta. Vídeos como objetos apontam para Blob.',1),('68000000-0000-4000-8000-000000000054','Azure Files.',false,'Files atende file share.',2),('68000000-0000-4000-8000-000000000054','Managed Disk.',false,'Disk atende VM.',3),('68000000-0000-4000-8000-000000000054','Table Storage.',false,'Table atende entidades NoSQL.',4),
('68000000-0000-4000-8000-000000000055','Discos persistentes para Azure VMs.',true,'Correta. Essa é a finalidade de Managed Disks.',1),('68000000-0000-4000-8000-000000000055','Compartilhamentos de arquivos.',false,'Isso descreve Files.',2),('68000000-0000-4000-8000-000000000055','Objetos não estruturados.',false,'Isso descreve Blob.',3),('68000000-0000-4000-8000-000000000055','Mensagens assíncronas.',false,'Isso descreve Queue.',4),
('68000000-0000-4000-8000-000000000056','OS disk.',true,'Correta. OS disk contém o sistema operacional.',1),('68000000-0000-4000-8000-000000000056','Queue.',false,'Queue armazena mensagens.',2),('68000000-0000-4000-8000-000000000056','Blob Container.',false,'Container organiza blobs.',3),('68000000-0000-4000-8000-000000000056','File share.',false,'File share não é disco de inicialização.',4),
('68000000-0000-4000-8000-000000000057','Um data disk gerenciado.',true,'Correta. Data disk adiciona persistência à VM.',1),('68000000-0000-4000-8000-000000000057','Uma Queue Storage.',false,'Queue não é disco.',2),('68000000-0000-4000-8000-000000000057','Uma Table Storage.',false,'Table não é disco.',3),('68000000-0000-4000-8000-000000000057','Um Blob Container como OS disk.',false,'Container não é disco gerenciado.',4),
('68000000-0000-4000-8000-000000000058','Disk fornece disco de VM; Files fornece file share.',true,'Correta. São padrões distintos.',1),('68000000-0000-4000-8000-000000000058','Ambos são nomes para Blob Container.',false,'Nenhum é Blob Container.',2),('68000000-0000-4000-8000-000000000058','Files inicializa obrigatoriamente toda VM.',false,'OS disk inicializa a VM.',3),('68000000-0000-4000-8000-000000000058','Disk é mensageria e Files é NoSQL.',false,'As definições estão incorretas.',4),
('68000000-0000-4000-8000-000000000059','Managed Disk.',true,'Correta. O requisito é disco persistente da VM.',1),('68000000-0000-4000-8000-000000000059','Blob Storage.',false,'Blob atende objetos.',2),('68000000-0000-4000-8000-000000000059','Azure Files.',false,'Files atende file share.',3),('68000000-0000-4000-8000-000000000059','Queue Storage.',false,'Queue atende mensagens.',4)
) values_seed(question_id,option_text,is_correct,explanation,display_order);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_882_option_seed;

do $$
begin
  if (select count(*) from public.lesson_content_blocks block join public.lessons lesson on lesson.id=block.lesson_id
      where lesson.topic_id='32000000-0000-4000-8000-000000000004' and lesson.slug in ('storage-accounts-and-services','blob-storage','azure-files','managed-disks') and block.is_published)<>31
    or exists(select 1 from public.lessons lesson where lesson.topic_id='32000000-0000-4000-8000-000000000004'
      and lesson.slug in ('storage-accounts-and-services','blob-storage','azure-files','managed-disks')
      and (select count(*) from public.flashcards card where card.lesson_id=lesson.id and card.is_published)<>case lesson.slug when 'storage-accounts-and-services' then 5 when 'blob-storage' then 4 when 'azure-files' then 3 when 'managed-disks' then 3 end)
    or exists(select 1 from public.lessons lesson where lesson.topic_id='32000000-0000-4000-8000-000000000004'
      and lesson.slug in ('storage-accounts-and-services','blob-storage','azure-files','managed-disks')
      and (select count(*) from public.questions question where question.lesson_id=lesson.id and question.is_published)<>case when lesson.slug='azure-files' then 10 else 5 end) then
    raise exception '8.8.2 final content counts are invalid';
  end if;
  if exists(select 1 from public.questions question join public.lessons lesson on lesson.id=question.lesson_id
    left join public.question_options option on option.question_id=question.id
    where lesson.topic_id='32000000-0000-4000-8000-000000000004' and lesson.slug in ('storage-accounts-and-services','blob-storage','azure-files','managed-disks')
    and question.is_published group by question.id having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1) then
    raise exception '8.8.2 Question options are invalid';
  end if;
end; $$;

commit;

begin;

do $$
declare target_count integer;
begin
  select count(*) into target_count
  from public.lessons lesson
  join public.topics topic on topic.id=lesson.topic_id
  join public.domains domain on domain.id=topic.domain_id
  join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900'
    and domain.title='Describe Azure architecture and services'
    and topic.id='32000000-0000-4000-8000-000000000004'
    and lesson.slug in ('moving-files-to-azure','azure-migrate-and-data-box');
  if target_count<>2 then raise exception '8.8.5 expected the two audited Lessons'; end if;
  if exists(
    select 1 from public.lessons lesson
    where lesson.topic_id='32000000-0000-4000-8000-000000000004'
      and lesson.slug in ('moving-files-to-azure','azure-migrate-and-data-box')
      and (exists(select 1 from public.lesson_content_blocks block where block.lesson_id=lesson.id)
        or exists(select 1 from public.visual_experiences visual where visual.lesson_id=lesson.id)
        or exists(select 1 from public.flashcards card where card.lesson_id=lesson.id)
        or exists(select 1 from public.questions question where question.lesson_id=lesson.id))
  ) then raise exception '8.8.5 Lessons no longer match the audited empty baseline'; end if;
end; $$;

update public.lessons set estimated_minutes=12
where topic_id='32000000-0000-4000-8000-000000000004' and slug='moving-files-to-azure';
update public.lessons set estimated_minutes=10
where topic_id='32000000-0000-4000-8000-000000000004' and slug='azure-migrate-and-data-box';

create temporary table stage_885_block_seed(
  id uuid primary key,lesson_slug text not null,type text not null,title text,content text,config jsonb,display_order integer not null
) on commit drop;
insert into stage_885_block_seed values
('7b150000-0000-4000-8000-000000000001','moving-files-to-azure','explanation','Três necessidades, três ferramentas',
$content$Movimentar dados para Azure Storage pode significar uma cópia executada por linha de comando, uma operação visual ou uma sincronização híbrida contínua. AzCopy, Azure Storage Explorer e Azure File Sync atendem necessidades diferentes.

Na prova, procure a interface desejada e se o cenário descreve transferência pontual ou sincronização contínua.$content$,null,1),
('7b150000-0000-4000-8000-000000000002','moving-files-to-azure','explanation','AzCopy: cópia por linha de comando',
$content$AzCopy é um utilitário de linha de comando para copiar dados de, para ou entre recursos do Azure Storage. Ele é adequado para transferências automatizadas e grandes conjuntos de blobs ou arquivos suportados.

O objetivo Fundamentals é reconhecer CLI + transferência de dados + Azure Storage. Não é necessário memorizar comandos ou parâmetros.$content$,null,2),
('7b150000-0000-4000-8000-000000000003','moving-files-to-azure','explanation','Azure Storage Explorer: gerenciamento gráfico',
$content$Azure Storage Explorer é uma aplicação gráfica para visualizar e gerenciar recursos e dados do Azure Storage. Conforme o recurso suportado, permite trabalhar visualmente com blobs, file shares, queues e tables.

Ele é útil quando o cenário pede navegação ou gerenciamento por GUI. A prova Fundamentals não exige conhecimento de menus.$content$,null,3),
('7b150000-0000-4000-8000-000000000004','moving-files-to-azure','explanation','Azure File Sync: cenário híbrido',
$content$Azure File Sync centraliza file shares em Azure Files enquanto permite que Windows Server continue oferecendo acesso e cache local. Os servidores sincronizam seus dados com o compartilhamento central no Azure.

Isso atende ambientes híbridos que ainda precisam do file server local, mas desejam uma cópia central em Azure Files e sincronização contínua.$content$,null,4),
('7b150000-0000-4000-8000-000000000005','moving-files-to-azure','important','Azure Files como centro, Windows Server como cache',
$content$Windows Server local ↕ Azure File Sync ↕ Azure Files central.

Cloud tiering pode, conceitualmente, manter arquivos usados com frequência no cache local e liberar espaço para dados menos usados. Esse detalhe é opcional para a decisão: a ideia principal é sincronização híbrida, não cópia pontual.$content$,null,5),
('7b150000-0000-4000-8000-000000000006','moving-files-to-azure','important','Comparação das opções de movimentação',
$content$| Ferramenta | Melhor reconhecimento | Natureza |
| --- | --- | --- |
| AzCopy | Copiar dados usando CLI ou automação | Transferência executada por comando |
| Storage Explorer | Navegar, gerenciar ou copiar por GUI | Operação gráfica |
| Azure File Sync | Sincronizar Windows Server com Azure Files | Serviço híbrido contínuo |

Escolha pela necessidade descrita, não apenas pelo volume de dados.$content$,null,6),
('7b150000-0000-4000-8000-000000000007','moving-files-to-azure','example','Reconheça o cenário',
$content$Copiar muitos blobs por script ou terminal → AzCopy.

Navegar por containers e file shares visualmente → Azure Storage Explorer.

Manter um servidor de arquivos Windows local sincronizado com Azure Files → Azure File Sync.$content$,null,7),
('7b150000-0000-4000-8000-000000000008','moving-files-to-azure','exam_trap','Cópia não é sincronização híbrida',
$content$AzCopy é uma ferramenta de transferência e não é o serviço híbrido que mantém file shares do Windows Server sincronizados com Azure Files. Azure File Sync atende essa continuidade.

AzCopy também não descobre, avalia e planeja a migração completa de workloads; esse é o papel de uma plataforma como Azure Migrate.$content$,null,8),
('7b150000-0000-4000-8000-000000000009','moving-files-to-azure','exam_tip','CLI, GUI ou híbrido?',
$content$Terminal, script ou automação aponta para AzCopy. Interface gráfica aponta para Storage Explorer. File server Windows que deve continuar local e sincronizado com Azure Files aponta para Azure File Sync.$content$,null,9),
('7b150000-0000-4000-8000-000000000010','moving-files-to-azure','summary','Resumo para memória ativa',null,
'{"items":["AzCopy copia dados por linha de comando.","Storage Explorer permite gerenciamento visual de Azure Storage.","Azure File Sync sincroniza Windows Server com Azure Files.","Azure Files funciona como armazenamento central no cenário de File Sync.","AzCopy é transferência; File Sync é sincronização híbrida contínua."]}'::jsonb,10),
('7b150000-0000-4000-8000-000000000011','azure-migrate-and-data-box','explanation','Migração de workloads ou transporte de dados?',
$content$Azure Migrate e Azure Data Box podem participar de uma jornada para Azure, mas resolvem problemas diferentes. Azure Migrate ajuda a decidir, avaliar, planejar e executar a migração de workloads. Data Box transporta grande volume de dados por meio físico quando a rede não é prática.

O cenário da prova normalmente revela se a necessidade é assessment de workloads ou movimentação offline de dados.$content$,null,1),
('7b150000-0000-4000-8000-000000000012','azure-migrate-and-data-box','explanation','Azure Migrate: decidir, planejar e migrar',
$content$Azure Migrate é um serviço e plataforma central para descobrir workloads, avaliar readiness e custos estimados, planejar e ajudar a executar sua migração para Azure.

Ele reúne recursos para assessment e migração sem ser um dispositivo físico.$content$,null,2),
('7b150000-0000-4000-8000-000000000013','azure-migrate-and-data-box','explanation','Workloads reconhecidos pelo Azure Migrate',
$content$Em nível AZ-900, associe Azure Migrate a cenários com servers, máquinas virtuais, databases, web applications e outros workloads suportados.

O aluno precisa reconhecer a finalidade, não detalhes de appliance, descoberta interna, replicação, dependências ou ondas de migração.$content$,null,3),
('7b150000-0000-4000-8000-000000000014','azure-migrate-and-data-box','important','Assessment antes da decisão',
$content$Uma avaliação pode indicar preparação para Azure, possíveis destinos e estimativas de custo. Esses dados apoiam o planejamento; não significam que todo workload será automaticamente migrado ou modernizado.

Azure Migrate apoia a jornada, mas decisões e execução ainda dependem do cenário.$content$,null,4),
('7b150000-0000-4000-8000-000000000015','azure-migrate-and-data-box','explanation','Azure Data Box: transferência física',
$content$Azure Data Box é uma solução baseada em dispositivo físico para mover grandes volumes de dados para ou a partir de Azure quando a transferência pela rede é lenta, limitada ou impraticável.

Conceitualmente, Microsoft envia o dispositivo, a empresa copia os dados, devolve o equipamento e os dados são transferidos para Azure. Capacidades e detalhes logísticos não precisam ser memorizados.$content$,null,5),
('7b150000-0000-4000-8000-000000000016','azure-migrate-and-data-box','important','Azure Migrate versus Data Box',
$content$| Opção | Foco principal | Sinal no cenário |
| --- | --- | --- |
| Azure Migrate | Descoberta, assessment, planejamento e migração de workloads | Avaliar servers, VMs, databases ou web apps |
| Azure Data Box | Transferência física/offline de grande quantidade de dados | WAN limitada ou transferência pela rede impraticável |

Data Box movimenta dados; não analisa automaticamente a arquitetura do workload.$content$,null,6),
('7b150000-0000-4000-8000-000000000017','azure-migrate-and-data-box','example','Duas decisões diferentes',
$content$Avaliar servidores e estimar readiness e custo antes de migrá-los → Azure Migrate.

Transportar dezenas de terabytes para Azure com conexão extremamente limitada → Azure Data Box.

Uma iniciativa maior pode usar mais de uma ferramenta, mas cada requisito deve ser associado à sua finalidade.$content$,null,7),
('7b150000-0000-4000-8000-000000000018','azure-migrate-and-data-box','exam_trap','Serviço de assessment não é dispositivo físico',
$content$Azure Migrate não é um equipamento enviado à empresa. Azure Data Box não descobre workloads, avalia readiness nem cria um plano de migração automaticamente.

Não escolha Data Box apenas porque a palavra migração aparece; procure grande volume e limitação de rede.$content$,null,8),
('7b150000-0000-4000-8000-000000000019','azure-migrate-and-data-box','exam_tip','Identifique o objeto da ação',
$content$Se a ação é descobrir ou avaliar workloads, pense em Azure Migrate. Se é transportar fisicamente muitos dados porque a rede não atende, pense em Data Box.$content$,null,9),
('7b150000-0000-4000-8000-000000000020','azure-migrate-and-data-box','summary','Resumo para memória ativa',null,
'{"items":["Azure Migrate apoia descoberta, assessment, planejamento e migração de workloads.","Servers, VMs, databases e web apps são cenários reconhecíveis para Azure Migrate.","Data Box transporta grande volume de dados por dispositivo físico.","Rede limitada ou impraticável é um sinal para Data Box.","Azure Migrate avalia workloads; Data Box movimenta dados offline."]}'::jsonb,10);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.display_order,true
from stage_885_block_seed seed
join public.lessons lesson on lesson.topic_id='32000000-0000-4000-8000-000000000004' and lesson.slug=seed.lesson_slug;

create temporary table stage_885_flashcard_seed(
  id uuid primary key,lesson_slug text not null,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_885_flashcard_seed values
('7e300000-0000-4000-8000-000000000012','moving-files-to-azure','Para que serve o AzCopy?','Para copiar dados de, para ou entre recursos do Azure Storage por linha de comando.','CLI + transferência.',1),
('7e300000-0000-4000-8000-000000000013','moving-files-to-azure','Qual ferramenta oferece interface gráfica para gerenciar Azure Storage?','Azure Storage Explorer.','GUI.',2),
('7e300000-0000-4000-8000-000000000014','moving-files-to-azure','O que o Azure File Sync centraliza?','File shares em Azure Files, mantendo Windows Server sincronizado e disponível como cache local.','Cenário híbrido.',3),
('7e300000-0000-4000-8000-000000000015','moving-files-to-azure','AzCopy e Azure File Sync resolvem a mesma necessidade?','Não. AzCopy transfere dados; File Sync mantém sincronização híbrida contínua.','Cópia versus sync.',4),
('7e300000-0000-4000-8000-000000000016','moving-files-to-azure','Qual opção usar para copiar blobs por script?','AzCopy.','Automação por terminal.',5),
('7e300000-0000-4000-8000-000000000017','moving-files-to-azure','Qual opção mantém um file server Windows sincronizado com Azure Files?','Azure File Sync.','Servidor local continua no cenário.',6),
('7e300000-0000-4000-8000-000000000018','azure-migrate-and-data-box','Qual é a finalidade do Azure Migrate?','Descobrir, avaliar, planejar e ajudar a migrar workloads para Azure.','Assessment + migration.',1),
('7e300000-0000-4000-8000-000000000019','azure-migrate-and-data-box','Quando Azure Data Box é apropriado?','Ao mover grande volume de dados quando a transferência pela rede é limitada ou impraticável.','Dispositivo físico.',2),
('7e300000-0000-4000-8000-000000000020','azure-migrate-and-data-box','Qual é a diferença central entre Azure Migrate e Data Box?','Azure Migrate avalia e apoia a migração de workloads; Data Box transporta dados fisicamente.','Workload versus dados offline.',3),
('7e300000-0000-4000-8000-000000000021','azure-migrate-and-data-box','Qual opção avalia readiness de servidores para Azure?','Azure Migrate.','Assessment.',4),
('7e300000-0000-4000-8000-000000000022','azure-migrate-and-data-box','Data Box analisa automaticamente a arquitetura dos workloads?','Não. Ele é uma solução de transferência física de dados.','Transporte, não assessment.',5);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_885_flashcard_seed seed
join public.lessons lesson on lesson.topic_id='32000000-0000-4000-8000-000000000004' and lesson.slug=seed.lesson_slug;

create temporary table stage_885_question_seed(
  id uuid primary key,lesson_slug text not null,question_text text not null,difficulty text not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_885_question_seed values
('68000000-0000-4000-8000-000000000070','moving-files-to-azure','Qual ferramenta é um utilitário de linha de comando para copiar dados no Azure Storage?','easy','AzCopy é a ferramenta CLI voltada à transferência de dados de, para ou entre recursos suportados do Azure Storage.',1),
('68000000-0000-4000-8000-000000000071','moving-files-to-azure','Qual ferramenta oferece uma interface gráfica para navegar e gerenciar dados do Azure Storage?','easy','Azure Storage Explorer fornece uma experiência gráfica para trabalhar visualmente com recursos e dados suportados do Azure Storage.',2),
('68000000-0000-4000-8000-000000000072','moving-files-to-azure','Uma empresa quer manter seu Windows file server local sincronizado com um compartilhamento central no Azure. Qual opção é mais apropriada?','medium','Azure File Sync centraliza os dados em Azure Files enquanto mantém Windows Server sincronizado e disponível para acesso ou cache local.',3),
('68000000-0000-4000-8000-000000000073','moving-files-to-azure','Um administrador precisa automatizar por terminal a cópia de muitos blobs para Azure Storage. Qual opção deve reconhecer?','medium','AzCopy combina linha de comando e transferência de dados do Azure Storage, sendo mais alinhado ao cenário automatizado descrito.',4),
('68000000-0000-4000-8000-000000000074','moving-files-to-azure','Uma equipe usa Storage Explorer para inspeção visual, mas precisa manter file shares locais continuamente alinhados com Azure Files. O que deve adicionar?','hard','Azure File Sync atende a sincronização híbrida contínua. Storage Explorer é a interface gráfica e AzCopy é uma ferramenta de transferência.',5),
('68000000-0000-4000-8000-000000000075','azure-migrate-and-data-box','Qual serviço ajuda a descobrir e avaliar workloads antes de uma migração para Azure?','easy','Azure Migrate apoia descoberta, assessment, planejamento e execução da migração de workloads para Azure.',1),
('68000000-0000-4000-8000-000000000076','azure-migrate-and-data-box','Qual opção usa um dispositivo físico para transferir grande volume de dados quando a rede não é prática?','easy','Azure Data Box movimenta dados por dispositivo físico e é apropriado quando a conectividade torna a transferência de rede impraticável.',2),
('68000000-0000-4000-8000-000000000077','azure-migrate-and-data-box','Uma empresa deseja avaliar readiness e custo estimado de servidores antes de movê-los para Azure. Qual opção é mais alinhada?','medium','Azure Migrate fornece assessment e informações para planejar a migração; Data Box não avalia readiness de workloads.',3),
('68000000-0000-4000-8000-000000000078','azure-migrate-and-data-box','Dezenas de terabytes precisam chegar ao Azure, mas a conexão WAN é extremamente limitada. Qual opção é mais apropriada?','medium','Azure Data Box permite transportar fisicamente grande volume de dados sem depender de uma transferência completa pela WAN limitada.',4),
('68000000-0000-4000-8000-000000000079','azure-migrate-and-data-box','Uma iniciativa precisa avaliar VMs e também transportar um grande conjunto de dados por uma conexão impraticável. Qual combinação atende às duas necessidades?','hard','Azure Migrate atende assessment e planejamento dos workloads; Azure Data Box atende a transferência física do grande conjunto de dados.',5);
insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_885_question_seed seed
join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure architecture and services'
join public.topics topic on topic.domain_id=domain.id and topic.id='32000000-0000-4000-8000-000000000004'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug=seed.lesson_slug;

create temporary table stage_885_option_seed(
  id uuid primary key,question_id uuid not null,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_885_option_seed values
('7f100000-0000-4000-8000-000000000297','68000000-0000-4000-8000-000000000070','AzCopy.',true,'Correta. AzCopy é o utilitário CLI de transferência.',1),
('7f100000-0000-4000-8000-000000000298','68000000-0000-4000-8000-000000000070','Azure File Sync.',false,'File Sync é um serviço de sincronização híbrida.',2),
('7f100000-0000-4000-8000-000000000299','68000000-0000-4000-8000-000000000070','Azure Migrate.',false,'Azure Migrate avalia e migra workloads.',3),
('7f100000-0000-4000-8000-000000000300','68000000-0000-4000-8000-000000000070','Azure Data Box.',false,'Data Box usa transferência física.',4),
('7f100000-0000-4000-8000-000000000301','68000000-0000-4000-8000-000000000071','Azure Storage Explorer.',true,'Correta. Storage Explorer oferece GUI para Azure Storage.',1),
('7f100000-0000-4000-8000-000000000302','68000000-0000-4000-8000-000000000071','AzCopy.',false,'AzCopy é uma ferramenta de linha de comando.',2),
('7f100000-0000-4000-8000-000000000303','68000000-0000-4000-8000-000000000071','Azure File Sync.',false,'File Sync sincroniza Windows Server e Azure Files.',3),
('7f100000-0000-4000-8000-000000000304','68000000-0000-4000-8000-000000000071','Azure Migrate.',false,'Azure Migrate atende workloads e assessment.',4),
('7f100000-0000-4000-8000-000000000305','68000000-0000-4000-8000-000000000072','Azure File Sync.',true,'Correta. File Sync mantém o cenário híbrido sincronizado.',1),
('7f100000-0000-4000-8000-000000000306','68000000-0000-4000-8000-000000000072','AzCopy.',false,'AzCopy executa transferências, não mantém esse file server sincronizado.',2),
('7f100000-0000-4000-8000-000000000307','68000000-0000-4000-8000-000000000072','Storage Explorer.',false,'Storage Explorer oferece gerenciamento gráfico.',3),
('7f100000-0000-4000-8000-000000000308','68000000-0000-4000-8000-000000000072','Data Box.',false,'Data Box transporta dados fisicamente.',4),
('7f100000-0000-4000-8000-000000000309','68000000-0000-4000-8000-000000000073','AzCopy.',true,'Correta. O cenário combina terminal, automação e blobs.',1),
('7f100000-0000-4000-8000-000000000310','68000000-0000-4000-8000-000000000073','Azure File Sync.',false,'File Sync atende sincronização híbrida contínua.',2),
('7f100000-0000-4000-8000-000000000311','68000000-0000-4000-8000-000000000073','Storage Explorer.',false,'Storage Explorer é gráfico, não CLI.',3),
('7f100000-0000-4000-8000-000000000312','68000000-0000-4000-8000-000000000073','Azure Migrate.',false,'Azure Migrate atende avaliação e migração de workloads.',4),
('7f100000-0000-4000-8000-000000000313','68000000-0000-4000-8000-000000000074','Azure File Sync.',true,'Correta. Ele mantém Azure Files e Windows Server sincronizados.',1),
('7f100000-0000-4000-8000-000000000314','68000000-0000-4000-8000-000000000074','AzCopy.',false,'AzCopy não substitui o serviço de sincronização híbrida.',2),
('7f100000-0000-4000-8000-000000000315','68000000-0000-4000-8000-000000000074','Azure Data Box.',false,'Data Box resolve transporte físico de grande volume.',3),
('7f100000-0000-4000-8000-000000000316','68000000-0000-4000-8000-000000000074','Azure Migrate.',false,'Azure Migrate não mantém file shares sincronizados.',4),
('7f100000-0000-4000-8000-000000000317','68000000-0000-4000-8000-000000000075','Azure Migrate.',true,'Correta. Azure Migrate descobre e avalia workloads.',1),
('7f100000-0000-4000-8000-000000000318','68000000-0000-4000-8000-000000000075','Azure Data Box.',false,'Data Box transporta dados e não executa assessment.',2),
('7f100000-0000-4000-8000-000000000319','68000000-0000-4000-8000-000000000075','AzCopy.',false,'AzCopy copia dados do Azure Storage.',3),
('7f100000-0000-4000-8000-000000000320','68000000-0000-4000-8000-000000000075','Storage Explorer.',false,'Storage Explorer oferece gerenciamento gráfico de Storage.',4),
('7f100000-0000-4000-8000-000000000321','68000000-0000-4000-8000-000000000076','Azure Data Box.',true,'Correta. Data Box usa um dispositivo físico.',1),
('7f100000-0000-4000-8000-000000000322','68000000-0000-4000-8000-000000000076','Azure Migrate.',false,'Azure Migrate é um serviço de assessment e migração.',2),
('7f100000-0000-4000-8000-000000000323','68000000-0000-4000-8000-000000000076','Azure File Sync.',false,'File Sync mantém file shares sincronizados.',3),
('7f100000-0000-4000-8000-000000000324','68000000-0000-4000-8000-000000000076','AzCopy.',false,'AzCopy depende de transferência por rede.',4),
('7f100000-0000-4000-8000-000000000325','68000000-0000-4000-8000-000000000077','Azure Migrate.',true,'Correta. O requisito é assessment e planejamento.',1),
('7f100000-0000-4000-8000-000000000326','68000000-0000-4000-8000-000000000077','Azure Data Box.',false,'Data Box não avalia readiness ou custos.',2),
('7f100000-0000-4000-8000-000000000327','68000000-0000-4000-8000-000000000077','Storage Explorer.',false,'Storage Explorer gerencia dados de Storage visualmente.',3),
('7f100000-0000-4000-8000-000000000328','68000000-0000-4000-8000-000000000077','Azure File Sync.',false,'File Sync não avalia workloads para migração.',4),
('7f100000-0000-4000-8000-000000000329','68000000-0000-4000-8000-000000000078','Azure Data Box.',true,'Correta. A limitação da WAN favorece transporte físico.',1),
('7f100000-0000-4000-8000-000000000330','68000000-0000-4000-8000-000000000078','Azure Migrate.',false,'Azure Migrate não é o dispositivo de transporte.',2),
('7f100000-0000-4000-8000-000000000331','68000000-0000-4000-8000-000000000078','AzCopy.',false,'A transferência online não atende tão bem à rede impraticável.',3),
('7f100000-0000-4000-8000-000000000332','68000000-0000-4000-8000-000000000078','Storage Explorer.',false,'Uma GUI não resolve a limitação de conectividade.',4),
('7f100000-0000-4000-8000-000000000333','68000000-0000-4000-8000-000000000079','Azure Migrate para assessment e Data Box para transporte físico.',true,'Correta. Cada opção atende uma parte distinta do cenário.',1),
('7f100000-0000-4000-8000-000000000334','68000000-0000-4000-8000-000000000079','Data Box para assessment e Azure Migrate para transporte físico.',false,'As finalidades estão invertidas.',2),
('7f100000-0000-4000-8000-000000000335','68000000-0000-4000-8000-000000000079','Somente Azure Migrate, pois ele substitui qualquer transferência de dados.',false,'Assessment de workload não elimina a necessidade de movimentar dados.',3),
('7f100000-0000-4000-8000-000000000336','68000000-0000-4000-8000-000000000079','Somente Data Box, pois ele avalia e planeja a migração das VMs.',false,'Data Box não executa assessment nem planejamento de workloads.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_885_option_seed;

do $$
declare lesson_record record;
begin
  for lesson_record in select id,slug from public.lessons
    where topic_id='32000000-0000-4000-8000-000000000004'
      and slug in ('moving-files-to-azure','azure-migrate-and-data-box')
  loop
    if (select count(*) from public.lesson_content_blocks where lesson_id=lesson_record.id and is_published)<>10
      or (select count(*) from public.visual_experiences where lesson_id=lesson_record.id)<>0
      or (select count(*) from public.questions where lesson_id=lesson_record.id and is_published)<>5 then
      raise exception '8.8.5 final counts are invalid for %',lesson_record.slug; end if;
    if exists(select 1 from public.questions question left join public.question_options option on option.question_id=question.id
      where question.lesson_id=lesson_record.id and question.is_published group by question.id
      having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1) then
      raise exception '8.8.5 options are invalid for %',lesson_record.slug; end if;
  end loop;
  if (select count(*) from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='32000000-0000-4000-8000-000000000004' and lesson.slug='moving-files-to-azure' and card.is_published)<>6
    or (select count(*) from public.flashcards card join public.lessons lesson on lesson.id=card.lesson_id
      where lesson.topic_id='32000000-0000-4000-8000-000000000004' and lesson.slug='azure-migrate-and-data-box' and card.is_published)<>5 then
    raise exception '8.8.5 Flashcard counts are invalid'; end if;
end; $$;

commit;

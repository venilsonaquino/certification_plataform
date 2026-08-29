begin;

do $$
declare target_lesson_id uuid;
begin
  select lesson.id into strict target_lesson_id
  from public.lessons lesson
  join public.topics topic on topic.id=lesson.topic_id
  join public.domains domain on domain.id=topic.domain_id
  join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900'
    and domain.title='Describe Azure architecture and services'
    and topic.id='32000000-0000-4000-8000-000000000004'
    and topic.title='Storage Services'
    and lesson.slug='storage-redundancy-options';

  if exists(select 1 from public.lesson_content_blocks where lesson_id=target_lesson_id)
    or exists(select 1 from public.visual_experiences where lesson_id=target_lesson_id)
    or (select count(*) from public.flashcards where lesson_id=target_lesson_id)<>3
    or (select count(*) from public.questions where lesson_id=target_lesson_id)<>1 then
    raise exception 'Storage Redundancy does not match the audited 8.8.4 baseline';
  end if;
end; $$;

update public.lessons set estimated_minutes=12
where topic_id='32000000-0000-4000-8000-000000000004'
  and slug='storage-redundancy-options';

insert into public.visual_experiences(
  id,lesson_id,type,title,description,config,display_order,is_published
)
select
  '76000000-0000-4000-8000-000000000013',lesson.id,'architecture',
  'Redundância local, zonal e geográfica',
  'Compare onde as cópias ficam e identifique quando a região secundária aceita leitura. A replicação geográfica é assíncrona; leitura secundária exige uma variante RA e não concede escrita.',
  $config${
    "nodes":[
      {"id":"lrs","label":"LRS","kind":"group","description":"Proteção local na região primária.","x":8,"y":10},
      {"id":"lrs-datacenter","label":"Um datacenter","kind":"zone","description":"As cópias permanecem em um único datacenter físico da região primária.","x":43,"y":10},
      {"id":"lrs-copies","label":"Cópias locais","kind":"resource","description":"Protege contra falhas de unidade e rack, mas não contra indisponibilidade do datacenter ou da região.","x":78,"y":10},
      {"id":"zrs","label":"ZRS","kind":"group","description":"Proteção zonal na região primária.","x":8,"y":35},
      {"id":"zrs-zone-1","label":"Zona 1","kind":"zone","description":"Cópia síncrona em uma zona de disponibilidade.","x":36,"y":35},
      {"id":"zrs-zone-2","label":"Zona 2","kind":"zone","description":"Cópia síncrona em outra zona da mesma região.","x":59,"y":35},
      {"id":"zrs-zone-3","label":"Zona 3+","kind":"zone","description":"Cópia síncrona em pelo menos uma terceira zona da região primária.","x":82,"y":35},
      {"id":"grs","label":"GRS","kind":"group","description":"LRS na primária mais replicação geográfica.","x":8,"y":62},
      {"id":"grs-primary","label":"Primária: LRS","kind":"zone","description":"Cópias locais na região primária.","x":36,"y":62},
      {"id":"grs-secondary","label":"Secundária: LRS","kind":"zone","description":"Recebe dados de forma assíncrona em outra região.","x":64,"y":62},
      {"id":"ra-grs-read","label":"RA-GRS: leitura","kind":"service","description":"A variante RA permite ler a secundária. Ela não transforma a secundária em destino normal de escrita.","x":90,"y":62},
      {"id":"gzrs","label":"GZRS","kind":"group","description":"ZRS na primária mais replicação geográfica.","x":8,"y":88},
      {"id":"gzrs-primary-zones","label":"Primária: ZRS","kind":"group","description":"Cópias síncronas entre zonas da região primária.","x":36,"y":88},
      {"id":"gzrs-secondary","label":"Secundária: LRS","kind":"zone","description":"Recebe dados de forma assíncrona em outra região.","x":64,"y":88},
      {"id":"ra-gzrs-read","label":"RA-GZRS: leitura","kind":"service","description":"A variante RA permite ler a secundária, sem habilitar escrita normal nela.","x":90,"y":88}
    ],
    "edges":[
      {"id":"lrs-location","source":"lrs","target":"lrs-datacenter","label":"local"},
      {"id":"lrs-replicas","source":"lrs-datacenter","target":"lrs-copies","label":"cópias"},
      {"id":"zrs-first","source":"zrs","target":"zrs-zone-1","label":"síncrona"},
      {"id":"zrs-second","source":"zrs","target":"zrs-zone-2","label":"síncrona"},
      {"id":"zrs-third","source":"zrs","target":"zrs-zone-3","label":"síncrona"},
      {"id":"grs-local","source":"grs","target":"grs-primary","label":"LRS"},
      {"id":"grs-geo","source":"grs-primary","target":"grs-secondary","label":"assíncrona"},
      {"id":"grs-readable","source":"grs-secondary","target":"ra-grs-read","label":"somente RA"},
      {"id":"gzrs-zonal","source":"gzrs","target":"gzrs-primary-zones","label":"ZRS"},
      {"id":"gzrs-geo","source":"gzrs-primary-zones","target":"gzrs-secondary","label":"assíncrona"},
      {"id":"gzrs-readable","source":"gzrs-secondary","target":"ra-gzrs-read","label":"somente RA"}
    ]
  }$config$::jsonb,
  1,true
from public.lessons lesson
where lesson.topic_id='32000000-0000-4000-8000-000000000004'
  and lesson.slug='storage-redundancy-options';

create temporary table stage_884_block_seed(
  id uuid primary key,type text not null,title text,content text,config jsonb,
  visual_experience_id uuid,display_order integer not null
) on commit drop;
insert into stage_884_block_seed values
('7b140000-0000-4000-8000-000000000001','explanation','Por que redundância importa?',
$content$Redundância mantém múltiplas cópias dos dados para reduzir o impacto de falhas de hardware, datacenter, zona ou região. A opção adequada depende do alcance da falha contra a qual o workload precisa de proteção, da necessidade de leitura secundária e do custo aceitável.

Redundância aumenta resiliência, mas não substitui backup, proteção contra exclusão, governança nem uma arquitetura de recuperação de desastre.$content$,null,null,1),
('7b140000-0000-4000-8000-000000000002','explanation','LRS: redundância local',
$content$Locally-redundant storage mantém múltiplas cópias dentro de um único datacenter físico na região primária. Ele protege contra falhas locais de unidade e rack, mas uma indisponibilidade desse datacenter pode afetar todas as cópias.

LRS é a opção de menor alcance geográfico entre as alternativas desta Lesson.$content$,null,null,2),
('7b140000-0000-4000-8000-000000000003','explanation','ZRS: redundância entre zonas',
$content$Zone-redundant storage replica os dados de forma síncrona entre três ou mais zonas de disponibilidade na região primária. Como as zonas possuem infraestrutura física separada, ZRS pode manter os dados disponíveis diante da falha de uma zona.

ZRS não adiciona, por si só, uma cópia em outra região.$content$,null,null,3),
('7b140000-0000-4000-8000-000000000004','explanation','GRS: local e geográfica',
$content$Geo-redundant storage usa LRS na região primária e replica os dados de forma assíncrona para uma região secundária, onde também são mantidas cópias locais.

Por ser assíncrona, a secundária pode estar atrasada em relação à primária. Em GRS comum, ela não é um endpoint normal de leitura.$content$,null,null,4),
('7b140000-0000-4000-8000-000000000005','explanation','RA-GRS: leitura da secundária',
$content$Read-access geo-redundant storage mantém a arquitetura do GRS e acrescenta acesso de leitura à região secundária. Isso pode apoiar cenários de leitura quando a primária está indisponível ou quando a aplicação foi projetada para usar o endpoint secundário.

O prefixo RA indica read access; não significa escrita normal na secundária.$content$,null,null,5),
('7b140000-0000-4000-8000-000000000006','explanation','GZRS: zonas e geografia',
$content$Geo-zone-redundant storage combina ZRS na região primária com replicação assíncrona para uma região secundária. Assim, protege contra falha zonal na primária e mantém uma cópia geográfica para um desastre regional.

A região secundária usa redundância local e, em GZRS comum, não fica disponível para leitura direta.$content$,null,null,6),
('7b140000-0000-4000-8000-000000000007','explanation','RA-GZRS: leitura com proteção zonal',
$content$Read-access geo-zone-redundant storage acrescenta leitura da região secundária ao GZRS. A primária continua usando ZRS, a replicação entre regiões continua assíncrona e o endpoint secundário continua sendo de leitura.

RA-GZRS não torna as duas regiões ativas para escrita.$content$,null,null,7),
('7b140000-0000-4000-8000-000000000008','visual_experience','Compare o alcance das cópias',null,null,'76000000-0000-4000-8000-000000000013',8),
('7b140000-0000-4000-8000-000000000009','important','Comparação rápida',
$content$| Opção | Primária | Secundária geográfica | Leitura da secundária |
| --- | --- | --- | --- |
| LRS | Um datacenter | Não | Não se aplica |
| ZRS | Zonas da mesma região | Não | Não se aplica |
| GRS | LRS | Sim, assíncrona | Não, normalmente |
| RA-GRS | LRS | Sim, assíncrona | Sim |
| GZRS | ZRS | Sim, assíncrona | Não, normalmente |
| RA-GZRS | ZRS | Sim, assíncrona | Sim |$content$,null,null,9),
('7b140000-0000-4000-8000-000000000010','important','Replicação não é failover automático da aplicação',
$content$GRS e GZRS mantêm uma cópia geográfica assíncrona, mas isso não significa que a aplicação automaticamente passe a ler e escrever na região secundária. Variantes RA habilitam leitura da secundária; escrita pode depender de failover da conta e a aplicação ainda precisa estar arquitetada e configurada para o cenário.

Como a replicação é assíncrona, uma falha regional pode envolver perda dos dados mais recentes ainda não replicados.$content$,null,null,10),
('7b140000-0000-4000-8000-000000000011','example','Escolha pelo alcance da falha',
$content$Falha de hardware local, com custo como prioridade → LRS pode bastar.

Manter disponibilidade quando uma zona falha, sem cópia em outra região → ZRS.

Manter cópia em outra região e aceitar que a secundária não seja normalmente legível → GRS ou GZRS, conforme a proteção primária necessária.

Precisar consultar a secundária antes de um failover → escolha a variante RA correspondente.$content$,null,null,11),
('7b140000-0000-4000-8000-000000000012','exam_trap','RA significa leitura, não região ativa para escrita',
$content$Não confunda replicação geográfica com acesso ativo-ativo. GRS/GZRS replicam para outra região, mas a secundária não é normalmente legível; RA-GRS/RA-GZRS adicionam leitura, não escrita normal.

Também não confunda ZRS com proteção regional: suas zonas ficam na mesma região.$content$,null,null,12),
('7b140000-0000-4000-8000-000000000013','exam_tip','Leia o requisito em duas etapas',
$content$Primeiro identifique o alcance: datacenter, zona ou região. Depois procure se o cenário exige leitura da secundária. Região + leitura aponta para RA-GRS ou RA-GZRS; a necessidade de proteção zonal na primária separa GZRS de GRS.$content$,null,null,13),
('7b140000-0000-4000-8000-000000000014','summary','Resumo para memória ativa',null,
'{"items":["LRS mantém cópias em um datacenter da região primária.","ZRS replica sincronicamente entre zonas da mesma região.","GRS combina LRS na primária com replicação geográfica assíncrona.","GZRS combina ZRS na primária com replicação geográfica assíncrona.","RA-GRS e RA-GZRS permitem ler a secundária; não habilitam escrita normal nela.","Redundância geográfica não garante troca automática da aplicação nem substitui backup."]}'::jsonb,null,14);

insert into public.lesson_content_blocks(
  id,lesson_id,type,title,content,config,visual_experience_id,display_order,is_published
)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,
  seed.visual_experience_id,seed.display_order,true
from stage_884_block_seed seed
join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000004'
  and lesson.slug='storage-redundancy-options';

update public.flashcards
set front_text='Onde o LRS mantém as cópias dos dados?',
    back_text='Em um único datacenter físico da região primária.',
    hint='Local não significa toda a região.'
where id='70000000-0000-4000-8000-000000000025';

update public.flashcards
set front_text='Como o ZRS aumenta a resiliência dos dados?',
    back_text='Replicando de forma síncrona entre zonas de disponibilidade na região primária.',
    hint='Zonas diferentes, mesma região.'
where id='70000000-0000-4000-8000-000000000026';

update public.flashcards
set front_text='O que o GRS acrescenta ao LRS?',
    back_text='Replicação assíncrona para uma região secundária, sem leitura normal dela.',
    hint='Leitura secundária exige RA-GRS.'
where id='70000000-0000-4000-8000-000000000027';

create temporary table stage_884_flashcard_seed(
  id uuid primary key,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_884_flashcard_seed values
('7e300000-0000-4000-8000-000000000007','Como o GZRS protege os dados?','Usa ZRS na região primária e replica assincronamente para uma região secundária.','Zonal na primária, geográfica depois.',4),
('7e300000-0000-4000-8000-000000000008','O que o prefixo RA indica em RA-GRS e RA-GZRS?','Que a região secundária pode ser lida.','RA = read access.',5),
('7e300000-0000-4000-8000-000000000009','Qual é a diferença principal entre GRS e RA-GRS?','RA-GRS permite ler a região secundária; GRS comum não permite leitura normal dela.','A replicação geográfica existe nos dois.',6),
('7e300000-0000-4000-8000-000000000010','Qual é a diferença principal entre GZRS e RA-GZRS?','RA-GZRS acrescenta leitura da região secundária ao GZRS.','RA não habilita escrita.',7),
('7e300000-0000-4000-8000-000000000011','GRS ou GZRS fazem a aplicação mudar automaticamente de região?','Não. Replicação não substitui failover da conta nem a arquitetura e configuração da aplicação.','Redundância não é troca automática.',8);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_884_flashcard_seed seed
join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000004'
  and lesson.slug='storage-redundancy-options';

create temporary table stage_884_question_seed(
  id uuid primary key,question_text text not null,difficulty text not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_884_question_seed values
('68000000-0000-4000-8000-000000000065','Uma empresa quer cópias em um único datacenter da região primária. Qual opção corresponde ao requisito?','easy','LRS mantém múltiplas cópias em um único datacenter físico da região primária; não oferece proteção zonal ou geográfica.',2),
('68000000-0000-4000-8000-000000000066','Qual opção replica dados entre zonas de disponibilidade da mesma região, sem adicionar uma região secundária?','easy','ZRS replica sincronicamente entre zonas da região primária e não inclui, por si só, uma cópia em outra região.',3),
('68000000-0000-4000-8000-000000000067','Uma aplicação precisa de redundância geográfica baseada em LRS na primária e também deve ler a região secundária. Qual opção é mais alinhada?','medium','RA-GRS combina a estrutura geográfica do GRS com read access ao endpoint secundário; isso não habilita escrita normal nele.',4),
('68000000-0000-4000-8000-000000000068','Uma empresa exige proteção entre zonas na região primária, cópia geográfica e leitura da secundária. Qual opção atende aos três requisitos?','medium','RA-GZRS combina ZRS na primária, replicação geográfica assíncrona e acesso de leitura à região secundária.',5),
('68000000-0000-4000-8000-000000000069','Uma conta usa GZRS. Qual afirmação descreve corretamente a recuperação diante de falha regional?','hard','GZRS replica assincronamente para uma secundária, mas não troca automaticamente toda a aplicação nem oferece escrita normal nessa região. Failover da conta e arquitetura da aplicação podem ser necessários.',6);
insert into public.questions(
  id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order
)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_884_question_seed seed
join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure architecture and services'
join public.topics topic on topic.domain_id=domain.id and topic.id='32000000-0000-4000-8000-000000000004'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug='storage-redundancy-options';

create temporary table stage_884_option_seed(
  id uuid primary key,question_id uuid not null,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_884_option_seed values
('7f100000-0000-4000-8000-000000000277','68000000-0000-4000-8000-000000000065','LRS.',true,'Correta. LRS mantém cópias no mesmo datacenter.',1),
('7f100000-0000-4000-8000-000000000278','68000000-0000-4000-8000-000000000065','ZRS.',false,'ZRS distribui cópias entre zonas.',2),
('7f100000-0000-4000-8000-000000000279','68000000-0000-4000-8000-000000000065','GRS.',false,'GRS adiciona uma região secundária.',3),
('7f100000-0000-4000-8000-000000000280','68000000-0000-4000-8000-000000000065','GZRS.',false,'GZRS usa zonas e outra região.',4),
('7f100000-0000-4000-8000-000000000281','68000000-0000-4000-8000-000000000066','ZRS.',true,'Correta. ZRS usa zonas da região primária.',1),
('7f100000-0000-4000-8000-000000000282','68000000-0000-4000-8000-000000000066','LRS.',false,'LRS fica em um datacenter.',2),
('7f100000-0000-4000-8000-000000000283','68000000-0000-4000-8000-000000000066','GRS.',false,'GRS inclui replicação para outra região.',3),
('7f100000-0000-4000-8000-000000000284','68000000-0000-4000-8000-000000000066','RA-GRS.',false,'RA-GRS inclui outra região e leitura secundária.',4),
('7f100000-0000-4000-8000-000000000285','68000000-0000-4000-8000-000000000067','RA-GRS.',true,'Correta. RA-GRS usa LRS na primária e permite ler a secundária.',1),
('7f100000-0000-4000-8000-000000000286','68000000-0000-4000-8000-000000000067','GRS.',false,'GRS comum não permite leitura normal da secundária.',2),
('7f100000-0000-4000-8000-000000000287','68000000-0000-4000-8000-000000000067','RA-GZRS.',false,'RA-GZRS usa proteção zonal na primária.',3),
('7f100000-0000-4000-8000-000000000288','68000000-0000-4000-8000-000000000067','ZRS.',false,'ZRS não adiciona região secundária.',4),
('7f100000-0000-4000-8000-000000000289','68000000-0000-4000-8000-000000000068','RA-GZRS.',true,'Correta. Ela combina ZRS, geografia e read access.',1),
('7f100000-0000-4000-8000-000000000290','68000000-0000-4000-8000-000000000068','GZRS.',false,'GZRS comum não oferece leitura normal da secundária.',2),
('7f100000-0000-4000-8000-000000000291','68000000-0000-4000-8000-000000000068','RA-GRS.',false,'RA-GRS não usa ZRS na primária.',3),
('7f100000-0000-4000-8000-000000000292','68000000-0000-4000-8000-000000000068','ZRS.',false,'ZRS não adiciona cópia geográfica.',4),
('7f100000-0000-4000-8000-000000000293','68000000-0000-4000-8000-000000000069','A replicação é assíncrona; failover da conta e arquitetura da aplicação podem ser necessários.',true,'Correta. Redundância geográfica não é uma troca automática completa.',1),
('7f100000-0000-4000-8000-000000000294','68000000-0000-4000-8000-000000000069','A aplicação passa automaticamente a escrever na secundária sem configuração.',false,'A secundária não é um destino normal de escrita.',2),
('7f100000-0000-4000-8000-000000000295','68000000-0000-4000-8000-000000000069','A replicação entre regiões é síncrona e não pode perder dados recentes.',false,'A replicação geográfica é assíncrona.',3),
('7f100000-0000-4000-8000-000000000296','68000000-0000-4000-8000-000000000069','GZRS sempre permite leitura da secundária antes do failover.',false,'Essa leitura exige RA-GZRS.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_884_option_seed;

do $$
declare target_lesson_id uuid;
begin
  select id into strict target_lesson_id from public.lessons
  where topic_id='32000000-0000-4000-8000-000000000004'
    and slug='storage-redundancy-options';

  if (select count(*) from public.lesson_content_blocks where lesson_id=target_lesson_id and is_published)<>14
    or (select count(*) from public.visual_experiences where lesson_id=target_lesson_id and is_published)<>1
    or (select count(*) from public.flashcards where lesson_id=target_lesson_id and is_published)<>8
    or (select count(*) from public.questions where lesson_id=target_lesson_id and is_published)<>6 then
    raise exception '8.8.4 final content counts are invalid';
  end if;

  if exists(
    select 1 from public.questions question
    left join public.question_options option on option.question_id=question.id
    where question.lesson_id=target_lesson_id and question.is_published
    group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1
  ) then raise exception '8.8.4 Question options are invalid'; end if;

  if not exists(
    select 1 from public.questions where id='60000000-0000-4000-8000-000000000009'
      and lesson_id=target_lesson_id
  ) or (select count(*) from public.question_options
        where id in ('70000000-0000-4000-8000-000000000033','70000000-0000-4000-8000-000000000034','70000000-0000-4000-8000-000000000035','70000000-0000-4000-8000-000000000036'))<>4 then
    raise exception '8.8.4 did not preserve the historical Question and options';
  end if;
end; $$;

commit;

begin;

do $$
declare target_lesson_id uuid;
begin
  select lesson.id into strict target_lesson_id
  from public.lessons lesson join public.topics topic on topic.id=lesson.topic_id
  join public.domains domain on domain.id=topic.domain_id join public.certifications certification on certification.id=domain.certification_id
  where certification.code='az-900' and domain.title='Describe Azure architecture and services'
    and topic.id='32000000-0000-4000-8000-000000000004' and topic.title='Storage Services'
    and lesson.slug='storage-tiers';
  if exists(select 1 from public.lesson_content_blocks where lesson_id=target_lesson_id)
    or exists(select 1 from public.visual_experiences where lesson_id=target_lesson_id)
    or exists(select 1 from public.flashcards where lesson_id=target_lesson_id)
    or exists(select 1 from public.questions where lesson_id=target_lesson_id) then
    raise exception 'Storage Tiers must be empty before 8.8.3';
  end if;
end; $$;

update public.lessons set estimated_minutes=12
where topic_id='32000000-0000-4000-8000-000000000004' and slug='storage-tiers';

create temporary table stage_883_block_seed(
  id uuid primary key,type text not null,title text,content text,config jsonb,display_order integer not null
) on commit drop;
insert into stage_883_block_seed values
('7b130000-0000-4000-8000-000000000001','explanation','Por que existem access tiers?',
$content$Storage Access Tiers permitem alinhar o armazenamento de blobs à frequência de acesso, à rapidez necessária para recuperação, aos custos relativos de armazenamento e acesso e ao período esperado de retenção.

Em geral, dados acessados com frequência custam relativamente mais para armazenar e menos para acessar. Em tiers mais frios, o armazenamento tende a custar menos, enquanto acesso, recuperação e restrições tendem a aumentar. Não existe um tier universalmente melhor.$content$,null,1),
('7b130000-0000-4000-8000-000000000002','explanation','Hot tier',
$content$Hot é um tier online otimizado para dados acessados ou modificados frequentemente. Os dados permanecem disponíveis para leitura imediata.

Em termos relativos, Hot possui custo de armazenamento maior e custo de acesso/transações menor que tiers mais frios. Imagens carregadas com frequência, arquivos usados diariamente e dados ativos de aplicação são exemplos. Isso não significa que Hot seja sempre o tier mais rápido para qualquer workload.$content$,null,2),
('7b130000-0000-4000-8000-000000000003','explanation','Cool tier',
$content$Cool é um tier online para dados acessados ou modificados com menor frequência, mas que ainda precisam estar disponíveis imediatamente quando solicitados.

O armazenamento tende a custar menos que Hot, enquanto acesso e recuperação tendem a custar mais. Uma retenção mínima recomendada em torno de 30 dias pode aparecer como orientação, não como regra universal de arquitetura.$content$,null,3),
('7b130000-0000-4000-8000-000000000004','explanation','Cold tier',
$content$Cold é um tier online para dados raramente acessados, mas que ainda exigem recuperação rápida quando solicitados. Ele mantém acesso online e é conceitualmente mais frio que Cool.

O armazenamento tende a custar menos que Cool e o acesso tende a custar mais. Uma retenção mínima recomendada em torno de 90 dias é uma orientação, não uma decisão automática.$content$,null,4),
('7b130000-0000-4000-8000-000000000005','explanation','Archive tier',
$content$Archive é um tier offline para dados raramente acessados que toleram maior tempo de recuperação. Ele oferece o menor custo relativo de armazenamento e maior custo ou complexidade de recuperação.

Os dados não ficam disponíveis para leitura imediata: normalmente precisam ser reidratados para um tier online, e a recuperação pode levar horas. Arquivos históricos, retenção de longo prazo e dados de compliance raramente consultados são cenários possíveis.$content$,null,5),
('7b130000-0000-4000-8000-000000000006','important','Comparação Hot, Cool, Cold e Archive',
$content$| Tier | Frequência típica | Disponibilidade | Storage relativo | Acesso/recuperação relativo |
| --- | --- | --- | --- | --- |
| Hot | Frequente | Online/imediata | Maior | Menor |
| Cool | Pouco frequente | Online/imediata | Menor que Hot | Maior que Hot |
| Cold | Rara | Online/rápida | Menor que Cool | Maior que Cool |
| Archive | Muito rara | Offline; requer reidratação | Menor | Maior e mais demorada |

As relações são conceituais. Preços, disponibilidade e suporte dependem da configuração e não precisam ser decorados para AZ-900.$content$,null,6),
('7b130000-0000-4000-8000-000000000007','example','Quatro padrões de acesso',
$content$Dados usados várias vezes por dia → Hot.

Dados acessados ocasionalmente, mas sempre disponíveis online → Cool.

Dados raramente acessados que ainda precisam de recuperação rápida → Cold.

Arquivos regulatórios guardados por anos que podem esperar horas → Archive.$content$,null,7),
('7b130000-0000-4000-8000-000000000008','important','Nota opcional: Smart tier',
$content$Smart tier pode mover automaticamente dados entre Hot, Cool e Cold com base em padrões de uso. Ele é contexto adicional, não objetivo principal desta Lesson e não substitui a capacidade de diferenciar os quatro tiers centrais.$content$,null,8),
('7b130000-0000-4000-8000-000000000009','exam_trap','Cold não é Archive; Archive não é backup',
$content$Cold continua online e permite recuperação rápida. Archive é offline e normalmente exige reidratação antes da leitura.

Archive também não cria automaticamente uma estratégia de backup: é apenas um access tier. Proteção contra exclusão, retenção, cópias e recuperação exigem decisões adicionais fora desta Lesson.$content$,null,9),
('7b130000-0000-4000-8000-000000000010','exam_tip','Procure frequência e tolerância à espera',
$content$Primeiro identifique a frequência de acesso. Depois verifique se os dados precisam permanecer imediatamente disponíveis. Se o cenário tolera horas para reidratação, Archive pode ser adequado; se exige acesso online rápido mesmo sendo raro, considere Cold.$content$,null,10),
('7b130000-0000-4000-8000-000000000011','summary','Resumo para memória ativa',null,
'{"items":["Hot é online para dados acessados frequentemente.","Cool é online para dados pouco frequentes.","Cold é online para dados raros que ainda exigem recuperação rápida.","Archive é offline e normalmente exige reidratação.","Tiers mais frios reduzem storage relativo e aumentam acesso/recuperação.","Archive é access tier, não backup automático."]}'::jsonb,11);

insert into public.lesson_content_blocks(id,lesson_id,type,title,content,config,display_order,is_published)
select seed.id,lesson.id,seed.type,seed.title,seed.content,seed.config,seed.display_order,true
from stage_883_block_seed seed join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000004' and lesson.slug='storage-tiers';

create temporary table stage_883_flashcard_seed(
  id uuid primary key,front_text text not null,back_text text not null,hint text,display_order integer not null
) on commit drop;
insert into stage_883_flashcard_seed values
('7e300000-0000-4000-8000-000000000001','Quando o Hot tier é mais apropriado?','Para dados online acessados ou modificados frequentemente, com storage relativo maior e acesso relativo menor.','Dados ativos.',1),
('7e300000-0000-4000-8000-000000000002','O que caracteriza o Cool tier?','É online para dados pouco frequentes que ainda precisam estar imediatamente disponíveis.','Pouco frequente, ainda online.',2),
('7e300000-0000-4000-8000-000000000003','O que diferencia Cold de Archive?','Cold continua online e oferece recuperação rápida; Archive é offline e normalmente exige reidratação.','Online versus offline.',3),
('7e300000-0000-4000-8000-000000000004','Quando o Archive tier é apropriado?','Para dados muito raramente acessados que toleram horas de recuperação e reidratação.','Longo prazo e espera aceitável.',4),
('7e300000-0000-4000-8000-000000000005','Qual é o trade-off geral dos tiers mais frios?','Storage relativo tende a custar menos, enquanto acesso e recuperação tendem a custar mais.','Storage menor; acesso maior.',5),
('7e300000-0000-4000-8000-000000000006','Archive tier é uma estratégia completa de backup?','Não. Archive é um access tier; backup exige decisões adicionais de proteção, retenção e recuperação.','Tier não é backup.',6);
insert into public.flashcards(id,lesson_id,front_text,back_text,hint,display_order,is_published)
select seed.id,lesson.id,seed.front_text,seed.back_text,seed.hint,seed.display_order,true
from stage_883_flashcard_seed seed join public.lessons lesson
  on lesson.topic_id='32000000-0000-4000-8000-000000000004' and lesson.slug='storage-tiers';

create temporary table stage_883_question_seed(
  id uuid primary key,question_text text not null,difficulty text not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_883_question_seed values
('68000000-0000-4000-8000-000000000060','Qual tier é otimizado para dados online acessados ou modificados frequentemente?','easy','Hot é o tier online voltado a dados ativos, com custo relativo de armazenamento maior e acesso relativo menor.',1),
('68000000-0000-4000-8000-000000000061','Qual tier é offline e normalmente exige reidratação antes da leitura?','easy','Archive é offline; seus dados precisam ser reidratados para acesso, que pode levar horas.',2),
('68000000-0000-4000-8000-000000000062','Arquivos são consultados ocasionalmente, mas devem permanecer disponíveis online de forma imediata. Qual tier é mais alinhado?','medium','Cool é apropriado para dados pouco frequentes que ainda precisam permanecer online e imediatamente disponíveis.',3),
('68000000-0000-4000-8000-000000000063','Dados são acessados muito raramente, mas precisam de recuperação rápida sempre que solicitados. Qual tier é mais alinhado?','medium','Cold atende dados raros que continuam online; Archive não serve quando o cenário não tolera reidratação de horas.',4),
('68000000-0000-4000-8000-000000000064','Uma empresa classifica dados ativos, ocasionais, raros com recuperação rápida e históricos que toleram horas. Qual mapeamento está correto?','hard','Hot, Cool, Cold e Archive correspondem, respectivamente, a esses quatro padrões de acesso e tolerância à recuperação.',5);
insert into public.questions(id,certification_id,domain_id,topic_id,lesson_id,question_text,question_type,difficulty,explanation,is_published,display_order)
select seed.id,certification.id,domain.id,topic.id,lesson.id,seed.question_text,'single_choice',seed.difficulty,seed.explanation,true,seed.display_order
from stage_883_question_seed seed join public.certifications certification on certification.code='az-900'
join public.domains domain on domain.certification_id=certification.id and domain.title='Describe Azure architecture and services'
join public.topics topic on topic.domain_id=domain.id and topic.id='32000000-0000-4000-8000-000000000004'
join public.lessons lesson on lesson.topic_id=topic.id and lesson.slug='storage-tiers';

create temporary table stage_883_option_seed(
  id uuid primary key,question_id uuid not null,option_text text not null,is_correct boolean not null,explanation text not null,display_order integer not null
) on commit drop;
insert into stage_883_option_seed values
('7f100000-0000-4000-8000-000000000257','68000000-0000-4000-8000-000000000060','Hot.',true,'Correta. Hot atende dados online frequentes.',1),
('7f100000-0000-4000-8000-000000000258','68000000-0000-4000-8000-000000000060','Cool.',false,'Cool atende acesso menos frequente.',2),
('7f100000-0000-4000-8000-000000000259','68000000-0000-4000-8000-000000000060','Cold.',false,'Cold atende acesso raro com recuperação rápida.',3),
('7f100000-0000-4000-8000-000000000260','68000000-0000-4000-8000-000000000060','Archive.',false,'Archive é offline.',4),
('7f100000-0000-4000-8000-000000000261','68000000-0000-4000-8000-000000000061','Archive.',true,'Correta. Archive é offline e requer reidratação.',1),
('7f100000-0000-4000-8000-000000000262','68000000-0000-4000-8000-000000000061','Cold.',false,'Cold continua online.',2),
('7f100000-0000-4000-8000-000000000263','68000000-0000-4000-8000-000000000061','Cool.',false,'Cool continua online.',3),
('7f100000-0000-4000-8000-000000000264','68000000-0000-4000-8000-000000000061','Hot.',false,'Hot continua online.',4),
('7f100000-0000-4000-8000-000000000265','68000000-0000-4000-8000-000000000062','Cool.',true,'Correta. O cenário diz pouco frequente e online imediato.',1),
('7f100000-0000-4000-8000-000000000266','68000000-0000-4000-8000-000000000062','Hot.',false,'Hot é voltado a acesso frequente.',2),
('7f100000-0000-4000-8000-000000000267','68000000-0000-4000-8000-000000000062','Cold.',false,'Cold é mais alinhado a acesso raro.',3),
('7f100000-0000-4000-8000-000000000268','68000000-0000-4000-8000-000000000062','Archive.',false,'Archive não oferece leitura imediata.',4),
('7f100000-0000-4000-8000-000000000269','68000000-0000-4000-8000-000000000063','Cold.',true,'Correta. Cold é raro, online e de recuperação rápida.',1),
('7f100000-0000-4000-8000-000000000270','68000000-0000-4000-8000-000000000063','Archive.',false,'Archive pode exigir horas de reidratação.',2),
('7f100000-0000-4000-8000-000000000271','68000000-0000-4000-8000-000000000063','Hot.',false,'Hot é para acesso frequente.',3),
('7f100000-0000-4000-8000-000000000272','68000000-0000-4000-8000-000000000063','Cool.',false,'Cool é para acesso pouco frequente, não o padrão raro descrito.',4),
('7f100000-0000-4000-8000-000000000273','68000000-0000-4000-8000-000000000064','Hot → Cool → Cold → Archive.',true,'Correta. A ordem acompanha menor frequência e maior tolerância à recuperação.',1),
('7f100000-0000-4000-8000-000000000274','68000000-0000-4000-8000-000000000064','Archive → Cold → Cool → Hot.',false,'A ordem está invertida para os padrões descritos.',2),
('7f100000-0000-4000-8000-000000000275','68000000-0000-4000-8000-000000000064','Hot → Archive → Cool → Cold.',false,'Archive não corresponde a dados ocasionais com acesso imediato.',3),
('7f100000-0000-4000-8000-000000000276','68000000-0000-4000-8000-000000000064','Cool → Hot → Archive → Cold.',false,'O mapeamento não respeita frequência e disponibilidade.',4);
insert into public.question_options(id,question_id,option_text,is_correct,explanation,display_order)
select id,question_id,option_text,is_correct,explanation,display_order from stage_883_option_seed;

do $$ declare target_lesson_id uuid;
begin
  select id into strict target_lesson_id from public.lessons
  where topic_id='32000000-0000-4000-8000-000000000004' and slug='storage-tiers';
  if (select count(*) from public.lesson_content_blocks where lesson_id=target_lesson_id and is_published)<>11
    or (select count(*) from public.visual_experiences where lesson_id=target_lesson_id)<>0
    or (select count(*) from public.flashcards where lesson_id=target_lesson_id and is_published)<>6
    or (select count(*) from public.questions where lesson_id=target_lesson_id and is_published)<>5 then
    raise exception '8.8.3 final content counts are invalid'; end if;
  if exists(select 1 from public.questions question left join public.question_options option on option.question_id=question.id
    where question.lesson_id=target_lesson_id and question.is_published group by question.id
    having count(option.id)<>4 or count(option.id) filter(where option.is_correct)<>1) then
    raise exception '8.8.3 Question options are invalid'; end if;
end; $$;

commit;

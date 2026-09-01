begin;

do $$
begin
  if (select count(*) from public.flashcards card
      join public.lessons lesson on lesson.id = card.lesson_id
      join public.topics topic on topic.id = lesson.topic_id
      join public.domains domain on domain.id = topic.domain_id
      join public.certifications certification on certification.id = domain.certification_id
      where certification.code = 'az-900' and card.is_published and lesson.is_published) <> 397 then
    raise exception '13.5.4 expected exactly 397 published AZ-900 Flashcards';
  end if;

  if (select count(*) from public.flashcards where id in (
    '71000000-0000-4000-8000-000000000028',
    '71000000-0000-4000-8000-000000000037',
    '71000000-0000-4000-8000-000000000039',
    '71000000-0000-4000-8000-000000000040',
    '71000000-0000-4000-8000-000000000044',
    '71000000-0000-4000-8000-000000000049',
    '71000000-0000-4000-8000-000000000050',
    '71000000-0000-4000-8000-000000000055',
    '71000000-0000-4000-8000-000000000099'
  )) <> 9 then
    raise exception '13.5.4 could not find all nine Flashcards selected for in-place rewrite';
  end if;
end;
$$;

update public.lesson_content_blocks
set content = content || $addition$

Residência de dados é o requisito de manter dados em uma localização geográfica determinada. Quando esse requisito existe, ele também influencia a escolha do modelo e da localização de nuvem.$addition$
where id = '7a030000-0000-4000-8000-000000000001'
  and lesson_id = (select id from public.lessons where slug = 'choosing-a-cloud-model')
  and position('Residência de dados é o requisito' in content) = 0;

update public.lesson_content_blocks
set content = content || $addition$

Uma VNet é criada em uma Azure Region. Suas subnets permanecem dentro do espaço de endereços dessa VNet regional.$addition$
where id = '7b0e0000-0000-4000-8000-000000000001'
  and lesson_id = (select id from public.lessons where slug = 'virtual-networks-and-subnets')
  and position('Uma VNet é criada em uma Azure Region' in content) = 0;

create temporary table stage_1354_flashcard_rewrite (
  id uuid primary key,
  front_text text not null,
  back_text text not null,
  hint text
) on commit drop;

insert into stage_1354_flashcard_rewrite values
  ('71000000-0000-4000-8000-000000000028',
   'Como a cobrança se relaciona ao uso em serverless?',
   'Ela costuma acompanhar a execução ou o consumo do serviço, em vez de exigir a administração direta de um servidor permanentemente ativo.',
   'Execução ou consumo.'),
  ('71000000-0000-4000-8000-000000000037',
   'O que é elasticidade na computação em nuvem?',
   'É a capacidade de ajustar recursos dinamicamente conforme a demanda aumenta ou diminui.',
   'Demanda e recursos acompanham-se.'),
  ('71000000-0000-4000-8000-000000000039',
   'Como a elasticidade pode reduzir capacidade ociosa?',
   'Ela permite reduzir recursos quando a demanda cai, alinhando capacidade e consumo à necessidade de cada período.',
   'Reduzir depois do pico.'),
  ('71000000-0000-4000-8000-000000000040',
   'Elasticidade significa que todo serviço Azure escala sozinho?',
   'Não. O serviço precisa oferecer o mecanismo apropriado e pode exigir regras ou configurações para ajustar capacidade.',
   'Capacidade não elimina configuração.'),
  ('71000000-0000-4000-8000-000000000044',
   'Recuperar a operação ou os dados após uma falha contribui para Reliability ou Elasticity?',
   'Para Reliability, pois recuperação ajuda o sistema a voltar ao estado esperado depois de uma falha.',
   'Recuperação de falhas.'),
  ('71000000-0000-4000-8000-000000000049',
   'Quais capacidades de segurança da nuvem ajudam a proteger recursos e dados?',
   'Identity, encryption, security services e controls ajudam a controlar acesso, proteger dados e detectar ou bloquear ameaças.',
   'Identidade, criptografia e controles.'),
  ('71000000-0000-4000-8000-000000000050',
   'Ter recursos de segurança do provider torna a solução automaticamente segura?',
   'Não. Eles precisam ser selecionados, configurados, monitorados e usados conforme o Shared Responsibility Model.',
   'O recurso precisa ser usado corretamente.'),
  ('71000000-0000-4000-8000-000000000055',
   'O que Manageability in the cloud permite fazer?',
   'Permite operar o ambiente com capacidades como escala e monitoramento dos recursos.',
   'Operar recursos na nuvem.'),
  ('71000000-0000-4000-8000-000000000099',
   'Como a hierarquia de recursos apoia a governança no Azure?',
   'Ela organiza escopos progressivamente mais específicos e permite atribuir configurações de governança e acesso no nível apropriado.',
   'Organização e amplitude de escopo.');

update public.flashcards card
set front_text = rewrite.front_text,
    back_text = rewrite.back_text,
    hint = rewrite.hint
from stage_1354_flashcard_rewrite rewrite
where card.id = rewrite.id;

do $$
begin
  if (select count(*) from public.flashcards card
      join stage_1354_flashcard_rewrite rewrite on rewrite.id = card.id
      where card.front_text = rewrite.front_text
        and card.back_text = rewrite.back_text
        and card.hint is not distinct from rewrite.hint
        and card.is_published) <> 9 then
    raise exception '13.5.4 did not preserve and rewrite all nine published Flashcards';
  end if;

  if not exists (
    select 1 from public.lesson_content_blocks
    where id = '7a030000-0000-4000-8000-000000000001'
      and content like '%Residência de dados é o requisito%'
  ) or not exists (
    select 1 from public.lesson_content_blocks
    where id = '7b0e0000-0000-4000-8000-000000000001'
      and content like '%Uma VNet é criada em uma Azure Region%'
  ) then
    raise exception '13.5.4 Lesson improvements were not applied';
  end if;
end;
$$;

commit;

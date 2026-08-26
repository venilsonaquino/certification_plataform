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
    and lesson.slug in ('consumption-based-model', 'capex-vs-opex', 'predictability');

  if target_count <> 3 then
    raise exception 'Expected the three existing pricing Lessons, found %', target_count;
  end if;

  if (
    select count(*)
    from public.lesson_content_blocks block
    where block.id in (
      '7a040000-0000-4000-8000-000000000001',
      '7a040000-0000-4000-8000-000000000002',
      '7a040000-0000-4000-8000-000000000006',
      '7a050000-0000-4000-8000-000000000006',
      '7a050000-0000-4000-8000-000000000007',
      '7b050000-0000-4000-8000-000000000001',
      '7b050000-0000-4000-8000-000000000006',
      '7b050000-0000-4000-8000-000000000007'
    )
  ) <> 8 then
    raise exception 'A required pricing block is missing';
  end if;
end;
$$;

set constraints lesson_content_blocks_lesson_order_unique deferred;

update public.lesson_content_blocks block
set display_order = block.display_order + 1
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where block.lesson_id = lesson.id
  and certification.code = 'az-900'
  and domain.title = 'Describe cloud concepts'
  and lesson.slug = 'consumption-based-model'
  and block.display_order >= 2;

update public.lesson_content_blocks
set content = $content$No modelo baseado em consumo, a organização utiliza recursos conforme a necessidade e o custo é relacionado ao que foi consumido, de acordo com as métricas e condições do serviço.

Pay-as-you-go é a forma sob demanda desse conceito: não exige um compromisso antecipado de uso ou capacidade e o custo acompanha o consumo medido. Em vez de comprar toda a capacidade estimada para o maior pico, a organização pode aumentar ou reduzir recursos ao longo do tempo.$content$
where id = '7a040000-0000-4000-8000-000000000001';

insert into public.lesson_content_blocks (
  id, lesson_id, type, title, content, config, display_order, is_published
)
select
  '7a040000-0000-4000-8000-000000000007',
  lesson.id,
  'important',
  'Flexibilidade e previsibilidade nos modelos de preço',
  $content$Consumo sob demanda (pay-as-you-go)
→ maior flexibilidade para aumentar, reduzir ou encerrar recursos
→ o custo acompanha o uso medido e pode variar mais

Compromisso de uso ou capacidade planejada
→ menor flexibilidade durante o período assumido
→ maior previsibilidade porque parte do uso e do custo é planejada

Essas são formas de cobrança ou contratação. Elas não são sinônimos de CapEx e OpEx, que descrevem a natureza financeira do gasto.$content$,
  null,
  2,
  true
from public.lessons lesson
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where certification.code = 'az-900'
  and domain.title = 'Describe cloud concepts'
  and lesson.slug = 'consumption-based-model';

update public.lesson_content_blocks
set type = 'exam_trap',
    title = 'Pricing model não determina custo baixo nem classificação contábil',
    content = $content$Consumption model não significa custo automaticamente baixo: recursos ativos, superdimensionados ou esquecidos continuam gerando cobrança.

OpEx também não significa obrigatoriamente pay-as-you-go. CapEx e OpEx descrevem a natureza do gasto; pricing model descreve como o serviço é cobrado ou contratado. Um compromisso planejado pode continuar sendo uma despesa operacional, conforme contrato e regras contábeis.$content$
where id = '7a040000-0000-4000-8000-000000000002';

update public.lesson_content_blocks
set config = $json${
  "items": [
    "Pay-as-you-go relaciona custo ao consumo medido sem compromisso antecipado de capacidade.",
    "Consumo sob demanda oferece mais flexibilidade, mas o custo pode variar.",
    "Um compromisso planejado troca parte da flexibilidade por maior previsibilidade.",
    "Consumption model não garante custo baixo; recursos mal ajustados continuam gerando cobrança.",
    "Pricing model descreve a cobrança; CapEx e OpEx descrevem a natureza do gasto."
  ]
}$json$::jsonb
where id = '7a040000-0000-4000-8000-000000000006';

update public.lesson_content_blocks
set title = 'Não confunda natureza do gasto e modelo de preço',
    content = $content$CapEx e OpEx descrevem a natureza financeira do gasto: investimento antecipado em ativos ou despesa operacional recorrente. Pricing model descreve como um serviço é cobrado ou contratado.

Por isso, OpEx não é obrigatoriamente pay-as-you-go, e um compromisso de uso não se transforma automaticamente em CapEx. Em situações reais, a classificação depende do contrato e das regras contábeis da organização.$content$
where id = '7a050000-0000-4000-8000-000000000006';

update public.lesson_content_blocks
set config = $json${
  "items": [
    "CapEx é investimento antecipado em ativos.",
    "OpEx é despesa operacional recorrente.",
    "Pricing model descreve como o serviço é cobrado ou contratado.",
    "OpEx não é sinônimo obrigatório de pay-as-you-go.",
    "Um compromisso de uso pode aumentar previsibilidade sem definir sozinho a classificação contábil.",
    "A classificação final depende do contrato e do contexto da organização."
  ]
}$json$::jsonb
where id = '7a050000-0000-4000-8000-000000000007';

update public.lesson_content_blocks
set content = $content$Predictability ajuda uma organização a estimar e controlar o comportamento técnico e financeiro de uma solução.

Performance predictability usa medições, padrões de carga, dimensionamento e opções de escala para planejar capacidade. Cost predictability usa consumo observado e modelos de preço para estimar gastos. Pay-as-you-go preserva flexibilidade e acompanha o uso; um compromisso de uso ou capacidade planejada reduz parte dessa flexibilidade em troca de maior previsibilidade.$content$
where id = '7b050000-0000-4000-8000-000000000001';

update public.lesson_content_blocks
set content = $content$Predictability não significa custo sempre igual nem automaticamente menor. Pay-as-you-go pode variar com a demanda, enquanto um compromisso planejado pode tornar parte do custo mais previsível, mas reduz flexibilidade. Em ambos os casos, dimensionamento e acompanhamento continuam necessários.$content$
where id = '7b050000-0000-4000-8000-000000000006';

update public.lesson_content_blocks
set config = $json${
  "items": [
    "Predictability se aplica a performance e cost.",
    "Monitoramento e dimensionamento fornecem dados para planejar.",
    "Pay-as-you-go oferece flexibilidade e custo relacionado ao uso.",
    "Compromisso planejado reduz flexibilidade e aumenta previsibilidade.",
    "Previsibilidade reduz incerteza, mas não garante custo fixo ou baixo."
  ]
}$json$::jsonb
where id = '7b050000-0000-4000-8000-000000000007';

update public.lessons lesson
set estimated_minutes = 10
from public.topics topic
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification on certification.id = domain.certification_id
where lesson.topic_id = topic.id
  and certification.code = 'az-900'
  and domain.title = 'Describe cloud concepts'
  and lesson.slug = 'consumption-based-model';

update public.flashcards flashcard
set front_text = 'Como pay-as-you-go difere de um compromisso de uso ou capacidade?',
    back_text = 'Pay-as-you-go acompanha o consumo e oferece mais flexibilidade; um compromisso planejado reduz flexibilidade e aumenta previsibilidade.',
    hint = 'Compare flexibilidade e previsibilidade.'
from public.lessons lesson
where flashcard.lesson_id = lesson.id
  and flashcard.id = '71000000-0000-4000-8000-000000000018'
  and lesson.slug = 'consumption-based-model';

update public.flashcards flashcard
set front_text = 'CapEx/OpEx e pricing model descrevem a mesma coisa?',
    back_text = 'Não. CapEx/OpEx descreve a natureza do gasto; pricing model descreve como o serviço é cobrado ou contratado.',
    hint = 'OpEx não é obrigatoriamente pay-as-you-go.'
from public.lessons lesson
where flashcard.lesson_id = lesson.id
  and flashcard.id = '71000000-0000-4000-8000-000000000023'
  and lesson.slug = 'capex-vs-opex';

update public.questions question
set question_text = 'Uma equipe compara dois modelos para a mesma carga: pay-as-you-go sem compromisso antecipado e um compromisso de uso ou capacidade planejada. Qual análise está correta?',
    difficulty = 'medium',
    explanation = 'Pay-as-you-go prioriza flexibilidade e relaciona o custo ao consumo medido. Um compromisso planejado reduz parte da flexibilidade e aumenta a previsibilidade. Essa escolha de pricing não define sozinha se o gasto é CapEx ou OpEx.'
from public.lessons lesson
where question.lesson_id = lesson.id
  and question.id = '62000000-0000-4000-8000-000000000048'
  and lesson.slug = 'consumption-based-model';

update public.question_options
set option_text = case id
      when '73000000-0000-4000-8000-000000000189' then 'Pay-as-you-go é sempre o menor custo e o compromisso planejado é sempre CapEx.'
      when '73000000-0000-4000-8000-000000000190' then 'O compromisso planejado elimina as responsabilidades do cliente sobre uso e dimensionamento.'
      when '73000000-0000-4000-8000-000000000191' then 'Os dois modelos oferecem flexibilidade e previsibilidade idênticas.'
      when '73000000-0000-4000-8000-000000000192' then 'Pay-as-you-go tende a oferecer mais flexibilidade; o compromisso planejado tende a oferecer mais previsibilidade.'
    end,
    is_correct = id = '73000000-0000-4000-8000-000000000192',
    explanation = case id
      when '73000000-0000-4000-8000-000000000189' then 'Incorreta. Consumption não garante menor custo, e compromisso não determina sozinho CapEx.'
      when '73000000-0000-4000-8000-000000000190' then 'Incorreta. Planejamento e responsabilidades do cliente continuam existindo.'
      when '73000000-0000-4000-8000-000000000191' then 'Incorreta. Há uma troca entre flexibilidade e previsibilidade.'
      when '73000000-0000-4000-8000-000000000192' then 'Correta. O consumo sob demanda prioriza flexibilidade; o compromisso planejado aumenta previsibilidade.'
    end
where question_id = '62000000-0000-4000-8000-000000000048';

do $$
begin
  if (
    select array_agg(block.type order by block.display_order)
    from public.lesson_content_blocks block
    join public.lessons lesson on lesson.id = block.lesson_id
    where lesson.slug = 'consumption-based-model'
      and block.is_published
  ) is distinct from array[
    'explanation', 'important', 'exam_trap', 'example',
    'dotnet_example', 'exam_tip', 'summary'
  ]::text[] then
    raise exception 'Consumption pricing blocks are incomplete or out of order';
  end if;

  if not exists (
    select 1
    from public.lesson_content_blocks
    where id = '7a040000-0000-4000-8000-000000000007'
      and content ilike '%pay-as-you-go%'
      and content ilike '%compromisso%'
      and content ilike '%flexibilidade%'
      and content ilike '%previsibilidade%'
  ) or not exists (
    select 1
    from public.lesson_content_blocks
    where id = '7a050000-0000-4000-8000-000000000006'
      and content ilike '%natureza%gasto%'
      and content ilike '%pricing model%'
  ) then
    raise exception 'The required cloud pricing comparison or accounting distinction is missing';
  end if;

  if not exists (
    select 1 from public.flashcards
    where id = '71000000-0000-4000-8000-000000000018'
      and front_text ilike '%pay-as-you-go%compromisso%'
  ) or not exists (
    select 1 from public.flashcards
    where id = '71000000-0000-4000-8000-000000000023'
      and back_text ilike '%natureza do gasto%'
  ) then
    raise exception 'The pricing Flashcard reinforcement is missing';
  end if;

  if not exists (
    select 1
    from public.questions question
    join public.question_options option on option.question_id = question.id
    where question.id = '62000000-0000-4000-8000-000000000048'
      and question.question_text ilike '%pay-as-you-go%compromisso%'
    group by question.id
    having count(option.id) = 4
      and count(option.id) filter (where option.is_correct) = 1
  ) then
    raise exception 'The pricing scenario Question is invalid';
  end if;

  if exists (
    select 1
    from public.flashcard_reviews review
    left join public.flashcards flashcard on flashcard.id = review.flashcard_id
    where flashcard.id is null
  ) or exists (
    select 1
    from public.user_flashcard_progress progress
    left join public.flashcards flashcard on flashcard.id = progress.flashcard_id
    where flashcard.id is null
  ) or exists (
    select 1
    from public.quiz_attempt_questions attempt_question
    left join public.questions question on question.id = attempt_question.question_id
    where question.id is null
  ) then
    raise exception 'A practice history reference was lost';
  end if;
end;
$$;

commit;

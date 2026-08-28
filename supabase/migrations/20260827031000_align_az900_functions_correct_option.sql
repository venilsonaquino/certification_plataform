begin;

do $$
begin
  if not exists (
    select 1
    from public.question_options option
    where option.id = '74000000-0000-4000-8000-000000000443'
      and option.question_id = '63000000-0000-4000-8000-000000000111'
      and option.is_correct
  ) then
    raise exception 'The preserved correct option for Azure Functions Question 111 was not found';
  end if;
end;
$$;

update public.question_options
set option_text = 'Serviço serverless que executa código em resposta a eventos.',
  explanation = 'Correta. Functions combina código, triggers e infraestrutura abstraída.'
where id = '74000000-0000-4000-8000-000000000443';

update public.question_options
set option_text = 'Plataforma de virtualização de desktops para usuários finais.',
  explanation = 'Incorreta. Isso se aproxima de Azure Virtual Desktop.'
where id = '74000000-0000-4000-8000-000000000441';

do $$
begin
  if not exists (
    select 1
    from public.question_options option
    where option.id = '74000000-0000-4000-8000-000000000443'
      and option.is_correct
      and option.option_text ilike '%serverless%eventos%'
  ) or not exists (
    select 1
    from public.question_options option
    where option.id = '74000000-0000-4000-8000-000000000441'
      and not option.is_correct
      and option.option_text ilike '%desktops%'
  ) then
    raise exception 'Azure Functions Question 111 correct-option alignment failed';
  end if;
end;
$$;

commit;

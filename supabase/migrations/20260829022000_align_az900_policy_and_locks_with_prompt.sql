begin;

do $$
begin
  if (select count(*) from public.lesson_content_blocks
      where id in('7b240000-0000-4000-8000-000000000005','7b240000-0000-4000-8000-000000000023'))<>2 then
    raise exception '9.5.3 alignment expected the two existing Content Blocks';
  end if;
end; $$;

update public.lesson_content_blocks
set content=$c$A empresa determina que somente **West Europe** e **North Europe** podem receber novos recursos. Uma Azure Policy avalia a localização solicitada.

- Região permitida → recurso compliant.
- Região não permitida com `audit` → recurso identificado como non-compliant.
- Região não permitida com `deny` → criação ou alteração pode ser bloqueada.

O mesmo padrão conceitual pode avaliar outros requisitos organizacionais, sem exigir implementação de Policy nesta Lesson.$c$
where id='7b240000-0000-4000-8000-000000000005';

update public.lesson_content_blocks
set title='Locks têm herança; Tags não automaticamente',
  content=$c$Resource Locks aplicados a uma Subscription ou Resource Group podem ser herdados pelos recursos abaixo do scope. Tags aplicadas ao scope pai **não são automaticamente herdadas** pelos recursos filhos.

Para a prova:

- impedir somente exclusão → `CanNotDelete`;
- impedir também alterações administrativas → `ReadOnly`;
- classificar um recurso → Tag;
- recuperar dados perdidos ou corrompidos → backup.$c$
where id='7b240000-0000-4000-8000-000000000023';

do $$
begin
  if not exists(select 1 from public.lesson_content_blocks where id='7b240000-0000-4000-8000-000000000005'
      and content ~* 'West Europe' and content ~* 'North Europe' and content ~* 'compliant' and content ~* 'non-compliant')
    or not exists(select 1 from public.lesson_content_blocks where id='7b240000-0000-4000-8000-000000000023'
      and type='exam_tip' and content ~* 'Tags' and content ~* 'não são automaticamente herdadas'
      and content ~* 'CanNotDelete' and content ~* 'ReadOnly') then
    raise exception '9.5.3 alignment validation failed';
  end if;
end; $$;

commit;

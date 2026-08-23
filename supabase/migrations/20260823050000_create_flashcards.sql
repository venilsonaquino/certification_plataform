begin;

create table public.flashcards (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  front_text text not null,
  back_text text not null,
  hint text,
  display_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint flashcards_front_text_check check (length(btrim(front_text)) > 0),
  constraint flashcards_back_text_check check (length(btrim(back_text)) > 0),
  constraint flashcards_hint_check check (hint is null or length(btrim(hint)) > 0),
  constraint flashcards_display_order_check check (display_order >= 0),
  constraint flashcards_lesson_display_order_unique unique (lesson_id, display_order)
);

create index flashcards_published_lesson_order_idx
  on public.flashcards (lesson_id, display_order)
  where is_published = true;

create trigger flashcards_set_updated_at
before update on public.flashcards
for each row execute function public.set_updated_at();

alter table public.flashcards enable row level security;

create policy "Authenticated users can read published flashcards"
on public.flashcards for select
to authenticated
using (is_published = true);

revoke all on table public.flashcards from anon, authenticated;
grant select on table public.flashcards to authenticated;

create temporary table flashcard_seed (
  id uuid primary key,
  lesson_slug text not null,
  front_text text not null,
  back_text text not null,
  hint text,
  display_order integer not null
) on commit drop;

insert into flashcard_seed values
  ('70000000-0000-4000-8000-000000000001', 'what-is-cloud-computing', 'O que é computação em nuvem?', 'É a entrega sob demanda de recursos de TI, como computação, armazenamento e rede, pela internet.', 'Pense em como os recursos são acessados e provisionados.', 1),
  ('70000000-0000-4000-8000-000000000002', 'what-is-cloud-computing', 'O que significa consumir recursos de nuvem sob demanda?', 'Significa provisionar recursos quando necessário, sem comprar antecipadamente toda a infraestrutura.', null, 2),
  ('70000000-0000-4000-8000-000000000003', 'what-is-cloud-computing', 'Qual característica da nuvem relaciona custo ao uso real?', 'A cobrança conforme o uso, também chamada de modelo baseado em consumo.', 'Compare com a compra antecipada de servidores.', 3),

  ('70000000-0000-4000-8000-000000000004', 'shared-responsibility-model', 'Quem protege a infraestrutura física no modelo de responsabilidade compartilhada?', 'O provedor de nuvem, como a Microsoft.', null, 1),
  ('70000000-0000-4000-8000-000000000005', 'shared-responsibility-model', 'Qual responsabilidade permanece com o cliente em qualquer modelo de serviço?', 'Proteger e governar seus dados, identidades e acessos.', 'Ela não desaparece ao migrar de IaaS para SaaS.', 2),
  ('70000000-0000-4000-8000-000000000006', 'shared-responsibility-model', 'Como a responsabilidade do cliente muda de IaaS para SaaS?', 'Ela diminui, pois o provedor passa a administrar mais camadas da solução.', null, 3),

  ('70000000-0000-4000-8000-000000000007', 'public-private-hybrid-cloud', 'O que caracteriza uma nuvem pública?', 'Recursos de um provedor são oferecidos pela internet sobre infraestrutura compartilhada entre clientes.', null, 1),
  ('70000000-0000-4000-8000-000000000008', 'public-private-hybrid-cloud', 'O que caracteriza uma nuvem privada?', 'Infraestrutura de nuvem dedicada a uma única organização.', null, 2),
  ('70000000-0000-4000-8000-000000000009', 'public-private-hybrid-cloud', 'Quando um ambiente é considerado nuvem híbrida?', 'Quando integra nuvem pública e infraestrutura privada para que trabalhem em conjunto.', 'Imagine uma aplicação no Azure conectada a dados no datacenter.', 3),

  ('70000000-0000-4000-8000-000000000010', 'choosing-iaas-paas-saas', 'Qual modelo de serviço oferece mais controle sobre o sistema operacional?', 'IaaS, pois o cliente administra o sistema operacional e o software instalado.', 'Pense no modelo representado por uma máquina virtual.', 1),
  ('70000000-0000-4000-8000-000000000011', 'choosing-iaas-paas-saas', 'Em qual modelo o desenvolvedor se concentra na aplicação e nos dados?', 'PaaS, porque o provedor administra a infraestrutura, o sistema operacional e o runtime.', null, 2),
  ('70000000-0000-4000-8000-000000000012', 'choosing-iaas-paas-saas', 'O que distingue SaaS de IaaS e PaaS?', 'SaaS entrega uma aplicação pronta para uso, administrada principalmente pelo provedor.', 'Microsoft 365 é um exemplo.', 3),

  ('70000000-0000-4000-8000-000000000013', 'azure-regions', 'O que é uma Azure Region?', 'É uma área geográfica que contém um ou mais datacenters próximos do Azure.', null, 1),
  ('70000000-0000-4000-8000-000000000014', 'azure-regions', 'Por que a escolha da região pode afetar a latência?', 'Porque a distância entre usuários e datacenters influencia o tempo de comunicação.', 'Pense na localização física dos usuários.', 2),
  ('70000000-0000-4000-8000-000000000015', 'azure-regions', 'Quais fatores devem ser considerados ao escolher uma região?', 'Latência, disponibilidade de serviços, requisitos de residência de dados e custo.', null, 3),

  ('70000000-0000-4000-8000-000000000016', 'availability-zones', 'O que é uma Availability Zone?', 'É um local fisicamente separado dentro de uma região, com energia, rede e refrigeração independentes.', null, 1),
  ('70000000-0000-4000-8000-000000000017', 'availability-zones', 'Qual problema as Availability Zones ajudam a reduzir?', 'O impacto da falha de um datacenter ou de uma parte isolada da região.', 'Pense em falhas compartilhadas de energia ou rede.', 2),
  ('70000000-0000-4000-8000-000000000018', 'availability-zones', 'Qual é a diferença entre Region e Availability Zone?', 'Region é uma área geográfica; Availability Zone é uma separação física dentro de uma região compatível.', null, 3),

  ('70000000-0000-4000-8000-000000000019', 'resources-and-resource-groups', 'O que é um recurso do Azure?', 'É uma instância de serviço criada e gerenciada no Azure, como uma VM ou uma storage account.', null, 1),
  ('70000000-0000-4000-8000-000000000020', 'resources-and-resource-groups', 'O que é um Resource Group?', 'É um contêiner lógico usado para organizar e administrar recursos relacionados.', null, 2),
  ('70000000-0000-4000-8000-000000000021', 'resources-and-resource-groups', 'Um recurso pode pertencer simultaneamente a vários Resource Groups?', 'Não. Um recurso pertence a apenas um Resource Group por vez.', 'Pense no grupo como o contêiner administrativo atual do recurso.', 3),

  ('70000000-0000-4000-8000-000000000022', 'virtual-networks-and-subnets', 'O que é uma Azure Virtual Network (VNet)?', 'É uma rede privada lógica no Azure que define um espaço de endereços para recursos.', null, 1),
  ('70000000-0000-4000-8000-000000000023', 'virtual-networks-and-subnets', 'O que é uma subnet?', 'É uma divisão do espaço de endereços de uma VNet usada para organizar e isolar recursos.', 'Ela existe dentro de uma rede maior.', 2),
  ('70000000-0000-4000-8000-000000000024', 'virtual-networks-and-subnets', 'Qual é a relação entre VNet e subnet?', 'A VNet define a rede e seu espaço de endereços; as subnets dividem esse espaço internamente.', null, 3),

  ('70000000-0000-4000-8000-000000000025', 'storage-redundancy-options', 'Onde o LRS mantém suas cópias dos dados?', 'Em um único datacenter da região primária.', 'A sigla começa com Local.', 1),
  ('70000000-0000-4000-8000-000000000026', 'storage-redundancy-options', 'Como o ZRS aumenta a resiliência dos dados?', 'Distribuindo cópias entre diferentes zonas de disponibilidade na região primária.', null, 2),
  ('70000000-0000-4000-8000-000000000027', 'storage-redundancy-options', 'O que o GRS acrescenta à redundância local?', 'Replicação assíncrona dos dados para uma região secundária.', 'A letra G indica alcance geográfico.', 3),

  ('70000000-0000-4000-8000-000000000028', 'entra-id-and-domain-services', 'Qual é a função principal do Microsoft Entra ID?', 'Gerenciar identidades e controlar o acesso a aplicações e recursos.', null, 1),
  ('70000000-0000-4000-8000-000000000029', 'entra-id-and-domain-services', 'Microsoft Entra ID é o mesmo que Active Directory Domain Services tradicional?', 'Não. Entra ID é um serviço de identidade em nuvem; AD DS tradicional usa recursos de domínio como controladores e LDAP.', 'Compare identidade em nuvem com um domínio Windows tradicional.', 2),
  ('70000000-0000-4000-8000-000000000030', 'entra-id-and-domain-services', 'Quando usar Microsoft Entra Domain Services?', 'Quando aplicações precisam de recursos de domínio gerenciados, como ingresso em domínio, LDAP ou Kerberos, sem administrar controladores.', null, 3),

  ('70000000-0000-4000-8000-000000000031', 'azure-rbac', 'O que o Azure RBAC controla?', 'Quem pode executar quais ações e em qual escopo no Azure.', null, 1),
  ('70000000-0000-4000-8000-000000000032', 'azure-rbac', 'Quais são os principais elementos de uma atribuição RBAC?', 'Uma identidade, uma definição de função e um escopo.', 'Pense em quem, pode fazer o quê, onde.', 2),
  ('70000000-0000-4000-8000-000000000033', 'azure-rbac', 'O que acontece com uma função RBAC atribuída em um Resource Group?', 'A permissão se aplica ao grupo e, em geral, é herdada pelos recursos dentro dele.', null, 3);

insert into public.flashcards (
  id, lesson_id, front_text, back_text, hint, display_order, is_published
)
select
  seed.id,
  lessons.id,
  seed.front_text,
  seed.back_text,
  seed.hint,
  seed.display_order,
  true
from flashcard_seed seed
join public.lessons lessons on lessons.slug = seed.lesson_slug
join public.topics topics on topics.id = lessons.topic_id
join public.domains domains on domains.id = topics.domain_id
join public.certifications certifications on certifications.id = domains.certification_id
where certifications.code = 'az-900'
on conflict (id) do update set
  lesson_id = excluded.lesson_id,
  front_text = excluded.front_text,
  back_text = excluded.back_text,
  hint = excluded.hint,
  display_order = excluded.display_order,
  is_published = excluded.is_published;

commit;

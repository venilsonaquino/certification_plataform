begin;

alter table public.domains
  add constraint domains_id_certification_unique unique (id, certification_id);

alter table public.topics
  add constraint topics_id_domain_unique unique (id, domain_id);

alter table public.lessons
  add constraint lessons_id_topic_unique unique (id, topic_id);

create table public.questions (
  id uuid primary key default gen_random_uuid(),
  certification_id uuid not null references public.certifications(id) on delete cascade,
  domain_id uuid,
  topic_id uuid,
  lesson_id uuid,
  question_text text not null,
  question_type text not null default 'single_choice',
  difficulty text,
  explanation text,
  is_published boolean not null default false,
  display_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint questions_domain_certification_fkey
    foreign key (domain_id, certification_id)
    references public.domains (id, certification_id),
  constraint questions_topic_domain_fkey
    foreign key (topic_id, domain_id)
    references public.topics (id, domain_id),
  constraint questions_lesson_topic_fkey
    foreign key (lesson_id, topic_id)
    references public.lessons (id, topic_id),
  constraint questions_hierarchy_check check (
    (topic_id is null or domain_id is not null)
    and (lesson_id is null or topic_id is not null)
  ),
  constraint questions_text_not_blank_check check (btrim(question_text) <> ''),
  constraint questions_type_check check (question_type in ('single_choice')),
  constraint questions_difficulty_check
    check (difficulty is null or difficulty in ('easy', 'medium', 'hard')),
  constraint questions_display_order_check check (display_order >= 0)
);

create table public.question_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions(id) on delete cascade,
  option_text text not null,
  is_correct boolean not null default false,
  explanation text,
  display_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint question_options_question_order_unique unique (question_id, display_order),
  constraint question_options_text_not_blank_check check (btrim(option_text) <> ''),
  constraint question_options_display_order_check check (display_order >= 0)
);

create unique index question_options_one_correct_idx
  on public.question_options (question_id)
  where is_correct = true;

create index questions_certification_published_order_idx
  on public.questions (certification_id, display_order)
  where is_published = true;

create index questions_domain_published_order_idx
  on public.questions (domain_id, display_order)
  where is_published = true and domain_id is not null;

create index questions_topic_published_order_idx
  on public.questions (topic_id, display_order)
  where is_published = true and topic_id is not null;

create index questions_lesson_published_order_idx
  on public.questions (lesson_id, display_order)
  where is_published = true and lesson_id is not null;

create trigger questions_set_updated_at
before update on public.questions
for each row execute function public.set_updated_at();

create trigger question_options_set_updated_at
before update on public.question_options
for each row execute function public.set_updated_at();

alter table public.questions enable row level security;
alter table public.question_options enable row level security;

create policy "Authenticated users can read published questions"
on public.questions for select
to authenticated
using (is_published = true);

create policy "Authenticated users can read options from published questions"
on public.question_options for select
to authenticated
using (
  exists (
    select 1
    from public.questions
    where questions.id = question_options.question_id
      and questions.is_published = true
  )
);

revoke all on table public.questions from anon, authenticated;
revoke all on table public.question_options from anon, authenticated;
grant select on table public.questions to authenticated;
grant select on table public.question_options to authenticated;

with question_seed (
  id, lesson_slug, question_text, difficulty, explanation, display_order
) as (
  values
    (
      '60000000-0000-4000-8000-000000000001'::uuid,
      'what-is-cloud-computing',
      'Uma empresa precisa aumentar a capacidade de uma aplicação durante picos sazonais e reduzi-la depois, pagando apenas pelos recursos utilizados. Qual característica da nuvem atende melhor a esse cenário?',
      'medium',
      'Elasticidade permite ajustar recursos conforme a demanda cresce ou diminui. Ela combina capacidade variável com o modelo de consumo, evitando manter infraestrutura ociosa durante períodos de menor uso.',
      1
    ),
    (
      '60000000-0000-4000-8000-000000000002'::uuid,
      'shared-responsibility-model',
      'Uma aplicação usa Azure SQL Database. Qual responsabilidade continua pertencendo ao cliente no modelo de responsabilidade compartilhada?',
      'medium',
      'No Azure SQL Database, a Microsoft administra a infraestrutura física, o sistema operacional e grande parte da plataforma. O cliente continua responsável por seus dados, identidades, permissões e configurações da aplicação.',
      1
    ),
    (
      '60000000-0000-4000-8000-000000000003'::uuid,
      'platform-as-a-service',
      'Uma equipe quer publicar uma API sem administrar o sistema operacional nem aplicar patches no servidor. Qual modelo de serviço é o mais adequado?',
      'easy',
      'PaaS fornece uma plataforma gerenciada para execução da aplicação. O provedor administra infraestrutura, sistema operacional e runtime, enquanto a equipe se concentra no código e nos dados.',
      1
    ),
    (
      '60000000-0000-4000-8000-000000000004'::uuid,
      'azure-regions',
      'Ao escolher uma região do Azure para uma nova carga de trabalho, quais fatores devem ser avaliados em conjunto?',
      'medium',
      'A escolha de região pode afetar latência, requisitos de residência dos dados, disponibilidade dos serviços e custo. Esses fatores devem ser avaliados conforme os requisitos técnicos e regulatórios da solução.',
      1
    ),
    (
      '60000000-0000-4000-8000-000000000005'::uuid,
      'availability-zones',
      'Uma aplicação precisa permanecer disponível mesmo se ocorrer uma falha de energia em parte da infraestrutura de uma região compatível. Qual abordagem é mais apropriada?',
      'medium',
      'Zonas de disponibilidade são locais fisicamente separados dentro de uma região, com energia, rede e refrigeração independentes. Distribuir instâncias entre zonas reduz o impacto de uma falha localizada.',
      1
    ),
    (
      '60000000-0000-4000-8000-000000000006'::uuid,
      'resources-and-resource-groups',
      'Uma equipe deseja aplicar permissões e acompanhar custos de vários recursos que pertencem à mesma solução. Qual organização facilita esse gerenciamento conjunto?',
      'easy',
      'Um resource group é um contêiner lógico para recursos relacionados. Ele fornece um escopo comum para acesso, políticas, monitoramento e análise de custos, sem exigir que os recursos sejam do mesmo tipo.',
      1
    ),
    (
      '60000000-0000-4000-8000-000000000007'::uuid,
      'azure-virtual-machines',
      'Uma aplicação é hospedada em uma Azure Virtual Machine. Qual tarefa normalmente permanece sob responsabilidade do cliente?',
      'medium',
      'Azure Virtual Machines são IaaS. A Microsoft administra datacenter, hardware e virtualização, mas o cliente administra o sistema operacional convidado, patches, aplicações e configurações internas da VM.',
      1
    ),
    (
      '60000000-0000-4000-8000-000000000008'::uuid,
      'azure-app-service',
      'Qual característica diferencia o Azure App Service de hospedar a mesma aplicação diretamente em uma máquina virtual?',
      'medium',
      'Azure App Service é uma oferta PaaS que gerencia infraestrutura, sistema operacional e runtime. Em uma VM, o cliente mantém maior controle, mas também assume mais tarefas operacionais.',
      1
    ),
    (
      '60000000-0000-4000-8000-000000000009'::uuid,
      'storage-redundancy-options',
      'Uma organização precisa manter cópias síncronas dos dados em diferentes zonas da região primária e também replicá-los para uma região secundária. Qual opção de redundância atende ao requisito?',
      'hard',
      'GZRS combina replicação entre zonas na região primária com replicação geográfica para uma região secundária. Isso oferece proteção contra falhas zonais e amplia a resiliência contra desastres regionais.',
      1
    ),
    (
      '60000000-0000-4000-8000-000000000010'::uuid,
      'azure-rbac',
      'Um analista deve visualizar recursos de um resource group, mas não pode criar, alterar ou excluir recursos. Qual abordagem segue o princípio do menor privilégio?',
      'medium',
      'Azure RBAC permite atribuir uma função a uma identidade em um escopo. A função Reader no resource group concede leitura sem permissões de modificação, atendendo ao princípio do menor privilégio.',
      1
    )
)
insert into public.questions (
  id,
  certification_id,
  domain_id,
  topic_id,
  lesson_id,
  question_text,
  question_type,
  difficulty,
  explanation,
  is_published,
  display_order
)
select
  seed.id,
  certification.id,
  domain.id,
  topic.id,
  lesson.id,
  seed.question_text,
  'single_choice',
  seed.difficulty,
  seed.explanation,
  true,
  seed.display_order
from question_seed seed
join public.lessons lesson on lesson.slug = seed.lesson_slug
join public.topics topic on topic.id = lesson.topic_id
join public.domains domain on domain.id = topic.domain_id
join public.certifications certification
  on certification.id = domain.certification_id
  and certification.code = 'az-900'
on conflict (id) do update set
  certification_id = excluded.certification_id,
  domain_id = excluded.domain_id,
  topic_id = excluded.topic_id,
  lesson_id = excluded.lesson_id,
  question_text = excluded.question_text,
  question_type = excluded.question_type,
  difficulty = excluded.difficulty,
  explanation = excluded.explanation,
  is_published = excluded.is_published,
  display_order = excluded.display_order;

insert into public.question_options (
  id, question_id, option_text, is_correct, explanation, display_order
)
values
  ('70000000-0000-4000-8000-000000000001', '60000000-0000-4000-8000-000000000001', 'Elasticidade', true, 'Correta: ajusta recursos para acompanhar variações de demanda.', 1),
  ('70000000-0000-4000-8000-000000000002', '60000000-0000-4000-8000-000000000001', 'Alta disponibilidade', false, 'Alta disponibilidade busca reduzir interrupções, mas não descreve o ajuste de capacidade conforme a demanda.', 2),
  ('70000000-0000-4000-8000-000000000003', '60000000-0000-4000-8000-000000000001', 'Governança', false, 'Governança padroniza e controla recursos; não representa o ajuste automático de capacidade.', 3),
  ('70000000-0000-4000-8000-000000000004', '60000000-0000-4000-8000-000000000001', 'Previsibilidade', false, 'Previsibilidade auxilia o planejamento, mas não é o mecanismo de expansão e redução da capacidade.', 4),

  ('70000000-0000-4000-8000-000000000005', '60000000-0000-4000-8000-000000000002', 'Gerenciar usuários, permissões e os dados da aplicação', true, 'Correta: identidades, acessos e dados continuam sob responsabilidade do cliente.', 1),
  ('70000000-0000-4000-8000-000000000006', '60000000-0000-4000-8000-000000000002', 'Substituir discos físicos defeituosos', false, 'O hardware físico é administrado pela Microsoft.', 2),
  ('70000000-0000-4000-8000-000000000007', '60000000-0000-4000-8000-000000000002', 'Manter a refrigeração do datacenter', false, 'Instalações e refrigeração pertencem à responsabilidade do provedor.', 3),
  ('70000000-0000-4000-8000-000000000008', '60000000-0000-4000-8000-000000000002', 'Atualizar o hipervisor da plataforma', false, 'O hipervisor faz parte da infraestrutura gerenciada pela Microsoft.', 4),

  ('70000000-0000-4000-8000-000000000009', '60000000-0000-4000-8000-000000000003', 'Platform as a Service (PaaS)', true, 'Correta: PaaS abstrai a manutenção do sistema operacional e do runtime.', 1),
  ('70000000-0000-4000-8000-000000000010', '60000000-0000-4000-8000-000000000003', 'Infrastructure as a Service (IaaS)', false, 'Em IaaS, o cliente normalmente administra sistema operacional e patches.', 2),
  ('70000000-0000-4000-8000-000000000011', '60000000-0000-4000-8000-000000000003', 'Software as a Service (SaaS)', false, 'SaaS entrega uma aplicação pronta, não uma plataforma para publicar o código da equipe.', 3),
  ('70000000-0000-4000-8000-000000000012', '60000000-0000-4000-8000-000000000003', 'Datacenter privado', false, 'Um datacenter privado mantém a responsabilidade operacional com a organização.', 4),

  ('70000000-0000-4000-8000-000000000013', '60000000-0000-4000-8000-000000000004', 'Latência, residência de dados, disponibilidade de serviços e preço', true, 'Correta: todos esses fatores podem variar entre regiões e afetar a solução.', 1),
  ('70000000-0000-4000-8000-000000000014', '60000000-0000-4000-8000-000000000004', 'Somente a distância física até os usuários', false, 'A distância influencia latência, mas não é o único fator relevante.', 2),
  ('70000000-0000-4000-8000-000000000015', '60000000-0000-4000-8000-000000000004', 'Somente o número de zonas disponíveis', false, 'Zonas são importantes para resiliência, mas outros requisitos também precisam ser avaliados.', 3),
  ('70000000-0000-4000-8000-000000000016', '60000000-0000-4000-8000-000000000004', 'A região não altera custo nem disponibilidade de serviços', false, 'Preço e catálogo de serviços podem variar por região.', 4),

  ('70000000-0000-4000-8000-000000000017', '60000000-0000-4000-8000-000000000005', 'Distribuir as instâncias entre zonas de disponibilidade', true, 'Correta: zonas possuem infraestrutura independente dentro da região.', 1),
  ('70000000-0000-4000-8000-000000000018', '60000000-0000-4000-8000-000000000005', 'Executar todas as instâncias na mesma zona', false, 'Manter tudo na mesma zona preserva um ponto comum de falha.', 2),
  ('70000000-0000-4000-8000-000000000019', '60000000-0000-4000-8000-000000000005', 'Aumentar apenas o tamanho de uma única VM', false, 'Escala vertical não protege contra indisponibilidade da zona.', 3),
  ('70000000-0000-4000-8000-000000000020', '60000000-0000-4000-8000-000000000005', 'Criar vários resource groups na mesma zona', false, 'Resource groups são contêineres lógicos e não fornecem isolamento físico.', 4),

  ('70000000-0000-4000-8000-000000000021', '60000000-0000-4000-8000-000000000006', 'Colocar os recursos relacionados em um resource group', true, 'Correta: o resource group fornece um escopo lógico comum de gerenciamento.', 1),
  ('70000000-0000-4000-8000-000000000022', '60000000-0000-4000-8000-000000000006', 'Mover todos os recursos para a mesma máquina virtual', false, 'Uma VM é um recurso de computação, não um contêiner de gerenciamento.', 2),
  ('70000000-0000-4000-8000-000000000023', '60000000-0000-4000-8000-000000000006', 'Criar uma região exclusiva para a solução', false, 'Clientes não criam regiões do Azure para organizar recursos.', 3),
  ('70000000-0000-4000-8000-000000000024', '60000000-0000-4000-8000-000000000006', 'Usar apenas uma tag sem definir escopos de acesso', false, 'Tags ajudam na classificação e nos custos, mas não substituem o escopo de um resource group.', 4),

  ('70000000-0000-4000-8000-000000000025', '60000000-0000-4000-8000-000000000007', 'Aplicar patches e manter o sistema operacional convidado', true, 'Correta: essa é uma responsabilidade do cliente em IaaS.', 1),
  ('70000000-0000-4000-8000-000000000026', '60000000-0000-4000-8000-000000000007', 'Substituir o servidor físico do datacenter', false, 'A Microsoft administra o hardware físico.', 2),
  ('70000000-0000-4000-8000-000000000027', '60000000-0000-4000-8000-000000000007', 'Administrar a camada de virtualização', false, 'A camada de virtualização é responsabilidade do provedor.', 3),
  ('70000000-0000-4000-8000-000000000028', '60000000-0000-4000-8000-000000000007', 'Controlar o acesso físico às instalações', false, 'A segurança física do datacenter pertence à Microsoft.', 4),

  ('70000000-0000-4000-8000-000000000029', '60000000-0000-4000-8000-000000000008', 'A plataforma administra o sistema operacional e o runtime da aplicação', true, 'Correta: essa abstração é uma característica de PaaS.', 1),
  ('70000000-0000-4000-8000-000000000030', '60000000-0000-4000-8000-000000000008', 'O cliente recebe acesso físico ao servidor', false, 'Serviços Azure não fornecem acesso físico ao hardware ao cliente.', 2),
  ('70000000-0000-4000-8000-000000000031', '60000000-0000-4000-8000-000000000008', 'A aplicação obrigatoriamente é executada sem servidores', false, 'App Service usa infraestrutura gerenciada; não significa ausência de servidores.', 3),
  ('70000000-0000-4000-8000-000000000032', '60000000-0000-4000-8000-000000000008', 'Não existe responsabilidade do cliente sobre código ou dados', false, 'O cliente continua responsável pela aplicação, pelos dados e pelas configurações de acesso.', 4),

  ('70000000-0000-4000-8000-000000000033', '60000000-0000-4000-8000-000000000009', 'GZRS', true, 'Correta: combina redundância zonal na primária e replicação para uma região secundária.', 1),
  ('70000000-0000-4000-8000-000000000034', '60000000-0000-4000-8000-000000000009', 'LRS', false, 'LRS mantém cópias em um único datacenter da região primária.', 2),
  ('70000000-0000-4000-8000-000000000035', '60000000-0000-4000-8000-000000000009', 'ZRS', false, 'ZRS replica entre zonas, mas não inclui replicação para uma região secundária.', 3),
  ('70000000-0000-4000-8000-000000000036', '60000000-0000-4000-8000-000000000009', 'GRS', false, 'GRS replica geograficamente, mas não distribui as cópias síncronas entre zonas da região primária.', 4),

  ('70000000-0000-4000-8000-000000000037', '60000000-0000-4000-8000-000000000010', 'Atribuir a função Reader ao analista no escopo do resource group', true, 'Correta: concede leitura no escopo necessário sem permitir alterações.', 1),
  ('70000000-0000-4000-8000-000000000038', '60000000-0000-4000-8000-000000000010', 'Atribuir a função Owner no nível da subscription', false, 'Owner concede permissões muito superiores às necessárias e em um escopo mais amplo.', 2),
  ('70000000-0000-4000-8000-000000000039', '60000000-0000-4000-8000-000000000010', 'Compartilhar as credenciais de um administrador', false, 'Compartilhar credenciais viola boas práticas e não aplica menor privilégio.', 3),
  ('70000000-0000-4000-8000-000000000040', '60000000-0000-4000-8000-000000000010', 'Atribuir Contributor no nível do management group', false, 'Contributor permite alterações e o escopo de management group é muito mais amplo que o necessário.', 4)
on conflict (id) do update set
  question_id = excluded.question_id,
  option_text = excluded.option_text,
  is_correct = excluded.is_correct,
  explanation = excluded.explanation,
  display_order = excluded.display_order;

commit;

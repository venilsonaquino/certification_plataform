begin;

create temporary table imported_flashcard_batch2_seed (
  id uuid primary key,
  certification_code text not null,
  lesson_slug text not null,
  front_text text not null,
  back_text text not null,
  hint text,
  is_published boolean not null,
  source_reference text not null,
  source_order integer not null
) on commit drop;

insert into imported_flashcard_batch2_seed (
  id, certification_code, lesson_slug, front_text, back_text,
  hint, is_published, source_reference, source_order
)
values
  ('72000000-0000-4000-8000-000000000001', 'az-900', 'azure-virtual-desktop', 'O que é o Azure Virtual Desktop?', 'É um serviço de virtualização de desktops e aplicativos hospedado no Azure, que permite aos usuários acessar remotamente um ambiente Windows completo a partir de qualquer dispositivo.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 1),
  ('72000000-0000-4000-8000-000000000002', 'az-900', 'azure-virtual-desktop', 'Qual é uma vantagem do Azure Virtual Desktop para cenários de trabalho remoto?', 'Permite que os colaboradores acessem uma área de trabalho Windows centralizada e gerenciada pela empresa, sem depender do hardware local de cada usuário.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 2),
  ('72000000-0000-4000-8000-000000000003', 'az-900', 'azure-virtual-desktop', 'O Azure Virtual Desktop suporta sessões multiusuário em uma única máquina virtual Windows?', 'Sim. Ele permite hospedar múltiplas sessões de usuários simultaneamente em uma única VM com Windows 10 ou 11 multissessão, otimizando o uso de recursos.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 3),
  ('72000000-0000-4000-8000-000000000004', 'az-900', 'virtual-machine-resources', 'Além da própria máquina virtual, quais outros recursos do Azure são necessários para que uma VM funcione corretamente?', 'Disco do sistema operacional, interface de rede (NIC), rede virtual e, geralmente, um endereço IP público ou privado associado à VM.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 4),
  ('72000000-0000-4000-8000-000000000005', 'az-900', 'virtual-machine-resources', 'O que é um grupo de segurança de rede (NSG) em relação aos recursos de uma VM?', 'É um recurso que controla o tráfego de entrada e saída permitido para a interface de rede ou sub-rede associada à VM, funcionando como um firewall básico.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 5),
  ('72000000-0000-4000-8000-000000000006', 'az-900', 'virtual-machine-resources', 'O que acontece com os recursos associados a uma VM, como disco e NIC, quando a VM é excluída?', 'Por padrão, esses recursos não são excluídos automaticamente junto com a VM; eles continuam existindo e gerando custo até serem removidos manualmente.', 'Pense na independência dos recursos na hierarquia do Azure.', true, 'Microsoft Learn — Describe Azure compute and networking services', 6),
  ('72000000-0000-4000-8000-000000000007', 'az-900', 'azure-app-service', 'O que é o Azure App Service?', 'É um serviço PaaS totalmente gerenciado para hospedar aplicações web, APIs REST e back-ends para dispositivos móveis, sem a necessidade de gerenciar a infraestrutura subjacente.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 7),
  ('72000000-0000-4000-8000-000000000008', 'az-900', 'azure-app-service', 'Quais linguagens de programação o Azure App Service normalmente suporta?', 'Suporta múltiplas linguagens, como .NET, Java, Node.js, PHP, Python e Ruby, além de permitir a implantação de contêineres personalizados.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 8),
  ('72000000-0000-4000-8000-000000000009', 'az-900', 'azure-app-service', 'O que é um "deployment slot" no Azure App Service?', 'É um ambiente separado dentro do mesmo App Service usado para testar uma nova versão da aplicação antes de trocá-la com o ambiente de produção, reduzindo o risco de implantação.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 9),
  ('72000000-0000-4000-8000-000000000010', 'az-900', 'azure-app-service', 'Qual é a vantagem do Azure App Service em relação ao uso de uma Máquina Virtual para hospedar uma aplicação web?', 'Elimina a necessidade de gerenciar o sistema operacional e a infraestrutura, além de oferecer recursos integrados como escalonamento automático, certificados SSL e implantação contínua.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 10),
  ('72000000-0000-4000-8000-000000000011', 'az-900', 'azure-functions', 'O que é o Azure Functions?', 'É o serviço de computação serverless do Azure, usado para executar pequenos trechos de código (funções) em resposta a eventos, sem a necessidade de provisionar servidores.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 11),
  ('72000000-0000-4000-8000-000000000012', 'az-900', 'azure-functions', 'O que é um "trigger" no Azure Functions?', 'É o evento que inicia a execução de uma função, como uma requisição HTTP, uma mensagem em uma fila ou uma alteração em um banco de dados.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 12),
  ('72000000-0000-4000-8000-000000000013', 'az-900', 'azure-functions', 'Qual é uma diferença entre o Azure Functions e o Azure App Service em termos de cobrança?', 'No plano de consumo, o Azure Functions cobra com base no tempo de execução e no número de execuções das funções, enquanto o App Service normalmente cobra pela capacidade do plano contratado, independentemente do uso.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 13),
  ('72000000-0000-4000-8000-000000000014', 'az-900', 'containers-on-azure', 'O que é um contêiner, no contexto de computação em nuvem?', 'É uma unidade de software que empacota uma aplicação junto com todas as suas dependências, permitindo que ela seja executada de forma consistente em diferentes ambientes.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 14),
  ('72000000-0000-4000-8000-000000000015', 'az-900', 'containers-on-azure', 'O que é o Azure Container Instances (ACI)?', 'É um serviço que permite executar contêineres diretamente no Azure, sem a necessidade de provisionar ou gerenciar máquinas virtuais ou orquestradores.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 15),
  ('72000000-0000-4000-8000-000000000016', 'az-900', 'containers-on-azure', 'Para que serve o Azure Kubernetes Service (AKS)?', 'É um serviço gerenciado de orquestração de contêineres baseado no Kubernetes, usado para implantar, escalar e gerenciar aplicações em contêineres de forma automatizada.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 16),
  ('72000000-0000-4000-8000-000000000017', 'az-900', 'containers-on-azure', 'Qual é a principal diferença entre usar Azure Container Instances e Azure Kubernetes Service?', 'O ACI é indicado para executar contêineres isolados e simples rapidamente, enquanto o AKS é indicado para orquestrar múltiplos contêineres em larga escala, com recursos avançados de gerenciamento e escalonamento.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 17),
  ('72000000-0000-4000-8000-000000000018', 'az-900', 'virtual-networks-and-subnets', 'Qual é a principal finalidade de dividir uma rede virtual do Azure em sub-redes (subnets)?', 'Organizar e segmentar os recursos dentro da rede virtual, permitindo aplicar regras de segurança e roteamento específicas para diferentes grupos de recursos.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 18),
  ('72000000-0000-4000-8000-000000000019', 'az-900', 'virtual-networks-and-subnets', 'Os recursos em sub-redes diferentes de uma mesma rede virtual do Azure conseguem se comunicar entre si por padrão?', 'Sim. Por padrão, todas as sub-redes dentro de uma mesma rede virtual podem se comunicar entre si, a menos que regras de segurança de rede restrinjam esse tráfego.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 19),
  ('72000000-0000-4000-8000-000000000020', 'az-900', 'virtual-networks-and-subnets', 'Uma rede virtual do Azure pode se estender por múltiplas regiões?', 'Não. Uma rede virtual está sempre associada a uma única região do Azure, embora possa se conectar a redes virtuais de outras regiões por meio de peering.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 20),
  ('72000000-0000-4000-8000-000000000021', 'az-900', 'virtual-networks-and-subnets', 'O que define o intervalo de endereços IP disponíveis dentro de uma rede virtual do Azure?', 'O espaço de endereçamento definido no formato CIDR ao criar a rede virtual, que é então dividido entre as sub-redes contidas nela.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 21),
  ('72000000-0000-4000-8000-000000000022', 'az-900', 'virtual-networks-and-subnets', 'Por que é recomendável planejar cuidadosamente o espaço de endereçamento de uma rede virtual antes de criá-la?', 'Porque alterar o espaço de endereçamento depois de criado pode ser complexo, especialmente se já houver recursos implantados ou conexões estabelecidas com outras redes.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 22),
  ('72000000-0000-4000-8000-000000000023', 'az-900', 'vnet-peering', 'O que é o VNet Peering no Azure?', 'É um recurso que conecta duas redes virtuais do Azure, permitindo que os recursos nelas se comuniquem diretamente pela rede de backbone da Microsoft, como se estivessem na mesma rede.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 23),
  ('72000000-0000-4000-8000-000000000024', 'az-900', 'vnet-peering', 'O tráfego entre redes virtuais conectadas por VNet Peering passa pela internet pública?', 'Não. O tráfego trafega pela infraestrutura de backbone privada da Microsoft, sem passar pela internet pública, o que melhora a segurança e reduz a latência.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 24),
  ('72000000-0000-4000-8000-000000000025', 'az-900', 'vnet-peering', 'O VNet Peering pode conectar redes virtuais localizadas em regiões diferentes do Azure?', 'Sim, por meio do chamado Global VNet Peering, que permite conectar redes virtuais mesmo quando estão em regiões diferentes.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 25),
  ('72000000-0000-4000-8000-000000000026', 'az-900', 'azure-dns', 'Qual é a função do Azure DNS?', 'Hospedar e gerenciar registros de domínio DNS na infraestrutura do Azure, traduzindo nomes de domínio legíveis em endereços IP usados pelos recursos.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 26),
  ('72000000-0000-4000-8000-000000000027', 'az-900', 'azure-dns', 'Qual é uma vantagem de usar o Azure DNS em vez de um provedor de DNS separado?', 'Permite gerenciar os registros DNS dos domínios junto com os demais recursos do Azure, usando as mesmas ferramentas, controles de acesso e cobrança integrada.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 27),
  ('72000000-0000-4000-8000-000000000028', 'az-900', 'azure-dns', 'O Azure DNS é responsável por registrar (comprar) nomes de domínio?', 'Não. O Azure DNS hospeda e gerencia os registros DNS de domínios já registrados, mas não atua como um registrador de nomes de domínio.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 28),
  ('72000000-0000-4000-8000-000000000029', 'az-900', 'vpn-gateway-vs-expressroute', 'Qual é a principal diferença entre o Azure VPN Gateway e o Azure ExpressRoute?', 'O VPN Gateway cria uma conexão criptografada pela internet pública entre a rede local e o Azure. O ExpressRoute estabelece uma conexão privada e dedicada, sem passar pela internet pública.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 29),
  ('72000000-0000-4000-8000-000000000030', 'az-900', 'vpn-gateway-vs-expressroute', 'Por que o ExpressRoute costuma oferecer maior confiabilidade e desempenho do que uma VPN tradicional?', 'Porque utiliza uma conexão privada dedicada, fora da internet pública, o que resulta em latência mais previsível, maior largura de banda e menor exposição a instabilidades da internet.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 30),
  ('72000000-0000-4000-8000-000000000031', 'az-900', 'vpn-gateway-vs-expressroute', 'Em qual cenário uma empresa optaria pelo Azure VPN Gateway em vez do ExpressRoute?', 'Quando precisa de uma conexão segura e mais econômica, sem exigir os níveis extremos de desempenho e confiabilidade que o ExpressRoute oferece, ou quando a implantação precisa ser rápida.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 31),
  ('72000000-0000-4000-8000-000000000032', 'az-900', 'vpn-gateway-vs-expressroute', 'O tráfego que passa por uma conexão VPN Gateway do Azure é criptografado?', 'Sim. A VPN Gateway estabelece um túnel criptografado entre a rede local e a rede virtual do Azure, protegendo os dados transmitidos pela internet pública.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 32),
  ('72000000-0000-4000-8000-000000000033', 'az-900', 'public-vs-private-endpoints', 'Qual é a diferença entre um endpoint público e um endpoint privado para um serviço do Azure?', 'Um endpoint público é acessível pela internet, usando um endereço IP público. Um endpoint privado é acessível apenas dentro de uma rede virtual, usando um endereço IP privado.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 33),
  ('72000000-0000-4000-8000-000000000034', 'az-900', 'public-vs-private-endpoints', 'Qual é a principal vantagem de usar um Private Endpoint para acessar um serviço do Azure, como uma conta de armazenamento?', 'Elimina a exposição do serviço à internet pública, permitindo que o tráfego permaneça dentro da rede virtual privada, o que aumenta a segurança e reduz riscos de exposição.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 34),
  ('72000000-0000-4000-8000-000000000035', 'az-900', 'public-vs-private-endpoints', 'Um serviço configurado apenas com endpoint privado pode ser acessado diretamente pela internet pública?', 'Não. Quando configurado exclusivamente com endpoint privado, o serviço só pode ser acessado a partir da rede virtual à qual o endpoint está conectado.', null, true, 'Microsoft Learn — Describe Azure compute and networking services', 35),
  ('72000000-0000-4000-8000-000000000036', 'az-900', 'storage-accounts-and-services', 'O que é uma conta de armazenamento (storage account) no Azure?', 'É o contêiner de nível superior que fornece um namespace exclusivo para armazenar e acessar os diferentes serviços de dados do Azure, como blobs, filas, tabelas e arquivos.', null, true, 'Microsoft Learn — Describe Azure storage services', 36),
  ('72000000-0000-4000-8000-000000000037', 'az-900', 'storage-accounts-and-services', 'Quais tipos de serviços de dados podem ser armazenados dentro de uma única conta de armazenamento do Azure?', 'Blob Storage, Azure Files, filas (Queue Storage), tabelas (Table Storage) e discos gerenciados, dependendo do tipo de conta de armazenamento criada.', null, true, 'Microsoft Learn — Describe Azure storage services', 37),
  ('72000000-0000-4000-8000-000000000038', 'az-900', 'storage-accounts-and-services', 'O nome de uma conta de armazenamento do Azure precisa ser globalmente exclusivo?', 'Sim. O nome da conta de armazenamento deve ser único em todo o Azure, pois faz parte do endpoint público usado para acessar os dados armazenados.', null, true, 'Microsoft Learn — Describe Azure storage services', 38),
  ('72000000-0000-4000-8000-000000000039', 'az-900', 'storage-accounts-and-services', 'O que determina o desempenho e os tipos de serviço suportados por uma conta de armazenamento do Azure?', 'O nível de desempenho escolhido na criação da conta, como Standard (baseado em HDD) ou Premium (baseado em SSD), além do tipo de conta selecionado.', null, true, 'Microsoft Learn — Describe Azure storage services', 39),
  ('72000000-0000-4000-8000-000000000040', 'az-900', 'storage-accounts-and-services', 'É possível restringir o acesso de rede a uma conta de armazenamento do Azure apenas a redes virtuais específicas?', 'Sim. É possível configurar regras de firewall e endpoints privados para limitar o acesso à conta de armazenamento apenas a redes ou IPs autorizados.', null, true, 'Microsoft Learn — Describe Azure storage services', 40),
  ('72000000-0000-4000-8000-000000000041', 'az-900', 'blob-storage', 'Para que tipo de dado o Azure Blob Storage é mais indicado?', 'Para armazenar grandes volumes de dados não estruturados, como imagens, vídeos, documentos, backups e arquivos de log.', null, true, 'Microsoft Learn — Describe Azure storage services', 41),
  ('72000000-0000-4000-8000-000000000042', 'az-900', 'blob-storage', 'Quais são os três principais tipos de blob suportados pelo Azure Blob Storage?', 'Block blobs, usados para arquivos comuns; append blobs, otimizados para operações de adição, como logs; e page blobs, usados principalmente para discos de máquinas virtuais.', null, true, 'Microsoft Learn — Describe Azure storage services', 42),
  ('72000000-0000-4000-8000-000000000043', 'az-900', 'blob-storage', 'O que são os níveis de acesso (access tiers) do Blob Storage, como Hot, Cool e Archive?', 'São camadas que determinam o custo de armazenamento e de acesso aos dados, sendo Hot indicado para acesso frequente, Cool para acesso pouco frequente e Archive para dados raramente acessados.', null, true, 'Microsoft Learn — Describe Azure storage services', 43),
  ('72000000-0000-4000-8000-000000000044', 'az-900', 'blob-storage', 'Os dados armazenados no nível Archive do Blob Storage podem ser acessados instantaneamente?', 'Não. Dados no nível Archive precisam ser reidratados (rehydrated) antes de serem acessados, um processo que pode levar horas, mas que oferece o menor custo de armazenamento.', null, true, 'Microsoft Learn — Describe Azure storage services', 44),
  ('72000000-0000-4000-8000-000000000045', 'az-900', 'azure-files', 'O que é o Azure Files?', 'É um serviço que oferece compartilhamentos de arquivos totalmente gerenciados na nuvem, acessíveis pelos protocolos SMB e NFS, tanto localmente quanto pela internet.', null, true, 'Microsoft Learn — Describe Azure storage services', 45),
  ('72000000-0000-4000-8000-000000000046', 'az-900', 'azure-files', 'Qual é uma vantagem do Azure Files em relação a um compartilhamento de arquivos tradicional hospedado localmente?', 'Elimina a necessidade de manter servidores de arquivos físicos, permitindo montar o compartilhamento simultaneamente em múltiplas máquinas, em diferentes locais, com alta disponibilidade gerenciada pelo Azure.', null, true, 'Microsoft Learn — Describe Azure storage services', 46),
  ('72000000-0000-4000-8000-000000000047', 'az-900', 'azure-files', 'O Azure Files pode ser usado para substituir um servidor de arquivos local acessado por múltiplos usuários?', 'Sim. Ele permite montar o mesmo compartilhamento simultaneamente em várias máquinas, na nuvem ou localmente, funcionando como um substituto de servidores de arquivos tradicionais.', null, true, 'Microsoft Learn — Describe Azure storage services', 47),
  ('72000000-0000-4000-8000-000000000048', 'az-900', 'managed-disks', 'O que são discos gerenciados (managed disks) no Azure?', 'São discos de armazenamento usados por máquinas virtuais, cuja criação, configuração e manutenção da infraestrutura subjacente são totalmente gerenciadas pelo Azure.', null, true, 'Microsoft Learn — Describe Azure storage services', 48),
  ('72000000-0000-4000-8000-000000000049', 'az-900', 'managed-disks', 'Qual é a vantagem dos discos gerenciados em relação aos discos não gerenciados (unmanaged disks)?', 'O cliente não precisa se preocupar em criar ou gerenciar contas de armazenamento manualmente para os discos, o que simplifica a administração e melhora a confiabilidade e a escalabilidade.', null, true, 'Microsoft Learn — Describe Azure storage services', 49),
  ('72000000-0000-4000-8000-000000000050', 'az-900', 'managed-disks', 'Quais tipos de disco gerenciado o Azure oferece, considerando desempenho e custo?', 'Discos Standard HDD, Standard SSD, Premium SSD e Ultra Disk, variando em desempenho, latência e custo, conforme a necessidade da carga de trabalho.', null, true, 'Microsoft Learn — Describe Azure storage services', 50);

do $$
declare
  invalid_slugs text;
begin
  select string_agg(invalid.lesson_slug, ', ' order by invalid.lesson_slug)
  into invalid_slugs
  from (
    select seed.lesson_slug
    from imported_flashcard_batch2_seed seed
    left join public.lessons lesson on lesson.slug = seed.lesson_slug
    group by seed.lesson_slug
    having count(distinct lesson.id) <> 1
  ) invalid;

  if invalid_slugs is not null then
    raise exception 'A importação contém lesson_slug ausente ou ambíguo: %', invalid_slugs;
  end if;
end
$$;

with resolved_seed as (
  select seed.*, lesson.id as lesson_id
  from imported_flashcard_batch2_seed seed
  join public.lessons lesson on lesson.slug = seed.lesson_slug
),
new_seed as (
  select resolved.*
  from resolved_seed resolved
  where not exists (
    select 1
    from public.flashcards existing
    where existing.id = resolved.id
       or (
         existing.lesson_id = resolved.lesson_id
         and lower(trim(existing.front_text)) = lower(trim(resolved.front_text))
       )
  )
),
ordered_seed as (
  select
    new_seed.*,
    row_number() over (partition by new_seed.lesson_id order by new_seed.source_order)::integer as lesson_offset
  from new_seed
),
existing_order as (
  select
    lesson.id as lesson_id,
    coalesce(max(flashcard.display_order), 0) as max_display_order
  from (select distinct lesson_id as id from ordered_seed) lesson
  left join public.flashcards flashcard on flashcard.lesson_id = lesson.id
  group by lesson.id
)
insert into public.flashcards (
  id, lesson_id, front_text, back_text, hint, display_order, is_published
)
select
  ordered.id,
  ordered.lesson_id,
  ordered.front_text,
  ordered.back_text,
  ordered.hint,
  existing.max_display_order + ordered.lesson_offset,
  ordered.is_published
from ordered_seed ordered
join existing_order existing on existing.lesson_id = ordered.lesson_id
order by ordered.source_order
on conflict (id) do nothing;

commit;

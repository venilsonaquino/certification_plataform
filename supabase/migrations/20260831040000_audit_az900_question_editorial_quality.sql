begin;

create temporary table az900_question_ids_before on commit drop as
select question.id
from public.questions question
join public.certifications certification on certification.id = question.certification_id
where certification.code = 'az-900' and question.is_published;

create temporary table az900_option_ids_before on commit drop as
select option.id
from public.question_options option
join az900_question_ids_before question on question.id = option.question_id;

create temporary table az900_mock_snapshot_digest_before on commit drop as
select md5(coalesce(string_agg(
  snapshot.id::text || snapshot.question_text_snapshot || snapshot.options_snapshot::text
  || coalesce(snapshot.question_explanation_snapshot, '') || snapshot.correct_option_key,
  '' order by snapshot.id), '')) as digest
from public.mock_exam_attempt_questions snapshot;

create temporary table az900_editorial_terms (
  source text primary key,
  replacement text not null
) on commit drop;

insert into az900_editorial_terms values
  ('qual e','qual é'),('o que e','o que é'),('como e','como é'),('nao e','não é'),
  ('esta correta','está correta'),('esta avaliando','está avaliando'),('esta definindo','está definindo'),
  ('esta comparando','está comparando'),('esta planejando','está planejando'),('esta escolhendo','está escolhendo'),
  ('e responsavel','é responsável'),('e necessario','é necessário'),('e necessaria','é necessária'),
  ('e limitada','é limitada'),('e limitado','é limitado'),('e exclusiva','é exclusiva'),('e exclusivo','é exclusivo'),
  ('e possivel','é possível'),('e mais adequada','é mais adequada'),('e mais adequado','é mais adequado'),
  ('e a principal','é a principal'),('e o principal','é o principal'),('em media','em média'),
  ('nuvem publica','nuvem pública'),('nuvens publicas','nuvens públicas'),('internet publica','internet pública'),
  ('regioes publicas','regiões públicas'),('recursos publicos','recursos públicos'),
  ('nao','não'),('voce','você'),('questao','questão'),('questoes','questões'),
  ('informacao','informação'),('informacoes','informações'),('configuracao','configuração'),('configuracoes','configurações'),
  ('aplicacao','aplicação'),('aplicacoes','aplicações'),('autenticacao','autenticação'),
  ('regiao','região'),('regioes','regiões'),('servico','serviço'),('servicos','serviços'),
  ('computacao','computação'),('fisico','físico'),('fisicos','físicos'),('fisica','física'),('fisicas','físicas'),
  ('contratacao','contratação'),('instalacao','instalação'),('usuarios','usuários'),('usuario','usuário'),
  ('opcao','opção'),('opcoes','opções'),('caracteristica','característica'),('caracteristicas','características'),
  ('aprovacao','aprovação'),('tecnico','técnico'),('tecnica','técnica'),('tecnicos','técnicos'),('tecnicas','técnicas'),
  ('intervencao','intervenção'),('localizacao','localização'),('funcionario','funcionário'),('funcionarios','funcionários'),
  ('escritorio','escritório'),('cenario','cenário'),('cenarios','cenários'),('seguranca','segurança'),
  ('afirmacao','afirmação'),('responsavel','responsável'),('responsaveis','responsáveis'),
  ('organizacao','organização'),('organizacoes','organizações'),('maximo','máximo'),('maxima','máxima'),
  ('customizacao','customização'),('gestao','gestão'),
  ('hibrida','híbrida'),('hibridas','híbridas'),('instituicao','instituição'),('instituicoes','instituições'),
  ('sensiveis','sensíveis'),('sensivel','sensível'),('exigencias','exigências'),('exigencia','exigência'),
  ('regulatorias','regulatórias'),('regulatoria','regulatória'),('rigidas','rígidas'),('rigida','rígida'),
  ('comunitaria','comunitária'),('orgaos','órgãos'),('medicos','médicos'),('medico','médico'),
  ('relatorios','relatórios'),('relatorio','relatório'),('conexao','conexão'),('duplicacao','duplicação'),
  ('nivel','nível'),('niveis','níveis'),('personalizacao','personalização'),('criterios','critérios'),('criterio','critério'),
  ('relacao','relação'),('saude','saúde'),('prontuarios','prontuários'),('eletronicos','eletrônicos'),
  ('legislacoes','legislações'),('legislacao','legislação'),('protecao','proteção'),('analise','análise'),
  ('preco','preço'),('trafego','tráfego'),('conclusao','conclusão'),('eficiencia','eficiência'),
  ('periodos','períodos'),('periodo','período'),('diferenca','diferença'),('diferencas','diferenças'),
  ('licenca','licença'),('unico','único'),('unica','única'),('flexivel','flexível'),('flexiveis','flexíveis'),
  ('mudancas','mudanças'),('mudanca','mudança'),('decisao','decisão'),('decisoes','decisões'),
  ('manutencao','manutenção'),('obsolescencia','obsolescência'),('numero','número'),('numeros','números'),
  ('variavel','variável'),('variaveis','variáveis'),('codigo','código'),('execucao','execução'),('execucoes','execuções'),
  ('funcao','função'),('funcoes','funções'),('automatico','automático'),('automatica','automática'),
  ('automaticos','automáticos'),('automaticas','automáticas'),('requisicoes','requisições'),('requisicao','requisição'),
  ('previsao','previsão'),('horarios','horários'),('horario','horário'),('maquina','máquina'),('maquinas','máquinas'),
  ('proprio','próprio'),('propria','própria'),('proprios','próprios'),('proprias','próprias'),
  ('especifica','específica'),('especificas','específicas'),('especifico','específico'),('especificos','específicos'),
  ('validacao','validação'),('necessario','necessário'),('necessaria','necessária'),('necessarios','necessários'),('necessarias','necessárias'),
  ('operacoes','operações'),('operacao','operação'),('multiplos','múltiplos'),('multiplas','múltiplas'),
  ('paises','países'),('politica','política'),('politicas','políticas'),('negocio','negócio'),('negocios','negócios'),
  ('frequencia','frequência'),('variacoes','variações'),('variacao','variação'),
  ('previsivel','previsível'),('imprevisivel','imprevisível'),('dificeis','difíceis'),('possivel','possível'),
  ('disponiveis','disponíveis'),('disponivel','disponível'),
  ('tambem','também'),('ja','já'),('so','só'),('ate','até'),('apos','após'),('alem','além'),
  ('logica','lógica'),('logico','lógico'),('pratica','prática'),('praticas','práticas'),
  ('basico','básico'),('basica','básica'),('facil','fácil'),('dificil','difícil'),
  ('rapido','rápido'),('rapida','rápida'),('critico','crítico'),('critica','crítica'),
  ('historico','histórico'),('historica','histórica'),('metodo','método'),('metodos','métodos'),
  ('beneficio','benefício'),('beneficios','benefícios'),('principio','princípio'),('principios','princípios'),
  ('proxima','próxima'),('proximo','próximo'),('distancia','distância'),('latencia','latência'),
  ('experiencia','experiência'),('consistencia','consistência');

insert into az900_editorial_terms values
  ('sao','são'),('estao','estão'),('ha','há'),('sera','será'),('permanecera','permanecerá'),
  ('utilizacao','utilização'),('interrupcoes','interrupções'),('interrupcao','interrupção'),('acessivel','acessível'),
  ('estrategia','estratégia'),('estrategias','estratégias'),('redundancia','redundância'),
  ('instancia','instância'),('instancias','instâncias'),('combinacao','combinação'),('combinacoes','combinações'),
  ('minimo','mínimo'),('minima','mínima'),('realizacao','realização'),('dependencia','dependência'),('dependencias','dependências'),
  ('distribuicao','distribuição'),('consideracao','consideração'),('sinonimos','sinônimos'),
  ('metricas','métricas'),('metrica','métrica'),('desativacao','desativação'),('adicao','adição'),
  ('lentidao','lentidão'),('elastica','elástica'),('situacao','situação'),('investigacao','investigação'),
  ('previa','prévia'),('recuperacao','recuperação'),('criticos','críticos'),('criticas','críticas'),
  ('continuo','contínuo'),('dimensoes','dimensões'),('orcamento','orçamento'),
  ('apresentacao','apresentação'),('precisao','precisão'),('viavel','viável'),('obrigatorio','obrigatório'),
  ('obrigatoria','obrigatória'),('equilibrio','equilíbrio'),('migracao','migração'),('migracoes','migrações'),
  ('solucao','solução'),('solucoes','soluções'),('construido','construído'),('construida','construída'),
  ('replicas','réplicas'),('unicos','únicos'),('unicas','únicas'),
  ('confiavel','confiável'),('confiaveis','confiáveis'),('caracteristicas','características'),
  ('orcamentos','orçamentos'),('adocao','adoção'),('portfolio','portfólio'),
  ('tres','três'),('proxima','próxima'),('geografica','geográfica'),('geograficas','geográficas'),
  ('aplicaveis','aplicáveis'),('residencia','residência'),('possiveis','possíveis'),
  ('padrao','padrão'),('padroes','padrões'),('hibrido','híbrido'),('hibridos','híbridos'),
  ('cobranca','cobrança'),('cobrancas','cobranças'),('estavel','estável'),('estaveis','estáveis'),
  ('precos','preços'),('antecedencia','antecedência'),('automacao','automação'),
  ('correcoes','correções'),('atualizacoes','atualizações'),('permissoes','permissões'),('acoes','ações'),
  ('resolucao','resolução'),('dominio','domínio'),('dominios','domínios'),('restricao','restrição'),('restricoes','restrições'),
  ('provisao','provisão'),('provisoes','provisões'),
  ('tecnologica','tecnológica'),('tecnologicas','tecnológicas'),
  ('administracao','administração'),('alteracao','alteração'),('alteracoes','alterações'),
  ('criacao','criação'),('exclusao','exclusão'),('integracao','integração'),('integracoes','integrações'),
  ('avaliacao','avaliação'),('avaliacoes','avaliações'),('recomendacao','recomendação'),('recomendacoes','recomendações'),
  ('identico','idêntico'),('identica','idêntica'),('sincrona','síncrona'),('assincrona','assíncrona'),
  ('memoria','memória'),('logica','lógica'),('estatisticas','estatísticas'),('esteticos','estéticos'),
  ('relacao','relação'),('relacoes','relações'),('utiliza-los','utilizá-los'),('utiliza-la','utilizá-la'),
  ('acessa-los','acessá-los'),('configura-la','configurá-la'),('protege-los','protegê-los'),('tao','tão')
on conflict (source) do update set replacement = excluded.replacement;

create function pg_temp.az900_editorial_normalize(value text)
returns text language plpgsql immutable as $$
declare
  item record;
  result text := value;
begin
  if result is null then return null; end if;
  for item in select source, replacement from az900_editorial_terms order by length(source) desc loop
    result := regexp_replace(result,
      '\m' || upper(left(item.source, 1)) || substr(item.source, 2) || '\M',
      upper(left(item.replacement, 1)) || substr(item.replacement, 2), 'g');
    result := regexp_replace(result, '\m' || item.source || '\M', item.replacement, 'g');
  end loop;
  return result;
end;
$$;

create temporary table az900_distractor_correction_seed (
  id uuid primary key,
  option_text text not null,
  explanation text not null
) on commit drop;

insert into az900_distractor_correction_seed values
  ('73000000-0000-4000-8000-000000000235','Comparar apenas o preço de compra dos servidores com a primeira fatura mensal da nuvem.','Incorreta. A comparação precisa considerar o custo total ao longo do tempo, incluindo operação, manutenção e flexibilidade.'),
  ('73000000-0000-4000-8000-000000000262','Executar em uma VM um processo agendado que verifica periodicamente se há novos arquivos.','Incorreta. O processo agendado pode funcionar, mas mantém infraestrutura e não reage diretamente ao evento como uma função serverless.'),
  ('73000000-0000-4000-8000-000000000415','Aumentar apenas CPU e memória da instância principal, sem criar cópias dos dados.','Incorreta. Mais capacidade de computação não protege os dados contra falha ou exclusão.'),
  ('73000000-0000-4000-8000-000000000449','Azure Service Health, por registrar incidentes que afetam serviços Azure.','Incorreta. Service Health comunica incidentes; não estima o custo de uma arquitetura planejada.'),
  ('73000000-0000-4000-8000-000000000450','Azure Monitor Metrics, por acompanhar séries temporais de desempenho.','Incorreta. Metrics acompanha telemetria operacional; não calcula o preço futuro dos recursos planejados.'),
  ('73000000-0000-4000-8000-000000000451','Microsoft Defender for Cloud, por avaliar postura e ameaças de workloads.','Incorreta. Defender for Cloud trata segurança; não é uma ferramenta de estimativa de preços.'),
  ('73000000-0000-4000-8000-000000000461','Projetar o ano inteiro usando somente o consumo de um único dia recente.','Incorreta. Uma amostra isolada não representa sazonalidade, crescimento nem mudanças planejadas.'),
  ('74000000-0000-4000-8000-000000000164','Um conjunto de cmdlets do Azure PowerShell que só pode ser usado no Windows.','Incorreta. Azure CLI usa comandos az e é multiplataforma; cmdlets pertencem ao Azure PowerShell.'),
  ('74000000-0000-4000-8000-000000000204','Uma instalação local obrigatória do Azure CLI, sem suporte ao PowerShell.','Incorreta. Cloud Shell é hospedado no navegador e oferece Azure CLI e Azure PowerShell.'),
  ('74000000-0000-4000-8000-000000000404','Um serviço de object storage acessado somente por APIs HTTP.','Incorreta. Isso se aproxima de Blob Storage; Azure Files oferece compartilhamentos de arquivos gerenciados.'),
  ('74000000-0000-4000-8000-000000000408','RDP, usado para abrir uma sessão remota em uma máquina Windows.','Incorreta. RDP fornece acesso remoto a uma máquina; não monta compartilhamentos do Azure Files.'),
  ('74000000-0000-4000-8000-000000000436','Migrar todos os arquivos imediatamente, sem testar compatibilidade nem qualidade da conexão.','Incorreta. A decisão deve considerar compatibilidade, conectividade e a necessidade de cache local.'),
  ('75000000-0000-4000-8000-000000000046','Porque todas as Azure Regions oferecem os mesmos serviços e preços.','Incorreta. Disponibilidade de serviços e preços pode variar entre Regions.'),
  ('75000000-0000-4000-8000-000000000050','Mover a aplicação para uma Region mais distante que ofereça menor preço.','Incorreta. Maior distância tende a aumentar a latência para os jogadores.'),
  ('75000000-0000-4000-8000-000000000051','Manter a Region atual e aumentar somente o tamanho da máquina virtual.','Incorreta. Mais capacidade pode ajudar processamento, mas não reduz a latência de rede causada pela distância.'),
  ('75000000-0000-4000-8000-000000000059','Escolher apenas a Region com mais Availability Zones, sem verificar serviços ou residência de dados.','Incorreta. Quantidade de Zones não substitui a avaliação conjunta dos requisitos do cenário.'),
  ('77000000-0000-4000-8000-000000000066','A versão do sistema operacional instalada, independentemente de CPU e memória.','Incorreta. A imagem do sistema operacional é uma escolha separada do tamanho da VM.'),
  ('77000000-0000-4000-8000-000000000067','O nível de permissão RBAC concedido aos administradores da máquina virtual.','Incorreta. RBAC controla acesso; o tamanho da VM define sua capacidade de computação.');

update public.question_options option
set option_text = seed.option_text,
    explanation = seed.explanation
from az900_distractor_correction_seed seed
where option.id = seed.id;

update public.questions question
set question_text = pg_temp.az900_editorial_normalize(question.question_text),
    explanation = pg_temp.az900_editorial_normalize(question.explanation)
from public.certifications certification
where certification.id = question.certification_id
  and certification.code = 'az-900'
  and question.is_published
  and (question.question_text, question.explanation) is distinct from
      (pg_temp.az900_editorial_normalize(question.question_text), pg_temp.az900_editorial_normalize(question.explanation));

update public.question_options option
set option_text = pg_temp.az900_editorial_normalize(option.option_text),
    explanation = pg_temp.az900_editorial_normalize(option.explanation)
from public.questions question
join public.certifications certification on certification.id = question.certification_id
where question.id = option.question_id
  and certification.code = 'az-900'
  and question.is_published
  and (option.option_text, option.explanation) is distinct from
      (pg_temp.az900_editorial_normalize(option.option_text), pg_temp.az900_editorial_normalize(option.explanation));

-- Remove justificativas redundantes da alternativa correta quando o próprio enunciado
-- já fornece o contexto. A explicação pedagógica permanece no feedback da Question.
update public.question_options option
set option_text = regexp_replace(option.option_text,
      ',\s+(pois|porque|já que|permitindo|representando|atendendo|reduzindo|mantendo|considerando|restando|confirmando|determinando|executando|funcionando|incluindo|oferecendo|evitando|fornecendo|usando|utilizando|deixando|garantindo|ajudando|possibilitando|como)\s+.*$', '', 'i')
from public.questions question
join public.certifications certification on certification.id = question.certification_id
where question.id = option.question_id
  and certification.code = 'az-900'
  and question.is_published
  and option.is_correct
  and option.option_text ~* ',\s+(pois|porque|já que|permitindo|representando|atendendo|reduzindo|mantendo|considerando|restando|confirmando|determinando|executando|funcionando|incluindo|oferecendo|evitando|fornecendo|usando|utilizando|deixando|garantindo|ajudando|possibilitando|como)\s+';

-- Preserve option UUIDs and answer keys while balancing only future presentation order.
create temporary table az900_option_order on commit drop as
with target_questions as (
  select question.id,
    ((row_number() over (order by question.id) - 1) % 4 + 1)::integer target_correct_order
  from public.questions question
  join public.certifications certification on certification.id = question.certification_id
  where certification.code = 'az-900' and question.is_published
), ranked_options as (
  select option.id, option.question_id, option.is_correct, option.display_order,
    target.target_correct_order,
    row_number() over (partition by option.question_id, option.is_correct order by option.display_order, option.id)::integer distractor_rank
  from public.question_options option
  join target_questions target on target.id = option.question_id
)
select ranked.id,
  case when ranked.is_correct then ranked.target_correct_order
       else (select position
             from generate_series(1,4) position
             where position <> ranked.target_correct_order
             order by position
             offset ranked.distractor_rank - 1 limit 1)
  end::integer as display_order
from ranked_options ranked;

update public.question_options option set display_order = option.display_order + 10
from az900_option_order target where target.id = option.id;

update public.question_options option set display_order = target.display_order
from az900_option_order target where target.id = option.id;

do $$
declare
  v_questions integer;
  v_options integer;
  v_eligible integer;
  v_distribution integer[];
begin
  select count(*) into v_questions from az900_question_ids_before;
  select count(*) into v_options from az900_option_ids_before;
  if v_questions <> 512 or v_options <> 2048 then
    raise exception 'Expected preserved 512 Questions and 2048 options, got % and %', v_questions, v_options;
  end if;
  if exists (
    select 1 from az900_question_ids_before before
    left join public.questions question on question.id = before.id
    where question.id is null
  ) or exists (
    select 1 from az900_option_ids_before before
    left join public.question_options option on option.id = before.id
    where option.id is null
  ) then raise exception 'Question or option UUID changed during editorial audit'; end if;
  if exists (
    select 1 from public.question_options option
    join az900_question_ids_before question on question.id = option.question_id
    group by option.question_id having count(*) <> 4 or count(*) filter (where option.is_correct) <> 1
  ) then raise exception 'Editorial audit changed option cardinality or answer keys'; end if;
  select count(*) into v_eligible from public.questions question
    join az900_question_ids_before published on published.id = question.id where question.mock_eligible;
  if v_eligible <> 439 then raise exception 'Mock-eligible pool changed: expected 439, got %', v_eligible; end if;
  select array_agg(count order by display_order) into v_distribution
  from (select option.display_order, count(*)::integer count
        from public.question_options option join az900_question_ids_before question on question.id=option.question_id
        where option.is_correct group by option.display_order) distribution;
  if v_distribution <> array[128,128,128,128] then
    raise exception 'Correct-option presentation distribution is not balanced: %', v_distribution;
  end if;
  if exists (
    select 1
    from public.questions question
    join az900_question_ids_before published on published.id = question.id
    where (question.question_text, question.explanation) is distinct from
      (pg_temp.az900_editorial_normalize(question.question_text), pg_temp.az900_editorial_normalize(question.explanation))
  ) or exists (
    select 1
    from public.question_options option
    join az900_option_ids_before published on published.id = option.id
    where (option.option_text, option.explanation) is distinct from
      (pg_temp.az900_editorial_normalize(option.option_text), pg_temp.az900_editorial_normalize(option.explanation))
  ) then raise exception 'Known Portuguese editorial issue remains'; end if;
  if (select digest from az900_mock_snapshot_digest_before) <> (
    select md5(coalesce(string_agg(
      snapshot.id::text || snapshot.question_text_snapshot || snapshot.options_snapshot::text
      || coalesce(snapshot.question_explanation_snapshot, '') || snapshot.correct_option_key,
      '' order by snapshot.id), ''))
    from public.mock_exam_attempt_questions snapshot
  ) then raise exception 'Historical Mock snapshots changed'; end if;
end;
$$;

commit;

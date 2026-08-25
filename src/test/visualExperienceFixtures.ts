import type {
  ArchitectureVisualExperience,
  ComparisonVisualExperience,
  FlowVisualExperience,
  InvalidVisualExperience,
  ResponsibilityVisualExperience,
} from '../types/visualExperience'

const metadata = {
  lessonId: '22222222-2222-4222-8222-222222222222',
  description: 'Descrição acessível da experiência visual.',
  displayOrder: 1,
  isPublished: true,
  createdAt: '2026-08-25T12:00:00.000Z',
  updatedAt: '2026-08-25T12:00:00.000Z',
} as const

export function comparisonExperience(
  overrides: Partial<ComparisonVisualExperience> = {},
): ComparisonVisualExperience {
  return {
    ...metadata,
    id: '11111111-1111-4111-8111-111111111111',
    type: 'comparison',
    title: 'IaaS, PaaS e SaaS',
    config: {
      columns: [
        { id: 'iaas', title: 'IaaS', description: 'Maior controle do cliente.' },
        { id: 'paas', title: 'PaaS', description: 'Plataforma gerenciada.' },
        { id: 'saas', title: 'SaaS', description: 'Aplicação pronta para uso.' },
      ],
      rows: [
        {
          id: 'operating-system',
          label: 'Sistema operacional',
          values: {
            iaas: 'Gerenciado pelo cliente',
            paas: 'Gerenciado pelo Azure',
            saas: 'Gerenciado pelo provedor',
          },
        },
        {
          id: 'application',
          label: 'Aplicação',
          values: {
            iaas: 'Gerenciada pelo cliente',
            paas: 'Gerenciada pelo cliente',
            saas: 'Gerenciada pelo provedor',
          },
        },
      ],
    },
    ...overrides,
  }
}

export function architectureExperience(
  overrides: Partial<ArchitectureVisualExperience> = {},
): ArchitectureVisualExperience {
  return {
    ...metadata,
    id: '33333333-3333-4333-8333-333333333333',
    type: 'architecture',
    title: 'Arquitetura de aplicação',
    config: {
      nodes: [
        {
          id: 'internet',
          label: 'Internet',
          kind: 'external',
          description: 'Origem das requisições dos usuários.',
          x: 25,
          y: 50,
        },
        {
          id: 'api',
          label: 'API',
          kind: 'service',
          description: 'Recebe e processa o tráfego.',
          x: 75,
          y: 50,
        },
      ],
      edges: [
        {
          id: 'internet-to-api',
          source: 'internet',
          target: 'api',
          label: 'HTTPS',
        },
      ],
    },
    ...overrides,
  }
}

export function flowExperience(
  overrides: Partial<FlowVisualExperience> = {},
): FlowVisualExperience {
  return {
    ...metadata,
    id: '44444444-4444-4444-8444-444444444444',
    type: 'flow',
    title: 'Fluxo de autenticação',
    config: {
      steps: [
        { id: 'user', label: 'Usuário', description: 'Inicia o acesso.' },
        { id: 'sign-in', label: 'Entrar', description: 'Envia as credenciais.' },
        { id: 'token', label: 'Token', description: 'Autoriza a aplicação.' },
      ],
    },
    ...overrides,
  }
}

export function responsibilityExperience(
  overrides: Partial<ResponsibilityVisualExperience> = {},
): ResponsibilityVisualExperience {
  return {
    ...metadata,
    id: '66666666-6666-4666-8666-666666666666',
    type: 'responsibility',
    title: 'Modelo de responsabilidade compartilhada',
    config: {
      owners: {
        customer: { label: 'Você', description: 'Responsabilidade do cliente.' },
        provider: { label: 'Microsoft Azure', description: 'Responsabilidade do provedor.' },
        shared: { label: 'Compartilhada', description: 'Ambas as partes participam.' },
      },
      layers: [
        { id: 'data', label: 'Dados', description: 'Informações da organização.' },
        { id: 'applications', label: 'Aplicações', description: 'Software usado pelo negócio.' },
        { id: 'runtime', label: 'Runtime' },
        { id: 'operating-system', label: 'Sistema operacional' },
        { id: 'virtualization', label: 'Virtualização' },
        { id: 'servers', label: 'Servidores' },
        { id: 'storage', label: 'Armazenamento' },
        { id: 'networking', label: 'Rede' },
        { id: 'physical-datacenter', label: 'Datacenter físico' },
      ],
      models: [
        {
          id: 'on-premises',
          label: 'On-Premises',
          description: 'Você gerencia todas as camadas.',
          responsibilities: {
            data: 'customer',
            applications: 'customer',
            runtime: 'customer',
            'operating-system': 'customer',
            virtualization: 'customer',
            servers: 'customer',
            storage: 'customer',
            networking: 'customer',
            'physical-datacenter': 'customer',
          },
        },
        {
          id: 'iaas',
          label: 'IaaS',
          description: 'O provedor assume a infraestrutura física.',
          responsibilities: {
            data: 'customer',
            applications: 'customer',
            runtime: 'customer',
            'operating-system': 'customer',
            virtualization: 'provider',
            servers: 'provider',
            storage: 'provider',
            networking: 'provider',
            'physical-datacenter': 'provider',
          },
          example: 'Em uma VM do Azure, você mantém a aplicação e o sistema operacional.',
        },
        {
          id: 'paas',
          label: 'PaaS',
          description: 'Você se concentra nos dados e na aplicação.',
          responsibilities: {
            data: 'customer',
            applications: 'customer',
            runtime: 'provider',
            'operating-system': 'provider',
            virtualization: 'provider',
            servers: 'provider',
            storage: 'provider',
            networking: 'provider',
            'physical-datacenter': 'provider',
          },
        },
        {
          id: 'saas',
          label: 'SaaS',
          description: 'O provedor opera a aplicação; você ainda protege dados e acessos.',
          responsibilities: {
            data: 'customer',
            applications: 'shared',
            runtime: 'provider',
            'operating-system': 'provider',
            virtualization: 'provider',
            servers: 'provider',
            storage: 'provider',
            networking: 'provider',
            'physical-datacenter': 'provider',
          },
        },
      ],
      progression: {
        startLabel: 'Mais responsabilidade do cliente',
        endLabel: 'Mais responsabilidade do provedor',
      },
      exampleTitle: 'Exemplo para desenvolvedor .NET',
    },
    ...overrides,
  }
}

export function invalidExperience(
  overrides: Partial<InvalidVisualExperience> = {},
): InvalidVisualExperience {
  return {
    ...metadata,
    id: '55555555-5555-4555-8555-555555555555',
    type: 'invalid',
    originalType: 'simulation',
    title: 'Visualização inválida',
    ...overrides,
  }
}

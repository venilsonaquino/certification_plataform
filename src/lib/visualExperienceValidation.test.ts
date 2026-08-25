import { describe, expect, it } from 'vitest'

import {
  architectureExperience,
  comparisonExperience,
  flowExperience,
  responsibilityExperience,
} from '../test/visualExperienceFixtures'
import { parseVisualExperience } from './visualExperienceValidation'

describe('parseVisualExperience', () => {
  it.each([
    ['comparison', comparisonExperience()],
    ['architecture', architectureExperience()],
    ['flow', flowExperience()],
    ['responsibility', responsibilityExperience()],
  ] as const)('aceita uma configuração %s válida', (type, candidate) => {
    const result = parseVisualExperience(candidate)

    expect(result.success).toBe(true)
    expect(result.experience.type).toBe(type)
    expect(result.issues).toEqual([])
  })

  it('rejeita uma configuração incompatível com o tipo', () => {
    const candidate = {
      ...comparisonExperience(),
      config: { columns: [], rows: [] },
    }

    const result = parseVisualExperience(candidate)

    expect(result.success).toBe(false)
    expect(result.experience.type).toBe('invalid')
    expect(result.issues).not.toHaveLength(0)
  })

  it('rejeita um tipo desconhecido sem lançar exceção', () => {
    const candidate = {
      ...comparisonExperience(),
      type: 'simulation',
    }

    expect(() => parseVisualExperience(candidate)).not.toThrow()

    const result = parseVisualExperience(candidate)
    expect(result.success).toBe(false)
    expect(result.experience).toMatchObject({
      type: 'invalid',
      originalType: 'simulation',
    })
  })

  it.each([
    [
      'colunas de comparison',
      {
        ...comparisonExperience(),
        config: {
          ...comparisonExperience().config,
          columns: [
            { id: 'same-id', title: 'Primeira' },
            { id: 'same-id', title: 'Segunda' },
          ],
          rows: [
            {
              id: 'row',
              label: 'Critério',
              values: { 'same-id': 'Valor' },
            },
          ],
        },
      },
    ],
    [
      'nodes de architecture',
      {
        ...architectureExperience(),
        config: {
          nodes: [
            { id: 'same-id', label: 'Primeiro', kind: 'service' },
            { id: 'same-id', label: 'Segundo', kind: 'resource' },
          ],
          edges: [],
        },
      },
    ],
    [
      'steps de flow',
      {
        ...flowExperience(),
        config: {
          steps: [
            { id: 'same-id', label: 'Primeiro' },
            { id: 'same-id', label: 'Segundo' },
          ],
        },
      },
    ],
    [
      'camadas de responsibility',
      {
        ...responsibilityExperience(),
        config: {
          ...responsibilityExperience().config,
          layers: [
            { id: 'same-id', label: 'Primeira' },
            { id: 'same-id', label: 'Segunda' },
          ],
        },
      },
    ],
  ])('rejeita IDs duplicados em %s', (_scenario, candidate) => {
    const result = parseVisualExperience(candidate)

    expect(result.success).toBe(false)
    expect(result.issues.some((issue) => issue.includes('únicos'))).toBe(true)
  })

  it.each([
    [
      'valor ausente',
      {
        iaas: 'Gerenciado pelo cliente',
        paas: 'Gerenciado pelo Azure',
      },
    ],
    [
      'valor para coluna inexistente',
      {
        iaas: 'Gerenciado pelo cliente',
        paas: 'Gerenciado pelo Azure',
        saas: 'Gerenciado pelo provedor',
        unknown: 'Não deveria existir',
      },
    ],
  ])('rejeita comparison com %s', (_scenario, values) => {
    const base = comparisonExperience()
    const candidate = {
      ...base,
      config: {
        ...base.config,
        rows: [{ ...base.config.rows[0], values }],
      },
    }

    const result = parseVisualExperience(candidate)

    expect(result.success).toBe(false)
    expect(result.issues.some((issue) => issue.includes('coluna'))).toBe(true)
  })

  it.each([
    ['origem', { source: 'missing-node', target: 'api' }],
    ['destino', { source: 'internet', target: 'missing-node' }],
  ])('rejeita architecture com node de %s inexistente', (_scenario, endpoints) => {
    const base = architectureExperience()
    const candidate = {
      ...base,
      config: {
        ...base.config,
        edges: [{ ...base.config.edges[0], ...endpoints }],
      },
    }

    const result = parseVisualExperience(candidate)

    expect(result.success).toBe(false)
    expect(result.issues.some((issue) => issue.includes('não existe'))).toBe(true)
  })

  it.each([
    [
      'camada sem responsabilidade',
      { data: 'customer', applications: 'customer', 'operating-system': 'customer' },
    ],
    [
      'camada inexistente',
      {
        data: 'customer',
        applications: 'customer',
        'operating-system': 'customer',
        'physical-datacenter': 'provider',
        unknown: 'provider',
      },
    ],
    [
      'responsável desconhecido',
      {
        data: 'customer',
        applications: 'customer',
        'operating-system': 'customer',
        'physical-datacenter': 'vendor',
      },
    ],
  ])('rejeita responsibility com %s', (_scenario, responsibilities) => {
    const base = responsibilityExperience()
    const candidate = {
      ...base,
      config: {
        ...base.config,
        models: [{ ...base.config.models[0], responsibilities }],
      },
    }

    const result = parseVisualExperience(candidate)

    expect(result.success).toBe(false)
    expect(result.issues).not.toHaveLength(0)
  })

  it('rejeita responsibility com modelo sem identificador', () => {
    const base = responsibilityExperience()
    const { id, ...modelWithoutId } = base.config.models[0]
    const candidate = {
      ...base,
      config: { ...base.config, models: [modelWithoutId] },
    }

    expect(id).toBe('on-premises')
    expect(parseVisualExperience(candidate).success).toBe(false)
  })
})

import { describe, expect, it } from 'vitest'

import { CERTIFICATION_SECTIONS, certificationRoute } from '../lib/routes'
import { navigationItems } from './navigation'

describe('product navigation cleanup', () => {
  it('expõe somente os fluxos funcionais da certificação', () => {
    expect(navigationItems.map((item) => item.label)).toEqual([
      'Dashboard',
      'Estudo do Dia',
      'Trilha de estudos',
      'Revisão',
      'Simulados',
      'Readiness',
      'Progresso de estudo',
    ])
  })

  it('não mantém placeholders como seções válidas', () => {
    expect(navigationItems.map((item) => item.segment)).not.toEqual(
      expect.arrayContaining(['map', 'labs', 'story', 'quiz']),
    )
    expect(CERTIFICATION_SECTIONS).not.toEqual(
      expect.arrayContaining(['map', 'labs', 'story', 'quiz']),
    )
  })

  it('preserva a estrutura multi-certificação das rotas funcionais', () => {
    for (const section of CERTIFICATION_SECTIONS) {
      expect(certificationRoute('AZ-900', section))
        .toBe(`/certifications/az-900/${section}`)
    }
    expect(navigationItems.map((item) => item.segment)).toEqual([...CERTIFICATION_SECTIONS])
  })
})

import { render, screen } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({ getCertificationByCode: vi.fn() }))

vi.mock('../../services/certificationService', () => ({
  getCertificationByCode: mocks.getCertificationByCode,
}))

import { CertificationRoute } from './CertificationRoute'

function renderRoute(path = '/certifications/does-not-exist/readiness') {
  return render(
    <MemoryRouter initialEntries={[path]} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
      <Routes>
        <Route path="/certifications/:certificationCode" element={<CertificationRoute />}>
          <Route path="readiness" element={<p>Conteúdo privado</p>} />
        </Route>
      </Routes>
    </MemoryRouter>,
  )
}

describe('CertificationRoute', () => {
  beforeEach(() => mocks.getCertificationByCode.mockReset())

  it('trata certification code inválido sem renderizar conteúdo privado', async () => {
    mocks.getCertificationByCode.mockResolvedValue(null)
    renderRoute()
    expect(await screen.findByRole('heading', { name: 'Certificação não encontrada.' })).toBeInTheDocument()
    expect(screen.queryByText('Conteúdo privado')).not.toBeInTheDocument()
  })

})

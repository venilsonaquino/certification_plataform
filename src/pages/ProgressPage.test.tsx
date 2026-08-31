import { render, screen } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { ProgressPage } from './ProgressPage'

const useCertificationProgress = vi.fn()

vi.mock('../hooks/useCertification', () => ({
  useCertification: () => ({
    currentCertification: { code: 'az-900', name: 'Azure Fundamentals' },
  }),
}))

vi.mock('../hooks/useCertificationProgress', () => ({
  useCertificationProgress: () => useCertificationProgress(),
}))

describe('ProgressPage', () => {
  beforeEach(() => {
    useCertificationProgress.mockReturnValue({
      summary: {
        percentage: 50,
        completedCount: 1,
        totalCount: 2,
        remainingCount: 1,
        completedMinutes: 10,
        isCompleted: false,
        domainProgress: [],
      },
      loading: false,
      error: null,
      retry: vi.fn(),
    })
  })

  it('mantém o progresso curricular funcional e distinto de Readiness', () => {
    render(<ProgressPage />)

    expect(screen.getByRole('heading', { level: 1, name: 'Progresso de estudo' }))
      .toBeInTheDocument()
    expect(screen.getByText('1 / 2 aulas')).toBeInTheDocument()
    expect(screen.getByRole('progressbar', { name: 'Progresso total de estudo' }))
      .toHaveAttribute('aria-valuenow', '50')
    expect(screen.queryByText('Readiness')).not.toBeInTheDocument()
  })
})

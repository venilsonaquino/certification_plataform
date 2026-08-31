import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { StudyTodayPage } from './StudyTodayPage'

const useCertificationProgress = vi.fn()

vi.mock('../hooks/useCertification', () => ({
  useCertification: () => ({ currentCertification: { code: 'az-900' } }),
}))

vi.mock('../hooks/useCertificationProgress', () => ({
  useCertificationProgress: () => useCertificationProgress(),
}))

describe('StudyTodayPage product acceptance', () => {
  beforeEach(() => {
    useCertificationProgress.mockReturnValue({
      domains: [],
      progressByLessonId: new Map(),
      summary: { isCompleted: true, completedCount: 42 },
      loading: false,
      error: null,
      retry: vi.fn(),
    })
  })

  it('oferece próximos passos úteis quando todo o currículo foi concluído', () => {
    render(
      <MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
        <StudyTodayPage />
      </MemoryRouter>,
    )

    expect(screen.getByRole('heading', { name: 'Parabéns!' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Fazer Practice Mock' }))
      .toHaveAttribute('href', '/certifications/az-900/exams')
    expect(screen.getByRole('link', { name: 'Revisar pontos de atenção' }))
      .toHaveAttribute('href', '/certifications/az-900/review')
    expect(screen.getByRole('link', { name: 'Ver trilha concluída' }))
      .toHaveAttribute('href', '/certifications/az-900/study')
  })
})

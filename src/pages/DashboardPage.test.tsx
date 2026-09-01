import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'

import { DashboardPage } from './DashboardPage'

vi.mock('../hooks/useCertification', () => ({
  useCertification: () => ({ currentCertification: { id: 'c1', code: 'az-900', name: 'Azure Fundamentals' } }),
}))
vi.mock('../hooks/useCertificationProgress', () => ({
  useCertificationProgress: () => ({
    domains: [], progressByLessonId: new Map(), loading: false, error: null, retry: vi.fn(),
    summary: { percentage: 50, completedCount: 3, totalCount: 6, remainingCount: 3, completedMinutes: 30, lastActivity: null, isCompleted: false },
  }),
}))
vi.mock('../hooks/useFlashcardReviewOverview', () => ({
  useFlashcardReviewOverview: () => ({ loading: false, error: null, overview: { queueCount: 0, dueCount: 0, newCount: 0, nextReviewAt: null, availableFlashcardCount: 0, totalFlashcardCount: 0 } }),
}))
vi.mock('../hooks/useStudyProgression', () => ({
  useStudyProgression: () => ({
    progression: { journeyCompleted: false, nextAction: { kind: 'checkpoint', checkpoint: { topic: { id: 't1', title: 'Cloud Computing' }, status: 'available' } } },
    loading: false, error: null, retry: vi.fn(),
  }),
}))

describe('DashboardPage progressive action', () => {
  it('não cria CTA para Lesson bloqueada e aponta para o Checkpoint disponível', () => {
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><DashboardPage /></MemoryRouter>)
    expect(screen.getByText('Checkpoint do Tópico · disponível')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Fazer Checkpoint' })).toHaveAttribute('href', '/certifications/az-900/topics/t1/quiz')
  })
})

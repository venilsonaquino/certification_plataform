import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { StudyTodayPage } from './StudyTodayPage'

const useCertificationProgress = vi.fn()
const useStudyProgression = vi.fn()

vi.mock('../hooks/useCertification', () => ({
  useCertification: () => ({ currentCertification: { id: 'certification-id', code: 'az-900' } }),
}))

vi.mock('../hooks/useCertificationProgress', () => ({
  useCertificationProgress: () => useCertificationProgress(),
}))

vi.mock('../hooks/useStudyProgression', () => ({
  useStudyProgression: () => useStudyProgression(),
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
    useStudyProgression.mockReturnValue({
      progression: { journeyCompleted: true, nextAction: null, lessonById: new Map() },
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

  it('prioriza um Checkpoint disponível em vez de sugerir conteúdo bloqueado', () => {
    useCertificationProgress.mockReturnValue({
      domains: [], progressByLessonId: new Map(), summary: { isCompleted: false, completedCount: 3 }, loading: false, error: null, retry: vi.fn(),
    })
    useStudyProgression.mockReturnValue({
      progression: {
        journeyCompleted: false,
        lessonById: new Map(),
        nextAction: { kind: 'checkpoint', checkpoint: { topic: { id: 'topic-id', title: 'Cloud Computing' }, status: 'available', questionCount: 20, targetQuestionCount: 20, activeAnsweredCount: 0, activeTotalQuestions: null } },
      },
      loading: false, error: null, retry: vi.fn(),
    })

    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><StudyTodayPage /></MemoryRouter>)

    expect(screen.getByRole('heading', { name: 'Checkpoint: Cloud Computing' })).toBeInTheDocument()
    expect(screen.getByText('As aulas deste tópico foram concluídas. Responda 20 questões para liberar o próximo tópico.')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Fazer Checkpoint' })).toHaveAttribute('href', '/certifications/az-900/topics/topic-id/quiz')
  })
})

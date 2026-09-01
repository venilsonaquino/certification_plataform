import { render, screen } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { TopicQuizPage } from './TopicQuizPage'

const mocks = vi.hoisted(() => ({
  useTopicQuiz: vi.fn(),
  useStudyProgression: vi.fn(),
}))

vi.mock('../hooks/useCertification', () => ({
  useCertification: () => ({ currentCertification: { id: 'c1', code: 'az-900' } }),
}))
vi.mock('../hooks/useCertificationProgress', () => ({
  useCertificationProgress: () => ({
    domains: [{ id: 'd1', topics: [{ id: 't1', title: 'Cloud Computing', lessons: [{ id: 'l1' }, { id: 'l2' }] }] }],
    progressByLessonId: new Map(), loading: false, error: null, retry: vi.fn(),
  }),
}))
vi.mock('../hooks/useStudyProgression', () => ({ useStudyProgression: mocks.useStudyProgression }))
vi.mock('../hooks/useTopicQuiz', () => ({ useTopicQuiz: mocks.useTopicQuiz }))

describe('TopicQuizPage as Topic Checkpoint', () => {
  beforeEach(() => {
    mocks.useTopicQuiz.mockReset()
    mocks.useStudyProgression.mockReturnValue({
      progression: { checkpointByTopicId: new Map([['t1', { status: 'locked', remainingLessonCount: 2 }]]) },
      loading: false, error: null, retry: vi.fn(),
    })
  })

  it('intercepta deep link bloqueado antes de iniciar uma tentativa', () => {
    render(
      <MemoryRouter initialEntries={['/certifications/az-900/topics/t1/quiz']} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
        <Routes><Route path="/certifications/:certificationCode/topics/:topicId/quiz" element={<TopicQuizPage />} /></Routes>
      </MemoryRouter>,
    )

    expect(screen.getByText('Este Checkpoint ainda está bloqueado.')).toBeInTheDocument()
    expect(screen.getByText('Conclua as 2 aulas restantes deste tópico para liberar o Checkpoint.')).toBeInTheDocument()
    expect(mocks.useTopicQuiz).not.toHaveBeenCalled()
  })
})

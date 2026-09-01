import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import type { LessonQuizAttemptData } from '../../types/quiz'
import { TopicQuizResult } from './TopicQuizResult'

const getTopicQuizResult = vi.fn()

vi.mock('../../services/quizService', () => ({
  getTopicQuizResult: (...args: unknown[]) => getTopicQuizResult(...args),
}))

const data: LessonQuizAttemptData = {
  attempt: {
    id: 'attempt-1', userId: 'user-1', certificationId: 'cert-1', quizType: 'topic',
    lessonId: null, topicId: 'topic-1', status: 'completed', totalQuestions: 20,
    correctAnswers: 16, scorePercentage: 80, startedAt: '2026-09-01T12:00:00.000Z',
    completedAt: '2026-09-01T12:10:00.000Z', createdAt: '2026-09-01T12:00:00.000Z',
    updatedAt: '2026-09-01T12:10:00.000Z',
  },
  questions: [],
}

describe('TopicQuizResult', () => {
  beforeEach(() => getTopicQuizResult.mockResolvedValue([]))

  it('oferece a próxima aula após concluir o Checkpoint', () => {
    render(
      <MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
        <TopicQuizResult
          data={data}
          certificationCode="az-900"
          restarting={false}
          onRestart={vi.fn()}
          nextLessonRoute="/certifications/az-900/study/proxima-aula"
        />
      </MemoryRouter>,
    )

    expect(screen.getByRole('link', { name: 'Ir para a próxima aula' }))
      .toHaveAttribute('href', '/certifications/az-900/study/proxima-aula')
    expect(screen.getByRole('button', { name: 'Refazer Checkpoint' })).toBeInTheDocument()
  })

  it('não mostra uma navegação inexistente após o último tópico', () => {
    render(
      <MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
        <TopicQuizResult data={data} certificationCode="az-900" restarting={false} onRestart={vi.fn()} nextLessonRoute={null} />
      </MemoryRouter>,
    )

    expect(screen.queryByRole('link', { name: 'Ir para a próxima aula' })).not.toBeInTheDocument()
  })
})

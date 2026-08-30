import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import type { MockExamAttempt, MockExamQuestionForReview } from '../types/mockExam'

const mocks = vi.hoisted(() => ({ useCertification: vi.fn(), getMockExamAttempt: vi.fn(), getMockExamReview: vi.fn() }))
vi.mock('../hooks/useCertification', () => ({ useCertification: mocks.useCertification }))
vi.mock('../services/mockExamService', () => ({ getMockExamAttempt: mocks.getMockExamAttempt, getMockExamReview: mocks.getMockExamReview }))

import { MockExamReviewPage } from './MockExamReviewPage'

const attempt = { id: 'attempt-1', certificationId: 'cert-1', status: 'completed', totalQuestions: 3 } as MockExamAttempt
const base: MockExamQuestionForReview = {
  id: 'r1', attemptId: 'attempt-1', questionId: 'q1', displayOrder: 1,
  domainId: 'd1', domainTitle: 'Domain', topicId: 't1', topicTitle: 'Topic',
  lessonId: 'l1', lessonTitle: 'Lesson', lessonSlug: 'lesson', difficulty: 'easy',
  questionText: 'Question 1?', options: [{ key: 'A', text: 'A', displayOrder: 1 }, { key: 'B', text: 'B', displayOrder: 2 }],
  selectedOptionKey: 'A', correctOptionKey: 'B', status: 'incorrect', explanation: 'Explicação 1',
}
const review: MockExamQuestionForReview[] = [
  base,
  { ...base, id: 'r2', questionId: 'q2', displayOrder: 2, questionText: 'Question 2?', selectedOptionKey: null, status: 'unanswered' },
  { ...base, id: 'r3', questionId: 'q3', displayOrder: 3, questionText: 'Question 3?', selectedOptionKey: 'B', status: 'correct' },
]

describe('MockExamReviewPage', () => {
  beforeEach(() => {
    Object.values(mocks).forEach((mock) => mock.mockReset())
    mocks.useCertification.mockReturnValue({ currentCertification: { id: 'cert-1', code: 'az-900' } })
    mocks.getMockExamAttempt.mockResolvedValue(attempt)
    mocks.getMockExamReview.mockResolvedValue(review)
  })

  it('começa em Incorrect + Unanswered e filtra All/Incorrect/Unanswered/Correct', async () => {
    render(<MemoryRouter initialEntries={['/certifications/az-900/exams/attempt-1/review']} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><Routes><Route path="/certifications/:certificationCode/exams/:attemptId/review" element={<MockExamReviewPage />} /></Routes></MemoryRouter>)
    expect(await screen.findByText('2 de 3 Questions exibidas')).toBeInTheDocument()
    expect(screen.getByText('Question 1?')).toBeInTheDocument()
    expect(screen.queryByText('Question 3?')).not.toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'All' }))
    expect(screen.getByText('3 de 3 Questions exibidas')).toBeInTheDocument()
    expect(screen.getByText('Question 3?')).toBeInTheDocument()
    await userEvent.click(screen.getByRole('button', { name: 'Incorrect' }))
    expect(screen.getByText('1 de 3 Questions exibidas')).toBeInTheDocument()
    expect(screen.getByText('Question 1?')).toBeInTheDocument()
    await userEvent.click(screen.getByRole('button', { name: 'Unanswered' }))
    expect(screen.getByText('Question 2?')).toBeInTheDocument()
    await userEvent.click(screen.getByRole('button', { name: 'Correct' }))
    expect(screen.getByText('Question 3?')).toBeInTheDocument()
  })
})

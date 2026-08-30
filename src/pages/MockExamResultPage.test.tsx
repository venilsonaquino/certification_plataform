import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import type { MockExamAttempt, MockExamResult } from '../types/mockExam'

const mocks = vi.hoisted(() => ({ useCertification: vi.fn(), getMockExamAttempt: vi.fn(), getMockExamResult: vi.fn() }))
vi.mock('../hooks/useCertification', () => ({ useCertification: mocks.useCertification }))
vi.mock('../services/mockExamService', () => ({ getMockExamAttempt: mocks.getMockExamAttempt, getMockExamResult: mocks.getMockExamResult }))

import { MockExamResultPage } from './MockExamResultPage'

const completedAttempt = { id: 'attempt-1', certificationId: 'cert-1', status: 'completed', totalQuestions: 40 } as MockExamAttempt
const breakdown = { totalQuestions: 40, correctAnswers: 30, incorrectAnswers: 5, unansweredQuestions: 5, percentage: 75 }
const result: MockExamResult = {
  attemptId: 'attempt-1', totalQuestions: 40, answeredQuestions: 35,
  correctAnswers: 30, incorrectAnswers: 5, unansweredQuestions: 5,
  practiceScorePercentage: 75, startedAt: '2026-08-30T10:00:00Z', submittedAt: '2026-08-30T11:00:00Z', elapsedSeconds: 3600,
  domains: [{ domainId: 'd1', domainTitle: 'Cloud Concepts', ...breakdown }],
  topics: [{ domainId: 'd1', domainTitle: 'Cloud Concepts', topicId: 't1', topicTitle: 'Cloud Benefits', ...breakdown }],
  difficulties: [{ difficulty: 'medium', ...breakdown }],
}

function renderPage() {
  return render(<MemoryRouter initialEntries={['/certifications/az-900/exams/attempt-1/result']} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><Routes>
    <Route path="/certifications/:certificationCode/exams/:attemptId/result" element={<MockExamResultPage />} />
    <Route path="/certifications/:certificationCode/exams/:attemptId/review" element={<p>Review aberto</p>} />
    <Route path="/certifications/:certificationCode/exams/:attemptId" element={<p>Runner aberto</p>} />
  </Routes></MemoryRouter>)
}

describe('MockExamResultPage', () => {
  beforeEach(() => {
    Object.values(mocks).forEach((mock) => mock.mockReset())
    mocks.useCertification.mockReturnValue({ currentCertification: { id: 'cert-1', code: 'az-900' } })
    mocks.getMockExamAttempt.mockResolvedValue(completedAttempt)
    mocks.getMockExamResult.mockResolvedValue(result)
  })

  it('mostra Practice Score, totais e breakdowns sem benchmark oficial', async () => {
    renderPage()
    expect(await screen.findByRole('heading', { name: '75%' })).toBeInTheDocument()
    expect(screen.getAllByText('30 / 40 correct')).toHaveLength(4)
    expect(screen.getByText('Incorrect').parentElement).toHaveTextContent('5')
    expect(screen.getByText('Unanswered').parentElement).toHaveTextContent('5')
    expect(screen.getByText('Cloud Concepts')).toBeInTheDocument()
    expect(screen.getByText('Cloud Benefits')).toBeInTheDocument()
    expect(screen.getByText('Medium')).toBeInTheDocument()
    expect(screen.getByText(/não representa a pontuação oficial/)).toBeInTheDocument()
    expect(screen.queryByText(/passed|failed|800\/1000/i)).not.toBeInTheDocument()
  })

  it('abre Review e redireciona Attempts em andamento para execução', async () => {
    const { unmount } = renderPage()
    await userEvent.click(await screen.findByRole('link', { name: 'Review Questions' }))
    expect(screen.getByText('Review aberto')).toBeInTheDocument()
    unmount()

    mocks.getMockExamAttempt.mockResolvedValue({ ...completedAttempt, status: 'in_progress' })
    mocks.getMockExamResult.mockClear()
    renderPage()
    expect(await screen.findByText('Runner aberto')).toBeInTheDocument()
    expect(mocks.getMockExamResult).not.toHaveBeenCalled()
  })
})

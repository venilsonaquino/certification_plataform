import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import type { MockExamAttempt, MockExamQuestionForExecution } from '../types/mockExam'

const mocks = vi.hoisted(() => ({
  useCertification: vi.fn(),
  getMockExamAttempt: vi.fn(),
  loadMockExamAttempt: vi.fn(),
  saveMockExamAnswer: vi.fn(),
  submitMockExam: vi.fn(),
  getMockExamResult: vi.fn(),
  getMockExamReview: vi.fn(),
}))

vi.mock('../hooks/useCertification', () => ({ useCertification: mocks.useCertification }))
vi.mock('../services/mockExamService', () => ({
  getMockExamAttempt: mocks.getMockExamAttempt,
  loadMockExamAttempt: mocks.loadMockExamAttempt,
  saveMockExamAnswer: mocks.saveMockExamAnswer,
  submitMockExam: mocks.submitMockExam,
  getMockExamResult: mocks.getMockExamResult,
  getMockExamReview: mocks.getMockExamReview,
}))

import { MockExamExecutionPage } from './MockExamExecutionPage'
import { MockExamResultPage } from './MockExamResultPage'
import { MockExamReviewPage } from './MockExamReviewPage'

const attempt: MockExamAttempt = {
  id: 'attempt-1',
  userId: 'user-1',
  certificationId: 'certification-1',
  status: 'in_progress',
  totalQuestions: 40,
  answeredQuestions: 0,
  correctAnswers: null,
  incorrectAnswers: null,
  unansweredQuestions: null,
  practiceScorePercentage: null,
  startedAt: '2026-08-30T12:00:00.000Z',
  submittedAt: null,
  abandonedAt: null,
  expiresAt: null,
  timeLimitSeconds: null,
  elapsedSeconds: null,
  lastActivityAt: '2026-08-30T12:00:00.000Z',
  selectionPolicyVersion: 'az900-mock-v1',
  domainAllocation: { 1: 11, 2: 15, 3: 14 },
  difficultyAllocation: { easy: 12, medium: 20, hard: 8 },
  createdAt: '2026-08-30T12:00:00.000Z',
  updatedAt: '2026-08-30T12:00:00.000Z',
}

const questions: MockExamQuestionForExecution[] = Array.from({ length: 40 }, (_, index) => ({
  id: `snapshot-${index + 1}`,
  attemptId: attempt.id,
  questionId: `source-${index + 1}`,
  displayOrder: index + 1,
  questionText: `Enunciado seguro ${index + 1}`,
  options: [
    { key: 'A', text: `Opção A da ${index + 1}`, displayOrder: 1 },
    { key: 'B', text: `Opção B da ${index + 1}`, displayOrder: 2 },
  ],
  selectedOptionKey: index === 1 ? 'A' : null,
  answeredAt: index === 1 ? '2026-08-30T12:01:00.000Z' : null,
}))

function renderPage() {
  return render(
    <MemoryRouter initialEntries={['/certifications/az-900/exams/attempt-1']} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
      <Routes>
        <Route path="/certifications/:certificationCode/exams/:attemptId" element={<MockExamExecutionPage />} />
        <Route path="/certifications/:certificationCode/exams/:attemptId/result" element={<p>Resultado mínimo</p>} />
      </Routes>
    </MemoryRouter>,
  )
}

describe('MockExamExecutionPage', () => {
  beforeEach(() => {
    Object.values(mocks).forEach((mock) => mock.mockReset())
    sessionStorage.clear()
    mocks.useCertification.mockReturnValue({ currentCertification: { id: 'certification-1', code: 'az-900' } })
    mocks.getMockExamAttempt.mockResolvedValue(attempt)
    mocks.loadMockExamAttempt.mockResolvedValue({ attempt, questions })
    mocks.saveMockExamAnswer.mockImplementation(({ attemptQuestionId, selectedOptionKey }) => Promise.resolve({
      id: `answer-${attemptQuestionId}`,
      attemptId: attempt.id,
      attemptQuestionId,
      selectedOptionKey,
      answeredAt: '2026-08-30T12:02:00.000Z',
    }))
    mocks.submitMockExam.mockResolvedValue({ ...attempt, status: 'completed' })
  })

  it('carrega as mesmas 40 Questions, navega e persiste alterações sem feedback', async () => {
    renderPage()
    expect(await screen.findByText('Enunciado seguro 1')).toBeInTheDocument()
    expect(screen.getByText((_, element) => element?.tagName === 'P' && element.textContent?.includes('1 respondidas') === true)).toBeInTheDocument()

    await userEvent.click(screen.getByRole('radio', { name: 'Opção B da 1' }))
    await waitFor(() => expect(mocks.saveMockExamAnswer).toHaveBeenCalledWith({
      attemptId: attempt.id,
      attemptQuestionId: 'snapshot-1',
      selectedOptionKey: 'B',
    }))
    expect(await screen.findByText('Resposta salva.')).toBeInTheDocument()
    expect(screen.queryByText(/correct|incorrect|explanation/i)).not.toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'Next' }))
    expect(screen.getByText('Enunciado seguro 2')).toBeInTheDocument()
    await userEvent.click(screen.getByRole('radio', { name: 'Opção B da 2' }))
    await waitFor(() => expect(mocks.saveMockExamAnswer).toHaveBeenLastCalledWith(expect.objectContaining({ selectedOptionKey: 'B' })))
    await userEvent.click(screen.getByRole('radio', { name: 'Opção A da 2' }))
    await waitFor(() => expect(mocks.saveMockExamAnswer).toHaveBeenLastCalledWith(expect.objectContaining({ selectedOptionKey: 'A' })))

    await userEvent.click(screen.getByRole('button', { name: 'Question 7, não respondida' }))
    expect(screen.getByText('Enunciado seguro 7')).toBeInTheDocument()
    await userEvent.click(screen.getByRole('button', { name: 'Previous' }))
    expect(screen.getByText('Enunciado seguro 6')).toBeInTheDocument()
  })

  it('mantém a posição não crítica no refresh e recupera respostas do servidor', async () => {
    sessionStorage.setItem(`mock-position:${attempt.id}`, '5')
    renderPage()
    expect(await screen.findByText('Enunciado seguro 6')).toBeInTheDocument()
    expect(mocks.loadMockExamAttempt).toHaveBeenCalledWith(attempt.id)
    expect(screen.getByRole('button', { name: 'Question 2, respondida' })).toBeInTheDocument()
  })

  it('não finge persistência em falha e oferece retry', async () => {
    vi.spyOn(console, 'error').mockImplementation(() => undefined)
    mocks.saveMockExamAnswer.mockRejectedValueOnce(new Error('network'))
    renderPage()
    await userEvent.click(await screen.findByRole('radio', { name: 'Opção A da 1' }))

    expect(await screen.findByRole('button', { name: 'Tentar salvar' })).toBeInTheDocument()
    expect(screen.getByText((_, element) => element?.tagName === 'P' && element.textContent?.includes('1 respondidas') === true)).toBeInTheDocument()
    await userEvent.click(screen.getByRole('button', { name: 'Tentar salvar' }))
    await waitFor(() => expect(mocks.saveMockExamAnswer).toHaveBeenCalledTimes(2))
  })

  it('resume o resumo, confirma submit uma vez e abre o estado mínimo', async () => {
    renderPage()
    await userEvent.click(await screen.findByRole('button', { name: 'Finalizar' }))
    expect(screen.getByText('Unanswered').parentElement).toHaveTextContent('39')

    await userEvent.click(screen.getByRole('button', { name: 'Submit Mock' }))
    expect(screen.getByRole('dialog')).toHaveTextContent('39 não respondidas')
    await userEvent.click(screen.getByRole('button', { name: 'Confirmar envio' }))
    expect(mocks.submitMockExam).toHaveBeenCalledOnce()
    expect(await screen.findByText('Resultado mínimo')).toBeInTheDocument()
  })

  it('redireciona attempt completado sem carregar Questions editáveis', async () => {
    mocks.getMockExamAttempt.mockResolvedValue({ ...attempt, status: 'completed' })
    renderPage()
    expect(await screen.findByText('Resultado mínimo')).toBeInTheDocument()
    expect(mocks.loadMockExamAttempt).not.toHaveBeenCalled()
  })

  it('integra execution, submit, persisted result e completed Review', async () => {
    const completedAttempt = {
      ...attempt,
      status: 'completed' as const,
      answeredQuestions: 1,
      correctAnswers: 1,
      incorrectAnswers: 0,
      unansweredQuestions: 39,
      practiceScorePercentage: 2.5,
      submittedAt: '2026-08-30T12:10:00.000Z',
    }
    mocks.getMockExamAttempt
      .mockResolvedValueOnce(attempt)
      .mockResolvedValue(completedAttempt)
    const summary = { totalQuestions: 40, correctAnswers: 1, incorrectAnswers: 0, unansweredQuestions: 39, percentage: 2.5 }
    mocks.getMockExamResult.mockResolvedValue({
      attemptId: attempt.id, totalQuestions: 40, answeredQuestions: 1,
      correctAnswers: 1, incorrectAnswers: 0, unansweredQuestions: 39,
      practiceScorePercentage: 2.5, startedAt: attempt.startedAt,
      submittedAt: completedAttempt.submittedAt, elapsedSeconds: 600,
      domains: [{ domainId: 'domain-1', domainTitle: 'Cloud Concepts', ...summary }],
      topics: [{ domainId: 'domain-1', domainTitle: 'Cloud Concepts', topicId: 'topic-1', topicTitle: 'Cloud Benefits', ...summary }],
      difficulties: [{ difficulty: 'medium', ...summary }],
    })
    mocks.getMockExamReview.mockResolvedValue(questions.map((question, index) => ({
      ...question,
      domainId: 'domain-1', domainTitle: 'Cloud Concepts', topicId: 'topic-1',
      topicTitle: 'Cloud Benefits', lessonId: 'lesson-1', lessonTitle: 'Benefits',
      lessonSlug: 'benefits', difficulty: 'medium' as const,
      selectedOptionKey: index === 0 ? 'A' : null, correctOptionKey: 'A',
      status: index === 0 ? 'correct' as const : 'unanswered' as const,
      explanation: 'Snapshot explanation.',
    })))

    render(
      <MemoryRouter initialEntries={['/certifications/az-900/exams/attempt-1']} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
        <Routes>
          <Route path="/certifications/:certificationCode/exams/:attemptId" element={<MockExamExecutionPage />} />
          <Route path="/certifications/:certificationCode/exams/:attemptId/result" element={<MockExamResultPage />} />
          <Route path="/certifications/:certificationCode/exams/:attemptId/review" element={<MockExamReviewPage />} />
        </Routes>
      </MemoryRouter>,
    )

    await userEvent.click(await screen.findByRole('button', { name: 'Finalizar' }))
    await userEvent.click(screen.getByRole('button', { name: 'Submit Mock' }))
    await userEvent.click(screen.getByRole('button', { name: 'Confirmar envio' }))
    expect(await screen.findByRole('heading', { name: 'AZ-900 Practice Mock Result' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: '2.5%' })).toBeInTheDocument()
    await userEvent.click(screen.getByRole('link', { name: 'Review Questions' }))
    expect(await screen.findByRole('heading', { name: 'Review Questions' })).toBeInTheDocument()
    expect(screen.getByText('39 de 40 Questions exibidas')).toBeInTheDocument()
  })
})

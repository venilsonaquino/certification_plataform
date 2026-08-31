import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it } from 'vitest'

import type { MockExamQuestionForReview } from '../../types/mockExam'
import { MockReviewQuestionCard } from './MockReviewQuestionCard'

const question: MockExamQuestionForReview = {
  id: 'review-1', attemptId: 'attempt-1', questionId: 'question-1', displayOrder: 3,
  domainId: 'domain-1', domainTitle: 'Azure Architecture and Services',
  topicId: 'topic-1', topicTitle: 'Azure Networking Services',
  lessonId: 'lesson-1', lessonTitle: 'Virtual Networks', lessonSlug: 'virtual-networks',
  difficulty: 'medium', questionText: 'Qual opção atende ao requisito?',
  options: [
    { key: 'A', text: 'Opção selecionada', displayOrder: 1 },
    { key: 'B', text: 'Opção correta', displayOrder: 2 },
  ],
  selectedOptionKey: 'A', correctOptionKey: 'B', status: 'incorrect',
  explanation: 'A opção B atende ao requisito técnico.',
}

describe('MockReviewQuestionCard', () => {
  it('identifica seleção, resposta correta, status e contexto sem depender só de cor', () => {
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><MockReviewQuestionCard question={question} certificationCode="az-900" /></MemoryRouter>)
    expect(screen.getByLabelText('Status da resposta: Incorreta')).toBeInTheDocument()
    expect(screen.getByText('Opção selecionada').parentElement).toHaveTextContent('Sua resposta')
    expect(screen.getByText('Opção correta').parentElement).toHaveTextContent('Resposta correta')
    expect(screen.getByLabelText('Explicação')).toHaveTextContent('A opção B atende')
    expect(screen.getByText(/Azure Networking Services/)).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Revisar aula' })).toHaveAttribute('href', '/certifications/az-900/study/virtual-networks')
    expect(screen.queryByRole('radio')).not.toBeInTheDocument()
  })

  it('anuncia unanswered separadamente', () => {
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><MockReviewQuestionCard question={{ ...question, selectedOptionKey: null, status: 'unanswered' }} certificationCode="az-900" /></MemoryRouter>)
    expect(screen.getByLabelText('Status da resposta: Não respondida')).toBeInTheDocument()
    expect(screen.getByText('Você não respondeu esta questão.')).toBeInTheDocument()
  })
})

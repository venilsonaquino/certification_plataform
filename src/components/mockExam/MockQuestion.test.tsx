import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import type { MockExamAnswerState, MockExamQuestionForExecution } from '../../types/mockExam'
import { MockQuestion } from './MockQuestion'

const question: MockExamQuestionForExecution = {
  id: 'question-snapshot-1',
  attemptId: 'attempt-1',
  questionId: 'question-1',
  displayOrder: 1,
  questionText: 'Qual opção atende ao cenário?',
  options: [
    { key: 'A', text: 'Opção A', displayOrder: 1 },
    { key: 'B', text: 'Opção B', displayOrder: 2 },
  ],
  selectedOptionKey: null,
  answeredAt: null,
}

const idleAnswer: MockExamAnswerState = {
  selectedOptionKey: null,
  persistedOptionKey: null,
  status: 'idle',
  error: null,
}

describe('MockQuestion', () => {
  it('usa radios e salva uma seleção sem revelar feedback pedagógico', async () => {
    const onSelect = vi.fn()
    render(<MockQuestion question={question} answer={idleAnswer} onSelect={onSelect} onRetry={vi.fn()} />)

    const option = screen.getByRole('radio', { name: 'Opção B' })
    await userEvent.click(option)

    expect(onSelect).toHaveBeenCalledWith('B')
    expect(screen.queryByText(/correct|incorrect|explanation|resposta correta/i)).not.toBeInTheDocument()
  })

  it('informa falha de persistência e permite retry', async () => {
    const onRetry = vi.fn()
    render(
      <MockQuestion
        question={question}
        answer={{ ...idleAnswer, selectedOptionKey: 'A', status: 'error', error: 'Ainda não salva.' }}
        onSelect={vi.fn()}
        onRetry={onRetry}
      />,
    )

    await userEvent.click(screen.getByRole('button', { name: 'Tentar salvar' }))
    expect(onRetry).toHaveBeenCalledOnce()
    expect(screen.getByRole('radio', { name: 'Opção A' })).toBeChecked()
  })
})

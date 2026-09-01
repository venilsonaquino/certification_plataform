import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'

import type { Flashcard, FlashcardReviewResult } from '../../types/flashcard'
import { FlashcardViewer } from './FlashcardViewer'

const stamp = '2026-08-31T12:00:00.000Z'
const cards: readonly Flashcard[] = [1, 2].map((index) => ({
  id: `card-${index}`, lessonId: 'lesson-1', frontText: `Pergunta ${index}`, backText: `Resposta ${index}`, hint: null, displayOrder: index, isPublished: true, createdAt: stamp, updatedAt: stamp,
}))

function reviewResult(flashcardId: string): FlashcardReviewResult {
  return {
    review: { id: `review-${flashcardId}`, userId: 'u1', flashcardId, rating: 'good', reviewedAt: stamp, createdAt: stamp },
    progress: { id: `progress-${flashcardId}`, userId: 'u1', flashcardId, lastRating: 'good', reviewCount: 1, successfulReviewCount: 1, intervalDays: 4, nextReviewAt: '2026-09-04T12:00:00.000Z', lastReviewedAt: stamp, createdAt: stamp, updatedAt: stamp },
  }
}

describe('FlashcardViewer modes', () => {
  it('faz estudo livre por flip/next sem persistir ratings ou schedule', async () => {
    const user = userEvent.setup()
    const submitReview = vi.fn()
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><FlashcardViewer cards={cards} mode="study" returnRoute="/flashcards" submitReview={submitReview} /></MemoryRouter>)

    await user.click(screen.getByRole('button', { name: 'Ver resposta' }))
    expect(screen.queryByText('Como foi?')).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Próximo card' }))
    await user.click(screen.getByRole('button', { name: 'Ver resposta' }))
    await user.click(screen.getByRole('button', { name: 'Concluir estudo' }))

    expect(screen.getByRole('heading', { name: 'Sessão concluída' })).toBeInTheDocument()
    expect(screen.getByText('2 flashcards estudados')).toBeInTheDocument()
    expect(screen.getByText('O estudo livre não altera a agenda de repetição espaçada.')).toBeInTheDocument()
    expect(submitReview).not.toHaveBeenCalled()
  })

  it('mantém ratings e persistência no modo de revisão diária', async () => {
    const user = userEvent.setup()
    const submitReview = vi.fn(async (flashcardId: string) => reviewResult(flashcardId))
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><FlashcardViewer cards={[cards[0]]} mode="review" returnRoute="/flashcards" submitReview={submitReview} /></MemoryRouter>)

    await user.click(screen.getByRole('button', { name: 'Ver resposta' }))
    await user.click(screen.getByRole('button', { name: /Sabia/ }))

    expect(await screen.findByRole('heading', { name: 'Sessão concluída' })).toBeInTheDocument()
    expect(submitReview).toHaveBeenCalledWith('card-1', 'good')
    expect(screen.getByText(/Próxima revisão agendada/)).toBeInTheDocument()
  })
})

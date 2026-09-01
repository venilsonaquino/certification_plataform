import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { DailyFlashcardReviewPage } from './DailyFlashcardReviewPage'

const mocks = vi.hoisted(() => ({ queue: vi.fn(), viewer: vi.fn() }))
vi.mock('../hooks/useCertification', () => ({ useCertification: () => ({ currentCertification: { id: 'c1', code: 'az-900' } }) }))
vi.mock('../hooks/useFlashcardReviewQueue', () => ({ useFlashcardReviewQueue: () => mocks.queue() }))
vi.mock('../components/flashcards/FlashcardViewer', () => ({ FlashcardViewer: (props: unknown) => { mocks.viewer(props); return <div>Viewer diário</div> } }))

const card = { id: 'card-1', lessonId: 'l1', lessonTitle: 'Lesson', lessonSlug: 'lesson', frontText: 'Front', backText: 'Back', hint: null, displayOrder: 1, isPublished: true, createdAt: '2026-08-31T00:00:00Z', updatedAt: '2026-08-31T00:00:00Z', reviewStatus: 'due', nextReviewAt: '2026-08-30T00:00:00Z' }

describe('DailyFlashcardReviewPage', () => {
  beforeEach(() => { mocks.viewer.mockReset() })

  it('preserva fila due/new e retorna ao novo hub', () => {
    mocks.queue.mockReturnValue({ cards: [card, { ...card, id: 'card-2', reviewStatus: 'new' }], overview: { queueCount: 2, dueCount: 1, newCount: 1, nextReviewAt: null, availableFlashcardCount: 2, totalFlashcardCount: 2 }, loading: false, error: null, retry: vi.fn() })
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><DailyFlashcardReviewPage /></MemoryRouter>)
    expect(screen.getByText('1 vencidos · 1 novos')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Voltar para Flashcards' })).toHaveAttribute('href', '/certifications/az-900/flashcards')
    expect(mocks.viewer).toHaveBeenCalledWith(expect.objectContaining({ returnRoute: '/certifications/az-900/flashcards', completionTitle: 'Revisão concluída' }))
  })

  it('mostra próxima revisão no empty state', () => {
    mocks.queue.mockReturnValue({ cards: [], overview: { queueCount: 0, dueCount: 0, newCount: 0, nextReviewAt: '2026-09-05T00:00:00Z', availableFlashcardCount: 2, totalFlashcardCount: 2 }, loading: false, error: null, retry: vi.fn() })
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><DailyFlashcardReviewPage /></MemoryRouter>)
    expect(screen.getByText('Tudo em dia!')).toBeInTheDocument()
    expect(screen.getByText(/próxima revisão está agendada/)).toBeInTheDocument()
  })
})

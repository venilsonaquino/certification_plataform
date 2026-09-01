import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { FlashcardsPage } from './FlashcardsPage'

const mocks = vi.hoisted(() => ({ catalog: vi.fn(), overview: vi.fn() }))
vi.mock('../hooks/useCertification', () => ({ useCertification: () => ({ currentCertification: { id: 'c1', code: 'az-900' } }) }))
vi.mock('../hooks/useFlashcardCatalog', () => ({ useFlashcardCatalog: () => mocks.catalog() }))
vi.mock('../hooks/useFlashcardReviewOverview', () => ({ useFlashcardReviewOverview: () => mocks.overview() }))

describe('FlashcardsPage', () => {
  beforeEach(() => {
    mocks.catalog.mockReturnValue({
      domains: [{ domainId: 'd1', title: 'Cloud Concepts', displayOrder: 1, availableCount: 3, totalCount: 7, studiedCount: 1, topics: [
        { topicId: 't1', title: 'Cloud Computing', displayOrder: 1, availableCount: 3, totalCount: 3, studiedCount: 1 },
        { topicId: 't2', title: 'Cloud Benefits', displayOrder: 2, availableCount: 0, totalCount: 4, studiedCount: 0 },
      ] }],
      loading: false, error: null, retry: vi.fn(),
    })
    mocks.overview.mockReturnValue({ overview: { queueCount: 3, dueCount: 2, newCount: 1, nextReviewAt: null, availableFlashcardCount: 3, totalFlashcardCount: 7 }, loading: false, error: null, retry: vi.fn() })
  })

  it('separa revisão diária de estudo livre e respeita counts desbloqueados', () => {
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><FlashcardsPage /></MemoryRouter>)
    expect(screen.getByText(/3 cards/).parentElement).toHaveTextContent('3 cards · 2 vencidos · 1 novos')
    expect(screen.getByRole('link', { name: 'Iniciar revisão' })).toHaveAttribute('href', '/certifications/az-900/flashcards/review')
    expect(screen.getByRole('link', { name: /Cloud Computing/ })).toHaveAttribute('href', '/certifications/az-900/flashcards/topics/t1')
    expect(screen.getByLabelText('Cloud Benefits: sem Flashcards disponíveis')).toHaveTextContent('Conclua as aulas deste tópico')
  })

  it('explica unlocking para aluno novo sem esconder o catálogo futuro', () => {
    mocks.overview.mockReturnValue({ overview: { queueCount: 0, dueCount: 0, newCount: 0, nextReviewAt: null, availableFlashcardCount: 0, totalFlashcardCount: 7 }, loading: false, error: null, retry: vi.fn() })
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><FlashcardsPage /></MemoryRouter>)
    expect(screen.getByText('Conclua aulas da trilha para liberar seus Flashcards.')).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: 'Iniciar revisão' })).not.toBeInTheDocument()
  })
})

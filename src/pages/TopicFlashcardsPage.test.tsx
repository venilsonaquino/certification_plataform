import { render, screen } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { TopicFlashcardsPage } from './TopicFlashcardsPage'

const mocks = vi.hoisted(() => ({ available: vi.fn(), catalog: vi.fn(), viewer: vi.fn() }))
vi.mock('../hooks/useCertification', () => ({ useCertification: () => ({ currentCertification: { id: 'certification-a', code: 'az-900' } }) }))
vi.mock('../hooks/useCertificationProgress', () => ({ useCertificationProgress: () => ({ domains: [{ id: 'd1', title: 'Cloud Concepts', topics: [{ id: 't1', title: 'Cloud Computing' }] }], loading: false, error: null, retry: vi.fn() }) }))
vi.mock('../hooks/useAvailableFlashcards', () => ({ useAvailableFlashcards: (scope: unknown) => { mocks.available(scope); return mocks.available() } }))
vi.mock('../hooks/useFlashcardCatalog', () => ({ useFlashcardCatalog: () => mocks.catalog() }))
vi.mock('../components/flashcards/FlashcardViewer', () => ({ FlashcardViewer: (props: unknown) => { mocks.viewer(props); return <div>Viewer livre</div> } }))

const card = { id: 'f1', lessonId: 'l1', lessonTitle: 'Lesson', lessonSlug: 'lesson', frontText: 'Front', backText: 'Back', hint: null, displayOrder: 1, isPublished: true, createdAt: '2026-08-31T00:00:00Z', updatedAt: '2026-08-31T00:00:00Z' }

function renderPage() {
  return render(<MemoryRouter initialEntries={['/certifications/az-900/flashcards/topics/t1']} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><Routes><Route path="/certifications/:certificationCode/flashcards/topics/:topicId" element={<TopicFlashcardsPage />} /></Routes></MemoryRouter>)
}

describe('TopicFlashcardsPage', () => {
  beforeEach(() => {
    mocks.available.mockReset()
    mocks.viewer.mockReset()
    mocks.available.mockReturnValue({ cards: [card], loading: false, error: null, retry: vi.fn() })
    mocks.catalog.mockReturnValue({ domains: [{ topics: [{ topicId: 't1', totalCount: 3 }] }], loading: false, error: null, retry: vi.fn() })
  })

  it('carrega Free Study com Certification + Topic e sem scheduling', () => {
    renderPage()
    expect(mocks.available).toHaveBeenCalledWith({ certificationId: 'certification-a', topicId: 't1' })
    expect(mocks.viewer).toHaveBeenCalledWith(expect.objectContaining({ mode: 'study', returnRoute: '/certifications/az-900/flashcards' }))
    expect(screen.getByText(/Esta sessão não altera sua agenda de revisão/)).toBeInTheDocument()
  })

  it('explica quando todos os cards do tópico continuam bloqueados', () => {
    mocks.available.mockReturnValue({ cards: [], loading: false, error: null, retry: vi.fn() })
    renderPage()
    expect(screen.getByText('Flashcards ainda bloqueados.')).toBeInTheDocument()
    expect(screen.getByText(/Conclua as aulas deste tópico/)).toBeInTheDocument()
    expect(mocks.viewer).not.toHaveBeenCalled()
  })
})

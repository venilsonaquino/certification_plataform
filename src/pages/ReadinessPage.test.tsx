import { render, screen, within } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { calculateAz900Readiness } from '../features/readiness/readinessEngine'
import { calculateStudyRecommendations } from '../features/readiness/studyRecommendationEngine'
import { recommendationReasonLabels } from '../features/readiness/readinessPresentation'
import {
  emptyReadinessBundle,
  profileConsistentStrong,
  profileImproving,
  profileWeak,
  profileWithLessonsOnly,
  profileWithMocks,
  profileWithWeakDomain,
} from '../test/readinessFixtures'
import type { ReadinessEvidenceBundle } from '../types/readiness'
import type { Az900ReadinessDashboardData } from '../types/readinessUi'
import type { StudyRecommendationCatalog } from '../types/studyRecommendation'

const mocks = vi.hoisted(() => ({
  useCertification: vi.fn(),
  useCertificationReadiness: vi.fn(),
}))

vi.mock('../hooks/useCertification', () => ({ useCertification: mocks.useCertification }))
vi.mock('../hooks/useCertificationReadiness', () => ({
  useCertificationReadiness: mocks.useCertificationReadiness,
}))

import { ReadinessPage } from './ReadinessPage'

function catalogFor(bundle: ReadinessEvidenceBundle): StudyRecommendationCatalog {
  return {
    certificationCode: 'az-900',
    lessons: bundle.lessons,
    questions: bundle.topics.flatMap((topic) =>
      Array.from({ length: 10 }, (_, index) => ({
        id: `question:${topic.id}:${index}`,
        topicId: topic.id,
        lessonId: topic.lessonIds[0] ?? null,
        mockEligible: true,
      }))),
    flashcards: bundle.lessons.map((lesson) => ({
      id: `flashcard:${lesson.id}`,
      lessonId: lesson.id,
    })),
  }
}

function dashboardFor(
  bundle: ReadinessEvidenceBundle,
  withRecentMocks = false,
): Az900ReadinessDashboardData {
  const readiness = calculateAz900Readiness(bundle)
  const recommendations = calculateStudyRecommendations(
    readiness,
    bundle,
    catalogFor(bundle),
  ).viewModel
  return {
    readiness,
    recommendations,
    recentMocks: withRecentMocks
      ? [82, 75, 65].map((score, index) => ({
        attemptId: `attempt-${index + 1}`,
        attemptNumber: 3 - index,
        status: 'completed' as const,
        practiceScorePercentage: score,
        evaluatedAt: `2026-08-${27 - index}T12:00:00.000Z`,
      }))
      : [],
  }
}

function renderPage(data: Az900ReadinessDashboardData) {
  mocks.useCertificationReadiness.mockReturnValue({
    data,
    loading: false,
    error: null,
    retry: vi.fn(),
  })
  return render(
    <MemoryRouter initialEntries={['/certifications/az-900/readiness']} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
      <ReadinessPage />
    </MemoryRouter>,
  )
}

describe('ReadinessPage', () => {
  beforeEach(() => {
    mocks.useCertification.mockReturnValue({
      currentCertification: {
        id: 'az900',
        code: 'az-900',
        name: 'Microsoft Azure Fundamentals',
      },
    })
    mocks.useCertificationReadiness.mockReset()
  })

  it('mantém layout estável no loading e oculta erro técnico no estado de falha', () => {
    mocks.useCertificationReadiness.mockReturnValue({
      data: null,
      loading: true,
      error: null,
      retry: vi.fn(),
    })
    const { unmount } = render(
      <MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><ReadinessPage /></MemoryRouter>,
    )
    expect(screen.getByRole('status', { name: 'Carregando Readiness' })).toBeInTheDocument()
    unmount()

    mocks.useCertificationReadiness.mockReturnValue({
      data: null,
      loading: false,
      error: 'Supabase private stack trace',
      retry: vi.fn(),
    })
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><ReadinessPage /></MemoryRouter>)
    expect(screen.getByRole('alert')).toHaveTextContent('Não foi possível carregar seu Readiness.')
    expect(screen.queryByText(/Supabase private stack trace/)).not.toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Tentar novamente' })).toBeInTheDocument()
  })

  it('trata aluno novo como falta de evidência, sem zero, Critical, weak ou Pass/Fail', () => {
    renderPage(dashboardFor(emptyReadinessBundle()))

    expect(screen.getAllByText('Not Enough Evidence').length).toBeGreaterThan(0)
    expect(screen.getByText('Ainda não há evidência suficiente')).toBeInTheDocument()
    expect(screen.getByText(/Precisamos de mais prática avaliada/)).toBeInTheDocument()
    expect(screen.queryByText('0% readiness', { exact: false })).not.toBeInTheDocument()
    expect(screen.queryByText(/Prioridade: Critical/i)).not.toBeInTheDocument()
    expect(screen.queryByText(/\bweak\b/i)).not.toBeInTheDocument()
    expect(screen.queryByText(/passed|failed|chance of passing/i)).not.toBeInTheDocument()
  })

  it('separa 100% de Learning Progress de Assessment Readiness insuficiente', () => {
    renderPage(dashboardFor(profileWithLessonsOnly()))

    expect(screen.getAllByText('Not Enough Evidence').length).toBeGreaterThan(0)
    expect(screen.getByText('100%')).toBeInTheDocument()
    expect(screen.getByText('Progresso de estudo')).toBeInTheDocument()
    expect(screen.getByText(/Concluir aulas demonstra progresso de estudo, não domínio/)).toBeInTheDocument()
    expect(screen.getByText(/Checkpoints do Tópico fornecem evidência/)).toBeInTheDocument()
    expect(screen.getByText(/Quizzes de aula anteriores permanecem como evidência histórica/)).toBeInTheDocument()
    expect(screen.queryByText(/Topic Quizzes|Lesson Quizzes/)).not.toBeInTheDocument()
  })

  it('renderiza Weak Topics na ordem da engine, reasons amigáveis e CTAs existentes', () => {
    const data = dashboardFor(profileWeak())
    renderPage(data)

    expect(screen.getByRole('heading', { name: 'Needs Review', level: 2 })).toBeInTheDocument()
    expect(screen.getAllByText('Prioridade: Critical')).toHaveLength(3)
    const firstReason = data.recommendations.topics[0].reasonCodes[0]
    expect(screen.getAllByText(new RegExp(recommendationReasonLabels[firstReason])).length)
      .toBeGreaterThan(0)
    expect(screen.queryByText(firstReason)).not.toBeInTheDocument()
    const firstTopic = screen.getByRole('heading', {
      name: data.recommendations.topics[0].topicTitle,
    }).closest('article')
    expect(firstTopic).not.toBeNull()
    const firstLesson = data.recommendations.topics[0].recommendedLessons[0]
    expect(within(firstTopic as HTMLElement).getByRole('link', { name: firstLesson.title }))
      .toHaveAttribute('href', firstLesson.route)
    const expectedActions = data.recommendations.topics[0].actions
      .filter((action) => action.type !== 'review_lesson')
    for (const action of expectedActions) {
      expect(within(firstTopic as HTMLElement).getAllByRole('link')
        .some((link) => link.getAttribute('href') === action.route)).toBe(true)
    }
  })

  it('preserva rotas reais para Lesson, Topic Quiz, Flashcards e Mock', () => {
    const weak = dashboardFor(profileWeak())
    const { unmount } = renderPage(weak)
    const weakRoutes = screen.getAllByRole('link').map((link) => link.getAttribute('href'))
    const firstWeakTopic = weak.recommendations.topics[0]
    expect(weakRoutes).toContain(firstWeakTopic.recommendedLessons[0].route)
    expect(weakRoutes).toContain(firstWeakTopic.actions.find(
      (action) => action.type === 'retake_topic_quiz')?.route)
    expect(weakRoutes).toContain(firstWeakTopic.actions.find(
      (action) => action.type === 'review_flashcards')?.route)
    unmount()

    const newcomer = dashboardFor(emptyReadinessBundle())
    renderPage(newcomer)
    const mockAction = newcomer.recommendations.topics[0].actions.find(
      (action) => action.type === 'take_another_mock')
    expect(screen.getAllByRole('link').some(
      (link) => link.getAttribute('href') === mockAction?.route)).toBe(true)
  })

  it('mostra trend Improving e somente resumos recentes de Practice Score', () => {
    renderPage(dashboardFor(profileImproving(), true))

    expect(screen.getByRole('heading', { name: 'Developing', level: 2 })).toBeInTheDocument()
    expect(screen.getAllByText('Improving').length).toBeGreaterThan(0)
    expect(screen.getByLabelText('Practice Score 82%')).toBeInTheDocument()
    expect(screen.getByLabelText('Practice Score 75%')).toBeInTheDocument()
    expect(screen.getByText(/não são previsão nem pontuação oficial/)).toBeInTheDocument()
  })

  it('mostra aviso de reavaliação quando a engine marca a evidência como stale', () => {
    renderPage(dashboardFor(profileWithMocks([45, 45, 45], { stale: true })))

    expect(screen.getByRole('status')).toHaveTextContent('Sua evidência mais forte está antiga')
    expect(screen.queryByText('Prioridade: Critical')).not.toBeInTheDocument()
  })

  it('mantém Domain fraco visível e não sobrescreve a classificação da engine', () => {
    const data = dashboardFor(profileWithWeakDomain())
    renderPage(data)

    const weakDomain = data.readiness.domains.find((domain) => domain.domainId === 'domain-3')
    expect(weakDomain?.classification).toBe('needs_review')
    const card = screen.getByRole('heading', { name: weakDomain?.title }).closest('article')
    expect(card).not.toBeNull()
    expect(within(card as HTMLElement).getByText('Needs Review')).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Needs Review', level: 2 })).toBeInTheDocument()
  })

  it('mostra Strong sem criar recomendações ou status de prova', () => {
    renderPage(dashboardFor(profileConsistentStrong(), true))

    expect(screen.getByRole('heading', { name: 'Strong', level: 2 })).toBeInTheDocument()
    expect(screen.getByText('Nenhuma revisão prioritária')).toBeInTheDocument()
    expect(screen.queryByText(/passed|failed|87% chance/i)).not.toBeInTheDocument()
  })
})

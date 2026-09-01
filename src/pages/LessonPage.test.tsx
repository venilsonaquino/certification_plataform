import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import type { DomainWithTopics, Lesson, TopicWithLessons } from '../types/content'
import type { UserLessonProgress } from '../types/progress'

const mocks = vi.hoisted(() => ({
  useCertification: vi.fn(),
  useCertificationProgress: vi.fn(),
  useUserProgress: vi.fn(),
  completeProgress: vi.fn(),
  recordCertificationProgress: vi.fn(),
  useStudyProgression: vi.fn(),
}))

vi.mock('../hooks/useCertification', () => ({
  useCertification: mocks.useCertification,
}))

vi.mock('../hooks/useCertificationProgress', () => ({
  useCertificationProgress: mocks.useCertificationProgress,
}))

vi.mock('../hooks/useUserProgress', () => ({
  useUserProgress: mocks.useUserProgress,
}))

vi.mock('../hooks/useStudyProgression', () => ({
  useStudyProgression: mocks.useStudyProgression,
}))

vi.mock('../components/study/LessonContentRenderer', () => ({
  LessonContentRenderer: ({
    lessonId,
    legacyContent,
  }: {
    lessonId: string
    legacyContent: string | null
  }) => (
    <section data-testid="lesson-content" data-lesson-id={lessonId} data-stage="content">
      {legacyContent}
    </section>
  ),
}))

vi.mock('../components/study/LessonCompletion', () => ({
  LessonCompletion: ({ onComplete }: { onComplete: () => void }) => (
    <section data-stage="completion">
      <button type="button" onClick={onComplete}>
        Concluir aula
      </button>
    </section>
  ),
}))

vi.mock('../components/study/LessonNavigation', () => ({
  LessonNavigation: () => <nav data-stage="navigation">Navegação entre aulas</nav>,
}))

import { LessonPage } from './LessonPage'

const topicId = '22000000-0000-4000-8000-000000000001'
const lessonId = '23000000-0000-4000-8000-000000000002'

function lesson(overrides: Partial<Lesson>): Lesson {
  return {
    id: '23000000-0000-4000-8000-000000000001',
    topicId,
    slug: 'previous-lesson',
    title: 'Aula anterior',
    shortDescription: null,
    content: 'Conteúdo anterior.',
    estimatedMinutes: 5,
    displayOrder: 1,
    isPublished: true,
    createdAt: '2026-08-25T12:00:00.000Z',
    updatedAt: '2026-08-25T12:00:00.000Z',
    ...overrides,
  }
}

const currentLesson = lesson({
  id: lessonId,
  slug: 'shared-responsibility-model',
  title: 'Shared Responsibility Model',
  content: 'Conteúdo legado preservado.',
  estimatedMinutes: 10,
  displayOrder: 2,
})

const topic: TopicWithLessons = {
  id: topicId,
  domainId: '21000000-0000-4000-8000-000000000001',
  title: 'Cloud concepts',
  description: null,
  displayOrder: 1,
  createdAt: '2026-08-25T12:00:00.000Z',
  updatedAt: '2026-08-25T12:00:00.000Z',
  lessons: [
    lesson({}),
    currentLesson,
    lesson({
      id: '23000000-0000-4000-8000-000000000003',
      slug: 'next-lesson',
      title: 'Próxima aula',
      displayOrder: 3,
    }),
  ],
}

const domains: readonly DomainWithTopics[] = [{
  id: topic.domainId,
  certificationId: '20000000-0000-4000-8000-000000000001',
  title: 'Describe cloud concepts',
  description: null,
  examWeightMin: 25,
  examWeightMax: 30,
  displayOrder: 1,
  createdAt: '2026-08-25T12:00:00.000Z',
  updatedAt: '2026-08-25T12:00:00.000Z',
  topics: [topic],
}]

const progress: UserLessonProgress = {
  id: '24000000-0000-4000-8000-000000000001',
  userId: '25000000-0000-4000-8000-000000000001',
  lessonId,
  status: 'in_progress',
  startedAt: '2026-08-25T12:00:00.000Z',
  completedAt: null,
  lastAccessedAt: '2026-08-25T12:00:00.000Z',
  createdAt: '2026-08-25T12:00:00.000Z',
  updatedAt: '2026-08-25T12:00:00.000Z',
}

describe('LessonPage', () => {
  beforeEach(() => {
    Object.values(mocks).forEach((mock) => mock.mockReset())
    mocks.useCertification.mockReturnValue({
      currentCertification: { id: '20000000-0000-4000-8000-000000000001', code: 'az-900' },
    })
    mocks.useCertificationProgress.mockReturnValue({
      domains,
      progressByLessonId: new Map([[lessonId, progress]]),
      loading: false,
      error: null,
      retry: vi.fn(),
      recordProgress: mocks.recordCertificationProgress,
    })
    mocks.useUserProgress.mockReturnValue({
      progressByLessonId: new Map([[lessonId, progress]]),
      loading: false,
      error: null,
      retry: vi.fn(),
      completeProgress: mocks.completeProgress,
      completingLessonId: null,
      mutationError: null,
    })
    mocks.useStudyProgression.mockReturnValue({
      progression: {
        lessonById: new Map([
          [lessonId, { lesson: currentLesson, topic, domain: domains[0], status: 'in_progress', available: true, grandfathered: false, prerequisiteLesson: null, prerequisiteTopic: null }],
          [topic.lessons[2].id, { lesson: topic.lessons[2], topic, domain: domains[0], status: 'locked', available: false, grandfathered: false, prerequisiteLesson: null, prerequisiteTopic: null }],
        ]),
        checkpointByTopicId: new Map(),
      },
      loading: false,
      error: null,
      retry: vi.fn(),
    })
  })

  it('preserva conteúdo, conclusão e navegação, sem ações secundárias no fluxo primário', async () => {
    const user = userEvent.setup()
    const { container } = render(
      <MemoryRouter
        initialEntries={['/certifications/az-900/study/shared-responsibility-model']}
        future={{ v7_startTransition: true, v7_relativeSplatPath: true }}
      >
        <Routes>
          <Route
            path="/certifications/:certificationCode/study/:lessonSlug"
            element={<LessonPage />}
          />
        </Routes>
      </MemoryRouter>,
    )

    expect(
      [...container.querySelectorAll('[data-stage]')].map((element) =>
        element.getAttribute('data-stage'),
      ),
    ).toEqual(['content', 'completion', 'navigation'])
    expect(screen.getByTestId('lesson-content')).toHaveTextContent('Conteúdo legado preservado.')

    await user.click(screen.getByRole('button', { name: 'Concluir aula' }))

    expect(mocks.completeProgress).toHaveBeenCalledWith(lessonId)
    expect(mocks.useUserProgress).toHaveBeenCalledWith({
      lessonIds: [lessonId],
      startLessonId: lessonId,
    })
    await waitFor(() => expect(mocks.recordCertificationProgress).toHaveBeenCalledWith(progress))
  })

  it('intercepta deep link bloqueado sem registrar início', () => {
    mocks.useStudyProgression.mockReturnValue({
      progression: {
        lessonById: new Map([[lessonId, { lesson: currentLesson, topic, domain: domains[0], status: 'locked', available: false, grandfathered: false, prerequisiteLesson: { lesson: topic.lessons[0], topic, domain: domains[0] }, prerequisiteTopic: null }]]),
        checkpointByTopicId: new Map(),
      },
      loading: false,
      error: null,
      retry: vi.fn(),
    })

    render(
      <MemoryRouter initialEntries={['/certifications/az-900/study/shared-responsibility-model']} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
        <Routes><Route path="/certifications/:certificationCode/study/:lessonSlug" element={<LessonPage />} /></Routes>
      </MemoryRouter>,
    )

    expect(screen.getByText('Esta aula ainda está bloqueada.')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Concluir “Aula anterior”' })).toHaveAttribute('href', '/certifications/az-900/study/previous-lesson')
    expect(mocks.useUserProgress).toHaveBeenCalledWith({ lessonIds: [lessonId], startLessonId: null })
  })
})

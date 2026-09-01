import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it } from 'vitest'

import type { DomainWithTopics } from '../../types/content'
import type { UserLessonProgress } from '../../types/progress'
import type { TopicQuizSummary } from '../../types/quiz'
import { resolveStudyProgression } from '../../lib/studyProgression'
import { StudyPath } from './StudyPath'

const stamp = '2026-08-31T12:00:00.000Z'
const domains: readonly DomainWithTopics[] = [{
  id: 'd1', certificationId: 'c1', title: 'Domínio', description: null, examWeightMin: null, examWeightMax: null, displayOrder: 1, createdAt: stamp, updatedAt: stamp,
  topics: [{
    id: 't1', domainId: 'd1', title: 'Tópico', description: null, displayOrder: 1, createdAt: stamp, updatedAt: stamp,
    lessons: [1, 2].map((displayOrder) => ({ id: `l${displayOrder}`, topicId: 't1', slug: `aula-${displayOrder}`, title: `Aula ${displayOrder}`, shortDescription: null, content: null, estimatedMinutes: 10, displayOrder, isPublished: true, createdAt: stamp, updatedAt: stamp })),
  }],
}]
const quizSummary: TopicQuizSummary = { topicId: 't1', questionCount: 20, targetQuestionCount: 12, activeAttemptId: null, activeTotalQuestions: null, activeAnsweredCount: 0, lastScorePercentage: null }

function progress(lessonId: string): UserLessonProgress {
  return { id: `p-${lessonId}`, userId: 'u1', lessonId, status: 'completed', startedAt: stamp, completedAt: stamp, lastAccessedAt: stamp, createdAt: stamp, updatedAt: stamp }
}

describe('StudyPath progressive unlocking', () => {
  it('comunica aula e checkpoint bloqueados com texto, sem links funcionais', () => {
    const progressMap = new Map<string, UserLessonProgress>()
    const progression = resolveStudyProgression(domains, progressMap, new Map([['t1', quizSummary]]))
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><StudyPath certificationCode="az-900" domains={domains} progressByLessonId={progressMap} progression={progression} /></MemoryRouter>)
    expect(screen.getByRole('link', { name: /Aula 1/ })).toHaveAttribute('href', '/certifications/az-900/study/aula-1')
    expect(screen.getByLabelText('Aula 2: bloqueada')).toBeInTheDocument()
    expect(screen.getByText(/Conclua as 2 aulas restantes/)).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: /Fazer Checkpoint/ })).not.toBeInTheDocument()
  })

  it('mostra Checkpoint disponível com tamanho real da tentativa', () => {
    const progressMap = new Map([['l1', progress('l1')], ['l2', progress('l2')]])
    const progression = resolveStudyProgression(domains, progressMap, new Map([['t1', quizSummary]]))
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><StudyPath certificationCode="az-900" domains={domains} progressByLessonId={progressMap} progression={progression} /></MemoryRouter>)
    expect(screen.getByText('12 questões nesta tentativa.')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /Fazer Checkpoint/ })).toHaveAttribute('href', '/certifications/az-900/topics/t1/quiz')
  })

  it('mostra Continuar Checkpoint para tentativa ativa', () => {
    const progressMap = new Map([['l1', progress('l1')], ['l2', progress('l2')]])
    const active = { ...quizSummary, activeAttemptId: 'attempt', activeTotalQuestions: 10, activeAnsweredCount: 4 }
    const progression = resolveStudyProgression(domains, progressMap, new Map([['t1', active]]))
    render(<MemoryRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}><StudyPath certificationCode="az-900" domains={domains} progressByLessonId={progressMap} progression={progression} /></MemoryRouter>)
    expect(screen.getByText('4 de 10 questões respondidas.')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /Continuar Checkpoint/ })).toBeInTheDocument()
  })
})

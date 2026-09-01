import { describe, expect, it } from 'vitest'

import type { DomainWithTopics, Lesson, TopicWithLessons } from '../types/content'
import type { UserLessonProgress } from '../types/progress'
import type { TopicQuizSummary } from '../types/quiz'
import { resolveStudyProgression } from './studyProgression'

const stamp = '2026-08-31T12:00:00.000Z'

function lesson(id: string, topicId: string, displayOrder: number): Lesson {
  return { id, topicId, slug: id, title: id, shortDescription: null, content: null, estimatedMinutes: 10, displayOrder, isPublished: true, createdAt: stamp, updatedAt: stamp }
}

function topic(id: string, domainId: string, displayOrder: number): TopicWithLessons {
  return { id, domainId, title: id, description: null, displayOrder, createdAt: stamp, updatedAt: stamp, lessons: [lesson(`${id}-l1`, id, 1), lesson(`${id}-l2`, id, 2)] }
}

const firstTopic = topic('t1', 'd1', 1)
const secondTopic = topic('t2', 'd1', 2)
const thirdTopic = topic('t3', 'd2', 1)
const domains: readonly DomainWithTopics[] = [
  { id: 'd1', certificationId: 'c1', title: 'd1', description: null, examWeightMin: null, examWeightMax: null, displayOrder: 1, createdAt: stamp, updatedAt: stamp, topics: [firstTopic, secondTopic] },
  { id: 'd2', certificationId: 'c1', title: 'd2', description: null, examWeightMin: null, examWeightMax: null, displayOrder: 2, createdAt: stamp, updatedAt: stamp, topics: [thirdTopic] },
]

function progress(lessonId: string, status: 'in_progress' | 'completed'): UserLessonProgress {
  return { id: `p-${lessonId}`, userId: 'u1', lessonId, status, startedAt: stamp, completedAt: status === 'completed' ? stamp : null, lastAccessedAt: stamp, createdAt: stamp, updatedAt: stamp }
}

function summary(topicId: string, options: { active?: boolean; score?: number | null; questions?: number; target?: number } = {}): TopicQuizSummary {
  return { topicId, questionCount: options.questions ?? 10, targetQuestionCount: options.target ?? 10, activeAttemptId: options.active ? `a-${topicId}` : null, activeTotalQuestions: options.active ? 10 : null, activeAnsweredCount: options.active ? 2 : 0, lastScorePercentage: options.score ?? null }
}

function resolve(progressItems: UserLessonProgress[] = [], summaries: TopicQuizSummary[] = [summary('t1'), summary('t2'), summary('t3')]) {
  return resolveStudyProgression(domains, new Map(progressItems.map((item) => [item.lessonId, item])), new Map(summaries.map((item) => [item.topicId, item])))
}

describe('resolveStudyProgression', () => {
  it('libera somente a primeira aula para um aluno novo', () => {
    const result = resolve()
    expect(result.lessons.map((item) => item.status)).toEqual(['available', 'locked', 'locked', 'locked', 'locked', 'locked'])
    expect(result.checkpoints.map((item) => item.status)).toEqual(['locked', 'locked', 'locked'])
  })

  it('exige completion para liberar a próxima aula e mantém in_progress sem avanço', () => {
    expect(resolve([progress('t1-l1', 'in_progress')]).lessonById.get('t1-l2')?.status).toBe('locked')
    expect(resolve([progress('t1-l1', 'completed')]).lessonById.get('t1-l2')?.status).toBe('available')
  })

  it('libera o checkpoint após a última aula, mas não o próximo tópico', () => {
    const result = resolve([progress('t1-l1', 'completed'), progress('t1-l2', 'completed')])
    expect(result.checkpointByTopicId.get('t1')?.status).toBe('available')
    expect(result.lessonById.get('t2-l1')?.status).toBe('locked')
    expect(result.nextAction).toMatchObject({ kind: 'checkpoint' })
  })

  it('mantém attempt ativo e o apresenta como próxima ação', () => {
    const result = resolve(
      [progress('t1-l1', 'completed'), progress('t1-l2', 'completed')],
      [summary('t1', { active: true }), summary('t2'), summary('t3')],
    )
    expect(result.checkpointByTopicId.get('t1')?.status).toBe('in_progress')
    expect(result.nextAction).toMatchObject({ kind: 'checkpoint' })
  })

  it.each([45, 95])('libera o próximo tópico após checkpoint com score %s', (score) => {
    const result = resolve(
      [progress('t1-l1', 'completed'), progress('t1-l2', 'completed')],
      [summary('t1', { score }), summary('t2'), summary('t3')],
    )
    expect(result.checkpointByTopicId.get('t1')?.status).toBe('completed')
    expect(result.lessonById.get('t2-l1')?.status).toBe('available')
  })

  it('atravessa Domain e encerra somente após o último checkpoint', () => {
    const progressItems = domains.flatMap((domain) => domain.topics.flatMap((item) => item.lessons.map((entry) => progress(entry.id, 'completed'))))
    const beforeLast = resolve(progressItems, [summary('t1', { score: 80 }), summary('t2', { score: 70 }), summary('t3')])
    expect(beforeLast.lessonById.get('t3-l1')?.available).toBe(true)
    expect(beforeLast.journeyCompleted).toBe(false)
    const completed = resolve(progressItems, [summary('t1', { score: 80 }), summary('t2', { score: 70 }), summary('t3', { score: 0 })])
    expect(completed.journeyCompleted).toBe(true)
    expect(completed.nextAction).toBeNull()
  })

  it('preserva um aluno legado com progresso fora de sequência', () => {
    const result = resolve([progress('t2-l2', 'in_progress')])
    expect(result.lessons.slice(0, 4).every((item) => item.available)).toBe(true)
    expect(result.lessonById.get('t3-l1')?.status).toBe('locked')
    expect(result.checkpointByTopicId.get('t1')?.status).toBe('available')
  })

  it('mantém histórico de checkpoint válido mesmo sem completion retroativa', () => {
    const result = resolve([], [summary('t1', { score: 55 }), summary('t2'), summary('t3')])
    expect(result.checkpointByTopicId.get('t1')?.status).toBe('completed')
    expect(result.lessonById.get('t2-l1')?.status).toBe('available')
  })

  it('classifica tópico vazio ou sem questões como configuração indisponível', () => {
    const emptyTopic = { ...firstTopic, lessons: [] }
    const emptyDomains = [{ ...domains[0], topics: [emptyTopic] }]
    const empty = resolveStudyProgression(emptyDomains, new Map(), new Map([['t1', summary('t1')]]))
    expect(empty.checkpointByTopicId.get('t1')?.status).toBe('unavailable')
    const noQuestions = resolve([], [summary('t1', { questions: 0 }), summary('t2'), summary('t3')])
    expect(noQuestions.checkpointByTopicId.get('t1')?.status).toBe('unavailable')
  })
})

import { describe, expect, it } from 'vitest'

import type { DomainWithTopics, Lesson, TopicWithLessons } from '../types/content'
import { findNextLessonAfterTopic } from './studyPath'

const stamp = '2026-09-01T12:00:00.000Z'

function lesson(id: string, topicId: string, displayOrder: number): Lesson {
  return { id, topicId, slug: id, title: id, shortDescription: null, content: null, estimatedMinutes: 10, displayOrder, isPublished: true, createdAt: stamp, updatedAt: stamp }
}

function topic(id: string, domainId: string, displayOrder: number): TopicWithLessons {
  return { id, domainId, title: id, description: null, displayOrder, createdAt: stamp, updatedAt: stamp, lessons: [lesson(`${id}-l1`, id, 1), lesson(`${id}-l2`, id, 2)] }
}

const domains: readonly DomainWithTopics[] = [
  { id: 'd1', certificationId: 'c1', title: 'd1', description: null, examWeightMin: null, examWeightMax: null, displayOrder: 1, createdAt: stamp, updatedAt: stamp, topics: [topic('t1', 'd1', 1), topic('t2', 'd1', 2)] },
  { id: 'd2', certificationId: 'c1', title: 'd2', description: null, examWeightMin: null, examWeightMax: null, displayOrder: 2, createdAt: stamp, updatedAt: stamp, topics: [topic('t3', 'd2', 1)] },
]

describe('findNextLessonAfterTopic', () => {
  it('encontra a primeira aula do próximo tópico no mesmo domínio', () => {
    expect(findNextLessonAfterTopic(domains, 't1')?.lesson.id).toBe('t2-l1')
  })

  it('atravessa a fronteira entre domínios', () => {
    expect(findNextLessonAfterTopic(domains, 't2')?.lesson.id).toBe('t3-l1')
  })

  it('não inventa uma próxima aula após o último tópico', () => {
    expect(findNextLessonAfterTopic(domains, 't3')).toBeNull()
    expect(findNextLessonAfterTopic(domains, 'missing')).toBeNull()
  })
})

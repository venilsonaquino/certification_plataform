import { describe, expect, it } from 'vitest'

import {
  mockExamAttemptDatabaseRowSchema,
  mockExamSnapshotSchema,
  saveMockExamAnswerInputSchema,
} from './mockExamValidation'

const id = (suffix: number) => `10000000-0000-4000-8000-${suffix.toString().padStart(12, '0')}`
const timestamp = '2026-08-29T12:00:00.000Z'

describe('Mock Exam validation', () => {
  it('accepts a valid immutable Question snapshot', () => {
    const snapshot = {
      domainId: id(1), domainTitle: 'Domain', topicId: id(2), topicTitle: 'Topic',
      lessonId: id(3), lessonTitle: 'Lesson', lessonSlug: 'lesson', difficulty: 'medium',
      questionType: 'single_choice', questionText: 'Question?',
      options: [
        { key: id(4), sourceOptionId: id(4), text: 'A', explanation: null, displayOrder: 1 },
        { key: id(5), sourceOptionId: id(5), text: 'B', explanation: 'Why', displayOrder: 2 },
      ],
      correctOptionKey: id(5), questionExplanation: null,
      questionSourceUpdatedAt: timestamp, schemaVersion: 1,
    }

    expect(mockExamSnapshotSchema.safeParse(snapshot).success).toBe(true)
  })

  it('rejects duplicate option keys and an external answer key', () => {
    const option = { key: id(4), sourceOptionId: id(4), text: 'A', explanation: null, displayOrder: 1 }
    const result = mockExamSnapshotSchema.safeParse({
      domainId: id(1), domainTitle: 'Domain', topicId: id(2), topicTitle: 'Topic',
      lessonId: id(3), lessonTitle: 'Lesson', lessonSlug: 'lesson', difficulty: 'easy',
      questionType: 'single_choice', questionText: 'Question?',
      options: [option, { ...option, displayOrder: 2 }], correctOptionKey: id(9),
      questionExplanation: null, questionSourceUpdatedAt: timestamp, schemaVersion: 1,
    })

    expect(result.success).toBe(false)
  })

  it('enforces completed lifecycle result fields', () => {
    const result = mockExamAttemptDatabaseRowSchema.safeParse({
      id: id(1), user_id: id(2), certification_id: id(3), status: 'completed',
      total_questions: 40, answered_questions: 40, correct_answers: null,
      incorrect_answers: null, unanswered_questions: null, practice_score_percentage: null,
      started_at: timestamp, submitted_at: timestamp, abandoned_at: null, expires_at: null,
      time_limit_seconds: null, elapsed_seconds: null, last_activity_at: timestamp,
      selection_policy_version: 'mock-v1', domain_allocation: {}, difficulty_allocation: {},
      created_at: timestamp, updated_at: timestamp,
    })

    expect(result.success).toBe(false)
  })

  it('rejects malformed answer input', () => {
    expect(saveMockExamAnswerInputSchema.safeParse({
      attemptId: 'not-a-uuid', attemptQuestionId: id(2), selectedOptionKey: '',
    }).success).toBe(false)
  })
})

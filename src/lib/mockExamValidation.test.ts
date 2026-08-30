import { describe, expect, it } from 'vitest'

import {
  mockExamAttemptDatabaseRowSchema,
  mockExamAttemptQuestionDatabaseRowSchema,
  mockExamResultDatabaseRowSchema,
  mockExamReviewDatabaseRowSchema,
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

  it('accepts an expired Attempt finalized with persisted result and bounded duration', () => {
    const result = mockExamAttemptDatabaseRowSchema.safeParse({
      id: id(1), user_id: id(2), certification_id: id(3), status: 'expired',
      total_questions: 40, answered_questions: 35, correct_answers: 30,
      incorrect_answers: 5, unanswered_questions: 5, practice_score_percentage: 75,
      started_at: timestamp, submitted_at: '2026-08-29T13:00:00.000Z', abandoned_at: null,
      expires_at: '2026-08-29T13:00:00.000Z', time_limit_seconds: 3600,
      elapsed_seconds: 3600, last_activity_at: '2026-08-29T13:00:01.000Z',
      selection_policy_version: 'mock-v1', domain_allocation: {}, difficulty_allocation: {},
      created_at: timestamp, updated_at: '2026-08-29T13:00:01.000Z',
    })
    expect(result.success).toBe(true)
  })

  it('rejects malformed answer input', () => {
    expect(saveMockExamAnswerInputSchema.safeParse({
      attemptId: 'not-a-uuid', attemptQuestionId: id(2), selectedOptionKey: '',
    }).success).toBe(false)
  })

  it('rejects answer keys and pedagogical metadata in the active execution DTO', () => {
    const result = mockExamAttemptQuestionDatabaseRowSchema.safeParse({
      id: id(1), attempt_id: id(2), question_id: id(3), display_order: 1,
      question_text: 'Which option meets the requirement?',
      options: [
        { key: id(4), text: 'Option A', displayOrder: 1 },
        { key: id(5), text: 'Option B', displayOrder: 2 },
      ],
      selected_option_key: null, answered_at: null,
      correct_option_key: id(5), explanation: 'This must never reach an active attempt.',
      difficulty: 'hard',
    })

    expect(result.success).toBe(false)
  })

  it('accepts a consistent persisted result with complete breakdowns', () => {
    const breakdown = { totalQuestions: 40, correctAnswers: 30, incorrectAnswers: 5, unansweredQuestions: 5, percentage: 75 }
    const result = mockExamResultDatabaseRowSchema.safeParse({
      attempt_id: id(1), total_questions: 40, answered_questions: 35,
      correct_answers: 30, incorrect_answers: 5, unanswered_questions: 5,
      practice_score_percentage: 75, started_at: timestamp, submitted_at: timestamp,
      elapsed_seconds: 1200,
      domain_breakdown: [{ domainId: id(2), domainTitle: 'Domain', ...breakdown }],
      topic_breakdown: [{ domainId: id(2), domainTitle: 'Domain', topicId: id(3), topicTitle: 'Topic', ...breakdown }],
      difficulty_breakdown: [{ difficulty: 'medium', ...breakdown }],
    })
    expect(result.success).toBe(true)
  })

  it('rejects result breakdowns that do not cover the full Attempt', () => {
    const breakdown = { totalQuestions: 39, correctAnswers: 29, incorrectAnswers: 5, unansweredQuestions: 5, percentage: 74.36 }
    const result = mockExamResultDatabaseRowSchema.safeParse({
      attempt_id: id(1), total_questions: 40, answered_questions: 35,
      correct_answers: 30, incorrect_answers: 5, unanswered_questions: 5,
      practice_score_percentage: 75, started_at: timestamp, submitted_at: timestamp,
      elapsed_seconds: null,
      domain_breakdown: [{ domainId: id(2), domainTitle: 'Domain', ...breakdown }],
      topic_breakdown: [{ domainId: id(2), domainTitle: 'Domain', topicId: id(3), topicTitle: 'Topic', ...breakdown }],
      difficulty_breakdown: [{ difficulty: 'medium', ...breakdown }],
    })
    expect(result.success).toBe(false)
  })

  it('validates completed Review status against selected and correct options', () => {
    const base = {
      id: id(1), attempt_id: id(2), question_id: id(3), display_order: 1,
      domain_id: id(4), domain_title: 'Domain', topic_id: id(5), topic_title: 'Topic',
      lesson_id: id(6), lesson_title: 'Lesson', lesson_slug: 'lesson', difficulty: 'hard',
      question_text: 'Question?', options: [
        { key: id(7), text: 'A', displayOrder: 1 },
        { key: id(8), text: 'B', displayOrder: 2 },
      ], selected_option_key: id(7), correct_option_key: id(8),
      answer_status: 'incorrect', explanation: 'Because B is correct.',
    }
    expect(mockExamReviewDatabaseRowSchema.safeParse(base).success).toBe(true)
    expect(mockExamReviewDatabaseRowSchema.safeParse({ ...base, answer_status: 'correct' }).success).toBe(false)
  })
})

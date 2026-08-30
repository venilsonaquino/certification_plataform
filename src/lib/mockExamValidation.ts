import { z } from 'zod'

import { MOCK_EXAM_ATTEMPT_STATUSES } from '../types/mockExam'

const uuidSchema = z.string().uuid()
const timestampSchema = z.string().datetime({ offset: true })
const nullableTimestampSchema = timestampSchema.nullable()
const nullableCountSchema = z.number().int().nonnegative().nullable()
const allocationSchema = z.record(z.string().min(1), z.number().int().nonnegative())

export const mockExamAttemptStatusSchema = z.enum(MOCK_EXAM_ATTEMPT_STATUSES)

export const mockExamSnapshotOptionSchema = z
  .object({
    key: z.string().trim().min(1).max(200),
    sourceOptionId: uuidSchema,
    text: z.string().trim().min(1).max(5_000),
    explanation: z.string().trim().min(1).max(10_000).nullable(),
    displayOrder: z.number().int().positive(),
  })
  .strict()

export const mockExamSnapshotSchema = z
  .object({
    domainId: uuidSchema,
    domainTitle: z.string().trim().min(1).max(300),
    topicId: uuidSchema,
    topicTitle: z.string().trim().min(1).max(300),
    lessonId: uuidSchema,
    lessonTitle: z.string().trim().min(1).max(300),
    lessonSlug: z.string().trim().min(1).max(300),
    difficulty: z.enum(['easy', 'medium', 'hard']),
    questionType: z.literal('single_choice'),
    questionText: z.string().trim().min(1).max(30_000),
    options: z.array(mockExamSnapshotOptionSchema).min(2).max(10),
    correctOptionKey: z.string().trim().min(1).max(200),
    questionExplanation: z.string().trim().min(1).max(30_000).nullable(),
    questionSourceUpdatedAt: timestampSchema,
    schemaVersion: z.number().int().positive(),
  })
  .strict()
  .superRefine((snapshot, context) => {
    const keys = snapshot.options.map((option) => option.key)
    const orders = snapshot.options.map((option) => option.displayOrder)

    if (new Set(keys).size !== keys.length) {
      context.addIssue({ code: 'custom', path: ['options'], message: 'Option keys must be unique.' })
    }
    if (new Set(orders).size !== orders.length) {
      context.addIssue({ code: 'custom', path: ['options'], message: 'Option order must be unique.' })
    }
    if (!keys.includes(snapshot.correctOptionKey)) {
      context.addIssue({
        code: 'custom',
        path: ['correctOptionKey'],
        message: 'Correct option must belong to the snapshot.',
      })
    }
  })

export const mockExamAttemptDatabaseRowSchema = z
  .object({
    id: uuidSchema,
    user_id: uuidSchema,
    certification_id: uuidSchema,
    status: mockExamAttemptStatusSchema,
    total_questions: z.number().int().positive().max(100),
    answered_questions: z.number().int().nonnegative(),
    correct_answers: nullableCountSchema,
    incorrect_answers: nullableCountSchema,
    unanswered_questions: nullableCountSchema,
    practice_score_percentage: z.coerce.number().min(0).max(100).nullable(),
    started_at: timestampSchema,
    submitted_at: nullableTimestampSchema,
    abandoned_at: nullableTimestampSchema,
    expires_at: nullableTimestampSchema,
    time_limit_seconds: z.number().int().positive().nullable(),
    elapsed_seconds: z.number().int().nonnegative().nullable(),
    last_activity_at: timestampSchema,
    selection_policy_version: z.string().trim().min(1).max(100),
    domain_allocation: allocationSchema,
    difficulty_allocation: allocationSchema,
    created_at: timestampSchema,
    updated_at: timestampSchema,
  })
  .strict()
  .superRefine((attempt, context) => {
    const resultFields = [
      attempt.correct_answers,
      attempt.incorrect_answers,
      attempt.unanswered_questions,
      attempt.practice_score_percentage,
    ]
    const hasResult = resultFields.every((value) => value !== null)
    const hasNoResult = resultFields.every((value) => value === null)

    if (attempt.answered_questions > attempt.total_questions) {
      context.addIssue({
        code: 'custom',
        path: ['answered_questions'],
        message: 'Answered count cannot exceed total Questions.',
      })
    }
    if (attempt.status === 'completed') {
      if (!hasResult || attempt.submitted_at === null || attempt.abandoned_at !== null) {
        context.addIssue({ code: 'custom', path: ['status'], message: 'Completed lifecycle is invalid.' })
      }
      if (
        attempt.correct_answers !== null &&
        attempt.incorrect_answers !== null &&
        attempt.unanswered_questions !== null &&
        (attempt.correct_answers + attempt.incorrect_answers + attempt.unanswered_questions !==
          attempt.total_questions ||
          attempt.answered_questions !== attempt.correct_answers + attempt.incorrect_answers)
      ) {
        context.addIssue({ code: 'custom', path: ['status'], message: 'Result totals are inconsistent.' })
      }
    } else if (!hasNoResult) {
      context.addIssue({ code: 'custom', path: ['status'], message: 'Only completed attempts have results.' })
    }
    if (attempt.status === 'in_progress' && (attempt.submitted_at || attempt.abandoned_at)) {
      context.addIssue({ code: 'custom', path: ['status'], message: 'In-progress lifecycle is invalid.' })
    }
    if (attempt.status === 'abandoned' && attempt.abandoned_at === null) {
      context.addIssue({ code: 'custom', path: ['abandoned_at'], message: 'Abandoned timestamp is required.' })
    }
    if (attempt.status !== 'completed' && attempt.submitted_at !== null) {
      context.addIssue({ code: 'custom', path: ['submitted_at'], message: 'Only completed attempts are submitted.' })
    }
    if (attempt.status !== 'abandoned' && attempt.abandoned_at !== null) {
      context.addIssue({ code: 'custom', path: ['abandoned_at'], message: 'Abandon timestamp is invalid.' })
    }
    if (attempt.status === 'expired' && attempt.expires_at === null) {
      context.addIssue({ code: 'custom', path: ['expires_at'], message: 'Expiry timestamp is required.' })
    }
    if ((attempt.time_limit_seconds === null) !== (attempt.expires_at === null)) {
      context.addIssue({ code: 'custom', path: ['expires_at'], message: 'Timer fields must be set together.' })
    }
  })

export const mockExamExecutionOptionSchema = z
  .object({
    key: z.string().trim().min(1).max(200),
    text: z.string().trim().min(1).max(5_000),
    displayOrder: z.number().int().positive(),
  })
  .strict()

export const mockExamAttemptQuestionDatabaseRowSchema = z
  .object({
    id: uuidSchema,
    attempt_id: uuidSchema,
    question_id: uuidSchema,
    display_order: z.number().int().positive(),
    domain_id: uuidSchema,
    domain_title: z.string().trim().min(1),
    topic_id: uuidSchema,
    topic_title: z.string().trim().min(1),
    lesson_id: uuidSchema,
    lesson_title: z.string().trim().min(1),
    lesson_slug: z.string().trim().min(1),
    difficulty: z.enum(['easy', 'medium', 'hard']),
    question_type: z.literal('single_choice'),
    question_text: z.string().trim().min(1),
    options: z.array(mockExamExecutionOptionSchema).min(2).max(10),
    selected_option_key: z.string().trim().min(1).nullable(),
    answered_at: nullableTimestampSchema,
  })
  .strict()

export const saveMockExamAnswerInputSchema = z
  .object({
    attemptId: uuidSchema,
    attemptQuestionId: uuidSchema,
    selectedOptionKey: z.string().trim().min(1).max(200),
  })
  .strict()

export const mockExamAnswerDatabaseRowSchema = z
  .object({
    id: uuidSchema,
    attempt_id: uuidSchema,
    attempt_question_id: uuidSchema,
    selected_option_key: z.string().trim().min(1).max(200),
    answered_at: timestampSchema,
  })
  .strict()

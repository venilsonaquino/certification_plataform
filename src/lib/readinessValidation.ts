import { z } from 'zod'

const uuidSchema = z.string().uuid()
const timestampSchema = z.string().datetime({ offset: true })

export const readinessEvidenceDatabaseRowSchema = z.object({
  evidence_id: uuidSchema,
  evidence_kind: z.enum(['assessment', 'learning']),
  source: z.enum([
    'mock_exam',
    'topic_quiz',
    'lesson_quiz',
    'review_quiz',
    'lesson_progress',
    'flashcard_review',
    'flashcard_progress',
  ]),
  attempt_id: uuidSchema.nullable(),
  question_id: uuidSchema.nullable(),
  domain_id: uuidSchema,
  topic_id: uuidSchema,
  lesson_id: uuidSchema.nullable(),
  outcome: z.enum(['correct', 'incorrect', 'unanswered']).nullable(),
  occurred_at: timestampSchema.nullable(),
  difficulty: z.enum(['easy', 'medium', 'hard']).nullable(),
  attempt_status: z.enum(['completed', 'expired']).nullable(),
  duration_seconds: z.number().int().nonnegative().nullable(),
  lesson_status: z.enum(['not_started', 'in_progress', 'completed']).nullable(),
  flashcard_rating: z.enum(['again', 'hard', 'good', 'easy']).nullable(),
  review_count: z.number().int().nonnegative().nullable(),
  successful_review_count: z.number().int().nonnegative().nullable(),
  due_at: timestampSchema.nullable(),
}).strict()


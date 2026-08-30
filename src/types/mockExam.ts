import type { QuestionDifficulty, QuestionType } from './question'

export const MOCK_EXAM_ATTEMPT_STATUSES = [
  'in_progress',
  'completed',
  'abandoned',
  'expired',
] as const

export type MockExamAttemptStatus = (typeof MOCK_EXAM_ATTEMPT_STATUSES)[number]

export const AZ900_PRACTICE_MOCK_CONFIGURATION = {
  totalQuestions: 40,
  domainAllocation: { 1: 11, 2: 15, 3: 14 },
  difficultyAllocation: { easy: 12, medium: 20, hard: 8 },
  selectionPolicyVersion: 'az900-mock-v1',
} as const

export interface MockExamAllocation {
  readonly [key: string]: number
}

export interface MockExamAttempt {
  readonly id: string
  readonly userId: string
  readonly certificationId: string
  readonly status: MockExamAttemptStatus
  readonly totalQuestions: number
  readonly answeredQuestions: number
  readonly correctAnswers: number | null
  readonly incorrectAnswers: number | null
  readonly unansweredQuestions: number | null
  readonly practiceScorePercentage: number | null
  readonly startedAt: string
  readonly submittedAt: string | null
  readonly abandonedAt: string | null
  readonly expiresAt: string | null
  readonly timeLimitSeconds: number | null
  readonly elapsedSeconds: number | null
  readonly lastActivityAt: string
  readonly selectionPolicyVersion: string
  readonly domainAllocation: MockExamAllocation
  readonly difficultyAllocation: MockExamAllocation
  readonly createdAt: string
  readonly updatedAt: string
}

export interface MockExamSnapshotOption {
  readonly key: string
  readonly sourceOptionId: string
  readonly text: string
  readonly explanation: string | null
  readonly displayOrder: number
}

export interface MockExamSnapshot {
  readonly domainId: string
  readonly domainTitle: string
  readonly topicId: string
  readonly topicTitle: string
  readonly lessonId: string
  readonly lessonTitle: string
  readonly lessonSlug: string
  readonly difficulty: QuestionDifficulty
  readonly questionType: QuestionType
  readonly questionText: string
  readonly options: readonly MockExamSnapshotOption[]
  readonly correctOptionKey: string
  readonly questionExplanation: string | null
  readonly questionSourceUpdatedAt: string
  readonly schemaVersion: number
}

export interface MockExamExecutionOption {
  readonly key: string
  readonly text: string
  readonly displayOrder: number
}

export interface MockExamQuestionForExecution {
  readonly id: string
  readonly attemptId: string
  readonly questionId: string
  readonly displayOrder: number
  readonly questionText: string
  readonly options: readonly MockExamExecutionOption[]
  readonly selectedOptionKey: string | null
  readonly answeredAt: string | null
}

export interface MockExamAnswer {
  readonly id: string
  readonly attemptId: string
  readonly attemptQuestionId: string
  readonly selectedOptionKey: string
  readonly answeredAt: string
}

export interface SaveMockExamAnswerInput {
  readonly attemptId: string
  readonly attemptQuestionId: string
  readonly selectedOptionKey: string
}

export interface MockExamAttemptData {
  readonly attempt: MockExamAttempt
  readonly questions: readonly MockExamQuestionForExecution[]
}

export type MockExamAnswerSaveStatus = 'idle' | 'saving' | 'saved' | 'error'

export interface MockExamAnswerState {
  readonly selectedOptionKey: string | null
  readonly persistedOptionKey: string | null
  readonly status: MockExamAnswerSaveStatus
  readonly error: string | null
}

export interface MockExamProgress {
  readonly currentQuestion: number
  readonly totalQuestions: number
  readonly answeredQuestions: number
  readonly unansweredQuestions: number
}

export interface MockExamResult {
  readonly attemptId: string
  readonly correctAnswers: number
  readonly incorrectAnswers: number
  readonly unansweredQuestions: number
  readonly practiceScorePercentage: number
}

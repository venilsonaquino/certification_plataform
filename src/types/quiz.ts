import type { PublicQuestion, PublicQuestionOption } from './question'

export type QuizAttemptStatus = 'in_progress' | 'completed'
export type QuizType = 'lesson' | 'topic' | 'review'

export const WEAK_AREA_THRESHOLD = 70
export const HIGH_ERROR_RATE_THRESHOLD = 60
export const MEDIUM_ERROR_RATE_THRESHOLD = 30
export const REVIEW_RECENT_DAYS = 30

export type ReviewPriority = 'high' | 'medium' | 'low'
export type ReviewPriorityFilter = 'all' | ReviewPriority | 'recent'

export interface QuizAttempt {
  readonly id: string
  readonly userId: string
  readonly certificationId: string
  readonly quizType: QuizType
  readonly lessonId: string | null
  readonly topicId: string | null
  readonly status: QuizAttemptStatus
  readonly totalQuestions: number
  readonly correctAnswers: number
  readonly scorePercentage: number
  readonly startedAt: string
  readonly completedAt: string | null
  readonly createdAt: string
  readonly updatedAt: string
}

export interface QuizAttemptQuestion {
  readonly id: string
  readonly attemptId: string
  readonly questionId: string
  readonly displayOrder: number
  readonly createdAt: string
}

export interface QuizAnswer {
  readonly id: string
  readonly attemptId: string
  readonly questionId: string
  readonly selectedOptionId: string
  readonly isCorrect: boolean
  readonly answeredAt: string
  readonly createdAt: string
}

export interface QuizAnswerReview {
  readonly questionId: string
  readonly selectedOptionId: string
  readonly selectedOptionText: string
  readonly isCorrect: boolean
  readonly correctOptionId: string
  readonly correctOptionText: string
  readonly questionExplanation: string | null
  readonly selectedOptionExplanation: string | null
  readonly correctOptionExplanation: string | null
}

export interface QuizAnswerFeedback extends QuizAnswerReview {
  readonly attemptCompleted: boolean
  readonly correctAnswers: number
  readonly totalQuestions: number
  readonly scorePercentage: number
}

export interface LessonQuizQuestion extends PublicQuestion {
  readonly attemptQuestionId: string
  readonly attemptDisplayOrder: number
  readonly options: readonly PublicQuestionOption[]
  readonly answer: QuizAnswer | null
  readonly review: QuizAnswerReview | null
}

export interface LessonQuizAttemptData {
  readonly attempt: QuizAttempt
  readonly questions: readonly LessonQuizQuestion[]
}

export interface LessonQuizSummary {
  readonly questionCount: number
  readonly activeAttempt: QuizAttempt | null
  readonly lastCompletedAttempt: QuizAttempt | null
  readonly answeredCount: number
}

export interface TopicQuizSummary {
  readonly topicId: string
  readonly questionCount: number
  readonly targetQuestionCount: number
  readonly activeAttemptId: string | null
  readonly activeTotalQuestions: number | null
  readonly activeAnsweredCount: number
  readonly lastScorePercentage: number | null
}

export interface LessonQuizPerformance {
  readonly lessonId: string | null
  readonly lessonTitle: string
  readonly lessonSlug: string | null
  readonly totalQuestions: number
  readonly correctAnswers: number
  readonly percentage: number
  readonly needsReview: boolean
}

export interface QuestionReviewStats {
  readonly questionId: string
  readonly questionText: string
  readonly domainId: string | null
  readonly domainTitle: string
  readonly topicId: string | null
  readonly topicTitle: string
  readonly lessonId: string | null
  readonly lessonTitle: string | null
  readonly lessonSlug: string | null
  readonly totalAttempts: number
  readonly correctCount: number
  readonly incorrectCount: number
  readonly accuracyPercentage: number
  readonly errorPercentage: number
  readonly lastAnsweredAt: string
  readonly lastResult: boolean
  readonly priority: ReviewPriority
}

export interface ReviewSummary {
  readonly totalQuestions: number
  readonly highPriorityCount: number
  readonly mediumPriorityCount: number
  readonly lowPriorityCount: number
  readonly overallAccuracy: number
  readonly activeAttempt: QuizAttempt | null
  readonly activeAnsweredCount: number
}

export type QuizQuestion = LessonQuizQuestion
export type QuizAttemptData = LessonQuizAttemptData

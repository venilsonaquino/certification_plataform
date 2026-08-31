import type { FlashcardReviewRating } from './flashcard'
import type { QuestionDifficulty } from './question'

export type AssessmentEvidenceSource =
  | 'mock_exam'
  | 'topic_quiz'
  | 'lesson_quiz'
  | 'review_quiz'

export type LearningEvidenceSource =
  | 'lesson_progress'
  | 'flashcard_review'
  | 'flashcard_progress'

export type AssessmentOutcome = 'correct' | 'incorrect' | 'unanswered'
export type EvidenceLevel = 'insufficient' | 'limited' | 'sufficient' | 'strong'
export type RecencyBucket = 'fresh' | 'recent' | 'aging' | 'stale'
export type PerformanceTrend = 'improving' | 'stable' | 'declining' | 'insufficient_data'
export type ConsistencyLevel = 'high' | 'moderate' | 'low' | 'insufficient_data'
export type ScopedReadinessClassification =
  | 'insufficient_evidence'
  | 'needs_review'
  | 'developing'
  | 'strong'
export type GlobalReadinessClassification =
  | 'not_enough_evidence'
  | 'needs_review'
  | 'developing'
  | 'strong'

export type ReadinessReasonCode =
  | 'insufficient_assessments'
  | 'insufficient_sessions'
  | 'insufficient_question_diversity'
  | 'insufficient_topic_coverage'
  | 'no_finalized_mock'
  | 'single_mock_only'
  | 'stale_evidence'
  | 'low_performance'
  | 'low_mock_performance'
  | 'repeated_topic_quiz_errors'
  | 'declining_performance'
  | 'inconsistent_performance'
  | 'high_unanswered_rate'
  | 'confirmed_weak_topic'
  | 'weak_domain'
  | 'broad_recent_evidence'
  | 'consistent_strong_performance'

export interface ReadinessTopicDefinition {
  readonly id: string
  readonly domainId: string
  readonly title: string
  readonly lessonIds: readonly string[]
}

export interface ReadinessDomainDefinition {
  readonly id: string
  readonly title: string
  readonly displayOrder: number
  readonly topicIds: readonly string[]
}

export interface ReadinessLessonDefinition {
  readonly id: string
  readonly topicId: string
  readonly title: string
  readonly slug: string
  readonly displayOrder: number
}

export interface AssessmentEvidence {
  readonly id: string
  readonly source: AssessmentEvidenceSource
  readonly attemptId: string
  readonly questionId: string
  readonly domainId: string
  readonly topicId: string
  readonly lessonId: string | null
  readonly outcome: AssessmentOutcome
  readonly occurredAt: string
  readonly difficulty: QuestionDifficulty | null
  readonly attemptStatus: 'completed' | 'expired'
  readonly durationSeconds: number | null
}

export interface LessonLearningEvidence {
  readonly id: string
  readonly source: 'lesson_progress'
  readonly domainId: string
  readonly topicId: string
  readonly lessonId: string
  readonly status: 'not_started' | 'in_progress' | 'completed'
  readonly occurredAt: string | null
}

export interface FlashcardLearningEvidence {
  readonly id: string
  readonly source: 'flashcard_review' | 'flashcard_progress'
  readonly domainId: string
  readonly topicId: string
  readonly lessonId: string
  readonly rating: FlashcardReviewRating | null
  readonly reviewCount: number | null
  readonly successfulReviewCount: number | null
  readonly occurredAt: string | null
  readonly dueAt: string | null
}

export type LearningEvidence = LessonLearningEvidence | FlashcardLearningEvidence

export interface ReadinessEvidenceBundle {
  readonly certificationId: string
  readonly evidenceAsOf: string
  readonly domains: readonly ReadinessDomainDefinition[]
  readonly topics: readonly ReadinessTopicDefinition[]
  readonly lessons: readonly ReadinessLessonDefinition[]
  readonly assessments: readonly AssessmentEvidence[]
  readonly learning: readonly LearningEvidence[]
}

export interface SourceEvidenceCount {
  readonly source: AssessmentEvidenceSource
  readonly answered: number
  readonly unanswered: number
  readonly distinctQuestions: number
  readonly attempts: number
}

export interface ReadinessEvidenceTrace {
  readonly answeredQuestions: number
  readonly unansweredQuestions: number
  readonly distinctQuestions: number
  readonly assessmentSessions: number
  readonly sourceCounts: readonly SourceEvidenceCount[]
  readonly rawAccuracy: number | null
  readonly weightedPerformance: number | null
  readonly latestEvidenceAt: string | null
  readonly recency: RecencyBucket | null
  readonly learningProgress: {
    readonly completedLessons: number
    readonly totalLessons: number
    readonly flashcardReviews: number
    readonly dueFlashcards: number
  }
  readonly reasons: readonly ReadinessReasonCode[]
}

export interface ReadinessConsistency {
  readonly level: ConsistencyLevel
  readonly attemptCount: number
  readonly scoreRange: number | null
}

export interface TopicReadiness {
  readonly topicId: string
  readonly domainId: string
  readonly title: string
  readonly readinessScore: number | null
  readonly classification: ScopedReadinessClassification
  readonly evidenceLevel: EvidenceLevel
  readonly trend: PerformanceTrend
  readonly consistency: ReadinessConsistency
  readonly trace: ReadinessEvidenceTrace
}

export type WeakTopicState = 'watch' | 'confirmed'

export interface WeakTopicCandidate {
  readonly topicId: string
  readonly domainId: string
  readonly classification: ScopedReadinessClassification
  readonly evidenceLevel: EvidenceLevel
  readonly state: WeakTopicState
  readonly recentPerformance: number | null
  readonly reasonCodes: readonly Extract<
    ReadinessReasonCode,
    'low_mock_performance' | 'repeated_topic_quiz_errors' | 'declining_performance'
  >[]
}

export interface DomainReadiness {
  readonly domainId: string
  readonly title: string
  readonly readinessScore: number | null
  readonly classification: ScopedReadinessClassification
  readonly evidenceLevel: EvidenceLevel
  readonly topicCoverage: number
  readonly trend: PerformanceTrend
  readonly consistency: ReadinessConsistency
  readonly weakTopicIds: readonly string[]
  readonly trace: ReadinessEvidenceTrace
}

export interface GlobalReadiness {
  readonly calculationVersion: string
  readonly evidenceAsOf: string
  readonly readinessScore: number | null
  readonly classification: GlobalReadinessClassification
  readonly evidenceLevel: EvidenceLevel
  readonly trend: PerformanceTrend
  readonly consistency: ReadinessConsistency
  readonly domains: readonly DomainReadiness[]
  readonly topics: readonly TopicReadiness[]
  readonly weakTopicCandidates: readonly WeakTopicCandidate[]
  readonly trace: ReadinessEvidenceTrace
}

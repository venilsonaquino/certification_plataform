import type {
  EvidenceLevel,
  GlobalReadinessClassification,
  PerformanceTrend,
  ScopedReadinessClassification,
} from './readiness'

export type StudyRecommendationPriority = 'critical' | 'high' | 'medium' | 'low'

export type StudyRecommendationReasonCode =
  | 'confirmed_weak_topic'
  | 'low_mock_performance'
  | 'repeated_mock_errors'
  | 'low_topic_quiz_performance'
  | 'repeated_topic_quiz_errors'
  | 'declining_trend'
  | 'inconsistent_performance'
  | 'insufficient_evidence'
  | 'stale_evidence'
  | 'domain_weakness'
  | 'developing_performance'
  | 'improving_performance'

export type LessonRecommendationReasonCode =
  | 'mock_errors'
  | 'topic_quiz_errors'
  | 'lesson_quiz_errors'
  | 'recurring_question_errors'
  | 'recent_incorrect_answers'
  | 'due_flashcards'

export type StudyRecommendationActionType =
  | 'review_lesson'
  | 'review_flashcards'
  | 'retake_topic_quiz'
  | 'assess_topic'
  | 'take_another_mock'

export interface RecommendationLessonDefinition {
  readonly id: string
  readonly topicId: string
  readonly title: string
  readonly slug: string
  readonly displayOrder: number
}

export interface RecommendationQuestionDefinition {
  readonly id: string
  readonly topicId: string
  readonly lessonId: string | null
  readonly mockEligible: boolean
}

export interface RecommendationFlashcardDefinition {
  readonly id: string
  readonly lessonId: string
}

export interface StudyRecommendationCatalog {
  readonly certificationCode: string
  readonly lessons: readonly RecommendationLessonDefinition[]
  readonly questions: readonly RecommendationQuestionDefinition[]
  readonly flashcards: readonly RecommendationFlashcardDefinition[]
}

export interface RecommendationEvidenceExplanation {
  readonly mockPerformance: number | null
  readonly topicQuizPerformance: number | null
  readonly lessonQuizPerformance: number | null
  readonly recentIncorrectAnswers: number
  readonly recurringIncorrectQuestions: number
  readonly latestEvidenceAt: string | null
}

export interface RecommendedLesson {
  readonly id: string
  readonly title: string
  readonly slug: string
  readonly route: string
  readonly reasonCodes: readonly LessonRecommendationReasonCode[]
}

export interface StudyRecommendationAction {
  readonly type: StudyRecommendationActionType
  readonly route: string
  readonly targetId: string | null
}

export interface TopicStudyRecommendation {
  readonly topicId: string
  readonly topicTitle: string
  readonly domainId: string
  readonly priority: StudyRecommendationPriority
  readonly classification: ScopedReadinessClassification
  readonly evidenceLevel: EvidenceLevel
  readonly trend: PerformanceTrend
  readonly reasonCodes: readonly StudyRecommendationReasonCode[]
  readonly evidence: RecommendationEvidenceExplanation
  readonly recommendedLessons: readonly RecommendedLesson[]
  readonly actions: readonly StudyRecommendationAction[]
}

export interface DomainStudyRecommendation {
  readonly domainId: string
  readonly domainTitle: string
  readonly classification: ScopedReadinessClassification
  readonly primaryTopicIds: readonly string[]
}

export interface ReadinessRecommendationViewModel {
  readonly calculationVersion: string
  readonly evidenceAsOf: string
  readonly globalClassification: GlobalReadinessClassification
  readonly topics: readonly TopicStudyRecommendation[]
  readonly domains: readonly DomainStudyRecommendation[]
}

export interface TopicRecommendationDebugTrace {
  readonly topicId: string
  readonly priorityScore: number
  readonly domainWeightModifier: number
  readonly lessonScores: Readonly<Record<string, number>>
}

export interface StudyRecommendationEngineResult {
  readonly viewModel: ReadinessRecommendationViewModel
  readonly debugTrace: readonly TopicRecommendationDebugTrace[]
}

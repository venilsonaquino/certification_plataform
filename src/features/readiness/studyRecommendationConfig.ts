import type {
  StudyRecommendationPriority,
  StudyRecommendationReasonCode,
} from '../../types/studyRecommendation'

export interface StudyRecommendationConfig {
  readonly calculationVersion: string
  readonly limits: {
    readonly maxPriorityTopics: number
    readonly maxLessonsPerTopic: number
    readonly maxTopicsPerDomain: number
  }
  readonly availability: {
    readonly minimumTopicQuizQuestions: number
    readonly minimumMockQuestions: number
  }
  readonly priority: {
    readonly baseScores: {
      readonly confirmedWeak: number
      readonly watchWeak: number
      readonly needsReview: number
      readonly developing: number
      readonly insufficientEvidence: number
    }
    readonly reasonModifiers: Readonly<Record<StudyRecommendationReasonCode, number>>
    readonly domainWeightModifierScale: number
    readonly thresholds: Readonly<Record<Exclude<StudyRecommendationPriority, 'low'>, number>>
  }
  readonly lessonRanking: {
    readonly sourceErrorWeights: {
      readonly mock_exam: number
      readonly topic_quiz: number
      readonly lesson_quiz: number
      readonly review_quiz: number
    }
    readonly correctAnswerOffsets: {
      readonly mock_exam: number
      readonly topic_quiz: number
      readonly lesson_quiz: number
      readonly review_quiz: number
    }
    readonly recurringErrorBonus: number
    readonly recentErrorBonus: number
    readonly dueFlashcardBonus: number
    readonly maximumRepeatedQuestionCount: number
  }
}

export const AZ900_STUDY_RECOMMENDATION_CONFIG: StudyRecommendationConfig = {
  calculationVersion: 'az900-study-recommendations-v1',
  limits: {
    maxPriorityTopics: 3,
    maxLessonsPerTopic: 3,
    maxTopicsPerDomain: 2,
  },
  availability: {
    minimumTopicQuizQuestions: 5,
    minimumMockQuestions: 40,
  },
  priority: {
    baseScores: {
      confirmedWeak: 100,
      watchWeak: 80,
      needsReview: 75,
      developing: 45,
      insufficientEvidence: 25,
    },
    reasonModifiers: {
      confirmed_weak_topic: 15,
      low_mock_performance: 20,
      repeated_mock_errors: 12,
      low_topic_quiz_performance: 10,
      repeated_topic_quiz_errors: 10,
      declining_trend: 15,
      inconsistent_performance: 8,
      insufficient_evidence: 0,
      stale_evidence: -25,
      domain_weakness: 8,
      developing_performance: 0,
      improving_performance: -12,
    },
    domainWeightModifierScale: 5,
    thresholds: { critical: 110, high: 75, medium: 40 },
  },
  lessonRanking: {
    sourceErrorWeights: {
      mock_exam: 5,
      topic_quiz: 3,
      lesson_quiz: 2,
      review_quiz: 1,
    },
    correctAnswerOffsets: {
      mock_exam: 0.5,
      topic_quiz: 0.3,
      lesson_quiz: 0.2,
      review_quiz: 0,
    },
    recurringErrorBonus: 2,
    recentErrorBonus: 1,
    dueFlashcardBonus: 0.5,
    maximumRepeatedQuestionCount: 3,
  },
}


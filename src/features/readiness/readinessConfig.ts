import type { AssessmentEvidenceSource, RecencyBucket } from '../../types/readiness'

export interface ReadinessConfig {
  readonly calculationVersion: string
  readonly sourceWeights: Readonly<Record<AssessmentEvidenceSource, number>>
  readonly domainWeightsByOrder: Readonly<Record<number, number>>
  readonly recency: {
    readonly freshMaxDays: number
    readonly recentMaxDays: number
    readonly agingMaxDays: number
    readonly weights: Readonly<Record<RecencyBucket, number>>
  }
  readonly classification: {
    readonly needsReviewBelow: number
    readonly strongAtOrAbove: number
  }
  readonly evidence: {
    readonly topic: {
      readonly sufficientAnswers: number
      readonly sufficientSessions: number
      readonly sufficientDistinctQuestions: number
      readonly strongAnswers: number
      readonly strongSessions: number
      readonly strongDistinctQuestions: number
    }
    readonly domain: {
      readonly sufficientAnswers: number
      readonly sufficientSessions: number
      readonly sufficientTopicCoverage: number
      readonly strongAnswers: number
      readonly strongSessions: number
      readonly strongTopicCoverage: number
    }
    readonly global: {
      readonly sufficientAnswers: number
      readonly sufficientSessions: number
      readonly strongAnswers: number
      readonly strongMockAttempts: number
    }
  }
  readonly consistency: {
    readonly minimumAttempts: number
    readonly highMaxRange: number
    readonly moderateMaxRange: number
  }
  readonly trend: {
    readonly minimumAttempts: number
    readonly changeThreshold: number
  }
  readonly safeguards: {
    readonly weakPerformanceBelow: number
    readonly criticalPerformanceBelow: number
    readonly maximumStrongUnansweredRate: number
  }
}

export const AZ900_READINESS_CONFIG: ReadinessConfig = {
  calculationVersion: 'az900-readiness-v1',
  sourceWeights: {
    mock_exam: 1,
    topic_quiz: 0.65,
    lesson_quiz: 0.35,
    review_quiz: 0,
  },
  domainWeightsByOrder: {
    1: 0.275,
    2: 0.375,
    3: 0.35,
  },
  recency: {
    freshMaxDays: 14,
    recentMaxDays: 30,
    agingMaxDays: 60,
    weights: { fresh: 1, recent: 0.8, aging: 0.6, stale: 0.4 },
  },
  classification: {
    needsReviewBelow: 60,
    strongAtOrAbove: 80,
  },
  evidence: {
    topic: {
      sufficientAnswers: 8,
      sufficientSessions: 2,
      sufficientDistinctQuestions: 5,
      strongAnswers: 16,
      strongSessions: 3,
      strongDistinctQuestions: 8,
    },
    domain: {
      sufficientAnswers: 20,
      sufficientSessions: 2,
      sufficientTopicCoverage: 0.75,
      strongAnswers: 40,
      strongSessions: 3,
      strongTopicCoverage: 1,
    },
    global: {
      sufficientAnswers: 40,
      sufficientSessions: 2,
      strongAnswers: 120,
      strongMockAttempts: 3,
    },
  },
  consistency: {
    minimumAttempts: 3,
    highMaxRange: 8,
    moderateMaxRange: 18,
  },
  trend: {
    minimumAttempts: 3,
    changeThreshold: 6,
  },
  safeguards: {
    weakPerformanceBelow: 60,
    criticalPerformanceBelow: 50,
    maximumStrongUnansweredRate: 0.1,
  },
}


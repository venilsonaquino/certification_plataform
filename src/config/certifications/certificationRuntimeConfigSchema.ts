import { z } from 'zod'

import type { CertificationRuntimeConfig } from './certificationRuntimeConfig'

const nonEmptyVersionSchema = z.string().trim().min(1).max(100)
const positiveIntegerSchema = z.number().int().positive()
const nonNegativeIntegerSchema = z.number().int().nonnegative()
const percentageSchema = z.number().min(0).max(100)
const unitWeightSchema = z.number().min(0).max(1)

const questionTypeSchema = z.literal('single_choice')
const difficultyAllocationSchema = z.object({
  easy: nonNegativeIntegerSchema,
  medium: nonNegativeIntegerSchema,
  hard: nonNegativeIntegerSchema,
})
const checkpointSchema = z.object({
  enabled: z.boolean(),
  policyVersion: nonEmptyVersionSchema,
})

const mockSchema = z.object({
  enabled: z.boolean(),
  policyVersion: nonEmptyVersionSchema,
  questionCount: positiveIntegerSchema,
  timeLimitSeconds: positiveIntegerSchema,
  eligibleQuestionTypes: z.array(questionTypeSchema),
  domainAllocation: z.array(z.object({
    domainId: z.string().uuid(),
    questionCount: positiveIntegerSchema,
    difficultyAllocation: difficultyAllocationSchema,
  })).min(1),
  difficultyAllocation: difficultyAllocationSchema,
}).superRefine((config, context) => {
  if (config.enabled && config.eligibleQuestionTypes.length === 0) {
    context.addIssue({
      code: 'custom',
      path: ['eligibleQuestionTypes'],
      message: 'Enabled Mock configuration requires an eligible Question type.',
    })
  }

  const domainIds = new Set(config.domainAllocation.map((allocation) => allocation.domainId))
  if (domainIds.size !== config.domainAllocation.length) {
    context.addIssue({
      code: 'custom',
      path: ['domainAllocation'],
      message: 'Mock Domain allocations must reference unique Domain IDs.',
    })
  }

  const domainTotal = config.domainAllocation.reduce(
    (total, allocation) => total + allocation.questionCount,
    0,
  )
  if (domainTotal !== config.questionCount) {
    context.addIssue({
      code: 'custom',
      path: ['domainAllocation'],
      message: 'Mock Domain allocations must sum to questionCount.',
    })
  }

  const difficultyTotal = Object.values(config.difficultyAllocation)
    .reduce((total, count) => total + count, 0)
  if (difficultyTotal !== config.questionCount) {
    context.addIssue({
      code: 'custom',
      path: ['difficultyAllocation'],
      message: 'Mock difficulty allocations must sum to questionCount.',
    })
  }

  for (const [index, allocation] of config.domainAllocation.entries()) {
    const allocationTotal = Object.values(allocation.difficultyAllocation)
      .reduce((total, count) => total + count, 0)
    if (allocationTotal !== allocation.questionCount) {
      context.addIssue({
        code: 'custom',
        path: ['domainAllocation', index, 'difficultyAllocation'],
        message: 'Each Domain difficulty allocation must sum to its question count.',
      })
    }
  }
})

const evidenceThresholdSchema = z.object({
  sufficientAnswers: positiveIntegerSchema,
  sufficientSessions: positiveIntegerSchema,
  sufficientDistinctQuestions: positiveIntegerSchema,
  strongAnswers: positiveIntegerSchema,
  strongSessions: positiveIntegerSchema,
  strongDistinctQuestions: positiveIntegerSchema,
})

const readinessSchema = z.object({
  calculationVersion: nonEmptyVersionSchema,
  sourceWeights: z.object({
    mock_exam: unitWeightSchema,
    topic_quiz: unitWeightSchema,
    lesson_quiz: unitWeightSchema,
    review_quiz: unitWeightSchema,
  }),
  domainWeightsByOrder: z.record(z.string().regex(/^\d+$/), unitWeightSchema),
  recency: z.object({
    freshMaxDays: nonNegativeIntegerSchema,
    recentMaxDays: positiveIntegerSchema,
    agingMaxDays: positiveIntegerSchema,
    weights: z.object({
      fresh: unitWeightSchema,
      recent: unitWeightSchema,
      aging: unitWeightSchema,
      stale: unitWeightSchema,
    }),
  }),
  classification: z.object({
    needsReviewBelow: percentageSchema,
    strongAtOrAbove: percentageSchema,
  }),
  evidence: z.object({
    topic: evidenceThresholdSchema,
    domain: z.object({
      sufficientAnswers: positiveIntegerSchema,
      sufficientSessions: positiveIntegerSchema,
      sufficientTopicCoverage: unitWeightSchema,
      strongAnswers: positiveIntegerSchema,
      strongSessions: positiveIntegerSchema,
      strongTopicCoverage: unitWeightSchema,
    }),
    global: z.object({
      sufficientAnswers: positiveIntegerSchema,
      sufficientSessions: positiveIntegerSchema,
      strongAnswers: positiveIntegerSchema,
      strongMockAttempts: positiveIntegerSchema,
    }),
  }),
  consistency: z.object({
    minimumAttempts: positiveIntegerSchema,
    highMaxRange: percentageSchema,
    moderateMaxRange: percentageSchema,
  }),
  trend: z.object({
    minimumAttempts: positiveIntegerSchema,
    changeThreshold: percentageSchema,
  }),
  safeguards: z.object({
    weakPerformanceBelow: percentageSchema,
    criticalPerformanceBelow: percentageSchema,
    maximumStrongUnansweredRate: unitWeightSchema,
  }),
}).superRefine((config, context) => {
  if (Object.keys(config.domainWeightsByOrder).length === 0) {
    context.addIssue({
      code: 'custom',
      path: ['domainWeightsByOrder'],
      message: 'Readiness requires at least one Domain weight.',
    })
  }
  const domainWeightTotal = Object.values(config.domainWeightsByOrder)
    .reduce((total, weight) => total + weight, 0)
  if (Math.abs(domainWeightTotal - 1) > Number.EPSILON * 10) {
    context.addIssue({
      code: 'custom',
      path: ['domainWeightsByOrder'],
      message: 'Readiness Domain weights must sum to one.',
    })
  }
  if (!(config.recency.freshMaxDays < config.recency.recentMaxDays
    && config.recency.recentMaxDays < config.recency.agingMaxDays)) {
    context.addIssue({
      code: 'custom',
      path: ['recency'],
      message: 'Readiness recency bounds must be strictly increasing.',
    })
  }
  if (config.classification.needsReviewBelow >= config.classification.strongAtOrAbove) {
    context.addIssue({
      code: 'custom',
      path: ['classification'],
      message: 'Readiness classification thresholds are not coherent.',
    })
  }
  if (config.consistency.highMaxRange > config.consistency.moderateMaxRange) {
    context.addIssue({
      code: 'custom',
      path: ['consistency'],
      message: 'Readiness consistency ranges are not coherent.',
    })
  }
  if (config.safeguards.criticalPerformanceBelow > config.safeguards.weakPerformanceBelow) {
    context.addIssue({
      code: 'custom',
      path: ['safeguards'],
      message: 'Readiness safeguard thresholds are not coherent.',
    })
  }

  const thresholdPairs = [
    [config.evidence.topic.sufficientAnswers, config.evidence.topic.strongAnswers],
    [config.evidence.topic.sufficientSessions, config.evidence.topic.strongSessions],
    [config.evidence.topic.sufficientDistinctQuestions, config.evidence.topic.strongDistinctQuestions],
    [config.evidence.domain.sufficientAnswers, config.evidence.domain.strongAnswers],
    [config.evidence.domain.sufficientSessions, config.evidence.domain.strongSessions],
    [config.evidence.domain.sufficientTopicCoverage, config.evidence.domain.strongTopicCoverage],
    [config.evidence.global.sufficientAnswers, config.evidence.global.strongAnswers],
  ] as const
  if (thresholdPairs.some(([sufficient, strong]) => strong < sufficient)) {
    context.addIssue({
      code: 'custom',
      path: ['evidence'],
      message: 'Strong Readiness evidence thresholds cannot be below sufficient thresholds.',
    })
  }
})

const recommendationSourceValuesSchema = z.object({
  mock_exam: z.number().nonnegative(),
  topic_quiz: z.number().nonnegative(),
  lesson_quiz: z.number().nonnegative(),
  review_quiz: z.number().nonnegative(),
})

const recommendationsSchema = z.object({
  calculationVersion: nonEmptyVersionSchema,
  limits: z.object({
    maxPriorityTopics: positiveIntegerSchema,
    maxLessonsPerTopic: positiveIntegerSchema,
    maxTopicsPerDomain: positiveIntegerSchema,
  }),
  availability: z.object({
    minimumTopicQuizQuestions: positiveIntegerSchema,
    minimumMockQuestions: positiveIntegerSchema,
  }),
  priority: z.object({
    baseScores: z.object({
      confirmedWeak: z.number().nonnegative(),
      watchWeak: z.number().nonnegative(),
      needsReview: z.number().nonnegative(),
      developing: z.number().nonnegative(),
      insufficientEvidence: z.number().nonnegative(),
    }),
    reasonModifiers: z.object({
      confirmed_weak_topic: z.number(),
      low_mock_performance: z.number(),
      repeated_mock_errors: z.number(),
      low_topic_quiz_performance: z.number(),
      repeated_topic_quiz_errors: z.number(),
      declining_trend: z.number(),
      inconsistent_performance: z.number(),
      insufficient_evidence: z.number(),
      stale_evidence: z.number(),
      domain_weakness: z.number(),
      developing_performance: z.number(),
      improving_performance: z.number(),
    }),
    domainWeightModifierScale: z.number().nonnegative(),
    thresholds: z.object({
      critical: z.number().nonnegative(),
      high: z.number().nonnegative(),
      medium: z.number().nonnegative(),
    }),
  }),
  lessonRanking: z.object({
    sourceErrorWeights: recommendationSourceValuesSchema,
    correctAnswerOffsets: recommendationSourceValuesSchema,
    recurringErrorBonus: z.number().nonnegative(),
    recentErrorBonus: z.number().nonnegative(),
    dueFlashcardBonus: z.number().nonnegative(),
    maximumRepeatedQuestionCount: positiveIntegerSchema,
  }),
}).superRefine((config, context) => {
  if (!(config.priority.thresholds.critical >= config.priority.thresholds.high
    && config.priority.thresholds.high >= config.priority.thresholds.medium)) {
    context.addIssue({
      code: 'custom',
      path: ['priority', 'thresholds'],
      message: 'Recommendation priority thresholds must be ordered critical to medium.',
    })
  }
})

export const certificationRuntimeConfigSchema = z.object({
  certificationCode: z.string().trim().regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/),
  configVersion: nonEmptyVersionSchema,
  capabilities: z.object({
    checkpoint: z.boolean(),
    flashcards: z.boolean(),
    mockExam: z.boolean(),
    readiness: z.boolean(),
  }),
  checkpoint: checkpointSchema,
  mock: mockSchema,
  readiness: readinessSchema,
  recommendations: recommendationsSchema,
}).superRefine((config, context) => {
  const capabilityPairs = [
    ['checkpoint', config.capabilities.checkpoint, config.checkpoint.enabled],
    ['mockExam', config.capabilities.mockExam, config.mock.enabled],
  ] as const
  for (const [name, capability, enabled] of capabilityPairs) {
    if (capability !== enabled) {
      context.addIssue({
        code: 'custom',
        path: ['capabilities', name],
        message: `${name} capability must match its engine configuration state.`,
      })
    }
  }
})

export function parseCertificationRuntimeConfig(input: unknown): CertificationRuntimeConfig {
  return certificationRuntimeConfigSchema.parse(input) as CertificationRuntimeConfig
}

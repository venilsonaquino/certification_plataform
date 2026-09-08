import { describe, expect, it } from 'vitest'

import { AZ900_READINESS_CONFIG } from '../../features/readiness/readinessConfig'
import { AZ900_STUDY_RECOMMENDATION_CONFIG } from '../../features/readiness/studyRecommendationConfig'
import { deepFreezeRuntimeConfig } from './certificationRuntimeConfig'
import {
  certificationRuntimeConfigSchema,
  parseCertificationRuntimeConfig,
} from './certificationRuntimeConfigSchema'
import {
  CertificationRuntimeConfigNotFoundError,
  getCertificationRuntimeConfig,
  hasCertificationRuntimeConfig,
} from './certificationRuntimeConfigRegistry'

const TEST_RUNTIME_CONFIG = {
  certificationCode: 'test-001',
  configVersion: 'test001-runtime-v7',
  capabilities: {
    checkpoint: true,
    flashcards: false,
    mockExam: true,
    readiness: true,
  },
  checkpoint: {
    enabled: true,
    policyVersion: 'test001-checkpoint-v2',
  },
  mock: {
    enabled: true,
    policyVersion: 'test001-mock-v3',
    questionCount: 25,
    timeLimitSeconds: 2700,
    eligibleQuestionTypes: ['single_choice'],
    domainAllocation: [
      {
        domainId: '10000000-0000-4000-8000-000000000001',
        questionCount: 10,
        difficultyAllocation: { easy: 2, medium: 6, hard: 2 },
      },
      {
        domainId: '10000000-0000-4000-8000-000000000002',
        questionCount: 15,
        difficultyAllocation: { easy: 3, medium: 9, hard: 3 },
      },
    ],
    difficultyAllocation: { easy: 5, medium: 15, hard: 5 },
  },
  readiness: {
    ...AZ900_READINESS_CONFIG,
    calculationVersion: 'test001-readiness-v4',
    domainWeightsByOrder: { 1: 0.4, 2: 0.6 },
  },
  recommendations: {
    ...AZ900_STUDY_RECOMMENDATION_CONFIG,
    calculationVersion: 'test001-recommendations-v2',
    availability: {
      minimumTopicQuizQuestions: 4,
      minimumMockQuestions: 25,
    },
  },
} as const

describe('Certification Runtime Configuration', () => {
  it('resolves and validates the explicit AZ-900 snapshot', () => {
    const config = getCertificationRuntimeConfig(' AZ-900 ')

    expect(certificationRuntimeConfigSchema.safeParse(config).success).toBe(true)
    expect(config.certificationCode).toBe('az-900')
    expect(config.configVersion).toBe('az900-runtime-v1')
    expect(config.checkpoint.policyVersion).toBe('az900-checkpoint-v1')
    expect(config.mock).toMatchObject({
      questionCount: 40,
      timeLimitSeconds: 3600,
      policyVersion: 'az900-mock-v1',
      difficultyAllocation: { easy: 12, medium: 20, hard: 8 },
    })
    expect(config.mock.domainAllocation.map((item) => item.questionCount)).toEqual([11, 15, 14])
    expect(config.readiness.calculationVersion).toBe('az900-readiness-v1')
    expect(config.recommendations.calculationVersion).toBe('az900-study-recommendations-v1')
  })

  it('fails explicitly for an unknown Certification and never returns AZ-900', () => {
    expect(hasCertificationRuntimeConfig('az-204')).toBe(false)
    expect(() => getCertificationRuntimeConfig('az-204')).toThrow(
      CertificationRuntimeConfigNotFoundError,
    )
    expect(() => getCertificationRuntimeConfig('az-204')).toThrow(/az-204/)
  })

  it('accepts a structurally different test-only Certification', () => {
    const config = parseCertificationRuntimeConfig(TEST_RUNTIME_CONFIG)

    expect(config.certificationCode).toBe('test-001')
    expect(config.checkpoint.policyVersion).toBe('test001-checkpoint-v2')
    expect(config.mock.domainAllocation).toHaveLength(2)
    expect(config.mock.questionCount).toBe(25)
    expect(config.mock.timeLimitSeconds).toBe(2700)
    expect(Object.values(config.readiness.domainWeightsByOrder)).toEqual([0.4, 0.6])
    expect(config.recommendations.availability.minimumMockQuestions).toBe(25)
  })

  it('rejects incoherent structural configuration', () => {
    const invalid = {
      ...TEST_RUNTIME_CONFIG,
      mock: {
        ...TEST_RUNTIME_CONFIG.mock,
        difficultyAllocation: { easy: 5, medium: 14, hard: 5 },
      },
      readiness: {
        ...TEST_RUNTIME_CONFIG.readiness,
        classification: { needsReviewBelow: 90, strongAtOrAbove: 80 },
      },
    }

    const result = certificationRuntimeConfigSchema.safeParse(invalid)
    expect(result.success).toBe(false)
    if (!result.success) {
      expect(result.error.issues.map((issue) => issue.path.join('.'))).toEqual(
        expect.arrayContaining([
          'mock.difficultyAllocation',
          'readiness.classification',
        ]),
      )
    }
  })

  it('deep-freezes the registered config and nested collections', () => {
    const config = getCertificationRuntimeConfig('az-900')

    expect(Object.isFrozen(config)).toBe(true)
    expect(Object.isFrozen(config.capabilities)).toBe(true)
    expect(Object.isFrozen(config.checkpoint)).toBe(true)
    expect(Object.isFrozen(config.mock.domainAllocation)).toBe(true)
    expect(Object.isFrozen(config.readiness.recency.weights)).toBe(true)
    expect(Object.isFrozen(config.recommendations.priority.thresholds)).toBe(true)

    const mutableMock = config.mock as { questionCount: number }
    expect(() => {
      mutableMock.questionCount = 200
    }).toThrow(TypeError)
  })

  it('can freeze a validated test fixture without registering it', () => {
    const config = deepFreezeRuntimeConfig(parseCertificationRuntimeConfig(TEST_RUNTIME_CONFIG))
    expect(Object.isFrozen(config.mock.domainAllocation[1])).toBe(true)
    expect(hasCertificationRuntimeConfig(config.certificationCode)).toBe(false)
  })
})

import { AZ900_READINESS_CONFIG } from '../../features/readiness/readinessConfig'
import { AZ900_STUDY_RECOMMENDATION_CONFIG } from '../../features/readiness/studyRecommendationConfig'
import type { CertificationRuntimeConfig } from './certificationRuntimeConfig'
import { deepFreezeRuntimeConfig } from './certificationRuntimeConfig'
import { parseCertificationRuntimeConfig } from './certificationRuntimeConfigSchema'

const AZ900_DOMAIN_IDS = {
  cloudConcepts: '20000000-0000-4000-8000-000000000001',
  architectureAndServices: '20000000-0000-4000-8000-000000000002',
  managementAndGovernance: '20000000-0000-4000-8000-000000000003',
} as const

const configSnapshot = {
  certificationCode: 'az-900',
  configVersion: 'az900-runtime-v1',
  capabilities: {
    checkpoint: true,
    flashcards: true,
    mockExam: true,
    readiness: true,
  },
  checkpoint: {
    enabled: true,
    policyVersion: 'az900-checkpoint-v1',
  },
  mock: {
    enabled: true,
    policyVersion: 'az900-mock-v1',
    questionCount: 40,
    timeLimitSeconds: 3600,
    eligibleQuestionTypes: ['single_choice'],
    domainAllocation: [
      {
        domainId: AZ900_DOMAIN_IDS.cloudConcepts,
        questionCount: 11,
        difficultyAllocation: { easy: 3, medium: 6, hard: 2 },
      },
      {
        domainId: AZ900_DOMAIN_IDS.architectureAndServices,
        questionCount: 15,
        difficultyAllocation: { easy: 5, medium: 7, hard: 3 },
      },
      {
        domainId: AZ900_DOMAIN_IDS.managementAndGovernance,
        questionCount: 14,
        difficultyAllocation: { easy: 4, medium: 7, hard: 3 },
      },
    ],
    difficultyAllocation: { easy: 12, medium: 20, hard: 8 },
  },
  readiness: AZ900_READINESS_CONFIG,
  recommendations: AZ900_STUDY_RECOMMENDATION_CONFIG,
} as const satisfies CertificationRuntimeConfig

export const AZ900_RUNTIME_CONFIG = deepFreezeRuntimeConfig(
  parseCertificationRuntimeConfig(configSnapshot),
)

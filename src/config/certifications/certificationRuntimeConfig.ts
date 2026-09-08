import type { ReadinessConfig } from '../../features/readiness/readinessConfig'
import type { StudyRecommendationConfig } from '../../features/readiness/studyRecommendationConfig'
import type { QuestionDifficulty, QuestionType } from '../../types/question'

export interface CertificationCapabilities {
  readonly checkpoint: boolean
  readonly flashcards: boolean
  readonly mockExam: boolean
  readonly readiness: boolean
}

export interface CheckpointRuntimeConfig {
  readonly enabled: boolean
  readonly policyVersion: string
}

export interface MockDomainAllocation {
  readonly domainId: string
  readonly questionCount: number
  readonly difficultyAllocation: Readonly<Record<QuestionDifficulty, number>>
}

export interface MockRuntimeConfig {
  readonly enabled: boolean
  readonly policyVersion: string
  readonly questionCount: number
  readonly timeLimitSeconds: number
  readonly eligibleQuestionTypes: readonly QuestionType[]
  readonly domainAllocation: readonly MockDomainAllocation[]
  readonly difficultyAllocation: Readonly<Record<QuestionDifficulty, number>>
}

export interface CertificationRuntimeConfig {
  readonly certificationCode: string
  readonly configVersion: string
  readonly capabilities: CertificationCapabilities
  readonly checkpoint: CheckpointRuntimeConfig
  readonly mock: MockRuntimeConfig
  readonly readiness: ReadinessConfig
  readonly recommendations: StudyRecommendationConfig
}

export function deepFreezeRuntimeConfig<T extends object>(value: T): T {
  if (Object.isFrozen(value)) return value

  for (const nestedValue of Object.values(value)) {
    if (nestedValue !== null && typeof nestedValue === 'object') {
      deepFreezeRuntimeConfig(nestedValue)
    }
  }

  return Object.freeze(value)
}

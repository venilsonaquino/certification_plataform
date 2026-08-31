import type { GlobalReadiness } from './readiness'
import type { ReadinessRecommendationViewModel } from './studyRecommendation'

export interface RecentMockPerformance {
  readonly attemptId: string
  readonly attemptNumber: number
  readonly status: 'completed' | 'expired'
  readonly practiceScorePercentage: number
  readonly evaluatedAt: string
}

export interface Az900ReadinessDashboardData {
  readonly readiness: GlobalReadiness
  readonly recommendations: ReadinessRecommendationViewModel
  readonly recentMocks: readonly RecentMockPerformance[]
}

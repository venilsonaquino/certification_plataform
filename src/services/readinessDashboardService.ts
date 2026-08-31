import { calculateAz900Readiness } from '../features/readiness/readinessEngine'
import { calculateStudyRecommendations } from '../features/readiness/studyRecommendationEngine'
import type { Az900ReadinessDashboardData } from '../types/readinessUi'
import { getMockExamHistory } from './mockExamService'
import { getReadinessEvidenceBundle } from './readinessService'
import { getStudyRecommendationCatalog } from './studyRecommendationService'

const RECENT_MOCK_LIMIT = 5
const MOCK_HISTORY_FETCH_LIMIT = 10

export async function getAz900ReadinessDashboard(
  certificationId: string,
  certificationCode: string,
  evidenceAsOf = new Date().toISOString(),
): Promise<Az900ReadinessDashboardData> {
  const [bundle, history] = await Promise.all([
    getReadinessEvidenceBundle(certificationId, evidenceAsOf),
    getMockExamHistory(certificationId, MOCK_HISTORY_FETCH_LIMIT, 0),
  ])
  const readiness = calculateAz900Readiness(bundle)
  const catalog = await getStudyRecommendationCatalog(bundle, certificationCode)
  const recommendations = calculateStudyRecommendations(readiness, bundle, catalog).viewModel

  return {
    readiness,
    recommendations,
    recentMocks: history.items
      .filter((attempt) =>
        (attempt.status === 'completed' || attempt.status === 'expired')
        && attempt.practiceScorePercentage !== null
        && attempt.submittedAt !== null)
      .slice(0, RECENT_MOCK_LIMIT)
      .map((attempt) => ({
        attemptId: attempt.attemptId,
        attemptNumber: attempt.attemptNumber,
        status: attempt.status as 'completed' | 'expired',
        practiceScorePercentage: attempt.practiceScorePercentage as number,
        evaluatedAt: attempt.submittedAt as string,
      })),
  }
}

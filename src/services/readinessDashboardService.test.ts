import { beforeEach, describe, expect, it, vi } from 'vitest'

import { profileImproving } from '../test/readinessFixtures'
import type { StudyRecommendationCatalog } from '../types/studyRecommendation'

const mocks = vi.hoisted(() => ({
  getReadinessEvidenceBundle: vi.fn(),
  getStudyRecommendationCatalog: vi.fn(),
  getMockExamHistory: vi.fn(),
}))

vi.mock('./readinessService', () => ({
  getReadinessEvidenceBundle: mocks.getReadinessEvidenceBundle,
}))
vi.mock('./studyRecommendationService', () => ({
  getStudyRecommendationCatalog: mocks.getStudyRecommendationCatalog,
}))
vi.mock('./mockExamService', () => ({ getMockExamHistory: mocks.getMockExamHistory }))

import { getAz900ReadinessDashboard } from './readinessDashboardService'

describe('readinessDashboardService', () => {
  beforeEach(() => {
    Object.values(mocks).forEach((mock) => mock.mockReset())
  })

  it('retorna DTO agregado sem histórico bruto e limita Mock summaries finalizados', async () => {
    const bundle = profileImproving()
    const catalog: StudyRecommendationCatalog = {
      certificationCode: 'az-900',
      lessons: bundle.lessons,
      questions: bundle.topics.flatMap((topic) =>
        Array.from({ length: 10 }, (_, index) => ({
          id: `question:${topic.id}:${index}`,
          topicId: topic.id,
          lessonId: topic.lessonIds[0] ?? null,
          mockEligible: true,
        }))),
      flashcards: [],
    }
    mocks.getReadinessEvidenceBundle.mockResolvedValue(bundle)
    mocks.getStudyRecommendationCatalog.mockResolvedValue(catalog)
    mocks.getMockExamHistory.mockResolvedValue({
      totalCount: 8,
      items: [
        { attemptId: 'active', status: 'in_progress', practiceScorePercentage: null, submittedAt: null },
        ...Array.from({ length: 6 }, (_, index) => ({
          attemptId: `mock-${index + 1}`,
          attemptNumber: 6 - index,
          status: index === 1 ? 'expired' : 'completed',
          practiceScorePercentage: 80 - index,
          submittedAt: `2026-08-${28 - index}T12:00:00.000Z`,
        })),
      ],
    })

    const result = await getAz900ReadinessDashboard('az900', 'az-900', bundle.evidenceAsOf)

    expect(mocks.getReadinessEvidenceBundle).toHaveBeenCalledWith('az900', bundle.evidenceAsOf)
    expect(mocks.getMockExamHistory).toHaveBeenCalledWith('az900', 10, 0)
    expect(mocks.getStudyRecommendationCatalog).toHaveBeenCalledWith(bundle, 'az-900')
    expect(result.readiness.classification).toBe('developing')
    expect(result.recommendations.globalClassification).toBe('developing')
    expect(result.recentMocks).toHaveLength(5)
    expect(result.recentMocks.some((attempt) => attempt.status === 'expired')).toBe(true)
    expect(result).not.toHaveProperty('assessments')
    expect(result).not.toHaveProperty('learning')
  })
})

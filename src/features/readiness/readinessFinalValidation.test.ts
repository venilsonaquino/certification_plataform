import { describe, expect, it } from 'vitest'

import {
  addTopicQuizAttempts,
  emptyReadinessBundle,
  evidenceForTopic,
  profileConsistentStrong,
  profileOneLuckyMock,
  profileWithLessonsOnly,
  profileWithMocks,
  profileWithWeakDomain,
  readinessLessons,
  readinessTopics,
  READINESS_AS_OF,
} from '../../test/readinessFixtures'
import type {
  AssessmentEvidence,
  ReadinessEvidenceBundle,
} from '../../types/readiness'
import type { StudyRecommendationCatalog } from '../../types/studyRecommendation'
import { recommendationReasonLabels } from './readinessPresentation'
import { AZ900_READINESS_CONFIG } from './readinessConfig'
import { calculateAz900Readiness } from './readinessEngine'
import {
  calculateConsistency,
  calculateTrend,
  getRecencyBucket,
} from './readinessMetrics'
import { calculateStudyRecommendations } from './studyRecommendationEngine'

function catalogFor(bundle: ReadinessEvidenceBundle): StudyRecommendationCatalog {
  return {
    certificationCode: 'az-900',
    lessons: bundle.lessons,
    questions: bundle.topics.flatMap((topic) =>
      Array.from({ length: 10 }, (_, index) => ({
        id: `catalog:${topic.id}:${index}`,
        topicId: topic.id,
        lessonId: topic.lessonIds[0] ?? null,
        mockEligible: true,
      }))),
    flashcards: bundle.lessons.map((lesson) => ({
      id: `card:${lesson.id}`,
      lessonId: lesson.id,
    })),
  }
}

function recommendationFor(bundle: ReadinessEvidenceBundle) {
  const readiness = calculateAz900Readiness(bundle)
  return calculateStudyRecommendations(readiness, bundle, catalogFor(bundle))
}

function assessmentOnly(
  source: 'topic_quiz' | 'lesson_quiz',
  score: number,
  attempts = 3,
): ReadinessEvidenceBundle {
  const assessments = readinessTopics.flatMap((topic) =>
    evidenceForTopic(topic.id, source, Array.from({ length: attempts }, () => score)))
  return { ...emptyReadinessBundle(), assessments }
}

function exactMockScores(scores: readonly number[]): AssessmentEvidence[] {
  const topic = readinessTopics[0]
  const template = evidenceForTopic(topic.id, 'mock_exam', [0]).slice(0, 1)[0]
  return scores.flatMap((score, attemptIndex) =>
    Array.from({ length: 100 }, (_, questionIndex): AssessmentEvidence => ({
      ...template,
      id: `exact:${attemptIndex}:${questionIndex}`,
      attemptId: `exact:${attemptIndex}`,
      questionId: `exact:${attemptIndex}:question:${questionIndex}`,
      outcome: questionIndex < score ? 'correct' : 'incorrect',
      occurredAt: `2026-08-${String(20 + attemptIndex).padStart(2, '0')}T12:00:00.000Z`,
    })))
}

describe('Final evidence profiles', () => {
  it('mantém 100% Lessons + Flashcards sem avaliação como Not Enough Evidence', () => {
    const lessons = profileWithLessonsOnly()
    const bundle: ReadinessEvidenceBundle = {
      ...lessons,
      learning: [
        ...lessons.learning,
        ...readinessLessons.map((lesson, index) => {
          const topic = readinessTopics.find((item) => item.id === lesson.topicId)!
          return {
            id: `flashcard:${lesson.id}`,
            source: 'flashcard_review' as const,
            domainId: topic.domainId,
            topicId: topic.id,
            lessonId: lesson.id,
            rating: 'easy' as const,
            reviewCount: 5,
            successfulReviewCount: 5,
            occurredAt: `2026-08-${String(20 + index % 8).padStart(2, '0')}T12:00:00.000Z`,
            dueAt: null,
          }
        }),
      ],
    }
    const result = calculateAz900Readiness(bundle)

    expect(result.classification).toBe('not_enough_evidence')
    expect(result.readinessScore).toBeNull()
    expect(result.trace.learningProgress.completedLessons).toBe(readinessLessons.length)
    expect(result.trace.learningProgress.flashcardReviews).toBe(readinessLessons.length)
  })

  it('reconhece Lesson Quiz forte como progresso, mas nunca como Strong global', () => {
    const result = calculateAz900Readiness(assessmentOnly('lesson_quiz', 90))

    expect(result.classification).toBe('developing')
    expect(result.classification).not.toBe('strong')
    expect(result.trace.reasons).toContain('no_finalized_mock')
  })

  it('reconhece Topic Quiz forte e amplo, mas exige Mock para Strong global', () => {
    const result = calculateAz900Readiness(addTopicQuizAttempts(emptyReadinessBundle(), 90, 4))

    expect(result.classification).toBe('developing')
    expect(result.evidenceLevel).toBe('sufficient')
    expect(result.trace.reasons).toContain('no_finalized_mock')
  })

  it('um único Mock de 95% não produz Strong nem consistency artificial', () => {
    const result = calculateAz900Readiness(profileWithMocks([95]))

    expect(result.classification).not.toBe('strong')
    expect(result.consistency.level).toBe('insufficient_data')
    expect(result.trace.reasons).toContain('single_mock_only')
  })

  it('Lucky Mock não equivale ao perfil consistente forte', () => {
    const lucky = calculateAz900Readiness(profileOneLuckyMock())
    const strong = calculateAz900Readiness(profileConsistentStrong())

    expect(lucky.classification).not.toBe('strong')
    expect(lucky.consistency.level).toBe('low')
    expect(strong.classification).toBe('strong')
    expect(strong.consistency.level).not.toBe('low')
  })

  it('declining recente não permanece Strong por causa dos resultados antigos', () => {
    const bundle = addTopicQuizAttempts(profileWithMocks([88, 83, 74, 65]), 75, 3)
    const result = calculateAz900Readiness(bundle)
    const recommendation = recommendationFor(bundle)

    expect(result.trend).toBe('declining')
    expect(result.classification).not.toBe('strong')
    expect(recommendation.viewModel.topics.some((topic) =>
      topic.reasonCodes.includes('declining_trend'))).toBe(true)
  })

  it('Mocks fortes stale reduzem Evidence e não permanecem Strong', () => {
    const bundle = profileWithMocks([84, 86, 85, 88], { stale: true })
    const result = calculateAz900Readiness(bundle)
    const recommendation = recommendationFor(bundle)

    expect(result.trace.recency).toBe('stale')
    expect(result.evidenceLevel).toBe('sufficient')
    expect(result.classification).not.toBe('strong')
    expect(recommendation.viewModel.topics.every((topic) =>
      topic.priority !== 'critical' && topic.reasonCodes.includes('stale_evidence'))).toBe(true)
  })
})

describe('Topic and source safeguards', () => {
  it('Topic sem evidência permanece null/Insufficient, não Needs Review', () => {
    const topic = calculateAz900Readiness(emptyReadinessBundle()).topics[0]

    expect(topic.readinessScore).toBeNull()
    expect(topic.classification).toBe('insufficient_evidence')
  })

  it('um erro isolado não cria Weak Topic nem prioridade Critical', () => {
    const topic = readinessTopics[0]
    const oneError = evidenceForTopic(topic.id, 'mock_exam', [0]).slice(0, 1)
    const bundle = { ...emptyReadinessBundle(), assessments: oneError }
    const readiness = calculateAz900Readiness(bundle)
    const recommendations = recommendationFor(bundle).viewModel

    expect(readiness.topics[0].evidenceLevel).toBe('limited')
    expect(readiness.weakTopicCandidates).toEqual([])
    expect(recommendations.topics.find((item) => item.topicId === topic.id)?.priority)
      .not.toBe('critical')
  })

  it('erros recorrentes em Mock e Topic Quiz confirmam Weak Topic com razões reais', () => {
    const topic = readinessTopics[0]
    const mock = evidenceForTopic(topic.id, 'mock_exam', [45, 45, 45]).map((event) => ({
      ...event,
      questionId: event.questionId.replace(/mock_exam:[^:]+:\d+/, 'mock_exam:repeated'),
    }))
    const topicQuiz = evidenceForTopic(topic.id, 'topic_quiz', [45, 45, 45])
    const bundle = { ...emptyReadinessBundle(), assessments: [...mock, ...topicQuiz] }
    const result = recommendationFor(bundle).viewModel.topics
      .find((item) => item.topicId === topic.id)

    expect(result?.priority).toBe('critical')
    expect(result?.reasonCodes).toEqual(expect.arrayContaining([
      'low_mock_performance',
      'repeated_mock_errors',
      'low_topic_quiz_performance',
    ]))
  })

  it('Mock baixo prevalece sobre Topic Quiz alto; Topic Quiz baixo também não é ignorado', () => {
    const topic = readinessTopics[0]
    const mockLow = {
      ...emptyReadinessBundle(),
      assessments: [
        ...evidenceForTopic(topic.id, 'mock_exam', [45, 45, 45]),
        ...evidenceForTopic(topic.id, 'topic_quiz', [90, 90, 90]),
      ],
    }
    const topicLow = {
      ...emptyReadinessBundle(),
      assessments: [
        ...evidenceForTopic(topic.id, 'mock_exam', [90, 90, 90]),
        ...evidenceForTopic(topic.id, 'topic_quiz', [45, 45, 45]),
      ],
    }
    const mockLowResult = calculateAz900Readiness(mockLow).topics[0]
    const topicLowResult = calculateAz900Readiness(topicLow).topics[0]

    expect(mockLowResult.classification).toBe('needs_review')
    expect(mockLowResult.trace.reasons).toContain('low_mock_performance')
    expect(topicLowResult.classification).toBe('needs_review')
    expect(topicLowResult.trace.reasons).toContain('repeated_topic_quiz_errors')
  })

  it('lacuna localizada continua visível e bloqueia overclassification do Domain/Global', () => {
    const target = readinessTopics.find((topic) => topic.domainId === 'domain-2')!
    const assessments = readinessTopics.flatMap((topic) => [
      ...evidenceForTopic(topic.id, 'mock_exam', [85, 85, 85]),
      ...evidenceForTopic(topic.id, 'topic_quiz',
        topic.id === target.id ? [45, 45, 45] : [90, 90, 90]),
    ])
    const bundle = { ...emptyReadinessBundle(), assessments }
    const readiness = calculateAz900Readiness(bundle)
    const recommendation = recommendationFor(bundle).viewModel.topics
      .find((topic) => topic.topicId === target.id)

    expect(readiness.topics.find((topic) => topic.topicId === target.id)?.classification)
      .toBe('needs_review')
    expect(readiness.domains.find((domain) => domain.domainId === target.domainId)
      ?.classification).toBe('needs_review')
    expect(readiness.classification).toBe('needs_review')
    expect(recommendation).toBeDefined()
  })
})

describe('Recency, consistency, trend and weighting math', () => {
  it('a resposta de 2 dias influencia mais que a resposta da mesma Question há 120 dias', () => {
    const topic = readinessTopics[0]
    const template = evidenceForTopic(topic.id, 'mock_exam', [0]).slice(0, 1)[0]
    const event = (
      id: string,
      outcome: AssessmentEvidence['outcome'],
      occurredAt: string,
    ): AssessmentEvidence => ({
      ...template,
      id,
      attemptId: id,
      questionId: 'same-question',
      outcome,
      occurredAt,
    })
    const recentCorrect = calculateAz900Readiness({
      ...emptyReadinessBundle(),
      assessments: [
        event('old', 'incorrect', '2026-05-02T12:00:00.000Z'),
        event('recent', 'correct', '2026-08-28T12:00:00.000Z'),
      ],
    }).topics[0]
    const recentIncorrect = calculateAz900Readiness({
      ...emptyReadinessBundle(),
      assessments: [
        event('old', 'correct', '2026-05-02T12:00:00.000Z'),
        event('recent', 'incorrect', '2026-08-28T12:00:00.000Z'),
      ],
    }).topics[0]

    expect(recentCorrect.readinessScore).toBe(71.43)
    expect(recentIncorrect.readinessScore).toBe(28.57)
  })

  it('consistency diferencia scores concentrados de scores voláteis com média semelhante', () => {
    const consistent = calculateConsistency(
      exactMockScores([84, 85, 86, 85]),
      AZ900_READINESS_CONFIG,
    )
    const volatile = calculateConsistency(
      exactMockScores([50, 95, 55, 90]),
      AZ900_READINESS_CONFIG,
    )

    expect(consistent).toMatchObject({ level: 'high', scoreRange: 2 })
    expect(volatile).toMatchObject({ level: 'low', scoreRange: 45 })
  })

  it.each([
    [[55, 65, 75], 'improving'],
    [[84, 85, 83], 'stable'],
    [[85, 74, 63], 'declining'],
    [[85], 'insufficient_data'],
  ] as const)('classifica trend %j como %s', (scores, expected) => {
    expect(calculateTrend(profileWithMocks(scores).assessments, AZ900_READINESS_CONFIG))
      .toBe(expected)
  })

  it('usa timestamps absolutos e mantém boundaries de recency independentes do timezone local', () => {
    expect(getRecencyBucket('2026-08-16T12:00:00.000Z', READINESS_AS_OF,
      AZ900_READINESS_CONFIG)).toBe('fresh')
    expect(getRecencyBucket('2026-08-16T11:59:59.999Z', READINESS_AS_OF,
      AZ900_READINESS_CONFIG)).toBe('recent')
    expect(getRecencyBucket('2026-08-16T09:00:00.000-03:00', READINESS_AS_OF,
      AZ900_READINESS_CONFIG)).toBe('fresh')
  })

  it('pesos globais são fixos, somam 1 e reproduzem o score dos Domains', () => {
    const result = calculateAz900Readiness(profileWithWeakDomain())
    const weights = AZ900_READINESS_CONFIG.domainWeightsByOrder
    const expected = result.domains.reduce((total, domain, index) =>
      total + (domain.readinessScore ?? 0) * weights[index + 1], 0)

    expect(weights[1] + weights[2] + weights[3]).toBe(1)
    expect(result.readinessScore).toBe(Math.round(expected * 100) / 100)
  })
})

describe('falseStrongSafeguards', () => {
  const cases: readonly [string, () => ReadinessEvidenceBundle][] = [
    ['A — 100% Lessons e zero assessment', profileWithLessonsOnly],
    ['B — um Mock de 95%', () => profileWithMocks([95])],
    ['C — score global bom com Domain fraco', profileWithWeakDomain],
    ['D — evidência forte antiga', () => profileWithMocks([85, 85, 85, 85], { stale: true })],
    ['E — baixa Topic coverage', () => ({
      ...emptyReadinessBundle(),
      assessments: evidenceForTopic(readinessTopics[0].id, 'mock_exam', [95, 95, 95]),
    })],
    ['F — performance extremamente inconsistente', () =>
      addTopicQuizAttempts(profileWithMocks([50, 95, 55, 90]), 90, 3)],
    ['G — muitos Topic Quizzes altos e nenhum Mock', () =>
      addTopicQuizAttempts(emptyReadinessBundle(), 95, 5)],
  ]

  it.each(cases)('%s não retorna Strong', (_name, fixture) => {
    expect(calculateAz900Readiness(fixture()).classification).not.toBe('strong')
  })
})

describe('Recommendation closure safeguards', () => {
  it('ordena Lessons A(5 erros), B(3) e não promove C(0)', () => {
    const topic = readinessTopics[0]
    const lessons = Array.from({ length: 5 }, (_, index) => ({
      id: `lesson-rank-${index + 1}`,
      topicId: topic.id,
      title: `Lesson ${String.fromCharCode(65 + index)}`,
      slug: `lesson-rank-${index + 1}`,
      displayOrder: index + 1,
    }))
    const events = evidenceForTopic(topic.id, 'topic_quiz', [30, 30, 30]).map(
      (event, index): AssessmentEvidence => ({
        ...event,
        lessonId: index < 5 ? lessons[0].id : index < 8 ? lessons[1].id : lessons[2].id,
        outcome: index < 8 ? 'incorrect' : 'correct',
      }),
    )
    const bundle: ReadinessEvidenceBundle = {
      ...emptyReadinessBundle(),
      topics: [
        { ...topic, lessonIds: lessons.map((lesson) => lesson.id) },
        ...readinessTopics.slice(1),
      ],
      lessons: [...lessons, ...readinessLessons.slice(1)],
      assessments: events,
    }
    const recommendation = recommendationFor(bundle).viewModel.topics
      .find((item) => item.topicId === topic.id)

    expect(recommendation?.recommendedLessons.map((lesson) => lesson.title))
      .toEqual(['Lesson A', 'Lesson B'])
  })

  it('mantém limits, actions válidas e determinismo em três execuções', () => {
    const bundle = assessmentOnly('topic_quiz', 45)
    const run = () => recommendationFor(bundle)
    const first = run()

    expect(first.viewModel.topics).toHaveLength(3)
    expect(first.viewModel.topics.every((topic) => topic.recommendedLessons.length <= 3))
      .toBe(true)
    for (const topic of first.viewModel.topics) {
      expect(topic.actions.every((action) =>
        action.route.startsWith('/certifications/az-900/'))).toBe(true)
    }
    expect(run()).toEqual(first)
    expect(run()).toEqual(first)
  })

  it('Insufficient Evidence recomenda assessment e todos os reason codes têm mapping', () => {
    const result = recommendationFor(emptyReadinessBundle()).viewModel
    const allReasonCodes = [
      'confirmed_weak_topic',
      'low_mock_performance',
      'repeated_mock_errors',
      'low_topic_quiz_performance',
      'repeated_topic_quiz_errors',
      'declining_trend',
      'inconsistent_performance',
      'insufficient_evidence',
      'stale_evidence',
      'domain_weakness',
      'developing_performance',
      'improving_performance',
    ]

    expect(result.topics.every((topic) =>
      topic.reasonCodes.includes('insufficient_evidence')
      && !topic.reasonCodes.includes('confirmed_weak_topic')
      && topic.actions.some((action) => action.type === 'assess_topic'))).toBe(true)
    expect(Object.keys(recommendationReasonLabels).sort()).toEqual([...allReasonCodes].sort())
  })

  it('metadata opcional ausente permanece compatível e não derruba as engines', () => {
    const events = profileWithMocks([75, 75, 75]).assessments.map((event) => ({
      ...event,
      difficulty: null,
      durationSeconds: null,
    }))
    const bundle = { ...emptyReadinessBundle(), assessments: events }

    expect(() => calculateAz900Readiness(bundle)).not.toThrow()
    expect(() => recommendationFor(bundle)).not.toThrow()
  })
})

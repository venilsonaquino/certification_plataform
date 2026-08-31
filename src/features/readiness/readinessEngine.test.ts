import { describe, expect, it } from 'vitest'

import {
  addTopicQuizAttempts,
  emptyReadinessBundle,
  evidenceForTopic,
  profileConsistentStrong,
  profileImproving,
  profileOneLuckyMock,
  profileWeak,
  profileWithLessonsOnly,
  profileWithMocks,
  profileWithWeakDomain,
  readinessTopics,
} from '../../test/readinessFixtures'
import { calculateAz900Readiness } from './readinessEngine'

describe('AZ-900 Readiness Calculation Engine', () => {
  it('Profile A — retorna Not Enough Evidence para aluno novo', () => {
    const result = calculateAz900Readiness(emptyReadinessBundle())

    expect(result.classification).toBe('not_enough_evidence')
    expect(result.readinessScore).toBeNull()
    expect(result.topics.every((topic) =>
      topic.classification === 'insufficient_evidence')).toBe(true)
  })

  it('Profile B — 100% das Lessons sem avaliação nunca produz Strong', () => {
    const result = calculateAz900Readiness(profileWithLessonsOnly())

    expect(result.classification).toBe('not_enough_evidence')
    expect(result.trace.learningProgress.completedLessons).toBe(12)
    expect(result.readinessScore).toBeNull()
  })

  it('Profile C — múltiplos desempenhos baixos produzem Needs Review', () => {
    const result = calculateAz900Readiness(profileWeak())

    expect(result.classification).toBe('needs_review')
    expect(result.weakTopicCandidates).toHaveLength(12)
    expect(result.weakTopicCandidates.every((topic) => topic.state === 'confirmed')).toBe(true)
  })

  it('Profile D — sequência crescente produz Improving sem falso Strong', () => {
    const result = calculateAz900Readiness(profileImproving())

    expect(result.trend).toBe('improving')
    expect(result.classification).toBe('developing')
  })

  it('Profile E — Mocks fortes, consistentes e cobertura ampla produzem Strong', () => {
    const result = calculateAz900Readiness(profileConsistentStrong())

    expect(result.classification).toBe('strong')
    expect(result.evidenceLevel).toBe('strong')
    expect(result.domains.every((domain) => domain.classification === 'strong')).toBe(true)
    expect(result.consistency.level).not.toBe('low')
  })

  it('Profile F — um Mock sortudo não equivale a desempenho consistente', () => {
    const result = calculateAz900Readiness(profileOneLuckyMock())

    expect(result.classification).not.toBe('strong')
    expect(result.consistency.level).toBe('low')
    expect(result.trace.reasons).toContain('inconsistent_performance')
  })

  it('Profile G — Domain fraco impede classificação global exagerada', () => {
    const result = calculateAz900Readiness(profileWithWeakDomain())
    const weakDomain = result.domains.find((domain) => domain.domainId === 'domain-3')

    expect(weakDomain?.classification).toBe('needs_review')
    expect(result.classification).toBe('needs_review')
    expect(result.trace.reasons).toContain('weak_domain')
  })

  it('é determinístico para o mesmo bundle e evidenceAsOf', () => {
    const bundle = profileConsistentStrong()

    expect(calculateAz900Readiness(bundle)).toEqual(calculateAz900Readiness(bundle))
  })
})

describe('Topic Readiness', () => {
  const topic = readinessTopics[0]

  it('não transforma ausência de evidência em zero por cento', () => {
    const result = calculateAz900Readiness(emptyReadinessBundle()).topics[0]

    expect(result.classification).toBe('insufficient_evidence')
    expect(result.readinessScore).toBeNull()
  })

  it('mantém uma única sessão como evidência limitada', () => {
    const bundle = {
      ...emptyReadinessBundle(),
      assessments: evidenceForTopic(topic.id, 'topic_quiz', [90]),
    }
    const result = calculateAz900Readiness(bundle).topics[0]

    expect(result.evidenceLevel).toBe('limited')
    expect(result.classification).toBe('insufficient_evidence')
  })

  it('prioriza baixo desempenho repetido em Mock diante de Topic Quiz alto', () => {
    const bundle = {
      ...emptyReadinessBundle(),
      assessments: [
        ...evidenceForTopic(topic.id, 'mock_exam', [45, 50, 55]),
        ...evidenceForTopic(topic.id, 'topic_quiz', [90, 90, 90]),
      ],
    }
    const result = calculateAz900Readiness(bundle)
    const topicResult = result.topics[0]

    expect(topicResult.classification).toBe('needs_review')
    expect(topicResult.trace.reasons).toContain('low_mock_performance')
    expect(result.weakTopicCandidates[0]).toMatchObject({
      topicId: topic.id,
      state: 'confirmed',
    })
  })

  it('mantém Needs Review quando Topic Quiz repete erros apesar de Mock alto', () => {
    const bundle = {
      ...emptyReadinessBundle(),
      assessments: [
        ...evidenceForTopic(topic.id, 'mock_exam', [90, 90, 90]),
        ...evidenceForTopic(topic.id, 'topic_quiz', [45, 50, 55]),
      ],
    }
    const topicResult = calculateAz900Readiness(bundle).topics[0]

    expect(topicResult.classification).toBe('needs_review')
    expect(topicResult.trace.reasons).toContain('repeated_topic_quiz_errors')
  })

  it('classifica tendência crescente, estável e decrescente', () => {
    const improving = calculateAz900Readiness({
      ...emptyReadinessBundle(),
      assessments: evidenceForTopic(topic.id, 'topic_quiz', [50, 60, 80]),
    }).topics[0]
    const stable = calculateAz900Readiness({
      ...emptyReadinessBundle(),
      assessments: evidenceForTopic(topic.id, 'topic_quiz', [86, 84, 85, 87]),
    }).topics[0]
    const declining = calculateAz900Readiness({
      ...emptyReadinessBundle(),
      assessments: evidenceForTopic(topic.id, 'topic_quiz', [85, 70, 55]),
    }).topics[0]

    expect(improving.trend).toBe('improving')
    expect(stable.trend).toBe('stable')
    expect(declining.trend).toBe('declining')
  })

  it('reduz a influência de evidência antiga de modo explicável', () => {
    const events = [
      ...evidenceForTopic(topic.id, 'mock_exam', [40], true),
      ...evidenceForTopic(topic.id, 'mock_exam', [90]),
    ]
    const result = calculateAz900Readiness({
      ...emptyReadinessBundle(),
      assessments: events,
    }).topics[0]

    expect(result.trace.weightedPerformance).toBeGreaterThan(result.trace.rawAccuracy ?? 0)
    expect(result.trace.recency).toBe('fresh')
  })

  it('detecta erros repetidos de Topic Quiz somente com amostra suficiente', () => {
    const result = calculateAz900Readiness({
      ...emptyReadinessBundle(),
      assessments: evidenceForTopic(topic.id, 'topic_quiz', [50, 50, 50]),
    })

    expect(result.weakTopicCandidates).toEqual([
      expect.objectContaining({
        topicId: topic.id,
        state: 'confirmed',
        reasonCodes: expect.arrayContaining(['repeated_topic_quiz_errors']),
      }),
    ])
  })
})

describe('Domain Readiness', () => {
  it('todos os Topics fortes permitem Domain forte', () => {
    const result = calculateAz900Readiness(profileConsistentStrong())

    expect(result.domains.every((domain) => domain.topicCoverage === 1)).toBe(true)
    expect(result.domains.every((domain) => domain.classification === 'strong')).toBe(true)
  })

  it('pouca cobertura mantém o Domain como Insufficient Evidence', () => {
    const onlyOneTopic = readinessTopics[3]
    const result = calculateAz900Readiness({
      ...emptyReadinessBundle(),
      assessments: evidenceForTopic(onlyOneTopic.id, 'topic_quiz', [90, 90, 90]),
    })
    const domain = result.domains.find((item) => item.domainId === onlyOneTopic.domainId)

    expect(domain?.classification).toBe('insufficient_evidence')
    expect(domain?.trace.reasons).toContain('insufficient_topic_coverage')
  })

  it('Topic crítico impede Domain perfeito apesar da média agregada', () => {
    const bundle = profileConsistentStrong()
    const criticalTopic = readinessTopics[0]
    const withoutTopic = bundle.assessments.filter((event) => event.topicId !== criticalTopic.id)
    const assessments = [
      ...withoutTopic,
      ...evidenceForTopic(criticalTopic.id, 'mock_exam', [40, 40, 40, 40]),
      ...evidenceForTopic(criticalTopic.id, 'topic_quiz', [40, 40, 40]),
    ]
    const result = calculateAz900Readiness({ ...bundle, assessments })
    const domain = result.domains.find((item) => item.domainId === criticalTopic.domainId)

    expect(domain?.classification).toBe('needs_review')
    expect(domain?.weakTopicIds).toContain(criticalTopic.id)
  })
})

describe('Global Readiness safeguards', () => {
  it('um único Mock de 95% não produz Strong', () => {
    const result = calculateAz900Readiness(profileWithMocks([95]))

    expect(result.classification).not.toBe('strong')
    expect(result.trace.reasons).toContain('single_mock_only')
  })

  it('Topic Quizzes altos sem Mock produzem no máximo Developing', () => {
    const result = calculateAz900Readiness(
      addTopicQuizAttempts(emptyReadinessBundle(), 90, 4),
    )

    expect(result.classification).toBe('developing')
    expect(result.trace.reasons).toContain('no_finalized_mock')
  })

  it('evidência antiga não produz Strong', () => {
    const result = calculateAz900Readiness(
      profileWithMocks([90, 90, 90, 90], { stale: true }),
    )

    expect(result.classification).not.toBe('strong')
  })

  it('muitas não respondidas impedem Strong sem virarem erro de Topic', () => {
    const bundle = profileConsistentStrong()
    const assessments = bundle.assessments.map((event, index) =>
      event.source === 'mock_exam' && index % 5 === 0
        ? { ...event, outcome: 'unanswered' as const }
        : event)
    const result = calculateAz900Readiness({ ...bundle, assessments })

    expect(result.classification).not.toBe('strong')
    expect(result.trace.reasons).toContain('high_unanswered_rate')
  })
})

import { describe, expect, it } from 'vitest'

import {
  addTopicQuizAttempts,
  emptyReadinessBundle,
  evidenceForTopic,
  profileConsistentStrong,
  profileImproving,
  profileWeak,
  profileWithMocks,
  profileWithWeakDomain,
  readinessLessons,
  readinessTopics,
} from '../../test/readinessFixtures'
import type { AssessmentEvidence, ReadinessEvidenceBundle } from '../../types/readiness'
import type { StudyRecommendationCatalog } from '../../types/studyRecommendation'
import { calculateAz900Readiness } from './readinessEngine'
import { calculateStudyRecommendations } from './studyRecommendationEngine'

function catalogFor(
  bundle: ReadinessEvidenceBundle,
  options: {
    readonly questionsPerTopic?: number
    readonly withFlashcards?: boolean
    readonly mockEligible?: boolean
  } = {},
): StudyRecommendationCatalog {
  const questionsPerTopic = options.questionsPerTopic ?? 10
  return {
    certificationCode: 'az-900',
    lessons: bundle.lessons,
    questions: bundle.topics.flatMap((topic) =>
      Array.from({ length: questionsPerTopic }, (_, index) => ({
        id: `catalog-question:${topic.id}:${index}`,
        topicId: topic.id,
        lessonId: topic.lessonIds[0] ?? null,
        mockEligible: options.mockEligible ?? true,
      }))),
    flashcards: options.withFlashcards === false
      ? []
      : bundle.lessons.map((lesson) => ({
        id: `flashcard:${lesson.id}`,
        lessonId: lesson.id,
      })),
  }
}

function recommendationsFor(
  bundle: ReadinessEvidenceBundle,
  catalog = catalogFor(bundle),
) {
  return calculateStudyRecommendations(
    calculateAz900Readiness(bundle),
    bundle,
    catalog,
  )
}

describe('Study Recommendation profiles', () => {
  it('A — Strong Topic não recebe prioridade alta nem recomendação desnecessária', () => {
    const result = recommendationsFor(profileConsistentStrong())

    expect(result.viewModel.topics).toEqual([])
  })

  it('B — Weak Student recebe prioridades críticas e Lessons ligadas aos erros', () => {
    const bundle = profileWeak()
    const result = recommendationsFor(bundle)

    expect(result.viewModel.topics).toHaveLength(3)
    expect(result.viewModel.topics.every((topic) => topic.priority === 'critical')).toBe(true)
    expect(result.viewModel.topics.every((topic) =>
      topic.reasonCodes.includes('confirmed_weak_topic'))).toBe(true)
    expect(result.viewModel.topics.every((topic) => topic.recommendedLessons.length > 0)).toBe(true)
  })

  it('C — New Student recebe assessment, não rótulo de fraqueza', () => {
    const bundle = emptyReadinessBundle()
    const result = recommendationsFor(bundle)

    expect(result.viewModel.topics).toHaveLength(3)
    expect(result.viewModel.topics.every((topic) => topic.priority === 'low')).toBe(true)
    expect(result.viewModel.topics.every((topic) =>
      topic.reasonCodes.includes('insufficient_evidence'))).toBe(true)
    expect(result.viewModel.topics.every((topic) =>
      topic.actions.some((action) => action.type === 'assess_topic'))).toBe(true)
  })

  it('D — erros repetidos nas mesmas Questions de Mock aumentam prioridade', () => {
    const topic = readinessTopics[0]
    const baseEvents = evidenceForTopic(topic.id, 'mock_exam', [50, 50, 50])
    const recurringEvents = baseEvents.map((event) => ({
      ...event,
      questionId: event.questionId.replace(/mock_exam:[^:]+:\d+/, 'mock_exam:repeated'),
    }))
    const base = { ...emptyReadinessBundle(), assessments: baseEvents }
    const recurring = { ...emptyReadinessBundle(), assessments: recurringEvents }
    const baseTrace = recommendationsFor(base).debugTrace.find((item) => item.topicId === topic.id)
    const recurringResult = recommendationsFor(recurring)
    const recurringTrace = recurringResult.debugTrace.find((item) => item.topicId === topic.id)

    expect(recurringResult.viewModel.topics.find((item) => item.topicId === topic.id)
      ?.reasonCodes).toContain('repeated_mock_errors')
    expect(recurringTrace?.priorityScore).toBeGreaterThan(baseTrace?.priorityScore ?? 0)
  })

  it('E/F — Declining aumenta e Improving reduz a prioridade', () => {
    const topic = readinessTopics[0]
    const declining = {
      ...emptyReadinessBundle(),
      assessments: evidenceForTopic(topic.id, 'topic_quiz', [85, 70, 55]),
    }
    const improving = {
      ...emptyReadinessBundle(),
      assessments: evidenceForTopic(topic.id, 'topic_quiz', [55, 70, 85]),
    }
    const decliningTrace = recommendationsFor(declining).debugTrace
      .find((item) => item.topicId === topic.id)
    const improvingTrace = recommendationsFor(improving).debugTrace
      .find((item) => item.topicId === topic.id)

    expect(decliningTrace?.priorityScore).toBeGreaterThan(improvingTrace?.priorityScore ?? 0)
  })

  it('Strong Overall + Weak Domain foca recomendações no Domain fraco', () => {
    const result = recommendationsFor(profileWithWeakDomain())

    expect(result.viewModel.topics).toHaveLength(3)
    expect(result.viewModel.topics.every((topic) => topic.domainId === 'domain-3')).toBe(true)
    expect(result.viewModel.domains.find((domain) => domain.domainId === 'domain-3')
      ?.primaryTopicIds).toHaveLength(2)
  })
})

describe('Lesson ranking and CTA safeguards', () => {
  it('G — Lesson dominada não supera Lesson com erros recorrentes', () => {
    const topic = readinessTopics[0]
    const weakLesson = { ...readinessLessons[0], id: 'weak-lesson', slug: 'weak-lesson' }
    const masteredLesson = {
      ...readinessLessons[0],
      id: 'mastered-lesson',
      slug: 'mastered-lesson',
      displayOrder: 2,
    }
    const topicDefinition = { ...topic, lessonIds: [weakLesson.id, masteredLesson.id] }
    const events = evidenceForTopic(topic.id, 'topic_quiz', [50, 50, 50]).map(
      (event, index): AssessmentEvidence => ({
        ...event,
        lessonId: index < 20 ? weakLesson.id : masteredLesson.id,
        outcome: index < 20 ? 'incorrect' : 'correct',
      }),
    )
    const bundle: ReadinessEvidenceBundle = {
      ...emptyReadinessBundle(),
      topics: [topicDefinition, ...readinessTopics.slice(1)],
      lessons: [weakLesson, masteredLesson, ...readinessLessons.slice(1)],
      assessments: events,
    }
    const recommendation = recommendationsFor(bundle, catalogFor(bundle)).viewModel.topics
      .find((item) => item.topicId === topic.id)

    expect(recommendation?.recommendedLessons.map((lesson) => lesson.id)).toEqual([
      weakLesson.id,
    ])
  })

  it('não recomenda Flashcards quando nenhuma Lesson selecionada possui cards', () => {
    const bundle = profileWeak()
    const withoutCards = recommendationsFor(bundle, catalogFor(bundle, {
      withFlashcards: false,
    }))
    const withCards = recommendationsFor(bundle)

    expect(withoutCards.viewModel.topics[0].actions.some(
      (action) => action.type === 'review_flashcards')).toBe(false)
    expect(withCards.viewModel.topics[0].actions.some(
      (action) => action.type === 'review_flashcards')).toBe(true)
  })

  it('só cria CTA de Topic Quiz quando há Questions publicadas suficientes', () => {
    const bundle = profileWeak()
    const unavailable = recommendationsFor(bundle, catalogFor(bundle, {
      questionsPerTopic: 4,
    }))
    const available = recommendationsFor(bundle, catalogFor(bundle, {
      questionsPerTopic: 5,
    }))

    expect(unavailable.viewModel.topics[0].actions.some(
      (action) => action.type === 'retake_topic_quiz')).toBe(false)
    expect(available.viewModel.topics[0].actions.some(
      (action) => action.type === 'retake_topic_quiz')).toBe(true)
  })

  it('retorna somente Lessons publicadas no catálogo e rotas válidas', () => {
    const bundle = profileWeak()
    const catalog = catalogFor(bundle)
    const result = recommendationsFor(bundle, catalog)

    for (const topic of result.viewModel.topics) {
      for (const lesson of topic.recommendedLessons) {
        expect(catalog.lessons.some((item) => item.id === lesson.id)).toBe(true)
        expect(lesson.route).toBe(`/certifications/az-900/study/${lesson.slug}`)
      }
    }
  })

  it('limita a três Lessons mesmo quando quatro possuem erros', () => {
    const topic = readinessTopics[0]
    const extraLessons = Array.from({ length: 4 }, (_, index) => ({
      id: `ranked-lesson-${index + 1}`,
      topicId: topic.id,
      title: `Ranked Lesson ${index + 1}`,
      slug: `ranked-lesson-${index + 1}`,
      displayOrder: index + 1,
    }))
    const topicDefinition = { ...topic, lessonIds: extraLessons.map((lesson) => lesson.id) }
    const events = evidenceForTopic(topic.id, 'topic_quiz', [40, 40, 40]).map(
      (event, index) => ({
        ...event,
        lessonId: extraLessons[index % extraLessons.length].id,
      }),
    )
    const bundle: ReadinessEvidenceBundle = {
      ...emptyReadinessBundle(),
      topics: [topicDefinition, ...readinessTopics.slice(1)],
      lessons: [...extraLessons, ...readinessLessons.slice(1)],
      assessments: events,
    }
    const recommendation = recommendationsFor(bundle).viewModel.topics
      .find((item) => item.topicId === topic.id)

    expect(recommendation?.recommendedLessons).toHaveLength(3)
  })
})

describe('Ordering, limits and isolation', () => {
  it('H — Domain weight funciona apenas como desempate pequeno', () => {
    const result = recommendationsFor(emptyReadinessBundle())
    const domain1Trace = result.debugTrace.find((item) => item.topicId === 'topic-1-1')
    const domain2Trace = result.debugTrace.find((item) => item.topicId === 'topic-2-1')

    expect(domain2Trace?.domainWeightModifier).toBeGreaterThan(
      domain1Trace?.domainWeightModifier ?? 0,
    )
    expect((domain2Trace?.priorityScore ?? 0) - (domain1Trace?.priorityScore ?? 0))
      .toBeLessThan(1)
  })

  it('I — respeita o limite global de três Topics', () => {
    const result = recommendationsFor(profileWeak())

    expect(result.viewModel.topics).toHaveLength(3)
  })

  it('J — mesmo Readiness, bundle e catálogo produzem resultado idêntico', () => {
    const bundle = profileImproving()
    const readiness = calculateAz900Readiness(bundle)
    const catalog = catalogFor(bundle)

    expect(calculateStudyRecommendations(readiness, bundle, catalog)).toEqual(
      calculateStudyRecommendations(readiness, bundle, catalog),
    )
  })

  it('recomenda reavaliação sem Critical para evidência stale', () => {
    const bundle = profileWithMocks([45, 45, 45], { stale: true })
    const result = recommendationsFor(bundle)

    expect(result.viewModel.topics.every((topic) => topic.priority !== 'critical')).toBe(true)
    expect(result.viewModel.topics.every((topic) =>
      topic.reasonCodes.includes('stale_evidence'))).toBe(true)
  })

  it('não mistura recomendações de perfis A/B nem usa cache global por Topic', () => {
    const userA = recommendationsFor(profileWeak()).viewModel
    const userB = recommendationsFor(profileConsistentStrong()).viewModel

    expect(userA.topics.length).toBeGreaterThan(0)
    expect(userB.topics).toEqual([])
  })

  it('oferece Mock somente após assessment quando ainda não há Mock', () => {
    const bundle = emptyReadinessBundle()
    const result = recommendationsFor(bundle)
    const actions = result.viewModel.topics[0].actions.map((action) => action.type)

    expect(actions).toEqual(['assess_topic', 'take_another_mock'])
  })

  it('mantém prioridade de Mock baixo mesmo com Topic Quiz alto', () => {
    const topic = readinessTopics[0]
    const bundle = {
      ...emptyReadinessBundle(),
      assessments: [
        ...evidenceForTopic(topic.id, 'mock_exam', [45, 50, 55]),
        ...evidenceForTopic(topic.id, 'topic_quiz', [90, 90, 90]),
      ],
    }
    const recommendation = recommendationsFor(bundle).viewModel.topics
      .find((item) => item.topicId === topic.id)

    expect(recommendation?.priority).toMatch(/critical|high/)
    expect(recommendation?.reasonCodes).toContain('low_mock_performance')
  })

  it('many Topic Quizzes sem Mock permanece determinístico e não inventa mastery', () => {
    const bundle = addTopicQuizAttempts(emptyReadinessBundle(), 90, 4)
    const result = recommendationsFor(bundle)

    expect(result.viewModel.globalClassification).toBe('developing')
    expect(result.viewModel.topics).toEqual([])
  })
})


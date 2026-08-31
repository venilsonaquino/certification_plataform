import { lessonFlashcardsRoute, lessonRoute, mockExamsRoute, topicQuizRoute } from '../../lib/routes'
import type {
  AssessmentEvidence,
  GlobalReadiness,
  LearningEvidence,
  ReadinessEvidenceBundle,
  TopicReadiness,
  WeakTopicCandidate,
} from '../../types/readiness'
import type {
  DomainStudyRecommendation,
  LessonRecommendationReasonCode,
  ReadinessRecommendationViewModel,
  RecommendationEvidenceExplanation,
  RecommendedLesson,
  StudyRecommendationAction,
  StudyRecommendationCatalog,
  StudyRecommendationEngineResult,
  StudyRecommendationPriority,
  StudyRecommendationReasonCode,
  TopicRecommendationDebugTrace,
  TopicStudyRecommendation,
} from '../../types/studyRecommendation'
import { AZ900_READINESS_CONFIG } from './readinessConfig'
import { getRecencyBucket, roundScore } from './readinessMetrics'
import {
  AZ900_STUDY_RECOMMENDATION_CONFIG,
  type StudyRecommendationConfig,
} from './studyRecommendationConfig'

interface RankedTopicRecommendation {
  readonly recommendation: TopicStudyRecommendation
  readonly debug: TopicRecommendationDebugTrace
  readonly priorityScore: number
}

function unique<T>(values: readonly T[]): T[] {
  return [...new Set(values)]
}

function sourcePerformance(
  events: readonly AssessmentEvidence[],
  source: AssessmentEvidence['source'],
): number | null {
  const answered = events.filter(
    (event) => event.source === source && event.outcome !== 'unanswered',
  )
  if (answered.length === 0) return null
  return roundScore(
    answered.filter((event) => event.outcome === 'correct').length / answered.length * 100,
  )
}

function sourceAttemptCount(
  events: readonly AssessmentEvidence[],
  source: AssessmentEvidence['source'],
): number {
  return new Set(events.filter((event) => event.source === source)
    .map((event) => event.attemptId)).size
}

function recurringIncorrectQuestionCount(
  events: readonly AssessmentEvidence[],
  source?: AssessmentEvidence['source'],
): number {
  const incorrect = events.filter((event) =>
    event.outcome === 'incorrect' && (!source || event.source === source))
  const attemptsByQuestion = new Map<string, Set<string>>()
  for (const event of incorrect) {
    const attempts = attemptsByQuestion.get(event.questionId) ?? new Set<string>()
    attempts.add(event.attemptId)
    attemptsByQuestion.set(event.questionId, attempts)
  }
  return [...attemptsByQuestion.values()].filter((attempts) => attempts.size >= 2).length
}

function isRecent(occurredAt: string, evidenceAsOf: string): boolean {
  const bucket = getRecencyBucket(occurredAt, evidenceAsOf, AZ900_READINESS_CONFIG)
  return bucket === 'fresh' || bucket === 'recent'
}

function buildEvidenceExplanation(
  topic: TopicReadiness,
  events: readonly AssessmentEvidence[],
  evidenceAsOf: string,
): RecommendationEvidenceExplanation {
  return {
    mockPerformance: sourcePerformance(events, 'mock_exam'),
    topicQuizPerformance: sourcePerformance(events, 'topic_quiz'),
    lessonQuizPerformance: sourcePerformance(events, 'lesson_quiz'),
    recentIncorrectAnswers: events.filter(
      (event) => event.outcome === 'incorrect' && isRecent(event.occurredAt, evidenceAsOf),
    ).length,
    recurringIncorrectQuestions: recurringIncorrectQuestionCount(events),
    latestEvidenceAt: topic.trace.latestEvidenceAt,
  }
}

function buildReasonCodes(
  topic: TopicReadiness,
  weakCandidate: WeakTopicCandidate | undefined,
  domainIsWeak: boolean,
  events: readonly AssessmentEvidence[],
): StudyRecommendationReasonCode[] {
  const reasons: StudyRecommendationReasonCode[] = []
  const mockPerformance = sourcePerformance(events, 'mock_exam')
  const topicQuizPerformance = sourcePerformance(events, 'topic_quiz')

  if (weakCandidate?.state === 'confirmed') reasons.push('confirmed_weak_topic')
  if (weakCandidate?.reasonCodes.includes('low_mock_performance')) {
    reasons.push('low_mock_performance')
  }
  if (recurringIncorrectQuestionCount(events, 'mock_exam') > 0) {
    reasons.push('repeated_mock_errors')
  }
  if (
    sourceAttemptCount(events, 'topic_quiz') >= 2
    && topicQuizPerformance !== null
    && topicQuizPerformance < AZ900_READINESS_CONFIG.safeguards.weakPerformanceBelow
  ) reasons.push('low_topic_quiz_performance')
  if (weakCandidate?.reasonCodes.includes('repeated_topic_quiz_errors')) {
    reasons.push('repeated_topic_quiz_errors')
  }
  if (topic.trend === 'declining') reasons.push('declining_trend')
  if (topic.consistency.level === 'low') reasons.push('inconsistent_performance')
  if (topic.classification === 'insufficient_evidence') reasons.push('insufficient_evidence')
  if (topic.trace.recency === 'stale') reasons.push('stale_evidence')
  if (domainIsWeak) reasons.push('domain_weakness')
  if (topic.classification === 'developing') reasons.push('developing_performance')
  if (topic.trend === 'improving') reasons.push('improving_performance')

  if (
    mockPerformance !== null
    && mockPerformance < AZ900_READINESS_CONFIG.safeguards.weakPerformanceBelow
    && sourceAttemptCount(events, 'mock_exam') >= 2
    && !reasons.includes('low_mock_performance')
  ) reasons.push('low_mock_performance')

  return unique(reasons)
}

function basePriorityScore(
  topic: TopicReadiness,
  weakCandidate: WeakTopicCandidate | undefined,
  config: StudyRecommendationConfig,
): number {
  if (weakCandidate?.state === 'confirmed') return config.priority.baseScores.confirmedWeak
  if (weakCandidate?.state === 'watch') return config.priority.baseScores.watchWeak
  if (topic.classification === 'needs_review') return config.priority.baseScores.needsReview
  if (topic.classification === 'developing') return config.priority.baseScores.developing
  return config.priority.baseScores.insufficientEvidence
}

function priorityFromScore(
  score: number,
  topic: TopicReadiness,
  weakCandidate: WeakTopicCandidate | undefined,
  config: StudyRecommendationConfig,
): StudyRecommendationPriority {
  if (
    score >= config.priority.thresholds.critical
    && weakCandidate?.state === 'confirmed'
    && topic.evidenceLevel === 'strong'
    && topic.trace.recency !== 'stale'
  ) return 'critical'
  if (score >= config.priority.thresholds.high) return 'high'
  if (score >= config.priority.thresholds.medium) return 'medium'
  return 'low'
}

function lessonReasonCodes(
  events: readonly AssessmentEvidence[],
  learning: readonly LearningEvidence[],
  evidenceAsOf: string,
): LessonRecommendationReasonCode[] {
  const reasons: LessonRecommendationReasonCode[] = []
  if (events.some((event) => event.source === 'mock_exam' && event.outcome === 'incorrect')) {
    reasons.push('mock_errors')
  }
  if (events.some((event) => event.source === 'topic_quiz' && event.outcome === 'incorrect')) {
    reasons.push('topic_quiz_errors')
  }
  if (events.some((event) => event.source === 'lesson_quiz' && event.outcome === 'incorrect')) {
    reasons.push('lesson_quiz_errors')
  }
  if (recurringIncorrectQuestionCount(events) > 0) reasons.push('recurring_question_errors')
  if (events.some((event) =>
    event.outcome === 'incorrect' && isRecent(event.occurredAt, evidenceAsOf))) {
    reasons.push('recent_incorrect_answers')
  }
  if (learning.some((event) =>
    event.source === 'flashcard_progress'
      && event.dueAt !== null
      && event.dueAt <= evidenceAsOf)) {
    reasons.push('due_flashcards')
  }
  return reasons
}

function calculateLessonScore(
  events: readonly AssessmentEvidence[],
  learning: readonly LearningEvidence[],
  evidenceAsOf: string,
  config: StudyRecommendationConfig,
): number {
  let score = 0
  for (const event of events) {
    const recency = getRecencyBucket(
      event.occurredAt,
      evidenceAsOf,
      AZ900_READINESS_CONFIG,
    )
    const recencyWeight = AZ900_READINESS_CONFIG.recency.weights[recency]
    if (event.outcome === 'incorrect') {
      score += config.lessonRanking.sourceErrorWeights[event.source] * recencyWeight
      if (isRecent(event.occurredAt, evidenceAsOf)) {
        score += config.lessonRanking.recentErrorBonus
      }
    } else if (event.outcome === 'correct') {
      score -= config.lessonRanking.correctAnswerOffsets[event.source] * recencyWeight
    }
  }

  const incorrectByQuestion = new Map<string, number>()
  for (const event of events.filter((item) => item.outcome === 'incorrect')) {
    incorrectByQuestion.set(event.questionId, (incorrectByQuestion.get(event.questionId) ?? 0) + 1)
  }
  for (const count of incorrectByQuestion.values()) {
    const repeats = Math.min(count, config.lessonRanking.maximumRepeatedQuestionCount) - 1
    if (repeats > 0) score += repeats * config.lessonRanking.recurringErrorBonus
  }

  if (learning.some((event) =>
    event.source === 'flashcard_progress'
      && event.dueAt !== null
      && event.dueAt <= evidenceAsOf)) {
    score += config.lessonRanking.dueFlashcardBonus
  }
  return roundScore(score)
}

function rankLessons(
  topic: TopicReadiness,
  bundle: ReadinessEvidenceBundle,
  catalog: StudyRecommendationCatalog,
  config: StudyRecommendationConfig,
): { lessons: RecommendedLesson[]; scores: Readonly<Record<string, number>> } {
  const catalogLessons = catalog.lessons.filter((lesson) => lesson.topicId === topic.topicId)
  const ranked = catalogLessons.map((lesson) => {
    const events = bundle.assessments.filter((event) => event.lessonId === lesson.id)
    const learning = bundle.learning.filter((event) => event.lessonId === lesson.id)
    const errors = events.filter((event) => event.outcome === 'incorrect')
    return {
      lesson,
      events,
      learning,
      errors,
      score: calculateLessonScore(events, learning, bundle.evidenceAsOf, config),
    }
  }).filter((item) => item.errors.length > 0 && item.score > 0)
    .sort((left, right) =>
      right.score - left.score
      || left.lesson.displayOrder - right.lesson.displayOrder
      || left.lesson.id.localeCompare(right.lesson.id))

  const selected = ranked.slice(0, config.limits.maxLessonsPerTopic)
  return {
    lessons: selected.map(({ lesson, events, learning }) => ({
      id: lesson.id,
      title: lesson.title,
      slug: lesson.slug,
      route: lessonRoute(catalog.certificationCode, lesson.slug),
      reasonCodes: lessonReasonCodes(events, learning, bundle.evidenceAsOf),
    })),
    scores: Object.fromEntries(ranked.map((item) => [item.lesson.id, item.score])),
  }
}

function buildActions(
  topic: TopicReadiness,
  lessons: readonly RecommendedLesson[],
  catalog: StudyRecommendationCatalog,
  hasAnyMockEvidence: boolean,
  config: StudyRecommendationConfig,
): StudyRecommendationAction[] {
  const actions: StudyRecommendationAction[] = []
  if (lessons[0]) {
    actions.push({ type: 'review_lesson', route: lessons[0].route, targetId: lessons[0].id })
  }

  const flashcardLesson = lessons.find((lesson) =>
    catalog.flashcards.some((flashcard) => flashcard.lessonId === lesson.id))
  if (flashcardLesson) {
    actions.push({
      type: 'review_flashcards',
      route: lessonFlashcardsRoute(catalog.certificationCode, flashcardLesson.slug),
      targetId: flashcardLesson.id,
    })
  }

  const topicQuestionCount = catalog.questions.filter(
    (question) => question.topicId === topic.topicId,
  ).length
  if (topicQuestionCount >= config.availability.minimumTopicQuizQuestions) {
    actions.push({
      type: topic.classification === 'insufficient_evidence'
        ? 'assess_topic'
        : 'retake_topic_quiz',
      route: topicQuizRoute(catalog.certificationCode, topic.topicId),
      targetId: topic.topicId,
    })
  }

  const mockQuestionCount = catalog.questions.filter((question) => question.mockEligible).length
  if (
    !hasAnyMockEvidence
    && topic.classification === 'insufficient_evidence'
    && mockQuestionCount >= config.availability.minimumMockQuestions
  ) {
    actions.push({
      type: 'take_another_mock',
      route: mockExamsRoute(catalog.certificationCode),
      targetId: null,
    })
  }
  return actions
}

function buildRankedTopic(
  topic: TopicReadiness,
  readiness: GlobalReadiness,
  bundle: ReadinessEvidenceBundle,
  catalog: StudyRecommendationCatalog,
  config: StudyRecommendationConfig,
): RankedTopicRecommendation | null {
  if (topic.classification === 'strong') return null

  const weakCandidate = readiness.weakTopicCandidates.find(
    (candidate) => candidate.topicId === topic.topicId,
  )
  const domain = readiness.domains.find((item) => item.domainId === topic.domainId)
  const domainDefinition = bundle.domains.find((item) => item.id === topic.domainId)
  const events = bundle.assessments.filter((event) => event.topicId === topic.topicId)
  const reasons = buildReasonCodes(
    topic,
    weakCandidate,
    domain?.classification === 'needs_review',
    events,
  )
  const domainWeight = domainDefinition
    ? AZ900_READINESS_CONFIG.domainWeightsByOrder[domainDefinition.displayOrder] ?? 0
    : 0
  const domainWeightModifier = domainWeight * config.priority.domainWeightModifierScale
  let priorityScore = basePriorityScore(topic, weakCandidate, config)
    + reasons.reduce(
      (total, reason) => total + config.priority.reasonModifiers[reason],
      0,
    )
    + domainWeightModifier
  if (topic.trace.recency === 'stale') {
    priorityScore = Math.min(priorityScore, config.priority.thresholds.high - 1)
  }

  const rankedLessons = rankLessons(topic, bundle, catalog, config)
  const hasAnyMockEvidence = bundle.assessments.some((event) => event.source === 'mock_exam')
  const recommendation: TopicStudyRecommendation = {
    topicId: topic.topicId,
    topicTitle: topic.title,
    domainId: topic.domainId,
    priority: priorityFromScore(priorityScore, topic, weakCandidate, config),
    classification: topic.classification,
    evidenceLevel: topic.evidenceLevel,
    trend: topic.trend,
    reasonCodes: reasons,
    evidence: buildEvidenceExplanation(topic, events, bundle.evidenceAsOf),
    recommendedLessons: rankedLessons.lessons,
    actions: buildActions(
      topic,
      rankedLessons.lessons,
      catalog,
      hasAnyMockEvidence,
      config,
    ),
  }
  return {
    recommendation,
    priorityScore,
    debug: {
      topicId: topic.topicId,
      priorityScore: roundScore(priorityScore),
      domainWeightModifier: roundScore(domainWeightModifier),
      lessonScores: rankedLessons.scores,
    },
  }
}

function buildDomainSummaries(
  readiness: GlobalReadiness,
  recommendations: readonly TopicStudyRecommendation[],
  config: StudyRecommendationConfig,
): DomainStudyRecommendation[] {
  return readiness.domains.map((domain) => ({
    domainId: domain.domainId,
    domainTitle: domain.title,
    classification: domain.classification,
    primaryTopicIds: recommendations
      .filter((recommendation) => recommendation.domainId === domain.domainId)
      .slice(0, config.limits.maxTopicsPerDomain)
      .map((recommendation) => recommendation.topicId),
  }))
}

export function calculateStudyRecommendations(
  readiness: GlobalReadiness,
  bundle: ReadinessEvidenceBundle,
  catalog: StudyRecommendationCatalog,
  config: StudyRecommendationConfig = AZ900_STUDY_RECOMMENDATION_CONFIG,
): StudyRecommendationEngineResult {
  const ranked = readiness.topics.map((topic) =>
    buildRankedTopic(topic, readiness, bundle, catalog, config))
    .filter((item): item is RankedTopicRecommendation => item !== null)
    .sort((left, right) =>
      right.priorityScore - left.priorityScore
      || left.recommendation.topicTitle.localeCompare(right.recommendation.topicTitle)
      || left.recommendation.topicId.localeCompare(right.recommendation.topicId))

  const selected = ranked.slice(0, config.limits.maxPriorityTopics)
  const topics = selected.map((item) => item.recommendation)
  const viewModel: ReadinessRecommendationViewModel = {
    calculationVersion: config.calculationVersion,
    evidenceAsOf: readiness.evidenceAsOf,
    globalClassification: readiness.classification,
    topics,
    domains: buildDomainSummaries(readiness, topics, config),
  }
  return { viewModel, debugTrace: ranked.map((item) => item.debug) }
}


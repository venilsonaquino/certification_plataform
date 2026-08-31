import type {
  AssessmentEvidence,
  DomainReadiness,
  EvidenceLevel,
  GlobalReadiness,
  LearningEvidence,
  ReadinessDomainDefinition,
  ReadinessEvidenceBundle,
  ReadinessEvidenceTrace,
  ReadinessReasonCode,
  ReadinessTopicDefinition,
  ScopedReadinessClassification,
  TopicReadiness,
  WeakTopicCandidate,
} from '../../types/readiness'
import { AZ900_READINESS_CONFIG, type ReadinessConfig } from './readinessConfig'
import {
  addReason,
  calculateConsistency,
  calculateTrend,
  evaluateTopicEvidenceLevel,
  getAttemptPerformances,
  roundScore,
  summarizeAssessmentEvidence,
} from './readinessMetrics'

function scopedLearning(
  learning: readonly LearningEvidence[],
  predicate: (event: LearningEvidence) => boolean,
): LearningEvidence[] {
  return learning.filter(predicate)
}

function withReasons(
  trace: ReadinessEvidenceTrace,
  reasons: readonly ReadinessReasonCode[],
): ReadinessEvidenceTrace {
  return { ...trace, reasons: [...new Set(reasons)] }
}

function evidenceReasons(trace: ReadinessEvidenceTrace, config: ReadinessConfig) {
  const reasons: ReadinessReasonCode[] = []
  addReason(reasons, trace.answeredQuestions < config.evidence.topic.sufficientAnswers,
    'insufficient_assessments')
  addReason(reasons, trace.assessmentSessions < config.evidence.topic.sufficientSessions,
    'insufficient_sessions')
  addReason(reasons, trace.distinctQuestions < config.evidence.topic.sufficientDistinctQuestions,
    'insufficient_question_diversity')
  addReason(reasons, trace.recency === 'stale', 'stale_evidence')
  return reasons
}

function calculateTopic(
  topic: ReadinessTopicDefinition,
  bundle: ReadinessEvidenceBundle,
  config: ReadinessConfig,
): TopicReadiness {
  const events = bundle.assessments.filter((event) => event.topicId === topic.id)
  const learning = scopedLearning(bundle.learning, (event) => event.topicId === topic.id)
  const baseTrace = summarizeAssessmentEvidence(
    events,
    bundle.evidenceAsOf,
    config,
    [],
    learning,
    topic.lessonIds.length,
  )
  const evidenceLevel = evaluateTopicEvidenceLevel(baseTrace, config)
  const trend = calculateTrend(events, config)
  const consistency = calculateConsistency(events, config)
  const score = baseTrace.weightedPerformance
  const mockPerformance = averageAttemptScores(events, 'mock_exam')
  const topicQuizPerformance = averageAttemptScores(events, 'topic_quiz')
  const repeatedLowMock = mockPerformance.count >= 2
    && mockPerformance.average !== null
    && mockPerformance.average < config.safeguards.weakPerformanceBelow
  const repeatedLowTopicQuiz = topicQuizPerformance.count >= 2
    && topicQuizPerformance.average !== null
    && topicQuizPerformance.average < config.safeguards.weakPerformanceBelow
  const reasons = evidenceReasons(baseTrace, config)
  addReason(reasons, score !== null && score < config.classification.needsReviewBelow,
    'low_performance')
  addReason(reasons, trend === 'declining', 'declining_performance')
  addReason(reasons, consistency.level === 'low', 'inconsistent_performance')
  addReason(reasons, repeatedLowMock, 'low_mock_performance')
  addReason(reasons, repeatedLowTopicQuiz, 'repeated_topic_quiz_errors')

  let classification: ScopedReadinessClassification = 'developing'
  if (evidenceLevel === 'insufficient' || evidenceLevel === 'limited') {
    classification = 'insufficient_evidence'
  } else if (
    (score !== null && score < config.classification.needsReviewBelow)
    || repeatedLowMock
    || repeatedLowTopicQuiz
  ) {
    classification = 'needs_review'
  } else {
    const sourceCounts = new Map(baseTrace.sourceCounts.map((item) => [item.source, item]))
    const hasStrongAssessmentSource =
      (sourceCounts.get('mock_exam')?.attempts ?? 0) >= 3
      || (sourceCounts.get('topic_quiz')?.attempts ?? 0) >= 3
    const canBeStrong = evidenceLevel === 'strong'
      && score !== null
      && score >= config.classification.strongAtOrAbove
      && hasStrongAssessmentSource
      && consistency.level !== 'low'
      && consistency.level !== 'insufficient_data'
      && baseTrace.recency !== 'stale'
    classification = canBeStrong ? 'strong' : 'developing'
    addReason(reasons, canBeStrong, 'broad_recent_evidence')
    addReason(reasons, canBeStrong && consistency.level === 'high',
      'consistent_strong_performance')
  }

  return {
    topicId: topic.id,
    domainId: topic.domainId,
    title: topic.title,
    readinessScore: score,
    classification,
    evidenceLevel,
    trend,
    consistency,
    trace: withReasons(baseTrace, reasons),
  }
}

function averageAttemptScores(
  events: readonly AssessmentEvidence[],
  source: 'mock_exam' | 'topic_quiz',
): { count: number; average: number | null } {
  const attempts = getAttemptPerformances(events).filter((attempt) => attempt.source === source)
  return {
    count: attempts.length,
    average: attempts.length === 0
      ? null
      : roundScore(attempts.reduce((total, attempt) => total + attempt.score, 0) / attempts.length),
  }
}

function detectWeakTopic(
  readiness: TopicReadiness,
  events: readonly AssessmentEvidence[],
  config: ReadinessConfig,
): WeakTopicCandidate | null {
  if (readiness.evidenceLevel === 'insufficient' || readiness.evidenceLevel === 'limited') {
    return null
  }

  const mock = averageAttemptScores(events, 'mock_exam')
  const topicQuiz = averageAttemptScores(events, 'topic_quiz')
  const reasonCodes: WeakTopicCandidate['reasonCodes'][number][] = []
  if (mock.count >= 2 && mock.average !== null
    && mock.average < config.safeguards.weakPerformanceBelow) {
    reasonCodes.push('low_mock_performance')
  }
  if (topicQuiz.count >= 2 && topicQuiz.average !== null
    && topicQuiz.average < config.safeguards.weakPerformanceBelow) {
    reasonCodes.push('repeated_topic_quiz_errors')
  }
  if (readiness.trend === 'declining'
    && readiness.readinessScore !== null
    && readiness.readinessScore < config.classification.strongAtOrAbove) {
    reasonCodes.push('declining_performance')
  }

  const lowOverall = readiness.readinessScore !== null
    && readiness.readinessScore < config.safeguards.weakPerformanceBelow
  if (!lowOverall && reasonCodes.length === 0) return null

  return {
    topicId: readiness.topicId,
    domainId: readiness.domainId,
    classification: readiness.classification,
    evidenceLevel: readiness.evidenceLevel,
    state: reasonCodes.includes('low_mock_performance')
      || reasonCodes.includes('repeated_topic_quiz_errors')
      || reasonCodes.length >= 2
      ? 'confirmed'
      : 'watch',
    recentPerformance: readiness.readinessScore,
    reasonCodes,
  }
}

function evaluateDomainEvidenceLevel(
  trace: ReadinessEvidenceTrace,
  topicCoverage: number,
  config: ReadinessConfig,
): EvidenceLevel {
  const limits = config.evidence.domain
  if (trace.answeredQuestions === 0) return 'insufficient'
  if (
    trace.answeredQuestions < limits.sufficientAnswers
    || trace.assessmentSessions < limits.sufficientSessions
    || topicCoverage < limits.sufficientTopicCoverage
  ) return 'limited'
  if (
    trace.answeredQuestions >= limits.strongAnswers
    && trace.assessmentSessions >= limits.strongSessions
    && topicCoverage >= limits.strongTopicCoverage
    && trace.recency !== 'stale'
  ) return 'strong'
  return 'sufficient'
}

function calculateDomain(
  domain: ReadinessDomainDefinition,
  domainTopics: readonly TopicReadiness[],
  weakTopics: readonly WeakTopicCandidate[],
  bundle: ReadinessEvidenceBundle,
  config: ReadinessConfig,
): DomainReadiness {
  const events = bundle.assessments.filter((event) => event.domainId === domain.id)
  const learning = scopedLearning(bundle.learning, (event) => event.domainId === domain.id)
  const lessonCount = bundle.topics
    .filter((topic) => topic.domainId === domain.id)
    .reduce((total, topic) => total + topic.lessonIds.length, 0)
  const baseTrace = summarizeAssessmentEvidence(
    events, bundle.evidenceAsOf, config, [], learning, lessonCount,
  )
  const topicsWithEvidence = domainTopics.filter(
    (topic) => topic.evidenceLevel === 'sufficient' || topic.evidenceLevel === 'strong',
  ).length
  const topicCoverage = domainTopics.length === 0
    ? 0
    : roundScore(topicsWithEvidence / domainTopics.length)
  const evidenceLevel = evaluateDomainEvidenceLevel(baseTrace, topicCoverage, config)
  const trend = calculateTrend(events, config)
  const consistency = calculateConsistency(events, config)
  const score = baseTrace.weightedPerformance
  const weakTopicIds = weakTopics
    .filter((topic) => topic.domainId === domain.id && topic.state === 'confirmed')
    .map((topic) => topic.topicId)
  const criticalTopic = domainTopics.some((topic) =>
    topic.evidenceLevel !== 'insufficient'
    && topic.evidenceLevel !== 'limited'
    && topic.readinessScore !== null
    && topic.readinessScore < config.safeguards.criticalPerformanceBelow)
  const reasons: ReadinessReasonCode[] = []
  addReason(reasons, topicCoverage < config.evidence.domain.sufficientTopicCoverage,
    'insufficient_topic_coverage')
  addReason(reasons, baseTrace.recency === 'stale', 'stale_evidence')
  addReason(reasons, score !== null && score < config.classification.needsReviewBelow,
    'low_performance')
  addReason(reasons, weakTopicIds.length > 0, 'confirmed_weak_topic')
  addReason(reasons, trend === 'declining', 'declining_performance')
  addReason(reasons, consistency.level === 'low', 'inconsistent_performance')

  let classification: ScopedReadinessClassification
  if (evidenceLevel === 'insufficient' || evidenceLevel === 'limited') {
    classification = 'insufficient_evidence'
  } else if (
    score === null
    || score < config.classification.needsReviewBelow
    || weakTopicIds.length > 0
    || criticalTopic
  ) {
    classification = 'needs_review'
  } else {
    const canBeStrong = evidenceLevel === 'strong'
      && score >= config.classification.strongAtOrAbove
      && topicCoverage === 1
      && weakTopicIds.length === 0
      && consistency.level !== 'low'
      && consistency.level !== 'insufficient_data'
      && baseTrace.recency !== 'stale'
    classification = canBeStrong ? 'strong' : 'developing'
    addReason(reasons, canBeStrong, 'broad_recent_evidence')
    addReason(reasons, canBeStrong && consistency.level === 'high',
      'consistent_strong_performance')
  }

  return {
    domainId: domain.id,
    title: domain.title,
    readinessScore: score,
    classification,
    evidenceLevel,
    topicCoverage,
    trend,
    consistency,
    weakTopicIds,
    trace: withReasons(baseTrace, reasons),
  }
}

function weightedDomainScore(
  domains: readonly DomainReadiness[],
  definitions: readonly ReadinessDomainDefinition[],
  config: ReadinessConfig,
): number | null {
  let weightedScore = 0
  let totalWeight = 0
  for (const domain of domains) {
    if (domain.readinessScore === null) continue
    const definition = definitions.find((item) => item.id === domain.domainId)
    if (!definition) continue
    const weight = config.domainWeightsByOrder[definition.displayOrder] ?? 0
    weightedScore += domain.readinessScore * weight
    totalWeight += weight
  }
  return totalWeight === 0 ? null : roundScore(weightedScore / totalWeight)
}

function evaluateGlobalEvidenceLevel(
  trace: ReadinessEvidenceTrace,
  mockAttempts: number,
  domains: readonly DomainReadiness[],
  config: ReadinessConfig,
): EvidenceLevel {
  if (trace.answeredQuestions === 0) return 'insufficient'
  if (
    trace.answeredQuestions < config.evidence.global.sufficientAnswers
    || trace.assessmentSessions < config.evidence.global.sufficientSessions
  ) return 'limited'
  const allDomainsClassifiable = domains.every(
    (domain) => domain.evidenceLevel === 'sufficient' || domain.evidenceLevel === 'strong',
  )
  if (
    trace.answeredQuestions >= config.evidence.global.strongAnswers
    && mockAttempts >= config.evidence.global.strongMockAttempts
    && allDomainsClassifiable
    && trace.recency !== 'stale'
  ) return 'strong'
  return 'sufficient'
}

export function calculateAz900Readiness(
  bundle: ReadinessEvidenceBundle,
  config: ReadinessConfig = AZ900_READINESS_CONFIG,
): GlobalReadiness {
  const topics = bundle.topics.map((topic) => calculateTopic(topic, bundle, config))
  const weakTopicCandidates = topics.map((topic) => detectWeakTopic(
    topic,
    bundle.assessments.filter((event) => event.topicId === topic.topicId),
    config,
  )).filter((candidate): candidate is WeakTopicCandidate => candidate !== null)
  const domains = bundle.domains.map((domain) => calculateDomain(
    domain,
    topics.filter((topic) => topic.domainId === domain.id),
    weakTopicCandidates,
    bundle,
    config,
  ))
  const lessonCount = bundle.topics.reduce((total, topic) => total + topic.lessonIds.length, 0)
  const baseTrace = summarizeAssessmentEvidence(
    bundle.assessments,
    bundle.evidenceAsOf,
    config,
    [],
    bundle.learning,
    lessonCount,
  )
  const mockAttempts = new Set(bundle.assessments
    .filter((event) => event.source === 'mock_exam')
    .map((event) => event.attemptId)).size
  const evidenceLevel = evaluateGlobalEvidenceLevel(baseTrace, mockAttempts, domains, config)
  const trend = calculateTrend(bundle.assessments, config)
  const consistency = calculateConsistency(bundle.assessments, config)
  const readinessScore = weightedDomainScore(domains, bundle.domains, config)
  const mockEvents = bundle.assessments.filter((event) => event.source === 'mock_exam')
  const unansweredRate = mockEvents.length === 0
    ? 0
    : mockEvents.filter((event) => event.outcome === 'unanswered').length / mockEvents.length
  const reasons: ReadinessReasonCode[] = []
  addReason(reasons, baseTrace.answeredQuestions === 0, 'insufficient_assessments')
  addReason(reasons, mockAttempts === 0, 'no_finalized_mock')
  addReason(reasons, mockAttempts === 1, 'single_mock_only')
  addReason(reasons, baseTrace.recency === 'stale', 'stale_evidence')
  addReason(reasons, unansweredRate > config.safeguards.maximumStrongUnansweredRate,
    'high_unanswered_rate')
  addReason(reasons, consistency.level === 'low', 'inconsistent_performance')
  addReason(reasons, trend === 'declining', 'declining_performance')
  const hasWeakDomain = domains.some((domain) => domain.classification === 'needs_review')
  addReason(reasons, hasWeakDomain, 'weak_domain')

  let classification: GlobalReadiness['classification']
  if (evidenceLevel === 'insufficient' || baseTrace.answeredQuestions < 8) {
    classification = 'not_enough_evidence'
  } else if (
    hasWeakDomain
    || (readinessScore !== null && readinessScore < config.classification.needsReviewBelow)
  ) {
    classification = 'needs_review'
  } else {
    const canBeStrong = evidenceLevel === 'strong'
      && readinessScore !== null
      && readinessScore >= config.classification.strongAtOrAbove
      && mockAttempts >= config.evidence.global.strongMockAttempts
      && domains.every((domain) => domain.classification === 'strong')
      && consistency.level !== 'low'
      && consistency.level !== 'insufficient_data'
      && unansweredRate <= config.safeguards.maximumStrongUnansweredRate
      && baseTrace.recency !== 'stale'
    classification = canBeStrong ? 'strong' : 'developing'
    addReason(reasons, canBeStrong, 'broad_recent_evidence')
    addReason(reasons, canBeStrong && consistency.level === 'high',
      'consistent_strong_performance')
  }

  return {
    calculationVersion: config.calculationVersion,
    evidenceAsOf: bundle.evidenceAsOf,
    readinessScore,
    classification,
    evidenceLevel,
    trend,
    consistency,
    domains,
    topics,
    weakTopicCandidates,
    trace: withReasons(baseTrace, reasons),
  }
}

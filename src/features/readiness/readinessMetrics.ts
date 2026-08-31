import type {
  AssessmentEvidence,
  AssessmentEvidenceSource,
  EvidenceLevel,
  PerformanceTrend,
  ReadinessConsistency,
  ReadinessEvidenceTrace,
  ReadinessReasonCode,
  RecencyBucket,
  SourceEvidenceCount,
  LearningEvidence,
} from '../../types/readiness'
import type { ReadinessConfig } from './readinessConfig'

const DAY_IN_MS = 86_400_000
const SOURCE_PRIORITY: readonly AssessmentEvidenceSource[] = [
  'mock_exam',
  'topic_quiz',
  'lesson_quiz',
]

export interface AttemptPerformance {
  readonly attemptId: string
  readonly source: AssessmentEvidenceSource
  readonly occurredAt: string
  readonly score: number
}

export function roundScore(value: number): number {
  return Math.round(value * 100) / 100
}

export function getRecencyBucket(
  occurredAt: string,
  evidenceAsOf: string,
  config: ReadinessConfig,
): RecencyBucket {
  const ageDays = Math.max(
    0,
    (new Date(evidenceAsOf).getTime() - new Date(occurredAt).getTime()) / DAY_IN_MS,
  )
  if (ageDays <= config.recency.freshMaxDays) return 'fresh'
  if (ageDays <= config.recency.recentMaxDays) return 'recent'
  if (ageDays <= config.recency.agingMaxDays) return 'aging'
  return 'stale'
}

function uniqueCount(values: readonly string[]): number {
  return new Set(values).size
}

function buildSourceCounts(events: readonly AssessmentEvidence[]): SourceEvidenceCount[] {
  const sources: AssessmentEvidenceSource[] = [
    'mock_exam',
    'topic_quiz',
    'lesson_quiz',
    'review_quiz',
  ]
  return sources.map((source) => {
    const sourceEvents = events.filter((event) => event.source === source)
    return {
      source,
      answered: sourceEvents.filter((event) => event.outcome !== 'unanswered').length,
      unanswered: sourceEvents.filter((event) => event.outcome === 'unanswered').length,
      distinctQuestions: uniqueCount(sourceEvents.map((event) => event.questionId)),
      attempts: uniqueCount(sourceEvents.map((event) => event.attemptId)),
    }
  })
}

function calculateWeightedPerformance(
  events: readonly AssessmentEvidence[],
  evidenceAsOf: string,
  config: ReadinessConfig,
): number | null {
  const answered = events.filter(
    (event) => event.outcome !== 'unanswered' && config.sourceWeights[event.source] > 0,
  )
  if (answered.length === 0) return null

  const bySourceAndQuestion = new Map<string, AssessmentEvidence[]>()
  for (const event of answered) {
    const key = `${event.source}:${event.questionId}`
    bySourceAndQuestion.set(key, [...(bySourceAndQuestion.get(key) ?? []), event])
  }

  let weightedCorrect = 0
  let totalWeight = 0
  for (const questionEvents of bySourceAndQuestion.values()) {
    const latest = [...questionEvents].sort((left, right) =>
      right.occurredAt.localeCompare(left.occurredAt))[0]
    const recencyWeightedOutcomes = questionEvents.map((event) => {
      const bucket = getRecencyBucket(event.occurredAt, evidenceAsOf, config)
      return {
        correct: event.outcome === 'correct' ? config.recency.weights[bucket] : 0,
        weight: config.recency.weights[bucket],
      }
    })
    const outcomeWeight = recencyWeightedOutcomes.reduce(
      (total, outcome) => total + outcome.weight,
      0,
    )
    const accuracy = recencyWeightedOutcomes.reduce(
      (total, outcome) => total + outcome.correct,
      0,
    ) / outcomeWeight
    const recency = getRecencyBucket(latest.occurredAt, evidenceAsOf, config)
    const weight = config.sourceWeights[latest.source] * config.recency.weights[recency]
    weightedCorrect += accuracy * weight
    totalWeight += weight
  }

  return totalWeight === 0 ? null : roundScore((weightedCorrect / totalWeight) * 100)
}

export function summarizeAssessmentEvidence(
  events: readonly AssessmentEvidence[],
  evidenceAsOf: string,
  config: ReadinessConfig,
  reasons: readonly ReadinessReasonCode[] = [],
  learning: readonly LearningEvidence[] = [],
  totalLessonCount = 0,
): ReadinessEvidenceTrace {
  const performanceEvents = events.filter((event) => config.sourceWeights[event.source] > 0)
  const answered = performanceEvents.filter((event) => event.outcome !== 'unanswered')
  const correct = answered.filter((event) => event.outcome === 'correct').length
  const latestEvidenceAt = performanceEvents.length === 0
    ? null
    : performanceEvents.reduce(
      (latest, event) => event.occurredAt > latest ? event.occurredAt : latest,
      performanceEvents[0].occurredAt,
    )

  return {
    answeredQuestions: answered.length,
    unansweredQuestions: performanceEvents.length - answered.length,
    distinctQuestions: uniqueCount(answered.map((event) => event.questionId)),
    assessmentSessions: uniqueCount(performanceEvents.map((event) => event.attemptId)),
    sourceCounts: buildSourceCounts(events),
    rawAccuracy: answered.length === 0 ? null : roundScore((correct / answered.length) * 100),
    weightedPerformance: calculateWeightedPerformance(events, evidenceAsOf, config),
    latestEvidenceAt,
    recency: latestEvidenceAt
      ? getRecencyBucket(latestEvidenceAt, evidenceAsOf, config)
      : null,
    learningProgress: {
      completedLessons: learning.filter(
        (event) => event.source === 'lesson_progress' && event.status === 'completed',
      ).length,
      totalLessons: totalLessonCount,
      flashcardReviews: learning.filter((event) => event.source === 'flashcard_review').length,
      dueFlashcards: learning.filter(
        (event) => event.source === 'flashcard_progress'
          && event.dueAt !== null
          && event.dueAt <= evidenceAsOf,
      ).length,
    },
    reasons: [...new Set(reasons)],
  }
}

export function getAttemptPerformances(
  events: readonly AssessmentEvidence[],
): AttemptPerformance[] {
  const performanceEvents = events.filter(
    (event) => event.source !== 'review_quiz' && event.outcome !== 'unanswered',
  )
  const grouped = new Map<string, AssessmentEvidence[]>()
  for (const event of performanceEvents) {
    const key = `${event.source}:${event.attemptId}`
    grouped.set(key, [...(grouped.get(key) ?? []), event])
  }

  return [...grouped.values()].map((attemptEvents) => ({
    attemptId: attemptEvents[0].attemptId,
    source: attemptEvents[0].source,
    occurredAt: attemptEvents[0].occurredAt,
    score: roundScore(
      (attemptEvents.filter((event) => event.outcome === 'correct').length
        / attemptEvents.length) * 100,
    ),
  })).sort((left, right) =>
    left.occurredAt.localeCompare(right.occurredAt) || left.attemptId.localeCompare(right.attemptId))
}

export function selectComparableAttempts(
  events: readonly AssessmentEvidence[],
  minimumAttempts: number,
): AttemptPerformance[] {
  const attempts = getAttemptPerformances(events)
  for (const source of SOURCE_PRIORITY) {
    const fromSource = attempts.filter((attempt) => attempt.source === source)
    if (fromSource.length >= minimumAttempts) return fromSource
  }
  return []
}

export function calculateTrend(
  events: readonly AssessmentEvidence[],
  config: ReadinessConfig,
): PerformanceTrend {
  const attempts = selectComparableAttempts(events, config.trend.minimumAttempts)
  if (attempts.length < config.trend.minimumAttempts) return 'insufficient_data'

  const window = attempts.slice(-5)
  const split = Math.floor(window.length / 2)
  const older = window.slice(0, split)
  const recent = window.slice(window.length - split)
  const average = (items: readonly AttemptPerformance[]) =>
    items.reduce((total, item) => total + item.score, 0) / items.length
  const change = average(recent) - average(older)
  if (change >= config.trend.changeThreshold) return 'improving'
  if (change <= -config.trend.changeThreshold) return 'declining'
  return 'stable'
}

export function calculateConsistency(
  events: readonly AssessmentEvidence[],
  config: ReadinessConfig,
): ReadinessConsistency {
  const attempts = selectComparableAttempts(events, config.consistency.minimumAttempts)
  if (attempts.length < config.consistency.minimumAttempts) {
    return { level: 'insufficient_data', attemptCount: attempts.length, scoreRange: null }
  }
  const recent = attempts.slice(-5)
  const scores = recent.map((attempt) => attempt.score)
  const range = roundScore(Math.max(...scores) - Math.min(...scores))
  const level = range <= config.consistency.highMaxRange
    ? 'high'
    : range <= config.consistency.moderateMaxRange
      ? 'moderate'
      : 'low'
  return { level, attemptCount: recent.length, scoreRange: range }
}

export function evaluateTopicEvidenceLevel(
  trace: ReadinessEvidenceTrace,
  config: ReadinessConfig,
): EvidenceLevel {
  const limits = config.evidence.topic
  if (trace.answeredQuestions === 0) return 'insufficient'
  if (
    trace.answeredQuestions < limits.sufficientAnswers
    || trace.assessmentSessions < limits.sufficientSessions
    || trace.distinctQuestions < limits.sufficientDistinctQuestions
  ) return 'limited'
  if (
    trace.answeredQuestions >= limits.strongAnswers
    && trace.assessmentSessions >= limits.strongSessions
    && trace.distinctQuestions >= limits.strongDistinctQuestions
    && trace.recency !== 'stale'
  ) return 'strong'
  return 'sufficient'
}

export function addReason(
  reasons: ReadinessReasonCode[],
  condition: boolean,
  reason: ReadinessReasonCode,
): void {
  if (condition && !reasons.includes(reason)) reasons.push(reason)
}

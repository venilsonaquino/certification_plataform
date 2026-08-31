import type {
  AssessmentEvidence,
  AssessmentEvidenceSource,
  ReadinessEvidenceBundle,
} from '../types/readiness'

export const READINESS_AS_OF = '2026-08-30T12:00:00.000Z'

const domainDefinitions = [
  { id: 'domain-1', title: 'Cloud Concepts', displayOrder: 1 },
  { id: 'domain-2', title: 'Azure Architecture and Services', displayOrder: 2 },
  { id: 'domain-3', title: 'Management and Governance', displayOrder: 3 },
]

const topicCounts = [3, 5, 4]

export const readinessTopics = domainDefinitions.flatMap((domain, domainIndex) =>
  Array.from({ length: topicCounts[domainIndex] }, (_, topicIndex) => ({
    id: `topic-${domainIndex + 1}-${topicIndex + 1}`,
    domainId: domain.id,
    title: `Topic ${domainIndex + 1}.${topicIndex + 1}`,
    lessonIds: [`lesson-${domainIndex + 1}-${topicIndex + 1}`],
  })))

export const readinessDomains = domainDefinitions.map((domain) => ({
  ...domain,
  topicIds: readinessTopics.filter((topic) => topic.domainId === domain.id)
    .map((topic) => topic.id),
}))

export const readinessLessons = readinessTopics.map((topic) => ({
  id: topic.lessonIds[0],
  topicId: topic.id,
  title: `Lesson ${topic.id}`,
  slug: `lesson-${topic.id}`,
  displayOrder: 1,
}))

interface AttemptOptions {
  readonly source: AssessmentEvidenceSource
  readonly attemptId: string
  readonly occurredAt: string
  readonly score: number
  readonly scoresByDomain?: Readonly<Record<string, number>>
  readonly topicIds?: readonly string[]
  readonly questionsPerTopic?: number
}

function attemptEvidence(options: AttemptOptions): AssessmentEvidence[] {
  const topics = readinessTopics.filter((topic) =>
    !options.topicIds || options.topicIds.includes(topic.id))
  const questionsPerTopic = options.questionsPerTopic ?? 10
  return topics.flatMap((topic) => {
    const targetScore = options.scoresByDomain?.[topic.domainId] ?? options.score
    const correctCount = Math.round((targetScore / 100) * questionsPerTopic)
    return Array.from({ length: questionsPerTopic }, (_, index) => ({
      id: `${options.attemptId}:${topic.id}:${index}`,
      source: options.source,
      attemptId: options.attemptId,
      questionId: `${options.attemptId}:${topic.id}:question:${index}`,
      domainId: topic.domainId,
      topicId: topic.id,
      lessonId: topic.lessonIds[0],
      outcome: index < correctCount ? 'correct' as const : 'incorrect' as const,
      occurredAt: options.occurredAt,
      difficulty: index < 3 ? 'easy' as const : index < 8 ? 'medium' as const : 'hard' as const,
      attemptStatus: 'completed' as const,
      durationSeconds: options.source === 'mock_exam' ? 3_000 : 600,
    }))
  })
}

export function emptyReadinessBundle(): ReadinessEvidenceBundle {
  return {
    certificationId: 'az900',
    evidenceAsOf: READINESS_AS_OF,
    domains: readinessDomains,
    topics: readinessTopics,
    lessons: readinessLessons,
    assessments: [],
    learning: [],
  }
}

export function profileWithLessonsOnly(): ReadinessEvidenceBundle {
  return {
    ...emptyReadinessBundle(),
    learning: readinessTopics.map((topic) => ({
      id: `progress:${topic.id}`,
      source: 'lesson_progress' as const,
      domainId: topic.domainId,
      topicId: topic.id,
      lessonId: topic.lessonIds[0],
      status: 'completed' as const,
      occurredAt: '2026-08-29T12:00:00.000Z',
    })),
  }
}

export function profileWithMocks(
  scores: readonly number[],
  options: {
    readonly stale?: boolean
    readonly scoresByDomain?: readonly Readonly<Record<string, number>>[]
  } = {},
): ReadinessEvidenceBundle {
  const dates = options.stale
    ? scores.map((_, index) => `2026-01-${String(index + 10).padStart(2, '0')}T12:00:00.000Z`)
    : scores.map((_, index) => `2026-08-${String(20 + index).padStart(2, '0')}T12:00:00.000Z`)
  return {
    ...emptyReadinessBundle(),
    assessments: scores.flatMap((score, index) => attemptEvidence({
      source: 'mock_exam',
      attemptId: `mock-${index + 1}`,
      occurredAt: dates[index],
      score,
      scoresByDomain: options.scoresByDomain?.[index],
    })),
  }
}

export function addTopicQuizAttempts(
  bundle: ReadinessEvidenceBundle,
  score: number,
  attemptsPerTopic = 3,
): ReadinessEvidenceBundle {
  const additions = readinessTopics.flatMap((topic) =>
    Array.from({ length: attemptsPerTopic }, (_, index) => attemptEvidence({
      source: 'topic_quiz',
      attemptId: `topic-quiz:${topic.id}:${index + 1}`,
      occurredAt: `2026-08-${String(24 + index).padStart(2, '0')}T12:00:00.000Z`,
      score,
      topicIds: [topic.id],
    })).flat())
  return { ...bundle, assessments: [...bundle.assessments, ...additions] }
}

export function profileWeak(): ReadinessEvidenceBundle {
  return addTopicQuizAttempts(profileWithMocks([45, 50, 55]), 50, 2)
}

export function profileImproving(): ReadinessEvidenceBundle {
  return addTopicQuizAttempts(profileWithMocks([55, 65, 75, 82]), 75, 3)
}

export function profileConsistentStrong(): ReadinessEvidenceBundle {
  return addTopicQuizAttempts(profileWithMocks([84, 86, 85, 88]), 90, 3)
}

export function profileOneLuckyMock(): ReadinessEvidenceBundle {
  return addTopicQuizAttempts(profileWithMocks([55, 58, 92]), 75, 3)
}

export function profileWithWeakDomain(): ReadinessEvidenceBundle {
  const domainScores = Array.from({ length: 4 }, () => ({
    'domain-1': 90,
    'domain-2': 90,
    'domain-3': 45,
  }))
  return addTopicQuizAttempts(
    profileWithMocks([75, 75, 75, 75], { scoresByDomain: domainScores }),
    85,
    3,
  )
}

export function evidenceForTopic(
  topicId: string,
  source: AssessmentEvidenceSource,
  scores: readonly number[],
  stale = false,
): AssessmentEvidence[] {
  return scores.flatMap((score, index) => attemptEvidence({
    source,
    attemptId: `${source}:${topicId}:${index + 1}`,
    occurredAt: stale
      ? `2026-01-${String(index + 10).padStart(2, '0')}T12:00:00.000Z`
      : `2026-08-${String(index + 20).padStart(2, '0')}T12:00:00.000Z`,
    score,
    topicIds: [topicId],
  }))
}

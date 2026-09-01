import type { DomainWithTopics, Lesson, TopicWithLessons } from '../types/content'
import type { UserLessonProgress } from '../types/progress'
import type { TopicQuizSummary } from '../types/quiz'
import { flattenStudyPath, type StudyPathLesson } from './studyPath'

export type ProgressionStatus = 'locked' | 'available' | 'in_progress' | 'completed'
export type CheckpointStatus = ProgressionStatus | 'unavailable'

export interface LessonProgressionState extends StudyPathLesson {
  readonly status: ProgressionStatus
  readonly available: boolean
  readonly grandfathered: boolean
  readonly prerequisiteLesson: StudyPathLesson | null
  readonly prerequisiteTopic: TopicWithLessons | null
}

export interface TopicCheckpointState {
  readonly topic: TopicWithLessons
  readonly status: CheckpointStatus
  readonly available: boolean
  readonly questionCount: number
  readonly targetQuestionCount: number
  readonly activeAttemptId: string | null
  readonly activeAnsweredCount: number
  readonly activeTotalQuestions: number | null
  readonly lastScorePercentage: number | null
  readonly remainingLessonCount: number
  readonly grandfathered: boolean
}

export type StudyProgressionAction =
  | { readonly kind: 'lesson'; readonly lesson: LessonProgressionState }
  | { readonly kind: 'checkpoint'; readonly checkpoint: TopicCheckpointState }

export interface StudyProgression {
  readonly lessons: readonly LessonProgressionState[]
  readonly lessonById: ReadonlyMap<string, LessonProgressionState>
  readonly checkpoints: readonly TopicCheckpointState[]
  readonly checkpointByTopicId: ReadonlyMap<string, TopicCheckpointState>
  readonly nextAction: StudyProgressionAction | null
  readonly journeyCompleted: boolean
}

function hasLessonEvidence(progress: UserLessonProgress | undefined) {
  return progress?.status === 'in_progress' || progress?.status === 'completed'
}

function hasCheckpointEvidence(summary: TopicQuizSummary | undefined) {
  return Boolean(summary?.activeAttemptId) || summary?.lastScorePercentage !== null && summary !== undefined
}

function isCheckpointCompleted(summary: TopicQuizSummary | undefined) {
  return summary?.lastScorePercentage !== null && summary?.lastScorePercentage !== undefined
}

export function resolveStudyProgression(
  domains: readonly DomainWithTopics[],
  progressByLessonId: ReadonlyMap<string, UserLessonProgress>,
  topicQuizSummaryById: ReadonlyMap<string, TopicQuizSummary>,
): StudyProgression {
  const orderedLessons = flattenStudyPath(domains)
  const orderedTopics = domains.flatMap((domain) => domain.topics)
  const lessonIndexById = new Map(orderedLessons.map((item, index) => [item.lesson.id, index]))
  const topicIndexById = new Map(orderedTopics.map((topic, index) => [topic.id, index]))
  let legacyFrontierLessonIndex = -1
  let latestEvidenceTopicIndex = -1

  for (const item of orderedLessons) {
    const index = lessonIndexById.get(item.lesson.id) ?? -1
    const topicIndex = topicIndexById.get(item.topic.id) ?? -1
    if (hasLessonEvidence(progressByLessonId.get(item.lesson.id))) {
      legacyFrontierLessonIndex = Math.max(legacyFrontierLessonIndex, index)
      latestEvidenceTopicIndex = Math.max(latestEvidenceTopicIndex, topicIndex)
    }
  }

  for (const topic of orderedTopics) {
    const summary = topicQuizSummaryById.get(topic.id)
    if (!hasCheckpointEvidence(summary)) continue
    const topicIndex = topicIndexById.get(topic.id) ?? -1
    latestEvidenceTopicIndex = Math.max(latestEvidenceTopicIndex, topicIndex)
    for (const lesson of topic.lessons) {
      legacyFrontierLessonIndex = Math.max(
        legacyFrontierLessonIndex,
        lessonIndexById.get(lesson.id) ?? -1,
      )
    }
  }

  const lessons = orderedLessons.map<LessonProgressionState>((item, index) => {
    const progress = progressByLessonId.get(item.lesson.id)
    const lessonIndexInTopic = item.topic.lessons.findIndex((lesson) => lesson.id === item.lesson.id)
    const topicIndex = topicIndexById.get(item.topic.id) ?? -1
    const previousLesson = lessonIndexInTopic > 0
      ? orderedLessons.find(({ lesson }) => lesson.id === item.topic.lessons[lessonIndexInTopic - 1]?.id) ?? null
      : null
    const previousTopic = topicIndex > 0 ? orderedTopics[topicIndex - 1] : null
    const previousTopicCompleted = previousTopic
      ? isCheckpointCompleted(topicQuizSummaryById.get(previousTopic.id))
      : true
    const unlockedBySequence = lessonIndexInTopic === 0
      ? previousTopicCompleted
      : progressByLessonId.get(previousLesson?.lesson.id ?? '')?.status === 'completed'
    const grandfathered = index <= legacyFrontierLessonIndex && !unlockedBySequence
    const available = unlockedBySequence || grandfathered || hasLessonEvidence(progress)
    const status: ProgressionStatus = progress?.status === 'completed'
      ? 'completed'
      : progress?.status === 'in_progress'
        ? 'in_progress'
        : available
          ? 'available'
          : 'locked'

    return {
      ...item,
      status,
      available,
      grandfathered,
      prerequisiteLesson: status === 'locked' ? previousLesson : null,
      prerequisiteTopic: status === 'locked' && !previousLesson ? previousTopic : null,
    }
  })

  const checkpoints = orderedTopics.map<TopicCheckpointState>((topic, topicIndex) => {
    const summary = topicQuizSummaryById.get(topic.id)
    const remainingLessonCount = topic.lessons.filter(
      (lesson) => progressByLessonId.get(lesson.id)?.status !== 'completed',
    ).length
    const completed = isCheckpointCompleted(summary)
    const active = Boolean(summary?.activeAttemptId)
    const grandfathered = topicIndex < latestEvidenceTopicIndex && remainingLessonCount > 0
    const hasQuestions = (summary?.questionCount ?? 0) > 0
    const status: CheckpointStatus = completed
      ? 'completed'
      : active
        ? 'in_progress'
        : topic.lessons.length === 0 || !hasQuestions
          ? 'unavailable'
          : remainingLessonCount === 0 || grandfathered
            ? 'available'
            : 'locked'

    return {
      topic,
      status,
      available: status === 'available' || status === 'in_progress' || status === 'completed',
      questionCount: summary?.questionCount ?? 0,
      targetQuestionCount: summary?.targetQuestionCount ?? 0,
      activeAttemptId: summary?.activeAttemptId ?? null,
      activeAnsweredCount: summary?.activeAnsweredCount ?? 0,
      activeTotalQuestions: summary?.activeTotalQuestions ?? null,
      lastScorePercentage: summary?.lastScorePercentage ?? null,
      remainingLessonCount,
      grandfathered,
    }
  })

  let nextAction: StudyProgressionAction | null = null
  for (const topic of orderedTopics) {
    const topicLessons = lessons.filter((item) => item.topic.id === topic.id)
    const inProgressLesson = topicLessons.find((item) => item.status === 'in_progress')
    const availableLesson = topicLessons.find((item) => item.status === 'available')
    if (inProgressLesson || availableLesson) {
      nextAction = { kind: 'lesson', lesson: inProgressLesson ?? availableLesson! }
      break
    }

    const checkpoint = checkpoints.find((item) => item.topic.id === topic.id)
    if (checkpoint?.status === 'in_progress' || checkpoint?.status === 'available') {
      nextAction = { kind: 'checkpoint', checkpoint }
      break
    }

    if (checkpoint?.status === 'locked' || checkpoint?.status === 'unavailable') break
  }

  const journeyCompleted = checkpoints.length > 0 && checkpoints.every(
    (checkpoint) => checkpoint.status === 'completed',
  )

  return {
    lessons,
    lessonById: new Map(lessons.map((item) => [item.lesson.id, item])),
    checkpoints,
    checkpointByTopicId: new Map(checkpoints.map((item) => [item.topic.id, item])),
    nextAction,
    journeyCompleted,
  }
}

export function findLessonProgressionState(
  progression: StudyProgression,
  lesson: Lesson,
) {
  return progression.lessonById.get(lesson.id) ?? null
}

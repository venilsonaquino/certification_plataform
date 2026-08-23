import { calculateCertificationProgress, formatEstimatedMinutes } from '../../src/lib/progressUtils'
import type { DomainWithTopics, Lesson, TopicWithLessons } from '../../src/types/content'
import type { LessonProgressStatus, UserLessonProgress } from '../../src/types/progress'

const timestamp = '2026-08-22T12:00:00.000Z'

function lesson(id: string, title: string, minutes: number, displayOrder: number): Lesson {
  return {
    id,
    topicId: id.startsWith('lesson-4') ? 'topic-2' : 'topic-1',
    slug: title.toLowerCase().replaceAll(' ', '-'),
    title,
    shortDescription: null,
    content: null,
    estimatedMinutes: minutes,
    displayOrder,
    isPublished: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  }
}

function topic(id: string, domainId: string, lessons: readonly Lesson[]): TopicWithLessons {
  return {
    id,
    domainId,
    title: id,
    description: null,
    displayOrder: 1,
    createdAt: timestamp,
    updatedAt: timestamp,
    lessons,
  }
}

function domain(
  id: string,
  displayOrder: number,
  topics: readonly TopicWithLessons[],
): DomainWithTopics {
  return {
    id,
    certificationId: 'certification-1',
    title: id,
    description: null,
    examWeightMin: null,
    examWeightMax: null,
    displayOrder,
    createdAt: timestamp,
    updatedAt: timestamp,
    topics,
  }
}

function progress(
  lessonId: string,
  status: LessonProgressStatus,
  lastAccessedAt: string,
): UserLessonProgress {
  return {
    id: `progress-${lessonId}`,
    userId: 'user-1',
    lessonId,
    status,
    startedAt: timestamp,
    completedAt: status === 'completed' ? timestamp : null,
    lastAccessedAt,
    createdAt: timestamp,
    updatedAt: timestamp,
  }
}

function expect(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(message)
  }
}

const lessons = [
  lesson('lesson-1', 'Lesson One', 10, 1),
  lesson('lesson-2', 'Lesson Two', 20, 2),
  lesson('lesson-3', 'Lesson Three', 30, 3),
  lesson('lesson-4', 'Lesson Four', 40, 1),
]
const domains = [
  domain('domain-1', 1, [topic('topic-1', 'domain-1', lessons.slice(0, 3))]),
  domain('domain-2', 2, [topic('topic-2', 'domain-2', lessons.slice(3))]),
]

const newUserSummary = calculateCertificationProgress(domains, new Map())
expect(newUserSummary.percentage === 0, 'New user percentage must be 0')
expect(newUserSummary.completedCount === 0, 'New user must have no completed lessons')
expect(newUserSummary.nextLesson?.lesson.id === 'lesson-1', 'New user must start at first lesson')
expect(newUserSummary.lastActivity === null, 'New user must not have last activity')

const partialProgress = new Map([
  ['lesson-1', progress('lesson-1', 'completed', '2026-08-21T12:00:00.000Z')],
  ['lesson-2', progress('lesson-2', 'in_progress', '2026-08-22T12:00:00.000Z')],
  ['lesson-4', progress('lesson-4', 'completed', '2026-08-20T12:00:00.000Z')],
])
const partialSummary = calculateCertificationProgress(domains, partialProgress)
expect(partialSummary.percentage === 50, 'Partial percentage must be 50')
expect(partialSummary.completedCount === 2, 'Two lessons must be completed')
expect(partialSummary.remainingCount === 2, 'Two lessons must remain')
expect(partialSummary.completedMinutes === 50, 'Completed minutes must sum completed lessons')
expect(partialSummary.nextLesson?.lesson.id === 'lesson-2', 'In-progress lesson must have priority')
expect(partialSummary.lastActivity?.lesson.id === 'lesson-2', 'Latest accessed lesson must be selected')
expect(partialSummary.domainProgress[0].percentage === 33, 'First domain must round to 33%')
expect(partialSummary.domainProgress[1].percentage === 100, 'Second domain must be complete')

const inProgressPriority = calculateCertificationProgress(
  domains,
  new Map([
    ['lesson-2', progress('lesson-2', 'in_progress', '2026-08-22T12:00:00.000Z')],
  ]),
)
expect(
  inProgressPriority.nextLesson?.lesson.id === 'lesson-2',
  'In-progress lesson must have priority over an earlier not-started lesson',
)

const completedProgress = new Map(
  lessons.map((item, index) => [
    item.id,
    progress(item.id, 'completed', `2026-08-22T12:0${index}:00.000Z`),
  ]),
)
const completedSummary = calculateCertificationProgress(domains, completedProgress)
expect(completedSummary.percentage === 100, 'Completed certification must be 100%')
expect(completedSummary.isCompleted, 'Completed certification flag must be true')
expect(completedSummary.nextLesson === null, 'Completed certification must not have next lesson')
expect(completedSummary.completedMinutes === 100, 'All estimated minutes must be included')
expect(formatEstimatedMinutes(100) === '1h 40min', 'Minutes must be formatted as hours and minutes')

console.log(JSON.stringify({
  newUser: newUserSummary.percentage,
  partial: partialSummary.percentage,
  completed: completedSummary.percentage,
  nextLesson: partialSummary.nextLesson?.lesson.id,
  lastActivity: partialSummary.lastActivity?.lesson.id,
  completedMinutes: partialSummary.completedMinutes,
}))

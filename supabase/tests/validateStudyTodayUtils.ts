import { buildDailyStudyPlan } from '../../src/features/studyToday/studyTodayUtils'
import type { DomainWithTopics, Lesson, TopicWithLessons } from '../../src/types/content'
import type { UserLessonProgress } from '../../src/types/progress'

const timestamp = '2026-08-22T12:00:00.000Z'

function lesson(id: string, minutes: number, order: number): Lesson {
  return {
    id,
    topicId: '',
    slug: id,
    title: id,
    shortDescription: null,
    content: 'Conteúdo',
    estimatedMinutes: minutes,
    displayOrder: order,
    isPublished: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  }
}

function topic(id: string, lessons: readonly Lesson[], order: number): TopicWithLessons {
  return {
    id,
    domainId: '',
    title: id,
    description: null,
    displayOrder: order,
    createdAt: timestamp,
    updatedAt: timestamp,
    lessons,
  }
}

function domain(
  id: string,
  topics: readonly TopicWithLessons[],
  order: number,
): DomainWithTopics {
  return {
    id,
    certificationId: 'certification-1',
    title: id,
    description: null,
    examWeightMin: null,
    examWeightMax: null,
    displayOrder: order,
    createdAt: timestamp,
    updatedAt: timestamp,
    topics,
  }
}

function progress(
  lessonId: string,
  status: UserLessonProgress['status'],
): UserLessonProgress {
  return {
    id: `progress-${lessonId}`,
    userId: 'user-1',
    lessonId,
    status,
    startedAt: timestamp,
    completedAt: status === 'completed' ? timestamp : null,
    lastAccessedAt: timestamp,
    createdAt: timestamp,
    updatedAt: timestamp,
  }
}

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(message)
  }
}

const domains = [
  domain(
    'domain-1',
    [
      topic('topic-1', [lesson('lesson-1', 10, 1), lesson('lesson-2', 10, 2)], 1),
      topic('topic-2', [lesson('lesson-3', 10, 1), lesson('lesson-4', 8, 2)], 2),
    ],
    1,
  ),
  domain('domain-2', [topic('topic-3', [lesson('lesson-5', 10, 1)], 1)], 2),
]

const newUserPlan = buildDailyStudyPlan(domains, new Map())
assert(
  newUserPlan.lessons.map(({ lesson: item }) => item.id).join(',') ===
    'lesson-1,lesson-2,lesson-3',
  'Usuário novo deve começar pela primeira aula e seguir a ordem global.',
)
assert(newUserPlan.totalMinutes === 30, 'O plano deve se aproximar da meta de 30 minutos.')

const inProgressMap = new Map([
  ['lesson-1', progress('lesson-1', 'completed')],
  ['lesson-3', progress('lesson-3', 'in_progress')],
  ['lesson-4', progress('lesson-4', 'completed')],
])
const inProgressPlan = buildDailyStudyPlan(domains, inProgressMap)
assert(
  inProgressPlan.lessons[0]?.lesson.id === 'lesson-3',
  'A primeira aula em andamento deve ter prioridade.',
)
assert(inProgressPlan.startsWithInProgress, 'O plano deve sinalizar que começa em andamento.')
assert(
  inProgressPlan.lessons.some(({ domain: item }) => item.id === 'domain-2'),
  'A seleção deve atravessar topics e domains mantendo a ordem.',
)
assert(
  !inProgressPlan.lessons.some(({ lesson: item }) => item.id === 'lesson-4'),
  'Aulas concluídas não devem voltar ao plano.',
)

const allCompleted = new Map(
  domains.flatMap((item) =>
    item.topics.flatMap((topicItem) =>
      topicItem.lessons.map((lessonItem) => [
        lessonItem.id,
        progress(lessonItem.id, 'completed'),
      ] as const),
    ),
  ),
)
const completedPlan = buildDailyStudyPlan(domains, allCompleted)
assert(completedPlan.lessons.length === 0, 'Certificação concluída não deve sugerir aulas.')
assert(completedPlan.totalMinutes === 0, 'Certificação concluída deve ter zero minutos sugeridos.')

console.log(
  JSON.stringify({
    newUserLessons: newUserPlan.lessons.length,
    newUserMinutes: newUserPlan.totalMinutes,
    inProgressFirst: inProgressPlan.lessons[0]?.lesson.id,
    crossesDomain: inProgressPlan.lessons.at(-1)?.domain.id,
    completedLessons: completedPlan.lessons.length,
  }),
)

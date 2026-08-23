import { flattenStudyPath, type StudyPathLesson } from './studyPath'
import type { DomainWithTopics } from '../types/content'
import type { UserLessonProgress } from '../types/progress'

export interface DomainProgressSummary {
  readonly domainId: string
  readonly title: string
  readonly completedCount: number
  readonly remainingCount: number
  readonly totalCount: number
  readonly percentage: number
}

export interface LastActivitySummary extends StudyPathLesson {
  readonly progress: UserLessonProgress
}

export interface CertificationProgressSummary {
  readonly percentage: number
  readonly completedCount: number
  readonly remainingCount: number
  readonly totalCount: number
  readonly completedMinutes: number
  readonly nextLesson: StudyPathLesson | null
  readonly lastActivity: LastActivitySummary | null
  readonly domainProgress: readonly DomainProgressSummary[]
  readonly isCompleted: boolean
}

function percentage(completed: number, total: number) {
  return total === 0 ? 0 : Math.round((completed / total) * 100)
}

export function calculateCertificationProgress(
  domains: readonly DomainWithTopics[],
  progressByLessonId: ReadonlyMap<string, UserLessonProgress>,
): CertificationProgressSummary {
  const orderedLessons = flattenStudyPath(domains)
  const completedLessons = orderedLessons.filter(
    ({ lesson }) => progressByLessonId.get(lesson.id)?.status === 'completed',
  )
  const nextLesson =
    orderedLessons.find(
      ({ lesson }) => progressByLessonId.get(lesson.id)?.status === 'in_progress',
    ) ??
    orderedLessons.find(
      ({ lesson }) => progressByLessonId.get(lesson.id)?.status !== 'completed',
    ) ??
    null
  const lastActivity = orderedLessons.reduce<LastActivitySummary | null>((latest, item) => {
    const progress = progressByLessonId.get(item.lesson.id)

    if (!progress?.lastAccessedAt) {
      return latest
    }

    if (!latest?.progress.lastAccessedAt) {
      return { ...item, progress }
    }

    return new Date(progress.lastAccessedAt).getTime() >
      new Date(latest.progress.lastAccessedAt).getTime()
      ? { ...item, progress }
      : latest
  }, null)
  const domainProgress = domains.map<DomainProgressSummary>((domain) => {
    const lessons = domain.topics.flatMap((topic) => topic.lessons)
    const domainCompleted = lessons.filter(
      (lesson) => progressByLessonId.get(lesson.id)?.status === 'completed',
    ).length

    return {
      domainId: domain.id,
      title: domain.title,
      completedCount: domainCompleted,
      remainingCount: lessons.length - domainCompleted,
      totalCount: lessons.length,
      percentage: percentage(domainCompleted, lessons.length),
    }
  })
  const totalCount = orderedLessons.length
  const completedCount = completedLessons.length

  return {
    percentage: percentage(completedCount, totalCount),
    completedCount,
    remainingCount: totalCount - completedCount,
    totalCount,
    completedMinutes: completedLessons.reduce(
      (total, { lesson }) => total + (lesson.estimatedMinutes ?? 0),
      0,
    ),
    nextLesson,
    lastActivity,
    domainProgress,
    isCompleted: totalCount > 0 && completedCount === totalCount,
  }
}

export function formatEstimatedMinutes(minutes: number) {
  const hours = Math.floor(minutes / 60)
  const remainingMinutes = minutes % 60

  if (hours === 0) {
    return `${remainingMinutes}min`
  }

  return remainingMinutes === 0 ? `${hours}h` : `${hours}h ${remainingMinutes}min`
}

export function formatLastActivityDate(value: string) {
  const activityDate = new Date(value)
  const today = new Date()
  const startOfToday = new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime()
  const startOfActivity = new Date(
    activityDate.getFullYear(),
    activityDate.getMonth(),
    activityDate.getDate(),
  ).getTime()
  const dayDifference = Math.round((startOfToday - startOfActivity) / 86_400_000)

  if (dayDifference === 0) {
    return 'Hoje'
  }

  if (dayDifference === 1) {
    return 'Ontem'
  }

  return new Intl.DateTimeFormat('pt-BR', {
    day: '2-digit',
    month: 'short',
    year: activityDate.getFullYear() === today.getFullYear() ? undefined : 'numeric',
  }).format(activityDate)
}

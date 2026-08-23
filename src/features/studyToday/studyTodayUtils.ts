import { flattenStudyPath, type StudyPathLesson } from '../../lib/studyPath'
import type { DomainWithTopics } from '../../types/content'
import type { UserLessonProgress } from '../../types/progress'
import { DEFAULT_DAILY_STUDY_MINUTES, MAX_DAILY_STUDY_LESSONS } from './constants'

export interface DailyStudyPlan {
  readonly lessons: readonly StudyPathLesson[]
  readonly totalMinutes: number
  readonly startsWithInProgress: boolean
}

export function buildDailyStudyPlan(
  domains: readonly DomainWithTopics[],
  progressByLessonId: ReadonlyMap<string, UserLessonProgress>,
  targetMinutes = DEFAULT_DAILY_STUDY_MINUTES,
): DailyStudyPlan {
  const orderedLessons = flattenStudyPath(domains)
  const inProgressIndex = orderedLessons.findIndex(
    ({ lesson }) => progressByLessonId.get(lesson.id)?.status === 'in_progress',
  )
  const startIndex =
    inProgressIndex >= 0
      ? inProgressIndex
      : orderedLessons.findIndex(
          ({ lesson }) => progressByLessonId.get(lesson.id)?.status !== 'completed',
        )

  if (startIndex < 0) {
    return {
      lessons: [],
      totalMinutes: 0,
      startsWithInProgress: false,
    }
  }

  const candidates = orderedLessons
    .slice(startIndex)
    .filter(({ lesson }) => progressByLessonId.get(lesson.id)?.status !== 'completed')
  const lessons: StudyPathLesson[] = []
  let totalMinutes = 0

  for (const candidate of candidates) {
    if (lessons.length >= MAX_DAILY_STUDY_LESSONS || totalMinutes >= targetMinutes) {
      break
    }

    const lessonMinutes = candidate.lesson.estimatedMinutes ?? 0
    const currentDistance = Math.abs(targetMinutes - totalMinutes)
    const nextDistance = Math.abs(targetMinutes - (totalMinutes + lessonMinutes))
    const closeEnough = totalMinutes >= targetMinutes - 5

    if (lessons.length > 0 && closeEnough && currentDistance <= nextDistance) {
      break
    }

    lessons.push(candidate)
    totalMinutes += lessonMinutes
  }

  return {
    lessons,
    totalMinutes,
    startsWithInProgress:
      progressByLessonId.get(lessons[0]?.lesson.id ?? '')?.status === 'in_progress',
  }
}

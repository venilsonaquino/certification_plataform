export type LessonProgressStatus = 'not_started' | 'in_progress' | 'completed'

export interface UserLessonProgress {
  readonly id: string
  readonly userId: string
  readonly lessonId: string
  readonly status: LessonProgressStatus
  readonly startedAt: string | null
  readonly completedAt: string | null
  readonly lastAccessedAt: string | null
  readonly createdAt: string
  readonly updatedAt: string
}

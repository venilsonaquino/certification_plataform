import { ArrowUpRight, Clock3 } from 'lucide-react'
import { Link } from 'react-router-dom'

import { lessonRoute } from '../../lib/routes'
import type { Lesson } from '../../types/content'
import type { UserLessonProgress } from '../../types/progress'
import { ProgressStatus } from './ProgressStatus'

interface LessonCardProps {
  certificationCode: string
  lesson: Lesson
  progress?: UserLessonProgress
}

export function LessonCard({ certificationCode, lesson, progress }: LessonCardProps) {
  const status = progress?.status ?? 'not_started'

  return (
    <Link
      to={lessonRoute(certificationCode, lesson.slug)}
      className="group flex min-h-[76px] items-center justify-between gap-4 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 transition hover:-translate-y-0.5 hover:border-blue-200 hover:shadow-md"
    >
      <div className="flex min-w-0 items-start gap-3">
        <ProgressStatus status={status} showLabel={false} />
        <div className="min-w-0">
        <h5 className="text-sm font-semibold leading-5 text-slate-800 transition-colors group-hover:text-blue-700">
          {lesson.title}
        </h5>
          <div className="mt-1.5 flex flex-wrap items-center gap-x-3 gap-y-1">
            <ProgressStatus status={status} />
            {lesson.estimatedMinutes !== null && (
              <p className="flex items-center gap-1.5 text-xs font-medium text-slate-400">
                <Clock3 aria-hidden="true" className="h-3.5 w-3.5" />
                {lesson.estimatedMinutes} min
              </p>
            )}
          </div>
        </div>
      </div>
      <ArrowUpRight
        aria-hidden="true"
        className="h-4 w-4 shrink-0 text-slate-300 transition group-hover:text-blue-600"
      />
    </Link>
  )
}

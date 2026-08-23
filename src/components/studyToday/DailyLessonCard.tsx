import { ArrowRight, Clock3, PlayCircle } from 'lucide-react'
import { Link } from 'react-router-dom'

import { lessonRoute } from '../../lib/routes'
import type { StudyPathLesson } from '../../lib/studyPath'

interface DailyLessonCardProps {
  certificationCode: string
  item: StudyPathLesson
  position: number
  continuing?: boolean
  returnTo: string
}

export function DailyLessonCard({
  certificationCode,
  item,
  position,
  continuing = false,
  returnTo,
}: DailyLessonCardProps) {
  return (
    <article className="group rounded-2xl border border-slate-200/80 bg-white p-5 shadow-card transition duration-200 hover:-translate-y-0.5 hover:border-blue-200 hover:shadow-lg hover:shadow-blue-100/60 sm:p-6">
      <div className="flex items-start gap-4">
        <div className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-blue-50 text-sm font-bold text-blue-700 ring-1 ring-inset ring-blue-100">
          {position}
        </div>
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-center gap-2">
            <p className="text-xs font-bold uppercase tracking-[0.12em] text-blue-600">
              {item.topic.title}
            </p>
            {continuing && (
              <span className="inline-flex items-center gap-1 rounded-full bg-amber-50 px-2 py-1 text-[11px] font-bold text-amber-700 ring-1 ring-inset ring-amber-200">
                <PlayCircle aria-hidden="true" className="h-3 w-3" />
                Continuar de onde parou
              </span>
            )}
          </div>
          <h2 className="mt-2 text-lg font-bold leading-7 text-slate-950 sm:text-xl">
            {item.lesson.title}
          </h2>
          <p className="mt-2 text-sm leading-6 text-slate-500">{item.domain.title}</p>
          <div className="mt-4 flex flex-wrap items-center justify-between gap-3">
            <span className="inline-flex items-center gap-2 text-sm font-semibold text-slate-500">
              <Clock3 aria-hidden="true" className="h-4 w-4 text-blue-600" />
              {item.lesson.estimatedMinutes ?? 0} min
            </span>
            <Link
              to={lessonRoute(certificationCode, item.lesson.slug)}
              state={{ returnTo, returnLabel: 'Voltar para Estudo do Dia' }}
              className="inline-flex min-h-10 items-center gap-2 rounded-xl bg-slate-950 px-4 text-sm font-semibold text-white transition group-hover:bg-blue-700"
            >
              Estudar
              <ArrowRight aria-hidden="true" className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </div>
    </article>
  )
}

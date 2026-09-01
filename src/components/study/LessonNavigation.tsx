import { ArrowLeft, ArrowRight } from 'lucide-react'
import { Link } from 'react-router-dom'

import { lessonRoute } from '../../lib/routes'
import type { StudyPathLesson } from '../../lib/studyPath'
import type { LessonNextAction } from './LessonCompletion'

interface LessonNavigationProps {
  certificationCode: string
  previous: StudyPathLesson | null
  nextAction: LessonNextAction | null
}

export function LessonNavigation({ certificationCode, previous, nextAction }: LessonNavigationProps) {
  if (!previous && !nextAction) {
    return null
  }

  return (
    <nav aria-label="Navegação entre aulas" className="mt-8 grid gap-3 sm:grid-cols-2 lg:mt-10">
      {previous ? (
        <Link
          rel="prev"
          to={lessonRoute(certificationCode, previous.lesson.slug)}
          className="group flex min-h-[92px] items-center gap-3 rounded-2xl border border-slate-200 bg-white p-4 shadow-card transition hover:border-blue-200 hover:shadow-md sm:p-5"
        >
          <ArrowLeft aria-hidden="true" className="h-5 w-5 shrink-0 text-blue-600" />
          <span className="min-w-0">
            <span className="block text-xs font-bold uppercase tracking-[0.13em] text-slate-400">
              Aula anterior
            </span>
            <span className="mt-1 block text-sm font-semibold leading-5 text-slate-800 group-hover:text-blue-700">
              {previous.lesson.title}
            </span>
          </span>
        </Link>
      ) : (
        <span aria-hidden="true" className="hidden sm:block" />
      )}

      {nextAction && (
        <Link
          rel="next"
          to={nextAction.to}
          className="group flex min-h-[92px] items-center justify-end gap-3 rounded-2xl border border-slate-200 bg-white p-4 text-right shadow-card transition hover:border-blue-200 hover:shadow-md sm:p-5"
        >
          <span className="min-w-0">
            <span className="block text-xs font-bold uppercase tracking-[0.13em] text-slate-400">
              {nextAction.label}
            </span>
            <span className="mt-1 block text-sm font-semibold leading-5 text-slate-800 group-hover:text-blue-700">
              {nextAction.label === 'Ir para o Checkpoint' ? 'Teste seus conhecimentos sobre o tópico' : 'Continue na sequência da trilha'}
            </span>
          </span>
          <ArrowRight aria-hidden="true" className="h-5 w-5 shrink-0 text-blue-600" />
        </Link>
      )}
    </nav>
  )
}

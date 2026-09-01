import { ArrowUpRight, CheckCircle2, Circle, CircleDotDashed, Clock3, LockKeyhole } from 'lucide-react'
import { Link } from 'react-router-dom'

import { lessonRoute } from '../../lib/routes'
import type { Lesson } from '../../types/content'
import type { UserLessonProgress } from '../../types/progress'
import type { LessonProgressionState } from '../../lib/studyProgression'

interface LessonCardProps {
  certificationCode: string
  lesson: Lesson
  progress?: UserLessonProgress
  progression?: LessonProgressionState
}

const statePresentation = {
  locked: { label: 'Bloqueada', icon: LockKeyhole, className: 'text-slate-500' },
  available: { label: 'Disponível', icon: Circle, className: 'text-blue-700' },
  in_progress: { label: 'Em andamento', icon: CircleDotDashed, className: 'text-amber-700' },
  completed: { label: 'Concluída', icon: CheckCircle2, className: 'text-emerald-700' },
} as const

export function LessonCard({ certificationCode, lesson, progress, progression }: LessonCardProps) {
  const state = progression?.status ?? (progress?.status === 'completed' ? 'completed' : progress?.status === 'in_progress' ? 'in_progress' : 'available')
  const presentation = statePresentation[state]
  const StatusIcon = presentation.icon
  const content = (
    <>
      <div className="flex min-w-0 items-start gap-3">
        <StatusIcon aria-hidden="true" className={`mt-0.5 h-4 w-4 shrink-0 ${presentation.className}`} />
        <div className="min-w-0">
          <h5 className="text-sm font-semibold leading-5 text-slate-800 transition-colors group-hover:text-blue-700">{lesson.title}</h5>
          <div className="mt-1.5 flex flex-wrap items-center gap-x-3 gap-y-1">
            <span className={`text-xs font-semibold ${presentation.className}`}>{presentation.label}</span>
            {lesson.estimatedMinutes !== null && <p className="flex items-center gap-1.5 text-xs font-medium text-slate-400"><Clock3 aria-hidden="true" className="h-3.5 w-3.5" />{lesson.estimatedMinutes} min</p>}
          </div>
          {state === 'locked' && <p className="mt-1.5 text-xs leading-5 text-slate-500">{progression?.prerequisiteLesson ? `Conclua “${progression.prerequisiteLesson.lesson.title}” primeiro.` : progression?.prerequisiteTopic ? `Conclua o Checkpoint de “${progression.prerequisiteTopic.title}” primeiro.` : 'Conclua a etapa anterior primeiro.'}</p>}
        </div>
      </div>
      {state !== 'locked' && <ArrowUpRight aria-hidden="true" className="h-4 w-4 shrink-0 text-slate-300 transition group-hover:text-blue-600" />}
    </>
  )

  if (state === 'locked') {
    return <article aria-label={`${lesson.title}: bloqueada`} className="flex min-h-[76px] items-center justify-between gap-4 rounded-xl border border-slate-200/80 bg-slate-100/70 px-4 py-3.5">{content}</article>
  }

  return (
    <Link
      to={lessonRoute(certificationCode, lesson.slug)}
      className="group flex min-h-[76px] items-center justify-between gap-4 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 transition hover:-translate-y-0.5 hover:border-blue-200 hover:shadow-md"
    >
      {content}
    </Link>
  )
}

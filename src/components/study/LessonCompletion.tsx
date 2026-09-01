import { ArrowRight, Check, CheckCircle2, LoaderCircle } from 'lucide-react'
import { Link } from 'react-router-dom'

import type { LessonProgressStatus } from '../../types/progress'

export interface LessonNextAction {
  readonly to: string
  readonly label: string
}

interface LessonCompletionProps {
  status: LessonProgressStatus
  nextAction: LessonNextAction | null
  completing: boolean
  error: string | null
  onComplete: () => void
}

export function LessonCompletion({
  status,
  nextAction,
  completing,
  error,
  onComplete,
}: LessonCompletionProps) {
  if (status === 'completed') {
    return (
      <section className="mt-8 rounded-2xl border border-emerald-200 bg-emerald-50/80 p-5 sm:flex sm:items-center sm:justify-between sm:gap-5 sm:p-6">
        <div className="flex items-center gap-3 text-emerald-800">
          <CheckCircle2 aria-hidden="true" className="h-6 w-6 shrink-0" />
          <div>
            <h2 className="font-bold">Aula concluída</h2>
            <p className="mt-0.5 text-sm text-emerald-700">Seu progresso está salvo.</p>
          </div>
        </div>
        {nextAction && (
          <Link
            to={nextAction.to}
            className="mt-4 inline-flex min-h-11 w-full items-center justify-center gap-2 rounded-xl bg-blue-600 px-5 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700 sm:mt-0 sm:w-auto"
          >
            {nextAction.label}
            <ArrowRight aria-hidden="true" className="h-4 w-4" />
          </Link>
        )}
      </section>
    )
  }

  return (
    <section className="mt-8 rounded-2xl border border-blue-200 bg-blue-50/70 p-5 sm:flex sm:items-center sm:justify-between sm:gap-5 sm:p-6">
      <div>
        <h2 className="font-bold text-slate-950">Terminou esta aula?</h2>
        <p className="mt-1 text-sm leading-6 text-slate-600">Marque como concluída quando finalizar o estudo.</p>
        {error && <p role="alert" className="mt-2 text-sm font-medium text-rose-600">{error}</p>}
      </div>
      <button
        type="button"
        onClick={onComplete}
        disabled={completing}
        className="mt-4 inline-flex min-h-11 w-full items-center justify-center gap-2 rounded-xl bg-blue-600 px-5 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700 disabled:cursor-wait disabled:opacity-65 sm:mt-0 sm:w-auto"
      >
        {completing ? (
          <LoaderCircle aria-hidden="true" className="h-4 w-4 animate-spin" />
        ) : (
          <Check aria-hidden="true" className="h-4 w-4" />
        )}
        {completing ? 'Salvando...' : 'Concluir aula'}
      </button>
    </section>
  )
}

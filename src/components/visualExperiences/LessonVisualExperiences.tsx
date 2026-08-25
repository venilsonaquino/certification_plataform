import { Eye, LoaderCircle, RotateCcw } from 'lucide-react'
import { useId } from 'react'

import { useVisualExperiences } from '../../hooks/useVisualExperiences'
import { VisualExperienceErrorBoundary } from './VisualExperienceErrorBoundary'
import { VisualExperienceRenderer } from './VisualExperienceRenderer'

interface LessonVisualExperiencesProps {
  lessonId: string
}

export function LessonVisualExperiences({ lessonId }: LessonVisualExperiencesProps) {
  const { experiences, loading, error, retry } = useVisualExperiences(lessonId)
  const headingId = useId()

  if (loading) {
    return (
      <div role="status" className="mt-8 flex items-center gap-2 text-sm text-slate-500">
        <LoaderCircle aria-hidden="true" className="h-4 w-4 animate-spin" />
        Carregando visualizações...
      </div>
    )
  }

  if (error) {
    return (
      <div
        role="alert"
        className="mt-8 rounded-2xl border border-rose-200 bg-rose-50/70 p-5 sm:flex sm:items-center sm:justify-between sm:gap-5"
      >
        <p className="text-sm font-medium text-rose-800">
          Não foi possível carregar as visualizações desta aula.
        </p>
        <button
          type="button"
          onClick={retry}
          className="mt-4 inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-white px-4 text-sm font-bold text-rose-700 shadow-sm ring-1 ring-inset ring-rose-200 transition hover:bg-rose-100 sm:mt-0"
        >
          <RotateCcw aria-hidden="true" className="h-4 w-4" />
          Tentar novamente
        </button>
      </div>
    )
  }

  if (experiences.length === 0) {
    return null
  }

  return (
    <section aria-labelledby={headingId} className="mt-8 border-y border-slate-200 py-8 sm:py-10">
      <div className="mb-5 flex items-center gap-3">
        <div className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-cyan-50 text-cyan-700">
          <Eye aria-hidden="true" className="h-5 w-5" />
        </div>
        <div>
          <p className="text-xs font-bold uppercase tracking-[0.16em] text-cyan-700">Visualize</p>
          <h2 id={headingId} className="text-xl font-bold tracking-tight text-slate-950 sm:text-2xl">
            Visualize este conceito
          </h2>
        </div>
      </div>

      <div className="space-y-5 sm:space-y-6">
        {experiences.map((experience, index) => (
          <VisualExperienceErrorBoundary
            key={`${experience.id}-${index}`}
            resetKey={experience.id}
          >
            <VisualExperienceRenderer experience={experience} />
          </VisualExperienceErrorBoundary>
        ))}
      </div>
    </section>
  )
}

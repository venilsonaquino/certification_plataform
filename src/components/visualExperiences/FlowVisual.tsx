import { ArrowDown } from 'lucide-react'
import { useId } from 'react'

import type { FlowVisualExperience } from '../../types/visualExperience'

interface FlowVisualProps {
  experience: FlowVisualExperience
}

export function FlowVisual({ experience }: FlowVisualProps) {
  const titleId = useId()
  const descriptionId = useId()

  return (
    <article
      aria-labelledby={titleId}
      aria-describedby={experience.description ? descriptionId : undefined}
      className="overflow-hidden rounded-2xl border border-slate-200/80 bg-white shadow-card"
    >
      <header className="border-b border-slate-200 bg-slate-50/70 px-5 py-5 sm:px-7">
        <p className="text-xs font-bold uppercase tracking-[0.14em] text-emerald-700">Fluxo</p>
        <h3 id={titleId} className="mt-1.5 text-xl font-bold tracking-tight text-slate-950">
          {experience.title}
        </h3>
        {experience.description && (
          <p id={descriptionId} className="mt-2 max-w-3xl text-sm leading-6 text-slate-600">
            {experience.description}
          </p>
        )}
      </header>

      <ol aria-label={`Etapas de ${experience.title}`} className="p-5 sm:p-7">
        {experience.config.steps.map((step, index) => {
          const isLast = index === experience.config.steps.length - 1

          return (
            <li key={step.id} className={`relative flex gap-4 ${isLast ? '' : 'pb-10'}`}>
              {!isLast && (
                <div aria-hidden="true" className="absolute bottom-1 left-5 top-10 flex w-px justify-center bg-slate-300">
                  <ArrowDown className="absolute -bottom-1 left-1/2 h-4 w-4 max-w-none -translate-x-1/2 text-slate-500" />
                </div>
              )}
              <div className="relative z-10 grid h-10 w-10 shrink-0 place-items-center rounded-full border-2 border-emerald-500 bg-emerald-50 text-sm font-bold text-emerald-900">
                <span className="sr-only">Etapa </span>
                {index + 1}
              </div>
              <div className="min-w-0 flex-1 rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 sm:px-5 sm:py-4">
                <h4 className="font-bold text-slate-950">{step.label}</h4>
                {step.description && (
                  <p className="mt-1 text-sm leading-6 text-slate-600">{step.description}</p>
                )}
              </div>
            </li>
          )
        })}
      </ol>
    </article>
  )
}

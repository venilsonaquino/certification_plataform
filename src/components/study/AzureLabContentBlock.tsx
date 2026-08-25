import { Clock3, FlaskConical, TriangleAlert } from 'lucide-react'

import type { AzureLabContentBlock as AzureLabContentBlockModel } from '../../types/lessonContentBlock'

interface AzureLabContentBlockProps {
  block: AzureLabContentBlockModel
}

export function AzureLabContentBlock({ block }: AzureLabContentBlockProps) {
  const { objective, steps, estimatedMinutes, warning } = block.config

  return (
    <section
      className="rounded-2xl border border-cyan-200 bg-cyan-50/60 p-5 sm:p-7"
      data-content-block-type="azure_lab"
    >
      <div className="flex items-start gap-4">
        <div className="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-cyan-700 text-white shadow-sm">
          <FlaskConical aria-hidden="true" className="h-5 w-5" />
        </div>
        <div className="min-w-0 flex-1">
          <p className="text-xs font-bold uppercase tracking-[0.15em] text-cyan-800">
            Mini laboratório
          </p>
          <h2 className="mt-1 text-lg font-bold tracking-tight text-slate-950 sm:text-xl">
            {block.title ?? 'Experimente no Azure'}
          </h2>
          {estimatedMinutes !== undefined && (
            <p className="mt-2 inline-flex items-center gap-1.5 text-sm font-medium text-slate-600">
              <Clock3 aria-hidden="true" className="h-4 w-4" />
              Aproximadamente {estimatedMinutes} min
            </p>
          )}

          <div className="mt-5">
            <h3 className="text-sm font-bold text-slate-900">Objetivo</h3>
            <p className="mt-1 text-[15px] leading-7 text-slate-700 sm:text-base">{objective}</p>
          </div>

          <div className="mt-5">
            <h3 className="text-sm font-bold text-slate-900">Passos</h3>
            <ol className="mt-3 space-y-3">
              {steps.map((step, index) => (
                <li key={index} className="flex gap-3 text-[15px] leading-7 text-slate-700 sm:text-base">
                  <span className="grid h-7 w-7 shrink-0 place-items-center rounded-full bg-cyan-700 text-xs font-bold text-white">
                    {index + 1}
                  </span>
                  <span>{step}</span>
                </li>
              ))}
            </ol>
          </div>

          {warning && (
            <div
              role="note"
              aria-label="Atenção antes de executar o laboratório"
              className="mt-5 flex gap-3 rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm leading-6 text-amber-900"
            >
              <TriangleAlert aria-hidden="true" className="mt-0.5 h-5 w-5 shrink-0" />
              <p>{warning}</p>
            </div>
          )}
        </div>
      </div>
    </section>
  )
}

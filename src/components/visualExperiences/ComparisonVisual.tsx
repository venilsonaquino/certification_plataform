import { useId } from 'react'

import type { ComparisonVisualExperience } from '../../types/visualExperience'

interface ComparisonVisualProps {
  experience: ComparisonVisualExperience
}

export function ComparisonVisual({ experience }: ComparisonVisualProps) {
  const titleId = useId()
  const descriptionId = useId()
  const { columns, rows } = experience.config

  return (
    <article
      aria-labelledby={titleId}
      aria-describedby={experience.description ? descriptionId : undefined}
      className="overflow-hidden rounded-2xl border border-slate-200/80 bg-white shadow-card"
    >
      <header className="border-b border-slate-200 bg-slate-50/70 px-5 py-5 sm:px-7">
        <p className="text-xs font-bold uppercase tracking-[0.14em] text-blue-700">Comparação</p>
        <h3 id={titleId} className="mt-1.5 text-xl font-bold tracking-tight text-slate-950">
          {experience.title}
        </h3>
        {experience.description && (
          <p id={descriptionId} className="mt-2 max-w-3xl text-sm leading-6 text-slate-600">
            {experience.description}
          </p>
        )}
      </header>

      <div className="grid gap-4 p-5 md:hidden">
        {columns.map((column) => {
          const columnTitleId = `${titleId}-${column.id}`

          return (
            <section
              key={column.id}
              aria-labelledby={columnTitleId}
              className="rounded-xl border border-slate-200 bg-slate-50 p-4"
            >
              <h4 id={columnTitleId} className="font-bold text-slate-950">
                {column.title}
              </h4>
              {column.description && (
                <p className="mt-1 text-sm leading-5 text-slate-600">{column.description}</p>
              )}
              <dl className="mt-4 divide-y divide-slate-200">
                {rows.map((row) => (
                  <div key={row.id} className="py-3 first:pt-0 last:pb-0">
                    <dt className="text-xs font-bold uppercase tracking-wide text-slate-500">
                      {row.label}
                    </dt>
                    {row.description && (
                      <dd className="mt-1 text-xs leading-5 text-slate-500">{row.description}</dd>
                    )}
                    <dd className="mt-1.5 text-sm font-semibold leading-6 text-slate-900">
                      {row.values[column.id]}
                    </dd>
                  </div>
                ))}
              </dl>
            </section>
          )
        })}
      </div>

      <div
        role="region"
        aria-label={`Tabela comparativa: ${experience.title}`}
        tabIndex={0}
        className="hidden overflow-x-auto overscroll-x-contain md:block"
      >
        <table className="w-full min-w-[44rem] border-collapse text-left">
          <caption className="sr-only">{experience.title}</caption>
          <thead>
            <tr className="border-b border-slate-200 bg-white">
              <th scope="col" className="w-48 px-5 py-4 text-sm font-bold text-slate-700 sm:px-7">
                Critério
              </th>
              {columns.map((column) => (
                <th key={column.id} scope="col" className="min-w-40 px-5 py-4 align-top">
                  <span className="block font-bold text-slate-950">{column.title}</span>
                  {column.description && (
                    <span className="mt-1 block text-xs font-normal leading-5 text-slate-500">
                      {column.description}
                    </span>
                  )}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-200">
            {rows.map((row) => (
              <tr key={row.id} className="align-top even:bg-slate-50/70">
                <th scope="row" className="px-5 py-4 text-sm font-bold text-slate-800 sm:px-7">
                  {row.label}
                  {row.description && (
                    <span className="mt-1 block text-xs font-normal leading-5 text-slate-500">
                      {row.description}
                    </span>
                  )}
                </th>
                {columns.map((column) => (
                  <td key={column.id} className="px-5 py-4 text-sm leading-6 text-slate-700">
                    {row.values[column.id]}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </article>
  )
}

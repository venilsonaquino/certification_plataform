interface BreakdownItem {
  label: string
  percentage: number
  correct: number
  total: number
  unanswered: number
}

interface MockExamBreakdownSectionProps {
  title: string
  description: string
  items: readonly BreakdownItem[]
}

export function MockExamBreakdownSection({ title, description, items }: MockExamBreakdownSectionProps) {
  const headingId = `breakdown-${title.replace(/ /g, '-').toLowerCase()}`
  return (
    <section aria-labelledby={headingId}>
      <h2 id={headingId} className="text-xl font-bold text-slate-950">{title}</h2>
      <p className="mt-1 text-sm leading-6 text-slate-500">{description}</p>
      <div className="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
        {items.map((item) => (
          <article key={item.label} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-card">
            <div className="flex items-start justify-between gap-3">
              <h3 className="font-bold leading-6 text-slate-900">{item.label}</h3>
              <strong className="text-lg text-blue-700">{item.percentage}%</strong>
            </div>
            <p className="mt-2 text-sm text-slate-600">{item.correct} / {item.total} corretas</p>
            {item.unanswered > 0 && <p className="mt-1 text-xs font-semibold text-amber-700">{item.unanswered} não respondidas</p>}
            <div role="progressbar" aria-label={`${item.label}: ${item.percentage}%`} aria-valuemin={0} aria-valuemax={100} aria-valuenow={item.percentage} className="mt-4 h-2 overflow-hidden rounded-full bg-slate-200">
              <div className="h-full rounded-full bg-blue-600" style={{ width: `${item.percentage}%` }} />
            </div>
          </article>
        ))}
      </div>
    </section>
  )
}

import { AlertTriangle, BarChart3, CircleGauge, ListChecks } from 'lucide-react'

import type { ReviewSummary } from '../../types/quiz'

interface ReviewSummaryCardsProps { summary: ReviewSummary }

export function ReviewSummaryCards({ summary }: ReviewSummaryCardsProps) {
  const cards = [
    { label: 'Questões para revisar', value: summary.totalQuestions, icon: ListChecks, color: 'text-blue-700 bg-blue-50' },
    { label: 'Prioridade alta', value: summary.highPriorityCount, icon: AlertTriangle, color: 'text-rose-700 bg-rose-50' },
    { label: 'Prioridade média', value: summary.mediumPriorityCount, icon: CircleGauge, color: 'text-amber-700 bg-amber-50' },
    { label: 'Precisão histórica', value: `${summary.overallAccuracy}%`, icon: BarChart3, color: 'text-emerald-700 bg-emerald-50' },
  ]
  return (
    <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
      {cards.map(({ label, value, icon: Icon, color }) => (
        <article key={label} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-card">
          <div className={`grid h-10 w-10 place-items-center rounded-xl ${color}`}><Icon className="h-5 w-5" /></div>
          <p className="mt-4 text-2xl font-bold text-slate-950">{value}</p>
          <p className="mt-1 text-sm font-medium text-slate-500">{label}</p>
        </article>
      ))}
    </div>
  )
}

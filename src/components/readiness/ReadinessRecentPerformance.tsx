import { Activity, CalendarDays } from 'lucide-react'

import { formatReadinessDate, trendLabels } from '../../features/readiness/readinessPresentation'
import type { PerformanceTrend } from '../../types/readiness'
import type { RecentMockPerformance } from '../../types/readinessUi'

interface ReadinessRecentPerformanceProps {
  readonly attempts: readonly RecentMockPerformance[]
  readonly trend: PerformanceTrend
}

export function ReadinessRecentPerformance({ attempts, trend }: ReadinessRecentPerformanceProps) {
  return (
    <section aria-labelledby="recent-performance-title" className="mt-10 grid gap-5 lg:grid-cols-[1.25fr_0.75fr]">
      <article className="rounded-2xl border border-slate-200 bg-white p-5 shadow-card sm:p-6">
        <h2 id="recent-performance-title" className="text-xl font-bold text-slate-950">Desempenho recente em Mocks</h2>
        <p className="mt-2 text-sm leading-6 text-slate-500">Practice Scores recentes da plataforma; não são previsão nem pontuação oficial.</p>
        {attempts.length > 0 ? (
          <ol className="mt-5 space-y-3">
            {attempts.map((attempt) => (
              <li key={attempt.attemptId} className="flex items-center justify-between gap-4 rounded-xl bg-slate-50 px-4 py-3">
                <div className="min-w-0">
                  <p className="font-bold text-slate-900">Mock #{attempt.attemptNumber}</p>
                  <p className="mt-1 flex items-center gap-1 text-xs text-slate-500"><CalendarDays aria-hidden="true" className="h-3.5 w-3.5" />{formatReadinessDate(attempt.evaluatedAt)} · {attempt.status === 'expired' ? 'Tempo esgotado' : 'Concluído'}</p>
                </div>
                <p className="text-xl font-bold text-blue-700" aria-label={`Practice Score ${attempt.practiceScorePercentage}%`}>{attempt.practiceScorePercentage}%</p>
              </li>
            ))}
          </ol>
        ) : (
          <p className="mt-5 rounded-xl bg-slate-50 px-4 py-5 text-sm text-slate-600">Nenhum Mock finalizado ainda. Faça um Mock quando quiser adicionar evidência ampla ao perfil.</p>
        )}
      </article>
      <article className="rounded-2xl border border-slate-200 bg-white p-5 shadow-card sm:p-6">
        <Activity aria-hidden="true" className="h-6 w-6 text-blue-600" />
        <h2 className="mt-4 text-lg font-bold text-slate-950">Tendência: {trendLabels[trend]}</h2>
        <p className="mt-2 text-sm leading-6 text-slate-500">
          {trend === 'improving' && 'Sua performance recente está avançando. Continue reforçando os Topics prioritários.'}
          {trend === 'stable' && 'Sua performance recente está estável dentro da variação esperada.'}
          {trend === 'declining' && 'A performance recente diminuiu. Revise os Topics relacionados sem interpretar isso como resultado definitivo.'}
          {trend === 'insufficient_data' && 'Ainda não há tentativas comparáveis suficientes para identificar uma tendência.'}
        </p>
      </article>
    </section>
  )
}

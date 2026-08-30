import { CheckCircle2, CircleMinus, XCircle } from 'lucide-react'

import { formatElapsedTime } from '../../lib/mockExamTime'
import type { MockExamResult } from '../../types/mockExam'

export function MockExamResultSummary({ result }: { result: MockExamResult }) {
  const metrics = [
    { label: 'Correct', value: result.correctAnswers, icon: CheckCircle2, tone: 'text-emerald-700 bg-emerald-50' },
    { label: 'Incorrect', value: result.incorrectAnswers, icon: XCircle, tone: 'text-rose-700 bg-rose-50' },
    { label: 'Unanswered', value: result.unansweredQuestions, icon: CircleMinus, tone: 'text-amber-700 bg-amber-50' },
  ]

  return (
    <section aria-labelledby="mock-result-score" className="rounded-3xl border border-slate-200 bg-white p-6 shadow-card sm:p-8">
      <div className="flex flex-col gap-6 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p className="text-sm font-bold text-blue-700">Desempenho neste simulado da plataforma</p>
          <h2 id="mock-result-score" className="mt-2 text-5xl font-bold tracking-tight text-slate-950">
            {result.practiceScorePercentage}%
          </h2>
          <p className="mt-1 text-lg font-semibold text-slate-600">Practice Score</p>
          <p className="mt-2 text-sm text-slate-500">{result.correctAnswers} / {result.totalQuestions} correct</p>
          <p className="mt-1 text-sm font-semibold text-slate-700">Time used: {formatElapsedTime(result.elapsedSeconds)}</p>
        </div>
        <div className="grid grid-cols-3 gap-2 sm:gap-3">
          {metrics.map(({ label, value, icon: Icon, tone }) => (
            <div key={label} className={`rounded-2xl p-3 text-center sm:min-w-24 sm:p-4 ${tone}`}>
              <Icon className="mx-auto h-5 w-5" aria-hidden="true" />
              <strong className="mt-2 block text-2xl">{value}</strong>
              <span className="text-xs font-semibold sm:text-sm">{label}</span>
            </div>
          ))}
        </div>
      </div>
      <div
        role="progressbar"
        aria-label="Practice Score"
        aria-valuemin={0}
        aria-valuemax={100}
        aria-valuenow={result.practiceScorePercentage}
        className="mt-7 h-3 overflow-hidden rounded-full bg-slate-200"
      >
        <div className="h-full rounded-full bg-blue-600" style={{ width: `${result.practiceScorePercentage}%` }} />
      </div>
      <p className="mt-4 text-xs leading-5 text-slate-500">
        Este é um Practice Score da Certification Academy. Ele não representa a pontuação oficial da Microsoft nem prevê aprovação no exame.
      </p>
    </section>
  )
}

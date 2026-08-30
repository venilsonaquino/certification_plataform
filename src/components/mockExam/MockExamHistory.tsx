import { ArrowLeft, ArrowRight, History, Play, SearchCheck } from 'lucide-react'

import { formatElapsedTime } from '../../lib/mockExamTime'
import type { MockExamHistoryItem } from '../../types/mockExam'

interface MockExamHistoryProps {
  items: readonly MockExamHistoryItem[]
  totalCount: number
  page: number
  pageSize: number
  loading: boolean
  onPageChange: (page: number) => void
  onResume: (attemptId: string) => void
  onViewResult: (attemptId: string) => void
}

const statusLabels = {
  in_progress: 'In Progress',
  completed: 'Completed',
  expired: 'Expired',
  abandoned: 'Abandoned',
} as const

export function MockExamHistory({ items, totalCount, page, pageSize, loading, onPageChange, onResume, onViewResult }: MockExamHistoryProps) {
  const pages = Math.max(1, Math.ceil(totalCount / pageSize))
  return (
    <section aria-labelledby="mock-history-title" className="mt-8 rounded-3xl border border-slate-200 bg-white p-6 shadow-card sm:p-8">
      <div className="flex items-center gap-3">
        <History className="h-6 w-6 text-blue-700" aria-hidden="true" />
        <div><h2 id="mock-history-title" className="text-xl font-bold text-slate-950">Mock History</h2><p className="mt-1 text-sm text-slate-600">Resultados reais das suas sessões de prática.</p></div>
      </div>
      {items.length === 0 ? (
        <p className="mt-6 rounded-2xl bg-slate-50 p-5 text-sm font-semibold text-slate-600">No mock exams yet. Start your first mock acima.</p>
      ) : (
        <div className="mt-6 grid gap-3">
          {items.map((item) => {
            const finalized = item.status === 'completed' || item.status === 'expired'
            return (
              <article key={item.attemptId} className="rounded-2xl border border-slate-200 p-4 sm:flex sm:items-center sm:justify-between sm:gap-5">
                <div>
                  <div className="flex flex-wrap items-center gap-2"><h3 className="font-bold text-slate-950">Mock #{item.attemptNumber}</h3><span className="rounded-full bg-slate-100 px-2.5 py-1 text-xs font-bold text-slate-700">{statusLabels[item.status]}</span></div>
                  <p className="mt-2 text-sm text-slate-600">{new Intl.DateTimeFormat('pt-BR', { dateStyle: 'medium' }).format(new Date(item.startedAt))}</p>
                  <p className="mt-1 text-sm font-semibold text-slate-700">{finalized ? `${item.practiceScorePercentage}% · ${item.correctAnswers} / ${item.totalQuestions} correct · ${formatElapsedTime(item.elapsedSeconds)}` : `${item.answeredQuestions} / ${item.totalQuestions} answered`}</p>
                </div>
                {item.status === 'in_progress' ? (
                  <button type="button" onClick={() => onResume(item.attemptId)} className="mt-4 inline-flex min-h-11 items-center gap-2 rounded-xl bg-blue-600 px-4 text-sm font-bold text-white hover:bg-blue-700 sm:mt-0"><Play className="h-4 w-4" aria-hidden="true" />Resume</button>
                ) : finalized ? (
                  <button type="button" onClick={() => onViewResult(item.attemptId)} className="mt-4 inline-flex min-h-11 items-center gap-2 rounded-xl border border-slate-300 px-4 text-sm font-bold text-slate-700 hover:bg-slate-50 sm:mt-0"><SearchCheck className="h-4 w-4" aria-hidden="true" />View Result</button>
                ) : null}
              </article>
            )
          })}
        </div>
      )}
      {totalCount > pageSize && <nav aria-label="Mock History pages" className="mt-6 flex items-center justify-between"><button type="button" disabled={loading || page === 0} onClick={() => onPageChange(page - 1)} className="inline-flex min-h-10 items-center gap-2 rounded-lg border border-slate-300 px-3 text-sm font-bold disabled:opacity-40"><ArrowLeft className="h-4 w-4" aria-hidden="true" />Previous</button><span className="text-sm font-semibold text-slate-600">Page {page + 1} of {pages}</span><button type="button" disabled={loading || page + 1 >= pages} onClick={() => onPageChange(page + 1)} className="inline-flex min-h-10 items-center gap-2 rounded-lg border border-slate-300 px-3 text-sm font-bold disabled:opacity-40">Next<ArrowRight className="h-4 w-4" aria-hidden="true" /></button></nav>}
    </section>
  )
}

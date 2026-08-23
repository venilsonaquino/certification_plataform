import { ArrowLeft, RotateCcw } from 'lucide-react'
import { Link } from 'react-router-dom'

import type { FlashcardSessionSummary as SessionSummary } from '../../hooks/useFlashcardSession'
import { formatReviewDate } from '../../lib/flashcardReview'

interface FlashcardSessionSummaryProps {
  summary: SessionSummary
  returnRoute: string
  returnLabel?: string
  title?: string
  allowDifficultReview?: boolean
  onRestart: () => void
  onReviewDifficult: () => void
}

export function FlashcardSessionSummary({
  summary,
  returnRoute,
  returnLabel = 'Voltar para aula',
  title = 'Sessão concluída',
  allowDifficultReview = true,
  onRestart,
  onReviewDifficult,
}: FlashcardSessionSummaryProps) {
  return (
    <section className="mt-8 rounded-3xl border border-emerald-200 bg-emerald-50 px-6 py-10 text-center shadow-sm sm:px-10">
      <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-emerald-100 text-2xl" aria-hidden="true">✓</div>
      <h2 className="mt-5 text-2xl font-bold text-slate-950">{title}</h2>
      <p className="mt-2 text-sm font-semibold text-emerald-800">{summary.total} {summary.total === 1 ? 'flashcard avaliado' : 'flashcards avaliados'}</p>
      <p className="mt-1 text-sm text-slate-600">{summary.remembered} de {summary.total} cards lembrados nesta sessão.</p>

      <dl className="mx-auto mt-7 grid max-w-xl grid-cols-2 gap-3 text-left sm:grid-cols-4">
        <div className="rounded-xl bg-white p-3"><dt className="text-xs font-semibold text-slate-500">Não sabia</dt><dd className="mt-1 text-xl font-bold text-rose-700">{summary.again}</dd></div>
        <div className="rounded-xl bg-white p-3"><dt className="text-xs font-semibold text-slate-500">Difícil</dt><dd className="mt-1 text-xl font-bold text-amber-700">{summary.hard}</dd></div>
        <div className="rounded-xl bg-white p-3"><dt className="text-xs font-semibold text-slate-500">Sabia</dt><dd className="mt-1 text-xl font-bold text-emerald-700">{summary.good}</dd></div>
        <div className="rounded-xl bg-white p-3"><dt className="text-xs font-semibold text-slate-500">Muito fácil</dt><dd className="mt-1 text-xl font-bold text-blue-700">{summary.easy}</dd></div>
      </dl>

      {allowDifficultReview && summary.difficultCards.length > 0 && (
        <div className="mx-auto mt-7 max-w-xl rounded-2xl border border-amber-200 bg-amber-50 p-5 text-left">
          <h3 className="font-bold text-amber-950">Precisa revisar</h3>
          <ul className="mt-2 list-disc space-y-1 pl-5 text-sm text-amber-900">
            {summary.difficultCards.map((card) => <li key={card.id}>{card.frontText}</li>)}
          </ul>
          <button type="button" onClick={onReviewDifficult} className="mt-4 inline-flex min-h-11 w-full items-center justify-center gap-2 rounded-xl bg-amber-700 px-5 text-sm font-bold text-white hover:bg-amber-800 sm:w-auto">
            <RotateCcw aria-hidden="true" className="h-4 w-4" />Revisar {summary.difficultCards.length} {summary.difficultCards.length === 1 ? 'card difícil' : 'cards difíceis'}
          </button>
        </div>
      )}

      <div className="mt-7 flex flex-col justify-center gap-3 sm:flex-row">
        <Link to={returnRoute} className="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl border border-slate-300 bg-white px-5 text-sm font-bold text-slate-700 hover:border-blue-300 hover:text-blue-700">
          <ArrowLeft aria-hidden="true" className="h-4 w-4" />{returnLabel}
        </Link>
        <button type="button" onClick={onRestart} className="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-blue-700 px-5 text-sm font-bold text-white hover:bg-blue-800">
          <RotateCcw aria-hidden="true" className="h-4 w-4" />Revisar novamente
        </button>
      </div>
      {summary.nextReviewAt && (
        <p className="mt-5 text-sm font-semibold text-emerald-800">Próxima revisão agendada: {formatReviewDate(summary.nextReviewAt)}</p>
      )}
      <p className="mt-5 text-xs text-slate-500">Este resultado representa apenas esta sessão e não altera o progresso da certificação.</p>
    </section>
  )
}

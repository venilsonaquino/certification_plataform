import { AlertCircle, Brain, CheckCircle2, LoaderCircle, Sparkles } from 'lucide-react'

import type { FlashcardReviewRating } from '../../types/flashcard'

interface FlashcardRatingButtonsProps {
  submitting: boolean
  pendingRating: FlashcardReviewRating | null
  error: string | null
  onRate: (rating: FlashcardReviewRating) => void
  onRetry: () => void
}

const options = [
  { rating: 'again', label: 'Não sabia', description: 'Não consegui lembrar', icon: AlertCircle, className: 'border-rose-200 bg-rose-50 text-rose-900 hover:bg-rose-100' },
  { rating: 'hard', label: 'Difícil', description: 'Lembrei com bastante esforço', icon: Brain, className: 'border-amber-200 bg-amber-50 text-amber-950 hover:bg-amber-100' },
  { rating: 'good', label: 'Sabia', description: 'Consegui lembrar', icon: CheckCircle2, className: 'border-emerald-200 bg-emerald-50 text-emerald-900 hover:bg-emerald-100' },
  { rating: 'easy', label: 'Muito fácil', description: 'Resposta imediata', icon: Sparkles, className: 'border-blue-200 bg-blue-50 text-blue-900 hover:bg-blue-100' },
] as const satisfies readonly {
  rating: FlashcardReviewRating
  label: string
  description: string
  icon: typeof AlertCircle
  className: string
}[]

export function FlashcardRatingButtons({
  submitting,
  pendingRating,
  error,
  onRate,
  onRetry,
}: FlashcardRatingButtonsProps) {
  return (
    <div className="mt-8 w-full">
      <p className="text-sm font-bold text-slate-800">Como foi?</p>
      <div className="mt-3 grid gap-3 sm:grid-cols-2">
        {options.map((option) => {
          const Icon = option.icon
          const isPending = pendingRating === option.rating
          return (
            <button
              key={option.rating}
              type="button"
              disabled={submitting || Boolean(error)}
              onClick={() => onRate(option.rating)}
              className={`min-h-20 rounded-2xl border p-4 text-left transition disabled:cursor-not-allowed disabled:opacity-60 ${option.className}`}
            >
              <span className="flex items-center gap-2 font-bold">
                {submitting && isPending
                  ? <LoaderCircle aria-hidden="true" className="h-5 w-5 animate-spin" />
                  : <Icon aria-hidden="true" className="h-5 w-5" />}
                {option.label}
              </span>
              <span className="mt-1 block text-xs font-medium opacity-80">{option.description}</span>
            </button>
          )
        })}
      </div>
      {error && (
        <div role="alert" className="mt-4 rounded-xl border border-rose-200 bg-rose-50 p-4 text-left text-sm text-rose-800">
          <p className="font-semibold">Não foi possível salvar sua resposta.</p>
          <p className="mt-1">{error}</p>
          <button type="button" onClick={onRetry} className="mt-3 min-h-10 rounded-lg bg-rose-700 px-4 font-bold text-white hover:bg-rose-800">
            Tentar novamente
          </button>
        </div>
      )}
    </div>
  )
}

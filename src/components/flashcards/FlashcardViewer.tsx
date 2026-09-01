import { Lightbulb } from 'lucide-react'
import { useEffect } from 'react'

import { useFlashcardSession, type FlashcardReviewSubmitter } from '../../hooks/useFlashcardSession'
import { getScheduleFeedback } from '../../lib/flashcardReview'
import type { Flashcard } from '../../types/flashcard'
import { FlashcardRatingButtons } from './FlashcardRatingButtons'
import { FlashcardSessionSummary } from './FlashcardSessionSummary'

interface FlashcardViewerProps {
  cards: readonly Flashcard[]
  returnRoute: string
  returnLabel?: string
  completionTitle?: string
  allowDifficultReview?: boolean
  submitReview?: FlashcardReviewSubmitter
  mode?: 'study' | 'review'
}

function isInteractiveTarget(target: EventTarget | null) {
  return target instanceof HTMLElement && Boolean(target.closest('button, a, input, textarea, select'))
}

export function FlashcardViewer({
  cards,
  returnRoute,
  returnLabel,
  completionTitle,
  allowDifficultReview,
  submitReview,
  mode = 'review',
}: FlashcardViewerProps) {
  const session = useFlashcardSession(cards, submitReview, mode)
  const card = session.currentCard

  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if (isInteractiveTarget(event.target) || session.isFinished || session.isSubmitting) return

      if ((event.key === ' ' || event.key === 'Enter') && !session.isRevealed) {
        event.preventDefault()
        session.revealAnswer()
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [session])

  if (session.isFinished) {
    return (
      <FlashcardSessionSummary
        summary={session.summary}
        returnRoute={returnRoute}
        returnLabel={returnLabel}
        title={completionTitle}
        allowDifficultReview={allowDifficultReview}
        mode={mode}
        onRestart={session.restart}
        onReviewDifficult={session.reviewDifficultCards}
      />
    )
  }

  if (!card) return null

  const progress = ((session.currentIndex + 1) / session.sessionCards.length) * 100

  return (
    <section className="mt-8" aria-label="Sessão de flashcards">
      <div className="mb-4 flex items-center justify-between gap-4 text-sm font-semibold text-slate-600">
        <span>Card {session.currentIndex + 1} de {session.sessionCards.length}</span>
        <span>{Math.round(progress)}%</span>
      </div>
      <div role="progressbar" aria-label="Progresso da sessão" aria-valuemin={1} aria-valuemax={session.sessionCards.length} aria-valuenow={session.currentIndex + 1} className="mb-6 h-2 overflow-hidden rounded-full bg-slate-200">
        <div className="h-full rounded-full bg-gradient-to-r from-blue-600 to-cyan-500 transition-[width] duration-300" style={{ width: `${progress}%` }} />
      </div>

      {session.lastScheduledProgress && (
        <p role="status" className="mb-4 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-center text-sm font-semibold text-emerald-800">
          Avaliação salva. {getScheduleFeedback(session.lastScheduledProgress)}
        </p>
      )}

      <article className="flex min-h-[21rem] flex-col items-center justify-center rounded-3xl border border-slate-200 bg-white px-6 py-10 text-center shadow-[0_18px_55px_-30px_rgba(15,23,42,0.35)] sm:min-h-[25rem] sm:px-12">
        <p className="text-xs font-bold uppercase tracking-[0.18em] text-blue-600">{session.isRevealed ? 'Resposta' : 'Pergunta'}</p>
        <div aria-live="polite" className="mt-5 max-w-2xl whitespace-pre-line text-balance text-xl font-semibold leading-relaxed text-slate-950 sm:text-2xl">
          {session.isRevealed ? card.backText : card.frontText}
        </div>

        {!session.isRevealed && session.isHintVisible && card.hint && (
          <div className="mt-7 max-w-xl rounded-2xl bg-amber-50 px-5 py-4 text-left text-sm leading-6 text-amber-950">
            <p className="flex items-center gap-2 font-bold"><Lightbulb aria-hidden="true" className="h-4 w-4" />Dica</p>
            <p className="mt-1">{card.hint}</p>
          </div>
        )}

        {!session.isRevealed ? (
          <div className="mt-8 flex w-full flex-col justify-center gap-3 sm:w-auto sm:flex-row">
            {card.hint && !session.isHintVisible && (
              <button type="button" onClick={session.revealHint} className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl border border-amber-300 bg-amber-50 px-5 text-sm font-bold text-amber-900 hover:bg-amber-100">
                <Lightbulb aria-hidden="true" className="h-4 w-4" />Ver dica
              </button>
            )}
            <button type="button" onClick={session.revealAnswer} className="inline-flex min-h-12 items-center justify-center rounded-xl bg-blue-700 px-7 text-sm font-bold text-white hover:bg-blue-800">
              Ver resposta
            </button>
          </div>
        ) : mode === 'study' ? (
          <button type="button" onClick={session.advanceCard} className="mt-8 inline-flex min-h-12 w-full items-center justify-center rounded-xl bg-blue-700 px-7 text-sm font-bold text-white hover:bg-blue-800 sm:w-auto">
            {session.currentIndex === session.sessionCards.length - 1 ? 'Concluir estudo' : 'Próximo card'}
          </button>
        ) : (
          <FlashcardRatingButtons
            submitting={session.isSubmitting}
            pendingRating={session.pendingRating}
            error={session.submitError}
            onRate={(rating) => { void session.rateCard(rating) }}
            onRetry={() => { void session.retryRating() }}
          />
        )}
      </article>
      <p className="mt-5 text-center text-xs text-slate-400">Espaço ou Enter revela a resposta. {mode === 'study' ? 'O estudo livre não altera sua agenda de revisão.' : 'Avalie o card para continuar.'}</p>
    </section>
  )
}

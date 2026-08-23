import { CheckCircle2, LoaderCircle, XCircle } from 'lucide-react'

import type { LessonQuizQuestion } from '../../types/quiz'

interface QuizQuestionCardProps {
  question: LessonQuizQuestion
  selectedOptionId: string | null
  submitting: boolean
  error: string | null
  onSelect: (optionId: string) => void
  onSubmit: () => void
  onNext: () => void
  isLast: boolean
}

export function QuizQuestionCard({
  question,
  selectedOptionId,
  submitting,
  error,
  onSelect,
  onSubmit,
  onNext,
  isLast,
}: QuizQuestionCardProps) {
  const review = question.review

  return (
    <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-card sm:p-7">
      <fieldset disabled={Boolean(review) || submitting}>
        <legend className="text-xl font-bold leading-8 text-slate-950 sm:text-2xl">
          {question.questionText}
        </legend>
        <div className="mt-6 grid gap-3" role="radiogroup" aria-label="Alternativas">
          {question.options.map((option) => {
            const selected = selectedOptionId === option.id || question.answer?.selectedOptionId === option.id
            const correct = review?.correctOptionId === option.id
            const wrongSelection = Boolean(review && selected && !correct)
            return (
              <label
                key={option.id}
                className={`flex min-h-14 cursor-pointer items-center gap-3 rounded-xl border px-4 py-3 text-sm font-medium transition sm:text-base ${
                  correct
                    ? 'border-emerald-300 bg-emerald-50 text-emerald-900'
                    : wrongSelection
                      ? 'border-rose-300 bg-rose-50 text-rose-900'
                      : selected
                        ? 'border-blue-400 bg-blue-50 text-blue-950'
                        : 'border-slate-200 text-slate-700 hover:border-blue-300 hover:bg-blue-50/40'
                } ${review ? 'cursor-default' : ''}`}
              >
                <input
                  type="radio"
                  name={`question-${question.id}`}
                  value={option.id}
                  checked={selected}
                  onChange={() => onSelect(option.id)}
                  className="h-4 w-4 shrink-0 accent-blue-600"
                />
                <span className="flex-1">{option.optionText}</span>
                {correct && <CheckCircle2 aria-label="Resposta correta" className="h-5 w-5 text-emerald-600" />}
                {wrongSelection && <XCircle aria-label="Sua resposta incorreta" className="h-5 w-5 text-rose-600" />}
              </label>
            )
          })}
        </div>
      </fieldset>

      {error && <p role="alert" className="mt-4 text-sm font-semibold text-rose-600">{error}</p>}

      {review ? (
        <div className={`mt-6 rounded-xl border p-5 ${review.isCorrect ? 'border-emerald-200 bg-emerald-50' : 'border-rose-200 bg-rose-50'}`}>
          <p className={`flex items-center gap-2 font-bold ${review.isCorrect ? 'text-emerald-800' : 'text-rose-800'}`}>
            {review.isCorrect ? <CheckCircle2 className="h-5 w-5" /> : <XCircle className="h-5 w-5" />}
            {review.isCorrect ? 'Correto!' : 'Incorreto'}
          </p>
          {!review.isCorrect && (
            <p className="mt-3 text-sm text-slate-700"><strong>Resposta correta:</strong> {review.correctOptionText}</p>
          )}
          <h3 className="mt-4 font-bold text-slate-900">Por que?</h3>
          <p className="mt-2 text-sm leading-6 text-slate-700">{review.questionExplanation}</p>
          {review.selectedOptionExplanation && (
            <p className="mt-3 text-sm leading-6 text-slate-600"><strong>Sua alternativa:</strong> {review.selectedOptionExplanation}</p>
          )}
          {!review.isCorrect && review.correctOptionExplanation && (
            <p className="mt-2 text-sm leading-6 text-slate-600"><strong>Alternativa correta:</strong> {review.correctOptionExplanation}</p>
          )}
        </div>
      ) : (
        <button
          type="button"
          onClick={onSubmit}
          disabled={!selectedOptionId || submitting}
          className="mt-6 inline-flex min-h-12 w-full items-center justify-center gap-2 rounded-xl bg-blue-600 px-5 text-sm font-bold text-white transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-50 sm:w-auto"
        >
          {submitting && <LoaderCircle className="h-4 w-4 animate-spin" />}
          {submitting ? 'Registrando...' : 'Confirmar resposta'}
        </button>
      )}

      {review && (
        <button
          type="button"
          onClick={onNext}
          className="mt-5 inline-flex min-h-12 w-full items-center justify-center rounded-xl bg-slate-950 px-5 text-sm font-bold text-white transition hover:bg-blue-800 sm:w-auto"
        >
          {isLast ? 'Ver resultado' : 'Próxima pergunta'}
        </button>
      )}
    </section>
  )
}

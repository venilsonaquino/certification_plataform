import { AlertCircle, LoaderCircle, RotateCcw } from 'lucide-react'

import type { MockExamAnswerState, MockExamQuestionForExecution } from '../../types/mockExam'

interface MockQuestionProps {
  question: MockExamQuestionForExecution
  answer: MockExamAnswerState
  disabled?: boolean
  onSelect: (optionKey: string) => void
  onRetry: () => void
}

export function MockQuestion({ question, answer, disabled = false, onSelect, onRetry }: MockQuestionProps) {
  const saving = answer.status === 'saving'

  return (
    <section aria-labelledby={`mock-question-${question.id}`} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-card sm:p-7">
      <fieldset disabled={disabled || saving}>
        <legend id={`mock-question-${question.id}`} className="text-xl font-bold leading-8 text-slate-950 sm:text-2xl">
          {question.questionText}
        </legend>
        <div className="mt-6 grid gap-3">
          {question.options.map((option) => {
            const selected = answer.selectedOptionKey === option.key
            return (
              <label key={option.key} className={`flex min-h-14 cursor-pointer items-center gap-3 rounded-xl border px-4 py-3 text-sm font-medium transition sm:text-base ${selected ? 'border-blue-500 bg-blue-50 text-blue-950 ring-1 ring-blue-500' : 'border-slate-200 text-slate-700 hover:border-blue-300 hover:bg-blue-50/40'} ${saving ? 'cursor-wait' : ''}`}>
                <input type="radio" name={`mock-question-${question.id}`} value={option.key} checked={selected} onChange={() => onSelect(option.key)} className="h-4 w-4 shrink-0 accent-blue-600" />
                <span className="flex-1">{option.text}</span>
              </label>
            )
          })}
        </div>
      </fieldset>

      <div aria-live="polite" className="mt-4 min-h-6 text-sm">
        {saving && <p className="flex items-center gap-2 font-medium text-slate-500"><LoaderCircle className="h-4 w-4 animate-spin" aria-hidden="true" />Salvando resposta...</p>}
        {answer.status === 'saved' && <p className="font-medium text-emerald-700">Resposta salva.</p>}
        {answer.status === 'error' && (
          <div role="alert" className="flex flex-wrap items-center gap-3 text-rose-700">
            <span className="flex items-center gap-2 font-semibold"><AlertCircle className="h-4 w-4" aria-hidden="true" />{answer.error}</span>
            <button type="button" onClick={onRetry} className="inline-flex min-h-10 items-center gap-2 rounded-lg px-2 font-bold hover:bg-rose-50"><RotateCcw className="h-4 w-4" aria-hidden="true" />Tentar salvar</button>
          </div>
        )}
      </div>
    </section>
  )
}

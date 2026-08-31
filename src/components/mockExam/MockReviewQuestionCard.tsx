import { CheckCircle2, CircleMinus, XCircle } from 'lucide-react'
import { Link } from 'react-router-dom'

import { lessonRoute } from '../../lib/routes'
import type { MockExamQuestionForReview } from '../../types/mockExam'

const statusPresentation = {
  correct: { label: 'Correta', icon: CheckCircle2, className: 'border-emerald-200 bg-emerald-50 text-emerald-800' },
  incorrect: { label: 'Incorreta', icon: XCircle, className: 'border-rose-200 bg-rose-50 text-rose-800' },
  unanswered: { label: 'Não respondida', icon: CircleMinus, className: 'border-amber-200 bg-amber-50 text-amber-800' },
} as const

interface MockReviewQuestionCardProps {
  question: MockExamQuestionForReview
  certificationCode: string
}

export function MockReviewQuestionCard({ question, certificationCode }: MockReviewQuestionCardProps) {
  const presentation = statusPresentation[question.status]
  const StatusIcon = presentation.icon

  return (
    <article aria-labelledby={`review-question-${question.id}`} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-card sm:p-7">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <p className="text-sm font-bold text-slate-500">Questão {question.displayOrder}</p>
        <p className={`inline-flex items-center gap-2 rounded-full border px-3 py-1 text-xs font-bold ${presentation.className}`} aria-label={`Status da resposta: ${presentation.label}`}>
          <StatusIcon className="h-4 w-4" aria-hidden="true" />{presentation.label}
        </p>
      </div>
      <h2 id={`review-question-${question.id}`} className="mt-4 text-lg font-bold leading-7 text-slate-950 sm:text-xl">{question.questionText}</h2>

      <div className="mt-5 grid gap-3" role="list" aria-label={`Alternativas da questão ${question.displayOrder}`}>
        {question.options.map((option) => {
          const selected = option.key === question.selectedOptionKey
          const correct = option.key === question.correctOptionKey
          const tone = correct
            ? 'border-emerald-400 bg-emerald-50 text-emerald-950'
            : selected
              ? 'border-rose-400 bg-rose-50 text-rose-950'
              : 'border-slate-200 bg-slate-50 text-slate-600'
          return (
            <div key={option.key} role="listitem" className={`rounded-xl border p-4 ${tone}`}>
              <p className="font-medium">{option.text}</p>
              <div className="mt-1 flex flex-wrap gap-2 text-xs font-bold">
                {selected && <span>Sua resposta</span>}
                {correct && <span>Resposta correta</span>}
              </div>
            </div>
          )
        })}
      </div>

      {question.status === 'unanswered' && <p className="mt-4 text-sm font-semibold text-amber-800">Você não respondeu esta questão.</p>}
      <section className="mt-5 rounded-xl border border-blue-100 bg-blue-50 p-4" aria-label="Explicação">
        <h3 className="text-sm font-bold text-blue-950">Explicação</h3>
        <p className="mt-1 text-sm leading-6 text-blue-900">{question.explanation ?? 'Nenhuma explicação adicional foi cadastrada para esta questão.'}</p>
      </section>

      <footer className="mt-5 flex flex-col gap-3 border-t border-slate-100 pt-5 sm:flex-row sm:items-center sm:justify-between">
        <p className="text-xs leading-5 text-slate-500">
          <strong>Domain:</strong> {question.domainTitle}<br />
          <strong>Topic:</strong> {question.topicTitle}<br />
          <strong>Aula:</strong> {question.lessonTitle}
        </p>
        <Link to={lessonRoute(certificationCode, question.lessonSlug)} className="inline-flex min-h-10 items-center justify-center rounded-xl border border-blue-200 px-4 text-sm font-bold text-blue-700 hover:bg-blue-50">Revisar aula</Link>
      </footer>
    </article>
  )
}

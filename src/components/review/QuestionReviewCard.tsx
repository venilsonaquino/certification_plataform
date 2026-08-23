import { ArrowRight, BookOpen, CheckCircle2, Clock3, XCircle } from 'lucide-react'
import { Link } from 'react-router-dom'

import type { QuestionReviewStats } from '../../types/quiz'

const priorityStyles = {
  high: { label: 'Alta prioridade', badge: 'bg-rose-100 text-rose-800', bar: 'bg-rose-500' },
  medium: { label: 'Média prioridade', badge: 'bg-amber-100 text-amber-800', bar: 'bg-amber-500' },
  low: { label: 'Baixa prioridade', badge: 'bg-blue-100 text-blue-800', bar: 'bg-blue-500' },
} as const

interface QuestionReviewCardProps {
  question: QuestionReviewStats
  reviewRoute: string
  lessonRoute?: string
  hasActiveReview: boolean
}

export function QuestionReviewCard({ question, reviewRoute, lessonRoute, hasActiveReview }: QuestionReviewCardProps) {
  const style = priorityStyles[question.priority]
  const lastDate = new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'short', year: 'numeric' }).format(new Date(question.lastAnsweredAt))
  return (
    <article className="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-card">
      <div className={`h-1 ${style.bar}`} />
      <div className="p-5 sm:p-6">
        <div className="flex flex-wrap items-center gap-2">
          <span className={`rounded-full px-3 py-1 text-xs font-bold ${style.badge}`}>{style.label}</span>
          <span className="text-xs font-semibold text-slate-500">{question.domainTitle} · {question.topicTitle}</span>
        </div>
        <h2 className="mt-4 text-lg font-bold leading-7 text-slate-950">{question.questionText}</h2>
        <div className="mt-5 grid grid-cols-2 gap-3 sm:grid-cols-4">
          <div><p className="text-xs font-semibold uppercase tracking-wide text-slate-400">Tentativas</p><p className="mt-1 font-bold text-slate-800">{question.totalAttempts}</p></div>
          <div><p className="text-xs font-semibold uppercase tracking-wide text-slate-400">Erros</p><p className="mt-1 font-bold text-rose-700">{question.incorrectCount}</p></div>
          <div><p className="text-xs font-semibold uppercase tracking-wide text-slate-400">Taxa de erro</p><p className="mt-1 font-bold text-slate-800">{Math.round(question.errorPercentage)}%</p></div>
          <div><p className="text-xs font-semibold uppercase tracking-wide text-slate-400">Última resposta</p><p className={`mt-1 flex items-center gap-1.5 font-bold ${question.lastResult ? 'text-emerald-700' : 'text-rose-700'}`}>{question.lastResult ? <CheckCircle2 className="h-4 w-4" /> : <XCircle className="h-4 w-4" />}{question.lastResult ? 'Correta' : 'Incorreta'}</p></div>
        </div>
        <p className="mt-4 flex items-center gap-2 text-xs text-slate-500"><Clock3 className="h-4 w-4" />Respondida em {lastDate}</p>
        <div className="mt-5 flex flex-col gap-2 border-t border-slate-100 pt-5 sm:flex-row">
          <Link to={reviewRoute} className="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-slate-950 px-4 text-sm font-bold text-white hover:bg-blue-800">{hasActiveReview ? 'Continuar revisão' : 'Revisar questão'}<ArrowRight className="h-4 w-4" /></Link>
          {lessonRoute && <Link to={lessonRoute} className="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl border border-slate-200 px-4 text-sm font-bold text-slate-700 hover:border-blue-300 hover:bg-blue-50"><BookOpen className="h-4 w-4" />Revisar aula</Link>}
        </div>
      </div>
    </article>
  )
}

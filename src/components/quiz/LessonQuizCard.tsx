import { BrainCircuit, LoaderCircle } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'

import { lessonQuizRoute } from '../../lib/routes'
import { getLessonQuizSummary } from '../../services/quizService'
import type { LessonQuizSummary } from '../../types/quiz'

interface LessonQuizCardProps { certificationCode: string; lessonId: string; lessonSlug: string }

export function LessonQuizCard({ certificationCode, lessonId, lessonSlug }: LessonQuizCardProps) {
  const [summary, setSummary] = useState<LessonQuizSummary | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let active = true
    getLessonQuizSummary(lessonId).then((value) => { if (active) setSummary(value) }).catch(() => {
      if (active) setError('Não foi possível carregar o Quiz.')
    })
    return () => { active = false }
  }, [lessonId])

  if (error) return <p role="alert" className="mt-6 text-sm text-rose-600">{error}</p>
  if (!summary) return <div className="mt-6 flex items-center gap-2 text-sm text-slate-500"><LoaderCircle className="h-4 w-4 animate-spin" />Carregando Quiz...</div>
  if (summary.questionCount === 0) return null

  const active = summary.activeAttempt
  const completed = summary.lastCompletedAttempt
  return (
    <section className="mt-6 rounded-2xl border border-violet-200 bg-violet-50/70 p-5 sm:flex sm:items-center sm:justify-between sm:gap-5 sm:p-6">
      <div className="flex items-start gap-3">
        <BrainCircuit className="mt-0.5 h-6 w-6 text-violet-700" />
        <div>
          <h2 className="font-bold text-slate-950">Teste seu conhecimento</h2>
          <p className="mt-1 text-sm text-slate-600">
            {active
              ? `Quiz em andamento · ${summary.answeredCount} de ${active.totalQuestions} respondidas`
              : completed
                ? `Último resultado: ${Math.round(completed.scorePercentage)}%`
                : `${summary.questionCount} ${summary.questionCount === 1 ? 'questão' : 'questões'} sobre esta aula`}
          </p>
        </div>
      </div>
      <Link
        to={lessonQuizRoute(certificationCode, lessonSlug)}
        className="mt-4 inline-flex min-h-11 w-full items-center justify-center rounded-xl bg-violet-700 px-5 text-sm font-bold text-white transition hover:bg-violet-800 sm:mt-0 sm:w-auto"
      >
        {active ? 'Continuar Quiz' : completed ? 'Fazer novamente' : 'Fazer Quiz'}
      </Link>
    </section>
  )
}

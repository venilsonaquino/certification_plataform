import { CheckCircle2, RotateCcw, XCircle } from 'lucide-react'
import { Link } from 'react-router-dom'

import { lessonRoute } from '../../lib/routes'
import type { LessonQuizAttemptData } from '../../types/quiz'
import type { LessonQuizPerformance } from '../../types/quiz'

interface QuizResultProps {
  data: LessonQuizAttemptData
  restarting: boolean
  onRestart: () => void
  performance?: readonly LessonQuizPerformance[]
  certificationCode?: string
  resultLabel?: string
  scoreDescription?: string
  restartLabel?: string
}

export function QuizResult({ data, restarting, onRestart, performance, certificationCode, resultLabel = 'Quiz concluído', scoreDescription, restartLabel = 'Refazer Quiz' }: QuizResultProps) {
  const { attempt, questions } = data
  const message = attempt.scorePercentage >= 90
    ? 'Excelente!'
    : attempt.scorePercentage >= 70
      ? 'Bom resultado. Continue revisando.'
      : 'Vale revisar esta aula antes de tentar novamente.'

  return (
    <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-card sm:p-8">
      <p className="text-sm font-bold uppercase tracking-[0.14em] text-blue-600">{resultLabel}</p>
      <div className="mt-3 flex flex-wrap items-end gap-x-5 gap-y-2">
        <h2 className="text-4xl font-bold text-slate-950">{attempt.correctAnswers} / {attempt.totalQuestions}</h2>
        <p className="pb-1 text-2xl font-bold text-blue-700">{Math.round(attempt.scorePercentage)}%</p>
      </div>
      {scoreDescription && <p className="mt-2 text-sm font-semibold text-slate-500">{scoreDescription}</p>}
      <p className="mt-3 text-base text-slate-600">{message}</p>
      <div className="mt-6 flex flex-wrap gap-4 text-sm font-semibold">
        <span className="flex items-center gap-2 text-emerald-700"><CheckCircle2 className="h-5 w-5" />{attempt.correctAnswers} corretas</span>
        <span className="flex items-center gap-2 text-rose-700"><XCircle className="h-5 w-5" />{attempt.totalQuestions - attempt.correctAnswers} incorretas</span>
      </div>

      {performance && performance.length > 0 && (
        <div className="mt-8 border-t border-slate-200 pt-7">
          <h3 className="text-lg font-bold text-slate-950">Desempenho por assunto</h3>
          <div className="mt-4 grid gap-3 sm:grid-cols-2">
            {performance.map((item) => (
              <article key={item.lessonId ?? 'topic-general'} className="rounded-xl border border-slate-200 bg-slate-50 p-4">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <h4 className="font-bold text-slate-900">{item.lessonTitle}</h4>
                    <p className="mt-1 text-sm text-slate-500">{item.correctAnswers} / {item.totalQuestions} · {Math.round(item.percentage)}%</p>
                  </div>
                  {item.needsReview && <span className="rounded-full bg-amber-100 px-2.5 py-1 text-xs font-bold text-amber-800">Revisar</span>}
                </div>
              </article>
            ))}
          </div>

          {performance.some((item) => item.needsReview) && (
            <div className="mt-6">
              <h3 className="text-lg font-bold text-slate-950">Pontos para revisar</h3>
              <div className="mt-3 space-y-2">
                {performance.filter((item) => item.needsReview).map((item) => (
                  <div key={`review-${item.lessonId ?? 'general'}`} className="flex flex-col gap-3 rounded-xl border border-amber-200 bg-amber-50 p-4 sm:flex-row sm:items-center sm:justify-between">
                    <div><p className="font-semibold text-slate-900">{item.lessonTitle}</p><p className="text-sm text-slate-600">{Math.round(item.percentage)}% · {item.totalQuestions} {item.totalQuestions === 1 ? 'questão' : 'questões'}</p></div>
                    {item.lessonSlug && certificationCode && (
                      <Link to={lessonRoute(certificationCode, item.lessonSlug)} className="inline-flex min-h-10 items-center justify-center rounded-lg bg-amber-700 px-4 text-sm font-bold text-white hover:bg-amber-800">Revisar aula</Link>
                    )}
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      <div className="mt-8 border-t border-slate-200 pt-7">
        <h3 className="mb-4 text-lg font-bold text-slate-950">Revisar respostas</h3>
        <div className="space-y-3">
        {questions.map((question, index) => (
          <details key={question.id} className="rounded-xl border border-slate-200 bg-slate-50 px-4 py-3">
            <summary className="cursor-pointer font-semibold text-slate-800">
              Questão {index + 1} — {question.review?.isCorrect ? 'Correta' : 'Incorreta'}
            </summary>
            <div className="mt-4 space-y-2 text-sm leading-6 text-slate-600">
              <p className="font-semibold text-slate-900">{question.questionText}</p>
              <p><strong>Sua resposta:</strong> {question.review?.selectedOptionText}</p>
              <p><strong>Resposta correta:</strong> {question.review?.correctOptionText}</p>
              <p><strong>Explicação:</strong> {question.review?.questionExplanation}</p>
            </div>
          </details>
        ))}
        </div>
      </div>

      <button
        type="button"
        onClick={onRestart}
        disabled={restarting}
        className="mt-7 inline-flex min-h-12 w-full items-center justify-center gap-2 rounded-xl bg-blue-600 px-5 text-sm font-bold text-white transition hover:bg-blue-700 disabled:opacity-60 sm:w-auto"
      >
        <RotateCcw className={`h-4 w-4 ${restarting ? 'animate-spin' : ''}`} />
        {restarting ? 'Criando tentativa...' : restartLabel}
      </button>
    </section>
  )
}

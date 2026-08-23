import { ArrowLeft, RefreshCw } from 'lucide-react'
import { Link, useSearchParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { QuizQuestionCard } from '../components/quiz/QuizQuestionCard'
import { ReviewQuizResult } from '../components/quiz/ReviewQuizResult'
import { useCertification } from '../hooks/useCertification'
import { useReviewQuiz } from '../hooks/useReviewQuiz'
import { certificationRoute } from '../lib/routes'

export function ReviewQuizPage() {
  const { currentCertification } = useCertification()
  const [searchParams] = useSearchParams()
  const questionId = searchParams.get('questionId')
  const quiz = useReviewQuiz(currentCertification.id, questionId)
  const backRoute = certificationRoute(currentCertification.code, 'review')

  if (quiz.loading) return <CertificationDataState title="Preparando sua revisão..." loading />
  if (quiz.unavailable) return <div className="mx-auto max-w-3xl"><CertificationDataState title="Nenhuma questão está disponível para esta revisão." description="A questão precisa pertencer a esta certificação, estar publicada e ter ao menos um erro no seu histórico." /><Link to={backRoute} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700"><ArrowLeft className="h-4 w-4" />Voltar para Meus Erros</Link></div>
  if (!quiz.data || quiz.error && !quiz.currentQuestion) return <CertificationDataState title="Não foi possível carregar a revisão." description={quiz.error ?? undefined} onRetry={quiz.retry} />

  const { data, currentQuestion, currentIndex } = quiz
  return <div className="mx-auto max-w-3xl"><Link to={backRoute} className="inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-blue-700"><ArrowLeft className="h-4 w-4" />Voltar para Meus Erros</Link><header className="mt-5 border-b border-slate-200 pb-6"><p className="flex items-center gap-2 text-sm font-bold text-violet-700"><RefreshCw className="h-5 w-5" />{currentCertification.code.toUpperCase()} · Revisão de erros</p><h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">Fortaleça seus pontos de atenção</h1><p className="mt-2 text-sm text-slate-500">{data.attempt.totalQuestions} {data.attempt.totalQuestions === 1 ? 'questão selecionada' : 'questões priorizadas'} pelo seu histórico.</p></header>{quiz.showResult ? <div className="mt-7"><ReviewQuizResult data={data} certificationCode={currentCertification.code} restarting={quiz.loading} onRestart={() => { void quiz.restart() }} /></div> : currentQuestion ? <div className="mt-7"><div className="mb-4 flex items-center justify-between text-sm font-semibold text-slate-600"><span>Pergunta {currentIndex + 1} de {data.attempt.totalQuestions}</span><span>{Math.round(((currentIndex + 1) / data.attempt.totalQuestions) * 100)}%</span></div><div role="progressbar" aria-valuemin={1} aria-valuemax={data.attempt.totalQuestions} aria-valuenow={currentIndex + 1} className="mb-6 h-2 overflow-hidden rounded-full bg-slate-200"><div className="h-full rounded-full bg-gradient-to-r from-violet-600 to-blue-500" style={{ width: `${((currentIndex + 1) / data.attempt.totalQuestions) * 100}%` }} /></div><QuizQuestionCard question={currentQuestion} selectedOptionId={quiz.selectedOptionId} submitting={quiz.submitting} error={quiz.error} onSelect={quiz.setSelectedOptionId} onSubmit={() => { void quiz.submit() }} onNext={quiz.nextQuestion} isLast={currentIndex === data.attempt.totalQuestions - 1} /></div> : null}</div>
}

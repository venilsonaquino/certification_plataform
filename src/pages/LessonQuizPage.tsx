import { ArrowLeft, BrainCircuit } from 'lucide-react'
import { Link, useParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { QuizQuestionCard } from '../components/quiz/QuizQuestionCard'
import { QuizResult } from '../components/quiz/QuizResult'
import { useCertification } from '../hooks/useCertification'
import { useCertificationProgress } from '../hooks/useCertificationProgress'
import { useLessonQuiz } from '../hooks/useLessonQuiz'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { lessonRoute } from '../lib/routes'
import { findLessonStudyContext } from '../lib/studyPath'

export function LessonQuizPage() {
  const { lessonSlug = '' } = useParams<{ lessonSlug: string }>()
  const { currentCertification } = useCertification()
  const { domains, loading: contentLoading, error: contentError, retry: retryContent } = useCertificationProgress()
  const context = findLessonStudyContext(domains, lessonSlug)
  const quiz = useLessonQuiz(context?.lesson.id ?? null)
  const backRoute = lessonRoute(currentCertification.code, lessonSlug)

  if (contentLoading || quiz.loading) {
    return <CertificationDataState title="Preparando seu Quiz..." loading />
  }
  if (contentError) {
    return <CertificationDataState title="Não foi possível carregar a aula." description={contentError} onRetry={retryContent} />
  }
  if (!context) {
    return <CertificationDataState title="Aula não encontrada." description="Confira o endereço e tente novamente pela trilha de estudos." />
  }
  if (quiz.unavailable) {
    return (
      <div className="mx-auto max-w-3xl">
        <CertificationDataState title="Ainda não existem questões disponíveis para esta aula." />
        <Link to={backRoute} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700"><ArrowLeft className="h-4 w-4" />Voltar para a aula</Link>
      </div>
    )
  }
  if (!quiz.data || quiz.error && !quiz.currentQuestion) {
    return <CertificationDataState title="Não foi possível carregar o Quiz." description={quiz.error ?? undefined} onRetry={quiz.retry} />
  }

  const { data, currentQuestion, currentIndex } = quiz
  return (
    <div className="mx-auto max-w-3xl">
      <Link to={backRoute} className="inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-blue-700"><ArrowLeft className="h-4 w-4" />Voltar para {context.lesson.title}</Link>
      <header className="mt-5 border-b border-slate-200 pb-6">
        <p className="flex items-center gap-2 text-sm font-bold text-violet-700"><BrainCircuit className="h-5 w-5" />{formatCertificationCode(currentCertification.code)} · Quiz</p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">{context.lesson.title}</h1>
        <p className="mt-2 text-sm text-slate-500">{data.attempt.totalQuestions} {data.attempt.totalQuestions === 1 ? 'pergunta' : 'perguntas'}</p>
      </header>

      {quiz.showResult ? (
        <div className="mt-7"><QuizResult data={data} restarting={quiz.loading} onRestart={() => { void quiz.restart() }} /></div>
      ) : currentQuestion ? (
        <div className="mt-7">
          <div className="mb-4 flex items-center justify-between gap-4 text-sm font-semibold text-slate-600">
            <span>Pergunta {currentIndex + 1} de {data.attempt.totalQuestions}</span>
            <span>{Math.round(((currentIndex + 1) / data.attempt.totalQuestions) * 100)}%</span>
          </div>
          <div role="progressbar" aria-valuemin={1} aria-valuemax={data.attempt.totalQuestions} aria-valuenow={currentIndex + 1} className="mb-6 h-2 overflow-hidden rounded-full bg-slate-200">
            <div className="h-full rounded-full bg-gradient-to-r from-violet-600 to-blue-500" style={{ width: `${((currentIndex + 1) / data.attempt.totalQuestions) * 100}%` }} />
          </div>
          <QuizQuestionCard
            question={currentQuestion}
            selectedOptionId={quiz.selectedOptionId}
            submitting={quiz.submitting}
            error={quiz.error}
            onSelect={quiz.setSelectedOptionId}
            onSubmit={() => { void quiz.submit() }}
            onNext={quiz.nextQuestion}
            isLast={currentIndex === data.attempt.totalQuestions - 1}
          />
        </div>
      ) : null}
    </div>
  )
}

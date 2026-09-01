import { ArrowLeft, BrainCircuit } from 'lucide-react'
import { Link, useParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { QuizQuestionCard } from '../components/quiz/QuizQuestionCard'
import { TopicQuizResult } from '../components/quiz/TopicQuizResult'
import { useCertification } from '../hooks/useCertification'
import { useCertificationProgress } from '../hooks/useCertificationProgress'
import { useStudyProgression } from '../hooks/useStudyProgression'
import { useTopicQuiz } from '../hooks/useTopicQuiz'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { certificationRoute, lessonRoute } from '../lib/routes'
import { findNextLessonAfterTopic } from '../lib/studyPath'

export function TopicQuizPage() {
  const { topicId = '' } = useParams<{ topicId: string }>()
  const { currentCertification } = useCertification()
  const { domains, progressByLessonId, loading: contentLoading, error: contentError, retry: retryContent } = useCertificationProgress()
  const studyProgression = useStudyProgression(currentCertification.id, domains, progressByLessonId)
  const topic = domains.flatMap((domain) => domain.topics).find((item) => item.id === topicId) ?? null
  const backRoute = certificationRoute(currentCertification.code, 'study')

  if (contentLoading || studyProgression.loading) return <CertificationDataState title="Preparando o Checkpoint do Tópico..." loading />
  if (contentError) return <CertificationDataState title="Não foi possível carregar o tópico." description={contentError} onRetry={retryContent} />
  if (studyProgression.error) return <CertificationDataState title="Não foi possível validar o Checkpoint." description={studyProgression.error} onRetry={studyProgression.retry} />
  if (!topic) return <CertificationDataState title="Tópico não encontrado." description="Confira o endereço e tente novamente pela trilha." />
  const checkpoint = studyProgression.progression.checkpointByTopicId.get(topic.id)
  if (!checkpoint || checkpoint.status === 'locked') return <div className="mx-auto max-w-3xl"><CertificationDataState title="Este Checkpoint ainda está bloqueado." description={`Conclua as ${checkpoint?.remainingLessonCount ?? topic.lessons.length} aulas restantes deste tópico para liberar o Checkpoint.`} /><Link to={backRoute} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700"><ArrowLeft className="h-4 w-4" />Voltar para a trilha</Link></div>
  if (checkpoint.status === 'unavailable') return <div className="mx-auto max-w-3xl"><CertificationDataState title="Checkpoint indisponível." description="Este tópico precisa de aulas e questões publicadas antes que o Checkpoint possa ser iniciado." /><Link to={backRoute} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700"><ArrowLeft className="h-4 w-4" />Voltar para a trilha</Link></div>

  const nextLesson = findNextLessonAfterTopic(domains, topic.id)
  return <TopicCheckpointSession topicId={topic.id} topicTitle={topic.title} certificationCode={currentCertification.code} nextLessonSlug={nextLesson?.lesson.slug ?? null} />
}

interface TopicCheckpointSessionProps {
  topicId: string
  topicTitle: string
  certificationCode: string
  nextLessonSlug: string | null
}

function TopicCheckpointSession({ topicId, topicTitle, certificationCode, nextLessonSlug }: TopicCheckpointSessionProps) {
  const quiz = useTopicQuiz(topicId)
  const backRoute = certificationRoute(certificationCode, 'study')

  if (quiz.loading) return <CertificationDataState title="Preparando o Checkpoint do Tópico..." loading />
  if (quiz.unavailable) return <div className="mx-auto max-w-3xl"><CertificationDataState title="Checkpoint indisponível." description="Ainda não existem questões publicadas para este tópico." /><Link to={backRoute} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700"><ArrowLeft className="h-4 w-4" />Voltar para a trilha</Link></div>
  if (!quiz.data || quiz.error && !quiz.currentQuestion) return <CertificationDataState title="Não foi possível carregar o Checkpoint." description={quiz.error ?? undefined} onRetry={quiz.retry} />

  const { data, currentQuestion, currentIndex } = quiz
  return (
    <div className="mx-auto max-w-3xl">
      <Link to={backRoute} className="inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-blue-700"><ArrowLeft className="h-4 w-4" />Voltar para a trilha</Link>
      <header className="mt-5 border-b border-slate-200 pb-6">
        <p className="flex items-center gap-2 text-sm font-bold text-violet-700"><BrainCircuit className="h-5 w-5" />{formatCertificationCode(certificationCode)} · Checkpoint do Tópico</p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">{topicTitle}</h1>
        <p className="mt-2 text-sm text-slate-500">{data.attempt.totalQuestions} questões combinando as aulas deste tópico.</p>
      </header>
      {quiz.showResult ? (
        <div className="mt-7"><TopicQuizResult data={data} certificationCode={certificationCode} restarting={quiz.loading} onRestart={() => { void quiz.restart() }} nextLessonRoute={nextLessonSlug ? lessonRoute(certificationCode, nextLessonSlug) : null} /></div>
      ) : currentQuestion ? (
        <div className="mt-7">
          <div className="mb-4 flex items-center justify-between text-sm font-semibold text-slate-600"><span>Pergunta {currentIndex + 1} de {data.attempt.totalQuestions}</span><span>{Math.round(((currentIndex + 1) / data.attempt.totalQuestions) * 100)}%</span></div>
          <div role="progressbar" aria-valuemin={1} aria-valuemax={data.attempt.totalQuestions} aria-valuenow={currentIndex + 1} className="mb-6 h-2 overflow-hidden rounded-full bg-slate-200"><div className="h-full rounded-full bg-gradient-to-r from-violet-600 to-blue-500" style={{ width: `${((currentIndex + 1) / data.attempt.totalQuestions) * 100}%` }} /></div>
          <QuizQuestionCard question={currentQuestion} selectedOptionId={quiz.selectedOptionId} submitting={quiz.submitting} error={quiz.error} onSelect={quiz.setSelectedOptionId} onSubmit={() => { void quiz.submit() }} onNext={quiz.nextQuestion} isLast={currentIndex === data.attempt.totalQuestions - 1} />
        </div>
      ) : null}
    </div>
  )
}

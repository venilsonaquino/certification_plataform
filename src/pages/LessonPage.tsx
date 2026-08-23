import { ArrowLeft, Clock3 } from 'lucide-react'
import { useEffect } from 'react'
import { Link, useLocation, useParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { LessonQuizCard } from '../components/quiz/LessonQuizCard'
import { LessonFlashcardCard } from '../components/flashcards/LessonFlashcardCard'
import { Breadcrumbs } from '../components/study/Breadcrumbs'
import { LessonContent } from '../components/study/LessonContent'
import { LessonCompletion } from '../components/study/LessonCompletion'
import { LessonNavigation } from '../components/study/LessonNavigation'
import { ProgressStatus } from '../components/study/ProgressStatus'
import { useCertification } from '../hooks/useCertification'
import { useCertificationProgress } from '../hooks/useCertificationProgress'
import { useUserProgress } from '../hooks/useUserProgress'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { certificationRoute } from '../lib/routes'
import { findLessonStudyContext } from '../lib/studyPath'

export function LessonPage() {
  const { lessonSlug = '' } = useParams<{ lessonSlug: string }>()
  const location = useLocation()
  const { currentCertification } = useCertification()
  const {
    domains,
    loading,
    error,
    retry,
    recordProgress: recordCertificationProgress,
  } = useCertificationProgress()
  const studyRoute = certificationRoute(currentCertification.code, 'study')
  const locationState =
    typeof location.state === 'object' && location.state !== null
      ? (location.state as Record<string, unknown>)
      : null
  const requestedReturnTo = locationState?.returnTo
  const certificationBaseRoute = `/certifications/${currentCertification.code.toLowerCase()}/`
  const returnTo =
    typeof requestedReturnTo === 'string' && requestedReturnTo.startsWith(certificationBaseRoute)
      ? requestedReturnTo
      : studyRoute
  const returnLabel =
    typeof locationState?.returnLabel === 'string'
      ? locationState.returnLabel
      : `Voltar para a trilha ${formatCertificationCode(currentCertification.code)}`
  const context = findLessonStudyContext(domains, lessonSlug)
  const currentLessonId = context?.lesson.id ?? null
  const {
    progressByLessonId,
    loading: progressLoading,
    error: progressError,
    retry: retryProgress,
    completeProgress,
    completingLessonId,
    mutationError,
  } = useUserProgress({
    lessonIds: currentLessonId ? [currentLessonId] : [],
    startLessonId: currentLessonId,
  })
  const currentLessonProgress = currentLessonId
    ? progressByLessonId.get(currentLessonId)
    : undefined

  useEffect(() => {
    if (currentLessonProgress) {
      recordCertificationProgress(currentLessonProgress)
    }
  }, [currentLessonProgress, recordCertificationProgress])

  if (loading) {
    return <CertificationDataState title="Carregando aula..." loading />
  }

  if (error) {
    return (
      <CertificationDataState
        title="Não foi possível carregar a aula."
        description="Confira sua conexão e tente novamente."
        onRetry={retry}
      />
    )
  }

  if (domains.length === 0) {
    return (
      <div>
        <CertificationDataState
          title="Conteúdo ainda não disponível."
          description="Esta certificação não possui uma trilha de estudos publicada."
        />
        <Link to={returnTo} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700">
          <ArrowLeft aria-hidden="true" className="h-4 w-4" />
          {returnLabel}
        </Link>
      </div>
    )
  }

  if (!context) {
    return (
      <div>
        <CertificationDataState
          title="Aula não encontrada."
          description="O endereço pode estar incorreto ou esta aula não está publicada."
        />
        <Link to={returnTo} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700">
          <ArrowLeft aria-hidden="true" className="h-4 w-4" />
          {returnLabel}
        </Link>
      </div>
    )
  }

  if (progressLoading) {
    return <CertificationDataState title="Registrando acesso à aula..." loading />
  }

  if (progressError) {
    return (
      <CertificationDataState
        title="Não foi possível carregar o progresso da aula."
        description={progressError}
        onRetry={retryProgress}
      />
    )
  }

  const { domain, topic, lesson, previous, next } = context
  const lessonProgress = progressByLessonId.get(lesson.id)
  const lessonStatus = lessonProgress?.status ?? 'in_progress'

  if (!lesson.content?.trim()) {
    return (
      <div>
        <CertificationDataState
          title="Conteúdo da aula indisponível."
          description="A aula existe, mas ainda não possui conteúdo publicado."
        />
        <Link to={returnTo} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700">
          <ArrowLeft aria-hidden="true" className="h-4 w-4" />
          {returnLabel}
        </Link>
      </div>
    )
  }

  return (
    <article className="mx-auto max-w-4xl">
      <Breadcrumbs
        items={[
          { label: formatCertificationCode(currentCertification.code), to: studyRoute },
          { label: domain.title },
          { label: topic.title },
          { label: lesson.title },
        ]}
      />

      <Link
        to={returnTo}
        className="mt-6 inline-flex min-h-10 items-center gap-2 rounded-lg text-sm font-semibold text-blue-700 transition hover:text-blue-800"
      >
        <ArrowLeft aria-hidden="true" className="h-4 w-4" />
        {returnLabel}
      </Link>

      <header className="mb-7 mt-5 border-b border-slate-200 pb-7 sm:mb-8 sm:pb-8">
        <p className="text-xs font-bold uppercase tracking-[0.16em] text-blue-600">{topic.title}</p>
        <h1 className="mt-2 text-balance text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl lg:text-5xl">
          {lesson.title}
        </h1>
        <div className="mt-4 flex flex-wrap items-center gap-x-4 gap-y-2">
          {lesson.estimatedMinutes !== null && (
            <p className="flex items-center gap-2 text-sm font-medium text-slate-500">
              <Clock3 aria-hidden="true" className="h-4 w-4 text-blue-600" />
              {lesson.estimatedMinutes} min de estudo
            </p>
          )}
          <ProgressStatus status={lessonStatus} />
        </div>
      </header>

      <LessonContent content={lesson.content} />
      <LessonCompletion
        certificationCode={currentCertification.code}
        status={lessonStatus}
        next={next}
        completing={completingLessonId === lesson.id}
        error={mutationError}
        onComplete={() => {
          void completeProgress(lesson.id)
        }}
      />
      <LessonFlashcardCard
        certificationCode={currentCertification.code}
        lessonId={lesson.id}
        lessonSlug={lesson.slug}
      />
      <LessonQuizCard
        certificationCode={currentCertification.code}
        lessonId={lesson.id}
        lessonSlug={lesson.slug}
      />
      <LessonNavigation
        certificationCode={currentCertification.code}
        previous={previous}
        next={next}
      />
    </article>
  )
}

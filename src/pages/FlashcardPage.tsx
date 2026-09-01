import { ArrowLeft, Layers3 } from 'lucide-react'
import { Link, useParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { FlashcardViewer } from '../components/flashcards/FlashcardViewer'
import { Breadcrumbs } from '../components/study/Breadcrumbs'
import { useCertification } from '../hooks/useCertification'
import { useCertificationProgress } from '../hooks/useCertificationProgress'
import { useAvailableFlashcards } from '../hooks/useAvailableFlashcards'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { certificationRoute, lessonRoute } from '../lib/routes'
import { findLessonStudyContext } from '../lib/studyPath'

export function FlashcardPage() {
  const { lessonSlug = '' } = useParams<{ lessonSlug: string }>()
  const { currentCertification } = useCertification()
  const { domains, loading: contentLoading, error: contentError, retry: retryContent } = useCertificationProgress()
  const context = findLessonStudyContext(domains, lessonSlug)
  const lessonId = context?.lesson.id ?? null
  const session = useAvailableFlashcards({ certificationId: currentCertification.id, lessonId })
  const studyRoute = certificationRoute(currentCertification.code, 'study')
  const backRoute = lessonRoute(currentCertification.code, lessonSlug)

  if (contentLoading) {
    return <CertificationDataState title="Carregando aula..." loading />
  }

  if (contentError) {
    return <CertificationDataState title="Não foi possível carregar a aula." description={contentError} onRetry={retryContent} />
  }

  if (!context) {
    return (
      <div>
        <CertificationDataState title="Aula não encontrada." description="O endereço pode estar incorreto ou esta aula não pertence à certificação atual." />
        <Link to={studyRoute} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700">
          <ArrowLeft aria-hidden="true" className="h-4 w-4" />Voltar para a trilha
        </Link>
      </div>
    )
  }

  if (session.loading) {
    return <CertificationDataState title="Carregando flashcards..." loading />
  }

  if (session.error) {
    return <CertificationDataState title="Não foi possível carregar os flashcards." description={session.error} onRetry={session.retry} />
  }

  const { domain, topic, lesson } = context

  if (session.cards.length === 0) {
    return (
      <div className="mx-auto max-w-3xl">
        <CertificationDataState title="Flashcards ainda não disponíveis para esta aula." description="Conclua a aula para liberar os cards. Flashcards já revisados anteriormente continuam acessíveis." />
        <Link to={backRoute} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700">
          <ArrowLeft aria-hidden="true" className="h-4 w-4" />Voltar para a aula
        </Link>
      </div>
    )
  }

  return (
    <main className="mx-auto max-w-3xl">
      <Breadcrumbs items={[
        { label: formatCertificationCode(currentCertification.code), to: studyRoute },
        { label: domain.title },
        { label: topic.title },
        { label: lesson.title, to: backRoute },
        { label: 'Flashcards' },
      ]} />
      <Link to={backRoute} className="mt-6 inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-blue-700 hover:text-blue-800">
        <ArrowLeft aria-hidden="true" className="h-4 w-4" />Voltar para aula
      </Link>
      <header className="mt-5 border-b border-slate-200 pb-6">
        <p className="flex items-center gap-2 text-sm font-bold text-blue-700">
          <Layers3 aria-hidden="true" className="h-5 w-5" />{formatCertificationCode(currentCertification.code)} · Flashcards
        </p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">{lesson.title}</h1>
        <p className="mt-2 text-sm text-slate-500">Tente lembrar antes de revelar a resposta.</p>
      </header>
      <FlashcardViewer key={lesson.id} cards={session.cards} mode="study" returnRoute={backRoute} completionTitle="Estudo livre concluído" allowDifficultReview={false} />
    </main>
  )
}

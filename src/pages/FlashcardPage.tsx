import { ArrowLeft, Layers3 } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { FlashcardViewer } from '../components/flashcards/FlashcardViewer'
import { Breadcrumbs } from '../components/study/Breadcrumbs'
import { useCertification } from '../hooks/useCertification'
import { useCertificationProgress } from '../hooks/useCertificationProgress'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { certificationRoute, lessonRoute } from '../lib/routes'
import { findLessonStudyContext } from '../lib/studyPath'
import { getFlashcardsByLesson } from '../services/flashcardService'
import type { Flashcard } from '../types/flashcard'

export function FlashcardPage() {
  const { lessonSlug = '' } = useParams<{ lessonSlug: string }>()
  const { currentCertification } = useCertification()
  const { domains, loading: contentLoading, error: contentError, retry: retryContent } = useCertificationProgress()
  const context = findLessonStudyContext(domains, lessonSlug)
  const lessonId = context?.lesson.id ?? null
  const [cards, setCards] = useState<readonly Flashcard[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [requestVersion, setRequestVersion] = useState(0)
  const studyRoute = certificationRoute(currentCertification.code, 'study')
  const backRoute = lessonRoute(currentCertification.code, lessonSlug)

  useEffect(() => {
    let active = true

    if (!lessonId) {
      setCards([])
      setLoading(false)
      setError(null)
      return () => {
        active = false
      }
    }

    setLoading(true)
    setError(null)
    getFlashcardsByLesson(lessonId)
      .then((value) => {
        if (active) setCards(value)
      })
      .catch(() => {
        if (active) {
          setError('Não foi possível carregar os flashcards.')
        }
      })
      .finally(() => {
        if (active) setLoading(false)
      })

    return () => {
      active = false
    }
  }, [lessonId, requestVersion])

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

  if (loading) {
    return <CertificationDataState title="Carregando flashcards..." loading />
  }

  if (error) {
    return <CertificationDataState title="Não foi possível carregar os flashcards." description={error} onRetry={() => setRequestVersion((value) => value + 1)} />
  }

  const { domain, topic, lesson } = context

  if (cards.length === 0) {
    return (
      <div className="mx-auto max-w-3xl">
        <CertificationDataState title="Flashcards ainda não disponíveis para esta aula." />
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
      <FlashcardViewer key={lesson.id} cards={cards} returnRoute={backRoute} />
    </main>
  )
}

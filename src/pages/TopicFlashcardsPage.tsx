import { ArrowLeft, Layers3 } from 'lucide-react'
import { Link, useParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { FlashcardViewer } from '../components/flashcards/FlashcardViewer'
import { Breadcrumbs } from '../components/study/Breadcrumbs'
import { useAvailableFlashcards } from '../hooks/useAvailableFlashcards'
import { useCertification } from '../hooks/useCertification'
import { useCertificationProgress } from '../hooks/useCertificationProgress'
import { useFlashcardCatalog } from '../hooks/useFlashcardCatalog'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { certificationRoute } from '../lib/routes'

export function TopicFlashcardsPage() {
  const { topicId = '' } = useParams<{ topicId: string }>()
  const { currentCertification } = useCertification()
  const content = useCertificationProgress()
  const catalog = useFlashcardCatalog(currentCertification.id)
  const session = useAvailableFlashcards({ certificationId: currentCertification.id, topicId })
  const flashcardsRoute = certificationRoute(currentCertification.code, 'flashcards')
  const context = content.domains.flatMap((domain) => domain.topics.map((topic) => ({ domain, topic }))).find((item) => item.topic.id === topicId)
  const topicOverview = catalog.domains.flatMap((domain) => domain.topics).find((topic) => topic.topicId === topicId)
  const loading = content.loading || catalog.loading || session.loading
  const error = content.error ?? catalog.error ?? session.error

  if (loading) return <CertificationDataState title="Preparando estudo livre..." loading />
  if (error) return <CertificationDataState title="Não foi possível carregar o estudo livre." description={error} onRetry={() => { content.retry(); void catalog.retry(); void session.retry() }} />
  if (!context) return <CertificationDataState title="Tópico não encontrado." description="Este tópico não pertence à certificação atual." />

  if (session.cards.length === 0) {
    return <div className="mx-auto max-w-3xl"><CertificationDataState title={topicOverview?.totalCount === 0 ? 'Nenhum Flashcard disponível neste tópico.' : 'Flashcards ainda bloqueados.'} description={topicOverview?.totalCount === 0 ? 'Este tópico não possui Flashcards publicados.' : 'Conclua as aulas deste tópico para liberar os Flashcards associados.'} /><Link to={flashcardsRoute} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700"><ArrowLeft aria-hidden="true" className="h-4 w-4" />Voltar para Flashcards</Link></div>
  }

  return (
    <main className="mx-auto max-w-3xl">
      <Breadcrumbs items={[{ label: formatCertificationCode(currentCertification.code), to: certificationRoute(currentCertification.code, 'dashboard') }, { label: 'Flashcards', to: flashcardsRoute }, { label: context.domain.title }, { label: context.topic.title }]} />
      <Link to={flashcardsRoute} className="mt-6 inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-blue-700 hover:text-blue-800"><ArrowLeft aria-hidden="true" className="h-4 w-4" />Voltar para Flashcards</Link>
      <header className="mt-5 border-b border-slate-200 pb-6"><p className="flex items-center gap-2 text-sm font-bold text-violet-700"><Layers3 aria-hidden="true" className="h-5 w-5" />Estudo livre · {context.domain.title}</p><h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">{context.topic.title}</h1><p className="mt-2 text-sm leading-6 text-slate-500">Tente lembrar antes de revelar. Esta sessão não altera sua agenda de revisão.</p></header>
      <FlashcardViewer cards={session.cards} mode="study" returnRoute={flashcardsRoute} returnLabel="Voltar para Flashcards" completionTitle="Estudo livre concluído" allowDifficultReview={false} />
    </main>
  )
}

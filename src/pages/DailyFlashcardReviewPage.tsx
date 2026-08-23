import { ArrowLeft, CalendarClock, Layers3 } from 'lucide-react'
import { Link } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { FlashcardViewer } from '../components/flashcards/FlashcardViewer'
import { useCertification } from '../hooks/useCertification'
import { useFlashcardReviewQueue } from '../hooks/useFlashcardReviewQueue'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { formatReviewDate } from '../lib/flashcardReview'
import { certificationRoute } from '../lib/routes'

export function DailyFlashcardReviewPage() {
  const { currentCertification } = useCertification()
  const queue = useFlashcardReviewQueue(currentCertification.id)
  const reviewRoute = certificationRoute(currentCertification.code, 'review')

  if (queue.loading) return <CertificationDataState title="Montando sua revisão de flashcards..." loading />
  if (queue.error) return <CertificationDataState title="Não foi possível carregar a revisão de flashcards." description={queue.error} onRetry={queue.retry} />

  if (queue.cards.length === 0) {
    const hasAvailableCards = (queue.overview?.availableFlashcardCount ?? 0) > 0
    return (
      <div className="mx-auto max-w-3xl">
        <CertificationDataState
          title={hasAvailableCards ? 'Tudo em dia!' : 'Nenhum Flashcard disponível para revisão.'}
          description={hasAvailableCards
            ? queue.overview?.nextReviewAt
              ? `Sua próxima revisão está agendada para ${formatReviewDate(queue.overview.nextReviewAt)}.`
              : 'Você não possui Flashcards para revisar agora.'
            : 'Esta certificação ainda não possui Flashcards publicados.'}
        />
        <Link to={reviewRoute} className="mt-5 inline-flex items-center gap-2 text-sm font-semibold text-blue-700">
          <ArrowLeft aria-hidden="true" className="h-4 w-4" />Voltar para Revisão
        </Link>
      </div>
    )
  }

  const dueCount = queue.cards.filter((card) => card.reviewStatus === 'due').length
  const newCount = queue.cards.length - dueCount

  return (
    <main className="mx-auto max-w-3xl">
      <Link to={reviewRoute} className="inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-blue-700 hover:text-blue-800">
        <ArrowLeft aria-hidden="true" className="h-4 w-4" />Voltar para Revisão
      </Link>
      <header className="mt-5 border-b border-slate-200 pb-6">
        <p className="flex items-center gap-2 text-sm font-bold text-blue-700">
          <Layers3 aria-hidden="true" className="h-5 w-5" />{formatCertificationCode(currentCertification.code)} · Revisão espaçada
        </p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">Flashcards para hoje</h1>
        <p className="mt-3 flex flex-wrap items-center gap-x-4 gap-y-2 text-sm text-slate-600">
          <span>{queue.cards.length} {queue.cards.length === 1 ? 'card na sessão' : 'cards na sessão'}</span>
          <span className="inline-flex items-center gap-1.5"><CalendarClock aria-hidden="true" className="h-4 w-4" />{dueCount} vencidos · {newCount} novos</span>
        </p>
      </header>
      <FlashcardViewer
        cards={queue.cards}
        returnRoute={reviewRoute}
        returnLabel="Voltar para Revisão"
        completionTitle="Revisão concluída"
        allowDifficultReview={false}
      />
    </main>
  )
}

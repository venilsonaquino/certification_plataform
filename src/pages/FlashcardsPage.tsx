import { ArrowRight, Brain, CalendarClock, ChevronDown, Layers3, LockKeyhole } from 'lucide-react'
import { Link } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { useCertification } from '../hooks/useCertification'
import { useFlashcardCatalog } from '../hooks/useFlashcardCatalog'
import { useFlashcardReviewOverview } from '../hooks/useFlashcardReviewOverview'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { formatReviewDate } from '../lib/flashcardReview'
import { flashcardReviewRoute, flashcardTopicRoute } from '../lib/routes'

export function FlashcardsPage() {
  const { currentCertification } = useCertification()
  const catalog = useFlashcardCatalog(currentCertification.id)
  const review = useFlashcardReviewOverview(currentCertification.id)
  const loading = catalog.loading || review.loading
  const error = catalog.error ?? review.error
  const overview = review.overview

  if (loading) return <CertificationDataState title="Organizando seus Flashcards..." loading />
  if (error || !overview) return <CertificationDataState title="Não foi possível carregar seus Flashcards." description={error ?? undefined} onRetry={() => { void catalog.retry(); void review.retry() }} />

  return (
    <div className="mx-auto max-w-6xl">
      <header className="max-w-3xl">
        <p className="flex items-center gap-2 text-sm font-bold text-blue-700"><Layers3 aria-hidden="true" className="h-5 w-5" />{formatCertificationCode(currentCertification.code)}</p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">Flashcards</h1>
        <p className="mt-3 text-base leading-7 text-slate-600">Reforce conceitos já estudados com recuperação ativa. A revisão diária agenda repetições; o estudo livre não altera sua agenda.</p>
      </header>

      <section aria-labelledby="daily-review-title" className="mt-8 rounded-2xl border border-blue-200 bg-gradient-to-br from-blue-50 to-cyan-50 p-6 sm:flex sm:items-center sm:justify-between sm:gap-6 sm:p-7">
        <div className="flex items-start gap-4">
          <div className="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-blue-100 text-blue-700"><CalendarClock aria-hidden="true" className="h-5 w-5" /></div>
          <div>
            <h2 id="daily-review-title" className="text-xl font-bold text-slate-950">Revisão de hoje</h2>
            {overview.queueCount > 0 ? (
              <p className="mt-2 text-sm text-slate-600"><strong className="text-slate-900">{overview.queueCount} {overview.queueCount === 1 ? 'card' : 'cards'}</strong> · {overview.dueCount} vencidos · {overview.newCount} novos</p>
            ) : overview.availableFlashcardCount === 0 ? (
              <p className="mt-2 text-sm text-slate-600">Conclua aulas da trilha para liberar seus Flashcards.</p>
            ) : (
              <p className="mt-2 text-sm text-slate-600">Tudo em dia! Você ainda pode estudar livremente.</p>
            )}
            {overview.queueCount === 0 && overview.nextReviewAt && <p className="mt-1 text-xs font-semibold text-blue-700">Próxima revisão: {formatReviewDate(overview.nextReviewAt)}</p>}
          </div>
        </div>
        {overview.queueCount > 0 && <Link to={flashcardReviewRoute(currentCertification.code)} className="mt-5 inline-flex min-h-11 w-full shrink-0 items-center justify-center gap-2 rounded-xl bg-blue-700 px-5 text-sm font-bold text-white hover:bg-blue-800 sm:mt-0 sm:w-auto">Iniciar revisão<ArrowRight aria-hidden="true" className="h-4 w-4" /></Link>}
      </section>

      <section aria-labelledby="free-study-title" className="mt-9">
        <div className="flex items-start gap-3">
          <div className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-violet-50 text-violet-700"><Brain aria-hidden="true" className="h-5 w-5" /></div>
          <div><h2 id="free-study-title" className="text-xl font-bold text-slate-950">Estudo livre por domínio</h2><p className="mt-1 text-sm leading-6 text-slate-500">Escolha um tópico e pratique sem modificar o agendamento da repetição espaçada.</p></div>
        </div>

        {overview.totalFlashcardCount === 0 ? (
          <div className="mt-5"><CertificationDataState title="Nenhum Flashcard disponível." description="Esta certificação ainda não possui Flashcards publicados." /></div>
        ) : (
          <div className="mt-5 space-y-4">
            {catalog.domains.map((domain) => (
              <details key={domain.domainId} className="group overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-card" open={domain.availableCount > 0}>
                <summary className="flex cursor-pointer list-none items-center justify-between gap-4 px-5 py-5 marker:content-none sm:px-6 [&::-webkit-details-marker]:hidden">
                  <div><h3 className="font-bold text-slate-950">{domain.title}</h3><p className="mt-1 text-sm text-slate-500">{domain.availableCount} disponíveis de {domain.totalCount}</p></div>
                  <ChevronDown aria-hidden="true" className="h-5 w-5 text-slate-400 transition group-open:rotate-180" />
                </summary>
                <div className="grid gap-3 border-t border-slate-100 p-4 sm:p-5 md:grid-cols-2">
                  {domain.topics.map((topic) => topic.availableCount > 0 ? (
                    <Link key={topic.topicId} to={flashcardTopicRoute(currentCertification.code, topic.topicId)} className="group/topic flex min-h-[88px] items-center justify-between gap-4 rounded-xl border border-slate-200 p-4 hover:border-violet-300 hover:bg-violet-50">
                      <span><span className="block text-sm font-bold text-slate-900 group-hover/topic:text-violet-800">{topic.title}</span><span className="mt-1 block text-xs text-slate-500">{topic.availableCount} disponíveis{topic.studiedCount > 0 ? ` · ${topic.studiedCount} já revisados` : ''}</span></span>
                      <ArrowRight aria-hidden="true" className="h-4 w-4 shrink-0 text-violet-600" />
                    </Link>
                  ) : (
                    <article key={topic.topicId} aria-label={`${topic.title}: sem Flashcards disponíveis`} className="flex min-h-[88px] items-center gap-3 rounded-xl border border-slate-200 bg-slate-50 p-4">
                      <LockKeyhole aria-hidden="true" className="h-4 w-4 shrink-0 text-slate-500" /><span><span className="block text-sm font-bold text-slate-700">{topic.title}</span><span className="mt-1 block text-xs text-slate-500">0 disponíveis de {topic.totalCount}. Conclua as aulas deste tópico.</span></span>
                    </article>
                  ))}
                </div>
              </details>
            ))}
          </div>
        )}
      </section>
    </div>
  )
}

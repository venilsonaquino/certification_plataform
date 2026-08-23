import { ArrowRight, BookOpenCheck, Filter, History, Layers3, LoaderCircle } from 'lucide-react'
import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { QuestionReviewCard } from '../components/review/QuestionReviewCard'
import { ReviewSummaryCards } from '../components/review/ReviewSummaryCards'
import { useCertification } from '../hooks/useCertification'
import { useQuestionReview } from '../hooks/useQuestionReview'
import { useFlashcardReviewOverview } from '../hooks/useFlashcardReviewOverview'
import { formatReviewDate } from '../lib/flashcardReview'
import { certificationRoute, flashcardReviewRoute, lessonRoute, reviewQuizRoute } from '../lib/routes'
import { REVIEW_RECENT_DAYS, type ReviewPriorityFilter } from '../types/quiz'

const filters: { value: ReviewPriorityFilter; label: string }[] = [
  { value: 'all', label: 'Todos' }, { value: 'high', label: 'Alta' },
  { value: 'medium', label: 'Média' }, { value: 'low', label: 'Baixa' },
  { value: 'recent', label: 'Recentes' },
]

export function ReviewPage() {
  const { currentCertification } = useCertification()
  const review = useQuestionReview(currentCertification.id)
  const flashcardReview = useFlashcardReviewOverview(currentCertification.id)
  const [priority, setPriority] = useState<ReviewPriorityFilter>('all')
  const [domainId, setDomainId] = useState('all')
  const [topicId, setTopicId] = useState('all')

  const domains = useMemo(() => Array.from(new Map(review.questions.filter((item) => item.domainId).map((item) => [item.domainId, item.domainTitle])).entries()), [review.questions])
  const topics = useMemo(() => Array.from(new Map(review.questions.filter((item) => item.topicId && (domainId === 'all' || item.domainId === domainId)).map((item) => [item.topicId, item.topicTitle])).entries()), [domainId, review.questions])
  const visibleQuestions = useMemo(() => {
    const recentCutoff = Date.now() - REVIEW_RECENT_DAYS * 24 * 60 * 60 * 1000
    return review.questions.filter((question) =>
      (priority === 'all' || (priority === 'recent' ? new Date(question.lastAnsweredAt).getTime() >= recentCutoff : question.priority === priority))
      && (domainId === 'all' || question.domainId === domainId)
      && (topicId === 'all' || question.topicId === topicId),
    )
  }, [domainId, priority, review.questions, topicId])

  if (review.loading) return <CertificationDataState title="Carregando seu histórico de erros..." loading />
  if (review.error || !review.summary) return <CertificationDataState title="Não foi possível carregar Meus Erros." description={review.error ?? undefined} onRetry={review.retry} />

  const active = review.summary.activeAttempt
  const generalReviewRoute = reviewQuizRoute(currentCertification.code)
  const dailyFlashcardRoute = flashcardReviewRoute(currentCertification.code)
  return (
    <div className="mx-auto max-w-6xl space-y-7">
      <header className="flex flex-col gap-5 sm:flex-row sm:items-end sm:justify-between"><div><p className="text-sm font-bold uppercase tracking-[0.16em] text-blue-600">Revisão inteligente</p><h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">Revisão</h1><p className="mt-3 max-w-2xl text-base leading-7 text-slate-600">Reforce conceitos com Flashcards espaçados e revise questões pelo seu histórico de erros.</p></div>{review.summary.totalQuestions > 0 && <Link to={generalReviewRoute} className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-blue-600 px-5 text-sm font-bold text-white shadow-sm hover:bg-blue-700">{active ? `Continuar revisão · ${review.summary.activeAnsweredCount}/${active.totalQuestions}` : 'Iniciar revisão de erros'}<ArrowRight className="h-4 w-4" /></Link>}</header>
      <section className="rounded-2xl border border-blue-200 bg-blue-50/70 p-5 sm:flex sm:items-center sm:justify-between sm:gap-5 sm:p-6">
        <div className="flex items-start gap-3">
          <Layers3 className="mt-0.5 h-6 w-6 shrink-0 text-blue-700" />
          <div>
            <h2 className="font-bold text-slate-950">Flashcards para hoje</h2>
            {flashcardReview.loading ? (
              <p className="mt-1 flex items-center gap-2 text-sm text-slate-500"><LoaderCircle className="h-4 w-4 animate-spin" />Calculando sua fila...</p>
            ) : flashcardReview.error ? (
              <button type="button" onClick={() => { void flashcardReview.retry() }} className="mt-2 text-sm font-semibold text-rose-700">Não foi possível carregar. Tentar novamente</button>
            ) : flashcardReview.overview ? (
              <p className="mt-1 text-sm text-slate-600">
                {flashcardReview.overview.queueCount > 0
                  ? `${flashcardReview.overview.queueCount} ${flashcardReview.overview.queueCount === 1 ? 'card pendente' : 'cards pendentes'} nesta sessão`
                  : flashcardReview.overview.availableFlashcardCount === 0
                    ? 'Nenhum Flashcard publicado nesta certificação.'
                    : flashcardReview.overview.nextReviewAt
                      ? `Tudo em dia · próxima revisão em ${formatReviewDate(flashcardReview.overview.nextReviewAt)}`
                      : 'Tudo em dia por enquanto.'}
              </p>
            ) : null}
          </div>
        </div>
        {flashcardReview.overview && flashcardReview.overview.queueCount > 0 && (
          <Link to={dailyFlashcardRoute} className="mt-4 inline-flex min-h-11 w-full items-center justify-center gap-2 rounded-xl bg-blue-700 px-5 text-sm font-bold text-white hover:bg-blue-800 sm:mt-0 sm:w-auto">Começar revisão<ArrowRight className="h-4 w-4" /></Link>
        )}
      </section>
      <ReviewSummaryCards summary={review.summary} />
      {active && <Link to={generalReviewRoute} className="flex flex-col gap-3 rounded-2xl border border-blue-200 bg-blue-50 p-5 sm:flex-row sm:items-center sm:justify-between"><span><strong className="block text-blue-950">Revisão em andamento</strong><span className="mt-1 block text-sm text-blue-700">Você respondeu {review.summary.activeAnsweredCount} de {active.totalQuestions} questões. Seu progresso foi salvo.</span></span><span className="inline-flex items-center gap-2 text-sm font-bold text-blue-800">Continuar <ArrowRight className="h-4 w-4" /></span></Link>}
      {review.summary.totalQuestions === 0 ? (
        <section className="rounded-2xl border border-slate-200 bg-white px-6 py-14 text-center shadow-card"><div className="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-emerald-50 text-emerald-700"><BookOpenCheck className="h-7 w-7" /></div><h2 className="mt-5 text-xl font-bold text-slate-950">Nenhum erro para revisar</h2><p className="mx-auto mt-2 max-w-lg text-sm leading-6 text-slate-500">Quando você errar uma questão em um Quiz, ela aparecerá aqui. Respostas corretas não são tratadas como erro.</p><Link to={certificationRoute(currentCertification.code, 'study')} className="mt-6 inline-flex min-h-11 items-center justify-center rounded-xl bg-slate-950 px-5 text-sm font-bold text-white">Ir para a trilha</Link></section>
      ) : (
        <>
          <section className="rounded-2xl border border-slate-200 bg-white p-4 shadow-card sm:p-5"><div className="flex items-center gap-2 text-sm font-bold text-slate-800"><Filter className="h-4 w-4" />Filtrar questões</div><div className="mt-4 flex flex-wrap gap-2">{filters.map((item) => <button key={item.value} type="button" onClick={() => setPriority(item.value)} className={`min-h-10 rounded-full px-4 text-sm font-bold ${priority === item.value ? 'bg-slate-950 text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}`}>{item.label}</button>)}</div><div className="mt-4 grid gap-3 sm:grid-cols-2"><select aria-label="Filtrar por domínio" value={domainId} onChange={(event) => { setDomainId(event.target.value); setTopicId('all') }} className="min-h-11 rounded-xl border border-slate-200 bg-white px-3 text-sm font-semibold text-slate-700"><option value="all">Todos os domínios</option>{domains.map(([id, title]) => <option key={id} value={id ?? ''}>{title}</option>)}</select><select aria-label="Filtrar por tópico" value={topicId} onChange={(event) => setTopicId(event.target.value)} className="min-h-11 rounded-xl border border-slate-200 bg-white px-3 text-sm font-semibold text-slate-700"><option value="all">Todos os tópicos</option>{topics.map(([id, title]) => <option key={id} value={id ?? ''}>{title}</option>)}</select></div></section>
          <div className="flex items-center justify-between"><h2 className="text-lg font-bold text-slate-950">Questões priorizadas</h2><span className="flex items-center gap-2 text-sm text-slate-500"><History className="h-4 w-4" />{visibleQuestions.length} {visibleQuestions.length === 1 ? 'questão' : 'questões'}</span></div>
          {visibleQuestions.length > 0 ? <div className="grid gap-4">{visibleQuestions.map((question) => <QuestionReviewCard key={question.questionId} question={question} hasActiveReview={Boolean(active)} reviewRoute={active ? generalReviewRoute : reviewQuizRoute(currentCertification.code, question.questionId)} lessonRoute={question.lessonSlug ? lessonRoute(currentCertification.code, question.lessonSlug) : undefined} />)}</div> : <div className="rounded-2xl border border-dashed border-slate-300 px-6 py-10 text-center text-sm text-slate-500">Nenhuma questão corresponde aos filtros selecionados.</div>}
        </>
      )}
    </div>
  )
}

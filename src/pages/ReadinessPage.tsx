import { BookOpen, ChevronDown } from 'lucide-react'
import { Link } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { ReadinessDomains } from '../components/readiness/ReadinessDomains'
import { ReadinessOverall } from '../components/readiness/ReadinessOverall'
import { ReadinessPriorityTopics } from '../components/readiness/ReadinessPriorityTopics'
import { ReadinessRecentPerformance } from '../components/readiness/ReadinessRecentPerformance'
import { useCertification } from '../hooks/useCertification'
import { useCertificationReadiness } from '../hooks/useCertificationReadiness'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { certificationRoute } from '../lib/routes'
import type { StudyRecommendationAction, TopicStudyRecommendation } from '../types/studyRecommendation'

function selectSummaryActions(topics: readonly TopicStudyRecommendation[]) {
  const uniqueRoutes = new Set<string>()
  const actions: { action: StudyRecommendationAction; topicTitle: string }[] = []
  for (const topic of topics) {
    const action = topic.actions.find((candidate) => !uniqueRoutes.has(candidate.route))
    if (!action) continue
    uniqueRoutes.add(action.route)
    actions.push({ action, topicTitle: topic.topicTitle })
    if (actions.length === 3) break
  }
  return actions
}

export function ReadinessPage() {
  const { currentCertification } = useCertification()
  const { data, loading, error, retry } = useCertificationReadiness(
    currentCertification.id,
    currentCertification.code,
  )
  const certificationCode = formatCertificationCode(currentCertification.code)

  return (
    <div>
      <header className="max-w-3xl">
        <p className="text-sm font-semibold text-blue-600">{certificationCode}</p>
        <h1 className="mt-2 text-balance text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">Readiness</h1>
        <p className="mt-3 text-base leading-7 text-slate-500">Entenda a força da sua evidência de prática, os domínios que pedem atenção e as próximas ações de estudo.</p>
      </header>

      {loading && <ReadinessLoading />}
      {!loading && error && (
        <div className="mt-8 lg:mt-10">
          <CertificationDataState title="Não foi possível carregar seu Readiness." description="Tente novamente. Seu histórico de estudo permanece preservado." onRetry={retry} />
        </div>
      )}

      {!loading && !error && data && (
        <>
          <ReadinessOverall readiness={data.readiness} summaryActions={selectSummaryActions(data.recommendations.topics)} />

          {data.readiness.classification === 'not_enough_evidence' && (
            <section aria-labelledby="readiness-empty-title" className="mt-5 rounded-2xl border border-blue-200 bg-blue-50 p-5 sm:flex sm:items-center sm:justify-between sm:gap-6 sm:p-6">
              <div>
                <h2 id="readiness-empty-title" className="font-bold text-blue-950">Ainda não há evidência suficiente</h2>
                <p className="mt-2 text-sm leading-6 text-blue-800">Conclua Quizzes ou um Mock Exam para construir seu perfil. Seu progresso de estudo continua sendo reconhecido separadamente.</p>
              </div>
              <Link to={certificationRoute(currentCertification.code, 'study')} className="mt-4 inline-flex min-h-11 shrink-0 items-center justify-center gap-2 rounded-xl bg-blue-700 px-5 text-sm font-bold text-white hover:bg-blue-800 sm:mt-0">
                <BookOpen aria-hidden="true" className="h-4 w-4" /> Continuar estudando
              </Link>
            </section>
          )}

          <ReadinessDomains certificationCode={currentCertification.code} domains={data.readiness.domains} topics={data.readiness.topics} />
          <ReadinessPriorityTopics topics={data.recommendations.topics} />
          <ReadinessRecentPerformance attempts={data.recentMocks} trend={data.readiness.trend} />

          <details className="group mt-10 rounded-2xl border border-slate-200 bg-white p-5 shadow-card sm:p-6">
            <summary className="flex min-h-11 cursor-pointer list-none items-center justify-between gap-4 font-bold text-slate-950 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-blue-600">
              Como o Readiness é calculado?
              <ChevronDown aria-hidden="true" className="h-5 w-5 text-slate-500 transition group-open:rotate-180" />
            </summary>
            <div className="mt-4 border-t border-slate-100 pt-4 text-sm leading-6 text-slate-600">
              <ul className="space-y-2">
                <li>• Mock Exams finalizados possuem a influência mais forte.</li>
                <li>• Checkpoints do Tópico fornecem evidência direcionada para cada tópico.</li>
                <li>• Quizzes de aula anteriores permanecem como evidência histórica de lacunas específicas.</li>
                <li>• Conclusão de aulas representa progresso de estudo, não domínio comprovado.</li>
                <li>• Evidências recentes recebem mais relevância do que evidências antigas.</li>
              </ul>
              <p className="mt-4 font-semibold text-slate-700">Readiness não representa chance de aprovação nem resultado oficial do exame.</p>
            </div>
          </details>
        </>
      )}
    </div>
  )
}

function ReadinessLoading() {
  return (
    <div role="status" aria-label="Carregando Readiness" className="mt-8 space-y-5 lg:mt-10">
      <span className="sr-only">Carregando Readiness...</span>
      <div className="h-72 animate-pulse rounded-3xl bg-slate-200" />
      <div className="grid gap-5 lg:grid-cols-3">
        {[0, 1, 2].map((item) => <div key={item} className="h-64 animate-pulse rounded-2xl bg-slate-200" />)}
      </div>
    </div>
  )
}

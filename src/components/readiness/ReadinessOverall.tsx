import { Activity, CalendarClock, ClipboardCheck, Layers3 } from 'lucide-react'
import { Link } from 'react-router-dom'

import {
  evidenceLabels,
  formatReadinessDate,
  globalStatusLabels,
  statusDescriptions,
  trendLabels,
} from '../../features/readiness/readinessPresentation'
import type { GlobalReadiness } from '../../types/readiness'
import type { StudyRecommendationAction } from '../../types/studyRecommendation'
import { actionLabels } from '../../features/readiness/readinessPresentation'
import { ReadinessStatusBadge } from './ReadinessStatusBadge'

interface ReadinessOverallProps {
  readonly readiness: GlobalReadiness
  readonly summaryActions: readonly {
    readonly action: StudyRecommendationAction
    readonly topicTitle: string
  }[]
}

export function ReadinessOverall({ readiness, summaryActions }: ReadinessOverallProps) {
  const progress = readiness.trace.learningProgress
  const learningPercentage = progress.totalLessons === 0
    ? 0
    : Math.round(progress.completedLessons / progress.totalLessons * 100)
  const sourceCounts = readiness.trace.sourceCounts
  const mockAttempts = sourceCounts.find((source) => source.source === 'mock_exam')?.attempts ?? 0
  const topicAttempts = sourceCounts.find((source) => source.source === 'topic_quiz')?.attempts ?? 0

  return (
    <>
      <section aria-labelledby="overall-readiness-title" className="mt-8 overflow-hidden rounded-3xl border border-blue-200 bg-gradient-to-br from-navy-900 via-blue-900 to-blue-700 p-6 text-white shadow-xl shadow-blue-900/10 sm:p-8 lg:mt-10">
        <div className="flex flex-col gap-6 lg:flex-row lg:items-start lg:justify-between">
          <div className="max-w-3xl">
            <p className="text-xs font-bold uppercase tracking-[0.16em] text-blue-200">Readiness geral</p>
            <h2 id="overall-readiness-title" className="mt-3 text-3xl font-bold tracking-tight sm:text-4xl">
              {globalStatusLabels[readiness.classification]}
            </h2>
            <p className="mt-3 max-w-2xl text-sm leading-6 text-blue-100 sm:text-base">
              {statusDescriptions[readiness.classification]}
            </p>
          </div>
          <ReadinessStatusBadge status={readiness.classification} global />
        </div>

        <div className="mt-7 grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
          <OverallFact icon={ClipboardCheck} label="Evidência" value={evidenceLabels[readiness.evidenceLevel]} />
          <OverallFact icon={Activity} label="Tendência" value={trendLabels[readiness.trend]} />
          <OverallFact icon={Layers3} label="Atividade avaliada" value={`${mockAttempts} Mocks · ${topicAttempts} Topic Quizzes`} />
          <OverallFact icon={CalendarClock} label="Última avaliação" value={formatReadinessDate(readiness.trace.latestEvidenceAt)} />
        </div>

        {readiness.trace.recency === 'stale' && (
          <p role="status" className="mt-5 rounded-xl border border-amber-300/40 bg-amber-300/10 px-4 py-3 text-sm font-semibold text-amber-100">
            Sua evidência mais forte está antiga. Faça uma nova avaliação para atualizar o perfil.
          </p>
        )}
      </section>

      <section aria-labelledby="evidence-title" className="mt-5 grid gap-5 lg:grid-cols-[1fr_1.15fr]">
        <article className="rounded-2xl border border-slate-200 bg-white p-5 shadow-card sm:p-6">
          <h2 id="evidence-title" className="text-lg font-bold text-slate-950">Evidência e progresso de estudo</h2>
          <p className="mt-2 text-sm leading-6 text-slate-500">
            Readiness usa atividades avaliadas. Concluir aulas demonstra progresso de estudo, não domínio comprovado.
          </p>
          <div className="mt-5 flex items-end justify-between gap-4">
            <div>
              <p className="text-3xl font-bold text-slate-950">{learningPercentage}%</p>
              <p className="mt-1 text-sm text-slate-500">Progresso de estudo</p>
            </div>
            <p className="text-right text-sm font-semibold text-slate-600">
              {progress.completedLessons} de {progress.totalLessons} aulas
            </p>
          </div>
          <div role="progressbar" aria-label="Progresso de estudo" aria-valuemin={0} aria-valuemax={100} aria-valuenow={learningPercentage} className="mt-4 h-2 overflow-hidden rounded-full bg-slate-100">
            <div className="h-full rounded-full bg-gradient-to-r from-blue-600 to-sky-400" style={{ width: `${learningPercentage}%` }} />
          </div>
          <p className="mt-4 text-xs text-slate-500">
            {readiness.trace.answeredQuestions} respostas avaliadas · {readiness.trace.distinctQuestions} questões distintas · {readiness.trace.assessmentSessions} sessões
          </p>
        </article>

        <article className="rounded-2xl border border-slate-200 bg-white p-5 shadow-card sm:p-6">
          <h2 className="text-lg font-bold text-slate-950">Próximas ações recomendadas</h2>
          {summaryActions.length > 0 ? (
            <ol className="mt-4 space-y-3">
              {summaryActions.map(({ action, topicTitle }, index) => (
                <li key={`${action.type}:${action.route}`}>
                  <Link to={action.route} className="flex min-h-11 items-center gap-3 rounded-xl border border-slate-200 px-4 py-3 text-sm font-semibold text-slate-700 transition hover:border-blue-300 hover:bg-blue-50 hover:text-blue-800">
                    <span aria-hidden="true" className="grid h-6 w-6 shrink-0 place-items-center rounded-full bg-blue-100 text-xs font-bold text-blue-700">{index + 1}</span>
                    <span>{actionLabels[action.type]} <span className="font-normal text-slate-500">· {topicTitle}</span></span>
                  </Link>
                </li>
              ))}
            </ol>
          ) : (
            <p className="mt-4 rounded-xl bg-emerald-50 px-4 py-3 text-sm text-emerald-800">
              Nenhuma revisão prioritária agora. Continue praticando para manter a evidência atual.
            </p>
          )}
        </article>
      </section>
    </>
  )
}

function OverallFact({ icon: Icon, label, value }: { icon: typeof Activity; label: string; value: string }) {
  return (
    <div className="rounded-xl bg-white/10 p-4 ring-1 ring-inset ring-white/10">
      <Icon aria-hidden="true" className="h-4 w-4 text-sky-300" />
      <p className="mt-3 text-xs font-semibold uppercase tracking-wide text-blue-200">{label}</p>
      <p className="mt-1 text-sm font-bold text-white">{value}</p>
    </div>
  )
}

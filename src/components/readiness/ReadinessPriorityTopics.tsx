import { ArrowRight, BookOpenCheck, CircleHelp } from 'lucide-react'
import { Link } from 'react-router-dom'

import {
  actionLabels,
  evidenceLabels,
  priorityLabels,
  priorityTone,
  recommendationReasonLabels,
  trendLabels,
} from '../../features/readiness/readinessPresentation'
import type { TopicStudyRecommendation } from '../../types/studyRecommendation'

interface ReadinessPriorityTopicsProps {
  readonly topics: readonly TopicStudyRecommendation[]
}

export function ReadinessPriorityTopics({ topics }: ReadinessPriorityTopicsProps) {
  return (
    <section aria-labelledby="priority-topics-title" className="mt-10">
      <p className="text-sm font-semibold text-blue-600">Priority Topics</p>
      <h2 id="priority-topics-title" className="mt-1 text-2xl font-bold tracking-tight text-slate-950">O que merece atenção agora</h2>
      <p className="mt-2 max-w-3xl text-sm leading-6 text-slate-500">A ordem e as ações vêm do Recommendation Engine. Evidência insuficiente significa avaliar, não fraqueza.</p>

      {topics.length === 0 ? (
        <div className="mt-5 rounded-2xl border border-emerald-200 bg-emerald-50 p-6">
          <h3 className="font-bold text-emerald-950">Nenhuma revisão prioritária</h3>
          <p className="mt-2 text-sm leading-6 text-emerald-800">Continue praticando para manter seu perfil atualizado.</p>
        </div>
      ) : (
        <div className="mt-5 space-y-5">
          {topics.map((topic) => (
            <article key={topic.topicId} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-card sm:p-6">
              <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                <div>
                  <h3 className="text-xl font-bold text-slate-950">{topic.topicTitle}</h3>
                  <p className="mt-2 text-sm text-slate-500">Evidence: <strong className="text-slate-700">{evidenceLabels[topic.evidenceLevel]}</strong> · Trend: <strong className="text-slate-700">{trendLabels[topic.trend]}</strong></p>
                </div>
                <span className={`inline-flex w-fit rounded-full border px-3 py-1 text-xs font-bold ${priorityTone[topic.priority]}`}>
                  Priority: {priorityLabels[topic.priority]}
                </span>
              </div>

              <div className="mt-5 grid gap-5 lg:grid-cols-2">
                <div>
                  <h4 className="flex items-center gap-2 text-sm font-bold text-slate-900"><CircleHelp aria-hidden="true" className="h-4 w-4 text-blue-600" />Why this is recommended</h4>
                  <ul className="mt-3 space-y-2 text-sm leading-6 text-slate-600">
                    {topic.reasonCodes.map((reason) => <li key={reason}>• {recommendationReasonLabels[reason]}</li>)}
                  </ul>
                  <dl className="mt-4 grid grid-cols-2 gap-3 rounded-xl bg-slate-50 p-4 text-xs">
                    <EvidenceMetric label="Mock" value={topic.evidence.mockPerformance} />
                    <EvidenceMetric label="Topic Quiz" value={topic.evidence.topicQuizPerformance} />
                    <EvidenceMetric label="Recent errors" value={topic.evidence.recentIncorrectAnswers} suffix="" />
                    <EvidenceMetric label="Recurring Questions" value={topic.evidence.recurringIncorrectQuestions} suffix="" />
                  </dl>
                </div>

                <div>
                  <h4 className="flex items-center gap-2 text-sm font-bold text-slate-900"><BookOpenCheck aria-hidden="true" className="h-4 w-4 text-blue-600" />Recommended lessons</h4>
                  {topic.recommendedLessons.length > 0 ? (
                    <ul className="mt-3 space-y-2">
                      {topic.recommendedLessons.map((lesson) => (
                        <li key={lesson.id}>
                          <Link to={lesson.route} className="flex min-h-11 items-center justify-between gap-3 rounded-xl border border-slate-200 px-4 py-3 text-sm font-semibold text-slate-700 hover:border-blue-300 hover:bg-blue-50 hover:text-blue-800">
                            <span>{lesson.title}</span><ArrowRight aria-hidden="true" className="h-4 w-4 shrink-0" />
                          </Link>
                        </li>
                      ))}
                    </ul>
                  ) : (
                    <p className="mt-3 rounded-xl bg-slate-50 px-4 py-3 text-sm text-slate-600">Nenhuma Lesson específica foi associada aos erros; use a avaliação do Topic.</p>
                  )}
                </div>
              </div>

              <div aria-label={`Ações para ${topic.topicTitle}`} className="mt-5 flex flex-col gap-2 border-t border-slate-100 pt-5 sm:flex-row sm:flex-wrap">
                {topic.actions.filter((action) => action.type !== 'review_lesson').map((action) => (
                  <Link key={`${action.type}:${action.route}`} to={action.route} className="inline-flex min-h-11 items-center justify-center rounded-xl bg-blue-700 px-4 text-sm font-bold text-white hover:bg-blue-800">
                    {actionLabels[action.type]}
                  </Link>
                ))}
              </div>
            </article>
          ))}
        </div>
      )}
    </section>
  )
}

function EvidenceMetric({ label, value, suffix = '%' }: { label: string; value: number | null; suffix?: string }) {
  return <div><dt className="text-slate-500">{label}</dt><dd className="mt-1 font-bold text-slate-800">{value === null ? 'No data' : `${value}${suffix}`}</dd></div>
}

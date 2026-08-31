import { ArrowRight, BarChart3, ShieldCheck } from 'lucide-react'
import { Link } from 'react-router-dom'

import {
  evidenceLabels,
  formatReadinessDate,
  trendLabels,
} from '../../features/readiness/readinessPresentation'
import { certificationRoute } from '../../lib/routes'
import type { DomainReadiness, TopicReadiness } from '../../types/readiness'
import { ReadinessStatusBadge } from './ReadinessStatusBadge'

interface ReadinessDomainsProps {
  readonly certificationCode: string
  readonly domains: readonly DomainReadiness[]
  readonly topics: readonly TopicReadiness[]
}

export function ReadinessDomains({ certificationCode, domains, topics }: ReadinessDomainsProps) {
  return (
    <section aria-labelledby="domain-readiness-title" className="mt-10">
      <div className="max-w-3xl">
        <p className="text-sm font-semibold text-blue-600">Domain Readiness</p>
        <h2 id="domain-readiness-title" className="mt-1 text-2xl font-bold tracking-tight text-slate-950">Onde sua evidência é mais forte</h2>
        <p className="mt-2 text-sm leading-6 text-slate-500">Os cards usam as classificações e a cobertura calculadas pela engine, sem transformar progresso em proficiência.</p>
      </div>
      <div className="mt-5 grid gap-5 xl:grid-cols-3">
        {domains.map((domain) => {
          const domainTopics = topics.filter((topic) => topic.domainId === domain.domainId)
          const attention = domainTopics.filter((topic) =>
            topic.classification === 'needs_review' || topic.classification === 'developing')
          const coverage = Math.round(domain.topicCoverage * 100)
          return (
            <article key={domain.domainId} className="flex flex-col rounded-2xl border border-slate-200 bg-white p-5 shadow-card sm:p-6">
              <div className="flex items-start justify-between gap-4">
                <div className="grid h-10 w-10 place-items-center rounded-xl bg-blue-50 text-blue-700">
                  <ShieldCheck aria-hidden="true" className="h-5 w-5" />
                </div>
                <ReadinessStatusBadge status={domain.classification} />
              </div>
              <h3 className="mt-5 text-lg font-bold leading-6 text-slate-950">{domain.title}</h3>
              <dl className="mt-4 grid grid-cols-2 gap-3 text-sm">
                <div>
                  <dt className="text-slate-500">Evidence</dt>
                  <dd className="mt-1 font-bold text-slate-800">{evidenceLabels[domain.evidenceLevel]}</dd>
                </div>
                <div>
                  <dt className="text-slate-500">Trend</dt>
                  <dd className="mt-1 font-bold text-slate-800">{trendLabels[domain.trend]}</dd>
                </div>
              </dl>
              <div className="mt-5">
                <div className="flex items-center justify-between gap-4 text-xs">
                  <span className="font-semibold text-slate-600">Assessment coverage</span>
                  <span className="font-bold text-slate-800">{coverage}% dos Topics</span>
                </div>
                <div role="progressbar" aria-label={`Assessment coverage de ${domain.title}`} aria-valuemin={0} aria-valuemax={100} aria-valuenow={coverage} className="mt-2 h-2 overflow-hidden rounded-full bg-slate-100">
                  <div className="h-full rounded-full bg-blue-600" style={{ width: `${coverage}%` }} />
                </div>
              </div>
              <div className="mt-5 rounded-xl bg-slate-50 p-4">
                <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wide text-slate-500">
                  <BarChart3 aria-hidden="true" className="h-4 w-4" /> Topics needing attention
                </div>
                <p className="mt-2 text-sm leading-6 text-slate-700">
                  {attention.length > 0
                    ? attention.slice(0, 2).map((topic) => topic.title).join(' · ')
                    : domain.evidenceLevel === 'insufficient' || domain.evidenceLevel === 'limited'
                      ? 'Mais avaliações são necessárias.'
                      : 'Nenhum Topic prioritário neste momento.'}
                </p>
              </div>
              <p className="mt-4 text-xs text-slate-400">Última evidência: {formatReadinessDate(domain.trace.latestEvidenceAt)}</p>
              <Link to={certificationRoute(certificationCode, 'study')} className="mt-auto inline-flex min-h-11 items-center gap-2 pt-5 text-sm font-bold text-blue-700 hover:text-blue-900">
                Explorar trilha <ArrowRight aria-hidden="true" className="h-4 w-4" />
              </Link>
            </article>
          )
        })}
      </div>
    </section>
  )
}

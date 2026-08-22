import { ArrowRight, Clock3 } from 'lucide-react'
import { Link } from 'react-router-dom'

import { formatCertificationCode, getCertificationColor } from '../../lib/certificationVisuals'
import { certificationRoute } from '../../lib/routes'
import type { Certification } from '../../types/certification'

interface CertificationCardProps {
  certification: Certification
}

export function CertificationCard({ certification }: CertificationCardProps) {
  const displayCode = formatCertificationCode(certification.code)

  const content = (
    <>
      <div className="flex items-start justify-between gap-4">
        <div
          aria-hidden="true"
          className="grid h-14 w-14 place-items-center rounded-2xl text-base font-bold tracking-tight text-white shadow-lg"
          style={{ backgroundColor: getCertificationColor(certification.code) }}
        >
          {displayCode.split('-')[0]}
        </div>
        <span
          className={[
            'inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-semibold ring-1 ring-inset',
            certification.isEnabled
              ? 'bg-emerald-50 text-emerald-700 ring-emerald-200'
              : 'bg-slate-100 text-slate-500 ring-slate-200',
          ].join(' ')}
        >
          {!certification.isEnabled && <Clock3 aria-hidden="true" className="h-3.5 w-3.5" />}
          {certification.isEnabled ? 'Disponível' : 'Em breve'}
        </span>
      </div>

      <div className="mt-7">
        <p className="text-sm font-bold tracking-wide text-blue-600">{displayCode}</p>
        <h2 className="mt-2 text-xl font-bold tracking-tight text-slate-950">
          {certification.name}
        </h2>
        <p className="mt-2 text-sm leading-6 text-slate-500">{certification.provider}</p>
      </div>

      <div className="mt-auto pt-7">
        {certification.isEnabled ? (
          <span className="inline-flex items-center gap-2 text-sm font-semibold text-blue-600">
            Começar
            <ArrowRight aria-hidden="true" className="h-4 w-4 transition-transform group-hover:translate-x-0.5" />
          </span>
        ) : (
          <span className="text-sm font-medium text-slate-400">Ainda não disponível</span>
        )}
      </div>
    </>
  )

  if (certification.isEnabled) {
    return (
      <Link
        to={certificationRoute(certification.code, 'dashboard')}
        aria-label={`Começar ${displayCode} — ${certification.name}`}
        className="group flex min-h-72 flex-col rounded-2xl border border-slate-200/80 bg-white p-6 shadow-card transition duration-200 hover:-translate-y-1 hover:border-blue-200 hover:shadow-xl hover:shadow-blue-100/60 sm:p-7"
      >
        {content}
      </Link>
    )
  }

  return (
    <article
      aria-disabled="true"
      className="flex min-h-72 flex-col rounded-2xl border border-slate-200/70 bg-white/60 p-6 opacity-70 shadow-sm sm:p-7"
    >
      {content}
    </article>
  )
}

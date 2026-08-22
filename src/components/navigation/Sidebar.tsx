import { ArrowLeftRight } from 'lucide-react'
import { Link } from 'react-router-dom'

import { useCertification } from '../../hooks/useCertification'
import { Brand } from '../Brand'
import { CertificationIdentity } from '../certifications/CertificationIdentity'
import { NavigationLinks } from './NavigationLinks'

export function Sidebar() {
  const { currentCertification } = useCertification()

  return (
    <aside className="fixed inset-y-0 left-0 z-30 hidden w-64 overflow-hidden bg-navy-900 lg:flex lg:flex-col">
      <div className="pointer-events-none absolute -left-20 top-24 h-64 w-64 rounded-full bg-blue-600/10 blur-3xl" />
      <div className="pointer-events-none absolute -right-16 bottom-16 h-48 w-48 rounded-full bg-sky-400/[0.07] blur-3xl" />

      <div className="relative flex h-[72px] items-center border-b border-white/[0.07] px-6">
        <Brand />
      </div>

      <div className="relative border-b border-white/[0.07] px-6 py-5">
        <p className="mb-3 text-[10px] font-semibold uppercase tracking-[0.18em] text-slate-600">
          Certificação ativa
        </p>
        <CertificationIdentity certification={currentCertification} />
      </div>

      <div className="relative flex-1 overflow-y-auto px-4 py-6">
        <p className="mb-3 px-3.5 text-[10px] font-semibold uppercase tracking-[0.18em] text-slate-600">
          Sua jornada
        </p>
        <NavigationLinks />
      </div>

      <div className="relative border-t border-white/[0.07] p-4">
        <Link
          to="/certifications"
          className="flex min-h-11 items-center gap-3 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-400 transition-colors hover:bg-white/[0.06] hover:text-white"
        >
          <ArrowLeftRight aria-hidden="true" className="h-[18px] w-[18px] text-slate-500" />
          Trocar certificação
        </Link>
      </div>
    </aside>
  )
}

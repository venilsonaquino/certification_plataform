import type { Certification } from '../../types/certification'
import { formatCertificationCode, getCertificationColor } from '../../lib/certificationVisuals'

interface CertificationIdentityProps {
  certification: Certification
  tone?: 'dark' | 'light'
  compact?: boolean
}

export function CertificationIdentity({
  certification,
  tone = 'dark',
  compact = false,
}: CertificationIdentityProps) {
  const primaryText = tone === 'dark' ? 'text-white' : 'text-slate-950'
  const secondaryText = tone === 'dark' ? 'text-slate-400' : 'text-slate-500'

  return (
    <div className="flex min-w-0 items-center gap-3">
      <span
        aria-hidden="true"
        className={[
          'h-2.5 w-2.5 shrink-0 rounded-full ring-4',
          tone === 'dark' ? 'ring-white/10' : 'ring-slate-200',
        ].join(' ')}
        style={{ backgroundColor: getCertificationColor(certification.code) }}
      />
      <div className="min-w-0">
        <p className={`truncate text-sm font-bold tracking-tight ${primaryText}`}>
          {formatCertificationCode(certification.code)}
        </p>
        {!compact && (
          <p className={`truncate text-xs font-medium ${secondaryText}`}>
            {certification.name}
          </p>
        )}
      </div>
    </div>
  )
}

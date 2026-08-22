import { Cloud } from 'lucide-react'

interface BrandProps {
  compact?: boolean
  tone?: 'dark' | 'light'
}

export function Brand({ compact = false, tone = 'dark' }: BrandProps) {
  return (
    <div className="flex min-w-0 items-center gap-3">
      <div className="relative grid h-10 w-10 shrink-0 place-items-center overflow-hidden rounded-xl bg-gradient-to-br from-sky-400 to-blue-600 text-white shadow-lg shadow-blue-950/30">
        <div className="absolute -right-3 -top-3 h-7 w-7 rounded-full bg-white/20" />
        <Cloud aria-hidden="true" className="relative h-5 w-5" strokeWidth={2.2} />
      </div>

      {!compact && (
        <div className="min-w-0">
          <p
            className={[
              'truncate text-sm font-semibold tracking-tight',
              tone === 'dark' ? 'text-white' : 'text-slate-950',
            ].join(' ')}
          >
            Certification
          </p>
          <p
            className={[
              'truncate text-xs font-medium',
              tone === 'dark' ? 'text-slate-400' : 'text-slate-500',
            ].join(' ')}
          >
            Academy
          </p>
        </div>
      )}
    </div>
  )
}

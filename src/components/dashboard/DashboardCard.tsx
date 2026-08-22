import type { LucideIcon } from 'lucide-react'
import type { ReactNode } from 'react'

interface DashboardCardProps {
  title: string
  value: string
  description: string
  icon: LucideIcon
  tone: 'blue' | 'cyan' | 'violet' | 'amber'
  footer?: ReactNode
}

const toneStyles = {
  blue: 'bg-blue-50 text-blue-600 ring-blue-100',
  cyan: 'bg-cyan-50 text-cyan-600 ring-cyan-100',
  violet: 'bg-violet-50 text-violet-600 ring-violet-100',
  amber: 'bg-amber-50 text-amber-600 ring-amber-100',
}

export function DashboardCard({
  title,
  value,
  description,
  icon: Icon,
  tone,
  footer,
}: DashboardCardProps) {
  return (
    <article className="group flex min-h-56 flex-col rounded-2xl border border-slate-200/80 bg-white p-6 shadow-card transition duration-200 hover:-translate-y-0.5 hover:border-slate-300/80 hover:shadow-lg hover:shadow-slate-200/50 sm:p-7">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-sm font-semibold text-slate-500">{title}</p>
          <p className="mt-4 text-2xl font-bold tracking-tight text-slate-900 sm:text-[28px]">
            {value}
          </p>
        </div>
        <div
          className={`grid h-11 w-11 shrink-0 place-items-center rounded-xl ring-1 ring-inset ${toneStyles[tone]}`}
        >
          <Icon aria-hidden="true" className="h-5 w-5" strokeWidth={2} />
        </div>
      </div>

      <p className="mt-2 text-sm leading-6 text-slate-500">{description}</p>

      {footer && <div className="mt-auto pt-6">{footer}</div>}
    </article>
  )
}

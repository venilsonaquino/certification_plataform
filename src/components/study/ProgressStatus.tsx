import { CheckCircle2, Circle, CircleDotDashed } from 'lucide-react'

import type { LessonProgressStatus } from '../../types/progress'

interface ProgressStatusProps {
  status: LessonProgressStatus
  showLabel?: boolean
}

const statusConfig = {
  not_started: {
    label: 'Não iniciada',
    icon: Circle,
    className: 'text-slate-400',
  },
  in_progress: {
    label: 'Em andamento',
    icon: CircleDotDashed,
    className: 'text-amber-600',
  },
  completed: {
    label: 'Concluída',
    icon: CheckCircle2,
    className: 'text-emerald-600',
  },
} satisfies Record<LessonProgressStatus, { label: string; icon: typeof Circle; className: string }>

export function ProgressStatus({ status, showLabel = true }: ProgressStatusProps) {
  const config = statusConfig[status]
  const Icon = config.icon

  return (
    <span className={`inline-flex items-center gap-1.5 text-xs font-semibold ${config.className}`}>
      <Icon aria-hidden="true" className="h-4 w-4 shrink-0" />
      {showLabel ? <span>{config.label}</span> : <span className="sr-only">{config.label}</span>}
    </span>
  )
}

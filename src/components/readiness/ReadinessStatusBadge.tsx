import type { GlobalReadinessClassification, ScopedReadinessClassification } from '../../types/readiness'
import { globalStatusLabels, scopedStatusLabels, statusTone } from '../../features/readiness/readinessPresentation'

interface ReadinessStatusBadgeProps {
  readonly status: GlobalReadinessClassification | ScopedReadinessClassification
  readonly global?: boolean
}

export function ReadinessStatusBadge({ status, global = false }: ReadinessStatusBadgeProps) {
  const label = global
    ? globalStatusLabels[status as GlobalReadinessClassification]
    : scopedStatusLabels[status as ScopedReadinessClassification]
  return (
    <span className={`inline-flex rounded-full border px-3 py-1 text-xs font-bold ${statusTone[status]}`}>
      {label}
    </span>
  )
}

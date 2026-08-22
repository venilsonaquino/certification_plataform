import { AlertCircle, LoaderCircle, RotateCcw } from 'lucide-react'

interface CertificationDataStateProps {
  title: string
  description?: string
  loading?: boolean
  onRetry?: () => void
}

export function CertificationDataState({
  title,
  description,
  loading = false,
  onRetry,
}: CertificationDataStateProps) {
  return (
    <div
      role={loading ? 'status' : 'alert'}
      className="rounded-2xl border border-slate-200/80 bg-white px-6 py-12 text-center shadow-card sm:px-8"
    >
      <div className="mx-auto grid h-12 w-12 place-items-center rounded-2xl bg-blue-50 text-blue-600">
        {loading ? (
          <LoaderCircle aria-hidden="true" className="h-5 w-5 animate-spin" />
        ) : (
          <AlertCircle aria-hidden="true" className="h-5 w-5" />
        )}
      </div>
      <h2 className="mt-5 text-lg font-bold text-slate-950">{title}</h2>
      {description && <p className="mx-auto mt-2 max-w-lg text-sm leading-6 text-slate-500">{description}</p>}
      {onRetry && (
        <button
          type="button"
          onClick={onRetry}
          className="mt-6 inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-blue-600 px-5 text-sm font-semibold text-white transition hover:bg-blue-700"
        >
          <RotateCcw aria-hidden="true" className="h-4 w-4" />
          Tentar novamente
        </button>
      )}
    </div>
  )
}

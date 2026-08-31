import { LoaderCircle } from 'lucide-react'

export function RouteLoadingState() {
  return (
    <section
      role="status"
      aria-live="polite"
      className="grid min-h-64 place-items-center rounded-2xl border border-slate-200 bg-white p-8 text-center shadow-card"
    >
      <div>
        <LoaderCircle aria-hidden="true" className="mx-auto h-7 w-7 animate-spin text-blue-600" />
        <p className="mt-3 text-sm font-semibold text-slate-600">Carregando página...</p>
      </div>
    </section>
  )
}

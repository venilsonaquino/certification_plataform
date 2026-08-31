import { AlertTriangle, RotateCcw } from 'lucide-react'
import { Component, type ErrorInfo, type ReactNode } from 'react'

interface AppErrorBoundaryProps {
  children: ReactNode
}

interface AppErrorBoundaryState {
  hasError: boolean
}

export class AppErrorBoundary extends Component<AppErrorBoundaryProps, AppErrorBoundaryState> {
  state: AppErrorBoundaryState = { hasError: false }

  static getDerivedStateFromError(): AppErrorBoundaryState {
    return { hasError: true }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    if (import.meta.env.DEV) {
      console.error('Falha inesperada ao renderizar a aplicação.', error, errorInfo)
    }
  }

  render() {
    if (!this.state.hasError) return this.props.children

    return (
      <main className="grid min-h-screen place-items-center bg-canvas px-4 py-10">
        <section className="w-full max-w-lg rounded-2xl border border-slate-200 bg-white p-7 text-center shadow-card sm:p-9">
          <span className="mx-auto grid h-12 w-12 place-items-center rounded-2xl bg-amber-50 text-amber-700">
            <AlertTriangle aria-hidden="true" className="h-6 w-6" />
          </span>
          <h1 className="mt-5 text-2xl font-bold text-slate-950">Algo inesperado aconteceu.</h1>
          <p className="mt-3 text-sm leading-6 text-slate-600">
            Seus dados permanecem preservados. Recarregue a página ou volte ao início para continuar.
          </p>
          <div className="mt-6 flex flex-col justify-center gap-3 sm:flex-row">
            <button
              type="button"
              onClick={() => window.location.reload()}
              className="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-blue-600 px-5 text-sm font-bold text-white hover:bg-blue-700"
            >
              <RotateCcw aria-hidden="true" className="h-4 w-4" />
              Recarregar
            </button>
            <a
              href="/"
              className="inline-flex min-h-11 items-center justify-center rounded-xl border border-slate-300 px-5 text-sm font-bold text-slate-700 hover:bg-slate-50"
            >
              Voltar ao início
            </a>
          </div>
        </section>
      </main>
    )
  }
}

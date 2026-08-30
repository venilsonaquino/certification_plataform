import { ArrowRight, BrainCircuit, LoaderCircle, RotateCcw } from 'lucide-react'

import { AZ900_PRACTICE_MOCK_CONFIGURATION } from '../../types/mockExam'
import type { MockExamAttempt } from '../../types/mockExam'

interface MockExamStartProps {
  activeAttempt: Pick<MockExamAttempt, 'id'> | null
  loading: boolean
  error: string | null
  hasHistory: boolean
  onStart: () => void
  onResume: (attemptId: string) => void
  onRetry: () => void
}

export function MockExamStart({
  activeAttempt,
  loading,
  error,
  hasHistory,
  onStart,
  onResume,
  onRetry,
}: MockExamStartProps) {
  return (
    <div className="mx-auto max-w-4xl">
      <header>
        <p className="text-sm font-bold text-blue-700">AZ-900 · prática completa</p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">
          AZ-900 Practice Mock Exam
        </h1>
        <p className="mt-3 max-w-2xl text-base leading-7 text-slate-600">
          Uma sessão de prática original da plataforma, alinhada aos três Domains do AZ-900.
          Não é um simulador oficial da Microsoft.
        </p>
      </header>

      <section className="mt-8 rounded-3xl border border-slate-200 bg-white p-6 shadow-card sm:p-8">
        <div className="grid gap-4 sm:grid-cols-2">
          {[
            ['40 Questions', 'Selecionadas e congeladas quando você inicia.'],
            [`${AZ900_PRACTICE_MOCK_CONFIGURATION.timeLimitMinutes} minutes`, 'Practice Mock Time Limit da plataforma; o tempo continua após fechar a página.'],
            ['Três Domains', 'Distribuição curricular e dificuldade balanceadas.'],
            ['Sem feedback imediato', 'O resultado aparece somente depois do envio.'],
            ['Respostas editáveis', 'Você pode voltar e alterar antes de finalizar.'],
          ].map(([title, description]) => (
            <div key={title} className="rounded-2xl bg-slate-50 p-4">
              <p className="font-bold text-slate-950">{title}</p>
              <p className="mt-1 text-sm leading-6 text-slate-600">{description}</p>
            </div>
          ))}
        </div>

        {error && (
          <div role="alert" className="mt-6 rounded-xl border border-rose-200 bg-rose-50 p-4">
            <p className="font-semibold text-rose-800">{error}</p>
            <button type="button" onClick={onRetry} className="mt-3 inline-flex min-h-11 items-center gap-2 text-sm font-bold text-rose-800">
              <RotateCcw className="h-4 w-4" aria-hidden="true" />Tentar novamente
            </button>
          </div>
        )}

        <div className="mt-7 flex flex-col gap-3 sm:flex-row">
          {activeAttempt ? (
            <button type="button" disabled={loading} onClick={() => onResume(activeAttempt.id)} className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-blue-600 px-6 text-sm font-bold text-white hover:bg-blue-700 disabled:cursor-wait disabled:opacity-60">
              {loading ? <LoaderCircle className="h-4 w-4 animate-spin" aria-hidden="true" /> : <ArrowRight className="h-4 w-4" aria-hidden="true" />}
              {loading ? 'Loading your mock exam...' : 'Resume Mock'}
            </button>
          ) : (
            <button type="button" disabled={loading} onClick={onStart} className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-blue-600 px-6 text-sm font-bold text-white hover:bg-blue-700 disabled:cursor-wait disabled:opacity-60">
              {loading ? <LoaderCircle className="h-4 w-4 animate-spin" aria-hidden="true" /> : <BrainCircuit className="h-4 w-4" aria-hidden="true" />}
              {loading ? 'Preparing your mock exam...' : hasHistory ? 'Start New Mock' : 'Start Mock'}
            </button>
          )}
        </div>
      </section>
    </div>
  )
}

import { BookCheck, Clock3, ListTodo, type LucideIcon } from 'lucide-react'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { useCertification } from '../hooks/useCertification'
import { useCertificationProgress } from '../hooks/useCertificationProgress'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { formatEstimatedMinutes } from '../lib/progressUtils'

export function ProgressPage() {
  const { currentCertification } = useCertification()
  const { summary, loading, error, retry } = useCertificationProgress()
  const certificationCode = formatCertificationCode(currentCertification.code)

  return (
    <div>
      <header className="max-w-3xl">
        <p className="text-sm font-semibold text-blue-600">{certificationCode}</p>
        <h1 className="mt-2 text-balance text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">
          Progresso
        </h1>
        <p className="mt-3 text-base leading-7 text-slate-500">
          Visão geral do seu avanço em {currentCertification.name}.
        </p>
      </header>

      {loading && (
        <div className="mt-8 lg:mt-10">
          <CertificationDataState title="Calculando seu progresso..." loading />
        </div>
      )}
      {!loading && error && (
        <div className="mt-8 lg:mt-10">
          <CertificationDataState
            title="Não foi possível carregar o progresso."
            description={error}
            onRetry={retry}
          />
        </div>
      )}

      {!loading && !error && (
        <>
          <section className="mt-8 overflow-hidden rounded-2xl border border-blue-200 bg-gradient-to-br from-blue-700 to-sky-600 p-6 text-white shadow-lg shadow-blue-900/10 sm:p-8 lg:mt-10">
            <p className="text-xs font-bold uppercase tracking-[0.16em] text-blue-100">Overall</p>
            <div className="mt-3 flex flex-col gap-5 sm:flex-row sm:items-end sm:justify-between">
              <div>
                <p className="text-5xl font-bold tracking-tight sm:text-6xl">
                  {summary.percentage}%
                </p>
                <p className="mt-2 text-sm font-medium text-blue-100 sm:text-base">
                  {summary.completedCount} / {summary.totalCount} aulas
                </p>
              </div>
              {summary.isCompleted && (
                <div className="rounded-xl bg-white/10 px-4 py-3 ring-1 ring-inset ring-white/20">
                  <p className="font-bold">Parabéns!</p>
                  <p className="mt-1 text-sm text-blue-100">
                    Você concluiu todo o conteúdo da {certificationCode}.
                  </p>
                </div>
              )}
            </div>
            <div className="mt-6 h-2.5 overflow-hidden rounded-full bg-white/20">
              <div
                className="h-full rounded-full bg-white transition-[width]"
                style={{ width: `${summary.percentage}%` }}
              />
            </div>
          </section>

          <section aria-label="Números do progresso" className="mt-5 grid gap-4 sm:grid-cols-3">
            <ProgressStat
              icon={BookCheck}
              label="Aulas concluídas"
              value={String(summary.completedCount)}
            />
            <ProgressStat
              icon={ListTodo}
              label="Aulas restantes"
              value={String(summary.remainingCount)}
            />
            <ProgressStat
              icon={Clock3}
              label="Tempo estimado concluído"
              value={formatEstimatedMinutes(summary.completedMinutes)}
            />
          </section>

          <section aria-labelledby="domain-progress-title" className="mt-8 lg:mt-10">
            <h2
              id="domain-progress-title"
              className="text-xl font-bold tracking-tight text-slate-950"
            >
              Progresso por domínio
            </h2>
            <div className="mt-5 space-y-4">
              {summary.domainProgress.map((domain) => (
                <article
                  key={domain.domainId}
                  className="rounded-2xl border border-slate-200/80 bg-white p-5 shadow-card sm:p-6"
                >
                  <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between sm:gap-5">
                    <div>
                      <h3 className="font-bold leading-6 text-slate-900">{domain.title}</h3>
                      <p className="mt-1 text-sm text-slate-500">
                        {domain.completedCount} de {domain.totalCount} aulas concluídas
                      </p>
                    </div>
                    <p className="text-2xl font-bold tracking-tight text-blue-700">
                      {domain.percentage}%
                    </p>
                  </div>
                  <div className="mt-4 h-2 overflow-hidden rounded-full bg-slate-100">
                    <div
                      className="h-full rounded-full bg-gradient-to-r from-blue-600 to-sky-400 transition-[width]"
                      style={{ width: `${domain.percentage}%` }}
                    />
                  </div>
                </article>
              ))}
            </div>
          </section>
        </>
      )}
    </div>
  )
}

interface ProgressStatProps {
  icon: LucideIcon
  label: string
  value: string
}

function ProgressStat({ icon: Icon, label, value }: ProgressStatProps) {
  return (
    <article className="rounded-2xl border border-slate-200/80 bg-white p-5 shadow-card">
      <div className="grid h-9 w-9 place-items-center rounded-xl bg-blue-50 text-blue-600">
        <Icon aria-hidden="true" className="h-4 w-4" />
      </div>
      <p className="mt-4 text-2xl font-bold tracking-tight text-slate-950">{value}</p>
      <p className="mt-1 text-sm text-slate-500">{label}</p>
    </article>
  )
}

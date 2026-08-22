import { BookOpen, CalendarCheck2, ChartNoAxesColumnIncreasing, TimerReset } from 'lucide-react'

import { DashboardCard } from '../components/dashboard/DashboardCard'
import { useCertification } from '../hooks/useCertification'
import { formatCertificationCode } from '../lib/certificationVisuals'

export function DashboardPage() {
  const { currentCertification } = useCertification()

  return (
    <div>
      <div className="max-w-2xl">
        <p className="text-sm font-semibold text-blue-600">
          {formatCertificationCode(currentCertification.code)}
        </p>
        <h1 className="mt-2 text-balance text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">
          Dashboard
        </h1>
        <p className="mt-3 text-base leading-7 text-slate-500">
          Sua jornada em {currentCertification.name} começa aqui.
        </p>
      </div>

      <section aria-label="Resumo de estudos" className="mt-8 grid gap-5 md:grid-cols-2 lg:mt-10 lg:gap-6">
        <DashboardCard
          title="Progresso geral"
          value="0% concluído"
          description={`Visão inicial da sua jornada ${formatCertificationCode(currentCertification.code)}.`}
          icon={ChartNoAxesColumnIncreasing}
          tone="blue"
          footer={
            <div>
              <div
                role="progressbar"
                aria-label="Progresso geral"
                aria-valuemin={0}
                aria-valuemax={100}
                aria-valuenow={0}
                className="h-2 overflow-hidden rounded-full bg-slate-100"
              >
                <div className="h-full w-0 rounded-full bg-gradient-to-r from-blue-600 to-sky-400" />
              </div>
              <p className="mt-2 text-xs font-medium text-slate-400">Exemplo estático</p>
            </div>
          }
        />
        <DashboardCard
          title="Estudo de hoje"
          value="Conceitos de nuvem"
          description={`Um ponto de partida para os estudos de ${formatCertificationCode(currentCertification.code)}.`}
          icon={BookOpen}
          tone="cyan"
          footer={<p className="text-xs font-medium text-slate-400">Conteúdo de exemplo</p>}
        />
        <DashboardCard
          title="Sequência de estudos"
          value="0 dias"
          description="Sua sequência será exibida neste espaço."
          icon={CalendarCheck2}
          tone="violet"
          footer={<p className="text-xs font-medium text-slate-400">Pronto para começar</p>}
        />
        <DashboardCard
          title="Último simulado"
          value="Ainda não realizado"
          description="O resultado mais recente aparecerá aqui."
          icon={TimerReset}
          tone="amber"
          footer={<p className="text-xs font-medium text-slate-400">Nenhum resultado</p>}
        />
      </section>
    </div>
  )
}

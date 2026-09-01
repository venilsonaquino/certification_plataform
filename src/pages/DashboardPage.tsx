import {
  ArrowRight,
  BookOpen,
  BrainCircuit,
  CalendarCheck2,
  ChartNoAxesColumnIncreasing,
  Clock3,
  History,
  Layers3,
} from 'lucide-react'
import { Link } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { DashboardCard } from '../components/dashboard/DashboardCard'
import { useCertification } from '../hooks/useCertification'
import { useCertificationProgress } from '../hooks/useCertificationProgress'
import { useFlashcardReviewOverview } from '../hooks/useFlashcardReviewOverview'
import { useStudyProgression } from '../hooks/useStudyProgression'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { formatEstimatedMinutes, formatLastActivityDate } from '../lib/progressUtils'
import { certificationRoute, flashcardReviewRoute, lessonRoute, topicQuizRoute } from '../lib/routes'

export function DashboardPage() {
  const { currentCertification } = useCertification()
  const { domains, progressByLessonId, summary, loading, error, retry } = useCertificationProgress()
  const flashcardReview = useFlashcardReviewOverview(currentCertification.id)
  const certificationCode = formatCertificationCode(currentCertification.code)
  const studyProgression = useStudyProgression(currentCertification.id, domains, progressByLessonId)
  const nextAction = studyProgression.progression.nextAction
  const nextLesson = nextAction?.kind === 'lesson' ? nextAction.lesson : null
  const nextCheckpoint = nextAction?.kind === 'checkpoint' ? nextAction.checkpoint : null
  const lastActivity = summary.lastActivity
  const studyTodayRoute = certificationRoute(currentCertification.code, 'study-today')

  return (
    <div>
      <header className="max-w-2xl">
        <p className="text-sm font-semibold text-blue-600">{certificationCode}</p>
        <h1 className="mt-2 text-balance text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">
          Dashboard
        </h1>
        <p className="mt-3 text-base leading-7 text-slate-500">
          Acompanhe sua jornada em {currentCertification.name}.
        </p>
      </header>

      {(loading || studyProgression.loading) && (
        <div className="mt-8 lg:mt-10">
          <CertificationDataState title="Carregando seu progresso..." loading />
        </div>
      )}
      {!loading && !studyProgression.loading && (error || studyProgression.error) && (
        <div className="mt-8 lg:mt-10">
          <CertificationDataState
            title="Não foi possível carregar o Dashboard."
            description={error ?? studyProgression.error ?? undefined}
            onRetry={() => { retry(); void studyProgression.retry() }}
          />
        </div>
      )}

      {!loading && !studyProgression.loading && !error && !studyProgression.error && (
        <>
          {studyProgression.progression.journeyCompleted && (
            <section className="mt-8 rounded-2xl border border-emerald-200 bg-emerald-50 p-6 sm:p-7 lg:mt-10">
              <p className="text-sm font-bold uppercase tracking-[0.14em] text-emerald-700">
                100% concluído
              </p>
              <h2 className="mt-2 text-2xl font-bold text-emerald-950">Parabéns!</h2>
              <p className="mt-2 text-sm leading-6 text-emerald-800 sm:text-base">
                Você concluiu todo o conteúdo da {certificationCode}.
              </p>
            </section>
          )}

          {!studyProgression.progression.journeyCompleted && (
            <section className="mt-8 overflow-hidden rounded-2xl border border-blue-200 bg-gradient-to-r from-blue-700 to-sky-600 p-6 text-white shadow-lg shadow-blue-200/50 sm:flex sm:items-center sm:justify-between sm:gap-6 sm:p-7 lg:mt-10">
              <div className="flex items-start gap-4">
                <div className="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-white/15 ring-1 ring-inset ring-white/20">
                  <CalendarCheck2 aria-hidden="true" className="h-5 w-5" />
                </div>
                <div>
                  <p className="text-sm font-semibold text-blue-100">Estudo do Dia</p>
                  <h2 className="mt-1 text-xl font-bold">
                    Uma sequência de aulas para cerca de 30 minutos
                  </h2>
                  <p className="mt-2 text-sm leading-6 text-blue-100">
                    Recomendada a partir do seu progresso atual na {certificationCode}.
                  </p>
                </div>
              </div>
              <Link
                to={studyTodayRoute}
                className="mt-5 inline-flex min-h-11 shrink-0 items-center justify-center gap-2 rounded-xl bg-white px-5 text-sm font-bold text-blue-700 transition hover:bg-blue-50 sm:mt-0"
              >
                {lastActivity ? 'Continuar estudo de hoje' : 'Começar estudo de hoje'}
                <ArrowRight aria-hidden="true" className="h-4 w-4" />
              </Link>
            </section>
          )}

          <section
            aria-label="Resumo de estudos"
            className="mt-8 grid gap-5 md:grid-cols-2 lg:mt-10 lg:gap-6"
          >
            <DashboardCard
              title="Progresso geral"
              value={`${summary.percentage}%`}
              description={`${summary.completedCount} de ${summary.totalCount} aulas concluídas · ${summary.remainingCount} restantes`}
              icon={ChartNoAxesColumnIncreasing}
              tone="blue"
              footer={
                <div>
                  <div
                    role="progressbar"
                    aria-label="Progresso geral"
                    aria-valuemin={0}
                    aria-valuemax={100}
                    aria-valuenow={summary.percentage}
                    className="h-2 overflow-hidden rounded-full bg-slate-100"
                  >
                    <div
                      className="h-full rounded-full bg-gradient-to-r from-blue-600 to-sky-400 transition-[width]"
                      style={{ width: `${summary.percentage}%` }}
                    />
                  </div>
                  <p className="mt-2 text-xs font-semibold text-slate-400">{certificationCode}</p>
                </div>
              }
            />

            <DashboardCard
              title={nextCheckpoint ? 'Próxima etapa' : 'Próxima aula'}
              value={nextLesson?.lesson.title ?? nextCheckpoint?.topic.title ?? 'Trilha concluída'}
              description={
                nextLesson
                  ? `${nextLesson.topic.title} · ${nextLesson.lesson.estimatedMinutes ?? 0} min`
                  : nextCheckpoint
                    ? `Checkpoint do Tópico · ${nextCheckpoint.status === 'in_progress' ? 'em andamento' : 'disponível'}`
                    : `Você finalizou a trilha publicada da ${certificationCode}.`
              }
              icon={nextCheckpoint ? BrainCircuit : BookOpen}
              tone="cyan"
              footer={
                nextLesson ? (
                  <Link
                    to={lessonRoute(currentCertification.code, nextLesson.lesson.slug)}
                    className="inline-flex min-h-11 items-center justify-center rounded-xl bg-blue-600 px-5 text-sm font-semibold text-white transition hover:bg-blue-700"
                  >
                    Continuar estudando
                  </Link>
                ) : nextCheckpoint ? (
                  <Link
                    to={topicQuizRoute(currentCertification.code, nextCheckpoint.topic.id)}
                    className="inline-flex min-h-11 items-center justify-center rounded-xl bg-violet-700 px-5 text-sm font-semibold text-white transition hover:bg-violet-800"
                  >
                    {nextCheckpoint.status === 'in_progress' ? 'Continuar Checkpoint' : 'Fazer Checkpoint'}
                  </Link>
                ) : undefined
              }
            />

            <DashboardCard
              title="Última atividade"
              value={lastActivity?.lesson.title ?? 'Nenhuma atividade'}
              description={
                lastActivity?.progress.lastAccessedAt
                  ? `${formatLastActivityDate(lastActivity.progress.lastAccessedAt)} · ${lastActivity.topic.title}`
                  : 'Comece a primeira aula para registrar sua atividade.'
              }
              icon={History}
              tone="violet"
            />

            <DashboardCard
              title="Tempo estudado estimado"
              value={formatEstimatedMinutes(summary.completedMinutes)}
              description="Soma da duração estimada das aulas concluídas; não representa tempo real de sessão."
              icon={Clock3}
              tone="amber"
            />

            <DashboardCard
              title="Revisão de Flashcards"
              value={flashcardReview.loading ? 'Calculando...' : `${flashcardReview.overview?.queueCount ?? 0} pendentes`}
              description={flashcardReview.error
                ? 'Não foi possível carregar sua fila de revisão.'
                : 'Cards vencidos e novos da certificação atual, priorizados para hoje.'}
              icon={Layers3}
              tone="violet"
              footer={flashcardReview.overview && flashcardReview.overview.queueCount > 0 ? (
                <Link to={flashcardReviewRoute(currentCertification.code)} className="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-violet-700 px-5 text-sm font-semibold text-white hover:bg-violet-800">Revisar agora<ArrowRight className="h-4 w-4" /></Link>
              ) : undefined}
            />
          </section>
        </>
      )}
    </div>
  )
}

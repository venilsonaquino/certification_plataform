import { BrainCircuit, CalendarCheck2, CheckCircle2, Clock3, Sparkles } from 'lucide-react'
import { useMemo } from 'react'
import { Link } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { DailyLessonCard } from '../components/studyToday/DailyLessonCard'
import { DEFAULT_DAILY_STUDY_MINUTES } from '../features/studyToday/constants'
import { buildDailyStudyPlan } from '../features/studyToday/studyTodayUtils'
import { useCertification } from '../hooks/useCertification'
import { useCertificationProgress } from '../hooks/useCertificationProgress'
import { useStudyProgression } from '../hooks/useStudyProgression'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { certificationRoute, topicQuizRoute } from '../lib/routes'

export function StudyTodayPage() {
  const { currentCertification } = useCertification()
  const { domains, progressByLessonId, summary, loading, error, retry } =
    useCertificationProgress()
  const certificationCode = formatCertificationCode(currentCertification.code)
  const studyTodayRoute = certificationRoute(currentCertification.code, 'study-today')
  const studyRoute = certificationRoute(currentCertification.code, 'study')
  const reviewRoute = certificationRoute(currentCertification.code, 'review')
  const examsRoute = certificationRoute(currentCertification.code, 'exams')
  const studyProgression = useStudyProgression(
    currentCertification.id,
    domains,
    progressByLessonId,
  )
  const plan = useMemo(
    () => buildDailyStudyPlan(domains, progressByLessonId, studyProgression.progression),
    [domains, progressByLessonId, studyProgression.progression],
  )
  const pageLoading = loading || studyProgression.loading
  const pageError = error ?? studyProgression.error
  const nextCheckpoint = studyProgression.progression.nextAction?.kind === 'checkpoint'
    ? studyProgression.progression.nextAction.checkpoint
    : null

  return (
    <div className="mx-auto max-w-5xl">
      <header className="rounded-3xl bg-gradient-to-br from-slate-950 via-blue-950 to-blue-800 px-6 py-8 text-white shadow-xl shadow-blue-950/10 sm:px-8 sm:py-10">
        <div className="flex flex-col gap-6 sm:flex-row sm:items-end sm:justify-between">
          <div className="max-w-2xl">
            <div className="flex items-center gap-2 text-sm font-semibold text-sky-300">
              <CalendarCheck2 aria-hidden="true" className="h-5 w-5" />
              {certificationCode}
            </div>
            <h1 className="mt-3 text-balance text-3xl font-bold tracking-tight sm:text-4xl">
              Estudo do Dia
            </h1>
            <p className="mt-3 max-w-xl text-sm leading-6 text-blue-100 sm:text-base">
              Uma sequência objetiva de aulas baseada no ponto atual da sua trilha.
            </p>
          </div>
          <div className="flex shrink-0 items-center gap-3 rounded-2xl bg-white/10 px-4 py-3 ring-1 ring-inset ring-white/15 backdrop-blur">
            <Clock3 aria-hidden="true" className="h-5 w-5 text-sky-300" />
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.12em] text-blue-200">Meta</p>
              <p className="text-lg font-bold">~{DEFAULT_DAILY_STUDY_MINUTES} min</p>
            </div>
          </div>
        </div>
      </header>

      {pageLoading && (
        <div className="mt-8">
          <CertificationDataState title="Preparando seu estudo de hoje..." loading />
        </div>
      )}

      {!pageLoading && pageError && (
        <div className="mt-8">
          <CertificationDataState
            title="Não foi possível preparar o estudo de hoje."
            description={pageError}
            onRetry={() => { retry(); void studyProgression.retry() }}
          />
        </div>
      )}

      {!pageLoading && !pageError && studyProgression.progression.journeyCompleted && (
        <section className="mt-8 rounded-2xl border border-emerald-200 bg-emerald-50 p-7 text-center sm:p-10">
          <CheckCircle2 aria-hidden="true" className="mx-auto h-12 w-12 text-emerald-600" />
          <h2 className="mt-4 text-2xl font-bold text-emerald-950">Parabéns!</h2>
          <p className="mx-auto mt-2 max-w-xl text-sm leading-6 text-emerald-800 sm:text-base">
            Você concluiu todo o conteúdo publicado da {certificationCode}. Não há novas aulas para sugerir.
          </p>
          <div className="mt-6 flex flex-col justify-center gap-3 sm:flex-row">
            <Link
              to={examsRoute}
              className="inline-flex min-h-11 items-center justify-center rounded-xl bg-emerald-700 px-5 text-sm font-semibold text-white transition hover:bg-emerald-800"
            >
              Fazer Practice Mock
            </Link>
            <Link
              to={reviewRoute}
              className="inline-flex min-h-11 items-center justify-center rounded-xl border border-emerald-300 bg-white px-5 text-sm font-semibold text-emerald-800 transition hover:bg-emerald-100"
            >
              Revisar pontos de atenção
            </Link>
            <Link
              to={studyRoute}
              className="inline-flex min-h-11 items-center justify-center rounded-xl px-5 text-sm font-semibold text-emerald-800 transition hover:bg-emerald-100"
            >
              Ver trilha concluída
            </Link>
          </div>
        </section>
      )}

      {!pageLoading && !pageError && !studyProgression.progression.journeyCompleted && nextCheckpoint && (
        <section className="mt-8 rounded-2xl border border-violet-200 bg-violet-50 p-6 sm:flex sm:items-center sm:justify-between sm:gap-6 sm:p-7">
          <div className="flex items-start gap-4">
            <div className="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-violet-100 text-violet-700"><BrainCircuit aria-hidden="true" className="h-5 w-5" /></div>
            <div>
              <p className="text-sm font-bold text-violet-700">Próxima etapa da trilha</p>
              <h2 className="mt-1 text-xl font-bold text-slate-950">Checkpoint: {nextCheckpoint.topic.title}</h2>
              <p className="mt-2 text-sm leading-6 text-slate-600">{nextCheckpoint.status === 'in_progress' ? `${nextCheckpoint.activeAnsweredCount} de ${nextCheckpoint.activeTotalQuestions ?? nextCheckpoint.targetQuestionCount} questões respondidas.` : `As aulas deste tópico foram concluídas. Responda ${nextCheckpoint.targetQuestionCount} questões para liberar o próximo tópico.`}</p>
            </div>
          </div>
          <Link to={topicQuizRoute(currentCertification.code, nextCheckpoint.topic.id)} className="mt-5 inline-flex min-h-11 shrink-0 items-center justify-center rounded-xl bg-violet-700 px-5 text-sm font-bold text-white hover:bg-violet-800 sm:mt-0">{nextCheckpoint.status === 'in_progress' ? 'Continuar Checkpoint' : 'Fazer Checkpoint'}</Link>
        </section>
      )}

      {!pageLoading && !pageError && !studyProgression.progression.journeyCompleted && !nextCheckpoint && plan.lessons.length > 0 && (
        <section className="mt-8">
          <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p className="flex items-center gap-2 text-sm font-bold text-blue-700">
                <Sparkles aria-hidden="true" className="h-4 w-4" />
                {summary.completedCount === 0
                  ? 'Seu estudo começa aqui'
                  : plan.startsWithInProgress
                    ? 'Continue de onde parou'
                    : 'Próximas aulas da trilha'}
              </p>
              <h2 className="mt-2 text-2xl font-bold tracking-tight text-slate-950">
                Plano recomendado
              </h2>
            </div>
            <p className="text-sm font-semibold text-slate-500">
              {plan.lessons.length} {plan.lessons.length === 1 ? 'aula' : 'aulas'} · cerca de{' '}
              {plan.totalMinutes} min
            </p>
          </div>

          <div className="mt-5 grid gap-4">
            {plan.lessons.map((item, index) => (
              <DailyLessonCard
                key={item.lesson.id}
                certificationCode={currentCertification.code}
                item={item}
                position={index + 1}
                continuing={index === 0 && plan.startsWithInProgress}
                returnTo={studyTodayRoute}
              />
            ))}
          </div>
        </section>
      )}

      {!pageLoading && !pageError && !studyProgression.progression.journeyCompleted && !nextCheckpoint && plan.lessons.length === 0 && (
        <div className="mt-8">
          <CertificationDataState
            title="Nenhuma aula disponível."
            description="A certificação não possui aulas publicadas para sugerir no momento."
          />
        </div>
      )}
    </div>
  )
}

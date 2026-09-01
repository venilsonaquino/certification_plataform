import { BookOpenText, BrainCircuit, CheckCircle2, LockKeyhole, TriangleAlert } from 'lucide-react'
import { Link } from 'react-router-dom'

import { topicQuizRoute } from '../../lib/routes'
import type { TopicWithLessons } from '../../types/content'
import type { UserLessonProgress } from '../../types/progress'
import type { LessonProgressionState, TopicCheckpointState } from '../../lib/studyProgression'
import { LessonCard } from './LessonCard'

interface TopicSectionProps {
  certificationCode: string
  domainNumber: number
  topic: TopicWithLessons
  topicNumber: number
  progressByLessonId: ReadonlyMap<string, UserLessonProgress>
  checkpoint?: TopicCheckpointState
  lessonStateById: ReadonlyMap<string, LessonProgressionState>
}

export function TopicSection({
  certificationCode,
  domainNumber,
  topic,
  topicNumber,
  progressByLessonId,
  checkpoint,
  lessonStateById,
}: TopicSectionProps) {
  const completedLessons = topic.lessons.filter(
    (lesson) => progressByLessonId.get(lesson.id)?.status === 'completed',
  ).length

  return (
    <section id={`topic-${topic.id}`} className="scroll-mt-28 rounded-2xl bg-slate-50/80 p-4 sm:p-5">
      <div className="flex items-start gap-3">
        <div className="mt-0.5 grid h-8 w-8 shrink-0 place-items-center rounded-lg bg-white text-blue-600 shadow-sm ring-1 ring-slate-200/80">
          <BookOpenText aria-hidden="true" className="h-4 w-4" />
        </div>
        <div className="min-w-0 flex-1">
          <p className="text-xs font-bold uppercase tracking-[0.14em] text-slate-400">
            Tópico {domainNumber}.{topicNumber}
          </p>
          <h4 className="mt-1 text-base font-bold text-slate-900">{topic.title}</h4>
          {topic.description && (
            <p className="mt-1.5 text-sm leading-6 text-slate-500">{topic.description}</p>
          )}
          <p className="mt-2 text-xs font-semibold text-blue-700">
            {completedLessons} / {topic.lessons.length} aulas concluídas
          </p>
        </div>
      </div>

      {topic.lessons.length === 0 ? (
        <p className="mt-4 text-sm text-slate-400">Nenhuma aula publicada neste tópico.</p>
      ) : (
        <ol className="mt-4 grid gap-3 md:grid-cols-2">
          {topic.lessons.map((lesson) => (
            <li key={lesson.id}>
              <LessonCard
                certificationCode={certificationCode}
                lesson={lesson}
                progress={progressByLessonId.get(lesson.id)}
                progression={lessonStateById.get(lesson.id)}
              />
            </li>
          ))}
        </ol>
      )}

      {checkpoint && (
        <div className="mt-4 border-t border-slate-200 pt-4">
          <div className={`rounded-xl border p-4 ${checkpoint.status === 'locked' ? 'border-slate-200 bg-slate-100/80' : checkpoint.status === 'unavailable' ? 'border-amber-200 bg-amber-50' : checkpoint.status === 'completed' ? 'border-emerald-200 bg-emerald-50' : 'border-violet-200 bg-white'}`}>
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <div className="flex min-w-0 items-start gap-3">
                {checkpoint.status === 'locked' ? <LockKeyhole aria-hidden="true" className="mt-0.5 h-5 w-5 shrink-0 text-slate-500" /> : checkpoint.status === 'unavailable' ? <TriangleAlert aria-hidden="true" className="mt-0.5 h-5 w-5 shrink-0 text-amber-700" /> : checkpoint.status === 'completed' ? <CheckCircle2 aria-hidden="true" className="mt-0.5 h-5 w-5 shrink-0 text-emerald-700" /> : <BrainCircuit aria-hidden="true" className="mt-0.5 h-5 w-5 shrink-0 text-violet-700" />}
                <div>
                  <h5 className="text-sm font-bold text-slate-900">Checkpoint do Tópico</h5>
                  <p className="mt-1 text-xs leading-5 text-slate-600">
                    {checkpoint.status === 'locked'
                      ? `Conclua as ${checkpoint.remainingLessonCount} ${checkpoint.remainingLessonCount === 1 ? 'aula restante' : 'aulas restantes'} deste tópico para liberar o checkpoint.`
                      : checkpoint.status === 'unavailable'
                        ? 'Checkpoint indisponível: este tópico precisa de aulas e questões publicadas.'
                        : checkpoint.status === 'in_progress'
                          ? `${checkpoint.activeAnsweredCount} de ${checkpoint.activeTotalQuestions ?? checkpoint.targetQuestionCount} questões respondidas.`
                          : checkpoint.status === 'completed'
                            ? `Concluído · último resultado: ${Math.round(checkpoint.lastScorePercentage ?? 0)}%.`
                            : `${checkpoint.targetQuestionCount} questões nesta tentativa.`}
                  </p>
                </div>
              </div>
              {checkpoint.available && (
                <Link
                  to={topicQuizRoute(certificationCode, topic.id)}
                  className="inline-flex min-h-10 shrink-0 items-center justify-center gap-2 rounded-lg bg-violet-700 px-4 text-xs font-bold text-white transition hover:bg-violet-800"
                >
                  <BrainCircuit aria-hidden="true" className="h-4 w-4" />
                  {checkpoint.status === 'in_progress' ? 'Continuar Checkpoint' : checkpoint.status === 'completed' ? 'Refazer Checkpoint' : 'Fazer Checkpoint'}
                </Link>
              )}
            </div>
          </div>
        </div>
      )}
    </section>
  )
}

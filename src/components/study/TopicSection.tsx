import { BookOpenText, BrainCircuit } from 'lucide-react'
import { Link } from 'react-router-dom'

import { topicQuizRoute } from '../../lib/routes'
import type { TopicWithLessons } from '../../types/content'
import type { UserLessonProgress } from '../../types/progress'
import type { TopicQuizSummary } from '../../types/quiz'
import { LessonCard } from './LessonCard'

interface TopicSectionProps {
  certificationCode: string
  domainNumber: number
  topic: TopicWithLessons
  topicNumber: number
  progressByLessonId: ReadonlyMap<string, UserLessonProgress>
  quizSummary?: TopicQuizSummary
}

export function TopicSection({
  certificationCode,
  domainNumber,
  topic,
  topicNumber,
  progressByLessonId,
  quizSummary,
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
          {quizSummary && quizSummary.questionCount > 0 && (
            <div className="mt-3 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-xs font-semibold text-violet-700">
                {quizSummary.questionCount} questões disponíveis
                {quizSummary.activeAttemptId
                  ? ` · ${quizSummary.activeAnsweredCount} de ${quizSummary.activeTotalQuestions ?? quizSummary.questionCount} respondidas`
                  : quizSummary.lastScorePercentage !== null
                    ? ` · Último resultado: ${Math.round(quizSummary.lastScorePercentage)}%`
                    : ''}
              </p>
              <Link
                to={topicQuizRoute(certificationCode, topic.id)}
                className="inline-flex min-h-10 items-center justify-center gap-2 rounded-lg bg-violet-700 px-4 text-xs font-bold text-white transition hover:bg-violet-800"
              >
                <BrainCircuit className="h-4 w-4" />
                {quizSummary.activeAttemptId ? 'Continuar Quiz' : 'Fazer Quiz do Tópico'}
              </Link>
            </div>
          )}
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
              />
            </li>
          ))}
        </ol>
      )}
    </section>
  )
}

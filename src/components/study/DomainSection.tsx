import { ChevronDown, Layers3 } from 'lucide-react'

import type { DomainWithTopics } from '../../types/content'
import type { UserLessonProgress } from '../../types/progress'
import type { TopicQuizSummary } from '../../types/quiz'
import { TopicSection } from './TopicSection'

interface DomainSectionProps {
  certificationCode: string
  domain: DomainWithTopics
  domainNumber: number
  progressByLessonId: ReadonlyMap<string, UserLessonProgress>
  topicQuizSummaryById: ReadonlyMap<string, TopicQuizSummary>
}

export function DomainSection({
  certificationCode,
  domain,
  domainNumber,
  progressByLessonId,
  topicQuizSummaryById,
}: DomainSectionProps) {
  const lessons = domain.topics.flatMap((topic) => topic.lessons)
  const completedLessons = lessons.filter(
    (lesson) => progressByLessonId.get(lesson.id)?.status === 'completed',
  ).length

  return (
    <details
      id={`domain-${domain.id}`}
      open
      className="group scroll-mt-28 overflow-hidden rounded-2xl border border-slate-200/80 bg-white shadow-card"
    >
      <summary className="flex cursor-pointer list-none items-start justify-between gap-4 px-5 py-5 marker:content-none sm:px-7 sm:py-6 [&::-webkit-details-marker]:hidden">
        <div className="flex min-w-0 items-start gap-3 sm:gap-4">
          <div className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-blue-50 text-blue-600">
            <Layers3 aria-hidden="true" className="h-5 w-5" />
          </div>
          <div className="min-w-0">
            <p className="text-xs font-bold uppercase tracking-[0.16em] text-blue-600">
              Domínio {domainNumber}
            </p>
            <h3 className="mt-1.5 text-lg font-bold leading-6 text-slate-950 sm:text-xl">
              {domain.title}
            </h3>
            {domain.description && (
              <p className="mt-2 hidden text-sm leading-6 text-slate-500 sm:block">
                {domain.description}
              </p>
            )}
            <p className="mt-2 text-xs font-semibold text-blue-700 sm:text-sm">
              {completedLessons} / {lessons.length} concluídas
            </p>
          </div>
        </div>
        <div className="flex shrink-0 items-center gap-3">
          {domain.examWeightMin !== null && domain.examWeightMax !== null && (
            <span className="hidden rounded-full bg-slate-100 px-3 py-1.5 text-xs font-semibold text-slate-600 sm:inline-flex">
              {domain.examWeightMin}–{domain.examWeightMax}%
            </span>
          )}
          <ChevronDown
            aria-hidden="true"
            className="mt-2 h-5 w-5 text-slate-400 transition group-open:rotate-180"
          />
        </div>
      </summary>

      <div className="space-y-4 border-t border-slate-100 px-4 py-4 sm:px-6 sm:py-6">
        {domain.topics.length === 0 ? (
          <p className="text-sm text-slate-400">Nenhum tópico cadastrado neste domínio.</p>
        ) : (
          domain.topics.map((topic, topicIndex) => (
            <TopicSection
              key={topic.id}
              certificationCode={certificationCode}
              domainNumber={domainNumber}
              topic={topic}
              topicNumber={topicIndex + 1}
              progressByLessonId={progressByLessonId}
              quizSummary={topicQuizSummaryById.get(topic.id)}
            />
          ))
        )}
      </div>
    </details>
  )
}

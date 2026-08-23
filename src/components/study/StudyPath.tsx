import type { DomainWithTopics } from '../../types/content'
import type { UserLessonProgress } from '../../types/progress'
import type { TopicQuizSummary } from '../../types/quiz'
import { DomainSection } from './DomainSection'

interface StudyPathProps {
  certificationCode: string
  domains: readonly DomainWithTopics[]
  progressByLessonId: ReadonlyMap<string, UserLessonProgress>
  topicQuizSummaryById: ReadonlyMap<string, TopicQuizSummary>
}

export function StudyPath({ certificationCode, domains, progressByLessonId, topicQuizSummaryById }: StudyPathProps) {
  return (
    <ol className="space-y-5 lg:space-y-6">
      {domains.map((domain, domainIndex) => (
        <li key={domain.id}>
          <DomainSection
            certificationCode={certificationCode}
            domain={domain}
            domainNumber={domainIndex + 1}
            progressByLessonId={progressByLessonId}
            topicQuizSummaryById={topicQuizSummaryById}
          />
        </li>
      ))}
    </ol>
  )
}

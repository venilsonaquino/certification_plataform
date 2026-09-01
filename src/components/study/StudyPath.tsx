import type { DomainWithTopics } from '../../types/content'
import type { UserLessonProgress } from '../../types/progress'
import type { StudyProgression } from '../../lib/studyProgression'
import { DomainSection } from './DomainSection'

interface StudyPathProps {
  certificationCode: string
  domains: readonly DomainWithTopics[]
  progressByLessonId: ReadonlyMap<string, UserLessonProgress>
  progression: StudyProgression
}

export function StudyPath({ certificationCode, domains, progressByLessonId, progression }: StudyPathProps) {
  return (
    <ol className="space-y-5 lg:space-y-6">
      {domains.map((domain, domainIndex) => (
        <li key={domain.id}>
          <DomainSection
            certificationCode={certificationCode}
            domain={domain}
            domainNumber={domainIndex + 1}
            progressByLessonId={progressByLessonId}
            progression={progression}
          />
        </li>
      ))}
    </ol>
  )
}

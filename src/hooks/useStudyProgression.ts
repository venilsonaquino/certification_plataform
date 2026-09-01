import { useMemo } from 'react'

import { resolveStudyProgression } from '../lib/studyProgression'
import type { DomainWithTopics } from '../types/content'
import type { UserLessonProgress } from '../types/progress'
import { useTopicQuizSummaries } from './useTopicQuizSummaries'

export function useStudyProgression(
  certificationId: string,
  domains: readonly DomainWithTopics[],
  progressByLessonId: ReadonlyMap<string, UserLessonProgress>,
) {
  const topicQuiz = useTopicQuizSummaries(certificationId)
  const topicQuizSummaryById = useMemo(
    () => new Map(topicQuiz.summaries.map((summary) => [summary.topicId, summary])),
    [topicQuiz.summaries],
  )
  const progression = useMemo(
    () => resolveStudyProgression(domains, progressByLessonId, topicQuizSummaryById),
    [domains, progressByLessonId, topicQuizSummaryById],
  )

  return {
    progression,
    topicQuizSummaryById,
    loading: topicQuiz.loading,
    error: topicQuiz.error,
    retry: topicQuiz.retry,
  }
}

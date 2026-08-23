import { type ReactNode, useCallback, useMemo } from 'react'

import { useStudyPathData } from '../hooks/useStudyPathData'
import { useUserProgress } from '../hooks/useUserProgress'
import { calculateCertificationProgress } from '../lib/progressUtils'
import {
  CertificationProgressContext,
  type CertificationProgressContextValue,
} from './CertificationProgressContext'

interface CertificationProgressProviderProps {
  certificationId: string
  children: ReactNode
}

export function CertificationProgressProvider({
  certificationId,
  children,
}: CertificationProgressProviderProps) {
  const {
    domains,
    loading: contentLoading,
    error: contentError,
    retry: retryContent,
  } = useStudyPathData(certificationId)
  const lessonIds = domains.flatMap((domain) =>
    domain.topics.flatMap((topic) => topic.lessons.map((lesson) => lesson.id)),
  )
  const {
    progressByLessonId,
    loading: progressLoading,
    error: progressError,
    retry: retryProgress,
    recordProgress,
  } = useUserProgress({ lessonIds })
  const summary = useMemo(
    () => calculateCertificationProgress(domains, progressByLessonId),
    [domains, progressByLessonId],
  )
  const retry = useCallback(() => {
    retryContent()
    retryProgress()
  }, [retryContent, retryProgress])
  const value = useMemo<CertificationProgressContextValue>(
    () => ({
      domains,
      progressByLessonId,
      summary,
      loading: contentLoading || (domains.length > 0 && progressLoading),
      error: contentError
        ? 'Não foi possível carregar o conteúdo da certificação.'
        : progressError,
      retry,
      recordProgress,
    }),
    [
      contentError,
      contentLoading,
      domains,
      progressByLessonId,
      progressError,
      progressLoading,
      recordProgress,
      retry,
      summary,
    ],
  )

  return (
    <CertificationProgressContext.Provider value={value}>
      {children}
    </CertificationProgressContext.Provider>
  )
}

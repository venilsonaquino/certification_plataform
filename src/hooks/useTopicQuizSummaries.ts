import { useCallback, useEffect, useRef, useState } from 'react'
import { getTopicQuizSummaries } from '../services/quizService'
import type { TopicQuizSummary } from '../types/quiz'

export function useTopicQuizSummaries(certificationId: string) {
  const [summaries, setSummaries] = useState<readonly TopicQuizSummary[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const requestVersion = useRef(0)
  const load = useCallback(async () => {
    const version = ++requestVersion.current
    setLoading(true); setError(null)
    try {
      const result = await getTopicQuizSummaries(certificationId)
      if (requestVersion.current === version) setSummaries(result)
    } catch {
      if (requestVersion.current === version) {
        setSummaries([])
        setError('Não foi possível carregar os Quizzes dos tópicos.')
      }
    } finally {
      if (requestVersion.current === version) setLoading(false)
    }
  }, [certificationId])
  useEffect(() => { void load() }, [load])
  return { summaries, loading, error, retry: load }
}

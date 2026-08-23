import { useCallback, useEffect, useState } from 'react'
import { getTopicQuizSummaries } from '../services/quizService'
import type { TopicQuizSummary } from '../types/quiz'

export function useTopicQuizSummaries(certificationId: string) {
  const [summaries, setSummaries] = useState<readonly TopicQuizSummary[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const load = useCallback(async () => {
    setLoading(true); setError(null)
    try { setSummaries(await getTopicQuizSummaries(certificationId)) }
    catch (caught) { setError(caught instanceof Error ? caught.message : 'Não foi possível carregar os Quizzes dos tópicos.') }
    finally { setLoading(false) }
  }, [certificationId])
  useEffect(() => { void load() }, [load])
  return { summaries, loading, error, retry: load }
}

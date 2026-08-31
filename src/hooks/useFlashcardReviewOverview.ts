import { useCallback, useEffect, useRef, useState } from 'react'

import { getFlashcardReviewOverview } from '../services/flashcardService'
import type { FlashcardReviewOverview } from '../types/flashcard'

export function useFlashcardReviewOverview(certificationId: string | null) {
  const [overview, setOverview] = useState<FlashcardReviewOverview | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const requestVersion = useRef(0)

  const load = useCallback(async () => {
    const version = ++requestVersion.current
    if (!certificationId) {
      setOverview(null)
      setLoading(false)
      return
    }
    setLoading(true)
    setError(null)
    try {
      const result = await getFlashcardReviewOverview(certificationId)
      if (requestVersion.current === version) setOverview(result)
    } catch {
      if (requestVersion.current === version) {
        setOverview(null)
        setError('Não foi possível carregar a revisão de flashcards.')
      }
    } finally {
      if (requestVersion.current === version) setLoading(false)
    }
  }, [certificationId])

  useEffect(() => { void load() }, [load])

  return { overview, loading, error, retry: load }
}

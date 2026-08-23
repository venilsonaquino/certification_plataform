import { useCallback, useEffect, useState } from 'react'

import { getFlashcardReviewOverview } from '../services/flashcardService'
import type { FlashcardReviewOverview } from '../types/flashcard'

export function useFlashcardReviewOverview(certificationId: string | null) {
  const [overview, setOverview] = useState<FlashcardReviewOverview | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const load = useCallback(async () => {
    if (!certificationId) {
      setLoading(false)
      return
    }
    setLoading(true)
    setError(null)
    try {
      setOverview(await getFlashcardReviewOverview(certificationId))
    } catch (caught: unknown) {
      setError(caught instanceof Error ? caught.message : 'Não foi possível carregar a revisão de flashcards.')
    } finally {
      setLoading(false)
    }
  }, [certificationId])

  useEffect(() => { void load() }, [load])

  return { overview, loading, error, retry: load }
}

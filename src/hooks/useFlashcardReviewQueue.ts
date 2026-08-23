import { useCallback, useEffect, useState } from 'react'

import { getFlashcardReviewOverview, getFlashcardStudyQueue } from '../services/flashcardService'
import type { FlashcardReviewOverview, FlashcardStudyQueueItem } from '../types/flashcard'

export function useFlashcardReviewQueue(certificationId: string | null) {
  const [cards, setCards] = useState<readonly FlashcardStudyQueueItem[]>([])
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
      const [queue, nextOverview] = await Promise.all([
        getFlashcardStudyQueue(certificationId),
        getFlashcardReviewOverview(certificationId),
      ])
      setCards(queue)
      setOverview(nextOverview)
    } catch (caught: unknown) {
      setError(caught instanceof Error ? caught.message : 'Não foi possível carregar a fila de flashcards.')
    } finally {
      setLoading(false)
    }
  }, [certificationId])

  useEffect(() => { void load() }, [load])

  return { cards, overview, loading, error, retry: load }
}

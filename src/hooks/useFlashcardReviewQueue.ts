import { useCallback, useEffect, useRef, useState } from 'react'

import { getFlashcardReviewOverview, getFlashcardStudyQueue } from '../services/flashcardService'
import type { FlashcardReviewOverview, FlashcardStudyQueueItem } from '../types/flashcard'

export function useFlashcardReviewQueue(certificationId: string | null) {
  const [cards, setCards] = useState<readonly FlashcardStudyQueueItem[]>([])
  const [overview, setOverview] = useState<FlashcardReviewOverview | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const requestVersion = useRef(0)

  const load = useCallback(async () => {
    const version = ++requestVersion.current
    if (!certificationId) {
      setCards([])
      setOverview(null)
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
      if (requestVersion.current === version) {
        setCards(queue)
        setOverview(nextOverview)
      }
    } catch {
      if (requestVersion.current === version) {
        setCards([])
        setOverview(null)
        setError('Não foi possível carregar a fila de flashcards.')
      }
    } finally {
      if (requestVersion.current === version) setLoading(false)
    }
  }, [certificationId])

  useEffect(() => { void load() }, [load])

  return { cards, overview, loading, error, retry: load }
}

import { useCallback, useEffect, useRef, useState } from 'react'

import { getAvailableFlashcards } from '../services/flashcardService'
import type { AvailableFlashcard } from '../types/flashcard'

interface AvailableFlashcardScope {
  certificationId: string | null
  topicId?: string | null
  lessonId?: string | null
}

export function useAvailableFlashcards({ certificationId, topicId, lessonId }: AvailableFlashcardScope) {
  const [cards, setCards] = useState<readonly AvailableFlashcard[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const requestVersion = useRef(0)

  const load = useCallback(async () => {
    const version = ++requestVersion.current
    if (!certificationId || (!topicId && !lessonId)) {
      setCards([])
      setLoading(false)
      return
    }
    setLoading(true)
    setError(null)
    try {
      const result = await getAvailableFlashcards({
        certificationId,
        topicId: topicId ?? undefined,
        lessonId: lessonId ?? undefined,
      })
      if (requestVersion.current === version) setCards(result)
    } catch {
      if (requestVersion.current === version) {
        setCards([])
        setError('Não foi possível carregar os Flashcards.')
      }
    } finally {
      if (requestVersion.current === version) setLoading(false)
    }
  }, [certificationId, lessonId, topicId])

  useEffect(() => { void load() }, [load])
  return { cards, loading, error, retry: load }
}

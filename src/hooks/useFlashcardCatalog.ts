import { useCallback, useEffect, useRef, useState } from 'react'

import { getFlashcardCatalogOverview } from '../services/flashcardService'
import type { FlashcardDomainOverview } from '../types/flashcard'

export function useFlashcardCatalog(certificationId: string | null) {
  const [domains, setDomains] = useState<readonly FlashcardDomainOverview[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const requestVersion = useRef(0)

  const load = useCallback(async () => {
    const version = ++requestVersion.current
    if (!certificationId) {
      setDomains([])
      setLoading(false)
      return
    }
    setLoading(true)
    setError(null)
    try {
      const result = await getFlashcardCatalogOverview(certificationId)
      if (requestVersion.current === version) setDomains(result)
    } catch {
      if (requestVersion.current === version) {
        setDomains([])
        setError('Não foi possível carregar os Flashcards disponíveis.')
      }
    } finally {
      if (requestVersion.current === version) setLoading(false)
    }
  }, [certificationId])

  useEffect(() => { void load() }, [load])
  return { domains, loading, error, retry: load }
}

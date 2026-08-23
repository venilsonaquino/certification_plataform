import { useEffect, useState } from 'react'

import { getCertificationContent } from '../services/certificationService'
import type { DomainWithTopics } from '../types/content'

export function useStudyPathData(certificationId: string) {
  const [domains, setDomains] = useState<DomainWithTopics[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(false)
  const [attempt, setAttempt] = useState(0)

  useEffect(() => {
    let active = true

    setLoading(true)
    setError(false)

    void getCertificationContent(certificationId)
      .then((content) => {
        if (active) {
          setDomains(content)
          setLoading(false)
        }
      })
      .catch(() => {
        if (active) {
          setDomains([])
          setError(true)
          setLoading(false)
        }
      })

    return () => {
      active = false
    }
  }, [attempt, certificationId])

  return {
    domains,
    loading,
    error,
    retry: () => setAttempt((current) => current + 1),
  }
}

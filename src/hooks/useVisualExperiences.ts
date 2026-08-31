import { useCallback, useEffect, useState } from 'react'

import { getPublishedVisualExperiencesByLesson } from '../services/visualExperienceService'
import type { RenderableVisualExperience } from '../types/visualExperience'

export function useVisualExperiences(lessonId: string | null) {
  const [experiences, setExperiences] = useState<readonly RenderableVisualExperience[]>([])
  const [loading, setLoading] = useState(Boolean(lessonId))
  const [error, setError] = useState<string | null>(null)
  const [requestVersion, setRequestVersion] = useState(0)

  useEffect(() => {
    let active = true

    if (!lessonId) {
      setExperiences([])
      setLoading(false)
      setError(null)
      return () => {
        active = false
      }
    }

    setExperiences([])
    setLoading(true)
    setError(null)

    void getPublishedVisualExperiencesByLesson(lessonId)
      .then((nextExperiences) => {
        if (active) {
          setExperiences(nextExperiences)
        }
      })
      .catch(() => {
        if (active) {
          setError('Não foi possível carregar as visualizações desta aula.')
        }
      })
      .finally(() => {
        if (active) {
          setLoading(false)
        }
      })

    return () => {
      active = false
    }
  }, [lessonId, requestVersion])

  const retry = useCallback(() => {
    setRequestVersion((current) => current + 1)
  }, [])

  return { experiences, loading, error, retry }
}

import { useCallback, useEffect, useState } from 'react'

import { getLessonContentBlocks } from '../services/lessonContentBlockService'
import type { RenderableLessonContentBlock } from '../types/lessonContentBlock'

export function useLessonContentBlocks(lessonId: string) {
  const [blocks, setBlocks] = useState<readonly RenderableLessonContentBlock[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [requestVersion, setRequestVersion] = useState(0)

  useEffect(() => {
    let active = true

    setBlocks([])
    setLoading(true)
    setError(null)

    void getLessonContentBlocks(lessonId)
      .then((nextBlocks) => {
        if (active) {
          setBlocks(nextBlocks)
        }
      })
      .catch(() => {
        if (active) {
          setError('Não foi possível carregar o conteúdo desta aula.')
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

  return { blocks, loading, error, retry }
}

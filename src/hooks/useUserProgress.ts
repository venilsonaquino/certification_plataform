import { useCallback, useEffect, useRef, useState } from 'react'

import {
  completeLesson,
  getUserProgressByLessonIds,
  startLesson,
} from '../services/progressService'
import type { UserLessonProgress } from '../types/progress'
import { useAuth } from './useAuth'

interface UseUserProgressOptions {
  lessonIds: readonly string[]
  startLessonId?: string | null
}

interface ProgressState {
  key: string
  progressByLessonId: ReadonlyMap<string, UserLessonProgress>
  error: string | null
}

const progressRequests = new Map<string, Promise<UserLessonProgress[]>>()
const startRequests = new Map<string, Promise<UserLessonProgress>>()

function progressMap(items: readonly UserLessonProgress[]) {
  return new Map(items.map((item) => [item.lessonId, item]))
}

function getProgressRequest(key: string, lessonIds: readonly string[]) {
  const cached = progressRequests.get(key)

  if (cached) {
    return cached
  }

  const request = getUserProgressByLessonIds(lessonIds).finally(() => {
    if (progressRequests.get(key) === request) {
      progressRequests.delete(key)
    }
  })

  progressRequests.set(key, request)
  return request
}

function getStartRequest(key: string, lessonId: string) {
  const cached = startRequests.get(key)

  if (cached) {
    return cached
  }

  const request = startLesson(lessonId).finally(() => {
    if (startRequests.get(key) === request) {
      startRequests.delete(key)
    }
  })

  startRequests.set(key, request)
  return request
}

export function useUserProgress({ lessonIds, startLessonId = null }: UseUserProgressOptions) {
  const { user } = useAuth()
  const normalizedLessonIds = [...new Set(lessonIds)].sort()
  const requestKey = user && startLessonId
    ? `start|${user.id}|${startLessonId}`
    : user && normalizedLessonIds.length > 0
      ? `batch|${user.id}|${normalizedLessonIds.join(',')}`
      : ''
  const [state, setState] = useState<ProgressState>({
    key: '',
    progressByLessonId: new Map(),
    error: null,
  })
  const [attempt, setAttempt] = useState(0)
  const [completingLessonId, setCompletingLessonId] = useState<string | null>(null)
  const [mutationError, setMutationError] = useState<string | null>(null)
  const completingLessonRef = useRef<string | null>(null)

  useEffect(() => {
    let active = true

    if (!requestKey) {
      setState({ key: '', progressByLessonId: new Map(), error: null })
      return () => {
        active = false
      }
    }

    setMutationError(null)

    const [requestType, , requestValue] = requestKey.split('|')
    const request = requestType === 'start'
      ? getStartRequest(requestKey, requestValue).then((item) => [item])
      : getProgressRequest(requestKey, requestValue.split(','))

    void request
      .then((items) => {
        if (active) {
          setState({ key: requestKey, progressByLessonId: progressMap(items), error: null })
        }
      })
      .catch(() => {
        if (active) {
          setState({
            key: requestKey,
            progressByLessonId: new Map(),
            error: 'Não foi possível carregar o progresso. Tente novamente.',
          })
        }
      })

    return () => {
      active = false
    }
  }, [attempt, requestKey])

  const completeProgress = useCallback(async (lessonId: string) => {
    if (completingLessonRef.current) {
      return null
    }

    completingLessonRef.current = lessonId
    setMutationError(null)
    setCompletingLessonId(lessonId)

    try {
      const completed = await completeLesson(lessonId)
      setState((current) => {
        const nextProgress = new Map(current.progressByLessonId)
        nextProgress.set(completed.lessonId, completed)
        return { ...current, progressByLessonId: nextProgress }
      })
      return completed
    } catch {
      setMutationError('Não foi possível concluir a aula. Tente novamente.')
      return null
    } finally {
      completingLessonRef.current = null
      setCompletingLessonId(null)
    }
  }, [])

  const recordProgress = useCallback((progress: UserLessonProgress) => {
    setState((current) => {
      const nextProgress = new Map(current.progressByLessonId)
      nextProgress.set(progress.lessonId, progress)
      return { ...current, progressByLessonId: nextProgress }
    })
  }, [])

  const currentProgress = state.key === requestKey ? state.progressByLessonId : new Map()

  return {
    progressByLessonId: currentProgress,
    loading: Boolean(requestKey) && state.key !== requestKey,
    error: state.key === requestKey ? state.error : null,
    retry: () => {
      setState((current) => ({ ...current, key: '' }))
      setAttempt((current) => current + 1)
    },
    completeProgress,
    recordProgress,
    completingLessonId,
    mutationError,
  }
}

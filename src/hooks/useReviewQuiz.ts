import { useCallback } from 'react'

import { getActiveReviewQuiz, startReviewQuiz } from '../services/quizService'
import { useQuizAttempt } from './useQuizAttempt'

export function useReviewQuiz(certificationId: string | null, questionId: string | null) {
  const getActive = useCallback(
    async (scopeId: string) => questionId ? null : getActiveReviewQuiz(scopeId),
    [questionId],
  )
  const start = useCallback(
    (scopeId: string) => startReviewQuiz(scopeId, questionId),
    [questionId],
  )
  return useQuizAttempt({ scopeId: certificationId, getActiveQuiz: getActive, startQuiz: start })
}

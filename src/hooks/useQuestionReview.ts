import { useCallback, useEffect, useMemo, useRef, useState } from 'react'

import { getActiveReviewQuiz } from '../services/quizService'
import { countAttemptAnswers, getQuestionReviewStats } from '../services/reviewService'
import type { QuestionReviewStats, ReviewSummary } from '../types/quiz'

export function useQuestionReview(certificationId: string | null) {
  const [questions, setQuestions] = useState<readonly QuestionReviewStats[]>([])
  const [summary, setSummary] = useState<ReviewSummary | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const requestVersion = useRef(0)

  const load = useCallback(async () => {
    const version = ++requestVersion.current
    if (!certificationId) {
      setQuestions([])
      setSummary(null)
      setLoading(false)
      return
    }
    setLoading(true); setError(null)
    try {
      const [stats, activeAttempt] = await Promise.all([
        getQuestionReviewStats(certificationId),
        getActiveReviewQuiz(certificationId),
      ])
      const activeAnsweredCount = activeAttempt ? await countAttemptAnswers(activeAttempt.id) : 0
      const totalAnswers = stats.reduce((sum, question) => sum + question.totalAttempts, 0)
      const correctAnswers = stats.reduce((sum, question) => sum + question.correctCount, 0)
      if (requestVersion.current === version) {
        setQuestions(stats)
        setSummary({
          totalQuestions: stats.length,
          highPriorityCount: stats.filter((question) => question.priority === 'high').length,
          mediumPriorityCount: stats.filter((question) => question.priority === 'medium').length,
          lowPriorityCount: stats.filter((question) => question.priority === 'low').length,
          overallAccuracy: totalAnswers === 0 ? 0 : Math.round((correctAnswers / totalAnswers) * 100),
          activeAttempt,
          activeAnsweredCount,
        })
      }
    } catch {
      if (requestVersion.current === version) {
        setQuestions([])
        setSummary(null)
        setError('Não foi possível carregar seu histórico de erros.')
      }
    } finally {
      if (requestVersion.current === version) setLoading(false)
    }
  }, [certificationId])

  useEffect(() => { void load() }, [load])

  return useMemo(() => ({ questions, summary, loading, error, retry: load }), [error, load, loading, questions, summary])
}

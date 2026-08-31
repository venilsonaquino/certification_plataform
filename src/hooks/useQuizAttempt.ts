import { useCallback, useEffect, useMemo, useRef, useState } from 'react'

import { getQuizAttempt, QuizUnavailableError, submitQuizAnswer } from '../services/quizService'
import type { QuizAttempt, QuizAttemptData } from '../types/quiz'

interface UseQuizAttemptOptions {
  scopeId: string | null
  getActiveQuiz: (scopeId: string) => Promise<QuizAttempt | null>
  startQuiz: (scopeId: string) => Promise<QuizAttempt>
}

export function useQuizAttempt({ scopeId, getActiveQuiz, startQuiz }: UseQuizAttemptOptions) {
  const [data, setData] = useState<QuizAttemptData | null>(null)
  const [currentQuestionId, setCurrentQuestionId] = useState<string | null>(null)
  const [selectedOptionId, setSelectedOptionId] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [showResult, setShowResult] = useState(false)
  const [unavailable, setUnavailable] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const submittingRef = useRef(false)
  const requestVersion = useRef(0)

  const load = useCallback(async () => {
    const version = ++requestVersion.current
    if (!scopeId) {
      submittingRef.current = false
      setData(null)
      setCurrentQuestionId(null)
      setSelectedOptionId(null)
      setShowResult(false)
      setSubmitting(false)
      setLoading(false)
      return
    }
    submittingRef.current = false
    setSubmitting(false)
    setLoading(true); setError(null); setUnavailable(false)
    try {
      const active = await getActiveQuiz(scopeId)
      const attempt = active ?? (await startQuiz(scopeId))
      const loaded = await getQuizAttempt(attempt.id)
      if (!loaded) throw new Error('A tentativa não foi encontrada.')
      if (requestVersion.current === version) {
        setData(loaded)
        const firstUnanswered = loaded.questions.find((question) => !question.answer)
        setCurrentQuestionId(firstUnanswered?.id ?? loaded.questions[0]?.id ?? null)
        setSelectedOptionId(null)
        setShowResult(loaded.attempt.status === 'completed')
      }
    } catch (caughtError) {
      if (requestVersion.current === version) {
        if (caughtError instanceof QuizUnavailableError) setUnavailable(true)
        else setError('Não foi possível carregar o Quiz.')
      }
    } finally {
      if (requestVersion.current === version) setLoading(false)
    }
  }, [getActiveQuiz, scopeId, startQuiz])

  useEffect(() => { void load() }, [load])

  const currentQuestion = useMemo(
    () => data?.questions.find((question) => question.id === currentQuestionId) ?? null,
    [currentQuestionId, data],
  )
  const currentIndex = currentQuestion
    ? data?.questions.findIndex((question) => question.id === currentQuestion.id) ?? 0
    : 0

  const submit = useCallback(async () => {
    if (!data || !currentQuestion || !selectedOptionId || submittingRef.current) return
    const version = requestVersion.current
    submittingRef.current = true; setSubmitting(true); setError(null)
    try {
      await submitQuizAnswer(data.attempt.id, currentQuestion.id, selectedOptionId)
      const refreshed = await getQuizAttempt(data.attempt.id)
      if (refreshed && requestVersion.current === version) setData(refreshed)
    } catch {
      if (requestVersion.current === version) {
        setError('Não foi possível registrar sua resposta.')
      }
    } finally {
      submittingRef.current = false
      if (requestVersion.current === version) setSubmitting(false)
    }
  }, [currentQuestion, data, selectedOptionId])

  const nextQuestion = useCallback(() => {
    if (!data || !currentQuestion) return
    const next = data.questions[currentIndex + 1]
    if (next) {
      setCurrentQuestionId(next.id)
      setSelectedOptionId(next.answer?.selectedOptionId ?? null)
      setError(null)
    } else setShowResult(true)
  }, [currentIndex, currentQuestion, data])

  const restart = useCallback(async () => {
    if (!scopeId || submittingRef.current) return
    submittingRef.current = true
    const version = ++requestVersion.current
    setLoading(true); setError(null)
    try {
      const attempt = await startQuiz(scopeId)
      const loaded = await getQuizAttempt(attempt.id)
      if (!loaded) throw new Error('A nova tentativa não foi encontrada.')
      if (requestVersion.current === version) {
        setData(loaded)
        setCurrentQuestionId(loaded.questions[0]?.id ?? null)
        setSelectedOptionId(null)
        setShowResult(false)
      }
    } catch {
      if (requestVersion.current === version) {
        setError('Não foi possível iniciar outra tentativa.')
      }
    } finally {
      submittingRef.current = false
      if (requestVersion.current === version) setLoading(false)
    }
  }, [scopeId, startQuiz])

  return { data, currentQuestion, currentIndex, selectedOptionId, setSelectedOptionId, loading,
    submitting, showResult, unavailable, error, retry: load, submit, nextQuestion, restart }
}

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

  const load = useCallback(async () => {
    if (!scopeId) { setLoading(false); return }
    setLoading(true); setError(null); setUnavailable(false)
    try {
      const active = await getActiveQuiz(scopeId)
      const attempt = active ?? (await startQuiz(scopeId))
      const loaded = await getQuizAttempt(attempt.id)
      if (!loaded) throw new Error('A tentativa não foi encontrada.')
      setData(loaded)
      const firstUnanswered = loaded.questions.find((question) => !question.answer)
      setCurrentQuestionId(firstUnanswered?.id ?? loaded.questions[0]?.id ?? null)
      setSelectedOptionId(null)
      setShowResult(loaded.attempt.status === 'completed')
    } catch (caughtError) {
      if (caughtError instanceof QuizUnavailableError) setUnavailable(true)
      else setError(caughtError instanceof Error ? caughtError.message : 'Não foi possível carregar o Quiz.')
    } finally { setLoading(false) }
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
    submittingRef.current = true; setSubmitting(true); setError(null)
    try {
      await submitQuizAnswer(data.attempt.id, currentQuestion.id, selectedOptionId)
      const refreshed = await getQuizAttempt(data.attempt.id)
      if (refreshed) setData(refreshed)
    } catch (caughtError) {
      setError(caughtError instanceof Error ? caughtError.message : 'Não foi possível registrar sua resposta.')
    } finally { submittingRef.current = false; setSubmitting(false) }
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
    setLoading(true); setError(null)
    try {
      const attempt = await startQuiz(scopeId)
      const loaded = await getQuizAttempt(attempt.id)
      if (!loaded) throw new Error('A nova tentativa não foi encontrada.')
      setData(loaded)
      setCurrentQuestionId(loaded.questions[0]?.id ?? null)
      setSelectedOptionId(null)
      setShowResult(false)
    } catch (caughtError) {
      setError(caughtError instanceof Error ? caughtError.message : 'Não foi possível iniciar outra tentativa.')
    } finally { setLoading(false) }
  }, [scopeId, startQuiz])

  return { data, currentQuestion, currentIndex, selectedOptionId, setSelectedOptionId, loading,
    submitting, showResult, unavailable, error, retry: load, submit, nextQuestion, restart }
}

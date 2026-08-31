import { useCallback, useMemo, useRef, useState } from 'react'

import { submitFlashcardReview } from '../services/flashcardService'
import type {
  Flashcard,
  FlashcardReviewRating,
  FlashcardReviewResult,
  FlashcardSessionRating,
  UserFlashcardProgress,
} from '../types/flashcard'

export type FlashcardReviewSubmitter = (
  flashcardId: string,
  rating: FlashcardReviewRating,
) => Promise<FlashcardReviewResult>

export interface FlashcardSessionSummary {
  readonly total: number
  readonly remembered: number
  readonly again: number
  readonly hard: number
  readonly good: number
  readonly easy: number
  readonly difficultCards: readonly Flashcard[]
  readonly nextReviewAt: string | null
}

export function useFlashcardSession(
  cards: readonly Flashcard[],
  submitReview: FlashcardReviewSubmitter = submitFlashcardReview,
) {
  const [sessionCards, setSessionCards] = useState<readonly Flashcard[]>(cards)
  const [currentIndex, setCurrentIndex] = useState(0)
  const [isRevealed, setIsRevealed] = useState(false)
  const [isHintVisible, setIsHintVisible] = useState(false)
  const [isFinished, setIsFinished] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [submitError, setSubmitError] = useState<string | null>(null)
  const [pendingRating, setPendingRating] = useState<FlashcardReviewRating | null>(null)
  const [sessionRatings, setSessionRatings] = useState<readonly FlashcardSessionRating[]>([])
  const [lastScheduledProgress, setLastScheduledProgress] = useState<UserFlashcardProgress | null>(null)
  const submittingRef = useRef(false)
  const currentCard = sessionCards[currentIndex] ?? null

  const beginSession = useCallback((nextCards: readonly Flashcard[]) => {
    submittingRef.current = false
    setSessionCards(nextCards)
    setCurrentIndex(0)
    setIsRevealed(false)
    setIsHintVisible(false)
    setIsFinished(false)
    setIsSubmitting(false)
    setSubmitError(null)
    setPendingRating(null)
    setSessionRatings([])
    setLastScheduledProgress(null)
  }, [])

  const submitRating = useCallback(async (rating: FlashcardReviewRating) => {
    if (!currentCard || !isRevealed || isFinished || submittingRef.current) return

    submittingRef.current = true
    setIsSubmitting(true)
    setSubmitError(null)
    setPendingRating(rating)
    setLastScheduledProgress(null)

    try {
      const result = await submitReview(currentCard.id, rating)
      setSessionRatings((current) => [...current, {
        card: currentCard,
        rating,
        review: result.review,
        progress: result.progress,
      }])
      setLastScheduledProgress(result.progress)
      setPendingRating(null)

      if (currentIndex === sessionCards.length - 1) {
        setIsFinished(true)
      } else {
        setCurrentIndex((index) => index + 1)
        setIsRevealed(false)
        setIsHintVisible(false)
      }
    } catch {
      setSubmitError('Não foi possível salvar sua resposta.')
    } finally {
      submittingRef.current = false
      setIsSubmitting(false)
    }
  }, [currentCard, currentIndex, isFinished, isRevealed, sessionCards.length, submitReview])

  const summary = useMemo<FlashcardSessionSummary>(() => {
    const count = (rating: FlashcardReviewRating) =>
      sessionRatings.filter((item) => item.rating === rating).length
    const difficultCards = sessionRatings
      .filter((item) => item.rating === 'again' || item.rating === 'hard')
      .map((item) => item.card)
    const nextReviewAt = sessionRatings.reduce<string | null>((earliest, item) => {
      const candidate = item.progress.nextReviewAt
      if (!candidate || earliest && new Date(earliest).getTime() <= new Date(candidate).getTime()) {
        return earliest
      }
      return candidate
    }, null)

    return {
      total: sessionRatings.length,
      remembered: count('good') + count('easy'),
      again: count('again'),
      hard: count('hard'),
      good: count('good'),
      easy: count('easy'),
      difficultCards,
      nextReviewAt,
    }
  }, [sessionRatings])

  return {
    sessionCards,
    currentCard,
    currentIndex,
    isRevealed,
    isHintVisible,
    isFinished,
    isSubmitting,
    submitError,
    pendingRating,
    sessionRatings,
    lastScheduledProgress,
    summary,
    revealAnswer: () => setIsRevealed(true),
    revealHint: () => setIsHintVisible(true),
    rateCard: submitRating,
    retryRating: () => pendingRating ? submitRating(pendingRating) : Promise.resolve(),
    restart: () => beginSession(cards),
    reviewDifficultCards: () => beginSession(summary.difficultCards),
  }
}

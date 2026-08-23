export interface Flashcard {
  readonly id: string
  readonly lessonId: string
  readonly frontText: string
  readonly backText: string
  readonly hint: string | null
  readonly displayOrder: number
  readonly isPublished: boolean
  readonly createdAt: string
  readonly updatedAt: string
}

export type FlashcardReviewRating = 'again' | 'hard' | 'good' | 'easy'

export type FlashcardStudyStatus = 'new' | 'due' | 'scheduled'

export interface FlashcardReview {
  readonly id: string
  readonly userId: string
  readonly flashcardId: string
  readonly rating: FlashcardReviewRating
  readonly reviewedAt: string
  readonly createdAt: string
}

export interface UserFlashcardProgress {
  readonly id: string
  readonly userId: string
  readonly flashcardId: string
  readonly lastRating: FlashcardReviewRating | null
  readonly reviewCount: number
  readonly successfulReviewCount: number
  readonly intervalDays: number
  readonly nextReviewAt: string | null
  readonly lastReviewedAt: string | null
  readonly createdAt: string
  readonly updatedAt: string
}

export interface FlashcardReviewResult {
  readonly review: FlashcardReview
  readonly progress: UserFlashcardProgress
}

export interface FlashcardStudyQueueItem extends Flashcard {
  readonly lessonTitle: string
  readonly lessonSlug: string
  readonly reviewStatus: Extract<FlashcardStudyStatus, 'new' | 'due'>
  readonly nextReviewAt: string | null
}

export interface FlashcardReviewOverview {
  readonly queueCount: number
  readonly nextReviewAt: string | null
  readonly availableFlashcardCount: number
}

export interface FlashcardSessionRating {
  readonly card: Flashcard
  readonly rating: FlashcardReviewRating
  readonly review: FlashcardReview
  readonly progress: UserFlashcardProgress
}

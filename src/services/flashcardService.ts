import { supabase } from '../lib/supabase'
import type {
  FlashcardDatabaseRow,
  FlashcardReviewOverviewDatabaseRow,
  FlashcardStudyQueueDatabaseRow,
  SubmitFlashcardReviewDatabaseRow,
} from '../types/database'
import type {
  Flashcard,
  FlashcardReviewOverview,
  FlashcardReviewRating,
  FlashcardReviewResult,
  FlashcardStudyQueueItem,
} from '../types/flashcard'

export const MAX_DAILY_FLASHCARDS = 20
export const MAX_NEW_FLASHCARDS_PER_DAY = 5

export class FlashcardDataError extends Error {
  constructor(message = 'Não foi possível carregar os flashcards.') {
    super(message)
    this.name = 'FlashcardDataError'
  }
}

function getClient() {
  if (!supabase) {
    throw new FlashcardDataError('A conexão com o Supabase não está configurada.')
  }

  return supabase
}

function mapFlashcard(row: FlashcardDatabaseRow): Flashcard {
  return {
    id: row.id,
    lessonId: row.lesson_id,
    frontText: row.front_text,
    backText: row.back_text,
    hint: row.hint,
    displayOrder: row.display_order,
    isPublished: row.is_published,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function mapFlashcardReviewResult(row: SubmitFlashcardReviewDatabaseRow): FlashcardReviewResult {
  return {
    review: {
      id: row.review_id,
      userId: row.review_user_id,
      flashcardId: row.review_flashcard_id,
      rating: row.rating,
      reviewedAt: row.reviewed_at,
      createdAt: row.review_created_at,
    },
    progress: {
      id: row.progress_id,
      userId: row.review_user_id,
      flashcardId: row.review_flashcard_id,
      lastRating: row.last_rating,
      reviewCount: row.review_count,
      successfulReviewCount: row.successful_review_count,
      intervalDays: row.interval_days,
      nextReviewAt: row.next_review_at,
      lastReviewedAt: row.last_reviewed_at,
      createdAt: row.progress_created_at,
      updatedAt: row.progress_updated_at,
    },
  }
}

function mapStudyQueueItem(row: FlashcardStudyQueueDatabaseRow): FlashcardStudyQueueItem {
  return {
    ...mapFlashcard(row),
    lessonTitle: row.lesson_title,
    lessonSlug: row.lesson_slug,
    reviewStatus: row.review_status,
    nextReviewAt: row.next_review_at,
  }
}

function mapReviewOverview(row: FlashcardReviewOverviewDatabaseRow): FlashcardReviewOverview {
  return {
    queueCount: Number(row.queue_count),
    nextReviewAt: row.next_review_at,
    availableFlashcardCount: Number(row.available_flashcard_count),
  }
}

function throwQueryError(error: { message: string } | null) {
  if (error) {
    throw new FlashcardDataError(error.message)
  }
}

export async function getFlashcardsByLesson(lessonId: string): Promise<Flashcard[]> {
  const { data, error } = await getClient()
    .from('flashcards')
    .select('*')
    .eq('lesson_id', lessonId)
    .eq('is_published', true)
    .order('display_order', { ascending: true })
    .order('created_at', { ascending: true })

  throwQueryError(error)
  return (data ?? []).map(mapFlashcard)
}

export async function getFlashcardCountByLesson(lessonId: string): Promise<number> {
  const { count, error } = await getClient()
    .from('flashcards')
    .select('id', { count: 'exact', head: true })
    .eq('lesson_id', lessonId)
    .eq('is_published', true)

  throwQueryError(error)
  return count ?? 0
}

export async function submitFlashcardReview(
  flashcardId: string,
  rating: FlashcardReviewRating,
): Promise<FlashcardReviewResult> {
  const { data, error } = await getClient()
    .rpc('submit_flashcard_review', {
      p_flashcard_id: flashcardId,
      p_rating: rating,
    })
    .single()

  throwQueryError(error)

  if (!data) {
    throw new FlashcardDataError('A avaliação salva não foi retornada pelo Supabase.')
  }

  return mapFlashcardReviewResult(data)
}

export async function getFlashcardStudyQueue(
  certificationId: string,
): Promise<FlashcardStudyQueueItem[]> {
  const { data, error } = await getClient().rpc('get_flashcard_study_queue', {
    p_certification_id: certificationId,
    p_limit: MAX_DAILY_FLASHCARDS,
    p_new_limit: MAX_NEW_FLASHCARDS_PER_DAY,
  })

  throwQueryError(error)
  return (data ?? []).map(mapStudyQueueItem)
}

export async function getFlashcardReviewOverview(
  certificationId: string,
): Promise<FlashcardReviewOverview> {
  const { data, error } = await getClient()
    .rpc('get_flashcard_review_overview', { p_certification_id: certificationId })
    .single()

  throwQueryError(error)
  if (!data) throw new FlashcardDataError('O resumo da revisão não foi retornado pelo Supabase.')
  return mapReviewOverview(data)
}

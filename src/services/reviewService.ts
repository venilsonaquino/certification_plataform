import { supabase } from '../lib/supabase'
import type { QuestionReviewStatsDatabaseRow } from '../types/database'
import {
  HIGH_ERROR_RATE_THRESHOLD,
  MEDIUM_ERROR_RATE_THRESHOLD,
  type QuestionReviewStats,
  type ReviewPriority,
} from '../types/quiz'
import { QuizDataError } from './quizService'

function getClient() {
  if (!supabase) throw new QuizDataError('A conexão com o Supabase não está configurada.')
  return supabase
}

export function getReviewPriority(errorPercentage: number): ReviewPriority {
  if (errorPercentage >= HIGH_ERROR_RATE_THRESHOLD) return 'high'
  if (errorPercentage >= MEDIUM_ERROR_RATE_THRESHOLD) return 'medium'
  return 'low'
}

function mapStats(row: QuestionReviewStatsDatabaseRow): QuestionReviewStats {
  const errorPercentage = Number(row.error_percentage)
  return {
    questionId: row.question_id,
    questionText: row.question_text,
    domainId: row.domain_id,
    domainTitle: row.domain_title,
    topicId: row.topic_id,
    topicTitle: row.topic_title,
    lessonId: row.lesson_id,
    lessonTitle: row.lesson_title,
    lessonSlug: row.lesson_slug,
    totalAttempts: Number(row.total_attempts),
    correctCount: Number(row.correct_count),
    incorrectCount: Number(row.incorrect_count),
    accuracyPercentage: Number(row.accuracy_percentage),
    errorPercentage,
    lastAnsweredAt: row.last_answered_at,
    lastResult: row.last_result,
    priority: getReviewPriority(errorPercentage),
  }
}

export async function getQuestionReviewStats(
  certificationId: string,
): Promise<QuestionReviewStats[]> {
  const { data, error } = await getClient().rpc('get_user_question_stats', {
    p_certification_id: certificationId,
  })
  if (error) throw new QuizDataError(error.message)
  return (data ?? []).map(mapStats)
}

export async function countAttemptAnswers(attemptId: string): Promise<number> {
  const { count, error } = await getClient()
    .from('quiz_answers')
    .select('id', { count: 'exact', head: true })
    .eq('attempt_id', attemptId)
  if (error) throw new QuizDataError(error.message)
  return count ?? 0
}

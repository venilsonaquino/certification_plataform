import { supabase } from '../lib/supabase'
import type { QuestionDatabaseRow } from '../types/database'
import type { PublicQuestion } from '../types/question'

export class QuestionDataError extends Error {
  constructor(message = 'Não foi possível carregar as questões.') {
    super(message)
    this.name = 'QuestionDataError'
  }
}

function getClient() {
  if (!supabase) {
    throw new QuestionDataError('A conexão com o Supabase não está configurada.')
  }

  return supabase
}

function mapQuestion(row: Omit<QuestionDatabaseRow, 'explanation'>): PublicQuestion {
  return {
    id: row.id,
    certificationId: row.certification_id,
    domainId: row.domain_id,
    topicId: row.topic_id,
    lessonId: row.lesson_id,
    questionText: row.question_text,
    questionType: row.question_type,
    difficulty: row.difficulty,
    isPublished: row.is_published,
    displayOrder: row.display_order,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function throwQueryError(error: { message: string } | null) {
  if (error) {
    throw new QuestionDataError(error.message)
  }
}

async function getPublishedQuestionsBy(
  column: 'certification_id' | 'domain_id' | 'topic_id' | 'lesson_id',
  value: string,
): Promise<PublicQuestion[]> {
  const { data, error } = await getClient()
    .from('questions')
    .select('id, certification_id, domain_id, topic_id, lesson_id, question_text, question_type, difficulty, is_published, display_order, created_at, updated_at')
    .eq(column, value)
    .eq('is_published', true)
    .order('display_order', { ascending: true })
    .order('created_at', { ascending: true })

  throwQueryError(error)
  return (data ?? []).map(mapQuestion)
}

export function getQuestionsByCertification(certificationId: string): Promise<PublicQuestion[]> {
  return getPublishedQuestionsBy('certification_id', certificationId)
}

export function getQuestionsByDomain(domainId: string): Promise<PublicQuestion[]> {
  return getPublishedQuestionsBy('domain_id', domainId)
}

export function getQuestionsByTopic(topicId: string): Promise<PublicQuestion[]> {
  return getPublishedQuestionsBy('topic_id', topicId)
}

export function getQuestionsByLesson(lessonId: string): Promise<PublicQuestion[]> {
  return getPublishedQuestionsBy('lesson_id', lessonId)
}

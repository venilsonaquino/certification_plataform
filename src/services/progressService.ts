import { supabase } from '../lib/supabase'
import type { UserLessonProgressDatabaseRow } from '../types/database'
import type { UserLessonProgress } from '../types/progress'

export class ProgressDataError extends Error {
  constructor(message = 'Não foi possível acessar o progresso da aula.') {
    super(message)
    this.name = 'ProgressDataError'
  }
}

function getClient() {
  if (!supabase) {
    throw new ProgressDataError('A conexão com o Supabase não está configurada.')
  }

  return supabase
}

function mapProgress(row: UserLessonProgressDatabaseRow): UserLessonProgress {
  return {
    id: row.id,
    userId: row.user_id,
    lessonId: row.lesson_id,
    status: row.status,
    startedAt: row.started_at,
    completedAt: row.completed_at,
    lastAccessedAt: row.last_accessed_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function throwQueryError(error: { message: string } | null) {
  if (error) {
    throw new ProgressDataError(error.message)
  }
}

export async function getLessonProgress(lessonId: string): Promise<UserLessonProgress | null> {
  const { data, error } = await getClient()
    .from('user_lesson_progress')
    .select('*')
    .eq('lesson_id', lessonId)
    .maybeSingle()

  throwQueryError(error)
  return data ? mapProgress(data) : null
}

export async function getUserProgressByLessonIds(
  lessonIds: readonly string[],
): Promise<UserLessonProgress[]> {
  if (lessonIds.length === 0) {
    return []
  }

  const { data, error } = await getClient()
    .from('user_lesson_progress')
    .select('*')
    .in('lesson_id', [...lessonIds])

  throwQueryError(error)
  return (data ?? []).map(mapProgress)
}

export async function startLesson(lessonId: string): Promise<UserLessonProgress> {
  const { data, error } = await getClient()
    .rpc('start_lesson_progress', { p_lesson_id: lessonId })
    .single()

  throwQueryError(error)

  if (!data) {
    throw new ProgressDataError('O progresso iniciado não foi retornado pelo Supabase.')
  }

  return mapProgress(data)
}

export async function completeLesson(lessonId: string): Promise<UserLessonProgress> {
  const { data, error } = await getClient()
    .rpc('complete_lesson_progress', { p_lesson_id: lessonId })
    .single()

  throwQueryError(error)

  if (!data) {
    throw new ProgressDataError('O progresso concluído não foi retornado pelo Supabase.')
  }

  return mapProgress(data)
}

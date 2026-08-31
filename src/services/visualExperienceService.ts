import { supabase } from '../lib/supabase'
import { reportError } from '../lib/reportError'
import { parseVisualExperience } from '../lib/visualExperienceValidation'
import type { VisualExperienceDatabaseRow } from '../types/database'
import type { RenderableVisualExperience } from '../types/visualExperience'

export class VisualExperienceDataError extends Error {
  constructor(message = 'Não foi possível carregar as visualizações desta aula.') {
    super(message)
    this.name = 'VisualExperienceDataError'
  }
}

function getClient() {
  if (!supabase) {
    throw new VisualExperienceDataError('A conexão com o Supabase não está configurada.')
  }

  return supabase
}

function toValidationCandidate(row: VisualExperienceDatabaseRow) {
  return {
    id: row.id,
    lessonId: row.lesson_id,
    type: row.type,
    title: row.title,
    description: row.description,
    config: row.config,
    displayOrder: row.display_order,
    isPublished: row.is_published,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function parseDatabaseRow(row: VisualExperienceDatabaseRow): RenderableVisualExperience {
  const result = parseVisualExperience(toValidationCandidate(row))

  if (!result.success && import.meta.env.DEV) {
    reportError('Configuração de visual experience inválida.', {
      id: row.id,
      type: row.type,
      issues: result.issues,
    })
  }

  return result.experience
}

export async function getPublishedVisualExperiencesByLesson(
  lessonId: string,
): Promise<RenderableVisualExperience[]> {
  const { data, error } = await getClient()
    .from('visual_experiences')
    .select('*')
    .eq('lesson_id', lessonId)
    .eq('is_published', true)
    .order('display_order', { ascending: true })
    .order('created_at', { ascending: true })

  if (error) {
    throw new VisualExperienceDataError(error.message)
  }

  return (data ?? []).map(parseDatabaseRow)
}

export async function getPublishedVisualExperiencesByIds(
  lessonId: string,
  visualExperienceIds: readonly string[],
): Promise<RenderableVisualExperience[]> {
  if (visualExperienceIds.length === 0) {
    return []
  }

  const { data, error } = await getClient()
    .from('visual_experiences')
    .select('*')
    .eq('lesson_id', lessonId)
    .eq('is_published', true)
    .in('id', [...new Set(visualExperienceIds)])

  if (error) {
    throw new VisualExperienceDataError(error.message)
  }

  return (data ?? []).map(parseDatabaseRow)
}

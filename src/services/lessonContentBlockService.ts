import { parseLessonContentBlock } from '../lib/lessonContentBlockValidation'
import { supabase } from '../lib/supabase'
import { reportError } from '../lib/reportError'
import type { LessonContentBlockDatabaseRow } from '../types/database'
import type {
  RenderableLessonContentBlock,
  VisualExperienceContentBlock,
} from '../types/lessonContentBlock'
import { getPublishedVisualExperiencesByIds } from './visualExperienceService'

export class LessonContentBlockDataError extends Error {
  constructor(message = 'Não foi possível carregar o conteúdo desta aula.') {
    super(message)
    this.name = 'LessonContentBlockDataError'
  }
}

function getClient() {
  if (!supabase) {
    throw new LessonContentBlockDataError('A conexão com o Supabase não está configurada.')
  }

  return supabase
}

function toValidationCandidate(row: LessonContentBlockDatabaseRow) {
  return {
    id: row.id,
    lessonId: row.lesson_id,
    type: row.type,
    title: row.title,
    content: row.content,
    config: row.config,
    visualExperienceId: row.visual_experience_id,
    displayOrder: row.display_order,
    isPublished: row.is_published,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function parseDatabaseRow(row: LessonContentBlockDatabaseRow): RenderableLessonContentBlock {
  const result = parseLessonContentBlock(toValidationCandidate(row))

  if (!result.success && import.meta.env.DEV) {
    reportError('Configuração de lesson content block inválida.', {
      id: row.id,
      type: row.type,
      issues: result.issues,
    })
  }

  return result.block
}

function isVisualExperienceBlock(
  block: RenderableLessonContentBlock,
): block is VisualExperienceContentBlock {
  return block.type === 'visual_experience'
}

export async function getLessonContentBlocks(
  lessonId: string,
): Promise<RenderableLessonContentBlock[]> {
  const { data, error } = await getClient()
    .from('lesson_content_blocks')
    .select('*')
    .eq('lesson_id', lessonId)
    .eq('is_published', true)
    .order('display_order', { ascending: true })
    .order('created_at', { ascending: true })

  if (error) {
    throw new LessonContentBlockDataError(error.message)
  }

  const blocks = (data ?? []).map(parseDatabaseRow)
  const visualExperienceIds = [
    ...new Set(
      blocks
        .filter(isVisualExperienceBlock)
        .map((block) => block.visualExperienceId),
    ),
  ]
  const visualExperiences =
    visualExperienceIds.length > 0
      ? await getPublishedVisualExperiencesByIds(lessonId, visualExperienceIds)
      : []
  const visualExperiencesById = new Map(
    visualExperiences.map((experience) => [experience.id, experience] as const),
  )

  return blocks.map((block) =>
    isVisualExperienceBlock(block)
      ? {
          ...block,
          visualExperience: visualExperiencesById.get(block.visualExperienceId) ?? null,
        }
      : block,
  )
}

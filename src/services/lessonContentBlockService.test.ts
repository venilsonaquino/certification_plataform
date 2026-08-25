import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { comparisonExperience } from '../test/visualExperienceFixtures'
import type { LessonContentBlockDatabaseRow } from '../types/database'

const mocks = vi.hoisted(() => ({
  from: vi.fn(),
  getPublishedVisualExperiencesByIds: vi.fn(),
}))

vi.mock('../lib/supabase', () => ({
  supabase: { from: mocks.from },
}))

vi.mock('./visualExperienceService', () => ({
  getPublishedVisualExperiencesByIds: mocks.getPublishedVisualExperiencesByIds,
}))

import { getLessonContentBlocks } from './lessonContentBlockService'

const lessonId = '22222222-2222-4222-8222-222222222222'
const visualExperienceId = '44444444-4444-4444-8444-444444444444'

function databaseRow(
  overrides: Partial<LessonContentBlockDatabaseRow> = {},
): LessonContentBlockDatabaseRow {
  return {
    id: '33333333-3333-4333-8333-333333333333',
    lesson_id: lessonId,
    type: 'explanation',
    title: 'Explicação',
    content: 'Conteúdo ordenado.',
    config: null,
    visual_experience_id: null,
    display_order: 0,
    is_published: true,
    created_at: '2026-08-25T12:00:00.000Z',
    updated_at: '2026-08-25T12:00:00.000Z',
    ...overrides,
  }
}

function configureBlockQuery(rows: LessonContentBlockDatabaseRow[]) {
  const query = {
    select: vi.fn(),
    eq: vi.fn(),
    order: vi.fn(),
  }

  query.select.mockReturnValue(query)
  query.eq.mockReturnValue(query)
  query.order
    .mockReturnValueOnce(query)
    .mockResolvedValueOnce({ data: rows, error: null })
  mocks.from.mockReturnValue(query)

  return query
}

describe('getLessonContentBlocks', () => {
  let consoleError: ReturnType<typeof vi.spyOn>

  beforeEach(() => {
    mocks.from.mockReset()
    mocks.getPublishedVisualExperiencesByIds.mockReset()
    consoleError = vi.spyOn(console, 'error').mockImplementation(() => undefined)
  })

  afterEach(() => {
    consoleError.mockRestore()
  })

  it('solicita somente blocks publicados na ordem de exibição', async () => {
    const query = configureBlockQuery([
      databaseRow(),
      databaseRow({
        id: '55555555-5555-4555-8555-555555555555',
        display_order: 1,
        content: 'Segundo bloco.',
      }),
    ])

    const blocks = await getLessonContentBlocks(lessonId)

    expect(mocks.from).toHaveBeenCalledWith('lesson_content_blocks')
    expect(query.eq).toHaveBeenNthCalledWith(1, 'lesson_id', lessonId)
    expect(query.eq).toHaveBeenNthCalledWith(2, 'is_published', true)
    expect(query.order).toHaveBeenNthCalledWith(1, 'display_order', { ascending: true })
    expect(query.order).toHaveBeenNthCalledWith(2, 'created_at', { ascending: true })
    expect(blocks.map((block) => block.displayOrder)).toEqual([0, 1])
    expect(mocks.getPublishedVisualExperiencesByIds).not.toHaveBeenCalled()
  })

  it('carrega referências visuais únicas em uma única consulta e mantém sua posição', async () => {
    configureBlockQuery([
      databaseRow(),
      databaseRow({
        id: '55555555-5555-4555-8555-555555555555',
        type: 'visual_experience',
        title: null,
        content: null,
        visual_experience_id: visualExperienceId,
        display_order: 1,
      }),
      databaseRow({
        id: '66666666-6666-4666-8666-666666666666',
        type: 'visual_experience',
        title: null,
        content: null,
        visual_experience_id: visualExperienceId,
        display_order: 2,
      }),
    ])
    const experience = comparisonExperience({
      id: visualExperienceId,
      lessonId,
    })
    mocks.getPublishedVisualExperiencesByIds.mockResolvedValue([experience])

    const blocks = await getLessonContentBlocks(lessonId)

    expect(mocks.getPublishedVisualExperiencesByIds).toHaveBeenCalledOnce()
    expect(mocks.getPublishedVisualExperiencesByIds).toHaveBeenCalledWith(
      lessonId,
      [visualExperienceId],
    )
    expect(blocks.map((block) => block.type)).toEqual([
      'explanation',
      'visual_experience',
      'visual_experience',
    ])
    expect(blocks[1]).toMatchObject({ visualExperience: experience })
    expect(blocks[2]).toMatchObject({ visualExperience: experience })
  })

  it('preserva um config inválido como fallback isolado', async () => {
    configureBlockQuery([
      databaseRow(),
      databaseRow({
        id: '55555555-5555-4555-8555-555555555555',
        type: 'image',
        title: null,
        content: null,
        config: { url: 'javascript:alert(1)', alt: 'Imagem inválida' },
        display_order: 1,
      }),
      databaseRow({
        id: '66666666-6666-4666-8666-666666666666',
        content: 'Conteúdo posterior.',
        display_order: 2,
      }),
    ])

    const blocks = await getLessonContentBlocks(lessonId)

    expect(blocks.map((block) => block.type)).toEqual([
      'explanation',
      'invalid',
      'explanation',
    ])
    expect(consoleError).toHaveBeenCalledWith(
      'Configuração de lesson content block inválida.',
      expect.objectContaining({
        id: '55555555-5555-4555-8555-555555555555',
        type: 'image',
      }),
    )
  })
})

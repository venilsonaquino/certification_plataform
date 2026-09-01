import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({ rpc: vi.fn() }))
vi.mock('../lib/supabase', () => ({ supabase: { rpc: mocks.rpc } }))

import { getAvailableFlashcards, getFlashcardCatalogOverview } from './flashcardService'

describe('flashcardService experience queries', () => {
  beforeEach(() => mocks.rpc.mockReset())

  it('agrega Domain/Topic em uma única RPC owner-aware', async () => {
    mocks.rpc.mockResolvedValue({ data: [
      { domain_id: 'd1', domain_title: 'Domain', domain_display_order: 1, topic_id: 't1', topic_title: 'Topic 1', topic_display_order: 1, available_flashcard_count: 2, total_flashcard_count: 5, studied_flashcard_count: 1 },
      { domain_id: 'd1', domain_title: 'Domain', domain_display_order: 1, topic_id: 't2', topic_title: 'Topic 2', topic_display_order: 2, available_flashcard_count: 3, total_flashcard_count: 4, studied_flashcard_count: 2 },
    ], error: null })

    const result = await getFlashcardCatalogOverview('certification-a')
    expect(mocks.rpc).toHaveBeenCalledOnce()
    expect(mocks.rpc).toHaveBeenCalledWith('get_flashcard_catalog_overview', { p_certification_id: 'certification-a' })
    expect(result[0]).toMatchObject({ availableCount: 5, totalCount: 9, studiedCount: 3 })
    expect(result[0].topics).toHaveLength(2)
  })

  it('envia Certification e Topic explicitamente para isolar o estudo livre', async () => {
    mocks.rpc.mockResolvedValue({ data: [{ id: 'f1', lesson_id: 'l1', lesson_title: 'Lesson', lesson_slug: 'lesson', front_text: 'Front', back_text: 'Back', hint: null, display_order: 1, is_published: true, created_at: '2026-08-31T00:00:00Z', updated_at: '2026-08-31T00:00:00Z' }], error: null })
    const result = await getAvailableFlashcards({ certificationId: 'certification-b', topicId: 'topic-b' })
    expect(mocks.rpc).toHaveBeenCalledWith('get_available_flashcards', { p_certification_id: 'certification-b', p_topic_id: 'topic-b', p_lesson_id: null })
    expect(result[0]).toMatchObject({ id: 'f1', lessonId: 'l1', lessonTitle: 'Lesson' })
  })
})

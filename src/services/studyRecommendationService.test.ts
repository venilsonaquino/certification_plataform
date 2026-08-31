import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({
  from: vi.fn(),
}))

vi.mock('../lib/supabase', () => ({
  supabase: { from: mocks.from },
}))

import { emptyReadinessBundle } from '../test/readinessFixtures'
import { getStudyRecommendationCatalog } from './studyRecommendationService'

function resolvedQuery<T>(rows: T[], finalEqCall = 2) {
  const query = {
    select: vi.fn(),
    eq: vi.fn(),
    in: vi.fn(),
  }
  query.select.mockReturnValue(query)
  query.in.mockReturnValue(query)
  for (let call = 1; call < finalEqCall; call += 1) {
    query.eq.mockReturnValueOnce(query)
  }
  query.eq.mockResolvedValueOnce({ data: rows, error: null })
  return query
}

describe('studyRecommendationService', () => {
  beforeEach(() => {
    mocks.from.mockReset()
  })

  it('carrega Questions e Flashcards publicados em dois batches, sem N+1', async () => {
    const bundle = emptyReadinessBundle()
    const questionQuery = resolvedQuery([{
      id: 'question-1',
      topic_id: bundle.topics[0].id,
      lesson_id: bundle.lessons[0].id,
      mock_eligible: true,
    }])
    const flashcardQuery = resolvedQuery([{
      id: 'flashcard-1',
      lesson_id: bundle.lessons[0].id,
    }], 1)
    mocks.from.mockImplementation((table: string) =>
      table === 'questions' ? questionQuery : flashcardQuery)

    const catalog = await getStudyRecommendationCatalog(bundle, ' AZ-900 ')

    expect(mocks.from.mock.calls.map(([table]) => table)).toEqual([
      'questions',
      'flashcards',
    ])
    expect(questionQuery.eq).toHaveBeenNthCalledWith(
      1,
      'certification_id',
      bundle.certificationId,
    )
    expect(questionQuery.eq).toHaveBeenNthCalledWith(2, 'is_published', true)
    expect(flashcardQuery.in).toHaveBeenCalledOnce()
    expect(flashcardQuery.in).toHaveBeenCalledWith(
      'lesson_id',
      bundle.lessons.map((lesson) => lesson.id),
    )
    expect(flashcardQuery.eq).toHaveBeenCalledWith('is_published', true)
    expect(catalog).toMatchObject({
      certificationCode: 'az-900',
      questions: [{ id: 'question-1', mockEligible: true }],
      flashcards: [{ id: 'flashcard-1' }],
    })
  })

  it('não consulta Flashcards por Lesson quando a taxonomia não contém Lessons', async () => {
    const bundle = { ...emptyReadinessBundle(), lessons: [] }
    const questionQuery = resolvedQuery([])
    mocks.from.mockReturnValue(questionQuery)

    const catalog = await getStudyRecommendationCatalog(bundle, 'az-900')

    expect(mocks.from).toHaveBeenCalledOnce()
    expect(mocks.from).toHaveBeenCalledWith('questions')
    expect(catalog.flashcards).toEqual([])
  })

  it('não aceita nem envia user_id: o catálogo adicional consulta somente conteúdo publicado', async () => {
    const bundle = emptyReadinessBundle()
    const questionQuery = resolvedQuery([])
    const flashcardQuery = resolvedQuery([], 1)
    mocks.from.mockImplementation((table: string) =>
      table === 'questions' ? questionQuery : flashcardQuery)

    await getStudyRecommendationCatalog(bundle, 'az-900')

    const allArguments = [
      ...questionQuery.eq.mock.calls,
      ...flashcardQuery.eq.mock.calls,
      ...flashcardQuery.in.mock.calls,
    ].flat()
    expect(allArguments).not.toContain('user_id')
  })
})

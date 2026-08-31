import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({
  rpc: vi.fn(),
  getCertificationContent: vi.fn(),
}))

vi.mock('../lib/supabase', () => ({ supabase: { rpc: mocks.rpc } }))
vi.mock('./certificationService', () => ({
  getCertificationContent: mocks.getCertificationContent,
}))

import { getReadinessEvidenceBundle, ReadinessDataError } from './readinessService'

const certificationId = '10000000-0000-4000-8000-000000000001'
const domainId = '20000000-0000-4000-8000-000000000001'
const topicId = '30000000-0000-4000-8000-000000000001'
const lessonId = '40000000-0000-4000-8000-000000000001'

function contentFixture() {
  return [{
    id: domainId,
    certificationId,
    title: 'Domain',
    description: null,
    examWeightMin: 25,
    examWeightMax: 30,
    displayOrder: 1,
    createdAt: '2026-08-01T12:00:00.000Z',
    updatedAt: '2026-08-01T12:00:00.000Z',
    topics: [{
      id: topicId,
      domainId,
      title: 'Topic',
      description: null,
      displayOrder: 1,
      createdAt: '2026-08-01T12:00:00.000Z',
      updatedAt: '2026-08-01T12:00:00.000Z',
      lessons: [{
        id: lessonId,
        topicId,
        slug: 'lesson',
        title: 'Lesson',
        shortDescription: null,
        content: null,
        estimatedMinutes: 10,
        displayOrder: 1,
        isPublished: true,
        createdAt: '2026-08-01T12:00:00.000Z',
        updatedAt: '2026-08-01T12:00:00.000Z',
      }],
    }],
  }]
}

function assessmentRow() {
  return {
    evidence_id: '50000000-0000-4000-8000-000000000001',
    evidence_kind: 'assessment',
    source: 'mock_exam',
    attempt_id: '60000000-0000-4000-8000-000000000001',
    question_id: '70000000-0000-4000-8000-000000000001',
    domain_id: domainId,
    topic_id: topicId,
    lesson_id: lessonId,
    outcome: 'correct',
    occurred_at: '2026-08-30T12:00:00.000Z',
    difficulty: 'medium',
    attempt_status: 'completed',
    duration_seconds: 3000,
    lesson_status: null,
    flashcard_rating: null,
    review_count: null,
    successful_review_count: null,
    due_at: null,
  }
}

describe('readinessService', () => {
  beforeEach(() => {
    mocks.rpc.mockReset()
    mocks.getCertificationContent.mockReset()
    mocks.getCertificationContent.mockResolvedValue(contentFixture())
  })

  it('carrega taxonomia e evidências em batches, sem aceitar user_id do cliente', async () => {
    mocks.rpc.mockResolvedValue({ data: [assessmentRow()], error: null })

    const bundle = await getReadinessEvidenceBundle(
      certificationId,
      '2026-08-30T12:00:00.000Z',
    )

    expect(mocks.getCertificationContent).toHaveBeenCalledOnce()
    expect(mocks.rpc).toHaveBeenCalledOnce()
    expect(mocks.rpc).toHaveBeenCalledWith('get_readiness_evidence', {
      p_certification_id: certificationId,
    })
    expect(mocks.rpc.mock.calls[0][1]).not.toHaveProperty('user_id')
    expect(bundle.assessments).toEqual([
      expect.objectContaining({ source: 'mock_exam', outcome: 'correct', topicId }),
    ])
    expect(bundle.domains[0].topicIds).toEqual([topicId])
  })

  it('rejeita payload externo incompleto no boundary', async () => {
    mocks.rpc.mockResolvedValue({
      data: [{ ...assessmentRow(), attempt_id: null }],
      error: null,
    })

    await expect(getReadinessEvidenceBundle(certificationId)).rejects.toThrow(
      ReadinessDataError,
    )
  })

  it('propaga falha da agregação sem tentar interpretar dados parciais', async () => {
    mocks.rpc.mockResolvedValue({ data: null, error: { message: 'denied' } })

    await expect(getReadinessEvidenceBundle(certificationId)).rejects.toThrow('denied')
  })
})


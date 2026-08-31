import { calculateAz900Readiness } from '../features/readiness/readinessEngine'
import { readinessEvidenceDatabaseRowSchema } from '../lib/readinessValidation'
import { supabase } from '../lib/supabase'
import type { DomainWithTopics } from '../types/content'
import type {
  AssessmentEvidence,
  GlobalReadiness,
  LearningEvidence,
  ReadinessEvidenceBundle,
} from '../types/readiness'
import { getCertificationContent } from './certificationService'

export class ReadinessDataError extends Error {
  constructor(message = 'Não foi possível calcular o Readiness da certificação.') {
    super(message)
    this.name = 'ReadinessDataError'
  }
}

function getClient() {
  if (!supabase) {
    throw new ReadinessDataError('A conexão com o Supabase não está configurada.')
  }
  return supabase
}

function buildTaxonomy(content: readonly DomainWithTopics[]) {
  return {
    domains: content.map((domain) => ({
      id: domain.id,
      title: domain.title,
      displayOrder: domain.displayOrder,
      topicIds: domain.topics.map((topic) => topic.id),
    })),
    topics: content.flatMap((domain) => domain.topics.map((topic) => ({
      id: topic.id,
      domainId: domain.id,
      title: topic.title,
      lessonIds: topic.lessons.map((lesson) => lesson.id),
    }))),
    lessons: content.flatMap((domain) => domain.topics.flatMap((topic) =>
      topic.lessons.map((lesson) => ({
        id: lesson.id,
        topicId: topic.id,
        title: lesson.title,
        slug: lesson.slug,
        displayOrder: lesson.displayOrder,
      })))),
  }
}

function parseEvidenceRows(input: readonly unknown[]) {
  return input.map((row) => {
    const result = readinessEvidenceDatabaseRowSchema.safeParse(row)
    if (!result.success) {
      throw new ReadinessDataError('O Supabase retornou uma evidência de Readiness inválida.')
    }
    return result.data
  })
}

export async function getReadinessEvidenceBundle(
  certificationId: string,
  evidenceAsOf = new Date().toISOString(),
): Promise<ReadinessEvidenceBundle> {
  const [content, evidenceResult] = await Promise.all([
    getCertificationContent(certificationId),
    getClient().rpc('get_readiness_evidence', { p_certification_id: certificationId }),
  ])
  if (evidenceResult.error) throw new ReadinessDataError(evidenceResult.error.message)

  const rows = parseEvidenceRows(evidenceResult.data ?? [])
  const assessments: AssessmentEvidence[] = rows
    .filter((row) => row.evidence_kind === 'assessment')
    .map((row) => {
      if (
        !row.attempt_id
        || !row.question_id
        || !row.outcome
        || !row.occurred_at
        || !row.attempt_status
        || !['mock_exam', 'topic_quiz', 'lesson_quiz', 'review_quiz'].includes(row.source)
      ) {
        throw new ReadinessDataError('Uma evidência de avaliação está incompleta.')
      }
      return {
        id: row.evidence_id,
        source: row.source as AssessmentEvidence['source'],
        attemptId: row.attempt_id,
        questionId: row.question_id,
        domainId: row.domain_id,
        topicId: row.topic_id,
        lessonId: row.lesson_id,
        outcome: row.outcome,
        occurredAt: row.occurred_at,
        difficulty: row.difficulty,
        attemptStatus: row.attempt_status,
        durationSeconds: row.duration_seconds,
      }
    })

  const learning: LearningEvidence[] = rows
    .filter((row) => row.evidence_kind === 'learning')
    .map((row) => {
      if (!row.lesson_id) throw new ReadinessDataError('Uma evidência de estudo está sem Lesson.')
      if (row.source === 'lesson_progress') {
        if (!row.lesson_status) {
          throw new ReadinessDataError('Uma evidência de progresso está incompleta.')
        }
        return {
          id: row.evidence_id,
          source: 'lesson_progress' as const,
          domainId: row.domain_id,
          topicId: row.topic_id,
          lessonId: row.lesson_id,
          status: row.lesson_status,
          occurredAt: row.occurred_at,
        }
      }
      if (row.source !== 'flashcard_review' && row.source !== 'flashcard_progress') {
        throw new ReadinessDataError('Fonte de aprendizagem desconhecida.')
      }
      return {
        id: row.evidence_id,
        source: row.source,
        domainId: row.domain_id,
        topicId: row.topic_id,
        lessonId: row.lesson_id,
        rating: row.flashcard_rating,
        reviewCount: row.review_count,
        successfulReviewCount: row.successful_review_count,
        occurredAt: row.occurred_at,
        dueAt: row.due_at,
      }
    })

  const taxonomy = buildTaxonomy(content)
  return {
    certificationId,
    evidenceAsOf,
    ...taxonomy,
    assessments,
    learning,
  }
}

export async function getAz900Readiness(
  certificationId: string,
  evidenceAsOf = new Date().toISOString(),
): Promise<GlobalReadiness> {
  return calculateAz900Readiness(
    await getReadinessEvidenceBundle(certificationId, evidenceAsOf),
  )
}

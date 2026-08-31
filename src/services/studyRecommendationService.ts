import { calculateAz900Readiness } from '../features/readiness/readinessEngine'
import { calculateStudyRecommendations } from '../features/readiness/studyRecommendationEngine'
import { supabase } from '../lib/supabase'
import type { ReadinessEvidenceBundle } from '../types/readiness'
import type {
  ReadinessRecommendationViewModel,
  StudyRecommendationCatalog,
} from '../types/studyRecommendation'
import { getReadinessEvidenceBundle } from './readinessService'

export class StudyRecommendationDataError extends Error {
  constructor(message = 'Não foi possível calcular as recomendações de estudo.') {
    super(message)
    this.name = 'StudyRecommendationDataError'
  }
}

function getClient() {
  if (!supabase) {
    throw new StudyRecommendationDataError('A conexão com o Supabase não está configurada.')
  }
  return supabase
}

export async function getStudyRecommendationCatalog(
  bundle: ReadinessEvidenceBundle,
  certificationCode: string,
): Promise<StudyRecommendationCatalog> {
  const lessonIds = bundle.lessons.map((lesson) => lesson.id)
  const [questionsResult, flashcardsResult] = await Promise.all([
    getClient()
      .from('questions')
      .select('id, topic_id, lesson_id, mock_eligible')
      .eq('certification_id', bundle.certificationId)
      .eq('is_published', true),
    lessonIds.length === 0
      ? Promise.resolve({ data: [], error: null })
      : getClient()
        .from('flashcards')
        .select('id, lesson_id')
        .in('lesson_id', lessonIds)
        .eq('is_published', true),
  ])
  if (questionsResult.error) throw new StudyRecommendationDataError(questionsResult.error.message)
  if (flashcardsResult.error) throw new StudyRecommendationDataError(flashcardsResult.error.message)

  return {
    certificationCode: certificationCode.trim().toLowerCase(),
    lessons: bundle.lessons,
    questions: (questionsResult.data ?? [])
      .filter((question) => question.topic_id !== null)
      .map((question) => ({
        id: question.id,
        topicId: question.topic_id as string,
        lessonId: question.lesson_id,
        mockEligible: question.mock_eligible,
      })),
    flashcards: (flashcardsResult.data ?? []).map((flashcard) => ({
      id: flashcard.id,
      lessonId: flashcard.lesson_id,
    })),
  }
}

export async function getAz900StudyRecommendations(
  certificationId: string,
  certificationCode: string,
  evidenceAsOf = new Date().toISOString(),
): Promise<ReadinessRecommendationViewModel> {
  const bundle = await getReadinessEvidenceBundle(certificationId, evidenceAsOf)
  const readiness = calculateAz900Readiness(bundle)
  const catalog = await getStudyRecommendationCatalog(bundle, certificationCode)
  return calculateStudyRecommendations(readiness, bundle, catalog).viewModel
}


export type CertificationSection =
  | 'dashboard'
  | 'study-today'
  | 'study'
  | 'map'
  | 'labs'
  | 'story'
  | 'quiz'
  | 'review'
  | 'exams'
  | 'progress'

export function certificationRoute(certificationCode: string, section: CertificationSection) {
  return `/certifications/${certificationCode.toLowerCase()}/${section}`
}

export function lessonRoute(certificationCode: string, lessonSlug: string) {
  return `${certificationRoute(certificationCode, 'study')}/${lessonSlug}`
}

export function lessonQuizRoute(certificationCode: string, lessonSlug: string) {
  return `${lessonRoute(certificationCode, lessonSlug)}/quiz`
}

export function lessonFlashcardsRoute(certificationCode: string, lessonSlug: string) {
  return `${lessonRoute(certificationCode, lessonSlug)}/flashcards`
}

export function topicQuizRoute(certificationCode: string, topicId: string) {
  return `/certifications/${certificationCode.toLowerCase()}/topics/${topicId}/quiz`
}

export function reviewQuizRoute(certificationCode: string, questionId?: string) {
  const base = `${certificationRoute(certificationCode, 'review')}/quiz`
  return questionId ? `${base}?questionId=${encodeURIComponent(questionId)}` : base
}

export function flashcardReviewRoute(certificationCode: string) {
  return `${certificationRoute(certificationCode, 'review')}/flashcards`
}

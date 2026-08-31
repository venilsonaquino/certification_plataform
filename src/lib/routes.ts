export const CERTIFICATION_SECTIONS = [
  'dashboard',
  'study-today',
  'study',
  'review',
  'exams',
  'readiness',
  'progress',
] as const

export type CertificationSection = typeof CERTIFICATION_SECTIONS[number]

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

export function mockExamsRoute(certificationCode: string) {
  return certificationRoute(certificationCode, 'exams')
}

export function mockExamExecutionRoute(certificationCode: string, attemptId: string) {
  return `${mockExamsRoute(certificationCode)}/${attemptId}`
}

export function mockExamResultRoute(certificationCode: string, attemptId: string) {
  return `${mockExamExecutionRoute(certificationCode, attemptId)}/result`
}

export function mockExamReviewRoute(certificationCode: string, attemptId: string) {
  return `${mockExamExecutionRoute(certificationCode, attemptId)}/review`
}

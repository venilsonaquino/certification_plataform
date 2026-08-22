export type CertificationSection =
  | 'dashboard'
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

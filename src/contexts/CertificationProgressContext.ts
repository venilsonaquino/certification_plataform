import { createContext } from 'react'

import type { CertificationProgressSummary } from '../lib/progressUtils'
import type { DomainWithTopics } from '../types/content'
import type { UserLessonProgress } from '../types/progress'

export interface CertificationProgressContextValue {
  readonly domains: readonly DomainWithTopics[]
  readonly progressByLessonId: ReadonlyMap<string, UserLessonProgress>
  readonly summary: CertificationProgressSummary
  readonly loading: boolean
  readonly error: string | null
  readonly retry: () => void
  readonly recordProgress: (progress: UserLessonProgress) => void
}

export const CertificationProgressContext = createContext<
  CertificationProgressContextValue | undefined
>(undefined)

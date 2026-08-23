import type { Certification } from './certification'

export interface Domain {
  readonly id: string
  readonly certificationId: string
  readonly title: string
  readonly description: string | null
  readonly examWeightMin: number | null
  readonly examWeightMax: number | null
  readonly displayOrder: number
  readonly createdAt: string
  readonly updatedAt: string
}

export interface Topic {
  readonly id: string
  readonly domainId: string
  readonly title: string
  readonly description: string | null
  readonly displayOrder: number
  readonly createdAt: string
  readonly updatedAt: string
}

export interface Lesson {
  readonly id: string
  readonly topicId: string
  readonly slug: string
  readonly title: string
  readonly shortDescription: string | null
  readonly content: string | null
  readonly estimatedMinutes: number | null
  readonly displayOrder: number
  readonly isPublished: boolean
  readonly createdAt: string
  readonly updatedAt: string
}

export interface TopicWithLessons extends Topic {
  readonly lessons: readonly Lesson[]
}

export interface DomainWithTopics extends Domain {
  readonly topics: readonly TopicWithLessons[]
}

export interface CertificationStudyPath {
  readonly certification: Certification
  readonly domains: readonly DomainWithTopics[]
}

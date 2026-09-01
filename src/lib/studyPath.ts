import type { DomainWithTopics, Lesson, TopicWithLessons } from '../types/content'

export interface StudyPathLesson {
  readonly domain: DomainWithTopics
  readonly topic: TopicWithLessons
  readonly lesson: Lesson
}

export interface LessonStudyContext extends StudyPathLesson {
  readonly previous: StudyPathLesson | null
  readonly next: StudyPathLesson | null
}

export function flattenStudyPath(domains: readonly DomainWithTopics[]): StudyPathLesson[] {
  return domains.flatMap((domain) =>
    domain.topics.flatMap((topic) =>
      topic.lessons.map((lesson) => ({
        domain,
        topic,
        lesson,
      })),
    ),
  )
}

export function findLessonStudyContext(
  domains: readonly DomainWithTopics[],
  lessonSlug: string,
): LessonStudyContext | null {
  const orderedLessons = flattenStudyPath(domains)
  const currentIndex = orderedLessons.findIndex((item) => item.lesson.slug === lessonSlug)

  if (currentIndex === -1) {
    return null
  }

  return {
    ...orderedLessons[currentIndex],
    previous: orderedLessons[currentIndex - 1] ?? null,
    next: orderedLessons[currentIndex + 1] ?? null,
  }
}

export function findNextLessonAfterTopic(
  domains: readonly DomainWithTopics[],
  topicId: string,
): StudyPathLesson | null {
  const orderedLessons = flattenStudyPath(domains)
  const lastLessonIndex = orderedLessons.map((item) => item.topic.id).lastIndexOf(topicId)

  if (lastLessonIndex === -1) return null

  return orderedLessons.slice(lastLessonIndex + 1).find((item) => item.topic.id !== topicId) ?? null
}

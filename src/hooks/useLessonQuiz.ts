import { getActiveLessonQuiz, startLessonQuiz } from '../services/quizService'
import { useQuizAttempt } from './useQuizAttempt'

export function useLessonQuiz(lessonId: string | null) {
  return useQuizAttempt({
    scopeId: lessonId,
    getActiveQuiz: getActiveLessonQuiz,
    startQuiz: startLessonQuiz,
  })
}

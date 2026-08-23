import { getActiveTopicQuiz, startTopicQuiz } from '../services/quizService'
import { useQuizAttempt } from './useQuizAttempt'

export function useTopicQuiz(topicId: string | null) {
  return useQuizAttempt({ scopeId: topicId, getActiveQuiz: getActiveTopicQuiz, startQuiz: startTopicQuiz })
}

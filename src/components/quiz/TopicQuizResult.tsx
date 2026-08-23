import { useEffect, useState } from 'react'

import { getTopicQuizResult } from '../../services/quizService'
import type { LessonQuizAttemptData, LessonQuizPerformance } from '../../types/quiz'
import { QuizResult } from './QuizResult'

interface TopicQuizResultProps {
  data: LessonQuizAttemptData
  certificationCode: string
  restarting: boolean
  onRestart: () => void
}

export function TopicQuizResult({ data, certificationCode, restarting, onRestart }: TopicQuizResultProps) {
  const [performance, setPerformance] = useState<readonly LessonQuizPerformance[]>([])

  useEffect(() => {
    let active = true
    getTopicQuizResult(data.attempt.id).then((result) => { if (active) setPerformance(result) })
    return () => { active = false }
  }, [data.attempt.id])

  return <QuizResult data={data} restarting={restarting} onRestart={onRestart} performance={performance} certificationCode={certificationCode} />
}

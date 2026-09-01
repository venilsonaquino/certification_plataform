import { useEffect, useState } from 'react'

import { getTopicQuizResult } from '../../services/quizService'
import type { LessonQuizAttemptData, LessonQuizPerformance } from '../../types/quiz'
import { QuizResult } from './QuizResult'

interface TopicQuizResultProps {
  data: LessonQuizAttemptData
  certificationCode: string
  restarting: boolean
  onRestart: () => void
  nextLessonRoute: string | null
}

export function TopicQuizResult({ data, certificationCode, restarting, onRestart, nextLessonRoute }: TopicQuizResultProps) {
  const [performance, setPerformance] = useState<readonly LessonQuizPerformance[]>([])

  useEffect(() => {
    let active = true
    getTopicQuizResult(data.attempt.id).then((result) => { if (active) setPerformance(result) })
    return () => { active = false }
  }, [data.attempt.id])

  return <QuizResult data={data} restarting={restarting} onRestart={onRestart} performance={performance} certificationCode={certificationCode} resultLabel="Checkpoint concluído" restartLabel="Refazer Checkpoint" feedbackMessage="Seu resultado orienta Review e Readiness, mas não bloqueia a progressão da trilha." completionAction={nextLessonRoute ? { to: nextLessonRoute, label: 'Ir para a próxima aula' } : undefined} />
}

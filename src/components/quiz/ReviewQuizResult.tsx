import { useEffect, useState } from 'react'

import { getQuizLessonPerformance } from '../../services/quizService'
import type { LessonQuizAttemptData, LessonQuizPerformance } from '../../types/quiz'
import { QuizResult } from './QuizResult'

interface ReviewQuizResultProps { data: LessonQuizAttemptData; certificationCode: string; restarting: boolean; onRestart: () => void }

export function ReviewQuizResult({ data, certificationCode, restarting, onRestart }: ReviewQuizResultProps) {
  const [performance, setPerformance] = useState<readonly LessonQuizPerformance[]>([])
  useEffect(() => { let active = true; getQuizLessonPerformance(data.attempt.id).then((result) => { if (active) setPerformance(result) }); return () => { active = false } }, [data.attempt.id])
  return <QuizResult data={data} restarting={restarting} onRestart={onRestart} performance={performance} certificationCode={certificationCode} resultLabel="Revisão concluída" scoreDescription={`${data.attempt.correctAnswers} de ${data.attempt.totalQuestions} respostas corretas nesta revisão`} restartLabel="Iniciar nova revisão" />
}

import { useCallback, useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { MockExamStart } from '../components/mockExam/MockExamStart'
import { useCertification } from '../hooks/useCertification'
import { mockExamExecutionRoute } from '../lib/routes'
import {
  getActiveMockExamAttempt,
  startMockExam,
} from '../services/mockExamService'
import type { MockExamAttempt } from '../types/mockExam'

const START_ERROR = 'Não foi possível preparar o Mock agora. Tente novamente em instantes.'
const POOL_ERROR = 'O banco de Questions ainda não possui capacidade suficiente para iniciar este Mock.'

function getStartError(error: unknown) {
  const message = error instanceof Error ? error.message.toLowerCase() : ''
  return message.includes('insufficient') || message.includes('pool')
    ? POOL_ERROR
    : START_ERROR
}

export function MockExamsPage() {
  const { currentCertification } = useCertification()
  const navigate = useNavigate()
  const requestInFlight = useRef(false)
  const [activeAttempt, setActiveAttempt] = useState<MockExamAttempt | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const loadActiveAttempt = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      setActiveAttempt(await getActiveMockExamAttempt(currentCertification.id))
    } catch (cause) {
      console.error('Falha ao localizar Mock Exam em andamento.', cause)
      setError(START_ERROR)
    } finally {
      setLoading(false)
    }
  }, [currentCertification.id])

  useEffect(() => {
    void loadActiveAttempt()
  }, [loadActiveAttempt])

  const handleStart = async () => {
    if (requestInFlight.current) return
    requestInFlight.current = true
    setLoading(true)
    setError(null)
    try {
      const attempt = await startMockExam(currentCertification.id)
      navigate(mockExamExecutionRoute(currentCertification.code, attempt.id))
    } catch (cause) {
      console.error('Falha ao iniciar Mock Exam.', cause)
      setError(getStartError(cause))
      setLoading(false)
    } finally {
      requestInFlight.current = false
    }
  }

  if (loading && !activeAttempt && !error) {
    return <CertificationDataState title="Verificando seus simulados..." loading />
  }

  return (
    <MockExamStart
      activeAttempt={activeAttempt}
      loading={loading}
      error={error}
      onStart={() => void handleStart()}
      onResume={(attemptId) => navigate(mockExamExecutionRoute(currentCertification.code, attemptId))}
      onRetry={() => void loadActiveAttempt()}
    />
  )
}

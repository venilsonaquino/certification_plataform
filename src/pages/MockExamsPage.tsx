import { useCallback, useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { MockExamStart } from '../components/mockExam/MockExamStart'
import { MockExamHistory } from '../components/mockExam/MockExamHistory'
import { MockExamScoreHistory } from '../components/mockExam/MockExamScoreHistory'
import { useCertification } from '../hooks/useCertification'
import { mockExamExecutionRoute, mockExamResultRoute } from '../lib/routes'
import { reportError } from '../lib/reportError'
import {
  getMockExamHistory,
  startMockExam,
} from '../services/mockExamService'
import type { MockExamHistoryItem } from '../types/mockExam'

const START_ERROR = 'Não foi possível preparar o Mock agora. Tente novamente em instantes.'
const POOL_ERROR = 'O banco de questões ainda não possui capacidade suficiente para iniciar este Mock.'
const PAGE_SIZE = 10

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
  const historyRequestVersion = useRef(0)
  const [activeAttempt, setActiveAttempt] = useState<{ id: string } | null>(null)
  const [history, setHistory] = useState<readonly MockExamHistoryItem[]>([])
  const [recentHistory, setRecentHistory] = useState<readonly MockExamHistoryItem[]>([])
  const [historyTotal, setHistoryTotal] = useState(0)
  const [page, setPage] = useState(0)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const loadHistory = useCallback(async (targetPage = 0) => {
    const version = ++historyRequestVersion.current
    setLoading(true)
    setError(null)
    try {
      const loaded = await getMockExamHistory(currentCertification.id, PAGE_SIZE, targetPage * PAGE_SIZE)
      if (historyRequestVersion.current === version) {
        setHistory(loaded.items)
        setHistoryTotal(loaded.totalCount)
        setPage(targetPage)
        if (targetPage === 0) {
          setRecentHistory(loaded.items)
          const active = loaded.items.find((item) => item.status === 'in_progress')
          setActiveAttempt(active ? { id: active.attemptId } : null)
        }
      }
    } catch (cause) {
      reportError('Falha ao localizar Mock Exam em andamento.', cause)
      if (historyRequestVersion.current === version) setError(START_ERROR)
    } finally {
      if (historyRequestVersion.current === version) setLoading(false)
    }
  }, [currentCertification.id])

  useEffect(() => { void loadHistory(0) }, [loadHistory])

  const handleStart = async () => {
    if (requestInFlight.current) return
    requestInFlight.current = true
    setLoading(true)
    setError(null)
    try {
      const attempt = await startMockExam(currentCertification.id)
      navigate(mockExamExecutionRoute(currentCertification.code, attempt.id))
    } catch (cause) {
      reportError('Falha ao iniciar Mock Exam.', cause)
      setError(getStartError(cause))
      setLoading(false)
    } finally {
      requestInFlight.current = false
    }
  }

  if (loading && history.length === 0 && !error) {
    return <CertificationDataState title="Verificando seus simulados..." loading />
  }

  const resume = (attemptId: string) => navigate(mockExamExecutionRoute(currentCertification.code, attemptId))
  return <>
    <MockExamStart activeAttempt={activeAttempt} hasHistory={historyTotal > 0} loading={loading} error={error} onStart={() => void handleStart()} onResume={resume} onRetry={() => void loadHistory(page)} />
    <MockExamScoreHistory items={recentHistory} />
    <MockExamHistory items={history} totalCount={historyTotal} page={page} pageSize={PAGE_SIZE} loading={loading} onPageChange={(next) => void loadHistory(next)} onResume={resume} onViewResult={(attemptId) => navigate(mockExamResultRoute(currentCertification.code, attemptId))} />
  </>
}

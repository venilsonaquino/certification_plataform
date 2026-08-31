import { ArrowLeft, LoaderCircle, SearchCheck } from 'lucide-react'
import { useCallback, useEffect, useRef, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { MockExamBreakdownSection } from '../components/mockExam/MockExamBreakdownSection'
import { MockExamResultSummary } from '../components/mockExam/MockExamResultSummary'
import { useCertification } from '../hooks/useCertification'
import { certificationRoute, mockExamExecutionRoute, mockExamReviewRoute } from '../lib/routes'
import { reportError } from '../lib/reportError'
import { getMockExamAttempt, getMockExamResult, startMockExam } from '../services/mockExamService'
import type { MockExamResult } from '../types/mockExam'

const RESULT_ERROR = 'Não foi possível carregar o resultado deste Mock Exam.'

export function MockExamResultPage() {
  const { attemptId = '' } = useParams<{ attemptId: string }>()
  const { currentCertification } = useCertification()
  const navigate = useNavigate()
  const loadRequestVersion = useRef(0)
  const retakeInFlight = useRef(false)
  const [result, setResult] = useState<MockExamResult | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [startingRetake, setStartingRetake] = useState(false)
  const [retakeError, setRetakeError] = useState<string | null>(null)

  const loadResult = useCallback(async () => {
    const version = ++loadRequestVersion.current
    setLoading(true)
    setError(null)
    try {
      const attempt = await getMockExamAttempt(attemptId)
      if (loadRequestVersion.current !== version) return
      if (!attempt || attempt.certificationId !== currentCertification.id) {
        setError(RESULT_ERROR)
        return
      }
      if (attempt.status === 'in_progress') {
        navigate(mockExamExecutionRoute(currentCertification.code, attempt.id), { replace: true })
        return
      }
      if (attempt.status !== 'completed' && attempt.status !== 'expired') {
        setError('Este Mock Exam não possui um resultado disponível.')
        return
      }
      const loaded = await getMockExamResult(attemptId)
      if (loadRequestVersion.current !== version) return
      if (!loaded) {
        setError(RESULT_ERROR)
        return
      }
      setResult(loaded)
    } catch (cause) {
      reportError('Falha ao carregar resultado do Mock Exam.', cause)
      if (loadRequestVersion.current === version) setError(RESULT_ERROR)
    } finally {
      if (loadRequestVersion.current === version) setLoading(false)
    }
  }, [attemptId, currentCertification.code, currentCertification.id, navigate])

  useEffect(() => {
    void loadResult()
  }, [loadResult])

  const handleRetake = async () => {
    if (retakeInFlight.current) return
    retakeInFlight.current = true
    setStartingRetake(true)
    setRetakeError(null)
    try {
      const attempt = await startMockExam(currentCertification.id)
      navigate(mockExamExecutionRoute(currentCertification.code, attempt.id))
    } catch (cause) {
      reportError('Falha ao iniciar novo Mock Exam.', cause)
      setRetakeError('Não foi possível iniciar outro Mock agora. Tente novamente.')
      setStartingRetake(false)
    } finally {
      retakeInFlight.current = false
    }
  }

  if (loading) return <CertificationDataState title="Carregando o resultado do Mock..." loading />
  if (error || !result) return <CertificationDataState title="Resultado indisponível." description={error ?? RESULT_ERROR} onRetry={() => void loadResult()} />

  return (
    <div className="mx-auto max-w-6xl">
      <Link to={certificationRoute(currentCertification.code, 'exams')} className="inline-flex min-h-10 items-center gap-2 text-sm font-bold text-blue-700"><ArrowLeft className="h-4 w-4" aria-hidden="true" />Voltar para Simulados</Link>
      <header className="mt-4">
        <p className="text-sm font-bold text-blue-700">AZ-900 · resultado de prática</p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">Resultado do AZ-900 Practice Mock</h1>
      </header>

      <div className="mt-7"><MockExamResultSummary result={result} /></div>

      <div className="mt-8 grid gap-9">
        <MockExamBreakdownSection
          title="Desempenho por Domain"
          description="Desempenho nas áreas curriculares avaliadas nesta tentativa."
          items={result.domains.map((item) => ({ label: item.domainTitle, percentage: item.percentage, correct: item.correctAnswers, total: item.totalQuestions, unanswered: item.unansweredQuestions }))}
        />
        <MockExamBreakdownSection
          title="Desempenho por Topic"
          description="Somente Topics que tiveram questões neste Mock, ordenados do menor para o maior desempenho."
          items={result.topics.map((item) => ({ label: item.topicTitle, percentage: item.percentage, correct: item.correctAnswers, total: item.totalQuestions, unanswered: item.unansweredQuestions }))}
        />
        <MockExamBreakdownSection
          title="Desempenho por dificuldade"
          description="Diagnóstico por dificuldade, sem inferir readiness para o exame oficial."
          items={result.difficulties.map((item) => ({ label: item.difficulty[0].toUpperCase() + item.difficulty.slice(1), percentage: item.percentage, correct: item.correctAnswers, total: item.totalQuestions, unanswered: item.unansweredQuestions }))}
        />
      </div>

      <section className="mt-9 rounded-2xl bg-slate-900 p-6 text-white sm:flex sm:items-center sm:justify-between sm:gap-6 sm:p-7">
        <div><h2 className="text-xl font-bold">Revisar questões</h2><p className="mt-1 text-sm leading-6 text-slate-300">Confira respostas, explicações e o contexto curricular desta tentativa concluída.</p></div>
        <Link to={mockExamReviewRoute(currentCertification.code, attemptId)} className="mt-5 inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-white px-5 text-sm font-bold text-slate-950 hover:bg-blue-50 sm:mt-0"><SearchCheck className="h-4 w-4" aria-hidden="true" />Revisar questões</Link>
      </section>
      <div className="mt-5 text-center">
        <button type="button" disabled={startingRetake} onClick={() => void handleRetake()} className="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-blue-600 px-5 text-sm font-bold text-white hover:bg-blue-700 disabled:cursor-wait disabled:opacity-60">
          {startingRetake && <LoaderCircle className="h-4 w-4 animate-spin" aria-hidden="true" />}
          {startingRetake ? 'Preparando seu Mock...' : 'Fazer outro Mock'}
        </button>
        {retakeError && <p role="alert" className="mt-3 text-sm font-semibold text-rose-700">{retakeError}</p>}
      </div>
    </div>
  )
}

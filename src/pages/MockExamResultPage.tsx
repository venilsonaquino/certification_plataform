import { ArrowLeft, SearchCheck } from 'lucide-react'
import { useCallback, useEffect, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { MockExamBreakdownSection } from '../components/mockExam/MockExamBreakdownSection'
import { MockExamResultSummary } from '../components/mockExam/MockExamResultSummary'
import { useCertification } from '../hooks/useCertification'
import { certificationRoute, mockExamExecutionRoute, mockExamReviewRoute } from '../lib/routes'
import { getMockExamAttempt, getMockExamResult } from '../services/mockExamService'
import type { MockExamResult } from '../types/mockExam'

const RESULT_ERROR = 'Não foi possível carregar o resultado deste Mock Exam.'

export function MockExamResultPage() {
  const { attemptId = '' } = useParams<{ attemptId: string }>()
  const { currentCertification } = useCertification()
  const navigate = useNavigate()
  const [result, setResult] = useState<MockExamResult | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const loadResult = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const attempt = await getMockExamAttempt(attemptId)
      if (!attempt || attempt.certificationId !== currentCertification.id) {
        setError(RESULT_ERROR)
        return
      }
      if (attempt.status === 'in_progress') {
        navigate(mockExamExecutionRoute(currentCertification.code, attempt.id), { replace: true })
        return
      }
      if (attempt.status !== 'completed') {
        setError('Este Mock Exam não possui um resultado disponível.')
        return
      }
      const loaded = await getMockExamResult(attemptId)
      if (!loaded) {
        setError(RESULT_ERROR)
        return
      }
      setResult(loaded)
    } catch (cause) {
      console.error('Falha ao carregar resultado do Mock Exam.', cause)
      setError(RESULT_ERROR)
    } finally {
      setLoading(false)
    }
  }, [attemptId, currentCertification.code, currentCertification.id, navigate])

  useEffect(() => {
    void loadResult()
  }, [loadResult])

  if (loading) return <CertificationDataState title="Loading your Mock result..." loading />
  if (error || !result) return <CertificationDataState title="Resultado indisponível." description={error ?? RESULT_ERROR} onRetry={() => void loadResult()} />

  return (
    <div className="mx-auto max-w-6xl">
      <Link to={certificationRoute(currentCertification.code, 'exams')} className="inline-flex min-h-10 items-center gap-2 text-sm font-bold text-blue-700"><ArrowLeft className="h-4 w-4" aria-hidden="true" />Voltar para Simulados</Link>
      <header className="mt-4">
        <p className="text-sm font-bold text-blue-700">AZ-900 · resultado de prática</p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">AZ-900 Practice Mock Result</h1>
      </header>

      <div className="mt-7"><MockExamResultSummary result={result} /></div>

      <div className="mt-8 grid gap-9">
        <MockExamBreakdownSection
          title="Domain Breakdown"
          description="Desempenho nas áreas curriculares avaliadas neste Attempt."
          items={result.domains.map((item) => ({ label: item.domainTitle, percentage: item.percentage, correct: item.correctAnswers, total: item.totalQuestions, unanswered: item.unansweredQuestions }))}
        />
        <MockExamBreakdownSection
          title="Topic Breakdown"
          description="Somente Topics que tiveram Questions neste Mock, ordenados do menor para o maior desempenho."
          items={result.topics.map((item) => ({ label: item.topicTitle, percentage: item.percentage, correct: item.correctAnswers, total: item.totalQuestions, unanswered: item.unansweredQuestions }))}
        />
        <MockExamBreakdownSection
          title="Difficulty Breakdown"
          description="Diagnóstico por dificuldade, sem inferir readiness para o exame oficial."
          items={result.difficulties.map((item) => ({ label: item.difficulty[0].toUpperCase() + item.difficulty.slice(1), percentage: item.percentage, correct: item.correctAnswers, total: item.totalQuestions, unanswered: item.unansweredQuestions }))}
        />
      </div>

      <section className="mt-9 rounded-2xl bg-slate-900 p-6 text-white sm:flex sm:items-center sm:justify-between sm:gap-6 sm:p-7">
        <div><h2 className="text-xl font-bold">Review Questions</h2><p className="mt-1 text-sm leading-6 text-slate-300">Confira respostas, explicações e o contexto curricular deste Attempt concluído.</p></div>
        <Link to={mockExamReviewRoute(currentCertification.code, attemptId)} className="mt-5 inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-white px-5 text-sm font-bold text-slate-950 hover:bg-blue-50 sm:mt-0"><SearchCheck className="h-4 w-4" aria-hidden="true" />Review Questions</Link>
      </section>
    </div>
  )
}

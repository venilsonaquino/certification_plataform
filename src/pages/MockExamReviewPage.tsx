import { ArrowLeft } from 'lucide-react'
import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { MockReviewQuestionCard } from '../components/mockExam/MockReviewQuestionCard'
import { useCertification } from '../hooks/useCertification'
import { mockExamExecutionRoute, mockExamResultRoute } from '../lib/routes'
import { getMockExamAttempt, getMockExamReview } from '../services/mockExamService'
import type { MockExamQuestionForReview, MockExamReviewStatus } from '../types/mockExam'

type ReviewFilter = 'needs_review' | 'all' | MockExamReviewStatus

const filters: readonly { value: ReviewFilter; label: string }[] = [
  { value: 'needs_review', label: 'Incorretas + não respondidas' },
  { value: 'all', label: 'Todas' },
  { value: 'incorrect', label: 'Incorretas' },
  { value: 'unanswered', label: 'Não respondidas' },
  { value: 'correct', label: 'Corretas' },
]

const REVIEW_ERROR = 'Não foi possível carregar a revisão deste Mock Exam.'

export function MockExamReviewPage() {
  const { attemptId = '' } = useParams<{ attemptId: string }>()
  const { currentCertification } = useCertification()
  const navigate = useNavigate()
  const resultHeadingRef = useRef<HTMLHeadingElement>(null)
  const [questions, setQuestions] = useState<MockExamQuestionForReview[]>([])
  const [filter, setFilter] = useState<ReviewFilter>('needs_review')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const loadReview = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const attempt = await getMockExamAttempt(attemptId)
      if (!attempt || attempt.certificationId !== currentCertification.id) {
        setError(REVIEW_ERROR)
        return
      }
      if (attempt.status === 'in_progress') {
        navigate(mockExamExecutionRoute(currentCertification.code, attempt.id), { replace: true })
        return
      }
      if (attempt.status !== 'completed' && attempt.status !== 'expired') {
        setError('Este Mock Exam não está disponível para Review.')
        return
      }
      const loaded = await getMockExamReview(attemptId)
      if (loaded.length !== attempt.totalQuestions) {
        setError(REVIEW_ERROR)
        return
      }
      setQuestions(loaded)
    } catch (cause) {
      console.error('Falha ao carregar Review do Mock Exam.', cause)
      setError(REVIEW_ERROR)
    } finally {
      setLoading(false)
    }
  }, [attemptId, currentCertification.code, currentCertification.id, navigate])

  useEffect(() => {
    void loadReview()
  }, [loadReview])

  const visibleQuestions = useMemo(() => questions.filter((question) => {
    if (filter === 'all') return true
    if (filter === 'needs_review') return question.status !== 'correct'
    return question.status === filter
  }), [filter, questions])

  const applyFilter = (nextFilter: ReviewFilter) => {
    setFilter(nextFilter)
    requestAnimationFrame(() => resultHeadingRef.current?.focus())
  }

  if (loading) return <CertificationDataState title="Carregando a revisão do Mock..." loading />
  if (error) return <CertificationDataState title="Revisão indisponível." description={error} onRetry={() => void loadReview()} />

  return (
    <div className="mx-auto max-w-4xl">
      <Link to={mockExamResultRoute(currentCertification.code, attemptId)} className="inline-flex min-h-10 items-center gap-2 text-sm font-bold text-blue-700"><ArrowLeft className="h-4 w-4" aria-hidden="true" />Voltar ao resultado</Link>
      <header className="mt-4">
        <p className="text-sm font-bold text-blue-700">AZ-900 · revisão pós-Mock</p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">Revisão das questões</h1>
        <p className="mt-2 text-sm leading-6 text-slate-600">Respostas corretas e explicações são exibidas somente após a finalização da tentativa.</p>
      </header>

      <nav aria-label="Filtros do Review" className="mt-6 flex gap-2 overflow-x-auto pb-2">
        {filters.map((item) => (
          <button key={item.value} type="button" aria-pressed={filter === item.value} onClick={() => applyFilter(item.value)} className={`min-h-10 shrink-0 rounded-full border px-4 text-sm font-bold ${filter === item.value ? 'border-blue-600 bg-blue-600 text-white' : 'border-slate-300 bg-white text-slate-700 hover:border-blue-300'}`}>{item.label}</button>
        ))}
      </nav>

      <h2 ref={resultHeadingRef} tabIndex={-1} className="mt-5 text-sm font-semibold text-slate-600 outline-none" aria-live="polite">
        {visibleQuestions.length} de {questions.length} questões exibidas
      </h2>
      <div className="mt-4 grid gap-5">
        {visibleQuestions.map((question) => <MockReviewQuestionCard key={question.id} question={question} certificationCode={currentCertification.code} />)}
        {visibleQuestions.length === 0 && <p className="rounded-2xl border border-slate-200 bg-white p-8 text-center text-sm text-slate-600">Nenhuma questão corresponde a este filtro.</p>}
      </div>
    </div>
  )
}

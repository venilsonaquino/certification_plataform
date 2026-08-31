import { ArrowLeft, ArrowRight, CheckCircle2, Send } from 'lucide-react'
import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { MockQuestion } from '../components/mockExam/MockQuestion'
import { MockQuestionNavigator } from '../components/mockExam/MockQuestionNavigator'
import { MockSubmitDialog } from '../components/mockExam/MockSubmitDialog'
import { MockExamTimer } from '../components/mockExam/MockExamTimer'
import { useCertification } from '../hooks/useCertification'
import { mockExamResultRoute } from '../lib/routes'
import {
  loadMockExamAttempt,
  saveMockExamAnswer,
  submitMockExam,
  syncMockExamAttempt,
} from '../services/mockExamService'
import type {
  MockExamAnswerState,
  MockExamAttemptData,
  MockExamQuestionForExecution,
} from '../types/mockExam'

const LOAD_ERROR = 'Não foi possível carregar este Mock Exam.'
const SAVE_ERROR = 'A resposta ainda não foi salva.'
const EXPECTED_QUESTIONS = 40

function createAnswerState(question: MockExamQuestionForExecution): MockExamAnswerState {
  return {
    selectedOptionKey: question.selectedOptionKey,
    persistedOptionKey: question.selectedOptionKey,
    status: 'idle',
    error: null,
  }
}

export function MockExamExecutionPage() {
  const { attemptId = '' } = useParams<{ attemptId: string }>()
  const { currentCertification } = useCertification()
  const navigate = useNavigate()
  const submitInFlight = useRef(false)
  const expirationInFlight = useRef(false)
  const [data, setData] = useState<MockExamAttemptData | null>(null)
  const [answers, setAnswers] = useState<Record<string, MockExamAnswerState>>({})
  const [currentIndex, setCurrentIndex] = useState(0)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [showSummary, setShowSummary] = useState(false)
  const [dialogOpen, setDialogOpen] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [submitError, setSubmitError] = useState<string | null>(null)
  const [serverNow, setServerNow] = useState<string | null>(null)

  const loadAttempt = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const session = await syncMockExamAttempt(attemptId)
      const attempt = session?.attempt ?? null
      if (!attempt || attempt.certificationId !== currentCertification.id) {
        setError(LOAD_ERROR)
        return
      }
      if (attempt.status === 'completed' || attempt.status === 'expired') {
        navigate(mockExamResultRoute(currentCertification.code, attempt.id), { replace: true })
        return
      }
      if (attempt.status !== 'in_progress') {
        setError('Este Mock Exam não está mais disponível para edição.')
        return
      }
      setServerNow(session?.serverNow ?? null)

      const loaded = await loadMockExamAttempt(attemptId, attempt)
      if (!loaded || loaded.questions.length !== EXPECTED_QUESTIONS) {
        setError(LOAD_ERROR)
        return
      }
      setData(loaded)
      setAnswers(
        Object.fromEntries(loaded.questions.map((question) => [question.id, createAnswerState(question)])),
      )
      const storedPosition = Number(sessionStorage.getItem(`mock-position:${attemptId}`))
      setCurrentIndex(
        Number.isInteger(storedPosition) && storedPosition >= 0 && storedPosition < loaded.questions.length
          ? storedPosition
          : 0,
      )
    } catch (cause) {
      console.error('Falha ao carregar Mock Exam.', cause)
      setError(LOAD_ERROR)
    } finally {
      setLoading(false)
    }
  }, [attemptId, currentCertification.code, currentCertification.id, navigate])

  const handleExpiration = useCallback(async () => {
    if (expirationInFlight.current) return
    expirationInFlight.current = true
    setSubmitting(true)
    setDialogOpen(false)
    try {
      const session = await syncMockExamAttempt(attemptId)
      if (session?.attempt.status === 'expired' || session?.attempt.status === 'completed') {
        sessionStorage.removeItem(`mock-position:${attemptId}`)
        navigate(mockExamResultRoute(currentCertification.code, attemptId), { replace: true })
        return
      }
      await loadAttempt()
    } catch (cause) {
      console.error('Falha ao finalizar Mock Exam expirado.', cause)
      setSubmitError('O tempo terminou. Recarregue para abrir o resultado finalizado com segurança.')
    } finally {
      setSubmitting(false)
      expirationInFlight.current = false
    }
  }, [attemptId, currentCertification.code, loadAttempt, navigate])

  useEffect(() => {
    void loadAttempt()
  }, [loadAttempt])

  const navigateTo = (index: number) => {
    setCurrentIndex(index)
    setShowSummary(false)
    sessionStorage.setItem(`mock-position:${attemptId}`, String(index))
  }

  const persistAnswer = async (question: MockExamQuestionForExecution, optionKey: string) => {
    setAnswers((current) => ({
      ...current,
      [question.id]: {
        selectedOptionKey: optionKey,
        persistedOptionKey: current[question.id]?.persistedOptionKey ?? null,
        status: 'saving',
        error: null,
      },
    }))
    try {
      const saved = await saveMockExamAnswer({
        attemptId,
        attemptQuestionId: question.id,
        selectedOptionKey: optionKey,
      })
      setAnswers((current) => ({
        ...current,
        [question.id]: {
          selectedOptionKey: saved.selectedOptionKey,
          persistedOptionKey: saved.selectedOptionKey,
          status: 'saved',
          error: null,
        },
      }))
    } catch (cause) {
      console.error('Falha ao salvar resposta do Mock Exam.', cause)
      setAnswers((current) => ({
        ...current,
        [question.id]: {
          ...current[question.id],
          status: 'error',
          error: SAVE_ERROR,
        },
      }))
    }
  }

  const answeredIndexes = useMemo(() => {
    if (!data) return new Set<number>()
    return new Set(
      data.questions.flatMap((question, index) =>
        answers[question.id]?.persistedOptionKey ? [index] : [],
      ),
    )
  }, [answers, data])
  const answeredCount = answeredIndexes.size
  const hasPendingSave = Object.values(answers).some((answer) => answer.status === 'saving')

  const handleSubmit = async () => {
    if (submitInFlight.current) return
    submitInFlight.current = true
    setSubmitting(true)
    setSubmitError(null)
    try {
      await submitMockExam(attemptId)
      sessionStorage.removeItem(`mock-position:${attemptId}`)
      navigate(mockExamResultRoute(currentCertification.code, attemptId), { replace: true })
    } catch (cause) {
      console.error('Falha ao enviar Mock Exam.', cause)
      setSubmitError('Não foi possível enviar o Mock. Suas respostas salvas continuam seguras.')
      setSubmitting(false)
    } finally {
      submitInFlight.current = false
    }
  }

  if (loading) return <CertificationDataState title="Carregando seu Mock Exam..." loading />
  if (error || !data) {
    return (
      <CertificationDataState
        title="Mock Exam indisponível."
        description={error ?? LOAD_ERROR}
        onRetry={() => void loadAttempt()}
      />
    )
  }

  const currentQuestion = data.questions[currentIndex]
  const currentAnswer = answers[currentQuestion.id] ?? createAnswerState(currentQuestion)

  return (
    <div className="mx-auto max-w-6xl">
      <header className="border-b border-slate-200 pb-5">
        <div className="flex flex-col gap-4 sm:flex-row sm:flex-wrap sm:items-center sm:justify-between">
          <div>
            <p className="text-sm font-bold text-blue-700">AZ-900 · Practice Mock</p>
            <h1 className="mt-1 text-2xl font-bold text-slate-950 sm:text-3xl">AZ-900 Practice Mock</h1>
            <p aria-live="polite" className="mt-2 text-sm font-semibold text-slate-600">
              {showSummary ? 'Revisar respostas' : `Questão ${currentIndex + 1} de ${data.questions.length}`}
              {' · '}{answeredCount} respondidas
            </p>
          </div>
          {data.attempt.expiresAt && serverNow && (
            <MockExamTimer expiresAt={data.attempt.expiresAt} serverNow={serverNow} onExpire={handleExpiration} />
          )}
          <button
            type="button"
            disabled={hasPendingSave}
            onClick={() => setShowSummary(true)}
            className="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-slate-900 px-5 text-sm font-bold text-white hover:bg-slate-800 disabled:cursor-wait disabled:opacity-60"
          >
            <Send className="h-4 w-4" aria-hidden="true" />Finalizar
          </button>
        </div>
        <div
          role="progressbar"
          aria-label="Progresso de navegação do Mock"
          aria-valuemin={1}
          aria-valuemax={data.questions.length}
          aria-valuenow={currentIndex + 1}
          className="mt-5 h-2 overflow-hidden rounded-full bg-slate-200"
        >
          <div className="h-full rounded-full bg-blue-600" style={{ width: `${((currentIndex + 1) / data.questions.length) * 100}%` }} />
        </div>
      </header>

      <div className="mt-6 grid gap-6 lg:grid-cols-[minmax(0,1fr)_16rem]">
        <main>
          {showSummary ? (
            <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-card sm:p-8">
              <CheckCircle2 className="h-9 w-9 text-blue-600" aria-hidden="true" />
              <h2 className="mt-4 text-2xl font-bold text-slate-950">Revisar respostas</h2>
              <div className="mt-5 grid gap-3 sm:grid-cols-3">
                <p className="rounded-xl bg-slate-50 p-4"><strong className="block text-2xl text-slate-950">{data.questions.length}</strong><span className="text-sm text-slate-600">Questões</span></p>
                <p className="rounded-xl bg-blue-50 p-4"><strong className="block text-2xl text-blue-800">{answeredCount}</strong><span className="text-sm text-blue-700">Respondidas</span></p>
                <p className="rounded-xl bg-amber-50 p-4"><strong className="block text-2xl text-amber-800">{data.questions.length - answeredCount}</strong><span className="text-sm text-amber-700">Não respondidas</span></p>
              </div>
              {answeredCount < data.questions.length && (
                <p className="mt-5 rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm font-semibold text-amber-800">
                  Questões não respondidas serão registradas separadamente. Você ainda pode enviar.
                </p>
              )}
              <div className="mt-7 flex flex-col gap-3 sm:flex-row">
                <button type="button" onClick={() => setShowSummary(false)} className="min-h-11 rounded-xl border border-slate-300 px-5 text-sm font-bold text-slate-700 hover:bg-slate-50">Voltar ao Mock</button>
                <button type="button" disabled={hasPendingSave} onClick={() => setDialogOpen(true)} className="min-h-11 rounded-xl bg-blue-600 px-5 text-sm font-bold text-white hover:bg-blue-700 disabled:cursor-wait disabled:opacity-60">Enviar Mock</button>
              </div>
            </section>
          ) : (
            <>
              <MockQuestion
                question={currentQuestion}
                answer={currentAnswer}
                onSelect={(optionKey) => void persistAnswer(currentQuestion, optionKey)}
                onRetry={() => {
                  if (currentAnswer.selectedOptionKey) void persistAnswer(currentQuestion, currentAnswer.selectedOptionKey)
                }}
              />
              <div className="mt-5 flex items-center justify-between gap-3">
                <button type="button" disabled={currentIndex === 0} onClick={() => navigateTo(currentIndex - 1)} className="inline-flex min-h-11 items-center gap-2 rounded-xl border border-slate-300 px-4 text-sm font-bold text-slate-700 hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"><ArrowLeft className="h-4 w-4" aria-hidden="true" />Anterior</button>
                <button type="button" onClick={() => currentIndex === data.questions.length - 1 ? setShowSummary(true) : navigateTo(currentIndex + 1)} className="inline-flex min-h-11 items-center gap-2 rounded-xl bg-blue-600 px-4 text-sm font-bold text-white hover:bg-blue-700">{currentIndex === data.questions.length - 1 ? 'Revisar respostas' : 'Próxima'}<ArrowRight className="h-4 w-4" aria-hidden="true" /></button>
              </div>
            </>
          )}
        </main>

        <aside>
          <MockQuestionNavigator
            total={data.questions.length}
            currentIndex={currentIndex}
            answeredIndexes={answeredIndexes}
            onNavigate={navigateTo}
          />
        </aside>
      </div>

      <MockSubmitDialog
        open={dialogOpen}
        answered={answeredCount}
        total={data.questions.length}
        submitting={submitting}
        error={submitError}
        onCancel={() => {
          setDialogOpen(false)
          setSubmitError(null)
        }}
        onConfirm={() => void handleSubmit()}
      />
    </div>
  )
}

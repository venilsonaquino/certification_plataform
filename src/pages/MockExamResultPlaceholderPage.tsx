import { CheckCircle2 } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { useCertification } from '../hooks/useCertification'
import { certificationRoute, mockExamExecutionRoute } from '../lib/routes'
import { getMockExamAttempt } from '../services/mockExamService'

export function MockExamResultPlaceholderPage() {
  const { attemptId = '' } = useParams<{ attemptId: string }>()
  const { currentCertification } = useCertification()
  const navigate = useNavigate()
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let active = true
    void getMockExamAttempt(attemptId)
      .then((attempt) => {
        if (!active) return
        if (!attempt || attempt.certificationId !== currentCertification.id) {
          setError('Este Mock Exam não foi encontrado.')
        } else if (attempt.status === 'in_progress') {
          navigate(mockExamExecutionRoute(currentCertification.code, attempt.id), { replace: true })
        } else if (attempt.status !== 'completed') {
          setError('Este Mock Exam não possui um resultado disponível.')
        }
      })
      .catch((cause: unknown) => {
        console.error('Falha ao carregar confirmação do Mock Exam.', cause)
        if (active) setError('Não foi possível carregar este Mock Exam.')
      })
      .finally(() => {
        if (active) setLoading(false)
      })
    return () => {
      active = false
    }
  }, [attemptId, currentCertification.code, currentCertification.id, navigate])

  if (loading) return <CertificationDataState title="Confirmando o envio..." loading />
  if (error) return <CertificationDataState title="Resultado indisponível." description={error} />

  return (
    <section className="mx-auto max-w-2xl rounded-3xl border border-slate-200 bg-white p-8 text-center shadow-card">
      <CheckCircle2 className="mx-auto h-12 w-12 text-emerald-600" aria-hidden="true" />
      <h1 className="mt-5 text-3xl font-bold text-slate-950">Mock submitted successfully.</h1>
      <p className="mt-3 text-sm leading-6 text-slate-600">
        Sua tentativa foi encerrada e não pode mais ser alterada. A análise detalhada será disponibilizada na próxima etapa.
      </p>
      <Link to={certificationRoute(currentCertification.code, 'dashboard')} className="mt-7 inline-flex min-h-11 items-center justify-center rounded-xl bg-blue-600 px-6 text-sm font-bold text-white hover:bg-blue-700">Back to Certification</Link>
    </section>
  )
}

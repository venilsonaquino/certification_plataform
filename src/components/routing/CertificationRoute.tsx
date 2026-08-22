import { useEffect, useState } from 'react'
import { Outlet, useParams } from 'react-router-dom'

import { CertificationProvider } from '../../contexts/CertificationProvider'
import { CertificationStatusLayout } from '../../layouts/CertificationStatusLayout'
import { getCertificationByCode } from '../../services/certificationService'
import type { Certification } from '../../types/certification'

export function CertificationRoute() {
  const { certificationCode } = useParams<{ certificationCode: string }>()
  const [certification, setCertification] = useState<Certification | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [attempt, setAttempt] = useState(0)

  useEffect(() => {
    let active = true

    setLoading(true)
    setError(null)
    setCertification(null)

    if (!certificationCode) {
      setLoading(false)
      return () => {
        active = false
      }
    }

    void getCertificationByCode(certificationCode)
      .then((result) => {
        if (active) {
          setCertification(result)
          setLoading(false)
        }
      })
      .catch(() => {
        if (active) {
          setError('Não foi possível consultar esta certificação.')
          setLoading(false)
        }
      })

    return () => {
      active = false
    }
  }, [attempt, certificationCode])

  if (loading) {
    return <CertificationStatusLayout title="Carregando certificação..." loading />
  }

  if (error) {
    return (
      <CertificationStatusLayout
        title="Não foi possível carregar a certificação."
        description={error}
        onRetry={() => setAttempt((current) => current + 1)}
        showBackLink
      />
    )
  }

  if (!certification) {
    return (
      <CertificationStatusLayout
        title="Certificação não encontrada."
        description="Verifique o endereço ou escolha uma certificação disponível."
        showBackLink
      />
    )
  }

  if (!certification.isEnabled) {
    return (
      <CertificationStatusLayout
        title="Certificação em breve."
        description="Esta jornada já está cadastrada, mas ainda não foi habilitada."
        showBackLink
      />
    )
  }

  return (
    <CertificationProvider certification={certification}>
      <Outlet />
    </CertificationProvider>
  )
}

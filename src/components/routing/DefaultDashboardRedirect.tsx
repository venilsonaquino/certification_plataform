import { useEffect, useState } from 'react'
import { Navigate } from 'react-router-dom'

import { CertificationStatusLayout } from '../../layouts/CertificationStatusLayout'
import { certificationRoute } from '../../lib/routes'
import { getCertifications } from '../../services/certificationService'
import type { Certification } from '../../types/certification'

export function DefaultDashboardRedirect() {
  const [defaultCertification, setDefaultCertification] = useState<Certification | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(false)
  const [attempt, setAttempt] = useState(0)

  useEffect(() => {
    let active = true

    setLoading(true)
    setError(false)

    void getCertifications()
      .then((items) => {
        if (active) {
          setDefaultCertification(items.find((certification) => certification.isEnabled) ?? null)
          setLoading(false)
        }
      })
      .catch(() => {
        if (active) {
          setError(true)
          setLoading(false)
        }
      })

    return () => {
      active = false
    }
  }, [attempt])

  if (loading) {
    return <CertificationStatusLayout title="Carregando sua jornada..." loading />
  }

  if (error) {
    return (
      <CertificationStatusLayout
        title="Não foi possível carregar as certificações."
        onRetry={() => setAttempt((current) => current + 1)}
      />
    )
  }

  if (!defaultCertification) {
    return <Navigate to="/certifications" replace />
  }

  return <Navigate to={certificationRoute(defaultCertification.code, 'dashboard')} replace />
}

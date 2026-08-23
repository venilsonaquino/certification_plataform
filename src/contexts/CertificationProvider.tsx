import { type ReactNode, useMemo } from 'react'

import type { Certification } from '../types/certification'
import { CertificationContext, type CertificationContextValue } from './CertificationContext'
import { CertificationProgressProvider } from './CertificationProgressProvider'

interface CertificationProviderProps {
  certification: Certification
  children: ReactNode
}

export function CertificationProvider({ certification, children }: CertificationProviderProps) {
  const value = useMemo<CertificationContextValue>(
    () => ({
      currentCertification: certification,
      certificationCode: certification.code,
    }),
    [certification],
  )

  return (
    <CertificationContext.Provider value={value}>
      <CertificationProgressProvider certificationId={certification.id}>
        {children}
      </CertificationProgressProvider>
    </CertificationContext.Provider>
  )
}

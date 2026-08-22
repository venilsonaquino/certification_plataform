import { type ReactNode, useMemo } from 'react'

import type { Certification } from '../types/certification'
import { CertificationContext, type CertificationContextValue } from './CertificationContext'

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

  return <CertificationContext.Provider value={value}>{children}</CertificationContext.Provider>
}

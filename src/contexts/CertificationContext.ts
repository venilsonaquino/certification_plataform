import { createContext } from 'react'

import type { Certification } from '../types/certification'

export interface CertificationContextValue {
  currentCertification: Certification
  certificationCode: string
}

export const CertificationContext = createContext<CertificationContextValue | undefined>(undefined)

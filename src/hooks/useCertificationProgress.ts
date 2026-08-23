import { useContext } from 'react'

import { CertificationProgressContext } from '../contexts/CertificationProgressContext'

export function useCertificationProgress() {
  const context = useContext(CertificationProgressContext)

  if (!context) {
    throw new Error('useCertificationProgress deve ser usado dentro de CertificationProgressProvider')
  }

  return context
}

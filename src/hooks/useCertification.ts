import { useContext } from 'react'

import { CertificationContext } from '../contexts/CertificationContext'

export function useCertification() {
  const context = useContext(CertificationContext)

  if (!context) {
    throw new Error('useCertification deve ser usado dentro de CertificationProvider')
  }

  return context
}

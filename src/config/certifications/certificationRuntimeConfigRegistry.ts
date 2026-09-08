import type { CertificationRuntimeConfig } from './certificationRuntimeConfig'
import { AZ900_RUNTIME_CONFIG } from './az900RuntimeConfig'

export class CertificationRuntimeConfigNotFoundError extends Error {
  readonly certificationCode: string

  constructor(certificationCode: string) {
    super(`No runtime configuration is registered for Certification "${certificationCode}".`)
    this.name = 'CertificationRuntimeConfigNotFoundError'
    this.certificationCode = certificationCode
  }
}

const certificationRuntimeConfigRegistry: ReadonlyMap<string, CertificationRuntimeConfig> =
  new Map([[AZ900_RUNTIME_CONFIG.certificationCode, AZ900_RUNTIME_CONFIG]])

function normalizeCertificationCode(certificationCode: string) {
  return certificationCode.trim().toLowerCase()
}

export function getCertificationRuntimeConfig(
  certificationCode: string,
): CertificationRuntimeConfig {
  const normalizedCode = normalizeCertificationCode(certificationCode)
  const config = certificationRuntimeConfigRegistry.get(normalizedCode)

  if (!config) {
    throw new CertificationRuntimeConfigNotFoundError(normalizedCode)
  }

  return config
}

export function hasCertificationRuntimeConfig(certificationCode: string): boolean {
  return certificationRuntimeConfigRegistry.has(normalizeCertificationCode(certificationCode))
}

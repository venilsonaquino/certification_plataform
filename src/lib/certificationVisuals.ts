const certificationColors = ['#0ea5e9', '#2563eb', '#4f46e5', '#7c3aed', '#0891b2'] as const

export function getCertificationColor(code: string) {
  const colorIndex = [...code].reduce((total, character) => total + character.charCodeAt(0), 0)
  return certificationColors[colorIndex % certificationColors.length]
}

export function formatCertificationCode(code: string) {
  return code.toUpperCase()
}

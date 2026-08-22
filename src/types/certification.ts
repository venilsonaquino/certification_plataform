export interface Certification {
  readonly id: string
  readonly code: string
  readonly name: string
  readonly provider: string
  readonly description: string | null
  readonly level: string | null
  readonly isEnabled: boolean
  readonly displayOrder: number
  readonly createdAt: string
  readonly updatedAt: string
}

import type { LucideIcon } from 'lucide-react'
import type { CertificationSection } from '../lib/routes'

export interface NavigationItem {
  label: string
  segment: CertificationSection
  icon: LucideIcon
}

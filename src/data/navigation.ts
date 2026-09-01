import {
  BookOpen,
  CalendarCheck2,
  Gauge,
  HeartPulse,
  Layers3,
  MapPinned,
  RefreshCcw,
  Trophy,
} from 'lucide-react'

import type { NavigationItem } from '../types/navigation'

export const navigationItems: NavigationItem[] = [
  { label: 'Dashboard', segment: 'dashboard', icon: Gauge },
  { label: 'Estudo do Dia', segment: 'study-today', icon: CalendarCheck2 },
  { label: 'Trilha de estudos', segment: 'study', icon: BookOpen },
  { label: 'Flashcards', segment: 'flashcards', icon: Layers3 },
  { label: 'Revisão', segment: 'review', icon: RefreshCcw },
  { label: 'Simulados', segment: 'exams', icon: MapPinned },
  { label: 'Readiness', segment: 'readiness', icon: HeartPulse },
  { label: 'Progresso de estudo', segment: 'progress', icon: Trophy },
]

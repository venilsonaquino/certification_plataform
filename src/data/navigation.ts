import {
  BookOpen,
  BrainCircuit,
  FlaskConical,
  Gauge,
  Map,
  MapPinned,
  RefreshCcw,
  Route,
  Trophy,
} from 'lucide-react'

import type { NavigationItem } from '../types/navigation'

export const navigationItems: NavigationItem[] = [
  { label: 'Dashboard', segment: 'dashboard', icon: Gauge },
  { label: 'Estudo do Dia', segment: 'study', icon: BookOpen },
  { label: 'Mapa', segment: 'map', icon: Map },
  { label: 'Laboratórios', segment: 'labs', icon: FlaskConical },
  { label: 'Story Mode', segment: 'story', icon: Route },
  { label: 'Quiz', segment: 'quiz', icon: BrainCircuit },
  { label: 'Revisão', segment: 'review', icon: RefreshCcw },
  { label: 'Simulados', segment: 'exams', icon: MapPinned },
  { label: 'Progresso', segment: 'progress', icon: Trophy },
]

import type {
  EvidenceLevel,
  GlobalReadinessClassification,
  PerformanceTrend,
  ScopedReadinessClassification,
} from '../../types/readiness'
import type {
  StudyRecommendationActionType,
  StudyRecommendationPriority,
  StudyRecommendationReasonCode,
} from '../../types/studyRecommendation'

export const globalStatusLabels: Record<GlobalReadinessClassification, string> = {
  not_enough_evidence: 'Not Enough Evidence',
  needs_review: 'Needs Review',
  developing: 'Developing',
  strong: 'Strong',
}

export const scopedStatusLabels: Record<ScopedReadinessClassification, string> = {
  insufficient_evidence: 'Insufficient Evidence',
  needs_review: 'Needs Review',
  developing: 'Developing',
  strong: 'Strong',
}

export const statusDescriptions: Record<GlobalReadinessClassification, string> = {
  not_enough_evidence: 'Precisamos de mais prática avaliada antes de estimar seu preparo com confiança.',
  needs_review: 'A evidência recente aponta áreas importantes para revisar antes de avançar.',
  developing: 'Você está progredindo, mas alguns tópicos ainda precisam de prática e confirmação.',
  strong: 'Sua prática recente mostra desempenho consistente na maior parte do AZ-900.',
}

export const evidenceLabels: Record<EvidenceLevel, string> = {
  insufficient: 'Insufficient',
  limited: 'Limited',
  sufficient: 'Sufficient',
  strong: 'Strong',
}

export const trendLabels: Record<PerformanceTrend, string> = {
  improving: 'Improving',
  stable: 'Stable',
  declining: 'Declining',
  insufficient_data: 'Insufficient Data',
}

export const priorityLabels: Record<StudyRecommendationPriority, string> = {
  critical: 'Critical',
  high: 'High',
  medium: 'Medium',
  low: 'Low',
}

export const recommendationReasonLabels: Record<StudyRecommendationReasonCode, string> = {
  confirmed_weak_topic: 'A lacuna foi confirmada por evidências concordantes',
  low_mock_performance: 'Baixo desempenho nos simulados recentes',
  repeated_mock_errors: 'Erros repetidos em simulados',
  low_topic_quiz_performance: 'Baixo desempenho em Checkpoints de Tópico',
  repeated_topic_quiz_errors: 'Erros repetidos em Checkpoints de Tópico',
  declining_trend: 'A performance recente está diminuindo',
  inconsistent_performance: 'A performance ainda está inconsistente',
  insufficient_evidence: 'É necessário praticar mais para avaliar este tópico',
  stale_evidence: 'A evidência disponível está antiga',
  domain_weakness: 'Este tópico pertence a um domínio que precisa de revisão',
  developing_performance: 'A performance ainda está em desenvolvimento',
  improving_performance: 'A performance recente está melhorando',
}

export const actionLabels: Record<StudyRecommendationActionType, string> = {
  review_lesson: 'Revisar aula',
  review_flashcards: 'Revisar Flashcards',
  retake_topic_quiz: 'Refazer Checkpoint',
  assess_topic: 'Fazer Checkpoint',
  take_another_mock: 'Fazer Mock Exam',
}

export const statusTone: Record<
  GlobalReadinessClassification | ScopedReadinessClassification,
  string
> = {
  not_enough_evidence: 'border-slate-300 bg-slate-100 text-slate-700',
  insufficient_evidence: 'border-slate-300 bg-slate-100 text-slate-700',
  needs_review: 'border-amber-300 bg-amber-50 text-amber-800',
  developing: 'border-blue-300 bg-blue-50 text-blue-800',
  strong: 'border-emerald-300 bg-emerald-50 text-emerald-800',
}

export const priorityTone: Record<StudyRecommendationPriority, string> = {
  critical: 'border-rose-300 bg-rose-50 text-rose-800',
  high: 'border-amber-300 bg-amber-50 text-amber-800',
  medium: 'border-blue-300 bg-blue-50 text-blue-800',
  low: 'border-slate-300 bg-slate-100 text-slate-700',
}

export function formatReadinessDate(value: string | null): string {
  if (!value) return 'Ainda não avaliado'
  return new Intl.DateTimeFormat('pt-BR', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(new Date(value))
}

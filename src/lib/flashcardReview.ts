import type { UserFlashcardProgress } from '../types/flashcard'

export function formatReviewDate(value: string) {
  return new Intl.DateTimeFormat('pt-BR', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(new Date(value))
}

export function getScheduleFeedback(progress: UserFlashcardProgress) {
  if (progress.lastRating === 'again') {
    return 'Revisaremos novamente em 1 dia.'
  }

  return `Próxima revisão em ${progress.intervalDays} ${progress.intervalDays === 1 ? 'dia' : 'dias'}.`
}

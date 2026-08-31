import type { MockExamHistoryItem } from '../../types/mockExam'

export function MockExamScoreHistory({ items }: { items: readonly MockExamHistoryItem[] }) {
  const scores = items.filter((item) => item.status === 'completed' || item.status === 'expired').slice(0, 5).reverse()
  if (scores.length === 0) return null
  return (
    <section aria-labelledby="recent-scores-title" className="mt-8 rounded-3xl bg-slate-900 p-6 text-white sm:p-8">
      <h2 id="recent-scores-title" className="text-xl font-bold">Practice Scores recentes</h2>
      <p className="mt-1 text-sm text-slate-300">Resultados objetivos das tentativas mais recentes; não representam um Readiness Score.</p>
      <ol className="mt-5 grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
        {scores.map((item) => <li key={item.attemptId} className="rounded-2xl bg-white/10 p-4"><span className="block text-sm font-semibold text-slate-300">Mock #{item.attemptNumber}</span><strong className="mt-1 block text-2xl">{item.practiceScorePercentage}%</strong></li>)}
      </ol>
    </section>
  )
}

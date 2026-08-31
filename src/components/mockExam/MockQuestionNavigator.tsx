interface MockQuestionNavigatorProps {
  total: number
  currentIndex: number
  answeredIndexes: ReadonlySet<number>
  onNavigate: (index: number) => void
}

export function MockQuestionNavigator({ total, currentIndex, answeredIndexes, onNavigate }: MockQuestionNavigatorProps) {
  return (
    <nav aria-label="Navegador de questões" className="rounded-2xl border border-slate-200 bg-white p-4 shadow-card">
      <div className="mb-4 flex flex-wrap gap-x-4 gap-y-2 text-xs font-semibold text-slate-600">
        <span>Atual: contorno azul</span><span>Respondida: fundo azul</span><span>Não respondida: fundo branco</span>
      </div>
      <ol className="grid grid-cols-8 gap-2 sm:grid-cols-10 lg:grid-cols-5">
        {Array.from({ length: total }, (_, index) => {
          const current = index === currentIndex
          const answered = answeredIndexes.has(index)
          const state = current ? 'atual' : answered ? 'respondida' : 'não respondida'
          return (
            <li key={index}>
              <button type="button" aria-current={current ? 'step' : undefined} aria-label={`Questão ${index + 1}, ${state}`} onClick={() => onNavigate(index)} className={`grid h-10 w-full place-items-center rounded-lg border text-sm font-bold transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 ${current ? 'border-blue-600 ring-2 ring-blue-200' : answered ? 'border-blue-600 bg-blue-600 text-white hover:bg-blue-700' : 'border-slate-200 bg-white text-slate-600 hover:border-blue-300'}`}>
                {index + 1}
              </button>
            </li>
          )
        })}
      </ol>
    </nav>
  )
}

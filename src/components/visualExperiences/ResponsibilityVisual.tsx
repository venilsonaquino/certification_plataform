import { ArrowRight, Cloud, Code2, Handshake, UserRound } from 'lucide-react'
import { useId, useRef, useState, type KeyboardEvent } from 'react'

import type {
  ResponsibilityOwner,
  ResponsibilityVisualExperience,
} from '../../types/visualExperience'

interface ResponsibilityVisualProps {
  experience: ResponsibilityVisualExperience
}

const ownerPresentation = {
  customer: {
    icon: UserRound,
    badge: 'border-amber-200 bg-amber-50 text-amber-900',
    dot: 'bg-amber-500',
  },
  provider: {
    icon: Cloud,
    badge: 'border-blue-200 bg-blue-50 text-blue-900',
    dot: 'bg-blue-500',
  },
  shared: {
    icon: Handshake,
    badge: 'border-violet-200 bg-violet-50 text-violet-900',
    dot: 'bg-violet-500',
  },
} satisfies Record<ResponsibilityOwner, { icon: typeof UserRound; badge: string; dot: string }>

export function ResponsibilityVisual({ experience }: ResponsibilityVisualProps) {
  const titleId = useId()
  const descriptionId = useId()
  const tabPanelId = useId()
  const tabRefs = useRef<Array<HTMLButtonElement | null>>([])
  const { owners, layers, models, progression, exampleTitle } = experience.config
  const [selectedModelId, setSelectedModelId] = useState(models[0].id)
  const [expandedLayerId, setExpandedLayerId] = useState<string | null>(null)
  const selectedModel = models.find((model) => model.id === selectedModelId) ?? models[0]

  function selectTab(index: number) {
    const nextModel = models[index]
    setSelectedModelId(nextModel.id)
    tabRefs.current[index]?.focus()
  }

  function handleTabKeyDown(event: KeyboardEvent<HTMLButtonElement>, index: number) {
    let nextIndex: number | null = null

    if (event.key === 'ArrowRight') nextIndex = (index + 1) % models.length
    if (event.key === 'ArrowLeft') nextIndex = (index - 1 + models.length) % models.length
    if (event.key === 'Home') nextIndex = 0
    if (event.key === 'End') nextIndex = models.length - 1

    if (nextIndex !== null) {
      event.preventDefault()
      selectTab(nextIndex)
    }
  }

  return (
    <article
      aria-labelledby={titleId}
      aria-describedby={experience.description ? descriptionId : undefined}
      className="overflow-hidden rounded-2xl border border-slate-200/80 bg-white shadow-card"
    >
      <header className="border-b border-slate-200 bg-slate-50/70 px-5 py-5 sm:px-7">
        <p className="text-xs font-bold uppercase tracking-[0.14em] text-violet-700">
          Responsabilidade
        </p>
        <h3 id={titleId} className="mt-1.5 text-xl font-bold tracking-tight text-slate-950">
          {experience.title}
        </h3>
        {experience.description && (
          <p id={descriptionId} className="mt-2 max-w-3xl text-sm leading-6 text-slate-600">
            {experience.description}
          </p>
        )}
      </header>

      <div className="space-y-6 p-5 sm:p-7">
        {progression && (
          <div
            aria-label={`Progressão de ${progression.startLabel} para ${progression.endLabel}`}
            className="flex items-center gap-3 rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-xs font-bold text-slate-700 sm:text-sm"
          >
            <span className="min-w-0 flex-1">{progression.startLabel}</span>
            <span aria-hidden="true" className="hidden h-px min-w-4 flex-1 bg-slate-300 sm:block" />
            <ArrowRight aria-hidden="true" className="h-4 w-4 shrink-0 text-slate-500" />
            <span className="min-w-0 flex-1 text-right">{progression.endLabel}</span>
          </div>
        )}

        <div
          role="tablist"
          aria-label="Modelos de serviço"
          className="grid grid-cols-2 gap-2 sm:grid-cols-4"
        >
          {models.map((model, index) => {
            const isSelected = model.id === selectedModel.id

            return (
              <button
                key={model.id}
                ref={(element) => {
                  tabRefs.current[index] = element
                }}
                id={`${tabPanelId}-${model.id}-tab`}
                type="button"
                role="tab"
                aria-selected={isSelected}
                aria-controls={tabPanelId}
                tabIndex={isSelected ? 0 : -1}
                onClick={() => setSelectedModelId(model.id)}
                onKeyDown={(event) => handleTabKeyDown(event, index)}
                className={`rounded-xl border px-3 py-3 text-sm font-bold transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-violet-500 focus-visible:ring-offset-2 ${
                  isSelected
                    ? 'border-violet-500 bg-violet-50 text-violet-950 shadow-sm'
                    : 'border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:bg-slate-50'
                }`}
              >
                {model.label}
              </button>
            )
          })}
        </div>

        <section
          id={tabPanelId}
          role="tabpanel"
          aria-labelledby={`${tabPanelId}-${selectedModel.id}-tab`}
          className="focus:outline-none"
        >
          <div className="mb-4">
            <h4 className="text-lg font-bold text-slate-950">{selectedModel.label}</h4>
            <p className="mt-1 text-sm leading-6 text-slate-600">{selectedModel.description}</p>
          </div>

          <div aria-label={`Camadas do modelo ${selectedModel.label}`} className="space-y-2">
            {layers.map((layer) => {
              const ownerId = selectedModel.responsibilities[layer.id]
              const owner = owners[ownerId]
              const presentation = ownerPresentation[ownerId]
              const OwnerIcon = presentation.icon
              const isExpanded = expandedLayerId === layer.id
              const detailsId = `${tabPanelId}-${selectedModel.id}-${layer.id}-details`

              return (
                <div key={layer.id} className="overflow-hidden rounded-xl border border-slate-200">
                  <button
                    type="button"
                    aria-expanded={isExpanded}
                    aria-controls={detailsId}
                    aria-label={`${layer.label} — ${owner.label}`}
                    onClick={() => setExpandedLayerId(isExpanded ? null : layer.id)}
                    className="flex w-full items-center justify-between gap-3 bg-white px-4 py-3 text-left transition-colors hover:bg-slate-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-violet-500 sm:px-5"
                  >
                    <span className="font-semibold text-slate-900">{layer.label}</span>
                    <span
                      className={`inline-flex shrink-0 items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-bold ${presentation.badge}`}
                    >
                      <OwnerIcon aria-hidden="true" className="h-3.5 w-3.5" />
                      {owner.label}
                    </span>
                  </button>
                  {isExpanded && (
                    <div
                      id={detailsId}
                      className="border-t border-slate-200 bg-slate-50 px-4 py-3 text-sm leading-6 text-slate-600 sm:px-5"
                    >
                      {layer.description && <p>{layer.description}</p>}
                      {owner.description && (
                        <p className={layer.description ? 'mt-1' : undefined}>
                          <strong className="text-slate-800">{owner.label}:</strong>{' '}
                          {owner.description}
                        </p>
                      )}
                    </div>
                  )}
                </div>
              )
            })}
          </div>

          <div className="sr-only">
            <h5>Resumo textual de responsabilidades</h5>
            <ul>
              {layers.map((layer) => (
                <li key={layer.id}>
                  {layer.label}: {owners[selectedModel.responsibilities[layer.id]].label}
                </li>
              ))}
            </ul>
          </div>

          {selectedModel.example && (
            <aside className="mt-5 rounded-xl border border-emerald-200 bg-emerald-50 p-4 text-emerald-950">
              <h5 className="flex items-center gap-2 text-sm font-bold">
                <Code2 aria-hidden="true" className="h-4 w-4" />
                {exampleTitle ?? 'Exemplo'}
              </h5>
              <p className="mt-1 text-sm leading-6 text-emerald-900">{selectedModel.example}</p>
            </aside>
          )}
        </section>

        <aside aria-label="Legenda de responsabilidades" className="border-t border-slate-200 pt-5">
          <h4 className="text-sm font-bold text-slate-900">Legenda</h4>
          <ul className="mt-3 grid gap-3 sm:grid-cols-3">
            {(Object.keys(owners) as ResponsibilityOwner[]).map((ownerId) => {
              const owner = owners[ownerId]
              const presentation = ownerPresentation[ownerId]
              const OwnerIcon = presentation.icon

              return (
                <li key={ownerId} className="flex items-start gap-2.5 text-sm">
                  <span
                    aria-hidden="true"
                    className={`mt-1.5 h-2.5 w-2.5 shrink-0 rounded-full ${presentation.dot}`}
                  />
                  <span>
                    <span className="flex items-center gap-1.5 font-bold text-slate-900">
                      <OwnerIcon aria-hidden="true" className="h-4 w-4" />
                      {owner.label}
                    </span>
                    {owner.description && (
                      <span className="mt-0.5 block leading-5 text-slate-600">{owner.description}</span>
                    )}
                  </span>
                </li>
              )
            })}
          </ul>
        </aside>
      </div>
    </article>
  )
}

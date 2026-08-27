import { useEffect, useId, useMemo, useRef, useState } from 'react'

import type { ArchitectureVisualExperience } from '../../types/visualExperience'

interface ArchitectureVisualProps {
  experience: ArchitectureVisualExperience
}

type ArchitectureNode = ArchitectureVisualExperience['config']['nodes'][number]
type PositionedNode = ArchitectureNode & { x: number; y: number }

function clamp(value: number, minimum: number, maximum: number) {
  return Math.min(maximum, Math.max(minimum, value))
}

const nodeKindLabels = {
  external: 'Externo',
  service: 'Serviço',
  group: 'Grupo',
  zone: 'Zona',
  resource: 'Recurso',
} satisfies Record<ArchitectureNode['kind'], string>

const nodeKindClasses = {
  external: 'border-slate-400 bg-slate-100 text-slate-900',
  service: 'border-blue-400 bg-blue-50 text-blue-950',
  group: 'border-violet-400 bg-violet-50 text-violet-950',
  zone: 'border-emerald-400 bg-emerald-50 text-emerald-950',
  resource: 'border-amber-400 bg-amber-50 text-amber-950',
} satisfies Record<ArchitectureNode['kind'], string>

function positionNodes(nodes: readonly ArchitectureNode[]) {
  const hasConfiguredPositions = nodes.every(
    (node) => node.x !== undefined && node.y !== undefined,
  )

  if (hasConfiguredPositions) {
    return nodes.map((node) => ({
      ...node,
      x: clamp(node.x ?? 50, 12, 88),
      y: clamp(node.y ?? 50, 12, 88),
    }))
  }

  const columnCount = Math.max(1, Math.min(3, Math.ceil(Math.sqrt(nodes.length))))
  const rowCount = Math.max(1, Math.ceil(nodes.length / columnCount))

  return nodes.map((node, index) => {
    const column = index % columnCount
    const row = Math.floor(index / columnCount)
    const x = columnCount === 1 ? 50 : 12 + (column * 76) / (columnCount - 1)
    const y = rowCount === 1 ? 50 : 16 + (row * 68) / (rowCount - 1)

    return { ...node, x, y }
  })
}

function getVisibleEdge(source: PositionedNode, target: PositionedNode) {
  const deltaX = target.x - source.x
  const deltaY = target.y - source.y
  const distance = Math.hypot(deltaX, deltaY)

  if (distance === 0) {
    return { x1: source.x, y1: source.y, x2: target.x, y2: target.y }
  }

  const sourceOffset = Math.min(8, distance / 3)
  const targetOffset = Math.min(10, distance / 3)
  const directionX = deltaX / distance
  const directionY = deltaY / distance

  return {
    x1: source.x + directionX * sourceOffset,
    y1: source.y + directionY * sourceOffset,
    x2: target.x - directionX * targetOffset,
    y2: target.y - directionY * targetOffset,
  }
}

export function ArchitectureVisual({ experience }: ArchitectureVisualProps) {
  const titleId = useId()
  const descriptionId = useId()
  const detailsId = useId()
  const markerId = useId().replace(/:/g, '')
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(null)
  const scrollContainerRef = useRef<HTMLDivElement>(null)
  const nodes = useMemo(
    () => positionNodes(experience.config.nodes),
    [experience.config.nodes],
  )
  const nodeById = new Map<string, PositionedNode>(nodes.map((node) => [node.id, node]))
  const selectedNode = selectedNodeId ? nodeById.get(selectedNodeId) ?? null : null
  const rowCount = Math.max(1, Math.ceil(nodes.length / 3))
  const verticalLevelCount = new Set(nodes.map((node) => Math.round(node.y))).size
  const isSingleColumnLayout =
    nodes.length > 1 && new Set(nodes.map((node) => Math.round(node.x))).size === 1
  const canvasHeight = Math.max(360, rowCount * 150, verticalLevelCount * 120)

  useEffect(() => {
    const container = scrollContainerRef.current
    const firstNode = nodes[0]

    if (!container || !firstNode || container.scrollWidth <= container.clientWidth) return

    const nodeCenter = (firstNode.x / 100) * container.scrollWidth
    const maximumScroll = container.scrollWidth - container.clientWidth
    container.scrollLeft = Math.min(
      maximumScroll,
      Math.max(0, nodeCenter - container.clientWidth / 2),
    )
  }, [experience.id, nodes])

  return (
    <article
      aria-labelledby={titleId}
      aria-describedby={experience.description ? descriptionId : undefined}
      className="overflow-hidden rounded-2xl border border-slate-200/80 bg-white shadow-card"
    >
      <header className="border-b border-slate-200 bg-slate-50/70 px-5 py-5 sm:px-7">
        <p className="text-xs font-bold uppercase tracking-[0.14em] text-violet-700">Arquitetura</p>
        <h3 id={titleId} className="mt-1.5 text-xl font-bold tracking-tight text-slate-950">
          {experience.title}
        </h3>
        {experience.description && (
          <p id={descriptionId} className="mt-2 max-w-3xl text-sm leading-6 text-slate-600">
            {experience.description}
          </p>
        )}
        <p className="mt-3 text-xs font-semibold text-slate-500">
          Selecione um componente para consultar seus detalhes.
        </p>
      </header>

      <div
        ref={scrollContainerRef}
        role="region"
        aria-label={`Diagrama de arquitetura: ${experience.title}`}
        tabIndex={0}
        className="overflow-x-auto overscroll-x-contain p-4 sm:p-6"
      >
        <div
          className={`relative mx-auto overflow-hidden rounded-xl border border-slate-200 bg-slate-50 ${isSingleColumnLayout ? 'min-w-[14rem]' : 'min-w-[42rem]'}`}
          style={{ height: `${canvasHeight}px` }}
        >
          <svg
            aria-hidden="true"
            focusable="false"
            viewBox="0 0 100 100"
            preserveAspectRatio="none"
            className="absolute inset-0 h-full w-full"
          >
            <defs>
              <marker
                id={markerId}
                viewBox="0 0 10 10"
                refX="9"
                refY="5"
                markerWidth="7"
                markerHeight="7"
                orient="auto-start-reverse"
              >
                <path d="M 0 0 L 10 5 L 0 10 z" fill="currentColor" />
              </marker>
            </defs>
            {experience.config.edges.map((edge) => {
              const source = nodeById.get(edge.source)
              const target = nodeById.get(edge.target)

              if (!source || !target) return null
              const visibleEdge = getVisibleEdge(source, target)

              return (
                <line
                  key={edge.id}
                  x1={visibleEdge.x1}
                  y1={visibleEdge.y1}
                  x2={visibleEdge.x2}
                  y2={visibleEdge.y2}
                  stroke="currentColor"
                  strokeWidth="1.5"
                  vectorEffect="non-scaling-stroke"
                  markerEnd={`url(#${markerId})`}
                  className="text-slate-400"
                />
              )
            })}
          </svg>

          {experience.config.edges.map((edge) => {
            if (!edge.label) return null

            const source = nodeById.get(edge.source)
            const target = nodeById.get(edge.target)
            if (!source || !target) return null

            return (
              <span
                key={`${edge.id}-label`}
                aria-hidden="true"
                className="absolute z-10 max-w-32 -translate-x-1/2 -translate-y-1/2 rounded-full border border-slate-200 bg-white px-2 py-1 text-center text-[11px] font-semibold leading-4 text-slate-600 shadow-sm"
                style={{ left: `${(source.x + target.x) / 2}%`, top: `${(source.y + target.y) / 2}%` }}
              >
                {edge.label}
              </span>
            )
          })}

          {nodes.map((node) => {
            const selected = selectedNodeId === node.id

            return (
              <button
                key={node.id}
                type="button"
                aria-controls={detailsId}
                aria-expanded={selected}
                aria-label={`${node.label}, ${nodeKindLabels[node.kind]}. ${selected ? 'Ocultar detalhes' : 'Mostrar detalhes'}.`}
                onClick={() => setSelectedNodeId(selected ? null : node.id)}
                className={`absolute z-20 min-h-20 w-36 -translate-x-1/2 -translate-y-1/2 rounded-xl border-2 px-3 py-2 text-center shadow-sm transition hover:shadow-md focus-visible:z-30 sm:w-40 ${nodeKindClasses[node.kind]} ${selected ? 'ring-2 ring-blue-600 ring-offset-2' : ''}`}
                style={{ left: `${node.x}%`, top: `${node.y}%` }}
              >
                <span className="block text-xs font-bold uppercase tracking-wide opacity-75">
                  {nodeKindLabels[node.kind]}
                </span>
                <span className="mt-1 block text-sm font-bold leading-5">{node.label}</span>
              </button>
            )
          })}
        </div>
      </div>

      <div id={detailsId} aria-live="polite" className="border-t border-slate-200 px-5 py-4 sm:px-7">
        {selectedNode ? (
          <div>
            <p className="text-xs font-bold uppercase tracking-wide text-slate-500">
              {nodeKindLabels[selectedNode.kind]}
            </p>
            <h4 className="mt-1 font-bold text-slate-950">{selectedNode.label}</h4>
            <p className="mt-1 text-sm leading-6 text-slate-600">
              {selectedNode.description ?? 'Este componente não possui detalhes adicionais.'}
            </p>
          </div>
        ) : (
          <p className="text-sm text-slate-500">Nenhum componente selecionado.</p>
        )}
      </div>

      <div className="sr-only">
        <h4>Representação textual do diagrama</h4>
        <ul>
          {nodes.map((node) => (
            <li key={`${node.id}-description`}>
              {node.label}, classificado como {nodeKindLabels[node.kind]}.
              {node.description ? ` ${node.description}` : ''}
            </li>
          ))}
          {experience.config.edges.map((edge) => {
            const source = nodeById.get(edge.source)
            const target = nodeById.get(edge.target)
            if (!source || !target) return null

            return (
              <li key={`${edge.id}-description`}>
                Relação de {source.label} para {target.label}.
                {edge.label ? ` ${edge.label}.` : ''}
              </li>
            )
          })}
        </ul>
      </div>
    </article>
  )
}

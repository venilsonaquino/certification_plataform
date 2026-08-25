import type { RenderableVisualExperience } from '../../types/visualExperience'
import { ArchitectureVisual } from './ArchitectureVisual'
import { ComparisonVisual } from './ComparisonVisual'
import { FlowVisual } from './FlowVisual'
import { ResponsibilityVisual } from './ResponsibilityVisual'

interface VisualExperienceRendererProps {
  experience: RenderableVisualExperience
}

export function VisualExperienceRenderer({ experience }: VisualExperienceRendererProps) {
  switch (experience.type) {
    case 'comparison':
      return <ComparisonVisual experience={experience} />
    case 'architecture':
      return <ArchitectureVisual experience={experience} />
    case 'flow':
      return <FlowVisual experience={experience} />
    case 'responsibility':
      return <ResponsibilityVisual experience={experience} />
    case 'invalid':
      return (
        <div
          role="alert"
          className="rounded-2xl border border-rose-200 bg-rose-50 px-5 py-6 text-sm font-semibold text-rose-800"
        >
          Não foi possível carregar esta visualização.
        </div>
      )
  }

  const exhaustiveCheck: never = experience
  return exhaustiveCheck
}

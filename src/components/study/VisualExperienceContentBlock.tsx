import { Eye } from 'lucide-react'

import type { VisualExperienceContentBlock as VisualExperienceContentBlockModel } from '../../types/lessonContentBlock'
import { VisualExperienceErrorBoundary } from '../visualExperiences/VisualExperienceErrorBoundary'
import { VisualExperienceRenderer } from '../visualExperiences/VisualExperienceRenderer'

interface VisualExperienceContentBlockProps {
  block: VisualExperienceContentBlockModel
}

export function VisualExperienceContentBlock({ block }: VisualExperienceContentBlockProps) {
  if (!block.visualExperience) {
    return (
      <div
        role="alert"
        className="rounded-2xl border border-rose-200 bg-rose-50 px-5 py-6 text-sm font-semibold text-rose-800"
        data-content-block-type="visual_experience"
      >
        Esta visualização não está disponível.
      </div>
    )
  }

  return (
    <section
      className="border-y border-slate-200 py-7 sm:py-9"
      data-content-block-type="visual_experience"
    >
      {block.title && (
        <div className="mb-5 flex items-center gap-3">
          <div className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-cyan-50 text-cyan-700">
            <Eye aria-hidden="true" className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.16em] text-cyan-700">
              Visualize
            </p>
            <h2 className="text-xl font-bold tracking-tight text-slate-950 sm:text-2xl">
              {block.title}
            </h2>
          </div>
        </div>
      )}
      <VisualExperienceErrorBoundary resetKey={block.visualExperience.id}>
        <VisualExperienceRenderer experience={block.visualExperience} />
      </VisualExperienceErrorBoundary>
    </section>
  )
}

import type { RenderableLessonContentBlock } from '../../types/lessonContentBlock'
import { AzureLabContentBlock } from './AzureLabContentBlock'
import { ImageContentBlock } from './ImageContentBlock'
import { TextLessonContentBlock } from './LessonContentBlock'
import { VideoContentBlock } from './VideoContentBlock'
import { VisualExperienceContentBlock } from './VisualExperienceContentBlock'

interface LessonContentBlockRendererProps {
  block: RenderableLessonContentBlock
}

export function LessonContentBlockRenderer({ block }: LessonContentBlockRendererProps) {
  switch (block.type) {
    case 'explanation':
    case 'important':
    case 'example':
    case 'dotnet_example':
    case 'exam_tip':
    case 'exam_trap':
    case 'summary':
      return <TextLessonContentBlock block={block} />
    case 'image':
      return <ImageContentBlock block={block} />
    case 'video':
      return <VideoContentBlock block={block} />
    case 'visual_experience':
      return <VisualExperienceContentBlock block={block} />
    case 'azure_lab':
      return <AzureLabContentBlock block={block} />
    case 'invalid':
      return (
        <div
          role="alert"
          className="rounded-2xl border border-slate-200 bg-slate-50 px-5 py-6 text-sm font-semibold text-slate-700"
          data-content-block-type="invalid"
        >
          Conteúdo indisponível.
        </div>
      )
  }

  const exhaustiveCheck: never = block
  return exhaustiveCheck
}

import {
  BookOpen,
  CircleAlert,
  Code2,
  Lightbulb,
  ListChecks,
  Sparkles,
  TriangleAlert,
  type LucideIcon,
} from 'lucide-react'

import type {
  SummaryContentBlockConfig,
  TextLessonContentBlock as TextLessonContentBlockModel,
  TextLessonContentBlockType,
} from '../../types/lessonContentBlock'

interface LessonContentBlockProps {
  block: TextLessonContentBlockModel
}

interface BlockPresentation {
  readonly defaultTitle: string
  readonly eyebrow?: string
  readonly icon: LucideIcon
  readonly containerClassName: string
  readonly iconClassName: string
  readonly eyebrowClassName: string
}

const PRESENTATION: Record<TextLessonContentBlockType, BlockPresentation> = {
  explanation: {
    defaultTitle: 'Explicação',
    icon: BookOpen,
    containerClassName: 'border-slate-200/80 bg-white shadow-card',
    iconClassName: 'bg-slate-100 text-slate-700',
    eyebrowClassName: 'text-slate-500',
  },
  important: {
    defaultTitle: 'Importante',
    eyebrow: 'Destaque',
    icon: CircleAlert,
    containerClassName: 'border-amber-200 bg-amber-50/70',
    iconClassName: 'bg-amber-500 text-white',
    eyebrowClassName: 'text-amber-700',
  },
  example: {
    defaultTitle: 'Exemplo',
    icon: Sparkles,
    containerClassName: 'border-violet-200 bg-violet-50/60',
    iconClassName: 'bg-violet-600 text-white',
    eyebrowClassName: 'text-violet-700',
  },
  dotnet_example: {
    defaultTitle: 'Exemplo com .NET',
    eyebrow: 'Para desenvolvedores',
    icon: Code2,
    containerClassName: 'border-indigo-200 bg-indigo-50/60',
    iconClassName: 'bg-indigo-600 text-white',
    eyebrowClassName: 'text-indigo-700',
  },
  exam_tip: {
    defaultTitle: 'O que lembrar para a prova',
    eyebrow: 'Dica de prova',
    icon: Lightbulb,
    containerClassName: 'border-blue-200 bg-blue-50/70',
    iconClassName: 'bg-blue-600 text-white',
    eyebrowClassName: 'text-blue-700',
  },
  exam_trap: {
    defaultTitle: 'Não confunda',
    eyebrow: 'Atenção',
    icon: TriangleAlert,
    containerClassName: 'border-rose-200 bg-rose-50/70',
    iconClassName: 'bg-rose-600 text-white',
    eyebrowClassName: 'text-rose-700',
  },
  summary: {
    defaultTitle: 'Resumo',
    eyebrow: 'Pontos principais',
    icon: ListChecks,
    containerClassName: 'border-emerald-200 bg-emerald-50/60',
    iconClassName: 'bg-emerald-600 text-white',
    eyebrowClassName: 'text-emerald-700',
  },
}

function getParagraphs(content: string | null): string[] {
  if (!content) {
    return []
  }

  return content
    .split(/\n\s*\n/)
    .map((paragraph) => paragraph.replace(/\s*\n\s*/g, ' ').trim())
    .filter(Boolean)
}

function getSummaryItems(config: TextLessonContentBlockModel['config']): readonly string[] {
  const items = (config as SummaryContentBlockConfig | null)?.items

  if (!Array.isArray(items)) {
    return []
  }

  return items.filter((item): item is string => typeof item === 'string' && item.trim() !== '')
}

export function TextLessonContentBlock({ block }: LessonContentBlockProps) {
  const presentation = PRESENTATION[block.type]
  const Icon = presentation.icon
  const paragraphs = getParagraphs(block.content)
  const summaryItems = block.type === 'summary' ? getSummaryItems(block.config) : []

  return (
    <section
      className={`rounded-2xl border p-5 sm:p-7 ${presentation.containerClassName}`}
      data-content-block-type={block.type}
    >
      <div className="flex items-start gap-3 sm:gap-4">
        <div
          className={`grid h-10 w-10 shrink-0 place-items-center rounded-xl shadow-sm ${presentation.iconClassName}`}
        >
          <Icon aria-hidden="true" className="h-5 w-5" />
        </div>

        <div className="min-w-0 flex-1">
          {presentation.eyebrow && (
            <p
              className={`text-xs font-bold uppercase tracking-[0.15em] ${presentation.eyebrowClassName}`}
            >
              {presentation.eyebrow}
            </p>
          )}
          <h2 className="text-lg font-bold tracking-tight text-slate-950 sm:text-xl">
            {block.title ?? presentation.defaultTitle}
          </h2>

          {paragraphs.length > 0 && (
            <div className="mt-3 space-y-3">
              {paragraphs.map((paragraph, index) => (
                <p key={index} className="text-[15px] leading-7 text-slate-700 sm:text-base">
                  {paragraph}
                </p>
              ))}
            </div>
          )}

          {summaryItems.length > 0 && (
            <ul className="mt-4 space-y-2.5">
              {summaryItems.map((item, index) => (
                <li key={index} className="flex gap-3 text-[15px] leading-7 text-slate-700 sm:text-base">
                  <span aria-hidden="true" className="mt-[0.7rem] h-1.5 w-1.5 shrink-0 rounded-full bg-emerald-600" />
                  <span>{item}</span>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </section>
  )
}

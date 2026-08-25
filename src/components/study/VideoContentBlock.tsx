import { Clock3, ExternalLink, PlayCircle } from 'lucide-react'

import type { VideoContentBlock as VideoContentBlockModel } from '../../types/lessonContentBlock'

interface VideoContentBlockProps {
  block: VideoContentBlockModel
}

export function VideoContentBlock({ block }: VideoContentBlockProps) {
  const { url, title, provider, durationMinutes } = block.config

  return (
    <section
      className="rounded-2xl border border-red-200 bg-red-50/60 p-5 sm:p-7"
      data-content-block-type="video"
    >
      <div className="flex items-start gap-4">
        <div className="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-red-600 text-white shadow-sm">
          <PlayCircle aria-hidden="true" className="h-6 w-6" />
        </div>
        <div className="min-w-0 flex-1">
          <p className="text-xs font-bold uppercase tracking-[0.15em] text-red-700">
            Vídeo complementar · {provider === 'youtube' ? 'YouTube' : provider}
          </p>
          <h2 className="mt-1 text-lg font-bold tracking-tight text-slate-950 sm:text-xl">
            {block.title ?? title}
          </h2>
          {block.title && title !== block.title && (
            <p className="mt-2 text-sm leading-6 text-slate-600">{title}</p>
          )}
          <div className="mt-4 flex flex-wrap items-center gap-3">
            {durationMinutes !== undefined && (
              <span className="inline-flex items-center gap-1.5 text-sm font-medium text-slate-600">
                <Clock3 aria-hidden="true" className="h-4 w-4" />
                {durationMinutes} min
              </span>
            )}
            <a
              href={url}
              target="_blank"
              rel="noreferrer noopener"
              aria-label={`Assistir ao vídeo ${block.title ?? title} em uma nova aba`}
              className="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-red-600 px-4 text-sm font-bold text-white shadow-sm transition hover:bg-red-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-red-700 focus-visible:ring-offset-2"
            >
              Assistir
              <ExternalLink aria-hidden="true" className="h-4 w-4" />
            </a>
          </div>
        </div>
      </div>
    </section>
  )
}

import { ExternalLink, Image as ImageIcon } from 'lucide-react'

import type { ImageContentBlock as ImageContentBlockModel } from '../../types/lessonContentBlock'

interface ImageContentBlockProps {
  block: ImageContentBlockModel
}

export function ImageContentBlock({ block }: ImageContentBlockProps) {
  const { url, alt, caption, sourceLabel, sourceUrl } = block.config

  return (
    <figure
      className="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-card"
      data-content-block-type="image"
    >
      {block.title && (
        <div className="flex items-center gap-3 border-b border-slate-200 px-5 py-4 sm:px-7">
          <ImageIcon aria-hidden="true" className="h-5 w-5 text-cyan-700" />
          <h2 className="text-lg font-bold tracking-tight text-slate-950">{block.title}</h2>
        </div>
      )}
      <img
        src={url}
        alt={alt}
        loading="lazy"
        decoding="async"
        referrerPolicy="no-referrer"
        className="h-auto w-full bg-slate-100 object-contain"
      />
      {(caption || sourceLabel || sourceUrl) && (
        <figcaption className="space-y-2 border-t border-slate-200 px-5 py-4 text-sm leading-6 text-slate-600 sm:px-7">
          {caption && <p>{caption}</p>}
          {(sourceLabel || sourceUrl) && (
            <p className="text-xs text-slate-500">
              Fonte:{' '}
              {sourceUrl ? (
                <a
                  href={sourceUrl}
                  target="_blank"
                  rel="noreferrer noopener"
                  className="inline-flex items-center gap-1 font-semibold text-blue-700 hover:text-blue-800"
                >
                  {sourceLabel ?? 'Abrir fonte'}
                  <ExternalLink aria-hidden="true" className="h-3.5 w-3.5" />
                </a>
              ) : (
                sourceLabel
              )}
            </p>
          )}
        </figcaption>
      )}
    </figure>
  )
}

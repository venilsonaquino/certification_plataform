import { LoaderCircle, RotateCcw } from 'lucide-react'

import { useLessonContentBlocks } from '../../hooks/useLessonContentBlocks'
import { LessonVisualExperiences } from '../visualExperiences/LessonVisualExperiences'
import { LessonContent } from './LessonContent'
import { LessonContentBlockRenderer } from './LessonContentBlockRenderer'

interface LessonContentRendererProps {
  lessonId: string
  legacyContent: string | null
}

export function LessonContentRenderer({
  lessonId,
  legacyContent,
}: LessonContentRendererProps) {
  const { blocks, loading, error, retry } = useLessonContentBlocks(lessonId)

  if (loading) {
    return (
      <div role="status" className="flex items-center gap-2 text-sm text-slate-500">
        <LoaderCircle aria-hidden="true" className="h-4 w-4 animate-spin" />
        Carregando conteúdo da aula...
      </div>
    )
  }

  if (error) {
    return (
      <div
        role="alert"
        className="rounded-2xl border border-rose-200 bg-rose-50/70 p-5 sm:flex sm:items-center sm:justify-between sm:gap-5"
      >
        <div>
          <h2 className="font-bold text-rose-900">Não foi possível carregar o conteúdo da aula.</h2>
          <p className="mt-1 text-sm text-rose-800">Confira sua conexão e tente novamente.</p>
        </div>
        <button
          type="button"
          onClick={retry}
          className="mt-4 inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-white px-4 text-sm font-bold text-rose-700 shadow-sm ring-1 ring-inset ring-rose-200 transition hover:bg-rose-100 sm:mt-0"
        >
          <RotateCcw aria-hidden="true" className="h-4 w-4" />
          Tentar novamente
        </button>
      </div>
    )
  }

  if (blocks.length > 0) {
    return (
      <div className="space-y-5 sm:space-y-6">
        {blocks.map((block) => (
          <LessonContentBlockRenderer key={block.id} block={block} />
        ))}
      </div>
    )
  }

  if (legacyContent?.trim()) {
    return (
      <>
        <LessonContent content={legacyContent} />
        <LessonVisualExperiences lessonId={lessonId} />
      </>
    )
  }

  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-card">
      <h2 className="font-bold text-slate-900">Conteúdo da aula indisponível.</h2>
      <p className="mt-1 text-sm leading-6 text-slate-600">
        A aula existe, mas ainda não possui conteúdo publicado.
      </p>
    </div>
  )
}

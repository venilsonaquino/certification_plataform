import { ArrowRight, Layers3, LoaderCircle } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'

import { lessonFlashcardsRoute } from '../../lib/routes'
import { getFlashcardCountByLesson } from '../../services/flashcardService'

interface LessonFlashcardCardProps {
  certificationCode: string
  lessonId: string
  lessonSlug: string
}

export function LessonFlashcardCard({
  certificationCode,
  lessonId,
  lessonSlug,
}: LessonFlashcardCardProps) {
  const [count, setCount] = useState<number | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let active = true
    setCount(null)
    setError(null)

    getFlashcardCountByLesson(lessonId)
      .then((value) => {
        if (active) setCount(value)
      })
      .catch(() => {
        if (active) {
          setError('Não foi possível carregar os flashcards.')
        }
      })

    return () => {
      active = false
    }
  }, [lessonId])

  if (error) {
    return <p role="alert" className="mt-6 text-sm text-rose-600">{error}</p>
  }

  if (count === null) {
    return (
      <div className="mt-6 flex items-center gap-2 text-sm text-slate-500">
        <LoaderCircle aria-hidden="true" className="h-4 w-4 animate-spin" />
        Carregando flashcards...
      </div>
    )
  }

  if (count === 0) return null

  return (
    <section className="mt-6 rounded-2xl border border-blue-200 bg-blue-50/70 p-5 sm:flex sm:items-center sm:justify-between sm:gap-5 sm:p-6">
      <div className="flex items-start gap-3">
        <Layers3 aria-hidden="true" className="mt-0.5 h-6 w-6 shrink-0 text-blue-700" />
        <div>
          <h2 className="font-bold text-slate-950">Flashcards</h2>
          <p className="mt-1 text-sm text-slate-600">
            {count} {count === 1 ? 'card' : 'cards'}. Treine sua memória com os principais conceitos desta aula.
          </p>
        </div>
      </div>
      <Link
        to={lessonFlashcardsRoute(certificationCode, lessonSlug)}
        className="mt-4 inline-flex min-h-11 w-full items-center justify-center gap-2 rounded-xl bg-blue-700 px-5 text-sm font-bold text-white transition hover:bg-blue-800 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700 sm:mt-0 sm:w-auto"
      >
        Estudar Flashcards
        <ArrowRight aria-hidden="true" className="h-4 w-4" />
      </Link>
    </section>
  )
}

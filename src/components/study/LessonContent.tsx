import { Lightbulb } from 'lucide-react'

import { parseLessonContent } from '../../lib/lessonContent'

interface LessonContentProps {
  content: string
}

export function LessonContent({ content }: LessonContentProps) {
  const sections = parseLessonContent(content)

  return (
    <div className="space-y-5 sm:space-y-6">
      {sections.map((section) => {
        const isExamTip = section.heading.toLocaleLowerCase('pt-BR').includes('lembrar para a prova')

        return (
          <section
            key={section.heading}
            className={[
              'rounded-2xl border p-5 sm:p-7',
              isExamTip
                ? 'border-blue-200 bg-blue-50/70'
                : 'border-slate-200/80 bg-white shadow-card',
            ].join(' ')}
          >
            <div className="flex items-start gap-3">
              {isExamTip && (
                <div className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-blue-600 text-white shadow-sm">
                  <Lightbulb aria-hidden="true" className="h-4 w-4" />
                </div>
              )}
              <div>
                <h2 className="text-lg font-bold tracking-tight text-slate-950 sm:text-xl">
                  {section.heading}
                </h2>
                <div className="mt-3 space-y-3">
                  {section.paragraphs.map((paragraph, index) => (
                    <p key={index} className="text-[15px] leading-7 text-slate-600 sm:text-base">
                      {paragraph}
                    </p>
                  ))}
                </div>
              </div>
            </div>
          </section>
        )
      })}
    </div>
  )
}

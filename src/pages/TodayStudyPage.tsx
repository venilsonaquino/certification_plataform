import { BookOpen, Clock3 } from 'lucide-react'
import { useEffect, useState } from 'react'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { formatCertificationCode } from '../lib/certificationVisuals'
import { useCertification } from '../hooks/useCertification'
import { getCertificationContent } from '../services/certificationService'
import type { DomainWithTopics } from '../types/content'

export function TodayStudyPage() {
  const { currentCertification } = useCertification()
  const [domains, setDomains] = useState<DomainWithTopics[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(false)
  const [attempt, setAttempt] = useState(0)

  useEffect(() => {
    let active = true

    setLoading(true)
    setError(false)

    void getCertificationContent(currentCertification.id)
      .then((content) => {
        if (active) {
          setDomains(content)
          setLoading(false)
        }
      })
      .catch(() => {
        if (active) {
          setError(true)
          setLoading(false)
        }
      })

    return () => {
      active = false
    }
  }, [attempt, currentCertification.id])

  return (
    <div>
      <header className="max-w-3xl">
        <p className="text-sm font-semibold text-blue-600">
          {formatCertificationCode(currentCertification.code)}
        </p>
        <h1 className="mt-2 text-balance text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">
          {currentCertification.name}
        </h1>
        <p className="mt-3 text-base leading-7 text-slate-500">
          Conteúdo organizado por domínio, tópico e lesson.
        </p>
      </header>

      <section aria-labelledby="content-title" className="mt-8 lg:mt-10">
        <div className="mb-5 flex items-center gap-3">
          <div className="grid h-10 w-10 place-items-center rounded-xl bg-blue-50 text-blue-600">
            <BookOpen aria-hidden="true" className="h-5 w-5" />
          </div>
          <h2 id="content-title" className="text-xl font-bold tracking-tight text-slate-950">
            Conteúdo
          </h2>
        </div>

        {loading && <CertificationDataState title="Carregando conteúdo..." loading />}
        {!loading && error && (
          <CertificationDataState
            title="Não foi possível carregar o conteúdo."
            description="Confira sua conexão e tente novamente."
            onRetry={() => setAttempt((current) => current + 1)}
          />
        )}
        {!loading && !error && domains.length === 0 && (
          <CertificationDataState
            title="Nenhum conteúdo disponível."
            description="Esta certificação ainda não possui domínios publicados."
          />
        )}
        {!loading && !error && domains.length > 0 && (
          <ol className="space-y-5">
            {domains.map((domain, domainIndex) => (
              <li key={domain.id} className="rounded-2xl border border-slate-200/80 bg-white p-5 shadow-card sm:p-7">
                <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between sm:gap-5">
                  <div>
                    <p className="text-xs font-bold uppercase tracking-[0.16em] text-blue-600">
                      Domínio {domainIndex + 1}
                    </p>
                    <h3 className="mt-2 text-lg font-bold text-slate-950">{domain.title}</h3>
                  </div>
                  {domain.examWeightMin !== null && domain.examWeightMax !== null && (
                    <span className="shrink-0 rounded-full bg-slate-100 px-3 py-1.5 text-xs font-semibold text-slate-600">
                      {domain.examWeightMin}–{domain.examWeightMax}% da prova
                    </span>
                  )}
                </div>

                {domain.topics.length === 0 ? (
                  <p className="mt-5 text-sm text-slate-400">Nenhum tópico cadastrado.</p>
                ) : (
                  <ol className="mt-6 space-y-5 border-l border-slate-200 pl-5 sm:pl-6">
                    {domain.topics.map((topic, topicIndex) => (
                      <li key={topic.id}>
                        <h4 className="font-semibold text-slate-800">
                          {domainIndex + 1}.{topicIndex + 1} {topic.title}
                        </h4>
                        {topic.lessons.length === 0 ? (
                          <p className="mt-2 text-sm text-slate-400">Nenhuma lesson publicada.</p>
                        ) : (
                          <ul className="mt-3 grid gap-2 sm:grid-cols-2">
                            {topic.lessons.map((lesson) => (
                              <li
                                key={lesson.id}
                                className="flex items-start justify-between gap-3 rounded-xl bg-slate-50 px-4 py-3 text-sm text-slate-700 ring-1 ring-inset ring-slate-100"
                              >
                                <span>{lesson.title}</span>
                                {lesson.estimatedMinutes && (
                                  <span className="flex shrink-0 items-center gap-1 text-xs font-medium text-slate-400">
                                    <Clock3 aria-hidden="true" className="h-3.5 w-3.5" />
                                    {lesson.estimatedMinutes} min
                                  </span>
                                )}
                              </li>
                            ))}
                          </ul>
                        )}
                      </li>
                    ))}
                  </ol>
                )}
              </li>
            ))}
          </ol>
        )}
      </section>
    </div>
  )
}

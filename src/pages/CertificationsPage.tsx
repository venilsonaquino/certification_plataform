import { useEffect, useState } from 'react'

import { Brand } from '../components/Brand'
import { CertificationCard } from '../components/certifications/CertificationCard'
import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { getCertifications } from '../services/certificationService'
import type { Certification } from '../types/certification'

export function CertificationsPage() {
  const [certifications, setCertifications] = useState<Certification[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(false)
  const [attempt, setAttempt] = useState(0)

  useEffect(() => {
    let active = true

    setLoading(true)
    setError(false)

    void getCertifications()
      .then((items) => {
        if (active) {
          setCertifications(items)
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
  }, [attempt])

  return (
    <div className="min-h-screen bg-canvas">
      <header className="border-b border-slate-200/80 bg-white/90 backdrop-blur-xl">
        <div className="mx-auto flex h-[72px] max-w-[1440px] items-center px-4 sm:px-6 lg:px-8">
          <Brand tone="light" />
        </div>
      </header>

      <main className="mx-auto w-full max-w-[1440px] px-4 py-10 sm:px-6 sm:py-14 lg:px-8 lg:py-16">
        <div className="max-w-3xl">
          <p className="text-sm font-semibold text-blue-600">Sua próxima conquista</p>
          <h1 className="mt-3 text-balance text-3xl font-bold tracking-tight text-slate-950 sm:text-5xl">
            Escolha sua certificação
          </h1>
          <p className="mt-4 max-w-2xl text-base leading-7 text-slate-500 sm:text-lg">
            Selecione a certificação que deseja estudar. Novas jornadas serão adicionadas gradualmente.
          </p>
        </div>

        <section aria-label="Certificações" className="mt-10">
          {loading && <CertificationDataState title="Carregando certificações..." loading />}
          {!loading && error && (
            <CertificationDataState
              title="Não foi possível carregar as certificações."
              description="Confira sua conexão e tente novamente."
              onRetry={() => setAttempt((current) => current + 1)}
            />
          )}
          {!loading && !error && certifications.length === 0 && (
            <CertificationDataState
              title="Nenhuma certificação encontrada."
              description="O catálogo ainda não possui registros disponíveis."
            />
          )}
          {!loading && !error && certifications.length > 0 && (
            <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
              {certifications.map((certification) => (
                <CertificationCard key={certification.id} certification={certification} />
              ))}
            </div>
          )}
        </section>
      </main>
    </div>
  )
}

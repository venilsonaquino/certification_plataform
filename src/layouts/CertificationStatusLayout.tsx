import { Link } from 'react-router-dom'

import { Brand } from '../components/Brand'
import { CertificationDataState } from '../components/certifications/CertificationDataState'

interface CertificationStatusLayoutProps {
  title: string
  description?: string
  loading?: boolean
  onRetry?: () => void
  showBackLink?: boolean
}

export function CertificationStatusLayout({
  title,
  description,
  loading,
  onRetry,
  showBackLink = false,
}: CertificationStatusLayoutProps) {
  return (
    <div className="min-h-screen bg-canvas">
      <header className="border-b border-slate-200/80 bg-white/90 backdrop-blur-xl">
        <div className="mx-auto flex h-[72px] max-w-[1440px] items-center px-4 sm:px-6 lg:px-8">
          <Brand tone="light" />
        </div>
      </header>
      <main className="mx-auto w-full max-w-2xl px-4 py-16 sm:px-6 lg:px-8">
        <CertificationDataState
          title={title}
          description={description}
          loading={loading}
          onRetry={onRetry}
        />
        {showBackLink && (
          <div className="mt-6 text-center">
            <Link to="/certifications" className="text-sm font-semibold text-blue-600 hover:text-blue-700">
              Voltar para certificações
            </Link>
          </div>
        )}
      </main>
    </div>
  )
}

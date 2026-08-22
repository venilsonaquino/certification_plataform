import { ArrowLeftRight, LoaderCircle, LogOut } from 'lucide-react'
import { useState } from 'react'
import { Link, Outlet, useNavigate } from 'react-router-dom'

import { Brand } from '../components/Brand'
import { CertificationIdentity } from '../components/certifications/CertificationIdentity'
import { MobileNavigation } from '../components/navigation/MobileNavigation'
import { Sidebar } from '../components/navigation/Sidebar'
import { useAuth } from '../hooks/useAuth'
import { useCertification } from '../hooks/useCertification'

export function AppLayout() {
  const { currentCertification } = useCertification()
  const { user, signOut } = useAuth()
  const navigate = useNavigate()
  const [isSigningOut, setIsSigningOut] = useState(false)
  const [signOutError, setSignOutError] = useState<string | null>(null)
  const metadataName = user?.user_metadata.name
  const displayName =
    typeof metadataName === 'string' && metadataName.trim()
      ? metadataName.trim()
      : (user?.email ?? 'Estudante')

  const handleSignOut = async () => {
    setSignOutError(null)
    setIsSigningOut(true)
    const result = await signOut()
    setIsSigningOut(false)

    if (result.error) {
      setSignOutError(result.error)
      return
    }

    navigate('/login', { replace: true })
  }

  return (
    <div className="min-h-screen bg-canvas">
      <Sidebar />

      <div className="min-h-screen lg:pl-64">
        <header className="sticky top-0 z-20 border-b border-slate-200/80 bg-white/90 backdrop-blur-xl">
          <div className="mx-auto flex h-[72px] max-w-[1440px] items-center justify-between px-4 sm:px-6 lg:px-8">
            <div className="flex min-w-0 items-center gap-3 lg:hidden">
              <MobileNavigation />
              <Brand compact />
              <CertificationIdentity certification={currentCertification} tone="light" />
            </div>
            <div className="hidden lg:block">
              <p className="text-xs font-semibold uppercase tracking-[0.16em] text-blue-600">
                Certificação ativa
              </p>
              <CertificationIdentity certification={currentCertification} tone="light" />
            </div>
            <div className="flex items-center gap-2 sm:gap-3">
              <Link
                to="/certifications"
                className="hidden min-h-11 items-center gap-2 rounded-xl px-3 text-sm font-semibold text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 xl:flex"
              >
                <ArrowLeftRight aria-hidden="true" className="h-4 w-4" />
                Trocar certificação
              </Link>
              <div className="hidden text-right md:block">
                <p className="text-xs text-slate-400">Olá,</p>
                <p className="max-w-40 truncate text-sm font-semibold text-slate-800">{displayName}</p>
              </div>
              {signOutError && (
                <p role="alert" className="hidden max-w-44 text-xs font-medium text-rose-600 2xl:block">
                  {signOutError}
                </p>
              )}
              <button
                type="button"
                onClick={handleSignOut}
                disabled={isSigningOut}
                aria-label="Sair da conta"
                className="flex h-11 min-w-11 items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-3 text-sm font-semibold text-slate-600 transition hover:border-slate-300 hover:bg-slate-50 hover:text-slate-900 disabled:cursor-wait disabled:opacity-60"
              >
                {isSigningOut ? (
                  <LoaderCircle aria-hidden="true" className="h-4 w-4 animate-spin" />
                ) : (
                  <LogOut aria-hidden="true" className="h-4 w-4" />
                )}
                <span className="hidden sm:inline">Sair</span>
              </button>
            </div>
          </div>
        </header>

        <main className="mx-auto w-full max-w-[1440px] px-4 py-8 sm:px-6 sm:py-10 lg:px-8 lg:py-12">
          <Outlet />
        </main>
      </div>
    </div>
  )
}

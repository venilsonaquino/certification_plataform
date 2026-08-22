import { ArrowLeftRight, Menu, X } from 'lucide-react'
import { useEffect, useRef, useState } from 'react'
import { Link } from 'react-router-dom'

import { useCertification } from '../../hooks/useCertification'
import { Brand } from '../Brand'
import { CertificationIdentity } from '../certifications/CertificationIdentity'
import { NavigationLinks } from './NavigationLinks'

export function MobileNavigation() {
  const { currentCertification } = useCertification()
  const [isOpen, setIsOpen] = useState(false)
  const closeButtonRef = useRef<HTMLButtonElement>(null)
  const triggerButtonRef = useRef<HTMLButtonElement>(null)

  const closeNavigation = () => setIsOpen(false)

  useEffect(() => {
    if (!isOpen) {
      return
    }

    const previousOverflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    closeButtonRef.current?.focus()

    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        closeNavigation()
        triggerButtonRef.current?.focus()
      }
    }

    document.addEventListener('keydown', handleKeyDown)

    return () => {
      document.body.style.overflow = previousOverflow
      document.removeEventListener('keydown', handleKeyDown)
    }
  }, [isOpen])

  const closeAndRestoreFocus = () => {
    closeNavigation()
    triggerButtonRef.current?.focus()
  }

  return (
    <>
      <button
        ref={triggerButtonRef}
        type="button"
        aria-label="Abrir menu de navegação"
        aria-controls="mobile-navigation"
        aria-expanded={isOpen}
        onClick={() => setIsOpen(true)}
        className="grid h-11 w-11 shrink-0 place-items-center rounded-xl border border-slate-200 bg-white text-slate-700 transition-colors hover:border-slate-300 hover:bg-slate-50 lg:hidden"
      >
        <Menu aria-hidden="true" className="h-5 w-5" />
      </button>

      {isOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <button
            type="button"
            aria-label="Fechar menu de navegação"
            onClick={closeAndRestoreFocus}
            className="absolute inset-0 bg-slate-950/55 backdrop-blur-[2px]"
          />

          <aside
            id="mobile-navigation"
            aria-label="Menu de navegação"
            className="relative flex h-full w-[min(20rem,86vw)] flex-col overflow-hidden bg-navy-900 shadow-2xl shadow-slate-950/30"
          >
            <div className="pointer-events-none absolute -left-20 top-24 h-64 w-64 rounded-full bg-blue-600/10 blur-3xl" />

            <div className="relative flex h-[72px] items-center justify-between border-b border-white/[0.07] px-5">
              <Brand />
              <button
                ref={closeButtonRef}
                type="button"
                aria-label="Fechar menu"
                onClick={closeAndRestoreFocus}
                className="grid h-10 w-10 place-items-center rounded-xl text-slate-400 transition-colors hover:bg-white/10 hover:text-white"
              >
                <X aria-hidden="true" className="h-5 w-5" />
              </button>
            </div>

            <div className="relative border-b border-white/[0.07] px-5 py-5">
              <p className="mb-3 text-[10px] font-semibold uppercase tracking-[0.18em] text-slate-600">
                Certificação ativa
              </p>
              <CertificationIdentity certification={currentCertification} />
            </div>

            <div className="relative flex-1 overflow-y-auto px-4 py-6">
              <p className="mb-3 px-3.5 text-[10px] font-semibold uppercase tracking-[0.18em] text-slate-600">
                Sua jornada
              </p>
              <NavigationLinks onNavigate={closeNavigation} />
            </div>

            <div className="relative border-t border-white/[0.07] p-4">
              <Link
                to="/certifications"
                onClick={closeNavigation}
                className="flex min-h-11 items-center gap-3 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-400 transition-colors hover:bg-white/[0.06] hover:text-white"
              >
                <ArrowLeftRight aria-hidden="true" className="h-[18px] w-[18px] text-slate-500" />
                Trocar certificação
              </Link>
            </div>
          </aside>
        </div>
      )}
    </>
  )
}

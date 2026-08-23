import { NavLink } from 'react-router-dom'

import { navigationItems } from '../../data/navigation'
import { useCertification } from '../../hooks/useCertification'
import { certificationRoute } from '../../lib/routes'

interface NavigationLinksProps {
  onNavigate?: () => void
}

export function NavigationLinks({ onNavigate }: NavigationLinksProps) {
  const { certificationCode } = useCertification()

  return (
    <nav aria-label="Navegação principal" className="space-y-1">
      {navigationItems.map(({ icon: Icon, label, segment }) => {
        const path = certificationRoute(certificationCode, segment)

        return (
          <NavLink
            key={path}
            to={path}
            end={segment !== 'study'}
            onClick={onNavigate}
            className={({ isActive }) =>
              [
                'group relative flex min-h-11 items-center gap-3 rounded-xl px-3.5 py-2.5 text-sm font-medium transition-colors duration-150',
                isActive
                  ? 'bg-white/10 text-white shadow-sm ring-1 ring-inset ring-white/10'
                  : 'text-slate-400 hover:bg-white/[0.06] hover:text-slate-100',
              ].join(' ')
            }
          >
            {({ isActive }) => (
              <>
                <span
                  aria-hidden="true"
                  className={[
                    'absolute inset-y-2 left-0 w-0.5 rounded-full bg-sky-400 transition-opacity',
                    isActive ? 'opacity-100' : 'opacity-0',
                  ].join(' ')}
                />
                <Icon
                  aria-hidden="true"
                  className={[
                    'h-[18px] w-[18px] shrink-0 transition-colors',
                    isActive ? 'text-sky-400' : 'text-slate-500 group-hover:text-slate-300',
                  ].join(' ')}
                  strokeWidth={1.9}
                />
                <span>{label}</span>
              </>
            )}
          </NavLink>
        )
      })}
    </nav>
  )
}

import { Outlet } from 'react-router-dom'

import { Brand } from '../components/Brand'

export function AuthLayout() {
  return (
    <div className="min-h-screen bg-white lg:grid lg:grid-cols-[minmax(22rem,0.82fr)_1.18fr]">
      <aside className="relative hidden min-h-screen overflow-hidden bg-navy-900 p-10 lg:flex lg:flex-col xl:p-14">
        <div className="pointer-events-none absolute -left-24 top-24 h-80 w-80 rounded-full bg-blue-600/15 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-20 -right-20 h-72 w-72 rounded-full bg-sky-400/10 blur-3xl" />
        <div className="relative">
          <Brand />
        </div>

        <div className="relative my-auto max-w-md py-16">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-sky-400">
            Certification Academy
          </p>
          <h2 className="mt-5 text-balance text-4xl font-bold tracking-tight text-white xl:text-5xl">
            Sua jornada começa com uma base sólida.
          </h2>
          <p className="mt-5 text-base leading-7 text-slate-400">
            Acesse seu espaço de estudos e continue avançando na sua certificação.
          </p>
        </div>

        <p className="relative text-xs font-medium text-slate-600">
          Microsoft Certifications
        </p>
      </aside>

      <main className="flex min-h-screen flex-col bg-canvas">
        <div className="border-b border-slate-200/80 bg-white px-5 py-4 lg:hidden">
          <Brand tone="light" />
        </div>
        <div className="flex flex-1 items-center justify-center px-4 py-10 sm:px-8 lg:px-12">
          <div className="w-full max-w-md">
            <Outlet />
          </div>
        </div>
      </main>
    </div>
  )
}

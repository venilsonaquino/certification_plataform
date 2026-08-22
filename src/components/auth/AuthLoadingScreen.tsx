import { LoaderCircle } from 'lucide-react'

import { Brand } from '../Brand'

export function AuthLoadingScreen() {
  return (
    <main className="grid min-h-screen place-items-center bg-canvas px-4">
      <div className="flex flex-col items-center text-center">
        <Brand tone="light" />
        <LoaderCircle aria-hidden="true" className="mt-8 h-6 w-6 animate-spin text-blue-600" />
        <p className="mt-3 text-sm font-medium text-slate-500">Carregando...</p>
      </div>
    </main>
  )
}

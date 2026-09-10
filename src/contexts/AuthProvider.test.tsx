import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({
  getSession: vi.fn(),
  onAuthStateChange: vi.fn(),
  signUp: vi.fn(),
  signOut: vi.fn(),
  unsubscribe: vi.fn(),
}))

vi.mock('../lib/supabase', () => ({
  isSupabaseConfigured: true,
  supabase: {
    auth: {
      getSession: mocks.getSession,
      onAuthStateChange: mocks.onAuthStateChange,
      signUp: mocks.signUp,
      signOut: mocks.signOut,
    },
  },
}))

import { useAuth } from '../hooks/useAuth'
import { AuthProvider } from './AuthProvider'

function AuthProbe() {
  const { user, loading, signOut, signUp } = useAuth()
  if (loading) return <p>Carregando sessão</p>
  return (
    <div>
      <p>{user?.id ?? 'sem usuário'}</p>
      <button type="button" onClick={() => void signUp('Ana', 'ana@example.com', 'a-secure-password')}>Criar conta</button>
      <button type="button" onClick={() => void signOut()}>Sair</button>
    </div>
  )
}

describe('AuthProvider', () => {
  beforeEach(() => {
    sessionStorage.clear()
    mocks.getSession.mockReset()
    mocks.onAuthStateChange.mockReset()
    mocks.signUp.mockReset()
    mocks.signOut.mockReset()
    mocks.unsubscribe.mockReset()
    mocks.onAuthStateChange.mockReturnValue({
      data: { subscription: { unsubscribe: mocks.unsubscribe } },
    })
    mocks.getSession.mockResolvedValue({
      data: { session: { user: { id: 'user-a' } } },
      error: null,
    })
    mocks.signOut.mockResolvedValue({ error: null })
    mocks.signUp.mockResolvedValue({ data: { user: { identities: [{}] }, session: null }, error: null })
  })

  it('remove estado de navegação do Mock no logout local', async () => {
    sessionStorage.setItem('mock-position:attempt-a', '7')
    sessionStorage.setItem('safe-unrelated-ui', 'preserve')
    render(<AuthProvider><AuthProbe /></AuthProvider>)
    expect(await screen.findByText('user-a')).toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'Sair' }))
    await waitFor(() => expect(screen.getByText('sem usuário')).toBeInTheDocument())
    expect(mocks.signOut).toHaveBeenCalledWith({ scope: 'local' })
    expect(sessionStorage.getItem('mock-position:attempt-a')).toBeNull()
    expect(sessionStorage.getItem('safe-unrelated-ui')).toBe('preserve')
  })

  it('informa ao Supabase o destino de confirmação da aplicação atual', async () => {
    render(<AuthProvider><AuthProbe /></AuthProvider>)
    await screen.findByText('user-a')

    await userEvent.click(screen.getByRole('button', { name: 'Criar conta' }))

    expect(mocks.signUp).toHaveBeenCalledWith({
      email: 'ana@example.com',
      password: 'a-secure-password',
      options: {
        data: { name: 'Ana' },
        emailRedirectTo: `${window.location.origin}/dashboard`,
      },
    })
  })
})

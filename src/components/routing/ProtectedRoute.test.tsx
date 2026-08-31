import { useState } from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({ useAuth: vi.fn() }))

vi.mock('../../hooks/useAuth', () => ({ useAuth: mocks.useAuth }))

import { ProtectedRoute } from './ProtectedRoute'

function PrivateState() {
  const [value, setValue] = useState(0)
  return <button type="button" onClick={() => setValue((current) => current + 1)}>Estado {value}</button>
}

function TestRouter() {
  return (
    <MemoryRouter initialEntries={['/private']} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
      <Routes>
        <Route element={<ProtectedRoute />}>
          <Route path="/private" element={<PrivateState />} />
        </Route>
        <Route path="/login" element={<p>Login seguro</p>} />
      </Routes>
    </MemoryRouter>
  )
}

describe('ProtectedRoute', () => {
  it('não renderiza conteúdo privado enquanto a sessão ainda é desconhecida', () => {
    mocks.useAuth.mockReturnValue({ user: null, loading: true })
    render(<TestRouter />)
    expect(screen.getByText('Carregando...')).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: /Estado/ })).not.toBeInTheDocument()
  })

  it('descarta todo state privado quando o owner autenticado muda', async () => {
    let user = { id: 'user-a' }
    mocks.useAuth.mockImplementation(() => ({ user, loading: false }))
    const view = render(<TestRouter />)
    await userEvent.click(screen.getByRole('button', { name: 'Estado 0' }))
    expect(screen.getByRole('button', { name: 'Estado 1' })).toBeInTheDocument()

    user = { id: 'user-b' }
    view.rerender(<TestRouter />)
    expect(screen.getByRole('button', { name: 'Estado 0' })).toBeInTheDocument()
  })
})

import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'

import { MobileNavigation } from './MobileNavigation'
import { NavigationLinks } from './NavigationLinks'

vi.mock('../../hooks/useCertification', () => ({
  useCertification: () => ({
    certificationCode: 'az-900',
    currentCertification: {
      id: 'certification-az900',
      code: 'az-900',
      name: 'Azure Fundamentals',
      provider: 'Microsoft',
      description: null,
      level: 'Fundamentals',
      isEnabled: true,
      displayOrder: 1,
      createdAt: '2026-08-30T00:00:00.000Z',
      updatedAt: '2026-08-30T00:00:00.000Z',
    },
  }),
}))

const expectedLabels = [
  'Dashboard',
  'Estudo do Dia',
  'Trilha de estudos',
  'Revisão',
  'Simulados',
  'Readiness',
  'Progresso de estudo',
]

describe('responsive product navigation', () => {
  it('renderiza sete links claros, acessíveis e com estado ativo', () => {
    render(
      <MemoryRouter
        initialEntries={['/certifications/az-900/readiness']}
        future={{ v7_startTransition: true, v7_relativeSplatPath: true }}
      >
        <NavigationLinks />
      </MemoryRouter>,
    )

    const navigation = screen.getByRole('navigation', { name: 'Navegação principal' })
    expect(screen.getAllByRole('link').map((link) => link.textContent)).toEqual(expectedLabels)
    expect(navigation).not.toHaveTextContent(/Mapa|Laboratórios|Story Mode|^Quiz$/)
    expect(screen.getByRole('link', { name: 'Readiness' })).toHaveAttribute('aria-current', 'page')
    for (const link of screen.getAllByRole('link')) expect(link).toHaveClass('min-h-11')
  })

  it('abre e fecha o menu mobile por teclado sem perder o foco do gatilho', async () => {
    const user = userEvent.setup()
    render(
      <MemoryRouter
        initialEntries={['/certifications/az-900/dashboard']}
        future={{ v7_startTransition: true, v7_relativeSplatPath: true }}
      >
        <MobileNavigation />
      </MemoryRouter>,
    )

    const trigger = screen.getByRole('button', { name: 'Abrir menu de navegação' })
    await user.click(trigger)

    expect(trigger).toHaveAttribute('aria-expanded', 'true')
    expect(screen.getByRole('complementary', { name: 'Menu de navegação' }))
      .toBeInTheDocument()
    for (const label of expectedLabels) {
      expect(screen.getByRole('link', { name: label })).toBeInTheDocument()
    }

    await user.keyboard('{Escape}')
    expect(screen.queryByRole('complementary', { name: 'Menu de navegação' }))
      .not.toBeInTheDocument()
    expect(trigger).toHaveFocus()
  })
})

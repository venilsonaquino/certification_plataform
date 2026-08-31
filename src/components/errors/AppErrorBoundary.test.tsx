import { render, screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'

import { AppErrorBoundary } from './AppErrorBoundary'

function BrokenView(): never {
  throw new Error('technical render details')
}

describe('AppErrorBoundary', () => {
  it('isola falha inesperada sem mostrar detalhes técnicos ao usuário', () => {
    vi.spyOn(console, 'error').mockImplementation(() => undefined)

    render(
      <AppErrorBoundary>
        <BrokenView />
      </AppErrorBoundary>,
    )

    expect(screen.getByRole('heading', { name: 'Algo inesperado aconteceu.' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Recarregar' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Voltar ao início' })).toHaveAttribute('href', '/')
    expect(screen.queryByText('technical render details')).not.toBeInTheDocument()
  })
})

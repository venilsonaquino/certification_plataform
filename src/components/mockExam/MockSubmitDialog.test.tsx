import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import { MockSubmitDialog } from './MockSubmitDialog'

describe('MockSubmitDialog', () => {
  it('mostra o resumo, permite cancelar e exige confirmação explícita', async () => {
    const onCancel = vi.fn()
    const onConfirm = vi.fn()
    render(
      <MockSubmitDialog
        open
        answered={36}
        total={40}
        submitting={false}
        error={null}
        onCancel={onCancel}
        onConfirm={onConfirm}
      />,
    )

    expect(screen.getByRole('dialog')).toHaveTextContent('4 não respondidas')
    await userEvent.click(screen.getByRole('button', { name: 'Voltar ao Mock' }))
    await userEvent.click(screen.getByRole('button', { name: 'Confirmar envio' }))
    expect(onCancel).toHaveBeenCalledOnce()
    expect(onConfirm).toHaveBeenCalledOnce()
  })

  it('bloqueia ações durante submit', () => {
    render(
      <MockSubmitDialog
        open
        answered={40}
        total={40}
        submitting
        error={null}
        onCancel={vi.fn()}
        onConfirm={vi.fn()}
      />,
    )
    expect(screen.getByRole('button', { name: 'Enviando...' })).toBeDisabled()
    expect(screen.getByRole('button', { name: 'Voltar ao Mock' })).toBeDisabled()
  })
})

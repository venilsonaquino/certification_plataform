import { act, render, screen } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'

import { MockExamTimer } from './MockExamTimer'

describe('MockExamTimer', () => {
  afterEach(() => {
    vi.useRealTimers()
    vi.restoreAllMocks()
  })

  it('shows textual warning states and finalizes once at zero', () => {
    vi.useFakeTimers()
    let monotonicNow = 0
    vi.spyOn(performance, 'now').mockImplementation(() => monotonicNow)
    const onExpire = vi.fn()
    render(<MockExamTimer expiresAt="2026-08-30T12:00:02.000Z" serverNow="2026-08-30T12:00:00.000Z" onExpire={onExpire} />)
    expect(screen.getByRole('timer')).toHaveTextContent('Critical: 00:02 remaining')
    monotonicNow = 2500
    act(() => vi.advanceTimersByTime(1000))
    expect(screen.getByRole('timer')).toHaveTextContent('00:00 remaining')
    expect(onExpire).toHaveBeenCalledOnce()
    monotonicNow = 5500
    act(() => vi.advanceTimersByTime(3000))
    expect(onExpire).toHaveBeenCalledOnce()
  })

  it('uses Warning text instead of color alone', () => {
    render(<MockExamTimer expiresAt="2026-08-30T12:09:00.000Z" serverNow="2026-08-30T12:00:00.000Z" onExpire={() => undefined} />)
    expect(screen.getByRole('timer')).toHaveTextContent('Warning: 09:00 remaining')
    expect(screen.getByRole('timer')).toHaveAttribute('aria-live', 'off')
    expect(screen.getByText('Timer status: Warning')).toHaveAttribute('aria-live', 'polite')
  })
})

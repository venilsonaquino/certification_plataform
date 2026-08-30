import { describe, expect, it } from 'vitest'

import { formatCountdown, formatElapsedTime, getRemainingSeconds } from './mockExamTime'

describe('Mock Exam time helpers', () => {
  it('derives remaining time from persisted server timestamps', () => {
    const expiresAt = '2026-08-30T13:00:00.000Z'
    expect(getRemainingSeconds(expiresAt, '2026-08-30T12:00:00.000Z')).toBe(3600)
    expect(getRemainingSeconds(expiresAt, '2026-08-30T12:17:42.000Z')).toBe(2538)
  })

  it('never exposes negative time and formats countdown and duration', () => {
    expect(getRemainingSeconds('2026-08-30T12:00:00.000Z', '2026-08-30T12:01:00.000Z')).toBe(0)
    expect(formatCountdown(1938)).toBe('32:18')
    expect(formatElapsedTime(2058)).toBe('34m 18s')
  })
})

import { act, renderHook, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import type { Az900ReadinessDashboardData } from '../types/readinessUi'

const mocks = vi.hoisted(() => ({
  getAz900ReadinessDashboard: vi.fn(),
  useAuth: vi.fn(),
}))

vi.mock('../services/readinessDashboardService', () => ({
  getAz900ReadinessDashboard: mocks.getAz900ReadinessDashboard,
}))
vi.mock('./useAuth', () => ({ useAuth: mocks.useAuth }))

import { useCertificationReadiness } from './useCertificationReadiness'

function deferred<T>() {
  let resolve!: (value: T) => void
  const promise = new Promise<T>((next) => { resolve = next })
  return { promise, resolve }
}

function dashboard(classification: 'needs_review' | 'strong') {
  return {
    readiness: { classification },
    recommendations: { topics: [] },
    recentMocks: [],
  } as unknown as Az900ReadinessDashboardData
}

describe('useCertificationReadiness', () => {
  beforeEach(() => {
    mocks.getAz900ReadinessDashboard.mockReset()
    mocks.useAuth.mockReset()
  })

  it('isola mudanças de usuário e ignora uma resposta atrasada da sessão anterior', async () => {
    let user = { id: 'user-a' }
    mocks.useAuth.mockImplementation(() => ({ user }))
    const requestA = deferred<Az900ReadinessDashboardData>()
    const requestB = deferred<Az900ReadinessDashboardData>()
    mocks.getAz900ReadinessDashboard
      .mockReturnValueOnce(requestA.promise)
      .mockReturnValueOnce(requestB.promise)

    const { result, rerender } = renderHook(() =>
      useCertificationReadiness('certification-1', 'az-900'))
    await waitFor(() => expect(mocks.getAz900ReadinessDashboard).toHaveBeenCalledTimes(1))

    user = { id: 'user-b' }
    rerender()
    await waitFor(() => expect(mocks.getAz900ReadinessDashboard).toHaveBeenCalledTimes(2))
    await act(async () => requestB.resolve(dashboard('strong')))
    await waitFor(() => expect(result.current.data?.readiness.classification).toBe('strong'))

    await act(async () => requestA.resolve(dashboard('needs_review')))
    expect(result.current.data?.readiness.classification).toBe('strong')
  })

  it('limpa dados no logout e retry cria uma nova consulta owner-scoped', async () => {
    let user: { id: string } | null = { id: 'user-a' }
    mocks.useAuth.mockImplementation(() => ({ user }))
    mocks.getAz900ReadinessDashboard.mockResolvedValue(dashboard('needs_review'))
    const { result, rerender } = renderHook(() =>
      useCertificationReadiness('certification-1', 'az-900'))
    await waitFor(() => expect(result.current.data).not.toBeNull())

    act(() => result.current.retry())
    await waitFor(() => expect(mocks.getAz900ReadinessDashboard).toHaveBeenCalledTimes(2))

    user = null
    rerender()
    await waitFor(() => expect(result.current.loading).toBe(false))
    expect(result.current.data).toBeNull()
    expect(mocks.getAz900ReadinessDashboard).toHaveBeenCalledTimes(2)
  })
})

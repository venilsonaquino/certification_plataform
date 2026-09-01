import { act, renderHook, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import type { FlashcardReviewOverview } from '../types/flashcard'

const mocks = vi.hoisted(() => ({ getFlashcardReviewOverview: vi.fn() }))

vi.mock('../services/flashcardService', () => ({
  getFlashcardReviewOverview: mocks.getFlashcardReviewOverview,
}))

import { useFlashcardReviewOverview } from './useFlashcardReviewOverview'

function deferred<T>() {
  let resolve!: (value: T) => void
  let reject!: (reason: unknown) => void
  const promise = new Promise<T>((next, fail) => { resolve = next; reject = fail })
  return { promise, resolve, reject }
}

function overview(queueCount: number): FlashcardReviewOverview {
  return { queueCount, dueCount: queueCount, newCount: 0, nextReviewAt: null, availableFlashcardCount: queueCount, totalFlashcardCount: queueCount }
}

describe('useFlashcardReviewOverview', () => {
  beforeEach(() => mocks.getFlashcardReviewOverview.mockReset())

  it('ignora resposta atrasada da certificação anterior', async () => {
    const requestA = deferred<FlashcardReviewOverview>()
    const requestB = deferred<FlashcardReviewOverview>()
    mocks.getFlashcardReviewOverview
      .mockReturnValueOnce(requestA.promise)
      .mockReturnValueOnce(requestB.promise)

    const { result, rerender } = renderHook(
      ({ certificationId }) => useFlashcardReviewOverview(certificationId),
      { initialProps: { certificationId: 'certification-a' as string | null } },
    )
    await waitFor(() => expect(mocks.getFlashcardReviewOverview).toHaveBeenCalledTimes(1))
    rerender({ certificationId: 'certification-b' })
    await waitFor(() => expect(mocks.getFlashcardReviewOverview).toHaveBeenCalledTimes(2))

    await act(async () => requestB.resolve(overview(2)))
    await waitFor(() => expect(result.current.overview?.queueCount).toBe(2))
    await act(async () => requestA.resolve(overview(99)))
    expect(result.current.overview?.queueCount).toBe(2)
  })

})

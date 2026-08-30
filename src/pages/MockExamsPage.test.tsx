import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({
  useCertification: vi.fn(),
  getActiveMockExamAttempt: vi.fn(),
  startMockExam: vi.fn(),
}))

vi.mock('../hooks/useCertification', () => ({ useCertification: mocks.useCertification }))
vi.mock('../services/mockExamService', () => ({
  getActiveMockExamAttempt: mocks.getActiveMockExamAttempt,
  startMockExam: mocks.startMockExam,
}))

import { MockExamsPage } from './MockExamsPage'

const attempt = {
  id: 'attempt-1',
  certificationId: 'certification-1',
}

function renderPage() {
  return render(
    <MemoryRouter initialEntries={['/certifications/az-900/exams']} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
      <Routes>
        <Route path="/certifications/:certificationCode/exams" element={<MockExamsPage />} />
        <Route path="/certifications/:certificationCode/exams/:attemptId" element={<p>Runner aberto</p>} />
      </Routes>
    </MemoryRouter>,
  )
}

describe('MockExamsPage', () => {
  beforeEach(() => {
    Object.values(mocks).forEach((mock) => mock.mockReset())
    mocks.useCertification.mockReturnValue({ currentCertification: { id: 'certification-1', code: 'az-900' } })
    mocks.getActiveMockExamAttempt.mockResolvedValue(null)
  })

  it('inicia uma única tentativa mesmo com clique repetido e abre o runner', async () => {
    let resolveStart: (value: typeof attempt) => void = () => undefined
    mocks.startMockExam.mockReturnValue(new Promise((resolve) => { resolveStart = resolve }))
    renderPage()
    const start = await screen.findByRole('button', { name: 'Start Mock' })

    await userEvent.click(start)
    await userEvent.click(start)
    expect(mocks.startMockExam).toHaveBeenCalledOnce()
    resolveStart(attempt)
    expect(await screen.findByText('Runner aberto')).toBeInTheDocument()
  })

  it('exibe erro controlado quando o pool é insuficiente', async () => {
    vi.spyOn(console, 'error').mockImplementation(() => undefined)
    mocks.startMockExam.mockRejectedValue(new Error('insufficient mock pool'))
    renderPage()

    await userEvent.click(await screen.findByRole('button', { name: 'Start Mock' }))
    await waitFor(() => expect(screen.getByRole('alert')).toHaveTextContent('capacidade suficiente'))
    expect(screen.queryByText('insufficient mock pool')).not.toBeInTheDocument()
  })

  it('oferece resume sem criar outra tentativa', async () => {
    mocks.getActiveMockExamAttempt.mockResolvedValue(attempt)
    renderPage()

    await userEvent.click(await screen.findByRole('button', { name: 'Resume Mock' }))
    expect(await screen.findByText('Runner aberto')).toBeInTheDocument()
    expect(mocks.startMockExam).not.toHaveBeenCalled()
  })
})

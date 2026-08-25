import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { useVisualExperiences } from '../../hooks/useVisualExperiences'
import {
  comparisonExperience,
  flowExperience,
  invalidExperience,
} from '../../test/visualExperienceFixtures'
import { LessonVisualExperiences } from './LessonVisualExperiences'

vi.mock('../../hooks/useVisualExperiences', () => ({
  useVisualExperiences: vi.fn(),
}))

const mockedUseVisualExperiences = vi.mocked(useVisualExperiences)
const lessonId = '22222222-2222-4222-8222-222222222222'

describe('LessonVisualExperiences', () => {
  beforeEach(() => {
    mockedUseVisualExperiences.mockReset()
  })

  it('não renderiza seção quando a Lesson não possui visualizações', () => {
    mockedUseVisualExperiences.mockReturnValue({
      experiences: [],
      loading: false,
      error: null,
      retry: vi.fn(),
    })

    const { container } = render(<LessonVisualExperiences lessonId={lessonId} />)

    expect(mockedUseVisualExperiences).toHaveBeenCalledWith(lessonId)
    expect(container).toBeEmptyDOMElement()
    expect(screen.queryByRole('heading', { name: 'Visualize este conceito' }))
      .not.toBeInTheDocument()
  })

  it('isola uma experiência inválida entre duas válidas', () => {
    mockedUseVisualExperiences.mockReturnValue({
      experiences: [comparisonExperience(), invalidExperience(), flowExperience()],
      loading: false,
      error: null,
      retry: vi.fn(),
    })

    render(<LessonVisualExperiences lessonId={lessonId} />)

    expect(screen.getByRole('heading', { name: 'Visualize este conceito' })).toBeInTheDocument()
    expect(screen.getAllByRole('article')).toHaveLength(2)
    expect(screen.getByRole('article', { name: 'IaaS, PaaS e SaaS' })).toBeInTheDocument()
    expect(screen.getByRole('article', { name: 'Fluxo de autenticação' })).toBeInTheDocument()
    expect(screen.getByRole('alert')).toHaveTextContent(
      'Não foi possível carregar esta visualização.',
    )
  })

  it('mostra loading discreto sem criar uma seção vazia', () => {
    mockedUseVisualExperiences.mockReturnValue({
      experiences: [],
      loading: true,
      error: null,
      retry: vi.fn(),
    })

    render(<LessonVisualExperiences lessonId={lessonId} />)

    expect(screen.getByRole('status')).toHaveTextContent('Carregando visualizações...')
    expect(screen.queryByRole('heading', { name: 'Visualize este conceito' }))
      .not.toBeInTheDocument()
  })

  it('mostra erro inline e permite tentar novamente', async () => {
    const user = userEvent.setup()
    const retry = vi.fn()
    mockedUseVisualExperiences.mockReturnValue({
      experiences: [],
      loading: false,
      error: 'Falha de rede',
      retry,
    })

    render(<LessonVisualExperiences lessonId={lessonId} />)

    expect(screen.getByRole('alert')).toHaveTextContent(
      'Não foi possível carregar as visualizações desta aula.',
    )

    await user.click(screen.getByRole('button', { name: 'Tentar novamente' }))
    expect(retry).toHaveBeenCalledOnce()
  })
})

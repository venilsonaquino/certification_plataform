import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { useLessonContentBlocks } from '../../hooks/useLessonContentBlocks'
import { responsibilityExperience } from '../../test/visualExperienceFixtures'
import type {
  ExplanationContentBlock,
  RenderableLessonContentBlock,
} from '../../types/lessonContentBlock'
import { LessonContentRenderer } from './LessonContentRenderer'

vi.mock('../../hooks/useLessonContentBlocks', () => ({
  useLessonContentBlocks: vi.fn(),
}))

vi.mock('../visualExperiences/LessonVisualExperiences', () => ({
  LessonVisualExperiences: ({ lessonId }: { lessonId: string }) => (
    <div>Visualizações legadas de {lessonId}</div>
  ),
}))

const mockedUseLessonContentBlocks = vi.mocked(useLessonContentBlocks)
const lessonId = '22222222-2222-4222-8222-222222222222'

const explanationBlock: ExplanationContentBlock = {
  id: '33333333-3333-4333-8333-333333333333',
  lessonId,
  type: 'explanation',
  title: 'Nova explicação',
  content: 'Conteúdo estruturado.',
  config: null,
  visualExperienceId: null,
  displayOrder: 0,
  isPublished: true,
  createdAt: '2026-08-25T12:00:00.000Z',
  updatedAt: '2026-08-25T12:00:00.000Z',
}

const sharedResponsibilityBlocks = [
  {
    ...explanationBlock,
    id: '79000000-0000-4000-8000-000000000001',
    title: 'O que é?',
    content: 'Definição do modelo.',
    displayOrder: 1,
  },
  {
    ...explanationBlock,
    id: '79000000-0000-4000-8000-000000000002',
    type: 'important',
    title: 'Importante',
    content: 'A nuvem não elimina responsabilidades.',
    displayOrder: 2,
  },
  {
    id: '79000000-0000-4000-8000-000000000003',
    lessonId,
    type: 'visual_experience',
    title: 'Compare os modelos',
    content: null,
    config: null,
    visualExperienceId: '76000000-0000-4000-8000-000000000004',
    visualExperience: responsibilityExperience({
      id: '76000000-0000-4000-8000-000000000004',
      lessonId,
    }),
    displayOrder: 3,
    isPublished: true,
    createdAt: '2026-08-25T12:00:00.000Z',
    updatedAt: '2026-08-25T12:00:00.000Z',
  },
  {
    ...explanationBlock,
    id: '79000000-0000-4000-8000-000000000004',
    type: 'example',
    title: 'VM vs. App Service',
    content: 'Exemplo prático.',
    displayOrder: 4,
  },
  {
    ...explanationBlock,
    id: '79000000-0000-4000-8000-000000000005',
    type: 'dotnet_example',
    title: 'Exemplo com .NET',
    content: 'ASP.NET Core em dois modelos.',
    displayOrder: 5,
  },
  {
    ...explanationBlock,
    id: '79000000-0000-4000-8000-000000000006',
    type: 'exam_tip',
    title: 'O que lembrar para a prova',
    content: 'O provedor assume mais camadas.',
    displayOrder: 6,
  },
  {
    ...explanationBlock,
    id: '79000000-0000-4000-8000-000000000007',
    type: 'exam_trap',
    title: 'Não confunda',
    content: 'SaaS não elimina a responsabilidade do cliente.',
    displayOrder: 7,
  },
  {
    id: '79000000-0000-4000-8000-000000000008',
    lessonId,
    type: 'summary',
    title: 'Resumo',
    content: null,
    config: { items: ['Responsabilidade do cliente nunca desaparece.'] },
    visualExperienceId: null,
    displayOrder: 8,
    isPublished: true,
    createdAt: '2026-08-25T12:00:00.000Z',
    updatedAt: '2026-08-25T12:00:00.000Z',
  },
] satisfies readonly RenderableLessonContentBlock[]

describe('LessonContentRenderer', () => {
  beforeEach(() => {
    mockedUseLessonContentBlocks.mockReset()
  })

  it('prioriza blocks publicados e não duplica a seção visual legada', () => {
    mockedUseLessonContentBlocks.mockReturnValue({
      blocks: [explanationBlock],
      loading: false,
      error: null,
      retry: vi.fn(),
    })

    render(
      <LessonContentRenderer
        lessonId={lessonId}
        legacyContent={'## Conteúdo legado\n\nTexto antigo.'}
      />,
    )

    expect(screen.getByText('Conteúdo estruturado.')).toBeInTheDocument()
    expect(screen.queryByText('Texto antigo.')).not.toBeInTheDocument()
    expect(screen.queryByText(/Visualizações legadas/)).not.toBeInTheDocument()
  })

  it('renderiza a Lesson piloto na sequência educacional definida', () => {
    mockedUseLessonContentBlocks.mockReturnValue({
      blocks: sharedResponsibilityBlocks,
      loading: false,
      error: null,
      retry: vi.fn(),
    })

    const { container } = render(
      <LessonContentRenderer lessonId={lessonId} legacyContent="Conteúdo legado." />,
    )

    expect(
      [...container.querySelectorAll('[data-content-block-type]')].map((element) =>
        element.getAttribute('data-content-block-type'),
      ),
    ).toEqual([
      'explanation',
      'important',
      'visual_experience',
      'example',
      'dotnet_example',
      'exam_tip',
      'exam_trap',
      'summary',
    ])
    expect(
      screen.getByRole('article', { name: 'Modelo de responsabilidade compartilhada' }),
    ).toBeInTheDocument()
    expect(screen.getByText('Responsabilidade do cliente nunca desaparece.')).toBeInTheDocument()
    expect(screen.queryByText('Conteúdo legado.')).not.toBeInTheDocument()
  })

  it('aceita uma composição textual sem exigir mídia, laboratório ou exemplo .NET', () => {
    const textualBlocks = sharedResponsibilityBlocks.filter(({ type }) =>
      ['explanation', 'example', 'exam_tip', 'summary'].includes(type),
    )
    mockedUseLessonContentBlocks.mockReturnValue({
      blocks: textualBlocks,
      loading: false,
      error: null,
      retry: vi.fn(),
    })

    const { container } = render(
      <LessonContentRenderer lessonId={lessonId} legacyContent="Conteúdo legado." />,
    )

    expect(
      [...container.querySelectorAll('[data-content-block-type]')].map((element) =>
        element.getAttribute('data-content-block-type'),
      ),
    ).toEqual(['explanation', 'example', 'exam_tip', 'summary'])
    expect(container.querySelector('[data-content-block-type="image"]')).not.toBeInTheDocument()
    expect(container.querySelector('[data-content-block-type="video"]')).not.toBeInTheDocument()
    expect(container.querySelector('[data-content-block-type="azure_lab"]')).not.toBeInTheDocument()
    expect(container.querySelector('[data-content-block-type="dotnet_example"]')).not.toBeInTheDocument()
    expect(screen.queryByText('Conteúdo legado.')).not.toBeInTheDocument()
  })

  it('usa lessons.content e preserva as visualizações existentes sem blocks', () => {
    mockedUseLessonContentBlocks.mockReturnValue({
      blocks: [],
      loading: false,
      error: null,
      retry: vi.fn(),
    })

    render(
      <LessonContentRenderer
        lessonId={lessonId}
        legacyContent={'## Conteúdo legado\n\nTexto antigo.'}
      />,
    )

    expect(screen.getByText('Texto antigo.')).toBeInTheDocument()
    expect(screen.getByText(`Visualizações legadas de ${lessonId}`)).toBeInTheDocument()
  })

  it('isola um block inválido entre dois válidos', () => {
    mockedUseLessonContentBlocks.mockReturnValue({
      blocks: [
        explanationBlock,
        {
          id: '44444444-4444-4444-8444-444444444444',
          lessonId,
          type: 'invalid',
          originalType: 'image',
          title: null,
          displayOrder: 1,
          isPublished: true,
          createdAt: '2026-08-25T12:00:00.000Z',
          updatedAt: '2026-08-25T12:00:00.000Z',
          issues: ['config.url: Invalid URL'],
        },
        { ...explanationBlock, id: '55555555-5555-4555-8555-555555555555', content: 'Depois.' },
      ],
      loading: false,
      error: null,
      retry: vi.fn(),
    })

    render(<LessonContentRenderer lessonId={lessonId} legacyContent={null} />)

    expect(screen.getByText('Conteúdo estruturado.')).toBeInTheDocument()
    expect(screen.getByRole('alert')).toHaveTextContent('Conteúdo indisponível.')
    expect(screen.getByText('Depois.')).toBeInTheDocument()
  })

  it('mostra erro de consulta e permite tentar novamente', async () => {
    const user = userEvent.setup()
    const retry = vi.fn()
    mockedUseLessonContentBlocks.mockReturnValue({
      blocks: [],
      loading: false,
      error: 'Falha de rede',
      retry,
    })

    render(<LessonContentRenderer lessonId={lessonId} legacyContent={null} />)

    await user.click(screen.getByRole('button', { name: 'Tentar novamente' }))
    expect(retry).toHaveBeenCalledOnce()
  })
})

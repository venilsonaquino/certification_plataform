import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { comparisonExperience } from '../../test/visualExperienceFixtures'
import type {
  AzureLabContentBlock,
  ImageContentBlock,
  LessonContentBlock,
  SummaryContentBlock,
  TextLessonContentBlock,
  VideoContentBlock,
  VisualExperienceContentBlock,
} from '../../types/lessonContentBlock'
import { LessonContentBlockRenderer } from './LessonContentBlockRenderer'

const metadata = {
  id: '33333333-3333-4333-8333-333333333333',
  lessonId: '22222222-2222-4222-8222-222222222222',
  title: null,
  displayOrder: 0,
  isPublished: true,
  createdAt: '2026-08-25T12:00:00.000Z',
  updatedAt: '2026-08-25T12:00:00.000Z',
} as const

function textBlock(type: TextLessonContentBlock['type']): TextLessonContentBlock {
  if (type === 'summary') {
    return {
      ...metadata,
      type,
      content: null,
      config: { items: ['Ponto do resumo'] },
      visualExperienceId: null,
    } satisfies SummaryContentBlock
  }

  return {
    ...metadata,
    type,
    content: `Conteúdo ${type}`,
    config: null,
    visualExperienceId: null,
  } as TextLessonContentBlock
}

const imageBlock: ImageContentBlock = {
  ...metadata,
  type: 'image',
  title: 'Diagrama seguro',
  content: null,
  config: {
    url: 'https://example.com/diagram.png',
    alt: 'Arquitetura de exemplo',
    caption: 'Legenda da imagem',
    sourceLabel: 'Fonte oficial',
    sourceUrl: 'https://example.com/source',
  },
  visualExperienceId: null,
}

const videoBlock: VideoContentBlock = {
  ...metadata,
  type: 'video',
  content: null,
  config: {
    url: 'https://www.youtube.com/watch?v=example',
    title: 'Vídeo seguro',
    provider: 'youtube',
    durationMinutes: 8,
  },
  visualExperienceId: null,
}

const visualBlock: VisualExperienceContentBlock = {
  ...metadata,
  type: 'visual_experience',
  content: null,
  config: null,
  visualExperienceId: '44444444-4444-4444-8444-444444444444',
  visualExperience: comparisonExperience({
    id: '44444444-4444-4444-8444-444444444444',
  }),
}

const azureLabBlock: AzureLabContentBlock = {
  ...metadata,
  type: 'azure_lab',
  content: null,
  config: {
    objective: 'Localizar zonas de disponibilidade.',
    steps: ['Abra o Portal', 'Procure Virtual Machines'],
    estimatedMinutes: 5,
    warning: 'Não conclua a criação do recurso.',
  },
  visualExperienceId: null,
}

const cases: ReadonlyArray<{
  type: LessonContentBlock['type']
  block: LessonContentBlock
  expectedText: string
}> = [
  { type: 'explanation', block: textBlock('explanation'), expectedText: 'Conteúdo explanation' },
  { type: 'important', block: textBlock('important'), expectedText: 'Conteúdo important' },
  { type: 'example', block: textBlock('example'), expectedText: 'Conteúdo example' },
  { type: 'dotnet_example', block: textBlock('dotnet_example'), expectedText: 'Conteúdo dotnet_example' },
  { type: 'exam_tip', block: textBlock('exam_tip'), expectedText: 'Conteúdo exam_tip' },
  { type: 'exam_trap', block: textBlock('exam_trap'), expectedText: 'Conteúdo exam_trap' },
  { type: 'summary', block: textBlock('summary'), expectedText: 'Ponto do resumo' },
  { type: 'image', block: imageBlock, expectedText: 'Diagrama seguro' },
  { type: 'video', block: videoBlock, expectedText: 'Vídeo seguro' },
  {
    type: 'visual_experience',
    block: visualBlock,
    expectedText: visualBlock.visualExperience?.description ?? '',
  },
  { type: 'azure_lab', block: azureLabBlock, expectedText: 'Localizar zonas de disponibilidade.' },
]

describe('LessonContentBlockRenderer', () => {
  it.each(cases)('despacha $type para o renderer correto', ({ type, block, expectedText }) => {
    const { container } = render(<LessonContentBlockRenderer block={block} />)

    expect(container.querySelector(`[data-content-block-type="${type}"]`)).toBeInTheDocument()
    expect(screen.getByText(expectedText)).toBeInTheDocument()
  })

  it('renderiza strings parecidas com HTML como texto inerte', () => {
    const htmlLikeText = '<script>alert(1)</script>'
    const block: ImageContentBlock = {
      ...imageBlock,
      title: null,
      config: { ...imageBlock.config, caption: htmlLikeText },
    }

    const { container } = render(<LessonContentBlockRenderer block={block} />)

    expect(container).toHaveTextContent(htmlLikeText)
    expect(container.querySelector('script')).not.toBeInTheDocument()
  })

  it('expõe texto alternativo e carregamento tardio para imagens', () => {
    render(<LessonContentBlockRenderer block={imageBlock} />)

    expect(screen.getByRole('img', { name: 'Arquitetura de exemplo' })).toHaveAttribute(
      'loading',
      'lazy',
    )
  })

  it('oferece um alvo de toque e um nome acessível contextual para vídeos', () => {
    render(<LessonContentBlockRenderer block={videoBlock} />)

    const link = screen.getByRole('link', {
      name: 'Assistir ao vídeo Vídeo seguro em uma nova aba',
    })
    expect(link).toHaveClass('min-h-11')
    expect(link).toHaveAttribute('target', '_blank')
    expect(link).toHaveAttribute('rel', expect.stringContaining('noopener'))
  })

  it('identifica semanticamente o aviso do laboratório', () => {
    render(<LessonContentBlockRenderer block={azureLabBlock} />)

    expect(screen.getByRole('list')).toHaveTextContent('Abra o Portal')
    expect(screen.getByRole('list')).toHaveTextContent('Procure Virtual Machines')
    expect(
      screen.getByRole('note', { name: 'Atenção antes de executar o laboratório' }),
    ).toHaveTextContent('Não conclua a criação do recurso.')
  })

  it('renderiza os pontos do resumo como uma lista semântica', () => {
    render(<LessonContentBlockRenderer block={textBlock('summary')} />)

    const [item] = screen.getAllByRole('listitem')
    expect(screen.getByRole('list')).toContainElement(item)
    expect(item).toHaveTextContent('Ponto do resumo')
  })
})

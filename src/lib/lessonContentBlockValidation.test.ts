import { describe, expect, it } from 'vitest'

import { parseLessonContentBlock } from './lessonContentBlockValidation'

const metadata = {
  id: '33333333-3333-4333-8333-333333333333',
  lessonId: '22222222-2222-4222-8222-222222222222',
  title: null,
  displayOrder: 0,
  isPublished: true,
  createdAt: '2026-08-25T12:00:00.000Z',
  updatedAt: '2026-08-25T12:00:00.000Z',
}

const validCandidates = [
  ...['explanation', 'important', 'example', 'dotnet_example', 'exam_tip', 'exam_trap'].map(
    (type) => ({
      ...metadata,
      type,
      content: 'Conteúdo textual.',
      config: null,
      visualExperienceId: null,
    }),
  ),
  {
    ...metadata,
    type: 'summary',
    content: null,
    config: { items: ['Primeiro ponto'] },
    visualExperienceId: null,
  },
  {
    ...metadata,
    type: 'image',
    content: null,
    config: {
      url: 'https://example.com/image.png',
      alt: 'Diagrama',
      caption: 'Legenda',
      sourceLabel: 'Microsoft Learn',
      sourceUrl: 'https://learn.microsoft.com/',
    },
    visualExperienceId: null,
  },
  {
    ...metadata,
    type: 'video',
    content: null,
    config: {
      url: 'https://www.youtube.com/watch?v=example',
      title: 'Vídeo complementar',
      provider: 'youtube',
      durationMinutes: 8,
    },
    visualExperienceId: null,
  },
  {
    ...metadata,
    type: 'visual_experience',
    content: null,
    config: null,
    visualExperienceId: '44444444-4444-4444-8444-444444444444',
  },
  {
    ...metadata,
    type: 'azure_lab',
    content: null,
    config: {
      objective: 'Encontrar Availability Zones.',
      steps: ['Abra o Portal Azure'],
      estimatedMinutes: 5,
      warning: 'Não crie recursos pagos.',
    },
    visualExperienceId: null,
  },
]

describe('parseLessonContentBlock', () => {
  it.each(validCandidates)('aceita config válido para $type', (candidate) => {
    const result = parseLessonContentBlock(candidate)

    expect(result.success).toBe(true)
    expect(result.block.type).toBe(candidate.type)
  })

  it.each([
    {
      ...validCandidates[7],
      config: { url: 'javascript:alert(1)', alt: 'Imagem insegura' },
    },
    {
      ...validCandidates[8],
      config: { url: 'https://example.com/video', title: 'Vídeo', provider: 'vimeo' },
    },
    {
      ...validCandidates[9],
      config: { visualJson: { duplicated: true } },
    },
    {
      ...validCandidates[10],
      config: { objective: 'Objetivo', steps: [] },
    },
    {
      ...validCandidates[6],
      config: { items: [42] },
    },
  ])('transforma config inválido de $type em block inválido', (candidate) => {
    const result = parseLessonContentBlock(candidate)

    expect(result.success).toBe(false)
    expect(result.block.type).toBe('invalid')
    expect(result.issues.length).toBeGreaterThan(0)
  })
})

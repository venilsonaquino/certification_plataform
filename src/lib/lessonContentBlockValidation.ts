import { z } from 'zod'

import type {
  InvalidLessonContentBlock,
  LessonContentBlock,
  LessonContentBlockParseResult,
} from '../types/lessonContentBlock'

const titleSchema = z.string().trim().min(1).max(200).nullable()
const contentSchema = z.string().trim().min(1).max(30_000)
const shortTextSchema = z.string().trim().min(1).max(500)
const urlSchema = z
  .string()
  .trim()
  .url()
  .max(2_048)
  .refine((value) => {
    const protocol = new URL(value).protocol
    return protocol === 'https:' || protocol === 'http:'
  }, 'Use uma URL HTTP ou HTTPS.')

const metadataShape = {
  id: z.string().uuid(),
  lessonId: z.string().uuid(),
  title: titleSchema,
  displayOrder: z.number().int().nonnegative(),
  isPublished: z.boolean(),
  createdAt: z.string().min(1),
  updatedAt: z.string().min(1),
}

export const summaryContentBlockConfigSchema = z
  .object({
    items: z.array(shortTextSchema).min(1).max(30),
  })
  .strict()

export const imageContentBlockConfigSchema = z
  .object({
    url: urlSchema,
    alt: z.string().trim().min(1).max(500),
    caption: shortTextSchema.optional(),
    sourceLabel: z.string().trim().min(1).max(120).optional(),
    sourceUrl: urlSchema.optional(),
  })
  .strict()

export const videoContentBlockConfigSchema = z
  .object({
    url: urlSchema,
    title: z.string().trim().min(1).max(200),
    provider: z.literal('youtube'),
    durationMinutes: z.number().int().positive().max(600).optional(),
  })
  .strict()

export const azureLabContentBlockConfigSchema = z
  .object({
    objective: z.string().trim().min(1).max(1_000),
    steps: z.array(z.string().trim().min(1).max(1_000)).min(1).max(30),
    estimatedMinutes: z.number().int().positive().max(240).optional(),
    warning: z.string().trim().min(1).max(1_000).optional(),
  })
  .strict()

function textBlockSchema<Type extends 'explanation' | 'important' | 'example' | 'dotnet_example' | 'exam_tip' | 'exam_trap'>(
  type: Type,
) {
  return z
    .object({
      ...metadataShape,
      type: z.literal(type),
      content: contentSchema,
      config: z.null(),
      visualExperienceId: z.null(),
    })
    .strict()
}

const summarySchema = z
  .object({
    ...metadataShape,
    type: z.literal('summary'),
    content: contentSchema.nullable(),
    config: summaryContentBlockConfigSchema.nullable(),
    visualExperienceId: z.null(),
  })
  .strict()
  .superRefine((block, context) => {
    if (block.content === null && block.config === null) {
      context.addIssue({
        code: 'custom',
        message: 'Informe content ou config.items para o resumo.',
        path: ['config'],
      })
    }
  })

const imageSchema = z
  .object({
    ...metadataShape,
    type: z.literal('image'),
    content: z.null(),
    config: imageContentBlockConfigSchema,
    visualExperienceId: z.null(),
  })
  .strict()

const videoSchema = z
  .object({
    ...metadataShape,
    type: z.literal('video'),
    content: z.null(),
    config: videoContentBlockConfigSchema,
    visualExperienceId: z.null(),
  })
  .strict()

const visualExperienceSchema = z
  .object({
    ...metadataShape,
    type: z.literal('visual_experience'),
    content: z.null(),
    config: z.null(),
    visualExperienceId: z.string().uuid(),
  })
  .strict()

const azureLabSchema = z
  .object({
    ...metadataShape,
    type: z.literal('azure_lab'),
    content: z.null(),
    config: azureLabContentBlockConfigSchema,
    visualExperienceId: z.null(),
  })
  .strict()

export const lessonContentBlockSchema = z.discriminatedUnion('type', [
  textBlockSchema('explanation'),
  textBlockSchema('important'),
  textBlockSchema('example'),
  textBlockSchema('dotnet_example'),
  textBlockSchema('exam_tip'),
  textBlockSchema('exam_trap'),
  summarySchema,
  imageSchema,
  videoSchema,
  visualExperienceSchema,
  azureLabSchema,
])

function getRecord(value: unknown): Record<string, unknown> | null {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : null
}

function getString(record: Record<string, unknown> | null, key: string, fallback = '') {
  const value = record?.[key]
  return typeof value === 'string' ? value : fallback
}

function getInvalidBlock(input: unknown, issues: readonly string[]): InvalidLessonContentBlock {
  const record = getRecord(input)
  const originalType = getString(record, 'type')
  const displayOrder = record?.displayOrder
  const isPublished = record?.isPublished

  return {
    id: getString(record, 'id', 'invalid-lesson-content-block'),
    lessonId: getString(record, 'lessonId'),
    type: 'invalid',
    originalType: originalType || null,
    title: getString(record, 'title') || null,
    displayOrder:
      typeof displayOrder === 'number' && Number.isInteger(displayOrder) && displayOrder >= 0
        ? displayOrder
        : 0,
    isPublished: typeof isPublished === 'boolean' ? isPublished : false,
    createdAt: getString(record, 'createdAt'),
    updatedAt: getString(record, 'updatedAt'),
    issues,
  }
}

export function parseLessonContentBlock(input: unknown): LessonContentBlockParseResult {
  const result = lessonContentBlockSchema.safeParse(input)

  if (result.success) {
    const block =
      result.data.type === 'visual_experience'
        ? { ...result.data, visualExperience: null }
        : result.data

    return {
      success: true,
      block: block as LessonContentBlock,
      issues: [],
    }
  }

  const issues = result.error.issues.map((issue) => {
    const path = issue.path.length > 0 ? issue.path.join('.') : 'contentBlock'
    return `${path}: ${issue.message}`
  })

  return {
    success: false,
    block: getInvalidBlock(input, issues),
    issues,
  }
}

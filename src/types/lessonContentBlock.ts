import type { Json } from './database'
import type { RenderableVisualExperience } from './visualExperience'

export const LESSON_CONTENT_BLOCK_TYPES = [
  'explanation',
  'important',
  'example',
  'dotnet_example',
  'exam_tip',
  'exam_trap',
  'summary',
  'image',
  'video',
  'visual_experience',
  'azure_lab',
] as const

export type LessonContentBlockType = (typeof LESSON_CONTENT_BLOCK_TYPES)[number]

export const TEXT_LESSON_CONTENT_BLOCK_TYPES = [
  'explanation',
  'important',
  'example',
  'dotnet_example',
  'exam_tip',
  'exam_trap',
  'summary',
] as const satisfies readonly LessonContentBlockType[]

export type TextLessonContentBlockType =
  (typeof TEXT_LESSON_CONTENT_BLOCK_TYPES)[number]

export type LessonContentBlockConfig = Readonly<Record<string, Json | undefined>>

interface LessonContentBlockMetadata {
  readonly id: string
  readonly lessonId: string
  readonly title: string | null
  readonly displayOrder: number
  readonly isPublished: boolean
  readonly createdAt: string
  readonly updatedAt: string
}

interface TextContentBlock<Type extends Exclude<TextLessonContentBlockType, 'summary'>>
  extends LessonContentBlockMetadata {
  readonly type: Type
  readonly content: string
  readonly config: null
  readonly visualExperienceId: null
}

export type ExplanationContentBlock = TextContentBlock<'explanation'>
export type ImportantContentBlock = TextContentBlock<'important'>
export type ExampleContentBlock = TextContentBlock<'example'>
export type DotNetExampleContentBlock = TextContentBlock<'dotnet_example'>
export type ExamTipContentBlock = TextContentBlock<'exam_tip'>
export type ExamTrapContentBlock = TextContentBlock<'exam_trap'>

export interface SummaryContentBlockConfig extends LessonContentBlockConfig {
  readonly items: string[]
}

export interface SummaryContentBlock extends LessonContentBlockMetadata {
  readonly type: 'summary'
  readonly content: string | null
  readonly config: SummaryContentBlockConfig | null
  readonly visualExperienceId: null
}

export interface ImageContentBlockConfig extends LessonContentBlockConfig {
  readonly url: string
  readonly alt: string
  readonly caption?: string
  readonly sourceLabel?: string
  readonly sourceUrl?: string
}

export interface ImageContentBlock extends LessonContentBlockMetadata {
  readonly type: 'image'
  readonly content: null
  readonly config: ImageContentBlockConfig
  readonly visualExperienceId: null
}

export interface VideoContentBlockConfig extends LessonContentBlockConfig {
  readonly url: string
  readonly title: string
  readonly provider: 'youtube'
  readonly durationMinutes?: number
}

export interface VideoContentBlock extends LessonContentBlockMetadata {
  readonly type: 'video'
  readonly content: null
  readonly config: VideoContentBlockConfig
  readonly visualExperienceId: null
}

export interface AzureLabContentBlockConfig extends LessonContentBlockConfig {
  readonly objective: string
  readonly steps: string[]
  readonly estimatedMinutes?: number
  readonly warning?: string
}

export interface AzureLabContentBlock extends LessonContentBlockMetadata {
  readonly type: 'azure_lab'
  readonly content: null
  readonly config: AzureLabContentBlockConfig
  readonly visualExperienceId: null
}

export interface VisualExperienceContentBlock extends LessonContentBlockMetadata {
  readonly type: 'visual_experience'
  readonly content: null
  readonly config: null
  readonly visualExperienceId: string
  readonly visualExperience: RenderableVisualExperience | null
}

export type TextLessonContentBlock =
  | ExplanationContentBlock
  | ImportantContentBlock
  | ExampleContentBlock
  | DotNetExampleContentBlock
  | ExamTipContentBlock
  | ExamTrapContentBlock
  | SummaryContentBlock

export type LessonContentBlock =
  | TextLessonContentBlock
  | ImageContentBlock
  | VideoContentBlock
  | VisualExperienceContentBlock
  | AzureLabContentBlock

export interface InvalidLessonContentBlock extends LessonContentBlockMetadata {
  readonly type: 'invalid'
  readonly originalType: string | null
  readonly issues: readonly string[]
}

export type RenderableLessonContentBlock = LessonContentBlock | InvalidLessonContentBlock

export type LessonContentBlockParseResult =
  | {
      readonly success: true
      readonly block: LessonContentBlock
      readonly issues: readonly []
    }
  | {
      readonly success: false
      readonly block: InvalidLessonContentBlock
      readonly issues: readonly string[]
    }

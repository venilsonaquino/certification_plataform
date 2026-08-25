export type VisualExperienceType = 'comparison' | 'architecture' | 'flow' | 'responsibility'

interface VisualExperienceMetadata {
  readonly id: string
  readonly lessonId: string
  readonly title: string
  readonly description: string
  readonly displayOrder: number
  readonly isPublished: boolean
  readonly createdAt: string
  readonly updatedAt: string
}

export interface ComparisonColumn {
  readonly id: string
  readonly title: string
  readonly description?: string
}

export interface ComparisonRow {
  readonly id: string
  readonly label: string
  readonly description?: string
  readonly values: Readonly<Record<string, string>>
}

export interface ComparisonConfig {
  readonly columns: readonly ComparisonColumn[]
  readonly rows: readonly ComparisonRow[]
}

export interface ComparisonVisualExperience extends VisualExperienceMetadata {
  readonly type: 'comparison'
  readonly config: ComparisonConfig
}

export type ArchitectureNodeKind = 'external' | 'service' | 'group' | 'zone' | 'resource'

export interface ArchitectureNode {
  readonly id: string
  readonly label: string
  readonly kind: ArchitectureNodeKind
  readonly description?: string
  readonly x?: number
  readonly y?: number
}

export interface ArchitectureEdge {
  readonly id: string
  readonly source: string
  readonly target: string
  readonly label?: string
}

export interface ArchitectureConfig {
  readonly nodes: readonly ArchitectureNode[]
  readonly edges: readonly ArchitectureEdge[]
}

export interface ArchitectureVisualExperience extends VisualExperienceMetadata {
  readonly type: 'architecture'
  readonly config: ArchitectureConfig
}

export interface FlowStep {
  readonly id: string
  readonly label: string
  readonly description?: string
}

export interface FlowConfig {
  readonly steps: readonly FlowStep[]
}

export interface FlowVisualExperience extends VisualExperienceMetadata {
  readonly type: 'flow'
  readonly config: FlowConfig
}

export type ResponsibilityOwner = 'customer' | 'provider' | 'shared'

export interface ResponsibilityOwnerDefinition {
  readonly label: string
  readonly description?: string
}

export interface ResponsibilityLayer {
  readonly id: string
  readonly label: string
  readonly description?: string
}

export interface ResponsibilityModel {
  readonly id: string
  readonly label: string
  readonly description: string
  readonly responsibilities: Readonly<Record<string, ResponsibilityOwner>>
  readonly example?: string
}

export interface ResponsibilityProgression {
  readonly startLabel: string
  readonly endLabel: string
}

export interface ResponsibilityConfig {
  readonly owners: {
    readonly customer: ResponsibilityOwnerDefinition
    readonly provider: ResponsibilityOwnerDefinition
    readonly shared: ResponsibilityOwnerDefinition
  }
  readonly layers: readonly ResponsibilityLayer[]
  readonly models: readonly ResponsibilityModel[]
  readonly progression?: ResponsibilityProgression
  readonly exampleTitle?: string
}

export interface ResponsibilityVisualExperience extends VisualExperienceMetadata {
  readonly type: 'responsibility'
  readonly config: ResponsibilityConfig
}

export type VisualExperience =
  | ComparisonVisualExperience
  | ArchitectureVisualExperience
  | FlowVisualExperience
  | ResponsibilityVisualExperience

export interface InvalidVisualExperience extends VisualExperienceMetadata {
  readonly type: 'invalid'
  readonly originalType: string | null
}

export type RenderableVisualExperience = VisualExperience | InvalidVisualExperience

export type VisualExperienceParseResult =
  | {
      readonly success: true
      readonly experience: VisualExperience
      readonly issues: readonly []
    }
  | {
      readonly success: false
      readonly experience: InvalidVisualExperience
      readonly issues: readonly string[]
    }

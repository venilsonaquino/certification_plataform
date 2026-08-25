import { z } from 'zod'

import type {
  ArchitectureConfig,
  ComparisonConfig,
  FlowConfig,
  InvalidVisualExperience,
  ResponsibilityConfig,
  VisualExperience,
  VisualExperienceParseResult,
} from '../types/visualExperience'

const identifierSchema = z
  .string()
  .trim()
  .min(1)
  .max(64)
  .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, 'Use apenas letras minúsculas, números e hífens.')

const labelSchema = z.string().trim().min(1).max(120)
const descriptionSchema = z.string().trim().min(1).max(600)
const valueSchema = z.string().trim().min(1).max(500)

const comparisonConfigSchema: z.ZodType<ComparisonConfig> = z
  .object({
    columns: z
      .array(
        z
          .object({
            id: identifierSchema,
            title: labelSchema,
            description: descriptionSchema.optional(),
          })
          .strict(),
      )
      .min(2)
      .max(8),
    rows: z
      .array(
        z
          .object({
            id: identifierSchema,
            label: labelSchema,
            description: descriptionSchema.optional(),
            values: z.record(identifierSchema, valueSchema),
          })
          .strict(),
      )
      .min(1)
      .max(20),
  })
  .strict()
  .superRefine((config, context) => {
    const columnIds = new Set<string>()

    config.columns.forEach((column, columnIndex) => {
      if (columnIds.has(column.id)) {
        context.addIssue({
          code: 'custom',
          message: 'Os IDs das colunas devem ser únicos.',
          path: ['columns', columnIndex, 'id'],
        })
      }

      columnIds.add(column.id)
    })

    const rowIds = new Set<string>()

    config.rows.forEach((row, rowIndex) => {
      if (rowIds.has(row.id)) {
        context.addIssue({
          code: 'custom',
          message: 'Os IDs das linhas devem ser únicos.',
          path: ['rows', rowIndex, 'id'],
        })
      }

      rowIds.add(row.id)

      for (const columnId of columnIds) {
        if (!(columnId in row.values)) {
          context.addIssue({
            code: 'custom',
            message: `A coluna "${columnId}" não possui valor nesta linha.`,
            path: ['rows', rowIndex, 'values', columnId],
          })
        }
      }

      for (const valueId of Object.keys(row.values)) {
        if (!columnIds.has(valueId)) {
          context.addIssue({
            code: 'custom',
            message: `O valor "${valueId}" não corresponde a uma coluna.`,
            path: ['rows', rowIndex, 'values', valueId],
          })
        }
      }
    })
  })

const architectureNodeSchema = z
  .object({
    id: identifierSchema,
    label: labelSchema,
    kind: z.enum(['external', 'service', 'group', 'zone', 'resource']),
    description: descriptionSchema.optional(),
    x: z.number().min(0).max(100).optional(),
    y: z.number().min(0).max(100).optional(),
  })
  .strict()
  .superRefine((node, context) => {
    if ((node.x === undefined) !== (node.y === undefined)) {
      context.addIssue({
        code: 'custom',
        message: 'As coordenadas x e y devem ser informadas juntas.',
        path: [node.x === undefined ? 'x' : 'y'],
      })
    }
  })

const architectureConfigSchema: z.ZodType<ArchitectureConfig> = z
  .object({
    nodes: z.array(architectureNodeSchema).min(1).max(30),
    edges: z
      .array(
        z
          .object({
            id: identifierSchema,
            source: identifierSchema,
            target: identifierSchema,
            label: labelSchema.optional(),
          })
          .strict(),
      )
      .max(60),
  })
  .strict()
  .superRefine((config, context) => {
    const nodeIds = new Set<string>()

    config.nodes.forEach((node, nodeIndex) => {
      if (nodeIds.has(node.id)) {
        context.addIssue({
          code: 'custom',
          message: 'Os IDs dos nodes devem ser únicos.',
          path: ['nodes', nodeIndex, 'id'],
        })
      }

      nodeIds.add(node.id)
    })

    const positionedNodeCount = config.nodes.filter(
      (node) => node.x !== undefined && node.y !== undefined,
    ).length

    if (positionedNodeCount > 0 && positionedNodeCount !== config.nodes.length) {
      context.addIssue({
        code: 'custom',
        message: 'Informe posições para todos os nodes ou deixe o layout automático posicionar todos.',
        path: ['nodes'],
      })
    }

    const edgeIds = new Set<string>()

    config.edges.forEach((edge, edgeIndex) => {
      if (edgeIds.has(edge.id)) {
        context.addIssue({
          code: 'custom',
          message: 'Os IDs das relações devem ser únicos.',
          path: ['edges', edgeIndex, 'id'],
        })
      }

      edgeIds.add(edge.id)

      if (!nodeIds.has(edge.source)) {
        context.addIssue({
          code: 'custom',
          message: `O node de origem "${edge.source}" não existe.`,
          path: ['edges', edgeIndex, 'source'],
        })
      }

      if (!nodeIds.has(edge.target)) {
        context.addIssue({
          code: 'custom',
          message: `O node de destino "${edge.target}" não existe.`,
          path: ['edges', edgeIndex, 'target'],
        })
      }
    })
  })

const flowConfigSchema: z.ZodType<FlowConfig> = z
  .object({
    steps: z
      .array(
        z
          .object({
            id: identifierSchema,
            label: labelSchema,
            description: descriptionSchema.optional(),
          })
          .strict(),
      )
      .min(2)
      .max(20),
  })
  .strict()
  .superRefine((config, context) => {
    const stepIds = new Set<string>()

    config.steps.forEach((step, stepIndex) => {
      if (stepIds.has(step.id)) {
        context.addIssue({
          code: 'custom',
          message: 'Os IDs dos passos devem ser únicos.',
          path: ['steps', stepIndex, 'id'],
        })
      }

      stepIds.add(step.id)
    })
  })

const responsibilityOwnerDefinitionSchema = z
  .object({
    label: labelSchema,
    description: descriptionSchema.optional(),
  })
  .strict()

const responsibilityConfigSchema: z.ZodType<ResponsibilityConfig> = z
  .object({
    owners: z
      .object({
        customer: responsibilityOwnerDefinitionSchema,
        provider: responsibilityOwnerDefinitionSchema,
        shared: responsibilityOwnerDefinitionSchema,
      })
      .strict(),
    layers: z
      .array(
        z
          .object({
            id: identifierSchema,
            label: labelSchema,
            description: descriptionSchema.optional(),
          })
          .strict(),
      )
      .min(1)
      .max(30),
    models: z
      .array(
        z
          .object({
            id: identifierSchema,
            label: labelSchema,
            description: descriptionSchema,
            responsibilities: z.record(
              identifierSchema,
              z.enum(['customer', 'provider', 'shared']),
            ),
            example: descriptionSchema.optional(),
          })
          .strict(),
      )
      .min(1)
      .max(8),
    progression: z
      .object({
        startLabel: labelSchema,
        endLabel: labelSchema,
      })
      .strict()
      .optional(),
    exampleTitle: labelSchema.optional(),
  })
  .strict()
  .superRefine((config, context) => {
    const layerIds = new Set<string>()

    config.layers.forEach((layer, layerIndex) => {
      if (layerIds.has(layer.id)) {
        context.addIssue({
          code: 'custom',
          message: 'Os IDs das camadas devem ser únicos.',
          path: ['layers', layerIndex, 'id'],
        })
      }

      layerIds.add(layer.id)
    })

    const modelIds = new Set<string>()

    config.models.forEach((model, modelIndex) => {
      if (modelIds.has(model.id)) {
        context.addIssue({
          code: 'custom',
          message: 'Os IDs dos modelos devem ser únicos.',
          path: ['models', modelIndex, 'id'],
        })
      }

      modelIds.add(model.id)

      for (const layerId of layerIds) {
        if (!(layerId in model.responsibilities)) {
          context.addIssue({
            code: 'custom',
            message: `A camada "${layerId}" não possui responsabilidade neste modelo.`,
            path: ['models', modelIndex, 'responsibilities', layerId],
          })
        }
      }

      for (const responsibilityLayerId of Object.keys(model.responsibilities)) {
        if (!layerIds.has(responsibilityLayerId)) {
          context.addIssue({
            code: 'custom',
            message: `A responsabilidade aponta para a camada inexistente "${responsibilityLayerId}".`,
            path: ['models', modelIndex, 'responsibilities', responsibilityLayerId],
          })
        }
      }
    })
  })

const metadataShape = {
  id: z.string().uuid(),
  lessonId: z.string().uuid(),
  title: labelSchema,
  description: descriptionSchema,
  displayOrder: z.number().int().nonnegative(),
  isPublished: z.boolean(),
  createdAt: z.string().min(1),
  updatedAt: z.string().min(1),
}

export const visualExperienceSchema: z.ZodType<VisualExperience> = z.discriminatedUnion('type', [
  z
    .object({
      ...metadataShape,
      type: z.literal('comparison'),
      config: comparisonConfigSchema,
    })
    .strict(),
  z
    .object({
      ...metadataShape,
      type: z.literal('architecture'),
      config: architectureConfigSchema,
    })
    .strict(),
  z
    .object({
      ...metadataShape,
      type: z.literal('flow'),
      config: flowConfigSchema,
    })
    .strict(),
  z
    .object({
      ...metadataShape,
      type: z.literal('responsibility'),
      config: responsibilityConfigSchema,
    })
    .strict(),
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

function getInvalidExperience(input: unknown): InvalidVisualExperience {
  const record = getRecord(input)
  const originalType = getString(record, 'type')
  const displayOrder = record?.displayOrder
  const isPublished = record?.isPublished

  return {
    id: getString(record, 'id', 'invalid-visual-experience'),
    lessonId: getString(record, 'lessonId'),
    type: 'invalid',
    originalType: originalType || null,
    title: getString(record, 'title', 'Visualização indisponível'),
    description: getString(record, 'description'),
    displayOrder:
      typeof displayOrder === 'number' && Number.isInteger(displayOrder) && displayOrder >= 0
        ? displayOrder
        : 0,
    isPublished: typeof isPublished === 'boolean' ? isPublished : false,
    createdAt: getString(record, 'createdAt'),
    updatedAt: getString(record, 'updatedAt'),
  }
}

export function parseVisualExperience(input: unknown): VisualExperienceParseResult {
  const result = visualExperienceSchema.safeParse(input)

  if (result.success) {
    return {
      success: true,
      experience: result.data,
      issues: [],
    }
  }

  return {
    success: false,
    experience: getInvalidExperience(input),
    issues: result.error.issues.map((issue) => {
      const path = issue.path.length > 0 ? issue.path.join('.') : 'visualExperience'
      return `${path}: ${issue.message}`
    }),
  }
}

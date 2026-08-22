type CertificationRow = {
  id: string
  code: string
  name: string
  provider: string
  description: string | null
  level: string | null
  is_enabled: boolean
  display_order: number
  created_at: string
  updated_at: string
}

type DomainRow = {
  id: string
  certification_id: string
  title: string
  description: string | null
  exam_weight_min: number | null
  exam_weight_max: number | null
  display_order: number
  created_at: string
  updated_at: string
}

type TopicRow = {
  id: string
  domain_id: string
  title: string
  description: string | null
  display_order: number
  created_at: string
  updated_at: string
}

type LessonRow = {
  id: string
  topic_id: string
  slug: string
  title: string
  short_description: string | null
  content: string | null
  estimated_minutes: number | null
  display_order: number
  is_published: boolean
  created_at: string
  updated_at: string
}

type DatabaseRelationship = {
  foreignKeyName: string
  columns: string[]
  isOneToOne: boolean
  referencedRelation: string
  referencedColumns: string[]
}

type TableDefinition<Row, Insert, Update, Relationships extends DatabaseRelationship[] = []> = {
  Row: Row
  Insert: Insert
  Update: Update
  Relationships: Relationships
}

export interface Database {
  public: {
    Tables: {
      certifications: TableDefinition<
        CertificationRow,
        Pick<CertificationRow, 'code' | 'name' | 'provider'> & {
          id?: string
          description?: string | null
          level?: string | null
          is_enabled?: boolean
          display_order?: number
          created_at?: string
          updated_at?: string
        },
        Partial<CertificationRow>
      >
      domains: TableDefinition<
        DomainRow,
        Pick<DomainRow, 'certification_id' | 'title'> & {
          id?: string
          description?: string | null
          exam_weight_min?: number | null
          exam_weight_max?: number | null
          display_order?: number
          created_at?: string
          updated_at?: string
        },
        Partial<DomainRow>,
        [
          {
            foreignKeyName: 'domains_certification_id_fkey'
            columns: ['certification_id']
            isOneToOne: false
            referencedRelation: 'certifications'
            referencedColumns: ['id']
          },
        ]
      >
      topics: TableDefinition<
        TopicRow,
        Pick<TopicRow, 'domain_id' | 'title'> & {
          id?: string
          description?: string | null
          display_order?: number
          created_at?: string
          updated_at?: string
        },
        Partial<TopicRow>,
        [
          {
            foreignKeyName: 'topics_domain_id_fkey'
            columns: ['domain_id']
            isOneToOne: false
            referencedRelation: 'domains'
            referencedColumns: ['id']
          },
        ]
      >
      lessons: TableDefinition<
        LessonRow,
        Pick<LessonRow, 'topic_id' | 'slug' | 'title'> & {
          id?: string
          short_description?: string | null
          content?: string | null
          estimated_minutes?: number | null
          display_order?: number
          is_published?: boolean
          created_at?: string
          updated_at?: string
        },
        Partial<LessonRow>,
        [
          {
            foreignKeyName: 'lessons_topic_id_fkey'
            columns: ['topic_id']
            isOneToOne: false
            referencedRelation: 'topics'
            referencedColumns: ['id']
          },
        ]
      >
    }
    Views: Record<string, never>
    Functions: Record<string, never>
    Enums: Record<string, never>
    CompositeTypes: Record<string, never>
  }
}

export type CertificationDatabaseRow = CertificationRow
export type DomainDatabaseRow = DomainRow
export type TopicDatabaseRow = TopicRow
export type LessonDatabaseRow = LessonRow

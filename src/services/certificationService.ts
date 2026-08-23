import { supabase } from '../lib/supabase'
import type { Certification } from '../types/certification'
import type {
  CertificationStudyPath,
  Domain,
  DomainWithTopics,
  Lesson,
  Topic,
} from '../types/content'
import type {
  CertificationDatabaseRow,
  DomainDatabaseRow,
  LessonDatabaseRow,
  TopicDatabaseRow,
} from '../types/database'

export class CertificationDataError extends Error {
  constructor(message = 'Não foi possível carregar os dados das certificações.') {
    super(message)
    this.name = 'CertificationDataError'
  }
}

function getClient() {
  if (!supabase) {
    throw new CertificationDataError('A conexão com o Supabase não está configurada.')
  }

  return supabase
}

function mapCertification(row: CertificationDatabaseRow): Certification {
  return {
    id: row.id,
    code: row.code,
    name: row.name,
    provider: row.provider,
    description: row.description,
    level: row.level,
    isEnabled: row.is_enabled,
    displayOrder: row.display_order,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function mapDomain(row: DomainDatabaseRow): Domain {
  return {
    id: row.id,
    certificationId: row.certification_id,
    title: row.title,
    description: row.description,
    examWeightMin: row.exam_weight_min,
    examWeightMax: row.exam_weight_max,
    displayOrder: row.display_order,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function mapTopic(row: TopicDatabaseRow): Topic {
  return {
    id: row.id,
    domainId: row.domain_id,
    title: row.title,
    description: row.description,
    displayOrder: row.display_order,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function mapLesson(row: LessonDatabaseRow): Lesson {
  return {
    id: row.id,
    topicId: row.topic_id,
    slug: row.slug,
    title: row.title,
    shortDescription: row.short_description,
    content: row.content,
    estimatedMinutes: row.estimated_minutes,
    displayOrder: row.display_order,
    isPublished: row.is_published,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function throwQueryError(error: { message: string } | null) {
  if (error) {
    throw new CertificationDataError(error.message)
  }
}

export async function getCertifications(): Promise<Certification[]> {
  const { data, error } = await getClient()
    .from('certifications')
    .select('*')
    .order('display_order', { ascending: true })
    .order('code', { ascending: true })

  throwQueryError(error)
  return (data ?? []).map(mapCertification)
}

export async function getCertificationByCode(code: string): Promise<Certification | null> {
  const { data, error } = await getClient()
    .from('certifications')
    .select('*')
    .eq('code', code.trim().toLowerCase())
    .maybeSingle()

  throwQueryError(error)
  return data ? mapCertification(data) : null
}

export async function getDomainsByCertification(certificationId: string): Promise<Domain[]> {
  const { data, error } = await getClient()
    .from('domains')
    .select('*')
    .eq('certification_id', certificationId)
    .order('display_order', { ascending: true })
    .order('title', { ascending: true })

  throwQueryError(error)
  return (data ?? []).map(mapDomain)
}

export async function getTopicsByDomain(domainId: string): Promise<Topic[]> {
  const { data, error } = await getClient()
    .from('topics')
    .select('*')
    .eq('domain_id', domainId)
    .order('display_order', { ascending: true })
    .order('title', { ascending: true })

  throwQueryError(error)
  return (data ?? []).map(mapTopic)
}

export async function getLessonsByTopic(topicId: string): Promise<Lesson[]> {
  const { data, error } = await getClient()
    .from('lessons')
    .select('*')
    .eq('topic_id', topicId)
    .eq('is_published', true)
    .order('display_order', { ascending: true })
    .order('title', { ascending: true })

  throwQueryError(error)
  return (data ?? []).map(mapLesson)
}

export async function getCertificationContent(
  certificationId: string,
): Promise<DomainWithTopics[]> {
  const domains = await getDomainsByCertification(certificationId)

  if (domains.length === 0) {
    return []
  }

  const domainIds = domains.map((domain) => domain.id)
  const { data: topicRows, error: topicsError } = await getClient()
    .from('topics')
    .select('*')
    .in('domain_id', domainIds)
    .order('display_order', { ascending: true })
    .order('title', { ascending: true })

  throwQueryError(topicsError)
  const topics = (topicRows ?? []).map(mapTopic)
  const topicIds = topics.map((topic) => topic.id)

  let lessons: Lesson[] = []

  if (topicIds.length > 0) {
    const { data: lessonRows, error: lessonsError } = await getClient()
      .from('lessons')
      .select('*')
      .in('topic_id', topicIds)
      .eq('is_published', true)
      .order('display_order', { ascending: true })
      .order('title', { ascending: true })

    throwQueryError(lessonsError)
    lessons = (lessonRows ?? []).map(mapLesson)
  }

  return domains.map((domain) => ({
    ...domain,
    topics: topics
      .filter((topic) => topic.domainId === domain.id)
      .map((topic) => ({
        ...topic,
        lessons: lessons.filter((lesson) => lesson.topicId === topic.id),
      })),
  }))
}

export async function getCertificationStudyPath(
  code: string,
): Promise<CertificationStudyPath | null> {
  const certification = await getCertificationByCode(code)

  if (!certification) {
    return null
  }

  return {
    certification,
    domains: await getCertificationContent(certification.id),
  }
}

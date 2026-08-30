import { z } from 'zod'

import {
  mockExamAnswerDatabaseRowSchema,
  mockExamAttemptDatabaseRowSchema,
  mockExamAttemptQuestionDatabaseRowSchema,
  mockExamHistoryDatabaseRowSchema,
  mockExamResultDatabaseRowSchema,
  mockExamReviewDatabaseRowSchema,
  mockExamSessionDatabaseRowSchema,
  saveMockExamAnswerInputSchema,
} from '../lib/mockExamValidation'
import { supabase } from '../lib/supabase'
import type {
  MockExamAnswer,
  MockExamAttempt,
  MockExamAttemptData,
  MockExamHistoryItem,
  MockExamHistoryPage,
  MockExamQuestionForExecution,
  MockExamQuestionForReview,
  MockExamResult,
  MockExamSession,
  SaveMockExamAnswerInput,
} from '../types/mockExam'

export class MockExamDataError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'MockExamDataError'
  }
}

function getClient() {
  if (!supabase) {
    throw new MockExamDataError('A conexão com o Supabase não está configurada.')
  }
  return supabase
}

function throwQueryError(error: { message: string } | null) {
  if (error) throw new MockExamDataError(error.message)
}

function parseExternal<Schema extends z.ZodType>(schema: Schema, input: unknown): z.output<Schema> {
  const result = schema.safeParse(input)
  if (!result.success) {
    throw new MockExamDataError(`Resposta inválida do Mock Exam: ${z.prettifyError(result.error)}`)
  }
  return result.data
}

function mapAttempt(input: unknown): MockExamAttempt {
  const row = parseExternal(mockExamAttemptDatabaseRowSchema, input)
  return {
    id: row.id,
    userId: row.user_id,
    certificationId: row.certification_id,
    status: row.status,
    totalQuestions: row.total_questions,
    answeredQuestions: row.answered_questions,
    correctAnswers: row.correct_answers,
    incorrectAnswers: row.incorrect_answers,
    unansweredQuestions: row.unanswered_questions,
    practiceScorePercentage: row.practice_score_percentage,
    startedAt: row.started_at,
    submittedAt: row.submitted_at,
    abandonedAt: row.abandoned_at,
    expiresAt: row.expires_at,
    timeLimitSeconds: row.time_limit_seconds,
    elapsedSeconds: row.elapsed_seconds,
    lastActivityAt: row.last_activity_at,
    selectionPolicyVersion: row.selection_policy_version,
    domainAllocation: row.domain_allocation,
    difficultyAllocation: row.difficulty_allocation,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function mapQuestion(input: unknown): MockExamQuestionForExecution {
  const row = parseExternal(mockExamAttemptQuestionDatabaseRowSchema, input)
  return {
    id: row.id,
    attemptId: row.attempt_id,
    questionId: row.question_id,
    displayOrder: row.display_order,
    questionText: row.question_text,
    options: row.options,
    selectedOptionKey: row.selected_option_key,
    answeredAt: row.answered_at,
  }
}

function mapAnswer(input: unknown): MockExamAnswer {
  const row = parseExternal(mockExamAnswerDatabaseRowSchema, input)
  return {
    id: row.id,
    attemptId: row.attempt_id,
    attemptQuestionId: row.attempt_question_id,
    selectedOptionKey: row.selected_option_key,
    answeredAt: row.answered_at,
  }
}

function mapResult(input: unknown): MockExamResult {
  const row = parseExternal(mockExamResultDatabaseRowSchema, input)
  return {
    attemptId: row.attempt_id,
    totalQuestions: row.total_questions,
    answeredQuestions: row.answered_questions,
    correctAnswers: row.correct_answers,
    incorrectAnswers: row.incorrect_answers,
    unansweredQuestions: row.unanswered_questions,
    practiceScorePercentage: row.practice_score_percentage,
    startedAt: row.started_at,
    submittedAt: row.submitted_at,
    elapsedSeconds: row.elapsed_seconds,
    domains: row.domain_breakdown,
    topics: row.topic_breakdown,
    difficulties: row.difficulty_breakdown,
  }
}

function mapReviewQuestion(input: unknown): MockExamQuestionForReview {
  const row = parseExternal(mockExamReviewDatabaseRowSchema, input)
  return {
    id: row.id,
    attemptId: row.attempt_id,
    questionId: row.question_id,
    displayOrder: row.display_order,
    domainId: row.domain_id,
    domainTitle: row.domain_title,
    topicId: row.topic_id,
    topicTitle: row.topic_title,
    lessonId: row.lesson_id,
    lessonTitle: row.lesson_title,
    lessonSlug: row.lesson_slug,
    difficulty: row.difficulty,
    questionText: row.question_text,
    options: row.options,
    selectedOptionKey: row.selected_option_key,
    correctOptionKey: row.correct_option_key,
    status: row.answer_status,
    explanation: row.explanation,
  }
}

function mapHistoryItem(input: unknown): MockExamHistoryItem {
  const row = parseExternal(mockExamHistoryDatabaseRowSchema, input)
  return {
    attemptId: row.attempt_id,
    attemptNumber: row.attempt_number,
    status: row.status,
    totalQuestions: row.total_questions,
    answeredQuestions: row.answered_questions,
    correctAnswers: row.correct_answers,
    incorrectAnswers: row.incorrect_answers,
    unansweredQuestions: row.unanswered_questions,
    practiceScorePercentage: row.practice_score_percentage,
    startedAt: row.started_at,
    submittedAt: row.submitted_at,
    expiresAt: row.expires_at,
    timeLimitSeconds: row.time_limit_seconds,
    elapsedSeconds: row.elapsed_seconds,
  }
}

export async function getMockExamAttempt(attemptId: string): Promise<MockExamAttempt | null> {
  const { data, error } = await getClient()
    .from('mock_exam_attempts')
    .select('*')
    .eq('id', attemptId)
    .maybeSingle()
  throwQueryError(error)
  return data ? mapAttempt(data) : null
}

export async function startMockExam(certificationId: string): Promise<MockExamAttempt> {
  const { data, error } = await getClient()
    .rpc('start_mock_exam', { p_certification_id: certificationId })
    .single()
  throwQueryError(error)
  if (!data) throw new MockExamDataError('A tentativa de Mock Exam não foi retornada.')
  return mapAttempt(data)
}

export async function listMockExamAttempts(
  certificationId: string,
): Promise<MockExamAttempt[]> {
  const { data, error } = await getClient()
    .from('mock_exam_attempts')
    .select('*')
    .eq('certification_id', certificationId)
    .order('started_at', { ascending: false })
  throwQueryError(error)
  return (data ?? []).map(mapAttempt)
}

export async function syncMockExamAttempt(attemptId: string): Promise<MockExamSession | null> {
  const { data, error } = await getClient()
    .rpc('sync_mock_exam_attempt', { p_attempt_id: attemptId })
    .maybeSingle()
  throwQueryError(error)
  if (!data) return null
  const row = parseExternal(mockExamSessionDatabaseRowSchema, data)
  return { attempt: mapAttempt(row.attempt), serverNow: row.server_now }
}

export async function getMockExamHistory(
  certificationId: string,
  limit = 10,
  offset = 0,
): Promise<MockExamHistoryPage> {
  const { data, error } = await getClient().rpc('get_mock_exam_history', {
    p_certification_id: certificationId,
    p_limit: limit,
    p_offset: offset,
  })
  throwQueryError(error)
  const rows = (data ?? []).map((row) => ({
    parsed: parseExternal(mockExamHistoryDatabaseRowSchema, row),
    item: mapHistoryItem(row),
  }))
  return { items: rows.map(({ item }) => item), totalCount: rows[0]?.parsed.total_count ?? 0 }
}

export async function getActiveMockExamAttempt(
  certificationId: string,
): Promise<MockExamAttempt | null> {
  const { data, error } = await getClient()
    .from('mock_exam_attempts')
    .select('*')
    .eq('certification_id', certificationId)
    .eq('status', 'in_progress')
    .maybeSingle()
  throwQueryError(error)
  return data ? mapAttempt(data) : null
}

export async function loadMockExamAttempt(
  attemptId: string,
  synchronizedAttempt?: MockExamAttempt,
): Promise<MockExamAttemptData | null> {
  const attempt = synchronizedAttempt ?? await getMockExamAttempt(attemptId)
  if (!attempt) return null
  if (attempt.status !== 'in_progress') {
    throw new MockExamDataError('Somente um Mock Exam em andamento pode ser retomado.')
  }

  const { data, error } = await getClient().rpc('get_mock_exam_attempt_questions', {
    p_attempt_id: attemptId,
  })
  throwQueryError(error)

  return { attempt, questions: (data ?? []).map(mapQuestion) }
}

export async function resumeMockExam(
  certificationId: string,
): Promise<MockExamAttemptData | null> {
  const attempt = await getActiveMockExamAttempt(certificationId)
  return attempt ? loadMockExamAttempt(attempt.id) : null
}

export async function saveMockExamAnswer(
  input: SaveMockExamAnswerInput,
): Promise<MockExamAnswer> {
  const parsed = saveMockExamAnswerInputSchema.safeParse(input)
  if (!parsed.success) {
    throw new MockExamDataError(`Resposta inválida: ${z.prettifyError(parsed.error)}`)
  }

  const { data, error } = await getClient()
    .rpc('save_mock_exam_answer', {
      p_attempt_id: parsed.data.attemptId,
      p_attempt_question_id: parsed.data.attemptQuestionId,
      p_selected_option_key: parsed.data.selectedOptionKey,
    })
    .single()
  throwQueryError(error)
  if (!data) throw new MockExamDataError('A confirmação da resposta não foi retornada.')
  return mapAnswer(data)
}

export async function abandonMockExamAttempt(attemptId: string): Promise<MockExamAttempt> {
  const { data, error } = await getClient()
    .rpc('abandon_mock_exam_attempt', { p_attempt_id: attemptId })
    .single()
  throwQueryError(error)
  if (!data) throw new MockExamDataError('A tentativa abandonada não foi retornada.')
  return mapAttempt(data)
}

export async function submitMockExam(attemptId: string): Promise<MockExamAttempt> {
  const { data, error } = await getClient()
    .rpc('submit_mock_exam', { p_attempt_id: attemptId })
    .single()
  throwQueryError(error)
  if (!data) throw new MockExamDataError('A confirmação do envio não foi retornada.')
  return mapAttempt(data)
}

export async function getMockExamResult(attemptId: string): Promise<MockExamResult | null> {
  const { data, error } = await getClient()
    .rpc('get_mock_exam_result', { p_attempt_id: attemptId })
    .maybeSingle()
  throwQueryError(error)
  return data ? mapResult(data) : null
}

export async function getMockExamReview(
  attemptId: string,
): Promise<MockExamQuestionForReview[]> {
  const { data, error } = await getClient().rpc('get_mock_exam_review', {
    p_attempt_id: attemptId,
  })
  throwQueryError(error)
  return (data ?? []).map(mapReviewQuestion)
}

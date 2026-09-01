import { supabase } from '../lib/supabase'
import type {
  QuestionDatabaseRow,
  QuestionOptionPublicDatabaseRow,
  QuizAnswerDatabaseRow,
  QuizAnswerReviewDatabaseRow,
  QuizAttemptDatabaseRow,
  QuizAttemptQuestionDatabaseRow,
  TopicQuizPerformanceDatabaseRow,
  TopicQuizSummaryDatabaseRow,
} from '../types/database'
import type { PublicQuestion, PublicQuestionOption } from '../types/question'
import { WEAK_AREA_THRESHOLD } from '../types/quiz'
import type {
  LessonQuizAttemptData,
  LessonQuizSummary,
  QuizAnswer,
  QuizAnswerFeedback,
  QuizAnswerReview,
  QuizAttempt,
  QuizAttemptQuestion,
  LessonQuizPerformance,
  TopicQuizSummary,
} from '../types/quiz'

export class QuizDataError extends Error {
  constructor(message = 'Não foi possível carregar o Quiz.') {
    super(message)
    this.name = 'QuizDataError'
  }
}

export class QuizUnavailableError extends QuizDataError {
  constructor(message = 'Ainda não existem questões disponíveis para este Quiz.') {
    super(message)
    this.name = 'QuizUnavailableError'
  }
}

function getClient() {
  if (!supabase) {
    throw new QuizDataError('A conexão com o Supabase não está configurada.')
  }
  return supabase
}

function throwQueryError(error: { message: string; code?: string } | null) {
  if (!error) return
  if (error.code === 'P0002' || error.message.includes('No published questions')) {
    throw new QuizUnavailableError(error.message)
  }
  throw new QuizDataError(error.message)
}

function mapAttempt(row: QuizAttemptDatabaseRow): QuizAttempt {
  return {
    id: row.id,
    userId: row.user_id,
    certificationId: row.certification_id,
    quizType: row.quiz_type,
    lessonId: row.lesson_id,
    topicId: row.topic_id,
    status: row.status,
    totalQuestions: row.total_questions,
    correctAnswers: row.correct_answers,
    scorePercentage: Number(row.score_percentage),
    startedAt: row.started_at,
    completedAt: row.completed_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function mapAttemptQuestion(row: QuizAttemptQuestionDatabaseRow): QuizAttemptQuestion {
  return {
    id: row.id,
    attemptId: row.attempt_id,
    questionId: row.question_id,
    displayOrder: row.display_order,
    createdAt: row.created_at,
  }
}

function mapAnswer(row: QuizAnswerDatabaseRow): QuizAnswer {
  return {
    id: row.id,
    attemptId: row.attempt_id,
    questionId: row.question_id,
    selectedOptionId: row.selected_option_id,
    isCorrect: row.is_correct,
    answeredAt: row.answered_at,
    createdAt: row.created_at,
  }
}

function mapReview(row: QuizAnswerReviewDatabaseRow): QuizAnswerReview {
  return {
    questionId: row.question_id,
    selectedOptionId: row.selected_option_id,
    selectedOptionText: row.selected_option_text,
    isCorrect: row.is_correct,
    correctOptionId: row.correct_option_id,
    correctOptionText: row.correct_option_text,
    questionExplanation: row.question_explanation,
    selectedOptionExplanation: row.selected_option_explanation,
    correctOptionExplanation: row.correct_option_explanation,
  }
}

function mapPublicQuestion(
  row: Omit<QuestionDatabaseRow, 'explanation' | 'mock_eligible'>,
): PublicQuestion {
  return {
    id: row.id,
    certificationId: row.certification_id,
    domainId: row.domain_id,
    topicId: row.topic_id,
    lessonId: row.lesson_id,
    questionText: row.question_text,
    questionType: row.question_type,
    difficulty: row.difficulty,
    isPublished: row.is_published,
    displayOrder: row.display_order,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

function mapPublicOption(row: QuestionOptionPublicDatabaseRow): PublicQuestionOption {
  return {
    id: row.id,
    questionId: row.question_id,
    optionText: row.option_text,
    displayOrder: row.display_order,
  }
}

export async function startLessonQuiz(lessonId: string): Promise<QuizAttempt> {
  const { data, error } = await getClient()
    .rpc('start_lesson_quiz', { p_lesson_id: lessonId })
    .single()
  throwQueryError(error)
  if (!data) throw new QuizDataError('A tentativa iniciada não foi retornada.')
  return mapAttempt(data)
}

export async function getActiveLessonQuiz(lessonId: string): Promise<QuizAttempt | null> {
  const { data, error } = await getClient()
    .from('quiz_attempts')
    .select('*')
    .eq('quiz_type', 'lesson')
    .eq('lesson_id', lessonId)
    .eq('status', 'in_progress')
    .maybeSingle()
  throwQueryError(error)
  return data ? mapAttempt(data) : null
}

export async function getLastLessonQuizResult(lessonId: string): Promise<QuizAttempt | null> {
  const { data, error } = await getClient()
    .from('quiz_attempts')
    .select('*')
    .eq('quiz_type', 'lesson')
    .eq('lesson_id', lessonId)
    .eq('status', 'completed')
    .order('completed_at', { ascending: false })
    .limit(1)
    .maybeSingle()
  throwQueryError(error)
  return data ? mapAttempt(data) : null
}

export async function getQuizAnswerReviews(attemptId: string): Promise<QuizAnswerReview[]> {
  const { data, error } = await getClient().rpc('get_quiz_answer_review', {
    p_attempt_id: attemptId,
  })
  throwQueryError(error)
  return (data ?? []).map(mapReview)
}

export async function getQuizAttempt(attemptId: string): Promise<LessonQuizAttemptData | null> {
  const { data: attemptRow, error: attemptError } = await getClient()
    .from('quiz_attempts')
    .select('*')
    .eq('id', attemptId)
    .maybeSingle()
  throwQueryError(attemptError)
  if (!attemptRow) return null

  const { data: attemptQuestionRows, error: attemptQuestionsError } = await getClient()
    .from('quiz_attempt_questions')
    .select('*')
    .eq('attempt_id', attemptId)
    .order('display_order', { ascending: true })
  throwQueryError(attemptQuestionsError)

  const attemptQuestions = (attemptQuestionRows ?? []).map(mapAttemptQuestion)
  const questionIds = attemptQuestions.map((item) => item.questionId)
  if (questionIds.length === 0) {
    throw new QuizDataError('A tentativa não possui questões associadas.')
  }

  const [questionsResult, optionsResult, answersResult, reviews] = await Promise.all([
    getClient()
      .from('questions')
      .select('id, certification_id, domain_id, topic_id, lesson_id, question_text, question_type, difficulty, is_published, display_order, created_at, updated_at')
      .in('id', questionIds),
    getClient()
      .from('question_options_public')
      .select('*')
      .in('question_id', questionIds)
      .order('display_order', { ascending: true }),
    getClient().from('quiz_answers').select('*').eq('attempt_id', attemptId),
    getQuizAnswerReviews(attemptId),
  ])
  throwQueryError(questionsResult.error)
  throwQueryError(optionsResult.error)
  throwQueryError(answersResult.error)

  const questions = (questionsResult.data ?? []).map(mapPublicQuestion)
  const options = (optionsResult.data ?? []).map(mapPublicOption)
  const answers = (answersResult.data ?? []).map(mapAnswer)

  return {
    attempt: mapAttempt(attemptRow),
    questions: attemptQuestions.map((attemptQuestion) => {
      const question = questions.find((item) => item.id === attemptQuestion.questionId)
      if (!question) throw new QuizDataError('Uma questão da tentativa não está disponível.')
      return {
        ...question,
        attemptQuestionId: attemptQuestion.id,
        attemptDisplayOrder: attemptQuestion.displayOrder,
        options: options.filter((option) => option.questionId === question.id),
        answer: answers.find((answer) => answer.questionId === question.id) ?? null,
        review: reviews.find((review) => review.questionId === question.id) ?? null,
      }
    }),
  }
}

export async function submitQuizAnswer(
  attemptId: string,
  questionId: string,
  selectedOptionId: string,
): Promise<QuizAnswerFeedback> {
  const { data, error } = await getClient()
    .rpc('submit_quiz_answer', {
      p_attempt_id: attemptId,
      p_question_id: questionId,
      p_selected_option_id: selectedOptionId,
    })
    .single()
  throwQueryError(error)
  if (!data) throw new QuizDataError('O feedback da resposta não foi retornado.')

  const reviews = await getQuizAnswerReviews(attemptId)
  const review = reviews.find((item) => item.questionId === questionId)
  if (!review) throw new QuizDataError('A resposta foi salva, mas o feedback não foi carregado.')

  return {
    ...review,
    attemptCompleted: data.attempt_completed,
    correctAnswers: data.correct_answers,
    totalQuestions: data.total_questions,
    scorePercentage: Number(data.score_percentage),
  }
}

export async function getQuizResult(attemptId: string): Promise<LessonQuizAttemptData | null> {
  return getQuizAttempt(attemptId)
}

export async function startTopicQuiz(topicId: string): Promise<QuizAttempt> {
  const { data, error } = await getClient()
    .rpc('start_topic_quiz', { p_topic_id: topicId })
    .single()
  throwQueryError(error)
  if (!data) throw new QuizDataError('A tentativa do tópico não foi retornada.')
  return mapAttempt(data)
}

export async function getActiveTopicQuiz(topicId: string): Promise<QuizAttempt | null> {
  const { data, error } = await getClient()
    .from('quiz_attempts')
    .select('*')
    .eq('quiz_type', 'topic')
    .eq('topic_id', topicId)
    .eq('status', 'in_progress')
    .maybeSingle()
  throwQueryError(error)
  return data ? mapAttempt(data) : null
}

function mapTopicPerformance(row: TopicQuizPerformanceDatabaseRow): LessonQuizPerformance {
  const percentage = Number(row.percentage)
  return {
    lessonId: row.lesson_id,
    lessonTitle: row.lesson_title,
    lessonSlug: row.lesson_slug,
    totalQuestions: row.total_questions,
    correctAnswers: row.correct_answers,
    percentage,
    needsReview: percentage < WEAK_AREA_THRESHOLD,
  }
}

export async function getTopicQuizResult(attemptId: string): Promise<LessonQuizPerformance[]> {
  const { data, error } = await getClient().rpc('get_quiz_lesson_performance', {
    p_attempt_id: attemptId,
  })
  throwQueryError(error)
  return (data ?? []).map(mapTopicPerformance)
}

export async function startReviewQuiz(
  certificationId: string,
  questionId: string | null = null,
): Promise<QuizAttempt> {
  const { data, error } = await getClient()
    .rpc('start_review_quiz', {
      p_certification_id: certificationId,
      p_question_id: questionId,
    })
    .single()
  throwQueryError(error)
  if (!data) throw new QuizDataError('A tentativa de revisão não foi retornada.')
  return mapAttempt(data)
}

export async function getActiveReviewQuiz(certificationId: string): Promise<QuizAttempt | null> {
  const { data, error } = await getClient()
    .from('quiz_attempts')
    .select('*')
    .eq('quiz_type', 'review')
    .eq('certification_id', certificationId)
    .eq('status', 'in_progress')
    .maybeSingle()
  throwQueryError(error)
  return data ? mapAttempt(data) : null
}

export async function getQuizLessonPerformance(
  attemptId: string,
): Promise<LessonQuizPerformance[]> {
  const { data, error } = await getClient().rpc('get_quiz_lesson_performance', {
    p_attempt_id: attemptId,
  })
  throwQueryError(error)
  return (data ?? []).map(mapTopicPerformance)
}

function mapTopicSummary(row: TopicQuizSummaryDatabaseRow): TopicQuizSummary {
  return {
    topicId: row.topic_id,
    questionCount: Number(row.question_count),
    targetQuestionCount: Number(row.target_question_count),
    activeAttemptId: row.active_attempt_id,
    activeTotalQuestions: row.active_total_questions,
    activeAnsweredCount: Number(row.active_answered_count),
    lastScorePercentage:
      row.last_score_percentage === null ? null : Number(row.last_score_percentage),
  }
}

export async function getTopicQuizSummaries(
  certificationId: string,
): Promise<TopicQuizSummary[]> {
  const { data, error } = await getClient().rpc('get_topic_quiz_summaries', {
    p_certification_id: certificationId,
  })
  throwQueryError(error)
  return (data ?? []).map(mapTopicSummary)
}

export async function getLessonQuizSummary(lessonId: string): Promise<LessonQuizSummary> {
  const [questionsResult, activeAttempt, lastCompletedAttempt] = await Promise.all([
    getClient()
      .from('questions')
      .select('id', { count: 'exact', head: true })
      .eq('lesson_id', lessonId)
      .eq('is_published', true),
    getActiveLessonQuiz(lessonId),
    getLastLessonQuizResult(lessonId),
  ])
  throwQueryError(questionsResult.error)

  let answeredCount = 0
  if (activeAttempt) {
    const { count, error } = await getClient()
      .from('quiz_answers')
      .select('id', { count: 'exact', head: true })
      .eq('attempt_id', activeAttempt.id)
    throwQueryError(error)
    answeredCount = count ?? 0
  }

  return {
    questionCount: Math.min(questionsResult.count ?? 0, 5),
    activeAttempt,
    lastCompletedAttempt,
    answeredCount,
  }
}

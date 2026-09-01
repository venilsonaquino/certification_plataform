import type { LessonProgressStatus } from './progress'
import type { QuestionDifficulty, QuestionType } from './question'
import type { QuizAttemptStatus, QuizType } from './quiz'
import type { MockExamAttemptStatus } from './mockExam'
import type { FlashcardReviewRating } from './flashcard'
import type {
  LessonContentBlockConfig,
  LessonContentBlockType,
} from './lessonContentBlock'

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

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

type LessonContentBlockRow = {
  id: string
  lesson_id: string
  type: LessonContentBlockType
  title: string | null
  content: string | null
  config: LessonContentBlockConfig | null
  visual_experience_id: string | null
  display_order: number
  is_published: boolean
  created_at: string
  updated_at: string
}

type VisualExperienceRow = {
  id: string
  lesson_id: string
  type: string
  title: string
  description: string
  config: Json
  display_order: number
  is_published: boolean
  created_at: string
  updated_at: string
}

type FlashcardRow = {
  id: string
  lesson_id: string
  front_text: string
  back_text: string
  hint: string | null
  display_order: number
  is_published: boolean
  created_at: string
  updated_at: string
}

type FlashcardReviewRow = {
  id: string
  user_id: string
  flashcard_id: string
  rating: FlashcardReviewRating
  reviewed_at: string
  created_at: string
}

type UserFlashcardProgressRow = {
  id: string
  user_id: string
  flashcard_id: string
  last_rating: FlashcardReviewRating | null
  review_count: number
  successful_review_count: number
  interval_days: number
  next_review_at: string | null
  last_reviewed_at: string | null
  created_at: string
  updated_at: string
}

type SubmitFlashcardReviewRow = {
  review_id: string
  review_user_id: string
  review_flashcard_id: string
  rating: FlashcardReviewRating
  reviewed_at: string
  review_created_at: string
  progress_id: string
  last_rating: FlashcardReviewRating
  review_count: number
  successful_review_count: number
  interval_days: number
  next_review_at: string
  last_reviewed_at: string
  progress_created_at: string
  progress_updated_at: string
}

type FlashcardStudyQueueRow = FlashcardRow & {
  lesson_title: string
  lesson_slug: string
  review_status: 'new' | 'due'
  next_review_at: string | null
}

type FlashcardReviewOverviewRow = {
  queue_count: number
  due_count: number
  new_count: number
  next_review_at: string | null
  available_flashcard_count: number
  total_flashcard_count: number
}

type FlashcardCatalogOverviewRow = {
  domain_id: string
  domain_title: string
  domain_display_order: number
  topic_id: string
  topic_title: string
  topic_display_order: number
  available_flashcard_count: number
  total_flashcard_count: number
  studied_flashcard_count: number
}

type AvailableFlashcardRow = FlashcardRow & {
  lesson_title: string
  lesson_slug: string
}

type UserLessonProgressRow = {
  id: string
  user_id: string
  lesson_id: string
  status: LessonProgressStatus
  started_at: string | null
  completed_at: string | null
  last_accessed_at: string | null
  created_at: string
  updated_at: string
}

type QuestionRow = {
  id: string
  certification_id: string
  domain_id: string | null
  topic_id: string | null
  lesson_id: string | null
  question_text: string
  question_type: QuestionType
  difficulty: QuestionDifficulty | null
  explanation: string | null
  is_published: boolean
  mock_eligible: boolean
  display_order: number
  created_at: string
  updated_at: string
}

type QuestionOptionRow = {
  id: string
  question_id: string
  option_text: string
  is_correct: boolean
  explanation: string | null
  display_order: number
  created_at: string
  updated_at: string
}

type QuestionOptionPublicRow = Pick<
  QuestionOptionRow,
  'id' | 'question_id' | 'option_text' | 'display_order'
>

type QuizAttemptRow = {
  id: string
  user_id: string
  certification_id: string
  quiz_type: QuizType
  lesson_id: string | null
  topic_id: string | null
  status: QuizAttemptStatus
  total_questions: number
  correct_answers: number
  score_percentage: number
  started_at: string
  completed_at: string | null
  created_at: string
  updated_at: string
}

type QuizAttemptQuestionRow = {
  id: string
  attempt_id: string
  question_id: string
  display_order: number
  created_at: string
}

type QuizAnswerRow = {
  id: string
  attempt_id: string
  question_id: string
  selected_option_id: string
  is_correct: boolean
  answered_at: string
  created_at: string
}

type QuizAnswerReviewRow = {
  question_id: string
  selected_option_id: string
  selected_option_text: string
  is_correct: boolean
  correct_option_id: string
  correct_option_text: string
  question_explanation: string | null
  selected_option_explanation: string | null
  correct_option_explanation: string | null
}

type SubmitQuizAnswerRow = Omit<
  QuizAnswerReviewRow,
  'question_id' | 'selected_option_id' | 'selected_option_text' | 'correct_option_text'
> & {
  attempt_completed: boolean
  correct_answers: number
  total_questions: number
  score_percentage: number
}

type TopicQuizPerformanceRow = {
  lesson_id: string | null
  lesson_title: string
  lesson_slug: string | null
  total_questions: number
  correct_answers: number
  percentage: number
}

type TopicQuizSummaryRow = {
  topic_id: string
  question_count: number
  target_question_count: number
  active_attempt_id: string | null
  active_total_questions: number | null
  active_answered_count: number
  last_score_percentage: number | null
}

type QuestionReviewStatsRow = {
  question_id: string
  question_text: string
  domain_id: string | null
  domain_title: string
  topic_id: string | null
  topic_title: string
  lesson_id: string | null
  lesson_title: string | null
  lesson_slug: string | null
  total_attempts: number
  correct_count: number
  incorrect_count: number
  accuracy_percentage: number
  error_percentage: number
  last_answered_at: string
  last_result: boolean
}

type MockExamAttemptRow = {
  id: string
  user_id: string
  certification_id: string
  status: MockExamAttemptStatus
  total_questions: number
  answered_questions: number
  correct_answers: number | null
  incorrect_answers: number | null
  unanswered_questions: number | null
  practice_score_percentage: number | null
  started_at: string
  submitted_at: string | null
  abandoned_at: string | null
  expires_at: string | null
  time_limit_seconds: number | null
  elapsed_seconds: number | null
  last_activity_at: string
  selection_policy_version: string
  domain_allocation: Json
  difficulty_allocation: Json
  created_at: string
  updated_at: string
}

type MockExamAttemptQuestionRow = {
  id: string
  attempt_id: string
  question_id: string
  display_order: number
  domain_id: string
  domain_title_snapshot: string
  topic_id: string
  topic_title_snapshot: string
  lesson_id: string
  lesson_title_snapshot: string
  lesson_slug_snapshot: string
  difficulty_snapshot: QuestionDifficulty
  question_type_snapshot: QuestionType
  question_text_snapshot: string
  options_snapshot: Json
  correct_option_key: string
  question_explanation_snapshot: string | null
  question_source_updated_at: string
  snapshot_schema_version: number
  created_at: string
}

type MockExamAnswerRow = {
  id: string
  attempt_id: string
  attempt_question_id: string
  selected_option_key: string
  is_correct: boolean | null
  answered_at: string
  created_at: string
  updated_at: string
}

type MockExamAttemptQuestionPublicRow = {
  id: string
  attempt_id: string
  question_id: string
  display_order: number
  question_text: string
  options: Json
  selected_option_key: string | null
  answered_at: string | null
}

type SaveMockExamAnswerRow = Pick<
  MockExamAnswerRow,
  'id' | 'attempt_id' | 'attempt_question_id' | 'selected_option_key' | 'answered_at'
>

type MockExamResultRow = {
  attempt_id: string
  total_questions: number
  answered_questions: number
  correct_answers: number
  incorrect_answers: number
  unanswered_questions: number
  practice_score_percentage: number
  started_at: string
  submitted_at: string
  elapsed_seconds: number | null
  domain_breakdown: Json
  topic_breakdown: Json
  difficulty_breakdown: Json
}

type MockExamReviewRow = {
  id: string
  attempt_id: string
  question_id: string
  display_order: number
  domain_id: string
  domain_title: string
  topic_id: string
  topic_title: string
  lesson_id: string
  lesson_title: string
  lesson_slug: string
  difficulty: QuestionDifficulty
  question_text: string
  options: Json
  selected_option_key: string | null
  correct_option_key: string
  answer_status: 'correct' | 'incorrect' | 'unanswered'
  explanation: string | null
}

type MockExamSessionRow = {
  attempt: Json
  server_now: string
}

type MockExamHistoryRow = {
  attempt_id: string
  attempt_number: number
  status: MockExamAttemptStatus
  total_questions: number
  answered_questions: number
  correct_answers: number | null
  incorrect_answers: number | null
  unanswered_questions: number | null
  practice_score_percentage: number | null
  started_at: string
  submitted_at: string | null
  expires_at: string | null
  time_limit_seconds: number | null
  elapsed_seconds: number | null
  total_count: number
}

type ReadinessEvidenceRow = {
  evidence_id: string
  evidence_kind: 'assessment' | 'learning'
  source:
    | 'mock_exam'
    | 'topic_quiz'
    | 'lesson_quiz'
    | 'review_quiz'
    | 'lesson_progress'
    | 'flashcard_review'
    | 'flashcard_progress'
  attempt_id: string | null
  question_id: string | null
  domain_id: string
  topic_id: string
  lesson_id: string | null
  outcome: 'correct' | 'incorrect' | 'unanswered' | null
  occurred_at: string | null
  difficulty: QuestionDifficulty | null
  attempt_status: 'completed' | 'expired' | null
  duration_seconds: number | null
  lesson_status: LessonProgressStatus | null
  flashcard_rating: FlashcardReviewRating | null
  review_count: number | null
  successful_review_count: number | null
  due_at: string | null
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
          mock_eligible?: boolean
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
      lesson_content_blocks: TableDefinition<
        LessonContentBlockRow,
        Pick<LessonContentBlockRow, 'lesson_id' | 'type'> & {
          id?: string
          title?: string | null
          content?: string | null
          config?: LessonContentBlockConfig | null
          visual_experience_id?: string | null
          display_order?: number
          is_published?: boolean
          created_at?: string
          updated_at?: string
        },
        Partial<LessonContentBlockRow>,
        [
          {
            foreignKeyName: 'lesson_content_blocks_lesson_id_fkey'
            columns: ['lesson_id']
            isOneToOne: false
            referencedRelation: 'lessons'
            referencedColumns: ['id']
          },
          {
            foreignKeyName: 'lesson_content_blocks_visual_experience_lesson_fkey'
            columns: ['visual_experience_id', 'lesson_id']
            isOneToOne: false
            referencedRelation: 'visual_experiences'
            referencedColumns: ['id', 'lesson_id']
          },
        ]
      >
      visual_experiences: TableDefinition<
        VisualExperienceRow,
        Pick<
          VisualExperienceRow,
          'lesson_id' | 'type' | 'title' | 'description' | 'config'
        > & {
          id?: string
          display_order?: number
          is_published?: boolean
          created_at?: string
          updated_at?: string
        },
        Partial<VisualExperienceRow>,
        [
          {
            foreignKeyName: 'visual_experiences_lesson_id_fkey'
            columns: ['lesson_id']
            isOneToOne: false
            referencedRelation: 'lessons'
            referencedColumns: ['id']
          },
        ]
      >
      flashcards: TableDefinition<
        FlashcardRow,
        Pick<FlashcardRow, 'lesson_id' | 'front_text' | 'back_text'> & {
          id?: string
          hint?: string | null
          display_order?: number
          is_published?: boolean
          created_at?: string
          updated_at?: string
        },
        Partial<FlashcardRow>,
        [
          {
            foreignKeyName: 'flashcards_lesson_id_fkey'
            columns: ['lesson_id']
            isOneToOne: false
            referencedRelation: 'lessons'
            referencedColumns: ['id']
          },
        ]
      >
      flashcard_reviews: TableDefinition<
        FlashcardReviewRow,
        Pick<FlashcardReviewRow, 'user_id' | 'flashcard_id' | 'rating'> & {
          id?: string
          reviewed_at?: string
          created_at?: string
        },
        Partial<FlashcardReviewRow>,
        [
          {
            foreignKeyName: 'flashcard_reviews_flashcard_id_fkey'
            columns: ['flashcard_id']
            isOneToOne: false
            referencedRelation: 'flashcards'
            referencedColumns: ['id']
          },
        ]
      >
      user_flashcard_progress: TableDefinition<
        UserFlashcardProgressRow,
        Pick<UserFlashcardProgressRow, 'user_id' | 'flashcard_id'> & {
          id?: string
          last_rating?: FlashcardReviewRating | null
          review_count?: number
          successful_review_count?: number
          interval_days?: number
          next_review_at?: string | null
          last_reviewed_at?: string | null
          created_at?: string
          updated_at?: string
        },
        Partial<UserFlashcardProgressRow>,
        [
          {
            foreignKeyName: 'user_flashcard_progress_flashcard_id_fkey'
            columns: ['flashcard_id']
            isOneToOne: false
            referencedRelation: 'flashcards'
            referencedColumns: ['id']
          },
        ]
      >
      user_lesson_progress: TableDefinition<
        UserLessonProgressRow,
        Pick<UserLessonProgressRow, 'user_id' | 'lesson_id'> & {
          id?: string
          status?: LessonProgressStatus
          started_at?: string | null
          completed_at?: string | null
          last_accessed_at?: string | null
          created_at?: string
          updated_at?: string
        },
        Partial<UserLessonProgressRow>,
        [
          {
            foreignKeyName: 'user_lesson_progress_lesson_id_fkey'
            columns: ['lesson_id']
            isOneToOne: false
            referencedRelation: 'lessons'
            referencedColumns: ['id']
          },
        ]
      >
      questions: TableDefinition<
        QuestionRow,
        Pick<QuestionRow, 'certification_id' | 'question_text'> & {
          id?: string
          domain_id?: string | null
          topic_id?: string | null
          lesson_id?: string | null
          question_type?: QuestionType
          difficulty?: QuestionDifficulty | null
          explanation?: string | null
          is_published?: boolean
          display_order?: number
          created_at?: string
          updated_at?: string
        },
        Partial<QuestionRow>,
        [
          {
            foreignKeyName: 'questions_certification_id_fkey'
            columns: ['certification_id']
            isOneToOne: false
            referencedRelation: 'certifications'
            referencedColumns: ['id']
          },
          {
            foreignKeyName: 'questions_domain_certification_fkey'
            columns: ['domain_id', 'certification_id']
            isOneToOne: false
            referencedRelation: 'domains'
            referencedColumns: ['id', 'certification_id']
          },
          {
            foreignKeyName: 'questions_topic_domain_fkey'
            columns: ['topic_id', 'domain_id']
            isOneToOne: false
            referencedRelation: 'topics'
            referencedColumns: ['id', 'domain_id']
          },
          {
            foreignKeyName: 'questions_lesson_topic_fkey'
            columns: ['lesson_id', 'topic_id']
            isOneToOne: false
            referencedRelation: 'lessons'
            referencedColumns: ['id', 'topic_id']
          },
        ]
      >
      question_options: TableDefinition<
        QuestionOptionRow,
        Pick<QuestionOptionRow, 'question_id' | 'option_text'> & {
          id?: string
          is_correct?: boolean
          explanation?: string | null
          display_order?: number
          created_at?: string
          updated_at?: string
        },
        Partial<QuestionOptionRow>,
        [
          {
            foreignKeyName: 'question_options_question_id_fkey'
            columns: ['question_id']
            isOneToOne: false
            referencedRelation: 'questions'
            referencedColumns: ['id']
          },
        ]
      >
      quiz_attempts: TableDefinition<
        QuizAttemptRow,
        Pick<QuizAttemptRow, 'user_id' | 'certification_id' | 'quiz_type' | 'total_questions'> & {
          id?: string
          lesson_id?: string | null
          topic_id?: string | null
          status?: QuizAttemptStatus
          correct_answers?: number
          score_percentage?: number
          started_at?: string
          completed_at?: string | null
          created_at?: string
          updated_at?: string
        },
        Partial<QuizAttemptRow>
      >
      quiz_attempt_questions: TableDefinition<
        QuizAttemptQuestionRow,
        Pick<QuizAttemptQuestionRow, 'attempt_id' | 'question_id' | 'display_order'> & {
          id?: string
          created_at?: string
        },
        Partial<QuizAttemptQuestionRow>
      >
      quiz_answers: TableDefinition<
        QuizAnswerRow,
        Pick<QuizAnswerRow, 'attempt_id' | 'question_id' | 'selected_option_id' | 'is_correct'> & {
          id?: string
          answered_at?: string
          created_at?: string
        },
        Partial<QuizAnswerRow>
      >
      mock_exam_attempts: TableDefinition<
        MockExamAttemptRow,
        Pick<
          MockExamAttemptRow,
          'user_id' | 'certification_id' | 'total_questions' | 'selection_policy_version'
        > & {
          id?: string
          status?: MockExamAttemptStatus
          answered_questions?: number
          correct_answers?: number | null
          incorrect_answers?: number | null
          unanswered_questions?: number | null
          practice_score_percentage?: number | null
          started_at?: string
          submitted_at?: string | null
          abandoned_at?: string | null
          expires_at?: string | null
          time_limit_seconds?: number | null
          elapsed_seconds?: number | null
          last_activity_at?: string
          domain_allocation?: Json
          difficulty_allocation?: Json
          created_at?: string
          updated_at?: string
        },
        Partial<MockExamAttemptRow>
      >
      mock_exam_attempt_questions: TableDefinition<
        MockExamAttemptQuestionRow,
        Pick<
          MockExamAttemptQuestionRow,
          | 'attempt_id'
          | 'question_id'
          | 'display_order'
          | 'domain_id'
          | 'domain_title_snapshot'
          | 'topic_id'
          | 'topic_title_snapshot'
          | 'lesson_id'
          | 'lesson_title_snapshot'
          | 'lesson_slug_snapshot'
          | 'difficulty_snapshot'
          | 'question_type_snapshot'
          | 'question_text_snapshot'
          | 'options_snapshot'
          | 'correct_option_key'
          | 'question_source_updated_at'
        > & {
          id?: string
          question_explanation_snapshot?: string | null
          snapshot_schema_version?: number
          created_at?: string
        },
        Partial<MockExamAttemptQuestionRow>
      >
      mock_exam_answers: TableDefinition<
        MockExamAnswerRow,
        Pick<
          MockExamAnswerRow,
          'attempt_id' | 'attempt_question_id' | 'selected_option_key'
        > & {
          id?: string
          is_correct?: boolean | null
          answered_at?: string
          created_at?: string
          updated_at?: string
        },
        Partial<MockExamAnswerRow>
      >
    }
    Views: {
      question_options_public: {
        Row: QuestionOptionPublicRow
        Insert: never
        Update: never
        Relationships: []
      }
    }
    Functions: {
      start_lesson_progress: {
        Args: { p_lesson_id: string }
        Returns: UserLessonProgressRow[]
      }
      complete_lesson_progress: {
        Args: { p_lesson_id: string }
        Returns: UserLessonProgressRow[]
      }
      start_lesson_quiz: {
        Args: { p_lesson_id: string }
        Returns: QuizAttemptRow[]
      }
      submit_quiz_answer: {
        Args: {
          p_attempt_id: string
          p_question_id: string
          p_selected_option_id: string
        }
        Returns: SubmitQuizAnswerRow[]
      }
      get_quiz_answer_review: {
        Args: { p_attempt_id: string }
        Returns: QuizAnswerReviewRow[]
      }
      start_topic_quiz: {
        Args: { p_topic_id: string }
        Returns: QuizAttemptRow[]
      }
      get_topic_quiz_performance: {
        Args: { p_attempt_id: string }
        Returns: TopicQuizPerformanceRow[]
      }
      get_topic_quiz_summaries: {
        Args: { p_certification_id: string }
        Returns: TopicQuizSummaryRow[]
      }
      get_user_question_stats: {
        Args: { p_certification_id: string }
        Returns: QuestionReviewStatsRow[]
      }
      start_review_quiz: {
        Args: { p_certification_id: string; p_question_id?: string | null }
        Returns: QuizAttemptRow[]
      }
      get_quiz_lesson_performance: {
        Args: { p_attempt_id: string }
        Returns: TopicQuizPerformanceRow[]
      }
      submit_flashcard_review: {
        Args: { p_flashcard_id: string; p_rating: FlashcardReviewRating }
        Returns: SubmitFlashcardReviewRow[]
      }
      get_flashcard_study_queue: {
        Args: { p_certification_id: string; p_limit?: number; p_new_limit?: number }
        Returns: FlashcardStudyQueueRow[]
      }
      get_flashcard_review_overview: {
        Args: { p_certification_id: string }
        Returns: FlashcardReviewOverviewRow[]
      }
      get_flashcard_catalog_overview: {
        Args: { p_certification_id: string }
        Returns: FlashcardCatalogOverviewRow[]
      }
      get_available_flashcards: {
        Args: {
          p_certification_id: string
          p_topic_id?: string | null
          p_lesson_id?: string | null
        }
        Returns: AvailableFlashcardRow[]
      }
      get_mock_exam_attempt_questions: {
        Args: { p_attempt_id: string }
        Returns: MockExamAttemptQuestionPublicRow[]
      }
      save_mock_exam_answer: {
        Args: {
          p_attempt_id: string
          p_attempt_question_id: string
          p_selected_option_key: string
        }
        Returns: SaveMockExamAnswerRow[]
      }
      abandon_mock_exam_attempt: {
        Args: { p_attempt_id: string }
        Returns: MockExamAttemptRow[]
      }
      start_mock_exam: {
        Args: { p_certification_id: string }
        Returns: MockExamAttemptRow[]
      }
      submit_mock_exam: {
        Args: { p_attempt_id: string }
        Returns: MockExamAttemptRow[]
      }
      get_mock_exam_result: {
        Args: { p_attempt_id: string }
        Returns: MockExamResultRow[]
      }
      get_mock_exam_review: {
        Args: { p_attempt_id: string }
        Returns: MockExamReviewRow[]
      }
      sync_mock_exam_attempt: {
        Args: { p_attempt_id: string }
        Returns: MockExamSessionRow[]
      }
      get_mock_exam_history: {
        Args: { p_certification_id: string; p_limit?: number; p_offset?: number }
        Returns: MockExamHistoryRow[]
      }
      get_readiness_evidence: {
        Args: { p_certification_id: string }
        Returns: ReadinessEvidenceRow[]
      }
    }
    Enums: Record<string, never>
    CompositeTypes: Record<string, never>
  }
}

export type CertificationDatabaseRow = CertificationRow
export type DomainDatabaseRow = DomainRow
export type TopicDatabaseRow = TopicRow
export type LessonDatabaseRow = LessonRow
export type LessonContentBlockDatabaseRow = LessonContentBlockRow
export type VisualExperienceDatabaseRow = VisualExperienceRow
export type FlashcardDatabaseRow = FlashcardRow
export type FlashcardReviewDatabaseRow = FlashcardReviewRow
export type UserFlashcardProgressDatabaseRow = UserFlashcardProgressRow
export type SubmitFlashcardReviewDatabaseRow = SubmitFlashcardReviewRow
export type FlashcardStudyQueueDatabaseRow = FlashcardStudyQueueRow
export type FlashcardReviewOverviewDatabaseRow = FlashcardReviewOverviewRow
export type FlashcardCatalogOverviewDatabaseRow = FlashcardCatalogOverviewRow
export type AvailableFlashcardDatabaseRow = AvailableFlashcardRow
export type UserLessonProgressDatabaseRow = UserLessonProgressRow
export type QuestionDatabaseRow = QuestionRow
export type QuestionOptionDatabaseRow = QuestionOptionRow
export type QuestionOptionPublicDatabaseRow = QuestionOptionPublicRow
export type QuizAttemptDatabaseRow = QuizAttemptRow
export type QuizAttemptQuestionDatabaseRow = QuizAttemptQuestionRow
export type QuizAnswerDatabaseRow = QuizAnswerRow
export type QuizAnswerReviewDatabaseRow = QuizAnswerReviewRow
export type SubmitQuizAnswerDatabaseRow = SubmitQuizAnswerRow
export type TopicQuizPerformanceDatabaseRow = TopicQuizPerformanceRow
export type TopicQuizSummaryDatabaseRow = TopicQuizSummaryRow
export type QuestionReviewStatsDatabaseRow = QuestionReviewStatsRow
export type MockExamAttemptDatabaseRow = MockExamAttemptRow
export type MockExamAttemptQuestionDatabaseRow = MockExamAttemptQuestionRow
export type MockExamAnswerDatabaseRow = MockExamAnswerRow
export type MockExamAttemptQuestionPublicDatabaseRow = MockExamAttemptQuestionPublicRow
export type SaveMockExamAnswerDatabaseRow = SaveMockExamAnswerRow
export type MockExamResultDatabaseRow = MockExamResultRow
export type MockExamReviewDatabaseRow = MockExamReviewRow
export type MockExamSessionDatabaseRow = MockExamSessionRow
export type MockExamHistoryDatabaseRow = MockExamHistoryRow
export type ReadinessEvidenceDatabaseRow = ReadinessEvidenceRow

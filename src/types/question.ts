export type QuestionType = 'single_choice'

export type QuestionDifficulty = 'easy' | 'medium' | 'hard'

export interface Question {
  readonly id: string
  readonly certificationId: string
  readonly domainId: string | null
  readonly topicId: string | null
  readonly lessonId: string | null
  readonly questionText: string
  readonly questionType: QuestionType
  readonly difficulty: QuestionDifficulty | null
  readonly explanation: string | null
  readonly isPublished: boolean
  readonly displayOrder: number
  readonly createdAt: string
  readonly updatedAt: string
}

export interface QuestionOption {
  readonly id: string
  readonly questionId: string
  readonly optionText: string
  readonly isCorrect: boolean
  readonly explanation: string | null
  readonly displayOrder: number
  readonly createdAt: string
  readonly updatedAt: string
}

export interface QuestionWithOptions extends Question {
  readonly options: readonly QuestionOption[]
}

export type PublicQuestion = Omit<Question, 'explanation'>

export interface PublicQuestionOption {
  readonly id: string
  readonly questionId: string
  readonly optionText: string
  readonly displayOrder: number
}

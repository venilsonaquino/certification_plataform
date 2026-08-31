import { lazy, Suspense, type ReactNode } from 'react'
import { Navigate, Route, Routes } from 'react-router-dom'

import { RouteLoadingState } from './components/routing/RouteLoadingState'
import { CertificationRoute } from './components/routing/CertificationRoute'
import { DefaultDashboardRedirect } from './components/routing/DefaultDashboardRedirect'
import { ProtectedRoute } from './components/routing/ProtectedRoute'
import { PublicOnlyRoute } from './components/routing/PublicOnlyRoute'
import { AppLayout } from './layouts/AppLayout'
import { AuthLayout } from './layouts/AuthLayout'

const CertificationsPage = lazy(() => import('./pages/CertificationsPage').then((module) => ({ default: module.CertificationsPage })))
const DashboardPage = lazy(() => import('./pages/DashboardPage').then((module) => ({ default: module.DashboardPage })))
const MockExamsPage = lazy(() => import('./pages/MockExamsPage').then((module) => ({ default: module.MockExamsPage })))
const MockExamExecutionPage = lazy(() => import('./pages/MockExamExecutionPage').then((module) => ({ default: module.MockExamExecutionPage })))
const MockExamResultPage = lazy(() => import('./pages/MockExamResultPage').then((module) => ({ default: module.MockExamResultPage })))
const MockExamReviewPage = lazy(() => import('./pages/MockExamReviewPage').then((module) => ({ default: module.MockExamReviewPage })))
const ProgressPage = lazy(() => import('./pages/ProgressPage').then((module) => ({ default: module.ProgressPage })))
const ReadinessPage = lazy(() => import('./pages/ReadinessPage').then((module) => ({ default: module.ReadinessPage })))
const RegisterPage = lazy(() => import('./pages/RegisterPage').then((module) => ({ default: module.RegisterPage })))
const ReviewPage = lazy(() => import('./pages/ReviewPage').then((module) => ({ default: module.ReviewPage })))
const ReviewQuizPage = lazy(() => import('./pages/ReviewQuizPage').then((module) => ({ default: module.ReviewQuizPage })))
const LessonPage = lazy(() => import('./pages/LessonPage').then((module) => ({ default: module.LessonPage })))
const LessonQuizPage = lazy(() => import('./pages/LessonQuizPage').then((module) => ({ default: module.LessonQuizPage })))
const StudyPage = lazy(() => import('./pages/StudyPage').then((module) => ({ default: module.StudyPage })))
const StudyTodayPage = lazy(() => import('./pages/StudyTodayPage').then((module) => ({ default: module.StudyTodayPage })))
const TopicQuizPage = lazy(() => import('./pages/TopicQuizPage').then((module) => ({ default: module.TopicQuizPage })))
const LoginPage = lazy(() => import('./pages/LoginPage').then((module) => ({ default: module.LoginPage })))
const FlashcardPage = lazy(() => import('./pages/FlashcardPage').then((module) => ({ default: module.FlashcardPage })))
const DailyFlashcardReviewPage = lazy(() => import('./pages/DailyFlashcardReviewPage').then((module) => ({ default: module.DailyFlashcardReviewPage })))

function lazyRoute(element: ReactNode) {
  return <Suspense fallback={<RouteLoadingState />}>{element}</Suspense>
}

function App() {
  return (
    <Routes>
      <Route element={<PublicOnlyRoute />}>
        <Route element={<AuthLayout />}>
          <Route path="/login" element={lazyRoute(<LoginPage />)} />
          <Route path="/register" element={lazyRoute(<RegisterPage />)} />
        </Route>
      </Route>

      <Route element={<ProtectedRoute />}>
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="/dashboard" element={<DefaultDashboardRedirect />} />
        <Route path="/certifications" element={lazyRoute(<CertificationsPage />)} />
        <Route path="/certifications/:certificationCode" element={<CertificationRoute />}>
          <Route element={<AppLayout />}>
            <Route index element={<Navigate to="dashboard" replace />} />
            <Route path="dashboard" element={lazyRoute(<DashboardPage />)} />
            <Route path="study-today" element={lazyRoute(<StudyTodayPage />)} />
            <Route path="study" element={lazyRoute(<StudyPage />)} />
            <Route path="study/:lessonSlug/quiz" element={lazyRoute(<LessonQuizPage />)} />
            <Route path="study/:lessonSlug/flashcards" element={lazyRoute(<FlashcardPage />)} />
            <Route path="study/:lessonSlug" element={lazyRoute(<LessonPage />)} />
            <Route path="topics/:topicId/quiz" element={lazyRoute(<TopicQuizPage />)} />
            <Route path="review" element={lazyRoute(<ReviewPage />)} />
            <Route path="review/quiz" element={lazyRoute(<ReviewQuizPage />)} />
            <Route path="review/flashcards" element={lazyRoute(<DailyFlashcardReviewPage />)} />
            <Route path="exams" element={lazyRoute(<MockExamsPage />)} />
            <Route path="exams/:attemptId" element={lazyRoute(<MockExamExecutionPage />)} />
            <Route path="exams/:attemptId/result" element={lazyRoute(<MockExamResultPage />)} />
            <Route path="exams/:attemptId/review" element={lazyRoute(<MockExamReviewPage />)} />
            <Route path="readiness" element={lazyRoute(<ReadinessPage />)} />
            <Route path="progress" element={lazyRoute(<ProgressPage />)} />
          </Route>
        </Route>
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

export default App

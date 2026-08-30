import { Navigate, Route, Routes } from 'react-router-dom'

import { CertificationRoute } from './components/routing/CertificationRoute'
import { DefaultDashboardRedirect } from './components/routing/DefaultDashboardRedirect'
import { ProtectedRoute } from './components/routing/ProtectedRoute'
import { PublicOnlyRoute } from './components/routing/PublicOnlyRoute'
import { AppLayout } from './layouts/AppLayout'
import { AuthLayout } from './layouts/AuthLayout'
import { CertificationsPage } from './pages/CertificationsPage'
import { DashboardPage } from './pages/DashboardPage'
import { LabsPage } from './pages/LabsPage'
import { MapPage } from './pages/MapPage'
import { MockExamsPage } from './pages/MockExamsPage'
import { MockExamExecutionPage } from './pages/MockExamExecutionPage'
import { MockExamResultPlaceholderPage } from './pages/MockExamResultPlaceholderPage'
import { ProgressPage } from './pages/ProgressPage'
import { QuizPage } from './pages/QuizPage'
import { RegisterPage } from './pages/RegisterPage'
import { ReviewPage } from './pages/ReviewPage'
import { ReviewQuizPage } from './pages/ReviewQuizPage'
import { LessonPage } from './pages/LessonPage'
import { LessonQuizPage } from './pages/LessonQuizPage'
import { StoryModePage } from './pages/StoryModePage'
import { StudyPage } from './pages/StudyPage'
import { StudyTodayPage } from './pages/StudyTodayPage'
import { TopicQuizPage } from './pages/TopicQuizPage'
import { LoginPage } from './pages/LoginPage'
import { FlashcardPage } from './pages/FlashcardPage'
import { DailyFlashcardReviewPage } from './pages/DailyFlashcardReviewPage'

function App() {
  return (
    <Routes>
      <Route element={<PublicOnlyRoute />}>
        <Route element={<AuthLayout />}>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
        </Route>
      </Route>

      <Route element={<ProtectedRoute />}>
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="/dashboard" element={<DefaultDashboardRedirect />} />
        <Route path="/certifications" element={<CertificationsPage />} />
        <Route path="/certifications/:certificationCode" element={<CertificationRoute />}>
          <Route element={<AppLayout />}>
            <Route index element={<Navigate to="dashboard" replace />} />
            <Route path="dashboard" element={<DashboardPage />} />
            <Route path="study-today" element={<StudyTodayPage />} />
            <Route path="study" element={<StudyPage />} />
            <Route path="study/:lessonSlug/quiz" element={<LessonQuizPage />} />
            <Route path="study/:lessonSlug/flashcards" element={<FlashcardPage />} />
            <Route path="study/:lessonSlug" element={<LessonPage />} />
            <Route path="topics/:topicId/quiz" element={<TopicQuizPage />} />
            <Route path="map" element={<MapPage />} />
            <Route path="labs" element={<LabsPage />} />
            <Route path="story" element={<StoryModePage />} />
            <Route path="quiz" element={<QuizPage />} />
            <Route path="review" element={<ReviewPage />} />
            <Route path="review/quiz" element={<ReviewQuizPage />} />
            <Route path="review/flashcards" element={<DailyFlashcardReviewPage />} />
            <Route path="exams" element={<MockExamsPage />} />
            <Route path="exams/:attemptId" element={<MockExamExecutionPage />} />
            <Route path="exams/:attemptId/result" element={<MockExamResultPlaceholderPage />} />
            <Route path="progress" element={<ProgressPage />} />
          </Route>
        </Route>
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

export default App

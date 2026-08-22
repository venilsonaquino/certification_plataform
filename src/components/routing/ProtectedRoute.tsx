import { Navigate, Outlet, useLocation } from 'react-router-dom'

import { useAuth } from '../../hooks/useAuth'
import { AuthLoadingScreen } from '../auth/AuthLoadingScreen'

export function ProtectedRoute() {
  const { user, loading } = useAuth()
  const location = useLocation()

  if (loading) {
    return <AuthLoadingScreen />
  }

  if (!user) {
    const requestedPath = `${location.pathname}${location.search}${location.hash}`
    return <Navigate to="/login" replace state={{ from: requestedPath }} />
  }

  return <Outlet />
}

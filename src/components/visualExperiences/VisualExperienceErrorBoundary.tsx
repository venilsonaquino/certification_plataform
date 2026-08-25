import { Component, type ErrorInfo, type ReactNode } from 'react'

interface VisualExperienceErrorBoundaryProps {
  children: ReactNode
  resetKey: string
}

interface VisualExperienceErrorBoundaryState {
  hasError: boolean
}

export class VisualExperienceErrorBoundary extends Component<
  VisualExperienceErrorBoundaryProps,
  VisualExperienceErrorBoundaryState
> {
  state: VisualExperienceErrorBoundaryState = { hasError: false }

  static getDerivedStateFromError(): VisualExperienceErrorBoundaryState {
    return { hasError: true }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    if (import.meta.env.DEV) {
      console.error('Falha ao renderizar experiência visual.', error, errorInfo)
    }
  }

  componentDidUpdate(previousProps: VisualExperienceErrorBoundaryProps) {
    if (this.state.hasError && previousProps.resetKey !== this.props.resetKey) {
      this.setState({ hasError: false })
    }
  }

  render() {
    if (this.state.hasError) {
      return (
        <div
          role="alert"
          className="rounded-2xl border border-rose-200 bg-rose-50 px-5 py-6 text-sm font-semibold text-rose-800"
        >
          Não foi possível carregar esta visualização.
        </div>
      )
    }

    return this.props.children
  }
}

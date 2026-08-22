import { LoaderCircle } from 'lucide-react'
import { type FormEvent, useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'

import { FormField } from '../components/auth/FormField'
import { useAuth } from '../hooks/useAuth'
import { isValidEmail } from '../lib/validation'

interface LoginErrors {
  email?: string
  password?: string
}

interface LoginLocationState {
  from?: string
}

export function LoginPage() {
  const { signIn, isConfigured } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [errors, setErrors] = useState<LoginErrors>({})
  const [formError, setFormError] = useState<string | null>(null)
  const [isSubmitting, setIsSubmitting] = useState(false)

  const validate = () => {
    const nextErrors: LoginErrors = {}

    if (!email.trim()) {
      nextErrors.email = 'Informe seu email.'
    } else if (!isValidEmail(email.trim())) {
      nextErrors.email = 'Informe um email válido.'
    }

    if (!password) {
      nextErrors.password = 'Informe sua senha.'
    }

    setErrors(nextErrors)
    return Object.keys(nextErrors).length === 0
  }

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setFormError(null)

    if (!validate()) {
      return
    }

    setIsSubmitting(true)
    const result = await signIn(email.trim(), password)
    setIsSubmitting(false)

    if (result.error) {
      setFormError(result.error)
      return
    }

    const state = location.state as LoginLocationState | null
    const requestedPath = state?.from
    const returnTo = requestedPath?.startsWith('/') && !requestedPath.startsWith('//')
      ? requestedPath
      : '/dashboard'
    navigate(returnTo, { replace: true })
  }

  return (
    <section className="rounded-3xl border border-slate-200/80 bg-white p-6 shadow-card sm:p-8">
      <p className="text-sm font-semibold text-blue-600">Acesse sua conta</p>
      <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950">
        Bem-vindo de volta
      </h1>
      <p className="mt-3 text-sm leading-6 text-slate-500">
        Entre para continuar sua jornada de certificação.
      </p>

      {!isConfigured && (
        <div role="status" className="mt-6 rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm leading-6 text-amber-800">
          A autenticação ainda não está configurada neste ambiente.
        </div>
      )}

      {formError && (
        <div role="alert" className="mt-6 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm leading-6 text-rose-700">
          {formError}
        </div>
      )}

      <form noValidate onSubmit={handleSubmit} className="mt-7 space-y-5">
        <FormField
          id="email"
          label="Email"
          type="email"
          autoComplete="email"
          placeholder="voce@exemplo.com"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          error={errors.email}
          disabled={isSubmitting}
        />
        <FormField
          id="password"
          label="Senha"
          type="password"
          autoComplete="current-password"
          placeholder="Digite sua senha"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          error={errors.password}
          disabled={isSubmitting}
        />

        <button
          type="submit"
          disabled={isSubmitting}
          className="flex h-12 w-full items-center justify-center gap-2 rounded-xl bg-blue-600 px-5 text-sm font-semibold text-white shadow-lg shadow-blue-200 transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-slate-300 disabled:shadow-none"
        >
          {isSubmitting && <LoaderCircle aria-hidden="true" className="h-4 w-4 animate-spin" />}
          {isSubmitting ? 'Entrando...' : 'Entrar'}
        </button>
      </form>

      <p className="mt-7 text-center text-sm text-slate-500">
        Ainda não possui uma conta?{' '}
        <Link to="/register" className="font-semibold text-blue-600 hover:text-blue-700">
          Criar conta
        </Link>
      </p>
    </section>
  )
}

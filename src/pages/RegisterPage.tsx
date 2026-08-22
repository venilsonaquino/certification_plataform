import { LoaderCircle, MailCheck } from 'lucide-react'
import { type FormEvent, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'

import { FormField } from '../components/auth/FormField'
import { useAuth } from '../hooks/useAuth'
import { isValidEmail } from '../lib/validation'

interface RegisterErrors {
  name?: string
  email?: string
  password?: string
  passwordConfirmation?: string
}

export function RegisterPage() {
  const { signUp, isConfigured } = useAuth()
  const navigate = useNavigate()
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [passwordConfirmation, setPasswordConfirmation] = useState('')
  const [errors, setErrors] = useState<RegisterErrors>({})
  const [formError, setFormError] = useState<string | null>(null)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [requiresEmailConfirmation, setRequiresEmailConfirmation] = useState(false)

  const validate = () => {
    const nextErrors: RegisterErrors = {}

    if (!name.trim()) {
      nextErrors.name = 'Informe seu nome.'
    }

    if (!email.trim()) {
      nextErrors.email = 'Informe seu email.'
    } else if (!isValidEmail(email.trim())) {
      nextErrors.email = 'Informe um email válido.'
    }

    if (!password) {
      nextErrors.password = 'Informe uma senha.'
    } else if (password.length < 6) {
      nextErrors.password = 'A senha deve ter pelo menos 6 caracteres.'
    }

    if (!passwordConfirmation) {
      nextErrors.passwordConfirmation = 'Confirme sua senha.'
    } else if (passwordConfirmation !== password) {
      nextErrors.passwordConfirmation = 'As senhas não são iguais.'
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
    const result = await signUp(name.trim(), email.trim(), password)
    setIsSubmitting(false)

    if (result.error) {
      setFormError(result.error)
      return
    }

    if (result.requiresEmailConfirmation) {
      setRequiresEmailConfirmation(true)
      return
    }

    navigate('/dashboard', { replace: true })
  }

  if (requiresEmailConfirmation) {
    return (
      <section role="status" className="rounded-3xl border border-slate-200/80 bg-white p-6 text-center shadow-card sm:p-8">
        <div className="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-emerald-50 text-emerald-600 ring-1 ring-inset ring-emerald-100">
          <MailCheck aria-hidden="true" className="h-6 w-6" />
        </div>
        <h1 className="mt-6 text-3xl font-bold tracking-tight text-slate-950">Conta criada!</h1>
        <p className="mt-4 text-sm leading-6 text-slate-500">
          Enviamos um link de confirmação para seu email. Confirme seu endereço para acessar a plataforma.
        </p>
        <Link
          to="/login"
          className="mt-7 inline-flex min-h-11 items-center justify-center rounded-xl bg-blue-600 px-5 text-sm font-semibold text-white transition hover:bg-blue-700"
        >
          Voltar para o login
        </Link>
      </section>
    )
  }

  return (
    <section className="rounded-3xl border border-slate-200/80 bg-white p-6 shadow-card sm:p-8">
      <p className="text-sm font-semibold text-blue-600">Nova conta</p>
      <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950">Criar conta</h1>
      <p className="mt-3 text-sm leading-6 text-slate-500">
        Crie seu acesso para começar sua jornada de certificação.
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
          id="name"
          label="Nome"
          type="text"
          autoComplete="name"
          placeholder="Seu nome"
          value={name}
          onChange={(event) => setName(event.target.value)}
          error={errors.name}
          disabled={isSubmitting}
        />
        <FormField
          id="register-email"
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
          id="register-password"
          label="Senha"
          type="password"
          autoComplete="new-password"
          placeholder="Mínimo de 6 caracteres"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          error={errors.password}
          disabled={isSubmitting}
        />
        <FormField
          id="password-confirmation"
          label="Confirmar senha"
          type="password"
          autoComplete="new-password"
          placeholder="Digite a senha novamente"
          value={passwordConfirmation}
          onChange={(event) => setPasswordConfirmation(event.target.value)}
          error={errors.passwordConfirmation}
          disabled={isSubmitting}
        />

        <button
          type="submit"
          disabled={isSubmitting}
          className="flex h-12 w-full items-center justify-center gap-2 rounded-xl bg-blue-600 px-5 text-sm font-semibold text-white shadow-lg shadow-blue-200 transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-slate-300 disabled:shadow-none"
        >
          {isSubmitting && <LoaderCircle aria-hidden="true" className="h-4 w-4 animate-spin" />}
          {isSubmitting ? 'Criando conta...' : 'Criar conta'}
        </button>
      </form>

      <p className="mt-7 text-center text-sm text-slate-500">
        Já possui uma conta?{' '}
        <Link to="/login" className="font-semibold text-blue-600 hover:text-blue-700">
          Entrar
        </Link>
      </p>
    </section>
  )
}

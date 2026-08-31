import { type ReactNode, useCallback, useEffect, useMemo, useState } from 'react'
import type { Session } from '@supabase/supabase-js'

import { AuthContext, type AuthContextValue } from './AuthContext'
import { isSupabaseConfigured, supabase } from '../lib/supabase'
import type { AuthActionResult, SignUpActionResult } from '../types/auth'

interface AuthProviderProps {
  children: ReactNode
}

function clearUserScopedUiState() {
  if (typeof window === 'undefined') return
  for (let index = sessionStorage.length - 1; index >= 0; index -= 1) {
    const key = sessionStorage.key(index)
    if (key?.startsWith('mock-position:')) sessionStorage.removeItem(key)
  }
}

function getErrorCode(error: unknown) {
  if (typeof error === 'object' && error !== null && 'code' in error) {
    const code = error.code
    return typeof code === 'string' ? code : undefined
  }

  return undefined
}

function getFriendlyAuthError(error: unknown, fallback: string) {
  const code = getErrorCode(error)

  const messages: Record<string, string> = {
    invalid_credentials: 'Email ou senha incorretos.',
    email_not_confirmed: 'Confirme seu email antes de entrar.',
    user_already_exists: 'Já existe uma conta com este email.',
    email_exists: 'Já existe uma conta com este email.',
    weak_password: 'A senha não atende aos requisitos de segurança.',
    signup_disabled: 'Novos cadastros estão temporariamente indisponíveis.',
    over_email_send_rate_limit: 'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
    over_request_rate_limit: 'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
  }

  return code ? (messages[code] ?? fallback) : fallback
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let isMounted = true

    if (!supabase) {
      setLoading(false)
      return undefined
    }

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((event, nextSession) => {
      if (isMounted) {
        if (event === 'SIGNED_OUT') clearUserScopedUiState()
        setSession(nextSession)
        setLoading(false)
      }
    })

    void supabase.auth
      .getSession()
      .then(({ data, error }) => {
        if (isMounted) {
          setSession(error ? null : data.session)
          setLoading(false)
        }
      })
      .catch(() => {
        if (isMounted) {
          setSession(null)
          setLoading(false)
        }
      })

    return () => {
      isMounted = false
      subscription.unsubscribe()
    }
  }, [])

  const signIn = useCallback(async (email: string, password: string): Promise<AuthActionResult> => {
    if (!supabase) {
      return { error: 'A autenticação ainda não está configurada.' }
    }

    try {
      const { data, error } = await supabase.auth.signInWithPassword({ email, password })

      if (error) {
        return { error: getFriendlyAuthError(error, 'Não foi possível entrar. Tente novamente.') }
      }

      setSession(data.session)
      return { error: null }
    } catch (error) {
      return { error: getFriendlyAuthError(error, 'Não foi possível conectar. Tente novamente.') }
    }
  }, [])

  const signUp = useCallback(
    async (name: string, email: string, password: string): Promise<SignUpActionResult> => {
      if (!supabase) {
        return {
          error: 'A autenticação ainda não está configurada.',
          requiresEmailConfirmation: false,
        }
      }

      try {
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: { name: name.trim() },
            emailRedirectTo: `${window.location.origin}/dashboard`,
          },
        })

        if (error) {
          return {
            error: getFriendlyAuthError(error, 'Não foi possível criar sua conta. Tente novamente.'),
            requiresEmailConfirmation: false,
          }
        }

        if (data.user?.identities?.length === 0) {
          return {
            error: 'Já existe uma conta com este email.',
            requiresEmailConfirmation: false,
          }
        }

        setSession(data.session)

        return {
          error: null,
          requiresEmailConfirmation: Boolean(data.user && !data.session),
        }
      } catch (error) {
        return {
          error: getFriendlyAuthError(error, 'Não foi possível conectar. Tente novamente.'),
          requiresEmailConfirmation: false,
        }
      }
    },
    [],
  )

  const signOut = useCallback(async (): Promise<AuthActionResult> => {
    if (!supabase) {
      return { error: 'A autenticação ainda não está configurada.' }
    }

    try {
      const { error } = await supabase.auth.signOut({ scope: 'local' })

      if (error) {
        return { error: getFriendlyAuthError(error, 'Não foi possível sair. Tente novamente.') }
      }

      clearUserScopedUiState()
      setSession(null)
      return { error: null }
    } catch (error) {
      return { error: getFriendlyAuthError(error, 'Não foi possível sair. Tente novamente.') }
    }
  }, [])

  const value = useMemo<AuthContextValue>(
    () => ({
      user: session?.user ?? null,
      session,
      loading,
      isConfigured: isSupabaseConfigured,
      signIn,
      signUp,
      signOut,
    }),
    [loading, session, signIn, signOut, signUp],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

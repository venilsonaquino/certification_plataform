import { createContext } from 'react'
import type { Session, User } from '@supabase/supabase-js'

import type { AuthActionResult, SignUpActionResult } from '../types/auth'

export interface AuthContextValue {
  user: User | null
  session: Session | null
  loading: boolean
  isConfigured: boolean
  signIn: (email: string, password: string) => Promise<AuthActionResult>
  signUp: (name: string, email: string, password: string) => Promise<SignUpActionResult>
  signOut: () => Promise<AuthActionResult>
}

export const AuthContext = createContext<AuthContextValue | undefined>(undefined)

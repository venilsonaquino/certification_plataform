export interface AuthActionResult {
  error: string | null
}

export interface SignUpActionResult extends AuthActionResult {
  requiresEmailConfirmation: boolean
}

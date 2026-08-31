import { useCallback, useEffect, useMemo, useState } from 'react'

import { getAz900ReadinessDashboard } from '../services/readinessDashboardService'
import type { Az900ReadinessDashboardData } from '../types/readinessUi'
import { useAuth } from './useAuth'

interface ReadinessState {
  readonly key: string
  readonly data: Az900ReadinessDashboardData | null
  readonly error: string | null
  readonly loading: boolean
}

const INITIAL_STATE: ReadinessState = { key: '', data: null, error: null, loading: true }

export function useCertificationReadiness(certificationId: string, certificationCode: string) {
  const { user } = useAuth()
  const [refreshVersion, setRefreshVersion] = useState(0)
  const requestKey = `${user?.id ?? 'anonymous'}:${certificationId}:${refreshVersion}`
  const [state, setState] = useState<ReadinessState>(INITIAL_STATE)

  useEffect(() => {
    let active = true
    if (!user) {
      setState({ key: requestKey, data: null, error: null, loading: false })
      return () => { active = false }
    }

    setState({ key: requestKey, data: null, error: null, loading: true })
    void getAz900ReadinessDashboard(certificationId, certificationCode)
      .then((data) => {
        if (active) setState({ key: requestKey, data, error: null, loading: false })
      })
      .catch((cause) => {
        console.error('Falha ao carregar Readiness.', cause)
        if (active) {
          setState({
            key: requestKey,
            data: null,
            error: 'Não foi possível carregar seu Readiness agora.',
            loading: false,
          })
        }
      })
    return () => { active = false }
  }, [certificationCode, certificationId, requestKey, user])

  const retry = useCallback(() => setRefreshVersion((version) => version + 1), [])
  return useMemo(() => state.key === requestKey
    ? { data: state.data, error: state.error, loading: state.loading, retry }
    : { data: null, error: null, loading: true, retry }, [requestKey, retry, state])
}

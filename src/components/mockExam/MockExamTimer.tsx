import { Clock3 } from 'lucide-react'
import { useEffect, useRef, useState } from 'react'

import { formatCountdown, getRemainingSeconds } from '../../lib/mockExamTime'

interface MockExamTimerProps {
  expiresAt: string
  serverNow: string
  onExpire: () => void
}

export function MockExamTimer({ expiresAt, serverNow, onExpire }: MockExamTimerProps) {
  const initialSeconds = getRemainingSeconds(expiresAt, serverNow)
  const [remaining, setRemaining] = useState(initialSeconds)
  const expired = useRef(false)

  useEffect(() => {
    const started = performance.now()
    const update = () => {
      const next = Math.max(0, Math.ceil(initialSeconds - (performance.now() - started) / 1000))
      setRemaining(next)
      if (next === 0 && !expired.current) {
        expired.current = true
        onExpire()
      }
    }
    update()
    const interval = window.setInterval(update, 1000)
    return () => window.clearInterval(interval)
  }, [initialSeconds, onExpire])

  const state = remaining <= 300 ? 'Critical' : remaining <= 600 ? 'Warning' : 'Time remaining'
  const tone = remaining <= 300
    ? 'border-rose-200 bg-rose-50 text-rose-800'
    : remaining <= 600
      ? 'border-amber-200 bg-amber-50 text-amber-800'
      : 'border-slate-200 bg-slate-50 text-slate-700'

  return (
    <div role="timer" aria-live="off" aria-label={`${state}: ${formatCountdown(remaining)}`} className={`inline-flex min-h-10 items-center gap-2 rounded-xl border px-3 text-sm font-bold ${tone}`}>
      <Clock3 className="h-4 w-4" aria-hidden="true" />
      <span>{state}: {formatCountdown(remaining)} remaining</span>
      <span className="sr-only" aria-live="polite">Timer status: {state}</span>
    </div>
  )
}

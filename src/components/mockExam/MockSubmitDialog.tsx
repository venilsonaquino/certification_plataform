import { LoaderCircle, X } from 'lucide-react'
import { useEffect, useRef } from 'react'

interface MockSubmitDialogProps {
  open: boolean
  answered: number
  total: number
  submitting: boolean
  error: string | null
  onCancel: () => void
  onConfirm: () => void
}

export function MockSubmitDialog({ open, answered, total, submitting, error, onCancel, onConfirm }: MockSubmitDialogProps) {
  const confirmRef = useRef<HTMLButtonElement>(null)
  useEffect(() => {
    if (!open) return
    confirmRef.current?.focus()
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && !submitting) onCancel()
    }
    document.addEventListener('keydown', onKeyDown)
    return () => document.removeEventListener('keydown', onKeyDown)
  }, [onCancel, open, submitting])

  if (!open) return null
  const unanswered = total - answered
  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-slate-950/60 p-4 backdrop-blur-sm">
      <div role="dialog" aria-modal="true" aria-labelledby="submit-mock-title" className="w-full max-w-lg rounded-2xl bg-white p-6 shadow-2xl sm:p-7">
        <div className="flex items-start justify-between gap-4">
          <div><h2 id="submit-mock-title" className="text-xl font-bold text-slate-950">Enviar Practice Mock?</h2><p className="mt-2 text-sm leading-6 text-slate-600">Após enviar, as respostas não poderão ser alteradas. O resultado será calculado com segurança pelo servidor.</p></div>
          <button type="button" disabled={submitting} onClick={onCancel} aria-label="Fechar confirmação" className="grid h-10 w-10 shrink-0 place-items-center rounded-lg text-slate-500 hover:bg-slate-100"><X className="h-5 w-5" /></button>
        </div>
        <div className="mt-5 rounded-xl bg-slate-50 p-4 text-sm"><p><strong>{answered}</strong> respondidas de {total}</p><p className={unanswered ? 'mt-1 font-semibold text-amber-700' : 'mt-1 text-emerald-700'}>{unanswered} não respondidas</p></div>
        {error && <p role="alert" className="mt-4 text-sm font-semibold text-rose-700">{error}</p>}
        <div className="mt-6 flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
          <button type="button" disabled={submitting} onClick={onCancel} className="min-h-11 rounded-xl border border-slate-300 px-5 text-sm font-bold text-slate-700 hover:bg-slate-50">Voltar ao Mock</button>
          <button ref={confirmRef} type="button" disabled={submitting} onClick={onConfirm} className="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-blue-600 px-5 text-sm font-bold text-white hover:bg-blue-700 disabled:cursor-wait disabled:opacity-60">{submitting && <LoaderCircle className="h-4 w-4 animate-spin" aria-hidden="true" />}{submitting ? 'Enviando...' : 'Confirmar envio'}</button>
        </div>
      </div>
    </div>
  )
}

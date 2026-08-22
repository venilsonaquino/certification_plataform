import { useCertification } from '../hooks/useCertification'
import { formatCertificationCode } from '../lib/certificationVisuals'

interface PageHeadingProps {
  title: string
}

export function PageHeading({ title }: PageHeadingProps) {
  const { currentCertification } = useCertification()

  return (
    <header>
      <p className="text-sm font-semibold text-blue-600">
        {formatCertificationCode(currentCertification.code)} · {currentCertification.name}
      </p>
      <h1 className="mt-2 text-balance text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">
        {title}
      </h1>
    </header>
  )
}

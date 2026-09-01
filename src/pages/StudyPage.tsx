import { BookOpen, LibraryBig } from 'lucide-react'

import { CertificationDataState } from '../components/certifications/CertificationDataState'
import { StudyPath } from '../components/study/StudyPath'
import { useCertification } from '../hooks/useCertification'
import { useCertificationProgress } from '../hooks/useCertificationProgress'
import { useStudyProgression } from '../hooks/useStudyProgression'
import { formatCertificationCode } from '../lib/certificationVisuals'

export function StudyPage() {
  const { currentCertification } = useCertification()
  const {
    domains,
    progressByLessonId,
    summary,
    loading,
    error,
    retry,
  } = useCertificationProgress()
  const progression = useStudyProgression(
    currentCertification.id,
    domains,
    progressByLessonId,
  )
  const pageLoading = loading || progression.loading
  const pageError = error ?? progression.error

  return (
    <div>
      <header className="max-w-3xl">
        <p className="text-sm font-semibold text-blue-600">
          {formatCertificationCode(currentCertification.code)}
        </p>
        <h1 className="mt-2 text-balance text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">
          Trilha de estudos
        </h1>
        <p className="mt-3 text-base leading-7 text-slate-500">
          {currentCertification.name}. Explore os domínios, tópicos e aulas na ordem da prova.
        </p>
      </header>

      <section aria-labelledby="study-path-title" className="mt-8 lg:mt-10">
        <div className="mb-5 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div className="flex items-center gap-3">
            <div className="grid h-10 w-10 place-items-center rounded-xl bg-blue-50 text-blue-600">
              <BookOpen aria-hidden="true" className="h-5 w-5" />
            </div>
            <div>
              <h2 id="study-path-title" className="text-xl font-bold tracking-tight text-slate-950">
                Conteúdo da certificação
              </h2>
              {!pageLoading && !pageError && domains.length > 0 && (
                <p className="mt-0.5 flex items-center gap-1.5 text-sm text-slate-400">
                  <LibraryBig aria-hidden="true" className="h-4 w-4" />
                  {domains.length} domínios · {summary.totalCount} aulas
                </p>
              )}
            </div>
          </div>
        </div>

        {pageLoading && <CertificationDataState title="Carregando trilha de estudos..." loading />}
        {!pageLoading && pageError && (
          <CertificationDataState
            title="Não foi possível carregar a trilha."
            description="Confira sua conexão e tente novamente."
            onRetry={() => { retry(); void progression.retry() }}
          />
        )}
        {!pageLoading && !pageError && domains.length === 0 && (
          <CertificationDataState
            title="Conteúdo ainda não disponível."
            description="Esta certificação não possui uma trilha de estudos publicada."
          />
        )}
        {!pageLoading && !pageError && domains.length > 0 && (
          <StudyPath
            certificationCode={currentCertification.code}
            domains={domains}
            progressByLessonId={progressByLessonId}
            progression={progression.progression}
          />
        )}
      </section>
    </div>
  )
}

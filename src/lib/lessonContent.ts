export interface LessonContentSection {
  readonly heading: string
  readonly paragraphs: readonly string[]
}

export function parseLessonContent(content: string): LessonContentSection[] {
  const sections: Array<{ heading: string; paragraphs: string[] }> = []
  let currentSection: { heading: string; paragraphs: string[] } | null = null
  let paragraphLines: string[] = []

  const flushParagraph = () => {
    if (!currentSection || paragraphLines.length === 0) {
      paragraphLines = []
      return
    }

    currentSection.paragraphs.push(paragraphLines.join(' ').trim())
    paragraphLines = []
  }

  for (const rawLine of content.split(/\r?\n/)) {
    const line = rawLine.trim()

    if (line.startsWith('## ')) {
      flushParagraph()
      currentSection = { heading: line.slice(3).trim(), paragraphs: [] }
      sections.push(currentSection)
      continue
    }

    if (line.startsWith('# ')) {
      continue
    }

    if (!line) {
      flushParagraph()
      continue
    }

    if (!currentSection) {
      currentSection = { heading: 'Conteúdo', paragraphs: [] }
      sections.push(currentSection)
    }

    paragraphLines.push(line)
  }

  flushParagraph()
  return sections.filter((section) => section.paragraphs.length > 0)
}

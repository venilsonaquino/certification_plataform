import { readFileSync, readdirSync } from 'node:fs'
import { resolve } from 'node:path'

const root = resolve(import.meta.dirname, '..')
const migrationsDirectory = resolve(root, 'supabase', 'migrations')

function unquoteIdentifier(value) {
  return value.trim().replace(/^public\./i, '').replaceAll('"', '').toLowerCase()
}

function parseSqlValue(source, start) {
  let cursor = start
  while (/\s/.test(source[cursor] ?? '')) cursor += 1

  if (source[cursor] === "'") {
    cursor += 1
    let value = ''
    while (cursor < source.length) {
      if (source[cursor] === "'" && source[cursor + 1] === "'") {
        value += "'"
        cursor += 2
      } else if (source[cursor] === "'") {
        let nextCursor = cursor + 1
        const cast = source.slice(nextCursor).match(/^::[a-zA-Z_][a-zA-Z0-9_.]*/)?.[0]
        if (cast) nextCursor += cast.length
        return { value, cursor: nextCursor }
      } else {
        value += source[cursor]
        cursor += 1
      }
    }
    throw new Error('Unterminated SQL string')
  }

  if (source[cursor] === '$') {
    const tag = source.slice(cursor).match(/^\$[a-zA-Z0-9_]*\$/)?.[0]
    if (tag) {
      const end = source.indexOf(tag, cursor + tag.length)
      if (end === -1) throw new Error(`Unterminated dollar string ${tag}`)
      return { value: source.slice(cursor + tag.length, end), cursor: end + tag.length }
    }
  }

  const end = source.slice(cursor).search(/[,)]/)
  const raw = source.slice(cursor, end === -1 ? source.length : cursor + end).trim()
  const normalized = raw.toLowerCase()
  const value = normalized === 'null' ? null
    : normalized === 'true' ? true
      : normalized === 'false' ? false
        : /^-?\d+$/.test(raw) ? Number(raw)
          : raw
  return { value, cursor: end === -1 ? source.length : cursor + end }
}

function parseRows(source) {
  const rows = []
  let cursor = 0
  let depth = 0

  while (cursor < source.length) {
    if (source[cursor] !== '(') {
      cursor += 1
      continue
    }

    depth += 1
    if (depth !== 1) {
      cursor += 1
      continue
    }

    cursor += 1
    const row = []
    while (cursor < source.length) {
      while (/\s/.test(source[cursor] ?? '')) cursor += 1
      if (source[cursor] === ')') {
        cursor += 1
        depth -= 1
        rows.push(row)
        break
      }
      const parsed = parseSqlValue(source, cursor)
      row.push(parsed.value)
      cursor = parsed.cursor
      while (/\s/.test(source[cursor] ?? '')) cursor += 1
      if (source[cursor] === ',') cursor += 1
    }
  }

  return rows
}

function tableSchemas(sql) {
  const schemas = new Map()
  const pattern = /create\s+temporary\s+table\s+([^\s(]+)\s*\(([^;]+?)\)\s*on\s+commit/gis
  for (const match of sql.matchAll(pattern)) {
    const columns = match[2]
      .split(',')
      .map((definition) => definition.trim().match(/^"?([a-z_][a-z0-9_]*)"?\s+/i)?.[1]?.toLowerCase())
      .filter(Boolean)
    schemas.set(unquoteIdentifier(match[1]), columns)
  }
  return schemas
}

function insertStatements(sql) {
  const statements = []
  const pattern = /insert\s+into\s+([^\s(]+)\s*(?:\(([^)]*?)\))?\s*values\s*/gi
  for (const match of sql.matchAll(pattern)) {
    const valuesStart = match.index + match[0].length
    let cursor = valuesStart
    let quote = null
    let dollarTag = null
    while (cursor < sql.length) {
      if (dollarTag) {
        if (sql.startsWith(dollarTag, cursor)) {
          cursor += dollarTag.length
          dollarTag = null
        } else cursor += 1
        continue
      }
      if (quote) {
        if (sql[cursor] === quote && sql[cursor + 1] === quote) cursor += 2
        else if (sql[cursor] === quote) {
          quote = null
          cursor += 1
        } else cursor += 1
        continue
      }
      if (sql[cursor] === "'") {
        quote = "'"
        cursor += 1
        continue
      }
      if (sql[cursor] === '$') {
        dollarTag = sql.slice(cursor).match(/^\$[a-zA-Z0-9_]*\$/)?.[0] ?? null
        if (dollarTag) {
          cursor += dollarTag.length
          continue
        }
      }
      if (sql[cursor] === ';') break
      cursor += 1
    }
    statements.push({
      table: unquoteIdentifier(match[1]),
      columns: match[2]?.split(',').map((column) => unquoteIdentifier(column)) ?? null,
      values: sql.slice(valuesStart, cursor),
    })
  }
  return statements
}

function normalize(value) {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim()
}

const cards = new Map()
const sourceFiles = new Map()
const lessonContent = new Map()
const migrationFiles = readdirSync(migrationsDirectory)
  .filter((file) => file.endsWith('.sql'))
  .sort()

for (const file of migrationFiles) {
  const sql = readFileSync(resolve(migrationsDirectory, file), 'utf8')
  const schemas = tableSchemas(sql)
  const lessonSlugs = [...sql.matchAll(/lesson\.slug\s*=\s*'([^']+)'|\bslug\s*=\s*'([^']+)'/gi)]
    .map((match) => match[1] ?? match[2])
  const uniqueLessonSlugs = [...new Set(lessonSlugs)]

  for (const statement of insertStatements(sql)) {
    const columns = statement.columns ?? schemas.get(statement.table)
    if (!columns?.includes('id')) continue

    if (columns.includes('type') && (columns.includes('content') || columns.includes('config'))) {
      for (const values of parseRows(statement.values)) {
        if (values.length !== columns.length) continue
        const row = Object.fromEntries(columns.map((column, index) => [column, values[index]]))
        const lessonSlug = typeof row.lesson_slug === 'string'
          ? row.lesson_slug
          : uniqueLessonSlugs.length === 1 ? uniqueLessonSlugs[0] : null
        if (!lessonSlug) continue
        const text = [row.title, row.content, row.config]
          .filter((value) => typeof value === 'string')
          .join(' ')
        lessonContent.set(lessonSlug, `${lessonContent.get(lessonSlug) ?? ''} ${text}`.trim())
      }
    }

    if (!columns.includes('front_text') || !columns.includes('back_text')) continue

    for (const values of parseRows(statement.values)) {
      if (values.length !== columns.length) continue
      const row = Object.fromEntries(columns.map((column, index) => [column, values[index]]))
      if (typeof row.id !== 'string' || typeof row.front_text !== 'string' || typeof row.back_text !== 'string') continue
      const previous = cards.get(row.id) ?? {}
      const lessonSlug = typeof row.lesson_slug === 'string'
        ? row.lesson_slug
        : previous.lessonSlug ?? (uniqueLessonSlugs.length === 1 ? uniqueLessonSlugs[0] : null)
      cards.set(row.id, {
        ...previous,
        id: row.id,
        lessonSlug,
        frontText: row.front_text,
        backText: row.back_text,
        hint: row.hint ?? previous.hint ?? null,
        isPublished: row.is_published ?? previous.isPublished ?? true,
        lastSource: file,
      })
      sourceFiles.set(row.id, [...(sourceFiles.get(row.id) ?? []), file])
    }
  }

  const inlineFlashcards = /insert\s+into\s+public\.flashcards\s*\([^)]*\)\s*select[\s\S]*?from\s*\(\s*values([\s\S]*?)\)\s*seed\s*\(([^)]*)\)([\s\S]*?);/gi
  for (const inline of sql.matchAll(inlineFlashcards)) {
    const columns = inline[2].split(',').map((column) => unquoteIdentifier(column))
    const lessonSlug = inline[3].match(/lesson\.slug\s*=\s*'([^']+)'/i)?.[1]
      ?? (uniqueLessonSlugs.length === 1 ? uniqueLessonSlugs[0] : null)
    if (!columns.includes('id') || !columns.includes('front_text') || !columns.includes('back_text')) continue
    for (const values of parseRows(inline[1])) {
      if (values.length !== columns.length) continue
      const row = Object.fromEntries(columns.map((column, index) => [column, values[index]]))
      if (typeof row.id !== 'string' || typeof row.front_text !== 'string' || typeof row.back_text !== 'string') continue
      cards.set(row.id, {
        id: row.id,
        lessonSlug,
        frontText: row.front_text,
        backText: row.back_text,
        hint: row.hint ?? null,
        isPublished: true,
        lastSource: file,
      })
      sourceFiles.set(row.id, [...(sourceFiles.get(row.id) ?? []), file])
    }
  }

  const directFlashcards = /insert\s+into\s+public\.flashcards\s*\(([^)]*)\)\s*select\s+([\s\S]*?)\s+from\s+public\.lessons\s+lesson([\s\S]*?);/gi
  for (const direct of sql.matchAll(directFlashcards)) {
    if (/\bseed\./i.test(direct[2])) continue
    const columns = direct[1].split(',').map((column) => unquoteIdentifier(column))
    const values = parseRows(`(${direct[2]})`)[0]
    const lessonSlug = direct[3].match(/lesson\.slug\s*=\s*'([^']+)'/i)?.[1]
      ?? (uniqueLessonSlugs.length === 1 ? uniqueLessonSlugs[0] : null)
    if (!values || values.length !== columns.length) continue
    const row = Object.fromEntries(columns.map((column, index) => [column, values[index]]))
    if (typeof row.id !== 'string' || typeof row.front_text !== 'string' || typeof row.back_text !== 'string') continue
    cards.set(row.id, {
      id: row.id,
      lessonSlug,
      frontText: row.front_text,
      backText: row.back_text,
      hint: row.hint ?? null,
      isPublished: row.is_published ?? true,
      lastSource: file,
    })
    sourceFiles.set(row.id, [...(sourceFiles.get(row.id) ?? []), file])
  }

  for (const update of sql.matchAll(/update\s+public\.flashcards\s+set\s+([\s\S]*?)\s+where\s+([\s\S]*?);/gi)) {
    const assignments = update[1]
    const fieldCases = [
      ['frontText', 'front_text'],
      ['backText', 'back_text'],
      ['hint', 'hint'],
    ]
    for (const [property, column] of fieldCases) {
      const caseBody = assignments.match(new RegExp(`${column}\\s*=\\s*case\\s+id([\\s\\S]*?)\\s+else\\s+${column}\\s+end`, 'i'))?.[1]
      if (!caseBody) continue
      for (const item of caseBody.matchAll(/when\s+'([0-9a-f-]{36})'\s+then\s+'((?:''|[^'])*)'/gi)) {
        const previous = cards.get(item[1])
        if (!previous) continue
        cards.set(item[1], { ...previous, [property]: item[2].replaceAll("''", "'"), lastSource: file })
        sourceFiles.set(item[1], [...(sourceFiles.get(item[1]) ?? []), file])
      }
    }

    const directId = update[2].match(/\bid\s*=\s*'([0-9a-f-]{36})'/i)?.[1]
    const previous = directId ? cards.get(directId) : null
    if (previous) {
      let changed = false
      const next = { ...previous }
      for (const [property, column] of fieldCases) {
        const directValue = assignments.match(new RegExp(`${column}\\s*=\\s*'((?:''|[^'])*)'`, 'i'))?.[1]
        if (directValue === undefined) continue
        next[property] = directValue.replaceAll("''", "'")
        changed = true
      }
      if (changed) {
        next.lastSource = file
        cards.set(directId, next)
        sourceFiles.set(directId, [...(sourceFiles.get(directId) ?? []), file])
      }
    }
  }
}

const publishedCards = [...cards.values()].filter((card) => card.isPublished !== false)
const issues = []
const fronts = new Map()
const stopwords = new Set('a ao aos as como com da das de do dos e em entre essa esse esta este isso na nas no nos o os ou para pela pelo por porque qual quando que se sem ser sua suas um uma'.split(' '))

for (const card of publishedCards) {
  if (!card.lessonSlug) issues.push({ severity: 'error', kind: 'missing_lesson_mapping', id: card.id })
  if (!card.frontText.trim()) issues.push({ severity: 'error', kind: 'empty_front', id: card.id })
  if (!card.backText.trim()) issues.push({ severity: 'error', kind: 'empty_back', id: card.id })
  if (card.backText.length > 600) issues.push({ severity: 'candidate', kind: 'long_answer', id: card.id, length: card.backText.length })
  if (card.frontText.length > 260) issues.push({ severity: 'candidate', kind: 'long_question', id: card.id, length: card.frontText.length })

  const normalizedFront = normalize(card.frontText)
  fronts.set(normalizedFront, [...(fronts.get(normalizedFront) ?? []), card])
}

for (const duplicateCards of fronts.values()) {
  if (duplicateCards.length < 2) continue
  issues.push({
    severity: 'candidate',
    kind: 'exact_duplicate_front',
    ids: duplicateCards.map((card) => card.id),
    lessons: duplicateCards.map((card) => card.lessonSlug),
  })
}

for (const lessonCards of Object.values(Object.groupBy(publishedCards, (card) => card.lessonSlug ?? 'UNMAPPED'))) {
  for (let leftIndex = 0; leftIndex < lessonCards.length; leftIndex += 1) {
    const left = lessonCards[leftIndex]
    const leftWords = new Set(normalize(left.frontText).split(' ').filter((word) => word.length >= 4 && !stopwords.has(word)))
    for (let rightIndex = leftIndex + 1; rightIndex < lessonCards.length; rightIndex += 1) {
      const right = lessonCards[rightIndex]
      const rightWords = new Set(normalize(right.frontText).split(' ').filter((word) => word.length >= 4 && !stopwords.has(word)))
      const intersection = [...leftWords].filter((word) => rightWords.has(word)).length
      const union = new Set([...leftWords, ...rightWords]).size
      const similarity = union === 0 ? 0 : intersection / union
      if (similarity >= 0.85) {
        issues.push({ severity: 'candidate', kind: 'near_duplicate_front', ids: [left.id, right.id], lesson: left.lessonSlug, similarity })
      }
    }
  }
}

const lessonDistribution = Object.entries(Object.groupBy(publishedCards, (card) => card.lessonSlug ?? 'UNMAPPED'))
  .map(([lessonSlug, lessonCards]) => ({ lessonSlug, count: lessonCards.length }))
  .sort((a, b) => a.lessonSlug.localeCompare(b.lessonSlug))

function keywords(value) {
  return new Set(normalize(value).split(' ').filter((word) => word.length >= 5 && !stopwords.has(word)))
}
const lexicalReviewCandidates = publishedCards
  .map((card) => {
    const answerKeywords = keywords(card.backText)
    const corpus = keywords(lessonContent.get(card.lessonSlug) ?? '')
    const matched = [...answerKeywords].filter((word) => corpus.has(word))
    const coverage = answerKeywords.size === 0 ? 1 : matched.length / answerKeywords.size
    return { id: card.id, lessonSlug: card.lessonSlug, coverage, unmatchedKeywords: [...answerKeywords].filter((word) => !corpus.has(word)) }
  })
  .filter((candidate) => candidate.coverage < 0.35)
  .sort((a, b) => a.coverage - b.coverage)

const result = {
  totalFlashcards: publishedCards.length,
  lessonsWithFlashcards: lessonDistribution.length,
  structuralErrors: issues.filter((issue) => issue.severity === 'error'),
  editorialCandidates: issues.filter((issue) => issue.severity === 'candidate'),
  lexicalReviewCandidates,
  distribution: lessonDistribution,
  cards: publishedCards
    .sort((a, b) => `${a.lessonSlug}:${a.id}`.localeCompare(`${b.lessonSlug}:${b.id}`))
    .map((card) => ({ ...card, sourceFiles: sourceFiles.get(card.id) })),
}

const jsonMode = process.argv.includes('--json')
if (jsonMode) {
  console.log(JSON.stringify(result, null, 2))
} else {
  console.log(`Flashcards published: ${result.totalFlashcards}`)
  console.log(`Lessons with Flashcards: ${result.lessonsWithFlashcards}`)
  console.log(`Structural errors: ${result.structuralErrors.length}`)
  console.log(`Editorial candidates: ${result.editorialCandidates.length}`)
  console.log(`Lexical review candidates (non-semantic): ${result.lexicalReviewCandidates.length}`)
  for (const issue of issues) console.log(`${issue.severity.toUpperCase()} ${issue.kind}: ${JSON.stringify(issue)}`)
}

if (result.structuralErrors.length > 0) process.exitCode = 1

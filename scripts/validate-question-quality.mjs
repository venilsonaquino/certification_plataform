import { readFileSync, readdirSync } from 'node:fs'
import { resolve } from 'node:path'

const root = resolve(import.meta.dirname, '..')
const migrationsDirectory = resolve(root, 'supabase', 'migrations')
const throughArgument = process.argv.find((argument) => argument.startsWith('--through='))
const through = throughArgument?.slice('--through='.length) ?? null

function identifier(value) {
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
        cursor += 1
        const cast = source.slice(cursor).match(/^::[a-zA-Z_][a-zA-Z0-9_.]*/)?.[0]
        if (cast) cursor += cast.length
        return { value, cursor }
      } else {
        value += source[cursor]
        cursor += 1
      }
    }
    throw new Error('Unterminated SQL string')
  }
  const end = source.slice(cursor).search(/[,)]/)
  const raw = source.slice(cursor, end === -1 ? source.length : cursor + end).trim()
  const normalized = raw.toLowerCase().replace(/::[a-z_][a-z0-9_.]*$/i, '')
  const value = normalized === 'null' ? null
    : normalized === 'true' ? true
      : normalized === 'false' ? false
        : /^-?\d+$/.test(normalized) ? Number(normalized)
          : raw
  return { value, cursor: end === -1 ? source.length : cursor + end }
}

function parseRows(source) {
  const rows = []
  let cursor = 0
  while (cursor < source.length) {
    if (source[cursor] !== '(') {
      cursor += 1
      continue
    }
    cursor += 1
    const row = []
    while (cursor < source.length) {
      while (/\s/.test(source[cursor] ?? '')) cursor += 1
      if (source[cursor] === ')') {
        rows.push(row)
        cursor += 1
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

function scanUntilSemicolon(sql, start) {
  let cursor = start
  let quoted = false
  let lineComment = false
  let blockComment = false
  while (cursor < sql.length) {
    if (lineComment && /[\r\n]/.test(sql[cursor])) {
      lineComment = false
      cursor += 1
    } else if (blockComment && sql[cursor] === '*' && sql[cursor + 1] === '/') {
      blockComment = false
      cursor += 2
    } else if (lineComment || blockComment) cursor += 1
    else if (!quoted && sql[cursor] === '-' && sql[cursor + 1] === '-') {
      lineComment = true
      cursor += 2
    } else if (!quoted && sql[cursor] === '/' && sql[cursor + 1] === '*') {
      blockComment = true
      cursor += 2
    } else if (quoted && sql[cursor] === "'" && sql[cursor + 1] === "'") cursor += 2
    else if (sql[cursor] === "'") {
      quoted = !quoted
      cursor += 1
    } else if (!quoted && sql[cursor] === ';') return cursor
    else cursor += 1
  }
  return sql.length
}

function insertStatements(sql) {
  const result = []
  const pattern = /insert\s+into\s+([^\s(]+)\s*(?:\(([^)]*?)\))?\s*values\s*/gi
  for (const match of sql.matchAll(pattern)) {
    const start = match.index + match[0].length
    result.push({
      table: identifier(match[1]),
      columns: match[2]?.split(',').map(identifier) ?? null,
      values: sql.slice(start, scanUntilSemicolon(sql, start)),
    })
  }
  return result
}

function tableSchemas(sql) {
  const schemas = new Map()
  const pattern = /create\s+(?:temporary|temp)\s+table\s+([^\s(]+)\s*\(([\s\S]*?)\)\s*on\s+commit/gi
  for (const match of sql.matchAll(pattern)) {
    const columns = match[2].split(',')
      .map((definition) => definition.trim().match(/^"?([a-z_][a-z0-9_]*)"?\s+/i)?.[1]?.toLowerCase())
      .filter(Boolean)
    schemas.set(identifier(match[1]), columns)
  }
  return schemas
}

function cteSeeds(sql) {
  const seeds = []
  const pattern = /(?:with|,)\s*([a-z_][a-z0-9_]*)\s*\(([^)]*)\)\s+as\s*\(\s*values/gi
  for (const match of sql.matchAll(pattern)) {
    const start = match.index + match[0].length
    let cursor = start
    let depth = 1
    let quoted = false
    while (cursor < sql.length && depth > 0) {
      if (quoted && sql[cursor] === "'" && sql[cursor + 1] === "'") cursor += 2
      else if (sql[cursor] === "'") {
        quoted = !quoted
        cursor += 1
      } else {
        if (!quoted && sql[cursor] === '(') depth += 1
        if (!quoted && sql[cursor] === ')') depth -= 1
        cursor += 1
      }
    }
    seeds.push({
      table: identifier(match[1]),
      columns: match[2].split(',').map(identifier),
      values: sql.slice(start, cursor - 1),
    })
  }
  return seeds
}

function words(value) {
  return value.trim().split(/\s+/u).filter(Boolean).length
}

function normalize(value) {
  return value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim()
}

const absoluteLanguagePattern = /\b(?:sempre|nunca|imediatamente|inevitavelmente|obrigatoriamente|exclusivamente|somente|ignorar|nenhuma|todos|sem qualquer|em qualquer situa[cç][aã]o|[uú]nica solu[cç][aã]o|remover completamente)\b/iu

function sentenceLike(value) {
  return /[.!?]$/.test(value.trim()) || value.trim().split(/\s+/u).length >= 9
}

function countEditorialIssues(value) {
  if (value == null) return 0
  let result = value
  let count = 0
  for (const [source, replacement] of [...editorialTerms].sort((left, right) => right[0].length - left[0].length)) {
    const capitalized = source[0].toUpperCase() + source.slice(1)
    const capitalPattern = new RegExp(`(?<![\\p{L}\\p{N}_])${capitalized}(?![\\p{L}\\p{N}_])`, 'gu')
    const lowerPattern = new RegExp(`(?<![\\p{L}\\p{N}_])${source}(?![\\p{L}\\p{N}_])`, 'gu')
    count += result.match(capitalPattern)?.length ?? 0
    result = result.replace(capitalPattern, replacement[0].toUpperCase() + replacement.slice(1))
    count += result.match(lowerPattern)?.length ?? 0
    result = result.replace(lowerPattern, replacement)
  }
  return count
}

function editorialIssueSources(value) {
  if (value == null) return []
  let result = value
  const issues = []
  for (const [source, replacement] of [...editorialTerms].sort((left, right) => right[0].length - left[0].length)) {
    const capitalized = source[0].toUpperCase() + source.slice(1)
    const capitalPattern = new RegExp(`(?<![\\p{L}\\p{N}_])${capitalized}(?![\\p{L}\\p{N}_])`, 'gu')
    const lowerPattern = new RegExp(`(?<![\\p{L}\\p{N}_])${source}(?![\\p{L}\\p{N}_])`, 'gu')
    if (capitalPattern.test(result) || lowerPattern.test(result)) issues.push({ source, replacement })
    result = result.replace(capitalPattern, replacement[0].toUpperCase() + replacement.slice(1))
    result = result.replace(lowerPattern, replacement)
  }
  return issues
}

const questions = new Map()
const options = new Map()
const editorialTerms = new Map()
const lessonDomains = new Map()
let beforeEditorial = null
let beforeRemediation = null
const migrations = readdirSync(migrationsDirectory).filter((file) => file.endsWith('.sql')).sort()
  .filter((file) => !through || file.slice(0, 14) <= through)

function applyRow(columns, values, source) {
  if (columns.length !== values.length) return
  const row = Object.fromEntries(columns.map((column, index) => [column, values[index]]))
  if (typeof row.id !== 'string') return
  if (typeof row.question_text === 'string') {
    const previous = questions.get(row.id) ?? { id: row.id }
    questions.set(row.id, {
      ...previous,
      questionText: row.question_text,
      explanation: row.explanation ?? previous.explanation ?? null,
      difficulty: row.difficulty ?? previous.difficulty ?? null,
      lessonSlug: row.lesson_slug ?? row.slug ?? previous.lessonSlug ?? null,
      isPublished: row.is_published ?? previous.isPublished ?? true,
      source,
    })
  }
  if (typeof row.option_text === 'string') {
    const previous = options.get(row.id) ?? { id: row.id }
    options.set(row.id, {
      ...previous,
      questionId: row.question_id ?? previous.questionId ?? null,
      optionText: row.option_text,
      isCorrect: typeof row.is_correct === 'string' && /^(true|false)$/i.test(row.is_correct)
        ? row.is_correct.toLowerCase() === 'true'
        : row.is_correct ?? previous.isCorrect ?? false,
      explanation: row.explanation ?? previous.explanation ?? null,
      displayOrder: row.display_order ?? previous.displayOrder ?? null,
      source,
    })
  }
}

const editorialMigrationFile = readdirSync(migrationsDirectory).find((file) => file.startsWith('20260831040000'))
if (editorialMigrationFile) {
  const editorialSql = readFileSync(resolve(migrationsDirectory, editorialMigrationFile), 'utf8')
  const editorialSchemas = tableSchemas(editorialSql)
  for (const statement of insertStatements(editorialSql)) {
    const columns = statement.columns ?? editorialSchemas.get(statement.table)
    if (!columns?.includes('source') || !columns.includes('replacement')) continue
    for (const row of parseRows(statement.values)) {
      const values = Object.fromEntries(columns.map((column, index) => [column, row[index]]))
      if (typeof values.source === 'string' && typeof values.replacement === 'string') editorialTerms.set(values.source, values.replacement)
    }
  }
}

const curriculumFile = resolve(migrationsDirectory, '20260822183000_define_complete_az900_curriculum.sql')
const curriculumSql = readFileSync(curriculumFile, 'utf8')
const curriculumSchemas = tableSchemas(curriculumSql)
for (const statement of insertStatements(curriculumSql)) {
  const columns = statement.columns ?? curriculumSchemas.get(statement.table)
  if (!columns?.includes('topic_id') || !columns.includes('slug')) continue
  for (const row of parseRows(statement.values)) {
    const values = Object.fromEntries(columns.map((column, index) => [column, row[index]]))
    const topicId = values.topic_id
    const domain = topicId === '30000000-0000-4000-8000-000000000001' || topicId?.startsWith('31000000-') ? 1
      : topicId?.startsWith('33000000-') ? 3 : 2
    lessonDomains.set(values.slug, domain)
  }
}

for (const file of migrations) {
  const sql = readFileSync(resolve(migrationsDirectory, file), 'utf8')
  if (file.startsWith('20260831040000')) beforeEditorial = {
    questions: new Map([...questions].map(([id, value]) => [id, { ...value }])),
    options: new Map([...options].map(([id, value]) => [id, { ...value }])),
  }
  if (file.startsWith('20260908010000')) beforeRemediation = {
    questions: new Map([...questions].map(([id, value]) => [id, { ...value }])),
    options: new Map([...options].map(([id, value]) => [id, { ...value }])),
  }
  const schemas = tableSchemas(sql)
  for (const statement of [...insertStatements(sql), ...cteSeeds(sql)]) {
    const columns = statement.columns ?? schemas.get(statement.table)
    if (!columns) continue
    for (const row of parseRows(statement.values)) {
      if (columns.includes('source') && columns.includes('replacement')) {
        const values = Object.fromEntries(columns.map((column, index) => [column, row[index]]))
        if (typeof values.source === 'string' && typeof values.replacement === 'string') editorialTerms.set(values.source, values.replacement)
      }
      applyRow(columns, row, file)
    }
  }

  // Some compact enrichment migrations generate option UUIDs around an inline VALUES table.
  for (const inline of sql.matchAll(/from\s*\(\s*values([\s\S]*?)\)\s*values_seed\s*\(([^)]*)\)/gi)) {
    const columns = inline[2].split(',').map(identifier)
    if (!columns.includes('question_id') || !columns.includes('option_text')) continue
    const inlinePreamble = sql.slice(Math.max(0, inline.index - 500), inline.index)
    const inlineIdFormula = inlinePreamble.match(/\('([0-9a-f-]+)'\s*\|\|\s*lpad\(\((\d+)\+row_number\(\)/i)
    let rowIndex = 0
    for (const values of parseRows(inline[1])) {
      rowIndex += 1
      const row = Object.fromEntries(columns.map((column, index) => [column, values[index]]))
      const optionId = inlineIdFormula
        ? `${inlineIdFormula[1]}${String(Number(inlineIdFormula[2]) + rowIndex).padStart(12, '0')}`
        : `${file}:inline:${rowIndex}`
      applyRow(['id', ...columns], [`${file}:inline:${rowIndex}`, ...values], file)
      if (optionId !== `${file}:inline:${rowIndex}`) {
        const generated = options.get(`${file}:inline:${rowIndex}`)
        if (generated) {
          options.delete(`${file}:inline:${rowIndex}`)
          options.set(optionId, { ...generated, id: optionId })
        }
      }
    }
  }

  // Monitoring uses generate_series plus one four-option array per Question.
  const generatedRange = sql.match(/from\s+generate_series\((\d+),(\d+)\)\s+q\(n\)\s+cross\s+join\s+generate_series\(1,4\)/i)
  if (generatedRange) {
    const generatedIdFormula = sql.match(/select\s+\('([0-9a-f-]+)'\s*\|\|\s*lpad\(\(\(q\.n-(\d+)\)\*4\+o\.n\)::text,12,'0'\)\)::uuid/i)
    const generatedOptionId = (questionNumber, optionNumber) => generatedIdFormula
      ? `${generatedIdFormula[1]}${String((questionNumber - Number(generatedIdFormula[2])) * 4 + optionNumber).padStart(12, '0')}`
      : `${file}:generated:${questionNumber}:${optionNumber}`
    const correctCase = sql.match(/o\.n=case\s+q\.n([\s\S]*?)\s+else\s+(\d+)\s+end/i)
    const correctByQuestion = new Map()
    for (const item of correctCase?.[1].matchAll(/when\s+(\d+)\s+then\s+(\d+)/gi) ?? []) correctByQuestion.set(Number(item[1]), Number(item[2]))
    const fallbackCorrect = Number(correctCase?.[2] ?? 1)
    for (const item of sql.matchAll(/when\s+q\.n\s*=\s*(\d+)\s+then\s*\(array\[([^\]]+)\]\)\[o\.n\]/gi)) {
      const questionNumber = Number(item[1])
      const texts = parseRows(`(${item[2]})`)[0] ?? []
      texts.forEach((optionText, index) => applyRow(
        ['id', 'question_id', 'option_text', 'is_correct', 'explanation', 'display_order'],
        [generatedOptionId(questionNumber, index + 1), `68000000-0000-4000-8000-${String(questionNumber).padStart(12, '0')}`, optionText,
          index + 1 === (correctByQuestion.get(questionNumber) ?? fallbackCorrect), null, index + 1], file,
      ))
    }
    const start = Number(generatedRange[1])
    const end = Number(generatedRange[2])
    const elseArray = [...sql.matchAll(/else\s*\(array\[([^\]]+)\]\)\[o\.n\]/gi)].at(-1)
    if (elseArray) {
      const covered = new Set([...sql.matchAll(/when\s+q\.n\s*=\s*(\d+)/gi)].map((item) => Number(item[1])))
      for (let questionNumber = start; questionNumber <= end; questionNumber += 1) {
        if (covered.has(questionNumber)) continue
        const texts = parseRows(`(${elseArray[1]})`)[0] ?? []
        texts.forEach((optionText, index) => applyRow(
          ['id', 'question_id', 'option_text', 'is_correct', 'explanation', 'display_order'],
          [generatedOptionId(questionNumber, index + 1), `68000000-0000-4000-8000-${String(questionNumber).padStart(12, '0')}`, optionText,
            index + 1 === (correctByQuestion.get(questionNumber) ?? fallbackCorrect), null, index + 1], file,
        ))
      }
    }
  }

  for (const update of sql.matchAll(/update\s+public\.questions(?:\s+\w+)?\s+set\s+([\s\S]*?)\s+where\s+([\s\S]*?);/gi)) {
    const directId = update[2].match(/(?:\w+\.)?id\s*=\s*'([0-9a-f-]{36})'/i)?.[1]
    if (!directId || !questions.has(directId)) continue
    const next = { ...questions.get(directId), source: file }
    const questionText = update[1].match(/question_text\s*=\s*'((?:''|[^'])*)'/i)?.[1]
    const explanation = update[1].match(/explanation\s*=\s*'((?:''|[^'])*)'/i)?.[1]
    if (questionText) next.questionText = questionText.replaceAll("''", "'")
    if (explanation) next.explanation = explanation.replaceAll("''", "'")
    questions.set(directId, next)
  }

  for (const update of sql.matchAll(/update\s+public\.question_options(?:\s+\w+)?\s+set\s+([\s\S]*?)\s+where\s+([\s\S]*?);/gi)) {
    const questionId = update[2].match(/question_id\s*=\s*'([0-9a-f-]{36})'/i)?.[1]
    const bulkCorrect = update[1].match(/is_correct\s*=\s*(true|false)/i)?.[1]
    const directOptionId = update[2].match(/(?:^|\W)id\s*=\s*'([0-9a-f-]{36})'/i)?.[1]
    if (questionId && bulkCorrect && !directOptionId) {
      for (const [optionId, option] of options) {
        if (option.questionId === questionId && (!/and\s+is_correct/i.test(update[2]) || option.isCorrect)) {
          options.set(optionId, { ...option, isCorrect: bulkCorrect.toLowerCase() === 'true', source: file })
        }
      }
    }
    const directId = update[2].match(/(?:\w+\.)?id\s*=\s*'([0-9a-f-]{36})'/i)?.[1]
    if (!directId || !options.has(directId)) continue
    const next = { ...options.get(directId), source: file }
    const optionText = update[1].match(/option_text\s*=\s*'((?:''|[^'])*)'/i)?.[1]
    const explanation = update[1].match(/explanation\s*=\s*'((?:''|[^'])*)'/i)?.[1]
    const isCorrect = update[1].match(/is_correct\s*=\s*(true|false)/i)?.[1]
    const displayOrder = update[1].match(/display_order\s*=\s*(\d+)/i)?.[1]
    if (optionText) next.optionText = optionText.replaceAll("''", "'")
    if (explanation) next.explanation = explanation.replaceAll("''", "'")
    if (isCorrect) next.isCorrect = isCorrect.toLowerCase() === 'true'
    if (displayOrder) next.displayOrder = Number(displayOrder)
    options.set(directId, next)
  }

  for (const update of sql.matchAll(/update\s+public\.(questions|question_options)\s+set\s+([\s\S]*?)\s+where\s+([\s\S]*?);/gi)) {
    const collection = update[1].toLowerCase() === 'questions' ? questions : options
    const mappings = update[1].toLowerCase() === 'questions'
      ? [['questionText', 'question_text'], ['explanation', 'explanation']]
      : [['optionText', 'option_text'], ['explanation', 'explanation'], ['displayOrder', 'display_order']]
    for (const [property, column] of mappings) {
      const body = update[2].match(new RegExp(`${column}\\s*=\\s*case(?:\\s+id)?([\\s\\S]*?)(?:else\\s+${column}\\s+)?end`, 'i'))?.[1]
      if (!body) continue
      for (const item of body.matchAll(/when\s+'([0-9a-f-]{36})'\s+then\s+'?((?:''|[^'\n])*)'?/gi)) {
        const previous = collection.get(item[1])
        if (!previous) continue
        const raw = property === 'displayOrder' ? Number(item[2].trim()) : item[2].replaceAll("''", "'").trim()
        collection.set(item[1], { ...previous, [property]: raw, source: file })
      }
    }
  }

  for (const [collection, property, column] of [
    [questions, 'questionText', 'question_text'],
    [questions, 'explanation', 'explanation'],
    [options, 'optionText', 'option_text'],
    [options, 'explanation', 'explanation'],
  ]) {
    for (const block of sql.matchAll(new RegExp(`${column}\\s*=\\s*case\\s+id([\\s\\S]*?)\\s+end`, 'gi'))) {
      for (const item of block[1].matchAll(/when\s+'([0-9a-f-]{36})'\s+then\s+'((?:''|[^'])*)'/gi)) {
        const previous = collection.get(item[1])
        if (previous) collection.set(item[1], { ...previous, [property]: item[2].replaceAll("''", "'"), source: file })
      }
    }
  }

  const sourceLessonSlugs = [...sql.matchAll(/lesson\.slug\s*=\s*'([^']+)'/gi)].map((match) => match[1])
  if (new Set(sourceLessonSlugs).size === 1) {
    for (const [id, question] of questions) {
      if (!question.lessonSlug && question.source === file) questions.set(id, { ...question, lessonSlug: sourceLessonSlugs[0] })
    }
  }

  if (file.startsWith('20260830061000')) {
    for (const question of questions.values()) {
      const questionOptions = [...options.values()].filter((option) => option.questionId === question.id)
      question.mockEligible = question.isPublished !== false
        && question.questionText.trim().length >= 55
        && (question.explanation?.trim().length ?? 0) >= 80
        && questionOptions.length === 4
        && questionOptions.filter((option) => option.isCorrect).length === 1
        && new Set(questionOptions.map((option) => normalize(option.optionText))).size === 4
        && questionOptions.every((option) => option.optionText.trim().length >= 3)
    }
  }

  if (file.startsWith('20260831040000')) {
    const normalizeEditorial = (value) => {
      if (value == null) return value
      let result = value
      for (const [source, replacement] of [...editorialTerms].sort((left, right) => right[0].length - left[0].length)) {
        const capitalized = source[0].toUpperCase() + source.slice(1)
        const capitalizedReplacement = replacement[0].toUpperCase() + replacement.slice(1)
        result = result.replace(new RegExp(`(?<![\\p{L}\\p{N}_])${capitalized}(?![\\p{L}\\p{N}_])`, 'gu'), capitalizedReplacement)
        result = result.replace(new RegExp(`(?<![\\p{L}\\p{N}_])${source}(?![\\p{L}\\p{N}_])`, 'gu'), replacement)
      }
      return result
    }
    for (const [id, question] of questions) questions.set(id, {
      ...question,
      questionText: normalizeEditorial(question.questionText),
      explanation: normalizeEditorial(question.explanation),
      source: file,
    })
    for (const [id, option] of options) {
      let optionText = normalizeEditorial(option.optionText)
      if (option.isCorrect) optionText = optionText.replace(/,\s+(pois|porque|já que|permitindo|representando|atendendo|reduzindo|mantendo|considerando|restando|confirmando|determinando|executando|funcionando|incluindo|oferecendo|evitando|fornecendo|usando|utilizando|deixando|garantindo|ajudando|possibilitando|como)\s+.*$/iu, '')
      options.set(id, { ...option, optionText, explanation: normalizeEditorial(option.explanation), source: file })
    }
    const orderedQuestions = [...questions.values()].filter((question) => question.isPublished !== false).sort((left, right) => left.id.localeCompare(right.id))
    orderedQuestions.forEach((question, questionIndex) => {
      const targetCorrect = questionIndex % 4 + 1
      const questionOptions = [...options.values()].filter((option) => option.questionId === question.id)
        .sort((left, right) => left.displayOrder - right.displayOrder)
      const distractors = questionOptions.filter((option) => !option.isCorrect)
      let distractorIndex = 0
      for (let position = 1; position <= 4; position += 1) {
        const option = position === targetCorrect ? questionOptions.find((item) => item.isCorrect) : distractors[distractorIndex++]
        if (option) options.set(option.id, { ...option, displayOrder: position, source: file })
      }
    })
  }
}

const published = [...questions.values()].filter((question) => question.isPublished !== false)
for (const question of published) {
  question.options = [...options.values()].filter((option) => option.questionId === question.id)
    .sort((left, right) => left.displayOrder - right.displayOrder)
  const numericQuestion = question.id.startsWith('68000000-') ? Number(question.id.slice(-12)) : null
  question.domain = lessonDomains.get(question.lessonSlug)
    ?? (numericQuestion ? (numericQuestion <= 118 ? 2 : 3) : null)
}

const structuralErrors = []
const candidates = []
const automaticFlagCounts = new Map()
const distribution = { A: 0, B: 0, C: 0, D: 0 }
let correctLongest = 0
let correctOverRatio = 0
for (const question of published) {
  question.automaticFlags = []
  const correct = question.options.filter((option) => option.isCorrect)
  const distinct = new Set(question.options.map((option) => normalize(option.optionText)))
  if (question.options.length !== 4) structuralErrors.push({ id: question.id, kind: 'option_count', count: question.options.length })
  if (correct.length !== 1) structuralErrors.push({ id: question.id, kind: 'correct_count', count: correct.length })
  if (distinct.size !== question.options.length) structuralErrors.push({ id: question.id, kind: 'duplicate_options' })
  if (question.options.some((option) => !option.optionText?.trim())) structuralErrors.push({ id: question.id, kind: 'empty_option' })
  if (!question.explanation?.trim()) structuralErrors.push({ id: question.id, kind: 'empty_explanation' })
  if (question.questionText.length < 35) {
    candidates.push({ id: question.id, kind: 'short_stem', length: question.questionText.length })
    question.automaticFlags.push('SHORT_STEM_CANDIDATE')
  }
  if ((question.explanation?.length ?? 0) < 80) {
    candidates.push({ id: question.id, kind: 'short_explanation', length: question.explanation?.length ?? 0 })
    question.automaticFlags.push('WEAK_EXPLANATION_CANDIDATE')
  }
  const absoluteDistractors = question.options.filter((option) => !option.isCorrect && absoluteLanguagePattern.test(option.optionText))
  if (absoluteDistractors.length > 0) {
    question.automaticFlags.push('ABSOLUTE_LANGUAGE_CANDIDATE')
    candidates.push({ id: question.id, kind: 'absolute_language', optionIds: absoluteDistractors.map((option) => option.id) })
  }
  if (correct.length !== 1 || question.options.length < 2) continue
  const correctOption = correct[0]
  const distractors = question.options.filter((option) => !option.isCorrect)
  const distractorAverage = distractors.reduce((sum, option) => sum + option.optionText.length, 0) / distractors.length
  const distractorAverageWords = distractors.reduce((sum, option) => sum + words(option.optionText), 0) / distractors.length
  const maxDistractor = Math.max(...distractors.map((option) => option.optionText.length))
  const maxDistractorWords = Math.max(...distractors.map((option) => words(option.optionText)))
  const ratio = correctOption.optionText.length / distractorAverage
  const isLongest = correctOption.optionText.length > maxDistractor
  if (isLongest) correctLongest += 1
  if (ratio > 1.5) correctOverRatio += 1
  if (isLongest) candidates.push({ id: question.id, kind: 'correct_longest', ratio: Number(ratio.toFixed(2)) })
  if (ratio > 1.5) {
    candidates.push({ id: question.id, kind: 'correct_over_1_5x', ratio: Number(ratio.toFixed(2)) })
    question.automaticFlags.push('LENGTH_BIAS_CANDIDATE')
  }
  const sentenceDistractors = distractors.filter((option) => sentenceLike(option.optionText)).length
  if (sentenceLike(correctOption.optionText) && sentenceDistractors === 0) {
    candidates.push({ id: question.id, kind: 'structural_mismatch' })
    question.automaticFlags.push('STRUCTURAL_BIAS_CANDIDATE')
  }
  distribution[['A', 'B', 'C', 'D'][Math.max(0, correctOption.displayOrder - 1)] ?? 'A'] += 1
  question.lengthAnalysis = {
    correctCharacters: correctOption.optionText.length,
    correctWords: words(correctOption.optionText),
    distractorAverageCharacters: Number(distractorAverage.toFixed(2)),
    distractorAverageWords: Number(distractorAverageWords.toFixed(2)),
    longestDistractorCharacters: maxDistractor,
    longestDistractorWords: maxDistractorWords,
    ratio: Number(ratio.toFixed(2)),
    correctIsLongest: isLongest,
  }
  for (const flag of question.automaticFlags) automaticFlagCounts.set(flag, (automaticFlagCounts.get(flag) ?? 0) + 1)
}

const mockEligible = published.filter((question) => question.mockEligible)

const mockIneligible = published.filter((question) => !mockEligible.includes(question)).map((question) => ({
  id: question.id,
  stem: question.questionText.length,
  explanation: question.explanation?.length ?? 0,
  optionCount: question.options.length,
}))

function poolMetrics(pool) {
  const longest = pool.filter((question) => question.lengthAnalysis?.correctIsLongest).length
  const ratio = pool.filter((question) => question.lengthAnalysis?.ratio > 1.5).length
  const positions = { A: 0, B: 0, C: 0, D: 0 }
  for (const question of pool) {
    const correct = question.options.find((option) => option.isCorrect)
    if (correct) positions[['A', 'B', 'C', 'D'][correct.displayOrder - 1]] += 1
  }
  return {
    total: pool.length,
    correctLongest: longest,
    correctLongestPercentage: Number((longest / pool.length * 100).toFixed(2)),
    correctOver1_5x: ratio,
    positions,
  }
}

const scenarioPattern = /(empresa|organiza[cç][aã]o|equipe|cliente|aplica[cç][aã]o|carga de trabalho|requisito|precisa|deseja|usu[aá]rio|administrador|cen[aá]rio)/iu
const classification = {
  A: mockEligible.filter((question) => scenarioPattern.test(question.questionText) && ['medium', 'hard'].includes(question.difficulty)).length,
  B: mockEligible.filter((question) => !(scenarioPattern.test(question.questionText) && ['medium', 'hard'].includes(question.difficulty))).length,
  C: published.length - mockEligible.length,
  D: structuralErrors.length > 0 ? new Set(structuralErrors.map((error) => error.id)).size : 0,
}
const domainMetrics = Object.fromEntries([1, 2, 3].map((domain) => [domain, poolMetrics(published.filter((question) => question.domain === domain))]))
const changed = beforeEditorial ? {
  questions: [...questions].filter(([id, question]) => {
    const before = beforeEditorial.questions.get(id)
    return before && (before.questionText !== question.questionText || before.explanation !== question.explanation)
  }).length,
  questionTexts: [...questions].filter(([id, question]) => beforeEditorial.questions.get(id)?.questionText !== question.questionText).length,
  options: [...options].filter(([id, option]) => {
    const before = beforeEditorial.options.get(id)
    return before && (before.optionText !== option.optionText || before.displayOrder !== option.displayOrder)
  }).length,
  optionTexts: [...options].filter(([id, option]) => beforeEditorial.options.get(id)?.optionText !== option.optionText).length,
  explanations: [...questions].filter(([id, question]) => beforeEditorial.questions.get(id)?.explanation !== question.explanation).length
    + [...options].filter(([id, option]) => beforeEditorial.options.get(id)?.explanation !== option.explanation).length,
} : null

function contentChangesSince(snapshot) {
  if (!snapshot) return null
  return {
    questions: [...questions].filter(([id, question]) => {
      const before = snapshot.questions.get(id)
      return before && (before.questionText !== question.questionText || before.explanation !== question.explanation)
    }).length,
    questionTexts: [...questions].filter(([id, question]) => snapshot.questions.get(id)?.questionText !== question.questionText).length,
    options: [...options].filter(([id, option]) => {
      const before = snapshot.options.get(id)
      return before && (before.optionText !== option.optionText || before.explanation !== option.explanation)
    }).length,
    optionTexts: [...options].filter(([id, option]) => snapshot.options.get(id)?.optionText !== option.optionText).length,
    answerKeys: [...options].filter(([id, option]) => snapshot.options.get(id)?.isCorrect !== option.isCorrect).length,
    optionOrders: [...options].filter(([id, option]) => snapshot.options.get(id)?.displayOrder !== option.displayOrder).length,
  }
}
const remediationChanged = contentChangesSince(beforeRemediation)

const portugueseIssueDetails = []
for (const question of published) {
  for (const [field, value] of [['question_text', question.questionText], ['explanation', question.explanation]]) {
    for (const issue of editorialIssueSources(value)) portugueseIssueDetails.push({ questionId: question.id, field, ...issue })
  }
  for (const option of question.options) {
    for (const [field, value] of [['option_text', option.optionText], ['option_explanation', option.explanation]]) {
      for (const issue of editorialIssueSources(value)) portugueseIssueDetails.push({ questionId: question.id, optionId: option.id, field, ...issue })
    }
  }
}

const result = {
  through: through ?? migrations.at(-1)?.slice(0, 14),
  totalQuestions: published.length,
  totalOptions: published.reduce((sum, question) => sum + question.options.length, 0),
  mockEligible: mockEligible.length,
  mockIneligible,
  correctLongest: { count: correctLongest, percentage: Number((correctLongest / published.length * 100).toFixed(2)) },
  correctOver1_5x: { count: correctOverRatio, percentage: Number((correctOverRatio / published.length * 100).toFixed(2)) },
  correctOptionDistribution: distribution,
  lengthAnalysis: {
    averageCorrectCharacters: Number((published.reduce((sum, question) => sum + (question.lengthAnalysis?.correctCharacters ?? 0), 0) / published.length).toFixed(2)),
    averageCorrectWords: Number((published.reduce((sum, question) => sum + (question.lengthAnalysis?.correctWords ?? 0), 0) / published.length).toFixed(2)),
    averageDistractorCharacters: Number((published.reduce((sum, question) => sum + (question.lengthAnalysis?.distractorAverageCharacters ?? 0), 0) / published.length).toFixed(2)),
    averageDistractorWords: Number((published.reduce((sum, question) => sum + (question.lengthAnalysis?.distractorAverageWords ?? 0), 0) / published.length).toFixed(2)),
  },
  structuralErrors,
  editorialCandidates: candidates,
  automaticTriage: {
    warning: 'Candidate flags are mechanical triage only and are not an A/B/C/D semantic verdict.',
    flagCounts: Object.fromEntries([...automaticFlagCounts].sort(([left], [right]) => left.localeCompare(right))),
    questionsWithFlags: published.filter((question) => question.automaticFlags.length > 0).length,
  },
  portugueseIssueOccurrences: published.reduce((questionTotal, question) => questionTotal
    + countEditorialIssues(question.questionText)
    + countEditorialIssues(question.explanation)
    + question.options.reduce((optionTotal, option) => optionTotal
      + countEditorialIssues(option.optionText)
      + countEditorialIssues(option.explanation), 0), 0),
  portugueseIssueDetails,
  classification,
  legacyEligibilityHeuristic: {
    ...classification,
    warning: 'Legacy compatibility metric only: A/B/C/D here is not a semantic quality classification.',
  },
  pools: { topicCheckpoint: poolMetrics(published), mockEligible: poolMetrics(mockEligible), domains: domainMetrics },
  changed,
  remediationChanged,
  questions: published.sort((left, right) => left.id.localeCompare(right.id)),
}

if (process.argv.includes('--json')) console.log(JSON.stringify(result, null, 2))
else {
  console.log(`Questions published: ${result.totalQuestions}`)
  console.log(`Options: ${result.totalOptions}`)
  console.log(`Mock eligible: ${result.mockEligible}`)
  console.log(`Correct is longest: ${correctLongest}/${published.length} (${result.correctLongest.percentage}%)`)
  console.log(`Correct > 1.5x distractor average: ${correctOverRatio}/${published.length} (${result.correctOver1_5x.percentage}%)`)
  console.log(`Correct position: ${JSON.stringify(distribution)}`)
  console.log(`Length averages: ${JSON.stringify(result.lengthAnalysis)}`)
  console.log(`Structural errors: ${structuralErrors.length}`)
  console.log(`Editorial candidates: ${candidates.length}`)
  console.log(`Automatic triage only: ${JSON.stringify(result.automaticTriage.flagCounts)} (${result.automaticTriage.questionsWithFlags} Questions)`)
  console.log(`Portuguese issue occurrences: ${result.portugueseIssueOccurrences}`)
  console.log(`Legacy eligibility heuristic (not semantic A/B/C/D): ${JSON.stringify(classification)}`)
  console.log(`Domain metrics: ${JSON.stringify(domainMetrics)}`)
  console.log(`Mock metrics: ${JSON.stringify(result.pools.mockEligible)}`)
  if (changed) console.log(`Changed: ${JSON.stringify(changed)}`)
  if (remediationChanged) console.log(`Remediation changed: ${JSON.stringify(remediationChanged)}`)
  if (process.argv.includes('--details')) {
    for (const error of structuralErrors) console.log(`ERROR ${JSON.stringify(error)}`)
    for (const item of mockIneligible) console.log(`STUDY_ONLY ${JSON.stringify(item)}`)
  }
  if (process.argv.includes('--ratio-details')) {
    for (const question of published.filter((item) => item.lengthAnalysis?.ratio > 1.5)) {
      console.log(`RATIO ${question.id} ${question.lengthAnalysis.ratio} | ${question.questionText}`)
      for (const option of question.options) console.log(`  ${option.isCorrect ? '*' : '-'} ${option.optionText}`)
    }
  }
  if (process.argv.includes('--mapping-details')) {
    for (const question of published.filter((item) => !item.domain)) console.log(`UNMAPPED ${question.id} ${question.lessonSlug} ${question.source}`)
  }
  if (process.argv.includes('--portuguese-details')) {
    for (const issue of portugueseIssueDetails) console.log(`PORTUGUESE ${JSON.stringify(issue)}`)
  }
  if (process.argv.includes('--weak-details')) {
    const weakPattern = /(cor do|logotipo|editor de imagens|mensagens instant|streaming de v[ií]deo|design gr[aá]fico|videoconfer[eê]ncia|escolher aleatori|prefer[eê]ncia pessoal|nome de exibi[cç][aã]o|n[uú]mero de administradores|contratar uma equipe para verificar manualmente)/iu
    for (const question of published) for (const option of question.options) {
      if (weakPattern.test(option.optionText)) console.log(`WEAK ${option.id} ${question.id} | ${option.optionText}`)
    }
  }
}

if (structuralErrors.length > 0) process.exitCode = 1

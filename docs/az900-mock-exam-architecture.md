# AZ-900 Mock Exam Architecture

Architecture decision record prepared in Stage 11.1 on August 29, 2026. This document defines an **AZ-900 Practice Mock Exam**. It must not be presented as an official Microsoft exam simulator or as an exact reproduction of the official exam.

## Goals

- Run one complete practice session containing Questions from the whole AZ-900 curriculum.
- Preserve the official Domain weight ranges as a reference for our 40-Question Mock.
- Cover Topics intentionally instead of sampling the global pool uniformly.
- Freeze what the learner actually received in each historical attempt.
- Support answer persistence, refresh/resume, final submission, result, review and retakes.
- Keep attempts, answers, scores and history private to their owner.
- Leave a safe path for a future server-authoritative timer without implementing it now.
- Minimize overlap between retakes while preserving Domain, Topic and difficulty constraints.

## Non-Goals

- Reproduce the exact number of Questions, timing, interface or scaled score of the Microsoft exam.
- Implement Mock Exams, timer, readiness score, dashboard changes or automatic study recommendations in Stage 11.1.
- Change Lesson Quiz, Topic Quiz, Review, Flashcard scheduling or Lesson progress.
- Import exam dumps, leaked Questions or new curricular content.
- Promise that a Practice Score maps to the official 1–1,000 scaled score.

## Existing Quiz Architecture

There is no repository layer. React hooks call services, and services call Supabase tables/RPCs directly.

```text
LessonQuizPage / TopicQuizPage / ReviewQuizPage
                    ↓
 useLessonQuiz / useTopicQuiz / useReviewQuiz
                    ↓
               useQuizAttempt
                    ↓
                quizService
                    ↓
 Supabase tables + SECURITY DEFINER RPC functions
```

### React and TypeScript

| Concern | Current implementation |
| --- | --- |
| Lesson execution | `LessonQuizPage` → `useLessonQuiz` |
| Topic execution | `TopicQuizPage` → `useTopicQuiz` |
| Error Review execution | `ReviewQuizPage` → `useReviewQuiz` |
| Shared state machine | `useQuizAttempt` loads/resumes, tracks current Question, submits and restarts |
| Question UI | `QuizQuestionCard` selects one option, submits it and immediately renders correctness/explanation |
| Result UI | `QuizResult`, `TopicQuizResult`, `ReviewQuizResult` |
| Data access | `quizService.ts` and `reviewService.ts` |
| Static types | `types/quiz.ts`, `types/question.ts`, `types/database.ts` |
| Runtime schemas | None for quiz payloads; current services use handwritten mappers without Zod validation |
| Existing Mock route | `/:certificationCode/exams`; `MockExamsPage` is only a heading placeholder |

`QuizQuestionCard` and `useQuizAttempt` are study-quiz abstractions: they reveal feedback immediately and advance only after an answer is confirmed. They should not be reused unchanged for Mock execution. Styling and small presentation primitives can be extracted later, but the Mock needs a separate interaction state machine.

### Supabase data path

The current quiz implementation uses:

- `questions` and `question_options` as the canonical Question bank;
- `question_options_public` to expose option text without correctness;
- `quiz_attempts` for Lesson, Topic and Review attempts;
- `quiz_attempt_questions` for the selected Question IDs and display order;
- `quiz_answers` for the chosen option and the correctness calculated when answering.

Current `quiz_attempts.quiz_type` accepts `lesson`, `topic` and `review`. Status accepts only `in_progress` and `completed`; `total_questions` is constrained to 1–10. Partial unique indexes allow one active Lesson attempt per user/Lesson, one active Topic attempt per user/Topic and one active Review attempt per user/certification.

Writes occur through `SECURITY DEFINER` RPCs. Authenticated users receive read-only access to their own attempt/history rows through RLS. Direct access does not expose `questions.explanation`, `question_options.is_correct` or option explanations.

### Lesson Quiz

`start_lesson_quiz(uuid)` resumes the active attempt or selects the first five published `single_choice` Questions ordered by `display_order` and UUID. It does not currently rotate Lesson Quiz retakes.

`submit_quiz_answer(uuid, uuid, uuid)` locks the owned attempt, validates membership and option ownership, inserts one immutable answer and immediately returns correctness plus explanations. When all Questions have answers, it sets `completed_at`, `correct_answers` and `score_percentage`.

### Topic Quiz

`start_topic_quiz(uuid)` resumes an active attempt or creates a ten-Question selection. Since Stage 10.3, it uses history for the authenticated user and Topic, targets 3 easy / 5 medium / 2 hard, balances Lessons, prioritizes unseen Questions, avoids the immediately previous attempt and then uses least-recently-seen order.

`get_quiz_lesson_performance(uuid)` aggregates Topic/Review results by Lesson. `get_topic_quiz_summaries(uuid)` returns availability, active progress and last score for each Topic.

### Review and retakes

`get_user_question_stats(uuid)` aggregates the current user's history from `quiz_answers`. `start_review_quiz(uuid, uuid)` selects Questions with prior errors, prioritizes recent/repeated errors and rotates the lower-priority tail. Review uses the same attempt/question/answer tables and immediate-feedback UI.

RLS and all RPCs use `auth.uid()`. A user's history does not influence another user's selection.

### Current scoring and persistence

Current scoring is `correct_answers / total_questions × 100`, rounded to two decimals. An attempt completes automatically only after every Question has an answer. There is no unanswered submission, explicit abandon, expiration, timer or pause concept.

The current attempt stores Question ID and order, but not Question text, options, correct option or explanation snapshots. Foreign keys prevent deletion of referenced Questions/options, but later edits change how historical attempts render. This is insufficient for Mock history.

## Recommended Data Model

### Decision: hybrid architecture with dedicated Mock tables

Use dedicated Mock attempt tables while continuing to use the canonical `questions`/`question_options` catalog as the selection source. Reuse visual primitives, Supabase conventions and the ranking principles from Topic Quiz, but do not add `mock` to the current `quiz_attempts` flow.

| Option | Benefits | Problems | Decision |
| --- | --- | --- | --- |
| A — add `quiz_type = mock` | Reuses current RPCs and UI quickly | Current 10-item limit, two-state lifecycle, immediate feedback, automatic all-answered completion and no snapshot/timer support; changes risk Lesson/Topic regressions | Reject |
| B — fully isolated Mock system | Strong history and lifecycle isolation | Can duplicate conventions and selection logic unnecessarily | Use for persistence, not as a separate Question bank |
| C — hybrid | Dedicated attempt lifecycle/snapshots with canonical Questions and shared selection principles | Requires explicit contracts and more initial design | **Recommended** |

Recommended future tables:

### `mock_exam_attempts`

Conceptual fields:

- identity: `id`, `user_id`, `certification_id`;
- lifecycle: `status`, `started_at`, `submitted_at`, `abandoned_at`, `expires_at`;
- timing: nullable `time_limit_seconds`, finalized `elapsed_seconds`;
- totals: `total_questions`, `answered_questions`, `correct_answers`, `unanswered_questions`, `practice_score_percentage`;
- reproducibility: `selection_policy_version`, `domain_allocation`, `difficulty_allocation`, optional server-generated selection seed;
- audit: `created_at`, `updated_at`, `last_activity_at`.

Use a partial unique index for one `in_progress` Mock per user/certification. Start/resume must use a transaction and advisory lock or equivalent conflict-safe pattern.

### `mock_exam_attempt_questions`

Conceptual fields:

- `id`, `attempt_id`, canonical `question_id`, `display_order`;
- frozen `domain_id`, `topic_id`, `lesson_id` and their display labels/slugs where needed for historical breakdown;
- `difficulty_snapshot`, `question_text_snapshot`, `question_type_snapshot`;
- frozen option payload and answer key payload;
- `question_source_updated_at` and `snapshot_schema_version`.

The full snapshot must not be directly selectable by the client while an attempt is active because it contains the answer key. A sanitized RPC should return prompt and option text only. A separate completed-review RPC can return the answer key and explanations after finalization. Column-level grants or a split private answer-key table are acceptable implementation variants, but a plain client-readable JSON containing `isCorrect` is not.

### `mock_exam_answers`

Conceptual fields:

- `id`, `attempt_id`, `attempt_question_id`;
- selected snapshot option key/source option ID;
- `answered_at`, `updated_at`;
- server-calculated `is_correct`, populated or disclosed only at finalization.

Allow idempotent upsert while the attempt is `in_progress` so the user can change an answer before submission. The RPC must return only save acknowledgement and progress, never correctness.

## Question Selection

Selection should run server-side in one transaction:

```text
Eligible published AZ-900 Questions
                ↓
Domain allocation (11 / 15 / 14)
                ↓
Near-even Topic allocation inside each Domain
                ↓
Difficulty targets (12 / 20 / 8 globally)
                ↓
Lesson concentration guard where possible
                ↓
Mock history: unseen → outside last Mock → least recently seen
                ↓
Deterministic seeded tie-break
                ↓
Freeze 40 Question snapshots atomically
```

The authoritative selector should be a private PostgreSQL function called by the start RPC. The current Topic selector is also PostgreSQL, not a TypeScript engine. Stage 11.3 should first copy its proven ranking principles into a Mock-specific selector. Extracting a generic shared SQL selection kernel should happen only after parity tests prove that Topic Quiz behavior will not change.

The selector inputs should conceptually include certification, user, target size, Domain quotas, Topic policy, difficulty quotas, previous Mock attempt and selection policy version. Selection must be deterministic under a test seed; production can derive its seed server-side from the attempt ID.

## Domain Weighting

The official current ranges are:

- Domain 1 — Describe cloud concepts: 25–30%;
- Domain 2 — Describe Azure architecture and services: 35–40%;
- Domain 3 — Describe Azure management and governance: 30–35%.

For the product's standard 40-Question practice Mock, use this fixed V1 profile:

| Domain | Count | Mock percentage | Official range |
| --- | ---: | ---: | ---: |
| Domain 1 | 11 | 27.5% | 25–30% |
| Domain 2 | 15 | 37.5% | 35–40% |
| Domain 3 | 14 | 35.0% | 30–35% |

This is our practice configuration. Product text must not imply that the official exam always contains exactly 40 Questions or uses these exact counts.

Store the actual allocation and policy version on each attempt so future configuration changes do not reinterpret history.

## Topic Balancing

Every current Topic should appear when its pool is healthy. Use a near-even minimum allocation, with extra slots rotating between Topics across attempts:

- Domain 1, 11 slots across 3 Topics: 4 / 4 / 3;
- Domain 2, 15 slots across 5 Topics: 3 / 3 / 3 / 3 / 3;
- Domain 3, 14 slots across 4 Topics: 4 / 4 / 3 / 3.

The Topic receiving an extra slot should not be permanently fixed. Prefer the Topic least represented in recent Mock history, then use a deterministic tie-break. Within each Topic, penalize concentration in a single Lesson when alternative eligible Questions satisfy the same constraints.

If a Topic cell cannot satisfy its assigned difficulty, spill over in this order:

1. another difficulty in the same Topic;
2. another Topic in the same Domain that is currently under target;
3. never cross Domain quotas unless the whole Domain pool is insufficient.

Record any fallback allocation on the attempt for diagnostics.

## Difficulty Balancing

The current bank has 178 easy, 234 medium and 100 hard Questions: 34.8% / 45.7% / 19.5%. Topic Quiz already uses 30% / 50% / 20%.

Use **12 easy / 20 medium / 8 hard** for a standard Mock: 30% / 50% / 20%. This matches the proven project baseline, avoids an artificially hard Fundamentals Mock and is fully supported by every Domain.

Recommended per-Domain targets:

| Domain | Easy | Medium | Hard | Total |
| --- | ---: | ---: | ---: | ---: |
| Domain 1 | 3 | 6 | 2 | 11 |
| Domain 2 | 5 | 7 | 3 | 15 |
| Domain 3 | 4 | 7 | 3 | 14 |
| **Mock** | **12** | **20** | **8** | **40** |

Difficulty is subordinate to Domain and reasonable Topic coverage. A documented one-item fallback is preferable to dropping a Topic or violating Domain weights.

## Retake Rotation

Mock rotation should initially consider Mock history only, keeping it independent from Lesson/Topic study behavior.

Within each Domain/Topic/difficulty allocation:

1. Questions never used in a completed/abandoned Mock for that user;
2. Questions not present in the immediately previous Mock;
3. least-recently-seen Questions;
4. Questions from the immediately previous Mock only when required;
5. deterministic seeded tie-break for equivalent candidates.

Never block a retake when the pool is exhausted. Preserve Domain, Topic and difficulty constraints and choose the mathematically smallest feasible overlap. Persist the policy version and actual overlap for future analytics.

## Attempt Lifecycle

Recommended states:

- `in_progress`: accepts answer upserts and can be resumed;
- `completed`: immutable final result and review available;
- `abandoned`: explicitly ended without a score; remains available in history if product wants to show it;
- `expired`: reserved for the timer stage when the server deadline passes.

Recommended flow:

```text
Start or Resume
      ↓
Create attempt + select and freeze 40 Questions atomically
      ↓
Navigate and upsert answers without feedback
      ↓
Submit confirmation
      ↓
Server locks attempt, evaluates snapshots and finalizes totals
      ↓
Completed result and review
```

- Browser close, reload or temporary connection loss: keep `in_progress`; reopening resumes the same fixed Questions and saved answers.
- Duplicate answer saves: idempotent upsert.
- Duplicate final submission: return the already finalized result.
- Starting while an active attempt exists: resume it, do not silently create another.
- Abandon: explicit action with confirmation; it does not modify Lesson progress or Flashcards.
- Future timer expiry: server finalizes or marks `expired` according to the timer policy; the client cannot extend the deadline.

## Question Snapshot Strategy

The current dynamic-reference model is not sufficient for Mock history. Keep `question_id` for rotation and analytics, but freeze:

- Question text and type;
- Domain, Topic, Lesson and difficulty;
- every option's stable snapshot key, source ID, text and explanation;
- correct option key;
- Question explanation;
- source `updated_at` and snapshot schema version.

Snapshots protect historical review when editors later modify Question text, reassociate curriculum hierarchy, rewrite explanations or change options. Canonical foreign keys should use `ON DELETE RESTRICT` or an archival policy, but the snapshot remains the historical source of truth.

Security boundary: active-attempt payloads must omit correct option and explanations. Only server-side scoring and completed-review RPCs may access/return them.

## Scoring

The product score is:

```text
Practice Score = correct / 40 × 100
```

Unanswered Questions count as not correct at final submission. Show both `32 / 40 correct` and `80% Practice Score`, plus incorrect and unanswered totals.

Do not calculate or display a simulated Microsoft scaled score. Do not state or imply `70% = 700/1000`. Labels such as Needs Review, Developing, Strong or Mock Ready belong to a later readiness design and are not part of the first scoring model.

## Timer Support

Stage 11.2 should make the data model timer-ready but leave time limits nullable and disabled.

Recommended server-owned fields:

- `started_at`;
- nullable `time_limit_seconds`;
- nullable `expires_at`, calculated once from server time;
- `submitted_at`;
- finalized `elapsed_seconds`;
- `last_activity_at` for resume/history diagnostics.

Time continues while the browser is closed; V1 should not support pause. Refresh calculates remaining time from server `expires_at`, not a reset client counter. The submit/save RPCs must reject or finalize work past the deadline once timer behavior is enabled.

## Review

After completion, return:

- correct, incorrect and unanswered totals;
- Practice Score;
- Domain breakdown;
- Topic breakdown;
- optional difficulty breakdown;
- ordered Question review containing prompt, selected answer or unanswered marker, correct answer, explanation, Lesson, Topic and Domain.

The active execution endpoint must not return these fields. A future `Review this lesson` link can use the frozen Lesson slug when the current Lesson still exists, with a safe fallback if it does not.

## Security / RLS

Enable RLS on every Mock table from its creation migration.

Conceptual policies:

- user can read only `mock_exam_attempts` where `user_id = auth.uid()`;
- attempt Question and answer access must require ownership through the parent attempt;
- no direct client insert/update/delete grants on attempts, snapshots or scoring fields;
- mutations occur through narrowly granted `SECURITY DEFINER` RPCs with `search_path = ''` and explicit ownership/status checks;
- active-attempt read RPC returns sanitized snapshots only;
- completed-review RPC requires owned status `completed` before returning answer keys;
- history/summary RPCs filter by `auth.uid()` internally;
- `anon` receives no Mock table or RPC access.

Required isolation tests must cover attempts, Question snapshots, answer rows, scores, breakdowns, active resume and history. RLS alone is insufficient if a client-readable snapshot column embeds the answer key.

## Integration With Existing Practice

The safest first release keeps Mock results independent:

- no writes to `quiz_attempts`, `quiz_attempt_questions` or `quiz_answers`;
- no automatic changes to `user_lesson_progress`;
- no automatic Flashcard review or scheduling changes;
- existing Review continues to use current study-quiz history only;
- Mock review reads dedicated immutable snapshots.

Later, weak Topics/readiness can consume completed Mock aggregates through an explicit read model or RPC. If Mock errors should feed `Meus Erros`, extend the stats query deliberately and label the source; do not duplicate Mock answers into `quiz_answers`.

## Question Pool Analysis

### Current inventory

| Domain / Topic | Total | Easy | Medium | Hard | Capacity |
| --- | ---: | ---: | ---: | ---: | --- |
| **Domain 1** | **153** | **48** | **77** | **28** | Excellent globally |
| Cloud Computing | 72 | 21 | 37 | 14 | Excellent |
| Benefits of Cloud Services | 61 | 19 | 32 | 10 | Excellent |
| Cloud Service Types | 20 | 8 | 8 | 4 | Limited for repeated balanced Mocks |
| **Domain 2** | **219** | **81** | **94** | **44** | Excellent globally |
| Core Architectural Components | 42 | 15 | 19 | 8 | Sufficient |
| Compute Services | 51 | 19 | 22 | 10 | Excellent |
| Networking Services | 30 | 11 | 13 | 6 | Sufficient |
| Storage Services | 46 | 17 | 19 | 10 | Sufficient |
| Identity, Access and Security | 50 | 19 | 21 | 10 | Excellent |
| **Domain 3** | **140** | **49** | **63** | **28** | Excellent globally |
| Cost Management | 30 | 10 | 14 | 6 | Sufficient |
| Governance and Compliance | 15 | 6 | 6 | 3 | Limited; smallest pool |
| Resource Management and Deployment | 55 | 19 | 25 | 11 | Excellent |
| Monitoring | 40 | 14 | 18 | 8 | Sufficient |
| **AZ-900** | **512** | **178** | **234** | **100** | Excellent globally |

The raw global pool could fill twelve non-overlapping groups of 40, but curriculum balance makes that number misleading. Governance and Compliance is the first bottleneck: assigning three to four items per Mock exhausts its 15 Questions after approximately four near-disjoint attempts. Cloud Service Types becomes constrained after roughly six.

Practical expectation:

- approximately **four curriculum-balanced Mocks can be near-disjoint**;
- from Mock 5 onward, localized reuse becomes inevitable, first in Governance;
- least-recent rotation can still produce **10–12 useful varied attempts**, but they will not be globally unique;
- this is sufficient for Mock development and does not justify adding redundant Questions before implementation.

## UX Flow

### Mock Exams landing/history

Use the existing `exams` route as the landing page:

- product name: **AZ-900 Practice Mock Exam**;
- New Mock or Resume Active Mock;
- concise disclosure that this is practice, not an official Microsoft simulator;
- Previous Attempts showing number, date, status, Practice Score, correct/total, duration and action to view result/review.

### Active Mock

Show:

- Question number and overall progress;
- prompt and four options;
- Previous and Next;
- Question navigator;
- answered/current/unanswered markers;
- save state and connection error state;
- submit button with confirmation listing unanswered count.

Do not show correctness, explanation, exam tips or immediate feedback. Option selection should save without locking the learner out; answers may change until final submission.

### Completed Mock

Show summary and breakdown first, then an ordered review. Use `Practice Score`, never `official score`. Result/history URLs should identify the attempt and enforce ownership.

## Risks

| Risk | Mitigation |
| --- | --- |
| Answer-key leak from JSON snapshots | No direct active snapshot SELECT; sanitized execution RPC and completed-only review RPC |
| Regression in existing quizzes | Dedicated Mock tables/functions; do not change current selection in 11.2/11.3 |
| Question edits rewrite history | Immutable per-attempt snapshots with schema/source version |
| Domain, Topic and difficulty constraints conflict | Explicit fallback order, persisted actual allocation and deterministic tests |
| Small Governance pool repeats early | Least-recent rotation and honest `LIMITED BY POOL` behavior |
| Concurrent starts create duplicate active Mocks | Partial unique index plus transactional/advisory lock start RPC |
| Refresh loses state or resets future timer | Server-persisted answers and immutable `started_at`/`expires_at` |
| Client clock manipulation | Server time is authoritative |
| Submission race or double click | Row lock and idempotent finalization RPC |
| Existing Review/Flashcards change unexpectedly | Keep V1 integration read-only and independent |
| Handwritten payload mapping drifts | Add Mock-specific Zod schemas at the service boundary in 11.2 |
| Product overclaims exam fidelity | Fixed practice terminology and no scaled-score approximation |

## Migration Plan

No migration is created in Stage 11.1. The future database change should be additive:

1. create dedicated Mock tables, constraints, indexes, timestamps and RLS;
2. add private snapshot/selection support and narrowly granted RPCs;
3. keep timer fields nullable and inactive;
4. add generated/manual database types plus Mock domain types and Zod response schemas;
5. validate ownership, answer-key secrecy, one-active-attempt behavior, immutability and orphan prevention;
6. preserve all existing quiz and user history without rewriting current rows.

Do not alter old migrations or add `mock` to existing `quiz_type` constraints as part of this plan.

## Implementation Roadmap

### 11.2 — Database + Domain Model

- Add dedicated tables, lifecycle constraints, indexes, RLS and timer-ready nullable fields.
- Add Mock TypeScript types and Zod schemas.
- Add start/resume, sanitized read, answer-save and abandon contracts without UI.
- Prove answer-key secrecy and user isolation.

### 11.3 — Mock Question Selection Engine

- Implement 11/15/14 Domain allocation.
- Implement Topic coverage, 12/20/8 difficulty and Lesson concentration guard.
- Implement unseen/least-recent/previous-attempt rotation.
- Add deterministic tests for all constraints, exhausted pools and concurrency.

### 11.4 — Mock Exam Execution UI

- Replace the placeholder landing experience with Start/Resume entry.
- Add active Mock page, navigator, Previous/Next, unanswered states and answer persistence.
- Support reload/resume and responsive/keyboard behavior.
- Keep feedback and explanations hidden while active.

### 11.5 — Submission + Result + Review

- Add atomic final submission and Practice Score.
- Add Domain/Topic/difficulty breakdowns.
- Add completed-only Question review and optional Lesson links.
- Validate unanswered handling and immutable completed attempts.

### 11.6 — Timer + Retake + History

- Enable server-authoritative time limit using the fields designed in 11.2.
- Add expiration behavior, elapsed duration and refresh-safe countdown.
- Add retake/history UI and overlap diagnostics.

### 11.7 — Mock Exam Validation + Closure

- Revalidate curriculum weights, Topic/difficulty balance and retake rotation across repeated attempts.
- Revalidate score, timer, resume, review, RLS, isolation, mobile, keyboard and accessibility.
- Run complete technical/database regression and document remaining limitations.

Readiness scoring, Certification Dashboard integration, AI Tutor, achievements and other certifications remain outside this roadmap unless explicitly approved in later stages.

## Implementation Status — 11.2

Stage 11.2 implements the approved hybrid persistence foundation without changing the existing Quiz system.

### Implemented

- Dedicated private tables: `mock_exam_attempts`, `mock_exam_attempt_questions` and `mock_exam_answers`.
- Lifecycle constraint with exactly `in_progress`, `completed`, `abandoned` and `expired`.
- Timer-ready nullable fields (`expires_at`, `time_limit_seconds`, `elapsed_seconds`) without timer behavior.
- Immutable full Question snapshots containing the canonical IDs, curriculum hierarchy, prompt, options, answer key, explanations, source timestamp and schema version.
- Insert-time snapshot verification against the canonical published Question and option records.
- One active attempt per user/certification, fixed Question/order uniqueness and a composite answer relationship that prevents cross-attempt association.
- Owner-only attempt history through RLS; snapshot and answer tables have defense-in-depth owner policies but no direct client grants.
- Sanitized active-attempt RPC that omits source option IDs, correctness and explanations.
- Idempotent answer upsert for `in_progress` attempts, including answer changes and persisted progress, without calculating or returning correctness.
- Explicit abandon transition. Completed scoring remains server-owned and is intentionally deferred.
- TypeScript database/domain/DTO contracts, strict Zod validation at the service boundary and a minimal service for history, active attempt lookup, resume, answer save and abandon.
- SQL validation for schema, lifecycle, foreign keys, indexes, privileges, RLS, answer-key secrecy, snapshot immutability, duplicate prevention, relationship integrity and user A/B isolation.

Migrations:

- `20260829058000_create_mock_exam_foundation.sql`
- `20260829059000_validate_mock_exam_foundation.sql`
- `20260829060000_validate_mock_exam_quiz_regression.sql`

### Deliberately deferred

- The public start/create operation and atomic Question selection are deferred to Stage 11.3. An empty or fake selection path was not introduced.
- Domain weighting, Topic balancing, difficulty allocation and retake rotation are not implemented.
- Final submission, server scoring, completed review and result breakdowns are not implemented.
- Mock UI, timer behavior and Readiness Score are not implemented.

Future final submission will lock the owned attempt, evaluate each selected snapshot key against the private frozen answer key and write result totals in one server-side transaction. The browser will never submit an authoritative score.

## Implementation Status — 11.3

Stage 11.3 implements the exam-style eligibility dimension and the atomic server-side Mock selector. The detailed inventory and capacity evidence are recorded in `docs/az900-mock-question-bank-audit.md`.

### Implemented

- Minimal global metadata: `questions.mock_eligible boolean not null default false` and a partial pool index.
- A/B/C/D audit rubric with only A/B persisted as `mock_eligible = true`; 439 of 512 AZ-900 Questions are approved.
- Exclusive filtering by certification, publication, `single_choice`, curriculum relationships, supported difficulty and Mock eligibility. There is no Study-only fallback.
- Standard Practice Mock configuration: 40 Questions; Domains `11 / 15 / 14`; difficulty `12 / 20 / 8` with per-Domain targets.
- Near-even Topic allocation: `4/4/3`, `3/3/3/3/3` and `4/4/3/3`. Extra Topic slots favor the least represented Topic in the current user's Mock history.
- Mock-only user history: unseen first, previous-attempt penalty, least-recently-seen order and deterministic seeded tie-breaking.
- Lesson concentration as a lower-priority guard after curriculum, difficulty and history constraints.
- Atomic start: selection, attempt creation and all 40 immutable snapshots succeed in one transaction or fail together.
- Concurrency-safe start/resume using a per-user/certification transaction advisory lock plus the existing one-active-attempt index.
- Public authenticated `start_mock_exam(uuid)` RPC and private deterministic selector contract. Production derives its tie-break seed from the generated attempt ID.
- TypeScript service contract for start; existing resume and sanitized execution payload remain unchanged.
- SQL tests for eligibility, 40 unique items, Domain/Topic/difficulty allocation, deterministic parity, user isolation, RLS, Topic rotation, ten retakes and existing Quiz independence.

### Capacity result

- Eligible pool: 439 Questions — 228 A, 211 B, 73 Study Only and 0 Problematic.
- Ten simulated Mocks retained all 12 Topics, exact Domain/difficulty profiles and zero overlap with the immediately previous Mock.
- Accumulated coverage reached 337 unique Questions after ten Mocks.
- Bank classification: **STRONG**.

### Still deferred

- Mock execution UI, navigator and answer interaction page.
- Timer behavior.
- Final Submit and server-side score finalization.
- Result, completed Review, history screen and Readiness Score.

**Mock Question Bank: READY. Mock Selection Engine: READY. READY FOR MOCK UI.**

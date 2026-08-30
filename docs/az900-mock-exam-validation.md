# AZ-900 Mock Exam Final Validation

Final closure audit performed in Stage 11.7 on August 30, 2026. The validated product is the **AZ-900 Practice Mock Exam** provided by Certification Academy. It is not an official Microsoft exam simulator and its Practice Score is not a Microsoft scaled score or a prediction that a learner will pass.

## Architecture

The implementation matches the decisions recorded from Stages 11.1 through 11.6:

- a separate Mock persistence model, not an extension of Lesson/Topic Quiz attempts;
- immutable Question snapshots per Attempt;
- one active Attempt per user and certification;
- a private server-side selector and public authenticated start contract;
- distinct active Execution and finalized Review DTOs;
- server-owned submission, scoring, timing and lifecycle transitions;
- owner-only Result, Review, synchronization and History contracts.

The older “deferred” lists in the architecture document describe their historical checkpoint. Later implementation-status sections supersede those lists. No structural divergence was found.

## Question Bank

The production audit was recalculated by the closure validator:

| Classification | Questions | Mock eligible |
| --- | ---: | :---: |
| A — Strong Exam-Style | 228 | Yes |
| B — Acceptable | 211 | Yes |
| C — Study Only | 73 | No |
| D — Problematic | 0 | No |
| **Total** | **512** | **439** |

Only published, structurally valid, single-choice A/B Questions with complete Domain, Topic, Lesson, difficulty, four options, one correct option and a teaching explanation are eligible. The selector contains no Study-only fallback.

A representative repository sample covered Cloud models, PaaS selection, resource hierarchy, Application Insights, Availability Zones, Private Endpoints and Storage redundancy. The sample included direct concept, comparison, scenario and trap/differentiation prompts, plausible alternatives and Fundamentals-level explanations. No dump/leak source or copied confidential exam item was found. The quantitative split—228 scenario-oriented medium/hard A items and 211 concise B items—does not indicate a monotonic “Qual serviço é...?” bank.

## Selection

Every simulated Attempt contained exactly 40 unique Question IDs, display orders 1–40, valid frozen snapshots and only currently published `mock_eligible` AZ-900 Questions.

The approved allocation remained exact in all tested Attempts:

- Domain 1: 11;
- Domain 2: 15;
- Domain 3: 14;
- total: 40.

Every healthy-pool Mock contained all 12 current Topics. Within a Domain, Topic counts differed by at most one. The engine still prioritizes Domain quota, Topic coverage and difficulty before history rotation.

## Retake simulation

The established ten-Mock deterministic capacity audit was revalidated by the final five-Mock integrated closure scenario.

| Mock | Unique Questions | Overlap Previous | Topics Covered | D1 | D2 | D3 |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 40 | 0 | 12 | 11 | 15 | 14 |
| 2 | 40 | 0 | 12 | 11 | 15 | 14 |
| 3 | 40 | 0 | 12 | 11 | 15 | 14 |
| 4 | 40 | 0 | 12 | 11 | 15 | 14 |
| 5 | 40 | 0 | 12 | 11 | 15 | 14 |
| 6 | 40 | 0 | 12 | 11 | 15 | 14 |
| 7 | 40 | 0 | 12 | 11 | 15 | 14 |
| 8 | 40 | 0 | 12 | 11 | 15 | 14 |
| 9 | 40 | 0 | 12 | 11 | 15 | 14 |
| 10 | 40 | 0 | 12 | 11 | 15 | 14 |

Cumulative exposure was 40, 80, 120, 195 and 337 unique Questions after 1, 2, 3, 5 and 10 Mocks. Adjacent average and maximum overlap were both zero. The final validator independently required at least 190 unique Questions across five live-contract retakes.

## Execution

Start uses one atomic server RPC; React never selects Questions. Execution synchronizes the owned Attempt against server time and then loads all 40 sanitized Question DTOs in one batched RPC. The duplicate Attempt read found during the performance audit was removed.

The runner preserves navigation position only as non-authoritative UI state. Answers, Attempt status, timer and Question order remain server-backed. Selection changes, navigation, unanswered summary, retry after failure and double-click protection are covered by integration tests.

## Timer

Practice Mock duration is the platform configuration of 60 minutes. `started_at`, `time_limit_seconds` and `expires_at` are persisted and the server returns `server_now` during synchronization. The browser uses a monotonic elapsed clock only for display between synchronizations.

Reload and reopening cannot reset the deadline. A return after expiration finalizes before Resume. Manual submit before expiration completes normally; timeout finalizes as `expired`, preserves saved answers, marks missing items unanswered and caps duration at 3,600 seconds. There is no pause.

The timer exposes Normal, Warning and Critical text. Its per-second value uses `role="timer"` without a noisy live announcement; a separate polite live region announces only the status band.

## Persistence

Saving Q1 and then changing Q1 updates the same answer record. The current selection survives server reload. Failed writes remain visibly unpersisted and can be retried. Completed and expired Attempts reject further answer mutations.

The closure validator temporarily changed a source Question inside a rollback-only transaction after completion. The old Review continued to return the original snapshot prompt, proving historical independence from later source edits.

## Resume

- valid `in_progress` → Resume the same Attempt;
- `completed` → Result;
- timeout-finalized `expired` → Result;
- `abandoned` → non-resumable History state.

Starting while a valid active Attempt exists returns that Attempt instead of creating a second active row. A new Attempt is created only after the prior one is no longer resumable and the user explicitly starts or retakes.

## Submission

Submission locks the owned Attempt and evaluates frozen answer keys on the server. Normal, unanswered, double-click, repeated RPC, completed and expired paths are deterministic. A second submit returns the same finalized result and preserves `submitted_at`; it cannot create a second result.

## Scoring

The validated invariant is:

`correct + incorrect + unanswered = 40`

Practice Score is `correct / 40 × 100`. SQL fixtures cover 40/40, 0/40, 30 correct + 5 incorrect + 5 unanswered, and a mixed 17/13/10 result. No conversion to a Microsoft scaled score exists.

Difficulty allocation remained 12 easy, 20 medium and 8 hard. Difficulty breakdown totals 40 and is presented as objective practice data, not a pass/fail signal.

## Results

The Result page displays Practice Score, correct, incorrect, unanswered, Time Used, Domain, Topic and difficulty breakdowns, Review and Retake actions. Domain/Topic/difficulty totals each sum to 40 and percentages derive from snapshot IDs and evaluated answers, not text matching.

Topics absent from an Attempt are omitted instead of receiving a misleading zero. The UI explicitly states that Practice Score is neither an official Microsoft score nor a readiness prediction.

## Review

Review is read-only and finalized-only. Correct, incorrect and unanswered states identify selected and correct options with text/icons in addition to color. It provides snapshot explanation and the frozen Domain → Topic → Lesson context, filters All/Incorrect/Unanswered/Correct and a Review Lesson route.

The active Execution RPC and TypeScript DTO contain no correct option, answer key, explanation, difficulty or curriculum IDs. The closure validator enumerated active DTO keys and rejected any protected field. These fields become available only through the owner-only finalized Review contract.

## Retakes

`Start New Mock` and `Take Another Mock` call the same public `start_mock_exam` service. Each finalized retake receives a new UUID, snapshots, start time and deadline while retaining all earlier History. Unseen-first, previous-Mock penalty and least-recently-seen rules remain active without weakening curriculum allocation.

## History

History supports empty, one-item and multi-item states, newest-first ordering, stable `Mock #N`, score, counts, duration, In Progress/Completed/Expired/Abandoned, Resume and View Result. Pagination is 10 rows per page.

`get_mock_exam_history` returns only Attempt metadata, counts, score and timestamps. It does not fetch 40 snapshots or options for every card. Result and Review remain lazy detail queries.

## Security

RLS is enabled on Attempts, snapshots and answers. Authenticated users have owner-only Attempt reads and no direct snapshot/answer-table grant. All public Mock RPCs derive ownership from `auth.uid()`.

User A/B validation covered selection parity with isolated empty histories, direct foreign Attempt IDs, Result, Review, synchronization, History, snapshot table and answer table. No cross-user data was returned. Active answer keys remain server-private.

## Accessibility

Validated basics include heading hierarchy, radio groups, large option labels, button names/states, focusable filters, keyboard navigator controls, confirmation dialog semantics, progress values, textual save/error states, textual correct/incorrect/unanswered states and timer semantics that do not depend only on color.

Responsive layout uses stacked mobile controls and wrap-safe runner header/timer actions. The local browser shell showed no horizontal document overflow at 390 px or 1,440 px and no console errors. Protected Mock screens were validated through component/integration tests rather than entering real user credentials during the audit.

## Performance

- Start: one atomic selection/snapshot RPC, not dozens of serial client queries.
- Execution: one server synchronization plus one batched 40-Question load; no N+1 and no duplicate Attempt read.
- Answer save: one upsert RPC per explicit selection change.
- Result: one summary/breakdown RPC.
- Review: one lazy 40-row snapshot RPC only after opening Review.
- History: one metadata-only paginated RPC; no snapshot over-fetching.
- Timer: only its small component rerenders each second.

## Regression

Lesson Quiz remains independent and retains start, answer, score, feedback and Lesson progress behavior. Topic Quiz retains its approved selection, scoring, Review and 10.3 retake rotation. The Mock eligibility predicate is absent from Lesson, Topic and global Review selectors.

Global Review, flashcard scheduling, spaced repetition and Lesson progress tables/functions are unchanged by the Mock system. Mock Review uses separate tables and routes.

## Technical Validation

- TypeScript typecheck: passed.
- ESLint: passed with zero warnings.
- Vitest: 112 tests passed, 0 failed.
- Production build: passed.
- `git diff --check`: passed.
- Supabase closure validator: passed in production with rollback-only fixtures.
- Post-deploy `db:push:dry-run`: remote database up to date, zero pending migrations.
- Existing Vite bundle warning: main JS chunk is approximately 707 kB minified / 188 kB gzip.

Final closure migration:

- `20260830075000_validate_mock_exam_system_closure.sql`

## Blockers

| Priority | Count | Notes |
| --- | ---: | --- |
| P0 | 0 | No integrity, answer-key, cross-user or lifecycle leak found. |
| P1 | 0 | No scoring, curriculum allocation or pedagogical validity blocker found. |
| P2 | 0 | No issue compromising the principal Mock flow remains. |
| P3 | 2 | Existing bundle-size warning; some legacy imported Portuguese Questions omit diacritics, an editorial polish issue that does not change meaning or scoring. |

The lack of an automated axe-style suite and the authenticated manual-browser walkthrough are validation-improvement opportunities, not observed product defects. Component semantics, keyboard behavior, responsive structure and owner-isolated production contracts were directly tested.

## Final Decision

Question Bank, selection, execution, timer, persistence, resume, submission, scoring, Results, Review, retakes, History, RLS, basic accessibility and regressions are approved. The platform can measure objective learner practice through AZ-900 Mocks; this decision makes no claim that any learner is ready for the official exam.

**AZ-900 Mock Exam System: CLOSED**

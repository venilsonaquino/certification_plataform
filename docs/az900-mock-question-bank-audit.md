# AZ-900 Mock Question Bank Audit

Audit completed in Stage 11.3 on August 30, 2026. The bank contains original platform Questions aligned with the AZ-900 curriculum. No exam dump, leaked item or copied confidential Question was introduced.

## Total Question Bank

| Classification | Questions | Mock eligible |
| --- | ---: | :---: |
| A — Strong Exam-Style | 228 | Yes |
| B — Acceptable | 211 | Yes |
| C — Study Only | 73 | No |
| D — Problematic | 0 | No |
| **Total** | **512** | **439** |

The classification is additive. All 512 published study Questions remain available to Lesson Quiz, Topic Quiz and Review. Stage 11.3 changed no Question or option UUID and did not unpublish content.

## Mock Eligibility Criteria

An approved Question must belong to AZ-900, be published `single_choice`, have complete Domain/Topic/Lesson relationships, a supported difficulty, sufficiently clear prompt and teaching explanation, exactly four distinct non-empty options and exactly one correct answer. The selection engine additionally requires `mock_eligible = true`; there is no fallback to Study-only content.

Curricular and factual suitability comes from the completed Domain content audits. The 11.3 gate adds consistent structural and exam-use checks. Plausible distractors and Fundamentals depth remain editorial qualities and should continue to be sampled during future bank maintenance; text length alone is not treated as proof of semantic quality.

## Quality Rubric

- **A — Strong Exam-Style:** approved, with scenario/decision context and medium or hard reasoning.
- **B — Acceptable:** approved, clear and useful for comparison, purpose or direct conceptual differentiation, even when more concise.
- **C — Study Only:** valid for learning/review but below the Mock gate for prompt or explanation depth.
- **D — Problematic:** structurally or conceptually unusable until corrected. The audited bank currently has none after the earlier Domain cleanup stages.

Only the boolean `questions.mock_eligible` is persisted. A/B/C/D is an audit rubric, not an editorial workflow or a second source of truth.

## Domain Distribution

| Domain | Total | A/B eligible | Easy | Medium | Hard |
| --- | ---: | ---: | ---: | ---: | ---: |
| Describe cloud concepts | 153 | 144 | 40 | 76 | 28 |
| Describe Azure architecture and services | 219 | 183 | 52 | 88 | 43 |
| Describe Azure management and governance | 140 | 112 | 29 | 57 | 26 |
| **AZ-900** | **512** | **439** | **121** | **221** | **97** |

Each Domain independently exceeds its standard Mock quota of 11, 15 or 14 Questions and supports the per-Domain difficulty targets.

## Topic Distribution

| Domain | Topic | Total | Eligible | Easy | Medium | Hard |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 1 | Cloud Computing | 72 | 68 | 17 | 37 | 14 |
| 1 | Benefits of Cloud Services | 61 | 57 | 16 | 31 | 10 |
| 1 | Cloud Service Types | 20 | 19 | 7 | 8 | 4 |
| 2 | Core Architectural Components | 42 | 37 | 10 | 19 | 8 |
| 2 | Compute Services | 51 | 48 | 16 | 22 | 10 |
| 2 | Networking Services | 30 | 23 | 5 | 12 | 6 |
| 2 | Storage Services | 46 | 38 | 12 | 17 | 9 |
| 2 | Identity, Access and Security | 50 | 37 | 9 | 18 | 10 |
| 3 | Cost Management | 30 | 27 | 8 | 13 | 6 |
| 3 | Governance and Compliance | 15 | 15 | 6 | 6 | 3 |
| 3 | Resource Management and Deployment | 55 | 43 | 7 | 25 | 11 |
| 3 | Monitoring | 40 | 27 | 8 | 13 | 6 |

Every current Topic has an eligible pool larger than its per-Mock target. The engine therefore represents all 12 Topics in a healthy standard Mock.

## Difficulty Distribution

The eligible bank contains 121 easy, 221 medium and 97 hard Questions. Standard selection follows the architecture-approved `12 easy / 20 medium / 8 hard` profile, with per-Domain targets `3/6/2`, `5/7/3` and `4/7/3`. Domain quota and Topic coverage remain higher priorities; same-Topic difficulty relaxation is available for a future constrained pool.

## Eligible Questions

The 439 approved Questions form the exclusive Mock pool. Selection also checks publication and certification at execution time, so an unpublished Question or a Question from another certification cannot enter even if metadata is set incorrectly later.

## Study-Only Questions

The 73 C Questions remain published and usable by the existing study flows. `mock_eligible = false` does not alter Lesson Quiz, Topic Quiz, Topic retakes, Review or spaced repetition.

## Problematic Questions

The audit classified 0 Questions as D. No wording, option or explanation was changed in Stage 11.3. A later editorial review may still demote an item without deleting it or changing its UUID.

## Question Pool Capacity

Pool capacity is **STRONG** for the standard 40-Question Practice Mock:

- 10.98 full non-overlapping 40-item sets exist globally before considering curricular cell constraints;
- all three Domain quotas have substantial reserve;
- all 12 Topics can appear in every Mock;
- all per-Domain difficulty targets are supported;
- selection fails with a controlled readiness error instead of using Study-only Questions when a Domain becomes insufficient.

## Retake Capacity

| Mock | D1 | D2 | D3 | Easy | Medium | Hard | Topics | Overlap previous |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 11 | 15 | 14 | 12 | 20 | 8 | 12 | 0 |
| 2 | 11 | 15 | 14 | 12 | 20 | 8 | 12 | 0 |
| 3 | 11 | 15 | 14 | 12 | 20 | 8 | 12 | 0 |
| 4 | 11 | 15 | 14 | 12 | 20 | 8 | 12 | 0 |
| 5 | 11 | 15 | 14 | 12 | 20 | 8 | 12 | 0 |
| 6 | 11 | 15 | 14 | 12 | 20 | 8 | 12 | 0 |
| 7 | 11 | 15 | 14 | 12 | 20 | 8 | 12 | 0 |
| 8 | 11 | 15 | 14 | 12 | 20 | 8 | 12 | 0 |
| 9 | 11 | 15 | 14 | 12 | 20 | 8 | 12 | 0 |
| 10 | 11 | 15 | 14 | 12 | 20 | 8 | 12 | 0 |

The deterministic simulation used one isolated fixture user, unique seeds and Mock-only history. Attempts and the fixture user were deleted/rolled back by the SQL validators; no real user history was created.

Accumulated unique coverage:

| Completed Mocks | Unique Questions |
| ---: | ---: |
| 1 | 40 |
| 2 | 80 |
| 3 | 120 |
| 5 | 195 |
| 10 | 337 |

Average adjacent overlap was `0.00`; maximum adjacent overlap was `0`. Later Mocks can reuse older items when required, but the immediately previous Mock remains strongly penalized.

## Weak Topics

No Topic blocks standard selection. Relative reserve is lowest in:

- Governance and Compliance — 15 eligible;
- Cloud Service Types — 19 eligible;
- Networking Services — 23 eligible;
- Cost Management and Monitoring — 27 eligible each.

These are maintenance priorities for future editorial expansion, not blockers for the Mock UI. Governance has the earliest long-run repetition risk because it supplies three to four Questions per Mock from a 15-item pool.

## Recommendations

- Periodically sample A/B items for semantic distractor quality; structural validation cannot replace editorial judgment.
- Add future exam-style Questions first to Governance, Cloud Service Types and Networking, preserving the current UUID/history rules.
- Keep Mock history separate from study Quiz history unless a later product decision explicitly merges analytics.
- Re-run the 10-Mock capacity validator after any large Question edit, eligibility reclassification or curriculum change.

## Mock Bank Readiness

**STRONG — READY FOR MOCK UI.**

The current pool supports a complete 40-Question Mock, exact Domain weights, all-Topic diversity, the approved difficulty profile, deterministic selection and substantial retake rotation without Study-only fallback.

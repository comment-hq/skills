---
name: code-review
description: Run one evidence-focused, risk-scaled official code review on a pull request and post the result. Only invoke when explicitly requested as `$code-review` or `/code-review`, or when `ship` selects it as the sole official-review fallback.
---

# code-review — one official review for the exact PR head

This is the posted official review path. It is distinct from `review-loop`,
which certifies bounded in-flight deltas. Do not run both local Codex review and
this skill for the same candidate.

## Eligibility

Read the PR's state, base, exact head SHA, changed files, relevant
`AGENTS.md`/`CLAUDE.md`, and prior reviews. Stop for a closed/draft PR unless
`ship` deliberately opened a draft because this is the only available official
reviewer. Do not skip merely because an earlier head was reviewed: official
evidence must match the current head.

## Risk-scaled review

Use one strong primary reviewer for correctness, regressions, missed
requirements, and repository-instruction violations. Add one independent
specialist lens only when the diff touches authorization/security,
migrations/storage, protocol/compatibility, concurrency, native code,
destructive behavior, or credible data-loss risk. Three reviewers are reserved
for exceptional blast radius.

Lock the review to the PR's declared subject, acceptance criteria, invariants,
and exact base/head delta. Read only the surrounding code and history needed to
verify impact; untouched context is evidence, not a broader audit surface. A
finding is in scope only if the PR delta introduced or changed it, or the delta
makes an existing path violate an explicit requirement/invariant. For a lift promotion, consume the review
receipt ledger and focus on receipt coverage, cross-slice composition,
main-sync/conflict delta, migration/cut-over ordering, and uncovered commits
instead of blindly repeating each certified slice.

## Findings

Keep an issue only when evidence demonstrates a concrete correctness,
security/privacy, data-loss, compatibility, migration, protocol, or stated-
requirement failure on changed code. Verify debatable claims from code or a
focused case. Exclude:

- style or preference;
- speculative refactors/general quality advice;
- unrelated pre-existing debt;
- unsupported hypotheticals;
- compiler/linter/type errors already covered by a required gate, unless the
  review shows that gate is missing;
- intentional behavior required by the task.

Prefer the simplest implementation that works for the current user need. Do not
block shipping on speculative enterprise hardening, abstraction, or unlikely
edge cases without a credible reachable failure. This does not relax concrete
security/privacy, data-loss, migration, protocol, or correctness requirements.

Report a genuinely unrelated defect separately as an out-of-scope discovery;
do not put it in the PR review or expand the current diff. The orchestrating
agent searches for or files one focused GitHub issue and continues. If it is
actively release-breaking or makes the current delivery unsafe, the orchestrator
stops and asks the owner human to start a separate worktree job.

The main agent deduplicates and verifies the complete finding batch. Post one
brief official review for the exact head SHA, citing each real issue. If none
remain, post “No actionable issues found” and name the scope/lenses reviewed.
Never ask a second panel to sample until silence.

## After a fix

The edited PR is a new head. Review only the fix delta plus impacted invariants
when the platform supports it, but make the posted result explicitly apply to
the new exact head. Normal work gets at most two finding-bearing rounds before
redesign, targeted proof, residual-risk recording, or human escalation.

Do not run builds or full tests inside this skill; `ship` owns candidate
evidence. Use `gh` for PR inspection and posting.

---
name: review-loop
description: >-
  Review a change (a code diff, a plan, or a PR) with a panel of independent
  review subagents and loop — fix the real findings, re-review with a fresh
  panel — until a full panel comes back with nothing actionable. The local,
  pre-PR "iterate until clean" gate the delivery skills run at plan and phase
  boundaries. Distinct from `code-review`, which posts one official review to a
  PR; `review-loop` is the in-flight convergence loop. Only invoke when
  explicitly requested as `$review-loop` / `/review-loop`, or when a delivery
  skill calls it. Works identically under Codex and Claude Code. (Formerly
  `3wise`.)
---

# review-loop — converge a change to "no real findings"

A panel of **independent** reviewers is better than one: each catches blind
spots the others miss, and looping until the panel is quiet is what turns
"probably fine" into "reviewed". `review-loop` runs that panel and drives the
change to convergence.

This is a **gate primitive**: `comment-feature`, `comment-bug`, `comment-spec`,
and `drive-plan` invoke it (on the plan before building, and on the diff at each
phase boundary). Use it standalone on any diff, plan, or PR you want hardened.

## The loop

1. **Spin up a panel of independent review subagents** (default **3**) on the
   target — `$ARGUMENTS` names what to review (a diff, a plan, a PR, a file
   set). Each reviewer works independently; do not let them see each other's
   findings. Point them at *real* failure modes: correctness/logic bugs,
   security, regressions, missed or misread requirements, broken edge cases,
   and plan gaps — not style nits or speculative "could refactor" notes.
2. **Wait for the whole panel, then triage the batch.** Never start editing from
   partial results. Missing or unknown results block the round; they do not count
   as clean. Keep only the findings that are a **real issue**.
   Discard duplicates, false positives, and pure preference. When a finding is
   debatable, prefer to verify it (read the code, run the case) over guessing.
3. **Fix compatible findings together**, in priority order. Then run the
   narrowest useful validation for the batch (see **Repo config**).
4. **Re-review with a fresh panel.** Repeat from step 1.
5. **Exit when a full panel returns no actionable findings.** That clean round
   is the gate passing. Record the rounds (in comm mode, each round is a
   *comment*; see the calling skill).

Scale the panel to the stakes: 3 is the default; widen it (5+, or give each
reviewer a distinct lens — correctness, security, does-it-actually-reproduce)
for high-blast-radius changes, and you may run a single reviewer for a trivial
diff.

## Decline, don't loop forever

If a reviewer raises something you intentionally won't change, **record the
reasoning** and don't treat it as blocking — a real, unresolved disagreement is
a steer point, not an infinite loop. Convergence means "no *new* actionable
findings", not "every reviewer fell silent by exhaustion".

If finding-bearing rounds keep recurring, stop patching and reconsider the
design; three such rounds is a useful signal. Record the invariant or approach
that changes, then resume with a fresh panel.

## Repo config

`review-loop` itself is repo-agnostic. Read **`AGENTS.md` (else `CLAUDE.md`)**
and the `docs/TESTING.md` it links. Use focused checks during this convergence
loop; leave the complete affected lane to final candidate certification. If the
config is absent, infer suitable checks from `package.json` / `Makefile` / CI.

## Relationship to `code-review`

- **`review-loop`** (this skill): many independent reviewers, **looped to
  convergence**, run **locally and in-flight** (on a plan or an unpushed diff).
- **`code-review`**: one official, posted review on an open PR. `ship` runs that
  (or Codex's `codex review`) as the single pre-merge gate.

They compose: `review-loop` keeps the work clean as you build; the official
review confirms it at the PR.

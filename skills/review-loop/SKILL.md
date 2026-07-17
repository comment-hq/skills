---
name: review-loop
description: >-
  Review an explicit plan/code/PR SHA delta with a risk-scaled panel, fix one
  complete finding batch, validate the changed delta, and emit a durable review
  receipt. Defaults to one reviewer, adds targeted lenses for sensitive work,
  caps normal finding-bearing rounds, and avoids re-reading already certified
  branch history. Only invoke as `$review-loop` / `/review-loop`, or when a
  delivery skill calls it. Works identically under Codex and Claude Code.
---

# review-loop — bounded delta review with receipts

Read `delivery-methodology` and repo instructions first. Review is a risk-control
tool, not a stochastic search for a panel that eventually says nothing.

## Required target

Do not start from “review this branch.” Name:

- artifact type and scope;
- `base_sha` and `head_sha` (or exact plan revision);
- acceptance criteria and important invariants;
- risk tier and requested lenses;
- focused checks/evidence already available.

Treat the declared subject, acceptance criteria, invariants, and
`base_sha..head_sha` as a hard scope lock. Read only the surrounding context
needed to validate impact; untouched context is evidence, not a new audit
surface. A finding is in scope only if the target delta introduced or changed
it, or the delta makes an existing path violate an explicit acceptance
criterion/invariant. An explicit plan review may use plan revisions instead of
Git SHAs.

## Risk-scale the panel

- **Routine:** one reviewer.
- **Sensitive:** two independent reviewers/lenses for authorization,
  migrations/storage, protocol/compatibility, concurrency, native code,
  destructive behavior, or credible data-loss risk.
- **Exceptional:** three only for exceptional blast radius.

Reviewers report concrete failure paths, violated requirements/invariants, and
evidence. Exclude style nits, speculative refactors, unrelated pre-existing
debt, unsupported hypotheticals, and issues a required compiler/linter already
settles unless they reveal a missing gate.

Bias toward the simplest implementation that satisfies current user acceptance.
Do not block on imagined enterprise needs, unnecessary abstraction, or
combinatorial edge cases without a credible reachable failure. Hard correctness,
security/privacy, data-loss, migration, and protocol failures remain blockers.

## Out-of-scope discovery protocol

Reviewers report a genuinely unrelated defect separately as an **out-of-scope
discovery**, never as a finding against the reviewed target, and stop exploring
it after collecting enough evidence to identify it. The orchestrating agent:

1. Searches the GitHub issue ledger and attaches the evidence, or creates one
   focused issue (use `file-bug` when available).
2. Links the issue in the receipt/worklog and continues the original review.
3. Stops only when the discovery is actively release-breaking, creates a
   credible security/privacy or data-loss emergency, or makes this delivery
   unsafe to evaluate. Ask the owner human to start a separate worktree job;
   never silently absorb the fix into the current branch.

A regression introduced or exposed by the target delta remains in scope.

## Bounded loop

1. Run the requested reviewer(s) independently and wait for the complete batch.
   Missing requested results are unknown, not success.
2. Triage duplicates and false positives. Verify debatable claims from code or a
   focused case. Keep only actionable blockers or explicit residual risks.
3. Fix compatible findings together and run the narrowest useful validation.
4. If another review is needed, target `last_reviewed_head..HEAD` plus the
   surrounding code/invariants actually invalidated by the fix. Do not re-run a
   fresh full panel over already certified history.
5. Normal work gets at most two finding-bearing rounds. Continued findings mean
   redesign, targeted proof, a recorded residual risk, or human decision.
6. Exit when acceptance and invariants hold, required evidence passes, and no
   known actionable blocker remains. A reviewer need not fall silent about
   non-blocking preferences.

## Receipt

Emit one receipt containing:

```text
base_sha: <review base>
head_sha: <accepted head>
scope: <bounded target>
acceptance/invariants: <what was checked>
risk: routine | sensitive | exceptional
reviewers: <count and lenses>
checks: <commands/evidence>
findings: <fixed items>
declines: <item + reason>
residual_risks: <explicit remainder>
out_of_scope_issues: <GitHub links, or none>
```

For a controlled lift, add the `kind`, `merge_sha`, and optional `source_sha`
fields required by `delivery-methodology` after the delta enters the lift. Store
the receipt in the Project Root/ledger and post one concise review-batch comment,
not one comment per reviewer or round.

## Repo config

Read `AGENTS.md` (else `CLAUDE.md`) and linked delivery/testing docs. Use focused
checks during review convergence; leave the complete affected lane to a direct
candidate or frozen lift promotion unless a sensitive slice warrants more.

## Relationship to official review

`review-loop` certifies bounded in-flight deltas. `ship` runs one official review
for a direct candidate or final promotion. A lift promotion consumes prior
receipts and focuses on coverage/composition/uncovered delta instead of blindly
re-reviewing every slice.

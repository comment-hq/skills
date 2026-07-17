---
name: delivery-methodology
description: >-
  Choose and enforce a pragmatic engineering delivery topology: a direct PR for
  independently shippable work or a controlled lift branch for foundational
  work with unsafe intermediate states. Defines bounded SHA-delta reviews,
  risk-scaled reviewer counts, review receipts, lift freeze/promotion, and a
  technical-ready stopping point. Delivery skills call it before planning or
  shipping; invoke directly when deciding how a large change should reach main.
---

# delivery-methodology — ship bounded work without preserving two systems

Read the repo's `AGENTS.md` (else `CLAUDE.md`) and any linked delivery/testing
guide first. Repo rules may be stricter. This skill supplies the generic method
when a repo has no equivalent.

## Startup operating principle

Optimize for the smallest simple change that gives real users value and yields
useful product evidence. Treat complexity as a cost: abstraction, compatibility
machinery, enterprise hardening, and exhaustive hypothetical edge-case support
need a present requirement or credible failure path. Preserve hard correctness,
security/privacy, data-loss, migration, and protocol invariants. Otherwise ship
a reversible useful boundary, validate the real user journey, and expand from
evidence rather than imagination.

## Choose the topology

Use a **direct task branch** for a complete change that can safely ship in one
bounded PR. It starts from the target base and the PR targets that base.

Use a **controlled lift branch** for foundational work whose partial state is
unshippable or whose clean implementation replaces a system across coordinated
slices. Record the choice and why before implementation.

Feature flags are a rollout tool, not the default slicing strategy. Use one only
around a clean, bounded activation seam. Prefer a lift when a flag would require
broad branching, dual writes, duplicated state, compatibility shims, or two
authoritative systems.

## Controlled lift

- One Project Root/worklog and one `lift/<initiative>` own the work.
- Slice branches start from the current lift tip and target the lift, never
  another slice branch.
- Merge slices sequentially with real merge commits. Never squash, rebase, or
  force-push the lift.
- Merge the target base into the lift periodically and review conflict delta.
- Keep unrelated work out.
- A human-approved lift plan may authorize internal slice merges; promotion to
  the release branch still follows repo/user merge authority.
- Freeze the lift before promotion. No dependent slice remains open or lands
  after the promotion starts.

## Review explicit deltas

Every target names `base_sha`, `head_sha`, a locked subject/scope, acceptance criteria,
invariants, risk tier, and checks. Review `base_sha..head_sha` plus necessary
impact context—not the accumulated branch by habit. Surrounding code is evidence,
not a broader audit surface. A finding is in scope only when the target delta
introduced or changed it, or when the delta makes an existing path violate an
explicit acceptance criterion or invariant.

- **Routine:** one reviewer.
- **Sensitive:** two independent lenses for authorization, migrations/storage,
  protocol/compatibility, concurrency, native code, destructive behavior, or
  credible data-loss risk.
- **Exceptional:** three only for exceptional blast radius.

Gather one complete finding batch, fix compatible findings together, and run
focused validation. Review later fixes from the last reviewed head plus any
invalidated invariant. Normal work gets at most two finding-bearing rounds;
then redesign, prove the disputed case, record residual risk, or ask a human.

A blocking finding needs a concrete correctness, security/privacy, data-loss,
compatibility, migration, protocol, or stated-requirement failure. Decline style
preferences, speculative refactors, unrelated debt, and unsupported
hypotheticals with concise reasoning.

For a genuinely unrelated defect, do not expand the current review or branch.
Search the GitHub issue ledger and attach evidence or create one focused issue
(`file-bug` when available), link it in the receipt, and continue. If it is
actively release-breaking, creates a credible security/privacy or data-loss
emergency, or makes the current delivery unsafe to evaluate, stop and ask the
owner human to start a separate worktree job. A defect exposed or caused by the
target delta remains in scope.

## Emit a receipt

Record:

```text
kind: slice | main-sync | direct | promotion-fix
base_sha: <commit>
head_sha: <commit>
merge_sha: <commit that entered the lift, or head_sha for direct>
source_sha: <second parent for main-sync; omit otherwise>
scope: <bounded change>
invariants: <properties checked>
risk: routine | sensitive | exceptional
reviewers: <count/lenses>
checks: <commands/evidence>
findings: <fixed or declined with reasons>
residual_risks: <explicit remainder>
```

For a slice merge require `base_sha == merge_sha^1` and
`head_sha == merge_sha^2`. For a main sync require
`base_sha == merge_sha^1`, `source_sha == merge_sha^2`, and
`head_sha == merge_sha`. A `direct` or `promotion-fix` receipt must bind a
single-parent commit with `base_sha == merge_sha^1` and `head_sha == merge_sha`.
Ordered receipt `merge_sha` values must exactly cover the lift's first-parent
chain from its recorded base to frozen head.

The bundled `scripts/verify-lift-receipts.sh` checks a TSV ledger:

```text
kind<TAB>base_sha<TAB>head_sha<TAB>merge_sha<TAB>source_sha-or--
```

Run:

```bash
<skill-dir>/scripts/verify-lift-receipts.sh <lift-base-sha> <frozen-head-sha> <receipts.tsv>
```

## Test the right boundary

- During implementation/review fixes: narrowest useful checks.
- Lift slice: focused checks for its explicit delta; record them in the receipt.
- Direct release candidate: complete affected lane once on the frozen commit.
- Lift promotion: complete affected lane once on the frozen lift head plus the
  initiative's realistic integration/migration scenario.
- Release merge queue: full matrix on the speculative merge.

Do not claim a test command is slice-scoped when its selector compares with the
release branch. Run independent final gates concurrently where practical.

## Finish pragmatically

A boundary is complete when acceptance passes, required evidence passes, no
known severity-blocking defect remains, mandatory repo rules hold, and residual
risks/follow-ups are recorded. Optional polish, speculative enterprise
readiness, exhaustive hypothetical edge cases, and unrelated cleanup become
follow-ups. Phases organize implementation; they are not automatic review,
staging, steering, or artifact gates.

Update the worklog only on material state changes. Create separate Plan/design/
ADR docs only when they provide a real human review surface or durable decision.

Distinguish implementation-converged, candidate-certified, PR-technically-ready,
human-authorized, and merged. Do not keep an active session alive indefinitely
waiting for an external reaction the repository does not require.

## Promote a lift

1. Merge every intended slice and freeze the lift.
2. Merge current target base into the lift with a real merge commit.
3. Review and receipt conflict resolutions/uncovered delta.
4. Mechanically verify ordered receipt coverage to the frozen head.
5. Run final affected and integration certification on that SHA.
6. Run one composition review: receipt coverage, cross-slice seams, migration/
   cut-over order, single-source-of-truth outcome, and residual delta.
7. Open one promotion PR from the certified SHA. A draft is allowed before
   review only when the sole official reviewer requires a PR; keep it draft
   until that same SHA passes.
8. Merge through the target branch's normal mechanism when explicitly
   authorized, then verify every slice head and frozen lift head reached it.

Domain workflows such as production deployment, incidents, storage migration,
or protocol cut-over may impose stricter irreversible-risk gates. Preserve them
without reintroducing generic repeated review ceremony.

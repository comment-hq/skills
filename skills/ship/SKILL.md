---
name: ship
description: >-
  Drive a direct candidate, lift slice, or lift promotion through the right
  evidence and PR lifecycle. Runs exactly one official review for a direct/final
  candidate, consumes delta receipts for lift promotion, distinguishes technical
  readiness from human merge authority, and only queues/watches a merge when
  explicitly authorized. Invoke as `$ship` / `/ship`, or when asked to finish,
  land, merge, make a PR mergeable, or make it pristine. Works identically under
  Codex and Claude Code.
---

# ship — certify and move the intended delivery boundary

Read `delivery-methodology`, the repo's `AGENTS.md`/`CLAUDE.md`, and linked
delivery/testing/merge docs first. Determine the actual PR base and choose one
mode before running gates.

## Modes

### Direct candidate

A complete independently shippable task branch targeting the release branch.
Freeze one commit, run the complete affected lane and one official review on
that SHA, then push/open the PR.

### Lift slice

A bounded delta targeting a declared controlled lift. Require focused checks and
a base/head review receipt. Push/open the slice PR and merge it into the lift
with a real merge commit when the human-approved lift plan authorizes internal
slice merges. It does not enter the release merge queue or rerun the cumulative
main-based affected lane by default.

### Lift promotion

The frozen lift targeting the release branch. Require: no open dependent slice;
current release base merged into the lift; conflict/uncovered delta receipted;
ordered receipt coverage verified; complete affected lane plus required
integration/migration evidence on the frozen SHA; and one composition-oriented
official review.

## Exactly one official review path

For a direct candidate or lift promotion, prefer local `codex review`; otherwise
use the runtime's PR-based `code-review`, never both. Run the affected lane and
local official review concurrently when practical. Unknown/partial results are
not passes.

A PR-based-only reviewer may require opening a draft after test certification.
Keep it draft until that same SHA passes review. A finding or edit returns only
the affected delta to convergence and creates a new final candidate; valid
unrelated lift receipts remain valid.

## Worklog and identity

The worklog is optional for standalone use. When a caller supplies a worklog or
Project Root, keep its route identity/token and update only material transitions:
mode/frozen SHA, receipt, technically ready, blocker, queued, and merged. Never
switch to an ambient registered or Botlets profile. Invoke `comment-identity`
only immediately before an uncredentialed direct-REST write.

## Workflow

1. **Converge locally.** Finish the bounded implementation/review batch and
   focused checks. Record invariants and residual risk.
2. **Freeze.** Commit intended state, require a clean worktree, and record SHA,
   intended base, and mode.
3. **Certify the mode:**
   - lift slice → focused evidence + accepted delta receipt;
   - direct → complete affected lane + one official candidate review;
   - promotion → receipt-chain verification + complete affected/integration
     evidence + one official composition review.
4. **Push the exact SHA.** Use a normal explicit-SHA refspec; reserve
   `--force-with-lease` for an intentional verified rewrite (never rewrite a
   controlled lift). Verify remote head, then create/update the PR. Use a draft
   only for the PR-based-review exception above.
5. **Report technical readiness.** Re-confirm the current head, required PR
   checks, mergeability, and unresolved review threads. PR-event jobs that skip
   are not evidence; rely on the local certification. Address one complete late
   in-scope finding batch, then recertify the affected candidate. An unrelated
   discovery becomes a focused GitHub issue and does not expand this PR; stop
   only if it makes the candidate unsafe, then ask the owner human for a
   separate worktree job.
6. **Do not wait indefinitely for an external reaction.** If repository rules or
   the human require approval and it is absent, report “technically ready,
   awaiting approval” and end/resume on an actual event. Never manufacture a
   reaction or keep the session alive without a real monitor.
7. **Merge only with authority:**
   - lift slice → merge sequentially into its lift with a real merge commit when
     the approved lift plan authorizes it; record merge SHA in the receipt;
   - direct/promotion → only when the user explicitly asked to merge/land/queue,
     enqueue through the repository's release-branch mechanism with a real merge
     commit and watch until actually merged.
8. **Verify ancestry.** Fetch the actual base and prove the reviewed/frozen SHA
   landed. After promotion, prove every recorded slice head and frozen lift head
   are ancestors of the release branch. Clean up only after verification.

## Technical-ready criteria

- Remote head equals the certified local SHA.
- Required evidence for the chosen mode is current.
- Required PR checks are passing/skipped as designed and mergeability is not
  dirty.
- No known actionable blocker or unresolved required thread remains.
- Residual risks/declines are recorded.

Technical readiness is distinct from human merge authority and actual merge.

## Guardrails

- Never push directly to the release branch, squash-merge, or deploy production
  without explicit authority.
- If the user said no push/PR, stop after local evidence and report.
- Preserve stricter domain gates for production deployment, incidents,
  migrations, or protocol cut-over when they protect irreversible risk.
- Do not delay a user-useful candidate for speculative enterprise hardening,
  abstraction, or unsupported edge cases. Ship the simplest boundary that
  satisfies acceptance and hard invariants.

## Repo config

Run this repo's commands. Read **`AGENTS.md` (else `CLAUDE.md`)** and linked delivery/testing/merge/deploy docs. If absent, infer focused and final lanes from package/build/CI config and offer `comment-init`.

## Comment.io API

Use the active worklog/root and its working Comment.io route first. Resolve and freeze `$BASE` for the whole workflow in this order: the supplied comm's validated final Comment.io origin after any shortlink redirect; the active Comment.io tool/account base URL; an explicitly selected profile's `base_url`; only when no target context exists, `https://comment.io`. A shortlink origin is never `$BASE`; do not switch a staging/custom workflow to production. For direct REST, consult **`$BASE/llms/reference.txt`** only when exact API or recovery detail is needed. Fetch **`$BASE/llms.txt`** only when no current route works or another focused guide is needed. Invoke `comment-identity` only before an uncredentialed direct-REST write; never replace a supplied token or tool/browser/connector identity. Don't restate the live contracts here.

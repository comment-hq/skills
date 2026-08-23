---
name: code-review
description: Review a plan, diff, commit, or PR with one risk-scaled independent panel, then verify and pragmatically disposition its findings. Invoke for `$code-review`, `/code-review`, or when a delivery workflow requests review.
---

# code-review — independent discovery, edited result

Read the repository's `AGENTS.md`/`CLAUDE.md`. Before evaluating any finding or
public feedback, invoke `review-judgment` and follow it. That skill owns
classification, pragmatic reasoning, replies, and thread resolution. This skill
owns the review target, panel, fix loop, and output mode.

Read the host repository's delivery guidance only for a controlled lift or
nontrivial delivery topology. Use only the receipt fields that guidance defines;
otherwise keep the ordinary local disposition and do not invent a receipt.

## Target

Name the artifact, requested behavior, acceptance condition, relevant diff or
plan revision, important invariants, existing evidence, and any sensitive lens.
A working-tree diff, commit delta, or PR delta is enough for routine work. Exact
base/head SHAs are required only when the caller needs an exact-head review or a
controlled-lift receipt.

Lock the panel to that subject. Read surrounding context only to assess impact.
Untouched code is evidence, not a new audit surface. A regression introduced or
exposed by the target remains in scope.

**Configuration ownership:** For deployment or environment-configuration
changes, map every added or changed binding to one authoritative owner across
each affected environment and deploy path. Verify unset behavior. Generated
payloads preserve environment-managed values unless clearing them is explicit
and contract-tested.

For a PR, read its state, base, current head, changed files, prior review
disposition, and unresolved feedback. Stop for a closed PR. Review a draft only
when the caller intentionally chose it as the review surface.

## Beads checkpoint

Every engineering review names the exact shared Bead it serves. Review the
relevant delta against that Bead's acceptance and regression surface. For an
epic, review independently meaningful child deltas as they complete and review
the composed branch only when cross-child interaction could change the result.

Reviewers return candidate findings only and do not claim, update, note, close,
or reopen Beads. The orchestrating agent records the accepted and materially
declined disposition through `scripts/beads` on the exact task or composition.
Preserve the supplied Bead ID and expected base; do not infer them from ambient
Git. Never call `bd` directly, initialize `.beads`, or use GitHub Issues for
review findings.

Gateway reads use the local replica. A successful disposition write publishes
synchronously; an ambiguous result is resolved by rereading the exact Bead, not
by replaying the review mutation.

## Optional Matt replacement

Replace the routine general reviewer with Matt Pocock's complete `code-review`
only when a concrete, line-addressable spec makes requirement traceability
materially valuable, or a non-tool-enforced standards audit is itself an
acceptance concern. Routine work uses exactly one of these lanes. Sensitive work
still adds the targeted reviewer below.

Load the package-qualified skill when available; in a flattened install, use
`npx --yes skills use mattpocock/skills@code-review`. Give it this review's exact
target and acceptance sources. The outer diff, including working-tree changes,
overrides Matt's fixed-point and empty-diff preflight. Preserve its separate
Standards and Spec report, then apply `review-judgment` to its candidates. If
Matt's selected review cannot run, use the general reviewer and report the
fallback.

## Panel

- **Routine:** one strong general reviewer covering correctness, regressions,
  and missed acceptance.
- **Sensitive:** add one independent targeted reviewer for authorization,
  privacy, migrations/storage, protocol compatibility, concurrency, native
  code, destructive behavior, configuration ownership, or credible data loss.
- **Exceptional:** three reviewers only when the blast radius justifies it.

Name every applicable sensitive domain in the brief. One qualified targeted
reviewer may cover several named lenses. Ask reviewers for candidate findings
with a concrete failure scenario, current reachability, impact, code evidence,
and the smallest reasonable fix. Reviewers work independently and never write
code, Beads, or public review comments.

## Review and fix loop

1. Run the selected reviewers independently and wait for the complete panel.
2. Deduplicate the candidates and apply `review-judgment` to every item.
3. If implementation is authorized, fix accepted compatible findings in one
   coherent batch and run the narrowest checks covering that batch.
4. If follow-up review adds value, target only the fix delta and invalidated
   invariants. Do not rerun the whole panel by default.
5. Record the material disposition on the exact Bead when the repository uses
   one.
6. Exit when acceptance and hard invariants hold and no accepted actionable
   blocker remains.

## Output mode

Use a concise local disposition unless the caller explicitly requests or
requires a posted PR review:

```text
reviewed: <scope/diff>
panel: <reviewers/lenses>
accepted: <finding + fix, or none>
material_declines: <concern + pragmatic reason, or none>
checks: <focused evidence>
residual_risk: <material remainder, or none>
```

For posted mode, verify the PR head is still the reviewed head and post one
edited official result: accepted actionable findings with evidence and impact,
or “No actionable issues found” with the scope and lenses reviewed. Never post
raw reviewer output or declined nits. If the run also addresses existing public
feedback, follow `review-judgment` for its replies and thread resolution.

For a controlled lift, add only receipt fields explicitly defined by the host
repository. Routine direct work does not need a formal receipt.

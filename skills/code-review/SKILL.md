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

**Module shape:** When the target creates, grows, or splits a module, or changes
a module's interface or responsibilities, use the existing general reviewer to
check that cohesive behavior and invariants stay local behind a small
interface. Flag implementations that accumulate unrelated reasons to change,
expose internal ordering or state to callers, or split into shallow pass-through
modules that merely move complexity around. Size alone is not a finding: accept
substantial cohesive implementations, and recommend an extraction only when it
gives one place clear ownership of meaningful behavior. This lens never expands
the panel or adds an approval gate.

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

## Architecture applicability

Every engineering review starts with a cheap screen against the host
repository's canonical future-architecture contract, when it has one. In
Comment Docs that contract is `docs/ARCHITECTURE.md`. Read it when the target
may add or remove an architecture node or communication edge, shift durable
authority, reverse a deprecation, alter a latency contract, add a generic
framework or permanent compatibility/dual-system layer, or otherwise diverge
from the contract. An architecture node is a deployable, durable-state owner,
or cross-boundary module, not an ordinary class or file.

When the screen applies, give one independent panel member the exact target
and canonical contract. A targeted reviewer may cover architecture and other
sensitive lenses together; add a separate member only when the scope warrants it.
Return `conforming`, `intended architecture change`, or `unclear`, with the
specific contract clause, code evidence, and explanation. Authorized temporary
migration edges are conforming until their deletion boundary.

For `unclear`, investigate the named uncertainty and ask that reviewer to
reassess the new evidence. Unresolved uncertainty blocks dependent implementation
and landing, not unrelated work. For an intended change, follow the host's
architecture proposal process. In Comment Docs, prepare and independently review
the proposed contract and diagrams, obtain one explicit human acceptance of that
exact baseline, record it on the Bead, then adopt it and resume dependent work.
The existing contract remains authoritative until acceptance. A technical
reviewer cannot provide human acceptance.

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

Spawn native reviewer sub-agents by default, each with fresh context. In Codex,
use `spawn_agent` with `fork_turns="none"`; use the equivalent fresh-context
subagent capability in another host. Inherit the active model unless the human
or host configuration selects another. Give each member only the task's Bead,
requirements, acceptance sources, exact target, relevant invariants, checks
already performed, and assigned lenses. Keep implementer reasoning and other
reviewers' conclusions out of the initial packet.

Pin committed code to full base/head SHAs. Reviewers inspect `git diff <base>
<head>` and `git show <head>:<path>` so concurrent worktree edits cannot change
the subject. For uncommitted work or a plan, first capture a separate snapshot
and its digest; identify that snapshot in the report. Give reviewers read/search
access to surrounding code and tests. Use enforced read-only permissions when
the host provides them; fresh context and a detached checkout alone do not
restrict tool permissions. Otherwise state the permission limitation and require
reviewers to use immutable Git object reads, with no file, task-state, Git, or
external mutations. The coordinator runs any requested behavioral checks.

Launch independent reviewers and required checks together. Wait for actual
completion and report missing coverage on error or cancellation; progress text
is not a result. A native reviewer failure may be retried once with a fresh
agent and the same target. Persistent failure leaves coverage incomplete.

Grok is an optional, explicitly selected second opinion for model diversity or
a host without native subagents. Read [the Grok reference](references/grok.md)
only for that choice. Disclose its static-packet limitation. Do not silently
substitute a different provider for a human-selected reviewer.

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
panel: <reviewers/lenses, completed or incomplete>
accepted: <finding + fix, or none>
material_declines: <concern + pragmatic reason, or none>
checks: <focused evidence>
review_cost: <elapsed time and available token usage; unavailable when not exposed>
residual_risk: <material remainder, or none>
```

For posted mode, verify the PR head is still the reviewed head and post one
edited official result: accepted actionable findings with evidence and impact,
or “No actionable issues found” with the scope and lenses reviewed. Never post
raw reviewer output or declined nits. If the run also addresses existing public
feedback, follow `review-judgment` for its replies and thread resolution.

For a controlled lift, add only receipt fields explicitly defined by the host
repository. Routine direct work does not need a formal receipt.

Record elapsed review time, candidate count, accepted findings, and material
misses discovered later on the same Bead. Use observed outcomes to tune panel
size and compare native and optional Grok reviews; do not add a second panel
merely to collect metrics. Never equate reviewer agreement with proof.

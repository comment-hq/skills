---
name: comment-feature
description: >-
  Deliver a defined feature pragmatically through a live Comment.io worklog:
  choose a direct PR or controlled lift, implement bounded deltas, use
  risk-scaled review receipts, validate the right boundary, and drive the result
  to a technically ready PR. Invoke as `$comment-feature` / `/comment-feature`,
  or when asked to build/add/implement a feature with a watchable, steerable
  record. Works identically under Codex and Claude Code.
---

# comment-feature — bounded feature delivery through a comm

Use this for a feature whose goal and acceptance are defined. Use
`comment-spec` when a material goal or product fork still needs shaping; use
`comment-prototype` when the human wants to see an exploratory change first.

This skill composes `delivery-methodology`, `worklog`, `drive-plan`,
`review-loop`, `steer`, and `ship`. Before using one, read its full `SKILL.md`
(its `SKILL.md`).

## Project Root and identity

Direct feature work uses its worklog as Project Root. When a Spec or existing
Project Root URL is supplied, preserve it and make the worklog a child. A
prototype promotion reuses and upgrades the existing worklog/branch.

Keep the working Comment.io route and identity for every created artifact,
edit, and comment. Invoke `comment-identity` only immediately before an
uncredentialed direct-REST write. Never switch to an ambient registered or
Botlets profile.

## Workflow

1. **Choose topology before editing.** Read `delivery-methodology` plus the
   repo's `AGENTS.md`/`CLAUDE.md` and linked delivery/testing docs. Record one:
   - direct task branch for a complete independently shippable change; or
   - controlled lift for foundational work with unsafe intermediate states.

   Feature flags require a clean bounded activation seam. Do not use them to
   preserve two architectures, dual writes, duplicated state, or broad
   compatibility scaffolding.
2. **Open or inherit one worklog.** Put the plan in its body unless a genuinely
   multi-slice initiative benefits from a separate Plan comm. Post the material
   review/decision points. @mention the relevant human only when the active route exposes a valid handle;
   otherwise make it a general comment, hand the human the worklog URL directly,
   and never invent a handle.
3. **Understand the affected system.** Use read-only explorers when parallel
   investigation will reduce uncertainty. Record conclusions, not transcripts.
   Start from the real user journey and implement the simplest useful behavior
   that can validate whether users love it. Do not add speculative enterprise
   hardening, abstraction, or edge-case machinery without evidence or a current
   requirement.
4. **Plan bounded delivery slices.** Each has acceptance, explicit base/head
   intent, invariants, focused evidence, and promotion dependency. Phases may
   organize work but are not automatic review, staging, or steering gates.
   Consider alternatives only for a material choice; record the decision and
   rejected option briefly.
5. **Review the plan proportionally.** Skip review for an obvious routine plan.
   Otherwise use one reviewer; add a sensitive-risk lens only when warranted.
   Do not run fresh panels until silent. An inherited approved Spec is the
   non-technical design; do not recreate it.
6. **Execute with `drive-plan`.** Implement one bounded delta at a time, run
   focused checks, update the worklog at material milestones, and invoke
   `review-loop` only at a delivery-slice or changed-invariant boundary.
7. **Record receipts.** A lift worklog keeps the ordered receipt ledger required
   by `delivery-methodology`. A direct candidate records its final base/head,
   evidence, findings, declines, and residual risk.
8. **Ship the right boundary.** Use `ship` in direct, lift-slice, or
   lift-promotion mode. Direct candidates and frozen promotions get complete
   affected certification plus one official review; lift slices get focused
   delta evidence and receipts. Stop at technically ready unless merge authority
   is explicit; when it is, merge and verify ancestry.

## Pragmatic done

The feature boundary is done when acceptance passes, required evidence passes,
no known severity-blocking defect remains, mandatory repo rules hold, and
residual risks/follow-ups are recorded. Optional polish and unrelated cleanup
become follow-ups.

Keep reviews and fixes locked to the declared feature boundary. Unrelated bugs
follow `delivery-methodology`'s issue-and-continue protocol; never turn this
feature branch into a surprise cleanup job.

## Outputs

- One current Project Root/worklog with topology, plan, status, decisions,
  receipts, open questions, and PR links.
- A technically ready direct PR, lift-slice PR, or final promotion PR.
- Separate design/Plan/ADR comms only when a real audience or durable
  architecture decision needs them. A proposed ADR becomes accepted only after
  the change reaches the release branch.

## Content vs comments

Current plan, status, decisions, receipts, summary, and open questions belong in
the body. Review batches, steering exchanges, and escalations belong in concise
comments. Do not post one comment per reviewer.

## Repo config

Read **`AGENTS.md` (else `CLAUDE.md`)** and its linked delivery/testing docs for
topology, focused checks, final certification, PR/merge, and preview rules. If
missing, infer the safe minimum and offer `comment-init`.

## Comment.io API

Use the current worklog/Project Root and its working Comment.io route first. Resolve and freeze `$BASE` for the whole workflow in this order: the supplied comm's validated final Comment.io origin after any shortlink redirect; the active Comment.io tool/account base URL; an explicitly selected profile's `base_url`; only when no target context exists, `https://comment.io`. A shortlink origin is never `$BASE`; do not switch a staging/custom workflow to production. For direct REST, consult **`$BASE/llms/reference.txt`** only when exact API or recovery detail is needed. Fetch **`$BASE/llms.txt`** only when no current route works or another focused guide is needed. Invoke `comment-identity` only before an uncredentialed direct-REST write; never replace a supplied token or tool/browser/connector identity. Don't restate the live contracts here.

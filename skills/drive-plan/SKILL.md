---
name: drive-plan
description: >-
  Drive a multi-phase implementation plan to completion through a Comment.io
  Plan/worklog or local Markdown plan. Uses phases as execution organization,
  not automatic gates; validates focused deltas, invokes bounded risk-scaled
  review at delivery-slice or changed-invariant boundaries, keeps the plan
  current, and steers only on real decisions. Invoke as `$drive-plan` /
  `/drive-plan`, or when asked to execute a phased plan autonomously. Works
  identically under Codex and Claude Code.
---

# drive-plan — execute to acceptance, not endless polish

Read `delivery-methodology`, the repo's `AGENTS.md`/`CLAUDE.md`, and linked
delivery/testing docs before implementation. Preserve a supplied Project Root.
Use the supplied Plan comm/file; create a separate Plan via `worklog` only when
the initiative's complexity benefits from one.

## Source of truth

Keep scope, acceptance, delivery slices, topology, decisions, material status,
receipts, and remaining risks current in the Plan/worklog body. Put review batch
summaries, steering exchanges, and escalations in comments. Local-file mode
keeps both current state and a concise evidence log in the file.

Keep the working Comment.io route/identity. Invoke `comment-identity` only
immediately before an uncredentialed direct-REST write; never switch to an
ambient registered or Botlets identity.

## Operating rules

- Make reasonable implementation decisions and record only material ones.
- Work one bounded delta at a time with an explicit base and intended head.
- Optimize for the simplest user-useful implementation; do not add speculative
  enterprise hardening, abstraction, or hypothetical edge-case machinery.
- Run the narrowest useful checks while editing.
- A phase is not automatically a review, staging, steering, or artifact gate.
- Review at a delivery-slice boundary, when a sensitive invariant changes, or
  when uncertainty makes review useful.
- Update the worklog at material milestones, not every command or minor edit.
- Stop when acceptance/evidence hold and no known severity blocker remains;
  record optional polish and unrelated cleanup as follow-ups.

## Delta loop

For each delivery slice or direct candidate:

1. Normalize scope, acceptance, invariants, base SHA, topology, and evidence.
2. Implement the smallest coherent delta that satisfies that boundary.
3. Run focused checks. Use staging/preview only when deployed behavior adds
   material evidence.
4. Update the plan with the real outcome and remaining risk.
5. When review is warranted, invoke `review-loop` with explicit base/head and
   risk tier. Lock it to the declared subject and delta, fix one complete batch,
   and record its receipt. Route unrelated discoveries to a GitHub issue per
   `delivery-methodology`; do not absorb them into the slice.
6. Poll `steer` before an irreversible/materially ambiguous decision, after a
   long autonomous stretch, or at a delivery boundary. Continue when no real
   decision blocks useful work.
7. Mark the boundary complete when acceptance and required evidence pass, no
   known blocker remains, mandatory repo rules hold, and residual risks are
   explicit.
8. Move to the next slice or hand the completed boundary to `ship`.

Normal work gets at most two finding-bearing review rounds. Repeated findings
trigger redesign, targeted proof, residual-risk recording, or human escalation.

## Lift execution

For a controlled lift, keep the ordered receipt ledger in the Project Root,
merge slices sequentially into the lift with real merge commits, sync the release
base periodically, and use `delivery-methodology`'s freeze/coverage/promotion
barrier. Do not let a late slice land after promotion begins.

## Stop conditions

Stop for a human only when a new fact materially changes the goal/feasibility,
or when an external action, permission, secret, or product decision blocks all
useful work. Update the current-state body first and ask one crisp question.

## Composes

Read the full `SKILL.md` before using
`delivery-methodology`, `worklog`, `steer`, `review-loop`, or `ship`.

## Repo config

Run the repo's commands, not hardcoded ones. Read `AGENTS.md` (else
`CLAUDE.md`) and linked delivery/testing/deploy docs. If missing, infer focused
checks and final certification from package/build/CI config and offer
`comment-init`.

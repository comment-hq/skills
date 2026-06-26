---
name: drive-plan
description: >-
  Drive a multi-phase plan to completion autonomously — ideally a Comment.io
  "Plan" comm (falling back to a local Markdown plan file) as the living source
  of truth. Implements each phase, validates locally and on staging where
  possible, keeps the plan in sync, runs `$review-loop` at phase boundaries, and steers
  to a human when a decision shouldn't be made alone. Composes worklog/steer/review-loop
  and is the execution engine `comment-feature` delegates to. Invoke as
  `$drive-plan` / `/drive-plan`, or when asked to execute a phased plan
  autonomously. Works identically under Codex and Claude Code.
---

# drive-plan — the phased-plan execution engine

Drive one multi-phase plan to completion, moving through every phase autonomously until the plan is done or a stop condition is reached. This is a **generic, reusable engine**: use it standalone on any phased plan, and note that `comment-feature` / `comment-bug` delegate their execution step to it.

## Source of truth — prefer a Plan comm

The plan is the living source of truth for scope, current state, validation evidence, and remaining work. Prefer a **Comment.io Plan comm** so humans can watch and steer; fall back to a local Markdown plan file only when no Comment.io credentials are available or the user asked for a local file.

- Given a Plan comm URL/slug → drive that comm.
- Given a Markdown plan file → drive that file.
- Given a plan but no comm, and credentials exist → open one via `worklog` (Plan shape) and drive it.
- Given a Project Root URL by `comment-feature` / `comment-bug` → preserve it. Any Plan comm you create is a child with `Project Root: URL` near the top and a link from the root. Standalone `drive-plan` does not create a Project Root just for itself.

**Identity.** In comm mode, every Plan comm that `drive-plan` creates goes through `worklog`, so run `comment-identity` before the first write and use that same session-scoped ethereal handle for plan edits, evidence comments, and steering comments. If a Plan comm URL/share token was supplied, use that token for that existing doc; do not switch to an ambient registered profile, a Botlets bot profile, or a different ethereal handle mid-task. Markdown-file mode makes no Comment.io writes.

**Where things go** depends on the mode:
- **Comm mode** (preferred): phase tasks, acceptance criteria, status, decisions, and scope changes are **document body**, kept in sync as you go (check `- [x]` boxes, update status). Every `$review-loop` round, steering exchange, validation-evidence note, and escalation is a **comment** — a list or short lines, never one paragraph. If a Project Root exists, keep bulky evidence in the Plan comm/comment stream and add only short summaries or links to the root.
- **Markdown-file mode** (no comm): everything goes **in the file** — update the phase/status/decisions in place, and record validation evidence + `$review-loop` round summaries in a "Log" section of the file. Do **not** create a Comment.io doc you weren't given; steering in this mode is direct to the user.

## Operating rules

- Keep all phase status, scope changes, decisions, assumptions, validation results, and follow-ups in the plan body — revise it whenever reality changes (new constraints, reordered work, added/removed tasks, shifted scope).
- Make reasonable implementation decisions without asking; record meaningful assumptions and keep moving.
- Don't declare a phase done just because its listed tasks are checked — hunt for unfinished work, test gaps, edge cases, stale plan text, and follow-up fixes first.
- Work through all phases; stop only on a stop condition below.

## Phase loop

For each phase:

1. **Normalize** the phase into concrete tasks in the plan body.
2. **Implement** incrementally, keeping edits scoped to the phase.
3. **Validate locally** — run the repo's **`fast`** lane (see **Repo config**) for mid-phase iteration, and the **`full`** lane at a deliverable phase boundary, over ad-hoc checks (tests, builds, linters, smoke tests, or focused scripts).
4. **Validate on staging** when the project supports it and the change benefits from deployed verification. Never deploy to production unless the repo/user instructions explicitly allow it.
5. **Prove it works** before moving on; capture the commands, URLs, logs, or manual checks as evidence (comm mode → a **comment**; file mode → the plan's "Log" section).
6. **Update the plan** with the real outcome, plan changes, and remaining risks (the comm body, or the file).
7. **`$review-loop`** the phase result (plan + diff + evidence). Record each round as evidence (comm mode → a **comment**; file mode → the "Log" section).
8. If `$review-loop` returns real issues: fix in priority order, update the plan, revalidate, and re-run `$review-loop` until clean.
9. **`steer` checkpoint** — before an irreversible or ambiguous step, and at phase boundaries, get human input on decisions you shouldn't make alone (comm mode → poll the comm via `steer` and pass the Project Root URL when one exists; file mode → ask the user directly) and escalate.
10. Mark the phase complete only after implementation, validation, plan update, and a clean `$review-loop` round.

## Autonomy standard

At every phase boundary, ask whether there is another useful action available without user input — strengthen validation, inspect logs/errors, test a realistic workflow, update stale plan text, close obvious quality gaps, reduce known risk, document residual risk, or prepare the next phase to start cleanly. If any exists, do it before moving on or stopping.

## Repo config

This skill is repo-agnostic — run *this* repo's commands, not hardcoded ones. Read **`AGENTS.md` (else `CLAUDE.md`)** and its linked **`docs/TESTING.md`** for the **`fast`** lane (quick iteration) and **`full`** lane (the pre-push gate), plus the guide's PR/branch/merge and deploy/preview norms. If `docs/TESTING.md` is absent, infer lanes from `package.json` / `Makefile` / CI and offer **`comment-init`** to scaffold the config.

## Composes

- **`worklog`** — to open the Plan comm when one isn't supplied.
- **`steer`** — for human checkpoints and escalations. Polling is the canonical check; push wake may resume the session only when the caller armed it through `comment-identity` or a daemon-backed workflow.
- **`$review-loop`** — the review-loop gate at every phase boundary.
- Optionally **`ship`** — when a phase ends in a deliverable PR that should reach merge-ready.

Read a composed skill's full `SKILL.md` before relying on it — naming it here doesn't auto-load its contract.

## Stop conditions

Stop and ask the human only when:

- Something fully unexpected drastically changes the feasibility, direction, cost, or risk of the plan — proceeding would amount to choosing a new plan.
- You've exhausted the autonomous work and need a user action, secret, permission, product decision, or explicit approval that can't be reasonably inferred.

When stopping, update the plan body first with the current state, evidence, the blocker, and the exact decision or action needed — then escalate via `steer`. If a Project Root exists, the pause/final handoff ends with `Project Root: URL`.

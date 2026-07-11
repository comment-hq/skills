---
name: comment-feature
description: >-
  Deliver a feature end-to-end through a live Comment.io worklog comm — plan,
  request review points, design, review-loop the plan, implement while listening
  for human steering, and drive to a merge-ready PR. Outputs a merge-ready PR plus
  a decision history, a non-technical feature design, and (for architecture-level
  changes) a proposed architecture decision record, all as comms. Invoke explicitly as `$comment-feature` / `/comment-feature`,
  or when asked to build/add/implement a feature with a watchable, steerable record.
  Replaces the retired feat + feature-dev. Works identically under Codex and Claude Code.
---

# comment-feature — feature delivery through a comm

Full feature delivery whose **working memory, decision history, and human-steering channel all live in one worklog comm**. Replaces the retired `feat` + `feature-dev`; harness-generic (Codex or Claude Code).

> For an **un-shaped idea** — where the goal, scope, or product fit isn't settled yet — start with **`/comment-spec`** first. It shapes the idea into a crisp PM spec (clear goal, fits the app, fewest new concepts, a measurement plan) and then invokes this skill with that spec. Use `comment-feature` directly when the feature is already well-defined.

> For a quick **"let me see it first"** change, start with **`/comment-prototype`** — implement fast and show it, skipping the review-loop + PR gate; later promote it *into* this skill, reusing the same worklog/branch.

**Project Root.** Direct `comment-feature` uses its worklog as the Project Root. If invoked from `comment-spec` with a Spec comm / Project Root URL, the Spec doc remains the Project Root; create the feature worklog, Plan, design, and ADR docs as children with `Project Root: URL` near the top, and link them from the Spec root. Do not create a second root.

Composes the primitives, engine, and gates: **`worklog`** (the comm), **`steer`** (human-in-the-loop), **`drive-plan`** (the phased execution engine that does the actual end-to-end build), **`review-loop`** (review gate), **`ship`** (PR lifecycle), and **`comment-init`** (architecture refresh). All are sibling skills in this bundle; this skill is also reachable via the **`comment-dev`** front door.

**Before using a composed skill, read its full `SKILL.md`** — naming a skill here does not auto-load its contract, and the sub-skills carry mandatory rules (`drive-plan`'s phase loop, the `ship` review/PR gate, `worklog` update rules, `comment-init` idempotency) you must follow.

## Preconditions

- Work in a task worktree on a feature branch (this repo's convention is a `feat/...` prefix off fresh `origin/main` — see **Repo config** and the guide) — never on `main`. If you're on `main`, create the worktree first.

## Workflow

1. **Open or inherit the Project Root.** If a Spec comm / Project Root URL was supplied, keep that Spec doc as root and open the feature worklog (`worklog`) as a child with `Project Root: URL` near the top. Otherwise open the worklog using a session-scoped ephemeral identity from `comment-identity`; the worklog is the Project Root, so patch its own `Project Root: URL` line after creation. **Promotion from `comment-prototype`:** if you were handed a prototype's worklog `share_url` and branch, reuse *that* worklog as the Project Root — upgrade its light note in place to the full worklog shape (don't open a second) — and keep building on its branch. The worklog identity is the **flow identity**: use that same session-scoped ephemeral handle for feature-created Plan, design, ADR/proposed-ADR comms, status edits, and comments. If a supplied Project Root/share URL gives only a per-doc token, use that token for the existing root, but do not create new child docs as an ambient registered handle or any Botlets bot profile. For multi-phase work, also create a separate **Plan comm** (phased) as a child and link it from the worklog header; for small features the Plan can live in the worklog body (then drop the header Plan link). Post a **comment @-mentioning the relevant human(s)** naming the review points where you'll pause for input, and record those pause points in the Plan checklist.
2. **Understand**: fan out read-only explorers over the affected code; record findings in the worklog.
3. **Design**: consider 2–3 approaches; pick one and record it in the **Decision log** with the rejected alternatives. Draft the **non-technical design comm** now (so non-engineers can react before work is sunk), add `Project Root: URL` near the top when a root exists, and link it from the worklog/root; update it after implementation if needed. If a choice is architecture-level, flag it for an ADR (see `comment-init`).
4. **Review the plan** by explicitly invoking **`$review-loop`** on the plan itself (it runs only on explicit request — this step *is* that request; skip for genuinely trivial changes). Post **each review round as a comment** on the worklog; fix real findings; re-run until clean.
5. **Execute via `drive-plan`** — hand the plan and Project Root URL (when one exists) to `drive-plan`, the engine that does the actual end-to-end build: it implements each phase, validates locally and on the branch preview, runs `$review-loop` at every phase boundary, keeps the plan in sync, and runs `steer` checkpoints (folding in human @mentions, escalating decisions you shouldn't make alone). Pass the **separate Plan comm** if you made one in step 1; for a small feature whose Plan lives in the worklog body, point `drive-plan` at the worklog's Plan section instead — don't create an extra Plan comm just to satisfy this step. This *is* the "how you build the feature" step.
6. **Ship** with `ship` (pass it the worklog `share_url` and Project Root URL when distinct) — push the branch, open the PR, drive to merge-ready through the smart review gate, posting state transitions to the worklog.
7. **Finalize the outputs** (below) — most are created earlier; confirm they're current and cross-linked.

## Outputs (all linked from the Project Root; direct feature flows also link from the worklog)

- **Merge-ready PR.**
- **Decision history** — the worklog's decision log + comment stream.
- **Non-technical feature design** — a separate comm for non-engineers (problem · who · what changes · rollout · success). Plain language, no internals.
- **Architecture (default output is a *proposed* ADR)** — for any architecture-level decision, the deliverable at the merge-ready stop is a **proposed ADR**; the living Overview is **not** touched pre-merge (it describes "what is true now"). Refreshing the Overview and accepting the ADR is a **post-merge follow-up** — only if/when the change actually merges, run `comment-init` against updated `main` (it maps the codebase from a fresh checkout, so it does **not** need the task worktree `ship` may have cleaned up).

## Content vs comments

Plan, status, decisions, summary, open questions → worklog **body**. Every review-loop round, steer, and escalation → **comments** (lists / short lines). Keep the Project Root scannable: no bulky evidence, FYI detail, or review transcripts in the root body.

## Repo config

This skill is repo-agnostic — run *this* repo's commands, not hardcoded ones. Read **`AGENTS.md` (else `CLAUDE.md`)** and its linked **`docs/TESTING.md`** for the affected-tests lane used for iteration, pre-push, PR creation, and merge-ready gates, plus the guide's PR/branch/merge and deploy/preview norms. If `docs/TESTING.md` is absent, infer an affected/local lane from `package.json` / `Makefile` / CI and offer **`comment-init`** to scaffold the config.

## Comment.io API

**Read `$BASE/llms.txt`** as the current docs index, then **read `$BASE/llms/reference.txt`** for the exact API and auth contract. `$BASE` is the target Comment.io host from the doc URL or session identity (default `https://comment.io`). Profile files may help discover a host, but write identity follows `comment-identity` or a supplied doc token, not ambient profile selection. Don't restate its contracts here.

**Content vs comments (team convention).** The *answer* → document **body**; *how you got there* (review-loop rounds, steering, escalations) → **comments**, as lists / short lines.

## Templates

- **Worklog** → see the `worklog` skill.
- **Plan (phased)** → title + `Project Root: URL` + meta → `## Goal & acceptance` → `## Phase N — <name>` (tasks `- [ ]` + acceptance; review-loop at each boundary as comments) → `## Risks` → `## Related`.
- **Non-technical design** → title + `Project Root: URL` → `## The problem` → `## Who this is for` → `## What changes` (before/after table) → `## Rollout` → `## How we'll know it worked` → `## Out of scope`.

Follow the skeletons above for each artifact.

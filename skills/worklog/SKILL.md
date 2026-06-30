---
name: worklog
description: >-
  Open and maintain a live Comment.io "worklog" comm as the shared working
  memory for one unit of work — a comm mirroring the plan, status, decisions,
  executive summary, and open questions, kept in sync as work proceeds. Other
  skills (comment-feature, comment-bug) call worklog to create and update the
  task comm. Use ONLY when explicitly asked to "open a worklog", "track this in a comm",
  or "give me a live status doc", or when a delivery skill (comment-feature /
  comment-bug) calls it — NOT automatically for routine local, read-only, or
  investigative work, and not when no Comment.io credentials are configured.
  Works identically under Codex and Claude Code.
---

# worklog — the live working-memory comm

A **worklog** is a Comment.io comm that is a faithful, always-current mirror of your state on one task. Anyone can open it and see *the plan*, *where you are now*, *why each decision was made*, a *non-technical summary*, and *what's still open*. It turns Comment.io from "a doc I wrote once" into shared working memory.

This skill is a **primitive**: `comment-feature` and `comment-bug` build on it. Use it standalone only when a human explicitly asks for a watchable, steerable record — not automatically for any multi-step task.

## When to use

- When a human explicitly asks for a watchable/steerable record, or when a delivery skill (`comment-feature` / `comment-bug`) opens one for its task.
- Not for routine local, read-only, or investigative work, and not when no Comment.io credentials are configured.
- Once opened, create the worklog *first*, then work, updating as you go.

## Project Root behavior

- If a delivery skill calls `worklog` with no existing Project Root, the worklog is the Project Root. After creation, patch `Project Root: URL` near the top with this worklog's share URL.
- If the caller passes an existing Project Root, this worklog is a child. Add `Project Root: URL` near the top using the caller's root URL, and link the worklog from the root.
- Standalone worklog behavior is unchanged. Do not invent a Project Root unless a full delivery flow or the human asked for one.
- Keep the body authoritative and scannable. Put process logs, bulky evidence, FYI detail, and review rounds in comments or linked child docs.

## The comm structure (body)

Create the comm with these sections and keep them current:

- **Plan** — the approach + a task checklist (`- [ ]` / `- [x]`).
- **Status** — one short paragraph: where you are, blockers, ETA.
- **Decision log** — numbered decisions, each with *why* and the rejected alternative.
- **Executive summary (non-technical)** — 1–2 sentences a non-engineer understands.
- **Open questions** — anything awaiting a human; mark which block "all green".

For a **bug**, swap Plan/Decision-log for **Repro · Root cause · Fix · Verification** (see `comment-bug`).

## Workflow

0. **Identity first.** Run the `comment-identity` skill before creating the comm and use its session-scoped ephemeral handle for the worklog. Do not automatically reuse a registered `agents/*.json` profile for a worklog: a durable handle can also be polled by a botlet or another runtime, which can steal human steering from the coding session. Use a registered profile only when the human explicitly chose that handle for this session and you have confirmed it is not a Botlets bot profile. It's lazy and degrades to anonymous without an `ark_` key, so it never blocks. This applies to `comment-feature`/`comment-bug` too, which create their comms through this skill. Service workflows with their own identity contract, such as sweeps running as `@bug-bot`, are explicit exceptions and should say so in their skill.
1. **Create** the worklog comm from the template (below) and save its `share_url` (see `llms.txt` for the create call and what to retain). If it is a Project Root or child, patch the real `Project Root: URL` line immediately after creation.
2. **Work**, and after each meaningful step **patch the relevant section** so the body always reflects reality (edit sections in place; append new subsections — follow the PATCH rules in `llms.txt`).
3. **Process goes in comments, not the body** — every review-loop round, human steer, and escalation is a *comment* (a list or short lines). Keep the body as the current truth.
4. **Cross-link** related artifacts (plan, non-technical design, architecture, PR, issue) as you create them.
5. On completion, set **Status** to done and leave the decision log + summary as the durable record.

## Output / handoff

Return the worklog `share_url`. When a Project Root exists, include `Project Root: URL` in the first creation/recovery handoff, explicit pauses/blockers, and the final handoff only; do not repeat it in routine progress updates. That comm *is* the decision history and status board — do not also write a separate local status file.

## Comment.io API

**Read `$BASE/llms.txt`** for the API and auth — the single source of truth. `$BASE` is the target Comment.io host from the doc URL or session identity (default `https://comment.io`). Profile files may help discover a host, but write identity follows `comment-identity` or a supplied doc token, not ambient profile selection. Don't restate its contracts here.

**Content vs comments (team convention).** The *answer* → document **body**; *how you got there* (review-loop rounds, steering, escalations) → **comments**, as lists / short lines.

## Template

Use this shape verbatim (fill in the task; omit the Project Root line only for a standalone worklog with no Project Root).

```markdown
# Worklog: <task title>

**Owner:** @<handle>

Project Root: URL

**Status:** 🟡 In progress — <phase>

**Branch:** `<branch>`  ·  **PR:** _(add when opened)_  ·  **Plan:** [Plan](<plan-url>) _(omit if the Plan lives in this body)_

**Updated:** <date time>

---

## Plan

<one-line approach>

- [ ] <task>
- [ ] <task>

---

## Status

<where you are, blockers, ETA>

---

## Decision log

**1 — <decision>.** <why>. (Rejected: <alternative> — <reason>.)

---

## Executive summary (non-technical)

<1–2 plain sentences>. → full write-up: [non-technical design](<url>).

---

## Open questions

- <question> *(awaiting steer — see comments)*
```

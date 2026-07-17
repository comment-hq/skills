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
  investigative work.
  Works identically under Codex and Claude Code.
---

# worklog — the live working-memory comm

A **worklog** is a Comment.io comm that is a faithful, current mirror of the
material state of one task: topology, plan, status, decisions, receipts,
non-technical summary, and open questions. It is shared working memory, not a
command transcript.

This skill is a **primitive**: `comment-feature` and `comment-bug` build on it. Use it standalone only when a human explicitly asks for a watchable, steerable record — not automatically for any multi-step task.

## When to use

- When a human explicitly asks for a watchable/steerable record, or when a delivery skill (`comment-feature` / `comment-bug`) opens one for its task.
- Not for routine local, read-only, or investigative work.
- Once opened, create the worklog *first*, then work, updating as you go.

## Project Root behavior

- If a delivery skill calls `worklog` with no existing Project Root, the worklog is the Project Root. After creation, update `Project Root: URL` near the top with this worklog's human-openable URL.
- If the caller passes an existing Project Root, this worklog is a child. Add `Project Root: URL` near the top using the caller's root URL, and link the worklog from the root.
- Standalone worklog behavior is unchanged. Do not invent a Project Root unless a full delivery flow or the human asked for one.
- Keep the body authoritative and scannable. Put process logs, bulky evidence, FYI detail, and review rounds in comments or linked child docs.

## The comm structure (body)

Create the comm with these sections and keep them current:

- **Plan** — the approach + a task checklist (`- [ ]` / `- [x]`).
- **Status** — one short paragraph: where you are, blockers, ETA.
- **Decision log** — numbered decisions, each with *why* and the rejected alternative.
- **Review receipts** — for controlled lifts or other bounded certified deltas;
  keep exact SHAs, evidence, findings/declines, residual risk, and links to any
  separately filed out-of-scope discoveries.
- **Executive summary (non-technical)** — 1–2 sentences a non-engineer understands.
- **Open questions** — anything awaiting a human; mark which block "all green".

For a **bug**, swap Plan/Decision-log for **Repro · Root cause · Fix · Verification** (see `comment-bug`).

## Workflow

0. **Route and identity first.** Use the first working Comment.io route and keep the identity that route already carries. Reuse a supplied comm token instead of replacing it. Only when the chosen path is direct REST and no supplied per-doc token or human-selected registered identity authorizes the write, run `comment-identity` immediately before creating the comm and reuse that session-scoped Ephemeral handle for later direct-REST worklog writes. Do not silently borrow an ambient `agents/*.json` profile: a durable handle may also be polled by a botlet or another runtime. Service workflows with their own explicit daemon-backed identity, such as sweeps running as `@bug-bot`, remain exceptions.
1. **Create** the worklog comm from the template (below) through the active route and save the human-openable URL that route returns or displays. For direct REST only, `$BASE/llms/reference.txt` defines the create call and `share_url` to retain. If it is a Project Root or child, update the real `Project Root: URL` line immediately through the same route.
2. **Work**, and update through the same route on material state changes:
   topology choice, delivery-slice start/merge, material decision, blocker,
   receipt, frozen candidate, PR, and final outcome. Do not write after every
   command or minor edit. For direct REST, follow `$BASE/llms/reference.txt`.
3. **Process goes in comments, not the body** — summarize one complete review
   batch, steering decision, or escalation in a concise comment. Do not post one
   comment per reviewer or round. Keep the body as current truth.
4. **Cross-link** related artifacts (plan, non-technical design, architecture, PR, issue) as you create them.
5. On completion, set **Status** to done and leave the decision log + summary as the durable record.

## Output / handoff

Return the human-openable worklog URL (`share_url` for direct REST). When a Project Root exists, include `Project Root: URL` in the first creation/recovery handoff, explicit pauses/blockers, and the final handoff only; do not repeat it in routine progress updates. That comm *is* the decision history and status board — do not also write a separate local status file.

## Comment.io API

Use the current comm and its working Comment.io route first. Resolve and freeze `$BASE` for the whole workflow in this order: the supplied comm's validated final Comment.io origin after any shortlink redirect; the active Comment.io tool/account base URL; an explicitly selected profile's `base_url`; only when no target context exists, `https://comment.io`. A shortlink origin is never `$BASE`; do not switch a staging/custom workflow to production. For direct REST, use the supplied token or selected task identity and consult **`$BASE/llms/reference.txt`** only when exact API or recovery detail is needed. Fetch **`$BASE/llms.txt`** only when no current route works or another focused guide is needed. Invoke `comment-identity` only immediately before an uncredentialed direct-REST write; never replace a tool/browser/connector identity or supplied token. Don't restate the live contracts here.

**Content vs comments (team convention).** The *answer* → document **body**; *how you got there* (review-loop rounds, steering, escalations) → **comments**, as lists / short lines.

## Template

Use this shape verbatim (fill in the task; omit the Project Root line only for a standalone worklog with no Project Root).

```markdown
# Worklog: <task title>

**Owner:** <@handle when the active route exposes one; otherwise Anonymous session>

Project Root: URL

**Status:** 🟡 In progress — <phase>

**Topology:** direct / controlled lift  ·  **Branch:** `<branch>`  ·  **PR:** _(add when opened)_  ·  **Plan:** [Plan](<plan-url>) _(omit if the Plan lives in this body)_

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

## Review receipts

<exact base/head/merge SHAs + scope, invariants, checks, findings/declines, residual risk; omit for work with no receipts>

---

## Executive summary (non-technical)

<1–2 plain sentences>. → full write-up: [non-technical design](<url>).

---

## Open questions

- <question> *(awaiting steer — see comments)*
```

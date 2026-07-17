---
name: comment-dev
description: >-
  The front door for pragmatic engineering delivery through Comment.io. Talk to
  it about dev work in plain language and it picks the right path: shape a rough
  idea (`comment-spec`), build a defined feature (`comment-feature`), fix a
  defect (`comment-bug`), or try a fast change you'll validate later
  (`comment-prototype`). Invoke as `$comment-dev` / `/comment-dev`, or when
  someone describes coding work — "build / add / implement", "fix / it's
  broken", "let me try / quick tweak / show me", "should we / scope this" —
  without naming a specific path. When the user already named a specific skill,
  let that one fire directly. Works identically under Codex and Claude Code.
---

# comment-dev — the engineering front door

One thing to talk to. Describe the work; `comment-dev` classifies the intent and
routes to the path that fits, so you don't have to remember which `comment-*`
skill to call. It is a thin **dispatcher** — it does no delivery itself; it picks
a path and hands off.

Every route follows the same startup bias: get the simplest useful change in
front of real users, learn whether they love it, and add complexity only when
evidence or a hard invariant requires it.

> Not a Comment.io *document* skill. "Make me a comm / read this doc / edit this
> comm" is the **`comment`** skill. `comment-dev` is for *building, fixing, and
> shaping software*.

## Routing

Classify the request, state which path you're taking and why (one line), then run
that skill (read its full `SKILL.md` first — naming it here does not load it):

| The request looks like… | Route to | Why |
|---|---|---|
| A rough/unshaped idea; goal, scope, or product fit unsettled; "should we…", "what if…", "scope this", "is this worth doing" | **`comment-spec`** | Shape it into a crisp spec first; it then invokes `comment-feature`. |
| A defined feature; "build / add / implement / wire up X", clear what success is | **`comment-feature`** | Choose direct/lift topology → build bounded deltas → ship. |
| A defect/regression; "X is broken", "this throws", "stopped working", "wrong output" | **`comment-bug`** | Reproduce → failing test → fix → verify. |
| A fast, small, or exploratory change to *look at first*; "let me try", "quick tweak", "just show me", "spike / prototype this", UI nudges before committing to the gate | **`comment-prototype`** | Implement fast, show it, skip the heavy gate; promote later. |
| Make / read / edit a Comment.io doc itself (not code) | **`comment`** | That's a document operation, not a delivery flow. |

### Picking between adjacent paths

- **prototype vs feature/bug:** if the user wants to *see it before investing*,
  or it's a handful of UI/copy tweaks, start with **`comment-prototype`** — it
  promotes into `comment-feature`/`comment-bug` when they like it. If they want
  it real and merge-ready from the start, go straight to feature/bug.
- **spec vs feature:** if you can't yet state the goal and what "done" means in
  one sentence, it's a **spec**. If you can, it's a **feature**.
- **feature vs bug:** new capability → feature; restoring intended behavior →
  bug.

When it's genuinely ambiguous, ask **one** crisp question with your recommended
route — don't guess on a high-cost path. When it's clear, just route and say so.

## What carries across the handoff

- **Identity / worklog.** The chosen skill reuses the working Comment.io route
  and identity already available for the task. It invokes `comment-identity`
  only immediately before an uncredentialed direct-REST write. If the user
  already has a worklog / Project Root URL for this task, pass it through so the
  routed skill reuses it instead of opening a second root.
- **Repo config.** The routed skills read this repo's setup themselves (see
  **Repo config** below); `comment-dev` doesn't need to.
- **Delivery topology.** The routed delivery skill reads
  **`delivery-methodology`** and records direct versus controlled-lift choice
  before implementation. Do not default foundational work to feature flags when
  that would preserve two systems.

## Repo config

`comment-dev` only routes, so it needs no repo specifics. The skills it routes to
read **`AGENTS.md` (else `CLAUDE.md`)** and linked delivery/testing docs, plus
**`delivery-methodology`**. If those are missing, the routed skill infers them or
offers **`comment-init`** to scaffold the repo config.

## Out of scope

`comment-dev` never implements, tests, or ships directly — it delegates. If a
request spans paths (e.g. "spec then build"), route to the *first* one and let
the chain continue (`comment-spec` → `comment-feature`).

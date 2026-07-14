---
name: comment-prototype
description: >-
  Make a small or exploratory change FAST and show it, so you can look before
  committing to the merge-ready gate. Implements quickly, runs only a focused
  check (or none for a pure visual tweak), and surfaces the result in
  the real app — deliberately skipping the `review-loop` gate and the
  PR. When you like it, it promotes the work into `comment-feature` /
  `comment-bug` to harden and ship. Invoke as `$comment-prototype` /
  `/comment-prototype`, or when asked to "just try", "quickly tweak", "spike",
  "prototype", or "let me see X first". Works identically under Codex and Claude
  Code.
---

# comment-prototype — fast change, validate later

For the moments when you want to **see it before paying for it**: a few UI/copy
tweaks, an exploratory spike, a "does this even feel right" change. `comment-prototype`
optimizes for *time-to-look*, not for merge-readiness — it skips the heavy gate
on purpose and hands you something to react to fast.

It is the lightweight, local-only prototype path of the `comment-dev` family. The
merge-ready paths are `comment-feature` and `comment-bug`; this skill **promotes
into them** once the change earns the investment.

## What it deliberately skips (until you promote)

- ❌ the **`review-loop`** review gate
- ❌ opening a **PR** / driving to merge-ready (`ship`)
- ❌ pushing the prototype branch
- ❌ the full worklog ceremony (plan, decision log, review rounds)

## What it still does

- ✅ a **task branch** off fresh `origin/main` (so the work is promotable, never
  lost) — a sensible default is `proto/<name>`, or the repo's branch convention
  (see **Repo config**); never `main`.
- ✅ a **lightweight worklog** note so the change is watchable and the context
  survives into promotion (one short comm: what you're trying + a running list of
  what changed). Use the session-scoped ephemeral handle via `comment-identity`.
  For a genuinely throwaway visual check the user can say "no comm" and you skip it.
- ✅ a focused check for the change, or nothing for a pure visual tweak — see
  **Repo config**.
- ✅ **showing the result in the real app**, which is the whole point.

## Loop

1. **Scope it in one line.** Confirm this really is a fast/exploratory change. If
   it's clearly a real feature or a defect that needs a regression test, say so
   and route to `comment-feature` / `comment-bug` instead (or via `comment-dev`).
2. **Open the branch** (default `proto/<name>` off fresh `origin/main`, or the
   repo's branch convention) and, unless the user opted out, a **light worklog**
   note via `worklog` + `comment-identity`.
3. **Implement fast.** Smallest change that makes the idea visible. Don't gold-plate.
4. **Focused check** (Repo config) — typecheck/build when useful + the nearest test, or
   skip entirely for a pure visual nudge. This catches "it doesn't even compile",
   not "it's production-ready".
5. **Show it.** Surface the change in the real app the repo's way (see **Repo
   config** / the guide): the branch preview (in this repo, `make dev` →
   `https://<worktree>.toofs.us`), a local run, or a screenshot (`/verify`,
   `agent-browser`, or the `run` skill). Capture what you showed in the worklog
   note if one exists.
6. **Iterate with the human.** Fold feedback in and re-show. Stay in this fast
   loop as long as it's still "trying things".
7. **Decide:** keep iterating, drop it (`git`-clean the branch), or **promote**.

## Promote — make it real

When the human likes it, harden the *same branch and worklog* through the normal
merge-ready flow. **Hand the promoted skill the prototype's worklog `share_url` and branch**;
it **reuses that worklog as the Project Root — upgrading the light note in place
to the full shape — instead of opening a second**, and keeps building on the
branch:

- **Feature** → run **`comment-feature`**. It treats the handed-in prototype
  worklog as the root, plans (lightly, since code already exists), runs
  **`review-loop`** on the diff, certifies the final candidate, writes the
  non-technical design, and **`ship`**s to merge-ready.
- **Bug fix** → run **`comment-bug`**: it reuses the worklog as the root, then
  adds the **regression test that fails without the fix** (a prototype skips
  this; a real fix must not), `review-loop`, candidate certification, ship.

Promotion does not restart from scratch — the code, branch, worklog, and context
carry over; it adds the rigor a prototype skipped. Rename the branch to the
repo's `feat/…` / `bug/…` convention as part of promotion when the repo expects
that prefix (see **Repo config**).

## Repo config

Read **`AGENTS.md` (else `CLAUDE.md`)** and its linked **`docs/TESTING.md`** for
focused checks and candidate certification, and the guide's **deploy/preview**
section for how to run/show the app (or the repo's run skill). If
`docs/TESTING.md` is absent, infer a minimal
typecheck/build from `package.json` / `Makefile`, and offer `comment-init` to
scaffold the config.

## Honesty

A prototype is **not validated**. Never describe it as done, tested, or
merge-ready, and never push, open a PR, or merge from this skill — say plainly "this is
a prototype to look at; promote it to make it real."

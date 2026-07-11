---
name: ship
description: >-
  Drive a pull request to merge-ready — running exactly one official code review
  (auto-detected: prefer Codex, fall back to Claude Code), confirming CI, review,
  and approval. **Stops at merge-ready by default**; only enqueues into the merge
  queue, watches the merge, and cleans up the worktree when the user EXPLICITLY
  asks to land/queue/merge. Posts each state transition to the task's worklog comm
  when one is provided. Replaces the retired pristine + land — the single
  PR-lifecycle skill. Invoke as `$ship` / `/ship`, or when asked to finish, land,
  merge, make a PR mergeable, or "make it pristine". Works identically under Codex
  and Claude Code.
---

# ship — one PR lifecycle, runtime-generic

`ship` takes a delivered branch to merged: review gate → green + approved → enqueue → merged → cleanup. It reports each transition to the task's **worklog** comm so the comm closes the loop. Replaces the retired `pristine` + `land` — it is the single PR-lifecycle skill (drive-to-merge-ready *and* the optional land), so "make it pristine" lands here.

## The smart review gate (exactly one)

Run **one** official code review, auto-detecting the runtime — **prefer Codex, fall back to Claude Code, never both.** The two differ in *when* they run: **Codex** reviews the **local diff before any push** (the repo's pre-push gate); **Claude Code's `code-review` is PR-based**, so when Codex is absent you push and open the PR first, then run `code-review` on the PR as the pre-merge gate.

```bash
BASE_BRANCH="$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || echo main)"
if command -v codex >/dev/null 2>&1; then
  # Codex (preferred): local diff review, before push — private, zero Actions minutes
  codex review --base "$BASE_BRANCH"      # or --uncommitted for WIP
  # read the findings from the terminal output; fix real ones, then re-run until clean
elif command -v claude >/dev/null 2>&1; then
  # Claude Code: code-review is PR-based, so this runs AFTER push+PR-create (step 4),
  # not before. There is no bash way to invoke a sub-skill — STOP here, invoke the
  # `code-review` skill (e.g. /code-review) on the open PR, fix findings, re-run until
  # clean, THEN resume ship. Exit so the script never falls through to a pass.
  echo "STOP: run the code-review skill (/code-review) on the open PR, then resume ship." >&2
  exit 1
else
  echo "STOP: neither codex nor claude found — cannot run the review gate. Do not merge; report to the human." >&2
  exit 1
fi
```

Run the gate, then **act on it** — never treat a missing reviewer as a pass. Loop (fix real findings → re-run) until it returns no new actionable issues. Record which gate ran in the worklog. This one official `code-review` is distinct from the in-flight `review-loop` panel (the looped pre-push reviewer gate other skills run); `ship` runs the single official PR review, not that loop.

## Preconditions

The **worklog is optional**. When a caller (`comment-feature` / `comment-bug`) passes a worklog `share_url`, post status to it. When a Project Root URL is also passed, preserve it: detailed PR lifecycle notes go to the worklog, while the root gets only concise state changes, blockers, and the PR link. For a standalone `$ship` on an existing PR with no worklog, skip the comm updates and just report status in the PR and terminal — never block the lifecycle on a missing worklog.

**Identity for worklog updates.** If a caller passed a worklog/root, use that comm's supplied token or the session-scoped ephemeral identity established by the caller for every status comment/edit. Do not choose a registered profile just because one exists locally, and never switch to a Botlets bot profile for a coding-session worklog. If `$ship` is used standalone and must write to a Comment.io doc before any task identity exists, run `comment-identity` first.

## Merge is opt-in — default is "merge-ready", not "merged"

`ship` drives to **merge-ready and stops there** by default. Only proceed to enqueue/merge (step 6) when the user **explicitly** asked to merge/land/queue this PR. A request to "make a PR", "open a PR", or "make it mergeable/pristine" is **not** a merge request — leave merging to the human (per CLAUDE.md). When in doubt, stop at step 5 (PR-state verified) and report the PR as ready.

## Workflow

Under **Codex** the review gate runs **before any push** (local diff), satisfying the repo's pre-push gate so CI is never burned on issues the reviewer would catch. Under **Claude Code** (no Codex), `code-review` is PR-based, so it runs at step 4 on the open PR instead.

1. **Pre-flight (affected)**: run the repo's affected-tests lane (`make check` / `cd cf && bun run test:changed`, per **Repo config**; `docs/TESTING.md`) on the **staged/uncommitted** diff **first**; skip only for genuinely docs-only changes. Once green, commit so the tree is clean (`git status` clean) — don't push or review the wrong HEAD. Record results in the worklog; if a Project Root exists, summarize only pass/fail and blockers there. This same affected lane is the final local test gate before pushing or PRing; do not run a local full suite as routine ship validation.
2. **Review gate — Codex path (local, before push)**: if `codex` is available, run it on the local diff. For each real finding: fix it → **re-run only the scoped affected-tests lane** to confirm the fix (a review fix is new code, but the scoped lane covers it in seconds) → re-commit → re-run the reviewer. Loop until clean. (No Codex → the review happens at step 4 on the PR.)
3. **Affected gate + push**: once local and review are clean, stage the intended branch state and run the repo's affected-tests lane (`make check`, see **Repo config**) again when code changed since step 1, then push the committed branch whenever local is ahead of remote — this covers both the first push **and** resuming an existing PR after local fixes (`git push` / `git push -u origin HEAD`). CI's `merge_group` matrix is the full-matrix backstop; local ship validation stays affected-only. Skip entirely if the user said not to push a PR.
4. **PR + Claude review**: open the PR if none exists yet and the user wants one (`gh pr create`). On the **Claude Code path** (no Codex), run the `code-review` skill on the open PR now; fix findings (→ back to step 1's commit/push), re-run until clean.
5. **Merge-ready loop (the "pristine" gate — default stopping point).** Loop until every criterion holds; report "merge-ready" when it does (don't merge unless explicitly asked). Re-confirm CI **and** mergeability at the moment you exit — both can drift while you wait.
   - **CI**: `gh pr checks <n> --required`. Required jobs must all be `pass` or `skipping`. If any fail, read `gh run view --log-failed`, fix → re-run the affected-tests lane → commit → push, and re-enter the loop. If pending, wait.
   - **Automated PR review wait** *(only if the repo runs an automated PR reviewer; this repo uses Codex's `@codex review`)*: ensure that reviewer covers the *current* head — request it (e.g. a `@codex review` PR comment) if none is pending, then wait (poll ~2 min, up to ~20 min), inspecting all surfaces (`gh pr view --json reviews,comments`, `gh api .../pulls/<n>/comments`, the review-thread GraphQL query). Its automated 👍 (when it finds nothing) satisfies the approval gate below. This is **independent of the local review gate** — it does not run a second *local* reviewer. If the repo has no automated PR bot, skip this; the local `code-review` from step 4 was the review and approval comes from a human 👍.
   - **Review threads**: address every unresolved, non-outdated thread — fix → re-run the affected-tests lane → commit → push the batch (steps 1–3) → reply with what changed → resolve; or, if you disagree, reply with concise reasoning and leave it (a real unresolved disagreement is not merge-ready). Re-check after each new head.
   - **Approval (👍) gate**: the PR is merge-ready only when an **external** `+1` reaction is on the PR conversation, **fresh** relative to the current head (Codex's automated 👍 — emitted when its review finds nothing — counts; exclude the login you run as; **never add the reaction yourself**). If absent, enter a **persistent wait** watching all four signals at once until one fires: a fresh external `+1`; new review/comment activity (handle it, then re-loop — late reviews happen); mergeability turned `DIRTY`; or a previously-green required check regressed. Don't time-bound this wait.
6. **Enqueue (only if merge was explicitly requested)**: **re-read the PR's base now that the PR exists** (`BASE_BRANCH="$(gh pr view <n> --json baseRefName --jq .baseRefName)"`) — the value from the gate may be the `echo main` fallback computed before the PR existed. Confirm the remote head matches your reviewed local commit, then merge per the repo's merge norms (see **Repo config**, the guide) — here, via the merge queue with a real merge commit: `gh pr merge <n> --merge` (**never** `--squash`). On merge-queue mains where `--merge` is rejected, enqueue via the `enqueuePullRequest` GraphQL mutation. Then **watch**: poll until actually merged; verify against the PR's **actual base** (`$BASE_BRANCH` from the gate — not hard-coded `main`, since a stacked or `main`→`production` promotion PR has a different base): `git fetch origin "$BASE_BRANCH"` first (gh polling doesn't refresh the local ref), then re-confirm it landed (`git merge-base --is-ancestor <sha> origin/$BASE_BRANCH`) — a "MERGED" PR stacked on another branch may not have reached its base.
7. **Clean up (post-merge only)**: if local dev servers are running (and not in Codex Cloud / a no-server environment), stop them with the repo's dev-stop norm (see **Repo config**, the guide — here, `make dev-stop`); delete the task worktree.
8. **Report**: post the final state (merge-ready, or merged + cleaned up) to the worklog. If a Project Root exists, update its link/status summary and end the final handoff with `Project Root: URL`.

## Guardrails

- **Leave merging to a human unless they explicitly asked to merge/land/queue.** Default to stopping at merge-ready (step 5, after PR-state is verified). An implementation/"make a PR" request never implies consent to merge.
- Never push to remote `main` directly; never squash-merge; never deploy to production without explicit human go-ahead.
- If the user said "don't push a PR" or "no PR", stop after local validation + the review gate and report — do not open, push, or merge anything.

## Repo config

This skill is repo-agnostic — run *this* repo's commands, not hardcoded ones. Read **`AGENTS.md` (else `CLAUDE.md`)** and its linked **`docs/TESTING.md`** for the affected-tests lane used for iteration, pre-push, PR creation, and merge-ready gates, plus the guide's PR/branch/merge and deploy/preview norms. If `docs/TESTING.md` is absent, infer an affected/local lane from `package.json` / `Makefile` / CI and offer **`comment-init`** to scaffold the config.

## Comment.io API

**Read `$BASE/llms.txt`** as the current docs index, then **read `$BASE/llms/reference.txt`** for the exact API and auth contract. `$BASE` is the target Comment.io host from the doc URL or session identity (default `https://comment.io`). Profile files may help discover a host, but write identity follows `comment-identity` or a supplied doc token, not ambient profile selection. Don't restate its contracts here.

**Content vs comments (team convention).** The *answer* → document **body**; *how you got there* (review-loop rounds, steering, escalations) → **comments**, as lists / short lines.

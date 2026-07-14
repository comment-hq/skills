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

`ship` takes a delivered branch to merge-ready and, only when explicitly asked,
through merge and cleanup. It reports each transition to the task's **worklog**
comm when one exists.

## The smart review gate (exactly one)

Run **one** official code review, auto-detecting the runtime — prefer local
`codex review`, otherwise use Claude Code's PR-based `code-review`; never run
both. If neither is available, stop rather than treating the missing gate as a
pass.

Run the gate, then **act on it** — never treat a missing, partial, or unknown
review result as a pass. `ship` runs one official review path for each candidate,
not redundant reviewers.

## Preconditions

The **worklog is optional**. When a caller (`comment-feature` / `comment-bug`) passes a worklog `share_url`, post status to it. When a Project Root URL is also passed, preserve it: detailed PR lifecycle notes go to the worklog, while the root gets only concise state changes, blockers, and the PR link. For a standalone `$ship` on an existing PR with no worklog, skip the comm updates and just report status in the PR and terminal — never block the lifecycle on a missing worklog.

**Identity for worklog updates.** If a caller passed a worklog/root, use that comm's supplied token or the session-scoped ephemeral identity established by the caller for every status comment/edit. Do not choose a registered profile just because one exists locally, and never switch to a Botlets bot profile for a coding-session worklog. If `$ship` is used standalone and must write to a Comment.io doc before any task identity exists, run `comment-identity` first.

## Merge is opt-in — default is "merge-ready", not "merged"

`ship` drives to **merge-ready and stops there** by default. Only proceed to enqueue/merge (step 6) when the user **explicitly** asked to merge/land/queue this PR. A request to "make a PR", "open a PR", or "make it mergeable/pristine" is **not** a merge request — leave merging to the human (per CLAUDE.md). When in doubt, stop at step 5 (PR-state verified) and report the PR as ready.

## Workflow

1. **Converge locally:** finish implementation and any in-flight review loop,
   batching compatible findings and using focused checks. For high-risk work,
   briefly record the invariants, risks, and evidence needed.
2. **Freeze the candidate:** commit the intended state and record its SHA. The
   worktree must be clean.
3. **Certify that exact commit:** resolve the intended PR base, using the existing
   PR's actual base when one exists. Run the complete affected lane and, when the
   chosen official reviewer is local, review against that base. Wait for the
   entire requested batch. Any actionable finding, unknown result, or edit
   invalidates the candidate; record the reasoning for findings you decline.
4. **Push the exact candidate:** use a normal explicit-SHA refspec so a
   non-fast-forward update fails. Reserve `--force-with-lease` for an intentional,
   verified history rewrite. Verify the remote head, then create the PR if none
   exists or update the existing one. If the chosen official reviewer is
   PR-based, run it immediately;
   that SHA is only test-certified until the review is clean. Review findings
   return the work to local convergence and produce a new candidate.
5. **Merge-ready loop (the "pristine" gate — default stopping point).** Loop until every criterion holds; report "merge-ready" when it does (don't merge unless explicitly asked). Re-confirm CI **and** mergeability at the moment you exit — both can drift while you wait.
   - **CI**: required jobs for the current head must all be passing or explicitly skipped. Pending or unknown is blocking. If a check fails, gather the full failure batch before editing, return to local convergence, and certify one new candidate.
   - **Automated review**: use it only when it is the chosen official review path or a repository-required signal. Accept results only for the exact current head; do not request redundant reviewers or perform repeated blind waits.
   - **Review threads**: gather the current batch, address compatible findings together, then return to candidate certification before the next push. Reply or record concise reasoning for declined findings.
   - **Approval (👍) gate**: the PR is merge-ready only when an **external** `+1` reaction is on the PR conversation, **fresh** relative to the current head (Codex's automated 👍 — emitted when its review finds nothing — counts; exclude the login you run as; **never add the reaction yourself**). If absent, enter a **persistent wait** watching all four signals at once until one fires: a fresh external `+1`; new review/comment activity (handle it, then re-loop — late reviews happen); mergeability turned `DIRTY`; or a previously-green required check regressed. Don't time-bound this wait.
6. **Enqueue (only if merge was explicitly requested)**: **re-read the PR's base now that the PR exists** (`BASE_BRANCH="$(gh pr view <n> --json baseRefName --jq .baseRefName)"`) — the value from the gate may be the `echo main` fallback computed before the PR existed. Confirm the remote head matches your reviewed local commit, then merge per the repo's merge norms (see **Repo config**, the guide) — here, via the merge queue with a real merge commit: `gh pr merge <n> --merge` (**never** `--squash`). On merge-queue mains where `--merge` is rejected, enqueue via the `enqueuePullRequest` GraphQL mutation. Then **watch**: poll until actually merged; verify against the PR's **actual base** (`$BASE_BRANCH` from the gate — not hard-coded `main`, since a stacked or `main`→`production` promotion PR has a different base): `git fetch origin "$BASE_BRANCH"` first (gh polling doesn't refresh the local ref), then re-confirm it landed (`git merge-base --is-ancestor <sha> origin/$BASE_BRANCH`) — a "MERGED" PR stacked on another branch may not have reached its base.
7. **Clean up (post-merge only)**: if local dev servers are running (and not in Codex Cloud / a no-server environment), stop them with the repo's dev-stop norm (see **Repo config**, the guide — here, `make dev-stop`); delete the task worktree.
8. **Report**: post the final state (merge-ready, or merged + cleaned up) to the worklog. If a Project Root exists, update its link/status summary and end the final handoff with `Project Root: URL`.

## Guardrails

- **Leave merging to a human unless they explicitly asked to merge/land/queue.** Default to stopping at merge-ready (step 5, after PR-state is verified). An implementation/"make a PR" request never implies consent to merge.
- Never push to remote `main` directly; never squash-merge; never deploy to production without explicit human go-ahead.
- If the user said "don't push a PR" or "no PR", stop after local validation + the review gate and report — do not open, push, or merge anything.

## Repo config

This skill is repo-agnostic — run *this* repo's commands, not hardcoded ones. Read **`AGENTS.md` (else `CLAUDE.md`)** and its linked **`docs/TESTING.md`** for focused iteration checks and final affected-candidate certification, plus the guide's PR/branch/merge and deploy/preview norms. If `docs/TESTING.md` is absent, infer suitable lanes from `package.json` / `Makefile` / CI and offer **`comment-init`** to scaffold the config.

## Comment.io API

**Read `$BASE/llms.txt`** as the current docs index, then **read `$BASE/llms/reference.txt`** for the exact API and auth contract. `$BASE` is the target Comment.io host from the doc URL or session identity (default `https://comment.io`). Profile files may help discover a host, but write identity follows `comment-identity` or a supplied doc token, not ambient profile selection. Don't restate its contracts here.

**Content vs comments (team convention).** The *answer* → document **body**; *how you got there* (review-loop rounds, steering, escalations) → **comments**, as lists / short lines.

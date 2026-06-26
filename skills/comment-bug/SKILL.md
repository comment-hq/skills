---
name: comment-bug
description: >-
  Fix a bug end-to-end through a live Comment.io worklog comm — reproduce, write a
  regression test that fails first, fix, verify on the preview, and drive to a
  merge-ready PR, with the repro, root cause, and verification recorded as the
  decision history. Invoke explicitly as `$comment-bug` / `/comment-bug`, or when a
  task is a defect, regression, broken workflow, or user-visible failure to be
  reproduced and fixed with a watchable, steerable record. Replaces the retired bug
  skill. Works identically under Codex and Claude Code.
---

# comment-bug — bug fix through a comm

Same worklog-driven spine as `comment-feature`, shaped for a defect. The worklog records the **repro**, the **root cause**, the **fix**, and the **verification evidence** as durable content. Composes **`worklog`**, **`steer`**, **`review-loop`**, and **`ship`** — all sibling skills in this bundle. (A bug fix is usually linear, so it doesn't delegate to `drive-plan`; reach for `drive-plan` only if the fix is genuinely multi-phase.)

> A **`comment-prototype`** can promote INTO `comment-bug` (reusing its worklog/branch), which then adds the failing regression test a prototype skips. Reachable via the **`comment-dev`** front-door router.

**Project Root.** Direct `comment-bug` uses its worklog as the Project Root. If the human or caller supplies an existing Project Root URL, preserve it and make the bug worklog a child with `Project Root: URL` near the top. Do not create a second root.

**Identity.** Bug-fix comm activity follows the `worklog` identity rule: before the first Comment.io write, run `comment-identity` and use that session-scoped ethereal handle for the worklog, evidence comments, steering, and `ship` status updates. If a supplied Project Root/share URL gives only a per-doc token, use that token for the existing root, but do not create new bug worklogs as an ambient registered handle or any Botlets bot profile.

**Before using a composed skill, read its full `SKILL.md`** — naming it here does not auto-load its contract (the `ship` review/PR gate, `worklog` update rules), which you must follow.

## Preconditions

- Task worktree on a `bug/...` branch off fresh `origin/main` (never on `main`).

## Workflow

1. **Open or inherit the Project Root.** If no Project Root URL was supplied, open the worklog (`worklog`) with the bug-shaped body and treat it as the Project Root; patch its own `Project Root: URL` line after creation. If a Project Root URL was supplied, open the bug worklog as a child with that `Project Root: URL` near the top and link it from the root. **Promotion from `comment-prototype`:** if you were handed a prototype's worklog `share_url` and branch, reuse *that* worklog as the Project Root — upgrade its light note in place to the bug-shaped body (don't open a second) — and continue on its branch. Record the symptom and exact reproduction steps first.
2. **Reproduce** the failure deterministically. If you cannot reproduce, say so in the worklog and `steer` to the reporter for details — do not guess a fix.
3. **Write a regression test that FAILS on the current code** — this proves you've captured the bug. Record the failing output as a comment.
4. **Diagnose** the root cause; record it in the body with the evidence (logs, traces, the offending code path).
5. **Steer checkpoint** — before committing to a non-obvious fix strategy, run **`steer`**: check for human comments, and escalate the chosen approach if it's risky or ambiguous.
6. **Fix** minimally and at the right layer. The regression test must now pass. Run the **`full`** test lane (see **Repo config**).
7. **Review the fix** by explicitly invoking **`$review-loop`** (it runs only on explicit request — this step *is* that request; rounds as comments); fix real findings; re-run until clean. Do this *before* the real-scenario verification so the evidence reflects the final code.
8. **Verify the real scenario** — on the final post-review-loop code, confirm the original symptom is gone, on the branch preview where applicable (the repo's convention for a per-worktree staging deploy, e.g. `https://<worktree>.toofs.us` here — see the guide; skip if unavailable in your runtime). Capture evidence (screenshot/log) as a comment.
9. **Ship** with `ship` (pass it the worklog `share_url` and Project Root URL when distinct).

## Definition of done

- Regression test fails pre-fix, passes post-fix (both recorded).
- The original user-visible symptom is verified gone, not just the test green.
- Worklog body carries repro → root cause → fix; comments carry the failing/passing evidence and review-loop rounds.

## Content vs comments

Repro, root cause, fix, verification conclusion → worklog **body**. Failing/passing test output, screenshots, review-loop rounds, steering → **comments**. Keep the Project Root scannable: no bulky evidence or review transcripts in the root body.

## Repo config

This skill is repo-agnostic — run *this* repo's commands, not hardcoded ones. Read **`AGENTS.md` (else `CLAUDE.md`)** and its linked **`docs/TESTING.md`** for the **`fast`** lane (quick iteration) and **`full`** lane (the pre-push gate), plus the guide's PR/branch/merge and deploy/preview norms. If `docs/TESTING.md` is absent, infer lanes from `package.json` / `Makefile` / CI and offer **`comment-init`** to scaffold the config.

## Comment.io API

**Read `$BASE/llms.txt`** for the API and auth — the single source of truth. `$BASE` is the target Comment.io host from the doc URL or session identity (default `https://comment.io`). Profile files may help discover a host, but write identity follows `comment-identity` or a supplied doc token, not ambient profile selection. Don't restate its contracts here.

**Content vs comments (team convention).** The *answer* → document **body**; *how you got there* (review-loop rounds, steering, escalations) → **comments**, as lists / short lines.

## Template

Worklog **bug variant** body:

```markdown
Project Root: URL

## Repro
<symptom + exact steps>

## Root cause
<the real cause + evidence/code path>

## Fix
<what changed and why this layer>. Regression test: <name> (fails pre-fix).

## Verification
<original symptom reproduced gone — evidence in comments>
```

Follow the skeleton above; keep repro/root cause/fix/verification in the body and evidence in comments.

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

Same worklog-driven spine as `comment-feature`, shaped for a defect. The worklog records the **repro**, the **root cause**, the **fix**, and the **verification evidence** as durable content. Composes **`delivery-methodology`**, **`worklog`**, **`steer`**, **`review-loop`**, and **`ship`** — all sibling skills in this bundle. A bug fix is usually direct and linear; use a controlled lift only when the real fix is a foundational replacement with unsafe intermediate states.

> A **`comment-prototype`** can promote INTO `comment-bug` (reusing its worklog/branch), which then adds the failing regression test a prototype skips. Reachable via the **`comment-dev`** front-door router.

**Project Root.** Direct `comment-bug` uses its worklog as the Project Root. If the human or caller supplies an existing Project Root URL, preserve it and make the bug worklog a child with `Project Root: URL` near the top. Do not create a second root.

**Identity.** Bug-fix comm activity follows the `worklog` route-and-identity rule. Reuse the identity carried by the working Comment.io tool/browser/connector route or a supplied Project Root token. Invoke `comment-identity` only immediately before an uncredentialed direct-REST write, then reuse that Ephemeral handle for later direct-REST worklog activity. Do not create bug worklogs as an ambient registered handle or any Botlets bot profile.

**Before using a composed skill, read its full `SKILL.md`** — naming it here does not auto-load its contract (the `ship` review/PR gate, `worklog` update rules), which you must follow.

## Preconditions

- Task worktree on a `bug/...` branch off fresh `origin/main`, or a declared
  `lift/...` when `delivery-methodology` requires it (never on `main`).

## Workflow

1. **Open or inherit the Project Root.** If no Project Root URL was supplied, open the worklog (`worklog`) with the bug-shaped body and treat it as the Project Root; update its own `Project Root: URL` line after creation. If a Project Root URL was supplied, open the bug worklog as a child with that `Project Root: URL` near the top and link it from the root. **Promotion from `comment-prototype`:** if you were handed a prototype's human-openable worklog URL (`share_url` for direct REST) and branch, reuse *that* worklog as the Project Root — upgrade its light note in place to the bug-shaped body (don't open a second) — and continue on its branch. Record the symptom and exact reproduction steps first.
2. **Choose topology and reproduce.** Read `delivery-methodology`; default to a
   direct bug branch unless the correct fix is foundational and partially
   unshippable. Reproduce the failure deterministically when possible. If the
   report lacks required detail, `steer`; do not guess a fix.
3. **Capture before/after proof.** Prefer a regression test that fails on the
   current code. When an automated harness is unavailable or disproportionate
   (for example an external/flaky integration), record a deterministic manual
   or diagnostic repro and explain why an automated regression was not
   practical. Do not spend days building unrelated harness infrastructure.
4. **Diagnose** the root cause; record it in the body with the evidence (logs, traces, the offending code path).
5. **Steer only on a real decision** — check before an irreversible, risky, or
   materially ambiguous fix strategy; otherwise keep moving.
6. **Fix** minimally and at the right layer. The regression test must now pass.
   Prefer the simplest fix for the reproduced user failure; do not generalize
   into speculative enterprise hardening or imagined edge cases without a
   credible failure path.
   Use focused checks while the fix and review converge; `ship` runs the complete
   affected lane on the final committed candidate.
7. **Review the explicit delta** with `review-loop`: one reviewer normally, a
   second sensitive-risk lens when warranted, and at most two finding-bearing
   rounds before redesign/proof/escalation. Record one receipt and one batch
   summary, not a comment per reviewer.
8. **Verify the real scenario when material** — confirm the original symptom is
   gone on the final code. Use a branch preview for user-visible/integration
   behavior when available; a focused deterministic proof is enough for a
   narrow internal fix.
9. **Ship** with `ship` (pass it the human-openable worklog URL and Project Root URL when distinct).

Keep diagnosis and review locked to the reproduced defect. Genuinely unrelated
bugs use `delivery-methodology`'s issue-and-continue protocol; only an actively
release-breaking or safety-critical discovery stops the job for an owner-created
separate worktree.

## Definition of done

- Automated regression test fails pre-fix and passes post-fix when practical;
  otherwise deterministic before/after evidence and the harness exception are
  recorded.
- The original user-visible symptom is verified gone, not just the test green.
- Worklog body carries repro → root cause → fix; comments carry the failing/passing evidence and review-loop rounds.

## Content vs comments

Repro, root cause, fix, verification conclusion → worklog **body**. Failing/passing test output, screenshots, review-loop rounds, steering → **comments**. Keep the Project Root scannable: no bulky evidence or review transcripts in the root body.

## Repo config

This skill is repo-agnostic — run *this* repo's commands, not hardcoded ones. Read **`AGENTS.md` (else `CLAUDE.md`)** and linked delivery/testing docs for topology, focused iteration, final certification, PR/merge, and preview norms. If absent, infer suitable lanes from `package.json` / `Makefile` / CI and offer **`comment-init`**.

## Comment.io API

Use the current worklog/Project Root and its working Comment.io route first. Resolve and freeze `$BASE` for the whole workflow in this order: the supplied comm's validated final Comment.io origin after any shortlink redirect; the active Comment.io tool/account base URL; an explicitly selected profile's `base_url`; only when no target context exists, `https://comment.io`. A shortlink origin is never `$BASE`; do not switch a staging/custom workflow to production. For direct REST, consult **`$BASE/llms/reference.txt`** only when exact API or recovery detail is needed. Fetch **`$BASE/llms.txt`** only when no current route works or another focused guide is needed. Invoke `comment-identity` only before an uncredentialed direct-REST write; never replace a supplied token or tool/browser/connector identity. Don't restate the live contracts here.

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

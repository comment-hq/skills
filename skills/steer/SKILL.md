---
name: steer
description: >-
  Keep a human in the loop on a running task through a Comment.io comm. Poll the
  task comm for new @mentions and replies, fold human steering into the work
  mid-flight, and escalate by @mentioning a human and waiting when a decision
  shouldn't be made alone. Use during any long-running or autonomous task that
  has a worklog comm. Trigger when asked to "listen for steering", "check for
  comments", "escalate to a human", or whenever you need a human decision before
  continuing. Works identically under Codex and Claude Code.
---

# steer — the human-in-the-loop control plane

`steer` makes a Comment.io comm the place humans steer running agents and agents ask for help — no out-of-band chat thread. It is a **primitive**: `comment-feature` / `comment-bug` call it; use it standalone whenever autonomous work needs a human checkpoint.

`steer` always polls at checkpoints. Push wake can resume the session only when the caller armed it through `comment-identity` or a daemon-backed workflow; you still check the comm deliberately before phase boundaries and after long stretches.

**Identity.** `steer` writes as the active task identity. If the task was opened by `comment-feature`, `comment-bug`, `worklog`, or `drive-plan`, keep using that route's identity or supplied comm token for replies and escalations. If `steer` is used standalone, choose the first working Comment.io route; invoke `comment-identity` only immediately before an uncredentialed direct-REST write. Do not switch to an ambient registered profile or Botlets bot profile mid-task.

## Two motions

### 1. Listen — fold steering in

At natural checkpoints (phase boundaries, before irreversible steps, after long stretches), use the active route's native comment, notification, or read capability to check the task comm for human comments and @mentions newer than the last state you saw. For direct REST only, use the mention/notification and since-revision filters documented in `$BASE/llms/reference.txt` — don't hard-code the query syntax here, it evolves.

- For each new human comment: incorporate it into the **Plan**/**Decision log** of the worklog, and **reply** in-thread acknowledging what you changed.
- If a comment contradicts your current plan, the human wins — revise and record why.

### 2. Escalate — ask and wait

When you hit a decision you shouldn't make alone (product choice, irreversible action, ambiguous requirement):

1. Post a **comment** through the active route that @mentions the human, uses `Decision needed: headline` or `Blocked: headline`, states the decision crisply, lists your recommendation, and says what happens next. For direct REST only, include the required `notify` object from `$BASE/llms/reference.txt`; other routes use their native mention/notification behavior.
2. Name the blocker in the worklog **Open questions** — this body edit *is* allowed (it's current state, which belongs in the body).
3. If a Project Root exists and the active comm is a child/Plan doc, add only a one-line blocker summary/link to the root; keep the detailed ask where this skill is polling.
4. **Wait**: poll on a sensible cadence. Do other non-blocked work meanwhile. Resume when the human replies; if nothing else is doable, stop and hand back with the exact decision needed.

The escalation *discussion* — your ask and the human's replies — stays in **comments** (lists / short lines); only the one-line blocker in **Open questions** goes in the body.

## Honesty about "listening"

You are not continuously connected. "Listening" = you poll when you take a turn. For genuinely hands-off delivery, follow the active origin's `$BASE/llms/notifications.txt` guide and use its exact saved-origin/account, principal-pinned `comment run` route. Launch only arms that route; call push delivery ready only after a different participant sends a fresh event and this exact runtime receives, reads/responds, and settles it. That persistent path remains out of scope for this skill, which assumes polling.

## Comment.io API

Use the active task comm and its working Comment.io route first. Resolve and freeze `$BASE` for the whole workflow in this order: the supplied comm's validated final Comment.io origin after any shortlink redirect; the active Comment.io tool/account base URL; an explicitly selected profile's `base_url`; only when no target context exists, `https://comment.io`. A shortlink origin is never `$BASE`; do not switch a staging/custom workflow to production. For direct REST, consult **`$BASE/llms/reference.txt`** only when exact API or recovery detail is needed. Fetch **`$BASE/llms.txt`** only when no current route works or another focused guide is needed. Keep the supplied route identity/token or explicit daemon-backed workflow identity; invoke `comment-identity` only before an uncredentialed direct-REST write. Don't restate the live contracts here.

**Content vs comments (team convention).** The *answer* → document **body**; *how you got there* (review-loop rounds, steering, escalations) → **comments**, as lists / short lines.

## Escalation comment template

Replace `@reviewer-handle` with the real human handle; never leave it literal.

```markdown
@reviewer-handle **Decision needed: headline**

- **Need:** decision or approval needed
- **Recommend:** default path and why
- **Next:** what happens after the answer

Holding phase/step on your call.
```

Use `Blocked: headline` instead of `Decision needed: headline` only when no useful non-blocked work remains.

```markdown
@reviewer-handle **Blocked: headline**

- **Need:** action required to unblock
- **Recommend:** best next move
- **Next:** what resumes after this
```

When posting either template through the API, include `notify.kind: "decision"` for `Decision needed` and `notify.kind: "blocked"` for `Blocked`, with a <=120-character `notify.line` that summarizes the ask. Agent @mentions without `notify` are rejected.

---
name: comment-spec
description: >-
  Shape a rough product idea into a crisp, proportionate spec through a live
  Comment.io comm, then hand it to comment-feature when build authority exists.
  Makes goal, acceptance, delivery topology, key risks, and out-of-scope clear;
  uses analytics, instrumentation, dashboards, concept mapping, and critic
  review only when the size of the product bet warrants them. Invoke as
  `$comment-spec` / `/comment-spec`, or when asked to spec, shape, scope, or
  design a feature before building. Works identically under Codex and Claude
  Code.
---

# comment-spec — shape only as much as the decision needs

Use this above `comment-feature` when goal, product fit, or acceptance is
materially unsettled. The scarce resource is a clear decision and fast learning,
not maximal specification. Optimize for the cleanest architecture and smallest
useful learning step appropriate to the product's current phase.

Act like a fast-moving startup: the goal is a feature users love, not speculative
enterprise completeness. Prefer the simplest useful hypothesis and real-user
validation. Add extensibility, exhaustive edge cases, and operational machinery
only when current evidence, risk, or a hard invariant justifies their cost.

Direct `comment-spec` uses the Spec comm as Project Root. On build, pass that
same human-openable URL to `comment-feature`; do not create another root or
re-derive the approved design.

This skill composes `delivery-methodology`, `worklog`, `steer`, and
`comment-feature`. Read a composed skill's full `SKILL.md`
(its `SKILL.md`) before using it.

## Preconditions

This path is read-only on the codebase. It may inspect code, docs, and available
product evidence, but it does not create a worktree or edit code.

## Workflow

1. **Open the Spec comm.** Use the template below and the first working
   Comment.io route. Keep that identity/token; invoke `comment-identity` only
   immediately before an uncredentialed direct-REST write. Save the
   human-openable URL and make it the Project Root.

   Be honest about steering. Consult `$BASE/llms/notifications.txt` for the current listening and delivery contract. If this runtime cannot wake, hand back a resumable URL rather than pretending to wait.
2. **Orient proportionally.** Read the repo guide and the smallest product/
   architecture surface needed to understand the idea. Do not fan out broad
   concept mapping for an ordinary bounded feature.
3. **Make the mandatory core crisp:**
   - job-to-be-done and who it serves;
   - observable acceptance/success;
   - shaped behavior in product terms;
   - key risks/tradeoffs and out-of-scope;
   - recommended direct versus controlled-lift topology from
     `delivery-methodology`.

   Ask explicitly whether incremental main delivery would force harmful flags,
   dual writes, duplicated state, or two systems. Foundational magma-phase work
   should normally recommend a lift when its intermediate states are unsafe.
4. **Use evidence when it changes the decision.** Query analytics or logs when
   the spec makes an important empirical claim and a documented system can test
   it. State an assumption when no clean evidence exists. Do not turn every idea
   into an analytics research project.
5. **Scale measurement to the bet.** A consequential product bet should state a
   falsifiable hypothesis, useful metrics, needed instrumentation, and perhaps a
   dashboard. A small workflow/architecture improvement needs only observable
   acceptance. Never mandate a dashboard as ceremony.
6. **Review proportionally.** One critic is the default for a material spec; skip
   for an obvious small one. Add a second lens only for genuine product or
   architecture risk. Gather one batch, revise once, and do at most two
   finding-bearing rounds. Accepted tradeoffs are not blockers.
7. **Steer only on a goal-level fork.** @mention the human only when the active route exposes a valid handle;
   otherwise make it a general comment, deliver the URL directly, and never invent a handle.
   Existing authority such as
   “spec and build this” counts as the build go-ahead unless shaping uncovers a
   material goal change. Otherwise ask one final “build or iterate?” question.
8. **Hand off without restarting.** Invoke `comment-feature` with the Project
   Root URL, approved acceptance, topology recommendation, tradeoffs, and any
   proportionate measurement work. The Spec is the non-technical design.

## Done

- Goal and acceptance can judge the eventual result.
- Product behavior, topology, key risks, and out-of-scope are explicit.
- Empirical claims and measurement are proportionate to the decision.
- Material open goal forks are answered or visibly awaiting steer.
- Build authority is recorded before implementation begins.

## Content vs comments

Current app anchor, goal, acceptance, shaped behavior, topology, evidence,
measurement when relevant, risks, and out-of-scope belong in the body. Review
batch summaries, steering, and escalations belong in concise comments.

## Comment.io API

Use the Spec comm and its working Comment.io route first. Resolve and freeze `$BASE` for the whole workflow in this order: the supplied comm's validated final Comment.io origin after any shortlink redirect; the active Comment.io tool/account base URL; an explicitly selected profile's `base_url`; only when no target context exists, `https://comment.io`. A shortlink origin is never `$BASE`; do not switch a staging/custom workflow to production. For direct REST, consult **`$BASE/llms/reference.txt`** only when exact API or recovery detail is needed. Fetch **`$BASE/llms.txt`** only when no current route works or another focused guide is needed. Invoke `comment-identity` only before an uncredentialed direct-REST write; never replace a supplied token or tool/browser/connector identity. Don't restate the live contracts here.

## Template

```markdown
# Spec: <feature>

**Owner:** <@handle when the active route exposes one; otherwise Anonymous session>
**Status:** Shaping
Project Root: URL

## Goal and acceptance

**Job:** <what the user needs>
**Who:** <user/segment>
**Acceptance:** <observable result>

## Shaped behavior

<what changes for the user>

## Delivery topology

**Recommend:** direct / controlled lift
**Why:** <shippability, architecture, and dual-system reasoning>
**Feature flag:** not needed / justified by <clean bounded seam + removal>

## Evidence and measurement

<only what materially informs this bet; state assumptions>

## Tradeoffs and risks

| Risk/tradeoff | Treatment | Status |
|---|---|---|
| <risk> | <mitigation or accepted consequence> | accepted / open |

## Out of scope

- <deliberate exclusion>

## Open questions

- <goal-level blocker, if any>
```

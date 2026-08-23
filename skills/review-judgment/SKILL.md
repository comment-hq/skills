---
name: review-judgment
description: Evaluate review findings with pragmatic startup judgment. Invoke when `code-review`, `ship`, `deploy-prod`, or another workflow must decide whether to fix, verify, decline, reply to, or resolve feedback.
---

# Review judgment

Evaluate every review item yourself. Reviewers give advice, not orders.

We are a small startup. Move quickly, think clearly, and keep the code simple.
Fix real bugs and real risks. Decline style preferences, speculative refactors,
and changes that add more complexity than the problem deserves.

If a serious concern is uncertain, run one small check and decide. Do not
overengineer just to make every reviewer happy.

Security or privacy exposure, data loss, and broken storage, migration,
protocol, or repository guarantees are real risks. Fix them or escalate them.

## Decide

1. Read the concern and the current code.
2. Fix it, check it once, or decline it.
3. Keep unrelated discoveries out of scope unless they make this work unsafe.
4. Stop when no real issue or unanswered actionable comment remains.

Reviewer agreement is not proof. Prefer a concrete current failure path,
meaningful impact, and a proportionate fix over severity labels or vote counts.

## Public feedback

- **Fixed:** reply with what changed and the commit or PR, then resolve the
  thread.
- **False positive or disproportionate:** reply with the concise reason, then
  resolve the thread.
- **Uncertain serious concern:** leave it open, run one bounded check, then
  decide.

Never dismiss a formal review. If permissions prevent thread resolution, report
that plainly. Keep declined private-panel findings private unless the decision
is material enough that another reader could reasonably question it.

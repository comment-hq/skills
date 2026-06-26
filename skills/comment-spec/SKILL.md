---
name: comment-spec
description: >-
  Shape a raw feature idea into a crisp PM-level spec through a live Comment.io
  comm, then hand it to comment-feature to build. Nails the goal and success
  definition, fits the idea to the app's existing concepts, minimizes new
  user-facing concepts, and runs a self-checking shaping loop that surfaces the
  risks in the current plan plus ways to address each — so a human can decide how
  much to iterate before spending engineering time. Forms a falsifiable
  hypothesis, checks the implied problem against whatever analytics system the
  codebase uses, and specs the metrics that would prove the hypothesis right or
  wrong plus a feature-level dashboard to track them. Blocks on goal-level
  questions and on a final "build it?" go-ahead, then invokes comment-feature.
  Invoke explicitly as `$comment-spec` / `/comment-spec`, or when asked to spec,
  shape, scope, or design a feature before building it. Works identically under
  Codex and Claude Code.
---

# comment-spec — shape a great spec, then build it

The altitude **above** `comment-feature`. `comment-feature` builds a feature you've already decided on; `comment-spec` takes a raw idea and shapes it into a spec worth building — clear goal, fits the app, few new concepts — then hands that spec to `comment-feature`. Reachable on its own or routed in via the `comment-dev` front door; when the spec is ready it hands off to `comment-feature` to build.

**Project Root.** Direct `comment-spec` uses the Spec comm as the Project Root. After creation, patch `Project Root: URL` near the top with the Spec share URL. If the human says to build, pass that Spec URL to `comment-feature` as the Project Root; the feature worklog, Plan, design, and ADR docs are children.

**Operating premise.** Engineering time is cheap (coding agents build fast and build better with full context); the scarce thing is a **clear goal**. So this skill does **not** bias toward the smaller/tighter cut to save dev effort. It optimizes for: (1) a goal crisp enough to tell whether the feature met it, (2) fit with the app's existing concepts, and (3) the fewest **new user-facing concepts**. The build decision is assumed already made — the skill's value is making the tradeoffs in the current plan visible so the human can choose how much to iterate before kicking off the build.

**"Simpler in concepts" ≠ smaller scope.** Conceptual simplicity means the user has fewer *new* ideas to learn — reuse an existing concept/primitive/mental model instead of inventing one. Cutting scope to save engineering time is **not** a goal here.

**A spec is a falsifiable bet.** Make the bet explicit: a one-sentence **hypothesis** of the form *"we believe \<change\> will cause \<metric/behavior\> to move \<direction + rough magnitude\> for \<who\>, because \<mechanism\>; we're wrong if \<observable\> doesn't move."* The hypothesis is what picks the metrics — each metric exists to prove the hypothesis right or wrong, not as vanity decoration.

**See reality before trusting the stated problem.** A goal usually encodes an implicit claim ("users keep hitting X", "Y is too slow"). Where the product has an analytics system, look at it: confirming or contradicting that claim with data is the fastest route to goal clarity. **Discover which system it is from the repo — don't assume** (it might be a product-analytics tool, an event pipeline, an observability/log backend, a data warehouse, or nothing yet); honor its documented query method and credentials. And a feature that ships without a way to tell whether the bet paid off isn't finished being specced — so the spec also defines the metrics it should move and the dashboard that will watch them.

Composes the primitives and gates: **`comment-identity`** (named session handle), **`worklog`** (the comm's shape + identity rule), **`steer`** (human-in-the-loop blocking), and **`comment-feature`** (the build it hands off to). All are sibling skills in this bundle.

**Before using a composed skill, read its full `SKILL.md`** — naming a skill here does not auto-load its contract.

## Preconditions

- **Read-only on the codebase.** This skill shapes a spec; it does not edit code or create a worktree. `comment-feature` handles the worktree/branch when the build starts. Run it from anywhere (including `main`).

## Workflow

1. **Open the Spec comm — and arm a listener.** Get a session-scoped ethereal identity from `comment-identity` (never an ambient registered or Botlets handle — see `worklog`'s identity rule), then create the comm from the **Template** below. Save its `share_url`; it is both the deliverable, the steering surface, and the Project Root. Immediately patch the real `Project Root: URL` line near the top. Post a comment **@-mentioning the human(s)** naming the two points where you'll block: the **goal sign-off** and the final **"build it?"** gate.

   **Arming a listener is required, not optional** (`llms.txt` → "Ethereal handles → Start listening"). The Comment.io daemon **never listens for ethereal handles**, so a human's reply only queues to your inbox — **nothing wakes you** unless *this* session holds its own listener. The moment you mint the handle: on **Claude Code**, use `comment ephemeral ensure` / `comment-identity` or `/comment listen`'s delivery-session ethereal path so the wake-bind points at this session's ethereal handle; do not choose a registered profile from the generic listen picker for this flow. On **other runtimes** poll `GET /agents/me/notifications` between turns. Align `COMMENT_IO_ENV`/`COMMENT_IO_HOME` with the target host (e.g. staging) so home, base, and wake all agree — otherwise a staging cred is missed and @mentions never wake you. **Without an armed listener this skill's two human blocks strand silently** (the spec gets written, the escalation posts, then the session dies with no way to be woken). If your runtime genuinely cannot hold a listener, see the fire-and-forget fallback in step 8 — don't pretend to wait.

2. **Orient on the product — don't assume you already know what this app is.** Before you can frame a goal that fits the app, establish *what the product is and who it's for* in plain terms. Read `CLAUDE.md`, the home/agent docs (`/llms.txt`), any landing/marketing surfaces, and the architecture overview (`docs/ARCHITECTURE.md`). Capture a 2–3 sentence **"what this app is for"** anchor in the comm; the goal in step 3 must be expressed *relative to that purpose*. (This is the broad-context pass; the deeper concept map comes in step 4.)

3. **Frame the goal, form a falsifiable hypothesis, and check it against reality — this is the one thing that must become crisp.** Write the job-to-be-done, who it's for, and a **success definition you could later check the feature against** (observable / measurable, not "users like it"). Then state the **falsifiable hypothesis** — *"we believe \<change\> will cause \<metric/behavior\> to move \<direction + rough magnitude\> for \<who\>, because \<mechanism\>; we're wrong if \<observable\> doesn't move."* This hypothesis is the spine: it dictates which metrics the measurement plan (step 6) tracks. Then **validate the hypothesis's implied problem against the product's analytics**: discover what analytics system the project uses — look in `CLAUDE.md`, docs, config/env, and dependencies; it could be a product-analytics tool, an event/observability pipeline, a data warehouse, or none — and honor its documented query method and credentials. Look for data that confirms or contradicts the problem the hypothesis assumes. Record what you found. Three outcomes:
   - **Confirms** → cite the metric; the hypothesis is now reality-grounded.
   - **Contradicts** (the data tells a different story than the stated problem) → this is a **finding worth a blocking escalation** — the hypothesis may be aimed at the wrong problem.
   - **No analytics, or no clean metric exists** → say so and state the assumption explicitly (and make sure step 6's new instrumentation starts measuring it, so the next feature isn't flying as blind).
   If the goal is fuzzy, you find more than one plausible goal, or the data contradicts the hypothesis, **do not shape toward a guess** — `steer`-escalate and wait on your step-1 listener (no listener? use the step-8 fire-and-forget fallback rather than stranding). A wrong goal wastes the whole spec.

4. **Map the app's existing concepts** (so the idea fits and stays simple). Fan out read-only explorer subagents over the affected code **and the product's existing concepts**: `docs/ARCHITECTURE.md`, `docs/DOCUMENT-SURFACE.md`, and the relevant `src/`/`cf/`/`packages/` areas. Produce a short **map of existing concepts and primitives** the feature could build on rather than reinvent. Record it in the comm — it's what the conceptual-simplicity dimension scores against.

5. **Shape the feature, then run the shaping loop until clean.** Draft the feature in product terms. Then spin up **3 shaping-critic subagents** (the product-altitude analog of `$review-loop`), each attacking the current draft on the fixed dimensions below. Fix the *real* issues one at a time, in priority order; re-spin a fresh trio; **repeat until a round returns no real issues** — exactly the `review-loop` loop, but the bar is "no unresolved ambiguity or unflagged risk," not "no code defect." Post **each round as a comment** (short list). The dimensions:
   - **Goal fit** — does the drafted solution actually achieve the step-3 goal? Where is the gap, and is the success definition still checkable against it?
   - **Conceptual simplicity** — how many **new user-facing concepts** does this add? For each, is there an existing concept/primitive (from the step-4 map) it could reuse or extend instead? Fewer new concepts wins.
   - **App fit** — does it match existing patterns, navigation, and the product's grain, or fork behavior the boundaries (e.g. `DocumentSurface`) say should stay shared?
   - **Measurability** — does the step-6 plan actually test the step-3 hypothesis: will the chosen metrics move *because of this feature* (attributable, not confounded), is the expected magnitude realistic, and is there a clear signal that would **falsify** the hypothesis (tell success from failure)?
   - **Risk** — what could make this *not* meet the goal: dependencies, edge cases, rollout/migration risk, abuse, scale. Each risk must come with **at least one way it could be addressed**.
   A "real issue" is a genuine ambiguity, a goal gap, an avoidable new concept, an unmeasurable claim, or an unflagged risk. A risk the human may reasonably accept is **not** a blocker — record it as a tradeoff (step 7), don't loop on it.

6. **Spec the measurement plan — the instrument that tests the hypothesis.** The spec is not done until it says how we'll know the step-3 hypothesis held. Define: (a) the **metrics that should move** — chosen because each proves the hypothesis right or wrong — with a **realistic expected magnitude** and the falsification threshold (and current baseline where step 3 found one); (b) the **new datapoints/events to collect** to make those metrics computable (and to backfill any "no clean metric" gap from step 3); and (c) a **feature-level dashboard** — every new feature ships with one, built in **whatever analytics system the project uses** (the one discovered in step 3; honor its dashboard/credential mechanism). The spec *defines* instrumentation + dashboard; `comment-feature` *implements* them as part of the build (call this out explicitly at handoff so they aren't dropped).

7. **Record tradeoffs, don't silently resolve them.** Every risk or fork the loop surfaces goes in the **Tradeoffs & risks** table: the risk in the current plan, one or more ways to address it, and a status (`accepted` / `open`). This table *is* the "here's what you could iterate on" surface. Reserve `steer` blocking-escalations for **goal-level** decisions (forks that change what success means, including a metrics contradiction from step 3); present the rest as accepted-by-default tradeoffs the human can reopen.

8. **Block for the build gate.** When the loop is clean and the goal is signed off, set the comm Status to **Spec ready**, then post a `steer` escalation @-mentioning the human: state the goal and hypothesis in one line each, the key metric it should move, the open tradeoffs (N of them) and that they can be iterated or accepted, and ask **"Build it now, or iterate on a tradeoff?"** Then **wait** on your step-1 listener (poll on a sensible cadence; do no further work until they answer — the spec is cheap, a PR is not).

   **Fire-and-forget fallback (no listener possible).** If this runtime cannot hold a listener and the session is about to end, do **not** silently strand the comm. Set **Status: ⏸️ Awaiting human — resume by re-invoking `/comment-spec` on this comm**, leave the pending decision at the top of **Open questions**, and hand back the `share_url` with `Project Root: URL`. A stranded spec must read as obviously resumable, not as dead. (The same applies if you strand at the step-3 goal sign-off.)

9. **Hand off to `comment-feature`.** On go-ahead, invoke **`/comment-feature`** for the feature, passing the **Spec comm `share_url` as the Project Root** and instructing it to **use the spec as its non-technical design and decision input** (the goal, shaped solution, concepts, accepted tradeoffs) rather than re-deriving the design — and to **include the measurement plan in the build**: instrument the new datapoints and create the feature dashboard. Link the resulting child worklog/PR back into the Spec root when it exists. If the human chose to iterate, fold their direction into the relevant section, re-run the step-5 loop on the changed part, and return to the gate.

## Definition of done

- The **goal + success definition** is crisp enough to later judge whether the feature met it, expressed relative to what the app is for, and the human has signed off on it.
- There is a **falsifiable hypothesis** (change → metric move → mechanism, with a stated condition that would prove it wrong), and the metrics are derived from it.
- The implied problem was **checked against the project's analytics** (whichever system it uses) — confirmed, contradicted (and escalated), or recorded as "no analytics / no clean metric, assumption stated."
- The shaping loop ran to a clean round; **new user-facing concepts are enumerated and justified** against the existing-concepts map.
- The spec carries a **measurement plan**: metrics that test the hypothesis (with expected magnitude + falsification threshold), new datapoints to collect, and a feature-level dashboard — all flagged for `comment-feature` to implement.
- Every surfaced risk has at least one remediation and a status; nothing material is silently resolved.
- The human gave an explicit **build** go-ahead, and `/comment-feature` was invoked with the spec.

## Content vs comments

App-context anchor, goal, hypothesis, metrics check, shaped feature, concepts, measurement plan, tradeoffs table, out-of-scope → comm **body** (current truth). Shaping-loop rounds, steering, and escalations → **comments** (lists / short lines). The Spec root is the primary artifact, but keep process logs, bulky evidence, and review transcripts out of its body.

## Comment.io API

**Read `$BASE/llms.txt`** for the API and auth — the single source of truth. `$BASE` is the target Comment.io host from the doc URL or session identity (default `https://comment.io`). Profile files may help discover a host, but write identity follows `comment-identity` or a supplied doc token, not ambient profile selection. Don't restate its contracts here.

## Template

Use this shape verbatim (fill in the feature).

```markdown
# Spec: <feature>

**Owner:** @<handle>  ·  **Status:** 🟡 Shaping → _(Spec ready when clean & signed off)_

Project Root: URL

**Build:** _(add the comment-feature worklog/PR link when handed off)_  ·  **Updated:** <date time>

---

## What this app is for

<2–3 plain sentences: what the product is and who it's for — the anchor the goal is framed against>

---

## Goal & success

**Job-to-be-done:** <the user's actual goal, one or two sentences>
**Who:** <the user/segment>
**Success looks like:** <observable/measurable signal we could later check the feature against>

**Hypothesis:** We believe <change> will cause <metric/behavior> to move <direction + rough magnitude> for <who>, because <mechanism>. We're wrong if <observable that doesn't move>.

**Problem is real because:** <metric/evidence that confirms it — or "no analytics / no clean metric; assuming <X>" / "⚠️ data suggests <different story> — see open questions">

---

## The shaped feature

<what we're building, in product terms — what the user does and sees>

---

## Concepts introduced

| New concept (to the user) | Why it's needed | Existing concept it reuses / builds on |
|---|---|---|
| <concept> | <why a new one is unavoidable> | <existing primitive/pattern, or "none — net-new"> |

_(Fewer rows is better. Each net-new row is a thing the user must learn.)_

---

## Measurement plan

_Metrics chosen to test the hypothesis above — each proves it right or wrong._

| Metric (tests the hypothesis) | Baseline (if known) | Expected move | Falsified if | New datapoint(s) to collect |
|---|---|---|---|---|
| <metric> | <current value or "none yet"> | <realistic magnitude + direction> | <threshold that means it failed> | <event/field to instrument> |

**Feature dashboard:** <name + what it tracks> _(in the project's analytics system; built as part of `comment-feature`)_

---

## Tradeoffs & risks

| Risk in the current plan | How it could be addressed | Status |
|---|---|---|
| <risk> | <one or more remediations> | accepted / open |

---

## Out of scope

- <thing we are deliberately not doing, and why>

---

## Open questions (blocking)

- <goal-level fork awaiting a human decision> *(awaiting steer — see comments)*
```

Follow the skeleton above; keep the app anchor, goal, hypothesis, metrics check, shaped feature, concepts, measurement plan, and tradeoffs in the body and every loop/steer round in comments.

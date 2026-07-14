---
name: comment-init
description: >-
  Initialize or refresh a repo for the `comment-*` skill family. Two layers:
  (1) the **repo config the skills read** — the `AGENTS.md`/`CLAUDE.md` "Agent
  Skill Config" pointer plus `docs/TESTING.md` (focused iteration checks and
  affected-candidate certification), inferred from the
  repo's build/test setup;
  and (2) the **architecture docs as comms** — one living "Architecture Overview"
  comm plus immutable per-decision ADRs in a Team Wiki folder. Idempotent —
  re-running reconciles existing files/comms instead of duplicating them. Trigger
  on "set up comment-init / the comment skills for this repo", "set up the
  testing config", "set up the architecture doc", "get my architecture",
  "document the architecture", "write an ADR", or "update the architecture
  overview". Works identically under Codex and Claude Code.
---

# comment-init — initialize a repo for the comment-* skills

`comment-init` makes a repo ready for the rest of the family (`comment-dev`,
`comment-feature`, `comment-bug`, `comment-spec`, `comment-prototype`, `ship`,
`review-loop`) by producing and maintaining two layers:

1. **Repo config (on disk, in the repo)** — the files those skills read to learn
   *this* repo, so they stay generic and don't hardcode commands:
   - the **Agent Skill Config** pointer in **`AGENTS.md` (else `CLAUDE.md`)**, and
   - **`docs/TESTING.md`** — the affected-test lane.
2. **Architecture docs (as Comment.io comms)**:
   - **Architecture Overview** — ONE living comm: *what is true now* (system
     overview, component boundaries, data flows, a Mermaid diagram, invariants).
     Re-running reconciles this same comm; it is never duplicated.
   - **Architecture Decision Records (ADRs)** — IMMUTABLE comms, one per decision,
     in a **Team Wiki folder**. An ADR records *why*; reversing a decision means a
     *new* ADR that supersedes the old one. The Overview's invariants link to the
     ADRs that justify them.

Run the **Repo config** layer first when setting a repo up for the skills; run the
**Architecture** layer to document or refresh how the system is built. Either can
run alone.

## When to use

- **First-time setup** of a repo for the `comment-*` skills → run the Repo config
  layer (scaffold `docs/TESTING.md` + the pointer), then optionally the Overview.
- A repo where the skills couldn't find test lanes / the pointer → scaffold them.
- After a structural change → refresh the Overview (idempotent) and the config if
  build/test commands changed.
- A decision future readers must understand → add an ADR.

## Identity

Before creating, patching, or commenting on Comment.io comms, use the first
working Comment.io route and keep its identity or supplied token. Invoke
`comment-identity` only immediately before an uncredentialed direct-REST write.
The **Repo config** layer writes only local files (no Comment.io identity
needed). Exception for comms: if Team Wiki placement or reconciling an existing
Overview requires a human-selected registered profile with the needed library
access, use that explicit profile only for those library
writes after confirming it is not a Botlets bot profile. Never fall through to an
ambient default profile just because it exists locally.

## Workflow — Repo config (the files the skills read)

This layer is **local files only**, committed with the repo so every agent (and
Codex Cloud) gets the same setup. Idempotent: reconcile what exists, never clobber
human-authored nuance without confirming.

1. **Find the agent guide.** Prefer **`AGENTS.md`**; else **`CLAUDE.md`** (commonly
   one is a symlink to the other). If neither exists, create `AGENTS.md` with a
   one-paragraph project overview.
2. **Detect the build/test setup.** Fan out read-only explorers over the repo's
   ecosystem signals — `package.json` scripts, `Makefile`/`Justfile`,
   `pyproject.toml`/`tox.ini`, `Cargo.toml`, `go.mod`, `.github/workflows/*`,
   monorepo layout. Identify the affected/local command agents should run before
   candidate certification, plus the narrowest focused commands for local
   convergence (single file, by-name filter, one package/shard, typecheck-only).
   Record full-suite commands only as manual diagnostics / CI reference, not as
   the routine pre-push gate.
3. **Derive two levels:**
   - **focused** — the narrowest useful checks during local convergence.
   - **`affected`** — typecheck/build when useful + affected/nearest tests, run
     once against the committed push candidate.
4. **Write/refresh `docs/TESTING.md`** from the template below. If it exists,
   reconcile (update commands that drifted; keep human notes) and report what
   changed; never overwrite wholesale.
5. **Write/refresh the Agent Skill Config pointer** in the guide: a short section
   linking **affected test lane → `docs/TESTING.md`**, **PR/branch/merge norms**,
   **deploy/preview**, and **architecture → `docs/ARCHITECTURE.md`** + the Overview
   comm. Keep the load-bearing commands inline in the guide too (agents that
   auto-load `AGENTS.md` — e.g. Codex — won't follow links on their own).
6. **Confirm before overwriting** anything a human clearly hand-authored — surface
   a diff and `steer` if unsure.

## Workflow — Architecture Overview

1. **Find the existing Overview** first by searching the **Team Wiki / Library context** (per `$BASE/llms/reference.txt`) — not just your own doc grants, since another agent may have created the Overview and it won't appear in your personal grant list. Match only one whose title/metadata names **this repo** (e.g. `Architecture: <repo>`) — a generic `Architecture Overview` with no repo identifier is **not** a match, since the same Team Wiki may hold overviews for several repos and you must never reconcile/overwrite another repo's doc. Exactly one repo-specific match → reconcile it; zero → create fresh (titled `Architecture: <repo>`) **with the Team Wiki `library_target`** (shared placement — never the default personal placement, or other agents won't find it on later runs and will create a duplicate); more than one → list them in a comment and disambiguate via `steer`. **Never create a second Overview for this repo.**
2. **Map the codebase**: fan out read-only explorers over the major subsystems (backend, frontend, shared packages, infra). Collect components, boundaries, data flows, invariants.
3. **Write/update** the Overview body from the template: overview → Mermaid system map → components & boundaries table → key data flows → invariants → open questions. Each invariant links to its ADR.
4. **Reconcile, don't duplicate**: patch the existing comm's sections to match reality; note drift you corrected.

## Workflow — ADRs

1. **Get the ADR folder id.** There is no folder-list endpoint that returns folder ids, so the create call (`POST /docs/folders` with the team `library_target` — see `$BASE/llms/reference.txt`) is how you obtain the folder `node.id`. The **first** time, create the "Architecture Decision Records" Team-library folder and **record its id in the Overview's `Decision records` section**; on later runs, reuse that recorded id rather than creating a second folder.
2. **Create the ADR inside that folder** by passing the folder id as the team-library parent on doc creation (see `$BASE/llms/reference.txt` for the exact field). Capture the ADR's `share_url`.
3. **Number sequentially** (`ADR-0001`, `0002`, …). Status lifecycle: `Proposed` (decision made, change not yet merged) → `Accepted` (the change merged) → `Superseded`. The only edits permitted on an existing ADR are **narrow header-metadata flips**: `Proposed`→`Accepted` on merge, and `Accepted`→`Superseded` with a `Superseded by` link when a new ADR records `Supersedes: ADR-NNNN`. **Never touch an ADR's Context / Decision / Consequences once written** — those stay immutable.
4. **Link** the new ADR from the relevant Overview invariant, and cross-link related ADRs.

## Idempotency rules

- **Repo config** — reconcile `docs/TESTING.md` and the pointer in place; update
  drifted commands, preserve human notes, never duplicate the section or clobber.
- One Overview per codebase — always reconcile the existing comm.
- One ADR folder — reuse the folder id recorded in the Overview; don't create a second.
- ADRs are append-only — never rewrite an accepted ADR's body; supersede it (the only allowed edit is the narrow `Status` / `Superseded by` header flip).

## Output / handoff

Return the paths written/updated (`docs/TESTING.md`, the guide's pointer section),
the human-openable Overview URL, and any new human-openable ADR URLs. `comment-feature` calls
`comment-init` to refresh the Overview on merge; the delivery skills rely on the
Repo config layer existing.

## Comment.io API

Use the current architecture comm and its working Comment.io route first. Resolve and freeze `$BASE` for the whole workflow in this order: the supplied comm's validated final Comment.io origin after any shortlink redirect; the active Comment.io tool/account base URL; an explicitly selected profile's `base_url`; only when no target context exists, `https://comment.io`. A shortlink origin is never `$BASE`; do not switch a staging/custom workflow to production. For direct REST, consult **`$BASE/llms/reference.txt`** only when exact API or recovery detail is needed. Fetch **`$BASE/llms.txt`** only when no current route works or another focused guide is needed. Invoke `comment-identity` only before an uncredentialed direct-REST write; otherwise keep the supplied route identity/token or the explicit Team Wiki profile named above. Don't restate the live contracts here.

**Content vs comments (team convention).** The *answer* → document **body**; *how you got there* (review-loop rounds, steering, escalations) → **comments**, as lists / short lines.

## Templates

**`docs/TESTING.md`** — sections: intro naming focused convergence checks and
affected candidate certification, plus when to skip it (genuinely docs-only) →
the narrowest focused commands and the final affected command → optional
`## full suites` reference (manual diagnostics and
CI only, never the routine pre-push gate) → `## CI / merge norms` → a
**lane → skill mapping** table. Fill commands from the repo's actual
`package.json`/`Makefile`/CI — never copy another repo's.

**Agent Skill Config pointer** (in `AGENTS.md`/`CLAUDE.md`) — a short section:
affected test lane → `docs/TESTING.md`; PR/branch/merge norms → the guide's sections;
deploy/preview → the guide's deploy section; architecture → `docs/ARCHITECTURE.md`
+ the Overview comm. Keep the core test/build/deploy commands inline in the guide.

**Architecture Overview** — sections: title + maintenance note (living, reconciled on merge) → `## 1 System overview` → `## 2 System map` (Mermaid) → `## 3 Components & boundaries` (table: Component | Path | Owns | Must not) → `## 4 Key data flows` → `## 5 Invariants` (each `→ [ADR-NNNN](url)`) → `## 6 Open questions` → `## 7 Decision records` (links to the ADR folder + each ADR).

**ADR** — sections: `# ADR-NNNN: <title>` + artifact note (immutable, Team Wiki) → **Status / Date / Deciders / Supersedes / Superseded by** → `## Context` → `## Decision` → `## Consequences` (✅/⚠️) → `## Related` (Overview section, related ADRs, code paths, PRs). Follow the section skeletons above; keep the Overview as the single living doc and each ADR immutable.

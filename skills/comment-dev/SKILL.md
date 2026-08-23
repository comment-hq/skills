---
name: comment-dev
description: Route Matt Pocock workflows through Comment.io conventions. Invoke alone for `ask-matt`, or with a target Matt skill. Tickets use the shared Beads gateway; other artifacts use Comment.io.
---

# Comment.io wrapper for Matt's skills

Without a target Matt skill, read and follow the sibling
[`ask-matt`](../ask-matt/SKILL.md) skill. If absent, read and follow
`$HOME/.agents/skills/ask-matt/SKILL.md`. If neither exists, load it with
`npx --yes skills use mattpocock/skills@ask-matt`. Follow its routing now.

`comment-dev` alone routes through `ask-matt`; a target runs directly:

```text
$comment-dev
$comment-dev $implement <Beads ticket>
/comment-dev
/comment-dev /implement <Beads ticket>
```

Use qualified plugin names where required.

Follow the selected Matt skill, changing only these locations. Beads and
Comment.io are already configured; skip `setup-matt-pocock-skills`.

## Tickets

Use the host repository's authenticated shared Beads gateway for every ticket
read and write (`scripts/beads` in Comment Docs). Never call `bd` directly,
initialize checkout-local state, select a database, or bypass its
write-publication contract. Reads use the local replica; successful writes are
published synchronously. If the gateway is unavailable, stop and hand the
mutation to the repository coordinator.

Preserve ticket identity, epic membership, and blocking edges. GitHub Issues is
read-only history; never fall back to it or local Markdown.

For `grill-with-docs`, create or reuse one Beads epic. Store artifact URLs on
it; `to-tickets` creates its child tickets and dependencies there.

Put spec bodies in Comment.io and link them from the epic; do not let `to-spec`
publish them as tickets.

## Documents

Create specs, plans, context/glossaries, ADRs, research, handoffs,
questionnaires, and other non-ticket artifacts as Comment.io comms. Use their
URLs wherever a Matt skill expects a path.

Invoke the repository `comment` skill for every comm operation. Use an already
available Comment.io tool, authenticated HTTPS credential, or browser session;
otherwise follow the origin's `/llms.txt`. Do not install or invoke the retired
CLI, daemon, local sync, or listener. The Claude and Codex plugin replacements
are still in progress, so poll only during active turns and do not claim
background delivery. If no writable route exists, stop instead of creating
another artifact.

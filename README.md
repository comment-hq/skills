# Comment.io overlay for Matt Pocock's skills

[![skills.sh installs](https://skills.sh/b/comment-hq/skills)](https://skills.sh/comment-hq/skills)

A thin explicit wrapper for
[mattpocock/skills](https://github.com/mattpocock/skills):

- tickets live in [Beads](https://github.com/gastownhall/beads), with one epic
  created when `grill-with-docs` starts;
- specs, plans, ADRs, research, handoffs, and other non-ticket artifacts live in
  Comment.io;
- implementation closes with one risk-scaled review lane; Matt's review replaces
  the general lane only when a line-addressable spec needs traceability or a
  non-tool-enforced standards audit is an acceptance concern. Every candidate
  gets simple, startup-pragmatic judgment before it becomes work.

Matt's skills still own the workflow. This overlay is runtime-generic: the same
skills work in Claude Code, Codex, Cursor, Gemini CLI, and other Agent Skills
clients.

## Install

Install Matt's skills first, then this overlay:

```bash
npx skills add mattpocock/skills
npx skills add comment-hq/skills
```

The replacement review uses fresh native subagents with read/search access to
an immutable target. Use a host with native delegation; Grok Build plus jq is an
optional explicitly selected second opinion or an alternative for hosts without
subagents. See the bundled code-review skill for the exact workflow and limits.

The order is intentional: this overlay replaces Matt's `code-review` in the
global skill namespace. Matt's original remains available as
`mattpocock/skills@code-review`.

Engineering delivery requires the host repository's authenticated shared Beads
gateway and a writable Comment.io route. The gateway, backed by a pinned `bd`,
owns database selection, writer serialization, and remote synchronization;
agents never call `bd` directly or initialize checkout-local Beads state. If the
host has no shared gateway, hand the mutation to its coordinator instead of
creating a second task ledger. If the `comment` skill is installed, the overlay
invokes it so it can reuse or mint the session identity. It invokes `listen` too
when that skill and the current runtime support idle mention delivery.

Invoke `comment-dev` alone to start with `ask-matt`, or supply a target Matt
skill to run it directly:

```text
# Codex
$comment-dev
$comment-dev $grill-with-docs <idea>
$comment-dev $implement <Beads ticket>

# Claude Code with copied skills
/comment-dev
/comment-dev /grill-with-docs <idea>
/comment-dev /implement <Beads ticket>
```

The bundle contains `comment-dev`, the replacement `code-review`, and its
model-invoked `review-judgment` helper.

## License

MIT — see [LICENSE](LICENSE).

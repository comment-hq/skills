---
name: comment-dev
description: Route Matt Pocock workflows through Comment.io conventions. Invoke alone for `ask-matt`, or with a target Matt skill. Use task context and optional Comment.io artifacts without requiring a tracker.
---

# Comment.io wrapper for Matt's skills

Without a target Matt skill, read and follow the sibling
[`ask-matt`](../ask-matt/SKILL.md) skill. If absent, read and follow
`$HOME/.agents/skills/ask-matt/SKILL.md`. If neither exists, load it with
`npx --yes skills use mattpocock/skills@ask-matt`. Follow its routing now.

`comment-dev` alone routes through `ask-matt`; a target runs directly:

```text
$comment-dev
$comment-dev $implement <task context>
/comment-dev
/comment-dev /implement <task context>
```

Use qualified plugin names where required.

Follow the selected Matt skill, changing only these locations. Comment.io is
already configured when available; skip `setup-matt-pocock-skills`.

## Task context and documents

Use the supplied task context and conversation. Do not create or require a task
tracker, fake gateway, local database, or GitHub Issues backlog. If a worklog is
explicitly requested or supplied, keep it concise and use it as evidence only.

Put requested specs, plans, ADRs, and research in Comment.io when that route is
available; do not manufacture artifacts merely to satisfy this wrapper.

## Documents

Invoke the repository `comment` skill for every comm operation. Use an already
available Comment.io tool, authenticated HTTPS credential, or browser session;
otherwise follow the origin's `/llms.txt`. Do not install or invoke the retired
CLI, daemon, local sync, or listener. The Claude and Codex plugin replacements
are still in progress, so poll only during active turns and do not claim
background delivery. If no writable route exists, stop instead of creating
another artifact.

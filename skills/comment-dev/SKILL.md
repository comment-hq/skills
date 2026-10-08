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

Use a connected Comment.io `run` tool at `https://comment.io/mcp` when your
client supports remote OAuth MCP. Run `help` to confirm the workspace and agent
before working on a comm. If a connection is needed, follow the
[MCP guide](https://comment.io/llms/mcp.md); a person in the workspace signs in
and approves the agent. Agents with a shell can follow the
[SSH guide](https://comment.io/llms/ssh.md), and agents able to make HTTPS
requests can follow the [HTTP API guide](https://comment.io/llms/http-api.md).

For ongoing use, follow the [using-commentio skill](https://comment.io/skills/using-commentio/SKILL.md)
for the intended workspace. Read the current comm before a requested change,
then read back the result. If no writable route is available, ask the person
to connect the workspace before writing. Support: support@comment.io.

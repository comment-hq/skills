# Use Comment.io with agents

Connect an agent to a Comment.io workspace using remote OAuth MCP at `https://comment.io/mcp` when your client supports it. A person in the workspace signs in and approves the agent. Ask the connected `run` tool to run `help`. See the [MCP guide](https://comment.io/llms/mcp.md).

Install the bundled [using-commentio skill](skills/using-commentio/SKILL.md) for agents working with shared documents over SSH or the HTTP API:

```sh
npx skills add comment-hq/skills --skill using-commentio
```

The [agent guide](https://comment.io/llms.txt) covers workspace setup and supported connections. Support: [support@comment.io](mailto:support@comment.io).

MIT — see [LICENSE](LICENSE).

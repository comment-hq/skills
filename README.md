# Comment.io workflow skills

**Legacy workflow overlay, not a connector for current Comment.io workspaces.** These optional skills wrap [mattpocock/skills](https://github.com/mattpocock/skills) and still contain instructions for the older Comm/document integration. Do not use their workspace instructions or older credentials with the current service. The bundled skills have not been migrated to current workspace access.

To connect an agent to a current workspace, use the remote OAuth MCP server at `https://comment.io/mcp`. A person in the workspace signs in and approves the agent. Ask the connected `run` tool to run `help`. See the [current MCP guide](https://comment.io/llms/mcp.md), or the [agent guide](https://comment.io/llms.txt) for SSH and HTTP alternatives. For ongoing agent use, install the [using-commentio skill](https://comment.io/skills/using-commentio/SKILL.md).

The existing overlay is distributed here for older workflows; its `comment-dev`, `code-review`, and `review-judgment` skills are not current-workspace onboarding.

MIT — see [LICENSE](LICENSE).

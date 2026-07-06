# Comment.io engineering-workflow skills

A small, opinionated set of [Agent Skills](https://agentskills.io) that give any
AI coding agent a complete **engineering delivery workflow** — plan, prototype,
build, review, and ship — with the working memory, decision history, and
human-steering channel living in a live [Comment.io](https://comment.io) worklog.

Runtime-generic: the same `SKILL.md` files work in Claude Code, Codex, Cursor,
Gemini CLI, and any agent that reads the Agent Skills format.

## Install (one bundle — the skills call each other, so install them together)

```bash
# Vercel `skills` CLI — installs into whichever agent(s) you have (~70 supported)
npx skills add comment-hq/skills

# GitHub CLI
gh skill install comment-hq/skills <skill> --agent claude-code   # or codex / cursor / gemini-cli

# Claude Code plugin marketplace
claude plugin marketplace add comment-hq/skills
```

## The skills

| Skill | What it does |
|---|---|
| `comment-dev` | Front door — describe the work, it routes to the right path below |
| `comment-spec` | Shape a rough idea into a crisp spec, then hand off to build |
| `comment-feature` | Build a defined feature end-to-end → merge-ready PR |
| `comment-bug` | Reproduce → failing test → fix → verify → PR |
| `comment-prototype` | Fast "let me see it first" change; skips the gate, promote later |
| `drive-plan` | The phased-plan execution engine the delivery skills run on |
| `review-loop` | A panel of independent reviewers looped until clean (in-flight gate) |
| `ship` | Take a branch to merge-ready: review gate → green → PR |
| `worklog` | The live working-memory comm — plan, status, decisions, open questions |
| `steer` | Keep a human in the loop; escalate decisions that shouldn't be made alone |
| `comment-identity` | Give the session a named, attributable Comment.io handle |
| `comment-init` | Scaffold a repo's test/PR config + architecture docs the skills read |
| `code-review` | One official, posted review on a PR |
| `file-bug` | Turn a report into a well-formed GitHub issue |
| `next` | Write a detailed handoff note for a future session |

## Requirements

- **git** and the **GitHub CLI (`gh`)** for the build/ship paths.
- **A Comment.io agent for the *worklog* path.** `worklog`, `steer`,
  `comment-feature`, `comment-bug`, and `comment-spec` write to a shared
  Comment.io doc, so they need a Comment.io identity to write as. Create a
  Comment.io agent and install its profile at <https://comment.io/setup>
  (agents can fetch <https://comment.io/llms/setup.txt>). Without one,
  `comment-identity` falls back to writing anonymously — nothing hard-blocks.
  The router (`comment-dev`), `comment-prototype`, `review-loop`, `ship`,
  `code-review`, `file-bug`, and `next` need no Comment.io account at all.

## How the skills learn your repo

The skills are repo-agnostic. They read your repo's `AGENTS.md` (or `CLAUDE.md`)
and the `docs/TESTING.md` it links for the affected-test lane used during
iteration, pre-push, PR creation, and merge-ready handoffs. Don't have those?
Run `comment-init` and it scaffolds them.

## License

MIT — see [LICENSE](LICENSE).

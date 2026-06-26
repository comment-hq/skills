# Context sources — where to track down what the next person needs

Use this to assemble the **Context** section. Pull what's relevant to *this* bug; skip
the rest. Prefer concrete artifacts (exact strings, URLs, commit SHAs, file:line, links
to transcripts/logs) over vague description. When something important is missing and you
can find it locally, find it. When only the user has it, ask.

## Contents

- [Git & environment state](#git--environment-state)
- [Claude Code session transcripts](#claude-code-session-transcripts)
- [Structured logs (local + Axiom)](#structured-logs-local--axiom)
- [Error codes, stack traces, console output](#error-codes-stack-traces-console-output)
- [URLs & where it happened](#urls--where-it-happened)
- [Filepaths & code locations](#filepaths--code-locations)
- [What to ask the user for](#what-to-ask-the-user-for)

## Git & environment state

Almost always worth including — it tells the next person *which version* the bug is on.

```bash
git rev-parse --short HEAD          # commit
git branch --show-current           # branch
git status --short                  # dirty working tree? uncommitted changes matter
git log --oneline -5                # recent commits for context
```

Environment, when relevant to the symptom:

```bash
node --version
sw_vers 2>/dev/null || uname -a     # OS / platform
```

Worktree/preview context (this repo): a worktree named `<name>` serves at
`https://<name>.toofs.us`. If the bug was seen on a preview, capture the worktree name
and URL.

## Claude Code session transcripts

If the bug happened **during a Claude Code session** (an agent did something wrong, a
command misbehaved, an edit went sideways), the session transcript is high-value context.

Transcripts live as `.jsonl` files under:

```
~/.claude/projects/<encoded-cwd>/
```

where `<encoded-cwd>` is the absolute working directory with every `/` (and `.`)
replaced by `-`. For this repo (`/Users/jgordner/Code/monorepo`) that is:

```
~/.claude/projects/-Users-jgordner-Code-monorepo/
```

Find the relevant session (most recent, or by timestamp / content match):

```bash
ls -lt ~/.claude/projects/-Users-jgordner-Code-monorepo/*.jsonl | head
# search transcripts for the symptom:
grep -l "<error string or symptom>" ~/.claude/projects/-Users-jgordner-Code-monorepo/*.jsonl
```

In the issue, **link the transcript path** and, if useful, quote the few relevant lines
(the failing tool call + its output). Don't paste an entire transcript.

## Structured logs (local + Axiom)

Both backend and frontend log JSON (`{"ts","level","component","msg","data"}`). See
`docs/LOGGING.md`.

Local dev logs:

```bash
make logs          # tail all structured logs (jq)
make logs-errors   # errors/warnings only
```

Axiom (shipped logs) — dataset `comment-docs` (prod) / `comment-docs-staging`. Query for
the error around the time it happened (token in `.env.local` as `AXIOM_TOKEN`):

```bash
source .env.local
curl -s -H "Authorization: Bearer $AXIOM_TOKEN" -H "Content-Type: application/json" \
  -d '{"apl":"[\"comment-docs\"] | where level == \"error\" | take 20","startTime":"<ISO>","endTime":"<ISO>"}' \
  'https://api.axiom.co/v1/datasets/_apl?format=tabular'
```

Use bracket quoting for nested fields (`['data.slug']`) and filter `side == "server"` to
cut OTLP noise. Capture the matching log line(s) or an Axiom query the next person can
re-run, plus the time window.

## Error codes, stack traces, console output

- Quote the **exact** error string/code, verbatim — not a paraphrase.
- For frontend errors, ask for / capture the browser console + network tab if relevant.
- WebSocket close codes matter in this app (e.g. `4426 upgrade_required`, `NOT_AUTHOR`
  mark-rejection). Include the code and the message.
- If you can reproduce locally, note the steps you ran and what you saw. If you couldn't
  reproduce, say so explicitly.

## URLs & where it happened

The single most common missing piece. Capture the exact URL/route:

- Local preview: `https://<worktree>.toofs.us/...`
- Personal staging: `<name>.comt.dev` / `<name>.botlets.dev`
- A specific doc: include the slug.

If you don't have it, **ask the user which URL/route the bug occurred on.** Don't guess.

## Filepaths & code locations

If the symptom clearly maps to an area of the code, point at it with `file:line` so the
next person starts in the right place — e.g. `src/editor/ProvenanceGutter.tsx:142`. This
is *orientation*, not a diagnosis: name where the behavior surfaces, not what to change.
Use `grep`/search to locate the relevant component or handler when it's not obvious.

## What to ask the user for

Only ask for what you can't get yourself, and batch it. Typically:

- Exact URL/route and (for shared docs) the slug.
- Exact reproduction steps, if the symptom isn't self-evident.
- A screenshot or the literal error text, if it's a UI/console error you can't see.
- Which environment (local worktree / staging / prod) it happened on.
- For an idea: the underlying goal — what they're trying to accomplish.

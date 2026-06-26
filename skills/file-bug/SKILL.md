---
name: file-bug
description: Turn a user's report of something going wrong into a well-formed GitHub issue in the repo Claude is running in. Invoke explicitly as `$file-bug` or `/file-bug`, or when the user describes a defect, regression, broken behavior, confusing UX, error message, or a product idea and wants it captured as an issue/ticket — phrases like "file a bug", "open an issue for this", "log a ticket", "something's broken, write it up", or "track this idea". This skill investigates and writes the issue so the next person can understand AND reproduce the problem; it does NOT fix the bug or propose a fix.
---

# File Bug

Turn "here's what's going wrong" into a GitHub issue that lets whoever picks it up
**understand what happened and figure out how it happened** — without having to come
back and ask the reporter for basics.

## The one rule that defines this skill

**Your job is to capture, not to cure.** Do not design, propose, or implement a fix.
Do not root-cause to a code change. You may record a *suspected area* in Context if you
genuinely observed evidence for it, but never frame the issue around a solution. The
person who picks up the issue owns the diagnosis and the fix.

## Issue format (always)

The issue **body** uses exactly these three sections, in this order:

```markdown
## What actually happened
<the observed behavior — concrete, specific, what the user/system did and saw>

## What should have happened
<the expected behavior — what the user expected instead>

## Context
<everything the next person needs to understand and reproduce it — see below>
```

The **title** is a short, specific summary of the symptom (not the fix). Good:
`Comment anchor jumps to wrong paragraph after deleting a list item`. Bad:
`Fix anchor bug` / `Anchors broken`.

## Workflow

### 1. Get the report

If the user already described what's wrong, use that. If they invoked the skill with no
description, just ask them — openly — what went wrong (e.g. "What happened? Describe it
however's easiest."). **Do not ask them to categorize it, pick a type, or answer setup
questions first.** They came to report a problem; let them talk, then you do the work.

### 2. Classify silently (don't ask)

Once you have their report, infer the type yourself — this only decides the label and
framing, so don't make it a question to the user:

- **Bug / defect / regression** → something behaves wrong vs. how it's supposed to work.
  Label `bug`. Both "what actually" and "what should have" describe real-vs-expected
  behavior.
- **Idea / feature request / improvement** → the app works as built, but the user wants
  it to do something new or better. Label `enhancement`. Reframe the sections honestly:
  "What actually happened" = current behavior/limitation, "What should have happened" =
  the proposed behavior. Don't dress an idea up as a defect.

In almost every case the type is obvious from what they wrote, or becomes obvious as you
gather context. If it's genuinely still ambiguous when you reach the draft, just pick the
better-fitting label and state your read in the draft so they can correct it — don't
block on a classification question.

### 3. Confirm the filing target

The issue goes in **the repo Claude is running in**. Verify it:

```bash
gh repo view --json nameWithOwner -q .nameWithOwner
```

If there are multiple remotes or the cwd is ambiguous, confirm the repo with the user
before filing. Never file into a repo the user didn't intend.

### 4. Gather context — actively

This is the core of the skill. The reporter usually gives you the symptom; **you** are
responsible for assembling the surrounding evidence so the next person doesn't start
from zero.

Pull what's relevant and available. **If important user or machine context is missing,
track it down on the local machine before filing.** If it genuinely requires the user
(e.g. which URL it happened on, exact reproduction steps, a screenshot), **ask** —
batch your questions into one short message.

Read **[references/context-sources.md](references/context-sources.md)** for the catalog
of where to find each kind of context (git/env state, Claude Code session transcripts,
structured logs / Axiom, error codes, URLs, filepaths) and the exact commands.

Judgment call: include what materially helps understanding or reproduction; omit noise.
A great issue has *enough* — exact error string, the URL, the branch+commit, a link to
the session transcript, the relevant filepath — not a data dump.

### 5. Pre-flight checks — always, before proposing to file

Run both checks before you draft the issue. They catch bugs that are already fixed or
already tracked, so you don't file noise.

**a. Is the user on the latest CLI?** This repo's bug might already be fixed in a newer
`@comment-io/cli` (binary `comment`). Check non-destructively:

```bash
comment upgrade -dry-run            # repo's native check: prints the upgrade plan, changes nothing
npm ls -g @comment-io/cli           # installed version
npm view @comment-io/cli version    # latest published version
```

If they're behind and the bug plausibly involves the CLI / agent runtime / daemon, tell
the user the bug may already be fixed and recommend `comment upgrade` then re-checking
**before** filing. Don't upgrade for them; ask. If it's clearly a web-app/backend bug
unrelated to the CLI, note the installed version in Context and move on.

**b. Is this issue already filed?** Search existing issues (open *and* recently closed —
a closed/fixed match may mean it's already resolved):

```bash
gh issue list --state all --search "<key terms from the symptom>" --limit 20
# or broader: gh search issues --repo "<owner/repo>" "<key terms>"
```

If you find a likely match, **show it to the user and ask** whether to add a comment to
the existing issue instead of opening a new one. Don't silently file a duplicate. If a
closed issue looks like the same bug resurfacing, point that out (possible regression).

### 6. Draft, confirm, then file

1. Compose the full issue (title + 3-section body + proposed labels).
2. **Show the user the complete draft and the labels, and wait for their go-ahead.**
   Do not file until they confirm. They may edit anything.
3. On confirmation, file it:

```bash
gh issue create \
  --title "<title>" \
  --body-file <tmpfile>   # write the body to a temp file to preserve markdown/newlines
  --label "<bug|enhancement|...>"
```

   Use only labels that exist in the repo (`gh label list`). If a fitting label is
   missing, file without it rather than inventing one, and mention the gap.
4. Hand back the issue URL.

## Labels

Check `gh label list` for the repo's actual set. Common mapping:

- defect / regression / broken behavior → `bug`
- idea / feature request / improvement → `enhancement`
- docs problem → `documentation`
- needs clarification → `question`

Apply the one label that best fits. Don't over-label.

## What not to do

- Don't propose or implement a fix, and don't open a PR. That's `$comment-bug`'s job, not this skill's.
- Don't file before showing the draft and getting confirmation.
- Don't invent reproduction steps, error messages, or context you didn't verify. If you
  inferred something, say so in the issue ("reporter says…", "could not reproduce locally").
- Don't pad Context with irrelevant environment dumps.

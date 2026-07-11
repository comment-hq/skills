---
name: comment-identity
description: >-
  Give this agent session a named, session-scoped Comment.io identity instead of
  writing as faceless anonymous. Runtime-generic (Claude Code, Codex, any shell
  agent). On the session's FIRST write to Comment.io, lazily mint ONE ephemeral
  "ephemeral" handle (@owner.e-xxxx) bound to this session, then write/comment as
  that handle so the work is attributed and @mentionable. A primitive the
  generic comment skills (comment, worklog, comment-feature, comment-bug, ...)
  invoke before its first write. The generic `comment` skill points here; invoke
  when an agent is about to create/edit a comm or post a comment, especially for
  live worklogs and delivery tasks, even if registered profiles exist. Mints over
  EITHER a paired computer (the daemon's own token — native, or a Docker-caged
  daemon via `docker exec`; no key to copy) OR the owner's ark_ key; degrades to
  anonymous when neither is available. (Pairing enables identity for the paired
  host's origin; a different origin still needs an ark_ key.) Works the same under
  Codex and Claude Code.
---

# comment-identity — a named identity for this session, by default

Without this, an agent with no registered `@handle` writes to Comment.io as an
**anonymous** per-doc token: faceless, not @mentionable, no notifications, no
identity across docs. This primitive upgrades the default by one rung: the first
time the session writes, it acquires ONE **ephemeral** handle (`@owner.e-xxxx` —
ephemeral, session-scoped, 30-day-idle TTL, can never become a botlet) and
writes as that named handle for the rest of the session.

It is **lazy** (nothing is minted until the first write — read-only sessions stay
anonymous) and **idempotent per session** (every later call reuses the same
handle). One canonical helper does the work: `ensure-session-identity` (next to
this file).

## When to run it

Call it **right before the session's first Comment.io write** — the first
`POST /docs` (create a comm), first `POST /docs/:slug/comments`, or first
`PATCH /docs/:slug`. The generic `comment`/`worklog`/`comment-feature`/
`comment-bug` skills call it at that point. Do **not** run it just to *read* a
doc; reading is fine anonymously.

For live worklogs and delivery skills, use this session-scoped ephemeral identity
by default even when `agents/*.json` contains registered handles. A long-running
coding session needs an identity that belongs to THIS session, not a durable
handle a botlet or another runtime may also be polling. Only use a registered
profile when the human explicitly asked this session to act as that profile and
you have confirmed it is not a Botlets bot profile. Botlets bot profiles never
count as a safe ambient coding-session identity.

Dedicated service workflows can opt out explicitly when their contract requires a
durable daemon-backed identity. The sweep skills' `@bug-bot` path is one such
exception: it is shared automation that waits on one bot inbox across runs, not
an ordinary coding-session worklog.

## Use it

First set the **target host** — mint/reuse against the SAME host your task is on
(the host of the doc you're working on, e.g. `https://comt.dev` for a comt.dev
share URL, or your staging host). Only known Comment.io hosts are accepted
(comment.io, *.comt.dev, *.toofs.us, localhost); both the CLI and the helper
refuse to send your ark key anywhere else. **IMPORTANT:** creds AND the Claude
wake binding live in your `COMMENT_IO_HOME` / `COMMENT_IO_ENV` home — the same
place the wake hook reads — so for a staging target also set
`COMMENT_IO_ENV=staging` (or `COMMENT_IO_HOME`) so home, base, and notifications
all agree; otherwise a staging ark/cred is missed and @mentions won't wake you.

```sh
{ set +x; } 2>/dev/null   # never trace identity steps — they touch a secret
BASE="https://comt.dev"   # set to the host of the doc/API you are working on
case "$BASE" in           # comt.dev / toofs.us hosts are staging — align home + wake hook
  https://comt.dev|https://comt.dev/|https://*.comt.dev|https://*.comt.dev/|https://*.toofs.us|https://*.toofs.us/) export COMMENT_IO_ENV=staging ;;
esac
```

**Prefer the `comment` CLI when it's installed** — `comment ephemeral ensure`
does the whole thing (reuse-or-mint, store, bind, print) in one reliable command
with all the safety built in. Otherwise run the `ensure-session-identity` script
shipped **beside this SKILL.md** (it prints the same `OK <handle> <credfile>`
line and uses the same exit codes). Add `--session <stable-id>` only if neither
`COMMENT_IO_SESSION_ID` nor your runtime's session var (`CODEX_THREAD_ID` /
`CLAUDE_CODE_SESSION_ID`) is set.

```sh
# Probe `comment ephemeral` support too — a stale CLI on PATH has `comment` but
# not the `ephemeral` subcommand, so command -v alone would wrongly skip the
# helper and fall back to anonymous during a pre-CLI-upgrade rollout.
if command -v comment >/dev/null 2>&1 && comment ephemeral --help >/dev/null 2>&1; then
  out="$(comment ephemeral ensure --base-url "$BASE")"; rc=$?
else
  # No (or stale) comment CLI; use the helper bundled with THIS skill. No
  # $SKILL_DIR var is injected, so locate it:
  HELPER="$(find "$HOME/.claude" "$HOME/.codex" "$PWD/.agents" "$PWD/.claude" \
              -name ensure-session-identity -path '*comment-identity*' 2>/dev/null | head -n1)"
  out="$("$HELPER" --base "$BASE")"; rc=$?
fi
case "$rc" in
  0) handle="$(printf '%s' "$out" | awk '/^OK /{print $2}')"
     # cred path is everything after the handle — sed so a $HOME with spaces is safe:
     cred="$(printf '%s' "$out" | sed -n 's/^OK [^ ]* //p')" ;;
  2) : "no ark key — stay anonymous (see below)"; ;;
  3) : "no stable session key — ask the user (see below)"; ;;
  *) : "mint error — see stderr; fall back to anonymous"; ;;
esac
```

**Scope — which token to write with.** The ephemeral `as_` identifies you on docs
you **create** (`POST /docs` makes you the creator) and on your own new comms. It
does **not** grant access to a comm someone else shared with you: if you only
have a per-doc share token (from a share URL), that token *is* your access — keep
using it for writes on that doc (identify once via `POST /agents/identify`), and
do **not** swap in the ephemeral secret, which isn't on that doc's ACL and would
`403`. Use the ephemeral identity to create/own comms; use the supplied doc token
for docs shared to you (or first invite the ephemeral handle with that token).

On success, read the secret from the cred file and use it as the Bearer token
for writes to comms you create. Put it in a **0600 header file** and use
`curl --header @file` — that keeps the secret out of argv (`ps` /
`/proc/<pid>/cmdline`), just like the helper does for `ark_`. Keep tracing off so
it never lands in a log:

```sh
{ set +x; } 2>/dev/null
AUTH_HDR="$(mktemp "${TMPDIR:-/tmp}/cio-auth.XXXXXX")"; trap 'rm -f "$AUTH_HDR"' EXIT
CRED="$cred" python3 -c 'import json,os;print("Authorization: Bearer "+json.load(open(os.environ["CRED"]))["agent_secret"])' > "$AUTH_HDR"
# Now authenticate every call with the header file (never -H "...$SECRET..."):
# curl --header @"$AUTH_HDR" ...      (never echo the secret or this file)
```

The helper resolves the session key from `COMMENT_IO_SESSION_ID`, else
`CODEX_THREAD_ID`/`CODEX_SESSION_ID`, else `CLAUDE_CODE_SESSION_ID`, else
`--session <id>`. It passes the `ark_` key via a
0600 header file (never argv), writes nothing it doesn't have to, and never
echoes a secret. See its header comment for flags and exit codes.

## Name yourself (placeholder now, real name once you know the job)

The mint hands you a random handle and a default human first name as a
placeholder. Once you know what this session is doing, set a friendlier name with
`PATCH /agents/me` (`{"name":"..."}`) authenticated with the `$AUTH_HDR` file above:

- Start from a regular human **first name** ("Anne", "Fred", "Sam"). No "Bot",
  "Agent", "AI", or the `e-xxxx` suffix.
- Add the job in parentheses, **short** — alliterative if you can
  ("Sam (Shortlinks)"), else given name + job ("Fred (shortlinks)").
- Avoid clashing with other **currently-active** ephemeral handles on the doc —
  check participants/presence and pick a different first name if one is taken.
- Update `display_name` in the cred file to match if you want it to persist.

## Receiving @mentions on docs you work in (important)

A comm you create with your Ephemeral secret is joined immediately: authenticated
`POST /docs` writes the server-side join marker, so collaborators can @mention
that handle on the new comm. For an existing comm where your handle was invited
or @mentioned, read it back once with your secret to stamp the marker before you
rely on later collaborator mentions to wake you:

```sh
curl -s --header @"$AUTH_HDR" "$BASE/docs/$slug" >/dev/null
```

(Editing it via `PATCH` or posting a comment does the same.) Then later
collaborator @mentions on that doc reach you.

## Notifications — what actually works where

**Mint through the helper, never raw.** What makes you *reachable* is the
session→handle bind pointer, and only `comment ephemeral ensure` /
`ensure-session-identity` (or `/comment listen`) writes it. A raw
`POST /agents/ephemeral` — or re-using a previous session's stored cred without
re-running the helper — gives you a writable identity that is **not armed to
receive**: @mentions queue to its inbox and nothing wakes you. Always acquire (or
re-acquire) the ephemeral identity through the helper so the listener is armed for
*this* session.

- **Claude Code:** live. The helper writes the session→handle bind pointer the
  plugin's asyncRewake Stop hook reads, so an @mention wakes this idle session at
  zero token cost — same mechanism as `/comment listen`. (See the cross-tool
  contract below.)
- **Other runtimes (Codex, bare shells):** no Stop hook, so there is no idle
  wake. Poll `GET /agents/me/notifications` with `$SECRET` between turns to catch
  @mentions while the session is active. Be honest with the user: off-Claude,
  "you'll be notified" means "I'll check when I take a turn," not push.

## Degradation & teardown

- **No `ark_` key (exit 2):** stay anonymous and tell the user once how to enable
  named identity — reveal an `ark_` at `<BASE>/settings`, then `export
  COMMENT_IO_ARK_KEY=...` or add it to `~/.comment-io/config.env`. Don't take the
  key in chat; don't block the task.
- **No stable session key (exit 3):** the helper refuses to mint (an unstable key
  re-mints every turn). Ask the user to set `COMMENT_IO_SESSION_ID` to a value
  constant for the session, or pass `--session`.
- **Teardown:** the handle expires ~30 days after last use (refreshed on every
  use, so an active session is never reaped). To release it early when a session
  truly ends, `DELETE /agents/me` with `$SECRET` (best-effort).

## Cross-tool contract: the bind pointer

`~/.comment-io/rewake/bind-<session>` (text = the handle) and
`~/.comment-io/ephemeral/<handle>.json` (0600 cred) are a shared contract:
`ensure-session-identity` and `/comment listen` **write** them; the Claude plugin
asyncRewake Stop hook **reads** them to arm the listener; the plugin SessionEnd
hook removes the bind on session close. Any tool minting an ephemeral identity
should use these exact paths so notifications and reuse keep working. Each
session mints its own unique handle, so the handle-keyed cred never collides
across concurrent sessions. The cred is also stamped with its session id, so if
the bind pointer is ever lost the helper reclaims the existing handle instead of
minting a new one. Note the SessionEnd bind cleanup is **Claude-plugin-only** —
non-Claude runtimes leave the bind file until the handle's TTL expires or the
session id is reused (harmless; an expired cred is rejected and re-minted).

## Comment.io API

**Read `$BASE/llms.txt`** as the current docs index, then **read `$BASE/llms-full.txt`** for the complete Ephemeral identity lifecycle and listening contract.
`$BASE` defaults to `https://comment.io` (or the staging cascade). The ephemeral
mint endpoint and lifecycle are documented there under "Ephemeral handles".

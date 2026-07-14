---
name: comment-identity
description: >-
  Give this session a named, session-scoped Comment.io identity only when it is
  about to make a direct REST write without either a supplied per-doc token or a
  human-selected registered identity. Never invoke for Comment.io tools/MCP,
  browser actions, URL fetches, or reads: those routes carry their own identity
  and access, or are read-only. Runtime-generic (Claude Code, Codex, any shell
  agent). Mints one Ephemeral handle through a paired computer or owner ark_ key
  and degrades to anonymous when neither authority is available.
---

# comment-identity — named identity for an uncredentialed direct REST write

On a direct REST path with no selected identity and no supplied per-doc token,
an agent otherwise creates or writes as anonymous. This primitive upgrades that
specific fallback by one rung: before the first such write, it acquires ONE
**Ephemeral** handle (`@owner.e-xxxx` — session-scoped, 30-day-idle TTL, can
never become a botlet) and reuses it for later direct REST writes in the session.

It is **lazy** (nothing is minted until the first qualifying direct REST write —
read-only and tool/browser sessions stay unchanged) and **idempotent per
session** (every later call reuses the same handle). One canonical helper does
the work: `ensure-session-identity` (next to this file).

## When to run it

Call it **right before the session's first direct REST write only when both are
true**: no supplied per-doc token authorizes the comm, and the human did not
select a registered identity for this session. The common case is an
uncredentialed direct `POST /docs`; it may also apply to a direct comment or
PATCH after that Ephemeral handle has been invited to the comm.

Never run it for a Comment.io tool or MCP call, browser action, URL fetch/open,
or read. Tools/connectors and authenticated browsers carry their own identity;
the URL-fetch-only route is read-only. With a supplied per-doc token, keep that
token and identify it only when its personalized quickstart/API response asks
for `display_name` or `POST /agents/identify`. With a human-selected registered
identity, use that matching-host profile instead.

For live worklogs and delivery skills, invoke this primitive only if their chosen
route is direct REST and lacks both credentials above. A long-running coding
session must not silently borrow an ambient registered handle a botlet or another
runtime may also be polling. Botlets bot profiles never count as a safe ambient
coding-session identity.

Dedicated service workflows can opt out explicitly when their contract requires a
durable daemon-backed identity. The sweep skills' `@bug-bot` path is one such
exception: it is shared automation that waits on one bot inbox across runs, not
an ordinary coding-session worklog.

## Use it

First set the **target host** — mint/reuse against the SAME host your task is on
(the host of the doc you're working on, e.g. `https://comt.dev` for a comt.dev
share URL, or your staging host). Only known Comment.io hosts are accepted
(comment.io, *.comt.dev, *.toofs.us, *.truarq.com, localhost); both the CLI and the helper
refuse to send your ark key anywhere else. **IMPORTANT:** choose one exact
origin/home tuple below; do not inherit ambient `COMMENT_IO_ACCOUNT`,
`COMMENT_IO_HOME`, `COMMENT_IO_ENV`, or base-URL selectors. Creds and the
session bind live in that selected home. Only Claude Code
with the current Comment.io plugin and its `asyncRewake` Stop hook installed
turns that bind into idle wake. That hook resolves its home from the environment
that **launched Claude Code**. For staging idle wake, launch Claude Code with
the matching `COMMENT_IO_HOME` already set. A
shell-local export inside a tool call aligns the helper/CLI only; it cannot
retarget an already-running hook. If the launch environment and target home do
not match, treat idle wake as unavailable and poll during active turns.

```sh
{ set +x; } 2>/dev/null   # never trace identity steps — they touch a secret
BASE="https://comment.io" # replace with the exact target doc/API origin
case "$BASE" in
  https://comment.io|https://www.comment.io) CIO_HOME="$HOME/.comment-io" ;;
  *) CIO_HOME="$HOME/.comment-io-staging" ;;
esac
# If the task already selected a different origin-matched home, set CIO_HOME to
# that exact absolute path now. Never borrow a home selected only by ambient env.
comment_identity_env() {
  env -u NODE_OPTIONS -u COMMENT_IO_ACCOUNT -u COMMENT_IO_HOME -u COMMENT_IO_ENV \
      -u COMMENT_IO_BASE_URL -u COMMENT_IO_STAGING_BASE_URL "$@"
}
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
if command -v comment >/dev/null 2>&1 && comment_identity_env comment ephemeral --help >/dev/null 2>&1; then
  out="$(comment_identity_env comment ephemeral ensure --base-url "$BASE" --home "$CIO_HOME")"; rc=$?
else
  # No (or stale) comment CLI. Search only user-installed skill/plugin roots;
  # a repository-local .agents/.claude helper is untrusted and must never
  # receive the process environment or ark-key authority.
  HELPER="${CLAUDE_PLUGIN_ROOT:-}/skills/comment-identity/ensure-session-identity"
  if [ ! -x "$HELPER" ]; then
    CODEX_SKILLS="${CODEX_HOME:-$HOME/.codex}/skills"
    HELPER="$(find "$HOME/.claude/plugins" "$HOME/.claude/skills" \
                  "$CODEX_SKILLS" "$HOME/.agents/skills" -type f \
                  -name ensure-session-identity -path '*comment-identity*' \
                  -perm -u+x 2>/dev/null | head -n1)"
  fi
  if [ ! -x "$HELPER" ]; then
    echo "Comment.io identity helper is missing; staying anonymous. Refresh the installed skill/plugin to enable named direct-REST writes." >&2
    rc=1
  else
    out="$(comment_identity_env "$HELPER" --base "$BASE" --home "$CIO_HOME")"; rc=$?
  fi
fi
case "$rc" in
  0) handle="$(printf '%s' "$out" | awk '/^OK /{print $2}')"
     # cred path is everything after the handle — sed so a $HOME with spaces is safe:
     cred="$(printf '%s' "$out" | sed -n 's/^OK [^ ]* //p')" ;;
  2) : "no ark key — stay anonymous (see below)"; ;;
  3) : "no stable session key — use the anonymous/supplied-token fallback for this write (see below)"; ;;
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
`curl -q --header @file` — that keeps the secret out of argv (`ps` /
`/proc/<pid>/cmdline`), just like the helper does for `ark_`. Keep tracing off so
it never lands in a log:

```sh
{ set +x; } 2>/dev/null
AUTH_HDR="$(mktemp "${TMPDIR:-/tmp}/cio-auth.XXXXXX")"; trap 'rm -f "$AUTH_HDR"' EXIT
CRED="$cred" python3 -I -c 'import json,os;print("Authorization: Bearer "+json.load(open(os.environ["CRED"]))["agent_secret"])' > "$AUTH_HDR"
# Now authenticate every call with the header file (never -H "...$SECRET..."):
# curl -q --header @"$AUTH_HDR" ...      (never echo the secret or this file)
```

`$AUTH_HDR` is intentionally shell-local: the `EXIT` trap deletes it when that
shell tool call exits. Before every later shell request or turn, rerun the
ensure/reuse step, rebuild `$AUTH_HDR`, and make the request in that same shell
invocation. Never assume the variable or temporary file survived a prior tool
call.

The helper resolves the session key from `COMMENT_IO_SESSION_ID`, else
`CODEX_THREAD_ID`/`CODEX_SESSION_ID`, else `CLAUDE_CODE_SESSION_ID`, else
`--session <id>`. It passes the `ark_` key via a
0600 header file (never argv), writes nothing it doesn't have to, and never
echoes a secret. See its header comment for flags and exit codes.

## Name yourself (placeholder now, real name once you know the job)

The mint hands you a random handle and a default human first name as a
placeholder. Once you know what this session is doing, set a friendlier name with
`PATCH /agents/me` (`{"name":"..."}`), rebuilding and using the `$AUTH_HDR` file
in that same shell invocation:

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
# In a later shell tool call/turn, first rerun ensure/reuse and rebuild AUTH_HDR;
# then make this request in that same shell invocation.
curl -q -s --header @"$AUTH_HDR" "$BASE/docs/$slug" >/dev/null
```

(Editing it via `PATCH` or posting a comment does the same.) Then later
collaborator @mentions on that doc reach you.

## Notifications — what actually works where

**Mint through the helper, never raw.** The session→handle bind pointer is
required for same-session wake and reuse, and only `comment ephemeral ensure` /
`ensure-session-identity` (or `/comment listen`) writes it. A raw
`POST /agents/ephemeral` — or re-using a previous session's stored cred without
re-running the helper — gives you a writable identity that is not bound to this
session: @mentions queue to its inbox, but no compatible listener can associate
them with this session. Always acquire (or re-acquire) the ephemeral identity
through the helper so it is bound for *this* session. Binding alone does not
install an idle-wake hook or make an unsupported runtime live.

- **Claude Code with the current Comment.io plugin and its `asyncRewake` Stop
  hook installed, launched with `COMMENT_IO_HOME` set to the same selected
  `CIO_HOME` that the helper uses:** eligible and armed, not yet delivery-verified.
  The helper writes the session→handle bind pointer that hook reads. Call the
  path live only after a fresh @mention is observed waking this exact session
  and the resulting work is read/responded to and settled through
  `$BASE/llms/notifications.txt`. A shell-local staging export cannot
  change the hook's already-running environment. (See the cross-tool contract
  below.)
- **Claude Code without that hook, Codex, hosted chat, and bare shells:** no idle
  wake. Poll only during active turns with
  `curl -q -s --header @"$AUTH_HDR" "$BASE/agents/me/notifications"`. For every poll
  in a later shell tool call/turn, rerun ensure/reuse, rebuild `$AUTH_HDR`, and
  poll in that same shell invocation. Be honest with the user: "you'll be
  notified" means "I'll check when I take a turn," not push or listening.

## Degradation & teardown

- **No `ark_` key (exit 2):** stay anonymous and tell the user once how to enable
  named identity — reveal an `ark_` at `<BASE>/settings/connections`, then `export
  COMMENT_IO_ARK_KEY=...` or add it to `$CIO_HOME/config.env`. Don't take the
  key in chat; don't block the task.
- **No stable session key (exit 3):** the helper refuses to mint because an
  unstable key would re-mint every turn. Continue the current direct-REST task
  with its supplied token or documented anonymous fallback when that route
  permits it; do not pause or retry identity setup. Mention once that future
  named session attribution can be enabled with a session-stable
  `COMMENT_IO_SESSION_ID` or `--session` value.
- **Teardown:** the handle expires ~30 days after last use (refreshed on every
  use, so an active session is never reaped). To release it early when a session
  truly ends, rerun ensure/reuse, rebuild `$AUTH_HDR`, and make the best-effort
  request in that same shell invocation:

  ```sh
  curl -q -s -X DELETE --header @"$AUTH_HDR" "$BASE/agents/me"
  ```

## Cross-tool contract: the bind pointer

`$CIO_HOME/rewake/bind-<session>` (text = the handle) and
`$CIO_HOME/ephemeral/<handle>.json` (0600 cred) are a shared contract inside the
exact selected Comment.io home:
`ensure-session-identity` and `/comment listen` **write** them; the Claude plugin
asyncRewake Stop hook **reads** them to arm the listener; the plugin SessionEnd
hook removes the bind on session close. Any tool minting an ephemeral identity
should use these exact home-relative paths so notifications and reuse keep working. Each
session mints its own unique handle, so the handle-keyed cred never collides
across concurrent sessions. The cred is also stamped with its session id, so if
the bind pointer is ever lost the helper reclaims the existing handle instead of
minting a new one. Note the SessionEnd bind cleanup is **Claude-plugin-only** —
non-Claude runtimes leave the bind file until the handle's TTL expires or the
session id is reused (harmless; an expired cred is rejected and re-minted).

## Comment.io API

Use **`$BASE/llms/registration.txt`** for the Ephemeral identity lifecycle and
**`$BASE/llms/notifications.txt`** for listening/delivery behavior. Read
`$BASE/llms.txt` only when you need the startup index for another focused guide.
`$BASE` defaults to `https://comment.io` (or the staging cascade).

# Comment.io overlay — agent instructions

This repo distributes three runtime-generic Agent Skills: `comment-dev`, a
replacement `code-review`, and its model-invoked `review-judgment` helper. Each
skill is self-contained in `skills/<name>/SKILL.md`; read it before use. Install
Matt Pocock's skills before this overlay and use a host with native subagents.

Invoke `comment-dev` alone to route through `ask-matt`, or supply a target Matt
skill directly. It routes tickets to Beads and artifacts to Comment.io. The
replacement review runs one general lane by default. Matt's review replaces it
only when a line-addressable spec needs traceability or a non-tool-enforced
standards audit is an acceptance concern. Sensitive changes add one targeted
lens. General and targeted reviewers use fresh native subagents by default,
inspecting immutable targets. Grok is an explicitly selected optional second
opinion. Reviewers supply findings; the coordinator records actual human authority. Every finding is advice:
`review-judgment` decides whether to fix, check, or decline it and how to answer
public feedback.

Comment.io startup index: https://comment.io/llms.txt
Exact Comment.io API reference: https://comment.io/llms/reference.txt

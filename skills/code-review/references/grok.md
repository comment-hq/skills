# Optional Grok review

Use only when explicitly selected for a second opinion or a host without native
subagents. Install Grok Build and jq; the model defaults to
`cliproxy-grok-4.6`, with `GROK_REVIEW_MODEL` selecting another configured ID.
Resolve `../scripts/grok-reviewer.sh` relative to this reference.

Pass `--cwd <repo> --brief <complete brief> --lens <lens>` and exactly one of:
`--base <sha> --head <sha>`, `--working-tree`, or `--artifact <file>`.
The runner supplies a static packet to a fresh, tool-disabled session. Include
necessary surrounding evidence in the brief; Grok cannot fetch it independently.
For architecture, use the ordinary findings lane with the relevant contract
clauses in the brief so the reviewer can explain its assessment.

Run as a managed process, inspect progress, and wait for completion, cancellation,
or provider failure. Failed or empty output is incomplete coverage, never CLEAN.
A human-selected Grok reviewer is not silently replaced by a native reviewer.

#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
usage: grok-reviewer.sh [--cwd DIR] --brief TEXT [--lens TEXT]
                        [--architecture-contract FILE]
                        (--working-tree | --base REF --head REF | --artifact FILE)
EOF
  exit 2
}

cwd=$PWD
brief=""
lens="general correctness, regressions, and missed acceptance"
base=""
head=""
artifact=""
architecture_contract=""
working_tree=false

while (($#)); do
  case "$1" in
    --cwd) cwd=${2:?missing value for --cwd}; shift 2 ;;
    --brief) brief=${2:?missing value for --brief}; shift 2 ;;
    --lens) lens=${2:?missing value for --lens}; shift 2 ;;
    --base) base=${2:?missing value for --base}; shift 2 ;;
    --head) head=${2:?missing value for --head}; shift 2 ;;
    --artifact) artifact=${2:?missing value for --artifact}; shift 2 ;;
    --architecture-contract) architecture_contract=${2:?missing value for --architecture-contract}; shift 2 ;;
    --working-tree) working_tree=true; shift ;;
    -h|--help) usage ;;
    *) printf 'grok-reviewer: unknown argument: %s\n' "$1" >&2; usage ;;
  esac
done

[[ -n "$brief" ]] || usage
[[ -d "$cwd" ]] || { printf 'grok-reviewer: cwd is not a directory: %s\n' "$cwd" >&2; exit 2; }

mode_count=0
[[ "$working_tree" == true ]] && mode_count=$((mode_count + 1))
[[ -n "$artifact" ]] && mode_count=$((mode_count + 1))
if [[ -n "$base" || -n "$head" ]]; then
  [[ -n "$base" && -n "$head" ]] || usage
  mode_count=$((mode_count + 1))
fi
[[ "$mode_count" -eq 1 ]] || usage

repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || {
  printf 'grok-reviewer: cwd is not inside a Git repository: %s\n' "$cwd" >&2
  exit 2
}
repo_root=$(CDPATH='' cd -P -- "$repo_root" && pwd)

architecture_contract_path=""
if [[ -n "$architecture_contract" ]]; then
  case "$architecture_contract" in
    /*) architecture_contract_path=$architecture_contract ;;
    *) architecture_contract_path=$cwd/$architecture_contract ;;
  esac
  [[ -f "$architecture_contract_path" && -r "$architecture_contract_path" ]] || {
    printf 'grok-reviewer: architecture contract is not a readable file: %s\n' "$architecture_contract" >&2
    exit 2
  }
fi

grok_bin=$(command -v grok || true)
[[ -n "$grok_bin" ]] || {
  printf 'grok-reviewer: Grok Build is required but grok is not on PATH\n' >&2
  exit 69
}
command -v jq >/dev/null || {
  printf 'grok-reviewer: jq is required but is not on PATH\n' >&2
  exit 69
}

model=${GROK_REVIEW_MODEL:-cliproxy-grok-4.6}
umask 077
review_workspace=$(mktemp -d "${TMPDIR:-/tmp}/grok-review-workspace.XXXXXX")
prompt_file=$review_workspace/prompt.md
result_file=$review_workspace/result.json
trap 'rm -rf "$review_workspace"' EXIT

{
  printf '# Independent review brief\n\n'
  printf 'Repository: %s\n' "$repo_root"
  printf 'Lens: %s\n\n' "$lens"
  printf '%s\n\n' "$brief"
  if [[ -n "$architecture_contract_path" ]]; then
    cat <<'EOF'
Return exactly one result with no quotes or Markdown formatting: conforming,
intended architecture change, or unclear.
Compare the supplied target with the canonical architecture contract. Use `conforming` only
when the target follows the contract, including an explicitly authorized temporary migration
edge. Use `intended architecture change` when the target diverges from the contract, and
`unclear` when the evidence is insufficient. Do not edit code, Git state, Beads, or public
review threads.

# Review target

EOF
  else
    cat <<'EOF'
Return candidate findings only. Each finding must name a concrete current failure scenario,
reachability, impact, code evidence with file:line, and the smallest reasonable fix. Stay within
the supplied target; use surrounding code only to assess impact. Return exactly `CLEAN` when no
actionable candidate exists. Do not edit code, Git state, Beads, or public review threads.

# Review target

EOF
  fi

  if [[ "$working_tree" == true ]]; then
    printf 'Mode: working tree against HEAD\n\n'
    printf '## Status\n\n```text\n'
    git -C "$repo_root" status --short
    printf '```\n\n## Unstaged diff\n\n```diff\n'
    git -C "$repo_root" diff --no-ext-diff --no-textconv --find-renames -- .
    printf '```\n\n## Staged diff\n\n```diff\n'
    git -C "$repo_root" diff --cached --no-ext-diff --no-textconv --find-renames -- .
    printf '```\n\n## Untracked files\n\n'
    while IFS= read -r -d '' path; do
      full_path=$repo_root/$path
      if [[ -L "$full_path" ]]; then
        printf '%s\n' "--- UNTRACKED SYMLINK: $path -> $(readlink -- "$full_path")"
      elif [[ -f "$full_path" && -r "$full_path" ]]; then
        printf '%s\n' "--- BEGIN UNTRACKED FILE: $path ---"
        cat -- "$full_path"
        printf '\n%s\n' "--- END UNTRACKED FILE: $path ---"
      else
        printf '%s\n' "--- UNREADABLE UNTRACKED PATH: $path ---"
      fi
    done < <(git -C "$repo_root" ls-files --others --exclude-standard -z)
  elif [[ -n "$artifact" ]]; then
    case "$artifact" in
      /*) artifact_path=$artifact ;;
      *) artifact_path=$cwd/$artifact ;;
    esac
    [[ -f "$artifact_path" && -r "$artifact_path" ]] || {
      printf 'grok-reviewer: artifact is not a readable file: %s\n' "$artifact" >&2
      exit 2
    }
    printf 'Mode: artifact\nArtifact: %s\n\n```text\n' "$artifact_path"
    cat -- "$artifact_path"
    printf '\n```\n'
  else
    base_sha=$(git -C "$repo_root" rev-parse --verify "${base}^{commit}") || {
      printf 'grok-reviewer: invalid base ref: %s\n' "$base" >&2
      exit 2
    }
    head_sha=$(git -C "$repo_root" rev-parse --verify "${head}^{commit}") || {
      printf 'grok-reviewer: invalid head ref: %s\n' "$head" >&2
      exit 2
    }
    printf 'Mode: exact Git delta\nBase: %s\nHead: %s\n\n' "$base_sha" "$head_sha"
    printf '## Commits\n\n```text\n'
    git -C "$repo_root" log --oneline --decorate "${base_sha}..${head_sha}"
    printf '```\n\n## Diff stat\n\n```text\n'
    git -C "$repo_root" diff --no-ext-diff --no-textconv --find-renames --stat "$base_sha" "$head_sha" -- .
    printf '```\n\n## Diff\n\n```diff\n'
    git -C "$repo_root" diff --no-ext-diff --no-textconv --find-renames "$base_sha" "$head_sha" -- .
    printf '```\n'
  fi

  if [[ -n "$architecture_contract_path" ]]; then
    printf '\n# Canonical architecture contract\n\nContract: %s\n\n--- BEGIN CANONICAL ARCHITECTURE CONTRACT ---\n' "$architecture_contract_path"
    cat -- "$architecture_contract_path"
    printf '\n--- END CANONICAL ARCHITECTURE CONTRACT ---\n'
  fi
} >"$prompt_file"

if [[ -n "$architecture_contract_path" ]]; then
  rules='You are an independent architecture-conformance reviewer. The prompt contains the complete target and canonical contract. Do not invoke skills or tools. Return exactly one result: conforming, intended architecture change, or unclear. You cannot modify files, Git state, task state, or external systems.'
else
  rules='You are an independent code reviewer. The prompt contains the complete review packet. Do not invoke skills or tools. Return only evidence-backed candidate findings or CLEAN. You cannot modify files, Git state, task state, or external systems.'
fi

if ! "$grok_bin" \
  --cwd "$review_workspace" \
  --model "$model" \
  --reasoning-effort high \
  --permission-mode dontAsk \
  --no-subagents \
  --disable-web-search \
  --max-turns 3 \
  --tools '' \
  --deny Edit \
  --deny Write \
  --deny Bash \
  --deny WebFetch \
  --deny MCPTool \
  --rules "$rules" \
  --verbatim \
  --output-format json \
  --prompt-file "$prompt_file" >"$result_file"; then
  printf 'grok-reviewer: Grok Build failed; reviewer coverage is incomplete\n' >&2
  exit 70
fi

if ! review_text=$(jq -er '.text | select(type == "string" and length > 0)' "$result_file"); then
  printf 'grok-reviewer: Grok Build returned no review text; reviewer coverage is incomplete\n' >&2
  exit 70
fi

if [[ -n "$architecture_contract_path" ]]; then
  case "$review_text" in
    conforming|'intended architecture change'|unclear) ;;
    *)
      printf 'grok-reviewer: Grok Build returned an invalid architecture result; reviewer coverage is incomplete\n' >&2
      exit 70
      ;;
  esac
fi

printf '%s\n' "$review_text"

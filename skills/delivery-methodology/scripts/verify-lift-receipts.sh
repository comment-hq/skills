#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 <lift-base-sha> <frozen-head-sha> <receipts.tsv>" >&2
  exit 2
}

[[ $# -eq 3 ]] || usage
base="$1"
frozen="$2"
ledger="$3"

git rev-parse --verify "${base}^{commit}" >/dev/null
git rev-parse --verify "${frozen}^{commit}" >/dev/null
git merge-base --is-ancestor "$base" "$frozen" || {
  echo "lift base is not an ancestor of frozen head" >&2
  exit 1
}
[[ -f "$ledger" ]] || { echo "receipt ledger not found: $ledger" >&2; exit 1; }

tmp="$(mktemp -d "${TMPDIR:-/tmp}/lift-receipts.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
git rev-list --first-parent --reverse "$base..$frozen" > "$tmp/expected"
: > "$tmp/actual"

previous="$base"
line_no=0
while IFS=$'\t' read -r kind receipt_base head merge source extra; do
  line_no=$((line_no + 1))
  [[ -z "${kind}${receipt_base}${head}${merge}${source}${extra}" ]] && continue
  [[ "$kind" == \#* ]] && continue
  [[ -z "${extra:-}" && -n "$kind" && -n "$receipt_base" && -n "$head" && -n "$merge" ]] || {
    echo "malformed receipt line $line_no" >&2
    exit 1
  }

  for sha in "$receipt_base" "$head" "$merge"; do
    git rev-parse --verify "${sha}^{commit}" >/dev/null || {
      echo "unknown commit on receipt line $line_no: $sha" >&2
      exit 1
    }
    git merge-base --is-ancestor "$sha" "$frozen" || {
      echo "receipt line $line_no is not covered by frozen head: $sha" >&2
      exit 1
    }
  done
  [[ "$receipt_base" == "$previous" ]] || {
    echo "receipt line $line_no breaks first-parent order: expected base $previous, got $receipt_base" >&2
    exit 1
  }

  case "$kind" in
    slice)
      parent1="$(git rev-parse "$merge^1")"
      parent2="$(git rev-parse "$merge^2")"
      [[ "$receipt_base" == "$parent1" && "$head" == "$parent2" ]] || {
        echo "slice receipt line $line_no does not bind merge parents" >&2
        exit 1
      }
      ;;
    main-sync)
      parent1="$(git rev-parse "$merge^1")"
      parent2="$(git rev-parse "$merge^2")"
      [[ "$receipt_base" == "$parent1" && "$head" == "$merge" && "${source:--}" == "$parent2" ]] || {
        echo "main-sync receipt line $line_no does not bind merge parents" >&2
        exit 1
      }
      ;;
    direct|promotion-fix)
      parent_count="$(git rev-list --parents -n 1 "$merge" | awk '{print NF - 1}')"
      [[ "$parent_count" -eq 1 ]] || {
        echo "$kind receipt line $line_no must bind a single-parent commit" >&2
        exit 1
      }
      parent="$(git rev-parse "$merge^1")"
      [[ "$receipt_base" == "$parent" ]] || {
        echo "$kind receipt line $line_no does not bind its parent" >&2
        exit 1
      }
      [[ "$head" == "$merge" ]] || {
        echo "$kind receipt line $line_no must use head_sha as merge_sha" >&2
        exit 1
      }
      ;;
    *)
      echo "unknown receipt kind on line $line_no: $kind" >&2
      exit 1
      ;;
  esac

  printf '%s\n' "$merge" >> "$tmp/actual"
  previous="$merge"
done < "$ledger"

[[ "$previous" == "$frozen" ]] || {
  echo "receipt chain ends at $previous, not frozen head $frozen" >&2
  exit 1
}

if ! diff -u "$tmp/expected" "$tmp/actual"; then
  echo "receipt merge_sha sequence does not cover the frozen first-parent chain" >&2
  exit 1
fi

count="$(wc -l < "$tmp/actual" | tr -d ' ')"
echo "verified $count ordered lift receipt(s) through $frozen"

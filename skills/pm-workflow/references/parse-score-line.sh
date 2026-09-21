#!/usr/bin/env bash
# Parses the review round score line (docs/review-cycle.md#score-line).
#
# Usage:
#   bash scripts/parse-score-line.sh "Round: 1 | Stage: code | Confirmed findings: 0 | Failed runs: 0 | Coverage: full"
#   echo "<line>" | bash scripts/parse-score-line.sh
#   bash scripts/parse-score-line.sh --self-test        # fixtures scripts/fixtures/score-line/*.txt
#
# Exit: 0 and JSON {"round":N,"stage":"…","confirmed":N,"failed":N,"coverage":"…"} on stdout,
# or 1 and the reason on stderr. All five fields are required in a fixed order;
# the only tolerance is spaces around "|" and ":"; the case of keys and values is exact.
set -euo pipefail

SCORE_RE='^Round:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Stage:[[:space:]]*(spec|arch|code)[[:space:]]*\|[[:space:]]*Confirmed findings:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Failed runs:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Coverage:[[:space:]]*(full|partial|unknown)[[:space:]]*$'

parse_line() {
  local line="$1"
  if [[ "$line" =~ $SCORE_RE ]]; then
    printf '{"round":%s,"stage":"%s","confirmed":%s,"failed":%s,"coverage":"%s"}\n' \
      "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}" "${BASH_REMATCH[5]}"
    return 0
  fi
  printf 'score line does not match format: %s\n' "$line" >&2
  return 1
}

self_test() {
  local dir
  dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/fixtures/score-line"
  local total=0 passed=0 failed=0
  local f name expected actual line
  for f in "$dir"/*.txt; do
    [[ -e "$f" ]] || { echo "no fixtures in $dir" >&2; return 1; }
    name="$(basename "$f" .txt)"
    case "$name" in
      ok-*)   expected=0 ;;
      fail-*) expected=1 ;;
      *) echo "fixture name must start with ok- or fail-: $name" >&2; return 1 ;;
    esac
    line="$(head -n 1 "$f")"
    total=$((total + 1))
    if parse_line "$line" >/dev/null 2>&1; then actual=0; else actual=1; fi
    if [[ "$actual" == "$expected" ]]; then
      passed=$((passed + 1))
      echo "ok   $name (exit $actual)"
    else
      failed=$((failed + 1))
      echo "FAIL $name: expected exit $expected, got $actual — $line"
    fi
  done
  echo "score-line self-test: fixtures $total, passed $passed, failed $failed, skipped 0"
  if (( total < 7 )); then
    echo "FAIL: expected at least 7 fixtures, found $total" >&2
    return 1
  fi
  (( failed == 0 ))
}

if [[ "${1:-}" == "--self-test" ]]; then
  self_test
  exit $?
fi

if [[ $# -ge 1 ]]; then
  parse_line "$1"
else
  IFS= read -r input || true
  parse_line "${input:-}"
fi

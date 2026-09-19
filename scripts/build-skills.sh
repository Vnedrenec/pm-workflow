#!/usr/bin/env bash
# Собирает skills/pm-workflow/references/ из docs/, templates/ и scripts/ (постановка §6.6).
#
#   bash scripts/build-skills.sh            # копирует, перезаписывая references/
#   bash scripts/build-skills.sh --check    # только diff; код 1 при расхождении или лишнем файле
#
# references/ руками не править: канон — docs/ и templates/. Список пар фиксирован здесь.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/skills/pm-workflow/references"

# источник → имя в references/
PAIRS=(
  "docs/roles.md:roles.md"
  "docs/pipeline.md:pipeline.md"
  "docs/review-cycle.md:review-cycle.md"
  "docs/impact-class.md:impact-class.md"
  "docs/ownership.md:ownership.md"
  "docs/incidents.md:incidents.md"
  "templates/subtask.md:subtask.md"
  "templates/review-report.md:review-report.md"
  "templates/handoff-comment.md:handoff-comment.md"
  "scripts/parse-score-line.sh:parse-score-line.sh"
)

mode="${1:-build}"
rc=0

if [[ "$mode" == "--check" ]]; then
  for pair in "${PAIRS[@]}"; do
    src="$ROOT/${pair%%:*}"
    dst="$DEST/${pair##*:}"
    if [[ ! -f "$src" ]]; then echo "build-skills: source missing: ${pair%%:*}"; rc=1; continue; fi
    if [[ ! -f "$dst" ]]; then echo "build-skills: reference missing: skills/pm-workflow/references/${pair##*:}"; rc=1; continue; fi
    if ! diff -q "$src" "$dst" >/dev/null; then
      echo "build-skills: DIFFERS: ${pair%%:*} != skills/pm-workflow/references/${pair##*:}"
      diff "$src" "$dst" | head -n 10 || true
      rc=1
    fi
  done
  # лишние файлы в references/ — тоже расхождение
  for f in "$DEST"/*; do
    [[ -e "$f" ]] || continue
    base="$(basename "$f")"
    known=0
    for pair in "${PAIRS[@]}"; do [[ "${pair##*:}" == "$base" ]] && known=1; done
    if (( known == 0 )); then echo "build-skills: unexpected file in references/: $base"; rc=1; fi
  done
  if (( rc == 0 )); then echo "build-skills --check: ${#PAIRS[@]} files identical"; fi
  exit $rc
fi

mkdir -p "$DEST"
for pair in "${PAIRS[@]}"; do
  cp "$ROOT/${pair%%:*}" "$DEST/${pair##*:}"
done
echo "build-skills: ${#PAIRS[@]} files copied into skills/pm-workflow/references/"

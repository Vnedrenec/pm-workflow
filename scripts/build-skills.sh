#!/usr/bin/env bash
# Assembles skills/pm-workflow/references/ from docs/, templates/ and scripts/ (specification §6.6).
#
#   bash scripts/build-skills.sh            # copies, overwriting references/
#   bash scripts/build-skills.sh --check    # diff only; exit code 1 on a divergence or an extra file
#
# Never hand-edit references/: the canon is docs/ and templates/. The pair list is fixed here.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/skills/pm-workflow/references"

# source → name in references/
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
  # extra files in references/ are a divergence too
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

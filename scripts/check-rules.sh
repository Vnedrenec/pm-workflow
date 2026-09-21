#!/usr/bin/env bash
# Machine checks of the regulation — criteria 1–10 and 18–21 of the regulation-extraction
# specification (in the private archive) and the stop-word guard per the sanitization
# specification (docs/superpowers/plans/2026-09-18-sanitize-pm-workflow.md §6.5). Rule label: [CI: check].
#
#   bash scripts/check-rules.sh                    # all checks; exit code 1 on any error
#   bash scripts/check-rules.sh --list-no-incident # prints rules with the line "Incident: none"
#   bash scripts/check-rules.sh --show             # the guard prints matched fragments (local only)
#   bash scripts/check-rules.sh --history          # the guard only, over the whole git history (a separate CI step)
#
# Private part of the stop-word dictionary: the STOP_WORDS_PRIVATE variable (in CI — from the secret)
# or the STOP_WORDS_PRIVATE_FILE file. Without it at CI=true — FAIL, locally — WARN and a check by the public part only.
# The PR range (title, commit messages) is checked when PR_TITLE and PR_BASE_SHA are set.
#
# bash + grep/awk/sed only, no dependencies. Compatible with bash 3.2 (macOS) and BSD grep.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# a relative STOP_WORDS_PRIVATE_FILE is resolved from the call directory, not the repository root: resolve it before cd
if [[ -n "${STOP_WORDS_PRIVATE_FILE:-}" && "$STOP_WORDS_PRIVATE_FILE" != /* ]]; then
  STOP_WORDS_PRIVATE_FILE="$PWD/$STOP_WORDS_PRIVATE_FILE"
fi
cd "$ROOT"

RULE_FILES="docs/roles.md docs/pipeline.md docs/review-cycle.md docs/impact-class.md docs/ownership.md"
GOTCHAS="skills/agent-runtime-gotchas/SKILL.md"
INCIDENTS="docs/incidents.md"
REQUIRED_LINES="scripts/required-lines/subtask.txt"
REQUIRED_MIN=10

errors=0
fail() { echo "FAIL: $*"; errors=$((errors + 1)); }

MODE="${1:-}"

# ---------------------------------------------------------------- --list-no-incident
if [[ "$MODE" == "--list-no-incident" ]]; then
  for f in $RULE_FILES; do
    awk -v file="$f" '
      /^### / { title=$0; sub(/^### /, "", title); anchor="" }
      /<a id="/ { match($0, /id="[^"]+"/); anchor=substr($0, RSTART+4, RLENGTH-5) }
      /^Incident: none/ { printf "%s#%s · %s\n", file, anchor, title }
    ' "$f"
  done
  exit 0
fi

# ---------------------------------------------------------------- 4. stop words (the guard)
# Public structural patterns + a private literal list; any match is a FAIL with the coordinates
# and the pattern number, without the matched text (everyone can read the CI logs of a public repository).
# Step 0 — a filter: allowed tokens are cut out of the line before the patterns run (repeatedly, while the output changes).
if [[ -z "${LC_ALL:-}" ]]; then
  if locale -a 2>/dev/null | grep -qx 'C.UTF-8'; then export LC_ALL=C.UTF-8; else export LC_ALL=en_US.UTF-8; fi
fi

STOP_PUBLIC=scripts/stop-words.txt
STOP_ALLOW=scripts/stop-words-allow.txt
STOP_PRIVATE_MIN=20
STOP_SHOW=0; [[ "$MODE" == "--show" ]] && STOP_SHOW=1

stop_public=()
stop_private=()
allow_sed=""
stop_matches=0   # guard matches only; a configuration FAIL (no dictionary, a short dictionary) is not a match

read_patterns() { grep -v '^[[:space:]]*#' "$1" | grep -v '^[[:space:]]*$' || true; }

if [[ ! -f "$STOP_PUBLIC" ]]; then
  fail "$STOP_PUBLIC missing"
else
  while IFS= read -r pat; do stop_public+=("$pat"); done < <(read_patterns "$STOP_PUBLIC")
fi
private_src=""
if [[ -n "${STOP_WORDS_PRIVATE_FILE:-}" ]]; then
  if [[ -f "$STOP_WORDS_PRIVATE_FILE" ]]; then
    private_src="file"
    while IFS= read -r pat; do stop_private+=("$pat"); done < <(read_patterns "$STOP_WORDS_PRIVATE_FILE")
  else
    fail "STOP_WORDS_PRIVATE_FILE points to missing file"
  fi
elif [[ -n "${STOP_WORDS_PRIVATE:-}" ]]; then
  private_src="env"
  while IFS= read -r pat; do stop_private+=("$pat"); done < <(printf '%s\n' "$STOP_WORDS_PRIVATE" | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*$' || true)
fi
if [[ -z "$private_src" ]]; then
  if [[ "${CI:-}" == "true" ]]; then
    fail "private stop-word list missing (secret STOP_WORDS_PRIVATE or STOP_WORDS_PRIVATE_FILE)"
  else
    echo "WARN: private stop-word list missing — checking public patterns only"
  fi
elif (( ${#stop_private[@]} < STOP_PRIVATE_MIN )); then
  fail "private stop-word list shorter than $STOP_PRIVATE_MIN lines (${#stop_private[@]})"
fi
if [[ -f "$STOP_ALLOW" ]]; then
  allow_alt=$(read_patterns "$STOP_ALLOW" | sed -E 's/[][\.*^$/&|(){}+?]/\\&/g' | paste -sd '|' - || true)
  [[ -n "$allow_alt" ]] && allow_sed="s/(^|[^A-Za-z0-9_])($allow_alt)([^A-Za-z0-9_]|$)/\1\3/g"
fi

STOP_TMP=$(mktemp -d "${TMPDIR:-/tmp}/check-rules.XXXXXX")
trap 'rm -rf "$STOP_TMP"' EXIT

# step 0: stdin → stdout without the allowed tokens; line by line, line numbering does not change
stop_filter() {
  if [[ -z "$allow_sed" ]]; then cat; return; fi
  local a="$STOP_TMP/f.a" b="$STOP_TMP/f.b"
  cat > "$a"
  while :; do
    sed -E "$allow_sed" "$a" > "$b"
    if cmp -s "$a" "$b"; then break; fi
    mv "$b" "$a"
  done
  cat "$a"
}

# input: lines of the form "<coordinate><TAB><text>"; the patterns run over the text only, the coordinate goes into the FAIL.
# $1 — how to name the coordinate. Prints a FAIL per match: the coordinate and the pattern number only.
stop_scan() {
  local what="$1" i pat kind
  local coords="$STOP_TMP/coords" text="$STOP_TMP/text" nums="$STOP_TMP/nums"
  cat > "$STOP_TMP/in"
  [[ -s "$STOP_TMP/in" ]] || return 0
  cut -f1 "$STOP_TMP/in" > "$coords"
  cut -f2- "$STOP_TMP/in" | stop_filter > "$text"
  # not grep -q: with pipefail an early grep exit gives the writer a SIGPIPE and a false "no matches"
  local all="$STOP_TMP/all"; : > "$all"
  for pat in ${stop_public[@]+"${stop_public[@]}"} ${stop_private[@]+"${stop_private[@]}"}; do printf '%s\n' "$pat" >> "$all"; done
  [[ "$(grep -cE -f "$all" "$text" || true)" == "0" ]] && return 0
  for kind in public private; do
    i=0
    if [[ "$kind" == public ]]; then set -- ${stop_public[@]+"${stop_public[@]}"}; else set -- ${stop_private[@]+"${stop_private[@]}"}; fi
    for pat in "$@"; do
      i=$((i + 1))
      grep -nE -e "$pat" "$text" | cut -d: -f1 > "$nums" || true
      [[ -s "$nums" ]] || continue
      while IFS= read -r c; do fail "stop-word $kind#$i $what $c"; stop_matches=$((stop_matches + 1)); done < <(awk 'NR==FNR { want[$1]=1; next } (FNR in want)' "$nums" "$coords")
      (( STOP_SHOW )) && grep -oE -e "$pat" "$text" | sed 's/^/    show: /'
    done
  done
  return 0
}

if [[ "$MODE" == "--history" ]]; then
  # 5. the whole history: the patches of all commits (the coordinate is commit:patch-line) and the authors
  stop_scan "in history, commit" < <(git log --all -p --format='commit %H' \
    | awk 'BEGIN{OFS="\t"} /^commit [0-9a-f]+$/ && length($2)==40 {c=$2; n=0} {n++; print c ":" n, $0}')
  # author e-mails and names; a GitHub noreply address of the form <id>+<login>@users.noreply.github.com and an author
  # name matching its login do not count (the login is visible anyway as the repository owner — specification §12, V3).
  # A commit created by GitHub itself (committer GitHub + its plain no-reply address, e.g. the test merge
  # refs/pull/N/merge) does not count either: the author fields (the PR creator's profile e-mail) are chosen by GitHub,
  # not by the committer — a false positive on every PR (an extension of the same V3 exception;
  # the address literal is assembled by concatenation so the file does not catch itself in the tree)
  stop_scan "in history, author of commit" < <(git log --all --format='%H%x09%an%x09%ae%x09%cn%x09%ce' \
    | awk -F'\t' 'BEGIN{OFS="\t"} {
        gh_nr = ("noreply" "@" "github" "." "com")
        login = ""
        for (i = 3; i <= 5; i += 2) if ($i ~ /^[0-9]+\+[A-Za-z0-9-]+@users\.noreply\.github\.com$/) { login = $i; sub(/^[0-9]+\+/, "", login); sub(/@.*$/, "", login); $i = "" }
        if (login != "") for (i = 2; i <= 4; i += 2) if ($i == login) $i = ""
        if ($4 == "GitHub" && $5 == gh_nr) { $2 = ""; $3 = ""; $5 = "" }
        print $1, $2 " " $3 " " $4 " " $5 }')
  n=$stop_matches
  if (( n > 0 )); then echo "stop-words in history: $n match(es); run locally: bash scripts/check-rules.sh --show"; else echo "stop-words in history: 0 matches"; fi
  if (( errors > 0 )); then echo "check-rules --history: $errors error(s)"; exit 1; fi
  echo "check-rules --history: 0 errors"; exit 0
fi

# 2. the tree: every file from git ls-files, except the dictionaries themselves
while IFS= read -r f; do
  [[ "$f" == "$STOP_PUBLIC" || "$f" == "$STOP_ALLOW" ]] && continue
  [[ -f "$f" ]] || continue
  stop_scan "at" < <(awk -v f="$f" 'BEGIN{OFS="\t"} {print f ":" NR, $0}' "$f")
done < <(git ls-files)
# 3. file names
stop_scan "in path, git ls-files line" < <(git ls-files | awk 'BEGIN{OFS="\t"} {print NR, $0}')
# 4. the PR range: the title and the commit messages
if [[ -n "${PR_TITLE:-}" && -n "${PR_BASE_SHA:-}" ]]; then
  stop_scan "in PR" < <(printf 'title\t%s\n' "$PR_TITLE")
  stop_scan "in commit message" < <(git log --format='%H%x09%B' "$PR_BASE_SHA"..HEAD \
    | awk -F'\t' 'BEGIN{OFS="\t"} NF>=2 && length($1)==40 && $1 ~ /^[0-9a-f]+$/ {c=$1; sub(/^[0-9a-f]+\t/, "")} {print c, $0}')
fi
n=$stop_matches
if (( n > 0 )); then echo "stop-words: $n match(es); run locally: bash scripts/check-rules.sh --show"; else echo "stop-words: 0 matches"; fi

# ---------------------------------------------------------------- 1. every rule — one home
if [[ ! -f docs/rule-index.tsv ]]; then
  fail "docs/rule-index.tsv missing"
else
  rules=0
  while IFS=$'\t' read -r key target; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    rules=$((rules + 1))
    file="${target%%#*}"; anchor="${target##*#}"
    if [[ -z "$anchor" || "$file" == "$target" ]]; then fail "rule-index: '$key' target has no anchor: $target"; continue; fi
    n=$(grep -rl --include='*.md' --exclude-dir=superpowers --exclude-dir=archive --exclude-dir=references "id=\"$anchor\"" docs skills 2>/dev/null | wc -l | tr -d ' ' || true)
    if [[ "$n" != "1" ]]; then fail "rule-index: anchor '$anchor' ($key) found in $n files, expected 1"; fi
    if [[ ! -f "$file" ]]; then fail "rule-index: file '$file' ($key) missing"; continue; fi
    if ! grep -q "id=\"$anchor\"" "$file"; then fail "rule-index: anchor '$anchor' ($key) not in $file"; fi
  done < docs/rule-index.tsv
  # the reverse side: every anchor in the rule files is in the index
  for f in $RULE_FILES; do
    [[ -f "$f" ]] || continue
    for a in $(grep -o 'id="[^"]*"' "$f" | sed 's/id="//; s/"//'); do
      grep -q "	$f#$a\$" docs/rule-index.tsv || fail "rule-index: anchor '$f#$a' has no row in docs/rule-index.tsv"
    done
  done
  echo "rules in index: $rules"
fi

# ---------------------------------------------------------------- 2. a label on every rule
for f in $RULE_FILES; do
  [[ -f "$f" ]] || { fail "missing rule file $f"; continue; }
  bad=$(grep -nE '^### ' "$f" | grep -vE '`\[(CI: check|review: [^]]+ @ [^]]+)\]`$' || true)
  if [[ -n "$bad" ]]; then fail "label missing on rule heading in $f:"$'\n'"$bad"; fi
done

# ---------------------------------------------------------------- 3. an "Incident:" line on every rule
for f in $RULE_FILES; do
  [[ -f "$f" ]] || continue
  out=$(awk -v file="$f" '
    function flush() {
      if (title != "") {
        if (cnt != 1) printf "%s: rule \"%s\" has %d lines \"Incident:\", expected 1\n", file, title, cnt
        if (anchors != 1) printf "%s: rule \"%s\" has %d anchors <a id>, expected 1\n", file, title, anchors
      }
    }
    /^### / { flush(); title=$0; sub(/^### /, "", title); cnt=0; anchors=0; next }
    /<a id="/ { anchors++ }
    /^Incident: / {
      cnt++
      if ($0 !~ /^Incident: none$/ && $0 !~ /incidents\.md#[a-z0-9-]+/) printf "%s: rule \"%s\" incident line malformed: %s\n", file, title, $0
    }
    END { flush() }
  ' "$f")
  [[ -n "$out" ]] && fail "$out"
done

# ---------------------------------------------------------------- 5. every incidents.md#anchor link leads to an anchor
refs=$(grep -rhoE 'incidents\.md#[a-z0-9-]+' docs templates skills CHANGELOG.md README.md \
        --exclude-dir=superpowers --exclude-dir=archive --exclude-dir=references 2>/dev/null | sed 's/.*#//' | sort -u || true)
for a in $refs; do
  grep -q "<a id=\"$a\"></a>" "$INCIDENTS" || fail "link incidents.md#$a points to missing anchor"
done
nrows=$(grep -c '^| <a id="' "$INCIDENTS" || true)
# every resolver row has non-empty "Id", "Symptom", "Consequence", "Rules" (columns 3–6 by the | separator)
out=$(awk -F'|' '/^\| <a id="/ { for (c = 3; c <= 6; c++) { v = $c; gsub(/^[ \t]+|[ \t]+$/, "", v); if (v == "") printf "%s:%d: empty column %d\n", FILENAME, NR, c - 1 } }' "$INCIDENTS")
[[ -n "$out" ]] && fail "resolver rows with empty cells:"$'\n'"$out"
echo "incident rows in resolver: $nrows"

# ---------------------------------------------------------------- 6. five lines on the section A items of the skill; a removal date in B
if [[ ! -f "$GOTCHAS" ]]; then
  fail "$GOTCHAS missing"
else
  out=$(awk '
    function flush() {
      if (section == "A" && title != "") {
        if (s != 1) printf "A/%s: \"- Symptom:\" lines = %d\n", title, s
        if (c != 1) printf "A/%s: \"- Cause:\" lines = %d\n", title, c
        if (o != 1) printf "A/%s: \"- Workaround:\" lines = %d\n", title, o
        if (i != 1) printf "A/%s: \"- Incident:\" lines = %d\n", title, i
        if (u != 1) printf "A/%s: \"- Removal condition:\" lines = %d\n", title, u
        if (an != 1) printf "A/%s: anchors = %d\n", title, an
      }
      if (section == "B" && title != "") {
        if (u < 1) printf "B/%s: no \"- Removal condition:\" line\n", title
        else if (!udate) printf "B/%s: \"- Removal condition:\" without YYYY-MM-DD date\n", title
      }
    }
    /^## A\./ { flush(); section="A"; title=""; next }
    /^## B\./ { flush(); section="B"; title=""; next }
    /^## /    { flush(); section="other"; title=""; next }
    /^### /   { flush(); title=$0; sub(/^### /, "", title); s=c=o=i=u=an=udate=0; next }
    /<a id="/ { an++ }
    /^- Symptom:/ { s++ }
    /^- Cause:/ { c++ }
    /^- Workaround:/ { o++ }
    /^- Incident:/ { i++ }
    /^- Removal condition:/ { u++; if ($0 ~ /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) udate=1 }
    END { flush() }
  ' "$GOTCHAS")
  [[ -n "$out" ]] && fail "skill agent-runtime-gotchas structure:"$'\n'"$out"
  na=$(awk '/^## A\./{a=1;next} /^## /{a=0} a && /^### /{n++} END{print n+0}' "$GOTCHAS")
  nb=$(awk '/^## B\./{b=1;next} /^## /{b=0} b && /^### /{n++} END{print n+0}' "$GOTCHAS")
  echo "gotchas: section A $na items, section B $nb items"
fi

# ---------------------------------------------------------------- 7. the score line from the template + the fixtures
if [[ ! -f templates/review-report.md ]]; then
  fail "templates/review-report.md missing"
else
  example=$(grep -oE 'Round: [0-9]+ \| Stage: [a-z]+ \| Confirmed findings: [0-9]+ \| Failed runs: [0-9]+ \| Coverage: [a-z]+' templates/review-report.md | head -n 1 || true)
  if [[ -z "$example" ]]; then
    fail "templates/review-report.md has no example score line with numbers"
  elif ! bash scripts/parse-score-line.sh "$example" >/dev/null 2>&1; then
    fail "example score line in templates/review-report.md does not parse: $example"
  fi
fi
if ! bash scripts/parse-score-line.sh --self-test >/dev/null 2>&1; then
  fail "scripts/parse-score-line.sh --self-test failed"
fi

# ---------------------------------------------------------------- 8. the completion line in the subtask template
if [[ -f templates/subtask.md ]]; then
  n=$(grep -c 'multica issue status <id> done' templates/subtask.md || true)
  [[ "$n" == "1" ]] || fail "templates/subtask.md: 'multica issue status <id> done' occurs $n times, expected 1"
else
  fail "templates/subtask.md missing"
fi

# ---------------------------------------------------------------- 9. CHANGELOG — four lines per entry (bilingual: RU or EN, exactly one of the two)
if [[ -f CHANGELOG.md ]]; then
  # The Russian field names are assembled from byte escapes so that this file itself stays
  # Cyrillic-free (acceptance criterion A1); each check is equivalent to the anchored regex
  # "line starts with the Russian field name OR starts with the English one", one count per entry.
  RU_DEC=$'- \320\240\320\265\321\210\320\265\320\275\320\270\320\265:'
  RU_WHAT=$'- \320\247\321\202\320\276 \320\270\320\267\320\274\320\265\320\275\320\270\320\273\320\276\321\201\321\214:'
  RU_INC=$'- \320\230\320\275\321\206\320\270\320\264\320\265\320\275\321\202:'
  RU_AFF=$'- \320\227\320\260\321\202\321\200\320\276\320\275\321\203\321\202\320\276:'
  out=$(awk -v ru_dec="$RU_DEC" -v ru_what="$RU_WHAT" -v ru_inc="$RU_INC" -v ru_aff="$RU_AFF" '
    function flush() {
      if (entry != "") {
        if (r != 1) printf "%s: \"- Decision:\" = %d\n", entry, r
        if (w != 1) printf "%s: \"- What changed:\" = %d\n", entry, w
        if (i != 1) printf "%s: \"- Incident:\" = %d\n", entry, i
        if (t != 1) printf "%s: \"- Affected:\" = %d\n", entry, t
      }
    }
    /^## [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] — / { flush(); entry=$0; r=w=i=t=0; n++; next }
    /^## / { flush(); entry="" ; if ($0 !~ /^## [0-9]/) printf "malformed entry heading: %s\n", $0; next }
    index($0, ru_dec) == 1 || /^- Decision:/ { r++ }
    index($0, ru_what) == 1 || /^- What changed:/ { w++ }
    index($0, ru_inc) == 1 || /^- Incident:/ { i++ }
    index($0, ru_aff) == 1 || /^- Affected:/ { t++ }
    END { flush(); printf "COUNT %d\n", n+0 }
  ' CHANGELOG.md)
  cl_n=$(echo "$out" | sed -n 's/^COUNT //p')
  out=$(echo "$out" | grep -v '^COUNT ' || true)
  [[ -n "$out" ]] && fail "CHANGELOG.md:"$'\n'"$out"
  echo "changelog entries: $cl_n"
else
  fail "CHANGELOG.md missing"
fi

# ---------------------------------------------------------------- 10. the layer 1 skill contains no regulation
if [[ -f "$GOTCHAS" ]]; then
  bad=$(awk '/^## C\./{c=1} /^## [AB]\./{c=0} !c' "$GOTCHAS" | grep -niE 'owner decision' || true)
  [[ -n "$bad" ]] && fail "$GOTCHAS: 'owner decision' outside section C:"$'\n'"$bad"
  bad=$(grep -niE 'circuit breaker|three consecutive rounds' "$GOTCHAS" || true)
  [[ -n "$bad" ]] && fail "$GOTCHAS: layer 2 words (circuit breaker / three consecutive rounds):"$'\n'"$bad"
fi

# ---------------------------------------------------------------- 18. the required lines of the code-stage template block
if [[ ! -f "$REQUIRED_LINES" ]]; then
  fail "$REQUIRED_LINES missing"
else
  nreq=$(grep -c . "$REQUIRED_LINES" || true)
  if (( nreq < REQUIRED_MIN )); then fail "$REQUIRED_LINES has $nreq non-empty lines, threshold $REQUIRED_MIN"; fi
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    n=$(grep -cF -- "$line" templates/subtask.md || true)
    [[ "$n" == "1" ]] || fail "required line occurs $n times in templates/subtask.md (expected 1): $line"
  done < "$REQUIRED_LINES"
  echo "required lines checked: $nreq"
fi

# ---------------------------------------------------------------- 19. the copy in the skill is identical to the original
if ! out=$(bash scripts/build-skills.sh --check 2>&1); then
  fail "build-skills --check:"$'\n'"$out"
fi

# ---------------------------------------------------------------- 20. the router is complete
ROUTER=skills/pm-workflow/SKILL.md
if [[ ! -f "$ROUTER" ]]; then
  fail "$ROUTER missing"
else
  for f in skills/pm-workflow/references/*; do
    [[ -e "$f" ]] || continue
    b=$(basename "$f")
    grep -qF -- "$b" "$ROUTER" || fail "$ROUTER does not mention references/$b"
  done
  for m in $(grep -oE 'references/[A-Za-z0-9._-]+' "$ROUTER" | sort -u); do
    [[ -f "skills/pm-workflow/$m" ]] || fail "$ROUTER mentions missing file $m"
  done
fi

# ---------------------------------------------------------------- 21. no ../ links in docs/*.md
bad=$(grep -n '\.\./' docs/roles.md docs/pipeline.md docs/review-cycle.md docs/impact-class.md docs/ownership.md docs/incidents.md 2>/dev/null || true)
[[ -n "$bad" ]] && fail "'../' links in docs (break in references/):"$'\n'"$bad"

# ---------------------------------------------------------------- total
if (( errors > 0 )); then
  echo "check-rules: $errors error(s)"
  exit 1
fi
echo "check-rules: 0 errors"

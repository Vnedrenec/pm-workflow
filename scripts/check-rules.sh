#!/usr/bin/env bash
# Машинные проверки регламента — критерии 1–10 и 18–21 постановки о выносе регламента
# (в приватном архиве) и сторож стоп-слов по постановке об обезличивании
# (docs/superpowers/plans/2026-09-18-sanitize-pm-workflow.md §6.5). Метка правил: [CI: check].
#
#   bash scripts/check-rules.sh                    # все проверки; код 1 при любой ошибке
#   bash scripts/check-rules.sh --list-no-incident # печатает правила со строкой «Инцидент: нет»
#   bash scripts/check-rules.sh --show             # сторож печатает совпавшие фрагменты (только локально)
#   bash scripts/check-rules.sh --history          # только сторож по всей истории git (отдельный шаг CI)
#
# Приватная часть словаря стоп-слов: переменная STOP_WORDS_PRIVATE (в CI — из секрета) либо файл
# STOP_WORDS_PRIVATE_FILE. Без неё при CI=true — FAIL, локально — WARN и проверка публичной частью.
# Диапазон PR (заголовок, сообщения коммитов) проверяется, когда заданы PR_TITLE и PR_BASE_SHA.
#
# Только bash + grep/awk/sed, без зависимостей. Совместимо с bash 3.2 (macOS) и BSD grep.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# относительный STOP_WORDS_PRIVATE_FILE считается от каталога вызова, а не от корня репозитория: резолвим до cd
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
      /^Инцидент: нет/ { printf "%s#%s · %s\n", file, anchor, title }
    ' "$f"
  done
  exit 0
fi

# ---------------------------------------------------------------- 4. стоп-слова (сторож)
# Публичные структурные шаблоны + приватный литеральный список; любое совпадение — FAIL с координатами
# и номером шаблона, без текста совпадения (логи CI публичного репозитория читают все).
# Шаг 0 — фильтр: разрешённые токены вырезаются из строки до прогона шаблонов (повторно, пока вывод меняется).
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
stop_matches=0   # только совпадения сторожа; FAIL конфигурации (нет словаря, словарь короткий) — не совпадения

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

# шаг 0: stdin → stdout без разрешённых токенов; построчно, нумерация строк не меняется
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

# вход: строки вида «<координата><TAB><текст>»; шаблоны гоняются только по тексту, координата — в FAIL.
# $1 — как назвать координату. Печатает FAIL на каждое совпадение: только координата и номер шаблона.
stop_scan() {
  local what="$1" i pat kind
  local coords="$STOP_TMP/coords" text="$STOP_TMP/text" nums="$STOP_TMP/nums"
  cat > "$STOP_TMP/in"
  [[ -s "$STOP_TMP/in" ]] || return 0
  cut -f1 "$STOP_TMP/in" > "$coords"
  cut -f2- "$STOP_TMP/in" | stop_filter > "$text"
  # не grep -q: при pipefail ранний выход grep даёт SIGPIPE записи и ложный «нет совпадений»
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
  # 5. вся история: патчи всех коммитов (координата — commit:строка патча) и авторы
  stop_scan "in history, commit" < <(git log --all -p --format='commit %H' \
    | awk 'BEGIN{OFS="\t"} /^commit [0-9a-f]+$/ && length($2)==40 {c=$2; n=0} {n++; print c ":" n, $0}')
  # e-mail и имена авторов; адрес GitHub noreply вида <id>+<login>@users.noreply.github.com и совпадающее
  # с его login имя автора не считаются (login виден в любом случае как владелец репозитория — постановка §12, В3).
  # Коммит, созданный самим GitHub (коммиттер GitHub + его безымянный no-reply адрес, напр. тест-мерж
  # refs/pull/N/merge), тоже не считается: поля автора (профильный e-mail создателя PR) выбирает GitHub,
  # а не коммитивший, — ложное срабатывание на каждом PR (расширение того же исключения В3;
  # литерал адреса собран конкатенацией, чтобы файл не ловил сам себя деревом)
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

# 2. дерево: каждый файл из git ls-files, кроме самих словарей
while IFS= read -r f; do
  [[ "$f" == "$STOP_PUBLIC" || "$f" == "$STOP_ALLOW" ]] && continue
  [[ -f "$f" ]] || continue
  stop_scan "at" < <(awk -v f="$f" 'BEGIN{OFS="\t"} {print f ":" NR, $0}' "$f")
done < <(git ls-files)
# 3. имена файлов
stop_scan "in path, git ls-files line" < <(git ls-files | awk 'BEGIN{OFS="\t"} {print NR, $0}')
# 4. диапазон PR: заголовок и сообщения коммитов
if [[ -n "${PR_TITLE:-}" && -n "${PR_BASE_SHA:-}" ]]; then
  stop_scan "in PR" < <(printf 'title\t%s\n' "$PR_TITLE")
  stop_scan "in commit message" < <(git log --format='%H%x09%B' "$PR_BASE_SHA"..HEAD \
    | awk -F'\t' 'BEGIN{OFS="\t"} NF>=2 && length($1)==40 && $1 ~ /^[0-9a-f]+$/ {c=$1; sub(/^[0-9a-f]+\t/, "")} {print c, $0}')
fi
n=$stop_matches
if (( n > 0 )); then echo "stop-words: $n match(es); run locally: bash scripts/check-rules.sh --show"; else echo "stop-words: 0 matches"; fi

# ---------------------------------------------------------------- 1. каждое правило — один дом
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
  # обратная сторона: каждый якорь в файлах правил есть в индексе
  for f in $RULE_FILES; do
    [[ -f "$f" ]] || continue
    for a in $(grep -o 'id="[^"]*"' "$f" | sed 's/id="//; s/"//'); do
      grep -q "	$f#$a\$" docs/rule-index.tsv || fail "rule-index: anchor '$f#$a' has no row in docs/rule-index.tsv"
    done
  done
  echo "rules in index: $rules"
fi

# ---------------------------------------------------------------- 2. метка у каждого правила
for f in $RULE_FILES; do
  [[ -f "$f" ]] || { fail "missing rule file $f"; continue; }
  bad=$(grep -nE '^### ' "$f" | grep -vE '`\[(CI: check|ревью: [^]]+ @ [^]]+)\]`$' || true)
  if [[ -n "$bad" ]]; then fail "label missing on rule heading in $f:"$'\n'"$bad"; fi
done

# ---------------------------------------------------------------- 3. строка «Инцидент:» у каждого правила
for f in $RULE_FILES; do
  [[ -f "$f" ]] || continue
  out=$(awk -v file="$f" '
    function flush() {
      if (title != "") {
        if (cnt != 1) printf "%s: rule \"%s\" has %d lines \"Инцидент:\", expected 1\n", file, title, cnt
        if (anchors != 1) printf "%s: rule \"%s\" has %d anchors <a id>, expected 1\n", file, title, anchors
      }
    }
    /^### / { flush(); title=$0; sub(/^### /, "", title); cnt=0; anchors=0; next }
    /<a id="/ { anchors++ }
    /^Инцидент: / {
      cnt++
      if ($0 !~ /^Инцидент: нет$/ && $0 !~ /incidents\.md#[a-z0-9-]+/) printf "%s: rule \"%s\" incident line malformed: %s\n", file, title, $0
    }
    END { flush() }
  ' "$f")
  [[ -n "$out" ]] && fail "$out"
done

# ---------------------------------------------------------------- 5. каждая ссылка incidents.md#якорь ведёт на якорь
refs=$(grep -rhoE 'incidents\.md#[a-z0-9-]+' docs templates skills CHANGELOG.md README.md \
        --exclude-dir=superpowers --exclude-dir=archive --exclude-dir=references 2>/dev/null | sed 's/.*#//' | sort -u || true)
for a in $refs; do
  grep -q "<a id=\"$a\"></a>" "$INCIDENTS" || fail "link incidents.md#$a points to missing anchor"
done
nrows=$(grep -c '^| <a id="' "$INCIDENTS" || true)
# у каждой строки резолвера непустые «Id», «Симптом», «Следствие», «Правила» (столбцы 3–6 по разделителю |)
out=$(awk -F'|' '/^\| <a id="/ { for (c = 3; c <= 6; c++) { v = $c; gsub(/^[ \t]+|[ \t]+$/, "", v); if (v == "") printf "%s:%d: empty column %d\n", FILENAME, NR, c - 1 } }' "$INCIDENTS")
[[ -n "$out" ]] && fail "resolver rows with empty cells:"$'\n'"$out"
echo "incident rows in resolver: $nrows"

# ---------------------------------------------------------------- 6. пять строк у пунктов раздела A скилла; дата снятия в B
if [[ ! -f "$GOTCHAS" ]]; then
  fail "$GOTCHAS missing"
else
  out=$(awk '
    function flush() {
      if (section == "A" && title != "") {
        if (s != 1) printf "A/%s: \"- Симптом:\" lines = %d\n", title, s
        if (c != 1) printf "A/%s: \"- Причина:\" lines = %d\n", title, c
        if (o != 1) printf "A/%s: \"- Обход:\" lines = %d\n", title, o
        if (i != 1) printf "A/%s: \"- Инцидент:\" lines = %d\n", title, i
        if (u != 1) printf "A/%s: \"- Условие снятия:\" lines = %d\n", title, u
        if (an != 1) printf "A/%s: anchors = %d\n", title, an
      }
      if (section == "B" && title != "") {
        if (u < 1) printf "B/%s: no \"- Условие снятия:\" line\n", title
        else if (!udate) printf "B/%s: \"- Условие снятия:\" without YYYY-MM-DD date\n", title
      }
    }
    /^## A\./ { flush(); section="A"; title=""; next }
    /^## B\./ { flush(); section="B"; title=""; next }
    /^## /    { flush(); section="other"; title=""; next }
    /^### /   { flush(); title=$0; sub(/^### /, "", title); s=c=o=i=u=an=udate=0; next }
    /<a id="/ { an++ }
    /^- Симптом:/ { s++ }
    /^- Причина:/ { c++ }
    /^- Обход:/ { o++ }
    /^- Инцидент:/ { i++ }
    /^- Условие снятия:/ { u++; if ($0 ~ /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) udate=1 }
    END { flush() }
  ' "$GOTCHAS")
  [[ -n "$out" ]] && fail "skill agent-runtime-gotchas structure:"$'\n'"$out"
  na=$(awk '/^## A\./{a=1;next} /^## /{a=0} a && /^### /{n++} END{print n+0}' "$GOTCHAS")
  nb=$(awk '/^## B\./{b=1;next} /^## /{b=0} b && /^### /{n++} END{print n+0}' "$GOTCHAS")
  echo "gotchas: section A $na items, section B $nb items"
fi

# ---------------------------------------------------------------- 7. строка счёта из шаблона + фикстуры
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

# ---------------------------------------------------------------- 8. строка завершения в шаблоне подзадачи
if [[ -f templates/subtask.md ]]; then
  n=$(grep -c 'multica issue status <id> done' templates/subtask.md || true)
  [[ "$n" == "1" ]] || fail "templates/subtask.md: 'multica issue status <id> done' occurs $n times, expected 1"
else
  fail "templates/subtask.md missing"
fi

# ---------------------------------------------------------------- 9. CHANGELOG — четыре строки у каждой записи
if [[ -f CHANGELOG.md ]]; then
  out=$(awk '
    function flush() {
      if (entry != "") {
        if (r != 1) printf "%s: \"- Решение:\" = %d\n", entry, r
        if (w != 1) printf "%s: \"- Что изменилось:\" = %d\n", entry, w
        if (i != 1) printf "%s: \"- Инцидент:\" = %d\n", entry, i
        if (t != 1) printf "%s: \"- Затронуто:\" = %d\n", entry, t
      }
    }
    /^## [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] — / { flush(); entry=$0; r=w=i=t=0; n++; next }
    /^## / { flush(); entry="" ; if ($0 !~ /^## [0-9]/) printf "malformed entry heading: %s\n", $0; next }
    /^- Решение:/ { r++ }
    /^- Что изменилось:/ { w++ }
    /^- Инцидент:/ { i++ }
    /^- Затронуто:/ { t++ }
    END { flush(); printf "COUNT %d\n", n+0 }
  ' CHANGELOG.md)
  cl_n=$(echo "$out" | sed -n 's/^COUNT //p')
  out=$(echo "$out" | grep -v '^COUNT ' || true)
  [[ -n "$out" ]] && fail "CHANGELOG.md:"$'\n'"$out"
  echo "changelog entries: $cl_n"
else
  fail "CHANGELOG.md missing"
fi

# ---------------------------------------------------------------- 10. скилл слоя 1 не содержит регламента
if [[ -f "$GOTCHAS" ]]; then
  bad=$(awk '/^## C\./{c=1} /^## [AB]\./{c=0} !c' "$GOTCHAS" | grep -niE 'решение владельца' || true)
  [[ -n "$bad" ]] && fail "$GOTCHAS: 'Решение владельца' outside section C:"$'\n'"$bad"
  bad=$(grep -niE 'предохранител|три кода' "$GOTCHAS" || true)
  [[ -n "$bad" ]] && fail "$GOTCHAS: layer 2 words (предохранитель / три кода):"$'\n'"$bad"
fi

# ---------------------------------------------------------------- 18. обязательные строки блока code-stage шаблона
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

# ---------------------------------------------------------------- 19. копия в скилле тождественна оригиналу
if ! out=$(bash scripts/build-skills.sh --check 2>&1); then
  fail "build-skills --check:"$'\n'"$out"
fi

# ---------------------------------------------------------------- 20. маршрутизатор полон
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

# ---------------------------------------------------------------- 21. в docs/*.md нет ссылок ../
bad=$(grep -n '\.\./' docs/roles.md docs/pipeline.md docs/review-cycle.md docs/impact-class.md docs/ownership.md docs/incidents.md 2>/dev/null || true)
[[ -n "$bad" ]] && fail "'../' links in docs (break in references/):"$'\n'"$bad"

# ---------------------------------------------------------------- итог
if (( errors > 0 )); then
  echo "check-rules: $errors error(s)"
  exit 1
fi
echo "check-rules: 0 errors"

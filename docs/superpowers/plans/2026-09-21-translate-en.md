# Specification: translate pm-workflow content to English

> Plan stage of card 573, impact class `hygiene`. Author: Architect (substituted executor), 2026-09-21.
> Spec audit: one round (Reviewer), rework as one stage, then the code stage (Builder) with one
> code-audit round; merge, `multica skill refresh`, and the token measurement are the ops stage (PM).
> Owner decision: 2026-09-21, on card 448 — "our skills are in Russian and this consumes twice the
> tokens of English; start the translation to English" (comment mapping in the private registry;
> requisition D-10, §8).
>
> Written for an executor who sees neither the chat nor the tracker: everything needed is in this
> file, in the repository files by path, and in the executor's sub-issue body. This file itself is
> written in English from the start — it lands in the tree already in its final language and is not
> a translation target.

## 0. Why — with proof

The regulation is read by agents at every pipeline round: the PM skill reads
`skills/pm-workflow/references/` (the assembled copy of `docs/` + `templates/`), every agent of the
pipeline carries `skills/agent-runtime-gotchas/SKILL.md`, and auditors and builders receive template
blocks pasted into sub-issue bodies. All of this is Russian today. Cyrillic tokenizes at roughly
twice the cost of English, and that surcharge is paid on every read of every round — the owner's
decision of 2026-09-21 (card 448) is to move the content to English. The exact saving is measured at
the ops stage against the existing `token_baseline` of card 448; this specification delivers the
translation, not the number.

What is already English and must not drift: the score line and its five field names, the scorecard
row format, incident letters `A`…`X` and anchors `inc-*`, owner-decision requisitions `D-N`, all
identifiers (§1), most guard output strings (`FAIL: stop-word …`, `rules in index: N`).

## 1. Invariant

**Every rule keeps its exact meaning, holder, and address; the tree becomes English except the
listed exclusions; identifiers do not change; guards check the same things as before, re-aimed at
the English strings; the score line does not change by a single byte.**

Concretely — translation, not revision:

- No rule is added, removed, or reworded in meaning. A Russian sentence that is ambiguous stays
  ambiguous in English; resolving the ambiguity is a rule change and belongs to the owner, not to
  the translator. Doubt — record it in the code-stage report, do not decide silently.
- The anchor set `<a id="…">` in `docs/` and `skills/` is byte-identical before and after.
- `docs/rule-index.tsv`: same 70 rows, same order; the target column (file#anchor) byte-identical.
  The key column (the rule name, i.e. the heading text) is translated to match the translated
  heading — the key is content, not an identifier.
- Labels keep their semantics: `[CI: check]` unchanged; `[ревью: …]` becomes `[review: …]` with the
  same role and the same checkpoint (§4.2).
- The score line: `SCORE_RE` in `scripts/parse-score-line.sh`, all seven fixtures, the example line
  in `templates/review-report.md`, and the `--self-test` logic are untouched.
- Guard semantics are preserved exactly: every check in `scripts/check-rules.sh` still fails on the
  same class of defect, now matched against English strings (§5).

## 2. Decisions and alternatives

| Question | Chosen | Rejected | Why |
|---|---|---|---|
| Terminology | One glossary (§4) binding for docs/, skills/, templates/, guard messages, commit messages, PR titles; one Russian term — exactly one English term | Let each file choose wording | a term with two translations splits into two concepts for the reader and for grep-based checks |
| `docs/rule-index.tsv` | keys translated, targets and row order byte-identical | keep Russian keys | keys are the rule names (heading text) — content; keeping Cyrillic fails the completeness check (§7 A1) and desynchronizes keys from headings |
| Impact-class values | translated: `hygiene`, `money`, `customers`, `availability` | keep Russian values | values are content used in docs and sub-issue bodies; existing tracker metadata keeps its historical Russian values — the 1:1 map in §4.2 bridges them |
| `CHANGELOG.md` | history entries untouched; the header paragraph (format description) updated for the bilingual transition; new entries in English; the guard accepts both forms per entry (§5.1) | translate history | the entry history is a dated record, not living text; README forbids rewriting it in spirit ("past rows are not rewritten retroactively") |
| `docs/superpowers/plans/2026-09-18-sanitize-pm-workflow.md` | kept in Russian, marked historical | translate | an executed operational plan; it quotes pre-translation sources verbatim — translating it would falsify the quotes; no run ever loads it |
| `scripts/stop-words.txt`, `scripts/stop-words-allow.txt` | untouched, including their Russian comments | translate the comments | functional dictionaries; the public file documents the format shared with the private part (maintained in the private registry); an edit risks the guard for zero run-time benefit |
| Script comments and guard output strings | translated per glossary | keep Russian | the tree is public; comments and FAIL/WARN texts are content read by maintainers and auditors |
| PR structure for the code stage | stacked on the spec branch: merge the spec branch first, translate on top; ops merges one PR containing spec + translation | branch from `origin/main` without the spec | the spec rides in the same commit as the code (regulation `pipeline.md#spec-in-commit`); nothing is merged before ops, so `main` does not yet contain this file |

## 3. Scope — completeness checklist

Every file of the tree gets exactly one verdict. This table is the audit checklist: the code audit
walks it row by row; a file missing from the table is a finding.

| File / directory | Verdict | Why |
|---|---|---|
| `README.md` | translate | content: layer map, rule format, how to edit |
| `CHANGELOG.md` | partial | history entries untouched (dated record); header paragraph updated (bilingual format note); one new English entry on top (§8) |
| `docs/roles.md` | translate | rules layer 2 |
| `docs/pipeline.md` | translate | rules layer 2 |
| `docs/review-cycle.md` | translate | rules layer 2; score-line block stays byte-identical |
| `docs/impact-class.md` | translate | rules layer 2; class values → §4.2 |
| `docs/ownership.md` | translate | rules layer 2 |
| `docs/incidents.md` | translate | headers, preamble, symptom/consequence/rules cells; anchors `inc-*`, letters `A`…`X`, table shape (5 columns) unchanged |
| `docs/rule-index.tsv` | partial | key column and header comment translated; targets byte-identical; 70 rows, same order |
| `docs/required-checks.md` | translate | contract file; job name `check` unchanged |
| `docs/adr/0001-three-layer-regulation.md` | translate | ADR content |
| `docs/adr/0002-public-repository-sanitization.md` | translate | ADR content |
| `docs/autopilots/refresh-skills.md` | translate | autopilot runbook; skill ids stay placeholders |
| `docs/autopilots/rules-without-incident.md` | translate | autopilot runbook |
| `docs/superpowers/plans/2026-09-18-sanitize-pm-workflow.md` | exclude | executed historical plan; verbatim quotes of pre-translation sources must stay verbatim |
| `docs/superpowers/plans/2026-09-21-translate-en.md` | exclude | this file; created in English |
| `templates/subtask.md` | translate | the ten required lines → §5.2 verbatim |
| `templates/review-report.md` | translate | section headers and comments; the score line and the parseable example stay byte-identical (lowercase `full`) |
| `templates/handoff-comment.md` | translate | handoff record template |
| `skills/agent-runtime-gotchas/SKILL.md` | translate | frontmatter `description` + body; anchors, `name`, section prefixes `## A.`/`## B.`/`## C.`, five field-line names → §4.2 |
| `skills/pm-workflow/SKILL.md` | translate | router text; `references/…` file names unchanged (guard 20) |
| `skills/pm-workflow/references/*` (10 files) | via rebuild | never hand-edited: regenerate with `bash scripts/build-skills.sh` after translating the sources; identity held by guard 19 |
| `scripts/check-rules.sh` | partial | comments and FAIL/WARN texts translated per glossary; validation patterns re-aimed at English (§5.1); logic, checks, output coordinates unchanged |
| `scripts/build-skills.sh` | partial | comments translated; `PAIRS` list unchanged |
| `scripts/parse-score-line.sh` | partial | comments translated; `SCORE_RE`, parsing, `--self-test`, fixtures handling unchanged |
| `scripts/required-lines/subtask.txt` | replace | the 10 lines → §5.2 verbatim (exactly the lines guard 18 expects) |
| `scripts/fixtures/score-line/*.txt` (7 files) | exclude | score lines are already English; fixtures are functional |
| `scripts/stop-words.txt` | exclude | functional dictionary (§2) |
| `scripts/stop-words-allow.txt` | exclude | functional dictionary (§2) |
| `.github/workflows/check.yml` | partial | display names and comments translated; job name `check`, triggers, env, step logic unchanged (contract: `docs/required-checks.md`) |
| file and directory names, anchors `<a id="…">`, skill names, incident letters, `D-N`, CLI commands, POSIX ERE in the dictionaries and `SCORE_RE`, secret/variable names (`STOP_WORDS_PRIVATE`, `SANITIZED_HISTORY`), Multica status names | exclude | identifiers, not content |

## 4. Glossary RU → EN (normative)

One Russian term — exactly one English term, everywhere: docs/, skills/, templates/, guard
messages, commit messages, PR titles. Synonyms are forbidden: it is always `score line` (never
"scoring line" or "count line"), always `findings registry` (never "findings log"). Where a Russian
word has two senses, the glossary splits it explicitly.

### 4.1 Terms

| RU | EN |
|---|---|
| регламент | regulation |
| конвейер | pipeline |
| воркспейс | workspace |
| карточка | card |
| карточка-родитель, родитель | parent card |
| подзадача | sub-issue |
| задача | task |
| трекер | tracker |
| стадия | stage |
| стадия постановки | specification stage |
| стадия кода | code stage |
| стадия аудита | audit stage |
| стадия доработки | rework stage |
| механическая правка | mechanical edit |
| постановка | specification |
| спецификация | specification |
| тело подзадачи | sub-issue body |
| самодостаточна | self-sufficient |
| исполнитель | executor |
| запасной исполнитель | backup executor |
| владелец | owner |
| решение владельца | owner decision |
| реквизит (решения, исключения) | reference |
| приёмка | acceptance |
| принятие | acceptance |
| промоция | promotion |
| барьер | barrier |
| барьер стадии | stage barrier |
| очерёдность/порядок старта | start order |
| раскладка (по стадиям) | stage layout |
| прогон | run |
| мёртвый прогон | dead run |
| сорванный прогон | failed run |
| разбор сорванного прогона | failed-run analysis |
| подагент | subagent |
| слаг | slug |
| круг | round |
| круг ревью | review round |
| цикл ревью | review cycle |
| аудит | audit |
| аудитор (исполнитель стадии аудита: аудит постановки или кода) | auditor |
| ревьюер (участник круга ревью: находит и консультирует по диффу) | reviewer |
| замысел | intent |
| отчёт | report |
| коммит | commit |
| инвариант | invariant |
| строка счёта, счётная строка | score line |
| реестр находок | findings registry |
| карточка-реестр | registry card |
| строка реестра | registry row |
| находка | finding |
| подтверждённая находка | confirmed finding |
| код исключения | exception code |
| предохранитель | circuit breaker |
| сходимость, сходиться | convergence, converge |
| чистый круг | clean round |
| панель | panel |
| сборка панели | panel assembly |
| конверт круга | round envelope |
| семейство моделей | model family |
| ESC-пул, эскалационный пул | ESC pool |
| таблица прогонов | run table |
| scorecard | scorecard (unchanged) |
| покрытие | coverage |
| гейт | gate |
| мутация, провокация | mutation |
| кейс с островом | island case |
| замер | measurement |
| сверка | reconciliation |
| технический вердикт | technical verdict |
| синтез круга | round synthesis |
| «минимальный факт» | minimal fact |
| класс влияния | impact class |
| предел кругов | round limit |
| таблица лимитов | limits table |
| изменение объёма | scope change |
| объём | scope |
| эскалация | escalation |
| доклад владельцу | owner report |
| правило | rule |
| держатель | holder |
| метка | label |
| якорь | anchor |
| адрес правила | rule address |
| инцидент | incident |
| резолвер инцидентов | incident resolver |
| слой | layer |
| обход рантайма | runtime workaround |
| обход | workaround |
| условие снятия | removal condition |
| сторож | guard |
| сторож зависших (платформенный монитор) | stale watchdog |
| стоп-слова, стоп-словарь | stop words, stop-word dictionary |
| обезличивание | sanitization |
| приватный реестр | private registry |
| приватный архив | private archive |
| снимок | snapshot |
| заметки воркспейса | workspace notes |
| автопилот | autopilot |
| выкладка | deployment |
| машина (прогона) | machine |
| сборка (скилла) | build |
| собранная копия | assembled copy |
| правка (стадия по находкам) | rework |
| правка (изменение строк) | edit |
| правило без инцидента | rule without an incident |
| кандидат на пересмотр | revision candidate |
| вынос (регламента) | extraction |
| срыв (прогона) | failed run |
| виджет/карточка трекера проекта | project tracker card |

The `сторож` split, declared explicitly (§4: two senses — two rows). `сторож` alone is one of this
repository's own guards → `guard`. `сторож зависших` is the platform's stale-run monitor — a
platform component, kept under its fixed platform name `stale watchdog`. The runtime identifier
`idle_watchdog` (incident E) is a technical identifier, not a translation target (§3). Outside the
identifier lines (the incident E rows of `docs/incidents.md`,
`skills/agent-runtime-gotchas/SKILL.md`, `skills/pm-workflow/references/incidents.md`) and the
excluded plan files, `watchdog` occurs in the tree exactly once — the `сторож зависших` rendering
in `skills/agent-runtime-gotchas/SKILL.md` ("the stale watchdog sees it as silent");
`git grep -c 'watchdog'` minus those identifier lines and excluded plans counts exactly 1.

### 4.2 Fixed line forms — copied verbatim

These exact strings go into the named places; guards match them literally (§5).

Rule files (`docs/roles.md`, `docs/pipeline.md`, `docs/review-cycle.md`, `docs/impact-class.md`,
`docs/ownership.md`):

- Heading label: `` `[CI: check]` `` (unchanged) or `` `[review: <role> @ <point>]` `` with
  role ∈ {PM, Reviewer, Architect, Owner} and point from: `parent creation`, `card creation`,
  `stages creation`, `stage creation`, `audit stage creation`, `wakeup`, `stage barrier`,
  `code stage barrier`, `audit stage barrier`, `promotion`, `code stage promotion`,
  `audit stage promotion`, `round`, `code round`, `round closure`, `panel assembly`,
  `round synthesis`, `technical verdict`, `comment`, `resume comment`, `acceptance comment`,
  `acceptance`, `scorecard line`. The list is exhaustive: every checkpoint value used in
  `docs/` maps 1:1 into it (verify with `git grep -hoE 'ревью: [^]]+ @ ([^]]+)\]' main -- docs`).
  `<точка>` in quoted rule templates (ADR 0001) is the placeholder form, not a checkpoint — it
  translates to `<point>`.
- Incident line: `Incident: none` — or — `Incident: [B](incidents.md#inc-b) — <explanation kept>`.

Sub-issue template `templates/subtask.md` — section headers and fixed lines:

| RU | EN (verbatim) |
|---|---|
| `## Конвейер` | `## Pipeline` |
| `## Цель` | `## Goal` |
| `## Входы` | `## Inputs` |
| `## Что сделать` | `## What to do` |
| `## Что НЕ делается` | `## What is not done` |
| `## Что легко испортить` | `## Easy to break` |
| `## Результат и приёмка` | `## Result and acceptance` |
| `## Запасной исполнитель` | `## Backup executor` |
| `## Отчёт` | `## Report` |
| `## Конверт круга` | `## Round envelope` |
| `## Завершение` | `## Completion` |
| `Подагенты: не заводились` | `Subagents: none started` |
| `Мутации проверять прогоном, не предсказанием` | `Verify mutations by running, not by prediction` |
| `Кейсы с островом` | `Island cases` |
| `…иначе, чем постановка…` | `…differently from the specification…` |
| `…обещано и не сделано` | `…promised but not done` |
| `Свои промахи` | `Own misses` |
| `Класс влияния:` | `Impact class:` |
| `Слаг для PR:` | `PR slug:` |

Review-report template: `## Панель` → `## Panel`; `## Находки (реестр)` → `## Findings (registry)`;
`## Чего машина не проверяет` → `## What the machine does not check`; `## Свои промахи` →
`## Own misses`; panel table headers → `| Agent | Question (question_type) | Confirmed | False |
Unique | Failed (no/repeat/died) |`; registry table headers → `| # | Title | Where (path:line) |
Reproduced personally (yes/no, how) | State (open/closed/needs-decision) | Exception
(accepted-risk/spun-out/awaiting-owner + reference) | Minimal fact |`. The score line (line 2 of the
template) and the parseable example comment stay byte-identical.

Layer-1 skill `skills/agent-runtime-gotchas/SKILL.md` — item fields:

| RU | EN (verbatim) |
|---|---|
| `- Симптом:` | `- Symptom:` |
| `- Причина:` | `- Cause:` |
| `- Обход:` | `- Workaround:` |
| `- Инцидент:` | `- Incident:` |
| `- Условие снятия:` | `- Removal condition:` |

Section headings keep their prefixes: `## A. Multica platform workarounds`,
`## B. Runtimes and providers`, `## C. What moved from this skill to layer 2`.

Incident resolver `docs/incidents.md` — table header: `| Anchor | Id | Symptom | Consequence | Rules |`.

`CHANGELOG.md` — new entries use: `- Decision:`, `- What changed:`, `- Incident:`, `- Affected:`;
history entries keep their Russian forms (§5.1 makes the guard bilingual).

Impact-class values (one map, applied everywhere incl. limits table and sub-issue bodies):

| RU value | EN value |
|---|---|
| `гигиена` | `hygiene` |
| `деньги` | `money` |
| `клиенты` | `customers` |
| `доступность` | `availability` |

Existing tracker metadata on already-created cards keeps its historical Russian values; readers map
them 1:1 through this table. New cards use the English values.

## 5. Guard synchronization

### 5.1 `scripts/check-rules.sh` — pattern couplings

Every place the script matches Russian text, re-aimed at the English form. Logic, check order,
output coordinates (`file:line`, pattern number), and exit codes do not change.

| Check | Today (RU) | After (EN) |
|---|---|---|
| `--list-no-incident` | `/^Инцидент: нет/` | `/^Incident: none/` |
| 2: label on every rule heading | `` `\[(CI: check\|ревью: [^]]+ @ [^]]+)\]`$ `` | `` `\[(CI: check\|review: [^]]+ @ [^]]+)\]`$ `` |
| 3: incident line present, exactly one | `/^Инцидент: /`, valid forms `^Инцидент: нет$` or `incidents\.md#[a-z0-9-]+` | `/^Incident: /`, valid forms `^Incident: none$` or the same link pattern |
| 6: gotchas five fields | `/^- Симптом:/`, `/^- Причина:/`, `/^- Обход:/`, `/^- Инцидент:/`, `/^- Условие снятия:/` (B: field + a YYYY-MM-DD date) | `/^- Symptom:/`, `/^- Cause:/`, `/^- Workaround:/`, `/^- Incident:/`, `/^- Removal condition:/` (same date rule) |
| 9: CHANGELOG four fields | `/^- Решение:/`, `/^- Что изменилось:/`, `/^- Инцидент:/`, `/^- Затронуто:/` | each becomes bilingual, exactly one per entry: `/^- (Решение\|Decision):/`, `/^- (Что изменилось\|What changed):/`, `/^- (Инцидент\|Incident):/`, `/^- (Затронуто\|Affected):/`; the heading pattern `## YYYY-MM-DD — ` (em dash, spaces) is unchanged — English entries keep it |
| 10: layer 2 words must not appear in the layer 1 skill | `решение владельца` outside section C; `предохранител\|три кода` anywhere | `owner decision` outside section C; `circuit breaker\|three consecutive rounds` anywhere |
| 8: completion line in subtask template | `multica issue status <id> done` | unchanged |
| 7: example score line in review-report | `Round: … Coverage: [a-z]+` regex + parse | unchanged; the template keeps exactly one parseable example (lowercase `full`) |
| 1, 5, 20, 21: index, incident links, router, `../` links | language-independent | unchanged |

Comments in the script header and body, and human-readable FAIL/WARN messages, are translated per
the glossary. The WARN about a missing private stop-word list stays a WARN locally and a FAIL under
`CI=true`, exactly as today.

### 5.2 `scripts/required-lines/subtask.txt` — replacement, verbatim

The file is replaced line-for-line with the English counterparts (order irrelevant, count stays 10,
each must occur exactly once in the translated `templates/subtask.md` — guard 18):

```
multica issue status <id> done
## Easy to break
## Report
Subagents: none started
Verify mutations by running, not by prediction
`skipped` = 0
Island cases
differently from the specification
promised but not done
Own misses
```

### 5.3 `scripts/build-skills.sh` — rebuild discipline

After every edit under `docs/` or `templates/`: `bash scripts/build-skills.sh`, then commit the
regenerated `skills/pm-workflow/references/`. Hand edits in `references/` are forbidden (guard 19
fails on any divergence). The `PAIRS` list does not change.

### 5.4 What may NOT change in scripts

- `SCORE_RE`, parsing and `--self-test` in `scripts/parse-score-line.sh`; the seven fixtures.
- Both stop-word dictionaries (patterns and allow-list tokens).
- Guard logic: no check added, removed, or weakened; thresholds `REQUIRED_MIN=10`,
  `STOP_PRIVATE_MIN=20` unchanged. The only behavior change outside the RU→EN re-aiming is the
  history author-scan exemption for GitHub-generated commits — defined and justified in §5.6,
  already delivered in this PR.

### 5.5 `.github/workflows/check.yml`

Translate the two comment lines and the step display name only. The job stays `check`
(contract `docs/required-checks.md`); triggers, `env`, secrets, variables, and step conditions are
untouched.

### 5.6 Stop-word guard still passes

The translated tree must produce `stop-words: 0 matches` exactly as before. The translation cannot
introduce card identifiers, UUIDs, e-mails, GitHub URLs, or cross-repository PR links — if a
translated sentence needs none of them, it needs none; never "fix" a red guard by editing the
dictionaries or weakening patterns. `SANITIZED_HISTORY=1` in this repository, so the guard also
checks the PR title, the commit messages of the range, and — in the history step — commit author
names and e-mails: tracker card identifiers are stop words — the public slug form is `(card N)` and
only that (see §9); the author identity must be the sanitized noreply form (§9, step 2).

One spelling trap, found by running the guard on this very file: write `layer 1`, `layer 2`,
`layer 3` with a space — the hyphenated form matches stop-word pattern #2 (lowercase
letters-digits) and reds the guard on every occurrence, tree-wide.

Two more history-scan defects were found while delivering this PR; both fixes are included in
this PR and are part of what the spec audit reviews:

- Commit identity. The history step of the guard checks commit author names and e-mails; the
  checkout's default personal identity reds it. The delivery recipe (§9 step 2) sets the
  sanitized noreply identity and bypasses the checkout's `prepare-commit-msg` hook, whose
  platform attribution trailer carries an e-mail.
- GitHub-generated commits. The test-merge ref `refs/pull/N/merge` is committed by GitHub
  (committer identity `GitHub` with GitHub's plain no-reply address) but authored with the PR
  creator's profile e-mail — a stop-word false positive on every PR, unfixable from the PR side
  (the pull-request CI run checks out exactly that ref). The guard's author scan now exempts that
  single committer identity: those author fields are chosen by GitHub, not by the committer. Same
  intent as the existing numeric-noreply exception (sanitize decision В3); tripwire scope
  unchanged — the guard catches accidents, not adversaries (git committer fields are claims, not
  proofs). Demonstrated by run: before — the merge commit reds the e-mail pattern; after — the
  same history is clean, while a personal author with an ordinary committer still reds (§5.7 M9).
  Stage 4 inherits the fix through the spec branch; nothing to do there.

### 5.7 Provocations — prove by running, not by prediction

At the code stage each mutation below is applied, the check run, the red output captured, the
mutation reverted, and the green re-captured. Report: command + output for every case (regulation
`pipeline.md#mutation-by-run`). Each case names the invariant it protects.

| # | Mutation (temporary) | Must turn red | Protects |
|---|---|---|---|
| M1 | delete the line `Subagents: none started` from `templates/subtask.md` | guard 18 (`required line occurs 0 times`) | required-lines ↔ template lockstep |
| M2 | remove the label from one `### ` rule heading in `docs/roles.md` | guard 2 (`label missing`) | holder labels survive translation |
| M3 | in one rule of `docs/pipeline.md` replace `Incident: none` with an empty `Incident:` | guard 3 (`has 0 lines "Incident:"`) | incident line re-aimed at EN |
| M4 | insert the words `circuit breaker` into one section A item of the layer 1 skill | guard 10 (`layer 2 words`) | the layer 1 / layer 2 vocabulary fence works in EN |
| M5 | in the layer 1 skill rename one `- Removal condition:` to `- Removal:` | guard 6 (`"Removal condition:" lines = 0`) | gotchas field names re-aimed at EN |
| M6 | in the new CHANGELOG entry delete the `- What changed:` line | guard 9 (`"What changed:" = 0`) | bilingual CHANGELOG check |
| M7 | edit one line of `docs/pipeline.md` and do NOT rebuild `references/` | guard 19 (`build-skills --check` DIFFERS) | rebuild discipline; then `bash scripts/build-skills.sh` turns it green |
| M8 | add one Russian word into `README.md` | acceptance check A1 (§7) output becomes non-zero | the completeness grep actually detects leftovers |
| M9 | author scan: (a) a commit with committer `GitHub` + GitHub's plain no-reply address and a personal author — must stay green (exemption); (b) the same personal author with an ordinary committer — must turn red | `--history` author scan | the merge-ref exemption opens no general hole |

## 6. Equivalence invariants — baseline numbers and commands

Baseline on `origin/main` (commit `1cc9950`), verified 2026-09-21:

| Counter | Before | After |
|---|---|---|
| rules in index (`rules in index:`) | 70 | 70 |
| incident rows in resolver | 24 | 24 |
| gotchas section A / section B items | 13 / 7 | 13 / 7 |
| CHANGELOG entries | 15 | 16 (new entry §8) |
| required lines | 10 | 10 |
| score-line fixtures | 7 | 7 |

Commands (run from the repository root on the code-stage branch; write scratch files next to you,
not into the tree):

```bash
git fetch origin main

# 1. anchor set is byte-identical (empty diff expected)
git grep -ho 'id="[^"]*"' origin/main -- docs skills ':(exclude)docs/superpowers' | sort > anchors-before.txt
git grep -ho 'id="[^"]*"' -- docs skills ':(exclude)docs/superpowers' | sort > anchors-after.txt
diff anchors-before.txt anchors-after.txt && echo ANCHORS-OK

# 2. rule-index: same rows, same order, targets byte-identical
git show origin/main:docs/rule-index.tsv | grep -v '^#' | cut -f2 > tsv-before.txt
grep -v '^#' docs/rule-index.tsv | cut -f2 > tsv-after.txt
diff tsv-before.txt tsv-after.txt && echo TSV-OK
grep -vc '^#' docs/rule-index.tsv   # 70

# 3. rules without incident: same set as before (names translated, set unchanged)
bash scripts/check-rules.sh --list-no-incident | sed 's/ ·.*//' | sort > no-inc-after.txt
git stash -q && git checkout -q origin/main -- docs scripts || true
bash scripts/check-rules.sh --list-no-incident | sed 's/ ·.*//' | sort > no-inc-before.txt
git checkout -q HEAD -- docs scripts && git stash pop -q
diff no-inc-before.txt no-inc-after.txt && echo NOINC-OK
```

Both greps of command 1 carry the pathspec `':(exclude)docs/superpowers'` — the same exclusion
guard 1 makes with `--exclude-dir=superpowers`. This specification itself lives under
`docs/superpowers/` and quotes `id="…"` and the command verbatim; without the exclude a literal
run diffs four phantom anchors out of the plan files instead of the expected empty diff.

(Command 3 restores the working tree afterwards; if `git stash` is inconvenient, run the "before"
half in a second `multica repo checkout` worktree instead. The list's left part is `file#anchor` —
identical before/after even though the rule names to the right are translated. The delimiter ` · `
is multibyte, so the cut is `sed 's/ ·.*//'`, not `cut` — `cut -d` takes a single byte only.
Commit your work before running command 3: it rewrites `docs/` and `scripts/` from `origin/main`
and then restores them from `HEAD` — uncommitted edits in those paths are lost.)

"Unchanged" for `docs/rule-index.tsv` means exactly: targets, row order, and the 70-row count
(cmd 2 compares targets only); the key column is translated (§1) and does not redden any check —
the briefs of stages 4 and 5 use "unchanged" in the same sense.

## 7. Acceptance criteria — mechanical, with commands

All five must hold; each is demonstrated in the code-stage report by command + output.

**A1 — scope closed, no Cyrillic left outside the exclusions.** Zero matches. The tool is a
codepoint measurement (`python3`), not `grep`: in a C/POSIX locale — the default on macOS agent
shells — both plain `grep` and `git grep -P` apply the Cyrillic bracket class byte-wise and
false-positive on multibyte typography (`—`, `·`, `→`, `«»`): 399 false lines over the translated
files, 3 in the new CHANGELOG entry, 1 in its header — all found by run at the code stage. Below,
the class `[А-Яа-яЁё]` is expanded to its exact codepoints (U+0410–U+042F, U+0430–U+044F,
U+0401, U+0451) and `python3` decodes UTF-8 explicitly, so the counts are locale-independent —
0/0/0 on BSD/macOS and Linux alike:

```bash
git ls-files -- README.md docs/roles.md docs/pipeline.md docs/review-cycle.md \
  docs/impact-class.md docs/ownership.md docs/incidents.md docs/rule-index.tsv \
  docs/required-checks.md docs/adr docs/autopilots templates skills scripts/check-rules.sh \
  scripts/build-skills.sh scripts/parse-score-line.sh scripts/required-lines .github \
  | python3 -c 'import sys
print(sum(1 for p in map(str.strip, sys.stdin) for ln in open(p, encoding="utf8")
          if any("\u0410" <= c <= "\u042f" or "\u0430" <= c <= "\u044f" or c in "\u0401\u0451" for c in ln)))'
```

Excluded by design (§3): `CHANGELOG.md` history, `docs/superpowers/plans/2026-09-18-*.md`,
`scripts/stop-words.txt`, `scripts/stop-words-allow.txt`, `scripts/fixtures/`, this plan file.
The new CHANGELOG entry itself must be English — zero matches:

```bash
awk '/^## /{n++} n>=1 && n<2' CHANGELOG.md | python3 -c 'import sys
print(sum(1 for ln in sys.stdin.buffer.read().decode("utf8").splitlines()
          if any("\u0410" <= c <= "\u042f" or "\u0430" <= c <= "\u044f" or c in "\u0401\u0451" for c in ln)))'
```

The rewritten header paragraph of `CHANGELOG.md` (everything above the first `## ` entry heading)
is covered the same way — zero matches:

```bash
awk '/^## /{n++} n<1' CHANGELOG.md | python3 -c 'import sys
print(sum(1 for ln in sys.stdin.buffer.read().decode("utf8").splitlines()
          if any("\u0410" <= c <= "\u042f" or "\u0430" <= c <= "\u044f" or c in "\u0401\u0451" for c in ln)))'   # 0
```

**A2 — invariants green:** all three diffs of §6 empty, counters match the table.

**A3 — local guard green:** `bash scripts/check-rules.sh` prints `check-rules: 0 errors` with the
§6 counters (the local WARN about the missing private stop-word list is expected and is not an
error), and `bash scripts/parse-score-line.sh --self-test` reports 7 fixtures, 0 failed.

**A4 — CI green on the PR head:** `gh pr checks <pr>` — every check `pass`; one call, no
`--watch`; the output goes into the report verbatim. Red — the sub-issue goes `blocked` with the
output, per the code-stage barrier rule.

**A5 — provocations demonstrated:** M1–M8 (§5.7), each by run: red output, revert, green output.

## 8. CHANGELOG entry (English)

The code stage adds this entry on top of `CHANGELOG.md` (date = merge day; the header paragraph of
the file is updated the same PR to say: entries before 2026-09-21 keep the Russian field names,
new entries use the English ones — both are accepted by the guard):

```markdown
## <YYYY-MM-DD> — content translated to English
- Decision: owner, 2026-09-21 (D-10; card 448 comment — mapping in the private registry): the regulation is read in agent runs at every round, and Russian text costs roughly twice the English tokens; translate the repository content to English.
- What changed: all content translated (docs/, skills/, templates/, script comments and guard messages, workflow display names); rule-index.tsv keys translated with targets and row order unchanged; guards re-aimed at the English strings (labels, incident lines, gotchas fields, CHANGELOG fields, required lines) — bilingual CHANGELOG check; impact-class values hygiene/money/customers/availability; stop-word dictionaries, score-line format and fixtures, CHANGELOG history, and the 2026-09-18 sanitization plan untouched; stop-word history scan: GitHub-generated test-merge commits exempt from the author check (false-positive fix from the specification PR, see the plan §5.6).
- Incident: none.
- Affected: the whole tree except scripts/stop-words.txt, scripts/stop-words-allow.txt, CHANGELOG history entries, docs/superpowers/plans/2026-09-18-sanitize-pm-workflow.md, scripts/fixtures/.
```

`D-10` is the next free requisition number (last used: D-9). If it turns out taken at merge time,
take the next free number — the private-registry mapping (owner comment on card 448), not the
number, is the identity; the ops stage records the mapping.

## 9. Delivery (code stage)

1. `multica repo checkout <this repository URL>` — your own worktree on a dedicated branch; never
   `git switch` in a shared tree (regulation `pipeline.md#one-writer`).
2. Set the worktree git identity to the sanitized noreply form before the first commit — the
   history step of the stop-word guard checks commit author names and e-mails, and the default
   personal identity reds it (found by run on this very PR). Mirror the identity of the initial
   commit of this repository — no literal address is written here on purpose (an address literal
   is itself a stop-word match in the tree):

   ```bash
   git config --worktree user.name  "$(git log origin/main -1 --format='%an')"
   git config --worktree user.email "$(git log origin/main -1 --format='%ae')"
   ```

   (the guard's noreply exception requires the author name to equal the login).

   The checkout installs a `prepare-commit-msg` hook that appends a platform attribution
   trailer to every commit; the trailer's e-mail is a stop-word match in commit messages
   (found by run on this very PR; the initial commit of this repository is trailer-free).
   Bypass it — commit with an empty hooks path, and verify before pushing:

   ```bash
   NOHOOKS="$(mktemp -d)"
   git -c core.hooksPath="$NOHOOKS" commit -m "<message>"
   git log --format='%B' origin/main..HEAD | grep -c '@'   # 0
   ```
3. `git fetch origin agent/jarvis-ai-pm/3a6058a025f8 && git merge --no-edit FETCH_HEAD` — the spec
   branch; your branch now contains this file (it may have been amended by the spec-rework stage —
   merge whatever its current head is).
4. Translate per §3–§5; rebuild `references/` (§5.3); add the CHANGELOG entry (§8). For
   `docs/rule-index.tsv` translate the key column only — "unchanged" means targets + row order +
   the 70-row count (§6 cmd 2), the briefs of stages 4 and 5 use the word in the same sense.
5. Verify §7 locally (A1–A3, A5), push, open the PR:
   `gh pr create --base main --title "docs: translate pm-workflow content to English (card 573)"`.
   Title and every commit message use the `(card N)` slug form — tracker card identifiers are stop
   words and the guard checks titles and commit messages in this repository; a red
   `stop-word in PR` / `in commit message` means the text carries an identifier — rewrite the text.
6. Do NOT merge. The ops stage merges this PR (squash; the spec rides in the same commit) and
   closes the spec PR as included. Do not run any `multica skill …` commands — refresh is ops.
7. Report on your sub-issue per its body template (five sections, first line
   `Subagents: none started`), including: the PR link, §7 outputs A1–A5, and where you decided
   differently from this specification and why.
8. On completion set your sub-issue to `done` — never leave it `in_review`.

## 10. What is NOT done

- No rule changes: nothing added, removed, or reworded in meaning; ambiguity is preserved, not
  resolved (§1).
- No renames: files, directories, anchors, skill names, incident letters, `D-N`, job name `check`.
- No translation of: stop-word dictionaries, score-line fixtures, CHANGELOG history, the
  2026-09-18 sanitization plan.
- No guard weakening: patterns, thresholds, checks, output coordinates stay; only their target
  strings move RU → EN (§5.1), plus two documented deviations — the bilingual CHANGELOG
  acceptance (§2) and the history author-scan exemption for GitHub-generated commits (§5.6,
  false-positive fix delivered with this PR).
- No merge, no branch-protection changes, no `multica skill` operations, no publication steps —
  all ops stage.
- No changes in the private registry or the private archive (ops/PM bookkeeping, incl. the D-10
  mapping).

## 11. What the machine does not check

- Fidelity of the translation per anchor — that is the code audit's job (RU↔EN side-by-side per
  rule, per `docs/rule-index.tsv` row); counters and diffs in §6 prove structure, not meaning.
- The actual token saving — measured at ops against card 448 `token_baseline`.
- Private-registry bookkeeping (D-10 mapping, incident-letter backfill) — PM at ops.

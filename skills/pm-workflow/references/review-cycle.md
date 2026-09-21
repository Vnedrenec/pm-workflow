# Review cycle: score line, registry, exceptions, circuit breaker, panel, scorecard

Layer 2 of the workspace regulation. Rule format — `README.md`; rule address — `review-cycle.md#<anchor>`. Sources of the text: the snapshot of the PM instructions as of 2026-09-18 (in the private archive; the sections "Cycle-stopping rule", "Round score line and cycle closure"), the source-project file `docs/engineering/pm-workflow.md` §2.6 and §3, the `agent-runtime-gotchas` skill (moved rules). Round limits per class — `impact-class.md`.

## Score line

### The score line — the first line of the Reviewer report, checked character by character `[CI: check]`
<a id="score-line"></a>

The first line of the Reviewer report is machine-readable. Format:

```
Round: N | Stage: spec|arch|code | Confirmed findings: N | Failed runs: M | Coverage: full|partial|unknown
```

All five fields are required in this order; the only tolerance is spaces around `|` and `:`; the case of keys and values is exact. `Round` and `Stage` are read by the round counter in the parent metadata and by the scorecard row. `arch` is a legal value (Architecture Auditor), it counts as a specification stage round; do not return a report with `Stage: arch`. The regular expression (POSIX ERE):

```
^Round:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Stage:[[:space:]]*(spec|arch|code)[[:space:]]*\|[[:space:]]*Confirmed findings:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Failed runs:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Coverage:[[:space:]]*(full|partial|unknown)[[:space:]]*$
```

A report whose first line does not pass the format does not count as a round: return it to the Reviewer, do not guess the numbers. Closure is applied by the two numbers and the `Coverage` field, without interpreting the text; closure is possible only at `Coverage: full`. Holder: `scripts/parse-score-line.sh` — in CI on the example from `review-report.md` and the seven fixtures; at the barrier the PM runs the script on the first line of the report (`bash references/parse-score-line.sh "<line>"` from the skill directory), never reads it by eye.

Incident: none

## Cycle closure

### The cycle closes only when two conditions hold at once `[review: PM @ round closure]`
<a id="closure"></a>

1. The score line gives closure: zero confirmed new findings at `Coverage: full`.
2. The registry queue is empty: every registry row is in state `closed` or carries a valid label in the `Exception` column (`#exception-codes`).

Both hold — the next stage; at least one does not — the cycle is open. The check is mechanical: read the registry table (`#registry`); a single row not `closed` with an empty or invalid `Exception` cell — the cycle does not close, the registry goes back to the Reviewer with the row names. Reconciliation of 2026-09-18 (`CHANGELOG.md`): the "minimum two rounds" from the source-project file §2.6 does not apply — one clean round closes the cycle; confirmed by the owner 2026-09-18.

Incident: none

### The findings registry — a card under the parent `[review: PM @ round closure]`
<a id="registry"></a>

The registry carrier is a separate registry card in the tracker under the cycle's parent; its id is in the parent metadata, key `findings_registry_issue`. The registry outlives the cycle: it stays in `backlog` under the parent, the key is not removed. Row columns — `review-report.md` ("Findings (registry)").

Incident: none

### Exception codes — exactly three, there are no others `[review: PM @ round closure]`
<a id="exception-codes"></a>

| Code | Meaning | Who sets it | Reference — the validity sign, checked mechanically |
|---|---|---|---|
| `accepted-risk` | the owner accepted the finding as a conscious risk | the owner; the Reviewer writes it into the registry on his decision | a link to the owner decision: the id or date of the deciding comment |
| `spun-out` | the finding is spun out of the cycle into a separate task | the owner decides; the PM executes (creates the card, writes the id) | the id of an existing Multica card in the registry row |
| `awaiting-owner` | the finding is in state `needs-decision`, its "minimal fact" is the owner's answer | the Reviewer at round synthesis | the row state is `needs-decision` AND the "minimal fact" field names the owner's answer, not a run and not access |

The restriction on `awaiting-owner`: if the minimal fact is "a run" or "access", the exception is illegal — the cycle obtains such facts itself. An invalid label = a missing one: `accepted-risk` without a link to the decision, `spun-out` without the id of an existing card, `awaiting-owner` with the fact "run"/"access". The PM does not argue substance — he checks the references; such a row blocks closure, the registry goes back to the Reviewer with the row name. Removing or editing labels himself is outside the PM's powers. For the `hygiene` class the `accepted-risk` reference = the class decision comment (`impact-class.md#hygiene`).

Incident: none

### Circuit breaker: three rounds without convergence — stop and the owner `[review: PM @ audit stage barrier]`
<a id="fuse"></a>

Three rounds in a row without convergence — stop, do not start a fourth: the parent to `blocked`, to the owner — what exactly fails to converge. "Without convergence" = the round again produced confirmed findings, that is, the past edits did not close the problem. This is a circuit breaker, not the norm: by measurements a specification converges in three revisions, code — in two-three rounds. Limits per class — `impact-class.md#limits-table`.

Incident: none

### Zero findings ≠ a clean result on a dead run `[review: Reviewer @ round synthesis]`
<a id="dead-run-zero"></a>

An empty answer at `status=ok` is a dead run, not "found nothing". The Reviewer must tell them apart and say so explicitly (analysis — `agent-runtime-gotchas`, the "Failed-run analysis" section; the `Failed runs` field of the score line). A report without an explicit `Confirmed findings: N` line does not count as a round — ask again, do not guess.

Incident: none

### The closure comment lists the excepted rows `[review: PM @ round closure]`
<a id="closure-comment"></a>

Excepted findings do not evaporate. In the closure comment list every excepted row with its code and references. Further oversight by code: `spun-out` — the executor and owner of the spun-out card through the normal pipeline; `accepted-risk` and `awaiting-owner` — the owner, and the closure comment addresses this list to him explicitly.

Incident: none

## Round

### The audit subject — the whole diff, including text `[review: Reviewer @ round]`
<a id="audit-subject"></a>

Docblocks, file headers, commit messages, and the PR title are claims — they are checked like code; a false claim is a finding of the same weight as a false promise of a mutation.

Incident: [H](incidents.md#inc-h) — owner decision 2026-09-14.

### Every round finds its own layer; give the reviewer the intent; reproduce a finding before fixing `[review: PM @ audit stage creation]`
<a id="round-layers"></a>

Practice: the first round finds a defect in the code, the second — a check that does not know how to fail, the third — a comment promising more than it checks. Give the reviewer the intent, not only the diff: without it he compares the code against itself. Do not fix a finding from a story — reproduce it first: a finding's premise twice in one day turned out to be wrong. After edits per the findings — a new round: a fix regularly births a defect of the same class; the executor breaks the NEW check before handing over.

Incident: none

### An (agent, question) pair does not repeat two rounds in a row `[review: Reviewer @ panel assembly]`
<a id="panel"></a>

An agent that worked a question on round N brings almost zero on N+1 for the same question: he has converged on his picture and walks around the same places. Either the agent or the angle of the question changes; a round later the pair is allowed again — someone else's audit and edit have lain in between. This applies also to a narrow round with a single auditor, where the temptation "he is already in context" is maximal. Panel assembly order: first cut yesterday's pair, then pick a replacement by class and price. The previous round's pair is written into the round envelope (`pipeline.md#audit-envelope`). Basis — owner decision 2026-08-18 on a measurement on Sol (no card; entry in `CHANGELOG.md`).

Incident: none

### One representative of a model family per round; the run table `[review: Reviewer @ panel assembly]`
<a id="one-per-family"></a>

Two variants of one model produce overlapping findings at double the price and time. Composition: a strong model for "find the hole" and "boundaries", a mid one for specification audit, a cheap one for "reconcile the facts". The run table (confirmed / false / unique / failed) is in every round's report (`review-report.md`, "Panel"), otherwise the choice of auditor goes by impression. The assignment to an auditor includes a context budget and the requirement to write findings as they are discovered.

Incident: [T](incidents.md#inc-t).

### Scorecard — a row per run, the round closure gate `[review: PM @ round closure]`
<a id="scorecard"></a>

Every review round is scored, the scores live in git: the rows must outlive the workspace, and the diff is the only honest record of editing a past number. The repository is the one registered in the workspace registry with the description `scorecard`; the address — `multica repo list`, never from memory and never by card number (`incidents.md#inc-a`). The Reviewer writes his own rows — one PR per run, file `data/rows.d/<YYYY-MM-DD>-<task-slug>-<agent-slug>.csv`. Gate: a round closes only if the second line of the Reviewer report is `Scorecard: <PR URL>` and at that URL there exists a PR in the `scorecard` repository with exactly one file matching the mask, with the round date and the task; the PM check — `gh pr view <URL> --json files --jq '.files[].path'`. Merging the scorecard PR is not required — the owner does it, it does not block the pipeline. No `gh` or permissions — the line `Scorecard: blocked — <reason>`, the round does NOT close, the PM escalates to the owner within the hour.

Incident: [A](incidents.md#inc-a) → ADR 0001 of the `scorecard` repository; the last row before this rule — 2026-09-13, with rounds after it.

### The run model — only from `multica runtime usage` `[review: Reviewer @ scorecard line]`
<a id="model-from-usage"></a>

From inside a run the model is undeterminable: the harness substitutes a product persona and the agent will repeat it. Never ask an agent which model it runs on and never write a "Model: …" line into a specification — it invites a confident answer to an unanswerable question and lands in the scorecard as fact. Source: `multica runtime usage <runtime-id> --days 1 --output json` — one row per model with `input_tokens`, `output_tokens`, `cache_read_tokens`; it shows both that the models are different and that `thinking_level` applied. Task records and argv do not store the model (workaround — `agent-runtime-gotchas#model-not-in-task`). A model unconfirmed by accounting — the scorecard row is marked unreliable as to model.

Incident: [C](incidents.md#inc-c).

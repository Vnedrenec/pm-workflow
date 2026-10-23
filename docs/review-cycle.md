# Review cycle: score line, registry, exceptions, circuit breaker, panel, scorecard

Rule address — `review-cycle.md#<anchor>`. Round limits per class — `impact-class.md`.

## Score line

### The score line — first line of the Reviewer report, checked character by character `[CI: check]`
<a id="score-line"></a>

```
Round: N | Stage: spec|arch|code | Confirmed findings: N | Failed runs: M | Coverage: full|partial|unknown
```

All five fields required in this order; the only tolerance is spaces around `|` and `:`; case is exact. `arch` is legal (Architecture Auditor) and counts as a specification stage round. POSIX ERE:

```
^Round:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Stage:[[:space:]]*(spec|arch|code)[[:space:]]*\|[[:space:]]*Confirmed findings:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Failed runs:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Coverage:[[:space:]]*(full|partial|unknown)[[:space:]]*$
```

A report whose first line fails the format is not a round: return it to the Reviewer, do not guess. Closure is applied by the two numbers and `Coverage`, without interpreting the text; closure only at `Coverage: full`. At the barrier the PM runs `bash references/parse-score-line.sh "<line>"`, never reads by eye.

## Cycle closure

### The cycle closes only when two conditions hold `[review: PM @ round closure]`
<a id="closure"></a>

1. The score line gives closure: zero confirmed new findings at `Coverage: full`.
2. The registry queue is empty: every row is `closed` or carries a valid `Exception` label (`#exception-codes`).

Both hold — next stage; one does not — the cycle is open: a single row not `closed` with an empty or invalid `Exception` cell sends the registry back to the Reviewer with the row names. One clean round closes the cycle; there is no "minimum two rounds".

### The findings registry — a card under the parent, closed with the parent `[review: PM @ round closure]`
<a id="registry"></a>

A separate registry card under the cycle's parent; id in the parent metadata key `findings_registry_issue`. While the cycle lives it stays in `backlog`, rewritten round to round. When the parent goes to `done` (`ownership.md#parent-done`) the PM closes the registry card in `done` in the same run; the card stays under the parent and the metadata key stays. Row columns — `review-report.md` ("Findings (registry)").

### Exception codes — exactly three `[review: PM @ round closure]`
<a id="exception-codes"></a>

| Code | Meaning | Who sets it | Validity reference, checked mechanically |
|---|---|---|---|
| `accepted-risk` | the owner accepted the finding as a conscious risk | the owner; the Reviewer writes it into the registry | link to the owner decision: id or date of the deciding comment |
| `spun-out` | spun out into a separate task | the owner decides; the PM creates the card and writes the id | id of an existing Multica card in the row |
| `awaiting-owner` | row state `needs-decision`, its "minimal fact" is the owner's answer | the Reviewer at synthesis | state is `needs-decision` AND the minimal fact names the owner's answer, not a run and not access |

If the minimal fact is "a run" or "access", `awaiting-owner` is illegal — the cycle obtains such facts itself. An invalid label equals a missing one. The PM does not argue substance — he checks the references; an invalid row blocks closure and goes back to the Reviewer. The PM does not remove or edit labels. For `hygiene` the `accepted-risk` reference is the class decision comment (`impact-class.md#hygiene`).

### Circuit breaker: three rounds without convergence — stop `[review: PM @ audit stage barrier]`
<a id="fuse"></a>

Three rounds in a row that again produce confirmed findings — stop, no fourth: parent to `blocked`, to the owner with what fails to converge. Limits per class — `impact-class.md#limits-table`.

### Zero findings ≠ a clean result on a dead run `[review: Reviewer @ round synthesis]`
<a id="dead-run-zero"></a>

An empty answer at `status=ok` is a dead run, not "found nothing". The Reviewer tells them apart explicitly (`agent-runtime-gotchas`, "Failed-run analysis"; the `Failed runs` field). A report without an explicit `Confirmed findings: N` line is not a round — ask again.

### The closure comment lists the excepted rows `[review: PM @ round closure]`
<a id="closure-comment"></a>

List every excepted row with its code and references. Further oversight: `spun-out` — the spun-out card's pipeline; `accepted-risk` and `awaiting-owner` — the owner, addressed explicitly.

## Round

### The audit subject — the whole diff, including text `[review: Reviewer @ round]`
<a id="audit-subject"></a>

Docblocks, file headers, commit messages and the PR title are claims checked like code; a false claim is a finding of the same weight as a false mutation promise.

### Every round finds its own layer; give the reviewer the intent; reproduce before fixing `[review: PM @ audit stage creation]`
<a id="round-layers"></a>

Give the reviewer the intent, not only the diff: without it he compares the code against itself. Do not fix a finding from a story — reproduce it first. After edits per the findings — a new round: a fix regularly births a defect of the same class; the executor breaks the NEW check before handing over.

### An (agent, question) pair does not repeat two rounds in a row `[review: Reviewer @ panel assembly]`
<a id="panel"></a>

An agent that worked a question on round N brings almost nothing on N+1 for the same question. Change the agent or the angle; a round later the pair is allowed again. Applies also to a narrow round with a single auditor. Panel assembly order: first cut yesterday's pair, then pick a replacement by class and price. The previous round's pair goes into the round envelope (`pipeline.md#audit-envelope`).

### One representative of a model family per round; the run table `[review: Reviewer @ panel assembly]`
<a id="one-per-family"></a>

Two variants of one model produce overlapping findings at double the price. Composition: a strong model for "find the hole" and "boundaries", a mid one for specification audit, a cheap one for "reconcile the facts". The run table (confirmed / false / unique / failed) is in every round's report (`review-report.md`, "Panel"). The assignment to an auditor includes a context budget and the requirement to write findings as they are discovered.

### Scorecard — a row per run, the round closure gate `[review: PM @ round closure]`
<a id="scorecard"></a>

Scores live in git. The repository is the one registered in the workspace with the description `scorecard` — address via `multica repo list`, never from memory or by card number. The Reviewer writes his own rows — one PR per run, file `data/rows.d/<YYYY-MM-DD>-<task-slug>-<agent-slug>.csv`. Gate: a round closes only if the second line of the Reviewer report is `Scorecard: <PR URL>` and that PR in the `scorecard` repository has exactly one file matching the mask with the round date and the task; PM check — `gh pr view <URL> --json files --jq '.files[].path'`. Merging the PR is the owner's job and does not block. No `gh` or permissions — the line `Scorecard: blocked — <reason>`, the round does NOT close, the PM escalates within the hour.

### The run model — only from `multica runtime usage` `[review: Reviewer @ scorecard line]`
<a id="model-from-usage"></a>

From inside a run the model is undeterminable: the harness substitutes a product persona. Never ask an agent which model it runs on and never write a "Model: …" line into a specification. Source: `multica runtime usage <runtime-id> --days 1 --output json` — one row per model with `input_tokens`, `output_tokens`, `cache_read_tokens`; it also shows that `thinking_level` applied (`agent-runtime-gotchas#model-not-in-task`). A model unconfirmed by accounting — the scorecard row is marked unreliable as to model.

# Review cycle: score line, registry, exceptions, circuit breaker, panel, scorecard

Rule address — `review-cycle.md#<anchor>`. Round limits per class — `impact-class.md`.

## Score line

### The score line — first line of the Reviewer report, checked character by character `[CI: check]`
<a id="score-line"></a>

```
Round: N | Stage: spec|arch|code | Confirmed findings: N | Failed runs: M | Coverage: full|partial|unknown
```

Five fields, this order, exact case; only spaces around `|` and `:` are tolerated. `arch` (Architecture Auditor) counts as a specification stage round. POSIX ERE:

```
^Round:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Stage:[[:space:]]*(spec|arch|code)[[:space:]]*\|[[:space:]]*Confirmed findings:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Failed runs:[[:space:]]*([0-9]+)[[:space:]]*\|[[:space:]]*Coverage:[[:space:]]*(full|partial|unknown)[[:space:]]*$
```

First line fails the format — not a round: return to the Reviewer, do not guess. Closure is decided by the two numbers and `Coverage`, only at `Coverage: full`. At the barrier run `bash references/parse-score-line.sh "<line>"`; never parse by eye.

## Cycle closure

### The cycle closes only when two conditions hold `[review: PM @ round closure]`
<a id="closure"></a>

1. Score line: zero confirmed findings at `Coverage: full`.
2. Registry queue empty: every row `closed` or with a valid `Exception` label (`#exception-codes`).

Both — next stage. One row not `closed` with an empty or invalid `Exception` cell — registry back to the Reviewer with the row names. One clean round closes the cycle; no "minimum two rounds".

### The findings registry — a card under the parent, closed with the parent `[review: PM @ round closure]`
<a id="registry"></a>

A separate card under the cycle's parent; id in parent metadata `findings_registry_issue`. Stays in `backlog` while the cycle lives, rewritten round to round. On the parent's `done` (`ownership.md#parent-done`) the PM sets the registry card `done` in the same run; card and metadata key stay. Row columns — `review-report.md` ("Findings (registry)").

### Exception codes — exactly three `[review: PM @ round closure]`
<a id="exception-codes"></a>

| Code | Meaning | Who sets it | Validity reference, checked mechanically |
|---|---|---|---|
| `accepted-risk` | the owner accepted the finding as a conscious risk | the owner; the Reviewer writes it into the registry | id or date of the owner's deciding comment |
| `spun-out` | spun out into a separate task | the owner decides; the PM creates the card and writes the id | id of an existing Multica card in the row |
| `awaiting-owner` | row state `needs-decision`, its "minimal fact" is the owner's answer | the Reviewer at synthesis | state `needs-decision` AND the minimal fact names the owner's answer, not a run and not access |

Minimal fact "a run" or "access" — `awaiting-owner` is illegal; the cycle obtains such facts itself. Invalid label = missing label. The PM checks references, not substance; does not remove or edit labels; an invalid row blocks closure and goes back to the Reviewer. For `hygiene` the `accepted-risk` reference is the class decision comment (`impact-class.md#hygiene`).

### Circuit breaker: three rounds without convergence — stop `[review: PM @ audit stage barrier]`
<a id="fuse"></a>

Three rounds in a row with confirmed findings — no fourth: parent `blocked`, owner, with what fails to converge. Limits per class — `impact-class.md#limits-table`.

### Zero findings ≠ a clean result on a dead run `[review: Reviewer @ round synthesis]`
<a id="dead-run-zero"></a>

An empty answer at `status=ok` is a dead run, not "found nothing". The Reviewer separates them explicitly (`agent-runtime-gotchas`, "Failed-run analysis"; the `Failed runs` field). No explicit `Confirmed findings: N` — not a round, ask again.

### The closure comment lists the excepted rows `[review: PM @ round closure]`
<a id="closure-comment"></a>

Every excepted row with code and reference. Oversight after closure: `spun-out` — the spun-out card's pipeline; `accepted-risk` and `awaiting-owner` — the owner, addressed explicitly.

## Round

### The audit subject — the whole diff, including text `[review: Reviewer @ round]`
<a id="audit-subject"></a>

Docblocks, file headers, commit messages, PR title are claims checked like code; a false claim is a finding of the same weight as a false mutation promise.

### Every round finds its own layer; give the reviewer the intent; reproduce before fixing `[review: PM @ audit stage creation]`
<a id="round-layers"></a>

Give the reviewer the intent, not only the diff. Reproduce a finding before fixing it. After edits per the findings — a new round; the executor breaks the NEW check before handing over.

### An (agent, question) pair does not repeat two rounds in a row `[review: Reviewer @ panel assembly]`
<a id="panel"></a>

Change the agent or the angle; one round later the pair is allowed again. Applies to a single-auditor round too. Assembly order: cut the previous round's pair, then pick a replacement by class and price. The previous pair goes into the round envelope (`pipeline.md#audit-envelope`).

### One representative of a model family per round; the run table `[review: Reviewer @ panel assembly]`
<a id="one-per-family"></a>

One model per family. Composition: a strong model for "find the hole" and "boundaries", a mid one for specification audit, a cheap one for "reconcile the facts". The run table (confirmed / false / unique / failed) is in every round's report (`review-report.md`, "Panel"). An auditor's assignment includes a context budget and "write findings as they are discovered".

### Scorecard — a row per run, the round closure gate `[review: PM @ round closure]`
<a id="scorecard"></a>

Scores live in git: the workspace repository with description `scorecard`, address via `multica repo list`, never from memory. The Reviewer writes its own rows — one PR per run, file `data/rows.d/<YYYY-MM-DD>-<task-slug>-<agent-slug>.csv`. Gate: the second line of the Reviewer report is `Scorecard: <PR URL>` and that PR holds exactly one file matching the mask for the round date and task; PM check — `gh pr view <URL> --json files --jq '.files[].path'`. Merging the PR is the owner's job and does not block. No `gh` or no permissions — `Scorecard: blocked — <reason>`, the round does NOT close, the PM escalates within the hour.

### The run model — only from `multica runtime usage` `[review: Reviewer @ scorecard line]`
<a id="model-from-usage"></a>

Never ask an agent which model it runs on; never write a "Model: …" line into a specification. Source: `multica runtime usage <runtime-id> --days 1 --output json` — one row per model with `input_tokens`, `output_tokens`, `cache_read_tokens`, and whether `thinking_level` applied (`agent-runtime-gotchas#model-not-in-task`). Model unconfirmed by accounting — the scorecard row is marked unreliable as to model.

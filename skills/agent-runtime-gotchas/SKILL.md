---
name: agent-runtime-gotchas
description: Multica platform and provider workarounds for anyone assembling a round, standing at a barrier or reading someone else's run. Load when a card did not start, a barrier did not close, a run died, a barrier woke the PM twice, the model is in doubt, or a provider errored.
---

Workarounds only. Regulation (roles, barriers, score line, registry, round limits) is in the `pm-workflow` repository, `docs/`. For an executor inside its own run see `audit-run-hygiene`.

## A. Multica platform

### `mention-is-run` — only leaving `backlog` or a mention starts a run
<a id="mention-is-run"></a>
- `backlog → todo` starts the assignee's run unless an earlier-stage sibling is still open; so does creating an issue in `todo`. Confirm with `multica issue runs <issue-id> --active`.
- Any other status change starts nothing, `blocked → todo` included. To resume: comment with `[@Name](mention://agent/<agent-id>)`, or repeat a run with `multica issue rerun-task <run-id>` (IDs from `multica issue runs <issue-id> --full-id`; `--fresh` for a new session and working directory).
- A mention starts a run even past open earlier stages. Every mention is a paid run: replies, thanks, FYI — without the link.

### `in-review-not-terminal` — `in_review` does not close the stage barrier
<a id="in-review-not-terminal"></a>
- The barrier fires only on `done`/`cancelled` of all sub-issues; the runtime ends a run at `in_review` by default.
- Every sub-issue body must carry: "on completion run `multica issue status <id> done`; do NOT leave it `in_review`". The line lives in `templates/subtask.md` of `pm-workflow`, enforced by `scripts/check-rules.sh`. A sub-issue without it is not created.

### `parent-backlog-first` — a parent created outside `backlog` starts a second PM run
<a id="parent-backlog-first"></a>
- Order: parent with `--status backlog`; sub-issues (first `todo`, rest `backlog`); metadata; only then `in_progress`. Raising from `backlog` wakes the PM once — expected.

### `cancel-does-not-stop` — `cancelled` and unassigning do not stop a run
<a id="cancel-does-not-stop"></a>
- Stop a started run with `multica issue cancel-task <run-id>`; the ID comes from `multica issue runs <issue-id> --active`. A wasted run costs the same as a needed one — do not start what you may cancel.

### `barrier-by-status` — the barrier closes on statuses, not on reports
<a id="barrier-by-status"></a>
- At the barrier read the report, not the status. Reviewer dead, panel done — run a separate synthesis stage (`pm-workflow` `docs/pipeline.md#synthesis-stage`).

### `stage-wakeup-dies-at-done` — an issue's wakeups are disabled at its `done`
<a id="stage-wakeup-dies-at-done"></a>
- The executor sets `done` inside its own run, so `task.completed` on the sub-issue never fires. The barrier signal is a wakeup on the PARENT (`pm-workflow` `docs/pipeline.md#barrier-wakeup`).
- To react to an issue's `done`, put the wakeup on another open issue: `--until-issue <id> --until-issue-state done`. A wakeup needs `--instruction`.

### `system-child-done-duplicate` — the platform also wakes the parent's assignee when a stage closes
<a id="system-child-done-duplicate"></a>
- It fires when the next stage holds a `backlog` sub-issue and normally merges with the explicit wakeup into one run. A `todo` next stage starts by itself and the parent is not woken.
- Agents cannot disable it. A repeat wake is a no-op per `pm-workflow` `docs/pipeline.md#barrier-dedup`.

### `model-not-in-task` — the run model is not self-reportable; read it from the run's usage
<a id="model-not-in-task"></a>
- The harness injects a product persona; self-reports are unreliable.
- The model is in the run record: `usage[].model` in `multica issue runs <issue-id> --output json`. A run without `usage` proves nothing — mark the scorecard row "model unverified".

### `skill-no-versions` — `multica skill update` without `--base-revision` overwrites silently
<a id="skill-no-versions"></a>
- `multica skill get <id> --output json`, edit that text, write it back with `multica skill update <id> --base-revision <revision from get>`. A conflict means someone saved since: get again and reapply. A skill with `config.origin` is changed only in its repository, then `multica skill refresh <id>`.

### `daemon-restart-retry` — `daemon restarted while task was in flight`
<a id="daemon-restart-retry"></a>
- The platform retries by itself (up to three attempts). Do nothing; not the agent's result, not for the scorecard. A series of failures within one minute across agents — see section B.

### `json-no-stderr-merge` — `2>&1` breaks `--output json` parsing
<a id="json-no-stderr-merge"></a>
- JSON goes to stdout, warnings to stderr. Do not merge streams when parsing; a parse failure after a successful write produces a duplicate on retry.

### `never-kill-multica-by-name` — a long-lived `multica` process is the daemon
<a id="never-kill-multica-by-name"></a>
- Daemon and CLI are one executable. `pkill multica` kills every run on the machine. Kill only the exact child PID after checking `multica daemon status --output json`.

## B. Runtimes and providers


### Failed-run analysis
Do not trust sub-issue status. Reconcile `multica agent tasks <agent-id> --output json` (failed + reason) with `multica agent list --output json` (agent status). Verdict: dead run / infrastructure / genuine zero. A dead run is never "found nothing". `in_progress` with an `idle` agent, or an empty answer at `status=ok`, is a dead run.

### Antigravity passes the whole catalog line into `--model`
`agy models` prints `id<TAB>Name`; the daemon passes the full line and `agy` fails with `invalid model selection`. Clear `model` on the agent and pass `--custom-args '["--model","gemini-3.1-pro-high"]'`. `agy -p --model <nonexistent>` silently falls back to the default — a successful run does not prove the requested model ran.

### Claude refusals on a brief and routing
Claude returns `API Error: safeguards flagged this message` before the model works when a brief reads as bypassing a safeguard, even one's own. Triggers: "get around the guard", "find a way out", "slip past the check", "check that the workaround breaks the build". Defensive framing helps unreliably.
Routing: demonstrating a violation → a non-Claude line; divergence from intent and completeness → Fable, worded as "coverage completeness".

### Parallel runs fight over the npm cache
Concurrent `npm ci` into shared `~/.npm` fails other runs with `EACCES ... rename ... _cacache`. Every executor brief: `npm ci --cache ./.npm-cache`.

### Fresh dependency in `main` reddens the gates on a stale tree
After a merge that added a dependency, a stale `node_modules` fails lint config itself (`TypeError: Cannot convert undefined or null to object`) and all gates go red at once. Read "all gates red, linter config failing" as stale tree, not broken work. Before accepting someone else's branch: `npm ci`, not `npm install`.

### Infrastructure failures in series
Failures across different agents within one minute (`runtime_recovery`, `provider_network`, `task cancelled by server`) are infrastructure, not briefs. Read `failure_reason`, not `error`. Do not fix with briefs or restart rounds by hand — escalate to the owner (`pm-workflow` `docs/ownership.md#escalation`).

## C. Moved to `pm-workflow` docs
- (agent, question) pair does not repeat two rounds in a row → `docs/review-cycle.md#panel`.
- Two PRs for one defect — technical verdict, not merging both → `docs/ownership.md#two-prs`.
- Escalation to the owner → `docs/ownership.md#escalation`.
- Exact-mutation rule (aim by line number, check `diff` after mutation) → `test-guard-discipline`.

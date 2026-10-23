---
name: agent-runtime-gotchas
description: Multica platform and provider workarounds for anyone assembling a round, standing at a barrier or reading someone else's run. Load when a card did not start, a barrier did not close, a run died, a barrier woke the PM twice, the model is in doubt, or a provider errored.
---

Workarounds only. Regulation (roles, barriers, score line, registry, round limits) is in the `pm-workflow` repository, `docs/`. For an executor inside its own run see `audit-run-hygiene`.

## A. Multica platform

### `mention-is-run` — a status change does not start a run, only a mention does
<a id="mention-is-run"></a>
- To resume a card: comment with `[@Name](mention://agent/<agent-id>)`, then set `todo`, then confirm via `multica agent tasks <agent-id> --output json` that a task with that `issue_id` is `running`/`pending`/`queued`/`claimed`. No task — mention again.
- Every mention is a paid run. Replies, thanks, FYI — without the link.

### `rerun-after-promote` — after `blocked`, `todo` and `backlog → todo` create no task
<a id="rerun-after-promote"></a>
- Use `multica issue rerun <issue-id>`; it creates and starts a task for the current assignment. Verify in `multica agent tasks`: no task newer than the promotion means no run.

### `in-review-not-terminal` — `in_review` does not close the stage barrier
<a id="in-review-not-terminal"></a>
- The barrier fires only on `done`/`cancelled` of all sub-issues; the runtime ends a run at `in_review` by default.
- Every sub-issue body must carry: "on completion run `multica issue status <id> done`; do NOT leave it `in_review`". The line lives in `templates/subtask.md` of `pm-workflow`, enforced by `scripts/check-rules.sh`. A sub-issue without it is not created.

### `parent-backlog-first` — a parent created outside `backlog` starts a second PM run
<a id="parent-backlog-first"></a>
- Order: parent with `--status backlog`; sub-issues (first `todo`, rest `backlog`); metadata; only then `in_progress`. Raising from `backlog` wakes the PM once — expected.

### `done-is-silent` — `done` is terminal and emits no events
<a id="done-is-silent"></a>
- Start the next card when the current one reaches `in_review`; name it in the acceptance comment. Do not wait for `done`.

### `cancel-does-not-stop` — `cancelled` and unassigning do not stop a run
<a id="cancel-does-not-stop"></a>
- A started run is stopped only in the UI; the CLI has no stop. A wasted run costs the same as a needed one — do not start what you may cancel.

### `barrier-by-status` — the barrier closes on statuses, not on reports
<a id="barrier-by-status"></a>
- At the barrier read the report, not the status. Reviewer dead, panel done — run a separate synthesis stage (`pm-workflow` `docs/pipeline.md#synthesis-stage`).

### `stage-wakeup-dies-at-done` — a sub-issue's wakeups are disabled at `done`
<a id="stage-wakeup-dies-at-done"></a>
- The executor sets `done` inside its own run, so `task.completed` on the sub-issue never fires.
- Primary barrier signal is a wakeup on the PARENT: `multica issue wakeup create <parent-id> --until-children-done --stage <N> --kind event --mode once --expires-in 24h --on-timeout wake` (one-shot: a barrier closes once). Set it at every promotion. Keep one daily backstop on the parent.

### `system-child-done-duplicate` — the platform's child-completion notification duplicates the explicit barrier wakeup
<a id="system-child-done-duplicate"></a>
- After the PM creates or promotes the next stage, the system notification wakes the PM again for the barrier already processed. Cause not established; hypothesis — its deduplication key lacks parent + stage + completion generation.
- Do not disable the system rule through the CLI (the owner manages it). Use a one-shot explicit wakeup (`--mode once`) and make the repeat cheap: the `last_barrier_stage` metadata check and the delta-only read (`pm-workflow` `docs/pipeline.md#barrier-dedup`, `#compact-wake-read`).

### `model-not-in-task` — the run model is not stored and not self-reportable
<a id="model-not-in-task"></a>
- The harness injects a product persona; task records and argv do not hold the model. Self-reports are unreliable.
- Only `multica runtime usage <runtime-id> --days 1 --output json` (one row per model) proves the model. Antigravity reports no usage at all. Without proof mark the scorecard row "model unverified".

### `skill-no-versions` — `multica skill update` overwrites without versions
<a id="skill-no-versions"></a>
- Run `multica skill get <id> --output json` IMMEDIATELY before `update`, edit that text, write exactly it back. Verify with a marker absent from the old edition.

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

### Limits and peak hours
- **Grok**: free `grok-4.6` limit is 500k tokens/day; a large-diff audit is ~525k — cannot finish one round. Key resolution order is `api_key` → `env_key` → session → `XAI_API_KEY`; to make the key win set `~/.grok/config.toml`: `[models."grok-4.6"] env_key = "XAI_API_KEY"`.
- **GLM (Z.AI)**: peak Mon–Fri 06:00–10:00 UTC, off-peak rate is 50%. Unpaid plan → `Insufficient balance or no resource package`; after payment a failed task does not restart itself — `multica issue rerun`.
- **DeepSeek**: peak 01:00–04:00 and 06:00–10:00 UTC, off-peak is half price.
- Do not assemble a round 06:00–10:00 UTC (peak for both DeepSeek and GLM).

### Claude refusals on a brief and routing
Claude returns `API Error: safeguards flagged this message` before the model works when a brief reads as bypassing a safeguard, even one's own. Triggers: "get around the guard", "find a way out", "slip past the check", "check that the workaround breaks the build". Defensive framing helps unreliably.
Routing: demonstrating a violation → GLM (`glm-5.3`) or DeepSeek Pro; divergence from intent and completeness → Fable, worded as "coverage completeness".

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

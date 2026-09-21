---
name: agent-runtime-gotchas
description: Runtime workarounds caught on live runs, each with a removal condition. A — the Multica platform (a mention = a run, in_review does not close the barrier, the parent in backlog, rerun after blocked, cancelled does not stop the run, the barrier by statuses, the model only from runtime usage, a skill without versions, the daemon restart, 2>&1 with JSON, never kill multica by name). B — runtimes and providers (Antigravity and the catalog line, the Grok/GLM/DeepSeek limits and peak hours, the Claude refusals on a brief and routing, the npm cache, a fresh dependency in main, infrastructure failures in series). The pipeline regulation is not here but in the pm-workflow repository (docs/).
---

Runtime and platform failures caught on live runs. Every item cost a run or a round. Only workarounds live here — the things you will have to remove when the platform or a provider changes; every item has a removal condition. The pipeline regulation (roles, barriers, the score line, the registry, round limits) lives in the `pm-workflow` repository, `docs/`; the PM receives it as the `pm-workflow` skill. You are analyzing someone else's run: assembling a round, standing at a barrier, accepting reports. For an executor inside his own run — `audit-run-hygiene`.

The source of this file is `pm-workflow/skills/agent-runtime-gotchas/SKILL.md`; edit only via a PR there, update with `multica skill refresh`. `multica skill update` is forbidden for this skill (see `skill-no-versions`).

## A. Multica platform workarounds

### A status change does not raise a run; only a mention does
<a id="mention-is-run"></a>

- Symptom: a card moved from `blocked`/`in_review` to `todo`, the executor unchanged — no task is created, the card sits in a working status without work; the stale watchdog sees it as "silent" with a lag of up to 85 minutes.
- Cause: a status change is a record, not a command; only a mention `[@Name](mention://agent/<agent-id>)` creates a run (and assigning a new executor).
- Workaround: in the comment that resumes work, mention the executor; then the `todo` status; then check `multica agent tasks <agent-id> --output json` — a task with that `issue_id` in `running`/`pending`/`queued`/`claimed`; if absent — mention again. The flip side: any mention of an agent is a paid run; a reply/thanks/FYI — without the link. Regulation — `pm-workflow` `docs/pipeline.md#resume-by-mention`, `#mention-policy`.
- Incident: G (see `docs/incidents.md#inc-g` in the `pm-workflow` repository).
- Removal condition: remove when moving a card to `todo` starts creating the executor's task without a mention; check — move a blocked `hygiene`-class card to `todo` without a mention and see the task in `multica agent tasks`.

### `in_review` does not close the stage barrier
<a id="in-review-not-terminal"></a>

- Symptom: the stage barrier does not close, the PM is not woken, the sub-issue sits in `in_review`.
- Cause: the runtime by default ends a run at `in_review`, and the barrier triggers only on `done`/`cancelled` of all sub-issues.
- Workaround: in the body of every sub-issue the line "on completion `multica issue status <id> done`, do not leave it `in_review`" (see `done-line-in-body`). Regulation — `pm-workflow` `docs/pipeline.md#barrier-terminal`.
- Incident: B (see `docs/incidents.md#inc-b` in the `pm-workflow` repository).
- Removal condition: remove when Multica starts closing the barrier on `in_review` or offers a terminal-status setting; check — a sub-issue completed in `in_review` wakes the parent (test on a `hygiene`-class card).

### A parent created not in `backlog` starts a second PM run
<a id="parent-backlog-first"></a>

- Symptom: two identical first stages from two PM runs, both worked for nothing.
- Cause: a card assigned to an agent in a status other than `backlog` starts a run immediately — before the sub-issues are created; the second run knows nothing about them and builds its own.
- Workaround: the parent — `--status backlog`; the sub-issues (the first `todo`, the rest `backlog`); the metadata; only then `in_progress`. Raising from `backlog` wakes the PM once more — normal. Regulation — `pm-workflow` `docs/pipeline.md#start-order`.
- Incident: B (see `docs/incidents.md#inc-b` in the `pm-workflow` repository).
- Removal condition: remove when creating a card with an executor stops starting a run before an explicit start (for example, a `--no-start` appears on `issue create`, tested on a parent with the PM); check — create the parent in `in_progress` and see one run, not two.

### The "→ done" line in the sub-issue body
<a id="done-line-in-body"></a>

- Symptom: a sub-issue without the `done` line is closed by the executor in `in_review` — the barrier stands (a consequence of `in-review-not-terminal`, a separate item for the sake of `grep`).
- Cause: an explicit instruction in the body overrides the runtime default; without it the executor follows the runtime brief and stops at `in_review`.
- Workaround: without the line "on completion set it to `done`: `multica issue status <id> done`; do NOT leave it `in_review`" a sub-issue is not created; the line is in the "Completion" block of the `templates/subtask.md` template of the `pm-workflow` repository, held by `scripts/check-rules.sh`.
- Incident: B (see `docs/incidents.md#inc-b` in the `pm-workflow` repository).
- Removal condition: remove together with `in-review-not-terminal`.

### `done` is terminal and emits no events
<a id="done-is-silent"></a>

- Symptom: the owner moved the parent `in_review → done`, the next card did not start; the pipeline idled until a manual question.
- Cause: `done` is a terminal status, nobody is subscribed to it.
- Workaround: raise the next card when the current one goes to `in_review`, do not wait for `done`; in the acceptance comment name what has already been started to follow. Regulation — `pm-workflow` `docs/pipeline.md#next-card-on-in-review`.
- Incident: L (see `docs/incidents.md#inc-l` in the `pm-workflow` repository).
- Removal condition: remove when Multica starts waking the PM or the next card on a parent's `done`; check — a `hygiene`-class parent with a continuation card in `backlog`, a `done` by the owner raises it.

### After `blocked` neither `todo` nor `backlog → todo` creates a task
<a id="rerun-after-promote"></a>

- Symptom: a card after `blocked` was moved to `todo` directly and via `backlog → todo` — no task was created, the stage hangs dead while the runtime is alive.
- Cause: a status change does not create a task for the current assignment (see `mention-is-run`).
- Workaround: `multica issue rerun <issue-id>` — creates and immediately starts a task for the current assignment. Verify the fact via `multica agent tasks <agent-id>`: no task newer than the promotion — no run, no matter how the status looks.
- Incident: F (see `docs/incidents.md#inc-f` in the `pm-workflow` repository), 2026-09-03.
- Removal condition: remove together with `mention-is-run`.

### `cancelled` and unassigning the executor do not stop the run
<a id="cancel-does-not-stop"></a>

- Symptom: the card is `cancelled`, the executor unassigned, the run keeps working and spending money; there is no stop command in the CLI.
- Cause: status and assignment are records; stopping a started task exists only in the interface.
- Workaround: stop a started run only in the UI; cheaper not to start — a wasted run costs as much as a needed one.
- Incident: K (see `docs/incidents.md#inc-k` in the `pm-workflow` repository).
- Removal condition: remove when the CLI gets a task stop (`multica agent tasks stop <id>` or `cancelled` starts stopping the run); check — `cancelled` on a card with a working run moves the task to `cancelled` in `multica agent tasks`.

### The barrier triggers on statuses, not on the presence of a report
<a id="barrier-by-status"></a>

- Symptom: the stage is closed, the auditor sub-issues have reports, the Reviewer stage has only "the panel has been sent out": no score line, no registry, no personal reproduction. The Reviewer run died separately from the panel (`idle_watchdog`, then `API Error: 529 Overloaded` three times in a row).
- Cause: the barrier closes on the terminal statuses of the sub-issues; the platform does not check the report content.
- Workaround: at the barrier read the report, not the status; with a dead Reviewer — a separate stage for synthesis only. The procedure — `pm-workflow` `docs/pipeline.md#synthesis-stage`.
- Incident: E (see `docs/incidents.md#inc-e` in the `pm-workflow` repository), reproduced twice.
- Removal condition: remove when the barrier can demand a report (for example, a mandatory result comment at `done`); check — a `done` without a comment does not close the barrier.

### The run model is not stored in the task and is undeterminable from inside
<a id="model-not-in-task"></a>

- Symptom: three auditors on `gpt-5.6-sol`, `-luna`, `-terra` gave two identical self-reports "GPT-5 (Codex)" and one accidental match with the default of `~/.codex/config.toml`. `gpt-5.6-luna` never appeared in the accounting at all with a completed sub-issue (1 min 51 s against the usual 26–36 min) — the override did not land.
- Cause: the harness substitutes a product persona into the system prompt; task records (`multica agent tasks`) do not store the model, it is not in argv (codex speaks through the app-server).
- Workaround: only `multica runtime usage <runtime-id> --days 1 --output json` — one row per model. Antigravity does not report the spend at all. In both cases mark the scorecard row unreliable as to model. Regulation — `pm-workflow` `docs/review-cycle.md#model-from-usage`.
- Incident: C (see `docs/incidents.md#inc-c` in the `pm-workflow` repository).
- Removal condition: remove when `multica agent tasks` starts storing the actual model of the run; check — the model field in the task matches the `runtime usage` row.

### `multica skill update` overwrites without versions or rollback
<a id="skill-no-versions"></a>

- Symptom: a run appended one fact, taking the base from a stale copy — a recomposition from the day before disappeared (1073 code points, two blocks, two section merges); noticed a day later by a manual reconciliation.
- Cause: skills have no versions; `update` overwrites the `content` in full; for a skill without `config.origin` a `refresh` returns 422.
- Workaround: the skills from `pm-workflow/skills/` are edited only via a PR to the repository and `multica skill refresh <id>`; `multica skill update` is forbidden for them. For the other skills — fetch the `content` via `multica skill get <id> --output json` IMMEDIATELY before the `update`, edit that text, and write back exactly it; hang the acceptance on a marker that is entirely absent from the old edition.
- Incident: D (see `docs/incidents.md#inc-d` in the `pm-workflow` repository), 2026-08-17 — no primary card.
- Removal condition: remove when skills get versions and rollback (`multica skill history`/`rollback`); check — roll back a wiped edit with a command.

### `daemon restarted while task was in flight` — the platform restarts on its own
<a id="daemon-restart-retry"></a>

- Symptom: the task hangs in `todo`, `failure_reason` says `daemon restarted while task was in flight`.
- Cause: a restart of the workspace daemon; the platform creates a retry task by itself (up to three attempts).
- Workaround: do nothing; it is not the agent's result and does not go into the scorecard. A series of failures within one minute across different agents — infrastructure (see section B).
- Incident: none — a measurement of 2026-08-16 (no primary card).
- Removal condition: remove when a daemon restart stops dropping tasks in flight; check — `multica daemon status` after the restart shows the same tasks `running`.

### `2>&1` when parsing `--output json` makes a successful write look like a failure
<a id="json-no-stderr-merge"></a>

- Symptom: a write command returned JSON in stdout and a warning in stderr; after `2>&1` the parser falls over, the run repeats the write — a duplicate.
- Cause: `--output json` writes JSON to stdout, confirmations and warnings go to stderr.
- Workaround: do not merge the streams when parsing JSON. A layer 0 duplicate: the same in the runtime brief ("Available Commands").
- Incident: none — a layer 0 duplicate.
- Removal condition: lift when the runtime brief changes (when the brief stops containing this rule or the CLI starts writing everything to stdout).

### A long-lived `multica` process is the workspace daemon
<a id="never-kill-multica-by-name"></a>

- Symptom: `pkill multica` to kill one's own hung child process killed the workspace daemon — every run on the machine fell.
- Cause: the daemon and the CLI are one executable.
- Workaround: stop only the exact child PID, after comparing it with `multica daemon status --output json`. A layer 0 duplicate: the same in the runtime brief ("Background Task Safety").
- Incident: none — a layer 0 duplicate.
- Removal condition: lift when the runtime brief changes.

## B. Runtimes and providers

The removal condition of every item is: re-verify no later than the named date; no confirmation — delete.

### Failed-run analysis

Do not trust the sub-issue status, reconcile two sources:

```
multica agent tasks <agent-id> --output json    # failed + the reason
multica agent list --output json                # the agent status
```

Verdict: a dead run / infrastructure / a genuine zero. Never count a dead one as "found nothing" (regulation — `pm-workflow` `docs/review-cycle.md#dead-run-zero`).

- A sub-issue `in_progress` with an `idle` agent — a failed run.
- An empty answer at `status=ok` is also a dead run.
- Removal condition: re-verify no later than 2026-12-17.

### Antigravity: the daemon does not cut the catalog line

`agy models` prints `id<TAB>Name`; the daemon compares and passes the whole line into `--model`:

```
agy exited with error: invalid model selection (--model "gemini-3.7-flash-medium\tGemini 3.7 Flash (Medium)")
```

Workaround: clear `model` on the agent, pass `--custom-args '["--model","gemini-3.1-pro-high"]'`. Verified.

`agy -p --model <nonexistent>` does not fall over — it silently falls back to the default. A successful run does not prove that the requested model did the work.

- Removal condition: re-verify no later than 2026-12-17 (an Antigravity catalog defect; after the daemon is fixed — delete).

### Limits and peak hours

- **Grok**: the free limit of `grok-4.6` is 500,000 tokens/day, an audit of a large diff is ~525,000: it cannot pull even one round. The CLI is authorized via OIDC; the resolution order is `api_key` → `env_key` → session → `XAI_API_KEY`, that is, the variable AFTER the session. For the key to win — `~/.grok/config.toml`: `[models."grok-4.6"] env_key = "XAI_API_KEY"`.
- **GLM (Z.AI)**: peak Mon–Fri 06:00–10:00 UTC. The window is about PRICE: off-peak the rate is 50%. An unpaid plan → `Insufficient balance or no resource package`; after payment activation takes a few minutes, a task that failed before it does not restart by itself — push it through `multica issue rerun` (see `rerun-after-promote`).
- **DeepSeek**: peak 01:00–04:00 and 06:00–10:00 UTC, off-peak is twice as cheap.
- **06:00–10:00 UTC is the peak for both DeepSeek and GLM** — do not assemble a round in this window.
- Removal condition: re-verify no later than 2026-12-17 (provider limits and windows change without notice).

### Claude refusals on a brief (safeguards) and routing

Claude fails on a brief that reads as a request to bypass a safeguard — even if the safeguard is one's own. The refusal arrives BEFORE the model works, rewording helps unreliably. Three runs in a row, different tasks:

```
Claude (Fable) → API Error: safeguards flagged this message (anthropic.com/legal/aup)
```

Triggers: "get around the guard", "find a way out", "check that the workaround breaks the build", "slip past the check".

A protective framing ("a defensive audit of one's own private repo, everything local on fixtures") worked on one run and failed on the next three — put it in the brief but do not rely on it.

Did not refuse on the same questions: **GLM** (`glm-5.3`) — 10 confirmed findings and 14 build-guard workarounds, **DeepSeek Pro**, **Luna**.

Routing: demonstrating a violation → GLM or DeepSeek Pro; divergence from intent and completeness → Fable. Word it "coverage completeness", not "get around the guards".

- Removal condition: re-verify no later than 2026-12-17.

### Parallel runs fight over the npm cache

A simultaneous `npm ci` into the shared `~/.npm` brings down other runs: `EACCES ... rename ... _cacache`. Into every executor's brief: `npm ci --cache ./.npm-cache`.

- Removal condition: re-verify no later than 2026-12-17.

### A fresh dependency in `main` — stale `node_modules` redden the gates past the code

After a merge of someone else's PR that added a dependency, a run on a stale tree falls before checking anything. A measurement of 2026-08-24: a PR added `globals@17`, the ESLint config reads `globals[set]` — on the old tree `TypeError: Cannot convert undefined or null to object`, and all four gates go red at once (`boundary`, `lint`, both passes, and the tests).

It looks like a stage failure and is not one. `npm ci` — and everything is green.

Rule: before accepting someone else's branch `npm ci`, not `npm install` on top. Four red gates at once, one of which is the linter config itself falling, read as "the tree is stale", not "the work is broken".

- Removal condition: re-verify no later than 2026-12-17.

### Infrastructure failures in series

On 2026-08-16 at 20:26 every auditor of the round fell at once (`runtime_recovery`) with the daemon alive and a large uptime — the application around it was restarting. The platform makes up to three attempts; on DeepSeek two burned for nothing (`opencode stream ended on an empty step` → `provider_network`, then `task cancelled by server`).

A series of failures within one minute across different agents — infrastructure, not briefs. Look at `failure_reason`, not `error`. Do not cure with briefs and do not restart rounds by hand — to the owner (`pm-workflow` `docs/ownership.md#escalation`).

- Removal condition: re-verify no later than 2026-12-17.

## C. What moved from this skill to layer 2

One pointer line per rule remains in the skill; the text is in the `pm-workflow` repository:

- An (agent, question) pair does not repeat two rounds in a row (owner decision 2026-08-18) → `docs/review-cycle.md#panel`.
- Two PRs for one defect — a technical verdict, not merging both → `docs/ownership.md#two-prs`.
- The stage closed, the panel worked, no report — a synthesis stage → `docs/pipeline.md#synthesis-stage` (the symptom — `barrier-by-status` above).
- Escalation to the owner (a series of failures, an unverifiable model, a lost skill content) → `docs/ownership.md#escalation`.
- The model from the card may not land → `docs/review-cycle.md#model-from-usage` (the workaround — `model-not-in-task` above).
- "A mutation must hit the exact block" (aim by the line number of the needed block, not by the constant name; check the `diff` after the mutation) → the `test-guard-discipline` skill. Move at the next consolidation: 2026-09-18 | pm-workflow, the regulation-extraction PR | the exact-mutation rule lived in the workarounds skill, where nobody looks for it | at the next consolidation of the private registry add it to `test-guard-discipline`, remove it from here.

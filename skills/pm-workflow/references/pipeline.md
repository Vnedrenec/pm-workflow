# Pipeline: start, barriers, stages, metadata

Rule address — `pipeline.md#<anchor>`. Multica statuses: `todo / in_progress / in_review / done / backlog / cancelled / blocked`. Project tracker statuses are layer 3.

## Pipeline start

### Start order — the parent in `backlog` `[review: PM @ parent creation]`
<a id="start-order"></a>

1. Parent — `--status backlog`.
2. Sub-issues: first stage `todo`, the rest `backlog`.
3. Metadata (`#metadata-keys`) and impact class (`impact-class.md#classify-first`).
4. `multica issue status <parent-id> in_progress`. This wakes the PM once — expected.

A parent created in any other status starts a second PM run that builds its own sub-issues.

```bash
multica issue create --title "..." --parent <id> --assignee <agent> --stage <N> --status todo
multica issue create --title "..." --parent <id> --assignee <agent> --stage <N+1> --status backlog
```

### First action on any wakeup — `multica issue children` `[review: PM @ wakeup]`
<a id="children-first"></a>

`multica issue children <parent-id>` before any decision. Never recreate an existing stage.

### First stage of a new repository — bootstrap `[review: PM @ stages creation]`
<a id="bootstrap"></a>

Stage 1 of a new repository: a task per the `project-bootstrap-checklist` skill. No code stage until it is closed.

## Barriers

### A stage barrier closes only on terminal statuses `[review: PM @ stage barrier]`
<a id="barrier-terminal"></a>

A barrier closes when ALL sub-issues of the stage are `done` or `cancelled`. `in_review` keeps it open and wakes nobody (`agent-runtime-gotchas#in-review-not-terminal`). Every sub-issue body carries the Completion block of `subtask.md` ("on completion run `multica issue status <id> done`; do not leave it `in_review`"); without it the sub-issue is not created. `done` on the parent — the owner only (`ownership.md#parent-done`).

### What to do at every barrier `[review: PM @ stage barrier]`
<a id="barrier-procedure"></a>

1. `multica issue children <parent-id>`.
2. Read the result comment of the closed stage, not the status (`agent-runtime-gotchas#barrier-by-status`). No report — `#synthesis-stage`.
3. Read the parent metadata (`#metadata-keys`).
4. Decide: no findings → next stage; findings below the class limit → rework stage, then a new review stage; limit reached → parent `blocked`, owner (`review-cycle.md#fuse`, `impact-class.md#limits-table`); scope change → owner regardless of the counter (`ownership.md#scope-change`).
5. Write the metadata, including `last_barrier_stage` (`#barrier-dedup`).
6. Promote: `multica issue status <child-id> todo`.

Before promotion read the sub-issue body: unmet dependencies or a contradiction with the parent layout — leave it in `backlog` and ask.

### Code / mechanics stage barrier — green CI on the PR head `[review: PM @ code stage barrier]`
<a id="code-barrier"></a>

The executor sets `done` only when `gh pr checks <pr>` on the head of the last commit is fully green; anything red — output into the report, sub-issue to `blocked`. Local runs do not count. The required-checks list is layer 3 (`.github/branch-protection.json`, project `AGENTS.md`). The PM does not run CI; the PM checks that the green output is for the right head.

### Synthesis stage — the panel worked, the Reviewer died `[review: PM @ audit stage barrier]`
<a id="synthesis-stage"></a>

Sign: auditor sub-issues have reports; the Reviewer stage has no score line, registry or personal reproduction. Create a separate synthesis-only stage with the line "do not repeat the audit, do not send the panel out" and the ids of the sub-issues that already worked. Do not merge on raw auditor findings: a round is root-cause stitching, personal reproduction of the blocking findings, and the score line (`review-cycle.md#score-line`).

### A stage closed through `cancelled` without a reason is not promoted `[review: PM @ stage barrier]`
<a id="cancelled-needs-reason"></a>

Establish the cause, then promote.

### Hand-off record and executor reconciliation `[review: PM @ promotion]`
<a id="handoff-record"></a>

Every hand-off — a comment on the stage card per `handoff-comment.md`. On every wakeup compare the executor of the closed stage with the one assigned at promotion: `assignee_changed` not by the PM is a role incident, analyzed the same day.

### Sequential acceptance: the next card only after the owner's `done` `[review: PM @ acceptance]`
<a id="next-card-on-in-review"></a>

Parent in `in_review` — promote nothing; the run may end with an empty conveyor. Before ending the run: `multica issue wakeup create <id> --event issue.status_changed --filter-actor-type member --filter-actor-id <owner>` (`done` emits no events). On the owner's `done`, if no parent is `in_progress` and the `in_review` queue is empty: next ready parent `backlog` → stage 1 `todo` → parent `in_progress`, verify the run started. Any other status — acceptance and review-cycle rules, no promotion.

## Stages and their bodies

### One review round = one sub-issue `[review: PM @ stage creation]`
<a id="one-round-one-subtask"></a>

Do not reuse a review task with repeated comments: the stage barrier fires once.

### Every sub-issue is self-sufficient `[review: PM @ promotion]`
<a id="self-sufficient-body"></a>

The executor sees neither the chat nor neighboring cards. Goal, inputs, expected result, readiness criteria — in the body; last round's findings as TEXT, not a link. Skeleton — `subtask.md`.

### Stage bodies are assembled from templates `[review: PM @ promotion]`
<a id="body-from-template"></a>

Audit stage: `review-report.md` in full after the line "Report format:". Code stage: the "Easy to break", "Result and acceptance", "Backup executor", "Report", "Completion" blocks of `subtask.md` verbatim (`#code-stage-body`). Specification stage: the line "Read: `pm-workflow` `docs/roles.md`, `templates/subtask.md`". Copy from `references/`, not from memory. The PM checks the required lines at promotion.

### The specification goes to audit BEFORE the executor `[review: PM @ stages creation]`
<a id="spec-audit-first"></a>

The specification audit stage precedes the code stage and does not replace the code review after the Builder.

### Round envelope — in the audit stage body BEFORE promotion `[review: PM @ audit stage promotion]`
<a id="audit-envelope"></a>

Auditor count, model families, ESC pool forbidden/allowed, the previous round's (agent, question) pair (`review-cycle.md#panel`) — in the body before promotion. Boilerplate or empty body — not promoted.

### A backup executor in every code stage body `[review: PM @ code stage promotion]`
<a id="backup-executor"></a>

A backup executor of another model family and the switch sign: `failure_reason` with a quota in `multica agent tasks <agent-id>`. Check `multica agent tasks`; do not wait.

### Composition of the code stage body `[review: PM @ code stage promotion]`
<a id="code-stage-body"></a>

Work boundaries; what is easy to break and why; link to the project run rules (layer 3, e.g. `docs/engineering/pm-workflow.md` §4); the line "verify mutations by running, not by prediction" (`#mutation-by-run`); the subagent prohibition (`#no-subagents`); the "Report" block of `subtask.md` verbatim (`#builder-report`). Any item missing — not promoted.

### No subagents on the code stage `[review: PM @ code stage barrier]`
<a id="no-subagents"></a>

One run, one agent: no subagents, the diff goes to no other model (`roles.md#author-not-verifier`). Report line `Subagents: none started`; without it, or with subagents mentioned — not accepted, `blocked` with a question to the PM.

### Verify mutations by running, not by prediction `[review: Reviewer @ code round]`
<a id="mutation-by-run"></a>

Every island case (one branch) is proven by a mutation: break the line under test → red → revert; command and output, not prediction. Name the invariant, demand proof by running. Techniques — `test-guard-discipline`.

### Code stage report — five sections `[review: PM @ code stage barrier]`
<a id="builder-report"></a>

First line `Subagents: none started`. Then five non-empty sections: (1) gates — command verbatim, passed/failed/`skipped` numbers, `skipped` = 0 or every skip with a reason; (2) island cases — case → mutation → run result; (3) decided differently from the specification, and why; (4) promised but not done; (5) own misses — empty is suspicious, the PM asks before promotion. A section missing — does not pass the barrier.

## Resume and mentions

### Resuming work — only by mentioning the executor `[review: PM @ resume comment]`
<a id="resume-by-mention"></a>

A status change starts no run (`agent-runtime-gotchas#mention-is-run`). Any resuming comment — unblocking, owner decision, rework, "continue" — mentions the executor `[@Name](mention://agent/<agent-id>)`. Order: (1) comment with the specification AND the mention; (2) `multica issue status <id> todo`; (3) `multica agent tasks <agent-id> --output json` shows a task with that `issue_id` in `running`/`pending`/`queued`/`claimed`; otherwise mention again. A question to the owner does not replace the executor mention — two addressees, two comments.

### A mention = a paid run `[review: PM @ comment]`
<a id="mention-policy"></a>

Mention only when a run is needed (`#resume-by-mention`, a new sub-issue). Reply, thanks, FYI, reference — no link. Never mention an agent that just finished: agent-to-agent loop. Silence ends a conversation.

### A blocked stage wakes the PM — the report mentions the PM by link `[review: PM @ stage barrier]`
<a id="blocked-mentions-pm"></a>

An executor who cannot continue: sub-issue `blocked` plus the report with a `mention://` link to the PM in the same comment. Plain text wakes nobody. A `blocked` report without the mention is a report defect: the PM raises it at the barrier, the executor records it in section 5. The line lives in the Report block of `subtask.md`.

### Stage-card wakeup — set at every promotion `[review: PM @ promotion]`
<a id="stage-wakeup"></a>

At every promotion: a continuous event wakeup on the stage sub-issue for `task.completed` and `task.failed` of the executor. The platform disables it at `done`/`cancelled`; from there the parent-side `children_done` wakeup carries the signal (`#barrier-wakeup`). Missing — a hand-off record defect (`#handoff-record`).

### `children_done` wakeup on the parent — the primary barrier signal, one-shot `[review: PM @ promotion]`
<a id="barrier-wakeup"></a>

At every promotion: `multica issue wakeup create <parent-id> --until-children-done --stage <N> --kind event --mode once --expires-in 24h --on-timeout wake`, with a self-sufficient instruction: layout check, report read, verdict per `#barrier-procedure`, and the same wakeup for the stage that run promotes. One-shot because a barrier closes once; a sub-issue added later to the next stage cannot re-fire it. `--mode continuous --max-fires N` only when the PM will add sub-issues to the SAME stage after promotion, reason in the hand-off record. `wakeup.timeout` after 24h: re-check the executor, re-arm a new one-shot wakeup. Missing — a hand-off record defect. One daily backstop on the parent (verify the chain, recreate a lost `children_done`, process an unattended barrier) is the net, not the signal; no periodic polling. An executor failure arrives via the stage-card `task.failed` wakeup (`#stage-wakeup`).

### A barrier already processed is a no-op wake; the system signal stays on `[review: PM @ wakeup]`
<a id="barrier-dedup"></a>

One barrier wakes the PM twice: the explicit `children_done` wakeup and the platform's child-completion notification, which the PM does not disable. Dedup by metadata: step 5 of `#barrier-procedure` writes `last_barrier_stage`. On any wake, after `#children-first`: no terminal stage above `last_barrier_stage`, the next stage already promoted, no sub-issue status change since — a repeat: one short reply ("barrier N already processed"), nothing created, promoted or re-read. A terminal stage above `last_barrier_stage`, a `wakeup.timeout` or a `task.failed` — a real event, `#barrier-procedure`. Dropping either source — an owner decision.

### A wake with a server-side unchanged/delta report — read only the delta `[review: PM @ wakeup]`
<a id="compact-wake-read"></a>

When the per-turn message says the server compared the issue against the last run (unchanged) or hands the comment delta as one `--since <anchor>` read: do not re-read the issue, the comment history, or reports processed at an earlier barrier (`last_barrier_stage`). Bounded reads only: `--compact`, `--roots-only --summary`, `--thread <id> --tail N`, `--since`; metadata from the issue record, not from comments. Still read: `#children-first` always; the report of the stage that just closed, in full. No server report — normal scan.

## Merge, git, PR

### One writing agent per tree `[review: PM @ code stage promotion]`
<a id="one-writer"></a>

One worktree per executor, branch off fresh `origin/main`. A second branch — `git worktree` into a session directory, never `git switch` in a shared tree. Do not rewrite someone else's branch history.

### Merge and report `[review: PM @ code stage barrier]`
<a id="merge-and-report"></a>

PR with the specification in the body; green gate → squash. Card comment from the fact of a run: commit, PR number, gate numbers, what the review rounds found, what the machine does not check. "It should work" is not a report. Project tracker statuses after merge — layer 3.

### The specification rides in the commit `[review: PM @ code stage barrier]`
<a id="spec-in-commit"></a>

Specification and code in one commit. Before acceptance check `git ls-files`.

### PR ↔ card link — the slug in the PR title; the card before the title `[review: PM @ code stage barrier]`
<a id="pr-slug"></a>

The card slug in the PR TITLE is the only link that survives squash. Create the card BEFORE the PR title; give the executor the real slug, never an invented number.

### Card comment — the same action as the owner report `[review: PM @ acceptance comment]`
<a id="comment-with-report"></a>

Write both in one action; otherwise the task hangs in `in_review` after the merge.

### Intent lives in git, state in the tracker `[review: PM @ card creation]`
<a id="intent-in-git"></a>

Plans, ADRs, checklists — files in the repository. Exception — the findings registry: a tracker card, overwritten round to round, id in parent metadata `findings_registry_issue` (`review-cycle.md#registry`). Status, executor, order — tracker only.

## Parent metadata

### Parent metadata keys `[review: PM @ stage barrier]`
<a id="metadata-keys"></a>

Read first, write last. Keys: `last_barrier_stage` (`#barrier-dedup`); `impact_class`; `review_rounds_spec` (closed specification rounds, `Stage: arch` counts); `review_rounds_code`; `last_round_findings` (confirmed findings of the last round); `converging` (`true` if findings fall round to round); `findings_registry_issue`; `owner_decision` (id of the decision comment); `repo`.

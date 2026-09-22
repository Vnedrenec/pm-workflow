# Pipeline: start, barriers, stages, metadata

Layer 2 of the workspace regulation. Rule format — `README.md`; rule address — `pipeline.md#<anchor>`. Sources of the text: the snapshot of the PM instructions as of 2026-09-18 (in the private archive) and the source-project file `docs/engineering/pm-workflow.md` §2.3–§2.8 (the common part; the project-specific part stayed in the project). The pipeline tracker is Multica: statuses `todo / in_progress / in_review / done / backlog / cancelled / blocked`. The project tracker and its statuses are layer 3, in the project file.

## Pipeline start

### Start order — the parent in `backlog` `[review: PM @ parent creation]`
<a id="start-order"></a>

A card assigned to an agent in a status other than `backlog` starts a run immediately. The parent is assigned to the PM — created straight in `in_progress`, it raises a second PM run that knows nothing about the sub-issues created right after it and builds its own. The order is strict:

1. The parent — `--status backlog`; no run starts.
2. Sub-issues: the first stage `todo`, the rest `backlog` (otherwise the whole chain starts at once).
3. The counter metadata (`#metadata-keys`) and the impact class (`impact-class.md#classify-first`).
4. Only now `multica issue status <parent-id> in_progress`.

Raising the parent from `backlog` wakes the PM once more — that is normal.

```bash
multica issue create --title "..." --parent <id> --assignee <agent> --stage <N> --status todo
multica issue create --title "..." --parent <id> --assignee <agent> --stage <N+1> --status backlog
```

Incident: [B](incidents.md#inc-b) — two identical first stages, both worked for nothing.

### First action on any wakeup — `multica issue children` `[review: PM @ wakeup]`
<a id="children-first"></a>

On any wakeup, the first thing is `multica issue children <parent-id>`: the layout first, then the decision. An existing stage is never recreated.

Incident: [B](incidents.md#inc-b).

### First stage of a new repository — bootstrap `[review: PM @ stages creation]`
<a id="bootstrap"></a>

The first stage of any new repository is a task per the checklist of the `project-bootstrap-checklist` skill (boundary gates with a mutation per rule, coverage thresholds and `skipped` in reports, the required checks contract, a registry of scanner exceptions, a database of its own for every agent, outbox as the first load-bearing block). The code stage is not promoted until bootstrap is closed.

Incident: none

## Barriers

### A stage barrier closes only on terminal statuses `[review: PM @ stage barrier]`
<a id="barrier-terminal"></a>

A stage barrier closes only when ALL its sub-issues are in a terminal status: `done` or `cancelled`. `in_review` is not terminal: the barrier stays open, nobody wakes the PM, the pipeline stands still (workaround — layer 1, `agent-runtime-gotchas#in-review-not-terminal`). Therefore the body of EVERY sub-issue carries the explicit line "on completion set it to `done`: `multica issue status <id> done`; do not leave it `in_review`" — without it the sub-issue is not created. Acceptance does not disappear — it moves from the sub-issue to the barrier: the PM reads the result on wakeup and decides whether it is accepted or another round is needed. `done` on the PARENT is still set only by the owner (`ownership.md#parent-done`).

Incident: [B](incidents.md#inc-b).

### What to do at every barrier `[review: PM @ stage barrier]`
<a id="barrier-procedure"></a>

1. `multica issue children <parent-id>` — the layout by stages.
2. Read the report of the stage that closed: not the status but the comment with the result. The barrier triggers on statuses, not on the presence of a report (`agent-runtime-gotchas#barrier-by-status`) — for a missing report with the stage closed see `#synthesis-stage`.
3. Read the parent metadata (`#metadata-keys`).
4. Decide: no findings → the next stage; findings and rounds below the class limit → a rework stage, followed by a new review stage; the round limit reached → **stop**, the parent to `blocked`, to the owner — what exactly fails to converge (`review-cycle.md#fuse`, `impact-class.md#limits-table`); a finding changes the scope → stop and a question to the owner regardless of the counter (`ownership.md#scope-change`).
5. Update the metadata.
6. Promote the next stage: `multica issue status <child-id> todo`.

Before the promotion read the sub-issue description: if its declared dependencies are not met or it contradicts the parent layout — leave it in `backlog` and ask, do not move it on schedule.

Incident: none

### The code / mechanics stage barrier — green CI on the PR head `[review: PM @ code stage barrier]`
<a id="code-barrier"></a>

The code / mechanics stage closes only on green CI on the PR head. The executor does not set `done` until `gh pr checks <pr>` on the head of his last commit is green as a whole; anything red — paste the output into the report and set the sub-issue to `blocked`. Local runs are for yourself; for the barrier — only CI. The required checks list is a contract in the project repository (layer 3: e.g. `.github/branch-protection.json`, the project `AGENTS.md`); the barrier is bound to it, not to the list in the brief. The PM does not check CI himself — he checks that the executor attached green output for the right head.

Incident: [H](incidents.md#inc-h) — owner decision 2026-09-14.

### The round synthesis stage — separate, when the panel worked and the Reviewer died `[review: PM @ audit stage barrier]`
<a id="synthesis-stage"></a>

The sign at the barrier: the stage is closed, the auditor sub-issues have reports, the Reviewer stage has only "the panel has been sent out": no score line, no registry, no personal reproduction. The cure is a separate stage for synthesis only, with the explicit line "do not repeat the audit, do not send the panel out" and the list of ids of the sub-issues that already worked; otherwise the Reviewer will assemble the panel anew and the workspace will pay for the same work a second time. Merging on "seven findings from three reports" without synthesis is not allowed: those are paragraphs of text, not a verified round — a round is distinguished by stitching along the root cause, personal reproduction of the blocking ones, and the score line (`review-cycle.md#score-line`).

Incident: [E](incidents.md#inc-e) — reproduced twice (specification round 3 and code round 1).

### A stage closed through `cancelled` without an explanation is not promoted `[review: PM @ stage barrier]`
<a id="cancelled-needs-reason"></a>

If the previous stage closed through `cancelled` without an explanation — establish the cause first, promote the next stage second.

Incident: none

### Hand-off record for a stage and executor reconciliation `[review: PM @ promotion]`
<a id="handoff-record"></a>

The PM records every stage hand-off with a comment on the stage card: who decided, why, to whom (template — `handoff-comment.md`). A hand-off without a record is an incident. On every wakeup the PM reconciles the executor of the stage that just closed with who was assigned at the promotion: a divergence (`assignee_changed` not from the PM) is a role incident with an analysis the same day, regardless of the quality of the result.

Incident: none

### Sequential acceptance: raise the next card only after the owner's `done` `[review: PM @ acceptance]`
<a id="next-card-on-in-review"></a>

Unaccepted parents must not stack (owner decision 2026-09-22, D-11 — rollback of raising the next card on `in_review`). When a parent goes to `in_review`, promote nothing; a run may end with an empty conveyor. `done` is terminal and emits no events, so before ending the run the PM leaves a wakeup on the parent — `multica issue wakeup create <id> --event issue.status_changed --filter-actor-type member --filter-actor-id <owner>` — and the owner's status change wakes the PM. On `done`: if no parent is `in_progress` and the `in_review` queue is empty, promote the next queue card (a ready parent from `backlog` → stage 1 `todo` → parent `in_progress`, verify the run started). On a status other than `done`: act by the acceptance and review-cycle rules, promote nothing.

Incident: [L](incidents.md#inc-l) — the idle that had motivated promoting on `in_review`; the owner's-`done` wakeup removes both the idle and the stacking of unaccepted cards.

## Stages and their bodies

### One review round = one sub-issue `[review: PM @ stage creation]`
<a id="one-round-one-subtask"></a>

Do not reuse a review task with repeated comments: the stage barrier triggers once, repeated comments will not wake the PM.

Incident: none

### Every sub-issue is self-sufficient `[review: PM @ promotion]`
<a id="self-sufficient-body"></a>

The executor sees neither the chat nor the neighboring cards: the goal, inputs, expected result, readiness criteria — in the body. Last round's findings are carried over AS TEXT, not as a link. The body skeleton is `subtask.md`.

Incident: none

### Stage bodies are assembled from templates `[review: PM @ promotion]`
<a id="body-from-template"></a>

The audit stage body contains `review-report.md` in full after the line "Report format:". The code stage body — the "Easy to break", "Result and acceptance", "Backup executor", "Report", "Completion" blocks from `subtask.md` verbatim (composition — `#code-stage-body`). The specification stage body — the line "Read: `pm-workflow` `docs/roles.md`, `templates/subtask.md`". The PM takes the text from the `references/` of his `pm-workflow` skill, not from memory. The template's required lines are held by `scripts/check-rules.sh`; the script does not see sub-issue bodies — the PM checks them at promotion, and so does the auditor of the next pipeline.

Incident: none

### The specification goes to audit BEFORE the executor `[review: PM @ stages creation]`
<a id="spec-audit-first"></a>

The specification audit stage comes before the code stage. An error in the specification multiplies into all the work; an error in the code is caught by review. The specification audit does not replace the code review after the Builder: mutations prove that the written cases know how to fail and stay silent about what the cases do not contain.

Incident: none

### The round envelope — in the audit stage body BEFORE promotion `[review: PM @ audit stage promotion]`
<a id="audit-envelope"></a>

The number of auditors, the model families, the ESC pool prohibition/permission, the previous round's (agent, question) pair (`review-cycle.md#panel`) are written into the audit stage body before promotion. A stage with a boilerplate or empty body is not promoted.

Incident: [J](incidents.md#inc-j) — an auditor assembled two security runs, including the escalation pool, on round 1 of the spec audit.

### A backup executor in the body of every code stage `[review: PM @ code stage promotion]`
<a id="backup-executor"></a>

The body of every code stage carries a backup executor of another model family and the switch sign: `failure_reason` with a quota in `multica agent tasks <agent-id>`. Check the limit via `multica agent tasks`, do not wait.

Incident: [M](incidents.md#inc-m) — `provider_quota_limit` in the middle of the day, the backup line lived only in the PM's head.

### Composition of the code stage body `[review: PM @ code stage promotion]`
<a id="code-stage-body"></a>

The code stage body must contain: the work boundaries; what is easy to break and why; a link to the project machine's run rules (layer 3, e.g. `docs/engineering/pm-workflow.md` §4 in the project repository); the line "verify mutations by running, not by prediction" (`#mutation-by-run`); the subagent prohibition (`#no-subagents`); the report format — the "Report" block from `subtask.md` verbatim (`#builder-report`). A body missing any item is not promoted.

Incident: none

### No subagents on the code stage `[review: PM @ code stage barrier]`
<a id="no-subagents"></a>

The code stage executor does not start subagents and does not send his diff to other models — one run, one agent (the author ≠ verifier principle, `roles.md#author-not-verifier`). The report must carry the line `Subagents: none started`; a report without it or with a line about subagents — the stage is not accepted, `blocked` with a question to the PM.

Incident: none

### Verify mutations by running, not by prediction `[review: Reviewer @ code round]`
<a id="mutation-by-run"></a>

Every island case (a case protecting one branch) is proven by a mutation: break the line under test → red → revert; the result — by command and output, not by the prediction "it will go red". Do not predict which case will go red: name the invariant and demand proof by running. Techniques — the `test-guard-discipline` skill.

Incident: [S](incidents.md#inc-s), [O](incidents.md#inc-o).

### The code stage report — five sections `[review: PM @ code stage barrier]`
<a id="builder-report"></a>

The first line — `Subagents: none started`. Then five sections, each non-empty: (1) gates — the command verbatim and the passed/failed/`skipped` numbers; `skipped` = 0, otherwise every skip with a reason; (2) island cases — case → mutation → run result; (3) where I decided differently from the specification, and why; (4) promised but not done; (5) own misses — an empty section is suspicious, the PM asks before the promotion. A report missing any section does not pass the barrier.

Incident: [P](incidents.md#inc-p), [Q](incidents.md#inc-q).

## Resume and mentions

### Resuming work — only by mentioning the executor `[review: PM @ resume comment]`
<a id="resume-by-mention"></a>

A status change is a record, not a command. Moving a card from `blocked` or `in_review` back to `todo`/`in_progress` does not raise a run if the executor did not change: no task is created, the card sits in a working status without work (workaround — `agent-runtime-gotchas#mention-is-run`). Therefore any comment that resumes work — unblocking, an owner decision, sending a round back for rework, any "continue" — must mention the executor `[@Name](mention://agent/<agent-id>)`. The order is strict: (1) a comment with the specification AND the mention; (2) `multica issue status <id> todo`; (3) verify the run started: `multica agent tasks <agent-id> --output json` contains a task with that `issue_id` in `running`/`pending`/`queued`/`claimed`; it did not start — mention again, do not wait. Asking the owner for a decision does not replace mentioning the executor — two addressees, two comments.

Incident: [G](incidents.md#inc-g) — owner decision 2026-09-08.

### A mention = a new run; mention only when a run is needed `[review: PM @ comment]`
<a id="mention-policy"></a>

`mention://agent/<id>` creates a paid run. Mention when a run is needed (`#resume-by-mention`, a new sub-issue to an agent); a reply, thanks, FYI, a reference to someone else's argument — without a mention link. Special case: do not mention an agent that just finished in your reply — it starts an agent-to-agent loop; silence ends the conversation. The same wording is in the layer 0 runtime brief ("Mentions").

Incident: none

## Merge, git, PR

### One writing agent per tree `[review: PM @ code stage promotion]`
<a id="one-writer"></a>

A separate worktree per executor, a branch off a fresh `origin/main`. Parallel writers in one tree produce false gate redness and edits in files they never touched. A second branch — `git worktree` into a session directory, not `git switch` in a shared tree: switching drags away someone else's HEAD. Do not rewrite someone else's branch history.

Incident: [R](incidents.md#inc-r) — someone else's uncommitted migration was almost carried away.

### Merge and report `[review: PM @ code stage barrier]`
<a id="merge-and-report"></a>

A PR with the specification in the body; after the green gate — squash. The comment to the card is written from the fact of a run: the commit, the PR number, the gate numbers, what the review rounds found, what the machine does not check. "It should work" is not a report. The project tracker statuses after the merge — layer 3.

Incident: none

### The specification rides in the commit `[review: PM @ code stage barrier]`
<a id="spec-in-commit"></a>

The specification lands in the same commit as the code: otherwise an external reviewer reads the code without the brief. Before acceptance check `git ls-files`, do not trust the executor's word: document edits in a shared tree after the commit to the branch are lost.

Incident: [X](incidents.md#inc-x).

### PR ↔ card link — the slug in the PR title; the card before the title `[review: PM @ code stage barrier]`
<a id="pr-slug"></a>

A PR is linked to a task in exactly one way: the card slug in the PR TITLE. The title becomes the subject of the squash commit and survives the merge; the PR body is not preserved at squash, a trailer in it gives no link. The slug is created by the card BEFORE the PR title: an invented number the tracker's auto-numbering will hand to someone else's work; when creating the task, give the executor the real slug.

Incident: [U](incidents.md#inc-u), [V](incidents.md#inc-v).

### The card comment — the same action as the owner report `[review: PM @ acceptance comment]`
<a id="comment-with-report"></a>

Otherwise the task hangs in `in_review` for a day after the merge.

Incident: [W](incidents.md#inc-w).

### Intent lives in git, state — in the tracker `[review: PM @ card creation]`
<a id="intent-in-git"></a>

Plans, ADRs, checklists — as files in the repository: executors without tracker access read them. The exception — the round's findings registry: its carrier is a separate registry card in the tracker, because the registry must be overwritten and its id sits in the parent metadata (`findings_registry_issue`, `review-cycle.md#registry`). Status, executor, order — only in the tracker: this class of facts rots in files, and stale files have already caused nonexistent work to be planned twice. Source — the source project's `AGENTS.md`, "Intent lives in git" (the old tracker card does not resolve).

Incident: none

## Parent metadata

### Parent metadata keys `[review: PM @ stage barrier]`
<a id="metadata-keys"></a>

The PM wakes at the barrier with no memory of past rounds: the parent metadata is read first and written last. Keys: `impact_class` — the impact class (`impact-class.md#classify-first`); `review_rounds_spec` — the number of closed specification review rounds (`Stage: arch` counts as a specification round); `review_rounds_code` — the same for code; `last_round_findings` — how many confirmed findings the last round produced; `converging` — `true` if the number of findings falls from round to round; `findings_registry_issue` — the registry card id; `owner_decision` — the id of the comment with the owner decision; `repo` — the card's repository. Without these keys there is nothing to count the round limit from.

Incident: none

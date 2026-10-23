# Pipeline: start, barriers, stages, metadata

Rule address — `pipeline.md#<anchor>`. The pipeline tracker is Multica: statuses `todo / in_progress / in_review / done / backlog / cancelled / blocked`. The project tracker and its statuses are layer 3, in the project file.

## Pipeline start

### Start order — the parent in `backlog` `[review: PM @ parent creation]`
<a id="start-order"></a>

A card assigned to an agent in a status other than `backlog` starts a run immediately; a parent created straight in `in_progress` raises a second PM run that builds its own sub-issues. Order:

1. Parent — `--status backlog`.
2. Sub-issues: first stage `todo`, the rest `backlog`.
3. Counter metadata (`#metadata-keys`) and impact class (`impact-class.md#classify-first`).
4. Only now `multica issue status <parent-id> in_progress`. Raising from `backlog` wakes the PM once — expected.

```bash
multica issue create --title "..." --parent <id> --assignee <agent> --stage <N> --status todo
multica issue create --title "..." --parent <id> --assignee <agent> --stage <N+1> --status backlog
```

### First action on any wakeup — `multica issue children` `[review: PM @ wakeup]`
<a id="children-first"></a>

On any wakeup, first `multica issue children <parent-id>`: the layout, then the decision. An existing stage is never recreated.

### First stage of a new repository — bootstrap `[review: PM @ stages creation]`
<a id="bootstrap"></a>

The first stage of any new repository is a task per the `project-bootstrap-checklist` skill. The code stage is not promoted until bootstrap is closed.

## Barriers

### A stage barrier closes only on terminal statuses `[review: PM @ stage barrier]`
<a id="barrier-terminal"></a>

A stage barrier closes only when ALL its sub-issues are `done` or `cancelled`. `in_review` is not terminal: the barrier stays open and nobody wakes the PM (`agent-runtime-gotchas#in-review-not-terminal`). The body of EVERY sub-issue carries the line "on completion set it to `done`: `multica issue status <id> done`; do not leave it `in_review`" — without it the sub-issue is not created. Acceptance moves from the sub-issue to the barrier: the PM reads the result on wakeup and decides. `done` on the PARENT is set only by the owner (`ownership.md#parent-done`).

### What to do at every barrier `[review: PM @ stage barrier]`
<a id="barrier-procedure"></a>

1. `multica issue children <parent-id>` — the layout by stages.
2. Read the report of the closed stage: the result comment, not the status. The barrier fires on statuses, not on reports (`agent-runtime-gotchas#barrier-by-status`); stage closed without a report — `#synthesis-stage`.
3. Read the parent metadata (`#metadata-keys`).
4. Decide: no findings → next stage; findings and rounds below the class limit → a rework stage, then a new review stage; round limit reached → **stop**, parent to `blocked`, to the owner with what fails to converge (`review-cycle.md#fuse`, `impact-class.md#limits-table`); a finding changes the scope → stop and ask the owner regardless of the counter (`ownership.md#scope-change`).
5. Update the metadata.
6. Promote the next stage: `multica issue status <child-id> todo`.

Before promotion read the sub-issue description: declared dependencies unmet or contradiction with the parent layout — leave it in `backlog` and ask.

### Code / mechanics stage barrier — green CI on the PR head `[review: PM @ code stage barrier]`
<a id="code-barrier"></a>

The code / mechanics stage closes only on green CI on the PR head. The executor does not set `done` until `gh pr checks <pr>` on the head of the last commit is green as a whole; anything red — paste the output into the report and set the sub-issue to `blocked`. Local runs are for yourself; for the barrier only CI. The required-checks list is a contract in the project repository (layer 3, e.g. `.github/branch-protection.json`, the project `AGENTS.md`). The PM does not run CI himself — he checks that the executor attached green output for the right head.

### Synthesis stage — the panel worked, the Reviewer died `[review: PM @ audit stage barrier]`
<a id="synthesis-stage"></a>

Sign: the stage is closed, auditor sub-issues have reports, the Reviewer stage has only "the panel has been sent out" — no score line, no registry, no personal reproduction. Cure: a separate stage for synthesis only, with the explicit line "do not repeat the audit, do not send the panel out" and the ids of the sub-issues that already worked; otherwise the Reviewer assembles the panel anew and the work is paid twice. Merging on "seven findings from three reports" without synthesis is not allowed: a round is stitching along the root cause, personal reproduction of the blocking ones, and the score line (`review-cycle.md#score-line`).

### A stage closed through `cancelled` without a reason is not promoted `[review: PM @ stage barrier]`
<a id="cancelled-needs-reason"></a>

Establish the cause first, promote second.

### Hand-off record and executor reconciliation `[review: PM @ promotion]`
<a id="handoff-record"></a>

The PM records every stage hand-off with a comment on the stage card: who decided, why, to whom (`handoff-comment.md`). A hand-off without a record is an incident. On every wakeup the PM reconciles the executor of the closed stage with who was assigned at promotion: `assignee_changed` not by the PM is a role incident analyzed the same day, regardless of result quality.

### Sequential acceptance: the next card only after the owner's `done` `[review: PM @ acceptance]`
<a id="next-card-on-in-review"></a>

Unaccepted parents do not stack. When a parent goes to `in_review`, promote nothing; a run may end with an empty conveyor. `done` emits no events, so before ending the run the PM leaves a wakeup on the parent — `multica issue wakeup create <id> --event issue.status_changed --filter-actor-type member --filter-actor-id <owner>`. On the owner's `done`: if no parent is `in_progress` and the `in_review` queue is empty, promote the next queue card (ready parent from `backlog` → stage 1 `todo` → parent `in_progress`, verify the run started). On any other status: act by the acceptance and review-cycle rules, promote nothing.

## Stages and their bodies

### One review round = one sub-issue `[review: PM @ stage creation]`
<a id="one-round-one-subtask"></a>

Do not reuse a review task with repeated comments: the stage barrier fires once.

### Every sub-issue is self-sufficient `[review: PM @ promotion]`
<a id="self-sufficient-body"></a>

The executor sees neither the chat nor neighboring cards: goal, inputs, expected result, readiness criteria — in the body. Last round's findings are carried over AS TEXT, not as a link. Skeleton — `subtask.md`.

### Stage bodies are assembled from templates `[review: PM @ promotion]`
<a id="body-from-template"></a>

Audit stage body: `review-report.md` in full after the line "Report format:". Code stage body: the "Easy to break", "Result and acceptance", "Backup executor", "Report", "Completion" blocks from `subtask.md` verbatim (`#code-stage-body`). Specification stage body: the line "Read: `pm-workflow` `docs/roles.md`, `templates/subtask.md`". Take the text from `references/`, not from memory. The PM checks the required lines at promotion; so does the auditor of the next pipeline.

### The specification goes to audit BEFORE the executor `[review: PM @ stages creation]`
<a id="spec-audit-first"></a>

The specification audit stage comes before the code stage. It does not replace the code review after the Builder.

### Round envelope — in the audit stage body BEFORE promotion `[review: PM @ audit stage promotion]`
<a id="audit-envelope"></a>

The number of auditors, model families, ESC pool prohibition/permission, the previous round's (agent, question) pair (`review-cycle.md#panel`) are written into the audit stage body before promotion. A stage with a boilerplate or empty body is not promoted.

### A backup executor in every code stage body `[review: PM @ code stage promotion]`
<a id="backup-executor"></a>

Every code stage body carries a backup executor of another model family and the switch sign: `failure_reason` with a quota in `multica agent tasks <agent-id>`. Check the limit via `multica agent tasks`, do not wait.

### Composition of the code stage body `[review: PM @ code stage promotion]`
<a id="code-stage-body"></a>

Must contain: work boundaries; what is easy to break and why; a link to the project machine's run rules (layer 3, e.g. `docs/engineering/pm-workflow.md` §4); the line "verify mutations by running, not by prediction" (`#mutation-by-run`); the subagent prohibition (`#no-subagents`); the "Report" block from `subtask.md` verbatim (`#builder-report`). Missing any item — not promoted.

### No subagents on the code stage `[review: PM @ code stage barrier]`
<a id="no-subagents"></a>

The code stage executor starts no subagents and sends his diff to no other model — one run, one agent (`roles.md#author-not-verifier`). The report carries the line `Subagents: none started`; without it or with a line about subagents — not accepted, `blocked` with a question to the PM.

### Verify mutations by running, not by prediction `[review: Reviewer @ code round]`
<a id="mutation-by-run"></a>

Every island case (one branch) is proven by a mutation: break the line under test → red → revert; result by command and output, not by prediction. Name the invariant and demand proof by running. Techniques — the `test-guard-discipline` skill.

### Code stage report — five sections `[review: PM @ code stage barrier]`
<a id="builder-report"></a>

First line `Subagents: none started`. Then five non-empty sections: (1) gates — the command verbatim and passed/failed/`skipped` numbers; `skipped` = 0, otherwise every skip with a reason; (2) island cases — case → mutation → run result; (3) where I decided differently from the specification, and why; (4) promised but not done; (5) own misses — an empty section is suspicious, the PM asks before promotion. Missing a section — does not pass the barrier.

## Resume and mentions

### Resuming work — only by mentioning the executor `[review: PM @ resume comment]`
<a id="resume-by-mention"></a>

A status change is a record, not a command: moving a card from `blocked` or `in_review` back to `todo`/`in_progress` with the same executor starts no run (`agent-runtime-gotchas#mention-is-run`). Any comment that resumes work — unblocking, an owner decision, rework, "continue" — mentions the executor `[@Name](mention://agent/<agent-id>)`. Order: (1) comment with the specification AND the mention; (2) `multica issue status <id> todo`; (3) verify: `multica agent tasks <agent-id> --output json` has a task with that `issue_id` in `running`/`pending`/`queued`/`claimed`; not started — mention again. Asking the owner does not replace mentioning the executor — two addressees, two comments.

### A mention = a paid run `[review: PM @ comment]`
<a id="mention-policy"></a>

Mention when a run is needed (`#resume-by-mention`, a new sub-issue). A reply, thanks, FYI, a reference — without the link. Do not mention an agent that just finished in your reply — it starts an agent-to-agent loop; silence ends the conversation.

### A blocked stage wakes the PM — the report mentions the PM by link `[review: PM @ stage barrier]`
<a id="blocked-mentions-pm"></a>

An executor who cannot continue sets the sub-issue to `blocked` and posts the report with a `mention://` link to the PM in the same comment; a plain-text question wakes nobody. A `blocked` report without a PM mention is a report defect: the PM raises it at the barrier, the miss goes into section 5 of the executor's report. The line lives in the Report block of `subtask.md`.

### Stage-card wakeup — set at every promotion `[review: PM @ promotion]`
<a id="stage-wakeup"></a>

With every promotion the PM sets a continuous event wakeup on the stage sub-issue for `task.completed` and `task.failed` of the executor. It is disabled when the sub-issue reaches `done`/`cancelled`; at that moment the signal passes to the parent-side `children_done` wakeup (`#barrier-wakeup`). A promotion without it is a hand-off record defect (`#handoff-record`).

### `children_done` wakeup on the parent — the primary barrier signal `[review: PM @ promotion]`
<a id="barrier-wakeup"></a>

With every promotion the PM sets `multica issue wakeup create <parent-id> --until-children-done --stage <N> --kind event --mode continuous --expires-in 24h --on-timeout wake` with a self-sufficient barrier instruction: layout check, report read, verdict by `#barrier-procedure`, and the chain rule — the same wakeup for the stage this run promotes. The platform disables sub-issue wakeups at `done`, so the parent-side wakeup is the primary signal. `--expires-in 24h --on-timeout wake` wakes the PM once (`wakeup.timeout`) when a stage has not closed in a day — re-check the executor, re-arm. A promotion without it is a hand-off record defect. A single daily backstop on the parent (verify the chain, recreate a lost `children_done`, process an unattended barrier) is the catastrophe net, not the primary signal; no periodic polling.

## Merge, git, PR

### One writing agent per tree `[review: PM @ code stage promotion]`
<a id="one-writer"></a>

A separate worktree per executor, a branch off fresh `origin/main`. A second branch — `git worktree` into a session directory, not `git switch` in a shared tree: switching drags away someone else's HEAD. Do not rewrite someone else's branch history.

### Merge and report `[review: PM @ code stage barrier]`
<a id="merge-and-report"></a>

A PR with the specification in the body; after the green gate — squash. The card comment is written from the fact of a run: commit, PR number, gate numbers, what the review rounds found, what the machine does not check. "It should work" is not a report. Project tracker statuses after merge — layer 3.

### The specification rides in the commit `[review: PM @ code stage barrier]`
<a id="spec-in-commit"></a>

The specification lands in the same commit as the code. Before acceptance check `git ls-files`; document edits in a shared tree after the commit are lost.

### PR ↔ card link — the slug in the PR title; the card before the title `[review: PM @ code stage barrier]`
<a id="pr-slug"></a>

The card slug in the PR TITLE is the only link: the title becomes the squash commit subject; the body is not preserved. Create the card BEFORE the PR title — an invented number goes to someone else's work; give the executor the real slug.

### Card comment — the same action as the owner report `[review: PM @ acceptance comment]`
<a id="comment-with-report"></a>

Otherwise the task hangs in `in_review` after the merge.

### Intent lives in git, state in the tracker `[review: PM @ card creation]`
<a id="intent-in-git"></a>

Plans, ADRs, checklists — files in the repository: executors without tracker access read them. Exception — the findings registry: a separate registry card in the tracker, overwritten round to round, id in the parent metadata (`findings_registry_issue`, `review-cycle.md#registry`). Status, executor, order — only in the tracker; this class of facts rots in files.

## Parent metadata

### Parent metadata keys `[review: PM @ stage barrier]`
<a id="metadata-keys"></a>

The PM wakes at the barrier with no memory of past rounds: metadata is read first and written last. Keys: `impact_class`; `review_rounds_spec` — closed specification review rounds (`Stage: arch` counts); `review_rounds_code`; `last_round_findings` — confirmed findings of the last round; `converging` — `true` if findings fall round to round; `findings_registry_issue` — registry card id; `owner_decision` — id of the owner decision comment; `repo` — the card's repository.

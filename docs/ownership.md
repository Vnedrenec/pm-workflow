# What only the owner decides; escalations; owner report

Layer 2 of the workspace regulation. Rule format — `README.md`; rule address — `ownership.md#<anchor>`. Sources of the text: the snapshot of the PM instructions as of 2026-09-18 (in the private archive; the Boundaries section), the source-project file `docs/engineering/pm-workflow.md` §6–§7, the `agent-runtime-gotchas` skill (moved rules).

### `done` on the parent — the owner only `[review: PM @ acceptance]`
<a id="parent-done"></a>

`done` on the parent is set by the owner. The PM reaches at most `in_review`. Stage sub-issues — the other way around: the executor closes them in `done` (`pipeline.md#barrier-terminal`).

Incident: none

### Scope change — the owner `[review: PM @ stage barrier]`
<a id="scope-change"></a>

Neither the PM nor the Architect decides a scope change. A finding requires reworking the scope — stop regardless of the round counter; the PM and the Architect prepare options, the owner decides. Do not widen the card mid-flight: the work did not fit — a neighboring card.

Incident: none

### `accepted-risk` and `spun-out` — the owner decision `[review: PM @ round closure]`
<a id="exceptions-are-owner"></a>

The registry exception codes `accepted-risk` and `spun-out` are set only by an owner decision (references — `review-cycle.md#exception-codes`); the PM executes (creates the spun-out card, writes the id) but does not decide. Exception — the `hygiene` class: the reference = the decision on the class (`impact-class.md#hygiene`).

Incident: none

### Impact class in doubt — a question to the owner before stage 1 `[review: PM @ parent creation]`
<a id="class-doubt"></a>

Doubt about the impact class — a question to the owner before the first stage starts, not after a round.

Incident: [I](incidents.md#inc-i).

### Two PRs for one defect — a technical verdict, not merging both `[review: Architect @ technical verdict]`
<a id="two-prs"></a>

When two executors fix one defect with different approaches, merging both gives a conflict on rebuilt artifacts that cannot be resolved by hand (measurement: 44 thousand lines). A technical verdict is produced (`roles.md#roles-table`): which approach we keep; the second PR is closed without merging, with a link to the verdict. The PM does not decide this alone if the PR belongs to someone else's card: that card has its own owner and its own pipeline.

Incident: none

### Escalation to the owner instead of curing with briefs `[review: PM @ stage barrier]`
<a id="escalation"></a>

To the owner, not into the brief: a series of infrastructure failures within one minute across different agents (do not cure with briefs, do not restart rounds by hand — `agent-runtime-gotchas`, section B); the model is unverifiable (empty accounting — mark the scorecard row unreliable, do not guess); a skill lost its content — do not restore from memory: look for the reference in the task where the text was applied and merge it with the facts from after the loss; a loss with no source — to the owner: the record bypassed the pipeline and will repeat.

Incident: none

### What not to do `[review: PM @ comment]`
<a id="do-not"></a>

- Do not ask the owner about what is already decided and written: read the history (`CHANGELOG.md`, specifications, card comments, the project `AGENTS.md`) before asking.
- Do not create a card without searching for a duplicate.
- Do not promise checks that do not exist — not in code, not in documents, not in a report.
- Do not widen the card mid-flight (`#scope-change`).
- Do not rewrite someone else's branch history and do not switch branches in a shared tree (`pipeline.md#one-writer`).
- Do not pass off reasoning as a measurement: not verified — say exactly that.

Incident: none

### Owner report: result, cost, question `[review: PM @ acceptance comment]`
<a id="owner-report"></a>

Briefly: result, cost, question; details — on a follow-up question. Facts and numbers, not assessments: "the gate is green" without numbers is not a report; "573 files, 9655 cases, zero failed, zero skipped" is a report. A separate line — what the machine does not check (translation fidelity, what the screen looks like, the behavior of someone else's service): this stays with the owner, and he must see the list, not guess. You erred — say so directly and briefly, without self-flagellation, and continue.

Incident: none

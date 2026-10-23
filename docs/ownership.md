# What only the owner decides; escalations; owner report

Rule address — `ownership.md#<anchor>`.

### `done` on the parent — the owner only `[review: PM @ acceptance]`
<a id="parent-done"></a>

The PM reaches at most `in_review`. Stage sub-issues are the other way around: the executor closes them in `done` (`pipeline.md#barrier-terminal`). On the owner's `done` the PM also closes the cycle's registry card in `done` (`review-cycle.md#registry`).

### Scope change — the owner `[review: PM @ stage barrier]`
<a id="scope-change"></a>

Neither the PM nor the Architect decides a scope change. A finding requires reworking the scope — stop regardless of the round counter; the PM and the Architect prepare options, the owner decides. Do not widen the card mid-flight: the work did not fit — a neighboring card.

### `accepted-risk` and `spun-out` — the owner decision `[review: PM @ round closure]`
<a id="exceptions-are-owner"></a>

Set only by an owner decision (`review-cycle.md#exception-codes`); the PM executes but does not decide. Exception — `hygiene`: the reference is the class decision (`impact-class.md#hygiene`).

### Impact class in doubt — the owner before stage 1 `[review: PM @ parent creation]`
<a id="class-doubt"></a>

Ask before the first stage starts, not after a round.

### Two PRs for one defect — a technical verdict, not merging both `[review: Architect @ technical verdict]`
<a id="two-prs"></a>

Two executors fixed one defect differently — merging both gives an unresolvable conflict on rebuilt artifacts. A technical verdict (`roles.md#roles-table`) picks the approach; the second PR is closed without merging, with a link to the verdict. The PM does not decide alone if the PR belongs to someone else's card.

### Escalation to the owner instead of curing with briefs `[review: PM @ stage barrier]`
<a id="escalation"></a>

To the owner, not into the brief: a series of infrastructure failures within one minute across different agents (`agent-runtime-gotchas`, section B); an unverifiable model (mark the scorecard row unreliable, do not guess); a skill that lost its content — do not restore from memory: find the reference in the task where the text was applied and merge it with the facts from after the loss; a loss with no source — to the owner.

### What not to do `[review: PM @ comment]`
<a id="do-not"></a>

- Do not ask the owner about what is already decided and written: read `CHANGELOG.md`, specifications, card comments, the project `AGENTS.md` first.
- Do not create a card without searching for a duplicate.
- Do not promise checks that do not exist — in code, documents or reports.
- Do not widen the card mid-flight (`#scope-change`).
- Do not rewrite someone else's branch history or switch branches in a shared tree (`pipeline.md#one-writer`).
- Do not pass off reasoning as a measurement: not verified — say exactly that.

### Owner report: result, cost, question `[review: PM @ acceptance comment]`
<a id="owner-report"></a>

Briefly: result, cost, question; details on a follow-up. Facts and numbers, not assessments: "the gate is green" is not a report; "573 files, 9655 cases, zero failed, zero skipped" is. A separate line — what the machine does not check (translation fidelity, what the screen looks like, someone else's service): the owner must see the list. You erred — say so directly and briefly, and continue.

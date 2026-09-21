<!-- Sub-issue body template. Blocks marked "code stage / audit stage only" are pasted into that stage's body VERBATIM (pipeline.md#body-from-template). Required lines are held by scripts/check-rules.sh against the list scripts/required-lines/subtask.txt. -->

## Pipeline
Impact class: `<impact_class>` · Parent: <KEY-N> · Stage: <N> · PR slug: `<KEY-N>`
<!-- impact-class.md#classify-first -->

## Goal
<one phrase>

## Inputs
<repositories with `multica repo checkout …` commands; files; ids of cards whose findings are carried over AS TEXT below>

## What to do
<steps>

## What is not done
<…>

## Easy to break              <!-- code stage only; pipeline.md#code-stage-body -->
<what and why; the project machine's run rules — a link to the project file, e.g. `docs/engineering/pm-workflow.md` §4 in the project repository>

## Result and acceptance
<what the next barrier checks; for the code stage — "green `gh pr checks <pr>` on the head of the last commit, output attached">
<!-- pipeline.md#code-barrier -->

## Backup executor            <!-- code stage only; pipeline.md#backup-executor -->
<an agent of another model family>; the switch sign — `failure_reason` with a quota in `multica agent tasks`.

## Report                            <!-- code stage only; pipeline.md#builder-report -->
Do not start subagents; do not send the diff to other models. First line of the report: `Subagents: none started`.
<!-- pipeline.md#no-subagents -->
Verify mutations by running, not by prediction: each case — command and output.
<!-- pipeline.md#mutation-by-run -->
Five sections, each non-empty; without any of them the stage does not pass the barrier:
1. Gates: the command verbatim, the passed/failed/skipped numbers; `skipped` = 0, otherwise every skip with a reason.
2. Island cases: case → mutation → run result.
3. Where I decided differently from the specification, and why.
4. What was promised but not done.
5. Own misses. A report without misses is suspicious.

## Round envelope                    <!-- audit stage only; pipeline.md#audit-envelope -->
Auditors: <N> · Families: <…> · ESC pool: forbidden/allowed · Previous round's (agent, question) pair: <…> — do not repeat.

## Completion
On completion set this sub-issue to `done`: `multica issue status <id> done`. Do NOT leave it `in_review` — the stage will not close.
<!-- layer 1: agent-runtime-gotchas#done-line-in-body -->

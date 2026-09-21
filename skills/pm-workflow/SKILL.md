---
name: pm-workflow
description: Load on every run on a parent card and at a barrier — the start order, barriers, the score line, the registry and exception codes, the round limit per class, the sub-issue body templates. The workspace pipeline regulation (layer 2); references/ is the assembled copy of docs/ and templates/ of the pm-workflow repository.
---

Read the pipeline regulation from here, not from memory. `references/` is a copy of `docs/`, `templates/` and `scripts/parse-score-line.sh` from the `pm-workflow` repository (revision — `CHANGELOG.md` as of 2026-09-18; assembled by `scripts/build-skills.sh`, identity held by CI). Edit only in the repository's `docs/` via a PR; after merge the skill is updated by `multica skill refresh`. A rule address is `<file>#<anchor>`; an incident — `references/incidents.md#<anchor>`.

| Situation | Read |
|---|---|
| New parent card: class, start order, metadata | `references/impact-class.md` (`#classify-first`), `references/pipeline.md` (`#start-order`, `#metadata-keys`) |
| Any wakeup | `references/pipeline.md#children-first`, then `#barrier-procedure` |
| Creating a stage: roles, who the executor is, conflict of interest | `references/roles.md` |
| Sub-issue body (any stage) | `references/subtask.md` — paste the blocks verbatim (`references/pipeline.md#body-from-template`, `#self-sufficient-body`) |
| Code stage body | `references/pipeline.md`: `#code-stage-body`, `#no-subagents`, `#mutation-by-run`, `#builder-report`, `#backup-executor`, `#one-writer` |
| Audit stage body: envelope, panel | `references/pipeline.md#audit-envelope`, `references/review-cycle.md` (`#panel`, `#one-per-family`), the report format — `references/review-report.md` in full |
| The Reviewer report arrived: score line | `bash references/parse-score-line.sh "<first line>"`; the format — `references/review-cycle.md#score-line`; `Scorecard:` — `#scorecard` |
| Close the cycle or continue | `references/review-cycle.md`: `#closure`, `#registry`, `#exception-codes`, `#closure-comment`, `#dead-run-zero`, `#fuse` |
| How many rounds are allowed | `references/impact-class.md` (`#limits-table`, `#hygiene`, `#money-arch-auditor`) |
| The stage closed, no Reviewer report | `references/pipeline.md#synthesis-stage` |
| Code stage barrier: CI, merge, report | `references/pipeline.md`: `#code-barrier`, `#merge-and-report`, `#spec-in-commit`, `#pr-slug`, `#comment-with-report` |
| Stage promotion: the hand-off record | `references/handoff-comment.md`; `references/pipeline.md#handoff-record` |
| Resume after `blocked`/an owner decision | `references/pipeline.md#resume-by-mention`, `#mention-policy` |
| The parent went to `in_review`; the next card | `references/pipeline.md#next-card-on-in-review`; `references/ownership.md#parent-done` |
| What only the owner decides; scope; exceptions; the owner report | `references/ownership.md` |
| An incident by letter (`inc-<letter>`: symptom, consequence, rules) | `references/incidents.md` |
| Runtime workarounds (a mention = a run, rerun, cancelled, the model) | the `agent-runtime-gotchas` skill |

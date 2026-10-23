---
name: pm-workflow
description: Load on every run on a parent card and at a barrier. Start order, barriers, wakeups, score line, findings registry and exception codes, round limits per class, sub-issue body templates.
---

Read the regulation from `references/`, not from memory. A rule address is `<file>#<anchor>`.

| Situation | Read |
|---|---|
| New parent card: class, start order, metadata | `references/impact-class.md` (`#classify-first`), `references/pipeline.md` (`#start-order`, `#metadata-keys`) |
| Any wakeup | `references/pipeline.md#children-first`, `#compact-wake-read`, `#barrier-dedup`, then `#barrier-procedure` |
| Creating a stage: roles, executor, conflict of interest | `references/roles.md` |
| Sub-issue body (any stage) | `references/subtask.md` — paste the blocks verbatim (`references/pipeline.md#body-from-template`, `#self-sufficient-body`) |
| Code stage body | `references/pipeline.md`: `#code-stage-body`, `#no-subagents`, `#mutation-by-run`, `#builder-report`, `#backup-executor`, `#one-writer` |
| Audit stage body: envelope, panel | `references/pipeline.md#audit-envelope`, `references/review-cycle.md` (`#panel`, `#one-per-family`); report format — `references/review-report.md` in full |
| Reviewer report arrived: score line | `bash references/parse-score-line.sh "<first line>"`; format — `references/review-cycle.md#score-line`; `Scorecard:` — `#scorecard` |
| Close the cycle or continue | `references/review-cycle.md`: `#closure`, `#registry`, `#exception-codes`, `#closure-comment`, `#dead-run-zero`, `#fuse` |
| How many rounds are allowed | `references/impact-class.md` (`#limits-table`, `#hygiene`, `#money-arch-auditor`) |
| Stage closed, no Reviewer report | `references/pipeline.md#synthesis-stage` |
| Code stage barrier: CI, merge, report | `references/pipeline.md`: `#code-barrier`, `#merge-and-report`, `#spec-in-commit`, `#pr-slug`, `#comment-with-report` |
| Stage promotion: hand-off record, wakeups | `references/handoff-comment.md`; `references/pipeline.md#handoff-record`, `#stage-wakeup`, `#barrier-wakeup` |
| Resume after `blocked` / an owner decision | `references/pipeline.md#resume-by-mention`, `#mention-policy` |
| Parent went to `in_review`; the next card | `references/pipeline.md#next-card-on-in-review`; `references/ownership.md#parent-done` |
| What only the owner decides; scope; exceptions; owner report | `references/ownership.md` |
| Runtime workarounds (mention = run, rerun, cancelled, model) | the `agent-runtime-gotchas` skill |

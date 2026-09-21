<!-- Reviewer report template. Pasted into the audit stage body in full after the line "Report format:" (pipeline.md#body-from-template). The first line of the report is the score line (review-cycle.md#score-line), the second is Scorecard (review-cycle.md#scorecard). -->
Round: <N> | Stage: <spec|arch|code> | Confirmed findings: <N> | Failed runs: <M> | Coverage: <full|partial|unknown>
Scorecard: <URL of the PR in the scorecard repository, file data/rows.d/<YYYY-MM-DD>-<task-slug>-<agent-slug>.csv>

<!-- Example score line passing scripts/parse-score-line.sh (held by CI): Round: 1 | Stage: code | Confirmed findings: 0 | Failed runs: 0 | Coverage: full -->

## Panel
| Agent | Question (question_type) | Confirmed | False | Unique | Failed (no/repeat/died) |
|---|---|---|---|---|---|

## Findings (registry)
| # | Title | Where (path:line) | Reproduced personally (yes/no, how) | State (open/closed/needs-decision) | Exception (accepted-risk/spun-out/awaiting-owner + reference) | Minimal fact |
|---|---|---|---|---|---|---|

## What the machine does not check
<…>

## Own misses
<…>

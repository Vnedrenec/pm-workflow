# Required checks contract — branch protection of `main`

Workspace rule: the required checks list is a contract file in the repository, not the PM's memory and not a GitHub UI setting by itself. This file is the single source of truth for which jobs must be green before a merge into `pm-workflow` `main`. Branch protection on `main` was enabled by the owner on 2026-09-18 (decision V4, D-8).

| job | workflow file | what it checks | required since |
|---|---|---|---|
| `check` | `.github/workflows/check.yml` | `scripts/check-rules.sh` (inside — `scripts/build-skills.sh --check` and the stop-word guard; the `--history` step — per the `SANITIZED_HISTORY` variable) + `scripts/parse-score-line.sh --self-test` | 2026-09-18 |

Renamed a job — edit this contract in the same PR and the branch protection setting (required status checks on `main`) before the merge: GitHub compares the job name literally, and a PR with a renamed job either does not merge or — if the old name was forgotten to be removed — merges without any check. Added or removed a required check — the same procedure: a row in the table, the branch protection setting, one PR.

# Required checks contract — branch protection of `main`

The required checks list is this file, not the PM's memory and not the GitHub UI alone. Branch protection on `main` enabled 2026-09-18 (D-8).

| job | workflow file | what it checks | required since |
|---|---|---|---|
| `check` | `.github/workflows/check.yml` | `scripts/check-rules.sh` (inside — `scripts/build-skills.sh --check`, the stop-word guard, the `--history` step per `SANITIZED_HISTORY`) + `scripts/parse-score-line.sh --self-test` | 2026-09-18 |

Renamed, added or removed a job — this table and the branch protection setting change in the same PR, before merge: GitHub matches the job name literally; a stale name merges without any check.

# Platform request: one barrier — one PM run

Status: prepared, NOT sent; sending needs a separate owner permission. The system child-completion notification is not visible through the `multica` CLI (`multica issue wakeup --help`, `events`, `list/get/runs`), so its key and deduplication cannot be inspected from here.

## Observed (incident AA, `docs/incidents.md#inc-aa`)

1. Stage 1 closes. The explicit wakeup `--until-children-done --stage 1 --mode continuous` fires (`condition.met`, `fire_count` 1) together with the system notification — one PM run.
2. The PM creates and promotes stage 2, disables the stage 1 wakeup.
3. ~40 s later the system notification wakes the PM again for stage 1. The explicit rule shows a single run; the repeat came from the system source. Run facts: children count 1 → 2, field `next_stage=2`.

Cost of the repeat: one run, 25 s, ~11k input, ~0.75k output, ~365k cache-read tokens. Cause inside the platform — hypothesis.

## Requested change

1. Deduplicate barrier signals BEFORE an LLM run is enqueued, key `parent_id + stage + completion generation` (generation grows only on not-all-terminal → all-terminal).
2. System notification and explicit `--until-children-done` wakeup for the same key share it: first consumes, second dropped or merged.
3. Adding a child to a LATER stage does not re-issue the completion of an earlier stage.
4. A retry after failed delivery keeps the key: one logical run per generation.
5. `done`/`cancelled` of a sub-issue keeps disabling that sub-issue's own wakeups; the parent-side key is unaffected.

## Acceptance scenarios (live on the platform)

| # | Scenario | Expected |
|---|---|---|
| 1 | Close stage N | one logical PM run |
| 2 | Create and promote stage N+1 | zero repeats for stage N |
| 3 | Close stage N+1 | one new run |
| 4 | Explicit wakeup and system notification fire in the same instant | one run |
| 5 | Delivery fails and is retried | one run for the generation |
| 6 | A sub-issue goes `done` | its wakeups disabled, the parent signal still fires |
| 7 | A stage misses the deadline | exactly one `wakeup.timeout` run |

Until this ships: `docs/pipeline.md#barrier-wakeup`, `#barrier-dedup`, `#compact-wake-read`.

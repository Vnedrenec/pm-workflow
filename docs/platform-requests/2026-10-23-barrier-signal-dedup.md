# Platform request: one barrier — one PM run

Status: prepared, NOT sent. Sending it to the platform team needs a separate owner permission. The platform source and the contract of the system child-completion notification are not reachable through the supported `multica` CLI (checked: `multica --help`, `multica issue wakeup --help`, `multica issue wakeup events`, `multica issue wakeup list/get/runs`); the system notification does not appear among the issue's wakeup rules, so its key and deduplication cannot be inspected or proven from here.

## Observed (incident AA, `docs/incidents.md#inc-aa`)

1. Stage 1 closes. The explicit wakeup `--until-children-done --stage 1 --mode continuous` fires (`condition.met`, `fire_count` 1) together with the system child-completion notification — the two merge into ONE PM run. Good.
2. The PM creates and promotes stage 2 and disables the stage 1 wakeup (`disabled_at` before the next event).
3. ~40 s later the system child-completion notification wakes the PM AGAIN for stage 1, which did not close a second time. The explicit stage 1 rule shows a single run, so the repeat came from the system source. The run facts showed the total count of children grow from 1 to 2 and a `next_stage=2` field.

Cost of the repeat: one run, 25 s, ~11k input, ~0.75k output, ~365k cache-read tokens. The cause inside the platform is a hypothesis, not an established defect.

## Requested change

1. Deduplicate barrier signals BEFORE an LLM run is enqueued, by the key `parent_id + stage + completion generation` (the generation grows only when the stage goes from not-all-terminal to all-terminal).
2. The system child-completion notification and an explicit `--until-children-done` wakeup for the same key share it: whichever fires first consumes it, the other is dropped (or merged into the same pending run).
3. Adding a child to a LATER stage (or any change of the children count) does not re-issue the completion of an earlier stage whose generation has not changed.
4. A retry after a failed delivery keeps the same key (exactly one logical run per generation).
5. `done`/`cancelled` of a sub-issue keeps disabling that sub-issue's own wakeups (current behaviour) — the parent-side key is unaffected.

## Acceptance scenarios (live, on the platform; none of them is proven by this repository)

| # | Scenario | Expected |
|---|---|---|
| 1 | Close stage N | one logical PM run |
| 2 | Then create and promote stage N+1 | zero repeats for stage N |
| 3 | Close stage N+1 | one new run |
| 4 | Explicit wakeup and system notification fire in the same instant | one run |
| 5 | Delivery of the run fails and is retried | still one run for the generation |
| 6 | A sub-issue goes `done` | its own wakeups are disabled, the parent signal still fires |
| 7 | A stage does not close within the deadline | exactly one `wakeup.timeout` run |

Until this ships, the regulation keeps both sources and makes the repeat cheap: `docs/pipeline.md#barrier-wakeup` (one-shot explicit wakeup), `#barrier-dedup` (`last_barrier_stage` no-op), `#compact-wake-read` (delta-only reads).

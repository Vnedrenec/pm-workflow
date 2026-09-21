# Card impact class and the round limit

Layer 2 of the workspace regulation. Rule format — `README.md`; rule address — `impact-class.md#<anchor>`. Sources of the text: the snapshot of the PM instructions as of 2026-09-18 (in the private archive; the section "Impact class and round limits", the owner decision of 2026-09-12), the source-project file `docs/engineering/pm-workflow.md` §2.9; the limits table — the regulation-extraction specification §7.2 (in the private archive) and the owner decisions V1–V2 of 2026-09-18 (`CHANGELOG.md`).

### The class is set before the promotion of stage 1 `[review: PM @ parent creation]`
<a id="classify-first"></a>

Every parent card receives an impact class at creation, before the first stage's promotion: `customers` / `money` / `availability` / `hygiene`. The class is written as the first line of the "Pipeline" section in the card description and into the parent metadata under the key `impact_class`. Doubt about the class — a question to the owner before the promotion of stage 1, not after a round (`ownership.md#class-doubt`). Owner: "resources are scarce, decisions on such questions should come earlier".

Incident: [I](incidents.md#inc-i) — six stages and three specification rounds on a card that touched neither customers, nor money, nor availability.

### `hygiene` — one round each, no cycle until convergence `[review: PM @ audit stage barrier]`
<a id="hygiene"></a>

For the `hygiene` class (affects neither customers, nor money, nor availability): the specification audit — exactly one round; the code review — exactly one round; the confirmed findings of the single round the author closes with one rework stage without a repeat audit; rows still open after it the PM marks `accepted-risk` with the reference = the owner decision on the class (the id of the comment that set `impact_class`) — a separate decision per row is not needed; the three-round circuit breaker does not apply — there is nothing to converge.

Incident: [I](incidents.md#inc-i) — owner decision 2026-09-12.

### Limits table per class `[review: PM @ audit stage barrier]`
<a id="limits-table"></a>

| Class | Specification rounds (max) | Code rounds (max) | Mandatory `arch` round | Basis |
|---|---|---|---|---|
| `hygiene` | 1 | 1 | no | owner 2026-09-12 ([I](incidents.md#inc-i)) |
| `customers` | until convergence, circuit breaker 3 | until convergence, circuit breaker 3 | no | owner 2026-08-13; confirmed 2026-09-18 (V1) |
| `availability` | until convergence, circuit breaker 3 | the same | no | owner 2026-08-13; confirmed 2026-09-18 (V1) |
| `money` | until convergence, circuit breaker 3 | until convergence, circuit breaker 3 | no (but see `#money-arch-auditor`) | owner 2026-09-18 (V2) |

"Until convergence" — `review-cycle.md#closure`: a round with zero confirmed at `Coverage: full` and an empty registry closes the cycle; one clean round is enough. The circuit breaker — `review-cycle.md#fuse`.

Incident: none

### `money`: in the first round the Reviewer must include the Architecture Auditor `[review: PM @ audit stage promotion]`
<a id="money-arch-auditor"></a>

For the `money` class, in the first audit round (specification and code) the Reviewer must include the Architecture Auditor in the panel; its run produces `Stage: arch` in the score line (`review-cycle.md#score-line`). A fourth round and a separate mandatory `arch` round are not introduced — circuit breaker 3, same as `customers`. The PM checks the panel composition in the round envelope (`pipeline.md#audit-envelope`) before promotion.

Incident: [N](incidents.md#inc-n) — owner decision 2026-09-18 (V2), no measurement.

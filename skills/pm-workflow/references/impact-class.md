# Card impact class and the round limit

Rule address — `impact-class.md#<anchor>`.

### The class is set before the promotion of stage 1 `[review: PM @ parent creation]`
<a id="classify-first"></a>

Every parent card gets a class at creation: `customers` / `money` / `availability` / `hygiene`. Written as the first line of the "Pipeline" section in the description and into parent metadata `impact_class`. Doubt — the owner before stage 1 (`ownership.md#class-doubt`).

### `hygiene` — one round each, no cycle `[review: PM @ audit stage barrier]`
<a id="hygiene"></a>

`hygiene` (affects neither customers, nor money, nor availability): specification audit — one round; code review — one round; the author closes confirmed findings in one rework stage without a repeat audit; rows still open — the PM marks `accepted-risk` with reference = the comment that set `impact_class`; the circuit breaker does not apply.

### Limits table per class `[review: PM @ audit stage barrier]`
<a id="limits-table"></a>

| Class | Specification rounds (max) | Code rounds (max) | Mandatory `arch` round |
|---|---|---|---|
| `hygiene` | 1 | 1 | no |
| `customers` | until convergence, circuit breaker 3 | until convergence, circuit breaker 3 | no |
| `availability` | until convergence, circuit breaker 3 | the same | no |
| `money` | until convergence, circuit breaker 3 | until convergence, circuit breaker 3 | no (see `#money-arch-auditor`) |

"Until convergence" — `review-cycle.md#closure`. Circuit breaker — `review-cycle.md#fuse`.

### `money`: the Architecture Auditor in the first round `[review: PM @ audit stage promotion]`
<a id="money-arch-auditor"></a>

First audit round (specification and code): the Reviewer includes the Architecture Auditor in the panel; its run gives `Stage: arch` in the score line. No separate mandatory `arch` round. The PM checks the panel in the round envelope (`pipeline.md#audit-envelope`) before promotion.

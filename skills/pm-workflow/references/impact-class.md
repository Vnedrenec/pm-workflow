# Card impact class and the round limit

Rule address — `impact-class.md#<anchor>`.

### The class is set before the promotion of stage 1 `[review: PM @ parent creation]`
<a id="classify-first"></a>

Every parent card receives an impact class at creation: `customers` / `money` / `availability` / `hygiene`. Written as the first line of the "Pipeline" section in the description and into the parent metadata key `impact_class`. Doubt about the class — a question to the owner before stage 1, not after a round (`ownership.md#class-doubt`).

### `hygiene` — one round each, no cycle `[review: PM @ audit stage barrier]`
<a id="hygiene"></a>

For `hygiene` (affects neither customers, nor money, nor availability): specification audit — exactly one round; code review — exactly one round; the author closes the confirmed findings with one rework stage without a repeat audit; rows still open after it the PM marks `accepted-risk` with the reference = the comment that set `impact_class`; the three-round circuit breaker does not apply.

### Limits table per class `[review: PM @ audit stage barrier]`
<a id="limits-table"></a>

| Class | Specification rounds (max) | Code rounds (max) | Mandatory `arch` round |
|---|---|---|---|
| `hygiene` | 1 | 1 | no |
| `customers` | until convergence, circuit breaker 3 | until convergence, circuit breaker 3 | no |
| `availability` | until convergence, circuit breaker 3 | the same | no |
| `money` | until convergence, circuit breaker 3 | until convergence, circuit breaker 3 | no (see `#money-arch-auditor`) |

"Until convergence" — `review-cycle.md#closure`: one round with zero confirmed at `Coverage: full` and an empty registry closes the cycle. Circuit breaker — `review-cycle.md#fuse`.

### `money`: the Architecture Auditor in the first round `[review: PM @ audit stage promotion]`
<a id="money-arch-auditor"></a>

For `money`, in the first audit round (specification and code) the Reviewer includes the Architecture Auditor in the panel; its run produces `Stage: arch` in the score line. No fourth round and no separate mandatory `arch` round. The PM checks the panel in the round envelope (`pipeline.md#audit-envelope`) before promotion.

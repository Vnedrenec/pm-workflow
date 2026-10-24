# Pipeline roles

Rule address — `roles.md#<anchor>`.

Code or design work is a parent card with stage sub-issues. Parent — the PM; sub-issues — executors. Stages are not planned up front: the server wakes the PM on every barrier closure, the PM reads the result and decides the next stage. Review rounds are a cycle (`review-cycle.md`).

### Role table `[review: PM @ stage creation]`
<a id="roles-table"></a>

| Stage | Executor | What it does |
|---|---|---|
| approach fork | Architect | fans independent opinions out across models, decides himself |
| plan (specification) | Architect | the specification another agent will work from |
| code | Builder | implementation per the specification |
| mechanical edit | Mechanic | renames, typos, formatting; a side branch, not a stage |
| audit | Reviewer | a review round; picks the auditors himself |
| technical verdict | Architect | which findings are real, which block |
| scope change | **owner** | a finding requires reworking the scope |
| acceptance | **owner** | `in_review → done` on the parent |

The specification file path is a project convention (layer 3, e.g. `docs/superpowers/plans/`).

### Conflicts of interest: author ≠ verifier `[review: PM @ stage creation]`
<a id="author-not-verifier"></a>

The Reviewer does not consult on intent. The Architect does not audit his own plan or findings. The Builder does not send his diff out for review (`pipeline.md#no-subagents`).

### Role limit: a stage executor does not rebuild the pipeline `[review: PM @ stage barrier]`
<a id="role-limit"></a>

`multica issue assign`, changing the status of someone else's card, creating sub-issues outside his own review round — PM powers. At the limit — stop: a comment with the justification and a hand-off specification (who / what / acceptance criteria); the task stays with the executor until the PM decides.

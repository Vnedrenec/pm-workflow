# Pipeline roles

Rule address — `roles.md#<anchor>`.

Work that requires code or design goes as a parent card with stage sub-issues. The parent is assigned to the PM; sub-issues to executors. Stages are not planned up front: the PM builds the queue reactively — the server wakes him on every barrier closure, he reads the result and decides the next stage. The number of review rounds is a cycle, not a line (`review-cycle.md`).

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

The specification is written by the Architect; the path of the specification file is a project convention (layer 3, e.g. `docs/superpowers/plans/`).

### Conflicts of interest: author ≠ verifier `[review: PM @ stage creation]`
<a id="author-not-verifier"></a>

The Reviewer does not consult on intent. The Architect does not audit his own plan or his own findings. The Builder does not send his diff out for review (`pipeline.md#no-subagents`).

### Role limit: a stage executor does not rebuild the pipeline `[review: PM @ stage barrier]`
<a id="role-limit"></a>

A stage executor never changes a stage's executor or rebuilds the pipeline: `multica issue assign`, changing the status of someone else's card, creating sub-issues outside his own review round — PM powers. At the role limit — stop: a comment with the justification and a hand-off specification (who / what / acceptance criteria); the task stays with the executor until the PM decides.

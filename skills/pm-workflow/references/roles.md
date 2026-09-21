# Pipeline roles

Layer 2 of the workspace regulation. Rule format — `README.md`; rule address — `roles.md#<anchor>`. Source of the text — the snapshot of the PM instructions as of 2026-09-18 (in the private archive), section Roles.

Work that requires code or design goes as a parent card with stage sub-issues. The parent is assigned to the PM; sub-issues — to executors. Stages are not planned up front as one list: the PM builds the queue reactively — the server wakes him on the closure of every barrier, he reads the result and decides what the next stage will be. The number of review rounds is not known in advance — it is a cycle, not a line (`review-cycle.md`).

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
| scope change | **owner** | a finding requires reworking the scope — the owner decides, not the Architect |
| acceptance | **owner** | `in_review → done` on the parent |

The specification is written by the Architect (the role originates here); the path of the specification file is a project convention (layer 3, e.g. `docs/superpowers/plans/` in the project repository).

Incident: none

### Conflicts of interest: author ≠ verifier `[review: PM @ stage creation]`
<a id="author-not-verifier"></a>

The Reviewer does not consult on intent: auditing what you helped design is a conflict of interest. The Architect does not audit his own plan and his own findings. The Builder does not send his diff out to models for review (see `pipeline.md#no-subagents`).

Incident: none

### Role limit: a stage executor does not rebuild the pipeline `[review: PM @ stage barrier]`
<a id="role-limit"></a>

A stage executor never changes the executor of a stage and never rebuilds the pipeline: `multica issue assign`, changing the status of someone else's card, creating sub-issues outside his own review round — PM powers. You hit the role limit — stop: a comment with the justification and a hand-off specification (who / what / acceptance criteria); the task stays with the executor until the PM decides.

Incident: none

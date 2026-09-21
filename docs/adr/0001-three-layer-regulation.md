# ADR 0001 — the workspace regulation in three layers, the source of truth is the `pm-workflow` repository

- Status: proposed (the specification stage of the regulation extraction, 2026-09-18); accepted by an owner decision at the acceptance of the parent.
- Author: Architect. Audit: Reviewer (one round, the `hygiene` class).
- Specification: in the private archive (the original regulation-extraction specification).
- Owner decision to start: 2026-09-18, reference D-7 in the private registry.

## Context

The pipeline regulation lives in two copies — the `instructions` field of the PM agent (17,684 characters) and the source-project file `docs/engineering/pm-workflow.md` (276 lines) — and in a third place mixed with runtime workarounds (the `agent-runtime-gotchas` skill). The copies already contradict each other (the numbers 2.7/2.8 mean different things; the round limit for the unprotected classes differs by a round). Incidents are cited by card numbers of the former workspace, which no longer resolve. The workarounds have no removal conditions. The skill cannot be updated without the risk of wiping someone else's edit (`config: {}` — `refresh` impossible).

## Decision

Four layers with dependencies only top-down:

| Layer | What | Where it lives | Who edits it | How it is delivered to agents |
|---|---|---|---|---|
| 0 | the Multica platform: the product's system instructions, the runtime brief | the product | nobody in the workspace | automatically |
| 1 | runtime workarounds with a removal condition | `pm-workflow/skills/agent-runtime-gotchas/SKILL.md` | PR to `pm-workflow` | `multica skill import --url … --on-conflict overwrite` once, then `multica skill refresh <id>`; the binding to agents is preserved |
| 2 | the workspace regulation: roles, pipeline, review cycle, impact classes, ownership, templates, CHANGELOG | `pm-workflow/docs/`, `templates/`, `CHANGELOG.md` — canon; `skills/pm-workflow/references/` — assembled copy, identity held by CI | PR to `pm-workflow`; a change in substance — only with a `CHANGELOG.md` entry and an owner decision | PM — the `pm-workflow` skill (`import`/`refresh`, autopilot after merge); auditors and builders — template blocks pasted into the sub-issue body; Architect — the "read" line in the body; owner — git |
| 3 | project-specific: project tracker, machine, deployment, secrets, required checks contract | the project repository (the project regulation file, e.g. `docs/engineering/pm-workflow.md`, `AGENTS.md`) | PR to the project | as before |

Additionally: `docs/incidents.md` — the incident resolver (anchor → primary record); every rule carries a holder label `[CI: check]` or `[review: <role> @ <point>]` and an `Incident:` line; a rule without an incident is a revision candidate (owner decision 2026-09-18, `CHANGELOG.md`); only an unused rule is removed, in agreement with the owner, with a `CHANGELOG.md` entry.

## Alternatives considered

**A. Workspace notes as canon, the source-project file a copy.** Rejected: the `instructions` field has no edit history and no diff; a divergence is found only by manual reconciliation (which is what happened); external reviewers and the owner see the field only through the CLI. The selection criterion — "an edit leaves a trace and passes review" — is not met.

**B. An index in the notes + `multica repo checkout` on every PM run.** No duplicate at all. Rejected by the PM's clarification (2026-09-18): files in git do not get into the run context by themselves, and the PM does not do a checkout at every barrier — a rule that requires an action before it has been read does not work.

**B′ (accepted). The `pm-workflow` skill as the delivery channel, `docs/` as canon.** The files of a skill must live inside its directory (the import takes `tree/<ref>/<path>`), therefore `skills/pm-workflow/references/` is a copy of `docs/` and `templates/`, assembled by `scripts/build-skills.sh` and checked with a `diff` in CI. This is a duplicate, but one that is machine-checkable: a divergence goes red on the PR instead of being discovered a week later by manual reconciliation. The canon stays in `docs/`, because the regulation is read not only by bound agents — the owner, the specification auditor, external reviewers. The option "canon in `skills/…/references/`, `docs/` — pointers" was rejected: it makes the owner read the document from a directory whose name says "service copy".

**C. Keep the regulation in the source project and reference it from other projects.** Rejected: a workspace regulation does not belong to a project; a second project would get a link to someone else's repository, and a regulation edit would run the project's CI (`gate`, ~20 minutes) for the sake of text.

**D. Keep the through numbering of rules (2.1–2.9).** Rejected: the numbers already mean different things in the two copies; inserting a rule shifts everything below. A rule address = `file#anchor`. In the source project the numbers §2.4–2.9 remain as address stubs, because 22 specifications already reference them.

## Consequences

- Plus: one edit — one PR — one diff; every rule is addressable and script-checkable; workarounds get a lifetime; the skill is updated with a `refresh` without the risk of a wipe.
- Minus: the assembled copy in `skills/pm-workflow/references/` is a second instance of the text (held by CI); skill synchronization after merge is an autopilot with a webhook and a daily backup trigger, that is, one more moving part; the former workspace's incidents in the resolver are retellings, not primaries.
- Blast radius: only the PM depends on the `pm-workflow` skill; the other agents receive the rules through template blocks in sub-issue bodies and the `agent-runtime-gotchas` skill. Rollback — the snapshot of the PM instructions from the private archive back into `instructions`, unbind the `pm-workflow` skill from the PM.

## What proves the decision works

30 days after the notes were applied: (1) the `content_hash` of the `pm-workflow` skill = the sha256 of `SKILL.md` in `main` (the autopilot works, no UI edits); (2) every review round closed with a `Scorecard:` line; (3) at least one layer 1 item removed or re-verified per its own condition — otherwise the removal conditions are decorative; (4) the audit and code stage bodies contain the pasted template blocks, and no round was lost for the lack of a score line.

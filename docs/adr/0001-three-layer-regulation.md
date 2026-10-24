# ADR 0001 — the workspace regulation in layers, source of truth the `pm-workflow` repository

- Status: accepted (owner decision at parent acceptance; proposed 2026-09-18, D-7).
- Author: Architect. Audit: Reviewer, one round, class `hygiene`.
- Specification: private archive.

## Context

The regulation lived in three copies: the PM `instructions` field (17,684 characters), the source-project file `docs/engineering/pm-workflow.md` (276 lines), and the `agent-runtime-gotchas` skill mixed with runtime workarounds. The copies contradicted each other (rule numbers 2.7/2.8 meant different things; round limits differed by one). Incidents were cited by card numbers of a former workspace that no longer resolve. The skill could not be updated without wiping someone else's edit (`config: {}`, no `refresh`).

## Decision

Four layers, dependencies top-down only (table — `README.md`, "Layers"). Every rule carries a holder label `[CI: check]` or `[review: <role> @ <point>]`; a rule is removed only when unused, with the owner, with a `CHANGELOG.md` entry. `docs/incidents.md` resolves incident anchors. The per-rule `Incident:` line of the original decision was dropped 2026-10-23 (`CHANGELOG.md`): history stays in `CHANGELOG.md` and `docs/incidents.md`, not in the text agents read every run.

## Alternatives

**A. Workspace notes as canon, project file a copy.** Rejected: the `instructions` field has no history or diff; divergence is found only by manual reconciliation.

**B. Index in the notes + `multica repo checkout` on every PM run.** Rejected: files in git do not enter the run context by themselves; a rule that requires an action before it is read does not work.

**B′ (accepted). The `pm-workflow` skill as delivery, `docs/` as canon.** Skill files must live inside the skill directory, so `skills/pm-workflow/references/` is a copy of `docs/` and `templates/`, built by `scripts/build-skills.sh` and diffed in CI. Canon stays in `docs/` because the owner, specification auditors and external reviewers read it there.

**C. Keep the regulation in the source project.** Rejected: a workspace regulation does not belong to one project; a text edit would run the project's 20-minute CI.

**D. Through numbering of rules (2.1–2.9).** Rejected: numbers already diverged; insertion shifts everything below. Address = `file#anchor`. The source project keeps §2.4–2.9 as address stubs for 22 existing specifications.

## Consequences

- Plus: one edit — one PR — one diff; every rule addressable and script-checkable.
- Minus: the assembled copy is a second instance of the text (held by CI); skill synchronization is one more moving part (`docs/autopilots/refresh-skills.md`); former-workspace incidents are retellings, not primaries.
- Blast radius: only the PM depends on the `pm-workflow` skill. Rollback — the PM instructions snapshot from the private archive, unbind the skill.

## Proof after 30 days

(1) `content_hash` of the `pm-workflow` skill = sha256 of `SKILL.md` in `main`; (2) every review round closed with a `Scorecard:` line; (3) audit and code stage bodies carry the pasted template blocks, no round lost for lack of a score line.

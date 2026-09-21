# pm-workflow

Workspace regulation for the agent pipeline: roles, pipeline, review cycle, impact classes, ownership, templates. Source of truth for Multica workspace notes and the PM skills. Decisions: `docs/adr/0001-three-layer-regulation.md` (three layers), `docs/adr/0002-public-repository-sanitization.md` (a public repository without the internal workings); the regulation-extraction specification is in the private archive, the sanitization specification is `docs/superpowers/plans/2026-09-18-sanitize-pm-workflow.md`.

## Layer map

| Layer | What | Where it lives | Who edits it | How it is delivered |
|---|---|---|---|---|
| 0 | the Multica platform: system instructions, runtime brief | the product | nobody in the workspace | automatically, every run |
| 1 | runtime workarounds, each with a removal condition | `skills/agent-runtime-gotchas/SKILL.md` | PR here | `multica skill import --url … --on-conflict overwrite` once, then `multica skill refresh <id>` (autopilot after merge) |
| 2 | pipeline regulation: `docs/roles.md`, `docs/pipeline.md`, `docs/review-cycle.md`, `docs/impact-class.md`, `docs/ownership.md`, `templates/`, `CHANGELOG.md` | `docs/`, `templates/` — canon; `skills/pm-workflow/references/` — assembled copy, identity held by CI | PR here; a change in substance — only with a `CHANGELOG.md` entry and an owner decision | PM — the `pm-workflow` skill; auditors and builders — template blocks pasted into the sub-issue body; Architect — the "read" line in the body; owner — git |
| 3 | project-specific: project tracker, machine, deployment, secrets, required checks contract | the project repository (the project regulation file, e.g. `docs/engineering/pm-workflow.md`, `AGENTS.md`) | PR to the project | as before |

Dependencies go only top-down: layer 2 does not override layer 0. The text for workspace notes and the PM `instructions` is in the private workspace registry (applied by the PM after owner acceptance). The snapshot of the PM `instructions` before the extraction is in the private archive (rollback point).

## Rule format

One rule is one `###` heading with a holder label at the end, one anchor `<a id="…">`, an `Incident:` line:

```markdown
### <Rule name> `[review: PM @ stage barrier]`
<a id="code-barrier"></a>

<Text: who does what and when; what counts as a violation.>

Incident: [H](incidents.md#inc-h) — owner decision 2026-09-14.
```

The label is one of two: `[CI: check]` (held by `scripts/check-rules.sh` in the `check` job) or `[review: <role> @ <point>]`, role ∈ {PM, Reviewer, Architect, Owner}. There is no third; a rule without a holder does not exist. The label changes in the same PR as the check. A rule address is `<file>#<anchor>`; there are no through numbers; the index is `docs/rule-index.tsv`. The layer 1 item format (five lines: Symptom / Cause / Workaround / Incident / Removal condition) is in `skills/agent-runtime-gotchas/SKILL.md` itself.

## Rule without an incident — revision candidate

The line `Incident: none` is allowed, but such a rule is a revision candidate (list: `bash scripts/check-rules.sh --list-no-incident`; once a quarter the autopilot raises it, `docs/autopilots/rules-without-incident.md`). Only rules that are not used are removed, and only in agreement with the owner — with a `CHANGELOG.md` entry. Owner decision 2026-09-18 (D-8).

## How to reference an incident

`docs/incidents.md` is the public resolver: anchor `inc-<letter>` → letter → symptom → consequence → rules. From `docs/*.md` — `incidents.md#inc-b`; from `README.md`/`CHANGELOG.md` — `docs/incidents.md#inc-b`; from a skill — as text `docs/incidents.md#inc-b`. The public tree has no tracker card identifiers, comments, people, or projects — the guard holds that (`scripts/check-rules.sh`, the "stop words" criterion). The mapping of a letter to a card, date, and primary record, and of an owner-decision reference `D-N` to a card and comment, is kept in the private workspace registry (`pm-workflow/incidents-private.md` there), outside this repository.

A new incident is a new letter (the next in the alphabet; after `Z` — `AA`) and two lines: the public one here (symptom · consequence · rules, no stop words) and the private one in the registry (card, date, primary record). A new owner decision is a new `D-N`: publicly the date and number in `CHANGELOG.md`, privately the card and comment. A new name (project, agent, person, repository) — a line into the private stop-word dictionary and an update of the `STOP_WORDS_PRIVATE` secret (see "How to edit").

## How to edit

1. PR to this repository; the title carries the card slug in the bare-number form: `<type>(<scope>): <gist> (card N)` (rule `pipeline.md#pr-slug`; the slug form is a convention of this repository: the tracker prefix is a stop word). CI (`.github/workflows/check.yml`, job `check`) runs `scripts/check-rules.sh` (specification criteria, inside — `scripts/build-skills.sh --check` and the stop-word guard) and `scripts/parse-score-line.sh --self-test`.
2. Stop-word guard: public structural patterns — `scripts/stop-words.txt` (card identifiers, UUID, e-mail, GitHub URLs, `owner/repository#N` links), allowed exceptions — `scripts/stop-words-allow.txt`; the private literal list is supplied to CI by the `STOP_WORDS_PRIVATE` secret (locally — `STOP_WORDS_PRIVATE_FILE=<path> bash scripts/check-rules.sh --show`). The guard checks the tree, file names, the PR title, and the commit messages of the range; in CI it prints only `file:line` and the pattern number. A legitimate token went red — a line in `stop-words-allow.txt`, the pattern is not weakened. A new name — a line into the private list and `gh secret set STOP_WORDS_PRIVATE -R <owner>/<repository> < <private list>`.
3. You edit `docs/` or `templates/` — you run `bash scripts/build-skills.sh` and commit `skills/pm-workflow/references/`; never hand-edit `references/`.
4. A rule change in substance — a `CHANGELOG.md` entry (format there) with the owner decision reference; without an entry — do not change.
5. After merge the autopilot `pm-workflow: refresh skills` updates the skills (`docs/autopilots/refresh-skills.md`) with `multica skill refresh`. `multica skill update` for the skills from `skills/` is forbidden; a `content_hash` divergence from `main` at refresh is an incident.

## Tree

`docs/` — layer 2 rules, `docs/incidents.md`, `docs/rule-index.tsv`, `docs/required-checks.md` (the required checks contract for branch protection of `main`), `docs/adr/`, `docs/autopilots/`, `docs/superpowers/plans/`; `templates/subtask.md`, `templates/review-report.md`, `templates/handoff-comment.md`; `skills/agent-runtime-gotchas/`, `skills/pm-workflow/` (+ `references/`); `scripts/check-rules.sh`, `scripts/build-skills.sh`, `scripts/parse-score-line.sh`, `scripts/stop-words.txt`, `scripts/stop-words-allow.txt`, `scripts/required-lines/subtask.txt`, `scripts/fixtures/score-line/`; `.github/workflows/check.yml`; `CHANGELOG.md`.

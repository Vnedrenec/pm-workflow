# pm-workflow

Regulation of the agent pipeline: roles, pipeline, review cycle, impact classes, ownership, templates. Canon for the Multica workspace notes and the PM skills. Decisions: `docs/adr/`.

## Layers

| Layer | What | Where | Edited by |
|---|---|---|---|
| 0 | Multica platform: system instructions, runtime brief | the product | nobody here |
| 1 | runtime workarounds | `skills/agent-runtime-gotchas/SKILL.md` | PR here |
| 2 | pipeline regulation | `docs/*.md`, `templates/`, `CHANGELOG.md` — canon; `skills/pm-workflow/references/` — copy built by `scripts/build-skills.sh`, identity held by CI | PR here; a change in substance needs a `CHANGELOG.md` entry and an owner decision |
| 3 | project-specific: tracker, machine, deployment, secrets, required checks | the project repository (`docs/engineering/pm-workflow.md`, `AGENTS.md`) | PR to the project |

Dependencies go top-down only. Delivery: the PM reads layer 2 through the `pm-workflow` skill; auditors and builders get template blocks pasted into sub-issue bodies; every agent carries `agent-runtime-gotchas`.

## Rule format

One rule = one `###` heading with a holder label and one anchor. Body: who does what and when, what counts as a violation. No incident lines, no dates, no narrative — history lives in `CHANGELOG.md` and `docs/incidents.md`.

```markdown
### <Rule name> `[review: PM @ stage barrier]`
<a id="code-barrier"></a>

<Text.>
```

Labels: `[CI: check]` (held by `scripts/check-rules.sh`) or `[review: <role> @ <point>]`, role ∈ {PM, Reviewer, Architect, Owner}. The label changes in the same PR as the check. Rule address — `<file>#<anchor>`; index — `docs/rule-index.tsv`. Layer 1 item format: `### \`<slug>\` — <title>`, one anchor.

## Incidents and decisions

`docs/incidents.md`: anchor `inc-<letter>` → symptom → consequence → rules. Referenced from `CHANGELOG.md`, read by people, not shipped in the skill. Letter ↔ card and date, `D-N` ↔ comment live in the private workspace registry. New incident — the next letter (after `Z` — `AA`): one public row here, one private row there. New owner decision — the next `D-N`. New name (project, agent, person, repository) — a line in the private stop-word list and a new `STOP_WORDS_PRIVATE` secret.

## Editing

1. PR; title `<type>(<scope>): <gist> (card N)` — bare number, the tracker prefix is a stop word. CI (`.github/workflows/check.yml`): `scripts/check-rules.sh` and `scripts/parse-score-line.sh --self-test`.
2. Stop-word guard: structural patterns in `scripts/stop-words.txt`, exceptions in `scripts/stop-words-allow.txt`, literal names in the `STOP_WORDS_PRIVATE` secret (locally `STOP_WORDS_PRIVATE_FILE=<path> bash scripts/check-rules.sh --show`). Checks the tree, file names, PR title and commit messages; CI prints only `file:line` and the pattern number. False positive — a line in the allow list, never a weaker pattern. New name — `gh secret set STOP_WORDS_PRIVATE -R <owner>/<repository> < <private list>`.
3. Edited `docs/` or `templates/` — `bash scripts/build-skills.sh`, commit `references/`. Never hand-edit `references/`.
4. Rule change in substance — a `CHANGELOG.md` entry with the owner decision reference.
5. Server skills: both skills are imported from this repository (`config.origin` → `skills/<name>` on `main`). After merge: `multica skill refresh <id>` for `pm-workflow` and `agent-runtime-gotchas`, then `multica skill get <id> --with-content` and compare with the tree (`docs/autopilots/refresh-skills.md`). `multica skill update` on these skills is forbidden: the next refresh overwrites it.

## Tree

`docs/` — rules, `incidents.md`, `rule-index.tsv`, `required-checks.md`, `adr/`, `autopilots/`, `platform-requests/`; `templates/`; `skills/`; `scripts/`; `.github/workflows/check.yml`; `CHANGELOG.md`.

# ADR 0002 — a depersonalized public repository: new history, private resolver, two-part stop-word dictionary

- Status: proposed (the specification stage, 2026-09-18); accepted by an owner decision at the acceptance of the parent card.
- Author: Architect. Audit: Reviewer (one round, the `hygiene` class).
- Specification: `docs/superpowers/plans/2026-09-18-sanitize-pm-workflow.md` (in the archive tree the file name carries the card slug — see the specification, §5).
- Owner decision to start: 2026-09-18, reference D-9 in the private registry.

## Context

The regulation delivery layer (`multica skill import --url`) works only with public GitHub. The repository contains the workspace's internal workings: project and organization names, tracker card and comment identifiers, links to private repositories and documents, the snapshot of the PM instructions, agent and people names, incident details. The owner decided (2026-09-18): publish only after sanitization; a temporary import as an archive was rejected. Inventory: 260 lines in the working tree (without the assembled skill copy) and 635 added lines in the history of 11 commits contain stop words; there is no clean commit in the history — confidential material sits in every one of them.

## Decision

Three linked decisions.

**1. History: a new repository with a single commit; the old one — a private archive.** The sanitized tree is assembled by a PR into the current (private) repository, passes audit and CI, and after the merge is exported (`git archive`) into a new empty repository as a single commit. The old repository is renamed and archived (read-only), it stays private; the new one receives the former name, so the address in the workspace registry and the skill import URLs do not change.

**2. Private resolver.** The public `docs/incidents.md` keeps incidents in sanitized form: letter ids (`A`, `B`, … `Z`, `AA`, …), anchor `inc-<id>`, symptom, consequence, the rules that rely on them. The mapping "letter ↔ card, date, primary record" and the owner-decision references (`D-N` ↔ card, comment) are kept in the private workspace registry, outside the public repository. Rules and layer 1 items reference only letters; the `Decision:` lines in `CHANGELOG.md` reference the date and `D-N`.

**3. A two-part stop-word dictionary and a guard.** The public part (`scripts/stop-words.txt`) — only structural patterns: the tracker card identifier format (`PREFIX-N`), the UUID format, the e-mail format, GitHub URLs. The private part (literal names of projects, organizations, repositories, agents, people, short ids) lives in the private registry and is supplied to CI as a repository secret. The guard in `scripts/check-rules.sh` checks the tree, file names, the PR title, and the commit messages of the PR range, and in the new repository — the whole history; any match is a non-zero exit with `file:line` and the pattern number, without printing the matched text (everyone can read the Actions logs of a public repository).

## Alternatives considered

**History A. `git filter-repo` over the dictionary with a force-push into the same repository (branch protection removed and restored).** Rejected for three reasons. (1) GitHub does not delete commits on a force-push: old SHAs remain reachable through the `refs/pull/N/head` of the three merged PRs and by direct link; the cleanup requires contacting GitHub support and cannot be verified from inside the workspace. After the move to public, a leak via an old SHA is exactly what we are avoiding. (2) Dictionary substitution across 11 commits, where every commit contains stop words (635 lines), yields a history in which the original specification and the instructions snapshot still describe the internal workings — the substitution does not remove the meaning. The value of such a history for a public reader is zero. (3) The workspace checkout cache and the agents' working copies hold the old SHAs; after a force-push every working copy diverges from `origin`. The selection criterion — "a leak is impossible by construction, not by discipline" — is not met.

**History B. An orphan branch and a force-push into the same repository.** Cheaper than A (no `filter-repo`), but the same reason (1): old commits remain reachable through the PR refs. Rejected.

**History C (accepted). A new repository.** The only option under which the public repository physically contains not a single object with stop words. Price: owner operations (rename, creation, secret, variable, branch protection — about 20 minutes), re-registration of the workspace checkout cache, the loss of the public history of three PRs (it stays in the private archive).

**Option C′. A new repository under a different name, the old one not renamed.** Rejected: the address in the workspace registry, the import URLs of both skills, the autopilot and notes texts would change; renaming the old repository before creating the new one with the former name removes all of that in a single operation.

**Resolver A. Keep the card identifiers, remove only the project names.** Rejected: the identifier prefix is the project/workspace name (the owner explicitly included prefixes in the confidential checklist); an identifier without the prefix is a number meaningless to the reader but of no use to the rule either. A rule needs the symptom and the consequence, not a number.

**Resolver B. The date as the public key of an incident.** Rejected: five incidents of the former workspace have no exact date; two incidents fall on one day; a date is a detail of an organization's activity (schedules), a letter is not.

**Resolver C (accepted). A letter id + a private mapping table.** One address per incident, surviving both a workspace move and publication.

**Dictionary A. One public file with literal names.** Rejected: the dictionary itself would become a leak — a public file with the names of projects, organizations, and people. This is a contradiction in the original stage specification (the dictionary of "project names" in a public repository); it is removed by the split.

**Dictionary B. A fully private dictionary, the guard local only.** Rejected: a guard without CI is discipline, not a gate; the `[CI: check]` rule requires a machine check on every PR.

**Dictionary C (accepted). Public structural patterns + private literals as a CI secret.** Secrets are unavailable to PRs from forks — for them the guard goes red with the message "private dictionary not supplied"; PRs into this repository are made only by workspace agents, forks are not expected.

## Consequences

- Plus: the public repository contains no objects with stop words by construction; the guard holds that on every PR and across the whole history; the regulation keeps its evidentiary force (symptom · consequence · rule) without exposing cards.
- Minus: two places for one incident (a public row + a private row) — adding an incident requires two PRs; the private dictionary is a secret the owner updates by hand when a new name appears; an incident letter tells the reader nothing without the table — compensated by the "Symptom" and "Consequence" columns.
- Blast radius of a wrong decision: if the private dictionary is incomplete — one name goes public; it is discovered by reading at the owner's acceptance (he is the only one who knows the full list of names), cured by a PR and a new secret; the new repository's history becomes dirty again — then the "new repository" operation repeats (the same price, 20 minutes of the owner). If the workspace checkout cache does not survive the history change — `multica repo remove`/`add`; if that does not help — an owner operation on the workspace machine.

## What proves the decision works

(1) In the new repository `git log --all -p` over the combined dictionary gives 0 matches — the command is in the code stage report. (2) The guard goes red on four provocations (a stop word in a file, in a file name, in the PR title, in a commit message) — commands and output in the report. (3) 30 days after publication: the import and `refresh` of both skills work from the public URL; not a single PR into the public repository closed by a red guard because of a false positive of the structural patterns (otherwise — extend `scripts/stop-words-allow.txt`, do not weaken the pattern).

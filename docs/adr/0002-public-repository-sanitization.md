# ADR 0002 — a depersonalized public repository: new history, private resolver, two-part stop-word dictionary

- Status: accepted (owner decision at parent acceptance; proposed 2026-09-18, D-9).
- Author: Architect. Audit: Reviewer, one round, class `hygiene`.
- Specification: the sanitization plan, kept in the private archive (removed from the public tree 2026-10-24).

## Context

Skill delivery (`multica skill import --url`) works only from public GitHub. The repository held project and organization names, tracker card and comment ids, links to private repositories, the PM instructions snapshot, agent and people names, incident details: 260 lines in the tree and 635 added lines across 11 commits; no clean commit existed. Owner decision: publish only after sanitization; a temporary archive import rejected.

## Decision

1. **History.** The sanitized tree passes audit and CI as a PR into the private repository, then `git archive` → a new empty repository as one commit. The old repository is renamed and archived private; the new one takes the former name, so registry addresses and import URLs stay.
2. **Private resolver.** Public `docs/incidents.md` keeps letter ids, symptom, consequence, rules. Letter ↔ card/date/primary and `D-N` ↔ card/comment live in the private workspace registry.
3. **Two-part dictionary and guard.** Public `scripts/stop-words.txt` — structural patterns only (card id format, UUID, e-mail, GitHub URLs). Private literals — a CI secret. The guard in `scripts/check-rules.sh` checks tree, file names, PR title, commit messages and, in the new repository, the whole history; a match is a non-zero exit with `file:line` and pattern number, never the matched text.

## Alternatives

**History A. `git filter-repo` + force-push into the same repository.** Rejected: old SHAs stay reachable via `refs/pull/N/head` and direct links; substitution across 11 dirty commits leaves the meaning; every working copy diverges after force-push. Criterion "a leak is impossible by construction" not met.

**History B. Orphan branch + force-push.** Same reachability problem. Rejected.

**History C (accepted). New repository.** The only option with zero objects containing stop words. Price: ~20 minutes of owner operations, checkout-cache re-registration, public history of three PRs lost (kept in the archive).

**C′. New repository under a new name.** Rejected: registry address, import URLs, autopilot and notes would all change.

**Resolver A. Keep card ids, drop project names.** Rejected: the prefix is the project name; a bare number is useless to the rule.

**Resolver B. Date as the public key.** Rejected: five incidents lack an exact date, two share a day, dates leak schedules.

**Resolver C (accepted). Letter id + private table.**

**Dictionary A. One public file with literal names.** Rejected: the dictionary itself leaks.

**Dictionary B. Fully private, local guard only.** Rejected: a guard without CI is discipline, not a gate.

**Dictionary C (accepted). Public patterns + private literals as a secret.** Fork PRs get no secret and go red with "private dictionary not supplied"; forks are not expected.

## Consequences

- Plus: no stop-word objects by construction; the guard holds it on every PR and across history; rules keep symptom · consequence · rule without exposing cards.
- Minus: two rows per incident (two PRs); the private dictionary is a hand-maintained secret; a letter means nothing without the table — compensated by the Symptom and Consequence columns.
- Blast radius: an incomplete private dictionary leaks one name; found at owner acceptance, cured by a PR, a new secret and, if history is dirty again, a repeat of the new-repository operation. Checkout cache broken by the history change — `multica repo remove`/`add`, then an owner operation on the machine.

## Proof

(1) `git log --all -p` over the combined dictionary — 0 matches, command in the code stage report. (2) The guard goes red on four provocations: a stop word in a file, a file name, the PR title, a commit message. (3) 30 days after publication: import and `refresh` of both skills work from the public URL; no PR closed by a false positive of a structural pattern (otherwise extend `scripts/stop-words-allow.txt`, never weaken a pattern).

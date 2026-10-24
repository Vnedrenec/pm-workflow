# Autopilot: refresh skills after merge

Status: not operational. The workspace skills `agent-runtime-gotchas` and `pm-workflow` have no import origin (`config.origin` empty), so `multica skill refresh` has nothing to pull. Until the owner re-imports them from this repository (`multica skill import --url … --on-conflict overwrite` — rebinds agents, owner operation), synchronization is manual: `README.md`, "Editing", step 5.

Design once re-imported — triggers: GitHub webhook on push to `main` (URL and secret in the repository settings, not in documents) plus a nightly backup run. Mode `run_only`: no card, the trace is `multica autopilot runs`.

```
multica repo checkout <URL of this repository>
for id in <id agent-runtime-gotchas> <id pm-workflow>; do
  multica skill get $id --output json > before-$id.json          # content_hash before
  multica skill refresh $id --output json > after-$id.json        # 422/409/5xx — stop, comment to the owner
done
```

Check: `content_hash` from `before-*.json` vs `sha256sum` of the matching `SKILL.md` in `main` BEFORE the refresh. Differ AND `main` unchanged since the last run (`git log -1 --format=%cI -- skills/`) — someone edited the skill in the UI: a row in the private registry and a `hygiene` card to the owner. No `2>&1` when parsing JSON.

# Autopilot: refresh skills after merge

Synchronizes the `agent-runtime-gotchas` and `pm-workflow` skills with `main` of this repository. Both skills carry `config.origin` → `skills/<name>` on `main`, so `multica skill refresh <id>` re-downloads them, keeping id and agent bindings. Until the autopilot is created, the PM or the owner runs the steps by hand after every merge that touches `skills/`.

Triggers: GitHub webhook on push to `main` (URL and secret in the repository settings, not in documents) plus a nightly backup run. Mode `run_only`: no card, the trace is `multica autopilot runs`.

```
multica repo checkout <URL of this repository>
for id in <id agent-runtime-gotchas> <id pm-workflow>; do
  multica skill get $id --output json > before-$id.json          # content_hash before
  multica skill refresh $id --output json > after-$id.json        # 422/409/5xx — stop, comment to the owner
done
```

Check: `content_hash` from `before-*.json` vs `sha256sum` of the matching `SKILL.md` in `main` BEFORE the refresh. Differ AND `main` unchanged since the last run (`git log -1 --format=%cI -- skills/`) — someone edited the skill in the UI: a row in the private registry and a `hygiene` card to the owner. No `2>&1` when parsing JSON.

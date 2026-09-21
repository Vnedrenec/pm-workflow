Synchronization of the `agent-runtime-gotchas` and `pm-workflow` skills with `main` of the `pm-workflow` repository after a merge. Triggers: a GitHub webhook on push to `main` (the owner creates the URL and secret in the repository settings, they are in no documents) and a backup daily run at night (the schedule and time zone are configured in the autopilot itself). Mode `run_only`: no card is created, the trace of the run is the status in `multica autopilot runs`.

Run steps:

```
multica repo checkout <URL of this repository>
for id in <id agent-runtime-gotchas> <id pm-workflow>; do
  multica skill get $id --output json > before-$id.json          # content_hash before
  multica skill refresh $id --output json > after-$id.json        # 422/409/5xx — stop, a comment to the owner
done
```

Check: compare the `content_hash` from `before-*.json` with the `sha256sum` of the corresponding `SKILL.md` from `main` BEFORE the refresh. They differ AND `main` did not change since the last run (`git log -1 --format=%cI -- skills/`) — someone edited the skill in the UI; that is an incident: a row in the private workspace registry (a PR) and a `hygiene`-class card to the owner. Do not use `2>&1` when parsing JSON.

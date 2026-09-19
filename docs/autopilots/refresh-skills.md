Синхронизация скиллов `agent-runtime-gotchas` и `pm-workflow` с `main` репозитория `pm-workflow` после мержа. Триггеры: вебхук GitHub на push в `main` (URL и секрет заводит владелец в настройках репозитория, в документах их нет) и запасной ежедневный прогон ночью (расписание и пояс настраиваются в самом автопилоте). Режим `run_only`: карточка не создаётся, след прогона — статус в `multica autopilot runs`.

Шаги прогона:

```
multica repo checkout <URL этого репозитория>
for id in <id agent-runtime-gotchas> <id pm-workflow>; do
  multica skill get $id --output json > before-$id.json          # content_hash до
  multica skill refresh $id --output json > after-$id.json        # 422/409/5xx — стоп, комментарий владельцу
done
```

Проверка: сравнить `content_hash` из `before-*.json` с `sha256sum` соответствующего `SKILL.md` из `main` ДО refresh. Не совпало И `main` не менялся с прошлого прогона (`git log -1 --format=%cI -- skills/`) — кто-то правил скилл в UI; это инцидент: строка в приватном реестре воркспейса (PR) и карточка класса `гигиена` владельцу. `2>&1` при разборе JSON не использовать.
